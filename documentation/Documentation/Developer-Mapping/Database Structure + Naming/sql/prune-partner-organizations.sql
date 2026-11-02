-- =====================================================
-- PRUNE PARTNER ORGANIZATIONS to the five real coalition partners
-- =====================================================
-- Keeps (by organization_code): AHFH, MHO, CAO, CHC, LANDOFSKY.
-- Creates CHC and Land of Sky when missing. Everything else is removed
-- with FK-safe cleanup; cases claimed by a removed org are released back
-- to the unclaimed pool (organization_id NULL) rather than deleted.
--
-- Idempotent. Run: psql -d archr -f sql/prune-partner-organizations.sql
-- or: php app/apply-migration.php sql/prune-partner-organizations.sql
-- =====================================================

\set ON_ERROR_STOP on

BEGIN;

-- The five real partners (create any that are missing).
INSERT INTO coalition_organizations (organization_code, organization_name, contact_email, max_active_applications, is_active)
VALUES ('CHC', 'Community Housing Coalition', 'hello@chc-madison.org', 40, TRUE)
ON CONFLICT (organization_code) DO NOTHING;

INSERT INTO coalition_organizations (organization_code, organization_name, contact_email, max_active_applications, is_active)
VALUES ('LANDOFSKY', 'Land of Sky', 'info@landofsky.org', 40, TRUE)
ON CONFLICT (organization_code) DO NOTHING;

-- Stage the doomed org ids (CASCADE covers: organization_users,
-- organization_eligibility_rules, organization_metrics, funding_sources,
-- eligibility_results, user_role_assignments).
CREATE TEMP TABLE _prune_orgs AS
SELECT id FROM coalition_organizations
 WHERE organization_code NOT IN ('AHFH', 'MHO', 'CAO', 'CHC', 'LANDOFSKY');

-- Release any cases claimed by doomed orgs back to the unclaimed pool.
UPDATE cases
   SET organization_id = NULL, claimed_at = NULL, claimed_by = NULL,
       claim_status = NULL, claim_expires_at = NULL, last_progress_at = NULL
 WHERE organization_id IN (SELECT id FROM _prune_orgs);

-- Org-scoped operational rows from doomed orgs are dummy data — delete.
DELETE FROM case_claims WHERE claimed_by_org_id IN (SELECT id FROM _prune_orgs);
DELETE FROM case_repair_claims WHERE organization_id IN (SELECT id FROM _prune_orgs);
DELETE FROM application_assignments WHERE organization_id IN (SELECT id FROM _prune_orgs);
DELETE FROM progress_events WHERE organization_id IN (SELECT id FROM _prune_orgs);
DELETE FROM reimbursement_requests WHERE organization_id IN (SELECT id FROM _prune_orgs);

-- Non-FK org references: clear, do not delete the rows.
UPDATE review_queue SET organization_id = NULL WHERE organization_id IN (SELECT id FROM _prune_orgs);
UPDATE application_anchor SET assigned_organization_id = NULL WHERE assigned_organization_id IN (SELECT id FROM _prune_orgs);

-- Remove the orgs (CASCADE finishes the rest).
DELETE FROM coalition_organizations WHERE id IN (SELECT id FROM _prune_orgs);

DROP TABLE _prune_orgs;

-- Orgs created by this script (or added later) have no per-org match rows
-- yet — backfill them for all existing submissions.
INSERT INTO eligibility_results (submission_id, organization_id, match_score, is_eligible)
SELECT s.id, o.id,
       calculate_match_score(s.id, o.id),
       calculate_match_score(s.id, o.id) >= 50
  FROM intake_submissions s
  CROSS JOIN coalition_organizations o
 WHERE o.is_active = TRUE
ON CONFLICT (submission_id, organization_id) DO NOTHING;

COMMIT;

-- Verify:
--   SELECT organization_code, organization_name FROM coalition_organizations ORDER BY id;