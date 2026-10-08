<?php
declare(strict_types=1);

/* Assessor dashboard home API endpoint.
   Returns the default dashboard data: welcome, alerts, case search, quick tasks. */

require __DIR__ . '/../../lib/auth.php';
require __DIR__ . '/../../lib/db.php';

archr_require_auth();
header('Content-Type: application/json');

$pdo = archr_pdo();
$userId = $_SESSION['archr_user_id'] ?? 0;

// Get user info
$userStmt = $pdo->prepare("
    SELECT full_name, email, territory
    FROM system_users
    WHERE id = :uid
");
$userStmt->execute([':uid' => $userId]);
$user = $userStmt->fetch() ?: ['full_name' => 'User', 'email' => '', 'territory' => 'Unknown'];

// Get today's assessments count
$todayStmt = $pdo->prepare("
    SELECT COUNT(*) as count
    FROM assessments
    WHERE assessor_id = :uid
      AND scheduled_at::date = CURRENT_DATE
      AND status IN ('scheduled', 'in_progress')
");
$todayStmt->execute([':uid' => $userId]);
$todayCount = (int)($todayStmt->fetch()['count'] ?? 0);

// Get upcoming alerts
$alertsStmt = $pdo->prepare("
    SELECT a.id, a.scheduled_at, s.home_address, s.applicant_first_name, s.applicant_last_name
    FROM assessments a
    JOIN intake_submissions s ON s.id = a.submission_id
    WHERE a.assessor_id = :uid
      AND a.scheduled_at > NOW()
      AND a.scheduled_at < NOW() + INTERVAL '7 days'
      AND a.status = 'scheduled'
    ORDER BY a.scheduled_at ASC
    LIMIT 5
");
$alertsStmt->execute([':uid' => $userId]);
$alerts = $alertsStmt->fetchAll();

// Format alerts
$formattedAlerts = array_map(function($alert) {
    $scheduledAt = new DateTimeImmutable($alert['scheduled_at']);
    return [
        'id' => (int)$alert['id'],
        'type' => 'assessment',
        'title' => 'Upcoming Assessment',
        'message' => sprintf(
            'Assessment scheduled for %s at %s',
            $alert['applicant_first_name'] . ' ' . $alert['applicant_last_name'],
            $alert['home_address']
        ),
        'scheduled_at' => $scheduledAt->format('Y-m-d H:i:s'),
        'display_time' => $scheduledAt->format('M j, g:i A'),
    ];
}, $alerts);

echo json_encode([
    'success' => true,
    'data' => [
        'user' => [
            'name' => $user['full_name'],
            'email' => $user['email'],
            'territory' => $user['territory'],
        ],
        'stats' => [
            'today_count' => $todayCount,
        ],
        'alerts' => $formattedAlerts,
    ],
], JSON_PRETTY_PRINT);
