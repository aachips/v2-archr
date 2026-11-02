-- =====================================================
-- ARCHR Bursar Dashboard Schema Changes
-- Companion to: interface/bursar/bursar-technical-plan.md
-- =====================================================
--
-- Source-of-truth tables already exist and are NOT redefined here:
--   role-based-access.sql      : funding_sources, case_funding, invoices,
--                                cases, system_users, coalition_organizations
--   project-level-finance.sql  : reimbursement_requests (bare-bones),
--                                case_claims, case_funding lifecycle columns
--   partner-organizations.sql  : application_assignments (claim status source)
--
-- This file adds the columns, constraints, triggers, and views required by
-- the Bursar Dashboard wireframe + technical plan. All ALTERs use IF NOT
-- EXISTS so the script is idempotent and safe to re-run on existing data.

-- =====================================================
-- 1. EXTEND funding_sources
-- =====================================================
-- Required by funding_source_summary view (filter on active sources).
ALTER TABLE funding_sources
    ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- =====================================================
-- 2. EXTEND case_funding (status / hold support)
-- =====================================================
-- project-level-finance.sql already adds approved_date, expiration_date,
-- and a free-form status column. The bursar plan needs the 'on_hold' value
-- plus an explicit hold_reason for the "On Hold" KPI card and audit trail.
ALTER TABLE case_funding
    ADD COLUMN IF NOT EXISTS hold_reason TEXT,
    ADD COLUMN IF NOT EXISTS held_by INTEGER REFERENCES system_users(id),
    ADD COLUMN IF NOT EXISTS held_at TIMESTAMP;

-- =====================================================
-- 3. EXTEND reimbursement_requests
-- =====================================================
-- project-level-finance.sql defined the minimal row; the plan requires
-- a formatted public id, full review/payment audit, line items, and
-- separate actor columns for approve / reject / pay.
ALTER TABLE reimbursement_requests
    ADD COLUMN IF NOT EXISTS request_id VARCHAR(50) UNIQUE,
    ADD COLUMN IF NOT EXISTS submitted_by INTEGER REFERENCES system_users(id),
    ADD COLUMN IF NOT EXISTS invoice_number VARCHAR(100),
    ADD COLUMN IF NOT EXISTS invoice_date DATE,
    ADD COLUMN IF NOT EXISTS invoice_document_id INTEGER, -- FK target: case_documents (document-storage.sql)
    ADD COLUMN IF NOT EXISTS line_items JSONB,
    ADD COLUMN IF NOT EXISTS notes TEXT,
    ADD COLUMN IF NOT EXISTS approved_by INTEGER REFERENCES system_users(id),
    ADD COLUMN IF NOT EXISTS approved_at TIMESTAMP,
    ADD COLUMN IF NOT EXISTS rejected_by INTEGER REFERENCES system_users(id),
    ADD COLUMN IF NOT EXISTS rejected_at TIMESTAMP,
    ADD COLUMN IF NOT EXISTS rejection_reason TEXT,
    ADD COLUMN IF NOT EXISTS paid_by INTEGER REFERENCES system_users(id),
    ADD COLUMN IF NOT EXISTS paid_at TIMESTAMP,
    ADD COLUMN IF NOT EXISTS payment_reference VARCHAR(100),
    ADD COLUMN IF NOT EXISTS submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE INDEX IF NOT EXISTS idx_reimb_case   ON reimbursement_requests(case_id);
CREATE INDEX IF NOT EXISTS idx_reimb_org    ON reimbursement_requests(organization_id);
CREATE INDEX IF NOT EXISTS idx_reimb_status ON reimbursement_requests(status);

