<?php declare(strict_types=1);
/**
 * Profile settings endpoint for the Vue app.
 *
 * GET  /app/vue_api/profile.php  { "action": "get" }
 * POST /app/vue_api/profile.php  { "action": "update", "full_name": "...", "email": "...", "phone": "...", "session_indefinite": true }
 *
 * Returns JSON:
 *   { "success": true, "user": { ... } }
 *   { "success": false, "error": "..." }
 */

require_once __DIR__ . '/token-middleware.php';
require_once __DIR__ . '/../lib/db.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: ' . ($_SERVER['HTTP_ORIGIN'] ?? '*'));
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$user = vue_require_auth_token();
$userId = (int) $user['user_id'];
$pdo = archr_pdo();

// Ensure session_indefinite column exists (safe to run every request).
$pdo->exec("ALTER TABLE system_users ADD COLUMN IF NOT EXISTS session_indefinite BOOLEAN DEFAULT false");

// Parse input based on method
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $action = $_GET['action'] ?? 'get';
    $input = [];
} else {
    $rawInput = file_get_contents('php://input');
    $raw = json_decode($rawInput, true);
    if (json_last_error() !== JSON_ERROR_NONE) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Invalid JSON: ' . json_last_error_msg() . ' | Raw: ' . substr($rawInput, 0, 200)]);
        exit;
    }
    $action = $raw['action'] ?? 'update';
    $input = $raw ?: [];
}

if ($action === 'get') {
    $stmt = $pdo->prepare("
        SELECT id, username, full_name, email, phone, session_indefinite
          FROM system_users
         WHERE id = :id
         LIMIT 1
    ");
    $stmt->execute([':id' => $userId]);
    $profile = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$profile) {
        http_response_code(404);
        echo json_encode(['success' => false, 'error' => 'User not found']);
        exit;
    }

    echo json_encode([
        'success' => true,
        'user' => [
            'id'                   => (int) $profile['id'],
            'username'             => $profile['username'],
            'full_name'            => $profile['full_name'] ?? '',
            'email'                => $profile['email'] ?? '',
            'phone'                => $profile['phone'] ?? '',
            'session_indefinite'   => (bool) $profile['session_indefinite'],
        ],
    ]);
    exit;
}

if ($action === 'update') {
    $fullName = trim((string) ($input['full_name'] ?? ''));
    $email    = trim((string) ($input['email'] ?? ''));
    $phone    = trim((string) ($input['phone'] ?? ''));
    $indefinite = (bool) ($input['session_indefinite'] ?? false);

    if ($email === '') {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Email is required']);
        exit;
    }

    // Check for duplicate email (exclude current user)
    $dupStmt = $pdo->prepare("
        SELECT id FROM system_users WHERE email = :email AND id != :id LIMIT 1
    ");
    $dupStmt->execute([':email' => $email, ':id' => $userId]);
    if ($dupStmt->fetch()) {
        http_response_code(409);
        echo json_encode(['success' => false, 'error' => 'Email is already in use by another account']);
        exit;
    }

    $upd = $pdo->prepare("
        UPDATE system_users
           SET full_name = :full_name,
               email = :email,
               phone = :phone,
               session_indefinite = :session_indefinite,
               updated_at = CURRENT_TIMESTAMP
         WHERE id = :id
    ");
    $upd->execute([
        ':full_name'          => $fullName,
        ':email'              => $email,
        ':phone'              => $phone !== '' ? $phone : null,
        ':session_indefinite' => $indefinite,
        ':id'                 => $userId,
    ]);

    // Return updated profile so the client can refresh its state
    echo json_encode([
        'success' => true,
        'user' => [
            'id'                   => $userId,
            'username'             => $user['email'] ?? '',
            'full_name'            => $fullName,
            'email'                => $email,
            'phone'                => $phone,
            'session_indefinite'   => $indefinite,
        ],
    ]);
    exit;
}

if ($action === 'change_password') {
    $currentPassword = (string) ($input['current_password'] ?? '');
    $newPassword     = (string) ($input['new_password'] ?? '');
    $confirmPassword = (string) ($input['confirm_password'] ?? '');

    if ($currentPassword === '' || $newPassword === '' || $confirmPassword === '') {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'All password fields are required']);
        exit;
    }

    if ($newPassword !== $confirmPassword) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'New passwords do not match']);
        exit;
    }

    if (strlen($newPassword) < 8) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Password must be at least 8 characters']);
        exit;
    }

    // Fetch current password hash
    $stmt = $pdo->prepare("SELECT password_hash FROM system_users WHERE id = :id LIMIT 1");
    $stmt->execute([':id' => $userId]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$row) {
        http_response_code(404);
        echo json_encode(['success' => false, 'error' => 'User not found']);
        exit;
    }

    // Verify current password
    if (!password_verify($currentPassword, $row['password_hash'])) {
        http_response_code(401);
        echo json_encode(['success' => false, 'error' => 'Current password is incorrect']);
        exit;
    }

    // Update password
    $hash = password_hash($newPassword, PASSWORD_BCRYPT, ['cost' => 12]);
    $upd = $pdo->prepare("
        UPDATE system_users
           SET password_hash = :hash,
               updated_at = CURRENT_TIMESTAMP
         WHERE id = :id
    ");
    $upd->execute([':hash' => $hash, ':id' => $userId]);

    echo json_encode(['success' => true, 'message' => 'Password changed successfully']);
    exit;
}

http_response_code(400);
echo json_encode(['success' => false, 'error' => 'Unknown action: ' . $action]);
