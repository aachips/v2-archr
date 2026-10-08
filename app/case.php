<?php
declare(strict_types=1);

/* Portal-based case review with permission levels:
 *   1 = office worker (limited details)
 *   2 = org admin (full org-level view)
 *   3 = super admin (full system-level view)
 */

require __DIR__ . '/lib/auth.php';
archr_require_auth();

require __DIR__ . '/lib/db.php';
require __DIR__ . '/lib/case-access.php';
require __DIR__ . '/lib/case-review.php';
require __DIR__ . '/lib/case-phases.php';
require __DIR__ . '/lib/org-admin.php';
require __DIR__ . '/lib/case-documents.php';
require __DIR__ . '/lib/portal-layout.php';

$pdo = archr_pdo();
$access = archr_require_staff_access($pdo);

$caseId = isset($_GET['id']) ? (int)$_GET['id'] : 0;
$submissionId = isset($_GET['submission_id']) ? (int)$_GET['submission_id'] : 0;

/* "Back to results" context: the case search page passes its own URL so the
   review page can link back to the same filtered result set. Only local
   case-search.php URLs are accepted. */
$returnTo = (string)($_GET['return'] ?? '');
if ($returnTo === '' || !preg_match('/^case-search\.php(\?[a-zA-Z0-9\-._~%!$&\'()*+,;=:@\/?]*)?$/', $returnTo)) {
    $returnTo = 'case-search.php';
}

if ($submissionId > 0) {
    $caseId = archr_ensure_case($pdo, $submissionId);
    header('Location: case.php?id=' . $caseId . '&return=' . urlencode($returnTo));
    exit;
}

$notFound = false;
$permission = null;
$case = null;

if ($caseId <= 0) {
    $notFound = true;
} else {
    $permission = archr_case_view_permission($pdo, $caseId);
    if (!$permission['can_view']) {
        http_response_code(403);
        echo 'Access denied.';
        exit;
    }
    $case = archr_load_case($pdo, $caseId);
    if (!$case) {
        $notFound = true;
    }
}

if ($notFound) {
    archr_render_portal_header([
        'role' => 'generic',
        'role_label' => 'Staff',
        'brand' => 'ARCHR',
        'page_title' => 'Case not found',
        'user_name' => $_SESSION['archr_user_name'] ?? '',
        'badge_icon' => 'fa-folder-open',
        'nav' => archr_case_nav('case-search'),
    ]);
    echo '<main class="page-wrap narrow"><section class="panel"><h1>Case not found</h1><p><a href="' . e($returnTo) . '">Back to case search</a></p></section></main>';
    archr_render_portal_footer();
    exit;
}

$caseOrg = archr_case_claimed_org($pdo, $caseId);
// The claim lookup LEFT JOINs, so an unclaimed case comes back as a row of
// nulls — normalize to null so "unclaimed" checks behave.
if ($caseOrg !== null && empty($caseOrg['id'])) {
    $caseOrg = null;
}

// ---------------------------------------------------------------------
// Application context (ARCHR Core Terminology model): this case is one
// organization-specific instance of a deduplicated application. Repair
// needs and documents are shared at the application layer; each claiming
// org has its own case with its own 90-day progress cooldown.
// ---------------------------------------------------------------------
$applicationId = (int)($case['application_id'] ?? 0);
if ($applicationId === 0) {
    // Legacy row without an application link — consolidate on the fly.
    $applicationId = archr_deduplicate_application($pdo, (int)$case['submission_id']);
}
$appStmt = $pdo->prepare("SELECT id, status, status_reason, placecode, display_name, eligibility_flags, eligibility_report, to_jsonb(terminated_reason_checkboxes) AS terminated_reason_checkboxes FROM applications WHERE id = :id");
$appStmt->execute([':id' => $applicationId]);
$application = $appStmt->fetch() ?: null;
if ($application !== null) {
    $application['terminated_reason_checkboxes'] = json_decode((string)$application['terminated_reason_checkboxes'], true) ?: [];
}

$applicationStatus = (string)($application['status'] ?? 'new');
$applicationTerminal = in_array($applicationStatus, ['terminated', 'withdrawn', 'concluded'], true);
$applicationCases = archr_application_cases($pdo, $applicationId);
$terminationReasons = archr_termination_reasons($pdo);

