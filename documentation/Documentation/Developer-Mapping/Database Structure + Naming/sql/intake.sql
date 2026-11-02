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