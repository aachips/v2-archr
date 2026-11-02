# Application / Case Model Migration — Implementation README

Companion to **ARCHR Core Terminology and Operational Logic** (2026-08-17).
This document describes what changed in `app/` to implement that specification,
the decisions made, and — most importantly — the full breadth of remaining
work the model change ripples into.

Status: **backend complete** (2026-08-19). UI work is intentionally deferred.

---

## 1. The model now implemented

```
SUBMISSION   raw form response            -> intake_submissions (unchanged)
APPLICATION  deduplicated entry/placecode -> applications        (NEW)
CASE         one per claiming org          -> cases + application_id/organization_id (ALTERED)
PROJECT      batch of repairs              -> work_orders        (existing, mapped)
REPAIR TASK  smallest unit of work         -> work_tasks         (existing, mapped)
PROGRESS     immutable event log           -> progress_events    (NEW)
```

One Application may host **several Cases — one per claiming organization**
(e.g. Habitat claims the roof, CHC claims the plumbing on the same household).
Each case carries its own claim status and a **90-day progress cooldown**:
any progress event logged against the case resets `claim_expires_at` to
now + 90 days; with no progress for 90 days the claim expires and the
application becomes claimable by other organizations.

## 2. What was built (this pass)

### Database — `sql/application-lifecycle.sql` (new, idempotent)
- `applications` table: placecode (unique), `display_name`
  ("42 Cherry Street - Asheville" — human-friendly identifier), applicant/property
  core fields, `status` (`new/active/concluded/terminated/withdrawn/expired`),
  `status_reason`, `terminated_reason_checkboxes`, `eligibility_flags`
  (green/yellow/red JSONB), `eligibility_report`, activity timestamps.
- `intake_submissions` += `placecode`, `is_duplicate`, `deduplicated_into`.
- `cases` += `application_id`, `organization_id`, `claimed_at`, `claimed_by`,
  `claim_expires_at` (default now+90d), `claim_status` (active/expired/released),
  `last_progress_at`, `progress_events_count`; one-case-per-submission
  uniqueness dropped; one-case-per-(application, org) enforced.
- `progress_events` immutable log (`is_progress_event` distinguishes timer-resetting
  events from administrative ones).
- Functions: `archr_generate_placecode`, `archr_display_name`,
  `canonical_termination_reasons`, `deduplicate_submissions`, `claim_application`,
  `log_progress_event`, `expire_stale_claims`, `validate_status_transition`,
  `set_application_status` (enforces checkbox/contact-note rules).
- Idempotent backfill: historical submissions consolidated into applications;
  existing cases linked; legacy `case_claims` / anchor assignments adopted as
  owning orgs with their 90-day window starting at the original claim time.
- Wired into `sql/_master.sql` (Tier 2, first).
- Also fixed a pre-existing crash in `sql/partner-organizations.sql`
  (`auto_assign_applications()` had ambiguous `ON CONFLICT` column names that
  broke every raw `intake_submissions` insert when the trigger fires, e.g. on
  non-superuser webhosts).

### Eligibility is now flags-only (no robot denials)
- `app/lib/eligibility.php` and `sql/eligibility-tracker.sql` `check_eligibility()`:
  always assume eligibility; emit green/yellow/red flags; red flags set
  `submission_status = 'needs_review'` (never `ineligible`) and store flags on
  the application. Org-specific checks (e.g. each org verifies income under its
  own program maximum) remain per-organization in `eligibility_results`.
- The intake anchor no longer writes `ineligible`.

### PHP — `app/lib/applications.php` (new)
Validated wrappers over the SQL functions plus `archr_get_application()` —
the doc-shaped payload — `archr_list_applications()` (org-scoped),
`archr_termination_reasons()`, `archr_placecode()` (canonical; the old
`_archr_placecode()` delegates to it), and display-name helpers.

### Endpoints / flows
- `app/api/applications.php` (new, read-only): `?id=`, `?placecode=`, `?list=1`
  with org scoping and status filter; response matches the doc's example.
- `app/api/org-admin.php`: `claim_case` now claims at the **application** level
  (creates/reactivates the org's case, restarts the 90-day timer; first claim
  adopts the unclaimed intake case). Repair rows remain exclusive across all
  orgs (one active claim per repair). `withdraw_case` withdraws the **whole
  application** (all org cases close). New `terminate_application` action with
  required canonical checkbox reasons. Releases/withdrawals/terminations log
  non-progress events (they never extend a claim).
