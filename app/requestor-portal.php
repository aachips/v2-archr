<?php
declare(strict_types=1);

/* Requestor role portal. Loads the logged-in requestor's live intake
   submission and renders a real dashboard instead of the hard-coded template. */

require_once __DIR__ . '/lib/auth.php';
archr_require_auth();

require_once __DIR__ . '/lib/db.php';
require_once __DIR__ . '/lib/case-documents.php';
require_once __DIR__ . '/lib/portal-layout.php';

$pdo = archr_pdo();
$userId = (int)($_SESSION['archr_user_id'] ?? 0);

$subStmt = $pdo->prepare("
    SELECT s.id, s.applicant_first_name, s.applicant_last_name, s.contact_email,
           s.home_address, s.home_city, s.home_state, s.home_zip,
           s.submitted_at, s.submission_status,
           a.anchor_id, a.case_number, a.current_status AS anchor_status,
           a.is_eligible, a.eligibility_score, a.placecode, a.project_code
      FROM intake_submissions s
      LEFT JOIN application_anchor a ON a.submission_id = s.id
     WHERE s.requestor_user_id = :uid
     ORDER BY s.submitted_at DESC
     LIMIT 1
");
$subStmt->execute([':uid' => $userId]);
$submission = $subStmt->fetch() ?: null;

$firstName = $submission['applicant_first_name'] ?? '';
$lastName  = $submission['applicant_last_name'] ?? '';
$fullName  = trim("$firstName $lastName") ?: ($_SESSION['archr_user_name'] ?? 'Requestor');
$initials  = archr_initials_from_name($fullName);

$caseRef = $submission['placecode']
    ?? $submission['case_number']
    ?? $submission['anchor_id']
    ?? ('#' . ($submission['id'] ?? ''));
$status  = $submission['anchor_status'] ?? $submission['submission_status'] ?? 'pending';
$submittedAt = !empty($submission['submitted_at']) ? new DateTimeImmutable($submission['submitted_at']) : null;

// Documents section: the requestor's case documents + upload surface.
// Empty when the document tables are not deployed yet.
$docTablesReady = archr_doc_tables_ready($pdo);
$requestorCaseId = $docTablesReady ? archr_doc_requestor_case_id($pdo, $userId) : null;
$requestorDocs = ($docTablesReady && $requestorCaseId !== null)
    ? archr_doc_case_rows($pdo, $requestorCaseId)
    : [];
$requestorDocCodes = [
    'INC_PAYSTUB' => 'Pay stub',
    'INC_W2'      => 'W-2',
    'INC_SS'      => 'Social Security / benefits letter',
    'INC_BANK'    => 'Bank statement',
    'DEED'        => 'Deed or homeownership proof',
    'TAX'         => 'Property tax record',
    'CONSENT'     => 'Consent form',
    'OTHER'       => 'Other document',
];

archr_render_portal_header([
    'role'            => 'requestor',
    'role_label'      => 'Requestor',
    'brand'           => 'ARCHR Requestor',
    'page_title'      => 'My Application',
    'user_name'       => $fullName,
    'avatar_initials' => $initials,
    'badge_icon'      => 'fa-house-chimney-medical',
    'extra_head'      => '<link rel="stylesheet" href="assets/role-requestor.css">',
    'nav' => [
        ['href' => '#dashboard', 'icon' => 'fa-gauge-high', 'label' => 'My Application', 'active' => true],
        ['href' => '#documents', 'icon' => 'fa-folder-open', 'label' => 'Documents'],
        ['href' => '#eligibility', 'icon' => 'fa-handshake', 'label' => 'Eligibility'],
        ['href' => '#progress', 'icon' => 'fa-clock-rotate-left', 'label' => 'Progress Timeline'],
        ['href' => '#help', 'icon' => 'fa-circle-question', 'label' => 'Help'],
    ],
]);

require __DIR__ . '/partials/requestor-body-live.php';

archr_render_portal_footer();
