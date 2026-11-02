-- =====================================================
-- DUMMY DATA GENERATOR
-- Seeds development/UI test applications. Not run by _master.sql.
--
-- Usage from psql:
--     \c archr
--     \i sql/dummy-data.sql
--     SELECT seed_dashboard_placeholder();   -- the John Smith record powering
--                                            -- interface/requestor/dashboard-draft.html
--     SELECT generate_dummy_submissions(15); -- batch of randomised submissions
--
-- Every row inserted here is flagged is_test = TRUE so metric-tracking.sql
-- excludes them from coalition reports. Inserts go straight to the tables
-- (intake_submissions, application_anchor, eligibility_results, review_queue,
-- cases) instead of submit_intake_application(), bypassing its dependency on
-- columns/tables that are not present in the current schema.
-- =====================================================

-- Make sure the three coalition partners referenced by the dashboard exist.
CREATE OR REPLACE FUNCTION _ensure_dummy_partner_orgs() RETURNS VOID AS $$
BEGIN
    INSERT INTO coalition_organizations
        (organization_code, organization_name, contact_email, max_active_applications, is_active)
    VALUES
        ('AHFH', 'Asheville Habitat for Humanity', 'intake@ashevillehabitat.org', 60, TRUE),
        ('MHO',  'Mountain Housing Opportunities', 'help@mtnhousing.org',         40, TRUE),
        ('CAO',  'Community Action Opportunities', 'intake@caoinc.org',           30, TRUE)
    ON CONFLICT (organization_code) DO NOTHING;
END;
$$ LANGUAGE plpgsql;

-- Generic dummy submission generator. Returns the new submission id.
-- p_config keys: first_name, last_name, email, address, city, zip, income,
-- helene_related, submitted_at, submission_status, repair_codes (jsonb array),
-- household_attributes (jsonb array).
CREATE OR REPLACE FUNCTION generate_dummy_submission(p_config JSONB DEFAULT '{}'::JSONB)
RETURNS INTEGER AS $$
DECLARE
    v_id           INTEGER;
    v_first        TEXT      := COALESCE(p_config->>'first_name', 'Test');
    v_last         TEXT      := COALESCE(p_config->>'last_name',  'Applicant');
    v_email        TEXT      := COALESCE(p_config->>'email',
                                         LOWER(v_first || '.' || v_last) || '@example.com');
    v_zip          TEXT      := COALESCE(p_config->>'zip',  '28804');
    v_city         TEXT      := COALESCE(p_config->>'city', 'Asheville');
    v_address      TEXT      := COALESCE(p_config->>'address',
                                         (100 + FLOOR(RANDOM()*9000)::INT)::TEXT || ' Sample St');
    v_income       NUMERIC   := COALESCE((p_config->>'income')::NUMERIC, 28000);
    v_helene       BOOLEAN   := COALESCE((p_config->>'helene_related')::BOOLEAN, TRUE);
    v_submitted_at TIMESTAMP := COALESCE((p_config->>'submitted_at')::TIMESTAMP, CURRENT_TIMESTAMP);
    v_status       TEXT      := COALESCE(p_config->>'submission_status', 'ELIGIBLE');
    v_repair_codes TEXT[]    := CASE WHEN p_config ? 'repair_codes'
        THEN ARRAY(SELECT jsonb_array_elements_text(p_config->'repair_codes'))
        ELSE ARRAY['no_hvac','open_to_elements'] END;
    v_attr_codes   TEXT[]    := CASE WHEN p_config ? 'household_attributes'
        THEN ARRAY(SELECT jsonb_array_elements_text(p_config->'household_attributes'))
        ELSE ARRAY[]::TEXT[] END;
    v_prev_repl    TEXT;
