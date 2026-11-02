# ARCHR Document Generation System: Implementation Plan

## Executive Summary

The Document Generation System automatically creates, organizes, and stores all case-related documents in a standardized folder structure. It pulls data from multiple database tables, checks for duplicates and eligibility, and produces formatted documents (PDF, DOCX) that are stored securely in "The Bucket" (cloud storage).

---

## Part 1: The Big Picture

### What Documents Are Generated?

|Document Type|When Generated|Data Sources|
|---|---|---|
|**Application PDF**|On submission|Intake form data|
|**Property Card**|On case creation|County assessor data + case data|
|**Income Verification**|On upload|Uploaded docs + metadata|
|**Assessment Report**|After assessment|Assessor findings, photos, measurements|
|**Contract**|After estimate approval|Case data, repair scope, parties, amounts|
|**Change Order**|When scope changes|Original contract + change details|
|**Work Order**|Before work starts|Contract, tasks, crew assignment|
|**Subcontractor Quote**|When sub is engaged|Subcontractor data, scope, cost|
|**Invoice**|When work is complete|Work order, costs, vendor data|
|**Completion Certificate**|After final inspection|Case data, signatures, photos|
|**Communication Log**|Ongoing|All case communications|

### The Data Flow (Simplified)

text

┌───────────────────────────────────┐
│   DOCUMENT GENERATION DATA FLOW   │
├───────────────────────────────────┤
│                                   │
│  ┌────────────────────────┐       │
│  │    1. DATA SOURCES     │       │
│  │                        │
│  │  │Organization Table │ 
│           Restric-  │ │  Jobs    │ │  Tasks   │ │  Roles   │     │   │
│  │  │tion Table│ │tions     │ │  Table   │ │  Table   │ │  Table   │     │   │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘     │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐                   │   │
│  │  │ Documents│ │ Workflow │ │Interfaces│ │Individuals│                   │   │
│  │  │  Table   │ │  Table   │ │  Table   │ │  Table   │                   │   │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘                   │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                   │                                             │
│                                   ▼                                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                      2. VALIDATION                                      │   │
│  │  ┌────────────────────────────────────────────────────────────────┐    │   │
│  │  │  • Duplicate Check: Same document already exists?              │    │   │
│  │  │  • Eligibility Check: Does this case qualify for this doc?    │    │   │
│  │  │  • Restriction Check: Any funding restrictions?               │    │   │
│  │  └────────────────────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                   │                                             │
│                                   ▼                                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                      3. DOCUMENT GENERATION                             │   │
│  │  ┌────────────────────────────────────────────────────────────────┐    │   │
│  │  │  • Template Selection (which template to use)                  │    │   │
│  │  │  • Data Mapping (which fields go where)                       │    │   │
│  │  │  • Formatting (PDF, DOCX, HTML)                               │    │   │
│  │  │  • Signature Integration (if needed)                          │    │   │
│  │  └────────────────────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                   │                                             │
│                                   ▼                                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                      4. STORAGE ("THE BUCKET")                          │   │
│  │  ┌────────────────────────────────────────────────────────────────┐    │   │
│  │  │  • Standardized Folder Structure                               │    │   │
│  │  │  • Naming Convention Applied                                   │    │   │
│  │  │  • Encryption at Rest                                          │    │   │
│  │  │  • Cloud Sync (Dropbox, Z-Drive, or S3)                       │    │   │
│  │  └────────────────────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘

---

## Part 2: The Folder Structure (From document-storage.md)

### Complete Case Folder Structure

text

