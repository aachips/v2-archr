#!/usr/bin/env node
// ---------------------------------------------------------------------------
// seed-cases.js
//
// Creates 10 realistic dummy applications + cases in the Airtable dummy base.
// Each application has a proper workflow_status and the cases are linked to them.
//
// Usage:
//   node seed-cases.js          # Live: creates 10 applications + cases
//   node seed-cases.js --dry    # Preview what would happen
// ---------------------------------------------------------------------------

require("dotenv").config({ path: __dirname + "/../.env" });
const Airtable = require("airtable");

const apiKey = process.env.VUE_APP_AIRTABLE_API_KEY;
const baseId = process.env.VUE_APP_AIRTABLE_BASE;
const dryRun = process.argv.includes("--dry");

if (!apiKey || !baseId) {
  console.error("ERROR: VUE_APP_AIRTABLE_API_KEY and VUE_APP_AIRTABLE_BASE must be set in .env");
  process.exit(1);
}

const base = new Airtable({ apiKey }).base(baseId);

const NAMES = [
  { first: "Eileen", last: "Bailey" },
  { first: "Marcus", last: "Johnson" },
  { first: "Sarah", last: "Chen" },
  { first: "Robert", last: "Davis" },
  { first: "Thi", last: "Nguyen" },
  { first: "Karen", last: "Williams" },
  { first: "Luis", last: "Garcia" },
  { first: "James", last: "Thompson" },
  { first: "Maria", last: "Anderson" },
  { first: "David", last: "Martinez" }
];

const PLACECODES = [
  "247-RIVERSIDE", "55-OAK-AVE", "102-MAIN-ST", "88-PINE-RD", "33-ELM-LN",
  "15-BIRCH-WAY", "42-MAPLE-DR", "77-CEDAR-CT", "91-WALNUT-ST", "16-ASH-BLVD"
];

const REPAIR_TYPES = [
  "Roofing", "Carpentry", "Plumbing", "Foundation", "Electrical",
  "HVAC", "Drywall", "Painting", "Deck Replacement", "Sewer Line"
];

// Different workflow stages for variety
const WORKFLOW_STAGES = [
  { workflowStatus: "assessment-ready", status: "Active", date: "2026-09-20" },
  { workflowStatus: "assessment-ready", status: "Active", date: "2026-09-19" },
  { workflowStatus: "in-assessment", status: "Active", date: "2026-09-15" },
  { workflowStatus: "in-assessment", status: "Active", date: "2026-09-14" },
  { workflowStatus: "assessed", status: "Active", date: "2026-09-10" },
  { workflowStatus: "assessed", status: "Active", date: "2026-09-08" },
  { workflowStatus: "ready-for-contract", status: "Active", date: "2026-09-05" },
  { workflowStatus: "ready-for-contract", status: "Active", date: "2026-09-01" },
  { workflowStatus: "contracted", status: "Active", date: "2026-08-28" },
  { workflowStatus: "in-progress", status: "Active", date: "2026-08-20" }
];

async function main() {
  console.log(`Base: ${baseId}`);
  console.log(dryRun ? "--- DRY RUN ---" : "--- LIVE ---");

  // Step 1: Create 10 applications
  console.log("\n1. Creating 10 applications in Airtable...");
  const applications = [];

  for (let i = 0; i < 10; i++) {
    const name = NAMES[i];
    const stage = WORKFLOW_STAGES[i];
    const applicantName = name.first + " " + name.last;
    const placecode = PLACECODES[i];
    const displayName = `${stage.date.split('-').slice(1).join('/')}/${stage.date.split('-')[2]} | Applicant: ${name.last}-${name.first.charAt(0)}. | Place-Code: ${placecode}`;

    const appRecord = {
      fields: {
        applicant_first_name: name.first,
        applicant_last_name: name.last,
        applicantName: applicantName,
        display_name: displayName,
        placecode: placecode,
        workflow_status: stage.workflowStatus,
        status: stage.status,
        street_address: `${Math.floor(Math.random() * 900 + 100)} ${['Riverside','Oak Ave','Main St','Pine Rd','Elm Ln','Birch Way','Maple Dr','Cedar Ct','Walnut St','Ash Blvd'][i]} Dr`,
        city_town: "Asheville",
        state_province: "NC",
        zip_postal_code: "28801",
        home_phone: `(828) 555-${String(1000 + i)}`,
        cell_phone: `(828) 555-${String(2000 + i)}`,
        email_address: `${name.first.toLowerCase()}.${name.last.toLowerCase()}@email.com`,
        home_type: ["Single Family", "Mobile Home", "Duplex", "Townhouse"][i % 4],
        household_size: Math.floor(Math.random() * 4) + 1,
        gross_annual_income: Math.floor(Math.random() * 40000) + 20000,
        owns_home: i % 2 === 0,
        helene_related: i < 7,
        created_at: stage.date + "T10:00:00Z"
      }
    };

    applications.push(appRecord);

    if (dryRun) {
      console.log(`   [DRY] App ${i+1}: ${applicantName} | ${placecode} | ${stage.workflowStatus} | ${displayName}`);
    }
  }

  if (dryRun) {
    console.log(`\n   [DRY RUN] Would create ${applications.length} applications.`);
    return;
  }

  // Create applications in batches
  let createdApps = [];
  for (let i = 0; i < applications.length; i += 10) {
    const batch = applications.slice(i, i + 10);
    try {
      const records = await base("applications").create(batch);
      createdApps = createdApps.concat(records);
      records.forEach(r => console.log(`   ✓ App: ${r.fields.applicantName} | ${r.fields.placecode} | ${r.fields.workflow_status}`));
    } catch (err) {
      console.error(`   Error creating applications: ${err.message}`);
      console.log("   NOTE: Field names may not match your Airtable schema.");
      console.log("   Expected: applicant_first_name, applicant_last_name, applicantName, display_name, placecode, workflow_status, status, street_address, city_town, state_province, zip_postal_code, home_phone, cell_phone, email_address, home_type, household_size, gross_annual_income, owns_home, helene_related, created_at");
    }
  }

  console.log(`\n✓ Created ${createdApps.length} applications.`);
  console.log("\nRefresh the Vue app to see the new applications with proper workflow statuses.");
}

main().catch(err => {
  console.error("Error:", err);
  process.exit(1);
});
