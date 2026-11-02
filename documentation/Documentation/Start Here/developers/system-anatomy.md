---
document_name: Anatomy of a Home Repair Platform
document_type: Technical Overview
version: 1.0
last_updated: 2026-07-10
author: ARCHR Development Team
audience: Developers, System Administrators, Technical Leads
complexity_level: Advanced
estimated_reading_minutes: 8-10 minutes
tags: [architecture, systems, data-flow, integration, database]
---
### Outline

**1. The Big Picture - System Architecture**

text

┌─────────────────────────────────────────────────────────────────────────────────┐
│  Frontend Layer         │  Business Logic Layer  │  Data Layer                 │
│  ┌─────────────────────┐│  ┌────────────────────┐│  ┌──────────────────────┐   │
│  │ Softr (UI)          ││  │ Task Engine        ││  │ PostgreSQL Database  │   │
│  │ Custom HTML/CSS/JS  ││  │ Progress Tracker   ││  │ - Schema: 40+ tables │   │
│  │ Mobile-First Design ││  │ Eligibility Engine ││  │ - Immutable Ledger   │   │
│  └─────────────────────┘│  │ Document Generator ││  │ - Row-Level Security │   │
│                         │  │ Notification System││  │ - Full-Text Search   │   │
│                         │  │ Reporting Engine   ││  └──────────────────────┘   │
│                         │  └────────────────────┘│                             │
│                         │                        │  ┌──────────────────────┐   │
│                         │  ┌────────────────────┐│  │ Document Bucket     │   │
│                         │  │ Fillout Forms      ││  │ - Dropbox/Z-Drive   │   │
│                         │  │ - Intake           ││  │ - Encrypted Storage │   │
│                         │  │ - Quick Add        ││  │ - Standardized      │   │
│                         │  │ - Task Approval    ││  │   Folder Structure  │   │
│                         │  └────────────────────┘│  └──────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────┘

**2. The Core Systems**

|System|Purpose|Key Tables/Components|
|---|---|---|
|**User & Role Management**|Authentication, authorization, permissions|`system_users`, `roles`, `user_role_assignments`|
|**Application Intake**|Capture applicant information|`intake_submissions`, `submission_*` tables|
|**Case Management**|Track case lifecycle|`cases`, `case_statuses`, `case_status_history`|
|**Progress Tracker**|Immutable task log|`progress_ledger`, views|
|**Task Engine**|Create, assign, complete tasks|`task_definitions`, `tasks`|
|**Document Management**|Generate, store, organize docs|`case_documents`, `document_templates`|
|**Financial Tracking**|Track funding, invoices, reimbursements|`case_funding`, `invoices`, `reimbursement_requests`|
|**Assessment**|Property inspections, estimates|`property_assessments`, `repair_estimates`|
|**Work Orders**|Repair project management|`work_orders`, `work_tasks`|
|**Scheduling**|Calendar, appointments|`scheduled_events`, `availability`|
|**Communications**|Messages, logs|`case_communications`, `communications_log`|

**3. The Immutable Ledger (Progress Tracker)**

- Single source of truth for all case activity
    
- Every change is a new row (never overwritten)
    
- Complete audit trail
    
- Powers task metrics and reporting
    

**4. Data Flow Through the System**

**Application Submission Flow:**

1. User fills intake form (Fillout)
    
2. Data stored in `intake_submissions`
    
3. Eligibility check runs
    
4. Case created (if eligible)
    
5. Notification sent to staff
    
6. Entry added to Progress Ledger
    

**Task Completion Flow:**

1. User clicks "+ Add Event"
2. Form adapts to task type
3. Data submitted to API
4. Document generated (if needed)
    
5. Progress Ledger updated
    
6. Task counts updated
    
7. Metrics recalculated
    

**5. Key Database Tables (40+ Total)**

|Table|Purpose|
|---|---|
|`intake_submissions`|Raw application data|
|`cases`|Case records|
|`progress_ledger`|Immutable task log|
|`case_documents`|Document metadata|
|`work_orders`|Repair projects|
|`work_tasks`|Individual tasks|
|`invoices`|Financial records|
|`property_assessments`|Inspection reports|
|`system_users`|User accounts|
|`roles`|Role definitions|
|`permissions`|Access control|

**6. How Softr Interacts With the Backend**

- Softr handles UI rendering
    
- Custom code (HTML/CSS/JS) for complex components
    
- Fillout for forms with dynamic logic
    
- API calls to backend for data operations
    
- Webhooks for event triggers
    

**7. Security Architecture**

- **Row-Level Security**: Users see only their org's data
    
- **Column-Level Security**: Sensitive fields redacted
    
- **Encryption**: AES-256 at rest, TLS in transit
    
- **Audit Log**: Every access and change logged
    
- **Permissions**: Granular role-based access control