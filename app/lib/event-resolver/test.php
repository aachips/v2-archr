<?php declare(strict_types=1);
/**
 * Test the Event Resolver from the command line.
 *
 * Usage: php app/lib/event-resolver/test.php <caseId>
 *
 * Example: php app/lib/event-resolver/test.php 1
 */

require_once __DIR__ . '/../../lib/db.php';
require_once __DIR__ . '/resolver.php';

if ($argc < 2) {
    echo "Usage: php {$argv[0]} <caseId>\n";
    exit(1);
}

$caseId = (int) $argv[1];
$pdo = archr_pdo();

echo "Resolving case {$caseId}...\n\n";

$start = microtime(true);
$result = archr_resolve($pdo, $caseId);
$elapsed = round((microtime(true) - $start) * 1000, 1);

echo "Phase: {$result['phase']} — {$result['phase_name']}\n";
if ($result['exit_label']) {
    echo "Exit: {$result['exit_label']}\n";
}
echo "Blocked: " . ($result['blocked'] ? 'Yes' : 'No') . "\n";
echo "Resolved in {$elapsed}ms\n\n";

echo "Milestones:\n";
echo str_repeat('-', 60) . "\n";
foreach ($result['milestones'] as $m) {
    $mark = $m['completed'] ? '✅' : '⬜';
    $at = $m['at'] ? ' (' . $m['at'] . ')' : '';
    printf("  %s %s: %s%s\n", $mark, $m['code'], $m['name'], $at);
}

echo "\nNext actions:\n";
foreach ($result['next_actions'] as $i => $action) {
    printf("  %d. %s\n", $i + 1, $action);
}

echo "\n";
