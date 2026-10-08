<?php
declare(strict_types=1);

/* -----------------------------------------------------------------
 * Database connection for the /app site.
 *
 * This module provides both the new abstracted database interface
 * (which works with both PostgreSQL and Airtable) and the legacy
 * PDO function for backward compatibility.
 *
 * NEW API (recommended):
 *   $db = archr_db();
 *   $users = $db->select('system_users', ['role' => 'admin']);
 *
 * LEGACY API (for existing code):
 *   $pdo = archr_pdo();  // Only works with PostgreSQL
 *
 * To switch databases, set the DB_DRIVER environment variable:
 *   - DB_DRIVER=postgresql (default)
 *   - DB_DRIVER=airtable
 * ----------------------------------------------------------------- */

require_once __DIR__ . '/database/DatabaseFactory.php';

/**
 * Get the database instance (works with both PostgreSQL and Airtable)
 *
 * @return DatabaseInterface
 */
function archr_db(): DatabaseInterface {
    return DatabaseFactory::create();
}

/**
 * Get PDO connection (legacy function - PostgreSQL only)
 *
 * @deprecated Use archr_db() instead for database abstraction
 * @return PDO
 */
function archr_pdo(): PDO {
    $db = DatabaseFactory::create();

    // Only PostgreSQL supports PDO
    if (DatabaseFactory::getDriver() !== 'postgresql') {
        throw new RuntimeException(
            "archr_pdo() only works with PostgreSQL. " .
            "Current driver: " . DatabaseFactory::getDriver() . ". " .
            "Use archr_db() for database abstraction."
        );
    }

    return $db->getConnection();
}
