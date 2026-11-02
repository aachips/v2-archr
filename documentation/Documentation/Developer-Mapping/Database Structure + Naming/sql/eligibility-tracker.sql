-- =====================================================
-- ELIGIBILITY CHECKER
-- Philosophy ("ARCHR Core Terminology and Operational Logic" Part 4):
--   * Assume eligibility — every applicant defaults to eligible.
--   * Flag, don't decide — the system surfaces green/yellow/red flags.
--   * No automated denials — final determinations are made by humans.
--     (Terminations use the canonical checkbox reasons and are always human.)
-- =====================================================

-- Legacy flag-mirror columns used below (defensive: predated on some databases).
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS disqualification_reasons TEXT[];
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS eligibility_warnings TEXT[];

-- Per-org eligibility scoring results, written by check_eligibility() and read
-- by the staff dashboard views. Org-specific validation (e.g. each org verifies
-- income under its own program maximum) is case/org-specific by design.
CREATE TABLE IF NOT EXISTS eligibility_results (
    id SERIAL PRIMARY KEY,
    submission_id INTEGER REFERENCES intake_submissions(id) ON DELETE CASCADE,
    organization_id INTEGER REFERENCES coalition_organizations(id) ON DELETE CASCADE,
    match_score INTEGER,
    is_eligible BOOLEAN,
    checked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (submission_id, organization_id)
);

CREATE INDEX IF NOT EXISTS idx_eligibility_results_submission ON eligibility_results (submission_id, match_score DESC);
CREATE INDEX IF NOT EXISTS idx_eligibility_results_org        ON eligibility_results (organization_id, is_eligible);

CREATE OR REPLACE FUNCTION check_eligibility(p_submission_id INTEGER)
RETURNS JSONB AS $$
DECLARE
    v_submission RECORD;
    v_eligibility_result JSONB;
    v_green TEXT[] := '{}';
    v_yellow TEXT[] := '{}';
    v_red TEXT[] := '{}';
    v_ami_threshold INTEGER;
