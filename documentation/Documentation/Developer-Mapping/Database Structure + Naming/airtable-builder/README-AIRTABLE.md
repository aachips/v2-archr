# ARCHR Airtable Database Builder

This script reads the ARCHR PostgreSQL master SQL script and creates corresponding tables in Airtable.

## Prerequisites

1. **Node.js** (version 14 or higher)
2. **Airtable Personal Access Token** with permissions to create tables
3. **Base ID**: `appiMfIEzULJtmi5v` (configured in script)

## Setup

1. Create a file named `PAT.txt` in the same directory as `build-airtable.js`
2. Copy your Airtable Personal Access Token into `PAT.txt` (just the token, nothing else)
3. Ensure the SQL files are in the `sql/` directory

## Usage

Run the script using Node.js:

```bash
node build-airtable.js
```

Or using npm:

```bash
npm start
```

## What It Does

1. **Reads Master SQL Script**: Parses `sql/_master.sql` to find all referenced SQL files
2. **Extracts Table Schemas**: Analyzes each SQL file to extract table definitions
3. **Maps Data Types**: Converts PostgreSQL data types to Airtable field types:
   - `VARCHAR`/`TEXT` → Single/Multi-line Text
   - `INTEGER`/`BIGINT` → Number
   - `NUMERIC`/`DECIMAL` → Number (with decimals)
   - `BOOLEAN` → Checkbox
   - `DATE` → Date
   - `TIMESTAMP` → DateTime
   - `UUID` → Single-line Text
   - `JSON`/`JSONB` → Multi-line Text
4. **Creates Tables**: Uses Airtable API to create each table with appropriate fields

## Data Type Mapping

| PostgreSQL Type | Airtable Field Type | Notes |
|----------------|---------------------|-------|
| SERIAL, INTEGER, BIGINT | Number | Precision 0 (whole numbers) |
| NUMERIC, DECIMAL | Number | Precision 2 (decimals) |
| VARCHAR(n) | Single Line Text | - |
| TEXT | Multi-line Text | - |
| BOOLEAN | Checkbox | - |
| DATE | Date | ISO format |
| TIMESTAMP | DateTime | ISO format, UTC timezone |
| UUID | Single Line Text | - |
| JSON, JSONB | Multi-line Text | Serialized as text |

## Output

The script will:
- List all SQL files found in the master script
- Show each table being created with field count
- Display a summary of successful and failed table creations

## Notes

- **Auto-increment IDs**: PostgreSQL `SERIAL` columns are skipped (Airtable auto-creates record IDs)
- **Constraints**: Foreign keys and constraints are not created (Airtable uses linked records)
- **Rate Limiting**: Script includes 200ms delay between API calls to respect Airtable rate limits
- **Error Handling**: If a table creation fails, the script continues with remaining tables

## Getting Your Airtable Personal Access Token

1. Go to https://airtable.com/create/tokens
2. Click "Create new token"
3. Give it a name (e.g., "ARCHR Database Builder")
4. Add these scopes:
   - `data.records:read`
   - `data.records:write`
   - `schema.bases:read`
   - `schema.bases:write`
5. Add access to your base: `appiMfIEzULJtmi5v`
6. Click "Create token"
7. Copy the token to `PAT.txt`

## Troubleshooting

- **"PAT.txt not found"**: Create the file in the same directory as the script
- **"API Error 401"**: Check your Personal Access Token is valid and has correct permissions
- **"API Error 404"**: Verify the base ID is correct
- **Table creation fails**: Check if table already exists (delete or rename it in Airtable)

## File Structure

```
.
├── build-airtable.js      # Main script
├── package.json           # Node.js package configuration
├── PAT.txt               # Your Airtable token (create this)
├── PAT.txt.template      # Template for PAT.txt
└── sql/
    ├── _master.sql       # Master deployment script
    ├── intake.sql
    ├── role-based-access.sql
    └── ...               # Other SQL files
```
