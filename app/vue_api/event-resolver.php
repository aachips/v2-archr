<?php declare(strict_types=1);
/**
 * Event Resolver API endpoint for the Vue app.
 *
 * GET  /app/vue_api/event-resolver.php?action=resolve&case_id=123
 * POST /app/vue_api/event-resolver.php  { "action": "resolve", "case_id": 123 }
 *
 * Returns:
 *   { "success": true, "phase": 2, "phase_name": "Processing", "milestones": [...], ... }
 *
 * Uses token-middleware for auth.
 */

require_once __DIR__ . '/token-middleware.php';
require_once __DIR__ . '/../lib/db.php';
require_once __DIR__ . '/../lib/event-resolver/resolver.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: ' . ($_SERVER['HTTP_ORIGIN'] ?? '*'));
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$user = vue_require_auth_token();
$pdo = archr_pdo();

// Parse input
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $action = $_GET['action'] ?? 'resolve';
    $caseId = (int) ($_GET['case_id'] ?? 0);
} else {
    $raw = json_decode(file_get_contents('php://input'), true);
    $action = $raw['action'] ?? 'resolve';
    $caseId = (int) ($raw['case_id'] ?? 0);
}

if ($caseId <= 0) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'case_id is required']);
    exit;
}

if ($action === 'resolve') {
    $result = archr_resolve($pdo, $caseId);
    echo json_encode(['success' => true] + $result);
    exit;
}

http_response_code(400);
echo json_encode(['success' => false, 'error' => 'Unknown action: ' . $action]);
