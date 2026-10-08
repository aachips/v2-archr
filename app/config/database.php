<?php
declare(strict_types=1);

/**
 * Database Configuration
 *
 * Switch which database the app READS from by changing DB_DRIVER
 * ('postgresql' or 'airtable'). Writes via DualDatabaseWriter always go
 * to PostgreSQL first and then to Airtable when a token is configured.
 *
 * Credentials are resolved in this order:
 *   1. Real environment variables (always win)
 *   2. A secure config file OUTSIDE the web root, as a sibling of
 *      public_html (works whether the app IS public_html or lives in
 *      public_html/app):
 *        /home/<you>/secure_config/archr_connect.php
 *      Copy app/config/archr_connect.example.php and fill in real values.
 *      Override the search path with the ARCHR_SECURE_CONFIG env var.
 *   3. A PAT.txt file next to this config (local development only)
 *   4. Built-in local-development defaults
 *
 * Usage:
 *   require __DIR__ . '/../config/database.php';
 *   $config = get_database_config();
 */

/**
 * Keys the secure config file is allowed to set. Anything else is ignored.
 */
function archr_secure_config_allowed_keys(): array {
    return [
        'DB_DRIVER',
        'PGHOST', 'PGPORT', 'PGDATABASE', 'PGUSER', 'PGPASSWORD',
        'AIRTABLE_PAT', 'AIRTABLE_TOKEN', 'AIRTABLE_API_KEY',
        'AIRTABLE_INTAKE_BASE_ID',
        'DROPBOX_ACCESS_TOKEN', 'DROPBOX_APP_KEY', 'DROPBOX_APP_SECRET',
        'DROPBOX_REFRESH_TOKEN', 'DROPBOX_ROOT_PATH',
        'APP_ENV', 'APP_DEBUG',
    ];
}

/**
 * Load credentials/settings from the secure config file outside the web root
 * into the environment (only for keys that are not already real env vars).
 * Runs at most once per request. Never echoes secret values.
 */
function archr_load_secure_config(): void {
    static $loaded = false;
    if ($loaded) {
        return;
    }
    $loaded = true;

    $appRoot = dirname(__DIR__); // the app/ directory (public_html on the web host)

    $candidates = [];
    $override = getenv('ARCHR_SECURE_CONFIG');
    if ($override) {
        $candidates[] = $override;
    }
    // Outside the web root, farthest first so a file outside public_html
    // always wins over one inside it. Covers both host layouts:
    //   app at public_html/app  -> sibling of public_html (two levels up)
    //   app IS public_html      -> sibling of public_html (one level up)
    // Locally, one level up from app/ is <repo>/secure_config/ (gitignored).
    $candidates[] = dirname(dirname($appRoot)) . '/secure_config/archr_connect.php';
    $candidates[] = dirname($appRoot) . '/secure_config/archr_connect.php';
    // Inside the app root (local-development fallback only; gitignored).
    $candidates[] = $appRoot . '/secure_config/archr_connect.php';

    $file = null;
    foreach ($candidates as $candidate) {
        if (is_file($candidate)) {
            $file = $candidate;
            break;
        }
    }

    // Status is recorded for diagnostics (paths + key NAMES only, never values).
    $GLOBALS['archr_secure_config_status'] = [
        'file'     => $file,
        'searched' => $candidates,
        'keys'     => [],
    ];

    if ($file === null) {
        return;
    }

    $settings = include $file;
    if (!is_array($settings)) {
        error_log('[ARCHR] Secure config at ' . $file . ' did not return an array; ignoring it.');
        return;
    }

    foreach (archr_secure_config_allowed_keys() as $key) {
        if (!array_key_exists($key, $settings)) {
            continue;
        }
        $value = trim((string)$settings[$key]);
        if ($value === '') {
            continue;
        }
        // Real environment variables always win over the file.
        $existing = getenv($key);
        if ($existing === false || $existing === '') {
            putenv($key . '=' . $value);
            $_ENV[$key] = $value;
            $_SERVER[$key] = $value;
            $GLOBALS['archr_secure_config_status']['keys'][] = $key;
        }
    }
}

/**
 * Diagnostic status for the secure config loader (safe to display:
 * contains file paths and key names only, never secret values).
 *
 * @return array{file: ?string, searched: string[], keys: string[]}
 */
function archr_secure_config_status(): array {
    archr_load_secure_config();
    return $GLOBALS['archr_secure_config_status'] ?? ['file' => null, 'searched' => [], 'keys' => []];
}

