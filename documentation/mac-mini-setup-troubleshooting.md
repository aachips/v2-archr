# Mac Mini Server Setup — Troubleshooting Checklist

> Date: November 4, 2026
> Server: Mac Mini (macOS, Homebrew PostgreSQL@18, PHP 8.5.11)
> Purpose: ARCHR v2-archr office server at `localhost:3000`

---

## 1. Duplicate PostgreSQL Instances

**Problem:** Two PostgreSQL installations (Homebrew + Postgres.app) caused conflicting databases (`archr` vs `archrmac`) and authentication failures.

**Fix:**
- Identified Homebrew PostgreSQL@18 was the active one (port 5432)
- Removed Postgres.app: `rm -rf /Applications/Postgres.app`
- Cleaned up leftover data: `rm -rf ~/Library/Application\ Support/Postgres`

## 2. Database Name and User Mismatch

**Problem:** PHP config expected database `archr` with user `postgres`, but macOS PostgreSQL defaults to creating a database named after the macOS user (`archrmac`).

**Fix:**
- Confirmed Homebrew PostgreSQL was running: `brew services list | grep postgresql`
- Connected to the correct database: `psql -d archr` (database was already named `archr` from a prior setup)
- Updated `app/secure_config/archr_connect.php` with correct credentials: `PGDATABASE=archr`, `PGUSER=archrmac`

## 3. No Users in Database / Password Hash Mismatch

**Problem:** Database had tables but no user data, or password hashes were truncated/corrupted.

**Fix:**
- Exported database from Windows (Laragon PostgreSQL 17):
  ```cmd
  "C:\laragon\bin\postgresql\postgresql\bin\pg_dump.exe" -U postgres -d archr --no-owner --no-privileges --clean --if-exists -f C:\laragon\www\v2-archr\archr-export.sql
  ```
- Transferred via SCP:
  ```cmd
  scp C:\laragon\www\v2-archr\archr-export.sql archrmac@archrmac:/Users/archrmac/Desktop/
  ```
- Imported on Mac Mini:
  ```bash
  psql -d postgres -c "DROP DATABASE IF EXISTS archr;"
  psql -d postgres -c "CREATE DATABASE archr;"
  psql -d archr -f /Users/archrmac/Desktop/archr-export.sql
  ```
- Alternatively, reset passwords via PHP:
  ```bash
  HASH=$(php -r "echo password_hash('HopeBuilder26', PASSWORD_BCRYPT);")
  php -r "\$pdo = new PDO('pgsql:host=localhost;dbname=archr', 'archrmac', ''); \$pdo->prepare('UPDATE system_users SET password_hash = ? WHERE username = ?')->execute(['$HASH', 'admin']);"
  ```

## 4. Vue App Never Built

**Problem:** `vue-view/dist/` directory didn't exist (gitignored). The Mac Mini never ran `npm install` or `npm run build`.

**Fix:**
```bash
cd /Users/archrmac/Desktop/v2-archr/vue-view
npm install
npm run build
rm -rf ../portal/*
cp -r dist/* ../portal/
```

## 5. vue.config.js Corrupted by curl Garbage

**Problem:** Accidental curl command saved HTTP request headers as files in `vue-view/` (`Accept:`, `Content-Length:`, `POST`, etc.). The `vue.config.js` had `devServer` nested inside `pages`, causing build error: `"pages.devServer.entry" is required`.

**Fix:**
- Cleaned up garbage files: `rm -f "Accept:" "Content-Length:" "Content-Type:" "Host:" "POST" "User-Agent:"`
- Restored correct `vue.config.js` from git: `git checkout vue.config.js`
- Or recreated it with correct structure (`devServer` at top level, not nested in `pages`)

## 6. Git Repository Corrupted / Rebase Stuck

**Problem:** Git was in a stuck rebase state (`interactive rebase in progress`), preventing normal operations. `git status` showed conflicts.

**Fix:**
```bash
git rebase --abort
```

## 7. PHP Dev Server — 404 on Root

**Problem:** `php -S localhost:3000` was started from the home directory (`~`) instead of the repo root. PHP serves from the working directory.

**Fix:**
```bash
cd /Users/archrmac/Desktop/v2-archr
php -S localhost:3000
```

## 8. PHP Dev Server — Wrong MIME Types for CSS/JS (Blank White Portal Page)

