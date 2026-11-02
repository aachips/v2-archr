-- =====================================================
-- WIPE INTAKE TEST DATA
-- =====================================================
-- Removes ALL submissions and everything derived from them:
-- applications, cases (with every case child: claims, history, documents,
-- assessments, work orders/tasks, finance rows, progress events), anchors,
-- review queue, assignments, eligibility results, guest tokens, audit rows,
-- plus requestor-only user accounts created for those submissions and
-- case-linked notifications.
--
-- PRESERVES: organizations, staff/admin users, roles/permissions,
-- lookup tables (repair_categories, household_attributes, case_statuses...),
-- help content, SOPs, badges/skills definitions.
--
-- Use on development/staging only. Run:
--   psql -d archr -f sql/wipe-intake-test-data.sql
-- or: php app/apply-migration.php sql/wipe-intake-test-data.sql
-- =====================================================

\set ON_ERROR_STOP on

BEGIN;

-- Requestor-only accounts (created automatically for dummy submissions).
-- Ids are staged in a temp table FIRST: deleting role assignments before the
-- user delete would otherwise re-evaluate the "requestor-only" predicate to
-- empty mid-flight.
CREATE TEMP TABLE _wipe_requestor_users AS
SELECT u.id
  FROM system_users u
 WHERE EXISTS (
        SELECT 1 FROM user_role_assignments ura
          JOIN roles r ON r.id = ura.role_id
         WHERE ura.user_id = u.id AND r.role_code = 'REQUESTOR')
   AND NOT EXISTS (
        SELECT 1 FROM user_role_assignments ura
          JOIN roles r ON r.id = ura.role_id
         WHERE ura.user_id = u.id AND r.role_code <> 'REQUESTOR');

DELETE FROM notifications
 WHERE user_id IN (SELECT id FROM _wipe_requestor_users);
DELETE FROM notifications WHERE entity_type = 'case'; -- dummy case events
DELETE FROM user_role_assignments
 WHERE user_id IN (SELECT id FROM _wipe_requestor_users);
DELETE FROM system_users
 WHERE id IN (SELECT id FROM _wipe_requestor_users);

DROP TABLE _wipe_requestor_users;

-- The whole submission/application/case forest. CASCADE walks every FK
-- child (repair rows, junctions, anchors, queue, assignments, eligibility,
-- case claims/history/documents/assessments/work orders/tasks/finance,
-- progress events, guest tokens, audits, ...). Lookup tables are untouched.
TRUNCATE TABLE applications, intake_submissions, cases RESTART IDENTITY CASCADE;

-- Matching materialized view reads intake_submissions; clear the stale rows.
REFRESH MATERIALIZED VIEW application_match_scores;

COMMIT;

-- Verify:
--   SELECT count(*) FROM intake_submissions;  -- 0
--   SELECT count(*) FROM applications;        -- 0
--   SELECT count(*) FROM cases;               -- 0