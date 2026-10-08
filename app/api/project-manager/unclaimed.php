<?php
declare(strict_types=1);

/* Project Manager unclaimed jobs API endpoint. */

require __DIR__ . '/../../lib/auth.php';
require __DIR__ . '/../../lib/db.php';

archr_require_auth();
header('Content-Type: application/json');

$pdo = archr_pdo();

$stmt = $pdo->query("
    SELECT wo.id, wo.status, wo.estimated_cost, wo.created_at,
           c.case_number, c.id as case_id,
           s.home_address, s.home_city, s.home_state,
           s.applicant_first_name, s.applicant_last_name,
           STRING_AGG(DISTINCT rc.category_label, ', ') as scope,
           EXTRACT(DAY FROM NOW() - wo.created_at) as days_waiting
    FROM work_orders wo
    JOIN cases c ON c.id = wo.case_id
    JOIN intake_submissions s ON s.id = c.submission_id
    LEFT JOIN work_order_tasks wot ON wot.work_order_id = wo.id
    LEFT JOIN repair_categories rc ON rc.id = wot.repair_category_id
    WHERE wo.project_manager_id IS NULL
      AND wo.status = 'approved'
    GROUP BY wo.id
    ORDER BY wo.created_at ASC
");
$jobs = $stmt->fetchAll();

$formatted = array_map(function($j) {
    $createdAt = new DateTimeImmutable($j['created_at']);
    return [
        'id' => (int)$j['id'],
        'case_number' => $j['case_number'],
        'case_id' => (int)$j['case_id'],
        'scope' => $j['scope'] ?: 'General repairs',
        'address' => sprintf('%s, %s, %s',
            $j['home_address'],
            $j['home_city'],
            $j['home_state']
        ),
        'applicant' => $j['applicant_first_name'] . ' ' . $j['applicant_last_name'],
        'estimated_cost' => (float)$j['estimated_cost'],
        'created_at' => $createdAt->format('Y-m-d H:i:s'),
        'created_date' => $createdAt->format('M j, Y'),
        'days_waiting' => (int)$j['days_waiting'],
    ];
}, $jobs);

echo json_encode([
    'success' => true,
    'data' => $formatted,
    'count' => count($formatted),
], JSON_PRETTY_PRINT);
