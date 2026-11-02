#!/usr/bin/env node

/**
 * Offline sanity check for the Vue demo's data layer — no Airtable needed.
 *
 * Loads dummy-cases-export.json (real PostgreSQL dummy data), replicates the
 * join that vue-view/src/services/caseService.js performs at runtime, and
 * asserts every case resolves its submission / status / organization.
 *
 * Usage: node verify-export-shape.js
 */

const fs = require('fs');
const path = require('path');

const file = path.join(__dirname, 'dummy-cases-export.json');
if (!fs.existsSync(file)) {
  console.error('dummy-cases-export.json not found — run export-dummy-cases.ps1 first.');
  process.exit(1);
}
const data = JSON.parse(fs.readFileSync(file, 'utf8'));
const { case_statuses = [], coalition_organizations = [], intake_submissions = [], cases = [] } = data.tables || {};

const byId = rows => Object.fromEntries(rows.map(r => [String(r.id), r]));
const subs = byId(intake_submissions);
const orgs = byId(coalition_organizations);
const statuses = byId(case_statuses);

const URGENT_FLAGS = [
  'urgent_unable_to_stay', 'urgent_no_hvac', 'urgent_no_potable_water',
  'urgent_no_bathroom', 'urgent_no_kitchen', 'urgent_open_to_elements',
  'urgent_no_entry', 'urgent_accessibility', 'urgent_eviction_risk'
];

let failures = 0;
const fail = msg => { failures++; console.error('  FAIL:', msg); };

console.log(`Loaded: ${cases.length} cases, ${intake_submissions.length} submissions, ` +
            `${coalition_organizations.length} orgs, ${case_statuses.length} statuses`);

// Every case must resolve its joins and have a display identifier.
let urgentCount = 0;
for (const c of cases) {
  if (!c.case_number) fail(`case id=${c.id} has no case_number`);
  const sub = subs[String(c.submission_id)];
  if (!sub) { fail(`case ${c.case_number} -> missing submission ${c.submission_id}`); continue; }
  if (c.status_id && !statuses[String(c.status_id)]) fail(`case ${c.case_number} -> unknown status_id ${c.status_id}`);
  if (c.organization_id && !orgs[String(c.organization_id)]) fail(`case ${c.case_number} -> unknown org ${c.organization_id}`);
  if (URGENT_FLAGS.some(f => sub[f] === true)) urgentCount++;
}

// Sample of what the demo's list rows will show.
console.log('\nSample normalized list rows:');
for (const c of cases.slice(0, 3)) {
  const sub = subs[String(c.submission_id)] || {};
  const org = orgs[String(c.organization_id)];
  const status = statuses[String(c.status_id)];
  console.log(`  ${c.case_number} | ${[sub.applicant_first_name, sub.applicant_last_name].filter(Boolean).join(' ')}` +
              ` | ${sub.home_city || '?'}, ${sub.home_state || ''} | ${status ? status.status_name : '?'}` +
              ` | ${org ? org.organization_name : 'Unassigned'}`);
}

const orgFilterOptions = [...new Set(cases.map(c => { const o = orgs[String(c.organization_id)]; return o && o.organization_name; }).filter(Boolean))];
console.log(`\nOrg filter options (${orgFilterOptions.length}): ${orgFilterOptions.join(', ') || '(none)'}`);
console.log(`Cases flagged urgent: ${urgentCount}`);

if (failures) { console.error(`\n${failures} problem(s) found.`); process.exit(1); }
console.log('\nPASS — export shape matches what the demo components expect.');
