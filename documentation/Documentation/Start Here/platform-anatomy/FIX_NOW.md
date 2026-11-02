# Fix "Loading..." Credentials - Choose Your Method

The command-line script failed? No problem! Here are **4 easy alternatives**:

---

## ⭐ Method 1: Run in Your Browser (EASIEST!)

**No terminal, no commands, just click!**

1. Make sure Laragon is running with PostgreSQL started
2. Open your web browser
3. Go to: **`http://localhost/app/run-migration.php`**
4. Click the **"Run Migration Now"** button
5. Wait for "SUCCESS!" message
6. Done! ✅

---

## ⭐ Method 2: Use HeidiSQL (Also Easy!)

**Laragon comes with HeidiSQL - use the GUI!**

1. Open **Laragon**
2. Click **"Database"** button
3. HeidiSQL opens automatically
4. Click on **`archr`** database in left sidebar
5. Click **"Query"** tab at top
6. Click **"Load SQL file"** icon (folder icon)
7. Browse to: **`sql\add\system-users-username-fields.sql`**
8. Click **"Execute"** (play button) or press **F9**
9. Should say "Query OK"
10. Done! ✅

---

## ⭐ Method 3: Interactive Command (No Password Issues)

1. Double-click: **`run-migration-interactive.bat`**
2. It will ask you to press any key to continue
3. If prompted for password:
   - Try just pressing **Enter** (no password)
   - If that fails, try typing: **`password`**
   - If that fails, try: **`dumps-cassie-looks-trusts-nils-rubies`**
4. Done! ✅

---

## ⭐ Method 4: Copy/Paste in Laragon Terminal

1. Open **Laragon** → Click **"Terminal"**
2. Type: `psql -U postgres -d archr`
3. Press Enter (enter password if asked, or just press Enter)
4. **Copy and paste this whole block:**

```sql
ALTER TABLE system_users ADD COLUMN IF NOT EXISTS username VARCHAR(100) UNIQUE;
ALTER TABLE system_users ADD COLUMN IF NOT EXISTS first_name VARCHAR(100);
ALTER TABLE system_users ADD COLUMN IF NOT EXISTS last_name VARCHAR(100);
CREATE INDEX IF NOT EXISTS idx_system_users_username ON system_users(username);
UPDATE system_users SET username = LOWER(SPLIT_PART(email, '@', 1)) WHERE username IS NULL;
ALTER TABLE user_role_assignments DROP CONSTRAINT IF EXISTS user_role_assignments_user_id_organization_id_role_id_key;
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_role_org_unique ON user_role_assignments (user_id, role_id, organization_id) WHERE organization_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_role_null_org_unique ON user_role_assignments (user_id, role_id) WHERE organization_id IS NULL;
```

5. Press **Enter**
6. Type `\q` and press Enter to quit
7. Done! ✅

---

## 🎯 Recommended Order

1. **Try Method 1** (Browser) - Easiest, no password issues
2. **Try Method 2** (HeidiSQL) - Visual, no commands
3. **Try Method 3** (Interactive) - Handles passwords better
4. **Try Method 4** (Copy/Paste) - When all else fails

---

## ❓ Why Did the First Script Fail?

Most likely: **Password issue**

- Laragon's default PostgreSQL sometimes has no password
- Sometimes it's "password"
- Your config says: "dumps-cassie-looks-trusts-nils-rubies"
- The script couldn't figure out which one to use

**Solution:** Use Method 1 (browser) - it uses PHP's database connection which already works!

---

## ✅ How to Know It Worked

After running the migration:

1. **Submit the intake form**
2. **Look for:**
   - Alert shows username/password (not "Loading...")
   - Confirmation page shows actual credentials
   - File exists: `app/logs/account-credentials.log`

---

## 🆘 Still Not Working?

### If browser method (Method 1) shows an error:
- Read the error message - it tells you exactly what's wrong
- Common: "Database archr does not exist"
  - **Fix:** Create it first in HeidiSQL

### If HeidiSQL won't connect:
- Make sure PostgreSQL is running (Laragon should show green icon)
- Try: Laragon → Menu → PostgreSQL → Reload
- Try: Restart Laragon

### If you get "Table system_users does not exist":
- You need to run the base schema first
- In HeidiSQL: Load and execute `sql/role-based-access.sql`
- Then try the migration again

---

## 📁 Files Reference

- **`app/run-migration.php`** - Browser-based migration (Method 1)
- **`run-migration-interactive.bat`** - Interactive script (Method 3)
- **`sql/add/system-users-username-fields.sql`** - The SQL to run
- **`run-migration-gui.md`** - Detailed GUI instructions

---

## 🎯 TL;DR

**Open your browser, go to:**
```
http://localhost/app/run-migration.php
```

**Click "Run Migration Now"**

**Done! 🎉**
