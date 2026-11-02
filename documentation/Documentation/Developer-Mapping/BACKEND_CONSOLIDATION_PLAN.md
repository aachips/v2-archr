# ARCHR Backend Consolidation & Auth/Permission Plan

**Date:** 2026-10-26  
**Status:** Working document — no code changes made during this audit

---

## 1. Current Architecture (as of today)

### Two Parallel Backends

| | PHP Backend | Vue Backend |
|---|---|---|
| **Location** | `app/*.php` (12+ role portal files) | `vue-view/src/` (1 SPA) |
| **Auth** | PHP sessions (`$_SESSION`) via `app/login.php` | HMAC-SHA256 tokens via `app/vue_api/auth.php` |
| **Data source** | PostgreSQL (direct PDO) | Airtable (dummy/anchor base) |
| **Entry point** | `app/login.php` → redirects to role-specific `.php` files | `/portal/` → Vue SPA with `LoginPage.vue` |
| **Status** | **Working** — login fixed, all 12 role portals functional | **Partially working** — login works, but reads from Airtable, not PostgreSQL |

### What Was Fixed Today
- **Case-sensitivity bug**: Database stores role codes as UPPERCASE (`SUPER_ADMIN`), PHP queries used lowercase. Fixed with `LOWER()` in 12 PHP files.
- **Role lookup mismatch**: After auth, `login.php` received lowercase role_code but `$role_dashboards` keys were uppercase. Fixed with `strtoupper()`.
- **Super admin password**: Set `superadmin` account password to `12345` for testing.
- **Vue build**: Restored 15 missing source files from `documentation/`, added portal build entry, deployed to `portal/`.
- **Portal 404**: Stale JS bundle hash mismatch caused blank white page. Redeployed all dist assets.

### Current Working State
- `app/login.php` — ✅ Login works for all 13 roles, redirects to correct dashboard
- `app/vue_api/auth.php` — ✅ Returns valid tokens with user data and role info
- `/portal/` — ✅ Vue SPA loads and shows login page
- PHP session auth — ✅ Working
- Vue token auth — ✅ Working
- Vue case data — ❌ Still reads from Airtable, not PostgreSQL

---

## 2. Role & Permission Architecture

### 4 Permission Levels (Authoritative: `app/lib/permissions.php`)

| Level | Name | Capability Summary | Roles |
|---|---|---|---|
| **0** | Viewer | View own cases, own profile, log hours, view assigned tasks | `volunteer`, `requestor`, `crew-member` |
| **1** | Office Worker | Level 0 + view org cases (limited), edit cases (logged), create tasks, view assessments, upload documents | `assessor`, `subcontractor`, `envoy`, `crew-lead`, `tle-poc` |
| **2** | Organizational Admin | Level 1 + claim cases, manage org team, view org metrics, manage documents, approve expenses, change case status, assign staff | `project-manager`, `bursar`, `org-admin`, `admin`, `caseworker` |
| **3** | Super Administrator | Level 2 + view all orgs, manage users, manage orgs, platform config, manage docs, view audit log, handle helpdesk, onboarding | `super-admin` |

### 13 Roles Mapped

| Role Code | Level | Default Dashboard | Needs Marketplace? | Needs Case Search? |
|---|---|---|---|---|
| `volunteer` | 0 | Volunteer portal | No (sees quests/tasks) | No |
| `requestor` | 0 | Requestor portal | No | No (sees own case only) |
| `crew-member` | 0 | Crew Member portal | No | No (sees assigned tasks) |
| `assessor` | 1 | Assessor portal | No | Yes (limited lookup) |
| `subcontractor` | 1 | **Marketplace** (primary view) | **Yes** (core feature) | No (sees suggested tasks) |
| `envoy` | 1 | Envoy portal | Maybe (community outreach) | Yes (limited) |
| `crew-lead` | 1 | Crew Lead portal | Maybe (task assignment) | Yes |
| `tle-poc` | 1 | TLE-POC page | No | No |
| `project-manager` | 2 | Org Admin / Project view | Yes (assign subs, manage projects) | Yes |
| `bursar` | 2 | Org Admin / Finance view | Yes (budget/finance oversight) | Yes |
| `org-admin` | 2 | Org Admin (default Vue portal) | Yes | Yes |
| `admin` | 2 | Org Admin | Yes | Yes |
| `caseworker` | 2 | Case Search | Maybe | Yes |
| `super-admin` | 3 | Super Admin panel | No (system-level) | Yes (cross-org) |

