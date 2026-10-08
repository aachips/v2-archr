<?php
declare(strict_types=1);

/* Global case search API endpoint. */

require __DIR__ . '/../../lib/auth.php';
require __DIR__ . '/../../lib/db.php';

archr_require_auth();
header('Content-Type: application/json');

$pdo = archr_pdo();
$query = trim($_GET['q'] ?? '');
$filter = trim($_GET['filter'] ?? 'all'); // all, my_cases, recent, urgent

if ($query === '') {
    echo json_encode(['success' => true, 'data' => []]);
    exit;
}

$userId = $_SESSION['archr_user_id'] ?? 0;

// Base query
$sql = "
    SELECT c.id, c.case_number, c.status as case_status,
           s.applicant_first_name, s.applicant_last_name,
           s.home_address, s.home_city, s.home_state, s.home_zip,
           s.cell_phone, s.contact_email,
           a.anchor_id, a.current_status as anchor_status
    FROM cases c
    JOIN intake_submissions s ON s.id = c.submission_id
    LEFT JOIN application_anchor a ON a.submission_id = s.id
    WHERE (
        c.case_number LIKE :query
        OR a.anchor_id LIKE :query
        OR s.home_address LIKE :query
        OR s.cell_phone LIKE :query
        OR CONCAT(s.applicant_first_name, ' ', s.applicant_last_name) LIKE :query
    )
";

// Add filter conditions
$params = [':query' => '%' . $query . '%'];

switch ($filter) {
    case 'my_cases':
        $sql .= " AND c.assigned_caseworker_id = :user_id";
        $params[':user_id'] = $userId;
        break;
    case 'recent':
        $sql .= " AND c.created_at > NOW() - INTERVAL '30 days'";
        break;
    case 'urgent':
        $sql .= " AND c.status IN ('pending_review', 'in_review')
                  AND s.helene_related = 1";
        break;
}

$sql .= " ORDER BY c.created_at DESC LIMIT 20";

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$results = $stmt->fetchAll();

$formatted = array_map(function($r) {
    return [
        'id' => (int)$r['id'],
        'case_number' => $r['case_number'],
        'anchor_id' => $r['anchor_id'],
        'status' => $r['case_status'] ?: $r['anchor_status'],
        'applicant' => [
            'name' => $r['applicant_first_name'] . ' ' . $r['applicant_last_name'],
            'phone' => $r['cell_phone'],
            'email' => $r['contact_email'],
        ],
        'address' => sprintf(
            '%s, %s, %s %s',
            $r['home_address'],
            $r['home_city'],
            $r['home_state'],
            $r['home_zip']
        ),
    ];
}, $results);

echo json_encode([
    'success' => true,
    'data' => $formatted,
    'count' => count($formatted),
], JSON_PRETTY_PRINT);
