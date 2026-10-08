<?php
declare(strict_types=1);

/* Envoy dashboard home API endpoint. */

require __DIR__ . '/../../lib/auth.php';
require __DIR__ . '/../../lib/db.php';

archr_require_auth();
header('Content-Type: application/json');

$pdo = archr_pdo();

$userStmt = $pdo->prepare("SELECT full_name, email FROM system_users WHERE id = :uid");
$userStmt->execute([':uid' => $_SESSION['archr_user_id'] ?? 0]);
$user = $userStmt->fetch() ?: ['full_name' => 'User', 'email' => ''];

// Get new applications count
$newAppsStmt = $pdo->query("
    SELECT COUNT(*) as count
    FROM intake_submissions
    WHERE submission_status = 'submitted'
      AND submitted_at > NOW() - INTERVAL '7 days'
");
$newAppsCount = (int)($newAppsStmt->fetch()['count'] ?? 0);

// Get recent submissions for alerts
$alertsStmt = $pdo->query("
    SELECT id, applicant_first_name, applicant_last_name,
           home_address, submitted_at
    FROM intake_submissions
    WHERE submission_status = 'submitted'
    ORDER BY submitted_at DESC
    LIMIT 5
");
$alerts = $alertsStmt->fetchAll();

$formattedAlerts = array_map(function($a) {
    $dt = new DateTimeImmutable($a['submitted_at']);
    return [
        'type' => 'new_application',
        'title' => 'New Application',
        'message' => sprintf('%s %s - %s',
            $a['applicant_first_name'], $a['applicant_last_name'], $a['home_address']),
        'display_time' => $dt->format('M j, g:i A'),
    ];
}, $alerts);

echo json_encode([
    'success' => true,
    'data' => [
        'user' => ['name' => $user['full_name'], 'email' => $user['email']],
        'stats' => ['new_applications' => $newAppsCount],
        'alerts' => $formattedAlerts,
    ],
], JSON_PRETTY_PRINT);
