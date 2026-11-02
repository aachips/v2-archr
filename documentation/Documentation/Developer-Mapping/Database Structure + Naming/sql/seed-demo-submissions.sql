-- =====================================================
-- SEED: 50 substantive demo intake submissions
-- =====================================================
-- Development/demo data for the Org Admin UI and the application lifecycle
-- (ARCHR Core Terminology and Operational Logic). Not run by _master.sql.
--
-- Every submission is fully filled out (contact, address, household, repairs,
-- Helene/FEMA/insurance, income) and flagged is_test = TRUE. The seed drives
-- the REAL lifecycle machinery for each row: placecode derivation,
-- deduplicate_submissions() into applications, anchor + review queue +
-- unclaimed intake case, and the flags-only check_eligibility().
--
-- Includes deliberate demo scenarios:
--   * 2 duplicate pairs (same address, follow-up submission) -> one
--     application per placecode with two linked submissions
--   * red-flag demos: income over 80% AMI, outside service area, renter,
--     mobile home without lot ownership (all route to human review — the
--     system never auto-denies)
--   * a yellow-flag demo: applicant under 18
--   * a zero-income affidavit and calculator-method income records
--   * a post-pass that claims several applications through claim_application()
--     (including one application claimed by TWO orgs over different repairs),
--     logs progress events, and expires one backdated claim via the real
--     expire_stale_claims() job
--
-- Usage:
--   psql -d archr -f sql/wipe-intake-test-data.sql   (optional: start clean)
--   psql -d archr -f sql/seed-demo-submissions.sql
-- or: php app/apply-migration.php sql/seed-demo-submissions.sql
-- =====================================================

\set ON_ERROR_STOP on

BEGIN;

CREATE OR REPLACE FUNCTION seed_demo_submission(p_config JSONB)
RETURNS INTEGER AS $func$
DECLARE
    v_id INT;
    v_app_id INT;
    v_status_id INT;
    v_placecode VARCHAR(50);
    v_project_code VARCHAR(50);
    v_first TEXT := p_config->>'first_name';
    v_last TEXT := p_config->>'last_name';
    v_email TEXT := p_config->>'email';
    v_phone TEXT := p_config->>'phone';
    v_address TEXT := p_config->>'address';
    v_city TEXT := p_config->>'city';
    v_zip TEXT := p_config->>'zip';
    v_home_type TEXT := COALESCE(p_config->>'home_type', 'traditional');
    v_helene BOOLEAN := COALESCE((p_config->>'helene_related')::BOOLEAN, TRUE);
    v_has_income BOOLEAN := COALESCE((p_config->>'has_income')::BOOLEAN, TRUE);
    v_income_method TEXT := COALESCE(p_config->>'income_method', 'gross');
    v_income NUMERIC := (p_config->>'gross_income')::NUMERIC;
    v_repair_codes TEXT[] := ARRAY(SELECT jsonb_array_elements_text(p_config->'repair_categories'));
    v_urgent_codes TEXT[] := ARRAY(SELECT jsonb_array_elements_text(COALESCE(p_config->'urgent', '[]'::jsonb)));
    v_attr_codes TEXT[] := ARRAY(SELECT jsonb_array_elements_text(COALESCE(p_config->'attributes', '[]'::jsonb)));
    v_submitted_at TIMESTAMP := CURRENT_TIMESTAMP - ((COALESCE(p_config->>'days_ago', '0')) || ' days')::INTERVAL;
    v_is_referral BOOLEAN := COALESCE((p_config->>'is_referral')::BOOLEAN, FALSE);
    v_fema JSONB := p_config->'fema';
    v_ins JSONB := p_config->'insurance';
    v_repair JSONB;
    v_inc JSONB;
    v_i INT := 0;
    v_prev_repl TEXT;
