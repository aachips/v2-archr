<?php
declare(strict_types=1);

/* Project Manager escalations API endpoint. */

require __DIR__ . '/../../lib/auth.php';
require __DIR__ . '/../../lib/db.php';

archr_require_auth();
header('Content-Type: application/json');

$pdo = archr_pdo();

$stmt = $pdo->query("
    SELECT pe.id, pe.event_type, pe.severity, pe.description,
           pe.created_at, pe.resolved_at,
           wo.id as work_order_id,
           c.case_number, c.id as case_id,
           s.home_address
    FROM project_escalations pe
    JOIN work_orders wo ON wo.id = pe.work_order_id
    LEFT JOIN cases c ON c.id = wo.case_id
    LEFT JOIN intake_submissions s ON s.id = c.submission_id
    WHERE pe.resolved_at IS NULL
    ORDER BY pe.severity DESC, pe.created_at DESC
");
$escalations = $stmt->fetchAll();

$formatted = array_map(function($e) {
    $createdAt = new DateTimeImmutable($e['created_at']);
    return [
        'id' => (int)$e['id'],
        'work_order_id' => (int)$e['work_order_id'],
        'case_number' => $e['case_number'],
        'case_id' => (int)$e['case_id'],
        'event_type' => $e['event_type'],
        'severity' => $e['severity'],
        'title' => ucwords(str_replace('_', ' ', $e['event_type'])),
        'description' => $e['description'],
        'address' => $e['home_address'],
        'created_at' => $createdAt->format('Y-m-d H:i:s'),
        'created_date' => $createdAt->format('M j, Y'),
        'display_time' => $createdAt->format('M j, g:i A'),
    ];
}, $escalations);

echo json_encode([
    'success' => true,
    'data' => $formatted,
    'count' => count($formatted),
], JSON_PRETTY_PRINT);
