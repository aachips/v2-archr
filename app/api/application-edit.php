<?php declare(strict_types=1);
/**
 * Application contact edit API.
 *
 *   POST application_id, first_name, last_name, email, phone
 *
 * Writes the APPLICATION layer (the editable working copy) — never the raw
 * submission (SOP: editing-applicant-contact-info). Reads prefer the
 * application copy: archr_load_case() COALESCEs application values over the
 * submission's.
 *
 * Access: org admin / super admin (archr_require_org_admin).
 *
 * Ledger: one permanent activity_log entry (application_updated) plus one
 * activity_detail row per changed field (old -> new) — the granular 30-day
 * tier's first real use.
 */

require_once __DIR__ . '/../lib/auth.php';
archr_require_auth();

require_once __DIR__ . '/../lib/db.php';
require_once __DIR__ . '/../lib/org-admin.php';
require_once __DIR__ . '/../lib/applications.php';
require_once __DIR__ . '/../lib/activity-log.php';

header('Content-Type: application/json; charset=UTF-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    header('Allow: POST');
    echo json_encode(['success' => false, 'error' => 'Method Not Allowed']);
    exit;
}

function edit_fail(string $message): void {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => $message]);
    exit;
}

$pdo = archr_pdo();
archr_require_org_admin($pdo);

$applicationId = (int)($_POST['application_id'] ?? 0);
if ($applicationId === 0) edit_fail('Application ID is required.');

$appCheck = $pdo->prepare("SELECT id FROM applications WHERE id = :id");
$appCheck->execute([':id' => $applicationId]);
if (!$appCheck->fetch()) edit_fail('Application not found.');

$fields = [
    'first_name' => trim((string)($_POST['first_name'] ?? '')),
    'last_name'  => trim((string)($_POST['last_name'] ?? '')),
    'email'      => trim((string)($_POST['email'] ?? '')),
    'phone'      => trim((string)($_POST['phone'] ?? '')),
];
if ($fields['email'] !== '' && !filter_var($fields['email'], FILTER_VALIDATE_EMAIL)) {
    edit_fail('That email address does not look right.');
}
if ($fields['first_name'] === '' && $fields['last_name'] === '') {
    edit_fail('A first or last name is required.');
}

try {
    $changed = archr_update_application_contact($pdo, $applicationId, $fields);
} catch (InvalidArgumentException $e) {
    edit_fail($e->getMessage());
}

if ($changed === []) {
    echo json_encode(['success' => true, 'changed' => [], 'message' => 'No changes.']);
    exit;
}

// Permanent curated entry…
$pretty = [
    'applicant_first_name' => 'first name',
    'applicant_last_name'  => 'last name',
    'applicant_email'      => 'email',
    'applicant_phone'      => 'phone',
];
$names = array_map(fn($c) => $pretty[$c] ?? $c, array_keys($changed));
$ledgerId = archr_log_event($pdo, 'application_updated', [
    'application_id' => $applicationId,
    'summary'        => 'Applicant contact updated: ' . implode(', ', $names),
    'details'        => ['changed_fields' => array_keys($changed)],
]);

// …plus one granular 30-day detail row per changed field (old -> new).
foreach ($changed as $column => $pair) {
    archr_log_detail($pdo, 'application_field_changed', [
        'ledger_id'      => $ledgerId,
        'application_id' => $applicationId,
        'field_name'     => $column,
        'old_value'      => $pair['old'],
        'new_value'      => $pair['new'],
    ]);
}

echo json_encode(['success' => true, 'changed' => array_keys($changed)]);