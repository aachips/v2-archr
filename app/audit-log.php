<?php declare(strict_types=1);

/* Audit Trail — super-admin read view of the immutable activity ledger
   (activity_log; sql/add/activity-log.sql). Filter by user, household
   (application), case, category, action, source, date range, or summary
   text; the hash chain is verified on every render. */

require_once __DIR__ . '/lib/auth.php';
archr_require_auth();

require_once __DIR__ . '/lib/db.php';
require_once __DIR__ . '/lib/activity-log.php';
require_once __DIR__ . '/lib/portal-layout.php';

$pdo = archr_pdo();

// Super-admin only — same gate as super-admin-portal.php.
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
    http_response_code(403);
    echo 'Forbidden: Super-Admin access required.';
    exit;
}

// ---- Filters (GET) ----
$filters = [
    'user_id'        => (int)($_GET['user_id'] ?? 0) ?: null,
    'application_id' => (int)($_GET['application_id'] ?? 0) ?: null,
    'case_id'        => (int)($_GET['case_id'] ?? 0) ?: null,
    'category'       => trim((string)($_GET['category'] ?? '')),
    'action'         => trim((string)($_GET['action'] ?? '')),
    'source'         => trim((string)($_GET['source'] ?? '')),
    'since'          => trim((string)($_GET['since'] ?? '')),
    'until'          => trim((string)($_GET['until'] ?? '')),
    'search'         => trim((string)($_GET['search'] ?? '')),
];
// Date sanity: accept only Y-m-d from the date inputs.
foreach (['since', 'until'] as $d) {
    if ($filters[$d] !== '' && !preg_match('/^\d{4}-\d{2}-\d{2}$/', $filters[$d])) {
        $filters[$d] = '';
    }
}

$entries = archr_activity_query($pdo, array_filter($filters, fn($v) => $v !== null && $v !== ''));
$verify  = archr_activity_verify_chain($pdo);

// Filter-dropdown data
$users      = $pdo->query("SELECT id, full_name FROM system_users ORDER BY full_name")->fetchAll();
$categories = $pdo->query("SELECT DISTINCT category FROM activity_log ORDER BY category")->fetchAll(PDO::FETCH_COLUMN);
$actions    = $pdo->query("SELECT DISTINCT action FROM activity_log ORDER BY action")->fetchAll(PDO::FETCH_COLUMN);
$sources    = $pdo->query("SELECT DISTINCT source FROM activity_log ORDER BY source")->fetchAll(PDO::FETCH_COLUMN);

// Household labels for the applications in the result set
$appIds = array_unique(array_filter(array_map(fn($e) => (int)($e['application_id'] ?? 0), $entries)));
$appLabels = [];
if ($appIds) {
    $in = implode(',', array_map('intval', $appIds));
    $appLabels = $pdo->query(
        "SELECT id, COALESCE(display_name, placecode, 'Application #' || id) AS label FROM applications WHERE id IN ($in)"
    )->fetchAll(PDO::FETCH_KEY_PAIR);
}

archr_render_portal_header([
    'role'        => 'super-admin',
    'role_label'  => 'Super Admin',
    'brand'       => 'ARCHR Super Admin',
    'page_title'  => archr_translate('audit.title'),
    'user_name'   => $_SESSION['archr_user_name'] ?? '',
    'badge_icon'  => 'fa-clock-rotate-left',
    'nav'         => archr_super_admin_nav('audit', false),
]);

require __DIR__ . '/partials/audit-log-body.php';

archr_render_portal_footer();