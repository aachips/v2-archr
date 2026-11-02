Root Storage (Encrypted at rest)
├── /organizations/
│   ├── /{org_id}/
│   │   ├── /cases/
│   │   │   ├── /{case_number}/
│   │   │   │   ├── /application/
│   │   │   │   │   ├── {case_number}_application_original.pdf
│   │   │   │   │   ├── {case_number}_application_submission.json
│   │   │   │   │   └── {case_number}_consent_form.pdf
│   │   │   │   ├── /property/
│   │   │   │   │   ├── {case_number}_property_card.pdf
│   │   │   │   │   ├── {case_number}_deed.pdf
│   │   │   │   │   └── {case_number}_tax_record_{year}.pdf
│   │   │   │   ├── /income/
│   │   │   │   │   ├── /{document_id}_{filename}
│   │   │   │   │   └── .verification_log
│   │   │   │   ├── /assessments/
│   │   │   │   │   ├── /initial/
│   │   │   │   │   │   ├── {case_number}_assessment_initial.pdf
│   │   │   │   │   │   └── /photos/
│   │   │   │   │   │       ├── before_{timestamp1}.jpg
│   │   │   │   │   │       └── before_{timestamp2}.jpg
│   │   │   │   │   └── /final/
│   │   │   │   │       ├── {case_number}_assessment_final.pdf
│   │   │   │   │       └── /photos/
│   │   │   │   │           ├── after_{timestamp1}.jpg
│   │   │   │   │           └── after_{timestamp2}.jpg
│   │   │   │   ├── /contracts/
│   │   │   │   │   ├── {case_number}_contract_v1.pdf
│   │   │   │   │   ├── {case_number}_contract_v1_signed.pdf
│   │   │   │   │   └── {case_number}_change_order_{num}.pdf
│   │   │   │   ├── /work_orders/
│   │   │   │   │   ├── /{work_order_number}/
│   │   │   │   │   │   ├── WO_{wo_num}_scope.pdf
│   │   │   │   │   │   ├── WO_{wo_num}_assignment.pdf
│   │   │   │   │   │   └── /progress_photos/
│   │   │   │   ├── /financial/
│   │   │   │   │   ├── /quotes/
│   │   │   │   │   │   └── {vendor}_{quote_num}.pdf
│   │   │   │   │   ├── /invoices/
│   │   │   │   │   │   └── {vendor}_INV_{invoice_num}.pdf
│   │   │   │   │   └── /grants/
│   │   │   │   │       ├── {grant_num}_block_grant.pdf
│   │   │   │   │       ├── {grant_num}_env_review.pdf
│   │   │   │   │       └── {grant_num}_shpo_finding.pdf
│   │   │   │   ├── /completion/
│   │   │   │   │   ├── {case_number}_certificate_of_completion.pdf
│   │   │   │   │   └── /final_photos/
│   │   │   │   └── /communications/
│   │   │   │       ├── /email/
│   │   │   │       ├── /calls/
│   │   │   │       └── /portal_messages/
│   │   └── /shared/
│   │       ├── /templates/
│   │       │   ├── contract_template_v{version}.docx
│   │       │   └── certificate_template_v{version}.docx
│   │       └── /grants/
│   │           └── {grant_num}_master_agreement.pdf