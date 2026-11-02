# Database Abstraction Layer

This application supports both **PostgreSQL** and **Airtable** as backend databases. You can switch between them with a single configuration change.

## 🎯 Quick Switch

Change one environment variable to switch databases:

```bash
# Use PostgreSQL (default)
export DB_DRIVER=postgresql

# Use Airtable
export DB_DRIVER=airtable
export AIRTABLE_API_KEY=your_api_key
```

## 📁 Files Structure

```
app/
├── config/
│   └── database.php          # Database configuration
├── lib/
│   ├── db.php                # Main database connection
│   └── database/
│       ├── DatabaseInterface.php      # Common interface
│       ├── PostgreSQLDatabase.php     # PostgreSQL implementation
│       ├── AirtableDatabase.php       # Airtable implementation
│       └── DatabaseFactory.php        # Creates the right database
├── examples/
│   └── database-example.php  # Usage examples
├── DATABASE_SWITCHING_GUIDE.md
└── DATABASE_README.md        # This file
```

## 🚀 Usage

### New API (Recommended)

Works with both PostgreSQL and Airtable:

```php
<?php
require_once __DIR__ . '/lib/db.php';

$db = archr_db();

// SELECT
$users = $db->select('system_users', ['role' => 'admin']);

// FIND
$user = $db->find('system_users', 123);

// INSERT
$id = $db->insert('system_users', [
    'name' => 'John Doe',
    'email' => 'john@example.com',
]);

// UPDATE
$db->update('system_users', 123, ['status' => 'active']);

// DELETE
$db->delete('system_users', 123);

// COUNT
$count = $db->count('system_users', ['role' => 'admin']);
```

### Legacy API

For backward compatibility with existing code (PostgreSQL only):

```php
<?php
$pdo = archr_pdo(); // Returns PDO instance
$stmt = $pdo->query("SELECT * FROM system_users");
```

## ⚙️ Configuration

### PostgreSQL Configuration

Set via environment variables or defaults in `app/config/database.php`:

- **PGHOST**: Database host (default: 127.0.0.1)
- **PGPORT**: Database port (default: 5432)
- **PGDATABASE**: Database name (default: archr)
- **PGUSER**: Database user (default: postgres)
- **PGPASSWORD**: Database password

### Airtable Configuration

1. **Get API Key**: https://airtable.com/create/tokens
2. **Set Environment Variable**: `AIRTABLE_API_KEY=your_key`
3. **Configure Table Mappings**: Edit `app/config/database.php`

```php
'table_mappings' => [
    'intake_submissions' => [
        'base' => 'repair_requests',
        'table_id' => 'tblXXXXXXXXXXXXXX',
    ],
]
```

Base IDs are already configured. Find table IDs from:
- Right-click table → Copy table URL
- Format: `https://airtable.com/appXXX/tblYYY/...`
- Use `tblYYY` as the `table_id`

## 📊 Feature Comparison

| Feature | PostgreSQL | Airtable |
|---------|-----------|----------|
| CRUD Operations | ✅ | ✅ |
| Filtering | ✅ Full SQL | ⚠️ Basic |
| Transactions | ✅ | ❌ |
| Raw SQL | ✅ | ❌ |
| Joins | ✅ | ❌ |
| Performance | ⚡ Very fast | ⚠️ API limits |

## 🔄 Migration Tips

### From PostgreSQL to Airtable

1. Set `DB_DRIVER=airtable`
2. Configure table mappings in `app/config/database.php`
3. Replace raw SQL with abstracted methods
4. Remove transaction logic
5. Simplify complex queries

### From Airtable to PostgreSQL

1. Apply SQL schema: `psql -d archr -f sql/apply-additions.sql`
2. Set `DB_DRIVER=postgresql`
3. Can use advanced features (transactions, raw SQL, etc.)

## 📝 Examples

See `app/examples/database-example.php` for complete examples.

### Database-Agnostic Function

```php
function getActiveUsers() {
    $db = archr_db();
    return $db->select('system_users', ['status' => 'active']);
}
```

This works with both PostgreSQL and Airtable!

### Driver-Specific Code

```php
if (DatabaseFactory::getDriver() === 'postgresql') {
    // Use PostgreSQL features
    $db->beginTransaction();
    // ...
    $db->commit();
} else {
    // Airtable doesn't support transactions
    // Just do the operations directly
}
```

## 🛠️ For Developers

### Adding a New Database Driver

1. Create `app/lib/database/NewDatabase.php` implementing `DatabaseInterface`
2. Add configuration in `app/config/database.php`
3. Update `DatabaseFactory::create()` to handle the new driver

### Testing

```bash
# Test with PostgreSQL
export DB_DRIVER=postgresql
php app/examples/database-example.php

# Test with Airtable
export DB_DRIVER=airtable
export AIRTABLE_API_KEY=your_key
php app/examples/database-example.php
```

## 📖 Further Reading

- [DATABASE_SWITCHING_GUIDE.md](DATABASE_SWITCHING_GUIDE.md) - Detailed guide
- [documentation/task-engine/postgres-v-airtable.md](../documentation/task-engine/postgres-v-airtable.md) - Comparison
