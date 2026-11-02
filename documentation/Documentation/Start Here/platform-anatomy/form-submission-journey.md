---
document_name: Form Submission Journey — Security & Data Flow
document_type: Technical Reference
version: 1.0
last_updated: 2026-08-01
author: ARCHR Development Team
audience: Developers, Admins
complexity_level: Advanced
estimated_reading_minutes: 20
tags: [security, intake, data-flow, submission]
visibility: ["admin", "super-admin"]
---

┌─────────────────────────────────────────────────────────────────────────────┐
│                    APPLICATION SUBMISSION SECURITY FLOW                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  USER SUBMITS FORM                                                          │
│       │                                                                     │
│       ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  LAYER 1: TRANSPORT SECURITY (TLS 1.3)                              │   │
│  │  • All data encrypted between browser and server                    │   │
│  │  • HSTS enforced for all requests                                   │   │
│  │  • Perfect Forward Secrecy enabled                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│       │                                                                     │
│       ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  LAYER 2: INPUT VALIDATION & SANITIZATION                           │   │
│  │  • All form fields validated against schema                         │   │
│  │  • HTML/script tags stripped from text inputs                       │   │
│  │  • Email addresses normalized                                        │   │
│  │  • Phone numbers standardized to E.164 format                       │   │
│  │  • File uploads scanned for malware                                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│       │                                                                     │
│       ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  LAYER 3: DATABASE ENCRYPTION (AES-256)                             │   │
│  │  • PII fields encrypted at rest (name, address, DOB, SSN if any)    │   │
│  │  • Encryption keys stored in separate KMS (AWS KMS / HashiCorp)     │   │
│  │  • Database connections use TLS                                     │   │
│  │  • Automated backups also encrypted                                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│       │                                                                     │
│       ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  LAYER 4: ACCESS CONTROLS                                           │   │
│  │  • Row-level security: users see only their organization's data     │   │
│  │  • Column-level security: sensitive fields redacted by default      │   │
│  │  • Audit logging: every access is recorded                          │   │
│  │  • Session timeout: 30 minutes of inactivity                        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

### Data Classification & Protection Levels

|Data Category|Examples|Encryption|Access Restriction|Retention|
|---|---|---|---|---|
|**PII (Personally Identifiable)**|Name, address, phone, email, DOB|AES-256 at rest|Caseworker + assigned org only|7 years post-case|
|**Financial**|Income, bank statements, tax docs|AES-256 + column-level|Caseworker + Bursar + assigned org|7 years|
|**Medical/Disability**|Health conditions, accessibility needs|AES-256 + restricted|Caseworker only (with consent)|3 years post-case|
|**Property**|Photos, assessments, repair estimates|AES-256|All assigned staff|Permanent|
|**Communications**|Messages, call logs, emails|AES-256|All assigned staff + requestor|3 years|
|**Authentication**|Passwords, tokens|bcrypt (salt rounds=12)|System only|Until account deletion|

### Who Sees What Information?

text

┌─────────────────────────────────────────────────────────────────────────────┐
│                    INFORMATION ACCESS MATRIX                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  INFORMATION TYPE          │  REQUESTOR  │  CASEWORKER  │  ADMIN(ORG)      │
│────────────────────────────┼─────────────┼──────────────┼──────────────────│
│  Their own application     │    ✓ Full   │    ✓ Full    │    ✓ Full        │
│  Other applications        │    ✗        │    ✗         │    ✓ (org only)  │
│  PII of other applicants   │    ✗        │    ✗         │    ✓ (org only)  │
│  Financial verification    │    ✓        │    ✓         │    ✓             │
│  Internal notes            │    ✗        │    ✓         │    ✓             │
│  Cross-org communications  │    ✗        │    ✗         │    ✗             │
│  System audit logs         │    ✗        │    ✗         │    ✗ (superadmin)│
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

### Data Hygiene Checklist (Post-Submission)

markdown

