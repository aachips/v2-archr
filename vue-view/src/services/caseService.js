// ---------------------------------------------------------------------------
// Case service — the demo's single Airtable data-access point.
// Keeps components presentational: they receive normalized case items and
// never touch the Airtable SDK or field names themselves.
//
// Database source toggle (stored in localStorage):
//   'airtable-dummy'  — the dummy/demo Airtable base (default)
//   'airtable-anchor' — the real ANCHOR Airtable base
//   'postgresql'      — read from PSQL via API bridge (future)
//
// The dummy base mirrors the PostgreSQL schema, so case data is spread over
// small tables. We fetch each and join on the PSQL foreign keys:
//   cases.submission_id   -> intake_submissions.id
//   cases.organization_id -> coalition_organizations.id
//   cases.status_id       -> case_statuses.id
// This mirrors how the live Airtable base resolves data through lookups.
// ---------------------------------------------------------------------------

import Airtable from "airtable";
import { TABLES, FIELD_MAP, URGENT_FLAG_LABELS } from "../config/caseFields";

const apiKey = process.env.VUE_APP_AIRTABLE_API_KEY;
const baseId = process.env.VUE_APP_AIRTABLE_BASE;
const anchorBaseId = process.env.VUE_APP_AIRTABLE_ANCHOR_BASE || '';
const viewName = process.env.VUE_APP_AIRTABLE_VIEW; // optional, applies to cases

// Get active database source (default: airtable-dummy)
export function getDbSource() {
  try {
    return localStorage.getItem('archr-db-source') || 'airtable-dummy';
  } catch (e) { return 'airtable-dummy'; }
}

// Set database source
export function setDbSource(source) {
  try {
    localStorage.setItem('archr-db-source', source);
  } catch (e) { /* ignore */ }
}

// Get the active base ID based on current source
export function getActiveBaseId() {
  const source = getDbSource();
  if (source === 'airtable-anchor' && anchorBaseId) return anchorBaseId;
  return baseId;
}

// False until .env is filled in (see .env.example). App.vue uses this to
// show a setup hint instead of a confusing API error.
export function isConfigured() {
  return Boolean(apiKey && getActiveBaseId());
}

function fetchTable(base, tableName, view) {
  return new Promise((resolve, reject) => {
    const records = [];
    base(tableName)
      .select(view ? { view } : {})
      .eachPage(
        (partial, fetchNextPage) => {
          records.push(...partial);
          fetchNextPage();
        },
        err => (err ? reject(err) : resolve(records))
      );
  });
}

function indexBy(records, map) {
  const idField = map.id;
  const out = {};
  for (const r of records) out[String(r.fields[idField])] = r.fields;
  return out;
}

function urgentIssuesFor(submission) {
  return Object.keys(URGENT_FLAG_LABELS).filter(flag => submission[flag] === true);
}

// applications rows are indexed by their submission_id join key (one
// application per household, so at most one per submission in this demo).
function indexApplicationsBySubmission(records) {
  const am = FIELD_MAP.applications;
  const out = {};
  for (const r of records) {
    const raw = (r.fields || {})[am.submissionId];
    const key = raw === null || raw === undefined ? "" : String(raw);
    if (key) out[key] = r.fields;
  }
  return out;
}

