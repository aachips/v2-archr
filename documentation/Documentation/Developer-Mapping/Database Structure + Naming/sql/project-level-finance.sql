-- case_funding is created in role-based-access.sql (RBAC is the source of truth
-- per master-schema.dbml). This file contributes the finance-lifecycle columns
-- that the RBAC version omits: approval date, expiration date, and status.
ALTER TABLE case_funding
    ADD COLUMN IF NOT EXISTS approved_date DATE,
    ADD COLUMN IF NOT EXISTS expiration_date DATE,
    ADD COLUMN IF NOT EXISTS status VARCHAR(50); -- 'pending', 'approved', 'expired', 'depleted'
-- Reimbursement requests
CREATE TABLE reimbursement_requests (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id),
    organization_id INTEGER REFERENCES coalition_organizations(id),
    amount DECIMAL(12,2) NOT NULL,
    submitted_date DATE NOT NULL,
    approved_date DATE,
    paid_date DATE,
    status VARCHAR(50), -- 'submitted', 'approved', 'paid', 'denied'
    denial_reason TEXT,
    funding_source_id INTEGER REFERENCES funding_sources(id)
);
-- Case locking / claim tracking
CREATE TABLE case_claims (
    case_id INTEGER PRIMARY KEY REFERENCES cases(id),
    claimed_by_org_id INTEGER REFERENCES coalition_organizations(id),
    claimed_at TIMESTAMP,
    expires_at TIMESTAMP,
    is_locked BOOLEAN DEFAULT TRUE
);
