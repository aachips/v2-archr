<?php declare(strict_types=1);
/**
 * Vue Assessor API — token-authenticated endpoint.
 *
 * GET → returns claimed assessments + unclaimed (marketplace) + completed
 * POST action=claim_assessment → claim an unclaimed submission for assessment
 * POST action=update_assessment_status → update status of a claimed assessment
 */
require_once __DIR__ . '/token-middleware.php';
require_once __DIR__ . '/../lib/db.php';

header('Content-Type: application/json');

function fail(string $message): never {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => $message]);
    exit;
}

function ok(array $data = []): never {
    echo json_encode(array_merge(['success' => true], $data));
    exit;
}

$pdo = archr_pdo();
$user = vue_require_auth_token();
$userId = (int)$user['user_id'];

// ── POST actions ──
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = trim((string)($_POST['action'] ?? ''));

    if ($action === 'claim_assessment') {
        $submissionId = (int)($_POST['submission_id'] ?? 0);
        if ($submissionId <= 0) fail('Submission ID is required.');

        // Verify submission exists and has no assessment yet
        $checkStmt = $pdo->prepare("
            SELECT s.id, s.home_address, s.home_city, s.home_state
              FROM intake_submissions s
             WHERE s.id = :id
               AND NOT EXISTS (SELECT 1 FROM assessments a WHERE a.application_id = s.id)
        ");
        $checkStmt->execute([':id' => $submissionId]);
        $sub = $checkStmt->fetch();
        if (!$sub) fail('Submission not available for assessment.');

        // Create assessment record claimed by this assessor
        $addr = ($sub['home_address'] ?? '') . ', ' . ($sub['home_city'] ?? '') . ', ' . ($sub['home_state'] ?? '');
        $pdo->prepare("
            INSERT INTO assessments (application_id, assessor_id, status, assessor_name, full_address, created_at)
            VALUES (:sid, :aid, 'scheduled', :aname, :addr, NOW())
        ")->execute([
            ':sid' => $submissionId, ':aid' => $userId,
            ':aname' => $user['full_name'] ?? 'Assessor', ':addr' => $addr,
        ]);

        ok(['message' => 'Assessment claimed', 'assessment_id' => (int)$pdo->lastInsertId()]);
    }

    if ($action === 'update_assessment_status') {
        $assessId = (int)($_POST['assessment_id'] ?? 0);
        $status = trim((string)($_POST['status'] ?? ''));
        if ($assessId <= 0 || $status === '') fail('Assessment ID and status required.');

        $checkStmt = $pdo->prepare("SELECT id FROM assessments WHERE id = :id AND assessor_id = :uid");
        $checkStmt->execute([':id' => $assessId, ':uid' => $userId]);
        if (!$checkStmt->fetch()) fail('Access denied.');

        // Build update fields from POST data (only update fields that are provided)
        $fields = ['status' => ':status', 'updated_at' => 'NOW()'];
        $params = [':status' => $status, ':id' => $assessId];

        $textFields = [
            'notes' => 'notes',
            'address' => 'full_address',
            'city' => 'city',
            'state' => 'state',
            'zip' => 'zip',
        ];
        foreach ($textFields as $postKey => $colName) {
            if (isset($_POST[$postKey]) && trim((string)$_POST[$postKey]) !== '') {
                $fields[$colName] = ':' . $postKey;
                $params[':' . $postKey] = trim((string)$_POST[$postKey]);
            }
        }

        if (isset($_POST['estimated_hours']) && is_numeric($_POST['estimated_hours'])) {
            $fields['estimated_duration_hours'] = ':est_hours';
            $params[':est_hours'] = (float)$_POST['estimated_hours'];
        }

        // JSON fields (repair_areas, note metadata, verification flags)
        // These are stored as JSONB in the assessment_details column (if it exists)
        // or we can add them as dedicated columns in a future migration.
        // For now, pack extended data into notes as a structured append.
        $repairAreas = $_POST['repair_areas'] ?? null;
        $noteType = $_POST['note_type'] ?? null;
        $notesPublic = $_POST['notes_public'] ?? null;
        $verifiedId = $_POST['verified_id'] ?? null;
        $verifiedIncome = $_POST['verified_income'] ?? null;
        $verifiedOwnership = $_POST['verified_ownership'] ?? null;

        // Handle uploaded photos
        $photoCount = 0;
        foreach ($_FILES as $key => $file) {
            if ($file['error'] === UPLOAD_ERR_OK) {
                $photoCount++;
                // Photos are stored in uploads/assessments/{assessment_id}/
                // For now, we just count them; file handling would go here
                // or in a separate upload endpoint.
            }
        }

        $setClauses = [];
        foreach ($fields as $col => $val) {
            $setClauses[] = $col . ' = ' . $val;
        }
        $setSql = implode(', ', $setClauses);

        $pdo->prepare("UPDATE assessments SET $setSql WHERE id = :id")
            ->execute($params);

        ok(['message' => 'Status updated', 'photos_received' => $photoCount]);
    }

    fail('Unknown action: ' . $action);
}

// ── GET: return assessments data ──

