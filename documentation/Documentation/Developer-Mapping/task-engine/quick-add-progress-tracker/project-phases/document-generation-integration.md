### Document Codes & Actions

|Document Type|docCode|docAct|docEvent|Naming Convention|
|---|---|---|---|---|
|**Contract**|CON|Sign|{case_id}_{timestamp}|{client_name}_Contract_{date}.pdf|
|**Assessment Report**|ASSESS|Create|{case_id}_{timestamp}|{client_name}_Assessment_{date}.pdf|
|**Scope of Work**|SCOPE|Create|{case_id}_{timestamp}|{client_name}_SOW_{date}.pdf|
|**Work Order**|WO|Generate|{case_id}_{timestamp}|WO_{wo_num}_{client_name}_{date}.pdf|
|**Certificate of Completion**|CERT|Sign|{case_id}_{timestamp}|{client_name}_Certificate_{date}.pdf|
|**Change Order**|CO|Create|{case_id}_{timestamp}|CO_{num}_{client_name}_{date}.pdf|
|**Invoice**|INV|Create|{case_id}_{timestamp}|{vendor}_INV_{num}_{date}.pdf|

-- When a user completes a task that generates a document:

-- 1. Form submission triggers doc generation
-- 2. System checks: Does doc already exist? (prevent duplicates)
-- 3. System generates the document
-- 4. System names the document using convention
-- 5. System saves to case folder: /organizations/{org_id}/cases/{case_number}/{folder}/
-- 6. System records in Documents table with docCode, docAct, docEvent
-- 7. System adds entry to immutable ledger
-- 8. System updates task status