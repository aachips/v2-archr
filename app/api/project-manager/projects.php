<?php
declare(strict_types=1);

/* Project Manager active projects list API endpoint. */

require __DIR__ . '/../../lib/auth.php';
require __DIR__ . '/../../lib/db.php';

archr_require_auth();
header('Content-Type: application/json');

$pdo = archr_pdo();

$stmt = $pdo->query("
    SELECT wo.id, wo.status, wo.estimated_cost, wo.actual_cost,
           wo.scheduled_start_date, wo.scheduled_end_date,
           wo.progress_percentage,
           c.case_number, c.id as case_id,
           s.home_address, s.home_city, s.home_state,
           s.applicant_first_name, s.applicant_last_name,
           u.full_name as crew_lead_name,
           STRING_AGG(DISTINCT rc.category_label, ', ') as scope
    FROM work_orders wo
    JOIN cases c ON c.id = wo.case_id
    JOIN intake_submissions s ON s.id = c.submission_id
    LEFT JOIN system_users u ON u.id = wo.crew_lead_id
    LEFT JOIN work_order_tasks wot ON wot.work_order_id = wo.id
    LEFT JOIN repair_categories rc ON rc.id = wot.repair_category_id
    WHERE wo.status IN ('in_progress', 'scheduled', 'approved')
    GROUP BY wo.id
    ORDER BY wo.scheduled_start_date ASC
");
$projects = $stmt->fetchAll();

$formatted = array_map(function($p) {
    $scheduledStart = $p['scheduled_start_date'] ? new DateTimeImmutable($p['scheduled_start_date']) : null;
    $scheduledEnd = $p['scheduled_end_date'] ? new DateTimeImmutable($p['scheduled_end_date']) : null;

    // Calculate if project is on schedule
    $isOnSchedule = true;
    $daysRemaining = 0;
    if ($scheduledEnd) {
        $now = new DateTimeImmutable();
        $daysRemaining = (int)$now->diff($scheduledEnd)->format('%r%a');
        $expectedProgress = 100;
        if ($scheduledStart && $scheduledEnd > $scheduledStart) {
            $totalDays = (int)$scheduledStart->diff($scheduledEnd)->days;
            $elapsedDays = (int)$scheduledStart->diff($now)->days;
            if ($totalDays > 0) {
                $expectedProgress = min(100, ($elapsedDays / $totalDays) * 100);
            }
        }
        $isOnSchedule = ((float)$p['progress_percentage'] >= $expectedProgress - 10);
    }

    return [
        'id' => (int)$p['id'],
        'case_number' => $p['case_number'],
        'case_id' => (int)$p['case_id'],
        'status' => $p['status'],
        'scope' => $p['scope'] ?: 'General repairs',
        'address' => sprintf('%s, %s, %s',
            $p['home_address'],
            $p['home_city'],
            $p['home_state']
        ),
        'applicant' => $p['applicant_first_name'] . ' ' . $p['applicant_last_name'],
        'crew_lead' => $p['crew_lead_name'],
        'progress_percentage' => (float)$p['progress_percentage'],
        'estimated_cost' => (float)$p['estimated_cost'],
        'actual_cost' => (float)$p['actual_cost'],
        'scheduled_start' => $scheduledStart ? $scheduledStart->format('Y-m-d') : null,
        'scheduled_end' => $scheduledEnd ? $scheduledEnd->format('Y-m-d') : null,
        'is_on_schedule' => $isOnSchedule,
        'days_remaining' => $daysRemaining,
    ];
}, $projects);

echo json_encode([
    'success' => true,
    'data' => $formatted,
], JSON_PRETTY_PRINT);