-- Auto-format public request id as REIMB-YYYY-NNNNN once the row has an id.
CREATE OR REPLACE FUNCTION generate_reimbursement_request_id()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.request_id IS NULL THEN
        NEW.request_id := 'REIMB-' ||
                          TO_CHAR(COALESCE(NEW.submitted_at, CURRENT_TIMESTAMP), 'YYYY') ||
                          '-' || LPAD(NEW.id::TEXT, 5, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_reimbursement_request_id ON reimbursement_requests;
CREATE TRIGGER trigger_reimbursement_request_id
    BEFORE INSERT ON reimbursement_requests
    FOR EACH ROW
    EXECUTE PROCEDURE generate_reimbursement_request_id();

-- Keep updated_at fresh on status changes (workflow events).
CREATE OR REPLACE FUNCTION touch_reimbursement_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_touch_reimbursement ON reimbursement_requests;
CREATE TRIGGER trigger_touch_reimbursement
    BEFORE UPDATE ON reimbursement_requests
    FOR EACH ROW
    EXECUTE PROCEDURE touch_reimbursement_timestamp();

-- =====================================================
-- 4. EXTEND application_assignments (claim override audit)
-- =====================================================
-- The plan's case_claim_status view sources claim info from
-- application_assignments. Add columns so a Bursar can override
-- a lock without losing the prior chain of custody.
ALTER TABLE application_assignments
    ADD COLUMN IF NOT EXISTS overridden_by INTEGER REFERENCES system_users(id),
    ADD COLUMN IF NOT EXISTS overridden_at TIMESTAMP,
    ADD COLUMN IF NOT EXISTS override_reason TEXT;

-- =====================================================
-- 5. PER-CASE $50,000 CAP ENFORCEMENT
-- =====================================================
-- Block inserts/updates on case_funding that would push a single case
-- over the household cap. Raises a friendly SQLSTATE so the API can
-- surface a clean validation message.
CREATE OR REPLACE FUNCTION enforce_case_funding_cap()
RETURNS TRIGGER AS $$
DECLARE
    v_total DECIMAL(12,2);
BEGIN
    SELECT COALESCE(SUM(allocated_amount), 0)
      INTO v_total
      FROM case_funding
     WHERE case_id = NEW.case_id
       AND (TG_OP = 'INSERT' OR id <> NEW.id);

    IF v_total + COALESCE(NEW.allocated_amount, 0) > 50000 THEN
        RAISE EXCEPTION 'Case % would exceed the $50,000 per-household cap (current: %, attempted add: %)',
            NEW.case_id, v_total, NEW.allocated_amount
            USING ERRCODE = 'check_violation';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_case_funding_cap ON case_funding;
CREATE TRIGGER trigger_case_funding_cap
    BEFORE INSERT OR UPDATE OF allocated_amount ON case_funding
    FOR EACH ROW
    EXECUTE PROCEDURE enforce_case_funding_cap();


-- =====================================================
-- 6. BURSAR ACTION AUDIT LOG
-- =====================================================
-- Append-only record of bursar-initiated actions (approvals, rejections,
-- payments, lock overrides, manual allocations, hold placements). The
-- dashboard's role-notice block promises this trail to partners and funders.
CREATE TABLE IF NOT EXISTS bursar_action_audit (
    id SERIAL PRIMARY KEY,
    actor_id INTEGER REFERENCES system_users(id),
    action_type VARCHAR(50) NOT NULL,
        -- approve_invoice, reject_invoice, mark_paid, place_on_hold,
        -- release_hold, override_lock, allocate_funds, reallocate_funds,
        -- adjust_cap, resolve_duplicate
    target_table VARCHAR(50) NOT NULL,
    target_id INTEGER NOT NULL,
    case_id INTEGER REFERENCES cases(id),
    organization_id INTEGER REFERENCES coalition_organizations(id),
    amount DECIMAL(12,2),
    before_state JSONB,
    after_state JSONB,
    reason TEXT,
    ip_address INET,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_bursar_audit_case   ON bursar_action_audit(case_id);
CREATE INDEX IF NOT EXISTS idx_bursar_audit_actor  ON bursar_action_audit(actor_id);
CREATE INDEX IF NOT EXISTS idx_bursar_audit_action ON bursar_action_audit(action_type);
CREATE INDEX IF NOT EXISTS idx_bursar_audit_when   ON bursar_action_audit(created_at);

-- =====================================================
-- 7. DASHBOARD VIEWS
-- =====================================================

-- 7a. Per-case funding summary (Requirement 1 in the technical plan).
-- Powers: the 4 KPI cards + the Active Cases table on the dashboard.
CREATE OR REPLACE VIEW case_funding_summary AS
SELECT
    c.id                                       AS case_id,
    c.case_number,
    c.submission_id,
    s.applicant_first_name,
    s.applicant_last_name,
    s.assigned_organization,
    COALESCE(SUM(cf.allocated_amount), 0)      AS approved_amount,
    COALESCE(SUM(cf.spent_amount), 0)          AS incurred_amount,
    COALESCE(SUM(CASE WHEN rr.status = 'paid'
                      THEN rr.invoice_amount END), 0) AS reimbursed_amount,
    COALESCE(SUM(CASE WHEN rr.status IN ('pending','review','approved')
                      THEN rr.invoice_amount END), 0) AS pending_reimbursement,
    COALESCE(SUM(CASE WHEN cf.status = 'on_hold'
                      THEN cf.allocated_amount END), 0) AS on_hold_amount,
    (COALESCE(SUM(cf.allocated_amount), 0)
     - COALESCE(SUM(CASE WHEN rr.status = 'paid'
                         THEN rr.invoice_amount END), 0)) AS outstanding_balance,
    (COALESCE(SUM(cf.allocated_amount), 0)
     - COALESCE(SUM(cf.spent_amount), 0))      AS remaining_available,
    CASE
        WHEN COALESCE(SUM(cf.allocated_amount), 0) > 50000 THEN 'EXCEEDS_CAP'
        WHEN COALESCE(SUM(cf.allocated_amount), 0) = 50000 THEN 'AT_CAP'
        ELSE 'UNDER_CAP'
    END AS cap_status,
    EXISTS (SELECT 1 FROM case_funding cf2
             WHERE cf2.case_id = c.id AND cf2.status = 'on_hold') AS has_hold
FROM cases c
JOIN intake_submissions s ON c.submission_id = s.id
LEFT JOIN case_funding cf         ON cf.case_id = c.id
LEFT JOIN reimbursement_requests rr ON rr.case_id = c.id
GROUP BY c.id, c.case_number, c.submission_id,
         s.applicant_first_name, s.applicant_last_name, s.assigned_organization;

-- 7b. Claim / lock status (Requirement 2).
-- Sources from application_assignments per the plan.
CREATE OR REPLACE VIEW case_claim_status AS
SELECT
    c.id            AS case_id,
    c.case_number,
    s.home_address,
    s.home_city,
    s.home_zip,
    aa.organization_id AS claiming_org_id,
    co.organization_name AS claiming_org_name,
    aa.claimed_by,
    ou.full_name    AS claimed_by_name,
    aa.claimed_at,
    aa.status       AS claim_status,
    aa.expires_at   AS lock_expires_at,
    aa.overridden_by,
    aa.overridden_at,
    aa.override_reason,
    EXISTS (
        SELECT 1
          FROM intake_submissions s2
          JOIN cases c2 ON s2.id = c2.submission_id
         WHERE s2.home_address = s.home_address
           AND s2.home_city    = s.home_city
           AND c2.id          <> c.id
           AND c2.status_id IN (SELECT id FROM case_statuses
                                 WHERE status_code IN ('ASSIGNED_TO_CREW','IN_PROGRESS'))
    ) AS duplicate_address_flag,
    EXTRACT(EPOCH FROM (aa.expires_at - CURRENT_TIMESTAMP)) / 86400 AS days_until_expiry
FROM cases c
JOIN intake_submissions s ON c.submission_id = s.id
LEFT JOIN application_assignments aa
       ON aa.submission_id = c.submission_id
      AND aa.status IN ('claimed','pending')
LEFT JOIN coalition_organizations co ON aa.organization_id = co.id
LEFT JOIN organization_users ou      ON aa.claimed_by      = ou.id
WHERE c.status_id NOT IN (SELECT id FROM case_statuses
                           WHERE status_code IN ('COMPLETED','DENIED'));


-- 7c. Reimbursement aging (Requirement 3).
-- Powers the Reimbursement Queue panel + the "overdue" KPI badge.
-- SLA target per the plan is 30 days from submission to payment.
CREATE OR REPLACE VIEW reimbursement_aging AS
SELECT
    rr.id,
    rr.request_id,
    rr.case_id,
    c.case_number,
    rr.organization_id,
    co.organization_name,
    rr.invoice_amount,
    rr.invoice_number,
    rr.invoice_date,
    rr.status,
    rr.submitted_at,
    rr.approved_at,
    rr.paid_at,
    EXTRACT(DAY FROM (CURRENT_TIMESTAMP - rr.submitted_at))::INTEGER AS days_aging,
    CASE
        WHEN rr.status = 'paid' THEN 'paid'
        WHEN EXTRACT(DAY FROM (CURRENT_TIMESTAMP - rr.submitted_at)) > 30 THEN 'overdue'
        WHEN EXTRACT(DAY FROM (CURRENT_TIMESTAMP - rr.submitted_at)) > 20 THEN 'at_risk'
        ELSE 'on_track'
    END AS sla_status,
    CASE
        WHEN rr.paid_at IS NOT NULL
            THEN EXTRACT(DAY FROM (rr.paid_at - rr.submitted_at))::INTEGER
        ELSE NULL
    END AS days_to_pay
FROM reimbursement_requests rr
JOIN cases c                       ON rr.case_id = c.id
JOIN coalition_organizations co    ON rr.organization_id = co.id;

-- 7d. Funding source summary (Requirement 4).
-- Powers the Funding Sources panel: allocated vs. spent vs. remaining and
-- a health pill (Healthy / Depleting / Depleted).
CREATE OR REPLACE VIEW funding_source_summary AS
SELECT
    fs.id                          AS funding_source_id,
    fs.source_name,
    fs.source_type,
    fs.total_amount,
    COALESCE(SUM(cf.allocated_amount), 0)         AS allocated_amount,
    COALESCE(SUM(cf.spent_amount), 0)             AS spent_amount,
    (fs.total_amount - COALESCE(SUM(cf.allocated_amount), 0)) AS remaining_amount,
    COUNT(DISTINCT cf.case_id)                    AS cases_funded,
    CASE
        WHEN fs.total_amount = 0 THEN 0
        ELSE ROUND((COALESCE(SUM(cf.allocated_amount), 0) / fs.total_amount) * 100, 1)
    END                                           AS percent_allocated,
    CASE
        WHEN fs.total_amount = 0 THEN 'depleted'
        WHEN COALESCE(SUM(cf.allocated_amount), 0) >= fs.total_amount THEN 'depleted'
        WHEN COALESCE(SUM(cf.allocated_amount), 0) >= (fs.total_amount * 0.85) THEN 'depleting'
        ELSE 'healthy'
    END                                           AS health_status
FROM funding_sources fs
LEFT JOIN case_funding cf ON cf.funding_source_id = fs.id
WHERE fs.is_active = TRUE
GROUP BY fs.id, fs.source_name, fs.source_type, fs.total_amount;

-- 7e. Duplicate / overlap detection (Requirement 5).
-- Powers the "Duplicate & Overlap Alerts" panel. Three signal types:
-- same address, same applicant identity, and overlapping repair scope on
-- different funding sources for the same case.
CREATE OR REPLACE VIEW duplicate_case_alerts AS
-- Same address across active cases
SELECT
    'same_address'                 AS alert_type,
    c1.id                          AS case_id,
    c1.case_number,
    c2.id                          AS related_case_id,
    c2.case_number                 AS related_case_number,
    s1.home_address                AS detail,
    NULL::VARCHAR                  AS funding_source_a,
    NULL::VARCHAR                  AS funding_source_b,
    GREATEST(c1.created_at, c2.created_at) AS detected_at
FROM cases c1
JOIN intake_submissions s1 ON c1.submission_id = s1.id
JOIN intake_submissions s2 ON s2.home_address = s1.home_address
                          AND s2.home_city    = s1.home_city
                          AND s2.id          <> s1.id
JOIN cases c2 ON c2.submission_id = s2.id
WHERE c1.id < c2.id

UNION ALL

-- Same applicant identity (name + DOB) on different cases
SELECT
    'same_applicant'               AS alert_type,
    c1.id, c1.case_number,
    c2.id, c2.case_number,
    (s1.applicant_first_name || ' ' || s1.applicant_last_name) AS detail,
    NULL, NULL,
    GREATEST(c1.created_at, c2.created_at)
FROM cases c1
JOIN intake_submissions s1 ON c1.submission_id = s1.id
JOIN intake_submissions s2 ON LOWER(s2.applicant_first_name) = LOWER(s1.applicant_first_name)
                          AND LOWER(s2.applicant_last_name)  = LOWER(s1.applicant_last_name)
                          AND s2.applicant_dob               = s1.applicant_dob
                          AND s2.id <> s1.id
JOIN cases c2 ON c2.submission_id = s2.id
WHERE c1.id < c2.id

UNION ALL

-- Same case drawing from two different funding sources for an overlapping
-- repair scope (potential double-billing surfaced in the dashboard panel).
SELECT
    'overlap_scope'                AS alert_type,
    cf1.case_id,
    c.case_number,
    cf1.case_id,
    c.case_number,
    cf1.funding_category           AS detail,
    fs1.source_name,
    fs2.source_name,
    GREATEST(cf1.created_at, cf2.created_at)
FROM case_funding cf1
JOIN case_funding cf2 ON cf2.case_id          = cf1.case_id
                     AND cf2.funding_category = cf1.funding_category
                     AND cf2.funding_source_id <> cf1.funding_source_id
                     AND cf2.id > cf1.id
JOIN cases c             ON c.id   = cf1.case_id
JOIN funding_sources fs1 ON fs1.id = cf1.funding_source_id
JOIN funding_sources fs2 ON fs2.id = cf2.funding_source_id;
