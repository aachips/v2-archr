<?php declare(strict_types=1);
/**
 * Organization Administrator API endpoint.
 *
 * Consequential, human-initiated actions only:
 *   - claim_case            Claim an application for the org (all or selected
 *                           Repairs Needed). Creates/reactivates the org's own
 *                           case and starts the 90-day progress cooldown.
 *   - release_repair_claim  Release one of the org's own repair claims
 *   - withdraw_case         Withdraw an entire application (requires direct
 *                           applicant confirmation — never automated)
 *   - terminate_application Terminate an application with canonical checkbox
 *                           reasons (human decision — never automated)
 *   - mark_notifications_read
 */

require_once __DIR__ . '/../lib/auth.php';
archr_require_auth();

require_once __DIR__ . '/../lib/db.php';
require_once __DIR__ . '/../lib/applications.php';
require_once __DIR__ . '/../lib/case-review.php';
require_once __DIR__ . '/../lib/case-phases.php';
require_once __DIR__ . '/../lib/org-admin.php';
require_once __DIR__ . '/../lib/activity-log.php';

header('Content-Type: application/json');

function fail(string $message): void {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => $message]);
    exit;
}

function ok(array $data = []): void {
    echo json_encode(array_merge(['success' => true], $data));
    exit;
}

$pdo = archr_pdo();
$ctx = archr_require_org_admin($pdo);
$currentUserId = (int)($_SESSION['archr_user_id'] ?? 0);
$currentUserName = (string)($_SESSION['archr_user_name'] ?? 'Unknown user');

$action = trim((string)($_POST['action'] ?? ''));

