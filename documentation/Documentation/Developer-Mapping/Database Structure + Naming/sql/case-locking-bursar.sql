-- Case Locking / Claim Mechanism - As a Bursar, I want to prevent duplicate claims so that two organizations don't work on the same case.

-- Data Requirements: 

-- |Field|Type|Source|Definition|
-- |---|---|---|---|
-- |`claim_status`|VARCHAR(20)|`application_assignments`|unclaimed, claimed, locked, released|
-- |`claiming_organization`|UUID|`application_assignments`|Which org currently holds the claim|
-- |`claimed_by`|UUID|`application_assignments`|Which user claimed it|
-- |`claimed_at`|TIMESTAMP|`application_assignments`|When it was claimed|
-- |`lock_expires_at`|TIMESTAMP|`application_assignments`|Auto-release if no activity|
-- |`duplicate_flag`|BOOLEAN|Calculated|Same address/property appears elsewhere|

-- Business Rules:

-- + Once a case is claimed, no other org can claim it
-- + Claims auto-expire after 14 days of no activity
-- + Bursar can override locks (with reason logged)
-- + Duplicate addresses flagged automatically

CREATE OR REPLACE VIEW case_claim_status AS
SELECT 
    c.id AS case_id,
    c.case_number,
    s.home_address,
    s.home_city,
    s.home_zip,
    aa.organization_id AS claiming_org_id,
    co.organization_name AS claiming_org_name,
    aa.claimed_by,
    u.full_name AS claimed_by_name,
    aa.claimed_at,
    aa.status AS claim_status,
    aa.expires_at AS lock_expires_at,
    -- Duplicate detection
    EXISTS (
        SELECT 1 
        FROM intake_submissions s2
        JOIN cases c2 ON s2.id = c2.submission_id
        WHERE s2.home_address = s.home_address 
          AND s2.home_city = s.home_city
          AND c2.id != c.id
          AND c2.status_id IN (SELECT id FROM case_statuses WHERE status_code IN ('ASSIGNED_TO_CREW', 'IN_PROGRESS'))
    ) AS duplicate_address_flag,
    -- Time remaining
    EXTRACT(EPOCH FROM (aa.expires_at - NOW()))/86400 AS days_until_expiry
FROM cases c
JOIN intake_submissions s ON c.submission_id = s.id
LEFT JOIN application_assignments aa ON c.submission_id = aa.submission_id 
    AND aa.status IN ('claimed', 'locked')
LEFT JOIN coalition_organizations co ON aa.organization_id = co.id
LEFT JOIN system_users u ON aa.claimed_by = u.id
WHERE c.status_id NOT IN (SELECT id FROM case_statuses WHERE status_code IN ('COMPLETED', 'DENIED'));