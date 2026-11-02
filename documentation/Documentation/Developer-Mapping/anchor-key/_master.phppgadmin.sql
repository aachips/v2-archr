-- =====================================================================
-- ARCHR flattened deploy for phpPgAdmin
-- GENERATED FILE - do not edit by hand. Regenerate with:
--     pwsh -File sql\build-phppgadmin.ps1
-- HOW TO USE: phpPgAdmin > select the archr database > SQL tab > paste
-- this entire file > Execute.
-- =====================================================================

-- NOTE: CREATE EXTENSION pgcrypto is intentionally NOT in this script.
-- Shared cPanel PostgreSQL users are not superusers and cannot create
-- extensions. Instead, the compatibility shim below provides
-- gen_random_uuid() ONLY when neither the PostgreSQL 13+ built-in nor
-- the pgcrypto extension is present. It is a no-op on both.

-- gen_random_uuid() compatibility shim (pure SQL, works on PG 9.x+).
DO $shim$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM pg_proc p
          JOIN pg_namespace n ON n.oid = p.pronamespace
         WHERE p.proname = 'gen_random_uuid'
    ) THEN
        EXECUTE $fn$
            CREATE FUNCTION gen_random_uuid() RETURNS uuid AS $body$
            DECLARE
                b text := '';
                i int;
            BEGIN
                FOR i IN 1..16 LOOP
                    b := b || lpad(to_hex(floor(random() * 256)::int), 2, '0');
                END LOOP;
                -- set version (4) and variant (10xx) bits of a UUID v4
                b := overlay(b placing lpad(to_hex(64  + floor(random() * 16)::int), 2, '0') from 13 for 2);
                b := overlay(b placing lpad(to_hex(128 + floor(random() * 64)::int), 2, '0') from 17 for 2);
                RETURN b::uuid;
            END;
            $body$ LANGUAGE plpgsql;
        $fn$;
    END IF;
END $shim$;

-- ----------------------------------------------------------------
-- BEGIN sql/intake.sql
-- ----------------------------------------------------------------
-- ARCHR Intake Form Database Schema
-- Based on the HTML intake form and JavaScript handler

-- This schema:
-- 
-- Preserves all form fields from your multi-page intake form
-- 
-- Handles dynamic content (repair rows, income calculator entries, checkboxes)
-- 
-- Uses proper normalization for many-to-many relationships (household attributes, repair categories, contact methods)
-- 
-- Stores signatures as base64 PNG data URLs (as your JS does)
-- 
-- Includes audit logging for tracking changes through the approval workflow
-- 
-- Provides helpful views for common reporting needs like urgent conditions tracking
-- 
-- The schema avoids storing any privileged information beyond what your form already collects, and is structured to make the "nightmare" AirTable much more manageable with proper relational queries.

-- =====================================================
-- MAIN APPLICANT / REFERRAL TABLE
-- =====================================================



CREATE TABLE intake_submissions (
    id SERIAL PRIMARY KEY,
    submission_uuid UUID DEFAULT gen_random_uuid() UNIQUE,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    language VARCHAR(3) DEFAULT 'eng', -- eng / esp
    
    -- Referral information (Page 1 & 3)
    is_referral BOOLEAN, -- true=yes, false=no
    referrer_name VARCHAR(255),
    referrer_organization VARCHAR(255),
    referrer_email VARCHAR(255),
    referrer_notes TEXT,
    
    -- Consent (Page 2)
    consent_agreed BOOLEAN, -- true=agreed
    
    -- Primary applicant (Page 4)
    applicant_first_name VARCHAR(100),
    applicant_last_name VARCHAR(100),
    applicant_dob DATE,
    applicant_dob_unknown BOOLEAN DEFAULT FALSE,
    
    -- Contact methods (Page 4)
    preferred_phone BOOLEAN DEFAULT FALSE,
    preferred_text BOOLEAN DEFAULT FALSE,
    preferred_email BOOLEAN DEFAULT FALSE,
    preferred_other BOOLEAN DEFAULT FALSE,
    home_phone VARCHAR(20),
    cell_phone VARCHAR(20),
    contact_email VARCHAR(255),
    other_contact_method_description VARCHAR(500),
    contact_notes TEXT,
    
    -- Address & Home (Page 5)
    home_address VARCHAR(500),
    home_city VARCHAR(100),
    home_state VARCHAR(50),
    home_zip VARCHAR(20),
    is_primary_residence BOOLEAN,
    receives_different_mail BOOLEAN,
    
    -- Mailing address (conditional)
    mail_address VARCHAR(500),
    mail_city VARCHAR(100),
    mail_state VARCHAR(50),
    mail_zip VARCHAR(20),
    
    -- Home details (Page 5)
    home_type VARCHAR(50), -- traditional, modular, mobile, other
    year_built INTEGER,
    move_in_date DATE,
    owns_home BOOLEAN,
    owns_lot BOOLEAN, -- only for mobile homes
    insurance_provider VARCHAR(255),
    lived_one_year BOOLEAN,
    
    -- Household (Page 5)
    household_size INTEGER,
    household_adults INTEGER,
    
    -- Repair details (Page 6)
    additional_repair_details TEXT,
    
    -- Urgent conditions (Page 6 - staff version)
    urgent_unable_to_stay BOOLEAN DEFAULT FALSE,
    urgent_no_hvac BOOLEAN DEFAULT FALSE,
    urgent_no_potable_water BOOLEAN DEFAULT FALSE,
    urgent_no_bathroom BOOLEAN DEFAULT FALSE,
    urgent_no_kitchen BOOLEAN DEFAULT FALSE,
    urgent_open_to_elements BOOLEAN DEFAULT FALSE,
    urgent_no_entry BOOLEAN DEFAULT FALSE,
    urgent_accessibility BOOLEAN DEFAULT FALSE,
    urgent_other_issue BOOLEAN DEFAULT FALSE,
    urgent_eviction_risk BOOLEAN DEFAULT FALSE,
    
    -- Hurricane Helene (Page 9)
    helene_related BOOLEAN,
    
    -- FEMA claim (Page 10)
    fema_claim_filed BOOLEAN,
    fema_outcome VARCHAR(20), -- denied, settled, other
    fema_settlement_amount DECIMAL(12,2),
    fema_remaining_exists BOOLEAN,
    fema_remaining_amount DECIMAL(12,2),
    
    -- Insurance claim (Page 11)
    insurance_claim_filed BOOLEAN,
    insurance_outcome VARCHAR(20), -- denied, settled, other
    insurance_settlement_amount DECIMAL(12,2),
    insurance_remaining_exists BOOLEAN,
    insurance_remaining_amount DECIMAL(12,2),
    
    -- Income (Page 12)
    has_income BOOLEAN,
    income_method VARCHAR(10), -- gross, calculator
    gross_annual_income DECIMAL(12,2),
    income_docs_method VARCHAR(20), -- upload_now, email_link, in_person
    
    -- Zero Income Affidavit (Page 13)
    zero_income_first_name VARCHAR(100),
    zero_income_last_name VARCHAR(100),
    zero_income_address VARCHAR(500),
    zero_income_agreed BOOLEAN,
    
    -- Signatures (stored as base64 PNG data URLs)
    applicant_signature TEXT, -- PNG data URL
    zero_income_signature TEXT, -- PNG data URL
    
    -- Status tracking
    submission_status VARCHAR(20) DEFAULT 'pending', -- pending, reviewed, approved, denied
    assigned_organization VARCHAR(100),
    reviewed_by VARCHAR(100),
    reviewed_at TIMESTAMP,
    eligibility_checked_at TIMESTAMP, -- set by check_eligibility() in eligibility-tracker.sql
    is_test BOOLEAN DEFAULT FALSE, -- flagged true for fixtures inserted by test-case.sql; metric-tracking.sql excludes these

    -- Requestor account created after submission.
    -- FK constraint is NOT declared inline: system_users is created later by
    -- role-based-access.sql, and an inline reference aborts this whole CREATE
    -- TABLE on a fresh database. requestor-account-link.sql adds the FK.
    requestor_user_id INTEGER
);

-- =====================================================
-- HOUSEHOLD ATTRIBUTES (Checkboxes - many-to-many)
-- =====================================================
CREATE TABLE household_attributes (
    id SERIAL PRIMARY KEY,
    attribute_name VARCHAR(50) UNIQUE NOT NULL -- single_parent, child_under_5, person_over_62, person_with_disability, snap_wic, veteran
);

-- Pre-populate household attributes
INSERT INTO household_attributes (attribute_name) VALUES 
    ('single_parent'), ('child_under_5'), ('person_over_62'), 
    ('person_with_disability'), ('snap_wic'), ('veteran');

-- Junction table for submissions and household attributes
CREATE TABLE submission_household_attributes (
    submission_id INTEGER REFERENCES intake_submissions(id) ON DELETE CASCADE,
    attribute_id INTEGER REFERENCES household_attributes(id),
    PRIMARY KEY (submission_id, attribute_id)
);

-- =====================================================
-- REPAIR REQUESTS (Dynamic rows from Page 6 table)
-- =====================================================
CREATE TABLE repair_requests (
    id SERIAL PRIMARY KEY,
    submission_id INTEGER REFERENCES intake_submissions(id) ON DELETE CASCADE,
    repair_need TEXT NOT NULL,
    priority INTEGER, -- 1 = highest priority
    sort_order INTEGER -- order in which it was added
);

-- =====================================================
-- REPAIR CATEGORIES (Page 7 - applicant-facing checkboxes)
-- =====================================================
CREATE TABLE repair_categories (
    id SERIAL PRIMARY KEY,
    category_code VARCHAR(50) UNIQUE NOT NULL,
    category_label VARCHAR(100) NOT NULL
);

INSERT INTO repair_categories (category_code, category_label) VALUES
    ('unable_to_stay', 'Unable to stay in home'),
    ('no_hvac', 'No heating/AC'),
    ('no_potable_water', 'No potable water'),
    ('no_bathroom', 'Cannot use bathroom'),
    ('no_kitchen', 'Cannot use kitchen'),
    ('open_to_elements', 'Open to elements'),
    ('no_entry', 'Cannot enter/exit'),
    ('accessibility', 'Accessibility need'),
    ('other_issue', 'Other issue'),
    ('eviction_risk', 'Eviction risk');

-- Junction table for submissions and repair categories
CREATE TABLE submission_repair_categories (
    submission_id INTEGER REFERENCES intake_submissions(id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES repair_categories(id),
    PRIMARY KEY (submission_id, category_id)
);

-- =====================================================
-- REPAIR CATEGORY DETAILS (Page 8 - follow-up questions)
-- =====================================================
CREATE TABLE repair_category_details (
    id SERIAL PRIMARY KEY,
    submission_id INTEGER REFERENCES intake_submissions(id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES repair_categories(id),
    
    -- Common fields
    details_text TEXT,
    
    -- Heating sources (for no_hvac category)
    heating_woodstove BOOLEAN DEFAULT FALSE,
    heating_gas_propane BOOLEAN DEFAULT FALSE,
    heating_electric BOOLEAN DEFAULT FALSE,
    heating_kerosene BOOLEAN DEFAULT FALSE,
    
    -- Water source (for no_potable_water category)
    water_source VARCHAR(20), -- municipal, well
    
    UNIQUE(submission_id, category_id)
);

-- =====================================================
-- INCOME RECORDS (Calculator modal - Page 12)
-- =====================================================
CREATE TABLE income_records (
    id SERIAL PRIMARY KEY,
    submission_id INTEGER REFERENCES intake_submissions(id) ON DELETE CASCADE,
    whose_income VARCHAR(10), -- mine, other
    income_source VARCHAR(30), -- work, self_employment, social_security, disability, retirement, other
    frequency VARCHAR(15), -- weekly, biweekly, monthly, annually, other
    amount DECIMAL(12,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- CONTACT METHODS (Preferred contact - Page 4)
-- =====================================================
CREATE TABLE contact_methods (
    id SERIAL PRIMARY KEY,
    method_code VARCHAR(10) UNIQUE NOT NULL -- phone, text, email, other
);

INSERT INTO contact_methods (method_code) VALUES ('phone'), ('text'), ('email'), ('other');

CREATE TABLE submission_contact_methods (
    submission_id INTEGER REFERENCES intake_submissions(id) ON DELETE CASCADE,
    method_id INTEGER REFERENCES contact_methods(id),
    PRIMARY KEY (submission_id, method_id)
);

-- =====================================================
-- AUDIT LOG (Track changes, reviews, status updates)
-- =====================================================
CREATE TABLE audit_log (
    id SERIAL PRIMARY KEY,
    submission_id INTEGER REFERENCES intake_submissions(id) ON DELETE CASCADE,
    action VARCHAR(50), -- created, updated, reviewed, status_changed, assigned
    old_value TEXT,
    new_value TEXT,
    performed_by VARCHAR(100),
    performed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- HELPER VIEWS FOR COMMON QUERIES
-- =====================================================

-- View to see complete submission with aggregated data
CREATE VIEW submission_full_view AS
SELECT 
    s.*,
    -- Aggregated repair categories as array
    (SELECT ARRAY_AGG(rc.category_code) 
     FROM submission_repair_categories src 
     JOIN repair_categories rc ON src.category_id = rc.id 
     WHERE src.submission_id = s.id) as repair_categories,
    
    -- Aggregated household attributes as array
    (SELECT ARRAY_AGG(ha.attribute_name) 
     FROM submission_household_attributes sha 
     JOIN household_attributes ha ON sha.attribute_id = ha.id 
     WHERE sha.submission_id = s.id) as household_attributes,
    
    -- Aggregated contact methods as array
    (SELECT ARRAY_AGG(cm.method_code) 
     FROM submission_contact_methods scm 
     JOIN contact_methods cm ON scm.method_id = cm.id 
     WHERE scm.submission_id = s.id) as contact_methods,
    
    -- Income total (annualized from calculator records)
    (SELECT SUM(
        CASE frequency
            WHEN 'weekly' THEN amount * 52
            WHEN 'biweekly' THEN amount * 26
            WHEN 'monthly' THEN amount * 12
            WHEN 'annually' THEN amount
            ELSE amount
        END
     ) FROM income_records WHERE submission_id = s.id) as calculator_income_total

FROM intake_submissions s;

-- View for urgent conditions tracking
CREATE VIEW urgent_conditions_view AS
SELECT 
    id as submission_id,
    applicant_first_name,
    applicant_last_name,
    urgent_unable_to_stay,
    urgent_no_hvac,
    urgent_no_potable_water,
    urgent_no_bathroom,
    urgent_no_kitchen,
    urgent_open_to_elements,
    urgent_no_entry,
    urgent_accessibility,
    urgent_other_issue,
    urgent_eviction_risk,
    -- Count of urgent conditions for prioritization
    (urgent_unable_to_stay::int + 
     urgent_no_hvac::int + 
     urgent_no_potable_water::int + 
     urgent_no_bathroom::int + 
     urgent_no_kitchen::int + 
     urgent_open_to_elements::int + 
     urgent_no_entry::int) as urgent_condition_count
FROM intake_submissions
WHERE urgent_unable_to_stay IS NOT NULL;

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

CREATE INDEX idx_intake_submissions_submitted_at ON intake_submissions(submitted_at);
CREATE INDEX idx_intake_submissions_status ON intake_submissions(submission_status);
CREATE INDEX idx_intake_submissions_helene_related ON intake_submissions(helene_related);
CREATE INDEX idx_intake_submissions_has_income ON intake_submissions(has_income);
CREATE INDEX idx_repair_requests_submission_id ON repair_requests(submission_id);
CREATE INDEX idx_income_records_submission_id ON income_records(submission_id);
CREATE INDEX idx_repair_category_details_submission_id ON repair_category_details(submission_id);

-- =====================================================
-- NOTES ON DATA MIGRATION FROM AIRTABLE:
-- =====================================================
/*
The current HTML form would submit data that needs to be parsed into this schema.
Key mapping considerations:

1. `preferredContact[]` array -> submission_contact_methods table
2. `householdAttributes[]` array -> submission_household_attributes table  
3. `repairCategory[]` array -> submission_repair_categories table + repair_category_details
4. `urgentConditions[]` -> boolean columns on intake_submissions
5. Dynamic repair table rows -> repair_requests table
6. Dynamic income calculator rows -> income_records table
7. Signatures stored as base64 PNG -> TEXT columns
8. `heatingSource[]` -> boolean columns on repair_category_details for no_hvac category
*/

-- =====================================================
-- SAMPLE QUERIES FOR REPORTING
-- =====================================================

/*
-- Get all urgent cases requiring immediate attention:
SELECT * FROM urgent_conditions_view 
WHERE urgent_condition_count > 0 
ORDER BY urgent_condition_count DESC;

-- Get Helene-related cases with outstanding insurance balances:
SELECT applicant_first_name, applicant_last_name, 
       insurance_settlement_amount, insurance_remaining_amount
FROM intake_submissions 
WHERE helene_related = true 
  AND insurance_remaining_exists = true;

-- Get zero-income submissions awaiting affidavit review:
SELECT * FROM intake_submissions 
WHERE has_income = false 
  AND zero_income_agreed = true
  AND submission_status = 'pending';
*/
-- END sql/intake.sql

-- ----------------------------------------------------------------
-- BEGIN sql/partner-organizations.sql
-- ----------------------------------------------------------------
-- =====================================================
-- ARCHR Coalition Management Schema
-- Multi-Organization Application Claim/Reject System
-- =====================================================

-- This schema provides:
-- 
-- + Multi-organization support with flexible capacity management
-- + Dynamic eligibility engine supporting 20+ criteria types that can be modified without code changes
-- + Automatic matching with configurable match scores (0-100%)
-- + Claim/reject workflow with expiration and reassignment
-- + Auto-assignment for high-quality matches (configurable per organization)
-- + Performance materialized view for fast application-organization matching
-- + Metrics tracking for coalition oversight
-- + Full audit logging of all assignment actions
-- 
-- The system is designed so you can:
-- + Add/remove organizations dynamically
-- + Modify any organization's eligibility criteria on the fly
-- + Set different match thresholds per organization
-- + Track capacity and automatically route applications
-- + Generate reports on coalition performance

-- =====================================================
-- ORGANIZATION MANAGEMENT
-- =====================================================

-- Core organizations table
CREATE TABLE coalition_organizations (
    id SERIAL PRIMARY KEY,
    organization_code VARCHAR(20) UNIQUE NOT NULL, -- e.g., 'HABITAT', 'CAO', 'PODER'
    organization_name VARCHAR(200) NOT NULL,
    description TEXT,
    website_url VARCHAR(255),
    contact_email VARCHAR(255),
    contact_phone VARCHAR(20),
    logo_url VARCHAR(255),
    
    -- Operational settings
    is_active BOOLEAN DEFAULT TRUE,
    max_active_applications INTEGER DEFAULT 50, -- Max applications they can handle simultaneously
    auto_claim_enabled BOOLEAN DEFAULT FALSE, -- Auto-claim perfectly matched apps
    notification_email VARCHAR(255), -- Where to send match notifications
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

-- Organization users (staff who can view/claim applications)
CREATE TABLE organization_users (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER REFERENCES coalition_organizations(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    full_name VARCHAR(200),
    role VARCHAR(50) DEFAULT 'viewer', -- admin, reviewer, viewer
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(organization_id, email)
);

-- =====================================================
-- ELIGIBILITY CRITERIA ENGINE
-- =====================================================

-- Criteria types (for UI rendering)
CREATE TABLE criteria_types (
    id SERIAL PRIMARY KEY,
    type_code VARCHAR(50) UNIQUE NOT NULL,
    type_name VARCHAR(100) NOT NULL,
    input_type VARCHAR(20) NOT NULL, -- text, number, select, multiselect, boolean, range
    description TEXT
);

INSERT INTO criteria_types (type_code, type_name, input_type, description) VALUES
    ('income_max', 'Maximum Annual Income', 'number', 'Maximum household annual income allowed'),
    ('income_min', 'Minimum Annual Income', 'number', 'Minimum household annual income required'),
    ('geography_counties', 'Eligible Counties', 'multiselect', 'Comma-separated list of eligible counties'),
    ('geography_zipcodes', 'Eligible ZIP Codes', 'multiselect', 'Comma-separated list of eligible ZIP codes'),
    ('homeowner_status', 'Homeowner Status Required', 'select', 'Must own home? Values: yes, no, either'),
    ('home_type_allowed', 'Allowed Home Types', 'multiselect', 'traditional, modular, mobile, other'),
    ('primary_residence_required', 'Primary Residence Required', 'boolean', 'Must be primary residence'),
    ('min_household_size', 'Minimum Household Size', 'number', 'Minimum number of household members'),
    ('max_household_size', 'Maximum Household Size', 'number', 'Maximum number of household members'),
    ('min_years_in_home', 'Minimum Years in Home', 'number', 'Minimum years lived at current address'),
    ('helene_damage_only', 'Helene Damage Only', 'boolean', 'Only accept Helene-related damage'),
    ('repair_categories', 'Repair Categories Served', 'multiselect', 'Types of repairs organization handles'),
    ('household_attributes', 'Household Attributes Served', 'multiselect', 'Special household characteristics served'),
    ('urgent_only', 'Urgent Cases Only', 'boolean', 'Only accept urgent condition applications'),
    ('age_requirement', 'Age Requirement', 'range', 'Minimum age of primary applicant'),
    ('veteran_only', 'Veteran Only', 'boolean', 'Only serve veteran households'),
    ('disability_only', 'Disability Only', 'boolean', 'Only serve households with disability'),
    ('max_repair_estimate', 'Maximum Repair Cost', 'number', 'Maximum repair cost organization can handle'),
    ('fema_claim_accepted', 'FEMA Claim Status', 'select', 'Accept applications with FEMA claims: any, yes, no'),
    ('insurance_claim_accepted', 'Insurance Claim Status', 'select', 'Accept applications with insurance claims: any, yes, no');

-- Organization eligibility rules
CREATE TABLE organization_eligibility_rules (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER REFERENCES coalition_organizations(id) ON DELETE CASCADE,
    criteria_type_id INTEGER REFERENCES criteria_types(id),
    rule_operator VARCHAR(10) DEFAULT 'equals', -- equals, not_equals, greater_than, less_than, between, contains, in_list
    rule_value TEXT NOT NULL, -- JSON or comma-separated values depending on type
    priority INTEGER DEFAULT 0, -- Higher priority rules evaluated first
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- APPLICATION MATCHING & ASSIGNMENT
-- =====================================================

-- Track application assignments to organizations
CREATE TABLE application_assignments (
    id SERIAL PRIMARY KEY,
    submission_id INTEGER REFERENCES intake_submissions(id) ON DELETE CASCADE,
    organization_id INTEGER REFERENCES coalition_organizations(id),
    
    -- Assignment status
    status VARCHAR(20) DEFAULT 'pending', -- pending, claimed, rejected, completed, expired
    match_score INTEGER, -- 0-100 match percentage
    
    -- Claim/Reject tracking
    claimed_by INTEGER REFERENCES organization_users(id),
    claimed_at TIMESTAMP,
    rejected_by INTEGER REFERENCES organization_users(id),
    rejected_at TIMESTAMP,
    rejection_reason TEXT,
    
    -- Assignment metadata
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP, -- Auto-expire if not claimed by this date
    notes TEXT,
    
    UNIQUE(submission_id, organization_id)
);

-- Application assignment log (history)
CREATE TABLE assignment_log (
    id SERIAL PRIMARY KEY,
    assignment_id INTEGER REFERENCES application_assignments(id) ON DELETE CASCADE,
    action VARCHAR(50), -- assigned, claimed, rejected, reassigned, expired, completed
    old_value TEXT,
    new_value TEXT,
    performed_by INTEGER REFERENCES organization_users(id),
    performed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

-- =====================================================
-- MATCHING ENGINE - DENORMALIZED VIEW FOR PERFORMANCE
-- =====================================================

-- Materialized view for fast application-organization matching
-- Refresh periodically or on-demand
CREATE MATERIALIZED VIEW application_match_scores AS
WITH application_data AS (
    SELECT 
        s.id as submission_id,
        s.owns_home,
        s.home_type,
        s.is_primary_residence,
        s.household_size,
        s.move_in_date,
        s.helene_related,
        s.urgent_unable_to_stay OR s.urgent_no_hvac OR s.urgent_no_potable_water 
            OR s.urgent_no_bathroom OR s.urgent_no_kitchen OR s.urgent_open_to_elements 
            OR s.urgent_no_entry as is_urgent,
        s.gross_annual_income,
        s.insurance_claim_filed,
        s.fema_claim_filed,
        s.home_city,
        s.home_state,
        s.home_zip,
        s.household_adults,
        
        -- Aggregated arrays
        (SELECT ARRAY_AGG(rc.category_code) 
         FROM submission_repair_categories src 
         JOIN repair_categories rc ON src.category_id = rc.id 
         WHERE src.submission_id = s.id) as repair_categories,
        
        (SELECT ARRAY_AGG(ha.attribute_name) 
         FROM submission_household_attributes sha 
         JOIN household_attributes ha ON sha.attribute_id = ha.id 
         WHERE sha.submission_id = s.id) as household_attributes,
         
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, s.applicant_dob)) as applicant_age
    FROM intake_submissions s
    WHERE s.submission_status = 'pending'
),
organization_criteria AS (
    SELECT 
        o.id as organization_id,
        o.organization_name,
        o.max_active_applications,
        o.auto_claim_enabled,
        jsonb_object_agg(
            ct.type_code, 
            jsonb_build_object(
                'operator', er.rule_operator,
                'value', er.rule_value
            )
        ) FILTER (WHERE er.id IS NOT NULL) as criteria_map,
        COUNT(DISTINCT aa.id) as current_active_applications
    FROM coalition_organizations o
    LEFT JOIN organization_eligibility_rules er ON o.id = er.organization_id AND er.is_active = true
    LEFT JOIN criteria_types ct ON er.criteria_type_id = ct.id
    LEFT JOIN application_assignments aa ON o.id = aa.organization_id 
        AND aa.status IN ('pending', 'claimed')
        AND aa.expires_at > CURRENT_TIMESTAMP
    WHERE o.is_active = true
    GROUP BY o.id, o.organization_name, o.max_active_applications, o.auto_claim_enabled
)
SELECT 
    ad.submission_id,
    oc.organization_id,
    oc.organization_name,
    oc.current_active_applications,
    oc.max_active_applications,
    oc.auto_claim_enabled,
    
    -- Individual match flags for transparency
    CASE WHEN oc.criteria_map->'income_max' IS NOT NULL THEN
        (ad.gross_annual_income <= (oc.criteria_map->'income_max'->>'value')::numeric)
    ELSE true END as income_max_met,
    
    CASE WHEN oc.criteria_map->'income_min' IS NOT NULL THEN
        (ad.gross_annual_income >= (oc.criteria_map->'income_min'->>'value')::numeric)
    ELSE true END as income_min_met,
    
    CASE WHEN oc.criteria_map->'homeowner_status' IS NOT NULL THEN
        CASE (oc.criteria_map->'homeowner_status'->>'value')
            WHEN 'yes' THEN ad.owns_home = true
            WHEN 'no' THEN ad.owns_home = false
            ELSE true
        END
    ELSE true END as homeowner_status_met,
    
    CASE WHEN oc.criteria_map->'home_type_allowed' IS NOT NULL THEN
        ad.home_type = ANY(string_to_array(oc.criteria_map->'home_type_allowed'->>'value', ','))
    ELSE true END as home_type_met,
    
    CASE WHEN oc.criteria_map->'primary_residence_required' IS NOT NULL THEN
        ad.is_primary_residence = (oc.criteria_map->'primary_residence_required'->>'value')::boolean
    ELSE true END as primary_residence_met,
    
    CASE WHEN oc.criteria_map->'geography_zipcodes' IS NOT NULL THEN
        ad.home_zip = ANY(string_to_array(oc.criteria_map->'geography_zipcodes'->>'value', ','))
    ELSE true END as geography_zip_met,
    
    CASE WHEN oc.criteria_map->'helene_damage_only' IS NOT NULL THEN
        ad.helene_related = (oc.criteria_map->'helene_damage_only'->>'value')::boolean
    ELSE true END as helene_condition_met,
    
    CASE WHEN oc.criteria_map->'urgent_only' IS NOT NULL THEN
        ad.is_urgent = (oc.criteria_map->'urgent_only'->>'value')::boolean
    ELSE true END as urgent_only_met,
    
    CASE WHEN oc.criteria_map->'veteran_only' IS NOT NULL THEN
        'veteran' = ANY(ad.household_attributes)
    ELSE true END as veteran_condition_met,
    
    CASE WHEN oc.criteria_map->'disability_only' IS NOT NULL THEN
        'person_with_disability' = ANY(ad.household_attributes)
    ELSE true END as disability_condition_met,
    
    -- Calculate match score (percentage of criteria met)
    ROUND((
        (CASE WHEN oc.criteria_map->'income_max' IS NOT NULL THEN 
            CASE WHEN ad.gross_annual_income <= (oc.criteria_map->'income_max'->>'value')::numeric THEN 1 ELSE 0 END
         ELSE 1 END)::numeric * 
        (CASE WHEN oc.criteria_map->'income_min' IS NOT NULL THEN 
            CASE WHEN ad.gross_annual_income >= (oc.criteria_map->'income_min'->>'value')::numeric THEN 1 ELSE 0 END
         ELSE 1 END)::numeric *
        (CASE WHEN oc.criteria_map->'homeowner_status' IS NOT NULL THEN 
            CASE WHEN ad.owns_home = (oc.criteria_map->'homeowner_status'->>'value' = 'yes') THEN 1 ELSE 0 END
         ELSE 1 END)::numeric *
        (CASE WHEN oc.criteria_map->'home_type_allowed' IS NOT NULL THEN 
            CASE WHEN ad.home_type = ANY(string_to_array(oc.criteria_map->'home_type_allowed'->>'value', ',')) THEN 1 ELSE 0 END
         ELSE 1 END)::numeric *
        (CASE WHEN oc.criteria_map->'primary_residence_required' IS NOT NULL THEN 
            CASE WHEN ad.is_primary_residence = (oc.criteria_map->'primary_residence_required'->>'value')::boolean THEN 1 ELSE 0 END
         ELSE 1 END)::numeric
    ) * 100, 0) as match_score,
    
    -- Check if organization has capacity
    (oc.current_active_applications < oc.max_active_applications) as has_capacity

FROM application_data ad
CROSS JOIN organization_criteria oc
WHERE oc.current_active_applications < oc.max_active_applications -- Only orgs with capacity
    AND NOT EXISTS ( -- Exclude already assigned/rejected
        SELECT 1 FROM application_assignments aa
        WHERE aa.submission_id = ad.submission_id 
        AND aa.organization_id = oc.organization_id
        AND aa.status IN ('claimed', 'rejected')
    );

-- Indexes for the materialized view
CREATE INDEX idx_match_scores_submission ON application_match_scores(submission_id);
CREATE INDEX idx_match_scores_organization ON application_match_scores(organization_id);
CREATE INDEX idx_match_scores_score ON application_match_scores(match_score DESC);

-- =====================================================
-- FUNCTIONS FOR MATCHING AND ASSIGNMENT
-- =====================================================

-- Function to refresh materialized view
-- Plain (non-concurrent) refresh: CONCURRENTLY requires a UNIQUE index on the
-- view, which this view does not have, so the concurrent refresh fails and
-- takes the triggering INSERT down with it. The brief lock is fine at this
-- application's volume.
CREATE OR REPLACE FUNCTION refresh_match_scores()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW application_match_scores;
END;
$$ LANGUAGE plpgsql;

-- Function to automatically assign applications to matching orgs
CREATE OR REPLACE FUNCTION auto_assign_applications()
RETURNS TABLE(
    submission_id INTEGER,
    organization_id INTEGER,
    match_score INTEGER
) AS $$
BEGIN
    -- Insert assignments for unmatched applications with high match scores
    INSERT INTO application_assignments (submission_id, organization_id, match_score, expires_at)
    SELECT 
        ams.submission_id,
        ams.organization_id,
        ams.match_score,
        CURRENT_TIMESTAMP + INTERVAL '14 days' -- 2 weeks to claim
    FROM application_match_scores ams
    WHERE NOT EXISTS (
        SELECT 1 FROM application_assignments aa
        WHERE aa.submission_id = ams.submission_id
    )
    AND ams.match_score >= 80 -- Only high-quality matches
    AND ams.has_capacity = true
    ORDER BY ams.match_score DESC;
    
    -- Auto-claim for organizations with auto_claim_enabled
    INSERT INTO application_assignments (submission_id, organization_id, status, claimed_at, match_score)
    SELECT 
        ams.submission_id,
        ams.organization_id,
        'claimed',
        CURRENT_TIMESTAMP,
        ams.match_score
    FROM application_match_scores ams
    WHERE ams.auto_claim_enabled = true
        AND ams.match_score >= 90 -- Perfect or near-perfect matches
        AND ams.has_capacity = true
        AND NOT EXISTS (
            SELECT 1 FROM application_assignments aa
            WHERE aa.submission_id = ams.submission_id
            AND aa.status = 'claimed'
        )
    ON CONFLICT (submission_id, organization_id) DO UPDATE
    SET status = 'claimed', claimed_at = CURRENT_TIMESTAMP;
    
    RETURN QUERY
    SELECT aa.submission_id, aa.organization_id, aa.match_score
    FROM application_assignments aa
    WHERE aa.assigned_at > CURRENT_TIMESTAMP - INTERVAL '1 minute';
END;
$$ LANGUAGE plpgsql;

-- Trigger to run assignment on new submission
CREATE OR REPLACE FUNCTION on_new_submission()
RETURNS TRIGGER AS $$
BEGIN
    -- Refresh match scores
    PERFORM refresh_match_scores();
    -- Auto-assign
    PERFORM auto_assign_applications();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_new_submission
    AFTER INSERT ON intake_submissions
    FOR EACH ROW
    EXECUTE PROCEDURE on_new_submission();

-- =====================================================
-- ORGANIZATION METRICS & REPORTING
-- =====================================================

CREATE TABLE organization_metrics (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER REFERENCES coalition_organizations(id) ON DELETE CASCADE,
    metric_date DATE NOT NULL,
    
    -- Daily/Weekly metrics
    applications_assigned INTEGER DEFAULT 0,
    applications_claimed INTEGER DEFAULT 0,
    applications_rejected INTEGER DEFAULT 0,
    applications_completed INTEGER DEFAULT 0,
    applications_expired INTEGER DEFAULT 0,
    
    -- Time-to-action metrics (hours)
    avg_time_to_claim_hours DECIMAL(10,2),
    avg_time_to_complete_days DECIMAL(10,2),
    
    -- Quality metrics
    avg_match_score DECIMAL(5,2),
    rejection_rate DECIMAL(5,2),
    completion_rate DECIMAL(5,2),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(organization_id, metric_date)
);

-- Function to update organization metrics
CREATE OR REPLACE FUNCTION update_organization_metrics()
RETURNS void AS $$
BEGIN
    INSERT INTO organization_metrics (
        organization_id, metric_date,
        applications_assigned, applications_claimed, 
        applications_rejected, applications_completed,
        avg_time_to_claim_hours, avg_match_score
    )
    SELECT 
        o.id,
        CURRENT_DATE,
        COUNT(CASE WHEN aa.status IN ('pending', 'claimed', 'rejected', 'completed') THEN 1 END),
        COUNT(CASE WHEN aa.status = 'claimed' THEN 1 END),
        COUNT(CASE WHEN aa.status = 'rejected' THEN 1 END),
        COUNT(CASE WHEN aa.status = 'completed' THEN 1 END),
        AVG(EXTRACT(EPOCH FROM (aa.claimed_at - aa.assigned_at))/3600),
        AVG(aa.match_score)
    FROM coalition_organizations o
    LEFT JOIN application_assignments aa ON o.id = aa.organization_id
        AND aa.assigned_at >= CURRENT_DATE - INTERVAL '30 days'
    WHERE o.is_active = true
    GROUP BY o.id
    ON CONFLICT (organization_id, metric_date) DO UPDATE SET
        applications_assigned = EXCLUDED.applications_assigned,
        applications_claimed = EXCLUDED.applications_claimed,
        applications_rejected = EXCLUDED.applications_rejected,
        applications_completed = EXCLUDED.applications_completed,
        avg_time_to_claim_hours = EXCLUDED.avg_time_to_claim_hours,
        avg_match_score = EXCLUDED.avg_match_score,
        updated_at = CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SAMPLE QUERIES FOR COALITION MANAGEMENT
-- =====================================================

/*

-- Find which organizations can serve a specific application
SELECT * FROM application_match_scores 
WHERE submission_id = 123 
ORDER BY match_score DESC;

-- Get all pending applications for an organization
SELECT 
    s.id,
    s.applicant_first_name,
    s.applicant_last_name,
    s.home_city,
    aa.match_score,
    aa.expires_at
FROM application_assignments aa
JOIN intake_submissions s ON aa.submission_id = s.id
WHERE aa.organization_id = 1 
    AND aa.status = 'pending'
    AND aa.expires_at > CURRENT_TIMESTAMP
ORDER BY aa.match_score DESC;

-- Organization dashboard metrics
SELECT 
    o.organization_name,
    COUNT(CASE WHEN aa.status = 'pending' THEN 1 END) as pending_applications,
    COUNT(CASE WHEN aa.status = 'claimed' THEN 1 END) as active_applications,
    COUNT(CASE WHEN aa.status = 'completed' THEN 1 END) as completed_this_month,
    ROUND(AVG(aa.match_score), 1) as avg_match_quality
FROM coalition_organizations o
LEFT JOIN application_assignments aa ON o.id = aa.organization_id
    AND aa.assigned_at >= DATE_TRUNC('month', CURRENT_DATE)
WHERE o.is_active = true
GROUP BY o.id, o.organization_name;

-- Applications that need reassignment (expiring soon)
SELECT 
    s.id,
    s.applicant_first_name,
    s.applicant_last_name,
    o.organization_name,
    aa.expires_at,
    aa.match_score
FROM application_assignments aa
JOIN intake_submissions s ON aa.submission_id = s.id
JOIN coalition_organizations o ON aa.organization_id = o.id
WHERE aa.status = 'pending'
    AND aa.expires_at < CURRENT_TIMESTAMP + INTERVAL '3 days'
ORDER BY aa.expires_at ASC;

-- Add a new organization with eligibility rules
BEGIN;
    INSERT INTO coalition_organizations (organization_code, organization_name, max_active_applications)
    VALUES ('NEW_ORG', 'New Organization Name', 30);
    
    -- Add eligibility rules for the new organization
    INSERT INTO organization_eligibility_rules (organization_id, criteria_type_id, rule_value)
    SELECT 
        currval('coalition_organizations_id_seq'),
        id,
        CASE type_code
            WHEN 'income_max' THEN '50000'
            WHEN 'geography_zipcodes' THEN '28801,28803,28804'
            WHEN 'repair_categories' THEN 'no_hvac,no_potable_water'
            WHEN 'urgent_only' THEN 'true'
        END
    FROM criteria_types 
    WHERE type_code IN ('income_max', 'geography_zipcodes', 'repair_categories', 'urgent_only');
COMMIT;

-- Dynamic modification of an organization's criteria
UPDATE organization_eligibility_rules
SET rule_value = '75000',  -- Increase income max
    updated_at = CURRENT_TIMESTAMP
WHERE organization_id = 1 
    AND criteria_type_id = (SELECT id FROM criteria_types WHERE type_code = 'income_max');

*/
-- END sql/partner-organizations.sql

-- ----------------------------------------------------------------
-- BEGIN sql/role-based-access.sql
-- ----------------------------------------------------------------
-- =====================================================
-- ARCHR Role-Based Access Control Schema
-- Multi-Organization User Management & Case Workflow
-- =====================================================

-- This comprehensive schema provides:
-- 
-- 1) 11 distinct roles with granular permissions (50+ specific permissions)
-- 2) Role hierarchy from Admin down to Volunteer
-- 3) Complete case management workflow with status tracking
-- 4) Assessment and estimation capabilities for home repairs
-- 5) Project and task management for work execution
-- 6) Financial tracking with invoices, budgets, and funding sources
-- 7) Communication logging for audit trails
-- 8) Volunteer-specific tracking (hours, skills)
-- 9) Permission checking functions for API/UI integration
-- 10) Dashboard views for workload and case management
-- 
-- The system is designed to handle the complexity of multiple organizations with different staff roles coordinating on home repair cases from intake through completion.


