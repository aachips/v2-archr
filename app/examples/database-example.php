<?php
declare(strict_types=1);

/**
 * Database Abstraction Example
 * 
 * This demonstrates how to use the database abstraction layer
 * that works with both PostgreSQL and Airtable.
 * 
 * To switch databases, set the DB_DRIVER environment variable:
 *   $env:DB_DRIVER = "postgresql"  # or "airtable"
 */

require_once __DIR__ . '/../lib/db.php';

echo "=== Database Abstraction Example ===\n\n";

// Get the database instance
$db = archr_db();

// Show current driver
$driver = DatabaseFactory::getDriver();
echo "Current Driver: {$driver}\n\n";

// ================================================================
// Example 1: SELECT with Filters
// ================================================================
echo "Example 1: SELECT with filters\n";
echo "-------------------------------\n";

try {
    // Get active assessors (both PostgreSQL and Airtable)
    $assessors = $db->select(
        'system_users',
        ['role' => 'assessor', 'status' => 'active'],
        ['id', 'name', 'email'],
        10
    );
    
    echo "Found " . count($assessors) . " active assessors\n";
    foreach ($assessors as $assessor) {
        echo "  - {$assessor['name']} ({$assessor['email']})\n";
    }
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}

echo "\n";

// ================================================================
// Example 2: FIND a Single Record
// ================================================================
echo "Example 2: FIND a single record\n";
echo "-------------------------------\n";

try {
    $userId = 1; // Replace with actual user ID
    $user = $db->find('system_users', $userId);
    
    if ($user) {
        echo "Found user: {$user['name']}\n";
        echo "Email: {$user['email']}\n";
        echo "Role: {$user['role']}\n";
    } else {
        echo "User not found\n";
    }
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}

echo "\n";

// ================================================================
// Example 3: INSERT a New Record
// ================================================================
echo "Example 3: INSERT a new record\n";
echo "-------------------------------\n";

try {
    $newId = $db->insert('system_users', [
        'name' => 'Test User',
        'email' => 'test@example.com',
        'role' => 'volunteer',
        'status' => 'active',
    ]);
    
    echo "Created new user with ID: {$newId}\n";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}

echo "\n";

// ================================================================
// Example 4: UPDATE a Record
// ================================================================
echo "Example 4: UPDATE a record\n";
echo "-------------------------------\n";

try {
    $success = $db->update('system_users', 1, [
        'status' => 'active',
    ]);
    
    if ($success) {
        echo "User updated successfully\n";
    } else {
        echo "Update failed\n";
    }
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}

echo "\n";

// ================================================================
// Example 5: COUNT Records
// ================================================================
echo "Example 5: COUNT records\n";
echo "-------------------------------\n";

try {
    $count = $db->count('system_users', ['role' => 'assessor']);
    echo "Total assessors: {$count}\n";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}

echo "\n";

// ================================================================
// Example 6: Database-Specific Features
// ================================================================
echo "Example 6: Database-specific features\n";
echo "-------------------------------\n";

if ($driver === 'postgresql') {
    echo "Using PostgreSQL-specific features:\n";
    
    try {
        // Use raw SQL (only works with PostgreSQL)
        $pdo = archr_pdo();
        $stmt = $pdo->query("SELECT COUNT(*) as total FROM system_users");
        $result = $stmt->fetch();
        echo "  Total users (via raw SQL): {$result['total']}\n";
        
        // Use transactions (only works with PostgreSQL)
        $db->beginTransaction();
        echo "  Transaction started\n";
        // ... do some work ...
        $db->rollback(); // or $db->commit();
        echo "  Transaction rolled back\n";
        
    } catch (Exception $e) {
        echo "  Error: " . $e->getMessage() . "\n";
    }
    
} else if ($driver === 'airtable') {
    echo "Using Airtable (transactions and raw SQL not supported)\n";
    echo "  Use the abstracted methods (select, insert, update, etc.)\n";
}

echo "\n";

// ================================================================
// Example 7: Portable Code (Works with Both)
// ================================================================
echo "Example 7: Portable code\n";
echo "-------------------------------\n";

function getUsersByRole(string $role): array {
    $db = archr_db();
    return $db->select('system_users', ['role' => $role]);
}

try {
    $volunteers = getUsersByRole('volunteer');
    echo "Found " . count($volunteers) . " volunteers\n";
    echo "This code works with both PostgreSQL and Airtable!\n";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}

echo "\n=== Example Complete ===\n";