BEGIN
    PERFORM _ensure_dummy_partner_orgs();

    -- Suppress user triggers ONLY for the intake_submissions insert:
    -- trigger_new_submission refreshes a materialized view CONCURRENTLY without
    -- the unique index that operation requires, which would abort the seed.
    -- Triggers on application_anchor / cases (anchor_id + case_number generators)
    -- are still needed, so restore session_replication_role immediately after.
    v_prev_repl := current_setting('session_replication_role');
    PERFORM set_config('session_replication_role', 'replica', true);

    INSERT INTO intake_submissions (
        applicant_first_name, applicant_last_name, applicant_dob,
        contact_email, cell_phone, preferred_email, preferred_phone,
        home_address, home_city, home_state, home_zip,
        is_primary_residence, home_type, year_built, move_in_date, owns_home, owns_lot,
        household_size, household_adults,
        helene_related,
        has_income, income_method, gross_annual_income,
        consent_agreed, language,
        submission_status, submitted_at, is_test
    ) VALUES (
        v_first, v_last, DATE '1975-01-01' - (FLOOR(RANDOM()*7000))::INT,
        v_email, '(828) 555-' || LPAD(FLOOR(RANDOM()*10000)::TEXT, 4, '0'), TRUE, TRUE,
        v_address, v_city, 'NC', v_zip,
        TRUE, 'traditional', 1960 + FLOOR(RANDOM()*50)::INT,
        CURRENT_DATE - INTERVAL '5 years', TRUE, TRUE,
        2 + FLOOR(RANDOM()*4)::INT, 1 + FLOOR(RANDOM()*2)::INT,
        v_helene,
        TRUE, 'gross', v_income,
        TRUE, 'eng',
        v_status, v_submitted_at, TRUE
    ) RETURNING id INTO v_id;

    PERFORM set_config('session_replication_role', v_prev_repl, true);

    -- Mirror urgent-condition flags to the boolean columns the queue reads.
    UPDATE intake_submissions SET
        urgent_no_hvac          = 'no_hvac'          = ANY(v_repair_codes),
        urgent_no_potable_water = 'no_potable_water' = ANY(v_repair_codes),
        urgent_open_to_elements = 'open_to_elements' = ANY(v_repair_codes),
        urgent_no_bathroom      = 'no_bathroom'      = ANY(v_repair_codes),
        urgent_no_kitchen       = 'no_kitchen'       = ANY(v_repair_codes),
        urgent_unable_to_stay   = 'unable_to_stay'   = ANY(v_repair_codes),
        urgent_no_entry         = 'no_entry'         = ANY(v_repair_codes),
        urgent_accessibility    = 'accessibility'    = ANY(v_repair_codes),
        urgent_eviction_risk    = 'eviction_risk'    = ANY(v_repair_codes)
    WHERE id = v_id;

    INSERT INTO submission_repair_categories (submission_id, category_id)
    SELECT v_id, rc.id FROM repair_categories rc WHERE rc.category_code = ANY(v_repair_codes);

    INSERT INTO submission_household_attributes (submission_id, attribute_id)
    SELECT v_id, ha.id FROM household_attributes ha WHERE ha.attribute_name = ANY(v_attr_codes);

    INSERT INTO submission_contact_methods (submission_id, method_id)
    SELECT v_id, cm.id FROM contact_methods cm WHERE cm.method_code IN ('email','phone');

    INSERT INTO application_anchor (
        submission_id, submitted_at, is_eligible, eligibility_score, current_status,
        income_bucket, county_bucket, repair_type_bucket, helene_related
    ) VALUES (
        v_id, v_submitted_at, TRUE, 60 + FLOOR(RANDOM()*40)::INT,
        CASE WHEN v_status = 'ELIGIBLE' THEN 'eligible' ELSE LOWER(v_status) END,
        get_income_bucket(v_income), get_county_bucket(v_city, v_zip),
        v_repair_codes[1], v_helene
    );

    INSERT INTO eligibility_results (submission_id, organization_id, match_score, is_eligible)
    SELECT v_id, co.id, 60 + FLOOR(RANDOM()*40)::INT, TRUE
    FROM coalition_organizations co WHERE co.is_active = TRUE
    ON CONFLICT (submission_id, organization_id) DO NOTHING;

    INSERT INTO review_queue (submission_id, status, queued_at, priority_score)
    VALUES (v_id, 'PENDING_REVIEW', v_submitted_at,
            10 * COALESCE(array_length(v_repair_codes, 1), 0));

    RETURN v_id;
END;
$$ LANGUAGE plpgsql;


