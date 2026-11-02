### 9-6-2026

#### Documentation Library (Help Center)

- Added frontmatter to 12+ existing markdown files - went from 15 to 43 published docs
- Wrote 9 full SOPs from outlines - Application Review, Home Assessment, Repair Projects, Case Completion, Financial Management, Volunteer Management, How to Claim a Case, Document Management, Navigate Help
#### Added feedback-meeting' category to the help system

- Fixed the help page sidebar - collapsible categories, sticky full-height, title truncation for long names, no horizontal scroll
#### Permission & Role Consolidation

- Created 'lib/permissions. php' - maps 12 roles > 4 permission levels (Viewer, Office Worker, Org Admin, Super Admin) with capability system
- Enhanced 'Lib/auth. php' - added archr_current_permission_level(), archr_current_user_has_capability(), archr_require_level()
- Expanded org-admin navigation - added Projects, Finance, Marketplace, Admin groups with 15+ page links
- Fixed role dropdown - Super Admin sees all roles, Level 2 sees only Org Admin, lower levels see their role and below
- Added consolidated admin view bar at top of org-admin page - direct links to Bursar, Project Manager, Envoy, Crew Lead pages
- Restored project-manager.php to working state (was a dead redirect)
#### Persistent Sidebar Bug Fix

- Fixed 'helpdesk-tickets . php'
- was using hardcoded 3-item nav instead of shared archr_super_admin_nav()
- Created 'archr_case_nav()'
- shared nav for case-search, case, case-documents pages
- Fixed all role portals
- sidebar now shows consistent items across all pages within each portal family
#### Branch Merge & Cleanup

+ Merged 16 API endpoints from app-api-branch-bugs/ with PostgreSQL fixes (GROUP_CONCAT+STRING_AGG, DATEDIFF+EXTRACT, etc.)
+ Merged `partials/dashboard-home.php' reusable component
- Archived 9 documentation files to documentation/archived-branch-docs/
- Deleted 'app-api-branch-bugs/' - fully accounted for
#### Activity Log in Vue

+ Built 'ActivityLog. vue' component - filterable data table with chain verification, expandable details, pagination
- Created activityLogService. js' - service layer with mock data (10 realistic entries covering all action categories)
- Wired into App. vue - new "Activity Log" nav item in sidebar
- Full filter panel - user, category, action, source, application ID, case ID, date range, text search
#### Profile / Menu Configuration

- Added `menu_config' JSONB column to system_users
- Profile page got tabbed interface - Profile tab + Menu Configuration tab
- Menu config lets users toggle sidebar items on/off per their preference org-admin sidebar dynamically filters based on saved menu config

### 9-7-2026

#### Auth System (Pieces 1-3):

- Built PHP auth bridge (app/vue_api/auth.php) - login + token verify against PostgreSQL, HMAC-signed tokens (24h or 30d with remember_me)
- Created Vue auth store (vue-view/src/store/auth. js) - reactive Vue 2 state, localStorage persistence, auto-verify on app load
- Built Vue login page (vue-view/src/components/LoginPage. vue) - email/password form, remember-me checkbox, error display
- Gated the Vue app behind auth in App. vue - shows login when unauthenticated, loads cases only after login
- Fixed dev server proxy config (vue.config. js) - was stripping /app prefix, now correctly forwards to PHP backend
- Mounted $auth on Vue prototype (main. js) for component-wide access

----------------------
#### Token Middleware for API Requests:

- Created app/vue_api/token-middleware.php - reusable PHP token verification (vue_require_auth_token()) for any endpoint
- Added getToken() and getAuthHeaders() to authService. js - injects Authorization: Bearer header on API calls
- Created app/vue_api/cases.php - sample authenticated endpoint (placeholder)
- Updated app/api/activity-log.php to accept Vue auth tokens alongside PHP sessions
#### Activity Log Fixes:

- Rewrote activityLogService. js to call real PostgreSQL API instead of hardcoded mock data
- Created app/vue_api/activity-log.php - write endpoint for Vue app to log to activity_log + activity_detail tables
- Updated PHP read API to LEFT JOIN activity_detail rows and display old > new field values
- Added contact edit logging in App. vue onSaveContact - logs ledger entry + per-field detail rows
- Added refresh button to Activity Log component
- Fixed household label resolution to use placecode consistently (prioritized over display_name)
- Fixed household label fallback to resolve from case_id when application_id is null (Vue app)
#### Search Fix:

- Expanded header search to include address, zip, placecode, organization fields
#### Dropbox Documents Bucket:

- Diagnosed and fixed Dropbox 400 error - json_encode([]) was sending [] instead of {}; fixed with JSON_FORCE_OBJECT
- Created app/vue_api/bucket.php - bucket listing + file open endpoint (Dropbox or local fallback)
- Built vue-view/src/components/DocumentsBucket. vue - full file browser with breadcrumbs, list/grid view, folder navigation, file downloads
- Added "Documents Bucket" sidebar nav item in Vue app
#### Bug Fixes:

