#!/usr/bin/env node

/**
 * ARCHR Airtable Database Builder
 * 
 * Reads the master SQL script and creates corresponding Airtable tables
 * at base ID: appiMfIEzULJtmi5v
 * 
 * Usage: node build-airtable.js
 * Requires: PAT.txt file in same directory with Airtable Personal Access Token
 */

const fs = require('fs');
const path = require('path');
const https = require('https');

// Configuration
const BASE_ID = 'appiMfIEzULJtmi5v';
const PAT_FILE = path.join(__dirname, 'PAT.txt');
// The SQL schema lives at the repository root (../../sql); only fall back to
// a local sql/ directory if someone copies one in.
const LOCAL_SQL_DIR = path.join(__dirname, 'sql');
const SQL_DIR = fs.existsSync(path.join(LOCAL_SQL_DIR, '_master.sql'))
  ? LOCAL_SQL_DIR
  : path.join(__dirname, '..', '..', 'sql');
const MASTER_SQL = path.join(SQL_DIR, '_master.sql');

// Read Personal Access Token
function readPAT() {
    if (!fs.existsSync(PAT_FILE)) {
        console.error(`ERROR: PAT.txt not found at ${PAT_FILE}`);
        console.error('Please create PAT.txt with your Airtable Personal Access Token');
        process.exit(1);
    }
    return fs.readFileSync(PAT_FILE, 'utf8').trim();
}

// Make Airtable API request
function airtableRequest(method, endpoint, data = null) {
    const PAT = readPAT();
    
    return new Promise((resolve, reject) => {
        const options = {
            hostname: 'api.airtable.com',
            path: endpoint,
            method: method,
            headers: {
                'Authorization': `Bearer ${PAT}`,
                'Content-Type': 'application/json'
            }
        };

        const req = https.request(options, (res) => {
            let body = '';
            res.on('data', chunk => body += chunk);
            res.on('end', () => {
                if (res.statusCode >= 200 && res.statusCode < 300) {
                    resolve(JSON.parse(body));
                } else {
                    reject(new Error(`API Error ${res.statusCode}: ${body}`));
                }
            });
        });

        req.on('error', reject);
        if (data) req.write(JSON.stringify(data));
        req.end();
    });
}

// Parse SQL file to extract table definitions
function parseSQLFile(filePath) {
    const content = fs.readFileSync(filePath, 'utf8');
    const tables = [];
    
    // Match CREATE TABLE statements
    const tableRegex = /CREATE TABLE\s+(\w+)\s*\(([\s\S]*?)\);/gi;
    let match;
    
    while ((match = tableRegex.exec(content)) !== null) {
        const tableName = match[1];
        const columnsText = match[2];
        
        const fields = parseColumns(columnsText);
        
        tables.push({
            name: tableName,
            fields: fields,
            sourceFile: path.basename(filePath)
        });
    }
    
    return tables;
}

// Parse column definitions from CREATE TABLE statement
function parseColumns(columnsText) {
    const fields = [];
    const lines = columnsText.split('\n');
    
    for (let line of lines) {
        line = line.trim();
        
        // Skip empty lines, comments, and constraints
        if (!line || line.startsWith('--') || 
            line.toUpperCase().startsWith('PRIMARY KEY') ||
            line.toUpperCase().startsWith('FOREIGN KEY') ||
            line.toUpperCase().startsWith('UNIQUE') ||
            line.toUpperCase().startsWith('CHECK') ||
            line.toUpperCase().startsWith('CONSTRAINT')) {
            continue;
        }
        
        // Parse column definition
        const columnMatch = line.match(/^(\w+)\s+([A-Z]+(?:\([^)]+\))?)/i);
        if (columnMatch) {
            const columnName = columnMatch[1];
            const dataType = columnMatch[2].toUpperCase();
            
            // Map PostgreSQL types to Airtable field types
            const airtableField = mapToAirtableField(columnName, dataType, line);
            if (airtableField) {
                fields.push(airtableField);
            }
        }
    }
    
    return fields;
}

// Map PostgreSQL data types to Airtable field types
function mapToAirtableField(columnName, pgType, fullLine) {
    const field = { name: columnName };
    
    // Skip auto-generated fields
    if (columnName === 'id' || pgType.startsWith('SERIAL')) {
        return null; // Airtable auto-creates ID field
    }
    
    // Determine Airtable field type
    if (pgType.startsWith('VARCHAR') || pgType.startsWith('TEXT')) {
        field.type = 'singleLineText';
        if (pgType.startsWith('TEXT') || fullLine.includes('TEXT')) {
            field.type = 'multilineText';
        }
    } else if (pgType.startsWith('INTEGER') || pgType.startsWith('BIGINT') || pgType.startsWith('SMALLINT')) {
        field.type = 'number';
        field.options = { precision: 0 };
    } else if (pgType.startsWith('NUMERIC') || pgType.startsWith('DECIMAL')) {
        field.type = 'number';
        field.options = { precision: 2 };
    } else if (pgType === 'BOOLEAN' || pgType === 'BOOL') {
        field.type = 'checkbox';
        // Checkbox fields require options object with icon and color
        field.options = {
            icon: 'check',
            color: 'greenBright'
        };
    } else if (pgType === 'DATE') {
        field.type = 'date';
        field.options = { dateFormat: { name: 'iso' } };
    } else if (pgType.startsWith('TIMESTAMP')) {
        field.type = 'dateTime';
        field.options = {
            dateFormat: { name: 'iso' },
            timeFormat: { name: '24hour' },
            timeZone: 'utc'
        };
    } else if (pgType === 'UUID') {
        field.type = 'singleLineText';
    } else if (pgType === 'JSON' || pgType === 'JSONB') {
        field.type = 'multilineText';
    } else {
        // Default to single line text for unknown types
        field.type = 'singleLineText';
    }

    return field;
}

