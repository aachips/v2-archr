<?php declare(strict_types=1);
/**
 * Vue Super-Admin API — token-authenticated JSON endpoint.
 * Mirrors the functionality of api/super-admin.php but uses Vue token auth.
 *
 * Actions (POST):
 *   create_organization, create_user, reset_password, update_organization,
 *   create_eligibility_rule, delete_eligibility_rule, delete_organization,
 *   assign_ticket, resolve_ticket, bulk_eligibility_preset, block_ip, unblock_ip
 *
 * Data fetch (GET action param or no action):
 *   ?action=overview → KPI counts, orgs, users, roles, tickets, security data
 */

require_once __DIR__ . '/token-middleware.php';
require_once __DIR__ . '/../lib/db.php';
require_once __DIR__ . '/../lib/organization-export.php';

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

function requireSuperAdmin(array $payload, PDO $pdo): void {
    if ((int)($payload['role_level'] ?? 0) < 3) {
        http_response_code(403);
        echo json_encode(['success' => false, 'error' => 'Forbidden: Super Admin access required']);
        exit;
    }
}

$pdo = archr_pdo();
$user = vue_require_auth_token();
requireSuperAdmin($user, $pdo);

$userId = (int)$user['user_id'];
$action = $_GET['action'] ?? trim((string)($_POST['action'] ?? ''));

