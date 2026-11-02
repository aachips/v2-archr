I said I would upload the newest version several days ago, and finally got to it tonight. Better late than never I suppose. It's up at [www.aachips.co/archr](http://www.aachips.co/archr)

You won't be able to access much on it. The dashboard is behind a log in. The log in system that works locally on my device and developer environment does not work on my personal webhost. 

I have the data pipeline set to 'airtable' for the web one. So it's hooked to a dummy database on airtable that has the same tables and columns as my local PostgreSQL database. It should just be set for dual-read. dual-write is the next step.

When I go to try the intake to see if it successfully posts to the Airtable dummy db I get a generic http 500 error. This is because there are several functions linked to the submission on the mockup. This includes making an account for a Requestor. Since it isn't connected to an account management system it's synced with, it defaults with a submission error. I could disable these functions for testing, but it's a ripple error I don't want to get in the weeds of. It consoles an error to line 862 on intake.js. So I'd have to back track to test it through use. So instead I have these test files at [www.aachips.co/archr/](http://www.aachips.co/archr/).. and they are pretty helpful for diagnosing where the connection is at.    

I am probably going to do that troubleshooting tomorrow evening (Sunday). But you can look at the test pages listed and see what's going on. It's coming along, just tired of database migrating and troubleshooting. We're getting close..

# ARCHR Deployment Preflight (test-airtable-connection.php results)

Read source (DB_DRIVER): `airtable` | Airtable base: `appiMfIEzULJtmi5v` | Table: `intake_submissions` | Token: present (82 chars)

**Reminder:** this page reveals server paths and configuration metadata. Delete the `test-*.php` files from the web root once everything checks out.

## 1. Secure config

|Step|Status|Details|
|---|---|---|
|Searched locations|OK|/home/aachipsc/secure_config/archr_connect.php \| /home/aachipsc/public_html/secure_config/archr_connect.php \| /home/aachipsc/public_html/archr/secure_config/archr_connect.php|
|archr_connect.php|OK|Loaded: /home/aachipsc/secure_config/archr_connect.php|
|Keys applied from file|OK|DB_DRIVER, PGHOST, PGPORT, PGDATABASE, PGUSER, PGPASSWORD, AIRTABLE_PAT|
|DB_DRIVER (read source)|OK|airtable|
|PostgreSQL target|OK|aachipsc_superadmin@localhost:5432/aachipsc_archr — password set (24 chars)|
|Airtable token|OK|present (82 chars)|

## 2. PostgreSQL

|Step|Status|Details|
|---|---|---|
|Connect|OK|Connected to aachipsc_archr as aachipsc_superadmin|
|Table intake_submissions|ERR|MISSING — apply the schema SQL from the sql/ directory|
|Table system_users|ERR|MISSING — apply the schema SQL from the sql/ directory|
|Connect|ERR|SQLSTATE[42P01]: Undefined table: 7 ERROR: relation "intake_submissions" does not exist|

## 3. Airtable

|Step|Status|Details|
|---|---|---|
|Fetch base schema|OK|Token can read the base schema (scope + base access OK)|
|Find table intake_submissions|OK|Found (79 fields)|

## 4. Airtable write test

|Step|Status|Details|
|---|---|---|
|Create test record|OK|Record rec3oboph6ArPoG8I (proves data.records:write)|
|Read back test record|OK|OK|
|Delete test record|OK|Cleaned up|

## 5. Dual-write

|Step|Status|Details|
|---|---|---|
|Logs directory writable|OK|/home/aachipsc/public_html/archr/../logs|
|Airtable dual-write|OK|Enabled (PostgreSQL primary + Airtable mirror on every intake submission)|

## Tables in base `appiMfIEzULJtmi5v`

