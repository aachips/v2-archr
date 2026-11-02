# Quick Start: Fix "Loading..." Credentials

## The Problem
When you submit the intake form, the credentials show "Loading..." forever instead of showing the username and password.

## The Solution
Run a database migration to add missing columns.

---

## Windows/Laragon Users - Do This:

### Method 1: Double-Click (Easiest!)
1. Find the file **`run-migration.bat`** in this folder
2. **Double-click it**
3. Wait for "SUCCESS!" message
4. Done! Try the form again

### Method 2: Laragon Terminal
1. Open **Laragon**
2. Click **"Terminal"** button
3. Run this command:
   ```
   psql -U postgres -d archr -f sql/add/system-users-username-fields.sql
   ```
4. Done!

### Method 3: Copy/Paste SQL
1. Open **Laragon** → **Database** → HeidiSQL or pgAdmin
2. Open the file: `sql/add/system-users-username-fields.sql`
3. **Execute** the SQL
4. Done!

---

## What This Does

Adds 3 missing columns to the database:
- `username` - for login
- `first_name` - user's first name
- `last_name` - user's last name

Without these, account creation fails and you see "Loading..." forever.

---

## After Running

1. **Submit the intake form** again
2. **Credentials should display** (not "Loading...")
3. **You'll see:**
   - Alert popup with username/password
   - Credentials box with actual credentials
   - Logs created with account info

---

## Need More Help?

See **`HOW_TO_RUN_MIGRATION.md`** for:
- 5 different ways to run the migration
- Troubleshooting steps
- Screenshots and detailed instructions
- What to do if it doesn't work

---

## Files Created For You

- **`run-migration.bat`** - Windows batch script (double-click to run)
- **`run-migration.ps1`** - PowerShell script
- **`sql/add/system-users-username-fields.sql`** - The migration SQL
- **`HOW_TO_RUN_MIGRATION.md`** - Detailed instructions
- **`CREDENTIALS_LOADING_FIX.md`** - Technical explanation

---

## Summary

**Quick Fix:** Double-click `run-migration.bat`  
**Result:** Credentials will display properly  
**Time:** Less than 1 minute