/organizations/
└── /{org_id}/
    └── /cases/
        └── /{case_number}/
            ├── /application/
            │   ├── {case_number}_application_original.pdf
            │   ├── {case_number}_application_submission.json
            │   └── {case_number}_consent_form.pdf
            ├── /property/
            │   ├── {case_number}_property_card.pdf
            │   ├── {case_number}_deed.pdf
            │   └── {case_number}_tax_record_{year}.pdf
            ├── /income/
            │   ├── /{document_id}_{filename}
            │   └── .verification_log
            ├── /assessments/
            │   ├── /initial/
            │   │   ├── {case_number}_assessment_initial.pdf
            │   │   └── /photos/
            │   │       ├── before_{timestamp1}.jpg
            │   │       └── before_{timestamp2}.jpg
            │   └── /final/
            │       ├── {case_number}_assessment_final.pdf
            │       └── /photos/
            │           ├── after_{timestamp1}.jpg
            │           └── after_{timestamp2}.jpg
            ├── /contracts/
            │   ├── {case_number}_contract_v1.pdf
            │   ├── {case_number}_contract_v1_signed.pdf
            │   └── {case_number}_change_order_{num}.pdf
            ├── /work_orders/
            │   └── /{work_order_number}/
            │       ├── WO_{wo_num}_scope.pdf
            │       ├── WO_{wo_num}_assignment.pdf
            │       └── /progress_photos/
            ├── /financial/
            │   ├── /quotes/
            │   │   └── {vendor}_{quote_num}.pdf
            │   ├── /invoices/
            │   │   └── {vendor}_INV_{invoice_num}.pdf
            │   └── /grants/
            │       ├── {grant_num}_block_grant.pdf
            │       ├── {grant_num}_env_review.pdf
            │       └── {grant_num}_shpo_finding.pdf
            ├── /completion/
            │   ├── {case_number}_certificate_of_completion.pdf
            │   └── /final_photos/
            └── /communications/
                ├── /email/
                ├── /calls/
                └── /portal_messages/

---

## Part 3: Document Naming Convention

### Standard Format

text

{case_number}_{document_type}_{version_or_date}_{descriptor}.{extension}

### Examples

|Document Type|Example Filename|
|---|---|
|Application|`ARCHR-2024-001234_APP_v1.pdf`|
|Property Card|`ARCHR-2024-001234_PROP_20241201.pdf`|
|Assessment|`ARCHR-2024-001234_ASSESS_v1.pdf`|
|Contract|`ARCHR-2024-001234_CONT_v1_signed.pdf`|
|Change Order|`ARCHR-2024-001234_CO_001.pdf`|
|Certificate|`ARCHR-2024-001234_CERT_final.pdf`|
|Invoice|`ARCHR-2024-001234_INV_ABC-001.pdf`|

### Document Type Codes

|Code|Document Type|
|---|---|
|APP|Application|
|PROP|Property Card|
|DEED|Deed/Title|
|TAX|Tax Record|
|INC|Income Verification|
|ASSESS|Assessment Report|
|CONT|Contract|
|CO|Change Order|
|WO|Work Order|
|QUOTE|Subcontractor Quote|
|INV|Invoice|
|GRANT|Grant Document|
|ENV|Environmental Review|
|SHPO|Historic Preservation|
|CERT|Certificate of Completion|
|COMM|Communication Log|
|PH_B|Before Photo|
|PH_D|During Photo|
|PH_A|After Photo|

---

## Part 4: Document Generation Workflows

### Workflow 1: Contract Generation

text