|Table|Primary field|Fields|
|---|---|---|
|Table 1|fldaHRCbOyGPmiXTz|6|
|household_attributes|fldsxHzlF9yCbhp8o|1|
|submission_household_attributes|fldd8uJQsYbeqM83f|2|
|repair_requests|fldRMhd3pyYMG7dzk|4|
|repair_categories|fldmkKhCeBqH0Jmdb|2|
|submission_repair_categories|fldI810KzOt6lv0cT|2|
|income_records|fldn5WavrDzmFG4gc|6|
|contact_methods|fldYowbrPPqVARDeX|1|
|submission_contact_methods|fldLl4P3hTYKjHymJ|2|
|audit_log|fldjahXE3BNs94W7B|6|
|criteria_types|fldGSHEinWPtEQThO|4|
|application_assignments|fldP69Vfn9kradBVS|12|
|assignment_log|fldNoiEFbQKSTZSoz|7|
|organization_metrics|fld2K5W4JJyhfRUrs|14|
|permission_categories|fldDinwr7WYnYFZ9Y|3|
|permissions|fldflloqsvz4RaTtH|5|
|role_permissions|fldKu0TYuhsOT1suu|3|
|cases|flduwk0ZXNPyKvin7|20|
|case_status_history|fldObqObIaOPGk99r|6|
|property_assessments|fldLQTEjcxvsE5DO0|26|
|work_orders|fldEjS81GNdzFyIo2|13|
|work_tasks|fldy29At3i1hhdYVf|17|
|task_status_history|fldNR12UDCvbzB3l8|6|
|material_requests|fldU9cZNxPTyUzJ7y|14|
|funding_sources|fldJIyWVU7g0SK47w|11|
|case_funding|fldA35VRPwOonp5Nv|7|
|invoices|fldPLISjfX0STiPWc|16|
|invoice_line_items|fldjHR9bhgSILAxjC|6|
|volunteer_hours|fldJFqImJvp4FQiYr|8|
|volunteer_skills|fldxjXYs1xKPPKxoq|6|
|badges|fldQ8yptt735rMqjI|8|
|volunteer_badges|fldrkxbmXV4RD1cRG|4|
|volunteer_content|fld2js7vm3CYbxBAF|20|
|weekly_digests|fldHOMovmWRkpcFp6|7|
|email_queue|fldyKX66RhGvjt2mO|16|
|help_document_attachments|fld4n3BzflRMHJrpc|11|
|help_user_progress|fld1qtneJ52vRtKHI|7|
|help_search_log|fldpjfGhg4oliWzLl|8|
|help_document_reviews|fldIzvFwehcso74qG|7|
|document_statuses|fldUKXUF9fMF9d8gc|2|
|case_documents|fldvHQqTC4wyUs1On|26|
|document_generation_jobs|fldVmzlXcpn3pnx8G|11|
|document_access_log|fld11rv0xiRNVo2XG|6|
|reimbursement_requests|fldMsJJOPnoonltDO|9|
|review_queue|fldSXEdXGCYbyaKhl|11|
|guest_access_tokens|fldfrp36CEM5reKPi|5|
|intake_submissions|fld26SzBi4nc6mDfV|79|
|repair_category_details|fldrz3gL1CXyshv9J|8|
|coalition_organizations|flddvX0OU01P6k00E|15|
|organization_users|fld4HQwHAW0b2qCAD|7|
|organization_eligibility_rules|fld10fT4zyRbBsssZ|8|
|roles|fldF6ydyFp1XbQ1El|6|
|system_users|fldvEvnfwrHr0DBmC|14|
|user_role_assignments|fldgpm6thHAIcCB2R|8|
|case_statuses|fldePtnLcfRrOOgZN|6|
|repair_estimates|fldaFkMWKXihXC5UJ|14|
|case_communications|fldGhsWzDcVODYz0g|12|
|application_anchor|fldz04trmv6KeLbbA|17|
|volunteer_profiles|fldbl2rfc0j3bBDHx|17|
|quests|fld1Vg3OzQGJDT5Be|32|
|quest_assignments|fldUNyXdNPvxoTocj|20|
|skills|fldUFewGyEViyPaHC|7|
|content_reads|fldrjYSQ6qcg9Wxb9|4|
|beneficiary_feedback|fld536QOnAcbNPS6W|11|
|notifications|fldOGLFHOGwdo3DN1|14|
|edit_requests|fldgnR2NCBaukdAfq|12|
|help_categories|fld4jer3cSYAKHJkf|8|
|help_document_types|fldheP4taaRdvkZcV|6|
|help_documents|fldHwitRrCaaPXMc8|44|
|help_document_versions|fldqKFN47U3drf6tH|8|
|help_document_feedback|fldXjV0MlHi51En1Z|6|
|document_categories|fldw1J1tSWJKHL4QK|7|
|document_templates|fldZeuidDHj4MoPeM|12|
|document_share_links|fldZVzfcIJXY91a01|9|
|storage_providers|fldjIft0KuDe2Ken0|8|
|case_claims|fldUe9apITCsr61ih|5|
|eligibility_results|fldDQXI48Q7Gh4soc|4|
|volunteer_feedback|fldUpbTJCNqHANZjq|11|

## Fields in `intake_submissions`