## Immediate (0-5 minutes after submission)
- [ ] PII fields encrypted before writing to database
- [ ] IP address logged for audit trail (not stored with PII)
- [ ] File attachments scanned for malware
- [ ] Email notification sent to requestor (no PII in email body)
- [ ] Application added to review queue (encrypted reference only)
## Within 24 Hours
- [ ] Automated eligibility check completed
- [ ] No disqualifying factors found (or flagged)
- [ ] Assigned to appropriate organization (based on match score)
- [ ] Caseworker notified via secure dashboard (not email with PII)
## Within 7 Days
- [ ] Initial review completed by assigned caseworker
- [ ] Any missing documentation flagged
- [ ] Requestor notified of next steps
- [ ] Internal notes added (staff-only, encrypted)
## Data Retention & Deletion
- [ ] Case closed: data retained for 7 years per grant requirements
- [ ] Requestor deletion request: anonymize PII, retain metrics
- [ ] 7-year mark: automated archival to cold storage
- [ ] 10-year mark: permanent deletion (unless legal hold)

### Security Incident Response Protocol

markdown

## If You Suspect a Data Exposure
1. **DO NOT** delete logs or modify the data
2. **DO NOT** discuss in public channels
3. **IMMEDIATELY** contact: security@archr.org
4. **DOCUMENT** what you saw, when, and how
## What Happens Next
- Security team investigates within 1 hour
- Affected data identified and isolated
- Access logs reviewed
- If breach confirmed: affected parties notified within 72 hours
- Root cause analysis and remediation plan
## Reportable Incidents Include
- Unauthorized login to dashboard
- Email sent to wrong recipient with PII
- Lost or stolen device with access
- Suspicious database queries
- Unknown user added to organization

---

## Part 2: Organization Administrator Dashboard Guide

### Role Definition

**Organization Administrator** manages a specific partner organization within the ARCHR coalition (e.g., Habitat for Humanity - Buncombe County). This is **not** a platform super administrator.

**Primary Responsibilities:**

- Oversee applications assigned to their organization
    
- Manage caseworker assignments and workload
    
- Review and approve eligibility determinations
    
- Coordinate with subcontractors and volunteers
    
- Ensure timely processing of repairs
    

### Dashboard Overview

text

┌─────────────────────────────────────────────────────────────────────────────┐
│                    ORGANIZATION ADMIN DASHBOARD                              │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  ORG HEADER                                                          │   │
│  │  Habitat for Humanity - Buncombe County │ 12 active applications    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       │
│  │ PROCESSING   │ │VERIFICATION  │ │COMMUNICATION │ │ SCHEDULING   │       │
│  │      8       │ │      4       │ │     12       │ │      3       │       │
│  │  [Process]   │ │  [Verify]    │ │   [Comms]    │ │  [Schedule]  │       │
│  └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘       │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  RECENT APPLICATIONS                                                 │   │
│  │  ┌─────────────────────────────────────────────────────────────┐    │   │
│  │  │ ARCHR-2024-001234 │ John Henderson │ Next: Upload income    │    │   │
│  │  │ ARCHR-2024-001189 │ Sarah Williams │ Next: Schedule assess  │    │   │
│  │  │ ARCHR-2024-001103 │ James Thornton │ Next: Contract review  │    │   │
│  │  └─────────────────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌──────────────────────────────┐  ┌──────────────────────────────────┐   │
│  │  LATEST EVENTS               │  │  LATEST MESSAGES                 │   │
│  │  • Income docs uploaded      │  │  • John: "I uploaded docs"       │   │
│  │  • Eligibility confirmed     │  │  • Sarah: "Reschedule?"          │   │
│  │  • Assessment scheduled      │  │  • System: "New subcontractor"   │   │
│  └──────────────────────────────┘  └──────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  ACTION BUTTONS                                                     │   │
│  │  [Continue] [Process] [Verify] [Comms] [Schedule] [Alerts] [Msg]   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

### Administrator Task Reference

#### Task Metric Cards

|Metric Card|What It Counts|Clicking Opens|
|---|---|---|
|**Processing Tasks**|Applications in review, eligibility pending, assessment scheduled|`/processList` - queue of applications needing action|
|**Verification Tasks**|Documents awaiting review, income verification, contractor quotes|`/verifyList` - documents pending authentication|
|**Communication Tasks**|Unread messages, pending responses, client follow-ups|`/commsDashboard` - all organization communications|
|**Scheduling Tasks**|Assessment appointments, contractor visits, volunteer shifts|`/schedulingDashboard` - calendar and scheduling|

#### Seven Action Buttons

