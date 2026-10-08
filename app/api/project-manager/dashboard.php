<?php
declare(strict_types=1);

/* Project Manager dashboard home API endpoint.
   Returns welcome, alerts, stats, and quick access data. */

require __DIR__ . '/../../lib/auth.php';
require __DIR__ . '/../../lib/db.php';

archr_require_auth();
header('Content-Type: application/json');

$pdo = archr_pdo();
$userId = $_SESSION['archr_user_id'] ?? 0;

// Get user info
$userStmt = $pdo->prepare("
    SELECT full_name, email
    FROM system_users
    WHERE id = :uid
");
$userStmt->execute([':uid' => $userId]);
$user = $userStmt->fetch() ?: ['full_name' => 'User', 'email' => ''];

// Get active projects count
$activeStmt = $pdo->query("
    SELECT COUNT(*) as count
    FROM work_orders
    WHERE status IN ('in_progress', 'scheduled')
");
$activeCount = (int)($activeStmt->fetch()['count'] ?? 0);

// Get unclaimed jobs
$unclaimedStmt = $pdo->query("
    SELECT COUNT(*) as count
    FROM work_orders
    WHERE project_manager_id IS NULL
      AND status = 'approved'
");
$unclaimedCount = (int)($unclaimedStmt->fetch()['count'] ?? 0);

// Get recent alerts/events
$alertsStmt = $pdo->query("
    SELECT pe.id, pe.event_type, pe.severity, pe.description,
           pe.created_at, wo.case_id, c.case_number
    FROM project_escalations pe
    JOIN work_orders wo ON wo.id = pe.work_order_id
    LEFT JOIN cases c ON c.id = wo.case_id
    WHERE pe.resolved_at IS NULL
      AND pe.created_at > NOW() - INTERVAL '7 days'
    ORDER BY pe.severity DESC, pe.created_at DESC
    LIMIT 10
");
$alerts = $alertsStmt->fetchAll();

$formattedAlerts = array_map(function($alert) {
    $createdAt = new DateTimeImmutable($alert['created_at']);
    return [
        'id' => (int)$alert['id'],
        'type' => $alert['event_type'],
        'severity' => $alert['severity'],
        'title' => ucwords(str_replace('_', ' ', $alert['event_type'])),
        'message' => $alert['description'],
        'case_number' => $alert['case_number'],
        'created_at' => $createdAt->format('Y-m-d H:i:s'),
        'display_time' => $createdAt->format('M j, g:i A'),
    ];
}, $alerts);

echo json_encode([
    'success' => true,
    'data' => [
        'user' => [
            'name' => $user['full_name'],
            'email' => $user['email'],
        ],
        'stats' => [
            'active_projects' => $activeCount,
            'unclaimed_jobs' => $unclaimedCount,
        ],
        'alerts' => $formattedAlerts,
    ],
], JSON_PRETTY_PRINT);
