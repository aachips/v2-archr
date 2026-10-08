<?php declare(strict_types=1);
/**
 * Super-Administrator API endpoint.
 * Handles organization creation, user creation, and password resets.
 */

require_once __DIR__ . '/../lib/auth.php';
archr_require_auth();

require_once __DIR__ . '/../lib/db.php';
require_once __DIR__ . '/../lib/organization-export.php';

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

function requireSuperAdmin(PDO $pdo): void {
    $userId = (int)($_SESSION['archr_user_id'] ?? 0);
    $stmt = $pdo->prepare("
        SELECT 1 FROM user_role_assignments ura
        JOIN roles r ON r.id = ura.role_id
        WHERE ura.user_id = :uid AND r.role_code = 'SUPER_ADMIN' AND ura.is_active = true
        LIMIT 1
    ");
    $stmt->execute([':uid' => $userId]);
    if (!$stmt->fetch()) {
        http_response_code(403);
        echo json_encode(['success' => false, 'error' => 'Forbidden']);
        exit;
    }
}

function generatePassword(): string {
    return bin2hex(random_bytes(8));
}

$pdo = archr_pdo();
requireSuperAdmin($pdo);

$action = trim((string)($_POST['action'] ?? ''));
$currentUserId = (int)($_SESSION['archr_user_id'] ?? 0);

try {
    switch ($action) {
        case 'create_organization':
            $code = trim((string)($_POST['organization_code'] ?? ''));
            $name = trim((string)($_POST['organization_name'] ?? ''));
            $email = trim((string)($_POST['contact_email'] ?? ''));
            $phone = trim((string)($_POST['contact_phone'] ?? ''));
            if ($code === '' || $name === '') {
                fail('Organization code and name are required.');
            }
            $stmt = $pdo->prepare("
                INSERT INTO coalition_organizations (organization_code, organization_name, contact_email, contact_phone, created_by)
                VALUES (:code, :name, :email, :phone, :by)
                RETURNING id
            ");
            $stmt->execute([':code' => $code, ':name' => $name, ':email' => $email ?: null, ':phone' => $phone ?: null, ':by' => $currentUserId]);
            ok(['organization_id' => (int)$stmt->fetchColumn()]);

        case 'create_user':
            $fullName = trim((string)($_POST['full_name'] ?? ''));
            $username = trim((string)($_POST['username'] ?? ''));
            $email    = trim((string)($_POST['email'] ?? ''));
            $phone    = trim((string)($_POST['phone'] ?? ''));
            $roleId   = (int)($_POST['role_id'] ?? 0);
            $orgId    = (int)($_POST['organization_id'] ?? 0);

            if ($fullName === '' || $username === '' || $email === '' || $roleId === 0 || $orgId === 0) {
                fail('All user fields are required.');
            }
            if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                fail('Invalid email address.');
            }

            $parts = explode(' ', $fullName, 2);
            $firstName = $parts[0];
            $lastName  = $parts[1] ?? '';
            $password  = generatePassword();

            $pdo->beginTransaction();
            $userStmt = $pdo->prepare("
                INSERT INTO system_users (username, email, full_name, first_name, last_name, phone, password_hash, created_by)
                VALUES (:username, :email, :full_name, :first_name, :last_name, :phone, :hash, :by)
                RETURNING id
            ");
            $userStmt->execute([
                ':username'   => $username,
                ':email'      => $email,
                ':full_name'  => $fullName,
                ':first_name' => $firstName,
                ':last_name'  => $lastName,
                ':phone'      => $phone ?: null,
                ':hash'        => password_hash($password, PASSWORD_DEFAULT),
                ':by'          => $currentUserId,
            ]);
            $userId = (int) $userStmt->fetchColumn();

            $roleStmt = $pdo->prepare("
                INSERT INTO user_role_assignments (user_id, organization_id, role_id, assigned_by)
                VALUES (:uid, :org, :rid, :by)
            ");
            $roleStmt->execute([':uid' => $userId, ':org' => $orgId, ':rid' => $roleId, ':by' => $currentUserId]);
            $pdo->commit();

            ok(['user_id' => $userId, 'username' => $username, 'temporary_password' => $password]);

        case 'reset_password':
            $targetUserId = (int)($_POST['user_id'] ?? 0);
            if ($targetUserId === 0) {
                fail('User ID is required.');
            }
            $nameStmt = $pdo->prepare("SELECT username, full_name FROM system_users WHERE id = :uid");
            $nameStmt->execute([':uid' => $targetUserId]);
            $target = $nameStmt->fetch();
            if (!$target) {
                fail('User not found.');
            }
            $newPassword = generatePassword();
            $stmt = $pdo->prepare("
                UPDATE system_users
                   SET password_hash = :hash,
                       reset_token = NULL,
                       reset_token_expires = NULL,
                       updated_at = CURRENT_TIMESTAMP
                 WHERE id = :uid
            ");
            $stmt->execute([':hash' => password_hash($newPassword, PASSWORD_DEFAULT), ':uid' => $targetUserId]);
            ok(['user_id' => $targetUserId, 'username' => $target['username'], 'temporary_password' => $newPassword]);

        case 'update_organization':
            $orgId = (int)($_POST['organization_id'] ?? 0);
            if ($orgId === 0) {
                fail('Organization ID is required.');
            }
            $stmt = $pdo->prepare("
                UPDATE coalition_organizations
                   SET organization_name = :name,
                       contact_email = :email,
                       contact_phone = :phone,
                       description = :description,
                       funding_limit = :funding_limit,
                       max_active_applications = :max_active,
                       auto_claim_enabled = :auto_claim,
                       notification_email = :notify_email,
                       is_active = :is_active,
                       updated_at = CURRENT_TIMESTAMP
                 WHERE id = :id
            ");
            $stmt->execute([
                ':id'            => $orgId,
                ':name'          => trim((string)($_POST['organization_name'] ?? '')),
                ':email'         => trim((string)($_POST['contact_email'] ?? '')) ?: null,
                ':phone'         => trim((string)($_POST['contact_phone'] ?? '')) ?: null,
                ':description'   => trim((string)($_POST['description'] ?? '')) ?: null,
                ':funding_limit' => is_numeric($_POST['funding_limit'] ?? '') ? (float)$_POST['funding_limit'] : null,
                ':max_active'    => is_numeric($_POST['max_active_applications'] ?? '') ? (int)$_POST['max_active_applications'] : null,
                ':auto_claim'    => in_array(strtolower((string)($_POST['auto_claim_enabled'] ?? '')), ['on', '1', 'true', 'yes'], true),
                ':notify_email'  => trim((string)($_POST['notification_email'] ?? '')) ?: null,
                ':is_active'     => in_array(strtolower((string)($_POST['is_active'] ?? '')), ['on', '1', 'true', 'yes'], true),
            ]);
            ok(['organization_id' => $orgId]);

        case 'create_eligibility_rule':
            $orgId = (int)($_POST['organization_id'] ?? 0);
            $criteriaTypeId = (int)($_POST['criteria_type_id'] ?? 0);
            $ruleOperator = trim((string)($_POST['rule_operator'] ?? 'equals'));
            $ruleValue = trim((string)($_POST['rule_value'] ?? ''));
            $priority = (int)($_POST['priority'] ?? 0);
            if ($orgId === 0 || $criteriaTypeId === 0 || $ruleValue === '') {
                fail('Organization, criteria type, and rule value are required.');
            }
            $stmt = $pdo->prepare("
                INSERT INTO organization_eligibility_rules
                    (organization_id, criteria_type_id, rule_operator, rule_value, priority, is_active)
                VALUES (:org, :criteria, :operator, :value, :priority, true)
                RETURNING id
            ");
            $stmt->execute([
                ':org'       => $orgId,
                ':criteria'  => $criteriaTypeId,
                ':operator' => $ruleOperator,
                ':value'    => $ruleValue,
                ':priority' => $priority,
            ]);
            ok(['rule_id' => (int)$stmt->fetchColumn()]);

        case 'delete_eligibility_rule':
            $ruleId = (int)($_POST['rule_id'] ?? 0);
            if ($ruleId === 0) {
                fail('Rule ID is required.');
            }
            $stmt = $pdo->prepare("DELETE FROM organization_eligibility_rules WHERE id = :id");
            $stmt->execute([':id' => $ruleId]);
            ok(['deleted' => $stmt->rowCount() > 0]);

        case 'prepare_delete_organization':
            $orgId = (int)($_POST['organization_id'] ?? 0);
            if ($orgId === 0) {
                fail('Organization ID is required.');
            }
            $orgStmt = $pdo->prepare("SELECT id, organization_code, organization_name, is_active FROM coalition_organizations WHERE id = :id");
            $orgStmt->execute([':id' => $orgId]);
            $org = $orgStmt->fetch();
            if (!$org) {
                fail('Organization not found.');
            }
            ok([
                'organization' => $org,
                'counts' => archr_organization_association_counts($pdo, $orgId),
                'confirmation_target' => $org['organization_code'],
            ]);

        case 'delete_organization':
            $orgId = (int)($_POST['organization_id'] ?? 0);
            $confirmation = trim((string)($_POST['confirmation'] ?? ''));
            $acknowledge = (int)($_POST['acknowledge'] ?? 0);
            if ($orgId === 0) {
                fail('Organization ID is required.');
            }
            if ($acknowledge !== 1) {
                fail('You must acknowledge that this action is permanent.');
            }
            $orgStmt = $pdo->prepare("SELECT id, organization_code, organization_name FROM coalition_organizations WHERE id = :id");
            $orgStmt->execute([':id' => $orgId]);
            $org = $orgStmt->fetch();
            if (!$org) {
                fail('Organization not found.');
            }
            if ($confirmation !== $org['organization_code']) {
                fail('Confirmation code does not match the organization code.');
            }

            // Retention export before any destructive changes.
            $export = archr_export_organization($pdo, $orgId, $currentUserId);
            $backupPath = archr_save_organization_export($export);

            $pdo->beginTransaction();
            try {
                // Disconnect org-user references from other organizations' records before the cascade removes them.
                $userStmt = $pdo->prepare("SELECT id FROM organization_users WHERE organization_id = :org");
                $userStmt->execute([':org' => $orgId]);
                $userIds = $userStmt->fetchAll(PDO::FETCH_COLUMN);
                if (!empty($userIds)) {
                    $in = implode(',', array_map('intval', $userIds));
                    $pdo->exec("UPDATE application_assignments SET claimed_by = NULL, rejected_by = NULL WHERE claimed_by IN ($in) OR rejected_by IN ($in)");
                    $pdo->exec("UPDATE assignment_log SET performed_by = NULL WHERE performed_by IN ($in)");
                }

                // Disconnect this org's funding sources from reimbursement requests before they are cascaded away.
                $fsStmt = $pdo->prepare("SELECT id FROM funding_sources WHERE organization_id = :org");
                $fsStmt->execute([':org' => $orgId]);
                $fsIds = $fsStmt->fetchAll(PDO::FETCH_COLUMN);
                if (!empty($fsIds)) {
                    $in = implode(',', array_map('intval', $fsIds));
                    $pdo->exec("UPDATE reimbursement_requests SET funding_source_id = NULL WHERE funding_source_id IN ($in)");
                }

                // Nullify org references on financial/audit records so the rows survive for reporting.
                $pdo->prepare("UPDATE reimbursement_requests SET organization_id = NULL WHERE organization_id = :org")->execute([':org' => $orgId]);
                $tableExists = (bool)$pdo->query("SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'bursar_action_audit'")->fetchColumn();
                if ($tableExists) {
                    $pdo->prepare("UPDATE bursar_action_audit SET organization_id = NULL WHERE organization_id = :org")->execute([':org' => $orgId]);
                }

                // Remove records that directly reference the organization without ON DELETE CASCADE.
                $pdo->prepare("DELETE FROM application_assignments WHERE organization_id = :org")->execute([':org' => $orgId]);
                $pdo->prepare("DELETE FROM review_queue WHERE organization_id = :org")->execute([':org' => $orgId]);
                $pdo->prepare("DELETE FROM case_claims WHERE claimed_by_org_id = :org")->execute([':org' => $orgId]);

                // Delete the organization. Remaining related tables cascade automatically.
                $pdo->prepare("DELETE FROM coalition_organizations WHERE id = :org")->execute([':org' => $orgId]);

                $pdo->commit();
                error_log('[super-admin] Organization deleted: ' . $orgId . ' backup: ' . $backupPath);
                ok(['deleted' => true, 'organization_id' => $orgId, 'backup_path' => $backupPath]);
            } catch (Throwable $e) {
                $pdo->rollBack();
                throw $e;
            }

        case 'assign_ticket':
            $ticketId = (int)($_POST['ticket_id'] ?? 0);
            $assignTo = (int)($_POST['assigned_to'] ?? 0);
            if ($ticketId <= 0) fail('Ticket ID is required.');
            $pdo->prepare("
                UPDATE support_tickets
                   SET assigned_to = :uid,
                       status = CASE WHEN status = 'open' THEN 'in_progress' ELSE status END,
                       updated_at = CURRENT_TIMESTAMP
                 WHERE id = :id
            ")->execute([':uid' => $assignTo ?: null, ':id' => $ticketId]);
            ok(['assigned' => true]);

        case 'resolve_ticket':
            $ticketId = (int)($_POST['ticket_id'] ?? 0);
            $note = trim((string)($_POST['resolution_note'] ?? ''));
            if ($ticketId <= 0) fail('Ticket ID is required.');
            $pdo->prepare("
                UPDATE support_tickets
                   SET status = 'resolved',
                       resolved_at = CURRENT_TIMESTAMP,
                       resolved_by = :uid,
                       resolution_note = :note,
                       updated_at = CURRENT_TIMESTAMP
                 WHERE id = :id
            ")->execute([':uid' => $currentUserId, ':note' => $note, ':id' => $ticketId]);
            ok(['resolved' => true]);

        case 'bulk_eligibility_preset':
            $orgId = (int)($_POST['organization_id'] ?? 0);
            $preset = trim($_POST['preset'] ?? '');
            if ($orgId <= 0) fail('Organization ID is required.');

            $presets = require __DIR__ . '/../config/eligibility-presets.php';
            if (!isset($presets[$preset])) fail("Unknown preset: {$preset}");

            $rules = $presets[$preset];
            $created = 0;

            // Resolve type_codes to IDs
            $codeToId = [];
            $ctStmt = $pdo->query("SELECT id, type_code FROM criteria_types");
            foreach ($ctStmt->fetchAll() as $ct) {
                $codeToId[$ct['type_code']] = (int) $ct['id'];
            }

            $ins = $pdo->prepare("
                INSERT INTO organization_eligibility_rules
                    (organization_id, criteria_type_id, rule_operator, rule_value, priority, is_active)
                VALUES (:org_id, :criteria_type_id, :operator, :value, :priority, :is_active)
            ");

            foreach ($rules as $rule) {
                $typeCode = $rule['criteria_type_code'];
                if (!isset($codeToId[$typeCode])) {
                    error_log("[super-admin] Skipping eligibility rule: unknown criteria_type_code '{$typeCode}'");
                    continue;
                }

                $ins->execute([
                    ':org_id'           => $orgId,
                    ':criteria_type_id' => $codeToId[$typeCode],
                    ':operator'         => $rule['operator'],
                    ':value'            => $rule['value'],
                    ':priority'         => (int) ($rule['priority'] ?? 0),
                    ':is_active'        => (bool) ($rule['is_active'] ?? true),
                ]);
                $created++;
            }

            ok(['created' => $created, 'preset' => $preset]);

        case 'block_ip':
            $ipAddr = trim((string)($_POST['ip_address'] ?? ''));
            $reason = trim((string)($_POST['reason'] ?? ''));
            $expires = trim((string)($_POST['expires_at'] ?? ''));
            if ($ipAddr === '' || !filter_var($ipAddr, FILTER_VALIDATE_IP)) {
                fail('Valid IP address is required.');
            }

            // Ensure table exists (migration may not have been run yet)
            $pdo->exec("
                CREATE TABLE IF NOT EXISTS blocked_ips (
                    id          BIGSERIAL PRIMARY KEY,
                    ip_address  VARCHAR(45) NOT NULL UNIQUE,
                    blocked_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                    blocked_by  BIGINT REFERENCES system_users(id),
                    reason      TEXT,
                    is_active   BOOLEAN NOT NULL DEFAULT true,
                    expires_at  TIMESTAMPTZ,
                    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
                )
            ");

            $ins = $pdo->prepare("
                INSERT INTO blocked_ips (ip_address, blocked_by, reason, expires_at, is_active)
                VALUES (:ip, :by, :reason, " . ($expires ? ":expires" : "NULL") . ", true)
                ON CONFLICT (ip_address) DO UPDATE
                    SET is_active = true, reason = :reason, blocked_at = NOW(),
                        expires_at = " . ($expires ? ":expires" : "NULL") . ", blocked_by = :by
            ");
            $params = [':ip' => $ipAddr, ':by' => $currentUserId, ':reason' => $reason];
            if ($expires) {
                $params[':expires'] = $expires;
            }
            $ins->execute($params);

            // Also clear existing login attempts for this IP
            $pdo->prepare("DELETE FROM login_attempts WHERE ip_address = :ip")
                ->execute([':ip' => $ipAddr]);

            ok(['blocked' => $ipAddr, 'reason' => $reason]);

        case 'unblock_ip':
            $ipAddr = trim((string)($_POST['ip_address'] ?? ''));
            if ($ipAddr === '') {
                fail('IP address is required.');
            }

            $upd = $pdo->prepare("
                UPDATE blocked_ips SET is_active = false
                WHERE ip_address = :ip
            ");
            $upd->execute([':ip' => $ipAddr]);

            ok(['unblocked' => $ipAddr]);

        default:
            fail('Unknown action.');
    }
} catch (Throwable $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    error_log('[super-admin] ' . $e->getMessage());
    fail('Server error: ' . $e->getMessage());
}
