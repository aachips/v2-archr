<?php
declare(strict_types=1);

/* Crew Lead current job API endpoint. */

require __DIR__ . '/../../lib/auth.php';
require __DIR__ . '/../../lib/db.php';

archr_require_auth();
header('Content-Type: application/json');

$pdo = archr_pdo();
$userId = $_SESSION['archr_user_id'] ?? 0;

$stmt = $pdo->prepare("
    SELECT cjc.id, cjc.job_name, cjc.site_address, cjc.case_reference,
           cjc.status, cjc.progress_percentage, cjc.estimated_hours,
           cjc.scheduled_date, cjc.scheduled_start_time,
           c.case_number,
           s.applicant_first_name, s.applicant_last_name
    FROM crew_job_cards cjc
    LEFT JOIN cases c ON c.case_number = cjc.case_reference
    LEFT JOIN intake_submissions s ON s.id = c.submission_id
    WHERE cjc.crew_lead_id = :uid
      AND cjc.is_current_job = 1
    LIMIT 1
");
$stmt->execute([':uid' => $userId]);
$job = $stmt->fetch();

if (!$job) {
    echo json_encode([
        'success' => true,
        'data' => null,
        'message' => 'No current job',
    ]);
    exit;
}

// Get tasks for this job
$tasksStmt = $pdo->prepare("
    SELECT id, task_name, status, estimated_hours, actual_hours
    FROM crew_job_tasks
    WHERE job_card_id = :job_id
    ORDER BY sequence_order ASC
");
$tasksStmt->execute([':job_id' => $job['id']]);
$tasks = $tasksStmt->fetchAll();

$scheduledDate = new DateTimeImmutable($job['scheduled_date']);

echo json_encode([
    'success' => true,
    'data' => [
        'id' => (int)$job['id'],
        'job_name' => $job['job_name'],
        'case_number' => $job['case_number'] ?: $job['case_reference'],
        'site_address' => $job['site_address'],
        'applicant' => ($job['applicant_first_name'] ?? '') . ' ' . ($job['applicant_last_name'] ?? ''),
        'status' => $job['status'],
        'progress_percentage' => (float)$job['progress_percentage'],
        'estimated_hours' => (float)$job['estimated_hours'],
        'scheduled_date' => $scheduledDate->format('Y-m-d'),
        'scheduled_time' => $job['scheduled_start_time'],
        'tasks' => array_map(function($t) {
            return [
                'id' => (int)$t['id'],
                'name' => $t['task_name'],
                'status' => $t['status'],
                'estimated_hours' => (float)$t['estimated_hours'],
                'actual_hours' => (float)($t['actual_hours'] ?: 0),
            ];
        }, $tasks),
    ],
], JSON_PRETTY_PRINT);
