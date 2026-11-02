# Subcontractor

**Subcontractors** are specialized trade professionals (electricians, plumbers, roofers, etc.) who perform specific repair tasks on ARCHR projects. Unlike full-time staff, they:

- Work independently on a per-job basis
- May not be familiar with ARCHR's full platform
- Need to focus on **their tasks only** (not the whole case)
- Require a simple, job-centric interface
- Need to track: estimates, work dates, progress, and invoices
    
### Core Principles

|Principle|Implementation|
|---|---|
|**Job-Centric**|Show only tasks assigned/available to this subcontractor|
|**Action-Oriented**|Every screen has one primary action (claim, update, invoice)|
|**Mobile-Ready**|Works on phone in the field|
|**Status-Driven**|Clear visual indicators of task progress|
|**Financial Focus**|Easy quote submission and invoicing|

---

## Dashboard Layout

text

┌─────────────────────────────────────────────────────────────────────────────────┐
│  SUBCONTRACTOR DASHBOARD                                                        │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │  USER HEADER: Mike's Plumbing Co.                         │ ⚡ 2 Active    │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                                                                  │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │  📋 ACCEPTED TASKS (2)          │  💡 SUGGESTED TASKS (3)                │  │
│  │  ┌───────────────────────────┐  │  ┌───────────────────────────────────┐  │  │
│  │  │ Job: 42-CHERRY            │  │  │ Job: 15-MERRILL                  │  │  │
│  │  │ Subtasks: 3/5 complete    │  │  │ Subtasks: 0/4                    │  │  │
│  │  │ Todo: Replace sink,       │  │  │ Type: Plumbing                   │  │  │
│  │  │       Install faucet      │  │  │ Est. Hours: 4.5                 │  │  │
│  │  │ [Update Status]           │  │  │ [Claim Task]                     │  │  │
│  │  └───────────────────────────┘  │  └───────────────────────────────────┘  │  │
│  │  ┌───────────────────────────┐  │  ┌───────────────────────────────────┐  │  │
│  │  │ Job: 8-OAKLAND            │  │  │ Job: 23-PARKWAY                  │  │  │
│  │  │ Subtasks: 2/3 complete    │  │  │ Subtasks: 0/2                    │  │  │
│  │  │ Todo: Wire new outlet,    │  │  │ Type: Electrical                 │  │  │
│  │  │       Install breaker     │  │  │ Est. Hours: 3.0                 │  │  │
│  │  │ [Update Status]           │  │  │ [Claim Task]                     │  │  │
│  │  └───────────────────────────┘  │  └───────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                                                                  │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │  💬 MESSAGES (2 unread)                                                   │  │
│  │  ┌─────────────────────────────────────────────────────────────────────┐  │  │
│  │  │ 🔵 Habitat: "Can you provide quote for 42-CHERRY by Friday?"      │  │  │
│  │  │ 🔵 System: "New task available: 15-MERRILL - Plumbing"             │  │  │
│  │  │ [View All Messages]                                                 │  │  │
│  │  └─────────────────────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                                                                  │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │  ACTION BUTTONS                                                           │  │
│  │  [View Task] [Past Jobs] [Input Quote] [Schedule] [Respond] [Messages]   │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                                                                  │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │  QUICK ACTIONS (Contextual)                                               │  │
│  │  ┌─────────────────────────┐  ┌─────────────────────────────────────────┐ │  │
│  │  │  TASK MANAGEMENT        │  │  FINANCIAL                              │ │  │
│  │  │  • Update Task Status   │  │  • Send Quote                           │ │  │
│  │  │  • Claim Tasks          │  │  • Submit Invoice                       │ │  │
│  │  │  • Set Estimate Date    │  │  • Alert Sub Accepted                   │ │  │
│  │  │  • Set Work Start Date  │  │                                         │ │  │
│  │  │  • Set Work Finish Date │  │                                         │ │  │
│  │  │  • Upload 'After Photos'│  │                                         │ │  │
│  │  └─────────────────────────┘  └─────────────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────────┘

---

## User Persona: The Subcontractor

### Role Definition

**Subcontractor** performs specialized repair work on ARCHR projects. They operate independently, are typically licensed tradespeople, and work on a per-task basis.

### Primary Responsibilities

|Responsibility|Description|Frequency|
|---|---|---|
|**Task Claiming**|Accept available tasks matching their trade|As needed|
|**Task Management**|Update status, set dates, track progress|Daily during active jobs|
|**Documentation**|Upload after photos, completion evidence|Per task|
|**Financial**|Submit quotes, send invoices|Per task|
|**Communication**|Respond to messages from project managers|Ongoing|

### Key Characteristics

- **Trade-Specific** - Only sees tasks in their specialty
    
- **Independently Schedules** - Sets their own work dates
    
- **Task-Focused** - Not concerned with entire case, just their task
    
- **Field-Based** - Works on-site, needs mobile access
    
- **Invoice-Driven** - Primary motivation is getting paid
    
## Implementation Phases

### Phase 1: Foundation (1 week)

|Task|Description|
|---|---|
|Create subcontractor profiles|Schema + registration flow|
|Build task claiming system|Claim, accept, assign|
|Build accepted tasks list|Dashboard primary view|

### Phase 2: Task Management (1 week)

|Task|Description|
|---|---|
|Build status update|Task status workflow|
|Build date setting|Estimate, start, finish dates|
|Build suggested tasks|Matching algorithm + display|

### Phase 3: Financial (1 week)

|Task|Description|
|---|---|
|Build quote submission|Quote form + approval workflow|
|Build invoice submission|Invoice form + payment tracking|
|Build job history|Past jobs with status|

### Phase 4: Communication (1 week)

|Task|Description|
|---|---|
|Build message system|Inbox + compose|
|Build notifications|Alerts for new tasks, status changes|
|Build photo upload|After photos with categorization|

---

## Success Criteria

### Quantitative

|Metric|Target|
|---|---|
|Task claim time|< 5 minutes from suggestion|
|Quote submission time|< 24 hours from claim|
|Invoice submission time|< 48 hours from completion|
|Photo upload success|> 95%|
|Message response time|< 4 hours|

### Qualitative

- Subcontractor can claim task in 3 clicks or less
    
- Subcontractor can submit quote without needing to call anyone
    
- Subcontractor can upload photos from phone in field
    
- Subcontractor knows exactly what they need to do
    
- Subcontractor can see all their tasks in one place