// Join one cases record with its related rows -> component-friendly item.
// Contact fields prefer the APPLICATION (the editable working copy) and fall
// back to the raw submission — mirrors app/ lifecycle logic.
function joinCase(record, related) {
  const caseFields = record.fields || {};
  const cm = FIELD_MAP.cases;
  const sm = FIELD_MAP.submissions;
  const am = FIELD_MAP.applications;
  const submissionId = caseFields[cm.submissionId];
  const sub = related.submissions[String(submissionId)] || {};
  const app = related.applications[String(submissionId)] || null;
  const org = related.orgs[String(caseFields[cm.organizationId])] || {};
  const status = related.statuses[String(caseFields[cm.statusId])] || {};
  const first = (app && app[am.firstName]) || sub[sm.firstName] || "";
  const last = (app && app[am.lastName]) || sub[sm.lastName] || "";
  const urgentIssues = sub[sm.id] !== undefined ? urgentIssuesFor(sub) : [];

  return {
    id: caseFields[cm.id] !== undefined ? String(caseFields[cm.id]) : record.id,
    submissionId: submissionId !== undefined ? String(submissionId) : "",
    caseNumber: caseFields[cm.caseNumber] || "",
    projectCode: "", // lives in application_anchor, not imported into the dummy base
    placecode: (app && app[am.placecode]) || "",
    // Application-layer working-copy fields (empty until an application exists
    // for the submission — the same fields saveCaseContact seeds on first edit).
    displayName: (app && app[am.displayName]) || "",
    applicationStatus: (app && app[am.status]) || "",
    workflowStatus: (app && (app.workflow_status || app.workflowStatus)) || "",
    organizationCode: org[FIELD_MAP.orgs.code] || "",
    // Drives the pipeline-phase fallback in casePhases.js (mirrors
    // archr_case_phase()'s status_sequence mapping in app/).
    statusSequence: Number(status[FIELD_MAP.statuses.sequence]) || 0,
    homePhone: sub[sm.phone2] || "",
    firstName: first,
    lastName: last,
    applicantName: [first, last].filter(Boolean).join(" "),
    email: (app && app[am.email]) || sub[sm.email] || "",
    phone: (app && app[am.phone]) || sub[sm.phone] || "",
    address: sub[sm.address] || "",
    city: sub[sm.city] || "",
    state: sub[sm.state] || "",
    zip: sub[sm.zip] || "",
    status: status[FIELD_MAP.statuses.name] || "",
    organization: org[FIELD_MAP.orgs.name] || "",
    submittedAt: sub[sm.submittedAt] || caseFields[cm.createdAt] || "",
    householdSize: sub[sm.householdSize] || "",
    annualIncome: sub[sm.annualIncome],
    homeType: sub[sm.homeType] || "",
    yearBuilt: sub[sm.yearBuilt] || "",
    repairNeeds: [], // junction tables not imported into the dummy base yet
    urgentIssues,
    isUrgent: urgentIssues.length > 0,
    additionalDetails: "",
    hasApplication: Boolean(app)
  };
}

// Fetch all tables and return joined, normalized case items. The
// applications table is optional until `setup-applications` has been run —
// a missing table degrades to read-only submissions, not a broken demo.
export function fetchCases() {
  if (!isConfigured()) {
    return Promise.reject(new Error("Airtable is not configured. See .env.example."));
  }
  const base = new Airtable({ apiKey }).base(getActiveBaseId());
  const applications = fetchTable(base, TABLES.applications).catch(err => {
    const code = (err && (err.error || err.statusCode)) || "";
    if (code === "NOT_FOUND" || code === 404 || /404/.test(String(err && err.message))) {
      return [];
    }
    throw err;
  });
  return Promise.all([
    fetchTable(base, TABLES.cases, viewName),
    fetchTable(base, TABLES.submissions),
    fetchTable(base, TABLES.orgs),
    fetchTable(base, TABLES.statuses),
    applications
  ]).then(([cases, submissions, orgs, statuses, apps]) => {
    const related = {
      submissions: indexBy(submissions, FIELD_MAP.submissions),
      orgs: indexBy(orgs, FIELD_MAP.orgs),
      statuses: indexBy(statuses, FIELD_MAP.statuses),
      applications: indexApplicationsBySubmission(apps)
    };
    return cases.map(r => joinCase(r, related));
  });
}

