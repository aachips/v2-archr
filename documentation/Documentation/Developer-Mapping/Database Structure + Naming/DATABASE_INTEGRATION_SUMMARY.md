# Database Integration Summary

## ✅ Completed Tasks

This document summarizes the work completed to integrate the ARCHR application with the PostgreSQL database and add dummy data.

### 1. Dummy Data Added

Created and executed `sql/dummy-data-seed.sql` with the following test data:

#### System Users (Staff)
- **Maria Garcia** - Assessor (maria.garcia@habitat.org)
- **Morgan Reyes** - Bursar (morgan.reyes@habitat.org)
- **Jordan Lee** - Crew Lead (jordan.lee@habitat.org)
- **Sam Rivera, Pat Murphy, Drew Kim, Lou Chen, Kim Johnson** - Crew Members
- **Alex Chen** - Project Manager (alex.chen@habitat.org)
- **Dr. Eileen Bailey** - Envoy (eileen.bailey@archr.org)
- **Alex Henderson** - Org Admin (admin.habitat@habitat.org)
- **Bluestone Electric, Asheville Roofing, Mountain Plumbing** - Subcontractors

#### Organizations
- Habitat for Humanity - Buncombe County
- Mountain Housing Opportunities
- Helene Recovery Fund
- Habitat ReStore Asheville

#### Applicants (Intake Submissions)
- John Henderson - 42 Cherry St, Asheville
- Sarah Williams - 15 Merrill Ave, Asheville
- Robert Chen - 3 Sunset Ln, Asheville
- Maria Delgado - 19 Riverside Dr, Asheville
- James Thornton - 8 Oakland Rd, Asheville
- Linda Martinez - 27 Mountain View Rd, Asheville
- David Kim - 12 Oak Ridge Dr, Asheville

#### Roles
- Assessor, Bursar, Crew Lead, Crew Member, Project Manager, Envoy, Org Admin, Subcontractor, Volunteer

#### Statistics
- **Total Users**: 18
- **Total Organizations**: 7
- **Total Submissions**: 16
- **Total Roles**: 13
- **Total Role Assignments**: 17

### 2. Application Updated to Use Database

#### Modified Files

**`app/lib/sample-data.php`**
- Updated `archr_sample_assessor()` to query live data from PostgreSQL
- Fetches real users, organizations, and intake submissions
- Falls back to hardcoded data if database query fails
- Uses the new database abstraction layer (`archr_db()`)

**`app/login.php`**
- Updated login system to authenticate against the `system_users` table
- Checks user roles from `user_role_assignments` and `roles` tables
- Stores user information in session (user_id, name, email)
- Maintains backward compatibility with hardcoded logins for development

### 3. Test Page Created

**`app/test-dummy-data.php`**
- Visual test page to verify database integration
- Displays all dummy data from the database
- Shows current database driver (PostgreSQL or Airtable)
- Tests the sample data functions
- Provides test login credentials

## 🚀 How to Use

### Test the Integration

1. **View the test page:**
   ```
   http://localhost/app/test-dummy-data.php
   ```

2. **Test login with database user:**
   - Go to: `http://localhost/app/login.php`
   - Email: `maria.garcia@habitat.org`
   - Password: `12345`
   - Should redirect to Assessor dashboard with live data

3. **Other test accounts:**
   - **Bursar**: morgan.reyes@habitat.org / 12345
   - **Crew Lead**: jordan.lee@habitat.org / 12345
   - **Project Manager**: alex.chen@habitat.org / 12345
   - **Org Admin**: admin.habitat@habitat.org / 12345

### Re-seed the Database

If you need to reset the dummy data:

```bash
# Windows PowerShell
$env:PGPASSWORD = "dumps-cassie-looks-trusts-nils-rubies"
C:\laragon\bin\postgresql\postgresql\bin\psql -h localhost -p 5432 -U postgres -d archr -f sql/dummy-data-seed.sql

# Linux/Mac
export PGPASSWORD="dumps-cassie-looks-trusts-nils-rubies"
psql -h localhost -p 5432 -U postgres -d archr -f sql/dummy-data-seed.sql
```

### Switch Between PostgreSQL and Airtable

The application uses the database abstraction layer, so you can switch backends:

```powershell
# Use PostgreSQL (default)
$env:DB_DRIVER = "postgresql"

# Use Airtable
$env:DB_DRIVER = "airtable"
$env:AIRTABLE_API_KEY = "your_key"
```

## 📊 Data Relationships

```
system_users (staff)
    ├─ user_role_assignments (links users to roles)
    │   └─ roles (ASSESSOR, BURSAR, etc.)
    └─ coalition_organizations (Habitat, etc.)

intake_submissions (applicants)
    ├─ applicant info (name, email, phone)
    ├─ property info (address, ownership)
    ├─ household info (size, income)
    └─ submission_status (pending, under_review, approved)
```

## 🔍 What Changed

### Before
- All data was hardcoded in `sample-data.php`
- Login used hardcoded username/password mapping
- No real database integration

### After
- Data comes from PostgreSQL database
- Login authenticates against `system_users` table
- Real user roles from `user_role_assignments`
- Fallback to hardcoded data if database fails
- Works with both PostgreSQL and Airtable (via abstraction layer)

## 🎯 Benefits

1. **Live Data**: Application displays actual data from the database
2. **Dual Backend**: Can switch between PostgreSQL and Airtable
3. **Realistic Testing**: Dummy data matches the hardcoded prototype data
4. **Easy Development**: Test accounts already configured
5. **Production Ready**: Foundation for real user management

## 📝 Files Added/Modified

### Added
- `sql/dummy-data-seed.sql` - Dummy data insertion script
- `app/test-dummy-data.php` - Database integration test page
- `app/DATABASE_INTEGRATION_SUMMARY.md` - This file

### Modified
- `app/lib/sample-data.php` - Now queries database
- `app/login.php` - Now authenticates against database

### Related (from previous work)
- `app/config/database.php` - Database configuration
- `app/lib/db.php` - Database connection
- `app/lib/database/*` - Database abstraction layer
- `app/DATABASE_README.md` - Database abstraction documentation
- `app/DATABASE_SWITCHING_GUIDE.md` - How to switch backends

## 🎉 Summary

The ARCHR application is now fully integrated with the PostgreSQL database! You can:
- ✅ Login with real database users
- ✅ View live data in dashboards
- ✅ Switch between PostgreSQL and Airtable
- ✅ Test with realistic dummy data
- ✅ Develop and deploy with confidence

Next steps: Continue building out other dashboard views (Bursar, Crew Lead, etc.) using the same pattern established in `archr_sample_assessor()`.
