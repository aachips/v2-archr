#!/usr/bin/env node

/**
 * Syncs PostgreSQL dummy/test data into the dummy Airtable base.
 *
 * The dummy base mirrors the PSQL schema (built by build-airtable.js), so
 * rows are imported table-for-table: case_statuses, coalition_organizations,
 * intake_submissions, then cases (join keys id / submission_id preserved).
 *
 * Usage:
 *   node sync-dummy-airtable.js test      # connection smoke test
 *   node sync-dummy-airtable.js inspect   # list tables + fields in the base
 *   node sync-dummy-airtable.js import    # import dummy-cases-export.json
 *   node sync-dummy-airtable.js import --force   # allow import into non-empty tables
 *   node sync-dummy-airtable.js setup-tables  # create `applications` +
 *                                         # `progress_events` tables if missing
 *                                         # (needs schema.bases:write)
 *   node sync-dummy-airtable.js clean --yes   # delete ALL records in the dummy
 *                                         # tables (data scopes only)
 *   node sync-dummy-airtable.js seed-applications  # one application per
 *                                         # submission (idempotent)
 *   node sync-dummy-airtable.js rebuild --yes # clean + import + seed-applications
 *
 * Credentials (never printed) resolve in this order:
 *   PAT:    AIRTABLE_PAT env  ->  PAT.txt (this dir)  ->  archr_connect.php (repo root)
 *           ->  VUE_APP_AIRTABLE_API_KEY in vue-view/.env
 *   Base:   AIRTABLE_INTAKE_BASE_ID env  ->  archr_connect.php
 *           ->  VUE_APP_AIRTABLE_BASE in vue-view/.env  ->  built-in dummy id
 *
 * The token's Airtable scopes must include this base (PATs are per-base!)
 * with data.records:read + schema.bases:read, plus data.records:write for import.
 */

const fs = require('fs');
const path = require('path');
const https = require('https');

const DEFAULT_BASE_ID = 'appiMfIEzULJtmi5v'; // documented in app/config/database.php
const EXPORT_FILE = path.join(__dirname, 'dummy-cases-export.json');
const IMPORT_ORDER = ['case_statuses', 'coalition_organizations', 'intake_submissions', 'cases'];
// Field types the Airtable API does not accept writes to.
const READ_ONLY_TYPES = new Set([
  'autoNumber', 'button', 'count', 'createdBy', 'createdTime', 'formula',
  'multipleLookupValues', 'rollup', 'externalSyncSource', 'lastModifiedBy', 'lastModifiedTime'
]);

function isPlaceholder(v) { return !v || /YOUR|HERE|###|XXX/.test(v); }

function readPhpConfig() {
  const file = path.join(__dirname, '..', '..', 'archr_connect.php');
  const out = {};
  if (!fs.existsSync(file)) return out;
  const re = /'([A-Z_]+)'\s*=>\s*'([^']*)'/g;
  const text = fs.readFileSync(file, 'utf8');
  let m;
  while ((m = re.exec(text)) !== null) out[m[1]] = m[2];
  return out;
}

// Minimal reader for the demo's vue-view/.env (KEY=value lines), so the demo
// and these scripts can share one configured token + base id.
function readDotEnv() {
  const file = path.join(__dirname, '..', '..', 'vue-view', '.env');
  const out = {};
  if (!fs.existsSync(file)) return out;
  for (const line of fs.readFileSync(file, 'utf8').split(/\r?\n/)) {
    const m = /^([A-Z_]+)\s*=\s*(.*)$/.exec(line.trim());
    if (m) out[m[1]] = m[2].trim();
  }
  return out;
}

