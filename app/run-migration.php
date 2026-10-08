<?php
declare(strict_types=1);

/**
 * Database Migration Runner (Web Interface)
 * 
 * This runs the migration to add username fields to system_users
 * Access via browser: http://localhost/app/run-migration.php
 */

// Security: Only allow from localhost
if (!in_array($_SERVER['REMOTE_ADDR'] ?? '', ['127.0.0.1', '::1', 'localhost'])) {
    http_response_code(403);
    die('Access denied. This script can only be run from localhost.');
}

require_once __DIR__ . '/config/database.php';

?>
<!DOCTYPE html>
<html>
<head>
    <title>ARCHR Database Migration</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
        .success { background: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 15px; border-radius: 5px; }
        .error { background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 15px; border-radius: 5px; }
        .info { background: #d1ecf1; border: 1px solid #bee5eb; color: #0c5460; padding: 15px; border-radius: 5px; }
        pre { background: #f4f4f4; padding: 10px; border-radius: 5px; overflow-x: auto; }
        button { background: #007bff; color: white; border: none; padding: 10px 20px; font-size: 16px; cursor: pointer; border-radius: 5px; }
        button:hover { background: #0056b3; }
        .warning { background: #fff3cd; border: 1px solid #ffeaa7; color: #856404; padding: 15px; border-radius: 5px; }
    </style>
</head>
<body>
    <h1>🔧 ARCHR Database Migration</h1>
    <p><strong>Purpose:</strong> Add missing username fields to system_users table</p>

<?php

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['run_migration'])) {
    echo '<div class="info"><strong>Running migration...</strong></div>';
    echo '<br>';
    
    try {
        // Get database config
        $config = get_database_config();
        
        if (!isset($config['postgresql'])) {
            throw new Exception('PostgreSQL configuration not found');
        }
        
        $pg = $config['postgresql'];
        
        // Connect to database
        $dsn = "pgsql:host={$pg['host']};port={$pg['port']};dbname={$pg['database']}";
        echo '<pre>Connecting to: ' . htmlspecialchars($dsn) . '</pre>';
        
        $pdo = new PDO($dsn, $pg['user'], $pg['password'], [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        ]);
        
        echo '<pre>✅ Connected successfully</pre>';
        
        // Run migration SQL
        $migrationFile = __DIR__ . '/../sql/add/system-users-username-fields.sql';
        
        if (!file_exists($migrationFile)) {
            throw new Exception('Migration file not found: ' . $migrationFile);
        }
        
        $sql = file_get_contents($migrationFile);
        
        echo '<pre>Running migration SQL...</pre>';
        
        // Execute each statement
        $pdo->exec($sql);
        
        echo '<pre>✅ Migration executed successfully</pre>';
        
        // Verify columns exist
        $stmt = $pdo->query("
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name='system_users' 
            AND column_name IN ('username', 'first_name', 'last_name')
            ORDER BY column_name
        ");
        
        $columns = $stmt->fetchAll(PDO::FETCH_COLUMN);
        
        echo '<div class="success">';
        echo '<h3>✅ SUCCESS! Migration completed.</h3>';
        echo '<p><strong>Columns added:</strong></p>';
        echo '<ul>';
        foreach ($columns as $col) {
            echo '<li>' . htmlspecialchars($col) . '</li>';
        }
        echo '</ul>';
        echo '<p><strong>Next steps:</strong></p>';
        echo '<ol>';
        echo '<li>Go to the intake form</li>';
        echo '<li>Submit a test application</li>';
        echo '<li>Credentials should now display properly (not "Loading...")</li>';
        echo '</ol>';
        echo '</div>';
        
    } catch (PDOException $e) {
        echo '<div class="error">';
        echo '<h3>❌ Database Error</h3>';
        echo '<p><strong>Error:</strong> ' . htmlspecialchars($e->getMessage()) . '</p>';
        echo '<p><strong>Common fixes:</strong></p>';
        echo '<ul>';
        echo '<li>Make sure PostgreSQL is running in Laragon</li>';
        echo '<li>Check database credentials in app/config/database.php</li>';
        echo '<li>Verify database "archr" exists</li>';
        echo '</ul>';
        echo '</div>';
    } catch (Exception $e) {
        echo '<div class="error">';
        echo '<h3>❌ Error</h3>';
        echo '<p>' . htmlspecialchars($e->getMessage()) . '</p>';
        echo '</div>';
    }
    
} else {
    // Show form
    echo '<div class="warning">';
    echo '<h3>⚠️ Important</h3>';
    echo '<p>This will modify your database by adding the following columns to <code>system_users</code>:</p>';
    echo '<ul>';
    echo '<li><code>username</code> - Unique username for login</li>';
    echo '<li><code>first_name</code> - User first name</li>';
    echo '<li><code>last_name</code> - User last name</li>';
    echo '</ul>';
    echo '<p>This is safe to run multiple times (uses IF NOT EXISTS).</p>';
    echo '</div>';
    echo '<br>';
    
    // Check current database config
    try {
        $config = get_database_config();
        $pg = $config['postgresql'] ?? null;
        
        if ($pg) {
            echo '<div class="info">';
            echo '<h3>Database Configuration</h3>';
            echo '<ul>';
            echo '<li><strong>Host:</strong> ' . htmlspecialchars($pg['host']) . '</li>';
            echo '<li><strong>Port:</strong> ' . htmlspecialchars($pg['port']) . '</li>';
            echo '<li><strong>Database:</strong> ' . htmlspecialchars($pg['database']) . '</li>';
            echo '<li><strong>User:</strong> ' . htmlspecialchars($pg['user']) . '</li>';
            echo '<li><strong>Password:</strong> ' . (empty($pg['password']) ? '(empty)' : '****') . '</li>';
            echo '</ul>';
            echo '</div>';
            echo '<br>';
        }
    } catch (Exception $e) {
        echo '<div class="error">Could not load database config: ' . htmlspecialchars($e->getMessage()) . '</div>';
        echo '<br>';
    }
    
    echo '<form method="POST">';
    echo '<button type="submit" name="run_migration" value="1">▶️ Run Migration Now</button>';
    echo '</form>';
}

?>

    <br>
    <hr>
    <p><small>This script can only be accessed from localhost for security.</small></p>
</body>
</html>
