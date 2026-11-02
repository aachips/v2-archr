# ARCHR Dashboard System - README

## 📖 Overview

The ARCHR dashboard system has been completely refactored to provide a clean, consistent, and maintainable structure across all user roles. Each dashboard now features a standardized home page that serves as the default landing page when users log in.

---

## 🚀 Quick Start

### For Users

When you log into the ARCHR system:

1. **Default Landing Page**: You'll see the dashboard home with:
   - A personalized welcome message
   - Key statistics relevant to your role
   - Alerts about upcoming jobs and tasks
   - A case search bar
   - A quick task submission box

2. **Navigation**: Use the sidebar menu to access specific features:
   - Dashboard (home)
   - Role-specific tools and views
   - Reports and analytics
   - Communication tools

3. **Case Search**: Use the search bar on the home page to quickly find cases by:
   - Case number
   - Address
   - Applicant name
   - Phone number

4. **Quick Tasks**: Submit tasks, events, logs, or notes directly from the home page using the Quick Task box.

### For Developers

**Read These First:**
1. `DASHBOARD_REFACTORING_SUMMARY.md` - Complete overview of the changes
2. `DEVELOPER_GUIDE.md` - How to create new features and endpoints
3. `API_ENDPOINTS.md` - API documentation
4. `DASHBOARD_ARCHITECTURE.md` - Visual architecture diagrams

**File Locations:**
- Role dashboards: `app/{role}.php`
- Dashboard home component: `app/partials/dashboard-home.php`
- API endpoints: `app/api/{role}/`
- Common endpoints: `app/api/cases/`, `app/api/tasks/`

---

## 📂 Key Files & Directories

```
app/
├── assessor.php              # Assessor dashboard
├── project-manager.php       # Project Manager dashboard
├── crew-lead.php             # Crew Lead dashboard
├── crew-member.php           # Crew Member dashboard
├── bursar.php                # Bursar dashboard
├── volunteer.php             # Volunteer dashboard
├── subcontractor.php         # Subcontractor dashboard
├── envoy.php                 # Envoy dashboard
│
├── partials/
│   └── dashboard-home.php    # Common dashboard home component
│
├── api/
│   ├── API_ENDPOINTS.md      # API documentation
│   ├── {role}/               # Role-specific endpoints
│   ├── cases/search.php      # Global case search
│   └── tasks/quick-add.php   # Quick task submission
│
├── DASHBOARD_REFACTORING.md  # Refactoring overview
├── DEVELOPER_GUIDE.md        # Developer documentation
└── lib/
    ├── auth.php              # Authentication
    ├── db.php                # Database connection
    └── portal-layout.php     # Portal layout components
```

**Documentation Files (project root):**
- `DASHBOARD_REFACTORING_SUMMARY.md` - Complete summary
- `DASHBOARD_ARCHITECTURE.md` - Architecture diagrams
- `README_DASHBOARD.md` - This file

---

## 🎯 Features

### Dashboard Home (All Roles)

Every role dashboard includes:

1. **Welcome Section**
   - Personalized greeting with user's first name
   - Current date and role display
   - Primary statistics (varies by role)

2. **Alerts Panel**
   - Upcoming jobs and assignments
   - Important notifications
   - System alerts
   - Limited to 5 most relevant items

3. **Case Search**
   - Global search across all cases
   - Quick filter buttons
   - Real-time search results

4. **Quick Task Box**
   - Submit tasks, events, logs, or notes
   - Instant feedback
   - Adds to task rabbit queue for processing

### Role-Specific Features

Each role has menu items that correspond to specific features:

**Assessor:**
- Today's Assessments
- Upcoming Assessments
- Previous Assessments
- Document Verifications
- Schedule Management

**Project Manager:**
- Active Projects
- Unclaimed Jobs
- Escalations & Risks
- Budget & Estimates
- Crew & Team Management

**Crew Lead:**
- Current Job Details
- Task Updates
- Daily Logs
- Safety Talks
- Completion Sign-offs

*(See individual role documentation for complete feature lists)*

---

## 🔌 API Endpoints

All data is served through RESTful API endpoints:

### Common Endpoints

- `GET /api/cases/search.php` - Search cases
- `POST /api/tasks/quick-add.php` - Add quick task

### Role-Specific Endpoints

- `/api/{role}/dashboard.php` - Dashboard home data
- `/api/{role}/{feature}.php` - Feature-specific data

**Example:**
```bash
# Get assessor dashboard data
curl http://localhost/api/assessor/dashboard.php

# Search for a case
curl "http://localhost/api/cases/search.php?q=42-CHERRY"

# Submit a quick task
curl -X POST http://localhost/api/tasks/quick-add.php \
  -d "task_type=task" \
  -d "task_text=Follow up with client"
```

See `app/api/API_ENDPOINTS.md` for complete documentation.

---

## 🛠️ Development

### Adding a New Feature

1. Create API endpoint: `app/api/{role}/{feature}.php`
2. Add menu item in `app/{role}.php`
3. (Optional) Create dedicated page for complex features

See `DEVELOPER_GUIDE.md` for detailed instructions.

### Database

All endpoints use the `archr_pdo()` function from `lib/db.php`.

Key tables:
- `system_users` - User accounts
- `intake_submissions` - Applications
- `cases` - Case management
- `task_rabbit_queue` - Quick tasks
- *(Many more - see schema documentation)*

---

## 🧪 Testing

To test the system:

1. Log in as a user with a specific role
2. Verify the dashboard home page loads
3. Check that stats and alerts display correctly
4. Test the case search functionality
5. Submit a quick task and verify it's added to the queue
6. Navigate through menu items

---

## 📚 Additional Documentation

- **`DASHBOARD_REFACTORING_SUMMARY.md`** - Complete refactoring overview
- **`DASHBOARD_ARCHITECTURE.md`** - Visual architecture diagrams
- **`app/DASHBOARD_REFACTORING.md`** - Detailed technical documentation
- **`app/DEVELOPER_GUIDE.md`** - Developer guide with examples
- **`app/api/API_ENDPOINTS.md`** - API endpoint reference

---

## ✅ Status

**Current Status:** ✅ Complete

All major roles have been refactored with:
- Standardized dashboard home pages
- API endpoints for key features
- Common components (case search, quick tasks)
- Comprehensive documentation

---

## 🤝 Contributing

When adding new features:
1. Follow the established patterns
2. Use the API-first approach
3. Update documentation
4. Test thoroughly
5. Keep code clean and commented

---

## 📞 Support

For questions or issues:
1. Check the documentation files listed above
2. Review existing API endpoints for patterns
3. Consult the DEVELOPER_GUIDE.md for examples

---

**Last Updated:** December 2024  
**Version:** 2.0 (Dashboard Refactoring Complete)
