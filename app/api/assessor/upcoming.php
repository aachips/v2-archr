<?php
declare(strict_types=1);

/* Assessor upcoming assessments API endpoint. */

require __DIR__ . '/../../lib/auth.php';
require __DIR__ . '/../../lib/db.php';

archr_require_auth();
header('Content-Type: application/json');

$pdo = archr_pdo();
$userId = $_SESSION['archr_user_id'] ?? 0;

$stmt = $pdo->prepare("
    SELECT a.id, a.scheduled_at, a.status, a.estimated_hours,
           s.home_address, s.home_city, s.home_state, s.home_zip,
           s.applicant_first_name, s.applicant_last_name,
           s.cell_phone, s.contact_email,
           c.case_number
    FROM assessments a
    JOIN intake_submissions s ON s.id = a.submission_id
    LEFT JOIN cases c ON c.submission_id = s.id
    WHERE a.assessor_id = :uid
      AND a.scheduled_at > NOW()
      AND a.status IN ('scheduled', 'pending')
    ORDER BY a.scheduled_at ASC
");
$stmt->execute([':uid' => $userId]);
$assessments = $stmt->fetchAll();

$formatted = array_map(function($a) {
    $scheduledAt = new DateTimeImmutable($a['scheduled_at']);
    return [
        'id' => (int)$a['id'],
        'case_number' => $a['case_number'],
        'scheduled_at' => $scheduledAt->format('Y-m-d H:i:s'),
        'date' => $scheduledAt->format('M j, Y'),
        'time' => $scheduledAt->format('g:i A'),
        'day_of_week' => $scheduledAt->format('l'),
        'status' => $a['status'],
        'estimated_hours' => (float)$a['estimated_hours'],
        'address' => sprintf(
            '%s, %s, %s %s',
            $a['home_address'],
            $a['home_city'],
            $a['home_state'],
            $a['home_zip']
        ),
        'applicant' => [
            'name' => $a['applicant_first_name'] . ' ' . $a['applicant_last_name'],
            'phone' => $a['cell_phone'],
            'email' => $a['contact_email'],
        ],
    ];
}, $assessments);

echo json_encode([
    'success' => true,
    'data' => $formatted,
], JSON_PRETTY_PRINT);
