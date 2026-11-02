# Database Naming Conventions — Developer Guide

A reader-friendly naming standard for ARCHR databases, written after comparing
the PostgreSQL schema with the live Airtable base. The goal: names you can say
out loud, paste into code without escaping, and grep for reliably.

## Why this guide exists

The live Airtable base names things with emojis, spaces, arrows and parentheses —
e.g. table `⚓💼Cases`, fields `🪝→💜dirOrgId`, `Count (⚓🎯ARCHR Anchor Projects)`,
`💼→🪝→⚒️🤖clamedRoboNeedIds`. These render fine in the Airtable UI but cause real
problems in integrations:

- URL-encoding and quoting bugs in API calls (`⚓💼Cases` → `%E2%9A%93%F0%9F%92%BCCases`)
- invisible characters and inconsistent spacing (`clamed` vs `claimed` typos hide easily)
- impossible to type from memory; code reviews can't sanity-check names
- diffs and logs become unreadable; grep/regex need Unicode escapes

The PostgreSQL schema shows the opposite style: `intake_submissions.applicant_first_name`
— instantly readable, typeable, and safe in any toolchain.

## The rules

**Tables** — `snake_case`, plural, noun-first: `cases`, `intake_submissions`,
`coalition_organizations`, `case_statuses`. Junction tables name both parents:
`submission_repair_categories`.

**Fields** — `snake_case`, singular, no table prefix (the table already scopes it):
`case_number`, `gross_annual_income`, `home_city`.

**Keys & relationships**
- Primary key: `id` (single auto-increment integer / Airtable record id)
- Foreign key: `<other_table_singular>_id`: `submission_id`, `organization_id`, `status_id`
- Cross-system links: prefix with the target system: `dir_org_id`, `anchor_id`

**Booleans** — verb/adjective prefixes so `true` reads naturally:
`is_test`, `is_active`, `has_income`, `owns_home`, `helene_related`,
`urgent_no_hvac`, `urgent_eviction_risk`.

**Timestamps** — `_at` suffix, past tense: `created_at`, `submitted_at`,
`work_completed_at`. Dates without time: `_date` (`move_in_date`).

**Codes vs names** — keep both when both exist: `status_code` (`PENDING_REVIEW`,
machine-stable) and `status_name` (`Pending Review`, display). Same pattern:
`organization_code` / `organization_name`.

**Units & types** — make the unit part of the name: `total_budget` (dollars,
numeric), `file_size_bytes`, `household_size`. Money is numeric, never text.

**Never use:** emojis · spaces · `→`/`+`/`/` symbols · leading digits ·
camelCase or PascalCase in SQL · reserved words (`count`, `status`, `label`
bare — qualify them) · abbreviations only one person knows.

## Translating the live Airtable glyph language

The live base's emojis form a consistent visual vocabulary. When syncing or
building new tables, translate the glyph to a readable prefix:

| Glyph | Meaning | Readable prefix |
|---|---|---|
| ⚓ | Anchor (project/record) | `anchor_` |
| 💼 | Case | `case_` |
| 🪝 | Claim | `claim_` |
| 💜 | Organization (Directory) | `org_` / `dir_org_` |
| 📍 | Place / address | `place_` |
| 👤 | Person / applicant | `applicant_` |
| 📚 | Submission (Fillout intake) | `submission_` |
| 💸 | Money / draw request | `draw_` / `payment_` |
| ⚒️ | Repair need | `repair_` |
| 🎯 | Project | `project_` |
| 🏁 | Progress tracker | `progress_` |
| ❗ | Triage / urgent | `urgent_` / `triage_` |
| id(...) | Foreign/record id | `..._id` |
| Count (...) / Rollup | computed aggregate | omit — compute in code |

Examples: `🪝→💜dirOrgId` → `claim_dir_org_id` · `💼Case Opened Date` →
`case_opened_date` · `📚id(rawSub)` → `submission_raw_id` ·
`📚❗Triage Score (combined)` → `submission_triage_score`.

## Airtable-specific guidance

1. **Names may be human-friendly; references must be stable.** Every Airtable
   field has an immutable id (`fld…`). Application code should either reference
   field ids (`returnFieldsByFieldId`) or keep one map file (see
   `vue-view/src/config/caseFields.js`). Never scatter literal field names
   through components.
2. **Renaming a field is a breaking change.** Name-addressed API consumers break
   silently. Treat renames like database migrations: version, communicate, migrate.
3. **New bases/tables follow the PSQL conventions above** (the Dummy Database
   does — it is generated from `sql/_master.sql`). Views may carry emoji for UI
   polish; tables and fields should not.
4. **Multi-selects and links are arrays in the API** — name them plurally
   (`repair_needs`, `claim_ids`) so the type is obvious.

## Quick checklist for new names

- [ ] Can I type it from memory, first try?
- [ ] Can I say it on a call without describing characters?
- [ ] Does it survive a URL, a JSON key, and a shell command unescaped?
- [ ] Is the boolean/code/date pattern consistent with this guide?
- [ ] If it's a relationship, does the name say what it points to?