BEGIN
    -- Suppress the intake trigger only for the INSERT (it refreshes a
    -- materialized view per row); anchor/case generators still fire.
    v_prev_repl := current_setting('session_replication_role');
    PERFORM set_config('session_replication_role', 'replica', true);

    INSERT INTO intake_submissions (
        submitted_at, language, is_referral,
        referrer_name, referrer_organization, referrer_email, referrer_notes,
        consent_agreed,
        applicant_first_name, applicant_last_name, applicant_dob,
        preferred_phone, preferred_text, preferred_email,
        home_phone, cell_phone, contact_email, contact_notes,
        home_address, home_city, home_state, home_zip,
        is_primary_residence, home_type, year_built, move_in_date,
        owns_home, owns_lot, insurance_provider, lived_one_year,
        household_size, household_adults, additional_repair_details,
        urgent_unable_to_stay, urgent_no_hvac, urgent_no_potable_water,
        urgent_no_bathroom, urgent_no_kitchen, urgent_open_to_elements,
        urgent_no_entry, urgent_accessibility, urgent_other_issue, urgent_eviction_risk,
        helene_related,
        fema_claim_filed, fema_outcome, fema_settlement_amount,
        fema_remaining_exists, fema_remaining_amount,
        insurance_claim_filed, insurance_outcome, insurance_settlement_amount,
        insurance_remaining_exists, insurance_remaining_amount,
        has_income, income_method, gross_annual_income, income_docs_method,
        zero_income_first_name, zero_income_last_name, zero_income_address, zero_income_agreed,
        applicant_signature, submission_status, is_test
    ) VALUES (
        v_submitted_at, 'eng', v_is_referral,
        CASE WHEN v_is_referral THEN p_config->>'referrer_name' END,
        CASE WHEN v_is_referral THEN p_config->>'referrer_organization' END,
        CASE WHEN v_is_referral THEN p_config->>'referrer_email' END,
        CASE WHEN v_is_referral THEN p_config->>'referrer_notes' END,
        TRUE,
        v_first, v_last, (p_config->>'dob')::DATE,
        'phone' = ANY(ARRAY(SELECT jsonb_array_elements_text(COALESCE(p_config->'contact_methods', '["email"]'::jsonb)))),
        'text' = ANY(ARRAY(SELECT jsonb_array_elements_text(COALESCE(p_config->'contact_methods', '["email"]'::jsonb)))),
        'email' = ANY(ARRAY(SELECT jsonb_array_elements_text(COALESCE(p_config->'contact_methods', '["email"]'::jsonb)))),
        v_phone, v_phone, v_email, p_config->>'contact_notes',
        v_address, v_city, 'NC', v_zip,
        TRUE, v_home_type, (p_config->>'year_built')::INTEGER,
        CURRENT_DATE - (COALESCE(p_config->>'years_in_home', '6') || ' years')::INTERVAL,
        COALESCE((p_config->>'owns_home')::BOOLEAN, TRUE),
        COALESCE((p_config->>'owns_lot')::BOOLEAN, TRUE),
        p_config->>'insurance_provider', TRUE,
        (p_config->>'household_size')::INTEGER, (p_config->>'household_adults')::INTEGER,
        p_config->>'details',
        'unable_to_stay' = ANY(v_urgent_codes), 'no_hvac' = ANY(v_urgent_codes),
        'no_potable_water' = ANY(v_urgent_codes), 'no_bathroom' = ANY(v_urgent_codes),
        'no_kitchen' = ANY(v_urgent_codes), 'open_to_elements' = ANY(v_urgent_codes),
        'no_entry' = ANY(v_urgent_codes), 'accessibility' = ANY(v_urgent_codes),
        'other_issue' = ANY(v_urgent_codes), 'eviction_risk' = ANY(v_urgent_codes),
        v_helene,
        COALESCE((v_fema->>'filed')::BOOLEAN, FALSE), v_fema->>'outcome',
        (v_fema->>'settlement')::NUMERIC, (v_fema->>'remaining_exists')::BOOLEAN, (v_fema->>'remaining')::NUMERIC,
        COALESCE((v_ins->>'filed')::BOOLEAN, FALSE), v_ins->>'outcome',
        (v_ins->>'settlement')::NUMERIC, (v_ins->>'remaining_exists')::BOOLEAN, (v_ins->>'remaining')::NUMERIC,
        v_has_income, v_income_method,
        CASE WHEN v_has_income AND v_income_method = 'gross' THEN v_income END,
        COALESCE(p_config->>'income_docs', 'email_link'),
        CASE WHEN NOT v_has_income THEN v_first END,
        CASE WHEN NOT v_has_income THEN v_last END,
        CASE WHEN NOT v_has_income THEN v_address || ', ' || v_city || ' NC ' || v_zip END,
        CASE WHEN NOT v_has_income THEN TRUE END,
        'data:image/png;base64,SEED-DEMO-SIGNATURE', 'pending', TRUE
    ) RETURNING id INTO v_id;

    PERFORM set_config('session_replication_role', v_prev_repl, true);

    -- Junction rows
    INSERT INTO submission_repair_categories (submission_id, category_id)
    SELECT v_id, rc.id FROM repair_categories rc WHERE rc.category_code = ANY(v_repair_codes)
    ON CONFLICT DO NOTHING;

    INSERT INTO submission_household_attributes (submission_id, attribute_id)
    SELECT v_id, ha.id FROM household_attributes ha WHERE ha.attribute_name = ANY(v_attr_codes)
    ON CONFLICT DO NOTHING;

    INSERT INTO submission_contact_methods (submission_id, method_id)
    SELECT v_id, cm.id FROM contact_methods cm
     WHERE cm.method_code = ANY(ARRAY(SELECT jsonb_array_elements_text(COALESCE(p_config->'contact_methods', '["email"]'::jsonb))))
    ON CONFLICT DO NOTHING;

    -- Applicant-reported repair rows (Repairs Needed list)
    FOR v_repair IN SELECT * FROM jsonb_array_elements(COALESCE(p_config->'repairs', '[]'::jsonb)) LOOP
        v_i := v_i + 1;
        INSERT INTO repair_requests (submission_id, repair_need, priority, sort_order)
        SELECT v_id, v_repair->>'need', (v_repair->>'priority')::INTEGER, v_i;
    END LOOP;

    -- Calculator-method income rows
    FOR v_inc IN SELECT * FROM jsonb_array_elements(COALESCE(p_config->'income_records', '[]'::jsonb)) LOOP
        INSERT INTO income_records (submission_id, whose_income, income_source, frequency, amount, created_at)
        VALUES (v_id, v_inc->>'whose', v_inc->>'source', v_inc->>'frequency', (v_inc->>'amount')::NUMERIC, v_submitted_at);
    END LOOP;

    -- ---- Real lifecycle: placecode -> application -> anchor -> queue -> case -> flags ----
    v_placecode := archr_generate_placecode(v_address);
    UPDATE intake_submissions SET placecode = v_placecode WHERE id = v_id;
    v_app_id := deduplicate_submissions(v_id);

    v_project_code := CASE WHEN v_placecode IS NULL THEN NULL
                           ELSE (CASE WHEN v_home_type = 'mobile' THEN 'H' WHEN v_helene THEN 'D' ELSE 'A' END) || v_placecode
                      END;

    INSERT INTO application_anchor (
        submission_id, submitted_at, submitted_from_ip,
        is_eligible, current_status,
        income_bucket, county_bucket, repair_type_bucket, helene_related,
        placecode, project_code
    ) VALUES (
        v_id, v_submitted_at, '127.0.0.1',
        TRUE, 'eligible',
        get_income_bucket(v_income), get_county_bucket(v_city, v_zip),
        v_repair_codes[1], v_helene,
        v_placecode, v_project_code
    );

    INSERT INTO review_queue (submission_id, status, queued_at, priority_score)
    VALUES (v_id, 'PENDING_REVIEW', v_submitted_at, 10 * COALESCE(array_length(v_urgent_codes, 1), 0));

    -- One unclaimed intake case per application (first claiming org adopts it).
    SELECT id INTO v_status_id FROM case_statuses WHERE status_code = 'PENDING_REVIEW' LIMIT 1;
    IF v_status_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM cases WHERE application_id = v_app_id AND organization_id IS NULL
    ) THEN
        INSERT INTO cases (submission_id, application_id, status_id, project_code, placecode, created_at, updated_at)
        VALUES (v_id, v_app_id, v_status_id, v_project_code, v_placecode, v_submitted_at, v_submitted_at);
    END IF;

    -- Flags-only eligibility (green/yellow/red; stored on the application).
    PERFORM check_eligibility(v_id);

    RETURN v_id;
