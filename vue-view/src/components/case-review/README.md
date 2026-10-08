# Case Review components — data requirements

`CaseReview.vue` (one directory up) is the page template; every section is a
component here. Naming convention: **Summary\*** components summarize data;
**\*Overview** components explain context. Styles for all of them live in
`src/assets/styles/case-review.css` (imported once in `src/main.js`); shared
primitives (.panel, .pill, .btn, .def-list, .alert, .modal) are in
`src/assets/styles/base.css`.

Role model (demo simplification of `app/lib/case-access.php`):
`staff` = level 1 (limited view), `org-admin` = level 2 and `super-admin` =
level 3 (full view). Switch roles from the header to preview.

| Component | Renders | In the dummy base? | Back-end needs |
|---|---|---|---|
| `CaseBreadcrumbs` | Back-to-list link | n/a (client-side) | vue-router later for a real trail |
| `UrgentOverview` | Urgent-flag banner | Yes (`intake_submissions.urgent_*` checkboxes) | — |
| `SummaryHead` | Address-first title, applicant, key facts, status pills, org badge | Mostly | `application_anchor.project_code` import → `joinCase.projectCode` (currently `""`, so job code shows "—") |
| `ApplicationCaseList` | Sibling cases grouped by shared `submission_id` | Partial | `claims` tables (claim status, 90-day window columns); `cases.application_id` for the real grouping key |
| `PipelineProgress` | Six-phase tracker + next steps (best-effort from `case_statuses.status_sequence`) | Partial | Milestone columns on `cases` (`intake_completed_at`, `assessment_scheduled_at`, `assessment_completed_at`, `approved_at`, `work_started_at`, `work_completed_at`) for exact `archr_case_phase()` parity |
| `DocsList` | Required-doc checklist; Download when on file, Upload when missing | No | `case_documents` table: `case_id`, doc `key`/category, Airtable attachment (or URL), `uploaded_by`, `uploaded_at`. Reference: `app/lib/case-documents.php` |
| `SummaryCase` | Application & Case identity | Partial | `cases.queue_status`, `cases.priority_score`; project code as above |
| `SummaryFunding` | Budget figures + spent bar; FEMA/insurance/Helene | No | On `cases`: `total_budget`, `total_actual_cost`, `fema_claim_filed`, `fema_outcome`, `insurance_claim_filed`, `insurance_outcome`, `helene_related` |
| `SummaryApplicant` | Contact/household details + contact edit (writes `applications`, never the raw submission) | Mostly | `applicant_dob` (+ `applicant_dob_unknown`), `owns_home`, `owns_lot`, `is_primary_residence`, household-attribute rows |
| `SummaryEligibility` | Green/yellow/red flags + report | No | `applications.eligibility_flags` (JSON `{green,yellow,red}`) + `applications.eligibility_report`; per-org match table for scores |
| `SummaryNeeds` | Repair-need chips + urgent-condition chips | Partial | Import `submission_repair_categories` / `repair_categories` junction tables (INTEGRATION.md §6) |
| `SummaryTasks` | Event log + "+ Log event" modal | Yes (`progress_events` via `fetchCaseEvents` / `saveCaseEvent`) | — |
| `DangerZone` | Withdraw / terminate intents | No (actions) | Consequential-action endpoint equivalent to `app/api/org-admin.php`, with the same human-confirmation gates |

## Notes

- `SummaryFunding` is the `.summary-finding` slot from the section list —
  mapped to app/'s Funding & Claims panel (`.case-funding`).
- Urgent chips render human labels ("No heating or cooling"), not raw flag
  keys — an improvement over the previous CaseReview, which printed keys.
- `FilterableCaseList.vue`, `QuickTasks.vue`, and `HelpLibrary.vue` still
  carry inline scoped styles — externalize them into `src/assets/styles/`
  when next touched.