**Problem:** PHP's built-in server serves unknown file types as `text/html`, causing browsers to reject CSS/JS files. Console errors: "Did not parse stylesheet... because non CSS MIME types" and "SyntaxError: Unexpected token '<'" for JS.

**Fix:** Created `router.php` at repo root:
```php
<?php
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Serve PHP files in app/ directory directly (API endpoints)
if (strpos($uri, '/app/') === 0) {
    $file = __DIR__ . $uri;
    if (file_exists($file) && pathinfo($file, PATHINFO_EXTENSION) === 'php') {
        include $file;
        exit;
    }
}

// MIME types for static files
$mimeTypes = [
    '.css' => 'text/css',
    '.js'  => 'application/javascript',
    '.png' => 'image/png',
    '.jpg' => 'image/jpeg',
    '.svg' => 'image/svg+xml',
    '.ico' => 'image/x-icon',
    '.woff' => 'font/woff',
    '.woff2' => 'font/woff2',
    '.html' => 'text/html',
];

$ext = pathinfo($uri, PATHINFO_EXTENSION);
if ($ext && isset($mimeTypes['.' . $ext])) {
    $file = __DIR__ . $uri;
    if (file_exists($file)) {
        header('Content-Type: ' . $mimeTypes['.' . $ext]);
        readfile($file);
        exit;
    }
}

// Handle directory index
if (is_dir(__DIR__ . $uri)) {
    $indexFile = __DIR__ . $uri . 'index.html';
    if (file_exists($indexFile)) {
        header('Content-Type: text/html');
        readfile($indexFile);
        exit;
    }
    $portalFile = __DIR__ . $uri . 'portal.html';
    if (file_exists($portalFile)) {
        header('Content-Type: text/html');
        readfile($portalFile);
        exit;
    }
}

// Fall through to index.php
include __DIR__ . '/index.php';
```

Start server with: `php -S localhost:3000 router.php`

## 9. PHP Dev Server — Auth API Returned HTML Instead of JSON

**Problem:** The router.php fell through to `include index.php` for `/app/vue_api/auth.php` requests, returning the public website HTML instead of the API response. Login failed with "String did not match the expected pattern."

**Fix:** Added `/app/` path handling in `router.php` to serve PHP files directly (see item 8 above).

## 10. Safari "String Did Not Match Expected Pattern" Error

**Problem:** Safari HTML5 form validation error on login. Was caused by the auth API returning HTML (item 9), not an actual form validation issue.

**Fix:** Resolved by fixing router.php to serve API endpoints correctly (item 9).

## 11. PostgreSQL Trust Authentication Failure

**Problem:** `psql` command failed with "Postgres.app failed to verify trust authentication" when trying to update password hashes.

**Fix:** Used PHP PDO instead of `psql` for database updates (PHP connects via TCP, not Unix socket):
```bash
php -r "\$pdo = new PDO('pgsql:host=localhost;dbname=archr', 'archrmac', ''); \$pdo->exec('UPDATE system_users SET password_hash = ...');"
```

## 12. Repo Clone Missing Files

**Problem:** `vue.config.js` appeared missing from Mac Mini clone. Git showed `error: pathspec 'vue.config.js' did not match any file(s) known to git`.

**Root cause:** Previous clone was corrupted by curl garbage files and a stuck rebase.

**Fix:** Fresh clone resolved everything:
```bash
cd /Users/archrmac/Desktop
rm -rf v2-archr
git clone <repo-url> v2-archr
```

---

## Quick Start Commands (After Fresh Clone)

```bash
# 1. Install and build Vue app
cd /Users/archrmac/Desktop/v2-archr/vue-view
npm install
npm run build
rm -rf ../portal/*
cp -r dist/* ../portal/

# 2. Import database
psql -d postgres -c "DROP DATABASE IF EXISTS archr;"
psql -d postgres -c "CREATE DATABASE archr;"
psql -d archr -f /Users/archrmac/Desktop/archr-export.sql

# 3. Start server
cd /Users/archrmac/Desktop/v2-archr
kill $(lsof -ti :3000) 2>/dev/null
php -S localhost:3000 router.php
```

**Access URLs:**
- Homepage: `http://localhost:3000/`
- Portal: `http://localhost:3000/portal/portal.html`
- Documentation: `http://localhost:3000/help.php`
- Component Library: `http://localhost:3000/component-library.php`
