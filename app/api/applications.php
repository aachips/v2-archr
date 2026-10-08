<?php
declare(strict_types=1);

/* -----------------------------------------------------------------
 * Applications API (read-only).
 *
 * Implements the response shape documented in "ARCHR Core Terminology
 * and Operational Logic" Part 5 (GET /api/applications/:id):
 * the application record with submission ids, eligibility flags, and
 * every organization case (claim status, 90-day countdown, projects
 * and repair tasks).
 *
 *   GET app/api/applications.php?id=123
 *   GET app/api/applications.php?placecode=145LAKEW
 *   GET app/api/applications.php?list=1[&status=active][&limit=100]
 *
 * Access: any staff level (1+). Level 2 org admins see applications their
 * orgs hold cases on plus claimable (unclaimed/expired) applications.
 * ----------------------------------------------------------------- */

require_once __DIR__ . '/../lib/auth.php';
archr_require_auth();

require_once __DIR__ . '/../lib/db.php';
require_once __DIR__ . '/../lib/applications.php';
require_once __DIR__ . '/../lib/case-access.php';

header('Content-Type: application/json; charset=UTF-8');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    header('Allow: GET');
    echo json_encode(['success' => false, 'error' => 'Method Not Allowed']);
    exit;
}

$pdo = archr_pdo();
$access = archr_require_staff_access($pdo);

// Org scoping: level 3 (super admin) sees all; org admins see their orgs'
// applications plus the claimable pool.
$orgIds = $access['level'] >= 3 ? null : $access['orgs'];

try {
    if (isset($_GET['list'])) {
        $status = isset($_GET['status']) ? trim((string)$_GET['status']) : null;
        $limit = (int)($_GET['limit'] ?? 100);
        echo json_encode([
            'success' => true,
            'applications' => archr_list_applications($pdo, $orgIds, $status, $limit),
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    $payload = null;
    if (isset($_GET['id'])) {
        $payload = archr_get_application($pdo, (int)$_GET['id']);
    } elseif (isset($_GET['placecode'])) {
        $payload = archr_get_application_by_placecode($pdo, (string)$_GET['placecode']);
    } else {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Provide id, placecode, or list=1']);
        exit;
    }

    if ($payload === null) {
        http_response_code(404);
        echo json_encode(['success' => false, 'error' => 'Application not found']);
        exit;
    }

    // Org admins may only open applications within their scope: one of their
    // orgs holds a case on it, or it is claimable (no active case by anyone).
    if ($orgIds !== null) {
        $appId = (int)$payload['application']['id'];
        if (!$orgIds) {
            http_response_code(403);
            echo json_encode(['success' => false, 'error' => 'Forbidden']);
            exit;
        }
        $in = implode(',', array_map('intval', $orgIds));
        $visStmt = $pdo->prepare("
            SELECT 1 FROM applications a
             WHERE a.id = :id
               AND (EXISTS (SELECT 1 FROM cases c WHERE c.application_id = a.id AND c.organization_id IN ($in))
                    OR NOT EXISTS (SELECT 1 FROM cases c WHERE c.application_id = a.id AND c.claim_status = 'active'))
             LIMIT 1
        ");
        $visStmt->execute([':id' => $appId]);
        if (!$visStmt->fetchColumn()) {
            http_response_code(403);
            echo json_encode(['success' => false, 'error' => 'Forbidden']);
            exit;
        }
    }

    echo json_encode(['success' => true] + $payload, JSON_UNESCAPED_UNICODE);
} catch (Throwable $e) {
    error_log('[api/applications] ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Server error']);
}