#!/usr/bin/env node
// ---------------------------------------------------------------------------
// sync-workflow-status.js
//
// Adds workflow_status field to the intake_submissions table in Airtable
// (which maps to the applications table in PostgreSQL), then populates
// existing records with realistic workflow statuses.
//
// Applications go through: intake → assessment → SOW → contract → cases.
// Workflow status lives on the APPLICATION, not the case.
//
// Usage:
//   node sync-workflow-status.js          # Add field + populate
//   node sync-workflow-status.js --dry    # Show what would happen
//   node sync-workflow-status.js --reset  # Clear all workflow_status values
// ---------------------------------------------------------------------------

require("dotenv").config({ path: __dirname + "/../.env" });
const Airtable = require("airtable");

const apiKey = process.env.VUE_APP_AIRTABLE_API_KEY;
const baseId = process.env.VUE_APP_AIRTABLE_BASE;
const dryRun = process.argv.includes("--dry");
const resetOnly = process.argv.includes("--reset");

if (!apiKey || !baseId) {
  console.error("ERROR: VUE_APP_AIRTABLE_API_KEY and VUE_APP_AIRTABLE_BASE must be set in .env");
  process.exit(1);
}

const base = new Airtable({ apiKey }).base(baseId);
const TABLE_NAME = "applications";  // NOT cases — workflow lives on applications
const FIELD_NAME = "workflow_status";

// Workflow status options
const WORKFLOW_STATUSES = [
  "assessment-ready",
  "in-assessment",
  "assessed",
  "ready-for-contract",
  "contracted",
  "in-progress",
  "completed"
];

// Assignment strategy — distribute across existing records
function assignWorkflow(recordIndex, totalRecords) {
  if (resetOnly) return null;
  // Distribute: ~30% assessment-ready, ~20% in-assessment, ~25% assessed, ~25% ready-for-contract
  const r = recordIndex / totalRecords;
  if (r < 0.30) return "assessment-ready";
  if (r < 0.50) return "in-assessment";
  if (r < 0.75) return "assessed";
  return "ready-for-contract";
}

