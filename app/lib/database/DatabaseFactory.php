<?php
declare(strict_types=1);

require_once __DIR__ . '/DatabaseInterface.php';
require_once __DIR__ . '/PostgreSQLDatabase.php';
require_once __DIR__ . '/AirtableDatabase.php';
require_once __DIR__ . '/../../config/database.php';

/**
 * Database Factory
 * 
 * Creates the appropriate database instance based on configuration.
 * 
 * Usage:
 *   $db = DatabaseFactory::create();
 *   $users = $db->select('system_users', ['role' => 'admin']);
 */
class DatabaseFactory {
    private static ?DatabaseInterface $instance = null;
    
    /**
     * Create or get the database instance
     * 
     * @return DatabaseInterface
     */
    public static function create(): DatabaseInterface {
        if (self::$instance !== null) {
            return self::$instance;
        }
        
        $config = get_database_config();
        
        switch ($config['driver']) {
            case 'postgresql':
                if (!isset($config['postgresql'])) {
                    throw new RuntimeException("PostgreSQL configuration missing");
                }
                self::$instance = new PostgreSQLDatabase($config['postgresql']);
                break;
                
            case 'airtable':
                if (!isset($config['airtable'])) {
                    throw new RuntimeException("Airtable configuration missing");
                }
                $hasToken = !empty($config['airtable']['personal_access_token'])
                    || !empty($config['airtable']['api_key']);
                if (!$hasToken) {
                    throw new RuntimeException(
                        "Airtable credentials not configured. Provide AIRTABLE_PAT " .
                        "(or legacy AIRTABLE_API_KEY) via environment or secure_config."
                    );
                }
                self::$instance = new AirtableDatabase($config['airtable']);
                break;
                
            default:
                throw new RuntimeException("Unknown database driver: {$config['driver']}");
        }
        
        return self::$instance;
    }
    
    /**
     * Reset the instance (useful for testing)
     */
    public static function reset(): void {
        self::$instance = null;
    }
    
    /**
     * Get the current database driver name
     * 
     * @return string 'postgresql' or 'airtable'
     */
    public static function getDriver(): string {
        return get_database_driver();
    }
}
