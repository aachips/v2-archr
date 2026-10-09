<?php 
declare(strict_types=1);
ini_set('display_errors', 1);
error_reporting(E_ALL);
/**
 * Auth bridge for the Vue app.
 *
 * POST /app/vue_api/auth.php  { "email": "...", "password": "..." }
 * POST /app/vue_api/auth.php  { "action": "verify", "token": "..." }
 *
 * Actions:
 *   login   (default) — authenticate with email/username + password
 *   verify  — validate a previously issued token and return user info
 *
 * Returns JSON:
 *   { "success": true, "token": "...", "user": { ... } }
 *   { "success": false, "error": "..." }
 */

require_once __DIR__ . '/../lib/db.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: ' . ($_SERVER['HTTP_ORIGIN'] ?? '*'));
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Access-Control-Allow-Credentials: true');

// Handle CORS preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit;
}

// ---------------------------------------------------------------------------
// Token helpers
// ---------------------------------------------------------------------------

/**
 * Load the signing secret from environment or .env fallback.
 * In production this MUST be set via AUTH_SECRET_KEY environment variable.
 */
function get_auth_secret(): string {
    $secret = getenv('AUTH_SECRET_KEY');
    if ($secret !== false && $secret !== '') {
        return $secret;
    }
    // Fallback: read from app/.env if present (development only)
    $envFile = __DIR__ . '/../.env';
    if (file_exists($envFile)) {
        $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        foreach ($lines as $line) {
            $line = trim($line);
            if (strpos($line, '#') === 0) continue;
            if (preg_match('/^AUTH_SECRET_KEY\s*=\s*(.+)$/', $line, $m)) {
                return trim($m[1]);
            }
        }
    }
    // Last resort — development only, log a warning
    error_log('[auth] AUTH_SECRET_KEY not set — using insecure fallback');
    return 'change-me-in-production';
}

/**
 * Create a signed auth token (HMAC-SHA256, JWT-like structure without a library).
 *
 * Format: base64url(header).base64url(payload).base64url(signature)
 */
function create_auth_token(array $payload, int $ttlSeconds = 86400): string {
    $secret = get_auth_secret();
    $header = ['typ' => 'ARCHR', 'alg' => 'HS256'];
    $payload['exp'] = time() + $ttlSeconds;
    $payload['iat'] = time();

    $headerB64 = base64url_encode(json_encode($header));
    $bodyB64   = base64url_encode(json_encode($payload));
    $sigB64    = base64url_encode(hash_hmac('sha256', "$headerB64.$bodyB64", $secret, true));

    return "$headerB64.$bodyB64.$sigB64";
}

/**
 * Verify a signed token. Returns the payload array on success, null on failure.
 */
function verify_auth_token(string $token): ?array {
    $secret = get_auth_secret();
    $parts  = explode('.', $token, 3);
    if (count($parts) !== 3) return null;

    [$headerB64, $bodyB64, $sigB64] = $parts;

    // Recompute signature
    $expectedSig = base64url_encode(hash_hmac('sha256', "$headerB64.$bodyB64", $secret, true));
    if (!hash_equals($expectedSig, $sigB64)) return null;

    // Decode payload
    $payload = json_decode(base64url_decode($bodyB64), true);
    if (!$payload) return null;

    // Check expiration
    if (isset($payload['exp']) && time() > (int)$payload['exp']) return null;

    return $payload;
}

/**
 * URL-safe Base64 encoding (RFC 7515 / JWT standard).
 */
function base64url_encode(string $data): string {
    return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
}

function base64url_decode(string $data): string {
    $remainder = strlen($data) % 4;
    if ($remainder) {
        $data .= str_repeat('=', 4 - $remainder);
    }
    return base64_decode($data);
}

// ---------------------------------------------------------------------------
// Response helpers
// ---------------------------------------------------------------------------

function auth_fail(string $message, int $code = 401): void {
    http_response_code($code);
    echo json_encode(['success' => false, 'error' => $message]);
    exit;
}

function auth_ok(array $data): void {
    echo json_encode(array_merge(['success' => true], $data));
    exit;
}

// ---------------------------------------------------------------------------
// Rate limiting helpers
// ---------------------------------------------------------------------------

/**
 * Check if the current IP is rate-limited due to too many failed login attempts.
 * Returns true if the IP should be blocked, false otherwise.
 */
