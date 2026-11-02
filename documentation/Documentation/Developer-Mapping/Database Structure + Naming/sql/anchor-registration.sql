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