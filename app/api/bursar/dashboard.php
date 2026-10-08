<?php
declare(strict_types=1);

/* Bursar dashboard home API endpoint. */

require __DIR__ . '/../../lib/auth.php';
require __DIR__ . '/../../lib/db.php';

archr_require_auth();
header('Content-Type: application/json');

$pdo = archr_pdo();

$userStmt = $pdo->prepare("SELECT full_name, email FROM system_users WHERE id = :uid");
$userStmt->execute([':uid' => $_SESSION['archr_user_id'] ?? 0]);
$user = $userStmt->fetch() ?: ['full_name' => 'User', 'email' => ''];

// Get pending payments count
$pendingStmt = $pdo->query("
    SELECT COUNT(*) as count
    FROM payments
    WHERE status = 'pending_approval'
");
$pendingCount = (int)($pendingStmt->fetch()['count'] ?? 0);

// Get alerts - pending invoices and approvals
$alertsStmt = $pdo->query("
    SELECT p.id, p.amount, p.payment_type, p.created_at,
           c.case_number, s.applicant_first_name, s.applicant_last_name
    FROM payments p
    LEFT JOIN cases c ON c.id = p.case_id
    LEFT JOIN intake_submissions s ON s.id = c.submission_id
    WHERE p.status = 'pending_approval'
    ORDER BY p.created_at ASC
    LIMIT 5
");
$alerts = $alertsStmt->fetchAll();

$formattedAlerts = array_map(function($a) {
    $dt = new DateTimeImmutable($a['created_at']);
    return [
        'type' => 'pending_payment',
        'title' => 'Payment Pending Approval',
        'message' => sprintf('$%.2f %s for case %s',
            $a['amount'], ucwords(str_replace('_', ' ', $a['payment_type'])), $a['case_number']),
        'display_time' => $dt->format('M j, g:i A'),
    ];
}, $alerts);

echo json_encode([
    'success' => true,
    'data' => [
        'user' => ['name' => $user['full_name'], 'email' => $user['email']],
        'stats' => ['pending_payments' => $pendingCount],
        'alerts' => $formattedAlerts,
    ],
], JSON_PRETTY_PRINT);
