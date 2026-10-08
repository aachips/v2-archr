# ARCHR Data Sync Guide

## Quick Start

These scripts keep your **Airtable** data and **PostgreSQL** database in sync. No coding needed — just run commands.

---

## Prerequisites

1. **You're in the right folder:**
   ```bash
   cd C:\laragon\www\archr\repo\vue-view
   ```

2. **Dependencies installed:**
   ```bash
   npm install
   ```
   (Only needed once. Installs `pg`, `dotenv`, `node-fetch`.)

3. **`.env` file has your credentials:**
   ```
   VUE_APP_AIRTABLE_API_KEY=patXXXXXXXXXXXXX
   VUE_APP_AIRTABLE_BASE=appiMfIEzULJtmi5v
   ```

---

## Step 1: Add Workflow Status to Airtable

This adds a `workflow_status` dropdown field to your `cases` table and fills in existing records.

```bash
# Preview what would happen (no changes)
npm run sync:workflow -- --dry

# Do it for real
npm run sync:workflow
```

**What it does:**
- Creates a "workflow_status" single-select field in Airtable
- Assigns values: ~30% "assessment-ready", ~20% "in-assessment", ~25% "assessed", ~25% "ready-for-contract"
- Takes ~5 seconds for 50 records

**Available workflow statuses:**
| Status | Meaning |
|---|---|
| `assessment-ready` | Intake complete, waiting for assessor |
| `in-assessment` | Assessor is evaluating |
| `assessed` | SOW created |
| `ready-for-contract` | SOW approved, waiting for contract |
| `contracted` | Contract signed |
| `in-progress` | Work underway |
| `completed` | Repair finished |

---

## Step 2: Check What's on Both Sides

See how many records exist in each database and their workflow distribution:

```bash
npm run sync:inspect
```

**Example output:**
```
=== Database Inspection ===

PostgreSQL (archr): 42 cases
  Workflow status distribution:
    assessment-ready: 12
    in-assessment: 8
    assessed: 10
    ready-for-contract: 12

Airtable (appiMfIEzULJtmi5v): 42 cases
  Workflow status distribution:
    assessment-ready: 12
    in-assessment: 8
    assessed: 10
    ready-for-contract: 12
```

---

## Step 3: Sync Airtable → PostgreSQL

Copies all case data (including workflow_status) from Airtable to PostgreSQL:

```bash
# Preview
npm run sync:to-psql -- --dry

# Do it
npm run sync:to-psql
```

**What it does:**
- Reads all records from Airtable's `cases` table
- Inserts into PostgreSQL's `cases` table
- If a record already exists (same `id`), it **updates** `workflow_status` and `updated_at`
- Does **not** delete anything

**Safe to run multiple times** — it won't duplicate records.

---

## Step 4: Sync PostgreSQL → Airtable

Copies workflow_status changes from PostgreSQL back to Airtable:

```bash
# Preview
npm run sync:to-airtable -- --dry

# Do it
npm run sync:to-airtable
```

**What it does:**
- Reads all cases from PostgreSQL that have an Airtable record ID
- Updates the `workflow_status` field in Airtable
- Only works if records were previously synced from Airtable (so we know their Airtable IDs)

**When to use this:**
- You updated workflow statuses in PostgreSQL (e.g., through the PHP admin panel)
- You want Airtable to reflect those changes

---

## Troubleshooting

### "VUE_APP_AIRTABLE_API_KEY must be set"
Your `.env` file is missing or incomplete. Copy `.env.example` to `.env` and fill in your Airtable personal access token.

### "Table 'cases' not found"
The `cases` table doesn't exist in your Airtable base. Make sure you're using the correct base ID in `.env`.

### "permission denied for table cases"
PostgreSQL user doesn't have access to the `cases` table. Run this in psql:
```sql
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres;
```

### "relation 'cases' does not exist"
The `cases` table hasn't been created in PostgreSQL yet. Run your schema migrations first:
```bash
psql -U postgres -d archr -f sql/your-migration-file.sql
```

### Sync says "No records have matching Airtable record IDs"
PostgreSQL records were created directly (not synced from Airtable), so we don't know their Airtable IDs. Run `sync:to-psql` first to establish the mapping.

---

## Data Flow Diagram

```
┌─────────────┐     sync:to-psql     ┌─────────────┐
│  Airtable   │ ───────────────────► │ PostgreSQL  │
│  (Dummy)    │                      │  (PSQL)     │
│             │ ◄─────────────────── │             │
└─────────────┘   sync:to-airtable   └─────────────┘
       │                                      │
       │                                      │
       ▼                                      ▼
┌─────────────┐                        ┌─────────────┐
│ Vue App     │                        │ PHP Backend │
│ (frontend)  │                        │ (app/)      │
└─────────────┘                        └─────────────┘
```

**Typical workflow:**
1. Intake submission → creates record in Airtable
2. Run `sync:to-psql` → copies to PostgreSQL
3. Assessment happens → SOW created → `workflow_status` set to "assessed"
4. Run `sync:to-airtable` → updates Airtable with new status
5. Vue app reads from Airtable → shows updated workflow filter

---

## Common Commands Cheat Sheet

| Command | What it does |
|---|---|
| `npm run sync:inspect` | Show record counts on both sides |
| `npm run sync:workflow` | Add workflow_status field to Airtable + populate |
| `npm run sync:workflow -- --dry` | Preview workflow field creation |
| `npm run sync:to-psql` | Copy Airtable → PostgreSQL |
| `npm run sync:to-psql -- --dry` | Preview Airtable → PostgreSQL sync |
| `npm run sync:to-airtable` | Copy PostgreSQL → Airtable |
| `npm run sync:to-airtable -- --dry` | Preview PostgreSQL → Airtable sync |

---

## When Things Go Wrong

**"I accidentally ran sync:to-psql and now my data is wrong!"**
No data is deleted. You can always re-run `sync:to-psql` to overwrite with the correct Airtable data.

**"I added a new column in Airtable but sync doesn't see it."**
The sync scripts only sync known columns. To add a new column:
1. Add it to the PostgreSQL `cases` table: `ALTER TABLE cases ADD COLUMN new_column TEXT;`
2. Add it to the sync script's `caseData` object
3. Re-run `sync:to-psql`

**"I want to start fresh — wipe all workflow statuses."**
```bash
npm run sync:workflow -- --reset
npm run sync:to-psql
```