// Get all SQL files referenced in master script
function getSQLFilesFromMaster() {
    const masterContent = fs.readFileSync(MASTER_SQL, 'utf8');
    const files = [];

    // Match \ir statements (only lines that start with \ir, ignoring comments)
    const lines = masterContent.split('\n');
    for (const line of lines) {
        const trimmed = line.trim();
        if (trimmed.startsWith('\\ir ')) {
            const fileName = trimmed.substring(4).trim();
            files.push(fileName);
        }
    }

    return files;
}

// Get all existing tables in the base
async function getExistingTables() {
    try {
        const result = await airtableRequest('GET', `/v0/meta/bases/${BASE_ID}/tables`);
        return result.tables || [];
    } catch (error) {
        console.error(`Warning: Could not fetch existing tables: ${error.message}`);
        return [];
    }
}

// Create Airtable table
async function createAirtableTable(tableName, fields) {
    console.log(`Creating table: ${tableName} with ${fields.length} fields`);

    try {
        const result = await airtableRequest('POST', `/v0/meta/bases/${BASE_ID}/tables`, {
            name: tableName,
            fields: fields
        });
        console.log(`✓ Created table: ${tableName}`);
        return result;
    } catch (error) {
        console.error(`✗ Failed to create table ${tableName}: ${error.message}`);
        throw error;
    }
}

// Main execution
async function main() {
    console.log('ARCHR Airtable Database Builder');
    console.log('================================\n');

    console.log(`Base ID: ${BASE_ID}`);
    console.log(`Master SQL: ${MASTER_SQL}\n`);

    // Get all SQL files from master script
    const sqlFiles = getSQLFilesFromMaster();
    console.log(`Found ${sqlFiles.length} SQL files in master script:\n`);

    // Parse all SQL files
    const allTables = [];
    for (const sqlFile of sqlFiles) {
        const filePath = path.join(SQL_DIR, sqlFile);
        console.log(`Parsing: ${sqlFile}`);

        if (!fs.existsSync(filePath)) {
            console.warn(`  ⚠ File not found: ${filePath}`);
            continue;
        }

        const tables = parseSQLFile(filePath);
        console.log(`  Found ${tables.length} table(s)`);
        allTables.push(...tables);
    }

    console.log(`\nTotal tables found: ${allTables.length}\n`);

    // Display tables to be created
    console.log('Tables to create:');
    allTables.forEach((table, idx) => {
        console.log(`${idx + 1}. ${table.name} (${table.fields.length} fields) from ${table.sourceFile}`);
    });

    console.log('\n--- Checking existing tables ---\n');

    // Get existing tables
    const existingTables = await getExistingTables();
    const existingTableNames = existingTables.map(t => t.name);

    console.log(`Found ${existingTableNames.length} existing tables in base`);
    if (existingTableNames.length > 0) {
        console.log(`Existing tables: ${existingTableNames.slice(0, 5).join(', ')}${existingTableNames.length > 5 ? ', ...' : ''}\n`);
    }

    // Filter out tables that already exist
    const tablesToCreate = allTables.filter(t => !existingTableNames.includes(t.name));
    const skippedTables = allTables.filter(t => existingTableNames.includes(t.name));

    console.log(`Tables to create: ${tablesToCreate.length}`);
    console.log(`Tables to skip (already exist): ${skippedTables.length}\n`);

    if (skippedTables.length > 0) {
        console.log('Skipping existing tables:');
        skippedTables.forEach(t => console.log(`  ⊘ ${t.name}`));
        console.log('');
    }

    if (tablesToCreate.length === 0) {
        console.log('✓ All tables already exist! Nothing to create.\n');
        return;
    }

    console.log('--- Starting Airtable table creation ---\n');

    // Create tables in Airtable
    const results = [];

    // Add skipped tables to results
    skippedTables.forEach(t => {
        results.push({ success: true, table: t.name, skipped: true });
    });

    // Create new tables
    for (const table of tablesToCreate) {
        try {
            const result = await createAirtableTable(table.name, table.fields);
            results.push({ success: true, table: table.name, result });

            // Rate limiting: wait 200ms between requests
            await new Promise(resolve => setTimeout(resolve, 200));
        } catch (error) {
            results.push({ success: false, table: table.name, error: error.message });
        }
    }

    // Summary
    console.log('\n=== Summary ===');
    const created = results.filter(r => r.success && !r.skipped).length;
    const skipped = results.filter(r => r.success && r.skipped).length;
    const failed = results.filter(r => !r.success).length;

    console.log(`✓ Created: ${created}`);
    console.log(`⊘ Skipped (already exist): ${skipped}`);
    console.log(`✗ Failed: ${failed}`);
    console.log(`━ Total: ${results.length}`);

    if (failed > 0) {
        console.log('\nFailed tables:');
        results.filter(r => !r.success).forEach(r => {
            console.log(`  - ${r.table}: ${r.error}`);
        });
    }

    console.log('\nDone!');
}

// Run main function
main().catch(error => {
    console.error('Fatal error:', error);
    process.exit(1);
});