$eligibilityFlags = json_decode((string)($application['eligibility_flags'] ?? ''), true)
    ?: ['green' => [], 'yellow' => [], 'red' => []];

// Repair needs/claims are application-wide (a repair may be claimed by at
// most one org across all of the application's cases).
$repairs = archr_case_repairs($pdo, (int)$case['submission_id']);
$repairRequests = archr_application_repair_requests($pdo, $applicationId);
$repairDetails = archr_case_repair_details($pdo, (int)$case['submission_id']);
$repairClaims = archr_application_repair_claims($pdo, $applicationId);
$withdrawal = archr_case_withdrawal($pdo, $caseId);
$attrs = archr_case_household_attrs($pdo, (int)$case['submission_id']);
$eligibility = archr_case_eligibility($pdo, (int)$case['submission_id']);
$statusHistory = archr_case_status_history($pdo, $caseId);
$assignments = archr_case_assignment_log($pdo, (int)$case['submission_id']);
$tasks = archr_case_tasks($pdo, $caseId);
$documents = archr_case_documents($pdo, $caseId);
// Most-urgent document action items (pending verification, then missing
// required) for the review header widget. Empty when doc tables undeployed.
$docUrgent = archr_doc_tables_ready($pdo) ? archr_doc_urgent_items($pdo, $caseId, $documents) : [];

// Six-phase pipeline position + org-admin action context.
$phases = archr_case_phases();
$phaseInfo = archr_case_phase($case);

$orgAdminOrgs = $permission['level'] >= 2 ? archr_org_admin_orgs($pdo) : [];
$activeRepairClaims = array_values(array_filter($repairClaims, fn($c) => $c['released_at'] === null));
$claimedRepairIds = array_map('intval', array_column($activeRepairClaims, 'repair_request_id'));
$unclaimedRepairs = array_values(array_filter($repairRequests, fn($r) => !in_array((int)$r['id'], $claimedRepairIds, true)));

// My organization's own active case on this application (if any).
$myOrgCase = null;
foreach ($applicationCases as $ac) {
    if ($ac['organization_id'] !== null
        && array_key_exists((int)$ac['organization_id'], $orgAdminOrgs)
        && $ac['claim_status'] === 'active') {
        $myOrgCase = $ac;
        break;
    }
}

// Claim (multi-org model): level 2+ with an org, application not terminal.
// An org with no active case on the application may claim it (its own case
// is created); an org already holding a case may add still-unclaimed repairs.
$ownsClaim = $myOrgCase !== null;
$canClaim = $permission['level'] >= 2 && $orgAdminOrgs !== []
    && !$applicationTerminal
    && $phaseInfo['exit'] === null
    && (($myOrgCase === null && ($unclaimedRepairs !== [] || $repairRequests === []))
        || ($myOrgCase !== null && $unclaimedRepairs !== []));
// Withdraw: super admin anywhere, or org admin whose org holds a case on the
// application. Withdrawal closes the whole application (every org's case).
$canWithdraw = !$applicationTerminal && $phaseInfo['exit'] === null
    && ($permission['level'] >= 3 || ($permission['level'] >= 2 && $ownsClaim));
// Terminate: super admin, or org admin whose org holds a case; requires
// canonical checkbox reasons (human decision — never automated).
$canTerminate = !$applicationTerminal && $phaseInfo['exit'] === null
    && ($permission['level'] >= 3 || ($permission['level'] >= 2 && $ownsClaim));

$roleSlug = strtolower(str_replace('_', '-', (string)($permission['role_code'] ?? 'staff')));
$roleLabel = match ((int)$permission['level']) {
    3 => 'Super Admin',
    2 => 'Org Admin',
    default => 'Staff',
};

archr_render_portal_header([
    'role' => $roleSlug,
    'role_label' => $roleLabel,
    'brand' => 'ARCHR',
    'page_title' => 'Case — ' . ($application['display_name'] ?? $case['case_number'] ?? '#' . $caseId),
    'user_name' => $_SESSION['archr_user_name'] ?? '',
    'badge_icon' => 'fa-folder-open',
    'extra_head' => '<link rel="stylesheet" href="assets/role-org-admin.css"><link rel="stylesheet" href="assets/case-documents.css">',
    'nav' => archr_case_nav('case'),
]);

require __DIR__ . '/partials/case-review-body.php';

archr_render_portal_footer();
