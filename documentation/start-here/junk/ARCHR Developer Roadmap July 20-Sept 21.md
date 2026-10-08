---
document_name: ARCHR_DEVELOPMENT_ROADMAP_Q3_2026
document_type: Project Roadmap
version: 1.0
last_updated: 2026-07-18
author: ARCHR Development Team
audience: Leadership, Development Team, Stakeholders
status: For Review
timeline: July - September 2026
---
## Executive Summary

The ARCHR platform requires significant foundational work to transition from a prototype to a reliable, production-ready system. Over the next two months, we need to focus on five core areas:

|Priority|Area|Status|Focus|
|---|---|---|---|
|**Critical**|Intake Form & Submission|❌ Broken|Fix submission errors, add save/offline capability|
|**Critical**|Database Consolidation|⚠️ Split|Unify Airtable + PostgreSQL with dual-write|
|**Critical**|Requestor Account Creation|⚠️ Partial|Complete account generation, credentials, notifications|
|**High**|Role Consolidation|⚠️ Fragmented|Reduce to 4 permission levels, ensure fluidity|
|**High**|Eligibility Engine|⚠️ Static|Make dynamic, configurable by admins|
|**Medium**|Document Bucket|❌ Not Started|Create case directories via API or local server|
|**Medium**|Component Library|⚠️ Broken|Fix paths, organize components|
|**Medium**|Onboarding Portal|❌ Not Started|Self-service Super-Admin and org setup|
|**Ongoing**|Metrics & Reporting|⚠️ In Progress|Refine accuracy, automate funder reports|
|**Ongoing**|Task Engine & Progress Tracker|⚠️ Semi-functional|Complete audit trail, immutable ledger|

---

## Phase 1: Critical Fixes (Weeks 1-3)

### 1.1 Intake Form Overhaul

|Task|Description|Owner|Urgency|
|---|---|---|---|
|Fix submission error|Resolve "Submission Processing Failed" bug|Dev|🔴 Critical|
|Add save progress|Enable partial form saves, resume later|Dev|🔴 Critical|
|Offline capability|Allow form loading and data entry without internet|Dev|🟡 High|
|Comma support|Accept numbers with commas (e.g., 50,000)|Dev|🟡 High|
|Priority labels|Replace numeric scale with descriptive options|UX|🟡 High|
|Improve question wording|Review awkward/confusing questions|UX|🟢 Medium|

**Success Criteria:**

- Submission error rate: 0%
    
- Form progress saved automatically every 30 seconds
    
- Offline mode: form loads and caches entries
    
- User testing: 100% of test users complete without confusion
    

---

### 1.2 Submission Triggers & Events

When an application submits successfully, the following events must trigger:

|Event|Description|Status|Owner|
|---|---|---|---|
|**Database Write**|Submit to BOTH Airtable AND PostgreSQL|⚠️ Partial|Dev|
|**Requestor Account**|Create low-permission account, show credentials|⚠️ Partial|Dev|
|**Confirmation Email**|Send to requestor with login link, form copy|❌ Not Started|Dev|
|**Admin Alert**|Email + platform notification to admins|❌ Not Started|Dev|
|**Alert Opt-Out**|Profile setting: "Do not send alerts"|❌ Not Started|Dev|
|**Recent Queue**|Add submission to queue for admin review|⚠️ Partial|Dev|
|**Eligibility Check**|Run automatic eligibility checks|⚠️ Partial|Dev|
|**Case Directory**|Create folder in Document Bucket|❌ Not Started|Dev|

**Success Criteria:**

- All 8 events trigger on every submission
    
- Dual-database writes succeed with rollback on failure
    
- Email delivery rate: >95%
    

---

## Phase 2: Database & Account Consolidation (Weeks 3-5)

### 2.1 Dual-Database Architecture

![[Pasted image 20260718095110.png]]

**Requirements:**

|Requirement|Description|
|---|---|
|**Dual-Write**|Every submission writes to both databases|
|**Toggle Method**|Easy switch between Airtable and PostgreSQL|
|**Developer Friendly**|Clean abstraction, easily removable if consolidated|
|**Error Handling**|If one fails, log error but continue with the other|
|**Migration Path**|Clear path to deprecate one database when ready|

**Success Criteria:**

- 100% of submissions write to both databases
- Toggle switches between databases without code changes
- Abstraction layer: < 100 lines of PHP

