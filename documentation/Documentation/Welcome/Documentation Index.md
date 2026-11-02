# ARCHR Application - Documentation Index

## 🎯 Dashboard Refactoring

The dashboard system has been completely refactored with a new API-first architecture. **Start here:**

### 📖 Quick Start Guide
**[README_DASHBOARD.md](README_DASHBOARD.md)** - Main readme for users and developers

### 📋 Complete Overview
**[DASHBOARD_REFACTORING_SUMMARY.md](DASHBOARD_REFACTORING_SUMMARY.md)** - Complete summary of all changes

### 🏗️ Architecture
**[DASHBOARD_ARCHITECTURE.md](DASHBOARD_ARCHITECTURE.md)** - Visual diagrams and architecture overview

### 👨‍💻 Developer Guide
**[DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md)** - How to add new features and endpoints

### 📚 Technical Details
**[DASHBOARD_REFACTORING.md](DASHBOARD_REFACTORING.md)** - Detailed technical documentation

### 🧪 Testing
**[TESTING_CHECKLIST.md](TESTING_CHECKLIST.md)** - Comprehensive testing checklist

### 🔌 API Documentation
**[api/API_ENDPOINTS.md](api/API_ENDPOINTS.md)** - API endpoint reference

---

## 📂 Directory Structure

```
app/
├── *.php                          # Role dashboard files
├── partials/
│   └── dashboard-home.php         # Common dashboard home component
├── api/
│   ├── {role}/                    # Role-specific endpoints
│   │   ├── dashboard.php          # Dashboard home data
│   │   └── {feature}.php          # Feature endpoints
│   ├── cases/
│   │   └── search.php             # Global case search
│   └── tasks/
│       └── quick-add.php          # Quick task submission
├── lib/
│   ├── auth.php                   # Authentication
│   ├── db.php                     # Database connection
│   └── portal-layout.php          # Portal layout
└── assets/
    ├── portal.css                 # Portal styles
    └── role-*.css                 # Role-specific styles
```

---

## 🚀 What's New

### Dashboard Home (Default Landing Page)
Every role now has a standardized home page with:
- ✅ Welcome message with personalized greeting
- ✅ Alerts panel (upcoming jobs and notifications)
- ✅ Global case search
- ✅ Quick task submission box

### API-First Architecture
All features are now backed by API endpoints:
- ✅ RESTful JSON APIs
- ✅ Organized by role
- ✅ Consistent response format
- ✅ Works for web and mobile

### Refactored Roles
- ✅ Assessor
- ✅ Project Manager
- ✅ Crew Lead
- ✅ Crew Member
- ✅ Bursar
- ✅ Volunteer
- ✅ Subcontractor
- ✅ Envoy

---

## 📖 Documentation Reading Order

**For Users:**
1. [README_DASHBOARD.md](README_DASHBOARD.md)

**For Developers (New Features):**
1. [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md)
2. [api/API_ENDPOINTS.md](api/API_ENDPOINTS.md)

**For Understanding the System:**
1. [DASHBOARD_REFACTORING_SUMMARY.md](DASHBOARD_REFACTORING_SUMMARY.md)
2. [DASHBOARD_ARCHITECTURE.md](DASHBOARD_ARCHITECTURE.md)
3. [DASHBOARD_REFACTORING.md](DASHBOARD_REFACTORING.md)

**For Testing:**
1. [TESTING_CHECKLIST.md](TESTING_CHECKLIST.md)

---

## 🔧 Quick Reference

### Key Files
- **Dashboard Home:** `partials/dashboard-home.php`
- **Role Dashboards:** `{role}.php`
- **API Endpoints:** `api/{role}/*.php`

### Common Endpoints
- Case Search: `GET /api/cases/search.php`
- Quick Task: `POST /api/tasks/quick-add.php`

### Database
- Connection: `lib/db.php` → `archr_pdo()`
- Key tables: `system_users`, `cases`, `intake_submissions`, `task_rabbit_queue`

---

## 📝 Other Documentation

**Login System:**
- [LOGIN_SYSTEM_README.md](secrets/worklogs/LOGIN_SYSTEM_README.md) - Login and authentication

**Change History:**
- [CHANGES_SUMMARY.md](secrets/worklogs/CHANGES_SUMMARY.md) - Summary of previous changes

---

## ✅ Status

**Dashboard Refactoring:** ✅ Complete  
**API Endpoints:** ✅ Core endpoints created  
**Documentation:** ✅ Complete  
**Testing:** ⏳ Ready for testing

---

**Last Updated:** December 2024  
**Version:** 2.0 (Dashboard Refactoring)
