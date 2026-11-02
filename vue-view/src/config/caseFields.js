// ---------------------------------------------------------------------------
// Airtable field map — the ONLY file you should need to edit when the
// Airtable schema changes. Values must be the EXACT Airtable field names.
//
// Target: the "Dummy Database" base (id appiMfIEzULJtmi5v), which mirrors
// the PostgreSQL schema table-for-table, so names are snake_case columns.
// Verify against the live base any time with:
//   node elemental-integration/airtable-builder/sync-dummy-airtable.js inspect
//
// The demo reads three small tables and joins them in caseService.js:
//   cases                 (one row per case)
//   intake_submissions    (applicant/household details, joined via submission_id)
//   coalition_organizations (filter dropdown labels, joined via organization_id)
//   case_statuses         (status labels, joined via status_id)
// ---------------------------------------------------------------------------

export const TABLES = {
  cases: "cases",
  submissions: "intake_submissions",
  orgs: "coalition_organizations",
  statuses: "case_statuses",
  // The editable working copy in the submission -> application -> case
  // lifecycle. Created in the dummy base by:
  //   node sync-dummy-airtable.js setup-tables   (or manually — see INTEGRATION.md)
  applications: "applications",
  // Communication logs / assessment events / progress tasks per case
  // (Quick Tasks & Events view). Mirrors sql/application-lifecycle.sql §4.
  events: "progress_events"
};

export const FIELD_MAP = {
  cases: {
    id: "id",
    submissionId: "submission_id", // join key -> intake_submissions.id
    caseNumber: "case_number",
    statusId: "status_id", // join key -> case_statuses.id
    organizationId: "organization_id", // join key -> coalition_organizations.id
    createdAt: "created_at"
  },
  submissions: {
    id: "id",
    firstName: "applicant_first_name",
    lastName: "applicant_last_name",
    email: "contact_email",
    phone: "cell_phone",
    phone2: "home_phone",
    address: "home_address",
    city: "home_city",
    state: "home_state",
    zip: "home_zip",
    householdSize: "household_size",
    annualIncome: "gross_annual_income",
    homeType: "home_type",
    yearBuilt: "year_built",
    submittedAt: "submitted_at"
  },
  orgs: {
    id: "id",
    name: "organization_name",
    code: "organization_code"
  },
  statuses: {
    id: "id",
    name: "status_name",
    // Drives the pipeline-phase fallback in casePhases.js (mirrors the PHP
    // app's archr_case_phase() sequence mapping).
    sequence: "status_sequence"
  },
  // Editable copy of the submission's contact data (see
  // sql/application-lifecycle.sql: deduplicate_submissions copies these from
  // intake_submissions; contact edits target THIS table, never the raw
  // submission). Note the applicant_email / applicant_phone naming here.
  applications: {
    id: "id",
    submissionId: "submission_id", // join key -> intake_submissions.id
    firstName: "applicant_first_name",
    lastName: "applicant_last_name",
    email: "applicant_email",
    phone: "applicant_phone",
    displayName: "display_name",
    placecode: "placecode",
    status: "status"
  },
  events: {
    id: "id",
    caseId: "case_id", // join key -> cases.id
    type: "event_type", // comm_logged | assessment_event | progress_task | note
    description: "event_description",
    source: "event_source",
    performedAt: "performed_at"
  }
};

// Urgent-condition checkboxes on intake_submissions -> display labels.
// A case is "urgent" when any of these is true.
export const URGENT_FLAG_LABELS = {
  urgent_unable_to_stay: "Unable to stay in home",
  urgent_no_hvac: "No heating or cooling",
  urgent_no_potable_water: "No potable water",
  urgent_no_bathroom: "No working bathroom",
  urgent_no_kitchen: "No working kitchen",
  urgent_open_to_elements: "Open to elements",
  urgent_no_entry: "Cannot enter/exit safely",
  urgent_accessibility: "Accessibility barrier",
  urgent_eviction_risk: "Eviction risk"
};