/** Insert in-app notifications (dashboard items — not do-not-reply emails). */
function notify_users(PDO $pdo, array $userIds, string $type, string $title, string $body, string $entityType, int $entityId): void {
    $stmt = $pdo->prepare("
        INSERT INTO notifications (user_id, notification_type, title, body, entity_type, entity_id, priority)
        VALUES (:uid, :type, :title, :body, :etype, :eid, 'high')
    ");
    foreach (array_unique(array_map('intval', $userIds)) as $uid) {
        $stmt->execute([':uid' => $uid, ':type' => $type, ':title' => $title, ':body' => $body, ':etype' => $entityType, ':eid' => $entityId]);
    }
}

/** Super admins + staff of the given org who should see case events. */
function event_audience(PDO $pdo, int $orgId, ?int $excludeUserId): array {
    $stmt = $pdo->prepare("
        SELECT DISTINCT u.id
          FROM system_users u
          JOIN user_role_assignments ura ON ura.user_id = u.id AND ura.is_active = true
          JOIN roles r ON r.id = ura.role_id
         WHERE u.is_active = true
           AND (UPPER(r.role_code) = 'SUPER_ADMIN' OR ura.organization_id = :org)
    ");
    $stmt->execute([':org' => $orgId]);
    $ids = array_map('intval', $stmt->fetchAll(PDO::FETCH_COLUMN));
    return array_values(array_filter($ids, fn($id) => $id !== $excludeUserId));
}

try {
    switch ($action) {
        case 'claim_case': {
            // Claims happen at the APPLICATION level (terminology doc): each
            // claiming organization gets its own case; one application may
            // legitimately carry several org cases over different repairs.
            $applicationId = (int)($_POST['application_id'] ?? 0);
            $caseId = (int)($_POST['case_id'] ?? 0);
            $requestedOrgId = isset($_POST['organization_id']) ? (int)$_POST['organization_id'] : null;
            $notes = trim((string)($_POST['notes'] ?? ''));
            $repairIds = array_values(array_filter(array_map('intval', (array)($_POST['repair_request_ids'] ?? []))));

            if ($applicationId === 0 && $caseId === 0) fail('Application ID or Case ID is required.');

            $orgId = archr_org_admin_resolve_org_id($pdo, $ctx, $requestedOrgId);
            if ($orgId === null) fail('Organization could not be determined. If you administer multiple organizations, specify which one is claiming.');

            // Resolve the application from a legacy case id when needed.
            $case = null;
            if ($applicationId === 0) {
                $case = archr_load_case($pdo, $caseId);
                if (!$case) fail('Case not found.');
                $applicationId = (int)($case['application_id'] ?? 0);
                if ($applicationId === 0) {
                    $applicationId = archr_deduplicate_application($pdo, (int)$case['submission_id']);
                }
            }

            $appStmt = $pdo->prepare("SELECT id, status, placecode, display_name FROM applications WHERE id = :id");
            $appStmt->execute([':id' => $applicationId]);
            $application = $appStmt->fetch();
            if (!$application) fail('Application not found.');
            if (in_array($application['status'], ['terminated', 'withdrawn', 'concluded'], true)) {
                fail('This application is ' . $application['status'] . ' and cannot be claimed.');
            }

            // The claiming org's own case (if it already has one).
            $myCaseStmt = $pdo->prepare(
                "SELECT id, claim_status, status_id, case_number FROM cases
                  WHERE application_id = :app AND organization_id = :org
                  ORDER BY id DESC LIMIT 1"
            );
            $myCaseStmt->execute([':app' => $applicationId, ':org' => $orgId]);
            $myCase = $myCaseStmt->fetch() ?: null;
            $isNewCaseClaim = $myCase === null || $myCase['claim_status'] !== 'active';

            // Repairs are shared at the application layer: every repair request
            // across all of the application's submissions is claimable.
            $availStmt = $pdo->prepare(
                "SELECT rr.id FROM repair_requests rr
                  JOIN intake_submissions s ON s.id = rr.submission_id
                  WHERE s.deduplicated_into = :app"
            );
            $availStmt->execute([':app' => $applicationId]);
            $availableIds = array_map('intval', $availStmt->fetchAll(PDO::FETCH_COLUMN));
            if ($repairIds) {
                $unknown = array_diff($repairIds, $availableIds);
                if ($unknown) fail('One or more selected repairs do not belong to this application.');
            } else {
                $repairIds = $availableIds; // no explicit selection => claim all unclaimed
            }

            // A repair row may have at most one ACTIVE claim across ALL orgs'
            // cases (enforced by uq_case_repair_claims_active); skip anything
            // already claimed by anyone.
            $activeStmt = $pdo->prepare(
                "SELECT crc.repair_request_id
                   FROM case_repair_claims crc
                   JOIN cases c ON c.id = crc.case_id
                  WHERE c.application_id = :app AND crc.released_at IS NULL"
            );
            $activeStmt->execute([':app' => $applicationId]);
            $claimedRepairIds = array_map('intval', $activeStmt->fetchAll(PDO::FETCH_COLUMN));
            $toClaim = array_values(array_diff($repairIds, $claimedRepairIds));

            if (!$isNewCaseClaim && !$toClaim) {
                fail('Nothing new to claim — all selected repairs are already claimed (by your organization or another).');
            }

            $pdo->beginTransaction();

            // Create/reactivate this org's case and (re)start the 90-day timer.
            $myCaseId = archr_claim_application($pdo, $applicationId, $orgId, $currentUserId);

            $claimStmt = $pdo->prepare("
                INSERT INTO case_repair_claims (case_id, repair_request_id, organization_id, claimed_by, notes)
                VALUES (:case, :repair, :org, :by, :notes)
            ");
            foreach ($toClaim as $rid) {
                $claimStmt->execute([':case' => $myCaseId, ':repair' => $rid, ':org' => $orgId, ':by' => $currentUserId, ':notes' => $notes ?: null]);
            }

            // Reflect the claim on assignment rows for every submission of the
            // application (create otherwise). Keep the ORIGINAL claimed_at when
            // an already-claimed org adds repairs.
            $assign = $pdo->prepare("
                INSERT INTO application_assignments (submission_id, organization_id, status, claimed_at, notes)
                SELECT s.id, :org, 'claimed', CURRENT_TIMESTAMP, :notes
                  FROM intake_submissions s
                 WHERE s.deduplicated_into = :app
                ON CONFLICT ON CONSTRAINT application_assignments_submission_id_organization_id_key DO UPDATE
                   SET status = 'claimed',
                       claimed_at = COALESCE(application_assignments.claimed_at, CURRENT_TIMESTAMP),
                       notes = EXCLUDED.notes
                RETURNING id
            ");
            $assign->execute([':app' => $applicationId, ':org' => $orgId, ':notes' => 'Claimed by ' . $currentUserName . ' (system user #' . $currentUserId . ')']);
            $assignmentIds = array_map('intval', $assign->fetchAll(PDO::FETCH_COLUMN));
            $logStmt = $pdo->prepare("INSERT INTO assignment_log (assignment_id, action, new_value, notes) VALUES (:aid, 'claimed', 'claimed', :notes)");
            foreach ($assignmentIds as $aid) {
                $logStmt->execute([':aid' => $aid, ':notes' => 'Claimed by ' . $currentUserName]);
            }

            // Case ledger + submission audit entries.
            $myCaseRow = $pdo->prepare("SELECT status_id, case_number FROM cases WHERE id = :id");
            $myCaseRow->execute([':id' => $myCaseId]);
            $myCaseRow = $myCaseRow->fetch() ?: ['status_id' => null, 'case_number' => null];
            $claimDesc = $isNewCaseClaim
                ? 'Case claimed by ' . ($ctx['orgs'][$orgId]['organization_name'] ?? ('org #' . $orgId)) . ' (' . count($toClaim) . ' repair(s))'
                : count($toClaim) . ' additional repair(s) claimed by ' . ($ctx['orgs'][$orgId]['organization_name'] ?? ('org #' . $orgId));
            $pdo->prepare("
                INSERT INTO case_status_history (case_id, from_status_id, to_status_id, changed_by, notes)
                VALUES (:case, :from_status, :to_status, :by, :notes)
            ")->execute([':case' => $myCaseId, ':from_status' => $myCaseRow['status_id'], ':to_status' => $myCaseRow['status_id'], ':by' => $currentUserId, ':notes' => $claimDesc . ($notes ? ' — ' . $notes : '')]);
            $auditStmt = $pdo->prepare("INSERT INTO audit_log (submission_id, action, new_value, performed_by) VALUES (:sid, 'claimed', :val, :by)");
            $subStmt = $pdo->prepare("SELECT id FROM intake_submissions WHERE deduplicated_into = :app");
            $subStmt->execute([':app' => $applicationId]);
            foreach ($subStmt->fetchAll(PDO::FETCH_COLUMN) as $sid) {
                $auditStmt->execute([':sid' => (int)$sid, ':val' => $claimDesc, ':by' => $currentUserName]);
            }

            // Immutable ledger: one curated entry per claim action.
            archr_log_event($pdo, 'application_claimed', [
                'application_id'  => $applicationId,
                'case_id'         => $myCaseId,
                'organization_id' => $orgId,
                'summary'         => $claimDesc,
                'details'         => [
                    'repairs_claimed' => count($toClaim),
                    'repair_ids'      => $toClaim,
                    'new_case_claim'  => $isNewCaseClaim,
                    'notes'           => $notes !== '' ? $notes : null,
                ],
            ]);

            $displayName = $application['display_name'] ?: ($application['placecode'] ?? ($myCaseRow['case_number'] ?? ('#' . $myCaseId)));
            notify_users($pdo, event_audience($pdo, $orgId, $currentUserId),
                'case_claimed', 'Case claimed: ' . $displayName,
                $claimDesc . ' by ' . $currentUserName . '.', 'case', $myCaseId);

            $expiryStmt = $pdo->prepare("SELECT claim_expires_at FROM cases WHERE id = :id");
            $expiryStmt->execute([':id' => $myCaseId]);

            $pdo->commit();
            ok([
                'case_id' => $myCaseId,
                'application_id' => $applicationId,
                'organization_id' => $orgId,
                'repairs_claimed' => count($toClaim),
                'case_claimed' => $isNewCaseClaim,
                'claim_expires_at' => $expiryStmt->fetchColumn() ?: null,
            ]);
        }

        case 'release_repair_claim': {
            $claimId = (int)($_POST['claim_id'] ?? 0);
            if ($claimId === 0) fail('Claim ID is required.');

            $stmt = $pdo->prepare("SELECT * FROM case_repair_claims WHERE id = :id AND released_at IS NULL");
            $stmt->execute([':id' => $claimId]);
            $claim = $stmt->fetch();
            if (!$claim) fail('Active claim not found.');

            $claimOrg = (int)$claim['organization_id'];
            if (!$ctx['is_super_admin'] && !isset($ctx['orgs'][$claimOrg])) {
                fail('You can only release claims made by your own organization.');
            }

            $pdo->beginTransaction();
            $pdo->prepare("UPDATE case_repair_claims SET released_at = CURRENT_TIMESTAMP, released_by = :by WHERE id = :id")
                ->execute([':by' => $currentUserId, ':id' => $claimId]);
            $pdo->prepare("
                INSERT INTO case_status_history (case_id, from_status_id, to_status_id, changed_by, notes)
                SELECT c.id, c.status_id, c.status_id, :by, :notes FROM cases c WHERE c.id = :case
            ")->execute([
                ':by' => $currentUserId,
                ':case' => (int)$claim['case_id'],
                ':notes' => 'Repair claim released by ' . $currentUserName . ' (claim #' . $claimId . ')',
            ]);
            // Recorded, but NOT a progress event — releasing a claim must not
            // extend the organization's 90-day timer.
            archr_log_progress_event($pdo, (int)$claim['case_id'], 'repair_claim_released',
                'Repair claim #' . $claimId . ' released by ' . $currentUserName, $currentUserId, false);

            archr_log_event($pdo, 'repair_claim_released', [
                'application_id'  => (int)$pdo->query("SELECT application_id FROM cases WHERE id = " . (int)$claim['case_id'])->fetchColumn() ?: null,
                'case_id'         => (int)$claim['case_id'],
                'organization_id' => $claimOrg,
                'summary'         => 'Repair claim #' . $claimId . ' released by ' . $currentUserName,
                'details'         => ['claim_id' => $claimId, 'repair_request_id' => (int)$claim['repair_request_id']],
            ]);
            $pdo->commit();
            ok(['released' => true, 'claim_id' => $claimId]);
        }

        case 'withdraw_case': {
            // Withdrawal is APPLICATION-level (terminology doc): the applicant
            // withdraws the whole application, so every org's case closes.
            // Never automated — requires direct applicant confirmation.
            $caseId = (int)($_POST['case_id'] ?? 0);
            $confirmed = in_array(strtolower((string)($_POST['requestor_confirmed'] ?? '')), ['1', 'true', 'yes', 'on'], true);
            $method = strtolower(trim((string)($_POST['confirmation_method'] ?? '')));
            $detail = trim((string)($_POST['confirmation_detail'] ?? ''));
            $reason = trim((string)($_POST['reason'] ?? ''));

            if ($caseId === 0) fail('Case ID is required.');
            if (!$confirmed) fail('Withdrawal requires direct confirmation from the applicant. This step cannot be automated.');
            if (!in_array($method, ['phone', 'in_person', 'written'], true)) fail('Select how the applicant confirmed: phone, in person, or in writing.');
            if ($detail === '') fail('Describe the confirmation (who, how, and when).');

            $case = archr_load_case($pdo, $caseId);
            if (!$case) fail('Case not found.');
            if (archr_case_phase($case)['exit'] !== null || strtoupper((string)($case['status_code'] ?? '')) === 'COMPLETED') {
                fail('This case is already closed and cannot be withdrawn.');
            }
            $applicationId = (int)($case['application_id'] ?? 0);
            if ($applicationId === 0) {
                $applicationId = archr_deduplicate_application($pdo, (int)$case['submission_id']);
            }
            $appStatus = (string)$pdo->query("SELECT status FROM applications WHERE id = " . $applicationId)->fetchColumn();
            if (in_array($appStatus, ['withdrawn', 'terminated', 'concluded'], true)) {
                fail('This application is already ' . $appStatus . '.');
            }

            // Level 2 may only withdraw applications their org claims; level 3 any.
            $caseOrg = archr_case_organization_id($pdo, $caseId);
            if (!$ctx['is_super_admin'] && ($caseOrg === null || !isset($ctx['orgs'][$caseOrg]))) {
                fail('You can only withdraw applications claimed by your own organization.');
            }

            $withdrawnStatusId = (int)$pdo->query("SELECT id FROM case_statuses WHERE status_code = 'WITHDRAWN' LIMIT 1")->fetchColumn();
            if (!$withdrawnStatusId) fail('WITHDRAWN status is missing — run sql/org-admin.sql first.');

            $contactNote = 'Applicant confirmed via ' . str_replace('_', ' ', $method) . ' (' . $detail . ')' . ($reason ? '. Reason: ' . $reason : '');

            $pdo->beginTransaction();
            $pdo->prepare("
                INSERT INTO case_withdrawals (case_id, withdrawn_by, requestor_confirmed, confirmation_method, confirmation_detail, reason)
                VALUES (:case, :by, true, :method, :detail, :reason)
            ")->execute([':case' => $caseId, ':by' => $currentUserId, ':method' => $method, ':detail' => $detail, ':reason' => $reason ?: null]);

            // Application status: withdrawn (human interaction only, with note).
            archr_set_application_status($pdo, $applicationId, 'withdrawn', $contactNote, [], $currentUserId);

            // Every submission of the application is withdrawn.
            $pdo->prepare("
                UPDATE intake_submissions
                   SET submission_status = 'withdrawn', reviewed_by = :by, reviewed_at = CURRENT_TIMESTAMP
                 WHERE deduplicated_into = :app
            ")->execute([':by' => $currentUserName, ':app' => $applicationId]);

            // Every non-terminal case of the application is withdrawn and its
            // claim released; each gets a ledger entry and a (non-progress) event.
            $appCases = $pdo->prepare(
                "SELECT c.id, c.status_id, c.organization_id
                   FROM cases c
                   LEFT JOIN case_statuses cs ON cs.id = c.status_id
                  WHERE c.application_id = :app AND COALESCE(cs.is_terminal, false) = false"
            );
            $appCases->execute([':app' => $applicationId]);
            $appCaseRows = $appCases->fetchAll();

            $closeCase = $pdo->prepare("UPDATE cases SET status_id = :status, claim_status = 'released', updated_by = :by WHERE id = :case");
            $caseHistory = $pdo->prepare("
                INSERT INTO case_status_history (case_id, from_status_id, to_status_id, changed_by, notes)
                VALUES (:case, :from, :to, :by, :notes)
            ");
            $auditStmt = $pdo->prepare("INSERT INTO audit_log (submission_id, action, new_value, performed_by) VALUES (:sid, 'status_changed', 'withdrawn', :by)");
            $subStmt = $pdo->prepare("SELECT id FROM intake_submissions WHERE deduplicated_into = :app");
            $subStmt->execute([':app' => $applicationId]);
            $submissionIds = array_map('intval', $subStmt->fetchAll(PDO::FETCH_COLUMN));

            $notifyOrgs = [];
            foreach ($appCaseRows as $appCase) {
                $closeCase->execute([':status' => $withdrawnStatusId, ':by' => $currentUserId, ':case' => (int)$appCase['id']]);
                $caseHistory->execute([
                    ':case' => (int)$appCase['id'], ':from' => $appCase['status_id'], ':to' => $withdrawnStatusId, ':by' => $currentUserId,
                    ':notes' => 'Application withdrawn by ' . $currentUserName . ' after applicant confirmation via ' . str_replace('_', ' ', $method) . ' (' . $detail . ')' . ($reason ? '. Reason: ' . $reason : ''),
                ]);
                archr_log_progress_event($pdo, (int)$appCase['id'], 'application_withdrawn',
                    'Application withdrawn by ' . $currentUserName . ' after applicant confirmation.', $currentUserId, false);
                if (!empty($appCase['organization_id'])) {
                    $notifyOrgs[] = (int)$appCase['organization_id'];
                }
            }
            foreach ($submissionIds as $sid) {
                $auditStmt->execute([':sid' => $sid, ':by' => $currentUserName]);
            }

            // Immutable ledger: the withdrawal record (human-confirmed).
            archr_log_event($pdo, 'application_withdrawn', [
                'application_id' => $applicationId,
                'case_id'        => $caseId,
                'summary'        => 'Application withdrawn by ' . $currentUserName . ' (confirmed via ' . str_replace('_', ' ', $method) . ')',
                'details'        => [
                    'confirmation_method' => $method,
                    'confirmation_detail' => $detail,
                    'reason'              => $reason !== '' ? $reason : null,
                    'cases_closed'        => count($appCaseRows),
                ],
            ]);

            $displayName = $case['display_name'] ?? $case['case_number'] ?? ('#' . $caseId);
            foreach (array_unique($notifyOrgs) as $notifyOrgId) {
                notify_users($pdo, event_audience($pdo, $notifyOrgId, $currentUserId),
                    'case_withdrawn', 'Application withdrawn: ' . $displayName,
                    'Withdrawn by ' . $currentUserName . ' after applicant confirmation via ' . str_replace('_', ' ', $method) . '.', 'case', $caseId);
            }

            $pdo->commit();
            ok(['case_id' => $caseId, 'application_id' => $applicationId, 'withdrawn' => true]);
        }

        case 'terminate_application': {
            // Termination is APPLICATION-level and requires canonical checkbox
            // reasons (terminology doc Part 6) — a human decision, never automated.
            $applicationId = (int)($_POST['application_id'] ?? 0);
            $caseId = (int)($_POST['case_id'] ?? 0);
            $reasons = array_values(array_filter(array_map('trim', array_map('strval', (array)($_POST['reasons'] ?? [])))));
            $otherReason = trim((string)($_POST['other_reason'] ?? ''));
            $notes = trim((string)($_POST['notes'] ?? ''));

            if ($applicationId === 0 && $caseId === 0) fail('Application ID or Case ID is required.');
            if ($applicationId === 0) {
                $applicationId = (int)$pdo->query("SELECT application_id FROM cases WHERE id = " . $caseId)->fetchColumn();
            }
            if ($applicationId === 0) fail('Application not found.');
            if (!$reasons) fail('Terminating an application requires at least one checkbox reason.');

            // Level 2 must hold a case on the application; level 3 may terminate any.
            if (!$ctx['is_super_admin']) {
                $ownStmt = $pdo->prepare("SELECT 1 FROM cases WHERE application_id = :app AND organization_id IN (" . implode(',', array_map('intval', array_keys($ctx['orgs'])) ?: [0]) . ") LIMIT 1");
                $ownStmt->execute([':app' => $applicationId]);
                if (!$ownStmt->fetchColumn()) {
                    fail('You can only terminate applications claimed by your own organization.');
                }
            }

            $reasonNote = $notes;
            if (in_array('Other (please specify)', $reasons, true) && $otherReason !== '') {
                $reasonNote = ($reasonNote ? $reasonNote . ' — ' : '') . $otherReason;
            }

            $deniedStatusId = (int)$pdo->query("SELECT id FROM case_statuses WHERE status_code = 'DENIED' LIMIT 1")->fetchColumn();
            if (!$deniedStatusId) fail('DENIED status is missing from case_statuses.');

            $pdo->beginTransaction();
            try {
                archr_set_application_status($pdo, $applicationId, 'terminated', $reasonNote, $reasons, $currentUserId);
            } catch (InvalidArgumentException $e) {
                $pdo->rollBack();
                fail($e->getMessage());
            }

            // Close every non-terminal case of the application (DENIED) and
            // release claims; ledger + non-progress event per case.
            $appCases = $pdo->prepare(
                "SELECT c.id, c.status_id, c.organization_id
                   FROM cases c
                   LEFT JOIN case_statuses cs ON cs.id = c.status_id
                  WHERE c.application_id = :app AND COALESCE(cs.is_terminal, false) = false"
            );
            $appCases->execute([':app' => $applicationId]);
            $appCaseRows = $appCases->fetchAll();

            $closeCase = $pdo->prepare("UPDATE cases SET status_id = :status, claim_status = 'released', updated_by = :by WHERE id = :case");
            $caseHistory = $pdo->prepare("
                INSERT INTO case_status_history (case_id, from_status_id, to_status_id, changed_by, notes)
                VALUES (:case, :from, :to, :by, :notes)
            ");
            $reasonList = implode('; ', $reasons) . ($otherReason ? ' — ' . $otherReason : '');
            $notifyOrgs = [];
            foreach ($appCaseRows as $appCase) {
                $closeCase->execute([':status' => $deniedStatusId, ':by' => $currentUserId, ':case' => (int)$appCase['id']]);
                $caseHistory->execute([
                    ':case' => (int)$appCase['id'], ':from' => $appCase['status_id'], ':to' => $deniedStatusId, ':by' => $currentUserId,
                    ':notes' => 'Application terminated by ' . $currentUserName . '. Reasons: ' . $reasonList,
                ]);
                archr_log_progress_event($pdo, (int)$appCase['id'], 'application_terminated',
                    'Application terminated. Reasons: ' . $reasonList, $currentUserId, false);
                if (!empty($appCase['organization_id'])) {
                    $notifyOrgs[] = (int)$appCase['organization_id'];
                }
            }

            $subStmt = $pdo->prepare("SELECT id FROM intake_submissions WHERE deduplicated_into = :app");
            $subStmt->execute([':app' => $applicationId]);
            $auditStmt = $pdo->prepare("INSERT INTO audit_log (submission_id, action, new_value, performed_by) VALUES (:sid, 'status_changed', :val, :by)");
            foreach ($subStmt->fetchAll(PDO::FETCH_COLUMN) as $sid) {
                $auditStmt->execute([':sid' => (int)$sid, ':val' => 'terminated: ' . $reasonList, ':by' => $currentUserName]);
            }

            // Immutable ledger: the termination record (human decision).
            archr_log_event($pdo, 'application_terminated', [
                'application_id' => $applicationId,
                'case_id'        => $caseId > 0 ? $caseId : null,
                'summary'        => 'Application terminated by ' . $currentUserName . '. Reasons: ' . $reasonList,
                'details'        => [
                    'reasons'      => $reasons,
                    'other_reason' => $otherReason !== '' ? $otherReason : null,
                    'notes'        => $notes !== '' ? $notes : null,
                    'cases_closed' => count($appCaseRows),
                ],
            ]);

            $name = (string)$pdo->query("SELECT COALESCE(display_name, placecode, 'application #' || id) FROM applications WHERE id = " . $applicationId)->fetchColumn();
            foreach (array_unique($notifyOrgs) as $notifyOrgId) {
                notify_users($pdo, event_audience($pdo, $notifyOrgId, $currentUserId),
                    'case_terminated', 'Application terminated: ' . $name,
                    'Terminated by ' . $currentUserName . '. Reasons: ' . $reasonList, 'case', $caseId ?: (int)$appCaseRows[0]['id']);
            }

            $pdo->commit();
            ok(['application_id' => $applicationId, 'terminated' => true, 'reasons' => $reasons]);
        }

        case 'mark_notifications_read': {
            $ids = array_values(array_filter(array_map('intval', (array)($_POST['ids'] ?? []))));
            if ($ids) {
                $in = implode(',', $ids);
                $pdo->prepare("UPDATE notifications SET is_read = true, read_at = CURRENT_TIMESTAMP WHERE user_id = :uid AND id IN ($in)")
                    ->execute([':uid' => $currentUserId]);
            } else {
                $pdo->prepare("UPDATE notifications SET is_read = true, read_at = CURRENT_TIMESTAMP WHERE user_id = :uid AND is_read = false")
                    ->execute([':uid' => $currentUserId]);
            }
            ok(['marked' => true]);
        }

        default:
            fail('Unknown action.');
    }
} catch (Throwable $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    error_log('[org-admin] ' . $e->getMessage());
    fail('Server error: ' . $e->getMessage());
}
