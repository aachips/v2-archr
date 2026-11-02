<?php declare(strict_types=1);
/**
 * Vue Requestor API — token-authenticated endpoint.
 * Returns all submissions for the logged-in user (own + referrals they submitted).
 *
 * GET → list of submissions + detail for the most recent one
 * POST action=update_contact → update safe contact fields on a specific submission
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

    if ($action === 'update_contact') {
        $subId = (int)($_POST['submission_id'] ?? 0);
        if ($subId <= 0) fail('Submission ID is required.');

        // Verify ownership
        $checkStmt = $pdo->prepare("SELECT id FROM intake_submissions WHERE id = :id AND requestor_user_id = :uid");
        $checkStmt->execute([':id' => $subId, ':uid' => $userId]);
        if (!$checkStmt->fetch()) fail('Access denied.');

        $contactEmail = trim((string)($_POST['contact_email'] ?? ''));
        $homePhone = trim((string)($_POST['home_phone'] ?? ''));
        $cellPhone = trim((string)($_POST['cell_phone'] ?? ''));
        $prefEmail = !empty($_POST['preferred_email']);
        $prefPhone = !empty($_POST['preferred_phone']);

        $pdo->prepare("
            UPDATE intake_submissions SET
                contact_email = :email,
                home_phone = :home,
                cell_phone = :cell,
                preferred_email = :prefemail,
                preferred_phone = :prefphone
            WHERE id = :id AND requestor_user_id = :uid
        ")->execute([
            ':email' => $contactEmail ?: null,
            ':home' => $homePhone ?: null,
            ':cell' => $cellPhone ?: null,
            ':prefemail' => $prefEmail,
            ':prefphone' => $prefPhone,
            ':id' => $subId,
            ':uid' => $userId,
        ]);

        ok(['message' => 'Contact information updated']);
    }

    fail('Unknown action: ' . $action);
}

// ── GET: return list + latest detail ──

// Check if a specific submission is requested
$requestedId = (int)($_GET['submission_id'] ?? 0);

// List of all submissions for this user
$listStmt = $pdo->prepare("
    SELECT s.id, s.applicant_first_name, s.applicant_last_name,
           s.home_address, s.home_city, s.home_state, s.home_zip,
           s.is_referral, s.submission_status, s.submitted_at,
           a.case_number, a.anchor_id, a.current_status AS anchor_status
      FROM intake_submissions s
      LEFT JOIN application_anchor a ON a.submission_id = s.id
     WHERE s.requestor_user_id = :uid
     ORDER BY s.submitted_at DESC
");
$listStmt->execute([':uid' => $userId]);
$submissions = [];
while ($row = $listStmt->fetch()) {
    $submissions[] = [
        'id' => (int)$row['id'],
        'first_name' => $row['applicant_first_name'],
        'last_name' => $row['applicant_last_name'],
        'address' => $row['home_address'],
        'city' => $row['home_city'],
        'state' => $row['home_state'],
        'zip' => $row['home_zip'],
        'is_referral' => (bool)$row['is_referral'],
        'status' => $row['anchor_status'] ?: $row['submission_status'] ?: 'pending',
        'submitted_at' => $row['submitted_at'],
        'case_number' => $row['case_number'],
        'anchor_id' => $row['anchor_id'],
    ];
}

// Latest submission detail (for the default view or specific request)
$detailId = $requestedId ?: (count($submissions) > 0 ? $submissions[0]['id'] : 0);
if ($detailId > 0) {
    $stmt = $pdo->prepare("
        SELECT s.*, a.case_number, a.anchor_id, a.current_status AS anchor_status,
               a.is_eligible, a.eligibility_score, a.project_code
          FROM intake_submissions s
          LEFT JOIN application_anchor a ON a.submission_id = s.id
         WHERE s.id = :id AND s.requestor_user_id = :uid
    ");
    $stmt->execute([':id' => $detailId, ':uid' => $userId]);
    $sub = $stmt->fetch();

    $submission = [
        'id' => (int)$sub['id'],
        'first_name' => $sub['applicant_first_name'],
        'last_name' => $sub['applicant_last_name'],
        'contact_email' => $sub['contact_email'],
        'home_phone' => $sub['home_phone'],
        'cell_phone' => $sub['cell_phone'],
        'address' => $sub['home_address'],
        'city' => $sub['home_city'],
        'state' => $sub['home_state'],
        'zip' => $sub['home_zip'],
        'is_primary_residence' => (bool)$sub['is_primary_residence'],
        'owns_home' => (bool)$sub['owns_home'],
        'owns_lot' => (bool)$sub['owns_lot'],
        'home_type' => $sub['home_type'],
        'year_built' => $sub['year_built'] ? (int)$sub['year_built'] : null,
        'household_size' => $sub['household_size'] ? (int)$sub['household_size'] : null,
        'household_adults' => $sub['household_adults'] ? (int)$sub['household_adults'] : null,
        'has_income' => (bool)$sub['has_income'],
        'income_method' => $sub['income_method'],
        'gross_annual_income' => $sub['gross_annual_income'] ? (float)$sub['gross_annual_income'] : null,
        'insurance_provider' => $sub['insurance_provider'],
        'insurance_claim_filed' => (bool)$sub['insurance_claim_filed'],
        'helene_related' => (bool)$sub['helene_related'],
        'fema_claim_filed' => (bool)$sub['fema_claim_filed'],
        'fema_outcome' => $sub['fema_outcome'],
        'repair_details' => $sub['additional_repair_details'],
        'urgent_open_to_elements' => (bool)$sub['urgent_open_to_elements'],
        'urgent_no_hvac' => (bool)$sub['urgent_no_hvac'],
        'urgent_no_kitchen' => (bool)$sub['urgent_no_kitchen'],
        'preferred_email' => (bool)$sub['preferred_email'],
        'preferred_phone' => (bool)$sub['preferred_phone'],
        'status' => $sub['anchor_status'] ?: $sub['submission_status'] ?: 'pending',
        'assigned_organization' => $sub['assigned_organization'],
        'submitted_at' => $sub['submitted_at'],
        'placecode' => $sub['placecode'],
        'case_number' => $sub['case_number'],
        'anchor_id' => $sub['anchor_id'],
        'is_referral' => (bool)$sub['is_referral'],
        'is_eligible' => (bool)$sub['is_eligible'],
        'eligibility_score' => $sub['eligibility_score'] ? (int)$sub['eligibility_score'] : null,
        'project_code' => $sub['project_code'],
    ];
} else {
    $submission = null;
}

ok([
    'submissions' => $submissions,
    'submission' => $submission,
]);
