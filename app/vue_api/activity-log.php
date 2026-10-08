<?php declare(strict_types=1);
/**
 * Activity Log write endpoint for the Vue app.
 *
 * POST /app/vue_api/activity-log.php
 *   { "action": "log", "entry": { ... } }
 *
 * Requires a valid auth token. Writes to the PostgreSQL activity_log table
 * via archr_activity_append() from lib/activity-log.php.
 */

require_once __DIR__ . '/token-middleware.php';
$user = vue_require_auth_token();

require_once __DIR__ . '/../lib/db.php';
require_once __DIR__ . '/../lib/activity-log.php';

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
    case 'log':
        $entry = $input['entry'] ?? [];
        if (!isset($entry['category']) || !isset($entry['action'])) {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'category and action are required']);
            exit;
        }

        $pdo = archr_pdo();

        // Determine if this is a ledger entry or a detail row.
        // Detail rows have ledger_id and field_name at the top level of entry,
        // or nested inside details.
        $ledgerId = $entry['ledger_id'] ?? ($entry['details']['ledger_id'] ?? null);
        $fieldName = $entry['field_name'] ?? ($entry['details']['field_name'] ?? null);
        $oldValue = $entry['old_value'] ?? ($entry['details']['old_value'] ?? '');
        $newValue = $entry['new_value'] ?? ($entry['details']['new_value'] ?? '');
        $isDetail = $ledgerId !== null && $fieldName !== null;

        try {
            if ($isDetail) {
                // Granular detail row (30-day rolling)
                $id = archr_log_detail($pdo, $entry['action'], [
                    'ledger_id'       => (int)$ledgerId,
                    'user_id'         => $user['user_id'],
                    'user_name'       => $user['full_name'] ?? $user['email'],
                    'session_id'      => '',
                    'ip_address'      => $_SERVER['REMOTE_ADDR'] ?? '',
                    'application_id'  => $entry['application_id'] ?? null,
                    'case_id'         => $entry['case_id'] ?? null,
                    'field_name'      => $fieldName,
                    'old_value'       => $oldValue,
                    'new_value'       => $newValue,
                    'details'         => $entry['details'] ?? null,
                    'source'          => $entry['source'] ?? 'vue',
                ]);
            } else {
                // Permanent ledger entry
                $id = archr_log_event($pdo, $entry['action'], [
                    'user_id'         => $user['user_id'],
                    'user_name'       => $user['full_name'] ?? $user['email'],
                    'session_id'      => '',
                    'ip_address'      => $_SERVER['REMOTE_ADDR'] ?? '',
                    'application_id'  => $entry['application_id'] ?? null,
                    'case_id'         => $entry['case_id'] ?? null,
                    'organization_id' => $entry['organization_id'] ?? null,
                    'category'        => $entry['category'],
                    'summary'         => $entry['summary'] ?? '',
                    'details'         => $entry['details'] ?? null,
                    'source'          => $entry['source'] ?? 'vue',
                ]);
            }
            echo json_encode(['success' => true, 'event_id' => $id]);
        } catch (Throwable $e) {
            http_response_code(500);
            echo json_encode(['success' => false, 'error' => $e->getMessage()]);
        }
        break;

    default:
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Unknown action: ' . $action]);
}
