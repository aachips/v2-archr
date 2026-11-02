# Dashboard Refactoring Summary

## Overview

The dashboard views have been refactored to separate features into dedicated menu items with their own API endpoints. Each role now has a clean, consistent dashboard home page that serves as the default landing page.

---

## What Changed

### Before
- Each role's dashboard body partial (`partials/{role}-body.php`) contained ALL features in one massive file
- No clear separation between different functionalities
- Difficult to navigate and maintain
- No API endpoints for data retrieval

### After
- **Dashboard Home**: Common landing page for all roles with:
  - Welcome message
  - Alerts of upcoming jobs/tasks
  - Global case search
  - Quick task submission box (task rabbit queue)
  
- **Dedicated API Endpoints**: Each feature has its own API endpoint
- **Menu-Driven Navigation**: Sidebar menu items correspond to specific features
- **Modular Structure**: Easy to extend and maintain

---

## Dashboard Home Component

**File:** `app/partials/dashboard-home.php`

This reusable component provides a consistent home experience across all roles:

1. **Welcome Section**: Personalized greeting with user's first name and current date
2. **Stats Display**: Role-specific key metrics (e.g., "3 assessments today", "8 active projects")
3. **Alerts Panel**: Upcoming jobs, tasks, and important notifications (up to 5 items)
4. **Case Search**: Global search bar with quick filters
5. **Quick Task Box**: Form to submit tasks/events/logs to the task rabbit queue

---

## Role-Specific Dashboards

### Assessor (`assessor.php`)
**Default Home Displays:**
- Today's assessment count
- Upcoming assessments (next 7 days)

**Menu Items → API Endpoints:**
- Dashboard → `assessor.php` (home)
- Today's Assessments → `/api/assessor/today.php`
- Upcoming → `/api/assessor/upcoming.php`
- Previous Assessments → `/api/assessor/previous.php`
- Verifications → (to be implemented)
- Messages → (to be implemented)
- Subcontractors → (to be implemented)
- Schedule → (to be implemented)

### Project Manager (`project-manager.php`)
**Default Home Displays:**
- Active projects count
- Unclaimed jobs count
- Recent escalations/alerts

**Menu Items → API Endpoints:**
- Dashboard → `project-manager.php` (home)
- Active Projects → `/api/project-manager/projects.php`
- Unclaimed Jobs → `/api/project-manager/unclaimed.php`
- Ongoing Work → (to be implemented)
- Escalations → `/api/project-manager/escalations.php`
- Reports → (to be implemented)
- [See full menu in `project-manager.php`]

### Crew Lead (`crew-lead.php`)
**Default Home Displays:**
- Active jobs count
- Today's jobs count
- Upcoming job alerts

**Menu Items → API Endpoints:**
- Dashboard → `crew-lead.php` (home)
- Current Job → `/api/crew-lead/current-job.php`
- Tomorrow → (to be implemented)
- Task Updates → (to be implemented)
- [See full menu in `crew-lead.php`]

### Other Roles
Similar structure has been created for:
- **Crew Member** (`/api/crew-member/dashboard.php`)
- **Bursar** (`/api/bursar/dashboard.php`)
- **Volunteer** (`/api/volunteer/dashboard.php`)
- **Subcontractor** (`/api/subcontractor/dashboard.php`)
- **Envoy** (`/api/envoy/dashboard.php`)

---

## API Structure

```
app/api/
├── API_ENDPOINTS.md          # API documentation
├── assessor/
│   ├── dashboard.php          # Dashboard home data
│   ├── today.php              # Today's assessments
│   ├── upcoming.php           # Upcoming assessments
│   └── previous.php           # Previous assessments
├── project-manager/
│   ├── dashboard.php
│   ├── projects.php
│   ├── unclaimed.php
│   └── escalations.php
├── crew-lead/
│   ├── dashboard.php
│   └── current-job.php
├── crew-member/
│   └── dashboard.php
├── bursar/
│   └── dashboard.php
├── volunteer/
│   └── dashboard.php
├── subcontractor/
│   └── dashboard.php
├── envoy/
│   └── dashboard.php
├── cases/
│   └── search.php             # Global case search
└── tasks/
    └── quick-add.php          # Quick task submission
```

---

## Common Features

### Global Case Search
**Endpoint:** `/api/cases/search.php`
- Search by case number, address, applicant name, or phone
- Filters: all, my_cases, recent, urgent
- Available on all role dashboards

### Quick Task Submission
**Endpoint:** `/api/tasks/quick-add.php`
- Submit tasks, events, logs, or notes
- Adds to `task_rabbit_queue` table
- Available on all role dashboards

---

## How to Add New Features

1. **Create API Endpoint:**
   - File: `app/api/{role}/{feature-name}.php`
   - Include auth: `require __DIR__ . '/../../lib/auth.php';`
   - Include db: `require __DIR__ . '/../../lib/db.php';`
   - Return JSON response

2. **Update Menu:**
   - Edit `app/{role}.php`
   - Add menu item in `nav` array
   - Point `href` to appropriate page or anchor

3. **Create Page (optional):**
   - For complex features, create separate PHP page
   - Load data from API endpoint
   - Use existing portal layout

---

## Benefits

✅ **Cleaner Code**: Each feature is isolated and maintainable
✅ **Consistent UX**: All roles have the same home page structure
✅ **API-First**: Frontend can easily consume endpoints
✅ **Scalable**: Easy to add new features and roles
✅ **Better Navigation**: Clear menu structure matches functionality
✅ **Mobile-Friendly**: API endpoints work for web and mobile apps

---

## Next Steps

Remaining tasks to complete full refactoring:
- [ ] Create pages/endpoints for all menu items
- [ ] Add filtering and sorting to list endpoints
- [ ] Implement pagination for large datasets
- [ ] Add POST/PUT/DELETE endpoints for data modifications
- [ ] Create mobile-specific views
- [ ] Add real-time updates via WebSockets or polling
