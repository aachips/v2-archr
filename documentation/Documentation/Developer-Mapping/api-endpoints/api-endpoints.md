# ARCHR Platform API Endpoints

This document consolidates all API endpoints across all roles in the ARCHR platform.

---

## Table of Contents

- [ARCHR Platform API Endpoints](#archr-platform-api-endpoints)
  - [Table of Contents](#table-of-contents)
  - [Assessor](#assessor)
  - [Project Manager](#project-manager)
  - [Crew Lead](#crew-lead)
  - [Crew Member](#crew-member)
  - [Bursar](#bursar)
  - [Subcontractor](#subcontractor)
  - [Volunteer](#volunteer)
  - [Envoy](#envoy)
  - [Organization Admin](#organization-admin)
  - [Requestor](#requestor)
  - [Super Admin](#super-admin)
  - [Notes](#notes)

---

## Assessor

|Endpoint|Method|Purpose|
|---|---|---|
|`/api/assessor/dashboard`|GET|Dashboard data (last assessment, calendar, lists)|
|`/api/assessor/assessments/today`|GET|Today's scheduled assessments|
|`/api/assessor/assessments/upcoming`|GET|Upcoming assessments|
|`/api/assessor/assessments/:id`|GET|Single assessment detail|
|`/api/assessor/assessments/:id/start`|POST|Start assessment (check-in)|
|`/api/assessor/assessments/:id/complete`|POST|Complete assessment|
|`/api/assessor/assessments/:id/photos`|POST|Upload assessment photos|
|`/api/assessor/verifications`|GET|Pending verifications list|
|`/api/assessor/verifications/:id`|PUT|Update verification status|
|`/api/assessor/verifications/verify`|POST|Verify document|
|`/api/assessor/tasks`|GET|Assessment tasks list|
|`/api/assessor/tasks/:id`|PUT|Update task status|
|`/api/assessor/subcontractors`|GET|Subcontractor list|
|`/api/assessor/subcontractors/:id`|PUT|Review subcontractor|

---

## Project Manager

|Endpoint|Method|Purpose|
|---|---|---|
|`/api/pm/dashboard`|GET|Dashboard data|
|`/api/pm/projects/active`|GET|Active projects list|
|`/api/pm/projects/:id`|GET|Single project detail|
|`/api/pm/projects/:id/crew`|PUT|Assign crew|
|`/api/pm/estimates/:id/approve`|POST|Approve estimate|
|`/api/pm/estimates/:id/reject`|POST|Reject estimate|
|`/api/pm/subcontractors`|GET|Subcontractor queue|
|`/api/pm/subcontractors/:id/assign`|POST|Assign to project|
|`/api/pm/escalations`|GET|Active escalations|
|`/api/pm/escalations/:id/resolve`|POST|Resolve escalation|
|`/api/pm/reports`|GET|Generate reports|
|`/api/pm/milestones/:id`|PUT|Update milestone|

---

## Crew Lead

|Endpoint|Method|Purpose|
|---|---|---|
|`/api/crewlead/jobs`|GET|Assigned jobs|
|`/api/crewlead/jobs/:id`|PUT|Change current job|
|`/api/crewlead/phases/:id`|PUT|Update workflow phase|
|`/api/crewlead/orders/change`|POST|Change order request|
|`/api/crewlead/tasks/complete`|POST|Alert task complete|
|`/api/crewlead/jobs/complete`|POST|Alert job complete|
|`/api/crewlead/volunteers/block`|POST|Block volunteer|
|`/api/crewlead/subcontractors`|GET|View subcontractors|

---

## Crew Member

|Endpoint|Method|Purpose|
|---|---|---|
|`/api/crew/dashboard`|GET|Warehouse view|
|`/api/crew/jobs/today`|GET|Today's jobs list|
|`/api/crew/jobs/tomorrow`|GET|Tomorrow view|
|`/api/crew/jobs/:id`|GET|Project detail|
|`/api/crew/tasks/:id`|PUT|Update task status|
|`/api/crew/photos/upload`|POST|Upload photos|
|`/api/crew/logs/daily`|POST|Submit daily log|
|`/api/crew/volunteers/signin`|POST|Sign in volunteer|
|`/api/crew/volunteers/signout`|POST|Sign out volunteer|
|`/api/crew/safety/confirm`|POST|Confirm safety talk|
|`/api/crew/completion/sign`|POST|Sign completion doc|
|`/api/crew/incidents`|POST|File incident report|
|`/api/crew/messages`|GET|Get messages|
|`/api/crew/messages/:id`|GET|Message details|

---

## Bursar

|Endpoint|Method|Purpose|
|---|---|---|
|`/api/bursar/funding-overview`|GET|KPI cards data|
|`/api/bursar/cases/funding`|GET|List of cases with funding|
|`/api/bursar/cases/:id/funding`|GET|Single case funding detail|
|`/api/bursar/reimbursements`|GET|List reimbursement requests|
|`/api/bursar/reimbursements`|POST|Submit new reimbursement|
|`/api/bursar/reimbursements/:id/approve`|POST|Approve invoice|
|`/api/bursar/reimbursements/:id/reject`|POST|Reject with reason|
|`/api/bursar/reimbursements/:id/pay`|POST|Mark as paid|
|`/api/bursar/duplicates`|GET|List duplicate alerts|
|`/api/bursar/duplicates/:id/resolve`|POST|Resolve flag|

---

## Subcontractor

|Endpoint|Method|Purpose|
|---|---|---|
|`/api/subcontractor/dashboard`|GET|Dashboard data|
|`/api/subcontractor/tasks/accepted`|GET|Accepted tasks list|
|`/api/subcontractor/tasks/suggested`|GET|Suggested tasks list|
|`/api/subcontractor/tasks/:id`|GET|Single task detail|
|`/api/subcontractor/tasks/claim`|POST|Claim a task|
|`/api/subcontractor/tasks/accept`|POST|Accept a task|
|`/api/subcontractor/tasks/:id/status`|PUT|Update task status|
|`/api/subcontractor/tasks/:id/dates`|PUT|Set estimate/work dates|
|`/api/subcontractor/tasks/:id/photos`|POST|Upload after photos|
|`/api/subcontractor/quote`|POST|Submit quote|
|`/api/subcontractor/invoice`|POST|Submit invoice|
|`/api/subcontractor/communications`|GET|Get messages|
|`/api/subcontractor/communications/:id`|PUT|Mark message read|
|`/api/subcontractor/communications`|POST|Send message|
|`/api/subcontractor/past-jobs`|GET|Past jobs history|

---

## Volunteer

|Endpoint|Method|Purpose|
|---|---|---|
|`/api/volunteer/dashboard`|GET|Dashboard data (opportunities, schedule, stats)|
|`/api/volunteer/opportunities`|GET|Available volunteer opportunities|
|`/api/volunteer/opportunities/:id`|GET|Single opportunity detail|
|`/api/volunteer/opportunities/:id/claim`|POST|Claim a volunteer slot|
|`/api/volunteer/assignments`|GET|My assigned volunteer shifts|
|`/api/volunteer/assignments/:id`|GET|Single assignment detail|
|`/api/volunteer/assignments/:id/cancel`|POST|Cancel assignment|
|`/api/volunteer/checkin`|POST|Check in to shift|
|`/api/volunteer/checkout`|POST|Check out from shift|
|`/api/volunteer/hours`|GET|My volunteer hours history|
|`/api/volunteer/stats`|GET|My gamification stats (XP, badges, rank)|
|`/api/volunteer/leaderboard`|GET|Volunteer leaderboard|
|`/api/volunteer/profile`|GET|My volunteer profile|
|`/api/volunteer/profile`|PUT|Update volunteer profile|
|`/api/volunteer/availability`|PUT|Update availability|
|`/api/volunteer/notifications`|GET|My notifications|
|`/api/volunteer/notifications/:id`|PUT|Mark notification read|

---

## Envoy

|Endpoint|Method|Purpose|
|---|---|---|
|`/api/envoy/dashboard`|GET|Coalition-wide dashboard|
|`/api/envoy/coalition/overview`|GET|Coalition performance metrics|
|`/api/envoy/coalition/organizations`|GET|List all partner organizations|
|`/api/envoy/coalition/organizations/:id`|GET|Single organization detail|
|`/api/envoy/contracts/pending`|GET|Contracts awaiting approval|
|`/api/envoy/contracts/:id`|GET|Single contract detail|
|`/api/envoy/contracts/:id/approve`|POST|Approve contract (e-signature)|
|`/api/envoy/contracts/:id/reject`|POST|Reject contract with reason|
|`/api/envoy/eligibility/rules`|GET|Current eligibility configuration|
|`/api/envoy/eligibility/rules`|PUT|Update eligibility rules|
|`/api/envoy/funding/overview`|GET|Coalition funding overview|
|`/api/envoy/funding/by-org`|GET|Funding breakdown by organization|
|`/api/envoy/reports/coalition`|GET|Generate coalition report|
|`/api/envoy/reports/funder`|GET|Generate funder report|
|`/api/envoy/performance/metrics`|GET|Coalition performance metrics|
|`/api/envoy/performance/by-org`|GET|Performance by organization|
|`/api/envoy/approvals/budget`|GET|Pending budget approvals|
|`/api/envoy/approvals/budget/:id/approve`|POST|Approve budget|
|`/api/envoy/approvals/budget/:id/reject`|POST|Reject budget|
|`/api/envoy/strategic-notes`|GET|Strategic notes|
|`/api/envoy/strategic-notes`|POST|Create strategic note|

---

## Organization Admin

|Endpoint|Method|Purpose|
|---|---|---|
|`/api/orgadmin/dashboard`|GET|Organization dashboard|
|`/api/orgadmin/applications`|GET|Applications for this org|
|`/api/orgadmin/applications/:id`|GET|Single application detail|
|`/api/orgadmin/applications/:id/assign`|POST|Assign to staff member|
|`/api/orgadmin/applications/:id/eligibility`|PUT|Update eligibility determination|
|`/api/orgadmin/applications/:id/priority`|PUT|Set priority/triage|
|`/api/orgadmin/staff`|GET|Staff list|
|`/api/orgadmin/staff/:id`|GET|Staff member detail|
|`/api/orgadmin/staff/:id/workload`|GET|Staff workload|
|`/api/orgadmin/staff/assignments`|POST|Create staff assignment|
|`/api/orgadmin/volunteers`|GET|Volunteer list for org|
|`/api/orgadmin/volunteers/:id`|GET|Single volunteer detail|
|`/api/orgadmin/volunteers/schedule`|POST|Schedule volunteer|
|`/api/orgadmin/subcontractors`|GET|Subcontractor list for org|
|`/api/orgadmin/subcontractors/:id`|GET|Single subcontractor detail|
|`/api/orgadmin/subcontractors/:id/approve`|POST|Approve subcontractor|
|`/api/orgadmin/subcontractors/:id/review`|POST|Submit subcontractor review|
|`/api/orgadmin/events`|GET|Organization events|
|`/api/orgadmin/events`|POST|Create event|
|`/api/orgadmin/events/:id`|PUT|Update event|
|`/api/orgadmin/reports/org`|GET|Organization reports|
|`/api/orgadmin/messages`|GET|Organization messages|
|`/api/orgadmin/messages`|POST|Send message|
|`/api/orgadmin/timeline`|GET|Recent timeline events|
|`/api/orgadmin/settings`|GET|Organization settings|
|`/api/orgadmin/settings`|PUT|Update organization settings|

---

## Requestor

|Endpoint|Method|Purpose|
|---|---|---|
|`/api/requestor/application`|GET|My application status|
|`/api/requestor/application`|POST|Submit new application|
|`/api/requestor/application`|PUT|Update application|
|`/api/requestor/application/status`|GET|Application status details|
|`/api/requestor/documents`|GET|My uploaded documents|
|`/api/requestor/documents/upload`|POST|Upload document|
|`/api/requestor/documents/:id`|DELETE|Remove document|
|`/api/requestor/eligibility`|GET|My eligibility results|
|`/api/requestor/timeline`|GET|Application timeline|
|`/api/requestor/messages`|GET|Messages from caseworker|
|`/api/requestor/messages/:id`|GET|Single message detail|
|`/api/requestor/messages`|POST|Send message to caseworker|
|`/api/requestor/messages/:id/read`|PUT|Mark message as read|
|`/api/requestor/appointments`|GET|My scheduled appointments|
|`/api/requestor/appointments/:id`|GET|Single appointment detail|
|`/api/requestor/appointments/:id/confirm`|POST|Confirm appointment|
|`/api/requestor/appointments/:id/reschedule`|POST|Request reschedule|
|`/api/requestor/contracts`|GET|My contracts|
|`/api/requestor/contracts/:id`|GET|Single contract detail|
|`/api/requestor/contracts/:id/sign`|POST|E-sign contract|
|`/api/requestor/contact-info`|GET|My contact information|
|`/api/requestor/contact-info`|PUT|Update contact information|
|`/api/requestor/next-step`|GET|What I need to do next|

---

## Super Admin

|Endpoint|Method|Purpose|
|---|---|---|
|`/api/admin/dashboard`|GET|System-wide admin dashboard|
|`/api/admin/users`|GET|All users in system|
|`/api/admin/users/:id`|GET|Single user detail|
|`/api/admin/users`|POST|Create new user|
|`/api/admin/users/:id`|PUT|Update user|
|`/api/admin/users/:id`|DELETE|Deactivate user|
|`/api/admin/users/:id/roles`|PUT|Update user roles|
|`/api/admin/organizations`|GET|All organizations|
|`/api/admin/organizations/:id`|GET|Single organization detail|
|`/api/admin/organizations`|POST|Create organization|
|`/api/admin/organizations/:id`|PUT|Update organization|
|`/api/admin/organizations/:id/activate`|POST|Activate organization|
|`/api/admin/organizations/:id/deactivate`|POST|Deactivate organization|
|`/api/admin/roles`|GET|System roles configuration|
|`/api/admin/roles/:id`|PUT|Update role permissions|
|`/api/admin/system/config`|GET|System configuration|
|`/api/admin/system/config`|PUT|Update system configuration|
|`/api/admin/logs`|GET|System audit logs|
|`/api/admin/logs/:id`|GET|Single log entry|
|`/api/admin/analytics`|GET|System analytics|
|`/api/admin/reports/system`|GET|System-wide reports|
|`/api/admin/backup`|POST|Trigger system backup|
|`/api/admin/maintenance/mode`|POST|Toggle maintenance mode|
|`/api/admin/integrations`|GET|System integrations|
|`/api/admin/integrations/:id`|PUT|Update integration|
|`/api/admin/permissions`|GET|Permission matrix|
|`/api/admin/permissions`|PUT|Update permissions|

---

## Notes

- All endpoints require authentication unless otherwise specified
- All POST/PUT/DELETE endpoints return appropriate success/error responses
- Date formats follow ISO 8601 standard
- Pagination is implemented on list endpoints using `?page=` and `?limit=` query parameters
- Filtering is available on list endpoints using field-specific query parameters
- All file uploads use multipart/form-data encoding
- E-signature endpoints integrate with DocuSign or similar service
- Webhook notifications are available for critical state changes

---

**Total Endpoints:** ~250+ across all roles

**Last Updated:** 2026-07-18