function resolveConfig() {
  const php = readPhpConfig();
  const dotenv = readDotEnv();
  let pat = process.env.AIRTABLE_PAT || '';
  if (!pat && fs.existsSync(path.join(__dirname, 'PAT.txt'))) {
    pat = fs.readFileSync(path.join(__dirname, 'PAT.txt'), 'utf8').trim();
  }
  if (!pat && !isPlaceholder(php.AIRTABLE_PAT)) pat = php.AIRTABLE_PAT;
  if (!pat && dotenv.VUE_APP_AIRTABLE_API_KEY) pat = dotenv.VUE_APP_AIRTABLE_API_KEY;
  let baseId = process.env.AIRTABLE_INTAKE_BASE_ID || '';
  if (!baseId && !isPlaceholder(php.AIRTABLE_INTAKE_BASE_ID)) baseId = php.AIRTABLE_INTAKE_BASE_ID;
  if (!baseId && dotenv.VUE_APP_AIRTABLE_BASE) baseId = dotenv.VUE_APP_AIRTABLE_BASE;
  if (!baseId) baseId = DEFAULT_BASE_ID;
  if (!pat) {
    console.error('No Airtable PAT found. Do ONE of:');
    console.error('  - paste it as VUE_APP_AIRTABLE_API_KEY in vue-view/.env');
    console.error('  - save it in elemental-integration/airtable-builder/PAT.txt');
    console.error('  - set $env:AIRTABLE_PAT for this terminal session');
    process.exit(1);
  }
  return { pat, baseId };
}

function airtable(method, endpoint, data, pat) {
  return new Promise((resolve, reject) => {
    const req = https.request({
      hostname: 'api.airtable.com', path: endpoint, method,
      headers: { Authorization: `Bearer ${pat}`, 'Content-Type': 'application/json' }
    }, res => {
      let body = '';
      res.on('data', c => (body += c));
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) return resolve(JSON.parse(body));
        reject(new Error(`API ${res.statusCode}: ${body.slice(0, 300)}`));
      });
    });
    req.on('error', reject);
    if (data) req.write(JSON.stringify(data));
    req.end();
  });
}

const sleep = ms => new Promise(r => setTimeout(r, ms));

async function getSchema({ pat, baseId }) {
  const meta = await airtable('GET', `/v0/meta/bases/${baseId}/tables`, null, pat);
  const byName = {};
  for (const t of meta.tables) byName[t.name] = t;
  return byName;
}

function toWritableFields(table, row) {
  const types = Object.fromEntries(table.fields.map(f => [f.name, f.type]));
  const fields = {};
  for (const [key, value] of Object.entries(row)) {
    if (!(key in types)) continue;                       // column doesn't exist in Airtable
    const type = types[key];
    if (READ_ONLY_TYPES.has(type)) continue;             // computed on Airtable's side
    if (value === '' || value === null || value === undefined) continue;
    if (['number', 'currency', 'percent', 'rating'].includes(type)) {
      const n = Number(value);
      if (!Number.isNaN(n)) fields[key] = n;             // ODBC exports arrive as strings
    } else if (type === 'checkbox') {
      fields[key] = value === true || value === 1 || String(value).toLowerCase() === 'true';
    } else {
      fields[key] = value;
    }
  }
  return fields;
}

async function cmdTest(cfg) {
  const schema = await getSchema(cfg);
  console.log(`OK — base reachable (${cfg.baseId}). Tables: ${Object.keys(schema).join(', ')}`);
}

async function cmdInspect(cfg) {
  const schema = await getSchema(cfg);
  for (const t of Object.values(schema)) {
    console.log(`\n[${t.name}] (${t.fields.length} fields)`);
    for (const f of t.fields) console.log(`  ${f.name} : ${f.type}`);
  }
}

// The `applications` table mirrors sql/application-lifecycle.sql (subset the
// demo edits). Field names here must match FIELD_MAP.applications in
// vue-view/src/config/caseFields.js.
const APPLICATIONS_TABLE = {
  name: 'applications',
  fields: [
    { name: 'display_name', type: 'singleLineText' }, // primary field (first)
    { name: 'submission_id', type: 'number', options: { precision: 0 } },
    { name: 'applicant_first_name', type: 'singleLineText' },
    { name: 'applicant_last_name', type: 'singleLineText' },
    { name: 'applicant_email', type: 'email' },
    { name: 'applicant_phone', type: 'phoneNumber' },
    { name: 'property_address', type: 'singleLineText' },
    { name: 'property_city', type: 'singleLineText' },
    { name: 'property_state', type: 'singleLineText' },
    { name: 'property_zip', type: 'singleLineText' },
    { name: 'household_size', type: 'number', options: { precision: 0 } },
    { name: 'placecode', type: 'singleLineText' },
    { name: 'status', type: 'singleLineText' }
  ]
};

