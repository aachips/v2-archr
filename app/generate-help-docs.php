<?php declare(strict_types=1);
/**
 * Help documentation library generator.
 *
 * Scans documentation/start-here/ for markdown files with YAML frontmatter
 * and generates static PHP content files into app/help-content/.
 * Original markdown files are never modified.
 *
 * Usage:
 *   CLI:     php app/generate-help-docs.php
 *   Browser: /app/generate-help-docs.php  (requires admin or super-admin login)
 */

require_once __DIR__ . '/lib/session.php';
require_once __DIR__ . '/lib/doc-library.php';

$isCli = (PHP_SAPI === 'cli');

if (!$isCli) {
    archr_session_start();
    $role = $_SESSION['archr_role'] ?? null;
    if (!in_array($role, ['admin', 'super-admin'], true)) {
        http_response_code(403);
        echo 'Forbidden: help documentation generation requires an admin or super-admin login.';
        exit(1);
    }
}

$report = doc_library_generate();

if ($isCli) {
    $out = function (string $msg): void {
        fwrite(STDOUT, $msg . PHP_EOL);
    };
} else {
    header('Content-Type: text/html; charset=utf-8');
    echo '<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Help Docs Generation</title>';
    echo '<style>body{font-family:monospace;margin:2rem;}h2{margin-top:1.5rem;}li{margin:.15rem 0;}</style></head><body>';
    echo '<h1>Help Documentation Library &mdash; Generation Report</h1>';
    $out = function (string $msg): void {
        echo htmlspecialchars($msg, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8'), '<br>';
    };
}

$out('Generated at: ' . date('c'));
$out('Output dir:  ' . $report['output_dir']);
$out('');

$out('=== INCLUDED (' . count($report['included']) . ') ===');
foreach ($report['included'] as $doc) {
    $out(sprintf('  [%s] %s — %s (%s)', $doc['visibility'], $doc['slug'], $doc['title'], $doc['category']));
}
$out('');

$out('=== SKIPPED (' . count($report['skipped']) . ') ===');
foreach ($report['skipped'] as $doc) {
    $out(sprintf('  %s — %s', $doc['file'], $doc['reason']));
}
$out('');

$out('=== WARNINGS (' . count($report['warnings']) . ') ===');
foreach ($report['warnings'] as $warning) {
    $out('  ' . $warning);
}
$out('');

$out('Images copied: ' . $report['images']);
$out('Done. View the library at help.php');

if (!$isCli) {
    echo '<p><a href="help.php">Open the Help Library</a></p></body></html>';
}