---

## 3. What Each Role Needs from Auth

### Level 0 Roles (Viewer)

**Volunteer:**
- Auth → see welcome message, personal quests/tasks, availability, skills, personal info
- No case data access beyond assigned tasks
- Needs: Login → volunteer dashboard with quests, reputation meter (future), hours logging

**Requestor:**
- Auth → see own application status, upload documents, track case progress
- Similar to "Case Review" but scoped to their own home repair application
- Needs: Login → requestor portal (own case timeline, document upload, status updates)

**Crew Member:**
- Auth → see assigned tasks, log hours, view schedule
- No case search, no org-level data
- Needs: Login → task list, schedule view, hour logging

### Level 1 Roles (Office Worker)

**Subcontractor (Marketplace primary user):**
- Auth → see available tasks matching trade, claim tasks, submit quotes, set dates, upload after-photos, invoice
- Does NOT need full case search — only their tasks and suggested tasks
- Needs: Login → **Marketplace** as default view with "Accepted Tasks" + "Suggested Tasks" panels
- Claim flow: Browse suggested → Click "Claim" → Set estimate date → Submit quote → Do work → Upload photos → Invoice

### Level 2 Roles (Organizational Admin)

**Org Admin / Project Manager / Bursar / Admin / Caseworker:**
- Auth → full org-scoped case management
- Needs: Login → Vue SPA (`/portal/`) as default view with FilterableCaseList, Case Review, Marketplace (for assigning subs), Documents Bucket, Team Management

### Level 3 (Super Administrator)

- Auth → cross-org view, user management, org management, helpdesk, audit log, platform config, documentation library
- Needs: Login → Super Admin panel (PHP-based, `app/super-admin.php`)

---

## 4. Marketplace Deep Dive

### What It Is
The Marketplace is the pool of unclaimed RepairNeeds and RepairTasks that organizations and subcontractors can claim. It's the **default view for Subcontractors** and a **management view for Level 2 admins**.

### The Claim Object (from `Developer-Mapping/Canonical Objects/Claim.md`)
- States: `pending` → `active` → `released` / `expired` / `rejected` / `cancelled`
- Commands: `requestClaim`, `activateClaim`, `claimRepairNeed`
- Events: claim requested, claim approved, claim activated, claim released, claim expired
- An organization claims a RepairNeed; a subcontractor claims RepairTasks within that Need

### Subcontractor "Check-Out" Cart (from barkin orders.md)
The Marketplace supports bulk management with a cart/check-out pattern:
```json
{"cartType": "repairNeed", "cartItems": ["rec123675867834"]}
```
Cart types:
- **Repair Needs** — Claim/Release/Add Tasks
- **Repair Tasks** — Add to/Remove from Contract, Mark Complete, Delete
- **Documents** — Unlink/Reassign/Mark Verified/Unmark Verified
- **People** — Edit Roles/Add to Workcrew/See History
- **Subcontractors** — Solicit Bids
- **Projects** — Mark Complete/Assign Subcontractor/Add to Draw Requests

### What Auth Needs to Do for Marketplace
1. **Subcontractor login** → role = `subcontractor`, level = 1 → default route to Marketplace
2. Marketplace shows only tasks matching the subcontractor's trade specialty
3. Claim actions require `edit_cases` capability (Level 1)
4. Quote/invoice actions require `create_tasks` capability (Level 1)
5. Level 2 users see ALL unclaimed/claimed items across their org's cases (full Marketplace management view)
6. Level 0 users see nothing (no Marketplace access)

