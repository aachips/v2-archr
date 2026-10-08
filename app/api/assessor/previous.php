<?php
declare(strict_types=1);

/* Assessor previous/completed assessments API endpoint. */

require __DIR__ . '/../../lib/auth.php';
require __DIR__ . '/../../lib/db.php';

archr_require_auth();
header('Content-Type: application/json');

$pdo = archr_pdo();
$userId = $_SESSION['archr_user_id'] ?? 0;

$stmt = $pdo->prepare("
    SELECT a.id, a.scheduled_at, a.completed_at, a.status,
           s.home_address, s.home_city, s.home_state,
           s.applicant_first_name, s.applicant_last_name,
           c.case_number,
           COUNT(ap.id) as photo_count
    FROM assessments a
    JOIN intake_submissions s ON s.id = a.submission_id
    LEFT JOIN cases c ON c.submission_id = s.id
    LEFT JOIN assessment_photos ap ON ap.assessment_id = a.id
    WHERE a.assessor_id = :uid
      AND a.status IN ('completed', 'draft')
    GROUP BY a.id
    ORDER BY COALESCE(a.completed_at, a.scheduled_at) DESC
    LIMIT 50
");
$stmt->execute([':uid' => $userId]);
$assessments = $stmt->fetchAll();

$formatted = array_map(function($a) {
    $date = $a['completed_at'] ?: $a['scheduled_at'];
    $dt = new DateTimeImmutable($date);
    return [
        'id' => (int)$a['id'],
        'case_number' => $a['case_number'],
        'completed_at' => $a['completed_at'],
        'date' => $dt->format('M j, Y'),
        'status' => $a['status'],
        'state' => $a['status'],
        'address' => sprintf('%s, %s, %s',
            $a['home_address'],
            $a['home_city'],
            $a['home_state']
        ),
        'client' => $a['applicant_first_name'] . ' ' . $a['applicant_last_name'],
        'photo_count' => (int)$a['photo_count'],
    ];
}, $assessments);

echo json_encode([
    'success' => true,
    'data' => $formatted,
], JSON_PRETTY_PRINT);