function is_ip_rate_limited(PDO $pdo, string $ip): bool {
    // Check if table exists (migration may not have been run)
    try {
        $stmt = $pdo->prepare("
            SELECT COUNT(*) AS fail_count,
                   MAX(attempted_at) AS last_attempt
              FROM login_attempts
             WHERE ip_address = :ip
               AND attempted_at > NOW() - INTERVAL '15 minutes'
        ");
        $stmt->execute([':ip' => $ip]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        // Table doesn't exist yet — skip rate limiting until migration is run
        return false;
    }

    if (!$row || (int)$row['fail_count'] === 0) {
        return false;
    }

    $failCount = (int)$row['fail_count'];
    $lastAttempt = strtotime((string)$row['last_attempt']);
    $now = time();

    // 5+ failures in 15 minutes → progressive cooldown
    if ($failCount >= 10 && ($now - $lastAttempt) < 1800) {
        return true; // 30 min cooldown
    }
    if ($failCount >= 5 && ($now - $lastAttempt) < 300) {
        return true; // 5 min cooldown
    }

    return false;
}

/**
 * Record a failed login attempt for rate limiting.
 */
function record_login_attempt(PDO $pdo, string $ip, string $email): void {
    try {
        $pdo->prepare("
            INSERT INTO login_attempts (ip_address, email, attempted_at)
            VALUES (:ip, :email, NOW())
        ")->execute([':ip' => $ip, ':email' => $email]);

        // Clean up old attempts (> 1 hour)
        $pdo->prepare("DELETE FROM login_attempts WHERE attempted_at < NOW() - INTERVAL '1 hour'")
            ->execute();
    } catch (PDOException $e) {
        // Table doesn't exist yet — silently skip
    }
}

/**
 * Clear rate limit for an IP on successful login.
 */
function clear_login_attempts(PDO $pdo, string $ip): void {
    try {
        $pdo->prepare("DELETE FROM login_attempts WHERE ip_address = :ip")
            ->execute([':ip' => $ip]);
    } catch (PDOException $e) {
        // Table doesn't exist yet — silently skip
    }
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

$input = json_decode(file_get_contents('php://input'), true);
if (!$input) {
    auth_fail('Invalid JSON body', 400);
}

$action = trim((string)($input['action'] ?? 'login'));

// ---- LOGOUT (clear cookie) ----
if ($action === 'logout') {
    setcookie('archr_session', '', time() - 3600, '/', '', !empty($_SERVER['HTTPS']), true);
    echo json_encode(['success' => true, 'message' => 'Logged out']);
    exit;
}

// ---- TOKEN VERIFICATION (stateless, no DB needed) ----
if ($action === 'verify') {
    $token = trim((string)($input['token'] ?? ''));
    if ($token === '') {
        auth_fail('Token is required', 400);
    }

    $payload = verify_auth_token($token);
    if (!$payload) {
        // Clear stale cookie if token is invalid
        setcookie('archr_session', '', time() - 3600, '/', '', !empty($_SERVER['HTTPS']), true);
        auth_fail('Invalid or expired token', 401);
    }

    // Refresh cookie TTL on successful verify
    $ttl = (int)($payload['exp'] ?? 0) - time();
    if ($ttl > 0) {
        setcookie('archr_session', $token, [
            'expires' => time() + $ttl,
            'path' => '/',
            'domain' => '',
            'secure' => !empty($_SERVER['HTTPS']),
            'httponly' => true,
            'samesite' => 'Lax',
        ]);
    }

    // Token is valid — return the embedded user info
    auth_ok([
        'token' => $token,  // echo back so the client can keep using it
        'user'  => [
            'id'           => (int)$payload['user_id'],
            'email'        => $payload['email'],
            'full_name'    => $payload['full_name'] ?? '',
            'role'         => $payload['role'] ?? 'viewer',
            'role_display' => $payload['role_display'] ?? 'Viewer',
            'role_level'   => (int)($payload['role_level'] ?? 0),
        ],
    ]);
}

// ---- LOGIN (default action) ----

$email    = trim((string)($input['email'] ?? ''));
$password = (string)($input['password'] ?? '');
$remember = (bool)($input['remember_me'] ?? false);

if ($email === '' || $password === '') {
    auth_fail('Email and password are required', 400);
}

$pdo = archr_pdo();

// Get client IP (handle proxy headers if present)
$clientIp = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['HTTP_X_REAL_IP'] ?? $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';
$clientIp = trim(explode(',', $clientIp)[0]); // Take first IP if chained

// Check rate limit
if (is_ip_rate_limited($pdo, $clientIp)) {
    auth_fail('Too many failed login attempts. Please try again in a few minutes.');
}

// Check if IP is blocked by Super Admin
try {
    $blockedStmt = $pdo->prepare("
        SELECT 1 FROM blocked_ips
         WHERE ip_address = :ip
           AND is_active = true
           AND (expires_at IS NULL OR expires_at > NOW())
         LIMIT 1
    ");
    $blockedStmt->execute([':ip' => $clientIp]);
    if ($blockedStmt->fetch()) {
        auth_fail('Access denied. This IP address has been blocked by an administrator.');
    }
} catch (PDOException $e) {
    // blocked_ips table doesn't exist yet — skip check
}

// Look up user by email or username
$stmt = $pdo->prepare("
    SELECT u.id, u.username, u.email, u.full_name, u.password_hash, u.is_active, u.session_indefinite,
           r.role_code, r.role_name, r.role_level
    FROM system_users u
    LEFT JOIN user_role_assignments ura ON ura.user_id = u.id AND ura.is_active = true
    LEFT JOIN roles r ON r.id = ura.role_id
    WHERE u.email = :email OR u.username = :email
    LIMIT 1
");
$stmt->execute([':email' => $email]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$user) {
    record_login_attempt($pdo, $clientIp, $email);
    auth_fail('Invalid credentials');
}

if ((bool)$user['is_active'] === false) {
    record_login_attempt($pdo, $clientIp, $email);
    auth_fail('Account is disabled. Contact an administrator.');
}

// Verify password
if (!empty($user['password_hash'])) {
    if (!password_verify($password, $user['password_hash'])) {
        record_login_attempt($pdo, $clientIp, $email);
        auth_fail('Invalid credentials');
    }
} else {
    // Legacy fallback: demo accounts without a password_hash
    error_log('[auth] Legacy password fallback used for user: ' . $user['username']);
    if ($password !== '12345') {
        record_login_attempt($pdo, $clientIp, $email);
        auth_fail('Invalid credentials');
    }
}

// Update last login timestamp
$updateStmt = $pdo->prepare("UPDATE system_users SET last_login = NOW() WHERE id = :id");
$updateStmt->execute([':id' => $user['id']]);

// Clear rate limit for this IP on successful login
clear_login_attempts($pdo, $clientIp);

// Determine token TTL: indefinite (1 year) > remember_me (30 days) > default (24 hours)
$indefinite = (bool)($user['session_indefinite'] ?? false);
$ttl = $indefinite ? 31536000 : ($remember ? 2592000 : 86400);
$tokenPayload = [
    'user_id'      => (int)$user['id'],
    'email'        => $user['email'],
    'full_name'    => $user['full_name'],
    'role'         => strtolower((string)($user['role_code'] ?? 'viewer')),
    'role_display' => $user['role_name'] ?? 'Viewer',
    'role_level'   => (int)($user['role_level'] ?? 0),
];
$token = create_auth_token($tokenPayload, $ttl);

// Set HttpOnly cookie for root-level session detection
// Cookie is readable by PHP but not JavaScript (HttpOnly),
// secure in production (HTTPS), available site-wide (path=/)
$cookieName = 'archr_session';
$cookieOptions = [
    'expires' => time() + $ttl,
    'path' => '/',
    'domain' => '',              // current domain
    'secure' => !empty($_SERVER['HTTPS']),  // true in production
    'httponly' => true,          // not accessible via JavaScript
    'samesite' => 'Lax',         // CSRF protection
];
$cookieSet = setcookie($cookieName, $token, $cookieOptions);
error_log("[auth] Cookie '$cookieName' set: " . ($cookieSet ? 'YES' : 'NO') . ", TTL=$ttl, path=/");

auth_ok([
    'token' => $token,
    'user'  => [
        'id'           => (int)$user['id'],
        'email'        => $user['email'],
        'full_name'    => $user['full_name'],
        'role'         => strtolower((string)($user['role_code'] ?? 'viewer')),
        'role_display' => $user['role_name'] ?? 'Viewer',
        'role_level'   => (int)($user['role_level'] ?? 0),
    ],
]);
