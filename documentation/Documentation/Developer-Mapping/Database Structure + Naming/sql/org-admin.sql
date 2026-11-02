-- =====================================================
-- ORG ADMIN LIVE-DATA SUPPORT
-- Per-repair case claims + withdrawal attestations
-- =====================================================
--
-- Backs the Organization Administrator (permission level 2) portal:
--
-- 1) case_repair_claims  — an org can claim a whole case or only specific
--    "Repairs Needed" rows (repair_requests) from the requestor's intake
--    (e.g. claim Roofing but not HVAC). Only one ACTIVE claim is allowed
--    per repair row; releasing a claim frees it for another org.
--
-- 2) case_withdrawals — withdrawing/cancelling an application is a
--    consequential human decision. It may only happen after the admin has
--    confirmed directly with the applicant (phone, in person, or in
--    writing). The attestation is stored here — never automated.
--
-- 3) WITHDRAWN case status — terminal exit state, parallel to DENIED.
--
-- This file is idempotent so it can run on fresh deploys (via _master.sql)
-- and on existing databases as a migration.

-- ---------------------------------------------------------------
-- 1. WITHDRAWN case status (terminal)
-- ---------------------------------------------------------------
INSERT INTO case_statuses (status_code, status_name, status_sequence, is_terminal, allowed_roles_for_transition, description)
SELECT 'WITHDRAWN', 'Withdrawn', 98, true,
       ARRAY['ADMIN', 'SUPER_ADMIN', 'CASEWORKER'],
       'Application withdrawn at the applicant''s confirmed request - terminal'
WHERE NOT EXISTS (SELECT 1 FROM case_statuses WHERE status_code = 'WITHDRAWN');

-- ---------------------------------------------------------------
-- 2. Per-repair claims
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS case_repair_claims (
    id SERIAL PRIMARY KEY,
    case_id INTEGER NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
    repair_request_id INTEGER NOT NULL REFERENCES repair_requests(id) ON DELETE CASCADE,
    organization_id INTEGER NOT NULL REFERENCES coalition_organizations(id),
    claimed_by INTEGER REFERENCES system_users(id),
    claimed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    released_at TIMESTAMP,
    released_by INTEGER REFERENCES system_users(id),
    notes TEXT
);

-- One active claim per repair row (released claims stay for audit).
CREATE UNIQUE INDEX IF NOT EXISTS uq_case_repair_claims_active
    ON case_repair_claims (repair_request_id) WHERE released_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_case_repair_claims_case
    ON case_repair_claims (case_id, released_at);

CREATE INDEX IF NOT EXISTS idx_case_repair_claims_org
    ON case_repair_claims (organization_id, released_at);

-- ---------------------------------------------------------------
-- 3. Withdrawal attestations (human-confirmed only)
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS case_withdrawals (
    id SERIAL PRIMARY KEY,
    case_id INTEGER NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
    withdrawn_by INTEGER REFERENCES system_users(id),
    withdrawn_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Required attestation: the admin confirmed with the applicant
    -- directly (never an automated/do-not-reply process).
    requestor_confirmed BOOLEAN NOT NULL DEFAULT FALSE,
    confirmation_method VARCHAR(20) NOT NULL, -- phone, in_person, written
    confirmation_detail TEXT NOT NULL,        -- e.g. "Confirmed by phone with the applicant on 2026-07-28"
    reason TEXT
);

CREATE INDEX IF NOT EXISTS idx_case_withdrawals_case
    ON case_withdrawals (case_id, withdrawn_at DESC);
