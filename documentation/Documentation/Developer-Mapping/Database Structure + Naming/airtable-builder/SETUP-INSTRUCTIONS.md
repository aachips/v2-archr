# ARCHR Airtable Builder - Setup Instructions

This guide will help you build an Airtable database from your ARCHR PostgreSQL schema.

## 📋 Overview

The `build-airtable.js` script will:
1. Read the master SQL deployment script (`sql/_master.sql`)
2. Parse all 19 referenced SQL files
3. Extract 77 table definitions with 827 fields
4. Create corresponding tables in your Airtable base

## 🔧 Prerequisites

### 1. Node.js
Ensure you have Node.js installed (version 14 or higher):
```bash
node --version
```

### 2. Airtable Account
- Access to Airtable base: `appiMfIEzULJtmi5v`
- Personal Access Token (PAT) with appropriate permissions

## 🚀 Quick Start

### Step 1: Create PAT.txt
Create a file named `PAT.txt` in the project root:
```bash
# Copy the template
copy PAT.txt.template PAT.txt

# Edit PAT.txt and replace with your actual token
notepad PAT.txt
```

Your `PAT.txt` should contain ONLY your Airtable token on one line.

### Step 2: Get Your Airtable Personal Access Token

1. Visit: https://airtable.com/create/tokens
2. Click **"Create new token"**
3. Name it: `ARCHR Database Builder`
4. Add these scopes:
   - ✓ `data.records:read`
   - ✓ `data.records:write`
   - ✓ `schema.bases:read`
   - ✓ `schema.bases:write`
5. Add access to base: `appiMfIEzULJtmi5v`
6. Click **"Create token"**
7. Copy the token and paste into `PAT.txt`

### Step 3: Test the Parser (Optional but Recommended)
Before creating tables in Airtable, test that the SQL parsing works:
```bash
node test-parser.js
```

This will show you:
- How many SQL files will be processed
- How many tables will be created
- Field details for sample tables

### Step 4: Build Airtable Database
Run the builder script:
```bash
node build-airtable.js
```

Or using npm:
```bash
npm start
```

## 📊 What Gets Created

### Database Statistics
- **SQL Files**: 19
- **Total Tables**: 77
- **Total Fields**: 827

### Major Table Categories

1. **Intake System** (11 tables)
   - `intake_submissions` - Main application data
   - `repair_requests`, `income_records`, etc.

2. **Role-Based Access** (21 tables)
   - `system_users`, `roles`, `permissions`
   - `cases`, `work_orders`, `invoices`

3. **Partner Organizations** (7 tables)
   - `coalition_organizations`
   - `application_assignments`

4. **Volunteer System** (11 tables)
   - `volunteer_profiles`, `quests`, `badges`

5. **Document Management** (8 tables)
   - `case_documents`, `document_templates`

6. **Help/Documentation** (9 tables)
   - `help_documents`, `help_categories`

7. **Communications** (3 tables)
   - `notifications`, `email_queue`

8. **Finance** (7+ tables)
   - `invoices`, `funding_sources`, `case_funding`

## 🔄 Data Type Mapping

| PostgreSQL Type | Airtable Field Type | Example |
|----------------|---------------------|---------|
| `SERIAL`, `INTEGER` | Number (precision 0) | IDs, counts |
| `NUMERIC`, `DECIMAL` | Number (precision 2) | Money, percentages |
| `VARCHAR(n)` | Single Line Text | Names, emails |
| `TEXT` | Multi-line Text | Notes, descriptions |
| `BOOLEAN` | Checkbox | Yes/no fields |
| `DATE` | Date | Birthdate, move-in date |
| `TIMESTAMP` | DateTime | Created at, updated at |
| `UUID` | Single Line Text | UUIDs |
| `JSON`, `JSONB` | Multi-line Text | Structured data |

## ⚠️ Important Notes

### Auto-Generated Fields
- PostgreSQL `SERIAL` and `id` columns are **skipped**
- Airtable automatically creates a unique ID for each record

### Relationships
- Foreign key constraints are **not** created
- You'll need to manually set up linked record fields in Airtable
- The script focuses on creating the base table structure

### Rate Limiting
- Script includes 200ms delay between API calls
- Respects Airtable API rate limits
- Total runtime: ~15-20 seconds for all tables

### Existing Tables
- If a table already exists, creation will fail
- Delete or rename existing tables before running

## 🛠️ Troubleshooting

### Error: "PAT.txt not found"
**Solution**: Create `PAT.txt` in the project root directory

### Error: "API Error 401: Unauthorized"
**Solutions**:
- Verify your PAT is correct
- Check token hasn't expired
- Ensure token has correct scopes

### Error: "API Error 404: Not Found"
**Solutions**:
- Verify base ID `appiMfIEzULJtmi5v` is correct
- Ensure your PAT has access to this specific base

### Error: "Table already exists"
**Solution**: The table already exists in Airtable. Either:
- Delete it from Airtable
- Rename it
- Skip it by modifying the script

### Error: "Invalid field type"
**Solution**: Check the data type mapping. Some PostgreSQL types might need manual adjustment.

## 📁 Project Structure

```
project-root/
├── build-airtable.js       # Main builder script
├── test-parser.js          # Test/preview script
├── package.json            # Node.js configuration
├── PAT.txt                 # Your Airtable token (create this!)
├── PAT.txt.template        # Template for PAT.txt
├── README-AIRTABLE.md      # Detailed documentation
├── SETUP-INSTRUCTIONS.md   # This file
└── sql/
    ├── _master.sql         # Master deployment script
    └── *.sql               # Individual schema files
```

## ✅ Success Checklist

- [ ] Node.js installed and working
- [ ] Created `PAT.txt` with valid token
- [ ] Token has correct scopes and base access
- [ ] Ran `test-parser.js` successfully
- [ ] Ran `build-airtable.js`
- [ ] Verified tables created in Airtable
- [ ] Set up linked record fields as needed

## 🎯 Next Steps After Building

1. **Review Tables**: Check all 77 tables were created
2. **Add Relationships**: Create linked record fields for foreign keys
3. **Import Data**: Migrate data from PostgreSQL if needed
4. **Configure Views**: Set up useful views for each table
5. **Set Permissions**: Configure Airtable base permissions

## 💡 Tips

- Run `npm test` to preview without creating tables
- The script is idempotent-safe for new tables only
- Keep your `PAT.txt` secure and never commit it
- Review the field mappings in test output before building
