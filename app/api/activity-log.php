<?php
declare(strict_types=1);

/**
 * Activity Log API endpoint.
 * Wraps archr_activity_query() from app/lib/activity-log.php for JSON access.
 * Used by both the PHP audit-log.php viewer and the Vue app.
 *
 * GET  /app/api/activity-log.php  → query ledger entries
 * POST /app/api/activity-log.php  → verify chain integrity
 *
 * Auth: requires PHP session OR Vue auth token (Authorization: Bearer).
 */

require __DIR__ . '/../lib/auth.php';
require __DIR__ . '/../lib/db.php';
require __DIR__ . '/../lib/activity-log.php';

// Accept either PHP session auth or Vue auth token.
if (!archr_is_authenticated()) {
    // Try Vue token from Authorization header
    require_once __DIR__ . '/../vue_api/token-middleware.php';
    try {
        vue_require_auth_token();
    } catch (\Throwable $e) {
        // If token also fails, require standard auth (will 401)
        archr_require_auth();
    }
}

header('Content-Type: application/json');

$pdo = archr_pdo();
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    // Query ledger entries with optional filters.
    $filters = [];
    if (isset($_GET['user_id']) && $_GET['user_id'] !== '') {
        $filters['user_id'] = (int)$_GET['user_id'];
    }
    if (isset($_GET['application_id']) && $_GET['application_id'] !== '') {
        $filters['application_id'] = (int)$_GET['application_id'];
    }
    if (isset($_GET['case_id']) && $_GET['case_id'] !== '') {
        $filters['case_id'] = (int)$_GET['case_id'];
    }
    if (isset($_GET['category']) && $_GET['category'] !== '') {
        $filters['category'] = $_GET['category'];
    }
    if (isset($_GET['action']) && $_GET['action'] !== '') {
        $filters['action'] = $_GET['action'];
    }
    if (isset($_GET['source']) && $_GET['source'] !== '') {
        $filters['source'] = $_GET['source'];
    }
    if (isset($_GET['since']) && $_GET['since'] !== '') {
        $filters['since'] = $_GET['since'];
    }
    if (isset($_GET['until']) && $_GET['until'] !== '') {
        $filters['until'] = $_GET['until'];
    }
    if (isset($_GET['search']) && $_GET['search'] !== '') {
        $filters['search'] = $_GET['search'];
    }
    if (isset($_GET['limit']) && $_GET['limit'] !== '') {
        $limit = (int)$_GET['limit'];
        $filters['limit'] = min($limit, 1000);
    }
    if (isset($_GET['offset']) && $_GET['offset'] !== '') {
        $filters['offset'] = (int)$_GET['offset'];
    }

    $rows = archr_activity_query($pdo, $filters);

    // Resolve household labels for display.
    $appIds = array_unique(array_filter(array_map(fn($r) => (int)($r['application_id'] ?? 0), $rows)));
    $labels = [];
    if ($appIds) {
        $in = implode(',', $appIds);
        $labelRows = $pdo->query(
            "SELECT id, COALESCE(placecode, display_name, 'Application #' || id) AS label FROM applications WHERE id IN ($in)"
        )->fetchAll(PDO::FETCH_KEY_PAIR);
        $labels = $labelRows;
    }

    // Also resolve labels from case_id for entries without application_id (Vue app).
    $caseIds = array_unique(array_filter(array_map(fn($r) => (int)($r['case_id'] ?? 0), $rows)));
    if ($caseIds) {
        $in = implode(',', $caseIds);
        $caseLabels = $pdo->query(
            "SELECT id, COALESCE(placecode, 'Case #' || id) AS label FROM cases WHERE id IN ($in)"
        )->fetchAll(PDO::FETCH_KEY_PAIR);
        // Only set label if not already set from application_id
        foreach ($caseLabels as $cid => $lbl) {
            if (!in_array($lbl, $labels, true)) {
                $labels[$cid] = $lbl;
            }
        }
    }

    $formatted = array_map(function ($row) use ($labels) {
        $appId = (int)($row['application_id'] ?? 0);
        $details = $row['details'];
        if (is_string($details)) {
            $details = json_decode($details, true) ?: [];
        }
        return [
            'id' => (int)$row['id'],
            'event_guid' => $row['event_guid'],
            'created_at' => $row['created_at'],
            'user_id' => (int)($row['user_id'] ?? 0),
            'user_name' => $row['user_name'] ?? '',
            'session_id' => $row['session_id'] ?? '',
            'ip_address' => $row['ip_address'] ?? '',
            'application_id' => $appId,
            'case_id' => (int)($row['case_id'] ?? 0),
            'organization_id' => (int)($row['organization_id'] ?? 0),
            'category' => $row['category'] ?? 'system',
            'action' => $row['action'] ?? '',
            'summary' => $row['summary'] ?? '',
            'details' => $details,
            'source' => $row['source'] ?? 'web',
            'household_label' => $labels[$appId] ?? $labels[(int)($row['case_id'] ?? 0)] ?? null,
            'detail_rows' => [], // populated below
        ];
    }, $rows);

    // Fetch detail rows for each ledger entry.
    if ($formatted) {
        $ledgerIds = array_map(fn($r) => $r['id'], $formatted);
        $in = implode(',', $ledgerIds);
        $detailRows = $pdo->query(
            "SELECT ledger_id, field_name, old_value, new_value, action, details, source, created_at
             FROM activity_detail WHERE ledger_id IN ($in) ORDER BY id"
        )->fetchAll();
        // Group by ledger_id
        $byLedger = [];
        foreach ($detailRows as $dr) {
            $lid = (int)$dr['ledger_id'];
            if (!isset($byLedger[$lid])) $byLedger[$lid] = [];
            $d = $dr['details'];
            if (is_string($d)) $d = json_decode($d, true) ?: [];
            $byLedger[$lid][] = [
                'field_name' => $dr['field_name'],
                'old_value'  => $dr['old_value'],
                'new_value'  => $dr['new_value'],
                'action'     => $dr['action'],
                'details'    => $d,
                'source'     => $dr['source'],
                'created_at' => $dr['created_at'],
            ];
        }
        foreach ($formatted as &$row) {
            $row['detail_rows'] = $byLedger[$row['id']] ?? [];
        }
    }

    // Get distinct categories, actions, sources for filter dropdowns.
    $distinctCats = $pdo->query("SELECT DISTINCT category FROM activity_log ORDER BY category")->fetchAll(PDO::FETCH_COLUMN);
    $distinctActions = $pdo->query("SELECT DISTINCT action FROM activity_log ORDER BY action")->fetchAll(PDO::FETCH_COLUMN);
    $distinctSources = $pdo->query("SELECT DISTINCT source FROM activity_log ORDER BY source")->fetchAll(PDO::FETCH_COLUMN);

    // Get user list for dropdown.
    $users = $pdo->query("SELECT id, full_name FROM system_users ORDER BY full_name")->fetchAll();

    echo json_encode([
        'success' => true,
        'data' => $formatted,
        'meta' => [
            'categories' => $distinctCats,
            'actions' => $distinctActions,
            'sources' => $distinctSources,
            'users' => $users,
            'count' => count($formatted),
        ],
    ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

} elseif ($method === 'POST') {
    // Verify chain integrity.
    $result = archr_activity_verify_chain($pdo, 'activity_log', 0);
    echo json_encode([
        'success' => true,
        'chain' => $result,
    ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

} else {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
}
