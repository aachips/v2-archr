# ARCHR Login System - Implementation Summary

## Overview
The ARCHR app has been updated with a simple login portal system that allows users to authenticate as different roles before accessing their respective dashboards.

## Changes Made

### 1. New Files Created

#### `app/login.php`
- Login portal page with role-based authentication
- **Username**: Any role name (case-insensitive)
- **Password**: `12345` for all accounts
- Displays all available roles with instructions
- Redirects authenticated users to their appropriate dashboard

#### `app/logout.php`
- Simple logout handler
- Destroys session and redirects to login page

#### `app/lib/auth.php`
- Authentication helper functions:
  - `archr_require_auth()` - Protects pages that require login
  - `archr_get_current_role()` - Gets current user's role
  - `archr_get_current_role_display()` - Gets role display name
  - `archr_is_authenticated()` - Checks if user is logged in

### 2. Updated Files

#### All Portal Pages (Protected with Authentication)
The following pages now require login:
- `app/assessor.php`
- `app/bursar.php`
- `app/crew-lead.php`
- `app/crew-member.php`
- `app/subcontractor.php`
- `app/envoy.php`
- `app/project-manager.php`
- `app/requestor-portal.php`
- `app/volunteer.php`
- `app/org-admin.php`
- `app/tle-poc.php`

Each file now includes:
```php
require __DIR__ . '/lib/auth.php';
archr_require_auth();
```

#### `app/lib/portal-layout.php`
**Key Changes:**
1. **Replaced redundant h1 title with ARCHR logo wordmark**
   - Changed from: `<h1 class="portal-page-title"><?= e($pageTitle) ?></h1>`
   - Changed to: Logo + "ARCHR" text (clickable, links to home)
   
2. **Added logout button in topbar**
   - Positioned in top-right corner next to avatar
   - Icon + "Logout" text
   - Links to `logout.php`

#### `app/index.php`
1. Added authentication check
2. Shows logout button when authenticated
3. Updated "Role portals" section:
   - Shows "Log In to Access Dashboards" button when not authenticated
   - Links to login page instead of direct dashboard access when not logged in

#### `app/lib/layout.php`
1. Added session check
2. Changed "Admin queue" label to "Review queue"
3. Dynamically shows Login/Logout link in navigation based on auth status

## Available Demo Accounts

All accounts use the password: **12345**

### Available Roles (usernames):
- `assessor` - Field assessments, verifications, schedule
- `bursar` - Funding queue, reimbursements, audit
- `crew-lead` or `crew lead` - On-site task updates, daily logs
- `crew-member` or `crew member` - Today's tasks, photo upload, hours
- `subcontractor` - Bids, work orders, invoices
- `envoy` - Applicant outreach + intake support
- `project-manager` or `project manager` - Pipeline, schedule, reports
- `requestor` - Applicant-facing private dashboard
- `volunteer` - Shifts, opportunities, hours log
- `org-admin`, `org admin`, or `admin` - Org-level admin tasks
- `tle-poc` - Tasks, Logs & Events POC

## Navigation Structure

### Main Navigation (Top Bar)
**Unauthenticated Users See:**
- Home
- Start Intake
- Log In

**Authenticated Users See:**
- Home
- Start Intake
- Logout

### Home Page (index.php)
**Unauthenticated:**
- Two prominent buttons: "Start Intake Form" and "Log In to Dashboard"
- Role portal cards link to login page
- "Log In to Access Dashboards" button before portal list

**Authenticated:**
- Two prominent buttons: "Start Intake Form" and "Logout"
- Role portal cards link directly to dashboards

## User Flow

1. **Unauthenticated User**:
   - Visits any portal page → Redirected to `login.php`
   - Visits `index.php` → Can see portal list but links go to login
   - Navigation shows: Home | Start Intake | Log In

2. **Login Process**:
   - User enters role name and password "12345"
   - On success: Session created, redirected to role dashboard
   - On failure: Error message displayed

3. **Authenticated User**:
   - Can access any portal page directly
   - Sees logout button in portal topbars
   - Navigation shows: Home | Start Intake | Logout
   - Home page shows logout button

4. **Logout Process**:
   - Click logout → Session destroyed → Redirected to login page

## UI Improvements

### Portal Dashboard Headers
**Before:**
```
[Menu Icon] [Assessor Dashboard h1]    [Assessor badge] [Theme] [Avatar]
```

**After:**
```
[Menu Icon] [🏠 ARCHR logo]    [Assessor badge] [Theme] [Avatar] [Logout]
```

**Benefits:**
- Removed redundant "Assessor Dashboard" text when "Assessor" badge already visible
- Logo provides branding and navigation (clickable to home)
- Cleaner, more professional appearance
- Better use of horizontal space

## Security Notes

⚠️ **This is a demo/placeholder authentication system**:
- No actual password hashing
- No user database
- Simple session-based auth
- Same password for all accounts
- Suitable for prototyping and demos only

For production use, implement:
- Proper password hashing (bcrypt/argon2)
- Database-backed user accounts
- CSRF protection
- Proper session management
- Rate limiting on login attempts
