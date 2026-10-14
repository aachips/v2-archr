-- ============================================================================
-- ARCHR Complete PostgreSQL Migration
-- ============================================================================
-- Generated from a full audit of every PHP file in app/ (171 files).
-- This file creates ALL tables and columns the code references but that are
-- NOT defined in the existing sql/master-schema-psql-only.sql.
--
-- SAFE TO RUN MULTIPLE TIMES:
--   - Every CREATE TABLE uses IF NOT EXISTS
--   - Every ALTER TABLE ADD COLUMN uses IF NOT EXISTS
--   - Every CREATE INDEX uses IF NOT EXISTS
--   - Every FK add uses a DO block that checks first
--
-- Usage:
--   psql -U postgres -d archr -f sql/complete-migration.sql
--
-- Tables already in master-schema-psql-only.sql (SKIPPED here):
--   roles, system_users, user_role_assignments, auth_tokens,
--   login_attempts, blocked_ips, support_tickets, activity_log,
--   application_field_edits, assessments, scope_of_work_line_items,
--   materials_inventory, assessment_documents, site_photos
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. COALITION ORGANIZATIONS
-- ============================================================================
-- Referenced by: setup.php, case-access.php, case-review.php, org-admin.php,
--   super-admin.php, documents.php, export-organization.php, etc.
-- master-schema does NOT define this table.

CREATE TABLE IF NOT EXISTS coalition_organizations (
    id                      BIGSERIAL PRIMARY KEY,
    organization_code       VARCHAR(50) NOT NULL UNIQUE,
    organization_name       VARCHAR(255) NOT NULL,
    contact_email           VARCHAR(255),
    contact_phone           VARCHAR(50),
    description             TEXT,
    is_active               BOOLEAN NOT NULL DEFAULT true,
    created_by              BIGINT REFERENCES system_users(id),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    funding_limit           NUMERIC(12,2),
    max_active_applications INTEGER,
    auto_claim_enabled      BOOLEAN DEFAULT true,
    notification_email      VARCHAR(255)
);

CREATE INDEX IF NOT EXISTS idx_coalition_orgs_active ON coalition_organizations(is_active) WHERE is_active = true;