---

## 5. Volunteer & Volunteer Management Deep Dive

### Volunteer Portal (Level 0)
- Welcome message with name
- Available quests/tasks within range
- Own active quests
- Personal info: availability, skills, experience
- Hour logging

### Volunteer Management (Level 2 admin feature)
- Create/manage quests for volunteers
- Verify quest completions
- Manage volunteer accounts
- Assign volunteers to projects/cases
- Track volunteer hours and contributions

### Volunteer Gamification (Roadmap — not yet built)
- XP/reputation system (0-1000 reputation, levels 1-10)
- Badge tiers
- "First Quest" onboarding tutorial
- "Volunteer Contributor" role after 5 published stories
- 4-phase rollout (MVP at 3 months, full at 18+ months)

### What Auth Needs to Do for Volunteers
1. **Volunteer login** → role = `volunteer`, level = 0 → default route to volunteer portal
2. Volunteer portal shows only their assigned quests/tasks
3. No case data access, no org data
4. **Volunteer account creation**: Application flow → auto-generates Level 0 account (not through platform, through org website — but needs platform API endpoint)
5. Admin managing volunteers needs Level 2 `manage_org_team` capability

---

## 6. Backend Merge: What's Done, What's Left

### ✅ Already Built
| Component | Status |
|---|---|
| PHP session auth (`app/login.php`) | Working |
| Vue token auth (`app/vue_api/auth.php`) | Working |
| Permission layer (`app/lib/permissions.php`) | Working, authoritative |
| Role mapping (13 roles → 4 levels) | Working |
| Super Admin panel (PHP) | Working |
| Org Admin portals (PHP, 12 files) | Working |
| Vue SPA shell (AppHeader, AppSidebar, theme/lang) | Working |
| Vue auth store (`store/auth.js`) | Working |
| Vue login page (`LoginPage.vue`) | Working |
| Activity log (both PHP and Vue write to same table) | Working |

### ❌ Not Yet Done
| Component | What's Needed |
|---|---|
| **Vue reads PostgreSQL** | `vue_api/cases.php` is a stub — needs to query PostgreSQL and return cases. `caseService.js` needs a PostgreSQL backend path. |
| **Single login entry point** | Currently `app/login.php` (PHP sessions) and `/portal/` (Vue tokens) are separate. Need unified entry: login → redirect based on role. |
| **Vue respects actual user role** | Vue SPA defaults to `role: "super-admin"` in data() regardless of actual role. Needs to use `$auth.role` and `$auth.roleLevel` for view gating. |
| **Marketplace in Vue** | Marketplace.vue exists but reads from Airtable. Needs PostgreSQL data source. |
| **Volunteer portal in Vue** | No volunteer view exists in Vue yet. Needs to be built as a Vue component. |
| **Requestor portal in Vue** | Exists as PHP (`requestor-portal.php`). Needs Vue equivalent. |
| **Role-based default views** | After login, route to correct view based on role level (Level 0 → specific portal, Level 2 → Org Admin, Level 3 → Super Admin). |
| **Cart/Check-out system** | Mentioned in barkin orders.md but not implemented. Needs Pinia store for cart state. |

---

## 7. Consolidation Plan (3 Phases)

### Phase 1: Unified Auth & Role-Based Routing (1-2 days)
**Goal:** One login page, one auth system, role-based default views.

1. Make `app/login.php` the single login for all roles
2. After successful auth, redirect based on `role_level`:
   - Level 3 → `app/super-admin.php` (keep PHP for now)
   - Level 2 → `/portal/` (Vue SPA, already built)
   - Level 1 → role-specific view (Marketplace for subcontractor, PHP portal for others)
   - Level 0 → role-specific view (volunteer/requestor portal)