// ── Data fetch (GET or POST with no action) ──
if ($_SERVER['REQUEST_METHOD'] === 'GET' || $action === '') {
    // User search via GET param
    if ($action === 'users' || ($_GET['action'] ?? '') === 'users') {
        $q = trim((string)($_GET['q'] ?? ''));
        $all = !empty($_GET['all']);
        $userWhere = ['1=1'];
        $userParams = [];
        if ($q !== '') {
            $userWhere[] = "(u.username ILIKE :q OR u.email ILIKE :q OR u.full_name ILIKE :q)";
            $userParams[':q'] = '%' . $q . '%';
        }
        $userSql = "
            SELECT u.id, u.username, u.email, u.full_name, u.phone, u.is_active, u.last_login, u.created_at,
                   string_agg(DISTINCT r.role_name, ', ' ORDER BY r.role_name) AS roles
              FROM system_users u
              LEFT JOIN user_role_assignments ura ON ura.user_id = u.id AND ura.is_active = true
              LEFT JOIN roles r ON r.id = ura.role_id
             WHERE " . implode(' AND ', $userWhere) . "
             GROUP BY u.id, u.username, u.email, u.full_name, u.phone, u.is_active, u.last_login, u.created_at
             ORDER BY u.created_at DESC
        ";
        if (!$all) $userSql .= " LIMIT 100";
        $stmt = $pdo->prepare($userSql);
        $stmt->execute($userParams);
        ok(['users' => $stmt->fetchAll()]);
    }

    $counts = $pdo->query("
        SELECT
            (SELECT COUNT(*) FROM coalition_organizations) AS org_count,
            (SELECT COUNT(*) FROM system_users) AS user_count,
            (SELECT COUNT(*) FROM intake_submissions) AS submission_count,
            (SELECT COUNT(*) FROM cases) AS case_count
    ")->fetch();

    $orgs = $pdo->query("
        SELECT id, organization_code, organization_name, contact_email, contact_phone, description,
               funding_limit, max_active_applications, auto_claim_enabled, notification_email, is_active, created_at
          FROM coalition_organizations
         ORDER BY created_at DESC
    ")->fetchAll();

    $roles = $pdo->query("
        SELECT id, role_code, role_name
          FROM roles
         WHERE is_system_role = true
         ORDER BY role_level DESC, role_name
    ")->fetchAll();

    $criteriaTypes = $pdo->query("
        SELECT id, type_code, type_name, input_type, description
          FROM criteria_types
         ORDER BY type_name
    ")->fetchAll();

    $eligibilityRules = $pdo->query("
        SELECT r.id, r.organization_id, r.rule_operator, r.rule_value, r.priority, r.is_active,
               ct.type_name, ct.input_type, o.organization_name
          FROM organization_eligibility_rules r
          JOIN criteria_types ct ON ct.id = r.criteria_type_id
          JOIN coalition_organizations o ON o.id = r.organization_id
         ORDER BY o.organization_name, r.priority DESC, ct.type_name
    ")->fetchAll();

    $tickets = $pdo->query("
        SELECT t.*, su.full_name AS submitter_display_name, au.full_name AS assigned_name
          FROM support_tickets t
          LEFT JOIN system_users su ON su.id = t.submitted_by
          LEFT JOIN system_users au ON au.id = t.assigned_to
         ORDER BY
           CASE t.priority WHEN 'critical' THEN 1 WHEN 'high' THEN 2 WHEN 'normal' THEN 3 WHEN 'low' THEN 4 ELSE 5 END,
           t.created_at DESC
         LIMIT 100
    ")->fetchAll();

    $allUsers = $pdo->query("SELECT id, full_name FROM system_users WHERE is_active = true ORDER BY full_name")->fetchAll();

    $loginAttempts = [];
    $tableExists = $pdo->query("SELECT 1 FROM information_schema.tables WHERE table_name = 'login_attempts' LIMIT 1")->fetch();
    if ($tableExists) {
        $loginAttempts = $pdo->query("
            SELECT ip_address, COUNT(*) AS attempt_count,
                   MIN(attempted_at) AS first_attempt, MAX(attempted_at) AS last_attempt,
                   string_agg(DISTINCT email, ', ') AS targeted_emails
              FROM login_attempts
             WHERE attempted_at > NOW() - INTERVAL '24 hours'
             GROUP BY ip_address
             ORDER BY attempt_count DESC, last_attempt DESC
             LIMIT 100
        ")->fetchAll();
    }

    $blockedIps = [];
    if ($pdo->query("SELECT 1 FROM information_schema.tables WHERE table_name = 'blocked_ips' LIMIT 1")->fetch()) {
        $blockedIps = $pdo->query("SELECT ip_address, blocked_at, blocked_by, reason, is_active FROM blocked_ips ORDER BY blocked_at DESC")->fetchAll();
    }

    ok([
        'counts'           => $counts,
        'organizations'    => $orgs,
        'roles'            => $roles,
        'criteriaTypes'    => $criteriaTypes,
        'eligibilityRules' => $eligibilityRules,
        'tickets'          => $tickets,
        'allUsers'         => $allUsers,
        'users'            => $allUsers, // default user list (same as allUsers for initial load)
        'loginAttempts'    => $loginAttempts,
        'blockedIps'       => $blockedIps,
    ]);
}

// ── Mutations (POST) ──
try {
    switch ($action) {
        case 'create_organization': {
            $code = trim((string)($_POST['organization_code'] ?? ''));
            $name = trim((string)($_POST['organization_name'] ?? ''));
            $email = trim((string)($_POST['contact_email'] ?? ''));
            $phone = trim((string)($_POST['contact_phone'] ?? ''));
            if ($code === '' || $name === '') fail('Organization code and name are required.');
            $stmt = $pdo->prepare("
                INSERT INTO coalition_organizations (organization_code, organization_name, contact_email, contact_phone, created_by)
                VALUES (:code, :name, :email, :phone, :by) RETURNING id
            ");
            $stmt->execute([':code' => $code, ':name' => $name, ':email' => $email ?: null, ':phone' => $phone ?: null, ':by' => $userId]);
            ok(['organization_id' => (int)$stmt->fetchColumn()]);
        }

        case 'create_user': {
            $fullName = trim((string)($_POST['full_name'] ?? ''));
            $username = trim((string)($_POST['username'] ?? ''));
            $email    = trim((string)($_POST['email'] ?? ''));
            $phone    = trim((string)($_POST['phone'] ?? ''));
            $roleId   = (int)($_POST['role_id'] ?? 0);
            $orgId    = (int)($_POST['organization_id'] ?? 0);
            if ($fullName === '' || $username === '' || $email === '' || $roleId <= 0) {
                fail('Full name, username, email, and role are required.');
            }
            $tempPass = bin2hex(random_bytes(8));
            $hash = password_hash($tempPass, PASSWORD_DEFAULT);
            $stmt = $pdo->prepare("
                INSERT INTO system_users (username, email, full_name, phone, password_hash, is_active, created_by)
                VALUES (:u, :e, :f, :p, :h, true, :by) RETURNING id
            ");
            $stmt->execute([':u' => $username, ':e' => $email, ':f' => $fullName, ':p' => $phone ?: null, ':h' => $hash, ':by' => $userId]);
            $newUserId = (int)$stmt->fetchColumn();
            $pdo->prepare("
                INSERT INTO user_role_assignments (user_id, organization_id, role_id, assigned_by)
                VALUES (:uid, :oid, :rid, :by)
            ")->execute([':uid' => $newUserId, ':oid' => $orgId, ':rid' => $roleId, ':by' => $userId]);
            ok(['user_id' => $newUserId, 'username' => $username, 'password' => $tempPass]);
        }

        case 'reset_password': {
            $targetId = (int)($_POST['user_id'] ?? 0);
            if ($targetId <= 0) fail('User ID is required.');
            $tempPass = bin2hex(random_bytes(8));
            $hash = password_hash($tempPass, PASSWORD_DEFAULT);
            $pdo->prepare("UPDATE system_users SET password_hash = :h WHERE id = :id")
                ->execute([':h' => $hash, ':id' => $targetId]);
            $stmt = $pdo->prepare("SELECT username FROM system_users WHERE id = :id");
            $stmt->execute([':id' => $targetId]);
            $uname = $stmt->fetchColumn() ?: '';
            ok(['username' => $uname, 'password' => $tempPass]);
        }

        case 'update_organization': {
            $id = (int)($_POST['organization_id'] ?? 0);
            if ($id <= 0) fail('Organization ID is required.');
            $name = trim((string)($_POST['organization_name'] ?? ''));
            if ($name === '') fail('Organization name is required.');
            $pdo->prepare("
                UPDATE coalition_organizations SET
                    organization_name = :name,
                    contact_email = :email,
                    contact_phone = :phone,
                    description = :desc,
                    funding_limit = :funding,
                    max_active_applications = :maxapps,
                    notification_email = :notif,
                    auto_claim_enabled = :autoclaim,
                    is_active = :active,
                    updated_by = :by
                WHERE id = :id
            ")->execute([
                ':name' => $name, ':email' => $_POST['contact_email'] ?? null,
                ':phone' => $_POST['contact_phone'] ?? null, ':desc' => $_POST['description'] ?? null,
                ':funding' => $_POST['funding_limit'] !== '' ? $_POST['funding_limit'] : null,
                ':maxapps' => $_POST['max_active_applications'] !== '' ? (int)$_POST['max_active_applications'] : null,
                ':notif' => $_POST['notification_email'] ?? null,
                ':autoclaim' => isset($_POST['auto_claim_enabled']),
                ':active' => isset($_POST['is_active']),
                ':by' => $userId, ':id' => $id,
            ]);
            ok();
        }

        case 'create_eligibility_rule': {
            $orgId = (int)($_POST['organization_id'] ?? 0);
            $typeId = (int)($_POST['criteria_type_id'] ?? 0);
            $operator = trim((string)($_POST['rule_operator'] ?? ''));
            $value = trim((string)($_POST['rule_value'] ?? ''));
            $priority = (int)($_POST['priority'] ?? 0);
            if ($orgId <= 0 || $typeId <= 0 || $value === '') fail('All fields are required.');
            $pdo->prepare("
                INSERT INTO organization_eligibility_rules (organization_id, criteria_type_id, rule_operator, rule_value, priority)
                VALUES (:oid, :tid, :op, :val, :pri)
            ")->execute([':oid' => $orgId, ':tid' => $typeId, ':op' => $operator, ':val' => $value, ':pri' => $priority]);
            ok();
        }

        case 'delete_eligibility_rule': {
            $ruleId = (int)($_POST['rule_id'] ?? 0);
            if ($ruleId <= 0) fail('Rule ID is required.');
            $pdo->prepare("DELETE FROM organization_eligibility_rules WHERE id = :id")->execute([':id' => $ruleId]);
            ok();
        }

        case 'delete_organization': {
            $id = (int)($_POST['organization_id'] ?? 0);
            if ($id <= 0) fail('Organization ID is required.');
            // Run the same export+delete as the original API
            export_organization_data($pdo, $id);
            $pdo->prepare("DELETE FROM coalition_organizations WHERE id = :id")->execute([':id' => $id]);
            ok(['message' => 'Organization deleted with backup']);
        }

        case 'assign_ticket': {
            $ticketId = (int)($_POST['ticket_id'] ?? 0);
            $assignTo = (int)($_POST['assigned_to'] ?? 0);
            if ($ticketId <= 0) fail('Ticket ID is required.');
            $pdo->prepare("UPDATE support_tickets SET assigned_to = :to, updated_at = NOW() WHERE id = :id")
                ->execute([':to' => $assignTo ?: null, ':id' => $ticketId]);
            ok();
        }

        case 'resolve_ticket': {
            $ticketId = (int)($_POST['ticket_id'] ?? 0);
            $note = trim((string)($_POST['resolution_note'] ?? ''));
            if ($ticketId <= 0) fail('Ticket ID is required.');
            $pdo->prepare("UPDATE support_tickets SET status = 'resolved', resolution_note = :note, updated_at = NOW() WHERE id = :id")
                ->execute([':note' => $note, ':id' => $ticketId]);
            ok();
        }

        case 'bulk_eligibility_preset': {
            $orgId = (int)($_POST['organization_id'] ?? 0);
            $preset = trim((string)($_POST['preset'] ?? ''));
            if ($orgId <= 0 || $preset === '') fail('Organization and preset are required.');
            // Use the same presets as the original API
            $presets = include __DIR__ . '/../lib/eligibility-presets.php';
            if (!isset($presets[$preset])) fail('Unknown preset: ' . $preset);
            $pdo->beginTransaction();
            foreach ($presets[$preset] as $rule) {
                $pdo->prepare("
                    INSERT INTO organization_eligibility_rules (organization_id, criteria_type_id, rule_operator, rule_value, priority)
                    VALUES (:oid, :tid, :op, :val, :pri)
                ")->execute([
                    ':oid' => $orgId, ':tid' => $rule['type_id'],
                    ':op' => $rule['operator'], ':val' => $rule['value'], ':pri' => $rule['priority'] ?? 0,
                ]);
            }
            $pdo->commit();
            ok(['count' => count($presets[$preset])]);
        }

        case 'block_ip': {
            $ip = trim((string)($_POST['ip_address'] ?? ''));
            $reason = trim((string)($_POST['reason'] ?? ''));
            if ($ip === '') fail('IP address is required.');
            if ($pdo->query("SELECT 1 FROM information_schema.tables WHERE table_name = 'blocked_ips' LIMIT 1")->fetch()) {
                $pdo->prepare("INSERT INTO blocked_ips (ip_address, reason, blocked_by) VALUES (:ip, :reason, :by)")
                    ->execute([':ip' => $ip, ':reason' => $reason, ':by' => $userId]);
            }
            ok();
        }

        case 'unblock_ip': {
            $id = (int)($_POST['block_id'] ?? 0);
            if ($id <= 0) fail('Block ID is required.');
            if ($pdo->query("SELECT 1 FROM information_schema.tables WHERE table_name = 'blocked_ips' LIMIT 1")->fetch()) {
                $pdo->prepare("DELETE FROM blocked_ips WHERE id = :id")->execute([':id' => $id]);
            }
            ok();
        }

        default:
            fail('Unknown action: ' . $action);
    }
} catch (Throwable $e) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    fail('Server error: ' . $e->getMessage());
}
