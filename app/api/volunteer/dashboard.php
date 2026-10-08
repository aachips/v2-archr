<?php
declare(strict_types=1);

/* Volunteer dashboard home API endpoint. */

require __DIR__ . '/../../lib/auth.php';
require __DIR__ . '/../../lib/db.php';

archr_require_auth();
header('Content-Type: application/json');

$pdo = archr_pdo();
$userId = $_SESSION['archr_user_id'] ?? 0;

$userStmt = $pdo->prepare("SELECT full_name, email FROM system_users WHERE id = :uid");
$userStmt->execute([':uid' => $userId]);
$user = $userStmt->fetch() ?: ['full_name' => 'User', 'email' => ''];

// Get available slots count
$availableStmt = $pdo->query("
    SELECT COUNT(*) as count
    FROM volunteer_slots
    WHERE status = 'open'
      AND scheduled_date >= CURRENT_DATE
");
$availableCount = (int)($availableStmt->fetch()['count'] ?? 0);

// Get upcoming volunteer shifts
$alertsStmt = $pdo->prepare("
    SELECT vs.id, vs.scheduled_date, vs.scheduled_time, vs.required_level,
           cjc.job_name, cjc.site_address
    FROM volunteer_slot_assignments vsa
    JOIN volunteer_slots vs ON vs.id = vsa.slot_id
    LEFT JOIN crew_job_cards cjc ON cjc.id = vs.job_card_id
    WHERE vsa.volunteer_id = :uid
      AND vs.scheduled_date >= CURRENT_DATE
    ORDER BY vs.scheduled_date ASC
    LIMIT 5
");
$alertsStmt->execute([':uid' => $userId]);
$alerts = $alertsStmt->fetchAll();

$formattedAlerts = array_map(function($a) {
    $dt = new DateTimeImmutable($a['scheduled_date'] . ' ' . $a['scheduled_time']);
    return [
        'type' => 'upcoming_shift',
        'title' => 'Upcoming Volunteer Shift',
        'message' => sprintf('%s at %s', $a['job_name'] ?: 'Volunteer work', $a['site_address'] ?: 'TBD'),
        'display_time' => $dt->format('M j, g:i A'),
    ];
}, $alerts);

echo json_encode([
    'success' => true,
    'data' => [
        'user' => ['name' => $user['full_name'], 'email' => $user['email']],
        'stats' => ['available_slots' => $availableCount],
        'alerts' => $formattedAlerts,
    ],
], JSON_PRETTY_PRINT);
