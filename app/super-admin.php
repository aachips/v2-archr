<?php declare(strict_types=1);

/* Super-Administrator portal.
   Provides system-level organization and user management.
   Rendered using the shared portal layout. */

require_once __DIR__ . '/lib/auth.php';
archr_require_auth();

require_once __DIR__ . '/lib/db.php';
require_once __DIR__ . '/lib/portal-layout.php';

$pdo = archr_pdo();

// Verify the logged-in user actually has the SUPER_ADMIN role.
$userId = (int)($_SESSION['archr_user_id'] ?? 0);
$roleCheck = $pdo->prepare("
    SELECT 1
      FROM user_role_assignments ura
      JOIN roles r ON r.id = ura.role_id
     WHERE ura.user_id = :uid
       AND r.role_code = 'SUPER_ADMIN'
       AND ura.is_active = true
     LIMIT 1
");
$roleCheck->execute([':uid' => $userId]);
if (!$roleCheck->fetch()) {
    header('HTTP/1.0 403 Forbidden');
    echo 'Forbidden: Super-Admin access required.';
    exit;
}

// Load data for the dashboard.
$orgs = $pdo->query("
    SELECT id, organization_code, organization_name, contact_email, contact_phone, description,
           funding_limit, max_active_applications, auto_claim_enabled, notification_email, is_active, created_at
      FROM coalition_organizations
     ORDER BY created_at DESC
")->fetchAll();

$userSearch = trim((string)($_GET['user_q'] ?? ''));
$viewAllUsers = !empty($_GET['user_view_all']);
$userWhere = ['1=1'];
$userParams = [];
if ($userSearch !== '') {
    $userWhere[] = "(u.username ILIKE :q OR u.email ILIKE :q OR u.full_name ILIKE :q)";
    $userParams[':q'] = '%' . $userSearch . '%';
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
if (!$viewAllUsers) {
    $userSql .= " LIMIT 100";
}
$userStmt = $pdo->prepare($userSql);
$userStmt->execute($userParams);
$users = $userStmt->fetchAll();

$roles = $pdo->query("
    SELECT id, role_code, role_name
      FROM roles
     WHERE is_system_role = true
     ORDER BY role_level DESC, role_name
")->fetchAll();

$counts = $pdo->query("
    SELECT
        (SELECT COUNT(*) FROM coalition_organizations) AS org_count,
        (SELECT COUNT(*) FROM system_users) AS user_count,
        (SELECT COUNT(*) FROM intake_submissions) AS submission_count,
        (SELECT COUNT(*) FROM cases) AS case_count
")->fetch();

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

// ── Helpdesk tickets ──
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

$catLabels = [
    'bug' => '🐛 Bug',
    'feature_request' => '💡 Feature',
    'access_issue' => '🔑 Access',
    'data_error' => '📊 Data',
    'general' => '❓ General',
];

$priorityColors = [
    'critical' => '#dc2626',
    'high' => '#f59e0b',
    'normal' => '#3b82f6',
    'low' => '#6b7280',
];

// Super admin user list for assign dropdown
$allUsers = $pdo->query("SELECT id, full_name FROM system_users WHERE is_active = true ORDER BY full_name")->fetchAll();

$fullName = $_SESSION['archr_user_name'] ?? 'Super Admin';
$initials = archr_initials_from_name($fullName);

// ── Login attempts (for security monitoring) ──
$loginAttempts = [];
$tableExists = $pdo->query("SELECT 1 FROM information_schema.tables WHERE table_name = 'login_attempts' LIMIT 1")->fetch();
if ($tableExists) {
    $loginAttempts = $pdo->query("
        SELECT ip_address,
               COUNT(*) AS attempt_count,
               MIN(attempted_at) AS first_attempt,
               MAX(attempted_at) AS last_attempt,
               string_agg(DISTINCT email, ', ') AS targeted_emails
          FROM login_attempts
         WHERE attempted_at > NOW() - INTERVAL '24 hours'
         GROUP BY ip_address
         ORDER BY attempt_count DESC, last_attempt DESC
         LIMIT 100
    ")->fetchAll();
}

// ── Blocked IPs ──
$blockedIpsSql = "SELECT ip_address, blocked_at, blocked_by, reason, is_active
                    FROM blocked_ips
                   ORDER BY blocked_at DESC";
if ($pdo->query("SELECT 1 FROM information_schema.tables WHERE table_name = 'blocked_ips' LIMIT 1")->fetch()) {
    $blockedIps = $pdo->query($blockedIpsSql)->fetchAll();
} else {
    $blockedIps = [];
}

archr_render_portal_header([
    'role'            => 'super-admin',
    'role_label'      => 'Super Admin',
    'brand'           => 'ARCHR Super Admin',
    'page_title'      => 'System Dashboard',
    'user_name'       => $fullName,
    'avatar_initials' => $initials,
    'badge_icon'      => 'fa-shield-halved',
    'extra_head'      => '<link rel="stylesheet" href="assets/role-super-admin.css">',
    'nav' => archr_super_admin_nav('dashboard'),
]);

require __DIR__ . '/partials/super-admin-body.php';

archr_render_portal_footer();