|Button|Destination|Purpose|
|---|---|---|
|**Continue**|`/appDetails`|Resume working on most recent application|
|**Process**|`/processList`|Review and process queued applications|
|**Verify**|`/verifyList`|Authenticate submitted documents|
|**Comms**|`/commsDashboard`|Manage all communications|
|**Schedule**|`/schedulingDashboard`|Calendar and appointment management|
|**Alerts**|`/appAlerts`|View system notifications and flags|
|**Message Details**|`/messageDetails`|Deep dive into specific conversation|

---

### Admin Task Context Groups

#### Group 1: Requestors

text

┌─────────────────────────────────────────────────────────────────────────────┐
│  REQUESTORS TASK GROUP                                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  APPLICATION REVIEW              │  REQUESTOR ACTIONS                       │
│  ┌─────────────────────────────┐ │  ┌─────────────────────────────────────┐ │
│  │ • Review & confirm          │ │  │ • View Communication                │ │
│  │   eligibility               │ │  │ • Schedule Assessment               │ │
│  │ • Set Request Triage        │ │  │                                     │ │
│  │ • Update Information        │ │  │                                     │ │
│  │ • Take Notes                │ │  │                                     │ │
│  └─────────────────────────────┘ │  └─────────────────────────────────────┘ │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

|Task|Description|Typical Duration|Permissions Required|
|---|---|---|---|
|**Review & confirm eligibility**|Verify applicant meets program criteria (income, location, homeownership)|5-10 min|Admin, Caseworker|
|**Set Request Triage**|Assign priority level based on urgency (1=emergency, 5=routine)|2-5 min|Admin|
|**Update Information**|Correct or supplement applicant data|3-8 min|Admin, Caseworker|
|**Take Notes**|Add internal notes visible only to organization staff|2-5 min|All org staff|
|**View Communication**|Read message history between requestor and staff|Varies|Admin, Caseworker|
|**Schedule Assessment**|Set date/time for property inspection|5-10 min|Admin, Assessor|

#### Group 2: Organization

text

┌─────────────────────────────────────────────────────────────────────────────┐
│  ORGANIZATION TASK GROUP                                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  COALITION & INTERNAL                    │                                  │
│  ┌─────────────────────────────────────┐ │                                  │
│  │ • View Communication                │ │                                  │
│  │ • Schedule Coalition Events         │ │                                  │
│  └─────────────────────────────────────┘ │                                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

|Task|Description|Typical Duration|
|---|---|---|
|**View Communication**|Internal organization messages, coalition announcements|Varies|
|**Schedule Coalition Events**|Cross-org meetings, trainings, reporting deadlines|10-20 min|

#### Group 3: Subcontractors

text

┌─────────────────────────────────────────────────────────────────────────────┐
│  SUBCONTRACTORS TASK GROUP                                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  SUBCONTRACTOR MANAGEMENT                                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ • Review New Subcontractor    │ Review applications from trades    │   │
│  │ • View Communication          │ Message history with subcontractor  │   │
│  │ • Schedule Subcontractor Quote│ Arrange for bid on specific repair  │   │
│  │ • Attach Quotes & Invoices    │ Upload and categorize documents    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

|Task|Description|Typical Duration|
|---|---|---|
|**Review New Subcontractor**|Vet new trade specialist applications (licensing, insurance, background)|15-30 min|
|**View Communication**|Review message thread with subcontractor|Varies|
|**Schedule Subcontractor Quote**|Coordinate site visit for estimate|10-15 min|
|**Attach Quotes & Invoices**|Upload bid documents or payment requests|5-10 min|

#### Group 4: Volunteers

text

┌─────────────────────────────────────────────────────────────────────────────┐
│  VOLUNTEERS TASK GROUP                                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  VOLUNTEER COORDINATION                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ • Manage Volunteer Communication    │ Messages, announcements       │   │
│  │ • Schedule Volunteers               │ Shift assignments, task lists │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

|Task|Description|Typical Duration|
|---|---|---|
|**Manage Volunteer Communication**|Send updates, respond to questions, broadcast needs|10-20 min daily|
|**Schedule Volunteers**|Assign shifts, track availability, send reminders|15-30 min|

---

### Application Status Definitions (for Admin Use)