END;
$func$ LANGUAGE plpgsql;
-- ---------------------------------------------------------------
-- The 50 demo submissions (config-driven; one JSON object per row)
-- ---------------------------------------------------------------
DO $$
DECLARE
    v_cfg JSONB;
    v_id INT;
    v_ids INT[] := '{}';
    v_configs JSONB := $configs$[
{"first_name":"Dorothy","last_name":"Calloway","dob":"1951-04-12","email":"dorothy.calloway@example.com","phone":"(828) 555-0143","address":"88 Virginia Avenue","city":"Asheville","zip":"28806","year_built":1948,"household_size":1,"household_adults":1,"attributes":["person_over_62"],"repair_categories":["open_to_elements"],"urgent":["open_to_elements"],"repairs":[{"need":"Roof leaking over the bedroom; the tarp from the storm is failing","priority":1},{"need":"Rotted soffit and fascia at the rear eave","priority":2}],"helene_related":true,"fema":{"filed":true,"outcome":"denied"},"income_method":"gross","gross_income":21480,"details":"Fixed income (Social Security). Bedroom ceiling stained and sagging; buckets out when it rains.","days_ago":2},
{"first_name":"Marcus","last_name":"Johnson","dob":"1968-09-02","email":"marcus.johnson@example.com","phone":"(828) 555-0161","address":"45 Old Haw Creek Road","city":"Asheville","zip":"28805","year_built":1962,"household_size":2,"household_adults":2,"attributes":["veteran"],"repair_categories":["no_hvac"],"urgent":["no_hvac"],"repairs":[{"need":"Furnace stopped working entirely; using space heaters","priority":1}],"helene_related":false,"income_method":"gross","gross_income":31200,"details":"VA disability household. Winter is the worry.","days_ago":3},
{"first_name":"Patricia","last_name":"Alvarez","dob":"1989-06-21","email":"patricia.alvarez@example.com","phone":"(828) 555-0177","address":"112 Ridgecrest Drive","city":"Black Mountain","zip":"28711","year_built":1975,"household_size":4,"household_adults":1,"attributes":["single_parent","child_under_5"],"repair_categories":["no_bathroom"],"urgent":["no_bathroom"],"repairs":[{"need":"Bathroom floor rotted through around the toilet; soft subfloor","priority":1},{"need":"Bathtub drain leaks into the crawlspace","priority":2}],"helene_related":true,"income_method":"calculator","income_records":[{"whose":"mine","source":"work","frequency":"monthly","amount":2600}],"details":"Three kids, youngest is three. Only one bathroom.","days_ago":5},
{"first_name":"Jimmy","last_name":"Raynaud","dob":"1958-02-14","email":"jimmy.raynaud@example.com","phone":"(828) 555-0102","address":"8 Turkey Creek Road","city":"Marshall","zip":"28753","home_type":"mobile","year_built":1986,"household_size":2,"household_adults":2,"owns_lot":false,"repair_categories":["no_hvac","open_to_elements"],"urgent":["no_hvac"],"repairs":[{"need":"Skirting torn off on the north side; pipes froze twice","priority":1},{"need":"Furnace short-cycles and smells of gas","priority":2}],"helene_related":true,"fema":{"filed":true,"outcome":"settled","settlement":4200,"remaining_exists":true,"remaining":1500},"income_method":"gross","gross_income":18900,"details":"Own the trailer, rent the lot.","days_ago":7},
{"first_name":"Evelyn","last_name":"Sanders","dob":"1962-11-30","email":"evelyn.sanders@example.com","phone":"(828) 555-0119","address":"220 Kimberly Avenue","city":"Asheville","zip":"28804","year_built":1958,"household_size":1,"household_adults":1,"repair_categories":["no_kitchen"],"repairs":[{"need":"Kitchen supply line burst; cabinet base is swollen and moldy","priority":1}],"helene_related":false,"income_method":"gross","gross_income":62500,"details":"Still working part-time at the hospital.","days_ago":8},
{"first_name":"Tom","last_name":"Beck","dob":"1984-03-17","email":"tom.beck@example.com","phone":"(828) 555-0134","address":"56 Banks Avenue","city":"Asheville","zip":"28801","year_built":1925,"household_size":2,"household_adults":2,"owns_home":false,"repair_categories":["no_hvac"],"repairs":[{"need":"Heat pump dead; landlord unresponsive for months","priority":1}],"helene_related":false,"income_method":"gross","gross_income":27000,"details":"Renting the house; landlord lives out of state.","days_ago":9},
{"first_name":"Rosa","last_name":"Jimenez","dob":"1972-08-08","email":"rosa.jimenez@example.com","phone":"(828) 555-0151","address":"34 Main Street","city":"Rutherfordton","zip":"28139","year_built":1969,"household_size":3,"household_adults":2,"repair_categories":["open_to_elements"],"urgent":["open_to_elements"],"repairs":[{"need":"Tree limb punctured the roof during Helene; attic open to rain","priority":1}],"helene_related":true,"fema":{"filed":true,"outcome":"other"},"income_method":"gross","gross_income":24000,"details":"FEMA said the damage was insufficient for the program.","days_ago":10},
{"first_name":"Walter","last_name":"Boone","dob":"1949-12-01","email":"walter.boone@example.com","phone":"(828) 555-0182","address":"15 Church Street","city":"Weaverville","zip":"28787","year_built":1938,"household_size":1,"household_adults":1,"attributes":["person_over_62"],"repair_categories":["no_potable_water"],"urgent":["no_potable_water"],"repairs":[{"need":"Well pump failed; hauling water from the neighbor","priority":1}],"helene_related":true,"has_income":false,"income_method":"gross","details":"No income this year after the shop closed. Zero income affidavit signed.","days_ago":11},
{"first_name":"Helen","last_name":"Crowe","dob":"1946-05-25","email":"helen.crowe@example.com","phone":"(828) 555-0127","address":"90 Crowe Hollow Road","city":"Candler","zip":"28715","year_built":1952,"household_size":1,"household_adults":1,"attributes":["person_over_62","person_with_disability"],"repair_categories":["accessibility","no_entry"],"urgent":["accessibility"],"repairs":[{"need":"Wheelchair ramp needed at the front steps; fell twice in July","priority":1},{"need":"Front door frame sagging; deadbolt no longer catches","priority":2}],"helene_related":false,"income_method":"calculator","income_records":[{"whose":"mine","source":"social_security","frequency":"monthly","amount":1640},{"whose":"mine","source":"retirement","frequency":"monthly","amount":410}],"details":"Widowed last year. Daughter helps on weekends.","days_ago":13},
{"first_name":"George","last_name":"Finley","dob":"1957-07-19","email":"george.finley@example.com","phone":"(828) 555-0148","address":"12 Cherry Street","city":"Asheville","zip":"28801","year_built":1946,"household_size":2,"household_adults":2,"repair_categories":["open_to_elements"],"urgent":["open_to_elements"],"repairs":[{"need":"Roof replacement; three-tab shingles blown off across the south slope","priority":1},{"need":"Plumbing stack cracked, leaks into the kitchen wall","priority":2},{"need":"Water heater rusted at the base","priority":3}],"helene_related":true,"fema":{"filed":true,"outcome":"denied"},"insurance":{"filed":true,"outcome":"denied"},"income_method":"gross","gross_income":38900,"details":"Both denial letters in hand; can upload them.","days_ago":40},{"first_name":"George","last_name":"Finley","dob":"1957-07-19","email":"george.finley@example.com","phone":"(828) 555-0148","address":"12 Cherry Street","city":"Asheville","zip":"28801","year_built":1946,"household_size":2,"household_adults":2,"repair_categories":["open_to_elements"],"urgent":["open_to_elements"],"repairs":[{"need":"Roof replacement; three-tab shingles blown off across the south slope","priority":1},{"need":"Plumbing stack cracked, leaks into the kitchen wall","priority":2},{"need":"Water heater rusted at the base","priority":3}],"helene_related":true,"income_method":"gross","gross_income":38900,"contact_notes":"Follow-up submission: forgot to attach income documents the first time.","details":"Second submission to add paperwork.","days_ago":37},
{"first_name":"Sandra","last_name":"McGee","dob":"1978-04-03","email":"sandra.mcgee@example.com","phone":"(828) 555-0195","address":"3 Locust Street","city":"Black Mountain","zip":"28711","year_built":1971,"household_size":3,"household_adults":2,"repair_categories":["no_kitchen"],"urgent":["no_kitchen"],"repairs":[{"need":"Kitchen subfloor soft at the sink; stove unusable after the leak","priority":1}],"helene_related":true,"income_method":"calculator","income_records":[{"whose":"mine","source":"self_employment","frequency":"monthly","amount":1750},{"whose":"other","source":"work","frequency":"weekly","amount":310}],"details":"I clean houses; my son stocks shelves.","days_ago":14},
{"first_name":"Henry","last_name":"Abernathy","dob":"1955-10-11","email":"henry.abernathy@example.com","phone":"(828) 555-0108","address":"204 Sutton Avenue","city":"Asheville","zip":"28806","year_built":1940,"household_size":2,"household_adults":2,"attributes":["person_over_62"],"repair_categories":["no_hvac"],"repairs":[{"need":"Oil furnace quit in January; kerosene heater in the living room","priority":1}],"helene_related":false,"income_method":"gross","gross_income":27400,"details":"Kerosene is expensive and I worry about the fumes.","days_ago":15},
{"first_name":"Lucille","last_name":"Plemmons","dob":"1943-01-28","email":"lucille.plemmons@example.com","phone":"(828) 555-0171","address":"7 Beaverdam Road","city":"Asheville","zip":"28804","year_built":1935,"household_size":1,"household_adults":1,"attributes":["person_over_62"],"repair_categories":["no_potable_water"],"repairs":[{"need":"Galvanized lines barely trickle; the house needs a re-pipe","priority":1}],"helene_related":false,"income_method":"gross","gross_income":15800,"details":"","days_ago":16},
{"first_name":"Robert","last_name":"Trantham","dob":"1966-12-09","email":"robert.trantham@example.com","phone":"(828) 555-0139","address":"131 Montreat Road","city":"Black Mountain","zip":"28711","year_built":1965,"household_size":2,"household_adults":2,"repair_categories":["open_to_elements"],"urgent":["open_to_elements"],"repairs":[{"need":"Tree on the roof during Helene; rafters cracked over the den","priority":1},{"need":"Den ceiling drywall collapsed","priority":2}],"helene_related":true,"fema":{"filed":true,"outcome":"settled","settlement":9800,"remaining_exists":false},"insurance":{"filed":true,"outcome":"denied"},"income_method":"gross","gross_income":44600,"details":"Settlement went to the tree removal and the mortgage.","days_ago":17},
{"first_name":"Angela","last_name":"Rice","dob":"1992-02-26","email":"angela.rice@example.com","phone":"(828) 555-0112","address":"66 Florida Avenue","city":"Asheville","zip":"28806","year_built":1955,"household_size":3,"household_adults":1,"attributes":["single_parent","snap_wic"],"repair_categories":["no_bathroom","no_hvac"],"urgent":["no_bathroom"],"repairs":[{"need":"Only toilet runs constantly and the flange leaks at the base","priority":1},{"need":"Wall heater emits a burning smell","priority":2}],"helene_related":true,"income_method":"gross","gross_income":23900,"details":"SNAP household; two boys under ten.","days_ago":19},
{"first_name":"Charles","last_name":"Sprinkle","dob":"1960-06-14","email":"charles.sprinkle@example.com","phone":"(828) 555-0166","address":"481 Sand Hill Road","city":"Asheville","zip":"28806","year_built":1972,"household_size":2,"household_adults":2,"repair_categories":["other_issue"],"repairs":[{"need":"Crawlspace joists were sistered with scrap after the flood; needs proper repair","priority":1}],"helene_related":true,"income_method":"gross","gross_income":35100,"details":"The river came within two feet of the floor joists.","days_ago":21},
{"first_name":"Betty","last_name":"Gudger","dob":"1950-09-23","email":"betty.gudger@example.com","phone":"(828) 555-0185","address":"29 Old Leicester Highway","city":"Candler","zip":"28715","year_built":1944,"household_size":1,"household_adults":1,"attributes":["person_over_62"],"repair_categories":["no_hvac","open_to_elements"],"urgent":["no_hvac"],"repairs":[{"need":"No central heat; two window units for summer only","priority":1},{"need":"Chimney flashing leaks into the hall closet","priority":2}],"helene_related":false,"income_method":"gross","gross_income":17200,"details":"","days_ago":23},
{"first_name":"James","last_name":"Whitson","dob":"1975-05-06","email":"james.whitson@example.com","phone":"(828) 555-0121","address":"152 New Stock Road","city":"Weaverville","zip":"28787","year_built":1980,"household_size":4,"household_adults":2,"repair_categories":["no_potable_water"],"urgent":["no_potable_water"],"repairs":[{"need":"Well runs dry every evening; pressure tank is waterlogged","priority":1}],"helene_related":true,"income_method":"calculator","income_records":[{"whose":"mine","source":"work","frequency":"biweekly","amount":1180}],"details":"Family of four, two teenagers.","days_ago":24},
{"first_name":"Frances","last_name":"Hyatt","dob":"1948-08-17","email":"frances.hyatt@example.com","phone":"(828) 555-0144","address":"5 Hill Street","city":"Marshall","zip":"28753","year_built":1930,"household_size":1,"household_adults":1,"attributes":["person_over_62","person_with_disability"],"repair_categories":["no_entry","accessibility"],"urgent":["no_entry"],"repairs":[{"need":"Back steps collapsed; only one way in and out of the house","priority":1},{"need":"Grab bars needed in the bathroom","priority":2}],"helene_related":false,"income_method":"gross","gross_income":14900,"details":"I cannot safely leave the house alone anymore.","days_ago":25},{"first_name":"Douglas","last_name":"Kirkpatrick","dob":"1970-01-19","email":"douglas.kirkpatrick@example.com","phone":"(828) 555-0158","address":"338 Biltmore Avenue","city":"Asheville","zip":"28801","year_built":1922,"household_size":2,"household_adults":2,"repair_categories":["open_to_elements"],"repairs":[{"need":"Porch roof pulling away from the ledger; gaps at the header","priority":1}],"helene_related":true,"income_method":"gross","gross_income":41200,"details":"","days_ago":27},
{"first_name":"Wanda","last_name":"Suttles","dob":"1963-03-30","email":"wanda.suttles@example.com","phone":"(828) 555-0199","address":"77 Grove Street","city":"Asheville","zip":"28801","year_built":1928,"household_size":3,"household_adults":3,"repair_categories":["no_kitchen"],"repairs":[{"need":"Kitchen wiring is knob-and-tube; the breaker trips with the microwave","priority":1}],"helene_related":false,"income_method":"gross","gross_income":52400,"details":"Three adults share the house.","days_ago":28},
{"first_name":"Billy","last_name":"Messer","dob":"1982-07-07","email":"billy.messer@example.com","phone":"(828) 555-0116","address":"410 Swannanoa River Road","city":"Asheville","zip":"28805","home_type":"mobile","year_built":1994,"household_size":2,"household_adults":2,"repair_categories":["no_hvac","open_to_elements"],"urgent":["open_to_elements"],"repairs":[{"need":"Roof seam split after the storm; water runs down the hallway wall","priority":1},{"need":"Heat strips failed","priority":2}],"helene_related":true,"fema":{"filed":true,"outcome":"denied"},"income_method":"gross","gross_income":29800,"details":"Own the trailer and the lot.","days_ago":30},
{"first_name":"June","last_name":"Arrowood","dob":"1954-11-02","email":"june.arrowood@example.com","phone":"(828) 555-0132","address":"18 Rice Branch Road","city":"Asheville","zip":"28805","year_built":1950,"household_size":1,"household_adults":1,"attributes":["person_over_62"],"repair_categories":["no_bathroom"],"repairs":[{"need":"Shower pan cracked; water getting under the vinyl","priority":1}],"helene_related":false,"income_method":"gross","gross_income":19600,"details":"","days_ago":31},
{"first_name":"Albert","last_name":"Pruitt","dob":"1945-04-15","email":"albert.pruitt@example.com","phone":"(828) 555-0173","address":"263 Haywood Road","city":"Asheville","zip":"28806","year_built":1926,"household_size":2,"household_adults":2,"attributes":["person_over_62"],"repair_categories":["open_to_elements","no_entry"],"repairs":[{"need":"Front porch floorboards rotted through in two places","priority":1},{"need":"Gutter tore off the east side; water sheets down the wall","priority":2}],"helene_related":true,"income_method":"gross","gross_income":26700,"details":"My wife has early dementia; I do the calling.","days_ago":33},
{"first_name":"Sheila","last_name":"Godfrey","dob":"1987-10-27","email":"sheila.godfrey@example.com","phone":"(828) 555-0164","address":"9 Boston Way","city":"Asheville","zip":"28806","year_built":1968,"household_size":3,"household_adults":1,"attributes":["single_parent","child_under_5","snap_wic"],"repair_categories":["no_hvac"],"urgent":["no_hvac"],"repairs":[{"need":"Baseboard heaters dead in the kids bedrooms","priority":1}],"helene_related":true,"is_referral":true,"referrer_name":"Pastel Reyes","referrer_organization":"Poder Emma","referrer_email":"intake@poderemma.org","referrer_notes":"Family referred through our community navigators.","income_method":"calculator","income_records":[{"whose":"mine","source":"work","frequency":"weekly","amount":430}],"details":"Toddler at home; keeping rooms warm with the oven door open, which scares me.","days_ago":34},
{"first_name":"Ray","last_name":"Buckner","dob":"1959-01-23","email":"ray.buckner@example.com","phone":"(828) 555-0187","address":"85 Upper Brush Creek Road","city":"Marshall","zip":"28753","year_built":1978,"household_size":2,"household_adults":2,"repair_categories":["open_to_elements"],"repairs":[{"need":"Metal roof panels lifted at the ridge; leaks at the seams","priority":1}],"helene_related":true,"insurance":{"filed":true,"outcome":"settled","settlement":6100,"remaining_exists":true,"remaining":2400},"income_method":"gross","gross_income":33500,"details":"","days_ago":35},
{"first_name":"Carolyn","last_name":"Metcalf","dob":"1947-06-09","email":"carolyn.metcalf@example.com","phone":"(828) 555-0129","address":"141 Patton Avenue","city":"Asheville","zip":"28801","year_built":1920,"household_size":1,"household_adults":1,"attributes":["person_over_62"],"repair_categories":["no_potable_water"],"repairs":[{"need":"Water heater dead; heating water on the stove","priority":1}],"helene_related":false,"has_income":false,"income_method":"gross","details":"No income this year; affidavit signed at the library.","days_ago":36},
{"first_name":"Ernest","last_name":"Balling","dob":"1973-12-18","email":"ernest.balling@example.com","phone":"(828) 555-0106","address":"52 Pond Road","city":"Asheville","zip":"28806","year_built":1963,"household_size":2,"household_adults":2,"repair_categories":["no_bathroom"],"repairs":[{"need":"Tub surround separated from the wall; studs are soft","priority":1}],"helene_related":false,"income_method":"gross","gross_income":30800,"details":"","days_ago":38},
{"first_name":"Ruby","last_name":"Hensley","dob":"1953-02-11","email":"ruby.hensley@example.com","phone":"(828) 555-0153","address":"12 Walnut Street","city":"Marshall","zip":"28753","year_built":1942,"household_size":1,"household_adults":1,"attributes":["person_over_62"],"repair_categories":["no_hvac"],"urgent":["no_hvac"],"repairs":[{"need":"Monitor heater quit; using the oven for heat on cold mornings","priority":1}],"helene_related":true,"income_method":"gross","gross_income":16400,"details":"The oven for heat worries my daughter.","days_ago":39},{"first_name":"Vernon","last_name":"Caldwell","dob":"1969-08-24","email":"vernon.caldwell@example.com","phone":"(828) 555-0118","address":"1756 Riverside Drive","city":"Asheville","zip":"28804","year_built":1957,"household_size":2,"household_adults":2,"attributes":["veteran"],"repair_categories":["open_to_elements"],"urgent":["open_to_elements"],"repairs":[{"need":"Flood water stood in the crawlspace for weeks; insulation down, joists questionable","priority":1},{"need":"Ductwork submerged and likely moldy","priority":2}],"helene_related":true,"fema":{"filed":true,"outcome":"settled","settlement":12400,"remaining_exists":true,"remaining":5000},"income_method":"gross","gross_income":36200,"details":"Army vet. The house took on the river.","days_ago":42},
{"first_name":"Marlene","last_name":"Fortner","dob":"1980-05-16","email":"marlene.fortner@example.com","phone":"(828) 555-0146","address":"23 Graceland Avenue","city":"Asheville","zip":"28806","year_built":1960,"household_size":4,"household_adults":2,"repair_categories":["no_kitchen"],"urgent":["no_kitchen"],"repairs":[{"need":"Kitchen floor joists cracked under the fridge; floor visibly slopes","priority":1}],"helene_related":true,"income_method":"calculator","income_records":[{"whose":"mine","source":"work","frequency":"biweekly","amount":940},{"whose":"other","source":"work","frequency":"weekly","amount":380}],"details":"Two incomes, four mouths, still under the line.","days_ago":43},
{"first_name":"Harold","last_name":"Gillespie","dob":"1942-09-05","email":"harold.gillespie@example.com","phone":"(828) 555-0169","address":"310 New Haw Creek Road","city":"Asheville","zip":"28805","year_built":1932,"household_size":1,"household_adults":1,"attributes":["person_over_62"],"repair_categories":["open_to_elements","no_hvac"],"urgent":["open_to_elements"],"repairs":[{"need":"Two sheets of roofing tin gone since the hurricane; attic rains","priority":1},{"need":"Heat pump compressor seized","priority":2}],"helene_related":true,"income_method":"gross","gross_income":18200,"details":"","days_ago":44},
{"first_name":"Teresa","last_name":"Lankford","dob":"1995-04-21","email":"teresa.lankford@example.com","phone":"(828) 555-0124","address":"4 Lanvale Avenue","city":"Asheville","zip":"28801","year_built":1949,"household_size":2,"household_adults":1,"attributes":["single_parent"],"repair_categories":["no_bathroom"],"repairs":[{"need":"Sewer smell from the tub drain; trap likely dry or cracked","priority":1}],"helene_related":false,"income_method":"gross","gross_income":28600,"details":"New baby; my mom watches her while I work.","days_ago":46},
{"first_name":"Glenn","last_name":"Marlowe","dob":"1964-11-13","email":"glenn.marlowe@example.com","phone":"(828) 555-0189","address":"612 State Street","city":"Asheville","zip":"28806","year_built":1938,"household_size":2,"household_adults":2,"repair_categories":["other_issue"],"repairs":[{"need":"Foundation pier collapsed under the northeast corner; doors racked","priority":1}],"helene_related":true,"income_method":"gross","gross_income":41700,"details":"The corner dropped about two inches this spring.","days_ago":47},
{"first_name":"Alice","last_name":"Penland","dob":"1956-12-28","email":"alice.penland@example.com","phone":"(828) 555-0137","address":"16 Old Mars Hill Highway","city":"Weaverville","zip":"28787","year_built":1967,"household_size":1,"household_adults":1,"attributes":["person_over_62"],"repair_categories":["no_potable_water"],"repairs":[{"need":"Spring box cracked; water runs muddy after rain","priority":1}],"helene_related":true,"income_method":"gross","gross_income":20800,"details":"","days_ago":48},
{"first_name":"Curtis","last_name":"Revis","dob":"1986-03-08","email":"curtis.revis@example.com","phone":"(828) 555-0155","address":"91 Burlington Road","city":"Asheville","zip":"28806","year_built":1974,"household_size":5,"household_adults":2,"repair_categories":["no_hvac"],"urgent":["no_hvac"],"repairs":[{"need":"Package unit failed; five of us with two space heaters","priority":1}],"helene_related":false,"income_method":"gross","gross_income":68900,"details":"Three kids; my brother lives with us since the mill closed.","days_ago":49},
{"first_name":"Edna","last_name":"Shelton","dob":"1940-07-31","email":"edna.shelton@example.com","phone":"(828) 555-0179","address":"28 Broadway Street","city":"Marshall","zip":"28753","year_built":1918,"household_size":1,"household_adults":1,"attributes":["person_over_62","person_with_disability"],"repair_categories":["no_entry","accessibility"],"urgent":["no_entry"],"repairs":[{"need":"Front porch steps are crumbling brick; cannot manage them","priority":1},{"need":"Handrail loose on the interior stairs","priority":2}],"helene_related":false,"income_method":"calculator","income_records":[{"whose":"mine","source":"social_security","frequency":"monthly","amount":1290}],"details":"I have not been to the mailbox in a month.","days_ago":51},
{"first_name":"Floyd","last_name":"Treadway","dob":"1961-06-02","email":"floyd.treadway@example.com","phone":"(828) 555-0115","address":"503 Emma Road","city":"Asheville","zip":"28806","year_built":1953,"household_size":2,"household_adults":2,"repair_categories":["open_to_elements"],"urgent":["open_to_elements"],"repairs":[{"need":"Branch through the kitchen roof; skylight of tarp and plywood","priority":1}],"helene_related":true,"income_method":"gross","gross_income":32400,"details":"","days_ago":52},
{"first_name":"Gladys","last_name":"Worley","dob":"1952-10-19","email":"gladys.worley@example.com","phone":"(828) 555-0141","address":"7 Claxton Place","city":"Asheville","zip":"28801","year_built":1941,"household_size":1,"household_adults":1,"attributes":["person_over_62"],"repair_categories":["no_bathroom","other_issue"],"repairs":[{"need":"Bathroom only reachable by five steps; need main-floor wash options","priority":1}],"helene_related":false,"income_method":"gross","gross_income":17600,"details":"Hip replacement in May.","days_ago":54},{"first_name":"Hubert","last_name":"Angel","dob":"1979-01-26","email":"hubert.angel@example.com","phone":"(828) 555-0183","address":"840 Smokey Park Highway","city":"Candler","zip":"28715","home_type":"mobile","year_built":1998,"household_size":3,"household_adults":2,"repair_categories":["no_hvac"],"urgent":["no_hvac"],"repairs":[{"need":"Furnace blower dead; cold air return pulls from the crawlspace","priority":1}],"helene_related":true,"income_method":"gross","gross_income":33600,"details":"","days_ago":56},
{"first_name":"Irene","last_name":"Ballard","dob":"1944-05-12","email":"irene.ballard@example.com","phone":"(828) 555-0126","address":"102 West Street","city":"Black Mountain","zip":"28711","year_built":1936,"household_size":1,"household_adults":1,"attributes":["person_over_62"],"repair_categories":["open_to_elements"],"repairs":[{"need":"Valley leak over the dining room; plaster falling","priority":1}],"helene_related":true,"is_referral":true,"referrer_name":"Dana Whitfield","referrer_organization":"Swannanoa Valley Christian Ministry","referrer_email":"outreach@svcm.org","referrer_notes":"Neighbor asked us to help her apply.","income_method":"gross","gross_income":18900,"details":"","days_ago":58},
{"first_name":"Jesse","last_name":"Carpenter","dob":"1990-09-14","email":"jesse.carpenter@example.com","phone":"(828) 555-0162","address":"47 Oteen Church Road","city":"Asheville","zip":"28805","year_built":1966,"household_size":2,"household_adults":2,"repair_categories":["no_potable_water"],"urgent":["no_potable_water"],"repairs":[{"need":"Pressure switch shorted; pump cycles every few seconds","priority":1}],"helene_related":false,"income_method":"gross","gross_income":30100,"details":"","days_ago":59},
{"first_name":"Kathy","last_name":"Dillingham","dob":"1965-02-20","email":"kathy.dillingham@example.com","phone":"(828) 555-0104","address":"19 Dillingham Circle","city":"Barnardsville","zip":"28709","year_built":1972,"household_size":2,"household_adults":2,"repair_categories":["open_to_elements"],"urgent":["open_to_elements"],"repairs":[{"need":"Limb hole in the garage roof and the main roof ridge cap gone","priority":1}],"helene_related":true,"fema":{"filed":false},"income_method":"gross","gross_income":37800,"details":"Never filed with FEMA; did not know we could.","days_ago":61},
{"first_name":"Leonard","last_name":"Ensley","dob":"1958-06-27","email":"leonard.ensley@example.com","phone":"(828) 555-0193","address":"231 Old County Home Road","city":"Asheville","zip":"28806","year_built":1959,"household_size":2,"household_adults":2,"repair_categories":["no_bathroom"],"repairs":[{"need":"Tub unusable; standing shower over a floor drain for now","priority":1}],"helene_related":false,"income_method":"gross","gross_income":24500,"details":"","days_ago":63},
{"first_name":"Mabel","last_name":"Fox","dob":"1950-12-06","email":"mabel.fox@example.com","phone":"(828) 555-0131","address":"60 Arizona Avenue","city":"Asheville","zip":"28806","year_built":1947,"household_size":1,"household_adults":1,"attributes":["person_over_62"],"repair_categories":["no_hvac"],"repairs":[{"need":"Floor furnace grate gets dangerously hot; unit cycles off","priority":1}],"helene_related":false,"income_method":"gross","gross_income":16900,"details":"I keep a chair over the grate so I do not step on it barefoot.","days_ago":65},
{"first_name":"Nathan","last_name":"Gentry","dob":"1983-04-09","email":"nathan.gentry@example.com","phone":"(828) 555-0157","address":"118 Warren Avenue","city":"Asheville","zip":"28803","year_built":1961,"household_size":4,"household_adults":2,"repair_categories":["no_kitchen"],"urgent":["no_kitchen"],"repairs":[{"need":"Cabinet over the stove caught fire in June; scorched wall and no range","priority":1}],"helene_related":false,"income_method":"calculator","income_records":[{"whose":"mine","source":"work","frequency":"weekly","amount":620}],"details":"Cooking on a hot plate and the grill outside.","days_ago":66},
{"first_name":"Opal","last_name":"Hipps","dob":"1941-08-22","email":"opal.hipps@example.com","phone":"(828) 555-0175","address":"33 Mountain View Avenue","city":"Waynesville","zip":"28786","year_built":1939,"household_size":1,"household_adults":1,"attributes":["person_over_62","person_with_disability"],"repair_categories":["accessibility"],"urgent":["accessibility"],"repairs":[{"need":"Tub-to-shower conversion with a seat; cannot lift my legs over the tub wall","priority":1}],"helene_related":false,"income_method":"gross","gross_income":15400,"details":"Occupational therapist recommended the conversion in writing.","days_ago":68},
{"first_name":"Paul","last_name":"Inman","dob":"1977-11-04","email":"paul.inman@example.com","phone":"(828) 555-0111","address":"9 Goldview Street","city":"Asheville","zip":"28806","year_built":1956,"household_size":2,"household_adults":2,"repair_categories":["open_to_elements"],"urgent":["open_to_elements"],"repairs":[{"need":"Satellite dish tore a hole when it came down in the storm","priority":1}],"helene_related":true,"income_method":"gross","gross_income":34900,"details":"","days_ago":70},
{"first_name":"Ruth","last_name":"Justice","dob":"2009-03-16","email":"ruth.justice@example.com","phone":"(828) 555-0149","address":"72 Hazel Mill Road","city":"Asheville","zip":"28806","year_built":1950,"household_size":2,"household_adults":1,"repair_categories":["no_potable_water"],"repairs":[{"need":"Kitchen faucet snapped off at the base; main shutoff leaks too","priority":1}],"helene_related":false,"income_method":"gross","gross_income":19200,"details":"Applying with my grandmother; she owns the house and signed the consent. I am seventeen.","contact_notes":"Applicant is a minor; grandmother is the homeowner and co-signed.","days_ago":72},
{"first_name":"Samuel","last_name":"Kuykendall","dob":"1967-05-29","email":"samuel.kuykendall@example.com","phone":"(828) 555-0168","address":"305 Old Haw Creek Road","city":"Asheville","zip":"28805","year_built":1964,"household_size":2,"household_adults":2,"repair_categories":["no_hvac","open_to_elements"],"urgent":["no_hvac","open_to_elements"],"repairs":[{"need":"Storm took half the ridge and the furnace flue with it","priority":1},{"need":"Furnace red-tagged by the gas company","priority":2}],"helene_related":true,"fema":{"filed":true,"outcome":"denied"},"income_method":"gross","gross_income":31300,"details":"Gas is off at the meter until the flue is rebuilt.","days_ago":1},
{"first_name":"Viola","last_name":"Lunsford","dob":"1946-10-02","email":"viola.lunsford@example.com","phone":"(828) 555-0123","address":"11 Belmont Avenue","city":"Asheville","zip":"28806","year_built":1937,"household_size":1,"household_adults":1,"attributes":["person_over_62"],"repair_categories":["no_bathroom"],"urgent":["no_bathroom"],"repairs":[{"need":"Toilet rocks and leaks at the wax ring; floor spongy around it","priority":1}],"helene_related":true,"is_referral":true,"referrer_name":"Marcus Webb","referrer_organization":"Community Housing Coalition","referrer_email":"hello@chc-madison.org","referrer_notes":"Called our office; we helped her complete the form by phone.","income_method":"gross","gross_income":17800,"details":"","days_ago":4},
{"first_name":"Willard","last_name":"Mashburn","dob":"1971-07-18","email":"willard.mashburn@example.com","phone":"(828) 555-0181","address":"520 New Leicester Highway","city":"Asheville","zip":"28806","year_built":1970,"household_size":3,"household_adults":3,"repair_categories":["other_issue"],"repairs":[{"need":"Rear addition separating from the main house; crack widening","priority":1}],"helene_related":true,"income_method":"gross","gross_income":58700,"details":"Three adults; my brother pays half the mortgage.","days_ago":6},
{"first_name":"Yolanda","last_name":"Nieves","dob":"1988-12-23","email":"yolanda.nieves@example.com","phone":"(828) 555-0197","address":"26 Courtland Avenue","city":"Asheville","zip":"28801","year_built":1954,"household_size":4,"household_adults":2,"attributes":["snap_wic","child_under_5"],"repair_categories":["no_hvac"],"urgent":["no_hvac"],"repairs":[{"need":"No working heat upstairs where the kids sleep","priority":1}],"helene_related":false,"income_method":"calculator","income_records":[{"whose":"mine","source":"work","frequency":"biweekly","amount":980}],"details":"","days_ago":12},
{"first_name":"Elsie","last_name":"Barnwell","dob":"1953-06-08","email":"elsie.barnwell@example.com","phone":"(828) 555-0109","address":"144 Riverbend Road","city":"Asheville","zip":"28805","year_built":1951,"household_size":2,"household_adults":2,"repair_categories":["open_to_elements"],"urgent":["open_to_elements"],"repairs":[{"need":"River took the back deck and the steps to the door","priority":1},{"need":"Skirting and two basement windows gone","priority":2}],"helene_related":true,"fema":{"filed":true,"outcome":"other"},"income_method":"gross","gross_income":28400,"details":"","days_ago":20},
{"first_name":"Elsie","last_name":"Barnwell","dob":"1953-06-08","email":"elsie.barnwell@example.com","phone":"(828) 555-0109","address":"144 Riverbend Road","city":"Asheville","zip":"28805","year_built":1951,"household_size":2,"household_adults":2,"repair_categories":["open_to_elements","no_entry"],"urgent":["open_to_elements","no_entry"],"repairs":[{"need":"River took the back deck and the steps to the door","priority":1},{"need":"Skirting and two basement windows gone","priority":2},{"need":"Now the back door lock has failed; the house is not secure","priority":3}],"helene_related":true,"income_method":"gross","gross_income":28400,"contact_notes":"Called to add that the back door lock failed; submitted again with the update.","details":"Second submission with the lock update.","days_ago":18}
]$configs$;
BEGIN
    -- Guard against accidental double-seeding: wipe first to reseed.
    IF EXISTS (SELECT 1 FROM intake_submissions WHERE is_test = TRUE AND contact_email = 'dorothy.calloway@example.com') THEN
        RAISE NOTICE 'Demo submissions already seeded — skipping. Run sql/wipe-intake-test-data.sql first to reset.';
    ELSE
        FOR v_cfg IN SELECT * FROM jsonb_array_elements(v_configs) LOOP
            v_id := seed_demo_submission(v_cfg);
            v_ids := v_ids || v_id;
        END LOOP;
        RAISE NOTICE 'Seeded % demo submissions', array_length(v_ids, 1);
    END IF;
