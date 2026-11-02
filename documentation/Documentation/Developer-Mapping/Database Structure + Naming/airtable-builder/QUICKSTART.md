# ARCHR Airtable Builder - Quick Start

## 🚀 Get Started in 3 Minutes

### Step 1: Create Your Token File
```bash
# Copy the template
copy PAT.txt.template PAT.txt

# Open and edit PAT.txt
notepad PAT.txt
```

Paste your Airtable Personal Access Token (get it from: https://airtable.com/create/tokens)

### Step 2: Test the Parser
```bash
node test-parser.js
```

You should see output showing 77 tables will be created.

### Step 3: Build the Database
```bash
node build-airtable.js
```

Wait ~15-20 seconds while it creates all tables.

---

## ✅ That's It!

Your Airtable base `appiMfIEzULJtmi5v` now has:
- 77 tables
- 827 fields
- Complete schema from PostgreSQL

---

## 📖 Need More Help?

- **Setup Issues**: Read `SETUP-INSTRUCTIONS.md`
- **Technical Details**: Read `README-AIRTABLE.md`  
- **Overview**: Read `IMPLEMENTATION-SUMMARY.md`

---

## 🔑 Getting Your Airtable Token

1. Go to: https://airtable.com/create/tokens
2. Create new token with name: "ARCHR Database Builder"
3. Add scopes:
   - ✓ data.records:read
   - ✓ data.records:write
   - ✓ schema.bases:read
   - ✓ schema.bases:write
4. Add access to base: `appiMfIEzULJtmi5v`
5. Copy token to `PAT.txt`

---

## ⚡ Quick Commands

```bash
# Test without creating anything
npm test

# Build the database
npm start

# Alternative
node build-airtable.js
```

---

## ⚠️ Common Issues

**"PAT.txt not found"**
→ Create the file: `copy PAT.txt.template PAT.txt`

**"API Error 401"**
→ Check your token is valid and has correct permissions

**"Table already exists"**
→ Delete existing tables in Airtable first

---

## 🎯 What Gets Created

| Category | Tables | Examples |
|----------|--------|----------|
| Intake | 11 | intake_submissions, repair_requests |
| Users & Roles | 21 | system_users, cases, work_orders |
| Organizations | 7 | coalition_organizations |
| Volunteers | 11 | volunteer_profiles, quests, badges |
| Documents | 8 | case_documents, templates |
| Help System | 9 | help_documents, categories |
| Communications | 3 | notifications, email_queue |
| Other | 7+ | review_queue, eligibility, feedback |

**Total**: 77 tables, 827 fields from 19 SQL files