- `app/api/run-maintenance.php`: new `expire_stale_claims` action (super admin).
  Also made the missing `lib/user-maintenance.php` require non-fatal
  (pre-existing breakage) so other actions still run.
- `app/lib/intake-save.php`: every submission is deduplicated into its
  application at intake; duplicate submissions at the same placecode join the
  existing application instead of spawning parallel cases.
- `app/lib/case-review.php`, `app/lib/case-access.php`, `app/lib/org-admin.php`,
  `app/lib/case-documents.php`, `app/api/documents.php`, `app/case-search.php`:
  loaders/search understand `cases.organization_id`, application fields, the
  claimable pool (unclaimed + expired), and `display_name`.

## 3. Decisions & documented deviations

1. **Placecode format kept** (`145LAKEW`, 8-char) — the doc's sample `42-CHERRY`
   format was reviewed and the existing format retained (2026-08-19).
   Human-friendliness comes from `applications.display_name` instead of anchor IDs.
2. **Unclaimed intake case**: intake still creates one case per application so
   existing search/review screens find it; the first claiming org *adopts* it
   (preserving its case number, documents, history). Later orgs get fresh cases.
3. **Transition extensions** beyond the doc: `new -> withdrawn/terminated` and
   `expired -> withdrawn/terminated` are allowed, because an applicant can
   withdraw (or be terminated by humans) before/without any claim.
4. **Projects/Repair Tasks map onto `work_orders`/`work_tasks`** — no rename was
   done; API responses expose them under the doc's names.
5. `case_claims` (legacy single-org lock) is no longer written by the claim
   path; it remains for historical rows and is still consulted as a fallback.

## 4. Applying the migration

- Fresh database: `psql -d archr -f sql/_master.sql` (includes the new file).
- Existing database: `php app/apply-migration.php sql/application-lifecycle.sql`
  (idempotent; safe to re-run). Same for the edited `sql/eligibility-tracker.sql`
  and `sql/partner-organizations.sql` when applying to an existing DB.
- Daily job: schedule `SELECT * FROM expire_stale_claims();` (pg_cron or host
  cron) or POST `action=expire_stale_claims` to `app/api/run-maintenance.php`.

## 5. Remaining ripple work (not in this pass)

### UI (all deferred by design)
- Org Admin dashboard: claim/terminate/withdraw flows against applications
  (`application_id`), termination-reason checkboxes, 90-day countdown badges,
  application status display, human-readable `display_name` everywhere instead
  of anchor IDs. This is the priority surface — Bursar, Crew Lead, Envoy and
  Project Manager are planned to collapse into Org Admin permission levels.
- Case review page: show all org cases for the application + eligibility flags.
- Requestor portal: application-level status wording (withdrawn/terminated).
- Case search UI: surface `display_name` and claim expiry (backend ready).
- Termination checkbox rendering from `archr_termination_reasons()`.

### Platform / ops
- Cron/pg_cron scheduling of `expire_stale_claims()` in production, plus
  notification fan-out to the expiring org (and super admins) before/at expiry.
- Airtable dual-write mapping for `applications` + `progress_events`
  (`app/config/database.php` table_mappings; `app/lib/dual-write.php`).
- Regenerate `sql/_master.phppgadmin.sql` (it is a build artifact:
  `sql/build-phppgadmin.ps1`) so webhost deploys get the new schema.
- `sql/dummy-data.sql` / `app/lib/sample-data.php`: seed through the new
  application model (or run the backfill afterwards).
- Metric views (`sql/metric-tracking.sql`, `organization_metrics`) currently
  key off submissions/assignments; extend them to application-level funnel
  metrics (submissions -> applications -> claims -> conclusions) and add
  claim-expiry metrics.
- Documents: `case_documents` are case-scoped today; the doc says application
  documents are shared at the Application layer — decide the sharing rule
  (read access across orgs' cases of one application) before changing.
- Help content / terminology sweep (`app/help-content/*`,
  `documentation/*`) to the Submission -> Application -> Case -> Project ->
  Repair Task vocabulary.
- Tests: the harnesses used for this pass (dedup/claim/cooldown/expiry,
  flags-only eligibility, multi-org claims, withdraw/terminate) live outside
  the repo; a permanent PHPUnit/CLI test suite for the lifecycle is warranted.