<?php
declare(strict_types=1);

/* -----------------------------------------------------------------
 * Early duplicate-check API for the public intake form.
 *
 * Receives a JSON payload with email / address / phone values and
 * reports whether a recent submission already matches any of them.
 * The response is non-blocking: it is only a warning.
 * ----------------------------------------------------------------- */

require_once __DIR__ . '/../lib/db.php';
require_once __DIR__ . '/../lib/intake-duplicate.php';

header('Content-Type: application/json; charset=UTF-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    header('Allow: POST');
    echo json_encode(['success' => false, 'error' => 'Method Not Allowed']);
    exit;
}

$raw = file_get_contents('php://input') ?: '';
$payload = json_decode($raw, true);
if (!is_array($payload)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Invalid JSON body']);
    exit;
}

try {
    $pdo = archr_pdo();
    $dup = archr_intake_find_duplicate(
        $pdo,
        $payload['email'] ?? null,
        $payload['home_address'] ?? null,
        $payload['home_phone'] ?? null,
        $payload['cell_phone'] ?? null
    );

    $response = [
        'success'       => true,
        'duplicate'     => $dup !== null,
        'call_in_number' => archr_intake_call_in_number(),
    ];

    if ($dup) {
        $response['submission'] = [
            'id'          => (int)$dup['id'],
            'submitted_at' => $dup['submitted_at'],
            'match_label' => archr_intake_duplicate_match_label(
                $dup,
                $payload['email'] ?? null,
                $payload['home_address'] ?? null,
                $payload['home_phone'] ?? null,
                $payload['cell_phone'] ?? null
            ),
        ];
    }

    echo json_encode($response);
} catch (Throwable $e) {
    error_log('[check-duplicate] ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Unable to check duplicates right now.']);
}
