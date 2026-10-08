---
document_name: Schema Mapping and Database - The Flow of Data
document_type: Technical Reference
version: 1.0
last_updated: 2026-07-10
author: ARCHR Development Team
audience: Developers, Database Administrators, Technical Leads
complexity_level: Advanced
estimated_reading_minutes: 8-12 minutes
tags: [database, schema, data-flow, postgresql, relationships]
---
### Outline

**1. Database Overview**

- PostgreSQL (target), currently Airtable
    
- 40+ tables organized by domain
    
- Row-level security for multi-organization isolation
    
- Immutable ledger for audit trail
    
- Materialized views for reporting
    

**2. Core Domain Tables**

|Domain|Key Tables|Purpose|
|---|---|---|
|**Users & Roles**|`system_users`, `roles`, `permissions`, `user_role_assignments`|Authentication, authorization|
|**Applications**|`intake_submissions`, `submission_repair_categories`, `submission_household_attributes`|Intake data|
|**Cases**|`cases`, `case_statuses`, `case_status_history`|Case lifecycle|
|**Progress**|`progress_ledger`|Immutable task log|
|**Tasks**|`task_definitions`, `work_tasks`, `task_status_history`|Task management|
|**Work Orders**|`work_orders`, `project_assignments`|Repair projects|
|**Assessments**|`property_assessments`, `repair_estimates`|Property inspections|
|**Documents**|`case_documents`, `document_templates`|Document management|
|**Finance**|`case_funding`, `invoices`, `reimbursement_requests`, `funding_sources`|Financial tracking|
|**Communications**|`case_communications`|Message logging|
|**Scheduling**|`scheduled_events`, `applicant_availability`|Calendar management|

**3. The Immutable Ledger Table**

- `progress_ledger` - The single source of truth
    
- INSERT only, never UPDATE or DELETE
    
- Every change is a new row
    
- Provides complete audit trail
    
- Powers all metrics and reporting
    

**4. Key Relationships**

text

User → Role → Permission (Many-to-Many)
User → Organization (Many-to-One)
Intake Submission → Case (One-to-One)
Case → Work Orders (One-to-Many)
Work Order → Tasks (One-to-Many)
Case → Documents (One-to-Many)
Case → Funding (One-to-Many)
Progress Ledger → Everything (Immutable Reference)

**5. Data Flow Diagrams**

**Application to Case:**

text

Intake Submission → Eligibility Check → Case Created → Status: PENDING

**Task Creation:**

text

Quick Add → Progress Ledger (New Row) → Task Definition → Task Metrics Updated

**Document Generation:**

text

Task Complete → Document Generated → File Stored in Bucket → Document Table → Ledger Updated

**6. Key Views for Reporting**

|View|Purpose|
|---|---|
|`case_funding_summary`|Per-case funding status|
|`reimbursement_aging`|Invoice aging report|
|`funding_source_summary`|Grant utilization|
|`duplicate_case_alerts`|Overlap detection|
|`current_tasks`|Active task list|
|`task_metrics`|Dashboard metrics|
|`project_status_view`|Project health|
|`staff_review_queue`|Application queue|

**7. Row-Level Security (RLS)**

sql

-- Example: Users only see their organization's data
CREATE POLICY org_access_policy ON cases
    USING (organization_id = current_setting('app.current_org_id')::INTEGER);
-- Example: Users only see their assigned cases
CREATE POLICY caseworker_access_policy ON cases
    USING (assigned_to = current_user_id());

**8. Migration from Airtable to PostgreSQL**

|Airtable Concept|PostgreSQL Equivalent|
|---|---|
|Base → Database|Database|
|Table → Table|Table|
|Record → Row|Row|
|Field → Column|Column|
|View → Materialized View|Materialized View|
|Linked Record → Foreign Key|Foreign Key|
|Formula → Computed Column|Generated Column|
|Automation → Trigger/Function|PL/pgSQL Function|

**9. Query Examples**

sql

-- Get active cases with funding status
SELECT * FROM case_funding_summary WHERE status NOT IN ('completed', 'denied');
-- Get overdue reimbursement requests
SELECT * FROM reimbursement_aging WHERE days_aging > 30;
-- Get duplicate alerts
SELECT * FROM duplicate_case_alerts ORDER BY detected_at DESC;
-- Get task metrics for dashboard
SELECT * FROM task_metrics;
-- Get all progress for a case
SELECT * FROM progress_ledger WHERE case_id = 123 ORDER BY event_timestamp DESC;

**10. Schema Documentation**

- All tables documented with comments
    
- Fields have descriptions
    
- Relationships have foreign key constraints
    
- Views have purpose statements
    
- Functions have usage examples