|Status|Meaning|Admin Actions Available|
|---|---|---|
|**Pending Review**|New submission, not yet assigned|Review eligibility, assign to caseworker|
|**Eligibility Review**|Being checked against criteria|Confirm/deny eligibility, request more info|
|**Assessment Scheduled**|Home visit appointment set|Reschedule, assign assessor, add notes|
|**Assessment Complete**|Estimate created|Review estimate, approve budget|
|**Contract Pending**|Waiting for applicant signature|Resend contract, contact applicant|
|**Work In Progress**|Repair work underway|Monitor progress, approve change orders|
|**Quality Check**|Final inspection needed|Schedule inspection, assign crew lead|
|**Completed**|All work finished, signed off|Close case, archive documents|
|**Denied**|Applicant ineligible|Record reason, notify applicant|
|**On Hold**|Temporary pause|Document reason, set review date|

---

### Quick Reference: Admin Dashboard Elements

markdown

## Dashboard Components at a Glance
| Element | What It Shows | When to Use |
|---------|---------------|-------------|
| **Org Header** | Organization name + active count | Always visible |
| **Task Metrics** | 4 category counts (Process/Verify/Comms/Schedule) | Morning standup |
| **Recent Applications** | Last 5-10 apps with nextStep + holdingOn | Throughout day |
| **Latest Events** | Recent timeline entries | Track progress |
| **Latest Messages** | Recent communications | Respond promptly |
| **7 Action Buttons** | Quick navigation to task lists | Daily workflow |
| **Task Groups** | Collapsible context menus | When specific task arises |

---

### Common Administrator Workflows

#### Workflow 1: New Application Arrives

#### Workflow 2: Document Verification

#### Workflow 3: Weekly Oversight

markdown

**Monday Morning Checklist**
1. Review Task Metrics
   - [ ] Processing tasks: any stuck >5 days?
   - [ ] Verification tasks: oldest pending?
   - [ ] Communication tasks: any urgent?
   - [ ] Scheduling tasks: upcoming appointments?
2. Scan Recent Applications
   - [ ] Any with expiring nextStep dates?
   - [ ] Any holdingOn messages needing attention?
3. Check Latest Events
   - [ ] Any completed assessments ready for review?
   - [ ] Any contracts signed?
4. Review Messages
   - [ ] Respond to any >24 hours old
   - [ ] Flag any requiring escalation
5. Task Groups
   - [ ] Any new subcontractor applications?
   - [ ] Volunteer scheduling needs?

---

### Security Reminders for Admins

markdown

## DO
- Log out when leaving your workstation
- Use organization-provided devices when possible
- Report suspicious activity immediately
- Lock screen when away from desk
- Use strong, unique password (password manager encouraged)
## DON'T
- Share login credentials with anyone
- Discuss case details in public spaces
- Email PII to external addresses
- Download sensitive data to personal devices
- Leave paperwork with client information visible

---

## Part 3: Process Documentation Index

### Related SOP Documents

|Document|Description|Location|
|---|---|---|
|`REQUESTOR_PORTAL_SOP_v1`|Applicant dashboard, communication protocol|`/docs/sops/`|
|`VOLUNTEER_EXPERIENCE_SOP_v1`|Quest system, gamification, hour tracking|`/docs/sops/`|
|`APPLICATION_SUBMISSION_WORKFLOW_v1`|Intake, eligibility, anchor registration|`/docs/technical/`|
|`DATA_RETENTION_POLICY_v1`|7-year retention schedule, deletion protocols|`/docs/compliance/`|
|`INCIDENT_RESPONSE_PLAN_v1`|Security breach response|`/docs/security/`|

---

### Document Metadata Template for New SOPs

yaml

---
document_name: DOCUMENT_NAME_HERE
document_type: Standard Operating Procedure | Technical Specification | Policy
version: 1.0
last_updated: YYYY-MM-DD
author: Name
contributors: Name1, Name2
status: Draft | Review | Approved | Archived
review_date: YYYY-MM-DD
audience: Requestors | Caseworkers | Admins | All Staff
complexity_level: Beginner | Intermediate | Advanced
estimated_reading_minutes: XX
tags: [tag1, tag2, tag3]
---

---

This documentation should be maintained alongside the code. When features change, update these documents first - they're the source of truth for the whole team.