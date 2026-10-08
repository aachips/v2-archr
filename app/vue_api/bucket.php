<?php declare(strict_types=1);
/**
 * Documents Bucket endpoint for the Vue app.
 *
 * POST /app/vue_api/bucket.php { "action": "list", "path": "optional/folder/path" }
 *
 * Requires a valid auth token. Returns the bucket tree (Dropbox or local).
 */

require_once __DIR__ . '/token-middleware.php';
$user = vue_require_auth_token();

require_once __DIR__ . '/../lib/db.php';
require_once __DIR__ . '/../lib/case-documents.php';

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
$action = trim((string)($input['action'] ?? 'list'));
$path = trim((string)($input['path'] ?? ''));

switch ($action) {
    case 'list':
        $result = ['success' => true, 'mode' => 'local', 'path' => $path, 'entries' => [], 'account' => null];

        // Try Dropbox first if configured
        if (archr_dropbox_configured()) {
            $result['mode'] = 'dropbox';
            $result['account'] = archr_dropbox_account();

            $listing = archr_dropbox_list($path);
            if ($listing['ok']) {
                $result['entries'] = $listing['entries'];
            } else {
                $result['error'] = $listing['error'] ?? 'unknown';
            }
        } else {
            // Fallback: local bucket tree
            $pdo = archr_pdo();
            $bucketTree = archr_doc_bucket_tree([], []);
            $node = archr_doc_bucket_at($bucketTree, $path);
            if ($node) {
                $result['entries'] = $node['children'] ?? [];
            }
        }

        echo json_encode($result);
        break;

    case 'open':
        // Resolve a file path to a download link (Dropbox temp link or local redirect)
        $filePath = trim((string)($input['file_path'] ?? ''));
        if ($filePath === '') {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'file_path is required']);
            break;
        }

        if (archr_dropbox_configured()) {
            $link = archr_dropbox_temporary_link($filePath);
            if ($link) {
                echo json_encode(['success' => true, 'url' => $link]);
            } else {
                http_response_code(404);
                echo json_encode(['success' => false, 'error' => 'File not found']);
            }
        } else {
            echo json_encode(['success' => true, 'url' => '/app/api/documents.php?action=download&path=' . urlencode($filePath)]);
        }
        break;

    default:
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Unknown action: ' . $action]);
}