// Save edited contact fields to the `applications` table — never to the raw
// submission. Mirrors the app/ lifecycle rule: if no application exists for
// this submission yet, create one by copying the submission, then apply the
// edit. `changes` keys: firstName, lastName, email, phone.
// Resolves with the applied changes so the caller can update local state.
export function saveCaseContact(caseItem, changes) {
  if (!isConfigured()) {
    return Promise.reject(new Error("Airtable is not configured. See .env.example."));
  }
  const am = FIELD_MAP.applications;
  const sm = FIELD_MAP.submissions;
  const submissionId = Number(caseItem.submissionId);
  if (!submissionId) {
    return Promise.reject(new Error("This case has no submission id to attach an application to."));
  }
  const mapped = {};
  if (changes.firstName !== undefined) mapped[am.firstName] = changes.firstName;
  if (changes.lastName !== undefined) mapped[am.lastName] = changes.lastName;
  if (changes.email !== undefined) mapped[am.email] = changes.email;
  if (changes.phone !== undefined) mapped[am.phone] = changes.phone;

  const base = new Airtable({ apiKey }).base(getActiveBaseId());
  const applications = base(TABLES.applications);
  const bySubmission = `{${am.submissionId}} = ${submissionId}`;

  return applications
    .select({ filterByFormula: bySubmission, maxRecords: 1 })
    .firstPage()
    .then(found => {
      if (found.length) {
        return applications.update(found[0].id, mapped).then(() => changes);
      }
      // No application yet: create it as a copy of the raw submission
      // (deduplicate_submissions in sql/application-lifecycle.sql), then
      // apply the edit on top.
      return base(TABLES.submissions)
        .select({ filterByFormula: `{${sm.id}} = ${submissionId}`, maxRecords: 1 })
        .firstPage()
        .then(subs => {
          const s = subs.length ? subs[0].fields : {};
          const seed = {
            [am.submissionId]: submissionId,
            [am.firstName]: s[sm.firstName] || "",
            [am.lastName]: s[sm.lastName] || "",
            [am.email]: s[sm.email] || "",
            [am.phone]: s[sm.phone] || "",
            [am.displayName]: [s[sm.address], s[sm.city]].filter(Boolean).join(" - "),
            [am.status]: "new"
          };
          return applications.create({ ...seed, ...mapped }).then(() => changes);
        });
    });
}

// --- Quick Tasks & Events --------------------------------------------------
// progress_events is the append-only log per case (communication logs,
// assessment events, progress tasks, notes). Cases are referenced by their
// PSQL-style numeric id (the `id` column), matching how the demo joins tables.

// Events for one case (newest first). Tolerates a missing progress_events
// table (returns []) so the view works before the table is created.
export function fetchCaseEvents(caseItem) {
  if (!isConfigured()) return Promise.resolve([]);
  const em = FIELD_MAP.events;
  const base = new Airtable({ apiKey }).base(getActiveBaseId());
  const caseId = Number(caseItem.id);
  return base(TABLES.events)
    .select({
      filterByFormula: `{${em.caseId}} = ${caseId}`,
      sort: [{ field: em.performedAt, direction: "desc" }]
    })
    .firstPage()
    .then(records =>
      records.map(r => ({
        id: r.id,
        type: r.fields[em.type] || "note",
        description: r.fields[em.description] || "",
        performedAt: r.fields[em.performedAt] || ""
      }))
    )
    .catch(err => {
      const code = (err && (err.error || err.statusCode)) || "";
      if (code === "NOT_FOUND" || code === 404 || /404/.test(String(err && err.message))) {
        return [];
      }
      throw err;
    });
}

// Append one event to a case. Resolves with the normalized event.
export function saveCaseEvent(caseItem, event) {
  if (!isConfigured()) {
    return Promise.reject(new Error("Airtable is not configured. See .env.example."));
  }
  const em = FIELD_MAP.events;
  const caseId = Number(caseItem.id);
  if (!caseId) return Promise.reject(new Error("This case has no numeric id."));
  const base = new Airtable({ apiKey }).base(getActiveBaseId());
  const now = new Date().toISOString();
  const fields = {
    [em.caseId]: caseId,
    [em.type]: event.type,
    [em.description]: event.description,
    [em.source]: "user",
    [em.performedAt]: now
  };
  return base(TABLES.events)
    .create(fields)
    .then(record => ({
      id: record.id,
      type: fields[em.type],
      description: fields[em.description],
      performedAt: now
    }));
}