// `progress_events` mirrors sql/application-lifecycle.sql section 4 (subset
// the demo's Quick Tasks & Events view writes).
const PROGRESS_EVENTS_TABLE = {
  name: 'progress_events',
  fields: [
    { name: 'event_description', type: 'singleLineText' }, // primary field (first)
    { name: 'case_id', type: 'number', options: { precision: 0 } },
    { name: 'event_type', type: 'singleLineText' }, // comm_logged | assessment_event | progress_task | note
    { name: 'event_source', type: 'singleLineText' },
    { name: 'performed_at', type: 'dateTime', options: { timeZone: 'utc', dateFormat: { name: 'iso' } } },
    { name: 'created_at', type: 'dateTime', options: { timeZone: 'utc', dateFormat: { name: 'iso' } } }
  ]
};

const SETUP_TABLES = [APPLICATIONS_TABLE, PROGRESS_EVENTS_TABLE];

async function cmdSetupTables(cfg) {
  const schema = await getSchema(cfg);
  for (const t of SETUP_TABLES) {
    if (schema[t.name]) {
      console.log(`SKIP: table '${t.name}' already exists`);
      continue;
    }
    await airtable('POST', `/v0/meta/bases/${cfg.baseId}/tables`, t, cfg.pat);
    console.log(`OK: created table '${t.name}' (${t.fields.length} fields)`);
  }
}

// --- Record-level maintenance (data scopes only; no schema scope needed) ---

const MAINTENANCE_TABLES = [
  'cases', 'applications', 'progress_events',
  'intake_submissions', 'coalition_organizations', 'case_statuses'
];

async function listRecordIds(cfg, tableName) {
  const ids = [];
  let offset = null;
  do {
    const qs = `?fields%5B%5D=&pageSize=100` + (offset ? `&offset=${offset}` : '');
    const page = await airtable('GET', `/v0/${cfg.baseId}/${encodeURIComponent(tableName)}${qs}`, null, cfg.pat);
    ids.push(...page.records.map(r => r.id));
    offset = page.offset || null;
  } while (offset);
  return ids;
}

async function cmdClean(cfg) {
  for (const name of MAINTENANCE_TABLES) {
    let ids;
    try {
      ids = await listRecordIds(cfg, name);
    } catch (err) {
      console.warn(`SKIP ${name}: ${/404|NOT_FOUND/.test(err.message) ? 'table not found' : err.message}`);
      continue;
    }
    for (let i = 0; i < ids.length; i += 10) { // delete batch limit: 10
      const qs = ids.slice(i, i + 10).map(id => `records%5B%5D=${id}`).join('&');
      await airtable('DELETE', `/v0/${cfg.baseId}/${encodeURIComponent(name)}?${qs}`, null, cfg.pat);
      await sleep(250);
    }
    console.log(`OK ${name}: deleted ${ids.length} records`);
  }
}

// One application per submission, copied from the raw submission — the same
// mapping as deduplicate_submissions in sql/application-lifecycle.sql.
// Idempotent: submissions that already have an application are skipped.
async function cmdSeedApplications(cfg) {
  const submissions = await listAllRecords(cfg, 'intake_submissions');
  let existing = [];
  try {
    existing = await listAllRecords(cfg, 'applications');
  } catch (err) {
    if (/404|NOT_FOUND/.test(err.message)) {
      console.error("Table 'applications' not found. Create it manually (see INTEGRATION.md) or run setup-tables with schema.bases:write.");
      process.exit(1);
    }
    throw err;
  }
  const have = new Set(existing.map(r => String(r.fields.submission_id ?? '')));
  const toCreate = [];
  let skipped = 0;
  for (const r of submissions) {
    const s = r.fields;
    const subId = s.id;
    if (subId === undefined || subId === null || subId === '') { skipped++; continue; }
    if (have.has(String(subId))) { skipped++; continue; }
    const fields = {
      submission_id: Number(subId),
      applicant_first_name: s.applicant_first_name || '',
      applicant_last_name: s.applicant_last_name || '',
      applicant_email: s.contact_email || '',
      applicant_phone: s.home_phone || s.cell_phone || '',
      property_address: s.home_address || '',
      property_city: s.home_city || '',
      property_state: s.home_state || '',
      property_zip: s.home_zip || '',
      status: 'new'
    };
    fields.display_name = [fields.property_address, fields.property_city].filter(Boolean).join(' - ');
    if (s.household_size !== undefined && s.household_size !== '') {
      const n = Number(s.household_size);
      if (!Number.isNaN(n)) fields.household_size = n;
    }
    toCreate.push({ fields });
  }
  for (let i = 0; i < toCreate.length; i += 10) {
    await airtable('POST', `/v0/${cfg.baseId}/applications`, { records: toCreate.slice(i, i + 10) }, cfg.pat);
    await sleep(250);
  }
  console.log(`OK applications: created ${toCreate.length}, skipped ${skipped} (already had one or no id)`);
}

