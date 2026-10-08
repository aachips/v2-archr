<?php declare(strict_types=1);
/**
 * Helper to apply a SQL migration file using the configured PostgreSQL credentials.
 * Usage: php app/apply-migration.php sql/add/migration.sql
 */

if ($argc < 2) {
    fwrite(STDERR, "Usage: {$argv[0]} <path-to-migration.sql>\n");
    exit(1);
}

$path = $argv[1];
if (!is_file($path)) {
    fwrite(STDERR, "Migration file not found: {$path}\n");
    exit(1);
}

require __DIR__ . '/config/database.php';
$config = get_database_config();
$pg = $config['postgresql'] ?? null;
if (!$pg) {
    fwrite(STDERR, "PostgreSQL not configured.\n");
    exit(1);
}

putenv('PGPASSWORD=' . $pg['password']);
$cmd = sprintf(
    'psql -h %s -p %s -U %s -d %s -f %s',
    escapeshellarg($pg['host']),
    escapeshellarg($pg['port']),
    escapeshellarg($pg['user']),
    escapeshellarg($pg['database']),
    escapeshellarg($path)
);

$psqlPath = 'C:\\laragon\\bin\\postgresql\\postgresql\\bin\\psql.exe';
if (is_executable($psqlPath)) {
    $cmd = escapeshellarg($psqlPath) . ' ' . substr($cmd, 4);
}

passthru($cmd, $exitCode);
exit($exitCode);