|Name|Type|
|---|---|
|submission_uuid|singleLineText|
|submitted_at|dateTime|
|language|singleLineText|
|is_referral|checkbox|
|referrer_name|singleLineText|
|referrer_organization|singleLineText|
|referrer_email|singleLineText|
|referrer_notes|multilineText|
|consent_agreed|checkbox|
|applicant_first_name|singleLineText|
|applicant_last_name|singleLineText|
|applicant_dob|date|
|applicant_dob_unknown|checkbox|
|preferred_phone|checkbox|
|preferred_text|checkbox|
|preferred_email|checkbox|
|preferred_other|checkbox|
|home_phone|singleLineText|
|cell_phone|singleLineText|
|contact_email|singleLineText|
|other_contact_method_description|singleLineText|
|contact_notes|multilineText|
|home_address|singleLineText|
|home_city|singleLineText|
|home_state|singleLineText|
|home_zip|singleLineText|
|is_primary_residence|checkbox|
|receives_different_mail|checkbox|
|mail_address|singleLineText|
|mail_city|singleLineText|
|mail_state|singleLineText|
|mail_zip|singleLineText|
|home_type|singleLineText|
|year_built|number|
|move_in_date|date|
|owns_home|checkbox|
|owns_lot|checkbox|
|insurance_provider|singleLineText|
|lived_one_year|checkbox|
|household_size|number|
|household_adults|number|
|additional_repair_details|multilineText|
|urgent_unable_to_stay|checkbox|
|urgent_no_hvac|checkbox|
|urgent_no_potable_water|checkbox|
|urgent_no_bathroom|checkbox|
|urgent_no_kitchen|checkbox|
|urgent_open_to_elements|checkbox|
|urgent_no_entry|checkbox|
|urgent_accessibility|checkbox|
|urgent_other_issue|checkbox|
|urgent_eviction_risk|checkbox|
|helene_related|checkbox|
|fema_claim_filed|checkbox|
|fema_outcome|singleLineText|
|fema_settlement_amount|number|
|fema_remaining_exists|checkbox|
|fema_remaining_amount|number|
|insurance_claim_filed|checkbox|
|insurance_outcome|singleLineText|
|insurance_settlement_amount|number|
|insurance_remaining_exists|checkbox|
|insurance_remaining_amount|number|
|has_income|checkbox|
|income_method|singleLineText|
|gross_annual_income|number|
|income_docs_method|singleLineText|
|zero_income_first_name|singleLineText|
|zero_income_last_name|singleLineText|
|zero_income_address|singleLineText|
|zero_income_agreed|checkbox|
|applicant_signature|multilineText|
|zero_income_signature|multilineText|
|submission_status|singleLineText|
|assigned_organization|singleLineText|
|reviewed_by|singleLineText|
|reviewed_at|dateTime|
|eligibility_checked_at|dateTime|
|is_test|checkbox|
# Airtable Live Dual-Write Test (test-airtable-live.php)

Base: `appiMfIEzULJtmi5v` | Table: `intake_submissions` | Token: present

|Step|Status|Message|
|---|---|---|
|Find table intake_submissions|OK|Found. Fields: submission_uuid, submitted_at, language, is_referral, referrer_name, referrer_organization, referrer_email, referrer_notes, consent_agreed, applicant_first_name, applicant_last_name, applicant_dob, applicant_dob_unknown, preferred_phone, preferred_text, preferred_email, preferred_other, home_phone, cell_phone, contact_email, other_contact_method_description, contact_notes, home_address, home_city, home_state, home_zip, is_primary_residence, receives_different_mail, mail_address, mail_city, mail_state, mail_zip, home_type, year_built, move_in_date, owns_home, owns_lot, insurance_provider, lived_one_year, household_size, household_adults, additional_repair_details, urgent_unable_to_stay, urgent_no_hvac, urgent_no_potable_water, urgent_no_bathroom, urgent_no_kitchen, urgent_open_to_elements, urgent_no_entry, urgent_accessibility, urgent_other_issue, urgent_eviction_risk, helene_related, fema_claim_filed, fema_outcome, fema_settlement_amount, fema_remaining_exists, fema_remaining_amount, insurance_claim_filed, insurance_outcome, insurance_settlement_amount, insurance_remaining_exists, insurance_remaining_amount, has_income, income_method, gross_annual_income, income_docs_method, zero_income_first_name, zero_income_last_name, zero_income_address, zero_income_agreed, applicant_signature, zero_income_signature, submission_status, assigned_organization, reviewed_by, reviewed_at, eligibility_checked_at, is_test|
|Create test record|OK|Record ID: recZFgUqLFF470FOi|
|Read test record|OK|HTTP 200|
|Delete test record|OK|HTTP 200|

### test-db-connection.php

Returns server internal error 500. With a warning that 'Your connection may not be private, an app or service may see your encrypted traffic from this site'

### test-airtable-dual-write.php

'Dual-write failed: Primary database write failed: SQLSTATE[25P02]: In failed sql transaction: 7 ERROR: current transaction is aborted, commands ignored until end of transaction block'