- Fixed $titles undefined variable order in api/documents.php review action (found by simplify agent)
- Fixed Babel compile error ( ?? operator not supported in Vue 2 project - replaced with ternary)
- Fixed activityLogService. js detail row display with old>new value styling (red strikethrough > green bold


### 9-9-2026

#### Profile Settings

- Built app/vue_api/profile.php - GET/POST endpoint for user profile (name, email, phone, indefinite session toggle)
- Built vue-view/src/services/profileService. js - service layer
- Built vue-view/src/components/ProfileSettings. vue - two-tab component (Profile + Search Columns)
- Wired into App. vue and AppHeader - Profile link in avatar dropdown now navigates to the settings page
- Column visibility preferences stored in localStorage, broadcast live to FilterableCaseList
#### Case Search Results - Stage 1 (Display + Filters + Export)

- Rebuilt FilterableCaseList.vue from flex-box cards to a proper accessible table with thead
- Placecode is now the primary identifier (Case # removed from defaults)
- derivePlacecode() - ported PHP archr_placecode() logic to Vue, derives codes from address when empty
- Red triangle SVG icon ( A for urgent, moved to Placecode column
- Richer filters: status dropdown, org dropdown, date range (From/To), sort by (newest/oldest/name/city), urgent-only checkbox
- Client-side CSV and Excel export of filtered results
- Column visibility: toggleable per-column, configured in Profile Settings
#### Help Library

- Removed Vue HelpLibrary component - sidebar "Help Library" now opens app/help.php in a new tab
- Deleted dead code from App.vue
#### Quick Tasks > Task Engine (TLE-POC port)

- Rebuilt QuickTasks. vue from a simple case picker + modal into the full two-phase task engine:
- Quick Entry - type one or more lines, submit to unverified queue (zero friction)
#### Advanced fields - expandable case/type/priority on submit

- Unverified Queue - raw entries with type chips, triage, and verify
- Triage Modal - split entries into multiple lines, assign case/placecode, type, priority, then verify
- All Verified - structured table with type and status pills
- Case Event Log - case picker + event feed (uses existing fetchCaseEvents)
- Data stored in localStorage for POC (moves to DB when API bridge is ready)
#### Responsive Viewport (all breakpoints)

- Hamburger menu - appears at less than 992px, toggles sidebar from left with dark overlay
- Sidebar close button - in a proper nav header ("Navigation" label + X), no overlap with nav items
- Three ways to close sidebar: X button, click overlay, click hamburger again
- Filters - centered, uniform-width chips that wrap naturally at narrow widths
#### Case search table - Mobile Responsiveness
+ hides Status+Phase at less than 992px, also hides Organization at less than 480px
- QuickTasks - stacked modal fields, full-width buttons, horizontal-scroll tabs, narrow verified table
- ProfileSettings - single-column grids, scrollable tabs, reduced padding
- AppHeader - wraps on mobile, search goes full-width, button labels hide (icon-only)
- App. vue shell - overlay layer, flex layout, reduced content padding

#### Event Resolver (PHP - first build)
- Design doc (app/lib/event-resolver/README.md) - architecture, pipeline, milestone table, usage
- Milestone definitions (milestones. php) - 15 milestones (M1-M15) across 6 phases, each with an evaluate() rule
- Core resolver (resolver.php) - archr_resolve($pdo, $caseId) > { phase, phase_name, milestones[], next_actions[], blocked }
- State mutator (mutator.php) - idempotently stamps milestone timestamp columns on cases table
- CLI test script (test.php) - run php app/lib/event-resolver/test.php caseId from terminal
- Vue API endpoint (app/vue_api/event-resolver.php) - auth-gated, GET/POST
- Vue service (eventResolverService. js) - resolveCase(caseId) for frontend consumption




## September 8-11, 2026 (Continued)

### Event Resolver (PHP)
- Design doc (app/lib/event-resolver/README.md) - architecture, 6-phase pipeline, milestone table, usage
+ Milestone definitions (milestones. php) - 15 milestones (M1-M15) across phases 0-5, each with an evaluate() rule that checks progress_events and cases columns
- Core resolver (resolver.php) - archr_resolve($pdo, $caseId) > { phase, phase_name, milestones[], next_actions[], blocked }
+ State mutator (mutator.php) - idempotently stamps milestone timestamp columns on cases table
- CLI test script (test.php) - php app/lib/event-resolver/test.php caseId
+ Vue API endpoint (app/vue_api/event-resolver.php) - auth-gated GET/POST
+ Vue service (eventResolverService. js) - resolveCase(caseId) for frontend

### Support Chat + Helpdesk

- Vue widget (SupportChat. vue) - floating bottom-right panel with dumb bot greeting ("Beep boop. Me dumb robot"), category selector, submit form, confirmation with ticket #
+ PHP endpoint (support-chat. php) - creates ticket, auto-prioritizes ("crash"/"broken"/"cant log" > high), auto-creates support_tickets table
+ Super-Admin queue - integrated into super-admin. php#helpdesk-tickets (hash-routed), filterable table, expandable details, assign-to-user, resolve-with-note
- API actions - assign_ticket and resolve_ticket added to api/super-admin. php
- Database schema (sql/support-tickets.sql) - PostgreSQL table with status, priority, category, assignment, resolution
+ Email alerts - ARCHREmailer extended with sendSupportTicketAlert(), queries all SUPER_ADMIN users from DB, sends on each ticket submit

### Email / Mailpit Integration

- ARCHREmailer' updated - send() now auto-detects Mailpit on 127.0.0.1:1025 via fsockopen, sends via raw SMTP if available, falls back to file logging (app/logs/emails. json) if not sendViaSMTP()' - raw socket SMTP implementation (no PHPMailer needed locally) 
+ `getSuperAdminEmails()' - queries DB for all active SUPER_ADMIN users with emails
+ Mailpit configured - running on 127.0.0.1:1025 (SMTP) / 8025 (web UI at http://127.0.0.1:8025)
- Verified end-to-end - test ticket submitted, email confirmed in Mailpit API + web UI
### Super Admin Renamed + Helpdesk Nav Fix

- Renamed super-admin-portal.php > super-admin.php (all 10 refe)
- Helpdesk nav link fixed from standalone helpdesk-tickets.php > super-admin.php#helpdesk-tickets (hash-routed within portal)
- Helpdesk section added to super-admin-body.php with full ticket table
+ Sidebar now navigates correctly between all Super Admin sections

### Eligibility Presets + AMI System

+ Eligibility presets (app/config/eligibility-presets.php) - bulk rule templates keyed by slug
+ Habitat for Humanity preset - 10 rules: service areas (Buncombe + Madison), 80% AMI income, proof types, home types, max value, ownership, residence years, mobile home lot
- Community Housing Coalition preset - 8 rules: Madison County only, same income/proof/home criteria, no mobile lot or residence years
- Bulk import API - bulk_eligibility_preset action resolves type_code > criteria_type_id, inserts all rules, returns count
- UI - blue "Load Preset" bar above each org's eligibility table, dropdown with preset options, confirmation alert on load
- AMI Lookup table (sql/ami-lookup. sql) - ami_lookup with county/state/year and per-household-size AMI values. Seeded with Buncombe ($66,531) and Madison ($56,641) for 2026
+ income_max_ami_percent' criteria type - stores 80 (meaning 80% of AMI), resolved against ami_lookup table instead of raw dollar amounts
- SQL seed file (sql/seed-habitat-eligibility.sql) - standalone SQL for manual execution

### Quick Links Page
(;app/quick-links. php')
- Three groups: AMI & Census Data (HUD, Census), GIS Property Lookup (Buncombe, Madison, NC), Internal Shortcuts (eligibility rules, helpdesk, audit log)
- External links open in new tab with "External" badge
- Nav item added to Super Admin sidebar with @ icon
### Responsive Viewport (all components)
- Hamburger menu at < 992px with three close methods (X button, overlay, hamburger toggle)
- Centered uniform-width filter chips on case search
- Stacked modals, narrow tabs, full-width buttons on mobile
- All breakpoints synced at 992px / 480px
- curated resource page with card grid layout

## Follow-Up / Continue Later

1. Event Resolver - wire into save flows - Call archr_resolve() automatically after archr_log_event() in org-admin. php (claim), documents.php (upload/verify), intake-save.php (submission). Currently callable but not auto-triggered.

2. Event Resolver - refine evaluation rules - Current milestone rules are placeholders (checking for ILIKE patterns in details :: text). Need to tighten rules to check specific event fields/JSON paths, and add rules for milestones that don't have dedicated columns yet (M4, M7, M9, M10, M13, M14, M15).

3. AMI evaluator - The income_max_ami_percent rule is stored but not yet evaluated. Need to build the resolver function that reads ami_lookup for the applicant's county, multiplies by the percentage, and compares against actual household income.

4. QuickTasks - Triage modal depth - The triage modal works but needs: photo attachment, "split into multiple verified entries" that create different types from one raw line, and a proper task-to-application mapping (currently stores placecode as a string, not a FK). Move QuickTasks to DB - Unverified and verified data currently in localStorage. Needs a progress_events write endpoint and a Vue-callable API to persist.

5. Case Review - SummaryHead crash - Guarded against empty caseItem, but root cause may still produce warnings during transitions.

6. Vue Router / auth guards - No route-level protection yet. Auth is conditional rendering in App. vue. If the app grows, Vue Router with beforeEach guards would be cleaner.

7. Password reset - Still deferred (no email/SMTP system for production - Mailpit is local only).

8. Production SMTP - Mailpit works locally. Need PHPMailer + SendGrid/webhost SMTP credentials for production email delivery.

9. Eligibility presets for remaining 2 organizations - Doc mentions 4 total; Habitat and CHC are done, 2 more to add when their requirements are documented.

10. Vue Router / auth guards - No route-level protection yet. Auth is handled by conditional rendering in App.vue. If the app grows to more views, Vue Router with beforeEach guards would be cleaner.

11. Password reset - Still deferred (no email/SMTP system).