-- =====================================================
-- USER & ROLE MANAGEMENT
-- =====================================================

-- Core roles definition
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    role_code VARCHAR(50) UNIQUE NOT NULL,
    role_name VARCHAR(100) NOT NULL,
    role_level INTEGER NOT NULL, -- 0-10 for hierarchy
    description TEXT,
    is_system_role BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert all roles
INSERT INTO roles (role_code, role_name, role_level, description, is_system_role) VALUES
    ('ADMIN', 'Administrator', 10, 'Full system administration and configuration', true),
    ('PROJECT_MANAGER', 'Project Manager', 9, 'Oversees multiple projects, budgets, and timelines', true),
    ('BURSAR', 'Bursar', 8, 'Financial management, payments, and invoicing', true),
    ('CASEWORKER', 'Caseworker', 7, 'Primary applicant contact and case coordination', true),
    ('ASSESSOR', 'Assessor', 6, 'Conducts home visits and repair assessments', true),
    ('CREW_LEAD', 'Crew Lead', 5, 'Manages on-site repair crew and work quality', true),
    ('SUBCONTRACTOR', 'Subcontractor', 4, 'External trade specialist', true),
    ('ENVOY', 'Envoy', 3, 'Community liaison and applicant support', true),
    ('CREW_MEMBER', 'Crew Member', 2, 'Performs repair work under supervision', true),
    ('REQUESTOR', 'Requestor', 1, 'Submits initial intake applications', true),
    ('VOLUNTEER', 'Volunteer', 0, 'Unpaid helper with limited access', true);

-- Permission categories
CREATE TABLE permission_categories (
    id SERIAL PRIMARY KEY,
    category_code VARCHAR(50) UNIQUE NOT NULL,
    category_name VARCHAR(100) NOT NULL,
    description TEXT
);

INSERT INTO permission_categories (category_code, category_name) VALUES
    ('CASE', 'Case Management'),
    ('APPLICATION', 'Application Management'),
    ('ASSESSMENT', 'Assessment & Estimation'),
    ('REPAIR', 'Repair Execution'),
    ('FINANCE', 'Financial Management'),
    ('USER', 'User Management'),
    ('ORG', 'Organization Settings'),
    ('REPORT', 'Reporting & Analytics'),
    ('DOCUMENT', 'Document Management'),
    ('COMMUNICATION', 'Communication Tools');