### 2.2 Role Consolidation (4 Permission Levels)

| Level | Name                   | Roles Included                            | Access Level                                              |
| ----- | ---------------------- | ----------------------------------------- | --------------------------------------------------------- |
| **1** | **Field Worker**       | Volunteer, Requestor, Crew Member         | View own data, log hours, complete tasks                  |
| **2** | **Office Worker**      | Caseworker, Assessor, Subcontractor       | Create/edit data, log all actions, no destructive changes |
| **3** | **Organization Admin** | Admin, Project Manager, Bursar, Crew Lead | Full org control, manage staff, all non-destructive       |
| **4** | **Super-Admin**        | System Administrator                      | Full system access, sandbox mode, all features            |

**Key Changes:**

- Email digest option for Level 1 (don't need to log in)
- All Level 2+ actions logged in immutable progress tracker
- Level 3 can modify permissions for Level 1-2 users
- Level 4 has sandbox mode for safe testing

**Success Criteria:**

- All roles mapped to one of 4 levels
- Permission system refactored to support levels
- All Level 2+ actions logged
- Email digest working for Level 1

---

## Phase 3: Core Systems (Weeks 5-7)

### 3.1 Eligibility Engine

**Current State:** Static rules, manually coded  
**Target State:** Dynamic, configurable by Organization Admins and Super-Admins

|Feature|Description|
|---|---|
|**Income Threshold**|Configurable AMI percentage (e.g., 80%, 100%, 120%)|
|**Geographic Area**|ZIP code lists, county selection|
|**Demographics**|Toggle specific population groups|
|**Damage Type**|Helene-related vs. other vs. both|
|**Funding Source**|Link eligibility rules to specific grants|
|**Default Settings**|"Assume eligibility until proven otherwise"|

**Admin Configuration UI:**

- Profile Settings → Eligibility Rules
- Toggle on/off for each criterion
- Set custom values (income %, service area)
- Preview how many applicants would qualify

**Success Criteria:**

- Admins can modify rules without code changes
- Rules apply to new applications in real-time
- Ineligible applications logged with reason codes

---

### 3.2 Document Bucket (Case Directory Creation)

**Current State:** Document spaces exist, but no platform-specific bucket  
**Target State:** API-connected or local server for document storage

**Options:**

|Option|Pros|Cons|Recommendation|
|---|---|---|---|
|**Dropbox API**|Reliable, managed, easy integration|Monthly cost, dependency|✅ Primary option|
|**Local Server**|Free, full control|Maintenance, security risk, no backup|❌ Not recommended|
|**AWS S3**|Enterprise-grade, scalable|Cost, setup complexity|⚠️ Future option|

**Folder Structure (from document-storage.md):**

```
/organizations/
└── /{org_id}/
    └── /cases/
        └── /{case_number}/
            ├── /application/
            ├── /property/
            ├── /income/
            ├── /assessments/
            ├── /contracts/
            ├── /work_orders/
            ├── /financial/
            ├── /completion/
            └── /communications/
```

**Success Criteria:**

- Case directory created on application submission
- Standardized folder structure in place
- File naming convention implemented
- Basic CRUD operations via API
### 3.3 Component Library Fix

**Current State:** `component-library.php` is broken, components not loading  
**Target State:** Working component registry with path constants

**Implementation Plan:**

php
```
<?php
// config/paths.php
define('COMPONENTS_PATH', __DIR__ . '/../elemental-integration/components/');
// component-library.php
function load_component($component_name) {
    $path = COMPONENTS_PATH . $component_name . '.json';
    if (file_exists($path)) {
        return json_decode(file_get_contents($path), true);
    }
    return null;
}

```

**Success Criteria:**

- All components load correctly
- Path constant set and documented
- Component listing page works

---

## Phase 4: Onboarding & Support (Weeks 7-8)

### 4.1 Onboarding Portal

**Purpose:** Self-service setup for new ARCHR instances

**Workflow:**
![[Pasted image 20260718094827.png]]

**Success Criteria:**

- Installation script runs successfully
- Super-Admin created without manual database edits
- Organizations can be added via UI
- 2-way sync with Airtable + PostgreSQL

---

### 4.2 Super-Admin Dashboard

**Components:**

- System health monitor (uptime, errors, response time)
- Organization overview (all orgs with key metrics)
- User management (add, deactivate, impersonate)
- Onboarding queue (pending orgs, setups)
- Audit log (system-wide changes)
- Sandbox mode toggle

**Success Criteria:**

- Dashboard fully functional
- Sandbox mode prevents production data changes
- Audit log captures all Super-Admin actions

## Phase 5: Ongoing Work (Parallel)

### 5.1 Metrics & Reporting

|Metric Group|Status|Focus|
|---|---|---|
|Past Week Metrics|⚠️ Partial|Ensure accuracy, automate calculations|
|All Time Metrics|⚠️ Partial|Complete all 16 metrics|
|Organization Specific|⚠️ Partial|Per-org metrics|
|Funder Reports|❌ Not Started|Monthly report generation|

**Priority Metrics:**

1. Total Applications (weekly/all-time)
2. Average Triage Score
3. Total Jobs / In Progress / Completed
4. Average Job Cost
5. Funding by Source
6. Income Breakdown
7. County Breakdown

**Success Criteria:**

- All metrics displayed on dashboards
- Monthly funder reports generated automatically
- 3-level confidence interval tracked
### 5.2 Task Engine & Progress Tracker

| Component        | Status         | Focus                   |
| ---------------- | -------------- | ----------------------- |
| Quick Add Form   | ⚠️ In Progress | Complete MVP            |
| Immutable Ledger | ⚠️ In Progress | All actions logged      |
| Task Definitions | ⚠️ Partial     | Complete all 74 tasks   |
| Workflow Phases  | ✅ Complete     | 6 phases mapped         |
| Notifications    | ❌ Not Started  | Email + platform alerts |

**Success Criteria:**

- All 6 phases have complete task lists
- Progress tracker logs every action
- Quick Add works from any dashboard
- Notifications working for all major events

Week 1-2:  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  Intake Form Fix + Submission Events
Week 3-4:  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  Database Consolidation + Roles
Week 5-6:  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  Eligibility Engine + Doc Bucket
Week 7-8:  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  Onboarding + Super-Admin
━━━━━━━┷━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┷━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
         Critical Fixes  │  Core Systems  │  Onboarding  │  Ongoing Metrics

## Task Priority Matrix

|Task|Urgency|Complexity|Impact|Priority|
|---|---|---|---|---|
|Fix submission error|🔴 Critical|🟡 Medium|🔴 High|**P0**|
|Add save progress|🔴 Critical|🟢 Low|🔴 High|**P0**|
|Dual-database writes|🔴 Critical|🟡 Medium|🔴 High|**P0**|
|Requestor account creation|🔴 Critical|🟢 Low|🔴 High|**P0**|
|Role consolidation|🟡 High|🟡 Medium|🟡 Medium|**P1**|
|Eligibility engine (dynamic)|🟡 High|🔴 High|🟡 Medium|**P1**|
|Document Bucket|🟡 High|🔴 High|🟡 Medium|**P1**|
|Offline capability|🟡 High|🔴 High|🟢 Low|**P2**|
|Component library fix|🟢 Medium|🟢 Low|🟢 Low|**P2**|
|Onboarding portal|🟢 Medium|🔴 High|🟢 Low|**P2**|
|Comma support in intake|🟢 Low|🟢 Low|🟢 Low|**P3**|
|Priority labels|🟢 Low|🟢 Low|🟢 Low|**P3**|

## Success Metrics

### By End of Q3 2026

- Intake submission success rate: 99.9%
- Dual-database writes: 100% success
- Requestor accounts: 100% of applicants have option
- Admin alerts: All sent within 60 seconds
- Eligibility rules: 100% configurable via UI
- Document Bucket: Case folders created automatically
- Components: All loading correctly
- Super-Admin: Dashboard functional
- Metrics: All tracked accurately
### Quality Indicators

|Metric|Target|
|---|---|
|User error reports|< 5 per week|
|Submission failure rate|< 0.1%|
|Email delivery rate|> 99%|
|Admin satisfaction|> 4/5|
## Next Steps

1. **Review this roadmap** with your boss
2. **Confirm priorities** - adjust P0/P1/P2 based on business needs
3. **Assign owners** to each workstream
4. **Create detailed tasks** in project management tool
5. **Schedule weekly check-ins** to track progress

![[Pasted image 20260718094516.png]]