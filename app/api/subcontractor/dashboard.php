<?php
declare(strict_types=1);

/* Subcontractor dashboard home API endpoint. */

require __DIR__ . '/../../lib/auth.php';
require __DIR__ . '/../../lib/db.php';

archr_require_auth();
header('Content-Type: application/json');

$pdo = archr_pdo();
$userId = $_SESSION['archr_user_id'] ?? 0;

$userStmt = $pdo->prepare("SELECT full_name, email FROM system_users WHERE id = :uid");
$userStmt->execute([':uid' => $userId]);
$user = $userStmt->fetch() ?: ['full_name' => 'User', 'email' => ''];

// Get quote requests count
$requestsStmt = $pdo->prepare("
    SELECT COUNT(*) as count
    FROM subcontractor_quote_requests
    WHERE subcontractor_id = :uid
      AND status = 'pending'
");
$requestsStmt->execute([':uid' => $userId]);
$requestsCount = (int)($requestsStmt->fetch()['count'] ?? 0);

// Get active jobs count
$activeStmt = $pdo->prepare("
    SELECT COUNT(*) as count
    FROM subcontractor_assignments
    WHERE subcontractor_id = :uid
      AND status IN ('assigned', 'in_progress')
");
$activeStmt->execute([':uid' => $userId]);
$activeCount = (int)($activeStmt->fetch()['count'] ?? 0);

// Get alerts - pending quotes and upcoming jobs
$alertsStmt = $pdo->prepare("
    SELECT sqr.id, sqr.requested_at, sqr.due_date,
           c.case_number, s.home_address
    FROM subcontractor_quote_requests sqr
    LEFT JOIN cases c ON c.id = sqr.case_id
    LEFT JOIN intake_submissions s ON s.id = c.submission_id
    WHERE sqr.subcontractor_id = :uid
      AND sqr.status = 'pending'
    ORDER BY sqr.due_date ASC
    LIMIT 5
");
$alertsStmt->execute([':uid' => $userId]);
$alerts = $alertsStmt->fetchAll();

$formattedAlerts = array_map(function($a) {
    $dt = new DateTimeImmutable($a['due_date']);
    return [
        'type' => 'quote_request',
        'title' => 'Quote Request',
        'message' => sprintf('Quote needed for %s (%s)', $a['case_number'], $a['home_address']),
        'display_time' => 'Due ' . $dt->format('M j, Y'),
    ];
}, $alerts);

echo json_encode([
    'success' => true,
    'data' => [
        'user' => ['name' => $user['full_name'], 'email' => $user['email']],
        'stats' => [
            'quote_requests' => $requestsCount,
            'active_jobs' => $activeCount,
        ],
        'alerts' => $formattedAlerts,
    ],
], JSON_PRETTY_PRINT);
