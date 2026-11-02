<?php
declare(strict_types=1);

/* -----------------------------------------------------------------
 * ARCHR intake form handler
 * Receives a JSON POST from intake.js, hands it to the PostgreSQL
 * function submit_intake_application(), and returns its JSONB
 * result verbatim. Configured for Laragon's local PostgreSQL by
 * default; override with the standard libpq environment variables
 * (PGHOST, PGPORT, PGDATABASE, PGUSER, PGPASSWORD).
 * ----------------------------------------------------------------- */

// --- Config -------------------------------------------------------
$DB_HOST = getenv('PGHOST')     ?: '127.0.0.1';
$DB_PORT = getenv('PGPORT')     ?: '5432';
$DB_NAME = getenv('PGDATABASE') ?: 'archr';
$DB_USER = getenv('PGUSER')     ?: 'postgres';
$DB_PASS = getenv('PGPASSWORD') ?: '';

const LOG_DIR  = __DIR__ . '/logs';
const LOG_FILE = 'intake-submissions.jsonl';

header('Content-Type: application/json; charset=UTF-8');

// --- Guard: only accept POST -------------------------------------
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    header('Allow: POST');
    echo json_encode(['success' => false, 'error' => 'Method Not Allowed']);
    exit;
}

// --- Decode JSON body --------------------------------------------
$raw = file_get_contents('php://input') ?: '';
$payload = json_decode($raw, true);
if (!is_array($payload)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Invalid JSON body']);
    exit;
}

// --- Honeypot: silently accept-then-drop bot submissions ---------
// Real users never see the "website" field; bots fill in every input.
if (!empty($payload['website'] ?? '')) {
    echo json_encode(['success' => true, 'submission_id' => 0, 'bot' => true]);
    exit;
}
unset($payload['website']);

// --- Optional account creation -----------------------------------
// intake.js may include these top-level keys to opt in.
$createAccount = !empty($payload['createAccount']);
$email         = isset($payload['accountEmail']) && is_string($payload['accountEmail'])
                    ? trim($payload['accountEmail']) : null;
$plainPassword = isset($payload['accountPassword']) && is_string($payload['accountPassword'])
                    ? $payload['accountPassword'] : null;
unset($payload['createAccount'], $payload['accountEmail'], $payload['accountPassword']);

if ($createAccount) {
    if (!$email || !filter_var($email, FILTER_VALIDATE_EMAIL) || !$plainPassword) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Email and password required to create an account']);
        exit;
    }
}

// --- Log to disk BEFORE the DB call ------------------------------
// Guarantees a paper trail even if PostgreSQL is down.
if (!is_dir(LOG_DIR)) {
    @mkdir(LOG_DIR, 0750, true);
}
$record = [
    'received_at' => date(DATE_ATOM),
    'ip'          => $_SERVER['REMOTE_ADDR']     ?? null,
    'user_agent'  => $_SERVER['HTTP_USER_AGENT'] ?? null,
    'payload'     => $payload,
];
@file_put_contents(
    LOG_DIR . '/' . LOG_FILE,
    json_encode($record, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES) . "\n",
    FILE_APPEND | LOCK_EX
);

// --- Connect to PostgreSQL ---------------------------------------
try {
    $pdo = new PDO(
        "pgsql:host={$DB_HOST};port={$DB_PORT};dbname={$DB_NAME}",
        $DB_USER,
        $DB_PASS,
        [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]
    );
} catch (Throwable $e) {
    error_log('[intake] DB connect failed: ' . $e->getMessage());
    http_response_code(503);
    echo json_encode(['success' => false, 'error' => 'Database unavailable']);
    exit;
}

// --- Call submit_intake_application(...) -------------------------
try {
    $stmt = $pdo->prepare(
        'SELECT submit_intake_application(
            :form_data::jsonb,
            :create_account::boolean,
            :email,
            :password_hash,
            :ip::inet,
            :ua
        ) AS result'
    );
    // Hash the password here (bcrypt) before it ever touches the DB.
    $passwordHash = $createAccount ? password_hash($plainPassword, PASSWORD_BCRYPT) : null;
    $stmt->execute([
        ':form_data'      => json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES),
        ':create_account' => $createAccount ? 'true' : 'false',
        ':email'          => $email,
        ':password_hash'  => $passwordHash,
        ':ip'             => $_SERVER['REMOTE_ADDR']     ?? '0.0.0.0',
        ':ua'             => $_SERVER['HTTP_USER_AGENT'] ?? '',
    ]);
    $row = $stmt->fetch();
} catch (Throwable $e) {
    error_log('[intake] submit_intake_application failed: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Submission processing failed']);
    exit;
}

if (!$row || !isset($row['result'])) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Empty response from database']);
    exit;
}

// $row['result'] is a JSON-encoded string from PostgreSQL JSONB.
// Decode + re-encode so the client gets a clean object.
$result = json_decode($row['result'], true);
if (!is_array($result)) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Malformed response from database']);
    exit;
}

if (empty($result['success'])) {
    http_response_code(422);
}
echo json_encode($result);
