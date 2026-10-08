<?php
declare(strict_types=1);

/* Crew Lead dashboard home API endpoint. */

require __DIR__ . '/../../lib/auth.php';
require __DIR__ . '/../../lib/db.php';

archr_require_auth();
header('Content-Type: application/json');

$pdo = archr_pdo();
$userId = $_SESSION['archr_user_id'] ?? 0;

// Get user info
$userStmt = $pdo->prepare("SELECT full_name, email FROM system_users WHERE id = :uid");
$userStmt->execute([':uid' => $userId]);
$user = $userStmt->fetch() ?: ['full_name' => 'User', 'email' => ''];

// Get job counts
$statsStmt = $pdo->prepare("
    SELECT
        COUNT(*) as total_jobs,
        SUM(CASE WHEN status = 'in_progress' THEN 1 ELSE 0 END) as in_progress,
        SUM(CASE WHEN status = 'scheduled' THEN 1 ELSE 0 END) as scheduled,
        SUM(CASE WHEN scheduled_date::date = CURRENT_DATE THEN 1 ELSE 0 END) as today
    FROM crew_job_cards
    WHERE crew_lead_id = :uid
      AND status NOT IN ('completed', 'cancelled')
");
$statsStmt->execute([':uid' => $userId]);
$stats = $statsStmt->fetch();

// Get upcoming jobs for alerts
$alertsStmt = $pdo->prepare("
    SELECT cjc.job_name, cjc.site_address, cjc.scheduled_date
    FROM crew_job_cards cjc
    WHERE cjc.crew_lead_id = :uid
      AND cjc.scheduled_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '3 days'
    ORDER BY cjc.scheduled_date ASC
    LIMIT 5
");
$alertsStmt->execute([':uid' => $userId]);
$alerts = $alertsStmt->fetchAll();

$formattedAlerts = array_map(function($a) {
    $dt = new DateTimeImmutable($a['scheduled_date']);
    return [
        'type' => 'upcoming_job',
        'title' => 'Upcoming Job',
        'message' => sprintf('%s at %s', $a['job_name'], $a['site_address']),
        'scheduled_date' => $dt->format('Y-m-d'),
        'display_time' => $dt->format('M j, Y'),
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
            'total_jobs' => (int)$stats['total_jobs'],
            'in_progress' => (int)$stats['in_progress'],
            'scheduled' => (int)$stats['scheduled'],
            'today' => (int)$stats['today'],
        ],
        'alerts' => $formattedAlerts,
    ],
], JSON_PRETTY_PRINT);
