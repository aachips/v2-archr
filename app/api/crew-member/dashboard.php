<?php
declare(strict_types=1);

/* Crew Member dashboard home API endpoint. */

require __DIR__ . '/../../lib/auth.php';
require __DIR__ . '/../../lib/db.php';

archr_require_auth();
header('Content-Type: application/json');

$pdo = archr_pdo();
$userId = $_SESSION['archr_user_id'] ?? 0;

$userStmt = $pdo->prepare("SELECT full_name, email FROM system_users WHERE id = :uid");
$userStmt->execute([':uid' => $userId]);
$user = $userStmt->fetch() ?: ['full_name' => 'User', 'email' => ''];

// Get today's assignments
$todayStmt = $pdo->prepare("
    SELECT COUNT(*) as count
    FROM crew_assignments ca
    JOIN crew_job_cards cjc ON cjc.id = ca.job_card_id
    WHERE ca.crew_member_id = :uid
      AND cjc.scheduled_date::date = CURRENT_DATE
");
$todayStmt->execute([':uid' => $userId]);
$todayCount = (int)($todayStmt->fetch()['count'] ?? 0);

// Get upcoming jobs
$alertsStmt = $pdo->prepare("
    SELECT cjc.job_name, cjc.site_address, cjc.scheduled_date,
           u.full_name as crew_lead_name
    FROM crew_assignments ca
    JOIN crew_job_cards cjc ON cjc.id = ca.job_card_id
    JOIN system_users u ON u.id = cjc.crew_lead_id
    WHERE ca.crew_member_id = :uid
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
        'title' => 'Upcoming Assignment',
        'message' => sprintf('%s at %s (Lead: %s)',
            $a['job_name'], $a['site_address'], $a['crew_lead_name']),
        'display_time' => $dt->format('M j, Y'),
    ];
}, $alerts);

echo json_encode([
    'success' => true,
    'data' => [
        'user' => ['name' => $user['full_name'], 'email' => $user['email']],
        'stats' => ['today_assignments' => $todayCount],
        'alerts' => $formattedAlerts,
    ],
], JSON_PRETTY_PRINT);