-- Seeds the John Smith / ARCHR-2024-001234 application that powers
-- interface/requestor/dashboard-draft.html and the matching admin view.
-- Idempotent: re-running replaces the previous placeholder rows.
CREATE OR REPLACE FUNCTION seed_dashboard_placeholder() RETURNS TEXT AS $$
DECLARE
    v_submission_id INTEGER;
    v_case_id       INTEGER;
    v_requestor_id  INTEGER;
    v_caseworker_id INTEGER;
    v_habitat_id    INTEGER;
    v_status_id     INTEGER;
    v_submitted_at  TIMESTAMP := TIMESTAMP '2024-11-15 10:30:00';
    v_case_number   TEXT      := 'ARCHR-2024-001234';
    v_anchor_id     TEXT      := 'ANCHOR-2024-0001234';
BEGIN
    PERFORM _ensure_dummy_partner_orgs();
    SELECT id INTO v_habitat_id FROM coalition_organizations WHERE organization_code = 'AHFH';

    -- Drop any prior placeholder so the seeder stays idempotent.
    DELETE FROM intake_submissions
     WHERE applicant_first_name = 'John' AND applicant_last_name = 'Smith' AND is_test = TRUE;
    DELETE FROM system_users WHERE email IN ('john.smith@example.com', 'sarah.martinez@archr.org');

    -- Requestor + caseworker accounts.
    INSERT INTO system_users (username, email, full_name, first_name, last_name, phone, is_active)
    VALUES ('john.smith', 'john.smith@example.com', 'John Smith', 'John', 'Smith', '(828) 555-0188', TRUE)
    RETURNING id INTO v_requestor_id;
    INSERT INTO user_role_assignments (user_id, role_id)
    SELECT v_requestor_id, id FROM roles WHERE role_code = 'REQUESTOR';

    INSERT INTO system_users (username, email, full_name, first_name, last_name, phone, is_active)
    VALUES ('sarah.martinez', 'sarah.martinez@archr.org', 'Sarah Martinez', 'Sarah', 'Martinez', '(828) 555-0123', TRUE)
    RETURNING id INTO v_caseworker_id;
    INSERT INTO user_role_assignments (user_id, organization_id, role_id)
    SELECT v_caseworker_id, v_habitat_id, id FROM roles WHERE role_code = 'CASEWORKER';

    -- Build the submission via the generic generator so all child rows line up.
    v_submission_id := generate_dummy_submission(jsonb_build_object(
        'first_name',            'John',
        'last_name',             'Smith',
        'email',                 'john.smith@example.com',
        'address',               '247 Riverside Drive',
        'city',                  'Asheville',
        'zip',                   '28804',
        'income',                32400,
        'helene_related',        TRUE,
        'submitted_at',          to_char(v_submitted_at, 'YYYY-MM-DD HH24:MI:SS'),
        'submission_status',     'ELIGIBLE',
        'repair_codes',          jsonb_build_array('no_hvac', 'open_to_elements', 'accessibility'),
        'household_attributes',  jsonb_build_array('person_over_62', 'person_with_disability')
    ));

    -- Link the submission to its requestor account.
    UPDATE intake_submissions SET requestor_user_id = v_requestor_id WHERE id = v_submission_id;

    -- Pin the anchor id so the dashboard's ARCHR-2024-001234 reference resolves.
    UPDATE application_anchor
       SET anchor_id        = v_anchor_id,
           case_number      = v_case_number,
           current_status   = 'in_review',
           assigned_organization_id = v_habitat_id,
           assigned_at      = v_submitted_at + INTERVAL '18 days'
     WHERE submission_id = v_submission_id;

    -- Move the queue entry to "assigned to Habitat", matching the timeline copy.
    UPDATE review_queue
       SET status          = 'IN_REVIEW',
           organization_id = v_habitat_id,
           assigned_to_id  = v_caseworker_id,
           assigned_at     = v_submitted_at + INTERVAL '18 days'
     WHERE submission_id = v_submission_id;

    -- Active case row so the requestor + staff dashboards both see it.
    SELECT id INTO v_status_id FROM case_statuses WHERE status_code = 'PENDING_REVIEW';
    INSERT INTO cases (
        submission_id, case_number, status_id,
        assigned_caseworker_id, intake_completed_at, created_at, updated_at
    ) VALUES (
        v_submission_id, v_case_number, v_status_id,
        v_caseworker_id, v_submitted_at + INTERVAL '13 days',
        v_submitted_at, v_submitted_at + INTERVAL '20 days'
    ) RETURNING id INTO v_case_id;
    -- Trigger built the case_number from NEW.id; force the placeholder value.
    UPDATE cases SET case_number = v_case_number WHERE id = v_case_id;

    RETURN format('Seeded placeholder: submission_id=%s, case=%s, anchor=%s',
                  v_submission_id, v_case_number, v_anchor_id);
