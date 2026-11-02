-- Funding Source Tracking

-- User Story: As a Bursar, I want to know which grant/organization is paying for each case so I can ensure restricted funds are used correctly.

-- Data Requirements:

-- |Field|Type|Source|Definition|
-- |---|---|---|---|
-- |`funding_source_id`|UUID|`funding_sources`|Specific grant/org/funder|
-- |`source_name`|VARCHAR(200)|`funding_sources`|"Habitat Grant 2024", "FEMA DR-1234"|
-- |`source_type`|VARCHAR(50)|`funding_sources`|grant, donation, government, partner|
-- |`case_allocation`|DECIMAL(12,2)|`case_funding`|How much of this case is from this source|
-- |`source_total`|DECIMAL(12,2)|`funding_sources`|Total available from this source|
-- |`source_remaining`|DECIMAL(12,2)|`funding_sources`|What's left to allocate|

CREATE OR REPLACE VIEW funding_source_summary AS
SELECT 
    fs.id AS source_id,
    fs.source_name,
    fs.source_type,
    fs.total_amount,
    fs.remaining_amount,
    COALESCE(SUM(cf.allocated_amount), 0) AS allocated_to_cases,
    COALESCE(COUNT(DISTINCT cf.case_id), 0) AS case_count,
    -- Percentage used
    ROUND((fs.total_amount - fs.remaining_amount) / NULLIF(fs.total_amount, 0) * 100, 1) AS utilization_percentage,
    -- Flag if under or over
    CASE 
        WHEN fs.remaining_amount < 0 THEN 'OVERDRAWN'
        WHEN fs.remaining_amount = 0 THEN 'EXHAUSTED'
        WHEN fs.remaining_amount < (fs.total_amount * 0.1) THEN 'DEPLETED'
        ELSE 'HEALTHY'
    END AS health_status
FROM funding_sources fs
LEFT JOIN case_funding cf ON fs.id = cf.funding_source_id
WHERE fs.is_active = TRUE
GROUP BY fs.id, fs.source_name, fs.source_type, fs.total_amount, fs.remaining_amount;

### Requirement 5: Duplicate & Overlap Detection

**User Story:** As a Bursar, I want to be alerted to potential duplicate claims so I can investigate before money is spent twice.

**Detection Rules:**

|Detection Type|How It Works|Action Required|
|---|---|---|
|**Same Address**|Compare `home_address` + `home_city` across active cases|Flag for review|
|**Same Applicant**|Compare `first_name` + `last_name` + `dob`|Flag for review|
|**Same Repair Type**|Compare `repair_categories` on same address|Flag for review|
|**Overlapping Invoices**|Same vendor, same amount, similar date|Flag for review|

**SQL View:**

CREATE OR REPLACE VIEW duplicate_case_alerts AS
SELECT 
    s1.id AS submission_id_1,
    s1.applicant_first_name,
    s1.applicant_last_name,
    s1.home_address,
    s1.home_city,
    s2.id AS submission_id_2,
    s2.applicant_first_name AS applicant_name_2,
    c1.case_number AS case_number_1,
    c2.case_number AS case_number_2,
    'SAME_ADDRESS' AS alert_type,
    a1.organization_name AS org_1,
    a2.organization_name AS org_2,
    NOW() AS detected_at
FROM intake_submissions s1
JOIN intake_submissions s2 ON s1.id < s2.id
    AND s1.home_address ILIKE s2.home_address
    AND s1.home_city ILIKE s2.home_city
JOIN cases c1 ON s1.id = c1.submission_id
JOIN cases c2 ON s2.id = c2.submission_id
JOIN application_assignments a1 ON s1.id = a1.submission_id AND a1.status IN ('claimed', 'locked')
JOIN application_assignments a2 ON s2.id = a2.submission_id AND a2.status IN ('claimed', 'locked')
WHERE c1.status_id NOT IN (SELECT id FROM case_statuses WHERE status_code = 'COMPLETED')
  AND c2.status_id NOT IN (SELECT id FROM case_statuses WHERE status_code = 'COMPLETED')
  AND a1.organization_id != a2.organization_id
UNION
SELECT 
    s1.id,
    s1.applicant_first_name,
    s1.applicant_last_name,
    s1.home_address,
    s1.home_city,
    s2.id,
    s2.applicant_first_name,
    c1.case_number,
    c2.case_number,
    'SAME_APPLICANT' AS alert_type,
    a1.organization_name,
    a2.organization_name,
    NOW()
FROM intake_submissions s1
JOIN intake_submissions s2 ON s1.id < s2.id
    AND s1.applicant_first_name ILIKE s2.applicant_first_name
    AND s1.applicant_last_name ILIKE s2.applicant_last_name
    AND s1.applicant_dob = s2.applicant_dob
JOIN cases c1 ON s1.id = c1.submission_id
JOIN cases c2 ON s2.id = c2.submission_id
JOIN application_assignments a1 ON s1.id = a1.submission_id AND a1.status IN ('claimed', 'locked')
JOIN application_assignments a2 ON s2.id = a2.submission_id AND a2.status IN ('claimed', 'locked')
WHERE c1.id != c2.id
  AND c1.status_id NOT IN (SELECT id FROM case_statuses WHERE status_code = 'COMPLETED')
  AND c2.status_id NOT IN (SELECT id FROM case_statuses WHERE status_code = 'COMPLETED');
