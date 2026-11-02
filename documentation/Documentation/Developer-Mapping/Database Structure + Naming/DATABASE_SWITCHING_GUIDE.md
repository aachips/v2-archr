# Database Switching Guide

This guide explains how to switch between PostgreSQL and Airtable databases in the ARCHR application.

## Quick Start

### Switch to PostgreSQL (Default)
```bash
# Windows (PowerShell)
$env:DB_DRIVER = "postgresql"

# Linux/Mac
export DB_DRIVER=postgresql
```

### Switch to Airtable
```bash
# Windows (PowerShell)
$env:DB_DRIVER = "airtable"
$env:AIRTABLE_API_KEY = "your_api_key_here"

# Linux/Mac
export DB_DRIVER=airtable
export AIRTABLE_API_KEY=your_api_key_here
```

## Configuration

### PostgreSQL Configuration
Located in `app/config/database.php`. Can be overridden with environment variables:

- `PGHOST` - Database host (default: 127.0.0.1)
- `PGPORT` - Database port (default: 5432)
- `PGDATABASE` - Database name (default: archr)
- `PGUSER` - Database user (default: postgres)
- `PGPASSWORD` - Database password

### Airtable Configuration
Requires:

1. **API Key** - Set via `AIRTABLE_API_KEY` environment variable
   - Get your API key from: https://airtable.com/create/tokens
   
2. **Table Mappings** - Edit `app/config/database.php` to map PostgreSQL table names to Airtable tables:

```php
'table_mappings' => [
    'intake_submissions' => [
        'base' => 'repair_requests',
        'table_id' => 'tblXXXXXXXXXXXXXX',  // Replace with actual table ID
    ],
    'cases' => [
        'base' => 'progress_tracker',
        'table_id' => 'tblYYYYYYYYYYYYYY',  // Replace with actual table ID
    ],
]
```

## Usage Examples

### Basic CRUD Operations

```php
<?php
require_once __DIR__ . '/lib/db.php';

// Get database instance (works with both PostgreSQL and Airtable)
$db = archr_db();

// SELECT - Get all active users
$users = $db->select('system_users', ['status' => 'active']);

// SELECT with pagination
$users = $db->select('system_users', [], ['id', 'name', 'email'], 50, 0);

// FIND - Get a single record by ID
$user = $db->find('system_users', 123);

// INSERT - Create a new record
$newId = $db->insert('system_users', [
    'name' => 'John Doe',
    'email' => 'john@example.com',
    'role' => 'assessor',
]);

// UPDATE - Modify an existing record
$db->update('system_users', 123, [
    'status' => 'inactive',
]);

// DELETE - Remove a record
$db->delete('system_users', 123);

// COUNT - Count matching records
$count = $db->count('system_users', ['role' => 'assessor']);
```

### PostgreSQL-Specific Features

```php
<?php
// Raw SQL (only works with PostgreSQL)
if (DatabaseFactory::getDriver() === 'postgresql') {
    $pdo = archr_pdo();
    $stmt = $pdo->prepare("SELECT * FROM system_users WHERE created_at > ?");
    $stmt->execute(['2024-01-01']);
    $users = $stmt->fetchAll();
}

// Transactions (only works with PostgreSQL)
if (DatabaseFactory::getDriver() === 'postgresql') {
    $db = archr_db();
    $db->beginTransaction();
    try {
        $db->insert('system_users', [...]);
        $db->insert('user_roles', [...]);
        $db->commit();
    } catch (Exception $e) {
        $db->rollback();
        throw $e;
    }
}
```

### Database-Agnostic Code

```php
<?php
// This code works with both PostgreSQL and Airtable
function getUsersByRole($role) {
    $db = archr_db();
    return $db->select('system_users', ['role' => $role]);
}

function createUser($name, $email, $role) {
    $db = archr_db();
    return $db->insert('system_users', [
        'name' => $name,
        'email' => $email,
        'role' => $role,
    ]);
}
```

## Differences Between PostgreSQL and Airtable

| Feature | PostgreSQL | Airtable |
|---------|-----------|----------|
| **Transactions** | ✅ Supported | ❌ Not supported |
| **Raw SQL** | ✅ Supported | ❌ Not supported |
| **Complex Filters** | ✅ Full SQL | ⚠️ Limited (basic equality) |
| **Joins** | ✅ Supported | ❌ Use separate queries |
| **Performance** | ✅ Very fast | ⚠️ API rate limits |
| **Schema Changes** | ✅ Easy with SQL | ⚠️ Manual in Airtable UI |

## Best Practices

1. **Use the abstracted API** (`archr_db()`) instead of raw PDO when possible
2. **Check the driver** before using PostgreSQL-specific features
3. **Keep filters simple** for Airtable compatibility
4. **Avoid raw SQL** unless PostgreSQL-specific
5. **Test with both databases** if you need portability

## Troubleshooting

### "Table mapping not found" Error
Update `app/config/database.php` to add the table mapping for Airtable.

### "API key not configured" Error
Set the `AIRTABLE_API_KEY` environment variable.

### PDO-related errors with Airtable
Use `archr_db()` instead of `archr_pdo()` for database abstraction.

## Getting Airtable Table IDs

1. Open your Airtable base
2. Right-click on a table tab → "Copy table URL"
3. The URL format is: `https://airtable.com/appXXX/tblYYY/...`
   - `appXXX` = Base ID (already configured in database.php)
   - `tblYYY` = Table ID (use this in table_mappings)
