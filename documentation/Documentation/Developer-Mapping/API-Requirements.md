# API Requirements & Production Readiness

External services and APIs that ARCHR depends on, what they're used for,
production application status, and fallback strategies.

---

## Required for Production

### 1. Dropbox API
**Used for:** Document storage (Documents Bucket) — case files, financial receipts, templates, SOPs.
- **Endpoint:** `app/vue_api/bucket.php`, `app/lib/dropbox.php`
- **Token type:** Short-lived access token (expires ~4 hours)
- **Production status:** ⚠️ **Blocked** — Dropbox requires app review + branding compliance (Dropbox logo on site) before granting production access. Current dev token gets revoked after a few hours.
- **Fallback:** Local file storage in `app/uploads/` organized by placecode subdirectory. Files served through PHP readfile() with auth check.
- **Action needed:** Add Dropbox logo to the site, submit app for review at https://www.dropbox.com/developers/apps, request production scopes (`files.content.write`, `files.content.read`). Or migrate to local/S3 storage.

### 2. PostgreSQL Database
**Used for:** Primary data store — applications, cases, users, events, tickets, eligibility rules.
- **Status:** ✅ **Production ready** — no external approval needed. Runs on Laragon locally, will run on any VPS/host with PostgreSQL.
- **Fallback:** N/A — this is the primary store.

### 3. Airtable API
**Used for:** Legacy data source. The `app/` dual-writes to Airtable when configured, and `vue-view/` reads from Airtable directly as an intermediate step before full PostgreSQL migration.
- **Keys:** `AIRTABLE_API_KEY`, `AIRTABLE_BASE_*` (10+ bases)
- **Status:** ✅ **Production ready** — API keys don't require app review.
- **Rate limits:** 5 requests/second on free plan, record limits per base.
- **Fallback:** PostgreSQL-only mode. Set `AIRTABLE_API_KEY` to empty and the app falls back to reading/writing only PostgreSQL. Long-term goal: remove Airtable dependency entirely.

### 4. SMTP / Email Delivery
**Used for:** Support ticket alerts to Super Admins, future password reset, applicant notifications.
- **Endpoint:** `app/lib/email.php` (`ARCHREmailer`)
- **Status:** ⚠️ **Local only** — currently uses Mailpit (127.0.0.1:1025) for local testing. Production needs real SMTP.
- **Fallback:** File logging to `app/logs/emails.json` — emails are captured but not delivered.
- **Options for production:**
  - **SendGrid free tier** — 100 emails/day free. Needs `SMTP_HOST=smtp.sendgrid.net`, `SMTP_USER=apikey`, `SMTP_PASS=<sendgrid-api-key>`.
  - **Webhost SMTP** — If hosted on a cPanel server, use its built-in SMTP (`SMTP_HOST=localhost`, port 587 or 465).
  - **PHP `mail()`** — Last resort. Unreliable for deliverability but works on most hosts.

---

## Optional / Nice to Have

### 5. Census / HUD AMI Data API
**Used for:** Area Median Income lookup for eligibility evaluation (income threshold as % of AMI per county).
- **Status:** ❌ **Not integrated yet** — AMI values are stored in `ami_lookup` table (SQL seed). Updated manually from census.gov / huduser.gov.
- **Fallback:** Quick Links page links to HUD Income Limits table and Census ACS Data. Super Admin manually updates `ami_lookup` when Census publishes new figures (annually).
- **Recommendation:** Don't bother with an API. The data is published once per year. A manual update via pgAdmin or a "Update AMI" form in the Super Admin panel is simpler and more reliable.

### 6. County GIS / Property Card APIs
**Used for:** Automating address verification, property tax value lookup, ownership confirmation, lot size, home type.
- **Buncombe County:** https://prc-buncombe.spatialest.com/#/
- **Madison County:** https://www.madisonrod.net/
- **Status:** ❌ **Not integrated yet** — no public REST API. These are web portals. Would require screen scraping or working with county IT departments.
- **Fallback:** Quick Links page. Staff manually looks up property cards and records findings in the case notes. Currently mostly automated on the live system — the Vue/PHP app can do it manually via the links until APIs are available.
- **Recommendation:** Defer until after the core pipeline (intake → assessment → case → tasks) is working. The manual lookup process is documented and functional.

---

## Not Needed (Yet)

### 7. Password Reset Email
**Status:** Deferred. No email system in production. Currently: Super Admin resets passwords manually via `api/super-admin.php`.
- `system_users` table already has `reset_token` and `reset_token_expires` columns (partially built).
- Needs SMTP configured first, then add reset flow.

### 8. Vue Router / Auth Guards
**Status:** Deferred. Auth is handled by conditional rendering in App.vue (`v-if="authenticated"`). No route-level protection yet.
- If the app grows beyond the current scope, Vue Router with `beforeEach` guards would be cleaner.

---

## Summary: What to Apply For Now

| API | Apply for Production? | Priority | Effort |
|---|---|---|---|
| **Dropbox** | ✅ Yes (if using) | High — blocks document storage | Logo + form submission |
| **SendGrid / SMTP** | ✅ Yes | High — needed for email alerts | 15 min setup |
| **Airtable** | Already works | N/A | N/A |
| **Census/HUD AMI** | ❌ No | Low — manual update is fine | Annual data entry |
| **County GIS** | ❌ No | Low — no API available | Manual lookup via Quick Links |

**Recommendation:**
1. Apply for Dropbox production access (add logo, submit form) — or switch to local file storage
2. Set up SendGrid free tier or configure your webhost's SMTP
3. Skip Census/GIS APIs — Quick Links + manual process is sufficient for now
