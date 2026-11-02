**Created:**

- `interface/documents/case-documents.html` — static POC (tle-poc style)
- `app/case-documents.php` — page controller (org-admin scoped, `?case=` selector, overview mode)
- `app/partials/case-documents-body.php` — directory tree, doc rows, KPIs, generate + upload modals, verification queue
- `app/assets/case-documents.css` — page styles
- `app/lib/case-documents.php` — data layer: table probe, live bundle from `case_documents`, `case_document_inventory` rollups, `pending_verification_documents` queue, required-checklist → derived "missing" rows, sample fallback
- `app/api/documents.php` — `upload` (sha256 dedupe, 25MB cap, ext allowlist, requestor own-case scoping), `verify`, `reject` (reason required, notifies uploader), `generate` (validates against `document-tokens.json`, writes `document_generation_jobs` + rendered file into the case folder), `download` (auth + scope gated, traversal-safe)
- `elemental-integration/components/documents/` — 6 specs: `case-directory-tree`, `document-card`, `generate-document-button`, `upload-document-form`, `verify-document-button`, `reject-document-button`

**Modified:**

- `app/org-admin.php` — Case Documents in the admin side menu
- `app/requestor-portal.php` + `app/partials/requestor-body-live.php` — "My Documents" section (the nav's `#documents` link finally lands somewhere): upload form feeding the verification queue + their own docs with live status pills
- `elemental-integration/component-library.php` — now scans role/category subfolders (previously invisible)
- `elemental-integration/document-generation/document-tokens.json` — fixed invalid JSON (`35+,`), normalized the three "Draw Request…" spellings
- `documentation/field-mapping-confirmation.txt` — new dated addendum
- `.gitignore` — `app/uploads/`