END $$;
-- ---------------------------------------------------------------
-- CLAIMS DEMO — exercised through the real lifecycle functions
-- (claim_application / log_progress_event / expire_stale_claims)
-- ---------------------------------------------------------------
DO $$
DECLARE
    v_org_a INT; v_org_b INT; v_user INT;
    v_app INT; v_case INT; v_case_b INT;
    v_pending INT;
BEGIN
    -- Skip when the seed guard above found existing demo data.
    IF EXISTS (SELECT 1 FROM intake_submissions WHERE is_test = TRUE AND contact_email = 'dorothy.calloway@example.com')
       AND EXISTS (SELECT 1 FROM case_repair_claims) THEN
        RAISE NOTICE 'Claims demo already applied — skipping.';
        RETURN;
    END IF;

    SELECT id INTO v_org_a FROM coalition_organizations WHERE is_active = TRUE ORDER BY id LIMIT 1;
    SELECT id INTO v_org_b FROM coalition_organizations WHERE is_active = TRUE AND id <> v_org_a ORDER BY id LIMIT 1;
    SELECT ura.user_id INTO v_user
      FROM user_role_assignments ura JOIN roles r ON r.id = ura.role_id
     WHERE UPPER(r.role_code) = 'SUPER_ADMIN' AND ura.is_active = TRUE
     ORDER BY ura.user_id LIMIT 1;
    IF v_user IS NULL THEN
        SELECT id INTO v_user FROM system_users ORDER BY id LIMIT 1;
    END IF;
    SELECT id INTO v_pending FROM case_statuses WHERE status_code = 'PENDING_REVIEW' LIMIT 1;

    -- Org A claims two applications outright (all their repairs).
    FOR v_app IN
        SELECT a.id FROM applications a
         WHERE a.placecode IN (archr_generate_placecode('88 Virginia Avenue'),
                               archr_generate_placecode('45 Old Haw Creek Road'))
    LOOP
        v_case := claim_application(v_app, v_org_a, v_user);
        INSERT INTO case_repair_claims (case_id, repair_request_id, organization_id, claimed_by)
        SELECT v_case, rr.id, v_org_a, v_user
          FROM repair_requests rr JOIN intake_submissions s ON s.id = rr.submission_id
         WHERE s.deduplicated_into = v_app
           AND NOT EXISTS (SELECT 1 FROM case_repair_claims x WHERE x.repair_request_id = rr.id AND x.released_at IS NULL);
        INSERT INTO case_status_history (case_id, from_status_id, to_status_id, changed_by, notes)
        VALUES (v_case, v_pending, v_pending, v_user, 'Case claimed by seed org A (all repairs)');
        PERFORM log_progress_event(v_case, 'comm_logged', 'Called the applicant and scheduled the home assessment', v_user, TRUE, 'user');
    END LOOP;

    -- Org B claims two applications outright.
    IF v_org_b IS NOT NULL THEN
        FOR v_app IN
            SELECT a.id FROM applications a
             WHERE a.placecode IN (archr_generate_placecode('112 Ridgecrest Drive'),
                                   archr_generate_placecode('3 Locust Street'))
        LOOP
            v_case := claim_application(v_app, v_org_b, v_user);
            INSERT INTO case_repair_claims (case_id, repair_request_id, organization_id, claimed_by)
            SELECT v_case, rr.id, v_org_b, v_user
              FROM repair_requests rr JOIN intake_submissions s ON s.id = rr.submission_id
             WHERE s.deduplicated_into = v_app
               AND NOT EXISTS (SELECT 1 FROM case_repair_claims x WHERE x.repair_request_id = rr.id AND x.released_at IS NULL);
            INSERT INTO case_status_history (case_id, from_status_id, to_status_id, changed_by, notes)
            VALUES (v_case, v_pending, v_pending, v_user, 'Case claimed by seed org B (all repairs)');
            PERFORM log_progress_event(v_case, 'document_uploaded', 'Income documents uploaded for verification', v_user, TRUE, 'user');
        END LOOP;
    END IF;

    -- FLAGSHIP: 12 Cherry Street (the duplicate pair) claimed by BOTH orgs
    -- over different repairs — two cases, one application.
    SELECT id INTO v_app FROM applications WHERE placecode = archr_generate_placecode('12 Cherry Street');
    IF v_app IS NOT NULL AND v_org_b IS NOT NULL THEN
        v_case := claim_application(v_app, v_org_a, v_user);
        INSERT INTO case_repair_claims (case_id, repair_request_id, organization_id, claimed_by)
        SELECT v_case, rr.id, v_org_a, v_user
          FROM repair_requests rr JOIN intake_submissions s ON s.id = rr.submission_id
         WHERE s.deduplicated_into = v_app AND rr.repair_need ILIKE 'Roof%'
           AND NOT EXISTS (SELECT 1 FROM case_repair_claims x WHERE x.repair_request_id = rr.id AND x.released_at IS NULL);
        INSERT INTO case_status_history (case_id, from_status_id, to_status_id, changed_by, notes)
        VALUES (v_case, v_pending, v_pending, v_user, 'Case claimed by seed org A (roof repair)');

        v_case_b := claim_application(v_app, v_org_b, v_user);
        INSERT INTO case_repair_claims (case_id, repair_request_id, organization_id, claimed_by)
        SELECT v_case_b, rr.id, v_org_b, v_user
          FROM repair_requests rr JOIN intake_submissions s ON s.id = rr.submission_id
         WHERE s.deduplicated_into = v_app AND (rr.repair_need ILIKE 'Plumbing%' OR rr.repair_need ILIKE 'Water heater%')
           AND NOT EXISTS (SELECT 1 FROM case_repair_claims x WHERE x.repair_request_id = rr.id AND x.released_at IS NULL);
        INSERT INTO case_status_history (case_id, from_status_id, to_status_id, changed_by, notes)
        VALUES (v_case_b, v_pending, v_pending, v_user, 'Case claimed by seed org B (plumbing + water heater)');
        PERFORM log_progress_event(v_case, 'assessment_scheduled', 'Roof assessment scheduled for next week', v_user, TRUE, 'user');
    END IF;

    -- Expiry demo: one claim backdated past the 90-day window, then expired
    -- by the real expire_stale_claims() job (application becomes claimable).
    SELECT id INTO v_app FROM applications WHERE placecode = archr_generate_placecode('15 Church Street');
    IF v_app IS NOT NULL THEN
        v_case := claim_application(v_app, v_org_a, v_user);
        UPDATE cases SET claimed_at = CURRENT_TIMESTAMP - INTERVAL '95 days',
                         last_progress_at = CURRENT_TIMESTAMP - INTERVAL '95 days',
                         claim_expires_at = CURRENT_TIMESTAMP - INTERVAL '5 days'
         WHERE id = v_case;
        PERFORM * FROM expire_stale_claims();
    END IF;
