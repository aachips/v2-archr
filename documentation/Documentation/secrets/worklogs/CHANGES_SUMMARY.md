# ARCHR Login System - Changes Summary

## What Changed

### ✅ Navigation Bar (app/lib/layout.php)

**BEFORE:**
```
[ARCHR Logo] Home | Start intake | My dashboard | Admin queue | Role portals
```

**AFTER (Not Logged In):**
```
[ARCHR Logo] Home | Start Intake | Log In
```

**AFTER (Logged In):**
```
[ARCHR Logo] Home | Start Intake | Logout
```

---

### ✅ Home Page (app/index.php)

**BEFORE:**
- Two-column layout with "I need help" and "I am ARCHR staff" sections
- Direct links to all dashboards
- No login required

**AFTER (Not Logged In):**
```
┌─────────────────────────────────────────────┐
│  ARCHR application portal                   │
│  [Start Intake Form] [Log In to Dashboard]  │
│                                             │
│  Role portals                               │
│  → Must log in to access                   │
│  [Log In to Access Dashboards] button      │
│  (All portal cards link to login)          │
└─────────────────────────────────────────────┘
```

**AFTER (Logged In):**
```
┌─────────────────────────────────────────────┐
│  ARCHR application portal                   │
│  [Start Intake Form] [Logout]              │
│                                             │
│  Role portals                               │
│  (Portal cards link directly to dashboards)│
└─────────────────────────────────────────────┘
```

---

### ✅ Portal Dashboard Headers (app/lib/portal-layout.php)

**BEFORE:**
```
┌───────────────────────────────────────────────────────────┐
│ [☰] [Assessor Dashboard h1]      [Assessor] [🌓] [Avatar] │
└───────────────────────────────────────────────────────────┘
```
*Issue: Redundant "Assessor Dashboard" text when "Assessor" badge already shows role*

**AFTER:**
```
┌──────────────────────────────────────────────────────────────────┐
│ [☰] [🏠 ARCHR]      [Assessor] [🌓] [Avatar] [Logout]           │
└──────────────────────────────────────────────────────────────────┘
```
*Benefits:*
- ✅ Clean ARCHR logo wordmark (clickable → home)
- ✅ Removed redundant dashboard title
- ✅ Added logout button
- ✅ More professional appearance

---

### ✅ Login Page (app/login.php) - NEW

```
┌────────────────────────────────────┐
│  ARCHR Login Portal                │
│                                    │
│  Username: [_____________]         │
│  Password: [_____________]         │
│  [Log In]                          │
│                                    │
│  Demo Accounts                     │
│  Password: 12345                   │
│  Roles:                            │
│  • assessor    • envoy             │
│  • bursar      • project-manager   │
│  • crew-lead   • requestor         │
│  • etc...                          │
└────────────────────────────────────┘
```

---

## File Changes

### New Files
- ✅ `app/login.php` - Login portal with role list
- ✅ `app/logout.php` - Logout handler
- ✅ `app/lib/auth.php` - Authentication helpers

### Modified Files
- ✅ `app/lib/layout.php` - Simplified navigation (Home, Start Intake, Log In/Logout)
- ✅ `app/lib/portal-layout.php` - Logo wordmark + logout button
- ✅ `app/index.php` - Login-aware home page
- ✅ All 11 portal files - Added authentication requirement

### Protected Portal Pages
All require login (redirect to login.php if not authenticated):
1. `assessor.php`
2. `bursar.php`
3. `crew-lead.php`
4. `crew-member.php`
5. `subcontractor.php`
6. `envoy.php`
7. `project-manager.php`
8. `requestor-portal.php`
9. `volunteer.php`
10. `org-admin.php`
11. `tle-poc.php`

---

## Demo Credentials

**Password (all accounts):** `12345`

**Usernames:** assessor, bursar, crew-lead, crew-member, subcontractor, envoy, project-manager, requestor, volunteer, org-admin, tle-poc

*(Also accepts space variations like "crew lead" or "org admin")*

---

## Testing Checklist

- [ ] Navigate to `app/index.php` - Should see "Home | Start Intake | Log In"
- [ ] Click any portal card - Should redirect to login
- [ ] Login with "assessor" / "12345" - Should redirect to assessor dashboard
- [ ] Dashboard should show ARCHR logo (not "Assessor Dashboard" h1)
- [ ] Dashboard should have logout button in top right
- [ ] Click logout - Should redirect to login page
- [ ] Navigation should now show "Home | Start Intake | Log In"
