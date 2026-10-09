-- ============================================================================
-- ARCHR PostgreSQL Master Schema
-- ============================================================================
-- This schema covers the PostgreSQL-only ecosystem:
--   - User authentication & authorization
--   - Role management & permission levels
--   - System configuration
--   - Support tickets
--   - Activity logging
--   - Blocked IPs & login security
--   - Assessments & Scope of Work
--   - Field edit audit trail
--
-- Tables NOT included here (managed in Airtable):
--   - applications / intake_submissions
--   - cases / case_statuses
--   - coalition_organizations
--   - repair_needs / repair_tasks
--
-- Usage:
--   psql -U postgres -d archr -f sql/master-schema-psql-only.sql
--
-- Compatible with PostgreSQL 14+
-- ============================================================================

-- ============================================================================
-- 1. ROLES & PERMISSIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS roles (
    id              BIGSERIAL PRIMARY KEY,
    role_code       VARCHAR(50) NOT NULL UNIQUE,  -- e.g., 'super_admin', 'org_admin'
    role_name       VARCHAR(100) NOT NULL,         -- e.g., 'Super Admin', 'Organizational Admin'
    role_level      INTEGER NOT NULL DEFAULT 0,    -- 0=Basic, 1=Admin Lite, 2=Org Admin, 3=Super Admin
    description     TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Default roles (per role consolidation plan: 12 → 4 levels)
INSERT INTO roles (role_code, role_name, role_level, description) VALUES
    ('volunteer',     'Volunteer',      0, 'Basic access — shifts, tasks, own application status'),
    ('crew_member',   'Crew Member',    0, 'Basic access — assigned tasks and schedules'),
    ('requestor',     'Requestor',      0, 'Household submitting application — can view own status'),
    ('admin_lite',    'Admin Lite',     1, 'Office workers — partial permissions, case lookup with limited purview'),
    ('org_admin',     'Org Admin',      2, 'Organizational Admin — full admin for one organization'),
    ('super_admin',   'Super Admin',    3, 'IT/account management, cross-organizational view, platform config')
ON CONFLICT (role_code) DO NOTHING;

-- ============================================================================
-- 2. SYSTEM USERS (auth accounts)
-- ============================================================================

CREATE TABLE IF NOT EXISTS system_users (
    id                  BIGSERIAL PRIMARY KEY,
    username            VARCHAR(100) NOT NULL UNIQUE,
    email               VARCHAR(255) NOT NULL UNIQUE,
    password_hash       TEXT NOT NULL,
    full_name           VARCHAR(255),
    is_active           BOOLEAN NOT NULL DEFAULT true,
    session_indefinite  BOOLEAN NOT NULL DEFAULT false,  -- "Keep me logged in indefinitely" toggle
    reset_token         VARCHAR(255),
    reset_token_expires TIMESTAMPTZ,
    menu_config         JSONB DEFAULT '{}',              -- per-user menu configuration
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 3. USER-ROLE ASSIGNMENTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS user_role_assignments (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT NOT NULL REFERENCES system_users(id) ON DELETE CASCADE,
    role_id     BIGINT NOT NULL REFERENCES roles(id),
    is_active   BOOLEAN NOT NULL DEFAULT true,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, role_id)
);

-- ============================================================================
-- 4. AUTH TOKENS (for Vue app — stateless JWT, but we track refresh tokens)
-- ============================================================================

CREATE TABLE IF NOT EXISTS auth_tokens (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT NOT NULL REFERENCES system_users(id) ON DELETE CASCADE,
    token_hash  VARCHAR(255) NOT NULL,
    expires_at  TIMESTAMPTZ NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_auth_tokens_user ON auth_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_auth_tokens_hash ON auth_tokens(token_hash);

-- ============================================================================
-- 5. LOGIN ATTEMPTS & SECURITY
-- ============================================================================

CREATE TABLE IF NOT EXISTS login_attempts (
    id              BIGSERIAL PRIMARY KEY,
    ip_address      VARCHAR(45) NOT NULL,
    username        VARCHAR(100),
    success         BOOLEAN NOT NULL DEFAULT false,
    attempted_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_login_attempts_ip ON login_attempts(ip_address);
CREATE INDEX IF NOT EXISTS idx_login_attempts_time ON login_attempts(attempted_at DESC);

CREATE TABLE IF NOT EXISTS blocked_ips (
    id              BIGSERIAL PRIMARY KEY,
    ip_address      VARCHAR(45) NOT NULL UNIQUE,
    blocked_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    blocked_by      BIGINT REFERENCES system_users(id),
    reason          TEXT,
    is_active       BOOLEAN NOT NULL DEFAULT true,
    expires_at      TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_blocked_ips_ip ON blocked_ips(ip_address);
CREATE INDEX IF NOT EXISTS idx_blocked_ips_active ON blocked_ips(is_active) WHERE is_active = true;

-- ============================================================================
-- 6. SUPPORT TICKETS
-- ============================================================================

CREATE TABLE IF NOT EXISTS support_tickets (
    id              BIGSERIAL PRIMARY KEY,
    category        VARCHAR(50) NOT NULL DEFAULT 'general',  -- bug, feature, access, data, general
    priority        VARCHAR(20) NOT NULL DEFAULT 'medium',   -- low, medium, high, critical
    status          VARCHAR(30) NOT NULL DEFAULT 'open',     -- open, in_progress, resolved, closed
    subject         TEXT NOT NULL,
    description     TEXT,
    submitted_by    VARCHAR(255),              -- user email or anonymous
    assigned_to     BIGINT REFERENCES system_users(id),
    resolution_note TEXT,
    resolved_at     TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_support_tickets_status ON support_tickets(status);
CREATE INDEX IF NOT EXISTS idx_support_tickets_priority ON support_tickets(priority);
CREATE INDEX IF NOT EXISTS idx_support_tickets_created ON support_tickets(created_at DESC);

-- ============================================================================
-- 7. ACTIVITY LOG
-- ============================================================================

CREATE TABLE IF NOT EXISTS activity_log (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT REFERENCES system_users(id),
    action          VARCHAR(100) NOT NULL,       -- e.g., 'login', 'edit_field', 'claim_case'
    entity_type     VARCHAR(50),                 -- e.g., 'application', 'case', 'user'
    entity_id       BIGINT,
    old_value       TEXT,
    new_value       TEXT,
    notes           TEXT,
    ip_address      VARCHAR(45),
    user_agent      TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_activity_log_user ON activity_log(user_id);
CREATE INDEX IF NOT EXISTS idx_activity_log_entity ON activity_log(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_activity_log_created ON activity_log(created_at DESC);

-- ============================================================================
-- 8. APPLICATION FIELD EDITS (audit trail)
-- ============================================================================

CREATE TABLE IF NOT EXISTS application_field_edits (
    id                  BIGSERIAL PRIMARY KEY,
    application_id      BIGINT NOT NULL,  -- references applications(id) in Airtable — no FK
    field_name          VARCHAR(100) NOT NULL,
    input_value         TEXT,
    corrected_value     TEXT,
    edit_note           TEXT,
    edited_by           BIGINT REFERENCES system_users(id),
    edited_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_app_edits_application ON application_field_edits(application_id);
CREATE INDEX IF NOT EXISTS idx_app_edits_field ON application_field_edits(application_id, field_name);
CREATE INDEX IF NOT EXISTS idx_app_edits_edited_at ON application_field_edits(edited_at DESC);

-- ============================================================================
-- 9. ASSESSMENTS & SCOPE OF WORK
-- ============================================================================

-- Note: applications table lives in Airtable. We reference it by ID but don't
-- create it here. If you need a local mirror for testing, see the Airtable sync
-- scripts in vue-view/scripts/.

CREATE TABLE IF NOT EXISTS assessments (
    id                          BIGSERIAL PRIMARY KEY,
    application_id              BIGINT NOT NULL,  -- references Airtable applications
    organization_id             BIGINT,            -- references coalition_organizations (Airtable)
    claim_number                VARCHAR(32),
    date_created                TIMESTAMPTZ DEFAULT NOW(),
    date_of_loss                DATE,
    date_inspected              DATE,
    date_received               DATE,
    date_entered                DATE,
    policy_number               VARCHAR(64),
    homeowner_names             JSONB DEFAULT '[]',
    full_address                TEXT,
    street                      TEXT,
    city                        TEXT,
    state                       TEXT DEFAULT 'NC',
    zip                         TEXT,
    phone                       TEXT,
    is_emergency                BOOLEAN DEFAULT false,
    emergency_desc              TEXT,
    total_construction_price    NUMERIC(12,2),
    assessor_name               TEXT,
    notes                       TEXT,
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_assessments_application ON assessments(application_id);
CREATE INDEX IF NOT EXISTS idx_assessments_claim_number ON assessments(claim_number);
CREATE INDEX IF NOT EXISTS idx_assessments_org ON assessments(organization_id);

-- Scope of Work line items (become claimable repair needs or cases)
CREATE TABLE IF NOT EXISTS scope_of_work_line_items (
    id                  BIGSERIAL PRIMARY KEY,
    assessment_id       BIGINT NOT NULL REFERENCES assessments(id) ON DELETE CASCADE,
    task_name           TEXT,
    location            TEXT,
    details             TEXT,
    estimated_cost      NUMERIC(12,2),
    quoted_cost         NUMERIC(12,2),
    actual_cost         NUMERIC(12,2),
    status              VARCHAR(20) DEFAULT 'pending',  -- pending, claimed, in_progress, completed
    repair_need_id      BIGINT,   -- links to repair_needs when forked
    case_id             BIGINT,   -- links to cases if grouped
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sow_line_items_assessment ON scope_of_work_line_items(assessment_id);
CREATE INDEX IF NOT EXISTS idx_sow_line_items_status ON scope_of_work_line_items(status);
CREATE INDEX IF NOT EXISTS idx_sow_line_items_repair_need ON scope_of_work_line_items(repair_need_id);

-- Materials inventory (itemized per SOW line item)
CREATE TABLE IF NOT EXISTS materials_inventory (
    id                  BIGSERIAL PRIMARY KEY,
    sow_line_item_id    BIGINT NOT NULL REFERENCES scope_of_work_line_items(id) ON DELETE CASCADE,
    material_name       TEXT,
    quantity            NUMERIC(10,2),
    unit                TEXT,
    unit_cost           NUMERIC(10,2),
    total_cost          NUMERIC(10,2) GENERATED ALWAYS AS (quantity * unit_cost) STORED,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_materials_sow ON materials_inventory(sow_line_item_id);

-- Assessment documents (links to Document Bucket)
CREATE TABLE IF NOT EXISTS assessment_documents (
    id              BIGSERIAL PRIMARY KEY,
    assessment_id   BIGINT NOT NULL REFERENCES assessments(id) ON DELETE CASCADE,
    document_type   VARCHAR(40),
    file_path       TEXT,
    file_name       TEXT,
    file_size       BIGINT,
    mime_type       VARCHAR(100),
    uploaded_at     TIMESTAMPTZ DEFAULT NOW(),
    uploaded_by     BIGINT REFERENCES system_users(id),
    metadata        JSONB DEFAULT '{}'
);

CREATE INDEX IF NOT EXISTS idx_assessment_docs_assessment ON assessment_documents(assessment_id);

-- Site photos (before/after)
CREATE TABLE IF NOT EXISTS site_photos (
    id              BIGSERIAL PRIMARY KEY,
    assessment_id   BIGINT,
    repair_need_id  BIGINT,
    file_path       TEXT NOT NULL,
    file_name       TEXT NOT NULL,
    title           TEXT,
    date_taken      TIMESTAMPTZ,
    taken_by        TEXT,
    photo_type      VARCHAR(20) DEFAULT 'before',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_site_photos_assessment ON site_photos(assessment_id);
CREATE INDEX IF NOT EXISTS idx_site_photos_repair_need ON site_photos(repair_need_id);

-- ============================================================================
-- 10. DEFAULT SUPER ADMIN USER (only if no users exist)
-- ============================================================================
-- Password: change-me-in-production (bcrypt hash — change immediately!)
-- DO NOT use this in production without changing the password.

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM system_users) THEN
        INSERT INTO system_users (username, email, password_hash, full_name, is_active)
        VALUES (
            'admin',
            'admin@archr.local',
            '$2b$10$Zs8Y..REPLACE.WITH.BCRYPT.HASH.OF.YOUR.PASSWORD',
            'System Administrator',
            true
        );

        -- Assign Super Admin role
        INSERT INTO user_role_assignments (user_id, role_id)
        SELECT u.id, r.id
        FROM system_users u, roles r
        WHERE u.username = 'admin' AND r.role_code = 'super_admin';
    END IF;
END
$$;

-- ============================================================================
-- 11. GRANT PERMISSIONS (for non-superuser database access)
-- ============================================================================
-- Uncomment and modify for your volunteer machine setup:
-- CREATE USER archr_app WITH PASSWORD 'your-secure-password';
-- GRANT CONNECT ON DATABASE archr TO archr_app;
-- GRANT USAGE ON SCHEMA public TO archr_app;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO archr_app;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO archr_app;

-- ============================================================================
-- End of schema
-- ============================================================================
