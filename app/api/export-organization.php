<?php
declare(strict_types=1);

/* -----------------------------------------------------------------
 * Download an organization retention archive as JSON.
 * ----------------------------------------------------------------- */

require_once __DIR__ . '/../lib/auth.php';
archr_require_auth();

require_once __DIR__ . '/../lib/db.php';
require_once __DIR__ . '/../lib/organization-export.php';

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
        header('Content-Type: application/json');
        echo json_encode(['success' => false, 'error' => 'Forbidden']);
        exit;
    }
}

$orgId = (int)($_GET['organization_id'] ?? 0);
if ($orgId === 0) {
    http_response_code(400);
    header('Content-Type: application/json');
    echo json_encode(['success' => false, 'error' => 'Organization ID is required.']);
    exit;
}

try {
    $pdo = archr_pdo();
    requireSuperAdmin($pdo);

    $org = $pdo->prepare('SELECT organization_code, organization_name FROM coalition_organizations WHERE id = :org');
    $org->execute([':org' => $orgId]);
    $orgRow = $org->fetch();
    if (!$orgRow) {
        http_response_code(404);
        header('Content-Type: application/json');
        echo json_encode(['success' => false, 'error' => 'Organization not found.']);
        exit;
    }

    $export = archr_export_organization($pdo, $orgId, (int)($_SESSION['archr_user_id'] ?? 0));
    $filename = 'org-archive-' . $orgId . '-' . preg_replace('/[^a-z0-9_-]/i', '', $orgRow['organization_code']) . '-' . date('Ymd-His') . '.json';

    header('Content-Type: application/json; charset=UTF-8');
    header('Content-Disposition: attachment; filename="' . $filename . '"');
    echo json_encode($export, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
} catch (Throwable $e) {
    error_log('[export-organization] ' . $e->getMessage());
    http_response_code(500);
    header('Content-Type: application/json');
    echo json_encode(['success' => false, 'error' => 'Unable to export organization records.']);
}
