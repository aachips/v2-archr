# How to Run the Database Migration (Windows/Laragon)

The credentials are showing "Loading..." because the database is missing some columns. Here's how to fix it:

---

## Option 1: Double-Click the Script (EASIEST)

### For Batch Script:
1. Find `run-migration.bat` in your project folder
2. **Double-click it**
3. You'll see a window that runs the migration
4. Wait for "SUCCESS!" message
5. Press any key to close
6. Done! Try submitting the form again

### For PowerShell:
1. Find `run-migration.ps1` in your project folder
2. **Right-click** → **Run with PowerShell**
3. If you get "execution policy" error, see Option 2
4. Wait for "SUCCESS!" message
5. Press any key to close
6. Done!

---

## Option 2: In PowerShell

1. **Open PowerShell** (not regular Command Prompt)
   - Right-click Start menu → PowerShell or Windows Terminal

2. **Navigate to your project:**
   ```powershell
   cd "C:\Users\phill\.augment\worktrees\daemon\c5074f0e9518\agent-01KXTSZMJ9V2FD7EWGPH08XA76"
   ```

3. **Run the script:**
   ```powershell
   .\run-migration.ps1
   ```

4. **If you get "execution policy" error:**
   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   .\run-migration.ps1
   ```

---

## Option 3: In Laragon Terminal (RECOMMENDED)

1. **Open Laragon**
2. **Click "Terminal"** button (or Menu → Terminal)
3. **Navigate to your project:**
   ```bash
   cd /c/Users/phill/.augment/worktrees/daemon/c5074f0e9518/agent-01KXTSZMJ9V2FD7EWGPH08XA76
   ```

4. **Run the migration:**
   ```bash
   psql -U postgres -d archr -f sql/add/system-users-username-fields.sql
   ```

5. **If asked for password:** 
   - Try pressing Enter (no password)
   - Or try: `dumps-cassie-looks-trusts-nils-rubies`

---

## Option 4: In Laragon's PostgreSQL GUI (HeidiSQL or pgAdmin)

### Using HeidiSQL (if installed):
1. Open Laragon → Click "Database"
2. Connect to PostgreSQL
3. Select database: `archr`
4. Click "Query" tab
5. **Copy and paste** the contents of `sql/add/system-users-username-fields.sql`
6. Click "Execute" (F9)
7. Done!

### Using pgAdmin:
1. Open pgAdmin (comes with Laragon)
2. Connect to local PostgreSQL server
3. Navigate to: Servers → PostgreSQL → Databases → archr
4. Right-click archr → Query Tool
5. Open file: `sql/add/system-users-username-fields.sql`
6. Click Execute (F5)
7. Done!

---

## Option 5: Manual SQL Copy/Paste

If nothing else works:

1. **Open Laragon Terminal** (or Command Prompt)
2. **Connect to PostgreSQL:**
   ```bash
   cd C:\laragon\bin\postgresql\postgresql\bin
   psql.exe -U postgres -d archr
   ```

3. **You should see:** `archr=#`

4. **Copy the SQL below and paste it:**

```sql
-- Add missing username, first_name, and last_name fields to system_users
-- Required for account creation from intake submissions

-- Add username column (unique identifier for login)
ALTER TABLE system_users 
ADD COLUMN IF NOT EXISTS username VARCHAR(100) UNIQUE;

-- Add first_name and last_name columns
ALTER TABLE system_users 
ADD COLUMN IF NOT EXISTS first_name VARCHAR(100);

ALTER TABLE system_users 
ADD COLUMN IF NOT EXISTS last_name VARCHAR(100);

-- Create index on username for fast lookups
CREATE INDEX IF NOT EXISTS idx_system_users_username ON system_users(username);

-- Update existing records to have usernames if they don't
-- (using email prefix as username for existing users)
UPDATE system_users 
SET username = LOWER(SPLIT_PART(email, '@', 1))
WHERE username IS NULL;

-- Fix user_role_assignments to allow NULL organization_id for requestors
-- Drop the old unique constraint that includes organization_id
ALTER TABLE user_role_assignments 
DROP CONSTRAINT IF EXISTS user_role_assignments_user_id_organization_id_role_id_key;

-- Add a new unique constraint that handles NULLs properly
-- Multiple users can have the same role with NULL organization
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_role_org_unique
ON user_role_assignments (user_id, role_id, organization_id)
WHERE organization_id IS NOT NULL;

-- For NULL organization_id, only one role per user (for requestors)
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_role_null_org_unique
ON user_role_assignments (user_id, role_id)
WHERE organization_id IS NULL;
```

5. **Press Enter** to execute
6. **Type:** `\q` and press Enter to quit
7. Done!

---

## Verify It Worked

After running the migration, check if the columns were added:

### In Laragon Terminal:
```bash
psql -U postgres -d archr -c "\d system_users"
```

**Look for these columns:**
- `username`
- `first_name`
- `last_name`

If you see them, SUCCESS! ✅

---

## Troubleshooting

### "psql: command not found"
- Laragon's terminal should have psql in PATH
- Try full path: `C:\laragon\bin\postgresql\postgresql\bin\psql.exe`

### "password authentication failed"
- Default Laragon password is usually empty (just press Enter)
- Or try: `dumps-cassie-looks-trusts-nils-rubies`

### "database 'archr' does not exist"
- Create it first:
  ```sql
  psql -U postgres -c "CREATE DATABASE archr;"
  ```
- Then run the intake.sql schema first

### "relation 'system_users' does not exist"
- You need to run the base schema first:
  ```bash
  psql -U postgres -d archr -f sql/role-based-access.sql
  ```

---

## After Migration

1. **Submit the intake form** again
2. **Credentials should now display** (not "Loading...")
3. **Check the logs:**
   - `app/logs/account-credentials.log` should exist
   - Should show: Username and Password

---

## Still Not Working?

If credentials still show "Loading..." after migration:

1. **Check browser console** (F12)
   - Look for: "Credentials object: {username: ..., password: ...}"
   - If still null, check next step

2. **Check account creation log:**
   - Look at: `app/logs/account-credentials.log`
   - If file doesn't exist, account creation is still failing

3. **Check PHP error log:**
   - Laragon: `C:\laragon\logs\php_error.log`
   - Look for database errors

4. **Contact for help** - provide:
   - Browser console output
   - `app/logs/account-credentials.log` contents (if exists)
   - Any error messages from migration

---

## Summary

**Easiest:** Double-click `run-migration.bat`  
**Alternative:** Open Laragon Terminal, run psql command  
**Verify:** Check that username/first_name/last_name columns exist  
**Test:** Submit form, credentials should display!
