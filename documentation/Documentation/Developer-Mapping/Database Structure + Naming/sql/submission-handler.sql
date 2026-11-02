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