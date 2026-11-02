## Root cause

The 403 comes from `archr_require_org_admin()` (`app/lib/org-admin.php:52`), which checks the **database** for an active ADMIN/ORG_ADMIN role assignment keyed by `$_SESSION['archr_user_id']`. If that session value is missing, the user id reads as 0 → access level 0 → Forbidden.

Now look at the legacy prototype login fallback in `login.php` (lines 128–133) — username = role name (e.g. `org-admin` or `admin`), password `12345`:

```
if (!$authenticated && $password === '12345' && isset($legacy_roles[$userLower])) {
    $role_code = $legacy_roles[$userLower];
    $authenticated = true;
    $_SESSION['archr_user_name'] = ucwords(str_replace('-', ' ', $username));
}
```

It sets `archr_role` but **never sets `archr_user_id`**. So that browser's session _claims_ Org Admin (passes the login gate, and `dashboard.php` routes it to `org-admin.php`), but the live-data org-admin portal requires a DB user context and forbids it. That trap catches every page: `index.php` sees the session and redirects to `dashboard.php` → `org-admin.php` → 403 — which is why you "can't even reach the public site." The "other associated errors" on pages like case-search ("Access denied.") are the same level-0 signature.

## Why the Super Admin browser is fine

That session is a real database login: `archr_user_id` is set and has an active SUPER_ADMIN row → level 3 passes everywhere. Both browsers load the identical PHP files I edited — if my edits were broken, _both_ would fail. My diff is additive CORS response headers, asset-URL cache-busting, and CSS; none of it touches sessions, login, or role checks. This 403 is pre-existing behavior — the legacy login could never open the live org-admin portal. (It likely surfaced now because that browser freshly logged in with the prototype credentials — possibly because DB auth for that username silently fell back to legacy.)

## How to unblock that browser

1. Go directly to **`logout.php`** — it only needs `session.php`, destroys the session, and works fine.
2. Log in with the **real DB-backed org admin account** (the email/username + password created via setup or by the Super Admin) — not the `org-admin` / `12345` prototype shortcut.
3. Tip: `index.php?public=1` reaches the public site without logging out (that's what the topbar "Public Site" link uses).

If a fresh DB login _still_ 403s, the account itself is missing a proper role row. Check with:

```
SELECT u.id, u.username, r.role_code, ura.organization_id, ura.is_active
  FROM system_users u
  LEFT JOIN user_role_assignments ura ON ura.user_id = u.id
  LEFT JOIN roles r ON r.id = ura.role_id
 WHERE u.email = '...' OR u.username = '...';
```

It needs `is_active = true`, `role_code` of `ADMIN`/`ORG_ADMIN`, and a non-null `organization_id`.

One hardening offer, since this is a real trap: I can make the legacy fallback refuse live-data roles (or show a clear "prototype login can't access live portals" message) instead of creating a dead-end session. That's an auth behavior change, so I haven't touched it — want me to?