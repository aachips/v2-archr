<?php
declare(strict_types=1);

/* -----------------------------------------------------------------
 * Super-Admin maintenance actions.
 * ----------------------------------------------------------------- */

require_once __DIR__ . '/../lib/auth.php';
archr_require_auth();

require_once __DIR__ . '/../lib/db.php';
// user-maintenance.php backs only the cleanup_requestor_accounts action;
// tolerate its absence so other maintenance actions still run.
$userMaintenanceLoaded = is_file(__DIR__ . '/../lib/user-maintenance.php');
if ($userMaintenanceLoaded) {
    require_once __DIR__ . '/../lib/user-maintenance.php';
}
require_once __DIR__ . '/../lib/applications.php';
require_once __DIR__ . '/../lib/activity-log.php';

function requireSuperAdmin(PDO $pdo): void {
    $userId = (int)($_SESSION['archr_user_id'] ?? 0);
    $stmt = $pdo->prepare("
        SELECT 1
          FROM user_role_assignments ura
          JOIN roles r ON r.id = ura.role_id
         WHERE ura.user_id = :uid
           AND r.role_code = 'SUPER_ADMIN'
           AND ura.is_active = true
         LIMIT 1
    ");
    $stmt->execute([':uid' => $userId]);
    if (!$stmt->fetch()) {
        http_response_code(403);
        header('Content-Type: application/json');
        echo json_encode(['success' => false, 'error' => 'Forbidden']);
        exit;
    }
}

header('Content-Type: application/json; charset=UTF-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    header('Allow: POST');
    echo json_encode(['success' => false, 'error' => 'Method Not Allowed']);
    exit;
}

$action = $_POST['action'] ?? '';
if (!in_array($action, ['cleanup_requestor_accounts', 'expire_stale_claims', 'purge_activity_detail'], true)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Unknown action']);
    exit;
}

try {
    $pdo = archr_pdo();
    requireSuperAdmin($pdo);

    if ($action === 'purge_activity_detail') {
        // 30-day rolling tier: erase expired granular detail rows. The
        // permanent ledger (activity_log) is never touched by this.
        $purged = archr_activity_purge($pdo);
        echo json_encode(['success' => true, 'purged' => $purged]);
        exit;
    }

    if ($action === 'expire_stale_claims') {
        // 90-day progress cooldown (terminology doc Part 3): claims with no
        // progress event for 90 days expire; applications with no remaining
        // active claims become 'expired' and can be re-claimed.
        $expired = archr_expire_stale_claims($pdo);
        echo json_encode(['success' => true, 'expired_count' => count($expired), 'expired' => $expired]);
        exit;
    }

    if (!$userMaintenanceLoaded || !function_exists('archr_cleanup_requestor_accounts')) {
        http_response_code(503);
        echo json_encode(['success' => false, 'error' => 'cleanup_requestor_accounts is unavailable: lib/user-maintenance.php is missing.']);
        exit;
    }
    $deleted = archr_cleanup_requestor_accounts($pdo);
    echo json_encode(['success' => true, 'deleted' => $deleted]);
} catch (Throwable $e) {
    error_log('[run-maintenance] ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Maintenance failed.']);
}
