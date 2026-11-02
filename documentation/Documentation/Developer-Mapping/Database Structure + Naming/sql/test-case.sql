-- =====================================================
-- TEST CASES
-- Validate the submission workflow
-- =====================================================

-- Test 1: Eligible application submission
SELECT submit_intake_application(
    p_form_data => '{
        "applicantFirstName": "Test",
        "applicantLastName": "User",
        "contactEmail": "test@example.com",
        "homeAddress": "123 Main St",
        "homeCity": "Asheville",
        "homeZip": "28801",
        "ownsHome": "yes",
        "isPrimaryResidence": "yes",
        "householdSize": "2",
        "haveIncome": "yes",
        "grossAnnualIncome": "45000"
    }'::JSONB,
    p_create_account => true,
    p_email => 'test@example.com',
    p_password_hash => 'temp_password_123',
    p_ip_address => '127.0.0.1'::INET,
    p_user_agent => 'Test Suite'
);

-- Expected: success, is_eligible = true

-- Test 2: Ineligible application (outside service area)
SELECT submit_intake_application(
    p_form_data => '{
        "applicantFirstName": "Outside",
        "applicantLastName": "Area",
        "contactEmail": "outside@example.com",
        "homeAddress": "456 Other St",
        "homeCity": "Charlotte",
        "homeZip": "28201",
        "ownsHome": "yes",
        "isPrimaryResidence": "yes",
        "householdSize": "1",
        "haveIncome": "yes",
        "grossAnnualIncome": "30000"
    }'::JSONB,
    p_create_account => false,
    p_ip_address => '127.0.0.1'::INET,
    p_user_agent => 'Test Suite'
);

-- Expected: success, is_eligible = false, disqualifier = 'outside_service_area'

-- Test 3: Check queue order
SELECT * FROM get_next_in_queue();

-- Expected: Returns the earliest eligible application

-- Test 4: Verify anchor registration
SELECT * FROM application_anchor ORDER BY created_at DESC LIMIT 5;

-- Expected: Both eligible and ineligible applications appear