END;
$$ LANGUAGE plpgsql;

-- Batch generator: produces p_count randomised submissions across a spread of
-- ZIP codes, repair issues, and submission dates so the admin queue has volume.
CREATE OR REPLACE FUNCTION generate_dummy_submissions(p_count INTEGER DEFAULT 10)
RETURNS INTEGER AS $$
DECLARE
    v_firsts  TEXT[] := ARRAY['Maria','David','Linda','James','Patricia','Robert','Jennifer',
                              'Michael','Barbara','William','Elizabeth','Thomas','Susan','Daniel'];
    v_lasts   TEXT[] := ARRAY['Garcia','Johnson','Williams','Brown','Davis','Miller','Wilson',
                              'Moore','Taylor','Anderson','Thomas','Jackson','White','Harris'];
    v_cities  TEXT[]  := ARRAY['Asheville','Black Mountain','Swannanoa','Weaverville','Candler','Arden'];
    v_zips    TEXT[]  := ARRAY['28801','28803','28804','28805','28806','28711','28778','28787'];
    -- JSONB[] (not TEXT[][]) so single-index access returns a whole inner list.
    v_repairs JSONB[] := ARRAY[
        '["no_hvac","open_to_elements"]'::JSONB,
        '["no_potable_water","no_bathroom"]'::JSONB,
        '["no_kitchen","accessibility"]'::JSONB,
        '["unable_to_stay","no_entry"]'::JSONB,
        '["eviction_risk","no_hvac"]'::JSONB
    ];
    v_attrs   JSONB[] := ARRAY[
        '["single_parent","child_under_5"]'::JSONB,
        '["person_over_62"]'::JSONB,
        '["person_with_disability","veteran"]'::JSONB,
        '["snap_wic","child_under_5"]'::JSONB,
        '[]'::JSONB
    ];
    v_first   TEXT;
    v_last    TEXT;
    v_idx     INTEGER;
    v_created INTEGER := 0;
BEGIN
    PERFORM _ensure_dummy_partner_orgs();
    FOR v_idx IN 1..p_count LOOP
        v_first := v_firsts[1 + FLOOR(RANDOM() * array_length(v_firsts, 1))::INT];
        v_last  := v_lasts [1 + FLOOR(RANDOM() * array_length(v_lasts,  1))::INT];
        PERFORM generate_dummy_submission(jsonb_build_object(
            'first_name',      v_first,
            'last_name',       v_last,
            'email',           LOWER(v_first || '.' || v_last) || v_idx || '@example.com',
            'city',            v_cities[1 + FLOOR(RANDOM() * array_length(v_cities, 1))::INT],
            'zip',             v_zips  [1 + FLOOR(RANDOM() * array_length(v_zips,   1))::INT],
            'income',          18000 + FLOOR(RANDOM() * 30000)::INT,
            'helene_related',  RANDOM() < 0.7,
            'submitted_at',    to_char(CURRENT_TIMESTAMP - (FLOOR(RANDOM() * 60)::TEXT || ' days')::INTERVAL,
                                       'YYYY-MM-DD HH24:MI:SS'),
            'repair_codes',    v_repairs[1 + FLOOR(RANDOM() * array_length(v_repairs, 1))::INT],
            'household_attributes', v_attrs[1 + FLOOR(RANDOM() * array_length(v_attrs, 1))::INT]
        ));
        v_created := v_created + 1;
    END LOOP;
    RETURN v_created;
END;
$$ LANGUAGE plpgsql;