┌─────────────────────────────────────────────────────────────────────────────────┐
│                    CONTRACT GENERATION WORKFLOW                                 │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  STEP 1: TRIGGER                                                                │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  When: Case is approved and assessment is complete                      │   │
│  │  Who: Project Manager clicks "Generate Contract"                       │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                   │                                             │
│                                   ▼                                             │
│  STEP 2: DATA COLLECTION                                                        │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  Data Sources:                                                           │   │
│  │  • Organization Table → Organization name, address, contact             │   │
│  │  • Jobs Table → Case number, address, scope of work                    │   │
│  │  • Individuals Table → Homeowner name, contact info                    │   │
│  │  • Roles Table → Staff assigned, roles                                 │   │
│  │  • Restrictions Table → Funding terms, caps, eligibility              │   │
│  │  • Documents Table → Previous versions (for versioning)               │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                   │                                             │
│                                   ▼                                             │
│  STEP 3: VALIDATION                                                            │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  • Check: Does a contract already exist for this case?                  │   │
│  │  • Check: Is the case eligible for a contract?                          │   │
│  │  • Check: Has the $50,000 cap been exceeded?                           │   │
│  │  • Check: Are all required fields present?                             │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                   │                                             │
│                                   ▼                                             │
│  STEP 4: GENERATION                                                            │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  • Select template: contract_template_v{version}.docx                   │   │
│  │  • Map data to template fields                                          │   │
│  │  • Apply formatting                                                     │   │
│  │  • Generate PDF (with signature fields if needed)                      │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                   │                                             │
│                                   ▼                                             │
│  STEP 5: STORAGE                                                               │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  • Apply naming convention: {case_number}_CONT_v{version}.pdf           │   │
│  │  • Store in: /organizations/{org_id}/cases/{case_number}/contracts/    │   │
│  │  • Record in Documents table with metadata                             │   │
│  │  • Sync to cloud storage ("The Bucket")                               │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                   │                                             │
│                                   ▼                                             │
│  STEP 6: NOTIFICATION                                                          │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  • Notify Project Manager: "Contract generated"                         │   │
│  │  • Notify Homeowner: "Contract ready for signature"                    │   │
│  │  • Update Task: "Contract awaiting signature"                          │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘

### Workflow 2: Change Order Generation

text

┌─────────────────────────────────────────────────────────────────────────────────┐
│                    CHANGE ORDER GENERATION WORKFLOW                             │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  STEP 1: TRIGGER                                                                │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  When: Scope changes during repair work                                │   │
│  │  Who: Crew Lead submits "Change Order Request"                        │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                   │                                             │
│                                   ▼                                             │
│  STEP 2: APPROVAL                                                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  • Project Manager reviews change request                               │   │
│  │  • Bursar checks budget impact                                          │   │
│  │  • Both approve or request changes                                     │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                   │                                             │
│                                   ▼                                             │
│  STEP 3: GENERATION                                                            │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  • Select original contract data                                        │   │
│  │  • Add change order details                                             │   │
│  │  • Generate Change Order document (PDF)                                │   │
│  │  • Naming: {case_number}_CO_{num}.pdf                                 │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                   │                                             │
│                                   ▼                                             │
│  STEP 4: STORAGE                                                               │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  • Store in: /contracts/ folder                                         │   │
│  │  • Record in Documents table                                           │   │
│  │  • Update contract version reference                                   │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘

### Workflow 3: Invoice Generation

text

┌─────────────────────────────────────────────────────────────────────────────────┐
│                    INVOICE GENERATION WORKFLOW                                  │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  STEP 1: TRIGGER                                                                │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  When: Work is complete or milestone reached                           │   │
│  │  Who: Subcontractor or Crew Lead submits invoice request              │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                   │                                             │
│                                   ▼                                             │
│  STEP 2: VALIDATION                                                            │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  • Check: Duplicate invoice?                                            │   │
│  │  • Check: Within budget limits?                                        │   │
│  │  • Check: Work actually completed?                                    │   │
│  │  • Check: All required documentation attached?                        │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                   │                                             │
│                                   ▼                                             │
│  STEP 3: GENERATION                                                            │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  • Pull work order data                                                │   │
│  │  • Calculate totals (labor + materials + travel)                      │   │
│  │  • Apply tax if applicable                                            │   │
│  │  • Generate Invoice PDF                                               │   │
│  │  • Naming: {vendor}_INV_{invoice_num}.pdf                            │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                   │                                             │
│                                   ▼                                             │
│  STEP 4: STORAGE + NOTIFICATION                                                │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  • Store in: /financial/invoices/                                      │   │
│  │  • Notify Bursar: "Invoice ready for approval"                        │   │
│  │  • Add to reimbursement queue                                         │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘

---

## Part 5: Technical Implementation Plan