async function main() {
  console.log(`Base: ${baseId} | Table: ${TABLE_NAME}`);
  console.log(dryRun ? "--- DRY RUN ---" : "--- LIVE ---");

  // Step 1: Check if workflow_status field exists
  console.log("\n1. Checking for workflow_status field...");

  // Airtable doesn't have a simple "list fields" API in the SDK,
  // so we'll try to create the field and catch the "already exists" error.
  // Actually, we need to use the Airtable API to create the field.
  // The SDK doesn't support schema modifications directly.
  // We'll use the REST API instead.

  const fetch = (await import("node-fetch")).default;

  // Check fields via API
  const fieldsUrl = `https://api.airtable.com/v0/meta/bases/${baseId}/tables`;
  const fieldsResp = await fetch(fieldsUrl, {
    headers: { Authorization: `Bearer ${apiKey}` }
  });

  if (!fieldsResp.ok) {
    console.error(`Failed to fetch table schema: ${fieldsResp.status} ${fieldsResp.statusText}`);
    console.log("NOTE: You may need the 'schema:base:read' scope on your PAT.");
    console.log("Falling back to creating the field via the records API...");
    await createFieldViaRecords();
    return;
  }

  const schema = await fieldsResp.json();
  const casesTable = schema.tables.find(t => t.name === TABLE_NAME);

  if (!casesTable) {
    console.error(`Table "${TABLE_NAME}" not found in base ${baseId}`);
    process.exit(1);
  }

  const existingField = casesTable.fields.find(f => f.name === FIELD_NAME);

  if (existingField) {
    console.log(`   ✓ Field "${FIELD_NAME}" already exists (type: ${existingField.type})`);
  } else {
    console.log(`   ✗ Field "${FIELD_NAME}" does not exist. Creating...`);

    if (dryRun) {
      console.log("   [DRY RUN] Would create field:");
      console.log(`   - Name: ${FIELD_NAME}`);
      console.log(`   - Type: singleSelect`);
      console.log(`   - Options: ${WORKFLOW_STATUSES.join(", ")}`);
      return;
    }

    const createFieldUrl = `https://api.airtable.com/v0/meta/bases/${baseId}/tables/${casesTable.id}/fields`;
    const createResp = await fetch(createFieldUrl, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        name: FIELD_NAME,
        type: "singleSelect",
        options: {
          choices: WORKFLOW_STATUSES.map(s => ({ name: s }))
        }
      })
    });

    if (!createResp.ok) {
      const err = await createResp.text();
      console.error(`   Failed to create field: ${createResp.status} ${err}`);
      console.log("   Falling back to record-level field creation...");
      await createFieldViaRecords();
      return;
    }

    const created = await createResp.json();
    console.log(`   ✓ Created field "${FIELD_NAME}" (id: ${created.id})`);
  }

  // Step 2: Fetch all records
  console.log("\n2. Fetching existing case records...");
  const records = await fetchAllRecords();
  console.log(`   Found ${records.length} records.`);

  if (records.length === 0) {
    console.log("   No records to update. Done.");
    return;
  }

  // Step 3: Update records with workflow_status
  console.log("\n3. Updating records with workflow_status...");

  const updates = [];
  for (let i = 0; i < records.length; i++) {
    const record = records[i];
    const workflowValue = assignWorkflow(i, records.length);

    if (dryRun) {
      console.log(`   [DRY RUN] Record ${record.id}: workflow_status = ${workflowValue || "(cleared)"}`);
      continue;
    }

    if (workflowValue !== undefined) {
      updates.push({
        id: record.id,
        fields: {
          [FIELD_NAME]: workflowValue || undefined
        }
      });
    }
  }

  if (dryRun) {
    console.log(`\n   [DRY RUN] Would update ${updates.length} records.`);
    return;
  }

  // Batch updates (Airtable allows max 10 per request)
  const batches = [];
  for (let i = 0; i < updates.length; i += 10) {
    batches.push(updates.slice(i, i + 10));
  }

  let updatedCount = 0;
  for (const batch of batches) {
    const resp = await fetch(`https://api.airtable.com/v0/${baseId}/${encodeURIComponent(TABLE_NAME)}`, {
      method: "PATCH",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ records: batch })
    });

    if (!resp.ok) {
      const err = await resp.text();
      console.error(`   Batch update failed: ${resp.status} ${err}`);
      continue;
    }

    updatedCount += batch.length;
  }

  console.log(`   ✓ Updated ${updatedCount} records.`);
  console.log("\nDone! The workflow_status field is now populated.");
  console.log("Refresh the Vue app to see the new filter options.");
}

async function fetchAllRecords() {
  const allRecords = [];
  await base(TABLE_NAME)
    .select({})
    .eachPage((records, fetchNextPage) => {
      allRecords.push(...records);
      fetchNextPage();
    });
  return allRecords;
}

async function createFieldViaRecords() {
  // Fallback: Airtable auto-creates fields when you write a record with a new field name
  // (if the base allows it). This is not guaranteed to work.
  console.log("\n   Attempting to create field via record update...");

  const records = await fetchAllRecords();
  if (records.length === 0) {
    console.log("   No records to update. Cannot create field via record.");
    console.log("   Please create the field manually in Airtable:");
    console.log(`   - Name: ${FIELD_NAME}`);
    console.log(`   - Type: Single select`);
    console.log(`   - Options: ${WORKFLOW_STATUSES.join(", ")}`);
    return;
  }

  const firstRecord = records[0];
  await base(TABLE_NAME).update([
    {
      id: firstRecord.id,
      fields: { [FIELD_NAME]: "assessment-ready" }
    }
  ]);

  console.log(`   ✓ Field "${FIELD_NAME}" created via record update.`);
  console.log("   NOTE: You'll need to manually add the remaining options in Airtable:");
  console.log(`   ${WORKFLOW_STATUSES.join(", ")}`);
}

main().catch(err => {
  console.error("Error:", err);
  process.exit(1);
});