BEGIN
    -- Fetch submission data
    SELECT * INTO v_submission FROM intake_submissions WHERE id = p_submission_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Submission % not found', p_submission_id;
    END IF;

    -- =====================================================
    -- FLAGS (never hard stops — humans make final decisions)
    -- =====================================================

    -- 1. Geographic eligibility (service area check)
    IF is_in_service_area(v_submission.home_zip, v_submission.home_city) THEN
        v_green := array_append(v_green, 'in_service_area');
    ELSE
        v_red := array_append(v_red, 'outside_service_area');
    END IF;

    -- 2. Homeowner status
    IF v_submission.owns_home IS TRUE THEN
        v_green := array_append(v_green, 'homeownership_confirmed');
    ELSIF v_submission.owns_home IS FALSE THEN
        v_red := array_append(v_red, 'not_homeowner');
    END IF;

    -- 3. Primary residence
    IF v_submission.is_primary_residence IS TRUE THEN
        v_green := array_append(v_green, 'primary_residence_confirmed');
    ELSIF v_submission.is_primary_residence IS FALSE THEN
        v_red := array_append(v_red, 'not_primary_residence');
    END IF;

    -- 4. Income vs 80% AMI for household size (same table as the PHP checker)
    v_ami_threshold := CASE LEAST(COALESCE(v_submission.household_size, 1), 8)
        WHEN 1 THEN 48800 WHEN 2 THEN 55800 WHEN 3 THEN 62750 WHEN 4 THEN 69700
        WHEN 5 THEN 75300 WHEN 6 THEN 80900 WHEN 7 THEN 86500 ELSE 92050
    END;
    IF v_submission.gross_annual_income IS NOT NULL THEN
        IF v_submission.gross_annual_income <= v_ami_threshold THEN
            v_green := array_append(v_green, 'income_within_80pct_ami');
        ELSE
            v_red := array_append(v_red, 'income_above_80pct_ami');
        END IF;
    END IF;

    -- 5. Property type restrictions (mobile homes require lot ownership)
    IF v_submission.home_type = 'mobile' AND v_submission.owns_lot IS FALSE THEN
        v_red := array_append(v_red, 'mobile_home_no_lot_ownership');
    END IF;

    -- 6. Previous assistance (humans verify before terminating as duplicate)
    IF has_received_previous_assistance(v_submission.applicant_first_name,
                                        v_submission.applicant_last_name,
                                        v_submission.home_address) THEN
        v_red := array_append(v_red, 'previous_assistance_received');
    END IF;

    -- 7. Helene-related damage (context flag from the doc's example payload)
    IF v_submission.helene_related IS TRUE THEN
        v_green := array_append(v_green, 'helene_related');
    END IF;

    -- 8. Age requirement (under 18 needs a guardian — review flag only)
    IF v_submission.applicant_dob IS NOT NULL
       AND v_submission.applicant_dob > CURRENT_DATE - INTERVAL '18 years' THEN
        v_yellow := array_append(v_yellow, 'applicant_under_18_guardian_required');
    END IF;

    -- =====================================================
    -- CONDITIONAL ELIGIBILITY (Org-specific matching)
    -- These affect which organizations can serve, not overall eligibility
    -- =====================================================

    INSERT INTO eligibility_results (submission_id, organization_id, match_score, is_eligible, checked_at)
    SELECT
        p_submission_id,
        co.id,
        calculate_match_score(p_submission_id, co.id),
        CASE WHEN calculate_match_score(p_submission_id, co.id) >= 50 THEN TRUE ELSE FALSE END,
        CURRENT_TIMESTAMP
    FROM coalition_organizations co
    WHERE co.is_active = TRUE
    ON CONFLICT (submission_id, organization_id) DO UPDATE
    SET match_score = EXCLUDED.match_score,
        is_eligible = EXCLUDED.is_eligible,
        checked_at = EXCLUDED.checked_at;

    -- =====================================================
    -- PREPARE RESULT
    -- =====================================================

    -- Red flags route to human review ('needs_review'); the system never
    -- writes 'ineligible'. Legacy columns mirror red/yellow flags.
    UPDATE intake_submissions
    SET
        submission_status = CASE
            WHEN array_length(v_red, 1) IS NOT NULL THEN 'needs_review'
            ELSE 'eligible'
        END,
        eligibility_checked_at = CURRENT_TIMESTAMP,
        disqualification_reasons = v_red,
        eligibility_warnings = v_yellow
    WHERE id = p_submission_id;

    -- Store flags on the Application (the deduplicated source of truth).
    UPDATE applications
       SET eligibility_flags = jsonb_build_object('green', v_green, 'yellow', v_yellow, 'red', v_red),
           eligibility_report = left(
               (CASE WHEN array_length(v_green, 1)  IS NOT NULL THEN 'Green: '  || array_to_string(v_green, ', ')  || '. ' ELSE '' END)
             ||(CASE WHEN array_length(v_yellow, 1) IS NOT NULL THEN 'Yellow: ' || array_to_string(v_yellow, ', ') || '. ' ELSE '' END)
             ||(CASE WHEN array_length(v_red, 1)    IS NOT NULL THEN 'Red: '    || array_to_string(v_red, ', ')           ELSE '' END),
               4000),
           updated_at = CURRENT_TIMESTAMP
     WHERE id = (SELECT deduplicated_into FROM intake_submissions WHERE id = p_submission_id);

    v_eligibility_result := jsonb_build_object(
        'is_eligible', TRUE, -- assume eligibility: no automated denials
        'flags', jsonb_build_object('green', v_green, 'yellow', v_yellow, 'red', v_red),
        'recommended_action', CASE WHEN array_length(v_red, 1) IS NOT NULL THEN 'review_manually' ELSE 'approve' END,
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