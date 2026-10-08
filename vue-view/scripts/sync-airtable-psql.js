#!/usr/bin/env node
// ---------------------------------------------------------------------------
// sync-airtable-psql.js
//
// Bidirectional sync between Airtable (dummy or ANCHOR) and PostgreSQL.
// Copies case data, workflow statuses, and assessment data between systems.
//
// Usage:
//   node sync-airtable-psql.js --to-psql          # Airtable → PostgreSQL
//   node sync-airtable-psql.js --to-airtable      # PostgreSQL → Airtable
//   node sync-airtable-psql.js --dry              # Show what would happen
//   node sync-airtable-psql.js --inspect          # Show record counts on both
// ---------------------------------------------------------------------------

require("dotenv").config({ path: __dirname + "/../.env" });
const { Client } = require("pg");
const Airtable = require("airtable");

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------
const PSQL_CONFIG = {
  user: process.env.PGUSER || "postgres",
  host: process.env.PGHOST || "localhost",
  database: process.env.PGDATABASE || "archr",
  password: process.env.PGPASSWORD || "",
  port: parseInt(process.env.PGPORT || "5432", 10)
};

const AIRTABLE_API_KEY = process.env.VUE_APP_AIRTABLE_API_KEY;
const AIRTABLE_BASE = process.env.VUE_APP_AIRTABLE_BASE;
const AIRTABLE_ANCHOR_BASE = process.env.VUE_APP_AIRTABLE_ANCHOR_BASE;

const MODE = process.argv.find(a => a.startsWith("--")) || "--inspect";
const DRY_RUN = process.argv.includes("--dry");

// ---------------------------------------------------------------------------
// Airtable setup
// ---------------------------------------------------------------------------
function getAirtableBase() {
  if (MODE.includes("anchor")) {
    return AIRTABLE_ANCHOR_BASE || AIRTABLE_BASE;
  }
  return AIRTABLE_BASE;
}

function airtableBase() {
  return new Airtable({ apiKey: AIRTABLE_API_KEY }).base(getAirtableBase());
}

// ---------------------------------------------------------------------------
// Sync: Airtable → PostgreSQL (Applications with workflow status)
// ---------------------------------------------------------------------------
async function syncToPsql() {
  const at = airtableBase();
  const psql = new Client(PSQL_CONFIG);
  await psql.connect();

  console.log("Syncing: Airtable → PostgreSQL (Applications)");
  console.log(`Base: ${getAirtableBase()}`);

  // Fetch all applications from Airtable
  const atApps = [];
  await at("applications").select({}).eachPage((records, fetchNext) => {
    atApps.push(...records);
    fetchNext();
  });

  console.log(`Found ${atApps.length} applications in Airtable.`);

  for (const record of atApps) {
    const fields = record.fields;
    const appData = {
      id: fields.id || parseInt(record.id.replace(/^rec/, ""), 36) % 1000000,
      workflow_status: fields.workflow_status || null,
      updated_at: new Date().toISOString()
    };

    if (DRY_RUN) {
      console.log(`  [DRY] UPSERT application id=${appData.id}: workflow_status=${appData.workflow_status || "null"}`);
      continue;
    }

    // UPSERT: INSERT ... ON CONFLICT (id) DO UPDATE
    await psql.query(
      `INSERT INTO applications (id, workflow_status, updated_at)
       VALUES ($1, $2, $3)
       ON CONFLICT (id) DO UPDATE SET
         workflow_status = EXCLUDED.workflow_status,
         updated_at = EXCLUDED.updated_at`,
      [appData.id, appData.workflow_status, appData.updated_at]
    );
  }

  console.log(`✓ Synced ${DRY_RUN ? "(dry)" : atApps.length} applications to PostgreSQL.`);
  await psql.end();
}

// ---------------------------------------------------------------------------
// Sync: PostgreSQL → Airtable
// ---------------------------------------------------------------------------
async function syncToAirtable() {
  const at = airtableBase();
  const psql = new Client(PSQL_CONFIG);
  await psql.connect();

  console.log("Syncing: PostgreSQL → Airtable");
  console.log(`Base: ${getAirtableBase()}`);

  // Fetch all cases from PostgreSQL
  const { rows: psqlCases } = await psql.query(
    "SELECT * FROM cases ORDER BY id"
  );

  console.log(`Found ${psqlCases.length} cases in PostgreSQL.`);

  // Build Airtable record updates
  const updates = psqlCases.map(pgCase => ({
    id: pgCase.airtable_record_id || undefined, // if we have the Airtable record ID
    fields: {
      workflow_status: pgCase.workflow_status || null,
      updated_at: pgCase.updated_at || new Date().toISOString()
    }
  })).filter(u => u.id); // only update records we know the Airtable ID for

  if (updates.length === 0) {
    console.log("No PostgreSQL records have matching Airtable record IDs.");
    console.log("Run --to-psql first to establish the mapping.");
  }

  if (DRY_RUN) {
    console.log(`[DRY] Would update ${updates.length} Airtable records.`);
    return;
  }

  // Batch updates (max 10 per request)
  for (let i = 0; i < updates.length; i += 10) {
    const batch = updates.slice(i, i + 10);
    await at("cases").update(batch);
  }

  console.log(`✓ Synced ${updates.length} cases to Airtable.`);
  await psql.end();
}

// ---------------------------------------------------------------------------
// Inspect: Show record counts on both sides
// ---------------------------------------------------------------------------
async function inspect() {
  console.log("=== Database Inspection ===\n");

  // PostgreSQL — applications (NOT cases)
  try {
    const psql = new Client(PSQL_CONFIG);
    await psql.connect();
    const { rows } = await psql.query("SELECT COUNT(*) as count FROM applications");
    console.log(`PostgreSQL (${PSQL_CONFIG.database}): ${rows[0].count} applications`);

    const { rows: wf } = await psql.query(
      "SELECT workflow_status, COUNT(*) as count FROM applications GROUP BY workflow_status"
    );
    if (wf.length) {
      console.log("  Workflow status distribution:");
      wf.forEach(r => console.log(`    ${r.workflow_status || "(null)"}: ${r.count}`));
    }
    await psql.end();
  } catch (err) {
    console.log(`PostgreSQL: ERROR - ${err.message}`);
  }

  console.log("");

  // Airtable — applications
  try {
    const at = airtableBase();
    const records = [];
    await at("applications").select({}).eachPage((r, next) => {
      records.push(...r);
      next();
    });
    console.log(`Airtable (${getAirtableBase()}): ${records.length} applications`);

    const statusCounts = {};
    records.forEach(r => {
      const s = r.fields.workflow_status || "(not set)";
      statusCounts[s] = (statusCounts[s] || 0) + 1;
    });
    console.log("  Workflow status distribution:");
    Object.entries(statusCounts).forEach(([s, c]) => console.log(`    ${s}: ${c}`));
  } catch (err) {
    console.log(`Airtable: ERROR - ${err.message}`);
  }
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
(async () => {
  try {
    switch (MODE) {
      case "--to-psql":
        await syncToPsql();
        break;
      case "--to-airtable":
        await syncToAirtable();
        break;
      case "--dry":
        console.log("DRY RUN mode — no changes will be made.\n");
        await syncToPsql();
        break;
      case "--inspect":
      default:
        await inspect();
        break;
    }
  } catch (err) {
    console.error("Error:", err.message);
    process.exit(1);
  }
})();