### Phase 1: Foundation (Weeks 1-2)

|Task|Description|Deliverable|
|---|---|---|
|1.1|Set up cloud storage connector|Dropbox/Z-Drive API integration|
|1.2|Create folder structure generator|Creates case folders on demand|
|1.3|Implement naming convention|Consistent file naming|
|1.4|Build document metadata tracking|Documents table with full metadata|
|1.5|Test encryption and security|Verified encryption at rest|

### Phase 2: Template Engine (Weeks 3-4)

|Task|Description|Deliverable|
|---|---|---|
|2.1|Create document templates (DOCX)|Contract, certificate templates|
|2.2|Build template rendering engine|Maps data to templates|
|2.3|Add signature field support|DocuSign or PDF signature|
|2.4|Implement version control|Previous versions preserved|
|2.5|Add PDF generation|PDF output from templates|

### Phase 3: Core Documents (Weeks 5-6)

|Task|Description|Deliverable|
|---|---|---|
|3.1|Application PDF generation|Full application export|
|3.2|Property card generation|Tax/property data|
|3.3|Assessment report generation|Inspection findings|
|3.4|Contract generation|Repair contracts|
|3.5|Work order generation|Task assignments|

### Phase 4: Financial & Completion (Weeks 7-8)

|Task|Description|Deliverable|
|---|---|---|
|4.1|Invoice generation|Subcontractor invoices|
|4.2|Change order generation|Scope changes|
|4.3|Completion certificate|Final sign-off|
|4.4|Grant document generation|Compliance docs|
|4.5|Communication log export|Full case history|

### Phase 5: Integration & Testing (Weeks 9-10)

|Task|Description|Deliverable|
|---|---|---|
|5.1|API endpoints for generation|Trigger from UI|
|5.2|Duplicate detection|Prevent duplicate docs|
|5.3|Eligibility validation|Check before generation|
|5.4|User acceptance testing|Non-technical review|
|5.5|Deployment|Production ready|

---

## Part 6: Schema Mapping

### Data Flow: Contract Generation Example

|Data Source|Table|Field|Document Field|
|---|---|---|---|
|Organization|coalition_organizations|organization_name|{partner_name}|
|Organization|coalition_organizations|contact_email|{partner_contact}|
|Restrictions|funding_sources|cap_amount|{budget_cap}|
|Restrictions|funding_sources|remaining_amount|{remaining_budget}|
|Jobs|cases|case_number|{case_number}|
|Jobs|cases|total_budget|{approved_amount}|
|Jobs|work_orders|scope_of_work|{scope_description}|
|Jobs|work_orders|estimated_hours|{labor_hours}|
|Document|case_documents|file_name|{contract_version}|
|Workflow|case_status_history|status|{project_phase}|
|Tasks|work_tasks|description|{task_list}|
|Tasks|work_tasks|priority|{priority}|
|Interfaces|scheduled_events|scheduled_start|{start_date}|
|Interfaces|scheduled_events|scheduled_end|{end_date}|
|Roles|user_role_assignments|role_code|{role_name}|
|Roles|system_users|full_name|{staff_name}|
|Individuals|intake_submissions|applicant_first_name|{homeowner_first}|
|Individuals|intake_submissions|applicant_last_name|{homeowner_last}|
|Individuals|intake_submissions|home_address|{property_address}|
|Individuals|intake_submissions|home_city|{city}|
|Individuals|intake_submissions|home_zip|{zip}|

### Document Table Schema

sql