// 1. Claimed assessments (current, in progress, scheduled)
$claimedStmt = $pdo->prepare("
    SELECT a.id, a.status, a.scheduled_start, a.actual_start, a.actual_end,
           a.estimated_duration_hours, a.travel_distance_miles, a.travel_time_minutes,
           a.notes, a.completion_percentage,
           s.id AS submission_id,
           s.applicant_first_name, s.applicant_last_name,
           s.home_address, s.home_city, s.home_state, s.home_zip,
           s.contact_email, s.home_phone,
           s.submission_status, s.submitted_at,
           aa.case_number, aa.placecode
      FROM assessments a
      LEFT JOIN intake_submissions s ON s.id = a.application_id
      LEFT JOIN application_anchor aa ON aa.submission_id = s.id
     WHERE a.assessor_id = :uid
       AND a.status != 'completed'
     ORDER BY a.scheduled_start ASC NULLS LAST
");
$claimedStmt->execute([':uid' => $userId]);
$claimed = [];
while ($row = $claimedStmt->fetch()) {
    $claimed[] = [
        'id' => (int)$row['id'],
        'submission_id' => $row['submission_id'] ? (int)$row['submission_id'] : null,
        'status' => $row['status'],
        'applicant_name' => trim(($row['applicant_first_name'] ?? '') . ' ' . ($row['applicant_last_name'] ?? '')),
        'address' => $row['home_address'] ?? $row['full_address'] ?? '—',
        'city' => $row['home_city'] ?? '—',
        'state' => $row['home_state'] ?? 'NC',
        'zip' => $row['home_zip'] ?? '',
        'contact_email' => $row['contact_email'],
        'home_phone' => $row['home_phone'],
        'case_number' => $row['case_number'],
        'placecode' => $row['placecode'],
        'scheduled_start' => $row['scheduled_start'],
        'actual_start' => $row['actual_start'],
        'estimated_hours' => $row['estimated_duration_hours'],
        'travel_miles' => $row['travel_distance_miles'],
        'travel_min' => $row['travel_time_minutes'],
        'notes' => $row['notes'],
        'completion_pct' => (int)($row['completion_percentage'] ?? 0),
        'submitted_at' => $row['submitted_at'],
    ];
}

// 2. Marketplace — submissions that need an assessment (no assessment exists)
$marketStmt = $pdo->query("
    SELECT s.id, s.applicant_first_name, s.applicant_last_name,
           s.home_address, s.home_city, s.home_state, s.home_zip,
           s.contact_email, s.home_phone,
           s.submission_status, s.submitted_at,
           s.helene_related, s.urgent_open_to_elements, s.urgent_no_hvac,
           a.case_number, a.placecode, a.eligibility_score
      FROM intake_submissions s
      LEFT JOIN application_anchor a ON a.submission_id = s.id
     WHERE NOT EXISTS (SELECT 1 FROM assessments ass WHERE ass.application_id = s.id)
       AND s.submission_status IN ('pending_review', 'approved')
     ORDER BY s.submitted_at ASC
     LIMIT 50
");
$marketplace = [];
while ($row = $marketStmt->fetch()) {
    $marketplace[] = [
        'id' => (int)$row['id'],
        'applicant_name' => trim(($row['applicant_first_name'] ?? '') . ' ' . ($row['applicant_last_name'] ?? '')),
        'address' => $row['home_address'] ?? '—',
        'city' => $row['home_city'] ?? '—',
        'state' => $row['home_state'] ?? 'NC',
        'zip' => $row['home_zip'] ?? '',
        'contact_email' => $row['contact_email'],
        'home_phone' => $row['home_phone'],
        'case_number' => $row['case_number'],
        'placecode' => $row['placecode'],
        'eligibility_score' => $row['eligibility_score'] ? (int)$row['eligibility_score'] : null,
        'helene_related' => (bool)$row['helene_related'],
        'urgent' => (bool)$row['urgent_open_to_elements'] || (bool)$row['urgent_no_hvac'],
        'status' => $row['submission_status'],
        'submitted_at' => $row['submitted_at'],
    ];
}

// 3. Completed assessments
$completedStmt = $pdo->prepare("
    SELECT a.id, a.status, a.actual_end, a.notes,
           s.applicant_first_name, s.applicant_last_name,
           s.home_address, s.home_city, s.home_state,
           s.submitted_at,
           aa.case_number
      FROM assessments a
      LEFT JOIN intake_submissions s ON s.id = a.application_id
      LEFT JOIN application_anchor aa ON aa.submission_id = s.id
     WHERE a.assessor_id = :uid AND a.status = 'completed'
     ORDER BY a.actual_end DESC
     LIMIT 50
");
$completedStmt->execute([':uid' => $userId]);
$completed = [];
while ($row = $completedStmt->fetch()) {
    $completed[] = [
        'id' => (int)$row['id'],
        'applicant_name' => trim(($row['applicant_first_name'] ?? '') . ' ' . ($row['applicant_last_name'] ?? '')),
        'address' => $row['home_address'] ?? '—',
        'city' => $row['home_city'] ?? '—',
        'state' => $row['home_state'] ?? 'NC',
        'case_number' => $row['case_number'],
        'status' => $row['status'],
        'completed_at' => $row['actual_end'],
        'notes' => $row['notes'],
        'submitted_at' => $row['submitted_at'],
    ];
}

ok([
    'claimed' => $claimed,
    'marketplace' => $marketplace,
    'completed' => $completed,
]);