async function listAllRecords(cfg, tableName) {
  const out = [];
  let offset = null;
  do {
    const qs = '?pageSize=100' + (offset ? `&offset=${offset}` : '');
    const page = await airtable('GET', `/v0/${cfg.baseId}/${encodeURIComponent(tableName)}${qs}`, null, cfg.pat);
    out.push(...page.records);
    offset = page.offset || null;
  } while (offset);
  return out;
}

async function cmdImport(cfg, force) {
  if (!fs.existsSync(EXPORT_FILE)) {
    console.error('dummy-cases-export.json not found — run export-dummy-cases.ps1 first.');
    process.exit(1);
  }
  const data = JSON.parse(fs.readFileSync(EXPORT_FILE, 'utf8'));
  const schema = await getSchema(cfg);
  for (const name of IMPORT_ORDER) {
    const rows = (data.tables && data.tables[name]) || [];
    const table = schema[name];
    if (!table) { console.warn(`SKIP ${name}: table not found in base`); continue; }
    if (!rows.length) { console.log(`SKIP ${name}: no rows in export`); continue; }
    const existing = await airtable('GET', `/v0/${cfg.baseId}/${encodeURIComponent(name)}?maxRecords=1`, null, cfg.pat);
    if (existing.records.length && !force) {
      console.warn(`SKIP ${name}: table not empty (${existing.records.length}+ records). Re-run with --force to append.`);
      continue;
    }
    let created = 0;
    for (let i = 0; i < rows.length; i += 10) {           // Airtable batch limit: 10
      const batch = rows.slice(i, i + 10).map(r => ({ fields: toWritableFields(table, r) }));
      await airtable('POST', `/v0/${cfg.baseId}/${encodeURIComponent(name)}`, { records: batch }, cfg.pat);
      created += batch.length;
      await sleep(250);                                    // stay under 5 req/s
    }
    console.log(`OK ${name}: created ${created} records`);
  }
}

(async () => {
  const [command, flag] = [process.argv[2], process.argv[3]];
  const cfg = resolveConfig();
  console.log(`Target base: ${cfg.baseId}`); // compare with your Airtable URL: airtable.com/<baseId>/...
  try {
    if (command === 'test') await cmdTest(cfg);
    else if (command === 'inspect') await cmdInspect(cfg);
    else if (command === 'import') await cmdImport(cfg, flag === '--force');
    else if (command === 'setup-tables') await cmdSetupTables(cfg);
    else if (command === 'clean') {
      if (flag !== '--yes') {
        console.error('clean deletes ALL records in the dummy tables. Re-run with --yes to confirm.');
        process.exit(1);
      }
      await cmdClean(cfg);
    }
    else if (command === 'seed-applications') await cmdSeedApplications(cfg);
    else if (command === 'rebuild') {
      if (flag !== '--yes') {
        console.error('rebuild = clean (delete everything) + import + seed-applications. Re-run with --yes to confirm.');
        process.exit(1);
      }
      await cmdClean(cfg);
      await cmdImport(cfg, true);
      await cmdSeedApplications(cfg);
    }
    else {
      console.log('Usage: node sync-dummy-airtable.js [test|inspect|import|setup-tables|clean|seed-applications|rebuild] [--force|--yes]');
      process.exit(1);
    }
  } catch (err) {
    console.error('FAILED:', err.message);
    process.exit(1);
  }
})();