3. Ensure both PHP session and Vue token systems recognize the same user
4. Add logout that clears both session and token

### Phase 2: Vue Gets PostgreSQL Data (2-3 days)
**Goal:** Vue SPA reads from PostgreSQL, not Airtable.

1. Implement `vue_api/cases.php` — query PostgreSQL `cases`, `intake_submissions`, `coalition_organizations`, `case_statuses` tables
2. Update `caseService.js` — add PostgreSQL fetch path alongside Airtable
3. Add feature flag or localStorage toggle to switch between data sources
4. Test that Vue Case Review, FilterableCaseList, and Marketplace show real PostgreSQL data

### Phase 3: Progressive Role Migration to Vue (multi-week)
**Goal:** Each PHP role portal becomes a Vue view component.

Priority order (by impact):
1. **Marketplace** (Subcontractor default) — already exists as Vue component, just needs PostgreSQL data
2. **Volunteer portal** — needs to be built as Vue view
3. **Requestor portal** — exists as PHP, needs Vue equivalent
4. **Assessor portal** — field-work view, needs Vue component
5. **Crew Lead / Crew Member** — task management views

Each migration:
- Build Vue view component
- Wire to `vue_api/` endpoint
- Gate behind `$auth.roleLevel` check
- Keep PHP file as fallback during transition
- Deprecate PHP file after Vue version is stable

---

## 8. Documentation Gaps Identified

| Gap | What's Missing |
|---|---|
| Cart/Check-out spec | Mentioned in barkin orders.md but no detailed spec |
| Volunteer admin view | User stories exist, no admin-side management spec |
| "View As" / role-switching | Mentioned as desired Super-Admin feature, no spec |
| Capability matrix | No role × permission grid document (only in code) |
| Requestor → Marketplace flow | No diagram connecting intake submission to Marketplace listing |
| Subcontractor claiming reconciliation | Two different claiming flows (org-level vs individual task) not reconciled |
| Auth architecture doc | No end-to-end auth flow document |

---

## 9. Key Files Reference

### Auth & Permissions (source of truth)
- `app/lib/permissions.php` — Role-to-level mapping, capability matrix
- `app/lib/auth.php` — PHP session auth functions
- `app/vue_api/auth.php` — Vue token auth bridge
- `app/vue_api/token-middleware.php` — Token verification middleware
- `app/lib/session.php` — Session management

### Documentation
- `Your Dashboard/Dashboard Role Permission Levels.md` — 13 roles, 4 levels
- `Developer-Mapping/DASHBOARD_CONSOLIDATION_PLAN.md` — Consolidation architecture
- `Developer-Mapping/interface/subcontractor/` — Subcontractor role specs (4 files)
- `Developer-Mapping/interface/volunteer/getting-started.md` — Volunteer user stories
- `Developer-Mapping/Canonical Objects/Claim.md` — Claim object state machine
- `Developer-Mapping/Canonical Objects/Repair Need.md` — RepairNeed lifecycle
- `Start Here/platform-anatomy/branding-guide.md` — Marketplace definition, role identity system
- `Start Here/platform-anatomy/ARCHR Developer Roadmap July 20-Sept 21.md` — Role consolidation roadmap
- `Start Here/sops/roles-and-access-levels.md` — 11-level granular hierarchy (SOP)

---

## 10. Immediate Next Step (When Ready)

Pick **one** of these to tackle first:

A. **Phase 1 — Unified Auth**: Make `app/login.php` route to correct views based on role level. This is the smallest change with the biggest impact.

B. **Phase 2 — Vue + PostgreSQL**: Wire `vue_api/cases.php` to PostgreSQL so the Vue portal reads real data. This unlocks everything else.

C. **Marketplace spec**: Document the full cart/check-out flow for Subcontractors before building anything.

No code changes will be made until you choose a direction.
