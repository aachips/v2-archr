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
    -- ON CONFLICT ON CONSTRAINT: the function's RETURNS TABLE out-params share
    -- names with these columns, making the column-list form ambiguous (42702).
    ON CONFLICT ON CONSTRAINT application_assignments_submission_id_organization_id_key DO UPDATE
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