#!/usr/bin/env node

/**
 * Test script to verify SQL parsing works correctly
 * Run this before executing build-airtable.js to preview what will be created
 */

const fs = require('fs');
const path = require('path');

// The SQL schema lives at the repository root (../../sql); only fall back to
// a local sql/ directory if someone copies one in.
const LOCAL_SQL_DIR = path.join(__dirname, 'sql');
const SQL_DIR = fs.existsSync(path.join(LOCAL_SQL_DIR, '_master.sql'))
  ? LOCAL_SQL_DIR
  : path.join(__dirname, '..', '..', 'sql');
const MASTER_SQL = path.join(SQL_DIR, '_master.sql');

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
    const field = { name: columnName, pgType: pgType };
    
    // Skip auto-generated fields
    if (columnName === 'id' || pgType.startsWith('SERIAL')) {
        return null;
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
    } else if (pgType === 'DATE') {
        field.type = 'date';
    } else if (pgType.startsWith('TIMESTAMP')) {
        field.type = 'dateTime';
    } else if (pgType === 'UUID') {
        field.type = 'singleLineText';
    } else if (pgType === 'JSON' || pgType === 'JSONB') {
        field.type = 'multilineText';
    } else {
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

// Main
console.log('ARCHR SQL Parser Test\n');
console.log('='.repeat(60));

const sqlFiles = getSQLFilesFromMaster();
console.log(`\nFound ${sqlFiles.length} SQL files in master script\n`);

const allTables = [];
for (const sqlFile of sqlFiles) {
    const filePath = path.join(SQL_DIR, sqlFile);
    
    if (!fs.existsSync(filePath)) {
        console.log(`⚠ SKIP: ${sqlFile} (not found)`);
        continue;
    }
    
    const tables = parseSQLFile(filePath);
    console.log(`${sqlFile}:`);
    tables.forEach(t => {
        console.log(`  - ${t.name} (${t.fields.length} fields)`);
    });
    allTables.push(...tables);
}

console.log('\n' + '='.repeat(60));
console.log(`\nTotal: ${allTables.length} tables with ${allTables.reduce((sum, t) => sum + t.fields.length, 0)} fields\n`);

// Show first few tables in detail
console.log('Sample table details (first 3):\n');
allTables.slice(0, 3).forEach(table => {
    console.log(`\n${table.name} (from ${table.sourceFile}):`);
    table.fields.forEach(field => {
        console.log(`  • ${field.name}: ${field.type}${field.pgType ? ` [${field.pgType}]` : ''}`);
    });
});