-- Granular permissions
CREATE TABLE permissions (
    id SERIAL PRIMARY KEY,
    permission_code VARCHAR(100) UNIQUE NOT NULL,
    permission_name VARCHAR(200) NOT NULL,
    category_id INTEGER REFERENCES permission_categories(id),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO permissions (permission_code, permission_name, category_id) VALUES
    -- Case permissions
    ('CASE_VIEW', 'View case details', 1),
    ('CASE_CREATE', 'Create new case', 1),
    ('CASE_UPDATE', 'Update case information', 1),
    ('CASE_DELETE', 'Delete case', 1),
    ('CASE_ASSIGN', 'Assign cases to users', 1),
    ('CASE_STATUS_UPDATE', 'Update case status', 1),
    
    -- Application permissions
    ('APP_SUBMIT', 'Submit intake application', 2),
    ('APP_VIEW_OWN', 'View own applications', 2),
    ('APP_VIEW_ALL', 'View all applications', 2),
    ('APP_REVIEW', 'Review applications', 2),
    ('APP_APPROVE', 'Approve applications', 2),
    
    -- Assessment permissions
    ('ASSESS_CREATE', 'Create assessments', 3),
    ('ASSESS_VIEW', 'View assessments', 3),
    ('ASSESS_UPDATE', 'Update assessments', 3),
    ('ESTIMATE_CREATE', 'Create estimates', 3),
    ('ESTIMATE_APPROVE', 'Approve estimates', 3),
    ('PHOTO_UPLOAD', 'Upload photos', 3),
    
    -- Repair permissions
    ('REPAIR_VIEW', 'View repair tasks', 4),
    ('REPAIR_ASSIGN', 'Assign repair tasks', 4),
    ('REPAIR_UPDATE_STATUS', 'Update repair status', 4),
    ('REPAIR_COMPLETE', 'Mark repair complete', 4),
    ('MATERIAL_REQUEST', 'Request materials', 4),
    ('MATERIAL_APPROVE', 'Approve material requests', 4),
    
    -- Finance permissions
    ('FINANCE_VIEW', 'View financial data', 5),
    ('INVOICE_CREATE', 'Create invoices', 5),
    ('INVOICE_PROCESS', 'Process payments', 5),
    ('BUDGET_VIEW', 'View budgets', 5),
    ('BUDGET_UPDATE', 'Update budgets', 5),
    ('EXPENSE_TRACK', 'Track expenses', 5),
    
    -- User permissions
    ('USER_VIEW', 'View users', 6),
    ('USER_CREATE', 'Create users', 6),
    ('USER_UPDATE', 'Update users', 6),
    ('USER_DELETE', 'Delete users', 6),
    ('ROLE_ASSIGN', 'Assign roles', 6),
    
    -- Organization permissions
    ('ORG_VIEW', 'View organization settings', 7),
    ('ORG_UPDATE', 'Update organization settings', 7),
    ('RULE_CONFIG', 'Configure eligibility rules', 7),
    
    -- Reporting permissions
    ('REPORT_VIEW', 'View reports', 8),
    ('REPORT_EXPORT', 'Export reports', 8),
    ('REPORT_SCHEDULE', 'Schedule reports', 8),
    
    -- Document permissions
    ('DOC_UPLOAD', 'Upload documents', 9),
    ('DOC_VIEW', 'View documents', 9),
    ('DOC_DELETE', 'Delete documents', 9),
    
    -- Communication permissions
    ('COMM_VIEW', 'View communications', 10),
    ('COMM_SEND', 'Send communications', 10),
    ('COMM_BROADCAST', 'Broadcast to org', 10);

-- Role-permission assignments
CREATE TABLE role_permissions (
    id SERIAL PRIMARY KEY,
    role_id INTEGER REFERENCES roles(id) ON DELETE CASCADE,
    permission_id INTEGER REFERENCES permissions(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(role_id, permission_id)
);

-- Assign permissions to roles (comprehensive mapping)
-- ADMIN gets everything
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.role_code = 'ADMIN';

-- PROJECT_MANAGER permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.role_code = 'PROJECT_MANAGER'
    AND p.permission_code IN (
        'CASE_VIEW', 'CASE_UPDATE', 'CASE_ASSIGN', 'CASE_STATUS_UPDATE',
        'ASSESS_VIEW', 'ESTIMATE_APPROVE',
        'REPAIR_VIEW', 'REPAIR_ASSIGN', 'REPAIR_UPDATE_STATUS', 'MATERIAL_APPROVE',
        'FINANCE_VIEW', 'BUDGET_VIEW', 'BUDGET_UPDATE',
        'REPORT_VIEW', 'REPORT_EXPORT',
        'DOC_VIEW', 'COMM_VIEW', 'COMM_SEND'
    );

-- BURSAR permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.role_code = 'BURSAR'
    AND p.permission_code IN (
        'CASE_VIEW', 'FINANCE_VIEW', 'INVOICE_CREATE', 'INVOICE_PROCESS',
        'BUDGET_VIEW', 'EXPENSE_TRACK', 'REPORT_VIEW', 'REPORT_EXPORT'
    );

-- CASEWORKER permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.role_code = 'CASEWORKER'
    AND p.permission_code IN (
        'CASE_VIEW', 'CASE_UPDATE', 'CASE_STATUS_UPDATE',
        'APP_VIEW_ALL', 'APP_REVIEW',
        'ASSESS_VIEW',
        'DOC_VIEW', 'DOC_UPLOAD',
        'COMM_VIEW', 'COMM_SEND'
    );

-- ASSESSOR permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.role_code = 'ASSESSOR'
    AND p.permission_code IN (
        'CASE_VIEW', 'ASSESS_CREATE', 'ASSESS_VIEW', 'ASSESS_UPDATE',
        'ESTIMATE_CREATE', 'PHOTO_UPLOAD', 'DOC_VIEW', 'DOC_UPLOAD'
    );

-- CREW_LEAD permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.role_code = 'CREW_LEAD'
    AND p.permission_code IN (
        'CASE_VIEW', 'REPAIR_VIEW', 'REPAIR_ASSIGN', 'REPAIR_UPDATE_STATUS',
        'REPAIR_COMPLETE', 'MATERIAL_REQUEST', 'DOC_VIEW', 'COMM_VIEW'
    );

-- SUBCONTRACTOR permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.role_code = 'SUBCONTRACTOR'
    AND p.permission_code IN (
        'CASE_VIEW', 'REPAIR_VIEW', 'REPAIR_UPDATE_STATUS',
        'ESTIMATE_CREATE', 'DOC_VIEW', 'COMM_VIEW'
    );

-- ENVOY permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.role_code = 'ENVOY'
    AND p.permission_code IN (
        'CASE_VIEW', 'CASE_UPDATE', 'COMM_VIEW', 'COMM_SEND',
        'DOC_VIEW', 'DOC_UPLOAD'
    );

-- CREW_MEMBER permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.role_code = 'CREW_MEMBER'
    AND p.permission_code IN ('REPAIR_VIEW', 'REPAIR_UPDATE_STATUS', 'DOC_VIEW');

-- REQUESTOR permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.role_code = 'REQUESTOR'
    AND p.permission_code IN ('APP_SUBMIT', 'APP_VIEW_OWN', 'DOC_UPLOAD');

-- VOLUNTEER permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.role_code = 'VOLUNTEER'
    AND p.permission_code IN ('REPAIR_VIEW', 'DOC_VIEW');

-- =====================================================
-- USERS & ORGANIZATION ASSIGNMENTS
-- =====================================================

-- Users table (extends beyond organization_users)
CREATE TABLE system_users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(200) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    avatar_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP,
    last_ip INET,
    password_hash VARCHAR(255),
    reset_token VARCHAR(255),
    reset_token_expires TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES system_users(id),
    updated_by INTEGER REFERENCES system_users(id)
);

-- User role assignments (can have multiple roles across organizations)
CREATE TABLE user_role_assignments (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES system_users(id) ON DELETE CASCADE,
    organization_id INTEGER REFERENCES coalition_organizations(id) ON DELETE CASCADE,
    role_id INTEGER REFERENCES roles(id),
    assigned_by INTEGER REFERENCES system_users(id),
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP, -- For temporary assignments (e.g., volunteers)
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    UNIQUE(user_id, organization_id, role_id)
);

-- =====================================================
-- CASE MANAGEMENT WORKFLOW
-- =====================================================

-- Case status definitions
CREATE TABLE case_statuses (
    id SERIAL PRIMARY KEY,
    status_code VARCHAR(50) UNIQUE NOT NULL,
    status_name VARCHAR(100) NOT NULL,
    status_sequence INTEGER NOT NULL, -- For workflow order
    is_terminal BOOLEAN DEFAULT FALSE,
    allowed_roles_for_transition TEXT[], -- Which roles can move to this status
    description TEXT
);

INSERT INTO case_statuses (status_code, status_name, status_sequence, allowed_roles_for_transition, description) VALUES
    ('PENDING_REVIEW', 'Pending Review', 1, ARRAY['ADMIN', 'CASEWORKER'], 'New application awaiting initial review'),
    ('INTAKE_COMPLETE', 'Intake Complete', 2, ARRAY['ADMIN', 'CASEWORKER'], 'Initial eligibility determined'),
    ('ASSESSMENT_SCHEDULED', 'Assessment Scheduled', 3, ARRAY['ADMIN', 'ASSESSOR', 'CASEWORKER'], 'Home visit scheduled'),
    ('ASSESSMENT_COMPLETE', 'Assessment Complete', 4, ARRAY['ADMIN', 'ASSESSOR', 'CASEWORKER'], 'Home assessment finished, estimate created'),
    ('APPROVED', 'Approved', 5, ARRAY['ADMIN', 'PROJECT_MANAGER', 'CASEWORKER'], 'Case approved for repair work'),
    ('DENIED', 'Denied', 99, ARRAY['ADMIN', 'CASEWORKER'], 'Application denied - terminal'),
    ('ASSIGNED_TO_CREW', 'Assigned to Crew', 6, ARRAY['ADMIN', 'PROJECT_MANAGER', 'CREW_LEAD'], 'Repair team assigned'),
    ('IN_PROGRESS', 'In Progress', 7, ARRAY['CREW_LEAD', 'CREW_MEMBER', 'SUBCONTRACTOR'], 'Repair work underway'),
    ('QUALITY_CHECK', 'Quality Check', 8, ARRAY['CREW_LEAD', 'PROJECT_MANAGER'], 'Final inspection before completion'),
    ('COMPLETED', 'Completed', 10, ARRAY['ADMIN', 'PROJECT_MANAGER', 'CASEWORKER'], 'All work completed - terminal'),
    ('ON_HOLD', 'On Hold', 50, ARRAY['ADMIN', 'PROJECT_MANAGER', 'CASEWORKER'], 'Temporary hold - not terminal');

-- Extended case information
CREATE TABLE cases (
    id SERIAL PRIMARY KEY,
    submission_id INTEGER REFERENCES intake_submissions(id) ON DELETE CASCADE,
    case_number VARCHAR(50) UNIQUE NOT NULL,
    status_id INTEGER REFERENCES case_statuses(id),
    
    -- Assignment tracking
    assigned_caseworker_id INTEGER REFERENCES system_users(id),
    assigned_project_manager_id INTEGER REFERENCES system_users(id),
    assigned_assessor_id INTEGER REFERENCES system_users(id),
    
    -- Dates
    intake_completed_at TIMESTAMP,
    assessment_scheduled_at TIMESTAMP,
    assessment_completed_at TIMESTAMP,
    approved_at TIMESTAMP,
    work_started_at TIMESTAMP,
    work_completed_at TIMESTAMP,
    
    -- Metadata
    total_budget DECIMAL(12,2),
    total_actual_cost DECIMAL(12,2),
    notes TEXT,
    internal_notes TEXT, -- Staff-only notes
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES system_users(id),
    updated_by INTEGER REFERENCES system_users(id)
);

-- Generate case number function
CREATE OR REPLACE FUNCTION generate_case_number()
RETURNS TRIGGER AS $$
BEGIN
    NEW.case_number := 'ARCHR-' || TO_CHAR(NEW.created_at, 'YYYY') || '-' || LPAD(NEW.id::TEXT, 6, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_case_number
    BEFORE INSERT ON cases
    FOR EACH ROW
    EXECUTE PROCEDURE generate_case_number();

-- Case status history (audit trail)
CREATE TABLE case_status_history (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    from_status_id INTEGER REFERENCES case_statuses(id),
    to_status_id INTEGER REFERENCES case_statuses(id),
    changed_by INTEGER REFERENCES system_users(id),
    notes TEXT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- ASSESSMENT & ESTIMATES
-- =====================================================

-- Property assessment records
CREATE TABLE property_assessments (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    assessor_id INTEGER REFERENCES system_users(id),
    assessment_date DATE NOT NULL,
    
    -- Assessment findings
    property_condition TEXT,
    structural_issues TEXT,
    electrical_issues TEXT,
    plumbing_issues TEXT,
    hvac_issues TEXT,
    roofing_issues TEXT,
    accessibility_needs TEXT,
    safety_hazards TEXT,
    photos JSONB, -- Array of photo URLs
    
    -- Measurements
    square_footage DECIMAL(10,2),
    num_bedrooms INTEGER,
    num_bathrooms INTEGER,
    
    -- Recommendations
    recommended_repairs TEXT,
    priority_repairs TEXT,
    estimated_hours DECIMAL(10,2),
    estimated_material_cost DECIMAL(12,2),
    estimated_labor_cost DECIMAL(12,2),
    total_estimate DECIMAL(12,2),
    
    assessment_notes TEXT,
    assigned_at TIMESTAMP, -- set when the assessment is assigned to an assessor; metric-tracking.sql reads this
    assessment_completed_at TIMESTAMP, -- set when the assessor marks the visit complete; metric-tracking.sql filters on this
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Repair estimates (detailed line items)
CREATE TABLE repair_estimates (
    id SERIAL PRIMARY KEY,
    assessment_id INTEGER REFERENCES property_assessments(id) ON DELETE CASCADE,
    repair_category_id INTEGER REFERENCES repair_categories(id),
    description TEXT NOT NULL,
    quantity DECIMAL(10,2),
    unit_cost DECIMAL(10,2),
    material_cost DECIMAL(12,2),
    labor_hours DECIMAL(10,2),
    labor_rate DECIMAL(10,2),
    labor_cost DECIMAL(12,2),
    total_cost DECIMAL(12,2),
    is_approved BOOLEAN DEFAULT FALSE,
    approved_by INTEGER REFERENCES system_users(id),
    approved_at TIMESTAMP,
    notes TEXT
);

-- =====================================================
-- PROJECT & TASK MANAGEMENT
-- =====================================================

-- Work orders / projects
CREATE TABLE work_orders (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    work_order_number VARCHAR(50) UNIQUE NOT NULL,
    project_manager_id INTEGER REFERENCES system_users(id),
    crew_lead_id INTEGER REFERENCES system_users(id),
    
    -- Scheduling
    scheduled_start_date DATE,
    scheduled_end_date DATE,
    actual_start_date DATE,
    actual_end_date DATE,
    
    -- Status
    status VARCHAR(50) DEFAULT 'planned', -- planned, in_progress, on_hold, completed, cancelled
    
    -- Budget
    approved_budget DECIMAL(12,2),
    current_cost DECIMAL(12,2),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tasks assigned to crew members and subcontractors
CREATE TABLE work_tasks (
    id SERIAL PRIMARY KEY,
    work_order_id INTEGER REFERENCES work_orders(id) ON DELETE CASCADE,
    assigned_to_id INTEGER REFERENCES system_users(id), -- Can be crew member or subcontractor
    task_type VARCHAR(50), -- repair, inspection, material_delivery, etc.
    description TEXT,
    
    -- Repair categorization
    repair_category_id INTEGER REFERENCES repair_categories(id),
    estimate_id INTEGER REFERENCES repair_estimates(id),
    
    -- Status tracking
    status VARCHAR(50) DEFAULT 'assigned', -- assigned, in_progress, completed, blocked, cancelled
    priority INTEGER DEFAULT 1, -- 1=highest
    
    -- Timing
    estimated_hours DECIMAL(10,2),
    actual_hours DECIMAL(10,2),
    due_date DATE,
    completed_at TIMESTAMP,
    
    -- Notes
    instructions TEXT,
    completion_notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES system_users(id)
);

-- Task status history
CREATE TABLE task_status_history (
    id SERIAL PRIMARY KEY,
    task_id INTEGER REFERENCES work_tasks(id) ON DELETE CASCADE,
    from_status VARCHAR(50),
    to_status VARCHAR(50),
    changed_by INTEGER REFERENCES system_users(id),
    notes TEXT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Material requests
CREATE TABLE material_requests (
    id SERIAL PRIMARY KEY,
    task_id INTEGER REFERENCES work_tasks(id) ON DELETE CASCADE,
    requested_by INTEGER REFERENCES system_users(id),
    material_name VARCHAR(200),
    quantity DECIMAL(10,2),
    unit VARCHAR(20),
    estimated_cost DECIMAL(12,2),
    supplier VARCHAR(200),
    status VARCHAR(50) DEFAULT 'pending', -- pending, approved, ordered, received
    approved_by INTEGER REFERENCES system_users(id),
    approved_at TIMESTAMP,
    order_date DATE,
    received_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- FINANCIAL TRACKING
-- =====================================================

-- Funding sources
CREATE TABLE funding_sources (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER REFERENCES coalition_organizations(id) ON DELETE CASCADE,
    source_name VARCHAR(200) NOT NULL,
    source_type VARCHAR(50), -- grant, donation, government, partner, other
    total_amount DECIMAL(12,2),
    remaining_amount DECIMAL(12,2),
    start_date DATE,
    end_date DATE,
    restrictions TEXT,
    contact_name VARCHAR(200),
    contact_email VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Case funding allocation
CREATE TABLE case_funding (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    funding_source_id INTEGER REFERENCES funding_sources(id),
    allocated_amount DECIMAL(12,2),
    spent_amount DECIMAL(12,2) DEFAULT 0,
    allocated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    allocated_by INTEGER REFERENCES system_users(id),
    notes TEXT
);

-- Invoices and payments
CREATE TABLE invoices (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    vendor_name VARCHAR(200),
    vendor_type VARCHAR(50), -- subcontractor, supplier, etc.
    invoice_date DATE,
    due_date DATE,
    paid_date DATE,
    subtotal DECIMAL(12,2),
    tax DECIMAL(12,2),
    total_amount DECIMAL(12,2),
    status VARCHAR(50) DEFAULT 'pending', -- pending, approved, paid, rejected
    approved_by INTEGER REFERENCES system_users(id),
    approved_at TIMESTAMP,
    paid_by INTEGER REFERENCES system_users(id),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Invoice line items
CREATE TABLE invoice_line_items (
    id SERIAL PRIMARY KEY,
    invoice_id INTEGER REFERENCES invoices(id) ON DELETE CASCADE,
    task_id INTEGER REFERENCES work_tasks(id),
    description TEXT,
    quantity DECIMAL(10,2),
    unit_price DECIMAL(12,2),
    total DECIMAL(12,2)
);

-- =====================================================
-- COMMUNICATION LOGGING
-- =====================================================

-- Track all communications related to a case
CREATE TABLE case_communications (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    from_user_id INTEGER REFERENCES system_users(id),
    to_user_id INTEGER REFERENCES system_users(id),
    to_applicant BOOLEAN DEFAULT FALSE,
    communication_type VARCHAR(50), -- email, phone, sms, in_person, portal_message
    subject VARCHAR(500),
    body TEXT,
    attachments JSONB, -- Array of attachment URLs
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    notes TEXT
);

-- =====================================================
-- VOLUNTEER SPECIFIC TRACKING
-- =====================================================

CREATE TABLE volunteer_hours (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES system_users(id),
    work_order_id INTEGER REFERENCES work_orders(id),
    date DATE NOT NULL,
    hours DECIMAL(5,2),
    task_description TEXT,
    verified_by INTEGER REFERENCES system_users(id), -- Crew lead or project manager
    verified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- volunteer_skills is defined in volunteer-gamification.sql with a richer
-- schema (FK to a skills lookup, endorsements, uniqueness). Kept there as
-- the single source of truth.

-- =====================================================
-- FUNCTIONS AND TRIGGERS
-- =====================================================

-- Function to check user permissions
CREATE OR REPLACE FUNCTION user_has_permission(
    p_user_id INTEGER,
    p_permission_code VARCHAR,
    p_organization_id INTEGER DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    v_has_permission BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1
        FROM user_role_assignments ura
        JOIN role_permissions rp ON ura.role_id = rp.role_id
        JOIN permissions p ON rp.permission_id = p.id
        WHERE ura.user_id = p_user_id
            AND p.permission_code = p_permission_code
            AND ura.is_active = true
            AND (p_organization_id IS NULL OR ura.organization_id = p_organization_id)
            AND (ura.expires_at IS NULL OR ura.expires_at > CURRENT_TIMESTAMP)
    ) INTO v_has_permission;
    
    RETURN v_has_permission;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get user's role at an organization
CREATE OR REPLACE FUNCTION get_user_role_at_org(
    p_user_id INTEGER,
    p_organization_id INTEGER
)
RETURNS TABLE(
    role_code VARCHAR,
    role_level INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.role_code, r.role_level
    FROM user_role_assignments ura
    JOIN roles r ON ura.role_id = r.id
    WHERE ura.user_id = p_user_id
        AND ura.organization_id = p_organization_id
        AND ura.is_active = true
        AND (ura.expires_at IS NULL OR ura.expires_at > CURRENT_TIMESTAMP)
    ORDER BY r.role_level DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update case updated_at
CREATE OR REPLACE FUNCTION update_case_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_case_timestamp
    BEFORE UPDATE ON cases
    FOR EACH ROW
    EXECUTE PROCEDURE update_case_timestamp();

-- =====================================================
-- VIEWS FOR DASHBOARDS
-- =====================================================

-- Case assignment dashboard
CREATE VIEW case_assignment_dashboard AS
SELECT 
    c.id as case_id,
    c.case_number,
    cs.status_name as case_status,
    s.applicant_first_name,
    s.applicant_last_name,
    s.home_city,
    u1.full_name as caseworker_name,
    u2.full_name as project_manager_name,
    u3.full_name as assessor_name,
    c.approved_at,
    c.total_budget,
    c.total_actual_cost,
    CASE 
        WHEN c.work_completed_at IS NOT NULL THEN 'Completed'
        WHEN c.work_started_at IS NOT NULL THEN 'In Progress'
        WHEN c.approved_at IS NOT NULL THEN 'Approved'
        ELSE 'In Pipeline'
    END as project_phase
FROM cases c
JOIN case_statuses cs ON c.status_id = cs.id
JOIN intake_submissions s ON c.submission_id = s.id
LEFT JOIN system_users u1 ON c.assigned_caseworker_id = u1.id
LEFT JOIN system_users u2 ON c.assigned_project_manager_id = u2.id
LEFT JOIN system_users u3 ON c.assigned_assessor_id = u3.id;

-- Organization workload view
CREATE VIEW organization_workload AS
SELECT 
    o.id as organization_id,
    o.organization_name,
    COUNT(DISTINCT c.id) as total_cases,
    COUNT(DISTINCT CASE WHEN cs.status_sequence < 10 THEN c.id END) as active_cases,
    COUNT(DISTINCT CASE WHEN cs.status_code = 'COMPLETED' THEN c.id END) as completed_cases,
    COUNT(DISTINCT wo.id) as active_work_orders,
    COUNT(DISTINCT wt.id) as pending_tasks,
    SUM(CASE WHEN wt.status = 'in_progress' THEN 1 ELSE 0 END) as tasks_in_progress,
    SUM(CASE WHEN vh.id IS NOT NULL THEN vh.hours ELSE 0 END) as volunteer_hours_ytd
FROM coalition_organizations o
LEFT JOIN cases c ON EXISTS (
    SELECT 1 FROM intake_submissions s 
    WHERE s.id = c.submission_id 
    AND s.assigned_organization = o.organization_name
)
LEFT JOIN case_statuses cs ON c.status_id = cs.id
LEFT JOIN work_orders wo ON c.id = wo.case_id
LEFT JOIN work_tasks wt ON wo.id = wt.work_order_id
LEFT JOIN volunteer_hours vh ON vh.work_order_id = wo.id AND vh.date >= DATE_TRUNC('year', CURRENT_DATE)
GROUP BY o.id, o.organization_name;

-- Role-based access control policies (Row Level Security examples)
-- Note: These would be implemented based on specific database system (PostgreSQL RLS)

/*
-- Example RLS policy for cases table
CREATE POLICY case_access_policy ON cases
    USING (
        user_has_permission(current_user_id(), 'CASE_VIEW', get_user_org()) 
        OR assigned_caseworker_id = current_user_id()
        OR assigned_project_manager_id = current_user_id()
    );
*/
-- END sql/role-based-access.sql

-- ----------------------------------------------------------------
-- BEGIN sql/anchor-registration.sql
-- ----------------------------------------------------------------
-- =====================================================
-- ANCHOR REGISTRATION
-- Every application gets recorded here, regardless of eligibility
-- Used for metric tracking and historical analysis
-- =====================================================

CREATE TABLE application_anchor (
    id SERIAL PRIMARY KEY,
    submission_id INTEGER REFERENCES intake_submissions(id) UNIQUE,
    
    -- Core identifiers
    anchor_id VARCHAR(50) UNIQUE NOT NULL, -- Format: ANCHOR-YYYY-XXXXX
    case_number VARCHAR(50), -- Only populated if case created
    
    -- Submission metadata
    submitted_at TIMESTAMP NOT NULL,
    submitted_from_ip INET,
    
    -- Eligibility outcome
    is_eligible BOOLEAN,
    disqualification_reasons TEXT[],
    eligibility_score INTEGER, -- 0-100
    
    -- Tracking
    current_status VARCHAR(50), -- eligible, ineligible, assigned, in_progress, completed
    assigned_organization_id INTEGER,
    assigned_at TIMESTAMP,
    
    -- Metric buckets (for fast aggregation)
    income_bucket VARCHAR(50),
    county_bucket VARCHAR(50),
    repair_type_bucket VARCHAR(50),
    helene_related BOOLEAN,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Generate anchor ID
CREATE OR REPLACE FUNCTION generate_anchor_id()
RETURNS TRIGGER AS $$
BEGIN
    NEW.anchor_id := 'ANCHOR-' || TO_CHAR(NEW.created_at, 'YYYY') || '-' || LPAD(NEW.id::TEXT, 7, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_anchor_id
    BEFORE INSERT ON application_anchor
    FOR EACH ROW
    EXECUTE PROCEDURE generate_anchor_id();

-- Registration function
CREATE OR REPLACE FUNCTION register_application_anchor(
    p_submission_id INTEGER,
    p_eligibility_result JSONB
)
RETURNS VOID AS $$
DECLARE
    v_submission RECORD;
BEGIN
    SELECT * INTO v_submission FROM intake_submissions WHERE id = p_submission_id;
    
    INSERT INTO application_anchor (
        submission_id,
        submitted_at,
        submitted_from_ip,
        is_eligible,
        disqualification_reasons,
        eligibility_score,
        current_status,
        income_bucket,
        county_bucket,
        repair_type_bucket,
        helene_related
    ) VALUES (
        p_submission_id,
        v_submission.submitted_at,
        v_submission.ip_address,
        (p_eligibility_result->>'is_eligible')::BOOLEAN,
        ARRAY(SELECT jsonb_array_elements_text(p_eligibility_result->'disqualifiers')),
        (p_eligibility_result->>'eligibility_score')::INTEGER,
        CASE WHEN (p_eligibility_result->>'is_eligible')::BOOLEAN THEN 'eligible' ELSE 'ineligible' END,
        get_income_bucket(v_submission.gross_annual_income),
        get_county_bucket(v_submission.home_city, v_submission.home_zip),
        get_primary_repair_type(p_submission_id),
        v_submission.helene_related
    );
END;
$$ LANGUAGE plpgsql;

-- Helper bucket functions
CREATE OR REPLACE FUNCTION get_income_bucket(p_income DECIMAL)
RETURNS VARCHAR AS $$
BEGIN
    RETURN CASE 
        WHEN p_income IS NULL OR p_income = 0 THEN '$0'
        WHEN p_income <= 15000 THEN '$1-15k'
        WHEN p_income <= 30000 THEN '$15k-30k'
        WHEN p_income <= 50000 THEN '$30k-50k'
        WHEN p_income <= 75000 THEN '$50k-75k'
        ELSE '$75k+'
    END;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_county_bucket(p_city VARCHAR, p_zip VARCHAR)
RETURNS VARCHAR AS $$
BEGIN
    IF p_zip IN ('28801','28803','28804','28805','28806') OR p_city ILIKE '%Asheville%' THEN
        RETURN 'Buncombe';
    ELSIF p_city ILIKE '%Marshall%' OR p_city ILIKE '%Mars Hill%' THEN
        RETURN 'Madison';
    ELSIF p_city ILIKE '%Hendersonville%' THEN
        RETURN 'Henderson';
    ELSE
        RETURN 'Other';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_primary_repair_type(p_submission_id INTEGER)
RETURNS VARCHAR AS $$
DECLARE
    v_primary_category VARCHAR;
BEGIN
    SELECT rc.category_code INTO v_primary_category
    FROM submission_repair_categories src
    JOIN repair_categories rc ON src.category_id = rc.id
    WHERE src.submission_id = p_submission_id
    ORDER BY src.id ASC
    LIMIT 1;
    
    RETURN COALESCE(v_primary_category, 'unknown');
END;
$$ LANGUAGE plpgsql;
-- END sql/anchor-registration.sql

-- ----------------------------------------------------------------
-- BEGIN sql/volunteer-gamification.sql
-- ----------------------------------------------------------------
-- =====================================================
-- VOLUNTEER GAMIFICATION SCHEMA
-- Extends existing role-based system
-- =====================================================

-- Volunteer profile (extends system_users)
CREATE TABLE volunteer_profiles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES system_users(id) UNIQUE,
    
    -- Gamification stats
    level INTEGER DEFAULT 1,
    xp INTEGER DEFAULT 0,
    xp_to_next_level INTEGER DEFAULT 100,
    reputation_score INTEGER DEFAULT 0,
    reputation_tier INTEGER DEFAULT 0,
    
    -- Engagement metrics
    total_quests_completed INTEGER DEFAULT 0,
    total_hours_logged DECIMAL(10,2) DEFAULT 0,
    consecutive_weeks_active INTEGER DEFAULT 0,
    last_active_at TIMESTAMP,
    
    -- Settings
    push_notifications_enabled BOOLEAN DEFAULT TRUE,
    email_digest_enabled BOOLEAN DEFAULT TRUE,
    weekly_quest_limit INTEGER DEFAULT 5,
    
    -- Avatar customization
    avatar_choice VARCHAR(50) DEFAULT 'default',
    title_equipped VARCHAR(100), -- "Roof Ranger", "Tool Master", etc.
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Quests table (tasks available to volunteers)
CREATE TABLE quests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quest_number VARCHAR(20) UNIQUE, -- Human-readable: Q-2024-001
    
    -- Core fields
    title VARCHAR(200) NOT NULL,
    description TEXT,
    quest_type VARCHAR(50) NOT NULL, -- repair, delivery, cleanup, training, social
    difficulty INTEGER CHECK (difficulty BETWEEN 1 AND 5),
    
    -- Rewards
    xp_reward INTEGER DEFAULT 10,
    reputation_reward INTEGER DEFAULT 5,
    coin_reward INTEGER DEFAULT 0, -- For future marketplace
    
    -- Requirements
    required_level INTEGER DEFAULT 1,
    required_skills TEXT[],
    required_certifications TEXT[],
    
    -- Capacity
    max_volunteers INTEGER DEFAULT 1,
    current_volunteers INTEGER DEFAULT 0,
    
    -- Location
    location_address TEXT,
    location_lat DECIMAL(10,8),
    location_lng DECIMAL(11,8),
    radius_miles INTEGER DEFAULT 25,
    
    -- Scheduling
    estimated_hours DECIMAL(5,2),
    flexible_timing BOOLEAN DEFAULT TRUE,
    scheduled_start TIMESTAMP,
    scheduled_end TIMESTAMP,
    
    -- Relationships
    parent_quest_id UUID REFERENCES quests(id), -- For epic quests
    case_id INTEGER REFERENCES cases(id),
    work_task_id INTEGER REFERENCES work_tasks(id),
    
    -- Metadata
    quest_giver_id INTEGER REFERENCES system_users(id),
    instructions TEXT,
    safety_notes TEXT,
    materials_needed TEXT[],
    
    -- Status
    status VARCHAR(20) DEFAULT 'available', -- available, in_progress, completed, cancelled, expired
    expires_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_quests_status_expires ON quests (status, expires_at);
CREATE INDEX idx_quests_location       ON quests (location_lat, location_lng);
CREATE INDEX idx_quests_skills         ON quests USING GIN (required_skills);

-- Quest assignments (volunteer claiming)
CREATE TABLE quest_assignments (
    id SERIAL PRIMARY KEY,
    quest_id UUID REFERENCES quests(id) ON DELETE CASCADE,
    volunteer_id INTEGER REFERENCES system_users(id),
    
    -- Status tracking
    status VARCHAR(20) DEFAULT 'assigned', -- assigned, in_progress, completed, abandoned, expired
    
    -- Timing
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    
    -- Hours
    hours_logged DECIMAL(5,2),
    hours_verified BOOLEAN DEFAULT FALSE,
    verified_by INTEGER REFERENCES system_users(id),
    verified_at TIMESTAMP,
    
    -- Documentation
    before_photo_urls TEXT[],
    during_photo_urls TEXT[],
    after_photo_urls TEXT[],
    volunteer_notes TEXT,
    
    -- Rewards granted
    xp_awarded INTEGER,
    reputation_awarded INTEGER,
    rewards_claimed BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(quest_id, volunteer_id)
);

CREATE INDEX idx_assignments_volunteer ON quest_assignments (volunteer_id, status);

-- Skills library (controlled vocabulary)
CREATE TABLE skills (
    id SERIAL PRIMARY KEY,
    skill_code VARCHAR(50) UNIQUE NOT NULL,
    skill_name VARCHAR(100) NOT NULL,
    category VARCHAR(50), -- construction, cleanup, admin, social
    description TEXT,
    requires_training BOOLEAN DEFAULT FALSE,
    training_resource_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Pre-populate common skills
INSERT INTO skills (skill_code, skill_name, category, requires_training) VALUES
    ('LADDER_SAFE', 'Ladder Safety', 'construction', true),
    ('ROOF_WORK', 'Roof Work', 'construction', true),
    ('DEMOLITION', 'Demolition', 'construction', false),
    ('CLEANUP', 'Debris Cleanup', 'cleanup', false),
    ('MATERIAL_TRANSPORT', 'Material Transport', 'logistics', false),
    ('PHOTO_DOC', 'Photo Documentation', 'admin', false),
    ('CLIENT_COMM', 'Client Communication', 'social', false),
    ('TOOL_MAINT', 'Tool Maintenance', 'construction', false);

-- Volunteer skills (junction table)
CREATE TABLE volunteer_skills (
    id SERIAL PRIMARY KEY,
    volunteer_id INTEGER REFERENCES system_users(id) ON DELETE CASCADE,
    skill_id INTEGER REFERENCES skills(id) ON DELETE CASCADE,
    proficiency_level INTEGER DEFAULT 1 CHECK (proficiency_level BETWEEN 1 AND 5),
    endorsed_by INTEGER REFERENCES system_users(id),
    endorsed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(volunteer_id, skill_id)
);

-- Badges/achievements
CREATE TABLE badges (
    id SERIAL PRIMARY KEY,
    badge_code VARCHAR(50) UNIQUE NOT NULL,
    badge_name VARCHAR(100) NOT NULL,
    description TEXT,
    icon_url VARCHAR(500),
    criteria_type VARCHAR(50), -- quests_completed, hours_logged, skill_mastery, etc.
    criteria_value INTEGER,
    xp_bonus INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO badges (badge_code, badge_name, description, criteria_type, criteria_value, xp_bonus) VALUES
    ('FIRST_QUEST', 'First Quest', 'Complete your first volunteer task', 'quests_completed', 1, 25),
    ('ROOF_RANGER', 'Roof Ranger', 'Complete 5 roofing tasks', 'skill_quests', 5, 100),
    ('HUNDRED_HOURS', 'Century Club', 'Log 100 volunteer hours', 'hours_logged', 100, 200),
    ('HELPER_HEART', 'Helper Heart', 'Receive 10 positive beneficiary ratings', 'positive_ratings', 10, 50),
    ('MENTOR', 'Community Mentor', 'Help 5 new volunteers complete their first quest', 'mentored_count', 5, 150);

-- Volunteer badge assignments
CREATE TABLE volunteer_badges (
    id SERIAL PRIMARY KEY,
    volunteer_id INTEGER REFERENCES system_users(id) ON DELETE CASCADE,
    badge_id INTEGER REFERENCES badges(id) ON DELETE CASCADE,
    awarded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    awarded_by INTEGER REFERENCES system_users(id), -- system or admin
    UNIQUE(volunteer_id, badge_id)
);

-- Content library (blog posts, newsletters, updates)
CREATE TABLE volunteer_content (
    id SERIAL PRIMARY KEY,
    content_id VARCHAR(50) UNIQUE NOT NULL, -- e.g., FLD-2024-001
    title VARCHAR(300) NOT NULL,
    content TEXT, -- Markdown format
    content_html TEXT, -- Rendered HTML
    
    -- Metadata (YAML frontmatter equivalent)
    yaml_frontmatter JSONB DEFAULT '{}'::jsonb,
    
    -- Categorization
    content_type VARCHAR(50) NOT NULL, -- field_notes, spotlight, training, alert, impact_story
    tags TEXT[],
    
    -- Authorship
    author_id INTEGER REFERENCES system_users(id),
    author_name VARCHAR(100),
    reviewed_by INTEGER REFERENCES system_users(id),
    reviewed_at TIMESTAMP,
    
    -- Engagement
    view_count INTEGER DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    
    -- Gamification
    read_xp_reward INTEGER DEFAULT 10,
    
    -- Publishing
    status VARCHAR(20) DEFAULT 'draft', -- draft, published, archived
    published_at TIMESTAMP,
    pinned_until TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_content_published ON volunteer_content (status, published_at DESC);
CREATE INDEX idx_content_tags      ON volunteer_content USING GIN (tags);

-- Content read tracking (for XP rewards)
CREATE TABLE content_reads (
    id SERIAL PRIMARY KEY,
    content_id INTEGER REFERENCES volunteer_content(id) ON DELETE CASCADE,
    volunteer_id INTEGER REFERENCES system_users(id) ON DELETE CASCADE,
    read_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    xp_awarded BOOLEAN DEFAULT FALSE,
    UNIQUE(content_id, volunteer_id)
);

-- Weekly digests (auto-generated or manual)
CREATE TABLE weekly_digests (
    id SERIAL PRIMARY KEY,
    digest_week DATE NOT NULL, -- Monday of that week
    title VARCHAR(200),
    summary TEXT,
    featured_content_ids INTEGER[], -- References to volunteer_content
    sent_at TIMESTAMP,
    created_by INTEGER REFERENCES system_users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(digest_week)
);

-- Beneficiary feedback (extends earlier table)
CREATE TABLE beneficiary_feedback (
    id SERIAL PRIMARY KEY,
    quest_id UUID REFERENCES quests(id),
    volunteer_id INTEGER REFERENCES system_users(id),
    beneficiary_id INTEGER REFERENCES intake_submissions(id),
    
    -- Ratings
    quality_rating INTEGER CHECK (quality_rating BETWEEN 1 AND 5),
    kindness_rating INTEGER CHECK (kindness_rating BETWEEN 1 AND 5),
    would_recommend BOOLEAN,
    
    -- Text
    comments TEXT,
    thank_you_note TEXT,
    
    -- Photo evidence
    photo_urls TEXT[],
    
    -- Impact
    reputation_delta INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_feedback_volunteer ON beneficiary_feedback (volunteer_id, created_at DESC);

-- Function to award XP and check level-ups
CREATE OR REPLACE FUNCTION award_quest_completion(
    p_assignment_id INTEGER,
    p_hours_logged DECIMAL,
    p_photos TEXT[]
)
RETURNS JSONB AS $$
DECLARE
    v_assignment RECORD;
    v_quest RECORD;
    v_volunteer RECORD;
    v_new_xp INTEGER;
    v_new_level INTEGER;
    v_xp_needed INTEGER;
    v_new_reputation INTEGER;
    v_new_total_hours DECIMAL;
BEGIN
    -- Get assignment and quest details
    SELECT * INTO v_assignment FROM quest_assignments WHERE id = p_assignment_id;
    SELECT * INTO v_quest FROM quests WHERE id = v_assignment.quest_id;
    SELECT * INTO v_volunteer FROM volunteer_profiles WHERE user_id = v_assignment.volunteer_id;
    
    -- Update assignment
    UPDATE quest_assignments SET
        status = 'completed',
        completed_at = NOW(),
        hours_logged = p_hours_logged,
        before_photo_urls = p_photos[1:array_length(p_photos, 1)/3],
        during_photo_urls = p_photos[array_length(p_photos, 1)/3+1:2*array_length(p_photos, 1)/3],
        after_photo_urls = p_photos[2*array_length(p_photos, 1)/3+1:array_length(p_photos, 1)],
        xp_awarded = v_quest.xp_reward,
        reputation_awarded = v_quest.reputation_reward,
        rewards_claimed = TRUE
    WHERE id = p_assignment_id;
    
    -- Update volunteer stats
    v_new_xp := v_volunteer.xp + v_quest.xp_reward;
    v_new_reputation := v_volunteer.reputation_score + v_quest.reputation_reward;
    v_new_total_hours := v_volunteer.total_hours_logged + p_hours_logged;
    
    -- Check level-up
    v_new_level := v_volunteer.level;
    v_xp_needed := v_volunteer.xp_to_next_level;
    
    WHILE v_new_xp >= v_xp_needed LOOP
        v_new_level := v_new_level + 1;
        v_new_xp := v_new_xp - v_xp_needed;
        v_xp_needed := 100 * v_new_level; -- Simple formula: next level needs 100 * level
    END LOOP;
    
    UPDATE volunteer_profiles SET
        xp = v_new_xp,
        level = v_new_level,
        xp_to_next_level = v_xp_needed,
        reputation_score = v_new_reputation,
        total_hours_logged = v_new_total_hours,
        total_quests_completed = total_quests_completed + 1,
        last_active_at = NOW(),
        updated_at = NOW()
    WHERE user_id = v_assignment.volunteer_id;
    
    -- Check for badge awards (simplified - would call separate function)
    
    RETURN jsonb_build_object(
        'success', true,
        'xp_gained', v_quest.xp_reward,
        'reputation_gained', v_quest.reputation_reward,
        'new_level', v_new_level,
        'level_up', (v_new_level > v_volunteer.level),
        'total_xp', v_new_xp,
        'next_level_xp', v_xp_needed
    );
END;
$$ LANGUAGE plpgsql;
-- END sql/volunteer-gamification.sql

-- ----------------------------------------------------------------
-- BEGIN sql/notifications.sql
-- ----------------------------------------------------------------
-- =====================================================
-- NOTIFICATION SYSTEM
-- Real-time alerts for staff roles
-- =====================================================

-- Notifications table
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES system_users(id),
    notification_type VARCHAR(50) NOT NULL, -- new_application, assignment, deadline, etc.
    title VARCHAR(255) NOT NULL,
    body TEXT,
    
    -- Related entity
    entity_type VARCHAR(50), -- submission, case, work_order
    entity_id INTEGER,
    
    -- Status
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    is_archived BOOLEAN DEFAULT FALSE,
    
    -- Priority
    priority VARCHAR(20) DEFAULT 'normal', -- urgent, high, normal, low
    
    -- Delivery
    email_sent BOOLEAN DEFAULT FALSE,
    sms_sent BOOLEAN DEFAULT FALSE,
    in_app_delivered BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user ON notifications (user_id, is_read, created_at DESC);

-- Trigger notifications on new application
CREATE OR REPLACE FUNCTION trigger_new_application_notifications(p_submission_id INTEGER)
RETURNS VOID AS $$
DECLARE
    v_submission RECORD;
    v_role_codes VARCHAR[] := ARRAY['ADMIN', 'CASEWORKER', 'PROJECT_MANAGER', 'BURSAR'];
    v_role_id INTEGER;
    v_user RECORD;
BEGIN
    SELECT * INTO v_submission FROM intake_submissions WHERE id = p_submission_id;
    
    -- Notify all users with relevant roles
    FOR v_user IN 
        SELECT DISTINCT u.id, u.email, u.full_name, ura.role_id
        FROM system_users u
        JOIN user_role_assignments ura ON u.id = ura.user_id
        JOIN roles r ON ura.role_id = r.id
        WHERE r.role_code = ANY(v_role_codes)
          AND u.is_active = TRUE
    LOOP
        -- In-app notification
        INSERT INTO notifications (
            user_id, 
            notification_type, 
            title, 
            body, 
            entity_type, 
            entity_id,
            priority
        ) VALUES (
            v_user.id,
            'new_application',
            'New Application Submitted',
            'Application #' || v_submission.id || ' from ' || 
            v_submission.applicant_first_name || ' ' || v_submission.applicant_last_name,
            'submission',
            p_submission_id,
            'high'
        );
        
        -- Email notification (batch send, not per-record)
        -- Would be handled by a separate email worker
    END LOOP;
    
    -- Also trigger webhook for external integrations
    PERFORM trigger_webhook('new_application', p_submission_id);
END;
$$ LANGUAGE plpgsql;

-- Get unread notifications for a user
CREATE OR REPLACE FUNCTION get_unread_notifications(p_user_id INTEGER, p_limit INTEGER DEFAULT 20)
RETURNS TABLE(
    notification_id INTEGER,
    notification_type VARCHAR,
    title VARCHAR,
    body TEXT,
    created_at TIMESTAMP,
    priority VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        n.id,
        n.notification_type,
        n.title,
        n.body,
        n.created_at,
        n.priority
    FROM notifications n
    WHERE n.user_id = p_user_id
      AND n.is_read = FALSE
      AND n.is_archived = FALSE
    ORDER BY 
        CASE n.priority 
            WHEN 'urgent' THEN 1
            WHEN 'high' THEN 2
            WHEN 'normal' THEN 3
            ELSE 4
        END,
        n.created_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Mark notification as read
CREATE OR REPLACE FUNCTION mark_notification_read(p_notification_id INTEGER, p_user_id INTEGER)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE notifications 
    SET is_read = TRUE, read_at = CURRENT_TIMESTAMP
    WHERE id = p_notification_id AND user_id = p_user_id;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;
-- END sql/notifications.sql

-- ----------------------------------------------------------------
-- BEGIN sql/email-notification-digest.sql
-- ----------------------------------------------------------------
-- =====================================================
-- EMAIL NOTIFICATION SYSTEM
-- Batch digest for non-urgent notifications
-- =====================================================

-- Email queue table
CREATE TABLE email_queue (
    id SERIAL PRIMARY KEY,
    recipient_email VARCHAR(255),
    recipient_name VARCHAR(200),
    subject VARCHAR(500),
    body TEXT,
    body_html TEXT,
    
    -- Metadata
    notification_type VARCHAR(50),
    related_entity_type VARCHAR(50),
    related_entity_id INTEGER,
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending', -- pending, sent, failed
    attempts INTEGER DEFAULT 0,
    last_attempt_at TIMESTAMP,
    error_message TEXT,
    
    -- Scheduling
    priority INTEGER DEFAULT 5, -- 1=highest
    send_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sent_at TIMESTAMP
);

-- Function to queue new application notification emails
CREATE OR REPLACE FUNCTION queue_new_application_emails(p_submission_id INTEGER)
RETURNS VOID AS $$
DECLARE
    v_submission RECORD;
    v_staff RECORD;
BEGIN
    SELECT * INTO v_submission FROM intake_submissions WHERE id = p_submission_id;
    
    -- Queue emails for each staff role (batched, not immediate)
    FOR v_staff IN 
        SELECT DISTINCT u.email, u.full_name, r.role_code
        FROM system_users u
        JOIN user_role_assignments ura ON u.id = ura.user_id
        JOIN roles r ON ura.role_id = r.id
        WHERE r.role_code IN ('ADMIN', 'CASEWORKER', 'PROJECT_MANAGER')
          AND u.email IS NOT NULL
    LOOP
        INSERT INTO email_queue (
            recipient_email, recipient_name, subject, body,
            notification_type, related_entity_type, related_entity_id,
            priority
        ) VALUES (
            v_staff.email,
            v_staff.full_name,
            '[ARCHR] New Application Ready for Review',
            E'Hello ' || v_staff.full_name || ',\n\n' ||
            'A new application has been submitted and is ready for review.\n\n' ||
            'Applicant: ' || v_submission.applicant_first_name || ' ' || v_submission.applicant_last_name || '\n' ||
            'Address: ' || v_submission.home_address || '\n' ||
            'Submitted: ' || v_submission.submitted_at || '\n\n' ||
            'View in queue: https://apply.archr.org/dashboard/review\n\n' ||
            'ARCHR Platform',
            'new_application',
            'submission',
            p_submission_id,
            3 -- Normal priority
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Function to send daily digest emails
CREATE OR REPLACE FUNCTION send_daily_digest()
RETURNS INTEGER AS $$
DECLARE
    v_user RECORD;
    v_digest_count INTEGER := 0;
    v_digest_body TEXT;
BEGIN
    FOR v_user IN 
        SELECT DISTINCT u.id, u.email, u.full_name
        FROM system_users u
        JOIN user_role_assignments ura ON u.id = ura.user_id
        WHERE u.email_digest_enabled = TRUE
          AND u.is_active = TRUE
    LOOP
        -- Build digest content
        WITH user_notifications AS (
            SELECT * FROM get_unread_notifications(v_user.id, 50)
        ),
        pending_applications AS (
            SELECT COUNT(*) AS pending_count
            FROM review_queue rq
            WHERE rq.status = 'PENDING_REVIEW'
        )
        SELECT 
            'Daily Digest - ' || CURRENT_DATE || E'\n\n' ||
            'Pending Applications: ' || pending_count || E'\n\n' ||
            'Your Notifications:\n' ||
            string_agg('- ' || n.title || ' (' || n.created_at::DATE || ')', E'\n')
        INTO v_digest_body
        FROM pending_applications, user_notifications n;
        
        -- Queue digest email
        INSERT INTO email_queue (
            recipient_email, recipient_name, subject, body,
            notification_type, priority
        ) VALUES (
            v_user.email,
            v_user.full_name,
            '[ARCHR] Daily Digest - ' || CURRENT_DATE,
            v_digest_body,
            'daily_digest',
            5 -- Lower priority, send after urgent emails
        );
        
        v_digest_count := v_digest_count + 1;
    END LOOP;
    
    RETURN v_digest_count;
END;
$$ LANGUAGE plpgsql;

-- Schedule daily digest (to be run by cron/pg_cron)
-- SELECT send_daily_digest();
-- END sql/email-notification-digest.sql

-- ----------------------------------------------------------------
-- BEGIN sql/edit-application.sql
-- ----------------------------------------------------------------
-- Edit request tracking
CREATE TABLE edit_requests (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id),
    requested_by INTEGER REFERENCES system_users(id),
    field_name VARCHAR(100),
    old_value TEXT,
    new_value TEXT,
    reason TEXT,
    status VARCHAR(20) DEFAULT 'pending', -- pending, approved, denied
    reviewed_by INTEGER REFERENCES system_users(id),
    reviewed_at TIMESTAMP,
    approved_at TIMESTAMP,
    change_incorporated BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- END sql/edit-application.sql

-- ----------------------------------------------------------------
-- BEGIN sql/documentation-sops.sql
-- ----------------------------------------------------------------
-- =====================================================
-- ARCHR Help Documentation Library Schema
-- Open Source SOP & User Guide Management System
-- =====================================================

-- Documentation categories (high-level organization)
CREATE TABLE help_categories (
    id SERIAL PRIMARY KEY,
    category_code VARCHAR(50) UNIQUE NOT NULL,
    category_name VARCHAR(100) NOT NULL,
    parent_category_id INTEGER REFERENCES help_categories(id),
    display_order INTEGER DEFAULT 0,
    icon_class VARCHAR(100), -- CSS icon class
    is_active BOOLEAN DEFAULT TRUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Root categories
INSERT INTO help_categories (category_code, category_name, display_order, description) VALUES
    ('GETTING_STARTED', 'Getting Started', 1, 'First-time user guides and account setup'),
    ('APPLICANTS', 'For Applicants & Homeowners', 2, 'How to apply for home repair assistance'),
    ('CASEWORKERS', 'For Caseworkers', 3, 'Managing applications and client communication'),
    ('ASSESSORS', 'For Assessors', 4, 'Conducting home assessments and estimates'),
    ('PROJECT_MANAGEMENT', 'For Project Managers & Crew', 5, 'Managing repair projects and work orders'),
    ('FINANCE', 'For Finance Staff', 6, 'Budgeting, invoicing, and grant compliance'),
    ('VOLUNTEERS', 'For Volunteers', 7, 'Task assignments and hour tracking'),
    ('ADMIN', 'For Administrators', 8, 'System configuration and user management'),
    ('TROUBLESHOOTING', 'Troubleshooting & FAQ', 9, 'Common issues and solutions'),
    ('DEVELOPER', 'For Developers', 10, 'API documentation and system architecture');

-- Document types (doc_type field)
CREATE TABLE help_document_types (
    id SERIAL PRIMARY KEY,
    type_code VARCHAR(50) UNIQUE NOT NULL,
    type_name VARCHAR(100) NOT NULL,
    icon_class VARCHAR(100),
    is_interactive BOOLEAN DEFAULT FALSE, -- Is this a tutorial/walkthrough?
    requires_authentication BOOLEAN DEFAULT TRUE,
    description TEXT
);

INSERT INTO help_document_types (type_code, type_name, icon_class, description) VALUES
    ('SOP', 'Standard Operating Procedure', 'fa-file-alt', 'Step-by-step process documentation'),
    ('GUIDE', 'User Guide', 'fa-book', 'Comprehensive feature guide'),
    ('FAQ', 'Frequently Asked Questions', 'fa-question-circle', 'Common questions and answers'),
    ('TUTORIAL', 'Interactive Tutorial', 'fa-graduation-cap', 'Walkthrough with screenshots/video'),
    ('CHECKLIST', 'Checklist', 'fa-check-square', 'Task-based verification list'),
    ('REFERENCE', 'Quick Reference', 'fa-table', 'One-page cheat sheet or lookup table'),
    ('VIDEO', 'Video Tutorial', 'fa-video', 'Recorded training session'),
    ('TEMPLATE', 'Template', 'fa-file', 'Form, letter, or document template'),
    ('POLICY', 'Policy Document', 'fa-gavel', 'Organizational policy and compliance'),
    ('RELEASE_NOTES', 'Release Notes', 'fa-code-branch', 'System update documentation');

-- Main help documents table
CREATE TABLE help_documents (
    id SERIAL PRIMARY KEY,
    document_id VARCHAR(50) UNIQUE NOT NULL, -- Human-readable ID, e.g., "SOP-001"
    doc_type_id INTEGER REFERENCES help_document_types(id),
    category_id INTEGER REFERENCES help_categories(id),
    
    -- Core metadata
    title VARCHAR(500) NOT NULL,
    subtitle VARCHAR(500),
    version VARCHAR(20) DEFAULT '1.0',
    
    -- Content storage
    content TEXT, -- Markdown or HTML content (for SEO/display)
    content_format VARCHAR(20) DEFAULT 'markdown', -- markdown, html, plain
    file_path VARCHAR(1000), -- Path to PDF or other binary file (optional)
    
    -- For multi-language support
    language VARCHAR(5) DEFAULT 'en', -- en, es, etc.
    original_document_id INTEGER REFERENCES help_documents(id), -- For translations
    
    -- Authorship & ownership
    author VARCHAR(200),
    author_email VARCHAR(255),
    owner_role_id INTEGER REFERENCES roles(id), -- Which role owns this document
    reviewer_id INTEGER REFERENCES system_users(id),
    reviewer_notes TEXT,
    
    -- Target audience (which roles should see this)
    target_roles TEXT[], -- Array of role codes (e.g., {'ADMIN', 'CASEWORKER'})
    
    -- SEO and discovery
    tags TEXT[], -- Array of keywords for search
    search_keywords TEXT[], -- Additional search terms
    
    -- Estimated reading time
    estimated_minutes INTEGER,
    
    -- Related documents
    related_documents INTEGER[], -- Array of help_document IDs
    
    -- Prerequisites (other docs to read first)
    prerequisite_documents INTEGER[], -- Array of help_document IDs
    
    -- Status and lifecycle
    status VARCHAR(20) DEFAULT 'draft', -- draft, review, published, archived, deprecated
    is_featured BOOLEAN DEFAULT FALSE, -- Show on help homepage
    is_required BOOLEAN DEFAULT FALSE, -- Required reading for certain roles
    
    -- Metrics (for analytics)
    view_count INTEGER DEFAULT 0,
    helpful_count INTEGER DEFAULT 0,
    not_helpful_count INTEGER DEFAULT 0,
    last_viewed_at TIMESTAMP,
    
    -- Scheduling
    publish_at TIMESTAMP,
    expires_at TIMESTAMP, -- For time-sensitive content
    review_required_by DATE, -- Date when document needs review
    
    -- Version control
    previous_version_id INTEGER REFERENCES help_documents(id),
    change_notes TEXT,
    
    -- Tracking
    created_by INTEGER REFERENCES system_users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by INTEGER REFERENCES system_users(id),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP,
    reviewed_by INTEGER REFERENCES system_users(id),
    archived_at TIMESTAMP,
    archived_by INTEGER REFERENCES system_users(id),
    
    -- Custom fields (flexible metadata)
    custom_fields JSONB DEFAULT '{}'::jsonb,
    
    -- Notes field (as requested)
    notes TEXT,
    
    CONSTRAINT valid_status CHECK (status IN ('draft', 'review', 'published', 'archived', 'deprecated'))
);

-- TODO: full-text search index.
-- PostgreSQL rejects this expression because the implicit text->regconfig
-- conversion in to_tsvector('english', ...) is STABLE, not IMMUTABLE, and
-- index expressions must be IMMUTABLE. To restore search acceleration:
--   1. Define an IMMUTABLE wrapper, e.g.
--        CREATE FUNCTION help_docs_search_tsv(...)
--          RETURNS tsvector AS $$
--          SELECT to_tsvector('pg_catalog.english'::regconfig, ...);
--        $$ LANGUAGE SQL IMMUTABLE;
--   2. CREATE INDEX ... ON help_documents USING GIN (help_docs_search_tsv(...));
-- Or add a STORED generated column populated by the wrapper and GIN-index that.

-- Document attachments (screenshots, diagrams, supplementary files)
CREATE TABLE help_document_attachments (
    id SERIAL PRIMARY KEY,
    document_id INTEGER REFERENCES help_documents(id) ON DELETE CASCADE,
    attachment_type VARCHAR(50), -- screenshot, diagram, video, audio, dataset
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(1000) NOT NULL,
    file_size_bytes BIGINT,
    mime_type VARCHAR(100),
    alt_text VARCHAR(500), -- For accessibility
    caption TEXT,
    display_order INTEGER DEFAULT 0,
    uploaded_by INTEGER REFERENCES system_users(id),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Document versions history
CREATE TABLE help_document_versions (
    id SERIAL PRIMARY KEY,
    document_id INTEGER REFERENCES help_documents(id) ON DELETE CASCADE,
    version_number VARCHAR(20) NOT NULL,
    title VARCHAR(500),
    content TEXT,
    change_notes TEXT,
    created_by INTEGER REFERENCES system_users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_current BOOLEAN DEFAULT FALSE
);

-- User feedback on documents
CREATE TABLE help_document_feedback (
    id SERIAL PRIMARY KEY,
    document_id INTEGER REFERENCES help_documents(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES system_users(id),
    is_helpful BOOLEAN,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User progress tracking (for required docs or training)
CREATE TABLE help_user_progress (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES system_users(id) ON DELETE CASCADE,
    document_id INTEGER REFERENCES help_documents(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'not_started', -- not_started, in_progress, completed
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    last_position INTEGER, -- For long docs, scroll position
    notes TEXT,
    UNIQUE(user_id, document_id)
);

-- Search queries log (for analytics)
CREATE TABLE help_search_log (
    id SERIAL PRIMARY KEY,
    search_term VARCHAR(500),
    user_id INTEGER REFERENCES system_users(id),
    result_count INTEGER,
    clicked_document_id INTEGER REFERENCES help_documents(id),
    search_type VARCHAR(20), -- quick, advanced, facet
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Document reviews and approval workflow
CREATE TABLE help_document_reviews (
    id SERIAL PRIMARY KEY,
    document_id INTEGER REFERENCES help_documents(id) ON DELETE CASCADE,
    reviewer_id INTEGER REFERENCES system_users(id),
    review_status VARCHAR(20), -- pending, approved, changes_requested, rejected
    comments TEXT,
    requested_changes TEXT,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Function to increment view count
CREATE OR REPLACE FUNCTION increment_help_view(p_document_id INTEGER)
RETURNS void AS $$
BEGIN
    UPDATE help_documents 
    SET view_count = view_count + 1,
        last_viewed_at = CURRENT_TIMESTAMP
    WHERE id = p_document_id;
END;
$$ LANGUAGE plpgsql;

-- Function to record feedback
CREATE OR REPLACE FUNCTION record_help_feedback(
    p_document_id INTEGER,
    p_user_id INTEGER,
    p_is_helpful BOOLEAN,
    p_rating INTEGER DEFAULT NULL,
    p_comment TEXT DEFAULT NULL
)
RETURNS void AS $$
BEGIN
    INSERT INTO help_document_feedback (document_id, user_id, is_helpful, rating, comment)
    VALUES (p_document_id, p_user_id, p_is_helpful, p_rating, p_comment);
    
    -- Update aggregate counts on document
    UPDATE help_documents 
    SET helpful_count = (
        SELECT COUNT(*) FROM help_document_feedback 
        WHERE document_id = p_document_id AND is_helpful = true
    ),
    not_helpful_count = (
        SELECT COUNT(*) FROM help_document_feedback 
        WHERE document_id = p_document_id AND is_helpful = false
    )
    WHERE id = p_document_id;
END;
$$ LANGUAGE plpgsql;

-- Function to get documents by role
CREATE OR REPLACE FUNCTION get_docs_for_role(p_role_code VARCHAR)
RETURNS TABLE(
    id INTEGER,
    title VARCHAR,
    category_name VARCHAR,
    doc_type_name VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        hd.id,
        hd.title,
        hc.category_name,
        hdt.type_name
    FROM help_documents hd
    JOIN help_categories hc ON hd.category_id = hc.id
    JOIN help_document_types hdt ON hd.doc_type_id = hdt.id
    WHERE hd.status = 'published'
        AND (hd.target_roles IS NULL OR p_role_code = ANY(hd.target_roles))
    ORDER BY hc.display_order, hd.title;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- VIEWS FOR DOCUMENTATION DASHBOARD
-- =====================================================

-- Help center overview
CREATE VIEW help_center_overview AS
SELECT 
    hc.category_name,
    COUNT(hd.id) as total_documents,
    COUNT(CASE WHEN hd.status = 'published' THEN 1 END) as published_count,
    COUNT(CASE WHEN hd.status = 'draft' THEN 1 END) as draft_count,
    COUNT(CASE WHEN hd.status = 'review' THEN 1 END) as review_count,
    MAX(hd.updated_at) as last_updated,
    SUM(hd.view_count) as total_views,
    ROUND(AVG(CASE
        WHEN (hd.helpful_count + hd.not_helpful_count) > 0
        THEN (hd.helpful_count::numeric / (hd.helpful_count + hd.not_helpful_count)) * 100
        ELSE NULL
    END), 1) as helpful_percentage
FROM help_categories hc
LEFT JOIN help_documents hd ON hc.id = hd.category_id
WHERE hc.is_active = true
GROUP BY hc.id, hc.category_name, hc.display_order
ORDER BY hc.display_order;

-- Recently updated documents
CREATE VIEW recently_updated_docs AS
SELECT 
    hd.id,
    hd.document_id,
    hd.title,
    hdt.type_name,
    hc.category_name,
    hd.version,
    hd.updated_at,
    u.full_name as updated_by_name,
    hd.change_notes
FROM help_documents hd
JOIN help_document_types hdt ON hd.doc_type_id = hdt.id
JOIN help_categories hc ON hd.category_id = hc.id
LEFT JOIN system_users u ON hd.updated_by = u.id
WHERE hd.status = 'published'
ORDER BY hd.updated_at DESC
LIMIT 20;

-- Documents needing review
CREATE VIEW documents_needing_review AS
SELECT 
    hd.id,
    hd.document_id,
    hd.title,
    hd.version,
    hd.review_required_by,
    hd.updated_at,
    (CURRENT_DATE - hd.review_required_by) as days_overdue
FROM help_documents hd
WHERE hd.status = 'published'
    AND hd.review_required_by IS NOT NULL
    AND hd.review_required_by < CURRENT_DATE + INTERVAL '30 days'
ORDER BY hd.review_required_by ASC;

-- =====================================================
-- SAMPLE QUERIES FOR DOCUMENTATION MANAGEMENT
-- =====================================================

/*

-- Get all SOPs for Caseworkers
SELECT * FROM help_documents 
WHERE doc_type_id = (SELECT id FROM help_document_types WHERE type_code = 'SOP')
AND 'CASEWORKER' = ANY(target_roles)
AND status = 'published';

-- Search documentation
SELECT id, title, ts_rank_cd(search_vector, query) as rank
FROM help_documents, 
     to_tsquery('english', 'application & review') query
WHERE query @@ search_vector
ORDER BY rank DESC
LIMIT 20;

-- Get user's incomplete required reading
SELECT hd.* 
FROM help_documents hd
LEFT JOIN help_user_progress ha ON hd.id = ha.document_id AND ha.user_id = 123
WHERE hd.is_required = true
    AND hd.status = 'published'
    AND (ha.status IS NULL OR ha.status != 'completed')
    AND (hd.target_roles IS NULL OR 'CASEWORKER' = ANY(hd.target_roles));

-- Most helpful documents this month
SELECT 
    hd.title,
    hd.view_count,
    hd.helpful_count,
    ROUND((hd.helpful_count::float / NULLIF(hd.helpful_count + hd.not_helpful_count, 0)) * 100, 1) as helpful_pct
FROM help_documents hd
WHERE hd.status = 'published'
    AND hd.updated_at > CURRENT_DATE - INTERVAL '30 days'
ORDER BY helpful_pct DESC
LIMIT 10;

-- Export documentation for offline distribution (e.g., for disaster deployment)
COPY (
    SELECT 
        hd.document_id,
        hd.title,
        hd.version,
        hd.content,
        hc.category_name,
        hdt.type_name,
        hd.tags,
        hd.estimated_minutes
    FROM help_documents hd
    JOIN help_categories hc ON hd.category_id = hc.id
    JOIN help_document_types hdt ON hd.doc_type_id = hdt.id
    WHERE hd.status = 'published'
    ORDER BY hc.display_order, hd.title
) TO '/tmp/help_docs_export.csv' CSV HEADER;

*/

-- =====================================================
-- TRIGGERS FOR AUTO-UPDATING TIMESTAMPS
-- =====================================================

CREATE OR REPLACE FUNCTION update_help_doc_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_help_doc_timestamp
    BEFORE UPDATE ON help_documents
    FOR EACH ROW
    EXECUTE PROCEDURE update_help_doc_timestamp();

-- Trigger to version documents on update
CREATE OR REPLACE FUNCTION version_help_document()
RETURNS TRIGGER AS $$
BEGIN
    -- Store old version if content changed significantly
    IF OLD.content IS DISTINCT FROM NEW.content OR OLD.title IS DISTINCT FROM NEW.title THEN
        INSERT INTO help_document_versions (
            document_id, version_number, title, content, change_notes, 
            created_by, created_at, is_current
        ) VALUES (
            OLD.id, OLD.version, OLD.title, OLD.content, OLD.change_notes,
            OLD.updated_by, OLD.updated_at, false
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_version_help_document
    BEFORE UPDATE ON help_documents
    FOR EACH ROW
    EXECUTE PROCEDURE version_help_document();
-- END sql/documentation-sops.sql

-- ----------------------------------------------------------------
-- BEGIN sql/document-storage.sql
-- ----------------------------------------------------------------
-- =====================================================
-- ARCHR Document Management Schema
-- Hybrid SQL + Object Storage (S3/Dropbox/Google Cloud)

-- ## Implementation Recommendations
-- 
-- ### Phase 1: Foundation
-- 
-- 1. Set up object storage (Dropbox API, AWS S3, or Google Cloud Storage)
-- 2. Implement the SQL schema above
-- 3. Create basic upload/download endpoints
--     
-- 
-- ### Phase 2: Document Generation
-- 
-- 1. Build PDF generation service (using puppeteer, wkhtmltopdf, or Docmosis)
-- 2. Create contract and certificate templates  
-- 3. Implement signature collection (DocuSign or similar)
--     
-- 
-- ### Phase 3: Automation
-- 
-- 1. Property card integration with county assessor APIs
-- 2. OCR pipeline for income verification documents
-- 3. Auto-categorization of uploaded documents
--     
-- 
-- ### Phase 4: Advanced Features
-- 
-- 1. Full-text search across documents 
-- 2. AI-powered document classification
-- 3. Batch operations for common document types
--     
-- ## Key Considerations
-- 
-- 1. **Security**: All documents should be encrypted at rest and in transit
-- 2. **Backup**: Implement 3-2-1 backup strategy for all documents 
-- 3. **Compliance**: Ensure document retention meets grant requirements (typically 7-10 -- years)  
-- 4. **Performance**: Use thumbnails for image previews, lazy loading for large PDFs--  
-- 5. **Offline Support**: Consider mobile app for field workers to upload photos without  internet
--     
-- This hybrid approach gives you the structure of SQL with the flexibility of object storage, providing a scalable, searchable document management system that integrates with your case management workflow.
-- =====================================================

-- Document categories (taxonomy)
CREATE TABLE document_categories (
    id SERIAL PRIMARY KEY,
    category_code VARCHAR(50) UNIQUE NOT NULL,
    category_name VARCHAR(100) NOT NULL,
    parent_category_id INTEGER REFERENCES document_categories(id),
    storage_path_template TEXT, -- e.g., "/cases/{case_number}/property/"
    requires_encryption BOOLEAN DEFAULT TRUE,
    retention_months INTEGER,
    description TEXT
);

INSERT INTO document_categories (category_code, category_name, storage_path_template, requires_encryption, retention_months) VALUES
    ('APPLICATION', 'Application Documents', '/cases/{case_number}/application/', true, 120), -- 10 years
    ('PROPERTY', 'Property Records', '/cases/{case_number}/property/', true, 120),
    ('INCOME', 'Income Verification', '/cases/{case_number}/income/', true, 84), -- 7 years
    ('ASSESSMENT', 'Property Assessments', '/cases/{case_number}/assessments/', true, 120),
    ('ASSESSMENT_PHOTOS_BEFORE', 'Before Photos', '/cases/{case_number}/assessments/initial/photos/', true, 120),
    ('ASSESSMENT_PHOTOS_DURING', 'During Photos', '/cases/{case_number}/assessments/final/photos/', true, 120),
    ('ASSESSMENT_PHOTOS_AFTER', 'After Photos', '/cases/{case_number}/completion/final_photos/', true, 120),
    ('CONTRACT', 'Repair Contracts', '/cases/{case_number}/contracts/', true, 120),
    ('CHANGE_ORDER', 'Change Orders', '/cases/{case_number}/contracts/', true, 120),
    ('WORK_ORDER', 'Work Orders', '/cases/{case_number}/work_orders/{work_order_number}/', true, 84),
    ('QUOTE', 'Subcontractor Quotes', '/cases/{case_number}/financial/quotes/', true, 36), -- 3 years
    ('INVOICE', 'Invoices', '/cases/{case_number}/financial/invoices/', true, 84),
    ('GRANT', 'Grant Documents', '/cases/{case_number}/financial/grants/', true, 120),
    ('ENV_REVIEW', 'Environmental Review', '/cases/{case_number}/financial/grants/', true, 120),
    ('SHPO', 'SHPO Records', '/cases/{case_number}/financial/grants/', true, 120),
    ('COMPLETION', 'Completion Certificate', '/cases/{case_number}/completion/', true, 120),
    ('COMMUNICATION', 'Communications', '/cases/{case_number}/communications/', true, 36),
    ('TEMPLATE', 'System Templates', '/shared/templates/', false, 9999); -- Permanent

-- Document status tracking
CREATE TABLE document_statuses (
    id SERIAL PRIMARY KEY,
    status_code VARCHAR(50) UNIQUE NOT NULL,
    status_name VARCHAR(100) NOT NULL
);

INSERT INTO document_statuses (status_code, status_name) VALUES
    ('PENDING', 'Pending Upload'),
    ('UPLOADED', 'Uploaded - Pending Processing'),
    ('PROCESSING', 'Processing'),
    ('VERIFIED', 'Verified'),
    ('REJECTED', 'Rejected'),
    ('ARCHIVED', 'Archived'),
    ('DELETED', 'Deleted');

-- Main documents table
CREATE TABLE case_documents (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES document_categories(id),
    status_id INTEGER REFERENCES document_statuses(id) DEFAULT 1,
    
    -- File metadata
    file_name VARCHAR(255) NOT NULL,
    file_size_bytes BIGINT,
    file_hash VARCHAR(64), -- SHA-256 for deduplication
    mime_type VARCHAR(100),
    storage_path VARCHAR(1000) NOT NULL, -- Relative path in object storage
    storage_provider VARCHAR(50) DEFAULT 'dropbox', -- dropbox, s3, gcs, local
    storage_bucket VARCHAR(255),
    storage_region VARCHAR(100),
    
    -- Versioning
    version_number INTEGER DEFAULT 1,
    parent_document_id INTEGER REFERENCES case_documents(id), -- For version chains
    
    -- Dynamic metadata (JSON for flexible schema)
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Extracted data (for search/indexing)
    extracted_text TEXT, -- OCR or PDF text extraction
    thumbnail_path VARCHAR(1000), -- For images
    
    -- Tracking
    uploaded_by INTEGER REFERENCES system_users(id),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verified_by INTEGER REFERENCES system_users(id),
    verified_at TIMESTAMP,
    
    -- Retention
    expires_at TIMESTAMP,
    deleted_at TIMESTAMP,
    
    -- Access control
    access_roles TEXT[], -- Which roles can view this document
    
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Document generation templates
CREATE TABLE document_templates (
    id SERIAL PRIMARY KEY,
    template_code VARCHAR(50) UNIQUE NOT NULL,
    template_name VARCHAR(200) NOT NULL,
    category_id INTEGER REFERENCES document_categories(id),
    template_file_path VARCHAR(1000), -- Path to template file (DOCX, PDF form)
    template_type VARCHAR(50), -- contract, certificate, application, change_order
    output_format VARCHAR(20) DEFAULT 'pdf', -- pdf, docx, html
    requires_signature BOOLEAN DEFAULT FALSE,
    signature_fields JSONB, -- Coordinates/field names for signature placement
    version INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Document generation jobs (async PDF generation)
CREATE TABLE document_generation_jobs (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id),
    template_id INTEGER REFERENCES document_templates(id),
    status VARCHAR(20) DEFAULT 'pending', -- pending, processing, completed, failed
    data_source JSONB NOT NULL, -- The data to populate the template
    output_document_id INTEGER REFERENCES case_documents(id),
    error_message TEXT,
    priority INTEGER DEFAULT 5,
    created_by INTEGER REFERENCES system_users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    expires_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP + INTERVAL '7 days'
);

-- Document access logs
CREATE TABLE document_access_log (
    id SERIAL PRIMARY KEY,
    document_id INTEGER REFERENCES case_documents(id) ON DELETE CASCADE,
    accessed_by INTEGER REFERENCES system_users(id),
    access_type VARCHAR(20), -- view, download, print, share
    ip_address INET,
    user_agent TEXT,
    accessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Document share links (temporary access for external parties)
CREATE TABLE document_share_links (
    id SERIAL PRIMARY KEY,
    document_id INTEGER REFERENCES case_documents(id) ON DELETE CASCADE,
    share_token UUID DEFAULT gen_random_uuid() UNIQUE,
    shared_by INTEGER REFERENCES system_users(id),
    recipient_email VARCHAR(255),
    expires_at TIMESTAMP,
    max_accesses INTEGER,
    access_count INTEGER DEFAULT 0,
    requires_auth BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- AUTOMATED DOCUMENT GENERATION FUNCTIONS
-- =====================================================

-- Function to generate property card (simplified - would call external API)
CREATE OR REPLACE FUNCTION generate_property_card(
    p_case_id INTEGER,
    p_parcel_id VARCHAR
)
RETURNS INTEGER AS $$
DECLARE
    v_document_id INTEGER;
    v_case_record RECORD;
    v_property_data JSONB;
BEGIN
    -- Get case information
    SELECT c.*, s.home_address, s.home_city, s.home_zip, s.home_type, s.year_built
    INTO v_case_record
    FROM cases c
    JOIN intake_submissions s ON c.submission_id = s.id
    WHERE c.id = p_case_id;
    
    -- In production, this would call a county assessor API or web scraper
    -- For now, we construct a JSONB object with available data
    v_property_data = jsonb_build_object(
        'parcel_id', p_parcel_id,
        'property_address', v_case_record.home_address,
        'property_city', v_case_record.home_city,
        'property_zip', v_case_record.home_zip,
        'year_built', v_case_record.year_built,
        'property_type', v_case_record.home_type,
        'generated_at', CURRENT_TIMESTAMP,
        'source', 'system_generated'
    );
    
    -- Create a document record
    INSERT INTO case_documents (
        case_id, category_id, status_id, file_name, storage_path, 
        metadata, uploaded_by, access_roles
    ) VALUES (
        p_case_id,
        (SELECT id FROM document_categories WHERE category_code = 'PROPERTY'),
        (SELECT id FROM document_statuses WHERE status_code = 'PENDING'),
        'property_card_' || p_case_id || '_' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '.json',
        '/cases/' || v_case_record.case_number || '/property/property_card.json',
        v_property_data,
        NULL,
        ARRAY['ADMIN', 'CASEWORKER', 'ASSESSOR']
    ) RETURNING id INTO v_document_id;
    
    -- Queue a job to convert to PDF if needed
    -- This would be handled by a separate worker process
    
    RETURN v_document_id;
END;
$$ LANGUAGE plpgsql;

-- Function to generate contract from assessment
CREATE OR REPLACE FUNCTION generate_contract(
    p_case_id INTEGER,
    p_template_version INTEGER DEFAULT 1
)
RETURNS INTEGER AS $$
DECLARE
    v_document_id INTEGER;
    v_case_record RECORD;
    v_assessment RECORD;
    v_contract_data JSONB;
BEGIN
    -- Get case and assessment data
    SELECT c.*, s.applicant_first_name, s.applicant_last_name, s.home_address
    INTO v_case_record
    FROM cases c
    JOIN intake_submissions s ON c.submission_id = s.id
    WHERE c.id = p_case_id;
    
    -- Get approved assessment
    SELECT * INTO v_assessment
    FROM property_assessments
    WHERE case_id = p_case_id
    ORDER BY assessment_date DESC
    LIMIT 1;
    
    -- Build contract data
    v_contract_data = jsonb_build_object(
        'case_number', v_case_record.case_number,
        'applicant_name', v_case_record.applicant_first_name || ' ' || v_case_record.applicant_last_name,
        'property_address', v_case_record.home_address,
        'repair_scope', v_assessment.recommended_repairs,
        'total_estimate', v_assessment.total_estimate,
        'estimated_hours', v_assessment.estimated_hours,
        'start_date', (CURRENT_DATE + INTERVAL '14 days'),
        'completion_target', (CURRENT_DATE + INTERVAL '60 days'),
        'terms_and_conditions', 'Standard repair terms apply...',
        'generated_at', CURRENT_TIMESTAMP,
        'template_version', p_template_version
    );
    
    -- Queue for PDF generation
    INSERT INTO document_generation_jobs (
        case_id, template_id, data_source, created_by
    ) VALUES (
        p_case_id,
        (SELECT id FROM document_templates WHERE template_code = 'REPAIR_CONTRACT' AND is_active = true),
        v_contract_data,
        NULL
    );
    
    -- Create document record (PDF will be linked when generation completes)
    INSERT INTO case_documents (
        case_id, category_id, status_id, file_name, storage_path,
        metadata, access_roles
    ) VALUES (
        p_case_id,
        (SELECT id FROM document_categories WHERE category_code = 'CONTRACT'),
        (SELECT id FROM document_statuses WHERE status_code = 'PENDING'),
        v_case_record.case_number || '_contract_v1.pdf',
        '/cases/' || v_case_record.case_number || '/contracts/' || v_case_record.case_number || '_contract_v1.pdf',
        v_contract_data,
        ARRAY['ADMIN', 'CASEWORKER', 'PROJECT_MANAGER', 'APPLICANT']
    ) RETURNING id INTO v_document_id;
    
    -- Update generation job with document ID
    UPDATE document_generation_jobs 
    SET output_document_id = v_document_id 
    WHERE case_id = p_case_id 
    AND output_document_id IS NULL;
    
    RETURN v_document_id;
END;
$$ LANGUAGE plpgsql;

-- Function to batch upload site photos
CREATE OR REPLACE FUNCTION register_site_photos(
    p_case_id INTEGER,
    p_photos JSONB, -- Array of {file_name, file_data_base64, photo_type, timestamp}
    p_uploaded_by INTEGER
)
RETURNS TABLE(photo_id INTEGER, storage_path VARCHAR) AS $$
DECLARE
    v_photo RECORD;
    v_case_number VARCHAR;
    v_category_id INTEGER;
    v_doc_id INTEGER;
    v_storage_path VARCHAR;
BEGIN
    -- Get case number
    SELECT case_number INTO v_case_number FROM cases WHERE id = p_case_id;
    
    FOR v_photo IN SELECT * FROM jsonb_to_recordset(p_photos) AS x(file_name TEXT, photo_type TEXT, capture_timestamp TIMESTAMP)
    LOOP
        -- Determine category based on photo type
        SELECT id INTO v_category_id FROM document_categories 
        WHERE category_code = CASE v_photo.photo_type
            WHEN 'before' THEN 'ASSESSMENT_PHOTOS_BEFORE'
            WHEN 'during' THEN 'ASSESSMENT_PHOTOS_DURING'
            WHEN 'after' THEN 'ASSESSMENT_PHOTOS_AFTER'
            ELSE 'ASSESSMENT_PHOTOS_BEFORE'
        END;
        
        -- Generate storage path
        v_storage_path := '/cases/' || v_case_number || '/assessments/' || 
            CASE v_photo.photo_type
                WHEN 'before' THEN 'initial/photos/'
                WHEN 'during' THEN 'final/photos/'
                WHEN 'after' THEN 'completion/final_photos/'
            END || 
            v_photo.photo_type || '_' || 
            TO_CHAR(COALESCE(v_photo.capture_timestamp, CURRENT_TIMESTAMP), 'YYYYMMDD_HH24MISS') || 
            '_' || v_photo.file_name;
        
        -- Create document record
        INSERT INTO case_documents (
            case_id, category_id, status_id, file_name, storage_path,
            uploaded_by, mime_type, access_roles, metadata
        ) VALUES (
            p_case_id, v_category_id, 
            (SELECT id FROM document_statuses WHERE status_code = 'PROCESSING'),
            v_photo.file_name, v_storage_path,
            p_uploaded_by, 'image/jpeg',
            ARRAY['ADMIN', 'ASSESSOR', 'CREW_LEAD', 'PROJECT_MANAGER'],
            jsonb_build_object('photo_type', v_photo.photo_type, 'capture_timestamp', v_photo.capture_timestamp)
        ) RETURNING id INTO v_doc_id;
        
        photo_id := v_doc_id;
        storage_path := v_storage_path;
        RETURN NEXT;
    END LOOP;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- DOCUMENT NAMING CONVENTION STANDARDS
-- =====================================================

/*

DOCUMENT NAMING CONVENTION STANDARD v1.0

Format: {case_number}_{document_type}_{version_or_date}_{descriptor}.{extension}

Components:
- case_number: ARCHR-YYYY-XXXXXX (e.g., ARCHR-2024-001234)
- document_type: 2-4 letter code
- version_or_date: v{number} OR YYYYMMDD
- descriptor: Optional human-readable identifier
- extension: pdf, jpg, png, json, docx

Document Type Codes:
- APP = Application
- PROP = Property Card
- DEED = Deed/Title
- TAX = Tax Record
- INC = Income Verification (INC_SS, INC_W2, INC_PAYSTUB)
- ASSESS = Assessment Report
- PH_B = Before Photo
- PH_D = During Photo  
- PH_A = After Photo
- CONT = Contract
- CO = Change Order
- WO = Work Order
- QUOTE = Subcontractor Quote
- INV = Invoice
- GRANT = Grant Document
- ENV = Environmental Review
- SHPO = Historic Preservation
- CERT = Certificate of Completion
- COMM = Communication Log

Examples:
ARCHR-2024-001234_APP_v1.pdf
ARCHR-2024-001234_PROP_20241201.pdf
ARCHR-2024-001234_INC_SS_20241115.pdf
ARCHR-2024-001234_PH_B_20241201_roof_before.jpg
ARCHR-2024-001234_CONT_v1_signed.pdf
ARCHR-2024-001234_WO_001_v1.pdf
ARCHR-2024-001234_CERT_final.pdf

*/

-- Function to validate document naming
CREATE OR REPLACE FUNCTION validate_document_name(p_filename VARCHAR)
RETURNS BOOLEAN AS $$
BEGIN
    -- Check pattern: {case_number}_{doc_type}_{version_or_date}_{optional}.{ext}
    RETURN p_filename ~ '^ARCHR-\d{4}-\d{6}_[A-Z]{2,5}_[v\d+|YYYYMMDD](_[a-z0-9_]+)?\.(pdf|jpg|jpeg|png|json|docx)$';
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- STORAGE PROVIDER CONFIGURATION
-- =====================================================

CREATE TABLE storage_providers (
    id SERIAL PRIMARY KEY,
    provider_name VARCHAR(50) UNIQUE NOT NULL, -- dropbox, s3, gcs, local
    is_default BOOLEAN DEFAULT FALSE,
    configuration JSONB NOT NULL, -- API keys, buckets, regions (encrypted)
    base_url VARCHAR(500),
    max_file_size_bytes BIGINT DEFAULT 104857600, -- 100MB default
    allowed_mime_types TEXT[],
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default provider (example - would be configured per deployment)
INSERT INTO storage_providers (provider_name, is_default, configuration, base_url) VALUES
    ('dropbox', true, '{"app_key":"placeholder","app_secret":"placeholder"}', 'https://www.dropbox.com/');

-- =====================================================
-- VIEWS FOR DOCUMENT DASHBOARD
-- =====================================================

-- Case document inventory view
CREATE VIEW case_document_inventory AS
SELECT 
    c.id as case_id,
    c.case_number,
    dc.category_code,
    dc.category_name,
    COUNT(d.id) as document_count,
    COUNT(CASE WHEN d.status_id = (SELECT id FROM document_statuses WHERE status_code = 'VERIFIED') THEN 1 END) as verified_count,
    COUNT(CASE WHEN d.status_id = (SELECT id FROM document_statuses WHERE status_code = 'PENDING') THEN 1 END) as pending_count,
    MAX(d.uploaded_at) as last_upload,
    -- PostgreSQL requires the ORDER BY expression to appear in the argument
    -- list when DISTINCT is used inside an aggregate. Order by file_name
    -- here; for true recency ordering, query case_documents directly.
    ARRAY_AGG(DISTINCT d.file_name ORDER BY d.file_name) as recent_documents
FROM cases c
CROSS JOIN document_categories dc
LEFT JOIN case_documents d ON c.id = d.case_id AND dc.id = d.category_id
WHERE dc.parent_category_id IS NOT NULL -- Exclude parent categories
GROUP BY c.id, c.case_number, dc.category_code, dc.category_name
ORDER BY c.case_number, dc.category_code;

-- Documents requiring verification
CREATE VIEW pending_verification_documents AS
SELECT 
    d.id,
    c.case_number,
    s.applicant_first_name,
    s.applicant_last_name,
    dc.category_name,
    d.file_name,
    d.uploaded_by,
    u.full_name as uploaded_by_name,
    d.uploaded_at,
    d.extracted_text
FROM case_documents d
JOIN cases c ON d.case_id = c.id
JOIN intake_submissions s ON c.submission_id = s.id
JOIN document_categories dc ON d.category_id = dc.id
LEFT JOIN system_users u ON d.uploaded_by = u.id
WHERE d.status_id = (SELECT id FROM document_statuses WHERE status_code = 'UPLOADED')
    OR d.status_id = (SELECT id FROM document_statuses WHERE status_code = 'PROCESSING')
ORDER BY d.uploaded_at ASC;
-- END sql/document-storage.sql

-- ----------------------------------------------------------------
-- BEGIN sql/project-level-finance.sql
-- ----------------------------------------------------------------
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

-- END sql/project-level-finance.sql

-- ----------------------------------------------------------------
-- BEGIN sql/review-queue.sql
-- ----------------------------------------------------------------
-- =====================================================
-- FIFO REVIEW QUEUE
-- Applications appear in order received
-- =====================================================

CREATE SEQUENCE fifo_sequence START 1;

CREATE TABLE review_queue (
    id SERIAL PRIMARY KEY,
    submission_id INTEGER REFERENCES intake_submissions(id) UNIQUE,
    
    -- Queue position (FIFO)
    fifo_order BIGINT DEFAULT nextval('fifo_sequence'),
    
    -- Status tracking
    status VARCHAR(50) DEFAULT 'PENDING_REVIEW', -- PENDING_REVIEW, IN_REVIEW, REVIEWED, ASSIGNED, INELIGIBLE
    
    -- Assignment
    assigned_to_id INTEGER REFERENCES system_users(id),
    assigned_at TIMESTAMP,
    organization_id INTEGER REFERENCES coalition_organizations(id),
    
    -- Timestamps
    queued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP,
    completed_at TIMESTAMP,
    
    -- Metadata
    priority_score INTEGER DEFAULT 0, -- Calculated from triage score
    notes TEXT
);

CREATE INDEX idx_queue_order  ON review_queue (fifo_order);
CREATE INDEX idx_queue_status ON review_queue (status, priority_score DESC);

-- Function to get next application in queue (FIFO with priority)
CREATE OR REPLACE FUNCTION get_next_in_queue(p_organization_id INTEGER DEFAULT NULL)
RETURNS TABLE(
    submission_id INTEGER,
    case_number VARCHAR,
    applicant_name VARCHAR,
    fifo_order BIGINT,
    priority_score INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        rq.submission_id,
        c.case_number,
        s.applicant_first_name || ' ' || s.applicant_last_name AS applicant_name,
        rq.fifo_order,
        rq.priority_score
    FROM review_queue rq
    JOIN intake_submissions s ON rq.submission_id = s.id
    LEFT JOIN cases c ON s.id = c.submission_id
    WHERE rq.status = 'PENDING_REVIEW'
      AND (p_organization_id IS NULL OR rq.organization_id = p_organization_id)
    ORDER BY rq.priority_score DESC, rq.fifo_order ASC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;
-- END sql/review-queue.sql

-- ----------------------------------------------------------------
-- BEGIN sql/requestor-dashboard-access.sql
-- ----------------------------------------------------------------
-- Generate temporary access token for guest users
CREATE OR REPLACE FUNCTION generate_guest_access_token(p_submission_id INTEGER)
RETURNS VARCHAR AS $$
DECLARE
    v_token UUID;
    v_expires TIMESTAMP;
BEGIN
    v_token := gen_random_uuid();
    v_expires := CURRENT_TIMESTAMP + INTERVAL '30 days';
    
    INSERT INTO guest_access_tokens (submission_id, token, expires_at)
    VALUES (p_submission_id, v_token, v_expires)
    ON CONFLICT (submission_id) DO UPDATE
    SET token = EXCLUDED.token,
        expires_at = EXCLUDED.expires_at,
        last_accessed = NULL;
    
    RETURN '/track/' || v_token;
END;
$$ LANGUAGE plpgsql;

-- Guest access tokens table
CREATE TABLE guest_access_tokens (
    id SERIAL PRIMARY KEY,
    submission_id INTEGER REFERENCES intake_submissions(id) UNIQUE,
    token UUID UNIQUE DEFAULT gen_random_uuid(),
    expires_at TIMESTAMP,
    last_accessed TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Function to validate guest access
CREATE OR REPLACE FUNCTION validate_guest_access(p_token UUID)
RETURNS TABLE(
    valid BOOLEAN,
    submission_id INTEGER,
    case_number VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        gat.expires_at > CURRENT_TIMESTAMP AS valid,
        s.id,
        c.case_number
    FROM guest_access_tokens gat
    JOIN intake_submissions s ON gat.submission_id = s.id
    LEFT JOIN cases c ON s.id = c.submission_id
    WHERE gat.token = p_token;
    
    -- Update last accessed
    UPDATE guest_access_tokens 
    SET last_accessed = CURRENT_TIMESTAMP
    WHERE token = p_token;
END;
$$ LANGUAGE plpgsql;
-- END sql/requestor-dashboard-access.sql

-- ----------------------------------------------------------------
-- BEGIN sql/volunteer-task-claim.sql
-- ----------------------------------------------------------------
-- Claiming a task (prevents double-booking)
CREATE OR REPLACE FUNCTION claim_quest(
    p_quest_id UUID,
    p_volunteer_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_current_count INTEGER;
    v_max_volunteers INTEGER;
    v_result JSONB;
BEGIN
    -- Lock the quest row to prevent race conditions
    SELECT max_volunteers, current_volunteers 
    INTO v_max_volunteers, v_current_count
    FROM quests WHERE id = p_quest_id FOR UPDATE;
    
    -- Check availability
    IF v_current_count >= v_max_volunteers THEN
        RETURN jsonb_build_object('success', false, 'error', 'Quest is full');
    END IF;
    
    -- Check volunteer hasn't already claimed
    IF EXISTS (SELECT 1 FROM quest_assignments 
               WHERE quest_id = p_quest_id AND volunteer_id = p_volunteer_id) THEN
        RETURN jsonb_build_object('success', false, 'error', 'Already claimed');
    END IF;
    
    -- Assign the quest
    INSERT INTO quest_assignments (quest_id, volunteer_id, assigned_at, status)
    VALUES (p_quest_id, p_volunteer_id, NOW(), 'assigned');
    
    -- Update current count
    UPDATE quests 
    SET current_volunteers = current_volunteers + 1
    WHERE id = p_quest_id;
    
    RETURN jsonb_build_object('success', true, 'message', 'Quest claimed!');
END;
$$ LANGUAGE plpgsql;
-- END sql/volunteer-task-claim.sql

-- ----------------------------------------------------------------
-- BEGIN sql/eligibility-tracker.sql
-- ----------------------------------------------------------------
-- =====================================================
-- ELIGIBILITY CHECKER
-- Philosophy: Accept until disqualifying information found
-- Default: ELIGIBLE unless specific criteria fail
-- =====================================================

-- Per-org eligibility scoring results, written by check_eligibility() and read
-- by the staff dashboard views.
CREATE TABLE eligibility_results (
    id SERIAL PRIMARY KEY,
    submission_id INTEGER REFERENCES intake_submissions(id) ON DELETE CASCADE,
    organization_id INTEGER REFERENCES coalition_organizations(id) ON DELETE CASCADE,
    match_score INTEGER,
    is_eligible BOOLEAN,
    checked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (submission_id, organization_id)
);

CREATE INDEX idx_eligibility_results_submission ON eligibility_results (submission_id, match_score DESC);
CREATE INDEX idx_eligibility_results_org        ON eligibility_results (organization_id, is_eligible);

CREATE OR REPLACE FUNCTION check_eligibility(p_submission_id INTEGER)
RETURNS JSONB AS $$
DECLARE
    v_submission RECORD;
    v_eligibility_result JSONB;
    v_disqualifiers TEXT[] := '{}';
    v_warnings TEXT[] := '{}';
    v_is_eligible BOOLEAN := TRUE; -- Default to eligible
BEGIN
    -- Fetch submission data
    SELECT * INTO v_submission FROM intake_submissions WHERE id = p_submission_id;
    
    -- =====================================================
    -- DISQUALIFYING CONDITIONS (Hard stops)
    -- If ANY of these are true, application is INELIGIBLE
    -- =====================================================
    
    -- 1. Geographic eligibility (service area check)
    IF NOT is_in_service_area(v_submission.home_zip, v_submission.home_city) THEN
        v_disqualifiers := array_append(v_disqualifiers, 'outside_service_area');
        v_is_eligible := FALSE;
    END IF;
    
    -- 2. Homeowner status required
    IF v_submission.owns_home = FALSE THEN
        v_disqualifiers := array_append(v_disqualifiers, 'not_homeowner');
        v_is_eligible := FALSE;
    END IF;
    
    -- 3. Primary residence required
    IF v_submission.is_primary_residence = FALSE THEN
        v_disqualifiers := array_append(v_disqualifiers, 'not_primary_residence');
        v_is_eligible := FALSE;
    END IF;
    
    -- 4. Income eligibility (upper bound only - no lower bound)
    -- NOTE: We accept ANY income level, but track for grant reporting
    -- Hard disqualification only if income exceeds ALL partner maximums
    IF v_submission.gross_annual_income > 120000 THEN -- 120% AMI for area
        v_warnings := array_append(v_warnings, 'income_above_threshold_may_limit_orgs');
        -- NOT a hard disqualifier - just limits which orgs can serve
    END IF;
    
    -- 5. Property type restrictions (mobile homes require lot ownership)
    IF v_submission.home_type = 'mobile' AND v_submission.owns_lot = FALSE THEN
        v_disqualifiers := array_append(v_disqualifiers, 'mobile_home_no_lot_ownership');
        v_is_eligible := FALSE;
    END IF;
    
    -- 6. Previous assistance check (prevents duplicate services)
    IF has_received_previous_assistance(v_submission.applicant_first_name, 
                                        v_submission.applicant_last_name,
                                        v_submission.home_address) THEN
        v_disqualifiers := array_append(v_disqualifiers, 'previous_assistance_received');
        v_is_eligible := FALSE;
    END IF;
    
    -- 7. Age requirement (must be 18+ or have guardian)
    IF v_submission.applicant_dob > CURRENT_DATE - INTERVAL '18 years' THEN
        v_warnings := array_append(v_warnings, 'applicant_under_18_guardian_required');
        -- Not a hard disqualifier if guardian information provided
        IF v_submission.guardian_consent IS NULL OR v_submission.guardian_consent = FALSE THEN
            v_disqualifiers := array_append(v_disqualifiers, 'under_18_no_guardian');
            v_is_eligible := FALSE;
        END IF;
    END IF;
    
    -- =====================================================
    -- CONDITIONAL ELIGIBILITY (Org-specific matching)
    -- These affect which organizations can serve, not overall eligibility
    -- =====================================================
    
    -- Store eligibility results for each organization
    INSERT INTO eligibility_results (submission_id, organization_id, match_score, is_eligible)
    SELECT 
        p_submission_id,
        co.id,
        calculate_match_score(p_submission_id, co.id),
        CASE WHEN calculate_match_score(p_submission_id, co.id) >= 50 THEN TRUE ELSE FALSE END
    FROM coalition_organizations co
    WHERE co.is_active = TRUE;
    
    -- =====================================================
    -- PREPARE RESULT
    -- =====================================================
    
    -- Update submission status based on eligibility
    UPDATE intake_submissions 
    SET 
        submission_status = CASE 
            WHEN v_is_eligible THEN 'ELIGIBLE'
            ELSE 'INELIGIBLE'
        END,
        eligibility_checked_at = CURRENT_TIMESTAMP,
        disqualification_reasons = v_disqualifiers,
        eligibility_warnings = v_warnings
    WHERE id = p_submission_id;
    
    -- Return comprehensive eligibility result
    v_eligibility_result := jsonb_build_object(
        'is_eligible', v_is_eligible,
        'disqualifiers', v_disqualifiers,
        'warnings', v_warnings,
        'eligible_organizations', (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'organization_id', er.organization_id,
                    'organization_name', co.organization_name,
                    'match_score', er.match_score
                )
            )
            FROM eligibility_results er
            JOIN coalition_organizations co ON er.organization_id = co.id
            WHERE er.submission_id = p_submission_id AND er.is_eligible = TRUE
        ),
        'checked_at', CURRENT_TIMESTAMP
    );
    
    RETURN v_eligibility_result;
END;
$$ LANGUAGE plpgsql;

-- Helper functions for eligibility checks
CREATE OR REPLACE FUNCTION is_in_service_area(p_zip VARCHAR, p_city VARCHAR)
RETURNS BOOLEAN AS $$
BEGIN
    -- Service area: Buncombe, Madison, Henderson, Haywood counties
    RETURN p_zip IN ('28801','28803','28804','28805','28806','28711','28715','28716','28778','28787')
        OR p_city ILIKE '%Asheville%'
        OR p_city ILIKE '%Black Mountain%'
        OR p_city ILIKE '%Weaverville%'
        OR p_city ILIKE '%Marshall%'
        OR p_city ILIKE '%Hendersonville%'
        OR p_city ILIKE '%Waynesville%';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION has_received_previous_assistance(
    p_first_name VARCHAR, 
    p_last_name VARCHAR, 
    p_address VARCHAR
)
RETURNS BOOLEAN AS $$
BEGIN
    -- Check for existing completed cases at same address or same name
    RETURN EXISTS (
        SELECT 1 FROM cases c
        JOIN intake_submissions s ON c.submission_id = s.id
        WHERE c.status_id IN (SELECT id FROM case_statuses WHERE status_code IN ('COMPLETED'))
          AND (s.home_address ILIKE p_address
               OR (s.applicant_first_name ILIKE p_first_name 
                   AND s.applicant_last_name ILIKE p_last_name))
    );
END;
$$ LANGUAGE plpgsql;

-- Match score calculation (0-100)
CREATE OR REPLACE FUNCTION calculate_match_score(p_submission_id INTEGER, p_organization_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
    v_score INTEGER := 100; -- Start at 100, subtract for mismatches
    v_submission RECORD;
    v_org_criteria RECORD;
BEGIN
    SELECT * INTO v_submission FROM intake_submissions WHERE id = p_submission_id;
    
    -- Check each criterion and reduce score for mismatches
    FOR v_org_criteria IN 
        SELECT * FROM organization_eligibility_rules 
        WHERE organization_id = p_organization_id AND is_active = TRUE
    LOOP
        CASE v_org_criteria.criteria_type_id
            WHEN (SELECT id FROM criteria_types WHERE type_code = 'income_max') THEN
                IF v_submission.gross_annual_income > v_org_criteria.rule_value::INTEGER THEN
                    v_score := v_score - 20;
                END IF;
                
            WHEN (SELECT id FROM criteria_types WHERE type_code = 'geography_zipcodes') THEN
                IF v_submission.home_zip != ANY(string_to_array(v_org_criteria.rule_value, ',')) THEN
                    v_score := v_score - 30;
                END IF;
                
            WHEN (SELECT id FROM criteria_types WHERE type_code = 'urgent_only') THEN
                -- Check if submission has urgent conditions
                IF v_org_criteria.rule_value = 'true' THEN
                    IF NOT EXISTS (
                        SELECT 1 FROM submission_repair_categories src
                        JOIN repair_categories rc ON src.category_id = rc.id
                        WHERE src.submission_id = p_submission_id
                          AND rc.category_code IN ('unable_to_stay', 'no_hvac', 'no_potable_water')
                    ) THEN
                        v_score := v_score - 50;
                    END IF;
                END IF;
                
            -- Add more criteria as needed
            ELSE
                -- Unknown criteria, ignore
                CONTINUE;
        END CASE;
    END LOOP;
    
    -- Ensure score is between 0 and 100
    RETURN GREATEST(0, LEAST(100, v_score));
END;
$$ LANGUAGE plpgsql;
-- END sql/eligibility-tracker.sql

-- ----------------------------------------------------------------
-- BEGIN sql/feedback-collection.sql
-- ----------------------------------------------------------------
-- Beneficiary feedback form
CREATE TABLE volunteer_feedback (
    id SERIAL PRIMARY KEY,
    quest_id UUID REFERENCES quests(id),
    volunteer_id INTEGER REFERENCES system_users(id),
    beneficiary_id INTEGER REFERENCES intake_submissions(id),
    
    -- Rating categories (1-5 stars)
    quality_rating INTEGER CHECK (quality_rating BETWEEN 1 AND 5),
    timeliness_rating INTEGER CHECK (timeliness_rating BETWEEN 1 AND 5),
    professionalism_rating INTEGER CHECK (professionalism_rating BETWEEN 1 AND 5),
    
    -- Text feedback
    comments TEXT,
    would_recommend BOOLEAN,
    
    -- Photo evidence (optional)
    photo_urls TEXT[],
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Calculated reputation delta
    reputation_delta INTEGER,
    
    UNIQUE(quest_id, volunteer_id, beneficiary_id)
);
-- END sql/feedback-collection.sql

-- ----------------------------------------------------------------
-- BEGIN sql/submission-handler.sql
-- ----------------------------------------------------------------
-- =====================================================
-- SUBMISSION HANDLER WITH OPTIONAL ACCOUNT CREATION
-- =====================================================

-- Main submission function
CREATE OR REPLACE FUNCTION submit_intake_application(
    -- Form data (all fields from intake.html)
    p_form_data JSONB,
    -- Optional account creation
    p_create_account BOOLEAN DEFAULT FALSE,
    p_email VARCHAR(255) DEFAULT NULL,
    p_password_hash VARCHAR(255) DEFAULT NULL, -- bcrypt hash from PHP, not plain text
    -- Metadata
    p_ip_address INET DEFAULT NULL,
    p_user_agent TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_submission_id INTEGER;
    v_user_id INTEGER;
    v_case_id INTEGER;
    v_result JSONB;
    v_eligibility_result JSONB;
BEGIN
        -- 1. Insert the intake submission
        INSERT INTO intake_submissions (
            language, is_referral, referrer_name, referrer_organization,
            referrer_email, referrer_notes, consent_agreed,
            applicant_first_name, applicant_last_name, applicant_dob,
            applicant_dob_unknown, home_phone, cell_phone, contact_email,
            other_contact_method_description, contact_notes,
            home_address, home_city, home_state, home_zip,
            is_primary_residence, receives_different_mail,
            mail_address, mail_city, mail_state, mail_zip,
            home_type, year_built, move_in_date, owns_home, owns_lot,
            insurance_provider, lived_one_year, household_size, household_adults,
            additional_repair_details, helene_related, has_income,
            income_method, gross_annual_income, income_docs_method,
            submission_status, submitted_at, ip_address, user_agent
        ) VALUES (
            p_form_data->>'language',
            (p_form_data->>'isReferral') = 'yes',
            p_form_data->>'referrerName',
            p_form_data->>'referrerOrganization',
            p_form_data->>'referrerEmail',
            p_form_data->>'referrerNotes',
            (p_form_data->>'consentAgree') = 'yes',
            p_form_data->>'applicantFirstName',
            p_form_data->>'applicantLastName',
            (p_form_data->>'applicantDob')::DATE,
            (p_form_data->>'applicantDobUnknown') = 'yes',
            p_form_data->>'homePhone',
            p_form_data->>'cellPhone',
            p_form_data->>'contactEmail',
            p_form_data->>'otherContactMethod',
            p_form_data->>'contactNotes',
            p_form_data->>'homeAddress',
            p_form_data->>'homeCity',
            p_form_data->>'homeState',
            p_form_data->>'homeZip',
            (p_form_data->>'isPrimaryResidence') = 'yes',
            (p_form_data->>'receivesDifferentMail') = 'yes',
            p_form_data->>'mailAddress',
            p_form_data->>'mailCity',
            p_form_data->>'mailState',
            p_form_data->>'mailZip',
            p_form_data->>'homeType',
            (p_form_data->>'yearBuilt')::INTEGER,
            (p_form_data->>'moveInDate')::DATE,
            (p_form_data->>'ownsHome') = 'yes',
            (p_form_data->>'ownsLot') = 'yes',
            p_form_data->>'insuranceProvider',
            (p_form_data->>'livedOneYear') = 'yes',
            (p_form_data->>'householdSize')::INTEGER,
            (p_form_data->>'householdAdults')::INTEGER,
            p_form_data->>'additionalRepairDetails',
            (p_form_data->>'heleneRelated') = 'yes',
            (p_form_data->>'haveIncome') = 'yes',
            p_form_data->>'incomeMethod',
            (p_form_data->>'grossAnnualIncome')::DECIMAL,
            p_form_data->>'incomeDocsMethod',
            'PENDING_ELIGIBILITY', -- Initial status
            CURRENT_TIMESTAMP,
            p_ip_address,
            p_user_agent
        )
        RETURNING id INTO v_submission_id;
        
        -- 2. Insert contact methods (preferredContact[] array)
        IF p_form_data->'preferredContact' IS NOT NULL THEN
            INSERT INTO submission_contact_methods (submission_id, method_id)
            SELECT v_submission_id, cm.id
            FROM jsonb_array_elements_text(p_form_data->'preferredContact') AS method_code
            JOIN contact_methods cm ON cm.method_code = method_code;
        END IF;
        
        -- 3. Insert household attributes
        IF p_form_data->'householdAttributes' IS NOT NULL THEN
            INSERT INTO submission_household_attributes (submission_id, attribute_id)
            SELECT v_submission_id, ha.id
            FROM jsonb_array_elements_text(p_form_data->'householdAttributes') AS attr_name
            JOIN household_attributes ha ON ha.attribute_name = attr_name;
        END IF;
        
        -- 4. Insert repair categories
        IF p_form_data->'repairCategory' IS NOT NULL THEN
            INSERT INTO submission_repair_categories (submission_id, category_id)
            SELECT v_submission_id, rc.id
            FROM jsonb_array_elements_text(p_form_data->'repairCategory') AS cat_code
            JOIN repair_categories rc ON rc.category_code = cat_code;
        END IF;
        
        -- 5. Insert repair requests (dynamic rows)
        IF p_form_data->'repairNeeds' IS NOT NULL THEN
            FOR i IN 0..jsonb_array_length(p_form_data->'repairNeeds') - 1 LOOP
                INSERT INTO repair_requests (
                    submission_id, repair_need, priority, sort_order
                ) VALUES (
                    v_submission_id,
                    p_form_data->'repairNeeds'->i->>'need',
                    (p_form_data->'repairNeeds'->i->>'priority')::INTEGER,
                    i
                );
            END LOOP;
        END IF;
        
        -- 6. Insert income records if using calculator
        IF p_form_data->'incomeRecords' IS NOT NULL THEN
            INSERT INTO income_records (
                submission_id, whose_income, income_source, frequency, amount
            )
            SELECT 
                v_submission_id,
                record->>'whose',
                record->>'source',
                record->>'frequency',
                (record->>'amount')::DECIMAL
            FROM jsonb_array_elements(p_form_data->'incomeRecords') AS record;
        END IF;
        
        -- 7. Optional: Create requestor account
        IF p_create_account = TRUE AND p_email IS NOT NULL THEN
            -- Check if user already exists
            SELECT id INTO v_user_id FROM system_users WHERE email = p_email;
            
            IF v_user_id IS NULL THEN
                -- Create new user
                INSERT INTO system_users (email, full_name, password_hash, created_at)
                VALUES (
                    p_email,
                    p_form_data->>'applicantFirstName' || ' ' || p_form_data->>'applicantLastName',
                    crypt(p_password_hash, gen_salt('bf')), -- bcrypt hash
                    CURRENT_TIMESTAMP
                )
                RETURNING id INTO v_user_id;
                
                -- Assign Requestor role
                INSERT INTO user_role_assignments (user_id, organization_id, role_id, assigned_at)
                SELECT v_user_id, NULL, id, CURRENT_TIMESTAMP
                FROM roles WHERE role_code = 'REQUESTOR';
                
                -- Create requestor profile
                INSERT INTO requestor_profiles (user_id, created_at)
                VALUES (v_user_id, CURRENT_TIMESTAMP);
                
            END IF;
            
            -- Link submission to user
            UPDATE intake_submissions 
            SET requestor_user_id = v_user_id 
            WHERE id = v_submission_id;
        END IF;
        
        -- 8. Run eligibility checker (see Phase 2)
        v_eligibility_result := check_eligibility(v_submission_id);
        
        -- 9. ANCHOR: Register application (always, regardless of eligibility)
        PERFORM register_application_anchor(v_submission_id, v_eligibility_result);
        
        -- 10. Trigger notifications (see Phase 3)
        PERFORM trigger_new_application_notifications(v_submission_id);
        
        -- 11. Add to review queue
        INSERT INTO review_queue (submission_id, status, queued_at, fifo_order)
        VALUES (
            v_submission_id, 
            CASE WHEN (v_eligibility_result->>'is_eligible')::BOOLEAN 
                 THEN 'PENDING_REVIEW' 
                 ELSE 'INELIGIBLE' 
            END,
            CURRENT_TIMESTAMP,
            nextval('fifo_sequence')
        );
        
        -- Build success response (caller's transaction commits implicitly)
        v_result := jsonb_build_object(
            'success', true,
            'submission_id', v_submission_id,
            'case_number', (SELECT case_number FROM cases WHERE submission_id = v_submission_id),
            'eligibility', v_eligibility_result,
            'has_account', p_create_account,
            'dashboard_url', CASE WHEN p_create_account 
                THEN '/dashboard/' || v_user_id 
                ELSE '/status/' || v_submission_id 
            END
        );
        
        RETURN v_result;

EXCEPTION WHEN OTHERS THEN
    -- plpgsql functions auto-rollback when an exception propagates out of
    -- the block; returning here keeps the caller (PHP) happy with a
    -- structured error instead of a 500.
    RETURN jsonb_build_object(
        'success', false,
        'error', SQLERRM,
        'detail', SQLSTATE
    );
END;
$$ LANGUAGE plpgsql;
-- END sql/submission-handler.sql

-- ----------------------------------------------------------------
-- BEGIN sql/staff-dashboard-queue.sql
-- ----------------------------------------------------------------
-- =====================================================
-- STAFF QUEUE VIEW
-- For Admin, Caseworker, Project Manager dashboards
-- =====================================================

CREATE OR REPLACE VIEW staff_review_queue AS
SELECT 
    rq.fifo_order,
    s.id AS submission_id,
    s.applicant_first_name,
    s.applicant_last_name,
    s.home_address,
    s.submitted_at,
    s.helene_related,
    rq.status,
    rq.priority_score,
    -- Calculate time in queue
    EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - rq.queued_at))/3600 AS hours_in_queue,
    -- Get primary repair issue. submission_repair_categories has no id column
    -- (composite PK on submission_id+category_id), so order by category_id for
    -- a deterministic pick.
    (SELECT rc.category_label
     FROM submission_repair_categories src
     JOIN repair_categories rc ON src.category_id = rc.id
     WHERE src.submission_id = s.id
     ORDER BY src.category_id ASC LIMIT 1) AS primary_issue,
    -- Count of urgent conditions
    (SELECT COUNT(*) 
     FROM submission_repair_categories src
     JOIN repair_categories rc ON src.category_id = rc.id
     WHERE src.submission_id = s.id
       AND rc.category_code IN ('unable_to_stay', 'no_hvac', 'no_potable_water')) AS urgent_count,
    -- Eligibility result
    er.is_eligible,
    er.match_score AS best_match_score,
    co.organization_name AS best_match_org
FROM review_queue rq
JOIN intake_submissions s ON rq.submission_id = s.id
LEFT JOIN eligibility_results er ON s.id = er.submission_id
LEFT JOIN coalition_organizations co ON er.organization_id = co.id
WHERE rq.status IN ('PENDING_REVIEW', 'IN_REVIEW')
ORDER BY rq.priority_score DESC, rq.fifo_order ASC;

-- Role-specific queue filters
CREATE OR REPLACE VIEW admin_review_queue AS
SELECT * FROM staff_review_queue;

CREATE OR REPLACE VIEW caseworker_review_queue AS
SELECT * FROM staff_review_queue 
WHERE is_eligible = TRUE; -- Caseworkers only see eligible applications

CREATE OR REPLACE VIEW project_manager_review_queue AS
SELECT * FROM staff_review_queue 
WHERE is_eligible = TRUE 
  AND primary_issue IS NOT NULL; -- PMs see eligible with identified issues
-- END sql/staff-dashboard-queue.sql

-- ----------------------------------------------------------------
-- BEGIN sql/metric-tracking.sql
-- ----------------------------------------------------------------
-- =====================================================
-- ARCHR METRIC TRACKING SYSTEM
-- Live Dashboard Metrics with Algorithm Documentation
-- =====================================================
-- 
-- This file contains all 28 metrics organized into three dashboard sections:
--   1. Dashboard Past Week (7 metrics)
--   2. Dashboard All Time (8 metrics) 
--   3. Organization Specific Dashboard (13 metrics)
--
-- Each metric includes:
--   - Metric name and description
--   - Algorithm explanation
--   - Logic notes for developers
--   - Prepared SQL statement
--   - Expected output format
--
-- Last Updated: 2024-12-01
-- =====================================================

-- =====================================================
-- HELPER FUNCTIONS (Reusable across all metrics)
-- =====================================================

-- Function to get date range for "past week" (last 7 complete days, not including today)
CREATE OR REPLACE FUNCTION get_past_week_range()
RETURNS TABLE(start_date DATE, end_date DATE) AS $$
BEGIN
    start_date := (CURRENT_DATE - INTERVAL '7 days')::DATE;
    end_date := (CURRENT_DATE - INTERVAL '1 day')::DATE;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- Function to get date range for "current week to date" (including partial week)
CREATE OR REPLACE FUNCTION get_current_week_range()
RETURNS TABLE(start_date DATE, end_date DATE) AS $$
BEGIN
    start_date := DATE_TRUNC('week', CURRENT_DATE)::DATE;
    end_date := CURRENT_DATE;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- Helper view for completed assessments with valid triage scores
-- property_assessments uses `id` as its PK; expose it as assessment_id for
-- downstream consumers. assessment_completed_at is populated when the
-- assessor marks the visit complete (see role-based-access.sql).
CREATE OR REPLACE VIEW completed_assessments_with_triage AS
SELECT
    pa.case_id,
    pa.id AS assessment_id,
    pa.total_estimate,
    pa.priority_repairs,
    c.submission_id,
    s.helene_related,
    -- Calculate triage score based on: urgency (40%) + estimate size (30%) + Helene priority (30%)
    -- Formula: (urgent_conditions * 40) + (estimate_percentile * 30) + (helene_bonus * 30)
    -- Where urgent_conditions count is normalized to 0-100 scale
    LEAST(
        COALESCE(
            (SELECT COUNT(*) FROM submission_repair_categories src 
             JOIN repair_categories rc ON src.category_id = rc.id 
             WHERE src.submission_id = s.id 
             AND rc.category_code IN ('unable_to_stay', 'no_hvac', 'no_potable_water', 
                                       'no_bathroom', 'no_kitchen', 'open_to_elements', 'no_entry')
            ) * 12.5, 0
        ) + 
        COALESCE(
            (pa.total_estimate / NULLIF((SELECT MAX(total_estimate) FROM property_assessments), 0)) * 30, 0
        ) +
        CASE WHEN s.helene_related THEN 30 ELSE 0 END,
    100) AS triage_score
FROM property_assessments pa
JOIN cases c ON pa.case_id = c.id
JOIN intake_submissions s ON c.submission_id = s.id
WHERE pa.assessment_completed_at IS NOT NULL;


-- =====================================================
-- SECTION 1: DASHBOARD PAST WEEK METRICS
-- =====================================================

/* ------------------------------------------------------------------------
   METRIC 1: Total Applications
   ------------------------------------------------------------------------
   DESCRIPTION: Number of intake applications submitted in the past 7 days
   
   ALGORITHM: COUNT all intake_submissions where submitted_at falls within
              the past 7 complete days (excluding today to avoid partial data)
   
   LOGIC NOTES: 
   - Uses get_past_week_range() to get consistent date boundaries
   - Excludes test/debug submissions (is_test flag if available)
   - Includes all statuses (no filtering by approval/rejection)
   
   BUSINESS VALUE: Measures application volume and intake demand
   ------------------------------------------------------------------------ */
WITH past_week AS (SELECT * FROM get_past_week_range())
SELECT 
    COUNT(*) AS total_applications
FROM intake_submissions s, past_week pw
WHERE s.submitted_at::DATE BETWEEN pw.start_date AND pw.end_date
  AND (s.is_test IS NULL OR s.is_test = false);

-- PREPARED STATEMENT VERSION:
PREPARE metric_total_applications_past_week AS
    WITH past_week AS (SELECT * FROM get_past_week_range())
    SELECT COUNT(*) AS total_applications
    FROM intake_submissions s, past_week pw
    WHERE s.submitted_at::DATE BETWEEN pw.start_date AND pw.end_date
      AND (s.is_test IS NULL OR s.is_test = false);
-- EXECUTE metric_total_applications_past_week;


/* ------------------------------------------------------------------------
   METRIC 2: Assessments Assigned
   ------------------------------------------------------------------------
   DESCRIPTION: Number of property assessments assigned to assessors in the past week
   
   ALGORITHM: COUNT property_assessments where assigned_at (or created_at for 
              new assessments) is within past 7 days
   
   LOGIC NOTES:
   - An assessment is "assigned" when it has an assessor_id and assigned_at date
   - If assigned_at is NULL, use created_at as proxy
   - Excludes completed assessments from this count (they have their own metric)
   
   BUSINESS VALUE: Tracks assessment workload and assessor capacity
   ------------------------------------------------------------------------ */
WITH past_week AS (SELECT * FROM get_past_week_range())
SELECT 
    COUNT(DISTINCT pa.id) AS assessments_assigned
FROM property_assessments pa, past_week pw
CROSS JOIN cases c
WHERE pa.case_id = c.id
  AND (pa.assigned_at IS NOT NULL AND pa.assigned_at::DATE BETWEEN pw.start_date AND pw.end_date
       OR pa.assigned_at IS NULL AND pa.created_at::DATE BETWEEN pw.start_date AND pw.end_date);

PREPARE metric_assessments_assigned_past_week AS
    WITH past_week AS (SELECT * FROM get_past_week_range())
    SELECT COUNT(DISTINCT pa.id) AS assessments_assigned
    FROM property_assessments pa, past_week pw
    CROSS JOIN cases c
    WHERE pa.case_id = c.id
      AND (pa.assigned_at IS NOT NULL AND pa.assigned_at::DATE BETWEEN pw.start_date AND pw.end_date
           OR pa.assigned_at IS NULL AND pa.created_at::DATE BETWEEN pw.start_date AND pw.end_date);
-- EXECUTE metric_assessments_assigned_past_week;


/* ------------------------------------------------------------------------
   METRIC 3: Assessments Completed
   ------------------------------------------------------------------------
   DESCRIPTION: Number of property assessments completed in the past 7 days
   
   ALGORITHM: COUNT property_assessments where assessment_completed_at is 
              within past 7 days
   
   LOGIC NOTES:
   - "Completed" means the assessment has a non-NULL assessment_completed_at
   - Assessment may have been assigned weeks ago but completed this week
   - This tracks throughput, not just new work
   
   BUSINESS VALUE: Measures assessment completion rate and team productivity
   ------------------------------------------------------------------------ */
WITH past_week AS (SELECT * FROM get_past_week_range())
SELECT 
    COUNT(*) AS assessments_completed
FROM property_assessments pa, past_week pw
WHERE pa.assessment_completed_at::DATE BETWEEN pw.start_date AND pw.end_date;

PREPARE metric_assessments_completed_past_week AS
    WITH past_week AS (SELECT * FROM get_past_week_range())
    SELECT COUNT(*) AS assessments_completed
    FROM property_assessments pa, past_week pw
    WHERE pa.assessment_completed_at::DATE BETWEEN pw.start_date AND pw.end_date;
-- EXECUTE metric_assessments_completed_past_week;


/* ------------------------------------------------------------------------
   METRIC 4: Average Triage Score
   ------------------------------------------------------------------------
   DESCRIPTION: Average triage score of assessments completed in the past week
   
   ALGORITHM: AVG of triage_score from completed assessments in past week
   
   TRIAGE SCORE FORMULA (0-100):
   - Urgent conditions (40% max): Each urgent condition = 12.5 points
     * Conditions: unable_to_stay, no_hvac, no_potable_water, no_bathroom, 
                   no_kitchen, open_to_elements, no_entry (7 total = 87.5 max, capped at 40)
   - Estimate size (30% max): Normalized by max estimate in system
   - Helene-related (30% max): +30 if damage from Hurricane Helene
   
   LOGIC NOTES:
   - Higher score = more urgent need (prioritize these cases)
   - Capped at 100 total points
   - Uses helper view completed_assessments_with_triage for consistency
   
   BUSINESS VALUE: Prioritization tool for resource allocation
   ------------------------------------------------------------------------ */
WITH past_week AS (SELECT * FROM get_past_week_range()),
recent_assessments AS (
    -- Use ANSI JOINs throughout; mixing comma-joins with explicit JOIN ON
    -- breaks scoping of `pa` for the ON clause in PostgreSQL.
    SELECT pa.id, cat.triage_score
    FROM property_assessments pa
    JOIN completed_assessments_with_triage cat ON pa.id = cat.assessment_id
    CROSS JOIN past_week pw
    WHERE pa.assessment_completed_at::DATE BETWEEN pw.start_date AND pw.end_date
)
SELECT
    ROUND(AVG(triage_score), 1) AS avg_triage_score,
    MIN(triage_score) AS min_triage_score,
    MAX(triage_score) AS max_triage_score,
    COUNT(*) AS assessments_in_calc
FROM recent_assessments;

PREPARE metric_avg_triage_score_past_week AS
    WITH past_week AS (SELECT * FROM get_past_week_range()),
    recent_assessments AS (
        SELECT pa.id, cat.triage_score
        FROM property_assessments pa
        JOIN completed_assessments_with_triage cat ON pa.id = cat.assessment_id
        CROSS JOIN past_week pw
        WHERE pa.assessment_completed_at::DATE BETWEEN pw.start_date AND pw.end_date
    )
    SELECT ROUND(AVG(triage_score), 1) AS avg_triage_score
    FROM recent_assessments;
-- EXECUTE metric_avg_triage_score_past_week;


/* ------------------------------------------------------------------------
   METRIC 5: Total # of Individuals (from household size)
   ------------------------------------------------------------------------
   DESCRIPTION: Sum of household sizes from applications submitted in past week
   
   ALGORITHM: SUM(household_size) for all intake submissions in past week
   
   LOGIC NOTES:
   - Household size is self-reported by applicant on Page 5 of intake form
   - This is total people served, not number of households
   - Important for grant reporting and measuring community impact
   
   BUSINESS VALUE: Measures total individuals served/impacted by services
   ------------------------------------------------------------------------ */
WITH past_week AS (SELECT * FROM get_past_week_range())
SELECT 
    SUM(s.household_size) AS total_individuals_served,
    COUNT(*) AS total_households,
    ROUND(AVG(s.household_size), 1) AS avg_household_size
FROM intake_submissions s, past_week pw
WHERE s.submitted_at::DATE BETWEEN pw.start_date AND pw.end_date
  AND s.household_size IS NOT NULL;

PREPARE metric_total_individuals_past_week AS
    WITH past_week AS (SELECT * FROM get_past_week_range())
    SELECT SUM(s.household_size) AS total_individuals_served
    FROM intake_submissions s, past_week pw
    WHERE s.submitted_at::DATE BETWEEN pw.start_date AND pw.end_date
      AND s.household_size IS NOT NULL;
-- EXECUTE metric_total_individuals_past_week;


/* ------------------------------------------------------------------------
   METRIC 6: Income Breakdown
   ------------------------------------------------------------------------
   DESCRIPTION: Distribution of applications by income bracket (past week only)
   
   ALGORITHM: Categorize gross_annual_income into brackets and count
   
   INCOME BRACKETS:
   - $0 (Zero income affidavit)
   - $1 - $15,000 (Extremely low income)
   - $15,001 - $30,000 (Very low income)  
   - $30,001 - $50,000 (Low income)
   - $50,001 - $75,000 (Moderate income)
   - $75,001+ (Above moderate)
   
   LOGIC NOTES:
   - Uses gross_annual_income from Page 12 if available
   - If has_income = false, categorize as $0
   - If income_method = 'calculator', uses sum of income_records annualized
   
   BUSINESS VALUE: Grant eligibility reporting and needs assessment
   ------------------------------------------------------------------------ */
WITH past_week AS (SELECT * FROM get_past_week_range()),
income_data AS (
    SELECT 
        s.id,
        s.has_income,
        s.gross_annual_income,
        CASE 
            WHEN s.has_income = false THEN 0
            WHEN s.gross_annual_income IS NOT NULL THEN s.gross_annual_income
            ELSE (
                SELECT SUM(
                    CASE frequency
                        WHEN 'weekly' THEN amount * 52
                        WHEN 'biweekly' THEN amount * 26
                        WHEN 'monthly' THEN amount * 12
                        WHEN 'annually' THEN amount
                        ELSE amount
                    END
                ) FROM income_records ir WHERE ir.submission_id = s.id
            )
        END AS calculated_income
    FROM intake_submissions s, past_week pw
    WHERE s.submitted_at::DATE BETWEEN pw.start_date AND pw.end_date
)
SELECT 
    CASE 
        WHEN calculated_income = 0 THEN '$0 (Zero income)'
        WHEN calculated_income <= 15000 THEN '$1 - $15,000 (Extremely low)'
        WHEN calculated_income <= 30000 THEN '$15,001 - $30,000 (Very low)'
        WHEN calculated_income <= 50000 THEN '$30,001 - $50,000 (Low)'
        WHEN calculated_income <= 75000 THEN '$50,001 - $75,000 (Moderate)'
        ELSE '$75,001+ (Above moderate)'
    END AS income_bracket,
    COUNT(*) AS application_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM income_data
GROUP BY 
    CASE 
        WHEN calculated_income = 0 THEN '$0 (Zero income)'
        WHEN calculated_income <= 15000 THEN '$1 - $15,000 (Extremely low)'
        WHEN calculated_income <= 30000 THEN '$15,001 - $30,000 (Very low)'
        WHEN calculated_income <= 50000 THEN '$30,001 - $50,000 (Low)'
        WHEN calculated_income <= 75000 THEN '$50,001 - $75,000 (Moderate)'
        ELSE '$75,001+ (Above moderate)'
    END
ORDER BY MIN(calculated_income);

PREPARE metric_income_breakdown_past_week AS
    WITH past_week AS (SELECT * FROM get_past_week_range()),
    income_data AS (
        SELECT 
            s.id,
            CASE 
                WHEN s.has_income = false THEN 0
                WHEN s.gross_annual_income IS NOT NULL THEN s.gross_annual_income
                ELSE (
                    SELECT SUM(
                        CASE frequency
                            WHEN 'weekly' THEN amount * 52
                            WHEN 'biweekly' THEN amount * 26
                            WHEN 'monthly' THEN amount * 12
                            WHEN 'annually' THEN amount
                            ELSE amount
                        END
                    ) FROM income_records ir WHERE ir.submission_id = s.id
                )
            END AS calculated_income
        FROM intake_submissions s, past_week pw
        WHERE s.submitted_at::DATE BETWEEN pw.start_date AND pw.end_date
    )
    SELECT 
        CASE 
            WHEN calculated_income = 0 THEN '$0'
            WHEN calculated_income <= 15000 THEN '$1-15k'
            WHEN calculated_income <= 30000 THEN '$15k-30k'
            WHEN calculated_income <= 50000 THEN '$30k-50k'
            WHEN calculated_income <= 75000 THEN '$50k-75k'
            ELSE '$75k+'
        END AS bracket,
        COUNT(*) AS count
    FROM income_data
    GROUP BY 1
    ORDER BY MIN(calculated_income);
-- EXECUTE metric_income_breakdown_past_week;


/* ------------------------------------------------------------------------
   METRIC 7: County Breakdown
   ------------------------------------------------------------------------
   DESCRIPTION: Distribution of applications by county (past week only)
   
   ALGORITHM: Extract county from home_city or use home_county field, group by county
   
   LOGIC NOTES:
   - Primary service area: Buncombe County (Asheville)
   - Also tracks Madison, Henderson, Haywood, Transylvania, Yancey, Mitchell
   - Uses home_city to infer county for Buncombe (Asheville, Black Mountain, etc.)
   - Future improvement: add explicit home_county field to intake form
   
   BUSINESS VALUE: Geographic coverage analysis and resource planning
   ------------------------------------------------------------------------ */
WITH past_week AS (SELECT * FROM get_past_week_range()),
county_mapping AS (
    SELECT 
        s.id,
        s.home_city,
        s.home_zip,
        CASE 
            WHEN s.home_city ILIKE '%Asheville%' OR s.home_city ILIKE '%Black Mountain%' 
                 OR s.home_city ILIKE '%Weaverville%' OR s.home_city ILIKE '%Woodfin%'
                 OR s.home_city ILIKE '%Swannanoa%' OR s.home_zip IN ('28801','28803','28804','28805','28806','28711')
                THEN 'Buncombe'
            WHEN s.home_city ILIKE '%Mars Hill%' OR s.home_city ILIKE '%Marshall%' 
                 OR s.home_zip LIKE '287%' AND s.home_zip BETWEEN '28700' AND '28799'
                THEN 'Madison'
            WHEN s.home_city ILIKE '%Hendersonville%' OR s.home_zip LIKE '287%' 
                THEN 'Henderson'
            WHEN s.home_city ILIKE '%Waynesville%' OR s.home_city ILIKE '%Maggie Valley%'
                THEN 'Haywood'
            WHEN s.home_city ILIKE '%Brevard%' THEN 'Transylvania'
            WHEN s.home_city ILIKE '%Burnsville%' THEN 'Yancey'
            WHEN s.home_city ILIKE '%Spruce Pine%' THEN 'Mitchell'
            ELSE 'Other / Unknown'
        END AS county
    FROM intake_submissions s, past_week pw
    WHERE s.submitted_at::DATE BETWEEN pw.start_date AND pw.end_date
)
SELECT 
    county,
    COUNT(*) AS application_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM county_mapping
GROUP BY county
ORDER BY application_count DESC;

PREPARE metric_county_breakdown_past_week AS
    WITH past_week AS (SELECT * FROM get_past_week_range()),
    county_mapping AS (
        SELECT 
            CASE 
                WHEN s.home_city ILIKE '%Asheville%' OR s.home_zip IN ('28801','28803','28804','28805','28806') THEN 'Buncombe'
                WHEN s.home_city ILIKE '%Mars Hill%' OR s.home_city ILIKE '%Marshall%' THEN 'Madison'
                WHEN s.home_city ILIKE '%Hendersonville%' THEN 'Henderson'
                ELSE 'Other'
            END AS county
        FROM intake_submissions s, past_week pw
        WHERE s.submitted_at::DATE BETWEEN pw.start_date AND pw.end_date
    )
    SELECT county, COUNT(*) AS count
    FROM county_mapping
    GROUP BY county
    ORDER BY count DESC;
-- EXECUTE metric_county_breakdown_past_week;


/* ------------------------------------------------------------------------
   METRIC 8: Issue Type Pie
   ------------------------------------------------------------------------
   DESCRIPTION: Distribution of applications by primary repair issue type
   
   ALGORITHM: Count most frequently selected repair_category for each application
   
   LOGIC NOTES:
   - Each application can select multiple repair categories (Page 7)
   - This metric counts the PRIMARY issue (first selected or highest priority)
   - Categories: unable_to_stay, no_hvac, no_potable_water, no_bathroom, 
                 no_kitchen, open_to_elements, no_entry, accessibility, other_issue
   - For pie chart visualization
   
   BUSINESS VALUE: Resource planning (e.g., need more HVAC contractors vs roofers)
   ------------------------------------------------------------------------ */
WITH past_week AS (SELECT * FROM get_past_week_range()),
primary_issues AS (
    -- ANSI joins only; submission_repair_categories has a composite PK and no
    -- `id` column, so order by category_id for a deterministic primary pick.
    SELECT DISTINCT ON (s.id)
        s.id,
        rc.category_code,
        rc.category_label
    FROM intake_submissions s
    JOIN submission_repair_categories src ON s.id = src.submission_id
    JOIN repair_categories rc ON src.category_id = rc.id
    CROSS JOIN past_week pw
    WHERE s.submitted_at::DATE BETWEEN pw.start_date AND pw.end_date
    ORDER BY s.id, src.category_id
)
SELECT
    category_label AS issue_type,
    COUNT(*) AS application_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM primary_issues
GROUP BY category_code, category_label
ORDER BY application_count DESC;

PREPARE metric_issue_type_pie_past_week AS
    WITH past_week AS (SELECT * FROM get_past_week_range()),
    primary_issues AS (
        SELECT DISTINCT ON (s.id) s.id, rc.category_label
        FROM intake_submissions s
        JOIN submission_repair_categories src ON s.id = src.submission_id
        JOIN repair_categories rc ON src.category_id = rc.id
        CROSS JOIN past_week pw
        WHERE s.submitted_at::DATE BETWEEN pw.start_date AND pw.end_date
        ORDER BY s.id, src.category_id
    )
    SELECT category_label, COUNT(*) AS count
    FROM primary_issues
    GROUP BY category_label
    ORDER BY count DESC;
-- EXECUTE metric_issue_type_pie_past_week;


-- =====================================================
-- SECTION 2: DASHBOARD ALL TIME METRICS
-- =====================================================

/* ------------------------------------------------------------------------
   METRIC 9: Total Jobs
   ------------------------------------------------------------------------
   DESCRIPTION: Total number of work orders/jobs ever created
   
   ALGORITHM: COUNT all work_orders (distinct jobs, not individual tasks)
   
   LOGIC NOTES:
   - A "job" = one work_order record (may contain multiple tasks)
   - Counts all work orders regardless of status
   - Does not count applications that never became work orders
   
   BUSINESS VALUE: Total organizational output since inception
   ------------------------------------------------------------------------ */
SELECT 
    COUNT(*) AS total_jobs,
    COUNT(DISTINCT case_id) AS unique_cases_with_jobs
FROM work_orders;

PREPARE metric_total_jobs_all_time AS
    SELECT COUNT(*) AS total_jobs FROM work_orders;
-- EXECUTE metric_total_jobs_all_time;


/* ------------------------------------------------------------------------
   METRIC 10: Jobs in Progress
   ------------------------------------------------------------------------
   DESCRIPTION: Number of work orders currently in progress
   
   ALGORITHM: COUNT work_orders where status IN ('in_progress', 'assigned', 'planned')
   
   LOGIC NOTES:
   - Excludes completed, cancelled, and on_hold work orders
   - "In progress" means active work happening now
   - Does not include assessments or applications (different pipeline stage)
   
   BUSINESS VALUE: Current workload and capacity utilization
   ------------------------------------------------------------------------ */
SELECT 
    COUNT(*) AS jobs_in_progress,
    status,
    COUNT(*) AS count_by_status
FROM work_orders
WHERE status IN ('in_progress', 'assigned', 'planned')
GROUP BY ROLLUP(status)
ORDER BY status;

PREPARE metric_jobs_in_progress_all_time AS
    SELECT COUNT(*) AS jobs_in_progress
    FROM work_orders
    WHERE status IN ('in_progress', 'assigned', 'planned');
-- EXECUTE metric_jobs_in_progress_all_time;


/* ------------------------------------------------------------------------
   METRIC 11: Jobs Completed
   ------------------------------------------------------------------------
   DESCRIPTION: Number of work orders successfully completed
   
   ALGORITHM: COUNT work_orders where status = 'completed'
   
   LOGIC NOTES:
   - Completion requires final inspection and applicant sign-off
   - Work order completion triggers certificate generation
   - Does not include jobs that were cancelled or rejected
   
   BUSINESS VALUE: Total successful project completions (key performance metric)
   ------------------------------------------------------------------------ */
SELECT 
    COUNT(*) AS jobs_completed,
    DATE_TRUNC('month', actual_end_date) AS completion_month,
    COUNT(*) AS monthly_completions
FROM work_orders
WHERE status = 'completed'
  AND actual_end_date IS NOT NULL
GROUP BY DATE_TRUNC('month', actual_end_date)
ORDER BY completion_month DESC;

PREPARE metric_jobs_completed_all_time AS
    SELECT COUNT(*) AS jobs_completed FROM work_orders WHERE status = 'completed';
-- EXECUTE metric_jobs_completed_all_time;


/* ------------------------------------------------------------------------
   METRIC 12: Jobs Withdrawn/Rejected/Ineligible
   ------------------------------------------------------------------------
   DESCRIPTION: Number of work orders that were not completed (negative outcomes)
   
   ALGORITHM: COUNT work_orders where status IN ('cancelled', 'rejected') 
              OR applications where final_status = 'denied' or 'withdrawn'
   
   LOGIC NOTES:
   - Captures all applications that didn't result in completed work
   - Categories: Withdrawn (applicant withdrew), Rejected (by organization), 
                 Ineligible (screened out), Cancelled (after start)
   - Important for understanding pipeline leakage
   
   BUSINESS VALUE: Quality of intake screening and resource efficiency
   ------------------------------------------------------------------------ */
SELECT 
    'Withdrawn' AS outcome_type,
    COUNT(*) AS count
FROM intake_submissions
WHERE submission_status = 'withdrawn'
UNION ALL
SELECT 
    'Rejected by Org' AS outcome_type,
    COUNT(*) AS count
FROM application_assignments aa
JOIN intake_submissions s ON aa.submission_id = s.id
WHERE aa.status = 'rejected'
  AND s.submission_status != 'withdrawn'
UNION ALL
SELECT 
    'Ineligible' AS outcome_type,
    COUNT(*) AS count
FROM intake_submissions
WHERE submission_status = 'denied'
  AND submission_status NOT IN ('withdrawn', 'approved')
UNION ALL
SELECT 
    'Cancelled Work Order' AS outcome_type,
    COUNT(*) AS count
FROM work_orders
WHERE status = 'cancelled';

PREPARE metric_jobs_negative_outcomes_all_time AS
    SELECT 
        SUM(CASE WHEN submission_status = 'withdrawn' THEN 1 ELSE 0 END) AS withdrawn,
        SUM(CASE WHEN submission_status = 'denied' THEN 1 ELSE 0 END) AS ineligible
    FROM intake_submissions;
-- EXECUTE metric_jobs_negative_outcomes_all_time;


/* ------------------------------------------------------------------------
   METRIC 13: Average Job Cost
   ------------------------------------------------------------------------
   DESCRIPTION: Average cost of completed jobs (actual, not estimated)
   
   ALGORITHM: AVG(total_actual_cost) for completed work_orders
   
   LOGIC NOTES:
   - Uses total_actual_cost from cases table (sum of all expenses)
   - Only includes COMPLETED jobs (final actual cost known)
   - Excludes jobs with zero cost (data errors)
   
   BUSINESS VALUE: Budget planning and cost forecasting
   ------------------------------------------------------------------------ */
SELECT 
    ROUND(AVG(c.total_actual_cost), 2) AS avg_job_cost,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY c.total_actual_cost) AS median_job_cost,
    MIN(c.total_actual_cost) AS min_job_cost,
    MAX(c.total_actual_cost) AS max_job_cost,
    COUNT(*) AS number_of_jobs,
    SUM(c.total_actual_cost) AS total_spent
FROM cases c
JOIN work_orders wo ON c.id = wo.case_id
WHERE wo.status = 'completed'
  AND c.total_actual_cost IS NOT NULL
  AND c.total_actual_cost > 0;

PREPARE metric_avg_job_cost_all_time AS
    SELECT ROUND(AVG(c.total_actual_cost), 2) AS avg_job_cost
    FROM cases c
    JOIN work_orders wo ON c.id = wo.case_id
    WHERE wo.status = 'completed'
      AND c.total_actual_cost IS NOT NULL
      AND c.total_actual_cost > 0;
-- EXECUTE metric_avg_job_cost_all_time;


/* ------------------------------------------------------------------------
   METRIC 14: All Jobs Income Breakdown
   ------------------------------------------------------------------------
   DESCRIPTION: Distribution of ALL completed jobs by applicant income bracket
   
   ALGORITHM: Same as Metric 6, but for ALL completed jobs (not just past week)
   
   LOGIC NOTES:
   - Only includes cases with completed work orders
   - Shows who we're serving at macro level
   - Important for grant compliance (serving low-moderate income households)
   
   BUSINESS VALUE: Grant reporting and mission alignment verification
   ------------------------------------------------------------------------ */
WITH completed_cases AS (
    SELECT DISTINCT c.submission_id
    FROM cases c
    JOIN work_orders wo ON c.id = wo.case_id
    WHERE wo.status = 'completed'
),
income_data AS (
    SELECT 
        s.id,
        CASE 
            WHEN s.has_income = false THEN 0
            WHEN s.gross_annual_income IS NOT NULL THEN s.gross_annual_income
            ELSE (
                SELECT SUM(
                    CASE frequency
                        WHEN 'weekly' THEN amount * 52
                        WHEN 'biweekly' THEN amount * 26
                        WHEN 'monthly' THEN amount * 12
                        WHEN 'annually' THEN amount
                        ELSE amount
                    END
                ) FROM income_records ir WHERE ir.submission_id = s.id
            )
        END AS calculated_income
    FROM intake_submissions s
    JOIN completed_cases cc ON s.id = cc.submission_id
)
SELECT 
    CASE 
        WHEN calculated_income = 0 THEN '$0 (Zero income)'
        WHEN calculated_income <= 15000 THEN '$1 - $15,000'
        WHEN calculated_income <= 30000 THEN '$15,001 - $30,000'
        WHEN calculated_income <= 50000 THEN '$30,001 - $50,000'
        WHEN calculated_income <= 75000 THEN '$50,001 - $75,000'
        ELSE '$75,001+'
    END AS income_bracket,
    COUNT(*) AS completed_jobs,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM income_data
GROUP BY 
    CASE 
        WHEN calculated_income = 0 THEN '$0 (Zero income)'
        WHEN calculated_income <= 15000 THEN '$1 - $15,000'
        WHEN calculated_income <= 30000 THEN '$15,001 - $30,000'
        WHEN calculated_income <= 50000 THEN '$30,001 - $50,000'
        WHEN calculated_income <= 75000 THEN '$50,001 - $75,000'
        ELSE '$75,001+'
    END
ORDER BY MIN(calculated_income);

PREPARE metric_all_jobs_income_breakdown AS
    WITH completed_cases AS (
        SELECT DISTINCT c.submission_id
        FROM cases c
        JOIN work_orders wo ON c.id = wo.case_id
        WHERE wo.status = 'completed'
    ),
    income_data AS (
        SELECT 
            CASE 
                WHEN s.has_income = false THEN 0
                ELSE COALESCE(s.gross_annual_income, 0)
            END AS calculated_income
        FROM intake_submissions s
        JOIN completed_cases cc ON s.id = cc.submission_id
    )
    SELECT 
        CASE 
            WHEN calculated_income <= 15000 THEN 'Low (0-15k)'
            WHEN calculated_income <= 50000 THEN 'Moderate (15k-50k)'
            ELSE 'Higher (50k+)'
        END AS bracket,
        COUNT(*) AS count
    FROM income_data
    GROUP BY 1;
-- EXECUTE metric_all_jobs_income_breakdown;


/* ------------------------------------------------------------------------
   METRIC 15: All Jobs County Breakdown
   ------------------------------------------------------------------------
   DESCRIPTION: Distribution of ALL completed jobs by county
   
   ALGORITHM: Same as Metric 7, but for ALL completed jobs
   
   LOGIC NOTES:
   - Geographic distribution of where work was actually performed
   - May differ from application distribution (some counties harder to serve)
   
   BUSINESS VALUE: Geographic coverage analysis and resource allocation
   ------------------------------------------------------------------------ */
WITH completed_cases AS (
    SELECT DISTINCT c.submission_id
    FROM cases c
    JOIN work_orders wo ON c.id = wo.case_id
    WHERE wo.status = 'completed'
),
county_mapping AS (
    SELECT 
        s.id,
        CASE 
            WHEN s.home_city ILIKE '%Asheville%' OR s.home_zip IN ('28801','28803','28804','28805','28806') THEN 'Buncombe'
            WHEN s.home_city ILIKE '%Mars Hill%' OR s.home_city ILIKE '%Marshall%' THEN 'Madison'
            WHEN s.home_city ILIKE '%Hendersonville%' THEN 'Henderson'
            WHEN s.home_city ILIKE '%Waynesville%' THEN 'Haywood'
            ELSE 'Other'
        END AS county
    FROM intake_submissions s
    JOIN completed_cases cc ON s.id = cc.submission_id
)
SELECT 
    county,
    COUNT(*) AS completed_jobs,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM county_mapping
GROUP BY county
ORDER BY completed_jobs DESC;

PREPARE metric_all_jobs_county_breakdown AS
    WITH completed_cases AS (
        SELECT DISTINCT c.submission_id
        FROM cases c
        JOIN work_orders wo ON c.id = wo.case_id
        WHERE wo.status = 'completed'
    ),
    county_mapping AS (
        SELECT 
            CASE 
                WHEN s.home_city ILIKE '%Asheville%' THEN 'Buncombe'
                ELSE 'Other'
            END AS county
        FROM intake_submissions s
        JOIN completed_cases cc ON s.id = cc.submission_id
    )
    SELECT county, COUNT(*) AS count
    FROM county_mapping
    GROUP BY county;
-- EXECUTE metric_all_jobs_county_breakdown;


/* ------------------------------------------------------------------------
   METRIC 16: Highest and Lowest Job Costs
   ------------------------------------------------------------------------
   DESCRIPTION: Most expensive and least expensive completed jobs
   
   ALGORITHM: MAX(total_actual_cost) and MIN(total_actual_cost) from completed cases
   
   LOGIC NOTES:
   - Excludes zero-cost jobs (likely data errors)
   - Returns both the values AND the case identifiers for drill-down
   
   BUSINESS VALUE: Identify cost outliers, large/complex projects, small quick wins
   ------------------------------------------------------------------------ */
WITH completed_job_costs AS (
    SELECT 
        c.id AS case_id,
        c.case_number,
        c.total_actual_cost,
        s.applicant_first_name,
        s.applicant_last_name,
        s.home_address
    FROM cases c
    JOIN intake_submissions s ON c.submission_id = s.id
    JOIN work_orders wo ON c.id = wo.case_id
    WHERE wo.status = 'completed'
      AND c.total_actual_cost IS NOT NULL
      AND c.total_actual_cost > 0
)
SELECT 
    'Highest' AS metric_type,
    case_id,
    case_number,
    total_actual_cost AS cost,
    applicant_first_name || ' ' || applicant_last_name AS applicant_name,
    home_address
FROM completed_job_costs
WHERE total_actual_cost = (SELECT MAX(total_actual_cost) FROM completed_job_costs)
UNION ALL
SELECT 
    'Lowest' AS metric_type,
    case_id,
    case_number,
    total_actual_cost AS cost,
    applicant_first_name || ' ' || applicant_last_name AS applicant_name,
    home_address
FROM completed_job_costs
WHERE total_actual_cost = (SELECT MIN(total_actual_cost) FROM completed_job_costs);

PREPARE metric_extreme_job_costs_all_time AS
    WITH costs AS (
        SELECT c.total_actual_cost
        FROM cases c
        JOIN work_orders wo ON c.id = wo.case_id
        WHERE wo.status = 'completed' AND c.total_actual_cost > 0
    )
    SELECT 
        MAX(total_actual_cost) AS highest_cost,
        MIN(total_actual_cost) AS lowest_cost
    FROM costs;
-- EXECUTE metric_extreme_job_costs_all_time;


-- =====================================================
-- SECTION 3: ORGANIZATION SPECIFIC DASHBOARD
-- =====================================================

/* ------------------------------------------------------------------------
   METRIC 17: Org Specific - Total Jobs
   ------------------------------------------------------------------------
   DESCRIPTION: Total work orders assigned to a specific organization
   
   ALGORITHM: COUNT work_orders WHERE organization_id = target_org
   
   LOGIC NOTES:
   - Filter by the organization's ID (passed as parameter)
   - Includes all work orders regardless of status
   
   BUSINESS VALUE: Per-org productivity measurement
   ------------------------------------------------------------------------ */
-- Parameter: $1 = organization_id
-- Illustrative query only; $1 is only bound inside a PREPARE, so executing this
-- standalone fails at deploy time. The runnable form is the PREPARE below.
/*
SELECT
    o.organization_name,
    COUNT(DISTINCT wo.id) AS total_jobs,
    COUNT(DISTINCT wo.case_id) AS unique_cases
FROM coalition_organizations o
LEFT JOIN application_assignments aa ON o.id = aa.organization_id
LEFT JOIN cases c ON aa.submission_id = c.submission_id
LEFT JOIN work_orders wo ON c.id = wo.case_id
WHERE o.id = $1
GROUP BY o.id, o.organization_name;
*/

PREPARE metric_org_total_jobs(INTEGER) AS
    SELECT COUNT(DISTINCT wo.id) AS total_jobs
    FROM coalition_organizations o
    LEFT JOIN application_assignments aa ON o.id = aa.organization_id
    LEFT JOIN cases c ON aa.submission_id = c.submission_id
    LEFT JOIN work_orders wo ON c.id = wo.case_id
    WHERE o.id = $1;
-- EXECUTE metric_org_total_jobs(1);


/* ------------------------------------------------------------------------
   METRIC 18: Org Specific - Jobs in Progress
   ------------------------------------------------------------------------
   DESCRIPTION: Active work orders for a specific organization
   
   ALGORITHM: COUNT work_orders WHERE org = target AND status in progress
   
   BUSINESS VALUE: Org-specific workload monitoring
   ------------------------------------------------------------------------ */
PREPARE metric_org_jobs_in_progress(INTEGER) AS
    SELECT COUNT(DISTINCT wo.id) AS jobs_in_progress
    FROM coalition_organizations o
    LEFT JOIN application_assignments aa ON o.id = aa.organization_id
    LEFT JOIN cases c ON aa.submission_id = c.submission_id
    LEFT JOIN work_orders wo ON c.id = wo.case_id
    WHERE o.id = $1
      AND wo.status IN ('in_progress', 'assigned', 'planned');
-- EXECUTE metric_org_jobs_in_progress(1);


/* ------------------------------------------------------------------------
   METRIC 19: Org Specific - Jobs Completed
   ------------------------------------------------------------------------
   DESCRIPTION: Completed work orders for a specific organization
   
   ALGORITHM: COUNT work_orders WHERE org = target AND status = 'completed'
   
   BUSINESS VALUE: Org-specific success rate tracking
   ------------------------------------------------------------------------ */
PREPARE metric_org_jobs_completed(INTEGER) AS
    SELECT COUNT(DISTINCT wo.id) AS jobs_completed
    FROM coalition_organizations o
    LEFT JOIN application_assignments aa ON o.id = aa.organization_id
    LEFT JOIN cases c ON aa.submission_id = c.submission_id
    LEFT JOIN work_orders wo ON c.id = wo.case_id
    WHERE o.id = $1
      AND wo.status = 'completed';
-- EXECUTE metric_org_jobs_completed(1);


/* ------------------------------------------------------------------------
   METRIC 20: Org Specific - Jobs Suggested
   ------------------------------------------------------------------------
   DESCRIPTION: Number of jobs that were suggested/assigned to this org (may not have been claimed)
   
   ALGORITHM: COUNT application_assignments WHERE org = target AND status = 'pending'
   
   LOGIC NOTES:
   - Jobs "suggested" = assigned by system but not yet claimed/rejected
   - Important for measuring org responsiveness
   
   BUSINESS VALUE: Measure how quickly orgs claim assignments
   ------------------------------------------------------------------------ */
PREPARE metric_org_jobs_suggested(INTEGER) AS
    SELECT COUNT(*) AS jobs_suggested
    FROM application_assignments aa
    WHERE aa.organization_id = $1
      AND aa.status = 'pending'
      AND aa.expires_at > CURRENT_TIMESTAMP;
-- EXECUTE metric_org_jobs_suggested(1);


/* ------------------------------------------------------------------------
   METRIC 21: Org Specific - Assessments Assigned Total
   ------------------------------------------------------------------------
   DESCRIPTION: Total property assessments assigned to this org's assessors
   
   ALGORITHM: COUNT property_assessments WHERE organization derived from case
   
   BUSINESS VALUE: Assessment workload by organization
   ------------------------------------------------------------------------ */
PREPARE metric_org_assessments_assigned(INTEGER) AS
    SELECT COUNT(DISTINCT pa.id) AS assessments_assigned_total
    FROM coalition_organizations o
    LEFT JOIN application_assignments aa ON o.id = aa.organization_id
    LEFT JOIN cases c ON aa.submission_id = c.submission_id
    LEFT JOIN property_assessments pa ON c.id = pa.case_id
    WHERE o.id = $1
      AND pa.id IS NOT NULL;
-- EXECUTE metric_org_assessments_assigned(1);


/* ------------------------------------------------------------------------
   METRIC 22: Org Specific - Assessments Completed Total
   ------------------------------------------------------------------------
   DESCRIPTION: Total completed assessments for this organization
   
   ALGORITHM: COUNT property_assessments WHERE completed AND org = target
   
   BUSINESS VALUE: Assessment completion rate by organization
   ------------------------------------------------------------------------ */
PREPARE metric_org_assessments_completed(INTEGER) AS
    SELECT COUNT(DISTINCT pa.id) AS assessments_completed_total
    FROM coalition_organizations o
    LEFT JOIN application_assignments aa ON o.id = aa.organization_id
    LEFT JOIN cases c ON aa.submission_id = c.submission_id
    LEFT JOIN property_assessments pa ON c.id = pa.case_id
    WHERE o.id = $1
      AND pa.assessment_completed_at IS NOT NULL;
-- EXECUTE metric_org_assessments_completed(1);


/* ------------------------------------------------------------------------
   METRIC 23: Org Specific - Assessments Total Pending
   ------------------------------------------------------------------------
   DESCRIPTION: Assessments assigned but not yet completed
   
   ALGORITHM: assigned_total - completed_total
   
   LOGIC NOTES:
   - Backlog indicator for each organization
   - High pending may indicate need for more assessors
   
   BUSINESS VALUE: Resource allocation and backlog management
   ------------------------------------------------------------------------ */
PREPARE metric_org_assessments_pending(INTEGER) AS
    WITH org_assessments AS (
        SELECT 
            COUNT(DISTINCT pa.id) FILTER (WHERE pa.id IS NOT NULL) AS total_assigned,
            COUNT(DISTINCT pa.id) FILTER (WHERE pa.assessment_completed_at IS NOT NULL) AS total_completed
        FROM coalition_organizations o
        LEFT JOIN application_assignments aa ON o.id = aa.organization_id
        LEFT JOIN cases c ON aa.submission_id = c.submission_id
        LEFT JOIN property_assessments pa ON c.id = pa.case_id
        WHERE o.id = $1
    )
    SELECT (total_assigned - total_completed) AS assessments_pending
    FROM org_assessments;
-- EXECUTE metric_org_assessments_pending(1);


/* ------------------------------------------------------------------------
   METRIC 24: Org Specific - Highest Job Cost
   ------------------------------------------------------------------------
   DESCRIPTION: Most expensive completed job for this organization
   
   ALGORITHM: MAX(total_actual_cost) WHERE org = target AND job completed
   
   BUSINESS VALUE: Understand org's capacity for large projects
   ------------------------------------------------------------------------ */
PREPARE metric_org_highest_job_cost(INTEGER) AS
    SELECT 
        MAX(c.total_actual_cost) AS highest_job_cost,
        c.case_number,
        s.applicant_first_name || ' ' || s.applicant_last_name AS applicant_name
    FROM coalition_organizations o
    JOIN application_assignments aa ON o.id = aa.organization_id
    JOIN cases c ON aa.submission_id = c.submission_id
    JOIN intake_submissions s ON c.submission_id = s.id
    JOIN work_orders wo ON c.id = wo.case_id
    WHERE o.id = $1
      AND wo.status = 'completed'
      AND c.total_actual_cost IS NOT NULL
    GROUP BY c.id, c.case_number, s.applicant_first_name, s.applicant_last_name
    ORDER BY c.total_actual_cost DESC
    LIMIT 1;
-- EXECUTE metric_org_highest_job_cost(1);


/* ------------------------------------------------------------------------
   METRIC 25: Org Specific - Lowest Job Cost
   ------------------------------------------------------------------------
   DESCRIPTION: Least expensive completed job for this organization
   
   ALGORITHM: MIN(total_actual_cost) WHERE org = target AND job completed AND cost > 0
   
   BUSINESS VALUE: Identify small project capabilities
   ------------------------------------------------------------------------ */
PREPARE metric_org_lowest_job_cost(INTEGER) AS
    SELECT 
        MIN(c.total_actual_cost) AS lowest_job_cost,
        c.case_number,
        s.applicant_first_name || ' ' || s.applicant_last_name AS applicant_name
    FROM coalition_organizations o
    JOIN application_assignments aa ON o.id = aa.organization_id
    JOIN cases c ON aa.submission_id = c.submission_id
    JOIN intake_submissions s ON c.submission_id = s.id
    JOIN work_orders wo ON c.id = wo.case_id
    WHERE o.id = $1
      AND wo.status = 'completed'
      AND c.total_actual_cost IS NOT NULL
      AND c.total_actual_cost > 0
    GROUP BY c.id, c.case_number, s.applicant_first_name, s.applicant_last_name
    ORDER BY c.total_actual_cost ASC
    LIMIT 1;
-- EXECUTE metric_org_lowest_job_cost(1);


/* ------------------------------------------------------------------------
   METRIC 26: Org Specific - Average Job Cost
   ------------------------------------------------------------------------
   DESCRIPTION: Average cost of completed jobs for this organization
   
   ALGORITHM: AVG(total_actual_cost) WHERE org = target AND job completed
   
   BUSINESS VALUE: Benchmarking orgs against each other
   ------------------------------------------------------------------------ */
PREPARE metric_org_avg_job_cost(INTEGER) AS
    SELECT 
        ROUND(AVG(c.total_actual_cost), 2) AS avg_job_cost,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY c.total_actual_cost) AS median_job_cost
    FROM coalition_organizations o
    JOIN application_assignments aa ON o.id = aa.organization_id
    JOIN cases c ON aa.submission_id = c.submission_id
    JOIN work_orders wo ON c.id = wo.case_id
    WHERE o.id = $1
      AND wo.status = 'completed'
      AND c.total_actual_cost IS NOT NULL
      AND c.total_actual_cost > 0;
-- EXECUTE metric_org_avg_job_cost(1);


/* ------------------------------------------------------------------------
   METRIC 27: Org Specific - All Jobs Income Breakdown
   ------------------------------------------------------------------------
   DESCRIPTION: Distribution of completed jobs by income bracket for this org
   
   ALGORITHM: Same as Metric 14 but filtered by organization
   
   BUSINESS VALUE: Ensure org is serving appropriate income demographics
   ------------------------------------------------------------------------ */
PREPARE metric_org_income_breakdown(INTEGER) AS
    WITH org_completed_cases AS (
        SELECT DISTINCT c.submission_id
        FROM coalition_organizations o
        JOIN application_assignments aa ON o.id = aa.organization_id
        JOIN cases c ON aa.submission_id = c.submission_id
        JOIN work_orders wo ON c.id = wo.case_id
        WHERE o.id = $1
          AND wo.status = 'completed'
    ),
    income_data AS (
        SELECT 
            CASE 
                WHEN s.has_income = false THEN 0
                ELSE COALESCE(s.gross_annual_income, 0)
            END AS calculated_income
        FROM intake_submissions s
        JOIN org_completed_cases occ ON s.id = occ.submission_id
    )
    SELECT 
        CASE 
            WHEN calculated_income <= 15000 THEN 'Low (0-15k)'
            WHEN calculated_income <= 50000 THEN 'Moderate (15k-50k)'
            ELSE 'Higher (50k+)'
        END AS income_bracket,
        COUNT(*) AS completed_jobs,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
    FROM income_data
    GROUP BY 
        CASE 
            WHEN calculated_income <= 15000 THEN 'Low (0-15k)'
            WHEN calculated_income <= 50000 THEN 'Moderate (15k-50k)'
            ELSE 'Higher (50k+)'
        END;
-- EXECUTE metric_org_income_breakdown(1);


/* ------------------------------------------------------------------------
   METRIC 28: Org Specific - All Jobs County Breakdown
   ------------------------------------------------------------------------
   DESCRIPTION: Distribution of completed jobs by county for this organization
   
   ALGORITHM: Same as Metric 15 but filtered by organization
   
   BUSINESS VALUE: Geographic service area analysis per organization
   ------------------------------------------------------------------------ */
PREPARE metric_org_county_breakdown(INTEGER) AS
    WITH org_completed_cases AS (
        SELECT DISTINCT c.submission_id
        FROM coalition_organizations o
        JOIN application_assignments aa ON o.id = aa.organization_id
        JOIN cases c ON aa.submission_id = c.submission_id
        JOIN work_orders wo ON c.id = wo.case_id
        WHERE o.id = $1
          AND wo.status = 'completed'
    ),
    county_mapping AS (
        SELECT 
            CASE 
                WHEN s.home_city ILIKE '%Asheville%' OR s.home_zip IN ('28801','28803','28804','28805','28806') THEN 'Buncombe'
                WHEN s.home_city ILIKE '%Mars Hill%' OR s.home_city ILIKE '%Marshall%' THEN 'Madison'
                WHEN s.home_city ILIKE '%Hendersonville%' THEN 'Henderson'
                ELSE 'Other'
            END AS county
        FROM intake_submissions s
        JOIN org_completed_cases occ ON s.id = occ.submission_id
    )
    SELECT 
        county,
        COUNT(*) AS completed_jobs,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
    FROM county_mapping
    GROUP BY county
    ORDER BY completed_jobs DESC;
-- EXECUTE metric_org_county_breakdown(1);


-- =====================================================
-- DASHBOARD AGGREGATION FUNCTION
-- =====================================================
-- This function returns ALL metrics in a single call for dashboard display
-- =====================================================

CREATE OR REPLACE FUNCTION get_all_dashboard_metrics(p_organization_id INTEGER DEFAULT NULL)
RETURNS JSONB AS $$
DECLARE
    v_result JSONB;
    v_past_week_start DATE;
    v_past_week_end DATE;
BEGIN
    -- Get date range
    SELECT start_date, end_date INTO v_past_week_start, v_past_week_end FROM get_past_week_range();
    
    -- Build complete dashboard JSON
    SELECT jsonb_build_object(
        -- Section 1: Past Week Metrics
        'past_week', jsonb_build_object(
            'total_applications', (SELECT COUNT(*) FROM intake_submissions WHERE submitted_at::DATE BETWEEN v_past_week_start AND v_past_week_end),
            'assessments_assigned', (SELECT COUNT(*) FROM property_assessments WHERE assigned_at::DATE BETWEEN v_past_week_start AND v_past_week_end),
            'assessments_completed', (SELECT COUNT(*) FROM property_assessments WHERE assessment_completed_at::DATE BETWEEN v_past_week_start AND v_past_week_end),
            'avg_triage_score', (SELECT ROUND(AVG(triage_score), 1) FROM completed_assessments_with_triage WHERE assessment_completed_at::DATE BETWEEN v_past_week_start AND v_past_week_end),
            'total_individuals', (SELECT SUM(household_size) FROM intake_submissions WHERE submitted_at::DATE BETWEEN v_past_week_start AND v_past_week_end),
            'income_breakdown', (SELECT jsonb_agg(jsonb_build_object('bracket', bracket, 'count', count)) FROM metric_income_breakdown_past_week()),
            'county_breakdown', (SELECT jsonb_agg(jsonb_build_object('county', county, 'count', count)) FROM metric_county_breakdown_past_week()),
            'issue_breakdown', (SELECT jsonb_agg(jsonb_build_object('issue', category_label, 'count', count)) FROM metric_issue_type_pie_past_week())
        ),
        -- Section 2: All Time Metrics
        'all_time', jsonb_build_object(
            'total_jobs', (SELECT total_jobs FROM metric_total_jobs_all_time()),
            'jobs_in_progress', (SELECT jobs_in_progress FROM metric_jobs_in_progress_all_time()),
            'jobs_completed', (SELECT jobs_completed FROM metric_jobs_completed_all_time()),
            'avg_job_cost', (SELECT avg_job_cost FROM metric_avg_job_cost_all_time()),
            'highest_job_cost', (SELECT highest_cost FROM metric_extreme_job_costs_all_time()),
            'lowest_job_cost', (SELECT lowest_cost FROM metric_extreme_job_costs_all_time())
        )
    ) INTO v_result;
    
    -- Add org-specific metrics if organization ID provided
    IF p_organization_id IS NOT NULL THEN
        v_result := v_result || jsonb_build_object(
            'organization_specific', jsonb_build_object(
                'total_jobs', (SELECT total_jobs FROM metric_org_total_jobs(p_organization_id)),
                'jobs_in_progress', (SELECT jobs_in_progress FROM metric_org_jobs_in_progress(p_organization_id)),
                'jobs_completed', (SELECT jobs_completed FROM metric_org_jobs_completed(p_organization_id)),
                'jobs_suggested', (SELECT jobs_suggested FROM metric_org_jobs_suggested(p_organization_id)),
                'assessments_assigned', (SELECT assessments_assigned_total FROM metric_org_assessments_assigned(p_organization_id)),
                'assessments_completed', (SELECT assessments_completed_total FROM metric_org_assessments_completed(p_organization_id)),
                'assessments_pending', (SELECT assessments_pending FROM metric_org_assessments_pending(p_organization_id)),
                'avg_job_cost', (SELECT avg_job_cost FROM metric_org_avg_job_cost(p_organization_id)),
                'highest_job_cost', (SELECT highest_job_cost FROM metric_org_highest_job_cost(p_organization_id)),
                'lowest_job_cost', (SELECT lowest_job_cost FROM metric_org_lowest_job_cost(p_organization_id))
            )
        );
    END IF;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Example usage:
-- SELECT get_all_dashboard_metrics();  -- No org filter
-- SELECT get_all_dashboard_metrics(1); -- Filter for organization_id = 1


-- =====================================================
-- METRICS INDEX FOR DEVELOPERS
-- =====================================================
/*
Quick Reference Guide:

SECTION 1: DASHBOARD PAST WEEK (7 metrics)
-------------------------------------------
1. total_applications_past_week      - Metric 1
2. assessments_assigned_past_week    - Metric 2  
3. assessments_completed_past_week   - Metric 3
4. avg_triage_score_past_week        - Metric 4
5. total_individuals_past_week       - Metric 5
6. income_breakdown_past_week        - Metric 6
7. county_breakdown_past_week        - Metric 7
8. issue_type_pie_past_week          - Metric 8

SECTION 2: DASHBOARD ALL TIME (8 metrics)
------------------------------------------
9. total_jobs_all_time               - Metric 9
10. jobs_in_progress_all_time        - Metric 10
11. jobs_completed_all_time          - Metric 11
12. jobs_negative_outcomes_all_time  - Metric 12
13. avg_job_cost_all_time            - Metric 13
14. all_jobs_income_breakdown        - Metric 14
15. all_jobs_county_breakdown        - Metric 15
16. extreme_job_costs_all_time       - Metric 16

SECTION 3: ORGANIZATION SPECIFIC (12 metrics)
-----------------------------------------------
17. org_total_jobs                   - Metric 17
18. org_jobs_in_progress             - Metric 18
19. org_jobs_completed               - Metric 19
20. org_jobs_suggested               - Metric 20
21. org_assessments_assigned         - Metric 21
22. org_assessments_completed        - Metric 22
23. org_assessments_pending          - Metric 23
24. org_highest_job_cost             - Metric 24
25. org_lowest_job_cost              - Metric 25
26. org_avg_job_cost                 - Metric 26
27. org_income_breakdown             - Metric 27
28. org_county_breakdown             - Metric 28

To execute any prepared statement:
EXECUTE metric_name(param_if_needed);

To get all metrics at once:
SELECT get_all_dashboard_metrics();
SELECT get_all_dashboard_metrics(organization_id);
*/
-- END sql/metric-tracking.sql

-- ----------------------------------------------------------------
-- BEGIN sql/requestor-account-link.sql
-- ----------------------------------------------------------------
-- Add requestor_user_id column to link intake submissions to system_users
-- This allows requestors to track their case through the portal

ALTER TABLE intake_submissions
ADD COLUMN IF NOT EXISTS requestor_user_id INTEGER;

-- FK added separately: intake.sql creates the column WITHOUT the constraint
-- (system_users does not exist yet at that point in a fresh deploy), and
-- ADD COLUMN IF NOT EXISTS is a no-op when the column already exists, so a
-- combined statement could never add the constraint. This DO block adds it
-- exactly once, on both fresh and existing databases.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'intake_submissions_requestor_user_id_fkey'
    ) THEN
        ALTER TABLE intake_submissions
        ADD CONSTRAINT intake_submissions_requestor_user_id_fkey
        FOREIGN KEY (requestor_user_id) REFERENCES system_users(id) ON DELETE SET NULL;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_intake_submissions_requestor_user_id 
ON intake_submissions(requestor_user_id);

-- Add REQUESTOR role if it doesn't exist
INSERT INTO roles (role_code, role_name, role_level, description, is_system_role)
VALUES ('REQUESTOR', 'Requestor', 1, 'Homeowner who has submitted an application for repair services', true)
ON CONFLICT (role_code) DO NOTHING;

-- Grant REQUESTOR role appropriate permissions to view their own case
-- Requestors should be able to:
-- 1. View their own intake submission
-- 2. Upload documents to their case
-- 3. View their case status and progress
-- 4. Communicate with assigned staff

COMMENT ON COLUMN intake_submissions.requestor_user_id IS 
'Link to system_users table for requestor portal access. Set automatically on submission.';

-- END sql/requestor-account-link.sql

-- ----------------------------------------------------------------
-- BEGIN sql/add\super-admin-role.sql
-- ----------------------------------------------------------------
-- Migration: add the Super-Administrator role and permissions to existing databases.

-- 1. Insert the SUPER_ADMIN role (highest level)
INSERT INTO roles (role_code, role_name, role_level, description, is_system_role)
SELECT 'SUPER_ADMIN', 'Super Administrator', 15, 'System-level administrator across all organizations and the entire platform', true
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE role_code = 'SUPER_ADMIN');

-- 2. Insert new permission categories (idempotent)
INSERT INTO permission_categories (category_code, category_name) VALUES
    ('SYSTEM', 'System Administration'),
    ('AUDIT', 'Audit & Logs'),
    ('DATA', 'Data Management'),
    ('SUPPORT', 'Support & Maintenance')
ON CONFLICT (category_code) DO NOTHING;

-- 3. Insert Super-Admin permissions (idempotent)
INSERT INTO permissions (permission_code, permission_name, category_id) VALUES
    ('SYSTEM_VIEW', 'View system status', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('SYSTEM_EDIT', 'Edit system configuration', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('SYSTEM_BACKUP', 'Trigger system backups', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('SYSTEM_RESTORE', 'Restore from backup', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('SYSTEM_CONFIG', 'Manage system-wide settings', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('ORG_VIEW_ALL', 'View all organizations', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('ORG_CREATE', 'Create organizations', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('ORG_EDIT', 'Edit organizations', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('ORG_ARCHIVE', 'Archive organizations', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('ORG_RESTORE', 'Restore archived organizations', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('USER_VIEW_ALL', 'View all users', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('USER_CREATE', 'Create users', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('USER_EDIT', 'Edit users', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('USER_DEACTIVATE', 'Deactivate users', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('USER_IMPERSONATE', 'Impersonate users', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('AUDIT_VIEW_ALL', 'View all audit logs', (SELECT id FROM permission_categories WHERE category_code = 'AUDIT')),
    ('AUDIT_EXPORT', 'Export audit logs', (SELECT id FROM permission_categories WHERE category_code = 'AUDIT')),
    ('AUDIT_CONFIG', 'Configure audit retention', (SELECT id FROM permission_categories WHERE category_code = 'AUDIT')),
    ('DATA_VIEW_ALL', 'View all data', (SELECT id FROM permission_categories WHERE category_code = 'DATA')),
    ('DATA_EXPORT', 'Export data', (SELECT id FROM permission_categories WHERE category_code = 'DATA')),
    ('DATA_IMPORT', 'Import data', (SELECT id FROM permission_categories WHERE category_code = 'DATA')),
    ('DATA_ARCHIVE', 'Archive data', (SELECT id FROM permission_categories WHERE category_code = 'DATA')),
    ('SUPPORT_TICKET_VIEW_ALL', 'View all support tickets', (SELECT id FROM permission_categories WHERE category_code = 'SUPPORT')),
    ('SYSTEM_LOGS_VIEW', 'View system logs', (SELECT id FROM permission_categories WHERE category_code = 'SUPPORT'))
ON CONFLICT (permission_code) DO NOTHING;

-- 4. Grant all current and future permissions to SUPER_ADMIN
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.role_code = 'SUPER_ADMIN'
  AND NOT EXISTS (
      SELECT 1 FROM role_permissions rp
      WHERE rp.role_id = r.id AND rp.permission_id = p.id
  );

-- END sql/add\super-admin-role.sql

-- ----------------------------------------------------------------
-- BEGIN sql/add\system-users-username-fields.sql
-- ----------------------------------------------------------------
-- Add missing username, first_name, and last_name fields to system_users
-- Required for account creation from intake submissions

-- Add username column (unique identifier for login)
ALTER TABLE system_users 
ADD COLUMN IF NOT EXISTS username VARCHAR(100) UNIQUE;

-- Add first_name and last_name columns
ALTER TABLE system_users 
ADD COLUMN IF NOT EXISTS first_name VARCHAR(100);

ALTER TABLE system_users 
ADD COLUMN IF NOT EXISTS last_name VARCHAR(100);

-- Create index on username for fast lookups
CREATE INDEX IF NOT EXISTS idx_system_users_username ON system_users(username);

-- Update existing records to have usernames if they don't
-- (using email prefix as username for existing users)
UPDATE system_users 
SET username = LOWER(SPLIT_PART(email, '@', 1))
WHERE username IS NULL;

COMMENT ON COLUMN system_users.username IS 'Unique username for login (auto-generated from email on creation)';
COMMENT ON COLUMN system_users.first_name IS 'User first name';
COMMENT ON COLUMN system_users.last_name IS 'User last name';

-- Fix user_role_assignments to allow NULL organization_id for requestors
-- Drop the old unique constraint that includes organization_id
ALTER TABLE user_role_assignments
DROP CONSTRAINT IF EXISTS user_role_assignments_user_id_organization_id_role_id_key;

-- Add a new unique constraint that handles NULLs properly
-- Multiple users can have the same role with NULL organization
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_role_org_unique
ON user_role_assignments (user_id, role_id, organization_id)
WHERE organization_id IS NOT NULL;

-- For NULL organization_id, only one role per user (for requestors)
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_role_null_org_unique
ON user_role_assignments (user_id, role_id)
WHERE organization_id IS NULL;

COMMENT ON COLUMN user_role_assignments.organization_id IS
'Organization affiliation (NULL for requestors who are not part of an organization)';

-- END sql/add\system-users-username-fields.sql

-- ----------------------------------------------------------------
-- BEGIN sql/add\session-indefinite.sql
-- ----------------------------------------------------------------
-- Add a per-user preference for an indefinite (persistent) login session.

ALTER TABLE system_users
    ADD COLUMN IF NOT EXISTS session_indefinite BOOLEAN DEFAULT FALSE;

COMMENT ON COLUMN system_users.session_indefinite IS 'When true, the login session cookie should be persisted for a long duration instead of the default 24-hour expiry.';

-- END sql/add\session-indefinite.sql
