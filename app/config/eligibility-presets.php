<?php
/**
 * Eligibility rule presets for Super Admin bulk import.
 *
 * Each preset is a keyed array of rules that get inserted into
 * organization_eligibility_rules when loaded from the Super Admin panel.
 *
 * Criteria type IDs are looked up by type_code at runtime — this file
 * stores type_codes, not IDs, so it stays portable across databases.
 *
 * Source: "Eligibility Requirements for each Partner Organization.md"
 *
 * Disaster vs General tracks:
 *   - Disaster repair has more relaxed rules (waived residence, same/lower
 *     AMI threshold, fewer doc requirements)
 *   - General home repair has stricter rules (min residence, sometimes 50% AMI)
 *   - Presets below represent the base/disaster track. General track overrides
 *     can be added as separate presets (e.g., habitat_general) when needed.
 */

// Shared proof-of-income list (same across all orgs)
const PROOF_INCOME_TYPES = 'Pay Stubs,Social Security Benefit Letter,Disability Income,W2,Pension Statements,Alimony,Unemployment Benefits,Worker\'s Compensation,Veteran\'s Benefits,Net Rental Income,TANF Work First,Minor Children Benefits,Notarized Statement of Income,Net Gambling or Lottery Winnings,Dividends Interest Bonds or Other Investment';

return [

    // ── Asheville Habitat for Humanity ─────────────────────────────
    'habitat_for_humanity' => [
        ['criteria_type_code' => 'geography_counties',         'operator' => 'in_list', 'value' => 'Buncombe County,Madison County', 'priority' => 10],
        ['criteria_type_code' => 'income_max_ami_percent',     'operator' => 'less_than', 'value' => '80', 'priority' => 20],
        ['criteria_type_code' => 'proof_of_income_types',      'operator' => 'in_list', 'value' => PROOF_INCOME_TYPES, 'priority' => 5],
        ['criteria_type_code' => 'proof_of_ownership_types',   'operator' => 'in_list', 'value' => 'Property Tax Bill,Deed,Verification of Life Estate,Title,99 Year Lease,Mobile Home Bill of Sale', 'priority' => 5],
        ['criteria_type_code' => 'home_type_allowed',          'operator' => 'in_list', 'value' => 'stick_built,modular,mobile,other', 'priority' => 10],
        ['criteria_type_code' => 'max_home_value',             'operator' => 'less_than', 'value' => '450000', 'priority' => 20],
        ['criteria_type_code' => 'primary_residence_required', 'operator' => 'equals', 'value' => 'true', 'priority' => 20],
        ['criteria_type_code' => 'homeowner_status',           'operator' => 'equals', 'value' => 'yes', 'priority' => 20],
        ['criteria_type_code' => 'min_residence_years',        'operator' => 'greater_than', 'value' => '1', 'priority' => 15],
        ['criteria_type_code' => 'mobile_home_lot_owned',      'operator' => 'equals', 'value' => 'true', 'priority' => 15],
    ],

    // ── Community Housing Coalition ────────────────────────────────
    'community_housing_coalition' => [
        ['criteria_type_code' => 'geography_counties',         'operator' => 'in_list', 'value' => 'Madison County', 'priority' => 10],
        ['criteria_type_code' => 'income_max_ami_percent',     'operator' => 'less_than', 'value' => '80', 'priority' => 20],
        ['criteria_type_code' => 'proof_of_income_types',      'operator' => 'in_list', 'value' => PROOF_INCOME_TYPES, 'priority' => 5],
        ['criteria_type_code' => 'proof_of_ownership_types',   'operator' => 'in_list', 'value' => 'Property Tax Bill,Deed,Verification of Life Estate,Title,99 Year Lease', 'priority' => 5],
        ['criteria_type_code' => 'home_type_allowed',          'operator' => 'in_list', 'value' => 'stick_built,modular,mobile,other', 'priority' => 10],
        ['criteria_type_code' => 'max_home_value',             'operator' => 'less_than', 'value' => '450000', 'priority' => 20],
        ['criteria_type_code' => 'primary_residence_required', 'operator' => 'equals', 'value' => 'true', 'priority' => 20],
        ['criteria_type_code' => 'homeowner_status',           'operator' => 'equals', 'value' => 'yes', 'priority' => 20],
    ],

    // ── PODER Emma (disaster track) ───────────────────────────────
    // General track: Emma Neighborhood only (needs geography_neighborhoods type)
    'poder_emma' => [
        ['criteria_type_code' => 'geography_counties',         'operator' => 'in_list', 'value' => 'Buncombe County,Madison County', 'priority' => 10],
        ['criteria_type_code' => 'income_max_ami_percent',     'operator' => 'less_than', 'value' => '80', 'priority' => 20],
        ['criteria_type_code' => 'proof_of_income_types',      'operator' => 'in_list', 'value' => PROOF_INCOME_TYPES, 'priority' => 5],
        ['criteria_type_code' => 'proof_of_ownership_types',   'operator' => 'in_list', 'value' => 'Property Tax Bill,Deed,Verification of Life Estate,Title', 'priority' => 5],
        ['criteria_type_code' => 'home_type_allowed',          'operator' => 'in_list', 'value' => 'stick_built,modular,mobile,other', 'priority' => 10],
        ['criteria_type_code' => 'max_home_value',             'operator' => 'less_than', 'value' => '450000', 'priority' => 20],
        ['criteria_type_code' => 'primary_residence_required', 'operator' => 'equals', 'value' => 'true', 'priority' => 20],
        ['criteria_type_code' => 'homeowner_status',           'operator' => 'equals', 'value' => 'yes', 'priority' => 20],
    ],

];