CREATE TABLE case_documents (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    
    -- Document metadata
    document_type VARCHAR(50) NOT NULL,  -- APP, PROP, CONT, etc.
    document_category VARCHAR(50),       -- application, property, contract, etc.
    document_name VARCHAR(255) NOT NULL, -- Full filename
    document_version INTEGER DEFAULT 1,  -- Version number
    
    -- Generation
    generated_from_template_id INTEGER,
    generated_at TIMESTAMP,
    generated_by INTEGER REFERENCES system_users(id),
    
    -- Status
    status VARCHAR(20) DEFAULT 'draft',  -- draft, generated, signed, final
    
    -- Storage
    storage_path VARCHAR(1000) NOT NULL, -- Full path in bucket
    storage_provider VARCHAR(50) DEFAULT 'dropbox',
    file_size_bytes BIGINT,
    file_hash VARCHAR(64),               -- SHA-256 for deduplication
    
    -- Signatures
    signature_status VARCHAR(20),        -- pending, signed, declined
    signature_data JSONB,                -- Timestamps, IPs, etc.
    
    -- Relationships
    parent_document_id INTEGER REFERENCES case_documents(id),
    related_task_id INTEGER REFERENCES work_tasks(id),
    related_workflow_id INTEGER,
    
    -- Duplicate detection
    duplicate_group_id UUID,
    is_duplicate BOOLEAN DEFAULT FALSE,
    
    -- Expiration
    expires_at TIMESTAMP,
    archived_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_documents_case (case_id),
    INDEX idx_documents_type (document_type),
    INDEX idx_documents_status (status)
);

---

## Part 7: Non-Technical Review Questions

### Questions for Stakeholders

#### Organization & Eligibility

1. **Which organizations need their own templates?** (Habitat, CHC, PODER, etc.)
    
2. **Do funding restrictions vary by organization?** (How?)
    
3. **What eligibility rules must be checked before generating a document?**
    

#### Documents & Templates

4. **What document templates already exist?** (Word, PDF, etc.)
    
5. **Who maintains the templates?** (Admin? Legal? Each org?)
    
6. **How often are templates updated?** (Quarterly? Annually?)
    
7. **What's the approval process for template changes?**
    

#### Workflow & Approvals

8. **Who approves each document type?** (PM? Bursar? Legal?)
    
9. **What's the signature workflow?** (DocuSign? In-person? E-sign?)
    
10. **How long should documents be retained?**
    

#### Storage & Access

11. **Who can view which documents?** (Role-based access)
    
12. **Should documents be encrypted at rest?** (Yes - already planned)
    
13. **How should documents be backed up?** (3-2-1 strategy)
    

#### Duplicates & Validation

14. **How should duplicate documents be handled?** (Reject? Overwrite? Version?)
    
15. **What should happen if a contract is generated for an ineligible case?**
    

---

## Part 8: Success Criteria

### Quantitative

|Metric|Target|
|---|---|
|Document generation time|< 15 seconds per document|
|Template creation time|< 1 hour per template|
|Storage sync time|< 30 seconds|
|Duplicate detection accuracy|> 99%|
|Document retrieval time|< 2 seconds|

### Qualitative

- Documents follow consistent naming convention
    
- Folder structure is standardized across all cases
    
- Templates are maintained centrally
    
- Non-technical staff can create templates
    
- Documents are encrypted at rest
    
- Access is role-based
    
- Audit trail exists for all document actions
    
- Duplicates are prevented
    

---

## Part 9: Risk Assessment

|Risk|Impact|Mitigation|
|---|---|---|
|Template format changes|Documents break|Version templates; keep backward compatibility|
|Storage provider down|Can't generate docs|Local caching; multiple providers|
|Data missing from template|Incomplete documents|Validation before generation|
|Duplicate documents generated|Confusion and waste|Check before generation; deduplication|
|Unauthorized access to documents|Privacy breach|Role-based access; encryption|
|Document version confusion|Wrong version used|Clear versioning; audit trail|

---

## Next Steps

1. **Review this plan** with stakeholders (use the questions in Part 7)
    
2. **Prioritize document types** - start with contracts and assessments
    
3. **Gather existing templates** from each organization
    
4. **Choose storage provider** (Dropbox, Z-Drive, or S3)
    
5. **Set up one organization** as a pilot (Habitat for Humanity)
    
6. **Build contract generation** as first deliverable
    
7. **Test with real data** and user feedback
    
8. **Iterate and expand** to other document types