/**
 * Get database configuration
 *
 * @return array{
 *   driver: string,
 *   postgresql: array{host: string, port: string, database: string, user: string, password: string},
 *   airtable: array{api_key: string, personal_access_token: string, bases: array<string, string>, table_mappings: array<string, array>}
 * }
 */
function get_database_config(): array {
    archr_load_secure_config();

    // ================================================================
    // PRIMARY SETTING: DB_DRIVER selects which database the app READS
    // from. Options: 'postgresql' (default) or 'airtable'.
    // ================================================================
    $driver = getenv('DB_DRIVER') ?: 'postgresql';

    $config = ['driver' => $driver];
    
    // ================================================================
    // PostgreSQL Configuration
    // Always loaded: DualDatabaseWriter must write to PostgreSQL even
    // when the app is configured to READ from Airtable.
    // ================================================================
    $config['postgresql'] = [
        'host'     => getenv('PGHOST')     ?: '127.0.0.1',
        'port'     => getenv('PGPORT')     ?: '5432',
        'database' => getenv('PGDATABASE') ?: 'archr',
        'user'     => getenv('PGUSER')     ?: 'postgres',
        'password' => getenv('PGPASSWORD') ?: 'dumps-cassie-looks-trusts-nils-rubies',
    ];

    // ================================================================
    // Airtable Configuration
    // Always load for dual-write support (even when PostgreSQL is primary)
    // ================================================================
    if ($driver === 'airtable' || $driver === 'postgresql') {
        // Prefer env vars (including ones loaded from secure_config), then a
        // PAT.txt file next to this config or in the app root (local dev only).
        $pat = getenv('AIRTABLE_PAT') ?: getenv('AIRTABLE_TOKEN') ?: '';
        if (!$pat) {
            foreach ([__DIR__ . '/PAT.txt', __DIR__ . '/../PAT.txt'] as $patFile) {
                if (is_file($patFile)) {
                    $pat = trim((string)file_get_contents($patFile));
                    break;
                }
            }
        }
        $apiKey = getenv('AIRTABLE_API_KEY') ?: '';

        // The dummy Airtable base built by build-airtable.js is appiMfIEzULJtmi5v.
        // Override with AIRTABLE_INTAKE_BASE_ID if you are using a different base.
        $intakeBaseId = getenv('AIRTABLE_INTAKE_BASE_ID') ?: 'appiMfIEzULJtmi5v';

        $config['airtable'] = [
            // Support both API Key (legacy) and Personal Access Token (PAT)
            'api_key' => $apiKey,
            'personal_access_token' => $pat,

            // Base IDs from documentation/baseID-airtable-guide.md
            'bases' => [
                'documents'        => 'appjB8RyRb8VryrTd',  // ARCHR Project Documents
                'anchor_records'   => 'appWAmMNCsnsAgyTW',  // ANCHOR Records (v1-2)
                'directory'        => 'appfCMatXfknvXNkc',  // ARCHR Directory (v2)
                'task_library'     => 'appfhuefuekoCvL3J',  // ARCHR Multi Axis Task Library
                'fillout_results'  => 'appdJHg317xbe3Sd4',  // Fillout Results
                'eligibility'      => 'appIFBi7Rln8yFhCs',  // ARCHR Eligibility
                'progress_tracker' => 'appjHNCJFj14C30X3',  // ARCHR Progress Tracker
                'partner_programs' => 'appAmaLnsO0BTkKAk',  // ARCHR Partner Programs
                'repair_requests'  => 'appBq2Z1a9dssVVbL',  // ARCHR Repair Requests
                'intake_submissions' => $intakeBaseId,      // ARCHR dummy PostgreSQL mirror base
            ],

            // Table mappings (PostgreSQL table name => Airtable table info)
            // Airtable accepts either a table ID or a table name in the URL.
            'table_mappings' => [
                'intake_submissions' => [
                    'base' => 'intake_submissions',
                    'table_id' => 'intake_submissions',
                ],
                'cases' => [
                    'base' => 'intake_submissions',
                    'table_id' => 'cases',
                ],
                'system_users' => [
                    'base' => 'intake_submissions',
                    'table_id' => 'system_users',
                ],
                // Add more mappings as needed
            ],
        ];
    }

    return $config;
}

/**
 * Get the current database driver
 * 
 * @return string 'postgresql' or 'airtable'
 */
function get_database_driver(): string {
    archr_load_secure_config();
    return getenv('DB_DRIVER') ?: 'postgresql';
}

/**
 * Check if using PostgreSQL
 */
function is_postgresql(): bool {
    return get_database_driver() === 'postgresql';
}

/**
 * Check if using Airtable
 */
function is_airtable(): bool {
    return get_database_driver() === 'airtable';
}
