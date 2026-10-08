<?php declare(strict_types=1);
/**
 * Cases API endpoint for the Vue app.
 *
 * POST /app/vue_api/cases.php { "action": "list" }
 *
 * Requires a valid auth token (Bearer header or POST body).
 * Returns cases from Airtable (via the existing dual-write pipeline)
 * with the caller's role-level permissions applied.
 */

require_once __DIR__ . '/token-middleware.php';
$user = vue_require_auth_token();

require_once __DIR__ . '/../lib/db.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: ' . ($_SERVER['HTTP_ORIGIN'] ?? '*'));
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Access-Control-Allow-Credentials: true');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);
$action = trim((string)($input['action'] ?? ''));

switch ($action) {
    case 'list':
        // TODO: Replace with actual case listing from Airtable/PostgreSQL
        // For now, return a placeholder confirming auth works
        echo json_encode([
            'success' => true,
            'user'    => [
                'id'    => $user['user_id'],
                'role'  => $user['role'],
                'level' => $user['role_level'],
            ],
            'message' => 'Auth verified. Cases endpoint ready for implementation.',
            'cases'   => [],
        ]);
        break;

    default:
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Unknown action: ' . $action]);
}
