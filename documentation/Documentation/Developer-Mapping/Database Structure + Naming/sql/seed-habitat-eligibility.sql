-- Habitat for Humanity Eligibility Rules
-- Seed file for organization_eligibility_rules
-- Maps the requirements from "Eligibility Requirements for each Partner Organization.md"
-- to the criteria_types table.

-- First, ensure all required criteria_types exist (some may not be in the base set).
INSERT INTO criteria_types (type_code, type_name, input_type, description) VALUES
    ('max_home_value', 'Maximum Home Tax Value', 'number', 'Maximum assessed/tax value of the home in dollars'),
    ('mobile_home_lot_owned', 'Mobile Home: Must Own Lot', 'boolean', 'For mobile home repairs, applicant must own the lot'),
    ('min_residence_years', 'Minimum Years of Residence', 'number', 'Minimum years living at current address'),
    ('proof_of_income_types', 'Accepted Proof of Income Types', 'multiselect', 'Comma-separated list of accepted income proof document types'),
    ('proof_of_ownership_types', 'Accepted Proof of Ownership/Residency Types', 'multiselect', 'Comma-separated list of accepted ownership/residency proof types')
ON CONFLICT (type_code) DO NOTHING;

-- Now insert the Habitat for Humanity eligibility rules.
-- Replace :org_id with the actual coalition_organizations.id for Asheville Habitat for Humanity.
-- Run: UPDATE the :org_id placeholder with the correct organization ID before executing,
-- or use this as a template for the API bulk-create endpoint.

-- Service Areas (counties)
INSERT INTO organization_eligibility_rules (organization_id, criteria_type_id, rule_operator, rule_value, priority, is_active)
SELECT :org_id, ct.id, 'in_list', 'Buncombe County,Madison County', 10, true
FROM criteria_types ct WHERE ct.type_code = 'geography_counties';

-- State-level eligibility (NC)
INSERT INTO organization_eligibility_rules (organization_id, criteria_type_id, rule_operator, rule_value, priority, is_active)
SELECT :org_id, ct.id, 'in_list', 'North Carolina', 10, true
FROM criteria_types ct WHERE ct.type_code = 'geography_counties';

-- Income: Less than 80% AMI
INSERT INTO organization_eligibility_rules (organization_id, criteria_type_id, rule_operator, rule_value, priority, is_active)
SELECT :org_id, ct.id, 'less_than', '80', 20, true
FROM criteria_types ct WHERE ct.type_code = 'income_max';

-- Proof of Income Types (metadata — for UI rendering, not eligibility logic)
INSERT INTO organization_eligibility_rules (organization_id, criteria_type_id, rule_operator, rule_value, priority, is_active)
SELECT :org_id, ct.id, 'in_list',
    'Pay Stubs,Social Security Benefit Letter,Disability Income,W2,Pension Statements,Alimony,Unemployment Benefits,Worker''s Compensation,Veteran''s Benefits,Net Rental Income,TANF Work First,Minor Children Benefits,Notarized Statement of Income,Net Gambling or Lottery Winnings,Dividends Interest Bonds or Other Investment',
    5, true
FROM criteria_types ct WHERE ct.type_code = 'proof_of_income_types';

-- Proof of Ownership/Residency Types (metadata)
INSERT INTO organization_eligibility_rules (organization_id, criteria_type_id, rule_operator, rule_value, priority, is_active)
SELECT :org_id, ct.id, 'in_list',
    'Property Tax Bill,Deed,Verification of Life Estate,Title,99 Year Lease,Mobile Home Bill of Sale',
    5, true
FROM criteria_types ct WHERE ct.type_code = 'proof_of_ownership_types';

-- Home Types Allowed
INSERT INTO organization_eligibility_rules (organization_id, criteria_type_id, rule_operator, rule_value, priority, is_active)
SELECT :org_id, ct.id, 'in_list', 'stick_built,modular,mobile,other', 10, true
FROM criteria_types ct WHERE ct.type_code = 'home_type_allowed';

-- Maximum Home Tax Value: $450k
INSERT INTO organization_eligibility_rules (organization_id, criteria_type_id, rule_operator, rule_value, priority, is_active)
SELECT :org_id, ct.id, 'less_than', '450000', 20, true
FROM criteria_types ct WHERE ct.type_code = 'max_home_value';

-- Primary Residence Required
INSERT INTO organization_eligibility_rules (organization_id, criteria_type_id, rule_operator, rule_value, priority, is_active)
SELECT :org_id, ct.id, 'equals', 'true', 20, true
FROM criteria_types ct WHERE ct.type_code = 'primary_residence_required';

-- Must Own Home
INSERT INTO organization_eligibility_rules (organization_id, criteria_type_id, rule_operator, rule_value, priority, is_active)
SELECT :org_id, ct.id, 'equals', 'yes', 20, true
FROM criteria_types ct WHERE ct.type_code = 'homeowner_status';

-- Minimum Residence Years: 1 (for non-disaster and mobile repair)
INSERT INTO organization_eligibility_rules (organization_id, criteria_type_id, rule_operator, rule_value, priority, is_active)
SELECT :org_id, ct.id, 'greater_than', '1', 15, true
FROM criteria_types ct WHERE ct.type_code = 'min_residence_years';

-- Mobile Home: Must Own Lot
INSERT INTO organization_eligibility_rules (organization_id, criteria_type_id, rule_operator, rule_value, priority, is_active)
SELECT :org_id, ct.id, 'equals', 'true', 15, true
FROM criteria_types ct WHERE ct.type_code = 'mobile_home_lot_owned';