END $$;

COMMIT;

-- Verify:
--   SELECT count(*) FROM intake_submissions;   -- 50
--   SELECT count(*) FROM applications;         -- 48 (two duplicate pairs share)
--   SELECT status, count(*) FROM applications GROUP BY status;
--   SELECT count(*) FROM cases WHERE claim_status = 'active';
-- ---------------------------------------------------------------
-- DEMO REQUESTOR ACCOUNTS (3) — password for all three: archr-demo-2026
-- (bcrypt hash precomputed; embedded so reseeding reproduces the logins)
-- ---------------------------------------------------------------
BEGIN;

-- (Two statements: a data-modifying CTE's inserts are invisible to the rest
-- of its own statement's snapshot, so role assignment runs separately.)
INSERT INTO system_users (username, email, full_name, first_name, last_name, phone, is_active, password_hash)
SELECT d.username, d.email, d.first_name || ' ' || d.last_name, d.first_name, d.last_name,
       '(828) 555-0100', TRUE,
       '$2y$10$PIXKU2efkPig3KEmwN5inOJf/WpWW3GtlUJ22BoKoAT6iG1GQvmgy'
  FROM (VALUES
    ('dorothy.calloway', 'dorothy.calloway@example.com', 'Dorothy', 'Calloway'),
    ('george.finley',    'george.finley@example.com',    'George',  'Finley'),
    ('patricia.alvarez', 'patricia.alvarez@example.com', 'Patricia', 'Alvarez')
  ) AS d(username, email, first_name, last_name)
 WHERE NOT EXISTS (SELECT 1 FROM system_users u WHERE u.username = d.username OR u.email = d.email);

INSERT INTO user_role_assignments (user_id, role_id, is_active)
SELECT u.id, r.id, TRUE
  FROM system_users u
  CROSS JOIN roles r
 WHERE r.role_code = 'REQUESTOR'
   AND u.username IN ('dorothy.calloway', 'george.finley', 'patricia.alvarez')
   AND NOT EXISTS (
       SELECT 1 FROM user_role_assignments ura
        WHERE ura.user_id = u.id AND ura.role_id = r.id AND ura.organization_id IS NULL
   );

-- Link each account to its owner's submission(s) so the requestor portal
-- opens straight into their application.
UPDATE intake_submissions s
   SET requestor_user_id = u.id
  FROM system_users u
 WHERE u.email IN ('dorothy.calloway@example.com', 'george.finley@example.com', 'patricia.alvarez@example.com')
   AND s.contact_email = u.email;

COMMIT;

-- Verify:
--   SELECT username, email FROM system_users WHERE email LIKE '%@example.com' AND username IN ('dorothy.calloway','george.finley','patricia.alvarez');
-- ---------------------------------------------------------------
-- DEMO ORG ADMIN ACCOUNT — username: orgadmin / password: archr-demo-2026
-- (Org Admin for the first coalition org, so the portal is testable)
-- ---------------------------------------------------------------
BEGIN;

INSERT INTO system_users (username, email, full_name, first_name, last_name, phone, is_active, password_hash)
SELECT 'orgadmin', 'orgadmin@ashevillehabitat.org', 'Demo Org Admin', 'Demo', 'Org Admin',
       '(828) 555-0100', TRUE,
       '$2y$10$PIXKU2efkPig3KEmwN5inOJf/WpWW3GtlUJ22BoKoAT6iG1GQvmgy'
 WHERE NOT EXISTS (SELECT 1 FROM system_users WHERE username = 'orgadmin');

INSERT INTO user_role_assignments (user_id, organization_id, role_id, is_active)
SELECT u.id,
       (SELECT id FROM coalition_organizations WHERE organization_code = 'AHFH' LIMIT 1),
       r.id, TRUE
  FROM system_users u
  CROSS JOIN roles r
 WHERE u.username = 'orgadmin'
   AND r.role_code = 'ORG_ADMIN'
   AND NOT EXISTS (
       SELECT 1 FROM user_role_assignments ura
        WHERE ura.user_id = u.id AND ura.role_id = r.id
          AND ura.organization_id = (SELECT id FROM coalition_organizations WHERE organization_code = 'AHFH' LIMIT 1)
   );

COMMIT;