Session Summary - September 11-12, 2026 (Continued)

Eligibility Presets - Disaster vs General Tracks + PODER Emma
Disaster vs General distinction documented - disaster repair has relaxed rules (waived residence, same/lower AMI threshold, fewer docs); general repair has stricter criteria (min residence, sometimes
50% AMI)
Option C chosen - base org presets with disaster/general variants, less duplication, easier to maintain
PODER Emma preset added (poder_emma) - 8 rules: Buncombe + Madison counties, 80% AMI, 4 ownership doc types (no 99yr lease, no mobile home bill of sale), no residence/lot rules
Habitat preset updated - comments documenting disaster vs general income threshold differences
Community Housing Coalition preset retained - Madison only, 80% AMI, 5 ownership doc types
Preset config refactored - shared PROOF_INCOME_TYPES constant to reduce duplication across presets
- UI dropdown updated - now lists all three presets with rule counts

API Requirements Documentation
API-Requirements.md' created - comprehensive rundown of every external API/service:
Dropbox - blocked by production review (logo requirement), fallback is local file storage
PostgreSQL - production ready, no approval needed
- Airtable - already works, keys don't require review, rate-limited on free tier
- SMTP/Email - local only via Mailpit, needs SendGrid or webhost SMTP for production
Census/HUD AMI - no API needed, manual annual update is simpler
County GIS - no public APIs exist, manual lookup via Quick Links is the fallback
Password reset - deferred until SMTP is configured
- Vue Router/auth guards - deferred, current conditional rendering works
Priority table - Dropbox and SMTP marked high priority for production application

Quick Links Updated
Buncombe County Property Record Search added (https://prc-buncombe. spatialest.com/#/)
Madison County Register of Deeds added (https://www.madisonrod.net/)

Dropbox Directory Structure
`create-dropbox-directory. bat' - Windows batch script that generates the complete folder tree
- ARCHR-Dropbox-Root/' - generated directory with:
- financial/ - receipts, invoices, timesheets (root-level, case-linked via metadata)
organizations/ {org}/cases/{placecode}/ - full case structure (application, property, income, assessments, contracts, work orders, financial, completion, communications)
- organizations/{org}/shared/ - templates, grants
photo-unprocessed/ - raw site photos and Solocator uploads before case linking
- sop/ - support guides, operating procedures, templates
Per-org structures created for Habitat for Humanity, Community Housing Coalition, and PODER Emma
Sample case folder (SAMPLEPLACECODE) created under each org as a template
Script tested and verified - all folders created successfully with tree output

Follow-Up / Continue Later

1. Event Resolver - wire into save flows - Auto-trigger archr_resolve() after archr_log_event() in org-admin.php, documents.php, intake-save.php.

2. Event Resolver - tighten evaluation rules - Replace ILIKE '%keyword%' with specific JSON path checks in progress_events.details.

3. AMI evaluator - Build resolver function that reads ami_lookup for applicant's county, multiplies by percentage, compares against actual house

4. QuickTasks - move to DB - Unverified/verified data in localStorage needs progress_events write endpoint.

5. QuickTasks - Triage modal depth - Photo attachment, multi-type splitting, FK-based case mapping.

6. Case Review - SummaryHead crash - Root cause of undefined caseItem during transitions.

7. Vue Router / auth guards - Route-level protection if app grows.

8. Password reset - Still deferred (no production SMTP).

9. Production SMTP - Mailpit works locally; needs SendGrid or webhost SMTP for delivery.

10. Eligibility presets for 4th organization - Doc mentions 4 total; 3 done (Habitat, CHC, PODER Emma)

11. General/disaster track presets - When actual AMI percentage differences are determined (e.g., 50% vs 80%), add separate presets like habitat_general, poder_emma_general.

12. Dropbox production application - Add logo to site, submit for review, or migrate to local/S3 storage.
13. Real placecode folder generation - Replace SAMPLEPLACECODE with actual placecodes from the database when cases exist.

...