-- Add columns that code references but master-schema doesn't define
ALTER TABLE coalition_organizations ADD COLUMN IF NOT EXISTS funding_limit NUMERIC(12,2);
ALTER TABLE coalition_organizations ADD COLUMN IF NOT EXISTS max_active_applications INTEGER;
ALTER TABLE coalition_organizations ADD COLUMN IF NOT EXISTS auto_claim_enabled BOOLEAN DEFAULT true;
ALTER TABLE coalition_organizations ADD COLUMN IF NOT EXISTS notification_email VARCHAR(255);
ALTER TABLE coalition_organizations ADD COLUMN IF NOT EXISTS created_by BIGINT REFERENCES system_users(id);
ALTER TABLE coalition_organizations ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ============================================================================
-- 2. INTAKE SUBMISSIONS
-- ============================================================================
-- Referenced by: intake-save.php, eligibility.php, case-review.php,
--   org-admin.php, documents.php, assessor/*, bursar/*, envoy/*, etc.
-- This is the PRIMARY intake table — every column the INSERT in
-- intake-save.php uses is defined here.

CREATE TABLE IF NOT EXISTS intake_submissions (
    id                              BIGSERIAL PRIMARY KEY,
    language                        VARCHAR(3) DEFAULT 'eng',
    is_referral                     BOOLEAN DEFAULT false,
    referrer_name                   VARCHAR(255),
    referrer_organization           VARCHAR(255),
    referrer_email                  VARCHAR(255),
    referrer_notes                  TEXT,
    consent_agreed                  BOOLEAN DEFAULT false,
    applicant_first_name            VARCHAR(255),
    applicant_last_name             VARCHAR(255),
    applicant_dob                   DATE,
    applicant_dob_unknown           BOOLEAN DEFAULT false,
    preferred_phone                 BOOLEAN DEFAULT false,
    preferred_text                  BOOLEAN DEFAULT false,
    preferred_email                 BOOLEAN DEFAULT false,
    preferred_other                 BOOLEAN DEFAULT false,
    home_phone                      VARCHAR(20),
    cell_phone                      VARCHAR(20),
    contact_email                   VARCHAR(255),
    other_contact_method_description TEXT,
    contact_notes                   TEXT,
    home_address                    TEXT,
    home_city                       VARCHAR(100),
    home_state                      VARCHAR(50),
    home_zip                        VARCHAR(20),
    is_primary_residence            BOOLEAN,
    receives_different_mail         BOOLEAN DEFAULT false,
    mail_address                    TEXT,
    mail_city                       VARCHAR(100),
    mail_state                      VARCHAR(50),
    mail_zip                        VARCHAR(20),
    home_type                       VARCHAR(50),
    year_built                      INTEGER,
    move_in_date                    DATE,
    owns_home                       BOOLEAN,
    owns_lot                        BOOLEAN,
    insurance_provider              VARCHAR(255),
    lived_one_year                  BOOLEAN,
    household_size                  INTEGER,
    household_adults                INTEGER,
    additional_repair_details       TEXT,
    urgent_unable_to_stay           BOOLEAN DEFAULT false,
    urgent_no_hvac                  BOOLEAN DEFAULT false,
    urgent_no_potable_water         BOOLEAN DEFAULT false,
    urgent_no_bathroom              BOOLEAN DEFAULT false,
    urgent_no_kitchen               BOOLEAN DEFAULT false,
    urgent_open_to_elements         BOOLEAN DEFAULT false,
    urgent_no_entry                 BOOLEAN DEFAULT false,
    urgent_accessibility            BOOLEAN DEFAULT false,
    urgent_other_issue              BOOLEAN DEFAULT false,
    urgent_eviction_risk            BOOLEAN DEFAULT false,
    helene_related                  BOOLEAN DEFAULT false,
    fema_claim_filed                BOOLEAN DEFAULT false,
    fema_outcome                    TEXT,
    fema_settlement_amount          NUMERIC(12,2),
    fema_remaining_exists           BOOLEAN DEFAULT false,
    fema_remaining_amount           NUMERIC(12,2),
    insurance_claim_filed           BOOLEAN DEFAULT false,
    insurance_outcome               TEXT,
    insurance_settlement_amount     NUMERIC(12,2),
    insurance_remaining_exists      BOOLEAN DEFAULT false,
    insurance_remaining_amount      NUMERIC(12,2),
    has_income                      BOOLEAN DEFAULT false,
    income_method                   VARCHAR(50),
    gross_annual_income             NUMERIC(12,2),
    income_docs_method              VARCHAR(50),
    zero_income_first_name          VARCHAR(255),
    zero_income_last_name           VARCHAR(255),
    zero_income_address             TEXT,
    zero_income_agreed              BOOLEAN DEFAULT false,
    applicant_signature             TEXT,
    zero_income_signature           TEXT,
    submission_status               VARCHAR(30) DEFAULT 'pending',
    is_test                         BOOLEAN DEFAULT false,
    submitted_at                    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    submitted_from_ip               INET,
    eligibility_checked_at          TIMESTAMPTZ,
    deduplicated_into               BIGINT,
    requestor_user_id               BIGINT,
    placecode                       VARCHAR(50),
    project_code                    VARCHAR(50),
    reviewed_by                     BIGINT,
    reviewed_at                     TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_intake_dedup ON intake_submissions(deduplicated_into);
CREATE INDEX IF NOT EXISTS idx_intake_status ON intake_submissions(submission_status);
CREATE INDEX IF NOT EXISTS idx_intake_submitted ON intake_submissions(submitted_at DESC);
CREATE INDEX IF NOT EXISTS idx_intake_placecode ON intake_submissions(placecode);
CREATE INDEX IF NOT EXISTS idx_intake_requestor ON intake_submissions(requestor_user_id);

-- Ensure all columns exist (for tables that were already partially created)
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS language VARCHAR(3) DEFAULT 'eng';
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS is_referral BOOLEAN DEFAULT false;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS referrer_name VARCHAR(255);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS referrer_organization VARCHAR(255);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS referrer_email VARCHAR(255);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS referrer_notes TEXT;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS consent_agreed BOOLEAN DEFAULT false;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS applicant_first_name VARCHAR(255);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS applicant_last_name VARCHAR(255);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS applicant_dob DATE;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS applicant_dob_unknown BOOLEAN DEFAULT false;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS preferred_phone BOOLEAN DEFAULT false;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS preferred_text BOOLEAN DEFAULT false;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS preferred_email BOOLEAN DEFAULT false;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS preferred_other BOOLEAN DEFAULT false;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS home_phone VARCHAR(20);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS cell_phone VARCHAR(20);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS contact_email VARCHAR(255);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS other_contact_method_description TEXT;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS contact_notes TEXT;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS home_address TEXT;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS home_city VARCHAR(100);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS home_state VARCHAR(50);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS home_zip VARCHAR(20);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS is_primary_residence BOOLEAN;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS receives_different_mail BOOLEAN DEFAULT false;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS mail_address TEXT;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS mail_city VARCHAR(100);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS mail_state VARCHAR(50);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS mail_zip VARCHAR(20);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS home_type VARCHAR(50);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS year_built INTEGER;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS move_in_date DATE;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS owns_home BOOLEAN;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS owns_lot BOOLEAN;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS insurance_provider VARCHAR(255);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS lived_one_year BOOLEAN;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS household_size INTEGER;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS household_adults INTEGER;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS additional_repair_details TEXT;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS urgent_unable_to_stay BOOLEAN DEFAULT false;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS urgent_no_hvac BOOLEAN DEFAULT false;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS urgent_no_potable_water BOOLEAN DEFAULT false;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS urgent_no_bathroom BOOLEAN DEFAULT false;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS urgent_no_kitchen BOOLEAN DEFAULT false;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS urgent_open_to_elements BOOLEAN DEFAULT false;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS urgent_no_entry BOOLEAN DEFAULT false;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS urgent_accessibility BOOLEAN DEFAULT false;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS urgent_other_issue BOOLEAN DEFAULT false;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS urgent_eviction_risk BOOLEAN DEFAULT false;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS helene_related BOOLEAN DEFAULT false;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS fema_claim_filed BOOLEAN DEFAULT false;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS fema_outcome TEXT;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS fema_settlement_amount NUMERIC(12,2);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS fema_remaining_exists BOOLEAN DEFAULT false;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS fema_remaining_amount NUMERIC(12,2);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS insurance_claim_filed BOOLEAN DEFAULT false;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS insurance_outcome TEXT;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS insurance_settlement_amount NUMERIC(12,2);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS insurance_remaining_exists BOOLEAN DEFAULT false;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS insurance_remaining_amount NUMERIC(12,2);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS has_income BOOLEAN DEFAULT false;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS income_method VARCHAR(50);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS gross_annual_income NUMERIC(12,2);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS income_docs_method VARCHAR(50);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS zero_income_first_name VARCHAR(255);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS zero_income_last_name VARCHAR(255);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS zero_income_address TEXT;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS zero_income_agreed BOOLEAN DEFAULT false;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS applicant_signature TEXT;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS zero_income_signature TEXT;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS submission_status VARCHAR(30) DEFAULT 'pending';
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS is_test BOOLEAN DEFAULT false;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS submitted_from_ip INET;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS eligibility_checked_at TIMESTAMPTZ;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS deduplicated_into BIGINT;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS requestor_user_id BIGINT;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS placecode VARCHAR(50);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS project_code VARCHAR(50);
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS reviewed_by BIGINT;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS reviewed_at TIMESTAMPTZ;

-- ============================================================================
-- 3. APPLICATIONS
-- ============================================================================
-- Referenced by: applications.php, eligibility.php, case-review.php,
--   org-admin.php, documents.php, intake-save.php (via dedup function).
-- This table lives in Airtable in prod but is queried locally.

CREATE TABLE IF NOT EXISTS applications (
    id                              BIGSERIAL PRIMARY KEY,
    placecode                     VARCHAR(50) UNIQUE,
    display_name                  VARCHAR(500),
    status                        VARCHAR(30) DEFAULT 'new',
    property_address              TEXT,
    property_city                 VARCHAR(100),
    property_state                VARCHAR(50),
    property_zip                  VARCHAR(20),
    applicant_first_name          VARCHAR(255),
    applicant_last_name           VARCHAR(255),
    applicant_email               VARCHAR(255),
    applicant_phone               VARCHAR(20),
    last_activity_at              TIMESTAMPTZ,
    eligibility_flags             JSONB,
    eligibility_report            TEXT,
    terminated_reason_checkboxes  TEXT[],
    created_at                    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status_reason                 TEXT
);

CREATE INDEX IF NOT EXISTS idx_app_placecode ON applications(placecode);
CREATE INDEX IF NOT EXISTS idx_app_status ON applications(status);

-- All columns from application-field-edits.sql + additional columns the code uses
ALTER TABLE applications ADD COLUMN IF NOT EXISTS placecode VARCHAR(50);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS display_name VARCHAR(500);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS status VARCHAR(30) DEFAULT 'new';
ALTER TABLE applications ADD COLUMN IF NOT EXISTS property_address TEXT;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS property_city VARCHAR(100);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS property_state VARCHAR(50);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS property_zip VARCHAR(20);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS applicant_first_name VARCHAR(255);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS applicant_last_name VARCHAR(255);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS applicant_email VARCHAR(255);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS applicant_phone VARCHAR(20);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS last_activity_at TIMESTAMPTZ;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS eligibility_flags JSONB;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS eligibility_report TEXT;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS terminated_reason_checkboxes TEXT[];
ALTER TABLE applications ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
ALTER TABLE applications ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
ALTER TABLE applications ADD COLUMN IF NOT EXISTS status_reason TEXT;

-- Columns from application-field-edits.sql
ALTER TABLE applications ADD COLUMN IF NOT EXISTS applicant_dob DATE;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS primary_spoken_language VARCHAR(50);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS home_phone VARCHAR(20);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS cell_phone VARCHAR(20);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS unit VARCHAR(50);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS city_town VARCHAR(100);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS state_province VARCHAR(50);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS zip_postal_code VARCHAR(20);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS primary_residence BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS lived_one_year BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS move_in_date DATE;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS home_type VARCHAR(50);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS other_home_type VARCHAR(100);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS year_built INTEGER;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS owns_home BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS owns_lot BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS insurance_provider VARCHAR(255);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS household_size INTEGER;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS household_adults INTEGER;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS gross_annual_income NUMERIC(12,2);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS gross_monthly_income NUMERIC(12,2);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS ami_percent NUMERIC(5,2);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS ami_year INTEGER;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS ami_group VARCHAR(20);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS helene_related BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS insurance_claim_filed BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS insurance_settlement_amount NUMERIC(12,2);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS fema_claim_filed BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS fema_settlement_amount NUMERIC(12,2);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS zero_income_agreed BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS additional_repair_details TEXT;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS urgent_unable_to_stay TEXT;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS urgent_no_hvac BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS urgent_no_potable_water BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS urgent_no_bathroom BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS urgent_no_kitchen BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS urgent_open_to_elements BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS urgent_no_entry BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS urgent_accessibility BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS urgent_other_issue BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS urgent_eviction_risk BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS language VARCHAR(3);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS is_referral BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS referrer_name VARCHAR(255);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS referrer_organization VARCHAR(255);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS referrer_email VARCHAR(255);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS referrer_notes TEXT;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS consent_agreed BOOLEAN;

-- ============================================================================
-- 4. CASE STATUSES (lookup) — must exist before cases table references it
-- ============================================================================

CREATE TABLE IF NOT EXISTS case_statuses (
    id              BIGSERIAL PRIMARY KEY,
    status_code     VARCHAR(50) NOT NULL UNIQUE,
    status_name     VARCHAR(100) NOT NULL,
    status_sequence INTEGER NOT NULL DEFAULT 0,
    is_terminal     BOOLEAN NOT NULL DEFAULT false
);

-- Seed standard statuses from the terminology doc
INSERT INTO case_statuses (status_code, status_name, status_sequence, is_terminal) VALUES
    ('PENDING_REVIEW', 'Pending Review', 1, false),
    ('INTAKE',         'Intake',         2, false),
    ('ASSESSMENT',     'Assessment',     3, false),
    ('DESIGN',         'Design',         4, false),
    ('CONSTRUCTION',   'Construction',   5, false),
    ('CLOSED',         'Closed',         6, true),
    ('WITHDRAWN',      'Withdrawn',      7, true),
    ('DEFERRED',       'Deferred',       8, false)
ON CONFLICT (status_code) DO NOTHING;

-- ============================================================================
-- 5. CASES
-- ============================================================================
-- Referenced by: case-review.php, org-admin.php, documents.php,
--   case-access.php, applications.php, super-admin.php, etc.

CREATE TABLE IF NOT EXISTS cases (
    id                          BIGSERIAL PRIMARY KEY,
    case_number                 VARCHAR(50) UNIQUE,
    submission_id               BIGINT REFERENCES intake_submissions(id),
    application_id              BIGINT,
    organization_id             BIGINT REFERENCES coalition_organizations(id),
    status_id                   BIGINT REFERENCES case_statuses(id),
    project_code                VARCHAR(50),
    placecode                   VARCHAR(50),
    claim_status                VARCHAR(20) DEFAULT 'unclaimed',
    claimed_at                  TIMESTAMPTZ,
    claim_expires_at            TIMESTAMPTZ,
    last_progress_at            TIMESTAMPTZ,
    progress_events_count       INTEGER DEFAULT 0,
    assigned_caseworker_id      BIGINT REFERENCES system_users(id),
    created_by                  BIGINT,
    updated_by                  BIGINT,
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_cases_application ON cases(application_id);
CREATE INDEX IF NOT EXISTS idx_cases_submission ON cases(submission_id);
CREATE INDEX IF NOT EXISTS idx_cases_org ON cases(organization_id);
CREATE INDEX IF NOT EXISTS idx_cases_claim_status ON cases(claim_status);
CREATE INDEX IF NOT EXISTS idx_cases_status_id ON cases(status_id);

ALTER TABLE cases ADD COLUMN IF NOT EXISTS case_number VARCHAR(50);
ALTER TABLE cases ADD COLUMN IF NOT EXISTS submission_id BIGINT REFERENCES intake_submissions(id);
ALTER TABLE cases ADD COLUMN IF NOT EXISTS application_id BIGINT;
ALTER TABLE cases ADD COLUMN IF NOT EXISTS organization_id BIGINT REFERENCES coalition_organizations(id);
ALTER TABLE cases ADD COLUMN IF NOT EXISTS status_id BIGINT REFERENCES case_statuses(id);
ALTER TABLE cases ADD COLUMN IF NOT EXISTS project_code VARCHAR(50);
ALTER TABLE cases ADD COLUMN IF NOT EXISTS placecode VARCHAR(50);
ALTER TABLE cases ADD COLUMN IF NOT EXISTS claim_status VARCHAR(20) DEFAULT 'unclaimed';
ALTER TABLE cases ADD COLUMN IF NOT EXISTS claimed_at TIMESTAMPTZ;
ALTER TABLE cases ADD COLUMN IF NOT EXISTS claim_expires_at TIMESTAMPTZ;
ALTER TABLE cases ADD COLUMN IF NOT EXISTS last_progress_at TIMESTAMPTZ;
ALTER TABLE cases ADD COLUMN IF NOT EXISTS progress_events_count INTEGER DEFAULT 0;
ALTER TABLE cases ADD COLUMN IF NOT EXISTS assigned_caseworker_id BIGINT REFERENCES system_users(id);
ALTER TABLE cases ADD COLUMN IF NOT EXISTS created_by BIGINT;
ALTER TABLE cases ADD COLUMN IF NOT EXISTS updated_by BIGINT;
ALTER TABLE cases ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
ALTER TABLE cases ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
-- ============================================================================
-- 6. APPLICATION ANCHOR
-- ============================================================================
-- Referenced by: intake-save.php, case-access.php, case-review.php,
--   documents.php, org-admin.php, super-admin.php.

CREATE TABLE IF NOT EXISTS application_anchor (
    submission_id               BIGINT UNIQUE REFERENCES intake_submissions(id),
    anchor_id                   VARCHAR(50) PRIMARY KEY,
    submitted_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    submitted_from_ip           INET,
    is_eligible                 BOOLEAN DEFAULT true,
    current_status              VARCHAR(30) DEFAULT 'eligible',
    income_bucket               VARCHAR(20),
    county_bucket               VARCHAR(20),
    repair_type_bucket          VARCHAR(20),
    helene_related              BOOLEAN DEFAULT false,
    placecode                   VARCHAR(50),
    project_code                VARCHAR(50),
    assigned_at                 TIMESTAMPTZ,
    assigned_organization_id    BIGINT REFERENCES coalition_organizations(id),
    eligibility_score           NUMERIC(5,2)
);

CREATE INDEX IF NOT EXISTS idx_anchor_submission ON application_anchor(submission_id);
CREATE INDEX IF NOT EXISTS idx_anchor_org ON application_anchor(assigned_organization_id);
CREATE INDEX IF NOT EXISTS idx_anchor_placecode ON application_anchor(placecode);

ALTER TABLE application_anchor ADD COLUMN IF NOT EXISTS anchor_id VARCHAR(50);
ALTER TABLE application_anchor ADD COLUMN IF NOT EXISTS submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
ALTER TABLE application_anchor ADD COLUMN IF NOT EXISTS submitted_from_ip INET;
ALTER TABLE application_anchor ADD COLUMN IF NOT EXISTS is_eligible BOOLEAN DEFAULT true;
ALTER TABLE application_anchor ADD COLUMN IF NOT EXISTS current_status VARCHAR(30) DEFAULT 'eligible';
ALTER TABLE application_anchor ADD COLUMN IF NOT EXISTS income_bucket VARCHAR(20);
ALTER TABLE application_anchor ADD COLUMN IF NOT EXISTS county_bucket VARCHAR(20);
ALTER TABLE application_anchor ADD COLUMN IF NOT EXISTS repair_type_bucket VARCHAR(20);
ALTER TABLE application_anchor ADD COLUMN IF NOT EXISTS helene_related BOOLEAN DEFAULT false;
ALTER TABLE application_anchor ADD COLUMN IF NOT EXISTS placecode VARCHAR(50);
ALTER TABLE application_anchor ADD COLUMN IF NOT EXISTS project_code VARCHAR(50);
ALTER TABLE application_anchor ADD COLUMN IF NOT EXISTS assigned_at TIMESTAMPTZ;
ALTER TABLE application_anchor ADD COLUMN IF NOT EXISTS assigned_organization_id BIGINT REFERENCES coalition_organizations(id);
ALTER TABLE application_anchor ADD COLUMN IF NOT EXISTS eligibility_score NUMERIC(5,2);

-- ============================================================================
-- 7. REVIEW QUEUE
-- ============================================================================

CREATE TABLE IF NOT EXISTS review_queue (
    submission_id   BIGINT PRIMARY KEY REFERENCES intake_submissions(id),
    status          VARCHAR(30) DEFAULT 'PENDING_REVIEW',
    queued_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    priority_score  INTEGER DEFAULT 0,
    assigned_at     TIMESTAMPTZ,
    organization_id BIGINT REFERENCES coalition_organizations(id)
);

CREATE INDEX IF NOT EXISTS idx_queue_status ON review_queue(status);
CREATE INDEX IF NOT EXISTS idx_queue_org ON review_queue(organization_id);

ALTER TABLE review_queue ADD COLUMN IF NOT EXISTS status VARCHAR(30) DEFAULT 'PENDING_REVIEW';
ALTER TABLE review_queue ADD COLUMN IF NOT EXISTS queued_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
ALTER TABLE review_queue ADD COLUMN IF NOT EXISTS priority_score INTEGER DEFAULT 0;
ALTER TABLE review_queue ADD COLUMN IF NOT EXISTS assigned_at TIMESTAMPTZ;
ALTER TABLE review_queue ADD COLUMN IF NOT EXISTS organization_id BIGINT REFERENCES coalition_organizations(id);

-- ============================================================================
-- 8. REPAIR REQUESTS
-- ============================================================================
-- Referenced by: intake-save.php, case-review.php, org-admin.php.

CREATE TABLE IF NOT EXISTS repair_requests (
    id              BIGSERIAL PRIMARY KEY,
    submission_id   BIGINT REFERENCES intake_submissions(id),
    repair_need     TEXT NOT NULL,
    priority        INTEGER,
    sort_order      INTEGER
);

CREATE INDEX IF NOT EXISTS idx_repair_requests_submission ON repair_requests(submission_id);
CREATE INDEX IF NOT EXISTS idx_repair_requests_priority ON repair_requests(priority);

ALTER TABLE repair_requests ADD COLUMN IF NOT EXISTS submission_id BIGINT REFERENCES intake_submissions(id);
ALTER TABLE repair_requests ADD COLUMN IF NOT EXISTS repair_need TEXT NOT NULL;
ALTER TABLE repair_requests ADD COLUMN IF NOT EXISTS priority INTEGER;
ALTER TABLE repair_requests ADD COLUMN IF NOT EXISTS sort_order INTEGER;

-- ============================================================================
-- 9. REPAIR CATEGORIES (lookup)
-- ============================================================================

CREATE TABLE IF NOT EXISTS repair_categories (
    id              BIGSERIAL PRIMARY KEY,
    category_code   VARCHAR(50) NOT NULL UNIQUE,
    category_label  VARCHAR(255) NOT NULL
);

ALTER TABLE repair_categories ADD COLUMN IF NOT EXISTS category_code VARCHAR(50) NOT NULL UNIQUE;
ALTER TABLE repair_categories ADD COLUMN IF NOT EXISTS category_label VARCHAR(255) NOT NULL;

-- ============================================================================
-- 10. SUBMISSION_REPAIR_CATEGORIES (junction)
-- ============================================================================

CREATE TABLE IF NOT EXISTS submission_repair_categories (
    submission_id   BIGINT REFERENCES intake_submissions(id),
    category_id     BIGINT REFERENCES repair_categories(id),
    PRIMARY KEY (submission_id, category_id)
);

-- ============================================================================
-- 11. HOUSEHOLD ATTRIBUTES (lookup)
-- ============================================================================

CREATE TABLE IF NOT EXISTS household_attributes (
    id              BIGSERIAL PRIMARY KEY,
    attribute_name  VARCHAR(255) NOT NULL UNIQUE
);

-- ============================================================================
-- 12. SUBMISSION_HOUSEHOLD_ATTRIBUTES (junction)
-- ============================================================================

CREATE TABLE IF NOT EXISTS submission_household_attributes (
    submission_id   BIGINT REFERENCES intake_submissions(id),
    attribute_id    BIGINT REFERENCES household_attributes(id),
    PRIMARY KEY (submission_id, attribute_id)
);

-- ============================================================================
-- 13. CONTACT METHODS (lookup)
-- ============================================================================

CREATE TABLE IF NOT EXISTS contact_methods (
    id              BIGSERIAL PRIMARY KEY,
    method_code     VARCHAR(50) NOT NULL UNIQUE
);

-- Seed common contact methods
INSERT INTO contact_methods (method_code) VALUES
    ('phone'), ('text'), ('email'), ('other')
ON CONFLICT (method_code) DO NOTHING;

-- ============================================================================
-- 14. SUBMISSION_CONTACT_METHODS (junction)
-- ============================================================================

CREATE TABLE IF NOT EXISTS submission_contact_methods (
    submission_id   BIGINT REFERENCES intake_submissions(id),
    method_id       BIGINT REFERENCES contact_methods(id),
    PRIMARY KEY (submission_id, method_id)
);

-- ============================================================================
-- 15. INCOME RECORDS
-- ============================================================================
-- Referenced by: intake-save.php, case-review.php.

CREATE TABLE IF NOT EXISTS income_records (
    id              BIGSERIAL PRIMARY KEY,
    submission_id   BIGINT REFERENCES intake_submissions(id),
    whose_income    VARCHAR(100),
    income_source   VARCHAR(100),
    frequency       VARCHAR(50),
    amount          NUMERIC(12,2)
);

CREATE INDEX IF NOT EXISTS idx_income_submission ON income_records(submission_id);

ALTER TABLE income_records ADD COLUMN IF NOT EXISTS submission_id BIGINT REFERENCES intake_submissions(id);
ALTER TABLE income_records ADD COLUMN IF NOT EXISTS whose_income VARCHAR(100);
ALTER TABLE income_records ADD COLUMN IF NOT EXISTS income_source VARCHAR(100);
ALTER TABLE income_records ADD COLUMN IF NOT EXISTS frequency VARCHAR(50);
ALTER TABLE income_records ADD COLUMN IF NOT EXISTS amount NUMERIC(12,2);

-- ============================================================================
-- 16. ACTIVITY DETAIL (30-day rolling detail rows)
-- ============================================================================
-- master-schema defines activity_log but NOT activity_detail.
-- Referenced by: activity-log.php.

CREATE TABLE IF NOT EXISTS activity_detail (
    id              BIGSERIAL PRIMARY KEY,
    ledger_id       BIGINT REFERENCES activity_log(id),
    field_name      VARCHAR(100),
    old_value       TEXT,
    new_value       TEXT,
    action          VARCHAR(100),
    details         TEXT,
    source          VARCHAR(50),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    prev_hash       VARCHAR(64),
    entry_hash      VARCHAR(64)
);

CREATE INDEX IF NOT EXISTS idx_activity_detail_ledger ON activity_detail(ledger_id);
CREATE INDEX IF NOT EXISTS idx_activity_detail_created ON activity_detail(created_at DESC);

ALTER TABLE activity_detail ADD COLUMN IF NOT EXISTS ledger_id BIGINT REFERENCES activity_log(id);
ALTER TABLE activity_detail ADD COLUMN IF NOT EXISTS field_name VARCHAR(100);
ALTER TABLE activity_detail ADD COLUMN IF NOT EXISTS old_value TEXT;
ALTER TABLE activity_detail ADD COLUMN IF NOT EXISTS new_value TEXT;
ALTER TABLE activity_detail ADD COLUMN IF NOT EXISTS action VARCHAR(100);
ALTER TABLE activity_detail ADD COLUMN IF NOT EXISTS details TEXT;
ALTER TABLE activity_detail ADD COLUMN IF NOT EXISTS source VARCHAR(50);
ALTER TABLE activity_detail ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
ALTER TABLE activity_detail ADD COLUMN IF NOT EXISTS prev_hash VARCHAR(64);
ALTER TABLE activity_detail ADD COLUMN IF NOT EXISTS entry_hash VARCHAR(64);

-- ============================================================================
-- 17. NOTIFICATIONS
-- ============================================================================
-- Referenced by: org-admin.php, documents.php.

CREATE TABLE IF NOT EXISTS notifications (
    id                  BIGSERIAL PRIMARY KEY,
    user_id             BIGINT REFERENCES system_users(id),
    notification_type   VARCHAR(50),
    title               VARCHAR(255),
    body                TEXT,
    entity_type         VARCHAR(50),
    entity_id           BIGINT,
    is_read             BOOLEAN DEFAULT false,
    priority            VARCHAR(20) DEFAULT 'medium',
    read_at             TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = false;

ALTER TABLE notifications ADD COLUMN IF NOT EXISTS user_id BIGINT REFERENCES system_users(id);
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS notification_type VARCHAR(50);
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS title VARCHAR(255);
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS body TEXT;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS entity_type VARCHAR(50);
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS entity_id BIGINT;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS is_read BOOLEAN DEFAULT false;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS priority VARCHAR(20) DEFAULT 'medium';
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS read_at TIMESTAMPTZ;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ============================================================================
-- 18. DOCUMENT CATEGORIES (lookup) — must exist before case_documents
-- ============================================================================

CREATE TABLE IF NOT EXISTS document_categories (
    id              BIGSERIAL PRIMARY KEY,
    category_code   VARCHAR(50) NOT NULL UNIQUE,
    category_name   VARCHAR(255) NOT NULL
);

-- Seed standard document categories
INSERT INTO document_categories (category_code, category_name) VALUES
    ('APPLICATION', 'Application'),
    ('PROPERTY',    'Property'),
    ('INCOME',      'Income'),
    ('INSURANCE',   'Insurance'),
    ('FEMA',        'FEMA'),
    ('ASSESSMENT',  'Assessment'),
    ('PHOTO',       'Photo'),
    ('SOW',         'Scope of Work'),
    ('CONTRACT',    'Contract'),
    ('INVOICE',     'Invoice'),
    ('PERMIT',      'Permit'),
    ('OTHER',       'Other')
ON CONFLICT (category_code) DO NOTHING;

-- ============================================================================
-- 19. DOCUMENT STATUSES (lookup) — must exist before case_documents
-- ============================================================================

CREATE TABLE IF NOT EXISTS document_statuses (
    id              BIGSERIAL PRIMARY KEY,
    status_code     VARCHAR(50) NOT NULL UNIQUE,
    status_name     VARCHAR(255) NOT NULL
);

-- Seed standard document statuses
INSERT INTO document_statuses (status_code, status_name) VALUES
    ('PENDING',    'Pending'),
    ('VERIFIED',   'Verified'),
    ('REJECTED',   'Rejected'),
    ('EXPIRED',    'Expired')
ON CONFLICT (status_code) DO NOTHING;

-- ============================================================================
-- 20. CASE DOCUMENTS
-- ============================================================================
-- Referenced by: case-documents.php, documents.php, case-review.php.

CREATE TABLE IF NOT EXISTS case_documents (
    id                  BIGSERIAL PRIMARY KEY,
    case_id             BIGINT REFERENCES cases(id),
    category_id         BIGINT REFERENCES document_categories(id),
    status_id           BIGINT REFERENCES document_statuses(id),
    file_name           VARCHAR(500) NOT NULL,
    mime_type           VARCHAR(100),
    file_size_bytes     BIGINT,
    file_hash           VARCHAR(64),
    storage_path        TEXT,
    storage_provider    VARCHAR(50),
    version_number      INTEGER DEFAULT 1,
    metadata            JSONB DEFAULT '{}',
    notes               TEXT,
    uploaded_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    uploaded_by         BIGINT REFERENCES system_users(id),
    verified_at         TIMESTAMPTZ,
    verified_by         BIGINT REFERENCES system_users(id),
    deleted_at          TIMESTAMPTZ,
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_case_docs_case ON case_documents(case_id);
CREATE INDEX IF NOT EXISTS idx_case_docs_deleted ON case_documents(case_id) WHERE deleted_at IS NULL;

ALTER TABLE case_documents ADD COLUMN IF NOT EXISTS case_id BIGINT REFERENCES cases(id);
ALTER TABLE case_documents ADD COLUMN IF NOT EXISTS category_id BIGINT REFERENCES document_categories(id);
ALTER TABLE case_documents ADD COLUMN IF NOT EXISTS status_id BIGINT REFERENCES document_statuses(id);
ALTER TABLE case_documents ADD COLUMN IF NOT EXISTS file_name VARCHAR(500) NOT NULL;
ALTER TABLE case_documents ADD COLUMN IF NOT EXISTS mime_type VARCHAR(100);
ALTER TABLE case_documents ADD COLUMN IF NOT EXISTS file_size_bytes BIGINT;
ALTER TABLE case_documents ADD COLUMN IF NOT EXISTS file_hash VARCHAR(64);
ALTER TABLE case_documents ADD COLUMN IF NOT EXISTS storage_path TEXT;
ALTER TABLE case_documents ADD COLUMN IF NOT EXISTS storage_provider VARCHAR(50);
ALTER TABLE case_documents ADD COLUMN IF NOT EXISTS version_number INTEGER DEFAULT 1;
ALTER TABLE case_documents ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}';
ALTER TABLE case_documents ADD COLUMN IF NOT EXISTS notes TEXT;
ALTER TABLE case_documents ADD COLUMN IF NOT EXISTS uploaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
ALTER TABLE case_documents ADD COLUMN IF NOT EXISTS uploaded_by BIGINT REFERENCES system_users(id);
ALTER TABLE case_documents ADD COLUMN IF NOT EXISTS verified_at TIMESTAMPTZ;
ALTER TABLE case_documents ADD COLUMN IF NOT EXISTS verified_by BIGINT REFERENCES system_users(id);
ALTER TABLE case_documents ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;
ALTER TABLE case_documents ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ============================================================================
-- 21. DOCUMENT TEMPLATES
-- ============================================================================

CREATE TABLE IF NOT EXISTS document_templates (
    id              BIGSERIAL PRIMARY KEY,
    template_code   VARCHAR(50) NOT NULL UNIQUE,
    template_name   VARCHAR(255) NOT NULL,
    description     TEXT,
    category_id     BIGINT REFERENCES document_categories(id),
    template_data   JSONB,
    is_active       BOOLEAN DEFAULT true,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 22. DOCUMENT GENERATION JOBS
-- ============================================================================
-- Referenced by: documents.php.

CREATE TABLE IF NOT EXISTS document_generation_jobs (
    id                  BIGSERIAL PRIMARY KEY,
    case_id             BIGINT REFERENCES cases(id),
    template_id         BIGINT REFERENCES document_templates(id),
    status              VARCHAR(30) DEFAULT 'pending',
    data_source         VARCHAR(50),
    created_by          BIGINT REFERENCES system_users(id),
    output_document_id  BIGINT REFERENCES case_documents(id),
    completed_at        TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_docgen_case ON document_generation_jobs(case_id);
CREATE INDEX IF NOT EXISTS idx_docgen_status ON document_generation_jobs(status);

ALTER TABLE document_generation_jobs ADD COLUMN IF NOT EXISTS case_id BIGINT REFERENCES cases(id);
ALTER TABLE document_generation_jobs ADD COLUMN IF NOT EXISTS template_id BIGINT REFERENCES document_templates(id);
ALTER TABLE document_generation_jobs ADD COLUMN IF NOT EXISTS status VARCHAR(30) DEFAULT 'pending';
ALTER TABLE document_generation_jobs ADD COLUMN IF NOT EXISTS data_source VARCHAR(50);
ALTER TABLE document_generation_jobs ADD COLUMN IF NOT EXISTS created_by BIGINT REFERENCES system_users(id);
ALTER TABLE document_generation_jobs ADD COLUMN IF NOT EXISTS output_document_id BIGINT REFERENCES case_documents(id);
ALTER TABLE document_generation_jobs ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ;

-- ============================================================================
-- 23. DOCUMENT ACCESS LOG
-- ============================================================================

CREATE TABLE IF NOT EXISTS document_access_log (
    id              BIGSERIAL PRIMARY KEY,
    document_id     BIGINT REFERENCES case_documents(id),
    accessed_by     BIGINT REFERENCES system_users(id),
    access_type     VARCHAR(50),
    accessed_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_doc_access_doc ON document_access_log(document_id);
CREATE INDEX IF NOT EXISTS idx_doc_access_user ON document_access_log(accessed_by);

ALTER TABLE document_access_log ADD COLUMN IF NOT EXISTS document_id BIGINT REFERENCES case_documents(id);
ALTER TABLE document_access_log ADD COLUMN IF NOT EXISTS accessed_by BIGINT REFERENCES system_users(id);
ALTER TABLE document_access_log ADD COLUMN IF NOT EXISTS access_type VARCHAR(50);
ALTER TABLE document_access_log ADD COLUMN IF NOT EXISTS accessed_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ============================================================================
-- 24. CASE CLAIMS
-- ============================================================================
-- Referenced by: case-access.php, case-review.php, documents.php, org-admin.php.

CREATE TABLE IF NOT EXISTS case_claims (
    id                  BIGSERIAL PRIMARY KEY,
    case_id             BIGINT REFERENCES cases(id),
    claimed_by_org_id   BIGINT REFERENCES coalition_organizations(id),
    claimed_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_case_claims_case ON case_claims(case_id);
CREATE INDEX IF NOT EXISTS idx_case_claims_org ON case_claims(claimed_by_org_id);

ALTER TABLE case_claims ADD COLUMN IF NOT EXISTS case_id BIGINT REFERENCES cases(id);
ALTER TABLE case_claims ADD COLUMN IF NOT EXISTS claimed_by_org_id BIGINT REFERENCES coalition_organizations(id);
ALTER TABLE case_claims ADD COLUMN IF NOT EXISTS claimed_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ============================================================================
-- 25. CASE STATUS HISTORY
-- ============================================================================
-- Referenced by: case-review.php, org-admin.php.

CREATE TABLE IF NOT EXISTS case_status_history (
    id              BIGSERIAL PRIMARY KEY,
    case_id         BIGINT REFERENCES cases(id),
    from_status_id  BIGINT REFERENCES case_statuses(id),
    to_status_id    BIGINT REFERENCES case_statuses(id),
    changed_by      BIGINT REFERENCES system_users(id),
    changed_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    notes           TEXT
);

CREATE INDEX IF NOT EXISTS idx_csh_case ON case_status_history(case_id);
CREATE INDEX IF NOT EXISTS idx_csh_changed ON case_status_history(changed_at DESC);

ALTER TABLE case_status_history ADD COLUMN IF NOT EXISTS case_id BIGINT REFERENCES cases(id);
ALTER TABLE case_status_history ADD COLUMN IF NOT EXISTS from_status_id BIGINT REFERENCES case_statuses(id);
ALTER TABLE case_status_history ADD COLUMN IF NOT EXISTS to_status_id BIGINT REFERENCES case_statuses(id);
ALTER TABLE case_status_history ADD COLUMN IF NOT EXISTS changed_by BIGINT REFERENCES system_users(id);
ALTER TABLE case_status_history ADD COLUMN IF NOT EXISTS changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
ALTER TABLE case_status_history ADD COLUMN IF NOT EXISTS notes TEXT;

-- ============================================================================
-- 26. CASE WITHDRAWALS
-- ============================================================================
-- Referenced by: case-review.php, org-admin.php.

CREATE TABLE IF NOT EXISTS case_withdrawals (
    id                      BIGSERIAL PRIMARY KEY,
    case_id                 BIGINT REFERENCES cases(id),
    withdrawn_by            BIGINT REFERENCES system_users(id),
    requestor_confirmed     BOOLEAN DEFAULT false,
    confirmation_method     VARCHAR(50),
    confirmation_detail     TEXT,
    reason                  TEXT,
    withdrawn_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    withdrawn_by_name       VARCHAR(255)
);

CREATE INDEX IF NOT EXISTS idx_withdrawals_case ON case_withdrawals(case_id);

ALTER TABLE case_withdrawals ADD COLUMN IF NOT EXISTS case_id BIGINT REFERENCES cases(id);
ALTER TABLE case_withdrawals ADD COLUMN IF NOT EXISTS withdrawn_by BIGINT REFERENCES system_users(id);
ALTER TABLE case_withdrawals ADD COLUMN IF NOT EXISTS requestor_confirmed BOOLEAN DEFAULT false;
ALTER TABLE case_withdrawals ADD COLUMN IF NOT EXISTS confirmation_method VARCHAR(50);
ALTER TABLE case_withdrawals ADD COLUMN IF NOT EXISTS confirmation_detail TEXT;
ALTER TABLE case_withdrawals ADD COLUMN IF NOT EXISTS reason TEXT;
ALTER TABLE case_withdrawals ADD COLUMN IF NOT EXISTS withdrawn_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
ALTER TABLE case_withdrawals ADD COLUMN IF NOT EXISTS withdrawn_by_name VARCHAR(255);

-- ============================================================================
-- 27. CASE REPAIR CLAIMS
-- ============================================================================
-- Referenced by: case-review.php, org-admin.php.

CREATE TABLE IF NOT EXISTS case_repair_claims (
    id                  BIGSERIAL PRIMARY KEY,
    case_id             BIGINT REFERENCES cases(id),
    repair_request_id   BIGINT REFERENCES repair_requests(id),
    organization_id     BIGINT REFERENCES coalition_organizations(id),
    claimed_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    claimed_by          BIGINT REFERENCES system_users(id),
    released_at         TIMESTAMPTZ,
    released_by         BIGINT REFERENCES system_users(id),
    notes               TEXT
);

CREATE INDEX IF NOT EXISTS idx_crc_case ON case_repair_claims(case_id);
CREATE INDEX IF NOT EXISTS idx_crc_org ON case_repair_claims(organization_id);
CREATE INDEX IF NOT EXISTS idx_crc_repair ON case_repair_claims(repair_request_id);

ALTER TABLE case_repair_claims ADD COLUMN IF NOT EXISTS case_id BIGINT REFERENCES cases(id);
ALTER TABLE case_repair_claims ADD COLUMN IF NOT EXISTS repair_request_id BIGINT REFERENCES repair_requests(id);
ALTER TABLE case_repair_claims ADD COLUMN IF NOT EXISTS organization_id BIGINT REFERENCES coalition_organizations(id);
ALTER TABLE case_repair_claims ADD COLUMN IF NOT EXISTS claimed_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
ALTER TABLE case_repair_claims ADD COLUMN IF NOT EXISTS claimed_by BIGINT REFERENCES system_users(id);
ALTER TABLE case_repair_claims ADD COLUMN IF NOT EXISTS released_at TIMESTAMPTZ;
ALTER TABLE case_repair_claims ADD COLUMN IF NOT EXISTS released_by BIGINT REFERENCES system_users(id);
ALTER TABLE case_repair_claims ADD COLUMN IF NOT EXISTS notes TEXT;

-- ============================================================================
-- 28. WORK ORDERS
-- ============================================================================
-- Referenced by: applications.php, case-review.php, project-manager/*.

CREATE TABLE IF NOT EXISTS work_orders (
    id                      BIGSERIAL PRIMARY KEY,
    case_id                 BIGINT REFERENCES cases(id),
    work_order_number       VARCHAR(50) UNIQUE,
    status                  VARCHAR(30) DEFAULT 'pending',
    estimated_cost          NUMERIC(12,2),
    actual_cost             NUMERIC(12,2),
    approved_budget         NUMERIC(12,2),
    current_cost            NUMERIC(12,2),
    scheduled_start_date    DATE,
    scheduled_end_date      DATE,
    actual_end_date         DATE,
    progress_percentage     NUMERIC(5,2),
    project_manager_id      BIGINT REFERENCES system_users(id),
    crew_lead_id            BIGINT REFERENCES system_users(id),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_wo_case ON work_orders(case_id);
CREATE INDEX IF NOT EXISTS idx_wo_status ON work_orders(status);

ALTER TABLE work_orders ADD COLUMN IF NOT EXISTS case_id BIGINT REFERENCES cases(id);
ALTER TABLE work_orders ADD COLUMN IF NOT EXISTS work_order_number VARCHAR(50) UNIQUE;
ALTER TABLE work_orders ADD COLUMN IF NOT EXISTS status VARCHAR(30) DEFAULT 'pending';
ALTER TABLE work_orders ADD COLUMN IF NOT EXISTS estimated_cost NUMERIC(12,2);
ALTER TABLE work_orders ADD COLUMN IF NOT EXISTS actual_cost NUMERIC(12,2);
ALTER TABLE work_orders ADD COLUMN IF NOT EXISTS approved_budget NUMERIC(12,2);
ALTER TABLE work_orders ADD COLUMN IF NOT EXISTS current_cost NUMERIC(12,2);
ALTER TABLE work_orders ADD COLUMN IF NOT EXISTS scheduled_start_date DATE;
ALTER TABLE work_orders ADD COLUMN IF NOT EXISTS scheduled_end_date DATE;
ALTER TABLE work_orders ADD COLUMN IF NOT EXISTS actual_end_date DATE;
ALTER TABLE work_orders ADD COLUMN IF NOT EXISTS progress_percentage NUMERIC(5,2);
ALTER TABLE work_orders ADD COLUMN IF NOT EXISTS project_manager_id BIGINT REFERENCES system_users(id);
ALTER TABLE work_orders ADD COLUMN IF NOT EXISTS crew_lead_id BIGINT REFERENCES system_users(id);
ALTER TABLE work_orders ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
ALTER TABLE work_orders ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ============================================================================
-- 29. WORK TASKS
-- ============================================================================
-- Referenced by: applications.php, case-review.php, project-manager/*.

CREATE TABLE IF NOT EXISTS work_tasks (
    id              BIGSERIAL PRIMARY KEY,
    work_order_id   BIGINT REFERENCES work_orders(id),
    description     TEXT,
    status          VARCHAR(30) DEFAULT 'pending',
    due_date        DATE,
    completed_at    TIMESTAMPTZ,
    assigned_to_id  BIGINT REFERENCES system_users(id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_wt_wo ON work_tasks(work_order_id);
CREATE INDEX IF NOT EXISTS idx_wt_status ON work_tasks(status);

ALTER TABLE work_tasks ADD COLUMN IF NOT EXISTS work_order_id BIGINT REFERENCES work_orders(id);
ALTER TABLE work_tasks ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE work_tasks ADD COLUMN IF NOT EXISTS status VARCHAR(30) DEFAULT 'pending';
ALTER TABLE work_tasks ADD COLUMN IF NOT EXISTS due_date DATE;
ALTER TABLE work_tasks ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ;
ALTER TABLE work_tasks ADD COLUMN IF NOT EXISTS assigned_to_id BIGINT REFERENCES system_users(id);
ALTER TABLE work_tasks ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ============================================================================
-- 30. WORK ORDER TASKS (junction: work_orders ↔ repair_categories)
-- ============================================================================

CREATE TABLE IF NOT EXISTS work_order_tasks (
    work_order_id       BIGINT REFERENCES work_orders(id),
    repair_category_id  BIGINT REFERENCES repair_categories(id),
    PRIMARY KEY (work_order_id, repair_category_id)
);

-- ============================================================================
-- 31. APPLICATION ASSIGNMENTS
-- ============================================================================
-- Referenced by: org-admin.php, super-admin.php, case-review.php.

CREATE TABLE IF NOT EXISTS application_assignments (
    id              BIGSERIAL PRIMARY KEY,
    submission_id   BIGINT REFERENCES intake_submissions(id),
    organization_id BIGINT REFERENCES coalition_organizations(id),
    status          VARCHAR(30) DEFAULT 'pending',
    claimed_at      TIMESTAMPTZ,
    claimed_by      BIGINT REFERENCES system_users(id),
    rejected_by     BIGINT REFERENCES system_users(id),
    notes           TEXT
);

CREATE INDEX IF NOT EXISTS idx_aa_submission ON application_assignments(submission_id);
CREATE INDEX IF NOT EXISTS idx_aa_org ON application_assignments(organization_id);
CREATE INDEX IF NOT EXISTS idx_aa_status ON application_assignments(status);

ALTER TABLE application_assignments ADD COLUMN IF NOT EXISTS submission_id BIGINT REFERENCES intake_submissions(id);
ALTER TABLE application_assignments ADD COLUMN IF NOT EXISTS organization_id BIGINT REFERENCES coalition_organizations(id);
ALTER TABLE application_assignments ADD COLUMN IF NOT EXISTS status VARCHAR(30) DEFAULT 'pending';
ALTER TABLE application_assignments ADD COLUMN IF NOT EXISTS claimed_at TIMESTAMPTZ;
ALTER TABLE application_assignments ADD COLUMN IF NOT EXISTS claimed_by BIGINT REFERENCES system_users(id);
ALTER TABLE application_assignments ADD COLUMN IF NOT EXISTS rejected_by BIGINT REFERENCES system_users(id);
ALTER TABLE application_assignments ADD COLUMN IF NOT EXISTS notes TEXT;

-- ============================================================================
-- 32. ASSIGNMENT LOG
-- ============================================================================
-- Referenced by: org-admin.php, super-admin.php, case-review.php.

CREATE TABLE IF NOT EXISTS assignment_log (
    id              BIGSERIAL PRIMARY KEY,
    assignment_id   BIGINT REFERENCES application_assignments(id),
    action          VARCHAR(50),
    new_value       TEXT,
    performed_by    BIGINT REFERENCES system_users(id),
    performed_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    notes           TEXT
);

CREATE INDEX IF NOT EXISTS idx_al_assignment ON assignment_log(assignment_id);
CREATE INDEX IF NOT EXISTS idx_al_performed ON assignment_log(performed_at DESC);

ALTER TABLE assignment_log ADD COLUMN IF NOT EXISTS assignment_id BIGINT REFERENCES application_assignments(id);
ALTER TABLE assignment_log ADD COLUMN IF NOT EXISTS action VARCHAR(50);
ALTER TABLE assignment_log ADD COLUMN IF NOT EXISTS new_value TEXT;
ALTER TABLE assignment_log ADD COLUMN IF NOT EXISTS performed_by BIGINT REFERENCES system_users(id);
ALTER TABLE assignment_log ADD COLUMN IF NOT EXISTS performed_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
ALTER TABLE assignment_log ADD COLUMN IF NOT EXISTS notes TEXT;

-- ============================================================================
-- 33. PROGRESS EVENTS
-- ============================================================================
-- Referenced by: case-review.php (via log_progress_event SQL function).

CREATE TABLE IF NOT EXISTS progress_events (
    id              BIGSERIAL PRIMARY KEY,
    case_id         BIGINT REFERENCES cases(id),
    event_type      VARCHAR(50),
    description     TEXT,
    performed_by    BIGINT REFERENCES system_users(id),
    is_progress     BOOLEAN DEFAULT true,
    source          VARCHAR(50) DEFAULT 'user',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pe_case ON progress_events(case_id);
CREATE INDEX IF NOT EXISTS idx_pe_created ON progress_events(created_at DESC);

ALTER TABLE progress_events ADD COLUMN IF NOT EXISTS case_id BIGINT REFERENCES cases(id);
ALTER TABLE progress_events ADD COLUMN IF NOT EXISTS event_type VARCHAR(50);
ALTER TABLE progress_events ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE progress_events ADD COLUMN IF NOT EXISTS performed_by BIGINT REFERENCES system_users(id);
ALTER TABLE progress_events ADD COLUMN IF NOT EXISTS is_progress BOOLEAN DEFAULT true;
ALTER TABLE progress_events ADD COLUMN IF NOT EXISTS source VARCHAR(50) DEFAULT 'user';
ALTER TABLE progress_events ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ============================================================================
-- 34. PROJECT ESCALATIONS
-- ============================================================================
-- Referenced by: project-manager/dashboard.php, project-manager/escalations.php.

CREATE TABLE IF NOT EXISTS project_escalations (
    id              BIGSERIAL PRIMARY KEY,
    work_order_id   BIGINT REFERENCES work_orders(id),
    event_type      VARCHAR(50),
    severity        VARCHAR(20),
    description     TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at     TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_pe_wo ON project_escalations(work_order_id);
CREATE INDEX IF NOT EXISTS idx_pe_severity ON project_escalations(severity);
CREATE INDEX IF NOT EXISTS idx_pe_created ON project_escalations(created_at DESC);

ALTER TABLE project_escalations ADD COLUMN IF NOT EXISTS work_order_id BIGINT REFERENCES work_orders(id);
ALTER TABLE project_escalations ADD COLUMN IF NOT EXISTS event_type VARCHAR(50);
ALTER TABLE project_escalations ADD COLUMN IF NOT EXISTS severity VARCHAR(20);
ALTER TABLE project_escalations ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE project_escalations ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
ALTER TABLE project_escalations ADD COLUMN IF NOT EXISTS resolved_at TIMESTAMPTZ;

-- ============================================================================
-- 35. TASK RABBIT QUEUE
-- ============================================================================
-- Referenced by: tasks/quick-add.php.

CREATE TABLE IF NOT EXISTS task_rabbit_queue (
    id                  BIGSERIAL PRIMARY KEY,
    task_type           VARCHAR(50),
    description         TEXT,
    created_by_user_id  BIGINT REFERENCES system_users(id),
    status              VARCHAR(30) DEFAULT 'pending',
    priority            VARCHAR(20) DEFAULT 'medium',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_trq_status ON task_rabbit_queue(status);
CREATE INDEX IF NOT EXISTS idx_trq_created ON task_rabbit_queue(created_at DESC);

ALTER TABLE task_rabbit_queue ADD COLUMN IF NOT EXISTS task_type VARCHAR(50);
ALTER TABLE task_rabbit_queue ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE task_rabbit_queue ADD COLUMN IF NOT EXISTS created_by_user_id BIGINT REFERENCES system_users(id);
ALTER TABLE task_rabbit_queue ADD COLUMN IF NOT EXISTS status VARCHAR(30) DEFAULT 'pending';
ALTER TABLE task_rabbit_queue ADD COLUMN IF NOT EXISTS priority VARCHAR(20) DEFAULT 'medium';
ALTER TABLE task_rabbit_queue ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ============================================================================
-- 36. ASSESSMENTS — ADD MISSING COLUMNS
-- ============================================================================
-- master-schema already defines assessments, but code also references
-- submission_id, assessor_id, scheduled_at, status, completed_at,
-- estimated_hours which are NOT in the master schema.

ALTER TABLE assessments ADD COLUMN IF NOT EXISTS submission_id BIGINT REFERENCES intake_submissions(id);
ALTER TABLE assessments ADD COLUMN IF NOT EXISTS assessor_id BIGINT REFERENCES system_users(id);
ALTER TABLE assessments ADD COLUMN IF NOT EXISTS scheduled_at TIMESTAMPTZ;
ALTER TABLE assessments ADD COLUMN IF NOT EXISTS status VARCHAR(30) DEFAULT 'pending';
ALTER TABLE assessments ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ;
ALTER TABLE assessments ADD COLUMN IF NOT EXISTS estimated_hours NUMERIC(5,2);

CREATE INDEX IF NOT EXISTS idx_assessments_submission ON assessments(submission_id);
CREATE INDEX IF NOT EXISTS idx_assessments_assessor ON assessments(assessor_id);
CREATE INDEX IF NOT EXISTS idx_assessments_status ON assessments(status);

-- ============================================================================
-- 37. SCOPE OF WORK LINE ITEMS — ADD MISSING COLUMNS
-- ============================================================================
-- master-schema already defines this table. Add columns the code references
-- that may not exist.

ALTER TABLE scope_of_work_line_items ADD COLUMN IF NOT EXISTS task_name TEXT;
ALTER TABLE scope_of_work_line_items ADD COLUMN IF NOT EXISTS location TEXT;
ALTER TABLE scope_of_work_line_items ADD COLUMN IF NOT EXISTS details TEXT;
ALTER TABLE scope_of_work_line_items ADD COLUMN IF NOT EXISTS estimated_cost NUMERIC(12,2);
ALTER TABLE scope_of_work_line_items ADD COLUMN IF NOT EXISTS quoted_cost NUMERIC(12,2);
ALTER TABLE scope_of_work_line_items ADD COLUMN IF NOT EXISTS actual_cost NUMERIC(12,2);
ALTER TABLE scope_of_work_line_items ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'pending';
ALTER TABLE scope_of_work_line_items ADD COLUMN IF NOT EXISTS repair_need_id BIGINT;
ALTER TABLE scope_of_work_line_items ADD COLUMN IF NOT EXISTS case_id BIGINT;
ALTER TABLE scope_of_work_line_items ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
ALTER TABLE scope_of_work_line_items ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ============================================================================
-- 38. MATERIALS INVENTORY — ADD MISSING COLUMNS
-- ============================================================================

ALTER TABLE materials_inventory ADD COLUMN IF NOT EXISTS sow_line_item_id BIGINT REFERENCES scope_of_work_line_items(id);
ALTER TABLE materials_inventory ADD COLUMN IF NOT EXISTS material_name TEXT;
ALTER TABLE materials_inventory ADD COLUMN IF NOT EXISTS quantity NUMERIC(10,2);
ALTER TABLE materials_inventory ADD COLUMN IF NOT EXISTS unit TEXT;
ALTER TABLE materials_inventory ADD COLUMN IF NOT EXISTS unit_cost NUMERIC(10,2);

-- ============================================================================
-- 39. ASSESSMENT DOCUMENTS — ADD MISSING COLUMNS
-- ============================================================================

ALTER TABLE assessment_documents ADD COLUMN IF NOT EXISTS document_type VARCHAR(40);
ALTER TABLE assessment_documents ADD COLUMN IF NOT EXISTS file_path TEXT;
ALTER TABLE assessment_documents ADD COLUMN IF NOT EXISTS file_name TEXT;
ALTER TABLE assessment_documents ADD COLUMN IF NOT EXISTS file_size BIGINT;
ALTER TABLE assessment_documents ADD COLUMN IF NOT EXISTS mime_type VARCHAR(100);
ALTER TABLE assessment_documents ADD COLUMN IF NOT EXISTS uploaded_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE assessment_documents ADD COLUMN IF NOT EXISTS uploaded_by BIGINT REFERENCES system_users(id);
ALTER TABLE assessment_documents ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}';

-- ============================================================================
-- 40. SITE PHOTOS — ADD MISSING COLUMNS
-- ============================================================================

ALTER TABLE site_photos ADD COLUMN IF NOT EXISTS assessment_id BIGINT REFERENCES assessments(id);
ALTER TABLE site_photos ADD COLUMN IF NOT EXISTS repair_need_id BIGINT;
ALTER TABLE site_photos ADD COLUMN IF NOT EXISTS file_path TEXT NOT NULL;
ALTER TABLE site_photos ADD COLUMN IF NOT EXISTS file_name TEXT NOT NULL;
ALTER TABLE site_photos ADD COLUMN IF NOT EXISTS title TEXT;
ALTER TABLE site_photos ADD COLUMN IF NOT EXISTS date_taken TIMESTAMPTZ;
ALTER TABLE site_photos ADD COLUMN IF NOT EXISTS taken_by TEXT;
ALTER TABLE site_photos ADD COLUMN IF NOT EXISTS photo_type VARCHAR(20) DEFAULT 'before';
ALTER TABLE site_photos ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ============================================================================
-- 41. ASSESSMENT PHOTOS (alias for site_photos used by assessor/previous.php)
-- ============================================================================
-- The code references assessment_photos as a table name — this may be an
-- alias or legacy name for site_photos. Create a view if site_photos exists.
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_class WHERE relname = 'site_photos')
       AND NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'assessment_photos') THEN
        CREATE VIEW assessment_photos AS
        SELECT id, assessment_id, file_path, file_name, title, date_taken, photo_type
        FROM site_photos;
    END IF;
END
$$;

-- ============================================================================
-- 42. PAYMENTS
-- ============================================================================
-- Referenced by: bursar/dashboard.php.

CREATE TABLE IF NOT EXISTS payments (
    id              BIGSERIAL PRIMARY KEY,
    case_id         BIGINT REFERENCES cases(id),
    amount          NUMERIC(12,2) NOT NULL,
    payment_type    VARCHAR(50),
    status          VARCHAR(30) DEFAULT 'pending',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_payments_case ON payments(case_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);

ALTER TABLE payments ADD COLUMN IF NOT EXISTS case_id BIGINT REFERENCES cases(id);
ALTER TABLE payments ADD COLUMN IF NOT EXISTS amount NUMERIC(12,2) NOT NULL;
ALTER TABLE payments ADD COLUMN IF NOT EXISTS payment_type VARCHAR(50);
ALTER TABLE payments ADD COLUMN IF NOT EXISTS status VARCHAR(30) DEFAULT 'pending';
ALTER TABLE payments ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ============================================================================
-- 43. CREW JOB CARDS
-- ============================================================================
-- Referenced by: crew-lead/*, crew-member/*, volunteer/*.

CREATE TABLE IF NOT EXISTS crew_job_cards (
    id                  BIGSERIAL PRIMARY KEY,
    job_name            VARCHAR(255) NOT NULL,
    site_address        TEXT,
    case_reference      VARCHAR(50),
    status              VARCHAR(30) DEFAULT 'pending',
    progress_percentage NUMERIC(5,2),
    estimated_hours     NUMERIC(5,2),
    scheduled_date      DATE,
    scheduled_start_time TIME,
    crew_lead_id        BIGINT REFERENCES system_users(id),
    is_current_job      BOOLEAN DEFAULT false,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_cjc_crew_lead ON crew_job_cards(crew_lead_id);
CREATE INDEX IF NOT EXISTS idx_cjc_status ON crew_job_cards(status);
CREATE INDEX IF NOT EXISTS idx_cjc_scheduled ON crew_job_cards(scheduled_date);

ALTER TABLE crew_job_cards ADD COLUMN IF NOT EXISTS job_name VARCHAR(255) NOT NULL;
ALTER TABLE crew_job_cards ADD COLUMN IF NOT EXISTS site_address TEXT;
ALTER TABLE crew_job_cards ADD COLUMN IF NOT EXISTS case_reference VARCHAR(50);
ALTER TABLE crew_job_cards ADD COLUMN IF NOT EXISTS status VARCHAR(30) DEFAULT 'pending';
ALTER TABLE crew_job_cards ADD COLUMN IF NOT EXISTS progress_percentage NUMERIC(5,2);
ALTER TABLE crew_job_cards ADD COLUMN IF NOT EXISTS estimated_hours NUMERIC(5,2);
ALTER TABLE crew_job_cards ADD COLUMN IF NOT EXISTS scheduled_date DATE;
ALTER TABLE crew_job_cards ADD COLUMN IF NOT EXISTS scheduled_start_time TIME;
ALTER TABLE crew_job_cards ADD COLUMN IF NOT EXISTS crew_lead_id BIGINT REFERENCES system_users(id);
ALTER TABLE crew_job_cards ADD COLUMN IF NOT EXISTS is_current_job BOOLEAN DEFAULT false;
ALTER TABLE crew_job_cards ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ============================================================================
-- 44. CREW JOB TASKS
-- ============================================================================
-- Referenced by: crew-lead/current-job.php.

CREATE TABLE IF NOT EXISTS crew_job_tasks (
    id              BIGSERIAL PRIMARY KEY,
    job_card_id     BIGINT REFERENCES crew_job_cards(id),
    task_name       TEXT,
    status          VARCHAR(30) DEFAULT 'pending',
    estimated_hours NUMERIC(5,2),
    actual_hours    NUMERIC(5,2),
    sequence_order  INTEGER,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_cjt_job ON crew_job_tasks(job_card_id);
CREATE INDEX IF NOT EXISTS idx_cjt_status ON crew_job_tasks(status);

ALTER TABLE crew_job_tasks ADD COLUMN IF NOT EXISTS job_card_id BIGINT REFERENCES crew_job_cards(id);
ALTER TABLE crew_job_tasks ADD COLUMN IF NOT EXISTS task_name TEXT;
ALTER TABLE crew_job_tasks ADD COLUMN IF NOT EXISTS status VARCHAR(30) DEFAULT 'pending';
ALTER TABLE crew_job_tasks ADD COLUMN IF NOT EXISTS estimated_hours NUMERIC(5,2);
ALTER TABLE crew_job_tasks ADD COLUMN IF NOT EXISTS actual_hours NUMERIC(5,2);
ALTER TABLE crew_job_tasks ADD COLUMN IF NOT EXISTS sequence_order INTEGER;
ALTER TABLE crew_job_tasks ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ============================================================================
-- 45. CREW ASSIGNMENTS
-- ============================================================================
-- Referenced by: crew-member/dashboard.php.

CREATE TABLE IF NOT EXISTS crew_assignments (
    id              BIGSERIAL PRIMARY KEY,
    job_card_id     BIGINT REFERENCES crew_job_cards(id),
    crew_member_id  BIGINT REFERENCES system_users(id),
    assigned_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ca_job ON crew_assignments(job_card_id);
CREATE INDEX IF NOT EXISTS idx_ca_member ON crew_assignments(crew_member_id);

ALTER TABLE crew_assignments ADD COLUMN IF NOT EXISTS job_card_id BIGINT REFERENCES crew_job_cards(id);
ALTER TABLE crew_assignments ADD COLUMN IF NOT EXISTS crew_member_id BIGINT REFERENCES system_users(id);
ALTER TABLE crew_assignments ADD COLUMN IF NOT EXISTS assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ============================================================================
-- 46. VOLUNTEER SLOTS
-- ============================================================================
-- Referenced by: volunteer/dashboard.php.

CREATE TABLE IF NOT EXISTS volunteer_slots (
    id              BIGSERIAL PRIMARY KEY,
    scheduled_date  DATE NOT NULL,
    scheduled_time  TIME,
    required_level  VARCHAR(50),
    job_card_id     BIGINT REFERENCES crew_job_cards(id),
    status          VARCHAR(30) DEFAULT 'open',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vs_date ON volunteer_slots(scheduled_date);
CREATE INDEX IF NOT EXISTS idx_vs_job ON volunteer_slots(job_card_id);
CREATE INDEX IF NOT EXISTS idx_vs_status ON volunteer_slots(status);

ALTER TABLE volunteer_slots ADD COLUMN IF NOT EXISTS scheduled_date DATE NOT NULL;
ALTER TABLE volunteer_slots ADD COLUMN IF NOT EXISTS scheduled_time TIME;
ALTER TABLE volunteer_slots ADD COLUMN IF NOT EXISTS required_level VARCHAR(50);
ALTER TABLE volunteer_slots ADD COLUMN IF NOT EXISTS job_card_id BIGINT REFERENCES crew_job_cards(id);
ALTER TABLE volunteer_slots ADD COLUMN IF NOT EXISTS status VARCHAR(30) DEFAULT 'open';
ALTER TABLE volunteer_slots ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ============================================================================
-- 47. VOLUNTEER SLOT ASSIGNMENTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS volunteer_slot_assignments (
    id              BIGSERIAL PRIMARY KEY,
    slot_id         BIGINT REFERENCES volunteer_slots(id),
    volunteer_id    BIGINT REFERENCES system_users(id),
    assigned_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(slot_id, volunteer_id)
);

CREATE INDEX IF NOT EXISTS idx_vsa_slot ON volunteer_slot_assignments(slot_id);
CREATE INDEX IF NOT EXISTS idx_vsa_volunteer ON volunteer_slot_assignments(volunteer_id);

ALTER TABLE volunteer_slot_assignments ADD COLUMN IF NOT EXISTS slot_id BIGINT REFERENCES volunteer_slots(id);
ALTER TABLE volunteer_slot_assignments ADD COLUMN IF NOT EXISTS volunteer_id BIGINT REFERENCES system_users(id);
ALTER TABLE volunteer_slot_assignments ADD COLUMN IF NOT EXISTS assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ============================================================================
-- 48. SUBCONTRACTOR QUOTE REQUESTS
-- ============================================================================
-- Referenced by: subcontractor/dashboard.php.

CREATE TABLE IF NOT EXISTS subcontractor_quote_requests (
    id              BIGSERIAL PRIMARY KEY,
    subcontractor_id BIGINT REFERENCES system_users(id),
    case_id         BIGINT REFERENCES cases(id),
    requested_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    due_date        DATE,
    status          VARCHAR(30) DEFAULT 'pending'
);

CREATE INDEX IF NOT EXISTS idx_sqr_sub ON subcontractor_quote_requests(subcontractor_id);
CREATE INDEX IF NOT EXISTS idx_sqr_case ON subcontractor_quote_requests(case_id);
CREATE INDEX IF NOT EXISTS idx_sqr_status ON subcontractor_quote_requests(status);

ALTER TABLE subcontractor_quote_requests ADD COLUMN IF NOT EXISTS subcontractor_id BIGINT REFERENCES system_users(id);
ALTER TABLE subcontractor_quote_requests ADD COLUMN IF NOT EXISTS case_id BIGINT REFERENCES cases(id);
ALTER TABLE subcontractor_quote_requests ADD COLUMN IF NOT EXISTS requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
ALTER TABLE subcontractor_quote_requests ADD COLUMN IF NOT EXISTS due_date DATE;
ALTER TABLE subcontractor_quote_requests ADD COLUMN IF NOT EXISTS status VARCHAR(30) DEFAULT 'pending';

-- ============================================================================
-- 49. SUBCONTRACTOR ASSIGNMENTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS subcontractor_assignments (
    id              BIGSERIAL PRIMARY KEY,
    subcontractor_id BIGINT REFERENCES system_users(id),
    status          VARCHAR(30) DEFAULT 'active',
    assigned_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sa_sub ON subcontractor_assignments(subcontractor_id);
CREATE INDEX IF NOT EXISTS idx_sa_status ON subcontractor_assignments(status);

ALTER TABLE subcontractor_assignments ADD COLUMN IF NOT EXISTS subcontractor_id BIGINT REFERENCES system_users(id);
ALTER TABLE subcontractor_assignments ADD COLUMN IF NOT EXISTS status VARCHAR(30) DEFAULT 'active';
ALTER TABLE subcontractor_assignments ADD COLUMN IF NOT EXISTS assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ============================================================================
-- 50. ORGANIZATION ELIGIBILITY RULES
-- ============================================================================
-- Referenced by: super-admin.php, organization-export.php.

CREATE TABLE IF NOT EXISTS organization_eligibility_rules (
    id              BIGSERIAL PRIMARY KEY,
    organization_id BIGINT REFERENCES coalition_organizations(id),
    criteria_type_id BIGINT REFERENCES criteria_types(id),
    rule_operator   VARCHAR(10) DEFAULT '=',
    rule_value      TEXT,
    priority        INTEGER DEFAULT 0,
    is_active       BOOLEAN DEFAULT true
);

CREATE INDEX IF NOT EXISTS idx_oer_org ON organization_eligibility_rules(organization_id);
CREATE INDEX IF NOT EXISTS idx_oer_active ON organization_eligibility_rules(is_active) WHERE is_active = true;

ALTER TABLE organization_eligibility_rules ADD COLUMN IF NOT EXISTS organization_id BIGINT REFERENCES coalition_organizations(id);
ALTER TABLE organization_eligibility_rules ADD COLUMN IF NOT EXISTS criteria_type_id BIGINT REFERENCES criteria_types(id);
ALTER TABLE organization_eligibility_rules ADD COLUMN IF NOT EXISTS rule_operator VARCHAR(10) DEFAULT '=';
ALTER TABLE organization_eligibility_rules ADD COLUMN IF NOT EXISTS rule_value TEXT;
ALTER TABLE organization_eligibility_rules ADD COLUMN IF NOT EXISTS priority INTEGER DEFAULT 0;
ALTER TABLE organization_eligibility_rules ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

-- ============================================================================
-- 51. CRITERIA TYPES (lookup)
-- ============================================================================

CREATE TABLE IF NOT EXISTS criteria_types (
    id              BIGSERIAL PRIMARY KEY,
    type_code       VARCHAR(50) NOT NULL UNIQUE,
    type_name       VARCHAR(255),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 52. ELIGIBILITY RESULTS
-- ============================================================================
-- Referenced by: case-review.php, organization-export.php, super-admin.php.

CREATE TABLE IF NOT EXISTS eligibility_results (
    id              BIGSERIAL PRIMARY KEY,
    submission_id   BIGINT REFERENCES intake_submissions(id),
    organization_id BIGINT REFERENCES coalition_organizations(id),
    match_score     NUMERIC(5,2),
    is_eligible     BOOLEAN DEFAULT true,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_er_submission ON eligibility_results(submission_id);
CREATE INDEX IF NOT EXISTS idx_er_org ON eligibility_results(organization_id);
CREATE INDEX IF NOT EXISTS idx_er_eligible ON eligibility_results(is_eligible);

ALTER TABLE eligibility_results ADD COLUMN IF NOT EXISTS submission_id BIGINT REFERENCES intake_submissions(id);
ALTER TABLE eligibility_results ADD COLUMN IF NOT EXISTS organization_id BIGINT REFERENCES coalition_organizations(id);
ALTER TABLE eligibility_results ADD COLUMN IF NOT EXISTS match_score NUMERIC(5,2);
ALTER TABLE eligibility_results ADD COLUMN IF NOT EXISTS is_eligible BOOLEAN DEFAULT true;
ALTER TABLE eligibility_results ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ============================================================================
-- 53. ORGANIZATION METRICS
-- ============================================================================
-- Referenced by: organization-export.php.

CREATE TABLE IF NOT EXISTS organization_metrics (
    id                      BIGSERIAL PRIMARY KEY,
    organization_id         BIGINT REFERENCES coalition_organizations(id) UNIQUE,
    total_applications      INTEGER DEFAULT 0,
    active_applications     INTEGER DEFAULT 0,
    completed_applications  INTEGER DEFAULT 0,
    total_disbursed         NUMERIC(12,2) DEFAULT 0,
    last_updated            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_om_org ON organization_metrics(organization_id);

ALTER TABLE organization_metrics ADD COLUMN IF NOT EXISTS organization_id BIGINT REFERENCES coalition_organizations(id) UNIQUE;
ALTER TABLE organization_metrics ADD COLUMN IF NOT EXISTS total_applications INTEGER DEFAULT 0;
ALTER TABLE organization_metrics ADD COLUMN IF NOT EXISTS active_applications INTEGER DEFAULT 0;
ALTER TABLE organization_metrics ADD COLUMN IF NOT EXISTS completed_applications INTEGER DEFAULT 0;
ALTER TABLE organization_metrics ADD COLUMN IF NOT EXISTS total_disbursed NUMERIC(12,2) DEFAULT 0;
ALTER TABLE organization_metrics ADD COLUMN IF NOT EXISTS last_updated TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ============================================================================
-- 54. ORGANIZATION USERS
-- ============================================================================
-- Referenced by: super-admin.php, organization-export.php, case-review.php.

CREATE TABLE IF NOT EXISTS organization_users (
    id              BIGSERIAL PRIMARY KEY,
    organization_id BIGINT REFERENCES coalition_organizations(id),
    full_name       VARCHAR(255),
    email           VARCHAR(255),
    system_user_id  BIGINT REFERENCES system_users(id),
    is_active       BOOLEAN DEFAULT true,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ou_org ON organization_users(organization_id);
CREATE INDEX IF NOT EXISTS idx_ou_active ON organization_users(is_active) WHERE is_active = true;

ALTER TABLE organization_users ADD COLUMN IF NOT EXISTS organization_id BIGINT REFERENCES coalition_organizations(id);
ALTER TABLE organization_users ADD COLUMN IF NOT EXISTS full_name VARCHAR(255);
ALTER TABLE organization_users ADD COLUMN IF NOT EXISTS email VARCHAR(255);
ALTER TABLE organization_users ADD COLUMN IF NOT EXISTS system_user_id BIGINT REFERENCES system_users(id);
ALTER TABLE organization_users ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
ALTER TABLE organization_users ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ============================================================================
-- 55. FUNDING SOURCES
-- ============================================================================
-- Referenced by: super-admin.php, organization-export.php.

CREATE TABLE IF NOT EXISTS funding_sources (
    id              BIGSERIAL PRIMARY KEY,
    organization_id BIGINT REFERENCES coalition_organizations(id),
    source_name     VARCHAR(255) NOT NULL,
    description     TEXT,
    total_allocated NUMERIC(12,2) DEFAULT 0,
    total_spent     NUMERIC(12,2) DEFAULT 0,
    is_active       BOOLEAN DEFAULT true,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_fs_org ON funding_sources(organization_id);
CREATE INDEX IF NOT EXISTS idx_fs_active ON funding_sources(is_active) WHERE is_active = true;

ALTER TABLE funding_sources ADD COLUMN IF NOT EXISTS organization_id BIGINT REFERENCES coalition_organizations(id);
ALTER TABLE funding_sources ADD COLUMN IF NOT EXISTS source_name VARCHAR(255) NOT NULL;
ALTER TABLE funding_sources ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE funding_sources ADD COLUMN IF NOT EXISTS total_allocated NUMERIC(12,2) DEFAULT 0;
ALTER TABLE funding_sources ADD COLUMN IF NOT EXISTS total_spent NUMERIC(12,2) DEFAULT 0;
ALTER TABLE funding_sources ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
ALTER TABLE funding_sources ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ============================================================================
-- 56. REIMBURSEMENT REQUESTS
-- ============================================================================
-- Referenced by: super-admin.php, organization-export.php.

CREATE TABLE IF NOT EXISTS reimbursement_requests (
    id                  BIGSERIAL PRIMARY KEY,
    case_id             BIGINT REFERENCES cases(id),
    organization_id     BIGINT REFERENCES coalition_organizations(id),
    funding_source_id   BIGINT REFERENCES funding_sources(id),
    amount              NUMERIC(12,2),
    status              VARCHAR(30) DEFAULT 'pending',
    requested_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    processed_at        TIMESTAMPTZ,
    notes               TEXT
);

CREATE INDEX IF NOT EXISTS idx_rr_case ON reimbursement_requests(case_id);
CREATE INDEX IF NOT EXISTS idx_rr_org ON reimbursement_requests(organization_id);
CREATE INDEX IF NOT EXISTS idx_rr_status ON reimbursement_requests(status);

ALTER TABLE reimbursement_requests ADD COLUMN IF NOT EXISTS case_id BIGINT REFERENCES cases(id);
ALTER TABLE reimbursement_requests ADD COLUMN IF NOT EXISTS organization_id BIGINT REFERENCES coalition_organizations(id);
ALTER TABLE reimbursement_requests ADD COLUMN IF NOT EXISTS funding_source_id BIGINT REFERENCES funding_sources(id);
ALTER TABLE reimbursement_requests ADD COLUMN IF NOT EXISTS amount NUMERIC(12,2);
ALTER TABLE reimbursement_requests ADD COLUMN IF NOT EXISTS status VARCHAR(30) DEFAULT 'pending';
ALTER TABLE reimbursement_requests ADD COLUMN IF NOT EXISTS requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
ALTER TABLE reimbursement_requests ADD COLUMN IF NOT EXISTS processed_at TIMESTAMPTZ;
ALTER TABLE reimbursement_requests ADD COLUMN IF NOT EXISTS notes TEXT;

-- ============================================================================
-- 57. BURSTAR ACTION AUDIT (conditionally created)
-- ============================================================================
-- Referenced by: super-admin.php (conditional on table existence).

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'bursar_action_audit') THEN
        CREATE TABLE bursar_action_audit (
            id              BIGSERIAL PRIMARY KEY,
            organization_id BIGINT REFERENCES coalition_organizations(id),
            action          VARCHAR(100),
            details         JSONB,
            performed_by    BIGINT REFERENCES system_users(id),
            performed_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
        );
        CREATE INDEX idx_baa_org ON bursar_action_audit(organization_id);
        CREATE INDEX idx_baa_time ON bursar_action_audit(performed_at DESC);
    END IF;
END
$$;

ALTER TABLE bursar_action_audit ADD COLUMN IF NOT EXISTS organization_id BIGINT REFERENCES coalition_organizations(id);
ALTER TABLE bursar_action_audit ADD COLUMN IF NOT EXISTS action VARCHAR(100);
ALTER TABLE bursar_action_audit ADD COLUMN IF NOT EXISTS details JSONB;
ALTER TABLE bursar_action_audit ADD COLUMN IF NOT EXISTS performed_by BIGINT REFERENCES system_users(id);
ALTER TABLE bursar_action_audit ADD COLUMN IF NOT EXISTS performed_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ============================================================================
-- 58. AUDIT LOG (legacy — distinct from activity_log)
-- ============================================================================
-- Referenced by: org-admin.php, super-admin.php.

CREATE TABLE IF NOT EXISTS audit_log (
    id              BIGSERIAL PRIMARY KEY,
    submission_id   BIGINT REFERENCES intake_submissions(id),
    action          VARCHAR(100),
    new_value       TEXT,
    performed_by    BIGINT REFERENCES system_users(id),
    performed_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_log_submission ON audit_log(submission_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_time ON audit_log(performed_at DESC);

ALTER TABLE audit_log ADD COLUMN IF NOT EXISTS submission_id BIGINT REFERENCES intake_submissions(id);
ALTER TABLE audit_log ADD COLUMN IF NOT EXISTS action VARCHAR(100);
ALTER TABLE audit_log ADD COLUMN IF NOT EXISTS new_value TEXT;
ALTER TABLE audit_log ADD COLUMN IF NOT EXISTS performed_by BIGINT REFERENCES system_users(id);
ALTER TABLE audit_log ADD COLUMN IF NOT EXISTS performed_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ============================================================================
-- 59. REPAIR CATEGORY DETAILS
-- ============================================================================
-- Referenced by: case-review.php.

CREATE TABLE IF NOT EXISTS repair_category_details (
    id                      BIGSERIAL PRIMARY KEY,
    category_id             BIGINT REFERENCES repair_categories(id),
    submission_id           BIGINT REFERENCES intake_submissions(id),
    details_text            TEXT,
    water_source            VARCHAR(100),
    heating_woodstove       BOOLEAN DEFAULT false,
    heating_gas_propane     BOOLEAN DEFAULT false,
    heating_electric        BOOLEAN DEFAULT false,
    heating_kerosene        BOOLEAN DEFAULT false
);

CREATE INDEX IF NOT EXISTS idx_rcd_category ON repair_category_details(category_id);
CREATE INDEX IF NOT EXISTS idx_rcd_submission ON repair_category_details(submission_id);

ALTER TABLE repair_category_details ADD COLUMN IF NOT EXISTS category_id BIGINT REFERENCES repair_categories(id);
ALTER TABLE repair_category_details ADD COLUMN IF NOT EXISTS submission_id BIGINT REFERENCES intake_submissions(id);
ALTER TABLE repair_category_details ADD COLUMN IF NOT EXISTS details_text TEXT;
ALTER TABLE repair_category_details ADD COLUMN IF NOT EXISTS water_source VARCHAR(100);
ALTER TABLE repair_category_details ADD COLUMN IF NOT EXISTS heating_woodstove BOOLEAN DEFAULT false;
ALTER TABLE repair_category_details ADD COLUMN IF NOT EXISTS heating_gas_propane BOOLEAN DEFAULT false;
ALTER TABLE repair_category_details ADD COLUMN IF NOT EXISTS heating_electric BOOLEAN DEFAULT false;
ALTER TABLE repair_category_details ADD COLUMN IF NOT EXISTS heating_kerosene BOOLEAN DEFAULT false;

-- ============================================================================
-- 60. SUPPORT TICKETS — ADD MISSING COLUMNS
-- ============================================================================
-- master-schema already defines support_tickets. Code in vue_api/support-chat.php
-- also uses a slightly different schema (submitted_by as INTEGER). Add columns
-- the code references that master-schema may not have.

ALTER TABLE support_tickets ADD COLUMN IF NOT EXISTS submitter_name VARCHAR(128);
ALTER TABLE support_tickets ADD COLUMN IF NOT EXISTS submitter_email VARCHAR(256);
ALTER TABLE support_tickets ADD COLUMN IF NOT EXISTS screenshot_url TEXT;
ALTER TABLE support_tickets ADD COLUMN IF NOT EXISTS resolved_by BIGINT REFERENCES system_users(id);
ALTER TABLE support_tickets ADD COLUMN IF NOT EXISTS resolution_note TEXT;

-- ============================================================================
-- 61. LOGIN ATTEMPTS — ADD MISSING COLUMNS
-- ============================================================================
-- master-schema has: ip_address, username, success, attempted_at
-- app/sql/login-attempts.sql has: ip_address, email, attempted_at
-- vue_api/auth.php references: ip_address, email, attempted_at

ALTER TABLE login_attempts ADD COLUMN IF NOT EXISTS email VARCHAR(255);

-- ============================================================================
-- 62. BLOCKED IPS — ADD MISSING COLUMNS
-- ============================================================================
-- Already defined in master-schema. Add any missing columns.
-- (All columns from master-schema are already present)

-- ============================================================================
-- 63. SYSTEM USERS — ADD MISSING COLUMNS
-- ============================================================================
-- master-schema has: username, email, password_hash, full_name, is_active,
--   session_indefinite, reset_token, reset_token_expires, menu_config,
--   created_at, updated_at
-- Code additionally references: first_name, last_name, phone, territory,
--   last_login, created_by

ALTER TABLE system_users ADD COLUMN IF NOT EXISTS first_name VARCHAR(255);
ALTER TABLE system_users ADD COLUMN IF NOT EXISTS last_name VARCHAR(255);
ALTER TABLE system_users ADD COLUMN IF NOT EXISTS phone VARCHAR(20);
ALTER TABLE system_users ADD COLUMN IF NOT EXISTS territory VARCHAR(100);
ALTER TABLE system_users ADD COLUMN IF NOT EXISTS last_login TIMESTAMPTZ;
ALTER TABLE system_users ADD COLUMN IF NOT EXISTS created_by BIGINT REFERENCES system_users(id);
ALTER TABLE system_users ADD COLUMN IF NOT EXISTS session_indefinite BOOLEAN NOT NULL DEFAULT false;

-- ============================================================================
-- 64. USER ROLE ASSIGNMENTS — ADD MISSING COLUMNS
-- ============================================================================
-- master-schema has: user_id, role_id, is_active, assigned_at
-- Code additionally references: organization_id, assigned_by

ALTER TABLE user_role_assignments ADD COLUMN IF NOT EXISTS organization_id BIGINT REFERENCES coalition_organizations(id);
ALTER TABLE user_role_assignments ADD COLUMN IF NOT EXISTS assigned_by BIGINT REFERENCES system_users(id);

-- ============================================================================
-- 65. ADD MISSING FOREIGN KEY CONSTRAINTS
-- ============================================================================
-- Many tables were created with FK references inline above, but for tables
-- that already existed before this migration, we add FKs conditionally.

-- intake_submissions.deduplicated_into → applications.id
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_intake_deduplicated_into'
    ) THEN
        ALTER TABLE intake_submissions
            ADD CONSTRAINT fk_intake_deduplicated_into
            FOREIGN KEY (deduplicated_into) REFERENCES applications(id);
    END IF;
END
$$;

-- intake_submissions.requestor_user_id → system_users.id
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_intake_requestor'
    ) THEN
        ALTER TABLE intake_submissions
            ADD CONSTRAINT fk_intake_requestor
            FOREIGN KEY (requestor_user_id) REFERENCES system_users(id);
    END IF;
END
$$;

-- intake_submissions.reviewed_by → system_users.id
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_intake_reviewed_by'
    ) THEN
        ALTER TABLE intake_submissions
            ADD CONSTRAINT fk_intake_reviewed_by
            FOREIGN KEY (reviewed_by) REFERENCES system_users(id);
    END IF;
END
$$;

-- cases.application_id → applications.id
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_cases_application'
    ) THEN
        ALTER TABLE cases
            ADD CONSTRAINT fk_cases_application
            FOREIGN KEY (application_id) REFERENCES applications(id);
    END IF;
END
$$;

-- cases.created_by → system_users.id
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_cases_created_by'
    ) THEN
        ALTER TABLE cases
            ADD CONSTRAINT fk_cases_created_by
            FOREIGN KEY (created_by) REFERENCES system_users(id);
    END IF;
END
$$;

-- cases.updated_by → system_users.id
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_cases_updated_by'
    ) THEN
        ALTER TABLE cases
            ADD CONSTRAINT fk_cases_updated_by
            FOREIGN KEY (updated_by) REFERENCES system_users(id);
    END IF;
END
$$;

-- ============================================================================
-- 66. CREATE VIEWS
-- ============================================================================

-- case_document_inventory: per-case per-category doc counts
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_views WHERE viewname = 'case_document_inventory') THEN
        CREATE VIEW case_document_inventory AS
        SELECT
            c.id AS case_id,
            c.case_number,
            dc.category_code,
            dc.category_name,
            COUNT(d.id) AS document_count,
            COUNT(d.id) FILTER (WHERE d.verified_at IS NOT NULL) AS verified_count,
            COUNT(d.id) FILTER (WHERE d.status_id = (SELECT id FROM document_statuses WHERE status_code = 'PENDING')) AS pending_count,
            MAX(d.uploaded_at) AS last_upload
        FROM cases c
        CROSS JOIN document_categories dc
        LEFT JOIN case_documents d ON d.case_id = c.id AND d.category_id = dc.id AND d.deleted_at IS NULL
        GROUP BY c.id, c.case_number, dc.category_code, dc.category_name;
    END IF;
END
$$;

-- pending_verification_documents: docs awaiting verification
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_views WHERE viewname = 'pending_verification_documents') THEN
        CREATE VIEW pending_verification_documents AS
        SELECT
            d.id,
            d.case_id,
            c.case_number,
            d.file_name,
            d.uploaded_at,
            d.uploaded_by,
            dc.category_name,
            dc.category_code,
            up.full_name AS uploaded_by_name,
            COALESCE(ap.applicant_first_name, s.applicant_first_name) AS applicant_first_name,
            COALESCE(ap.applicant_last_name, s.applicant_last_name) AS applicant_last_name
        FROM case_documents d
        JOIN cases c ON c.id = d.case_id
        LEFT JOIN document_categories dc ON dc.id = d.category_id
        LEFT JOIN system_users up ON up.id = d.uploaded_by
        LEFT JOIN intake_submissions s ON s.id = c.submission_id
        LEFT JOIN applications ap ON ap.id = c.application_id
        WHERE d.deleted_at IS NULL
          AND d.verified_at IS NULL
          AND d.status_id = (SELECT id FROM document_statuses WHERE status_code = 'PENDING' LIMIT 1);
    END IF;
END
$$;

COMMIT;

-- ============================================================================
-- SUMMARY
-- ============================================================================
-- This migration creates/ensures the following tables:
--
-- Core workflow:     intake_submissions, applications, cases, case_statuses,
--                    application_anchor, review_queue
--
-- Intake data:       repair_requests, repair_categories,
--                    submission_repair_categories, household_attributes,
--                    submission_household_attributes, contact_methods,
--                    submission_contact_methods, income_records
--
-- Audit & logging:   activity_detail, notifications, audit_log,
--                    bursar_action_audit
--
-- Documents:         case_documents, document_categories, document_statuses,
--                    document_templates, document_generation_jobs,
--                    document_access_log, case_document_inventory (view),
--                    pending_verification_documents (view)
--
-- Case management:   case_claims, case_status_history, case_withdrawals,
--                    case_repair_claims, work_orders, work_tasks,
--                    work_order_tasks, progress_events, project_escalations,
--                    application_assignments, assignment_log
--
-- Role-specific:     crew_job_cards, crew_job_tasks, crew_assignments,
--                    volunteer_slots, volunteer_slot_assignments,
--                    subcontractor_quote_requests, subcontractor_assignments,
--                    task_rabbit_queue, payments, assessments (+ columns),
--                    repair_category_details
--
-- Organization:      coalition_organizations, organization_eligibility_rules,
--                    criteria_types, eligibility_results, organization_metrics,
--                    organization_users, funding_sources,
--                    reimbursement_requests
--
-- Security:          blocked_ips (+ columns), login_attempts (+ columns),
--                    support_tickets (+ columns)
--
-- User management:   system_users (+ columns), roles (in master),
--                    user_role_assignments (+ columns), auth_tokens (in master)
--
-- Already in master-schema-psql-only.sql (not recreated):
--   roles, system_users, user_role_assignments, auth_tokens,
--   login_attempts, blocked_ips, support_tickets, activity_log,
--   application_field_edits, assessments, scope_of_work_line_items,
--   materials_inventory, assessment_documents, site_photos
-- ============================================================================
