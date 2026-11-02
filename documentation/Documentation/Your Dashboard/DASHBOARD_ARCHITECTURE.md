# Dashboard Architecture Diagram

## System Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         USER LOGS IN                                │
│                              ↓                                       │
│                    Opens Dashboard (e.g., assessor.php)            │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────┐
│                     DASHBOARD HOME PAGE                             │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │  Welcome back, [Name]                    [Today's Count: 3]   │ │
│  │  [Date] • [Role] Dashboard                                    │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │  📢 Alerts & Upcoming Jobs                                    │ │
│  │  • Upcoming Assessment - Dec 6, 9:00 AM                       │ │
│  │  • New Job Assignment - 42 Cherry St                          │ │
│  │  • [View all →]                                               │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │  🔍 Case Search                                               │ │
│  │  [Search by case #, address, name, phone] [Search Button]    │ │
│  │  [All] [My Cases] [Recent] [Urgent]                          │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │  ⚡ Quick Task                                                │ │
│  │  Type: [Task ▼]                                              │ │
│  │  Description: [Text area]                                     │ │
│  │  [Submit to Queue] [Clear]                                    │ │
│  └───────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
                         User clicks menu item
                                ↓
┌─────────────────────────────────────────────────────────────────────┐
│                        FEATURE PAGE                                 │
│                     (Loads data from API)                           │
└─────────────────────────────────────────────────────────────────────┘
```

---

## File Structure

```
app/
│
├── assessor.php ────────────────┐
├── project-manager.php ─────────┤
├── crew-lead.php ───────────────┤  Role Dashboard Files
├── crew-member.php ─────────────┤  (Load dashboard-home.php)
├── bursar.php ──────────────────┤
├── volunteer.php ───────────────┤
└── subcontractor.php ───────────┘
        ↓
        Uses ↓
        ↓
├── partials/
│   └── dashboard-home.php ──────── Common Dashboard Home Component
│
├── api/
│   ├── cases/
│   │   └── search.php ──────────── Global case search
│   │
│   ├── tasks/
│   │   └── quick-add.php ───────── Quick task submission
│   │
│   ├── assessor/
│   │   ├── dashboard.php ───────── Dashboard data
│   │   ├── today.php ───────────── Today's assessments
│   │   ├── upcoming.php ────────── Upcoming assessments
│   │   └── previous.php ────────── Previous assessments
│   │
│   ├── project-manager/
│   │   ├── dashboard.php
│   │   ├── projects.php
│   │   ├── unclaimed.php
│   │   └── escalations.php
│   │
│   └── [other roles]/
│       └── dashboard.php
│
└── lib/
    ├── auth.php ────────────────── Authentication
    ├── db.php ──────────────────── Database connection
    └── portal-layout.php ───────── Portal header/footer
```

---

## Data Flow

```
┌──────────────┐
│   Browser    │
└──────┬───────┘
       │ 1. Request: assessor.php
       ↓
┌──────────────────────────────────┐
│   assessor.php                   │
│   • Check auth                   │
│   • Load user data               │
│   • Query database for stats     │
│   • Format alerts                │
│   • Set variables for home page  │
└──────┬───────────────────────────┘
       │ 2. Include: dashboard-home.php
       ↓
┌──────────────────────────────────┐
│   dashboard-home.php             │
│   • Display welcome message      │
│   • Show alerts panel            │
│   • Render case search           │
│   • Show quick task form         │
└──────┬───────────────────────────┘
       │ 3. Return HTML
       ↓
┌──────────────┐
│   Browser    │
└──────┬───────┘
       │ 4. User interacts
       │    (search, submit task)
       ↓
┌──────────────────────────────────┐
│   JavaScript (in browser)        │
│   • Capture form submit          │
│   • Send AJAX request            │
└──────┬───────────────────────────┘
       │ 5. POST/GET request
       ↓
┌──────────────────────────────────┐
│   API Endpoint                   │
│   /api/tasks/quick-add.php       │
│   /api/cases/search.php          │
│   • Validate auth                │
│   • Process request              │
│   • Query database               │
│   • Return JSON                  │
└──────┬───────────────────────────┘
       │ 6. JSON response
       ↓
┌──────────────┐
│   Browser    │
│   • Display result/feedback      │
└──────────────┘
```

---

## Menu Navigation Flow

```
Sidebar Menu
├── Dashboard ────────────→ assessor.php (Home)
├── Today's Assessments ──→ #today anchor OR separate page
├── Upcoming ─────────────→ #upcoming anchor OR separate page
├── Previous ─────────────→ #previous anchor OR separate page
├── Verifications ────────→ #verify anchor OR separate page
└── Schedule ─────────────→ #schedule anchor OR separate page
                              ↓
                     Each loads data from:
                     /api/assessor/{feature}.php
```

---

## Component Interaction

```
┌─────────────────────────────────────────────────────────────┐
│                    Portal Layout                            │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Header (topbar)                                       │ │
│  │  • Logo  • Page title  • User avatar                  │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌──────────┐  ┌────────────────────────────────────────┐ │
│  │          │  │  Main Content Area                     │ │
│  │ Sidebar  │  │  ┌──────────────────────────────────┐ │ │
│  │  Menu    │  │  │  Dashboard Home Component       │ │ │
│  │          │  │  │  • Welcome                      │ │ │
│  │ • Home   │  │  │  • Alerts                       │ │ │
│  │ • Item 1 │  │  │  • Case Search                  │ │ │
│  │ • Item 2 │  │  │  • Quick Task                   │ │ │
│  │ • Item 3 │  │  └──────────────────────────────────┘ │ │
│  │          │  │                                        │ │
│  └──────────┘  └────────────────────────────────────────┘ │
│                                                             │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Footer                                                │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## API Architecture

```
Frontend (Browser)
        ↓
        ↓ HTTP Request (GET/POST)
        ↓
┌───────────────────────────┐
│   API Endpoint            │
│   /api/{role}/{feature}   │
│                           │
│   1. Require auth.php     │ ← Check authentication
│   2. Require db.php       │ ← Get database connection
│   3. Query data           │ ← Fetch from database
│   4. Format response      │ ← Structure as JSON
│   5. Return JSON          │
└───────────────────────────┘
        ↓
        ↓ JSON Response
        ↓
Frontend (Browser)
        ↓
Parse & Display Data
```

---

## Database Layer

```
API Endpoints
     ↓
lib/db.php (archr_pdo())
     ↓
MySQL Database
     ├── system_users
     ├── intake_submissions
     ├── cases
     ├── assessments
     ├── work_orders
     ├── project_escalations
     ├── crew_job_cards
     ├── payments
     ├── volunteer_slots
     └── task_rabbit_queue
```

---

## Summary

This architecture provides:

✅ **Separation of Concerns** - UI, Logic, Data are separated  
✅ **Reusability** - Common components shared across roles  
✅ **Maintainability** - Each feature is isolated  
✅ **Scalability** - Easy to add new roles and features  
✅ **API-First** - Works for web, mobile, and integrations  
✅ **Consistent UX** - All roles have same home structure  
