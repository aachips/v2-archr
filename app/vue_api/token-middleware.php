<?php declare(strict_types=1);
/**
 * Token verification middleware for Vue API endpoints.
 *
 * Include this file in any PHP endpoint that needs to verify the Vue auth token:
 *   require_once __DIR__ . '/vue_api/token-middleware.php';
 *   $user = vue_require_auth_token();
 *
 * The token is read from the Authorization header (Bearer scheme) or from
 * the POST body field `token`. On failure, it exits with a 401 JSON response.
 *
 * On success, returns the decoded user payload array with keys:
 *   user_id, email, full_name, role, role_display, role_level, exp, iat
 */

/**
 * Load the signing secret (must match auth.php's get_auth_secret()).
 */
function vue_get_auth_secret(): string {
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
    error_log('[vue-auth] AUTH_SECRET_KEY not set — using insecure fallback');
    return 'change-me-in-production';
}

/**
 * URL-safe Base64 decoding (matches auth.php).
 */
function vue_base64url_decode(string $data): string {
    $remainder = strlen($data) % 4;
    if ($remainder) {
        $data .= str_repeat('=', 4 - $remainder);
    }
    return base64_decode($data);
}

/**
 * URL-safe Base64 encoding (must match auth.php's base64url_encode).
 */
function vue_base64url_encode(string $data): string {
    return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
}

/**
 * Verify a signed auth token. Returns the payload array on success, null on failure.
 */
function vue_verify_token(string $token): ?array {
    $secret = vue_get_auth_secret();
    $parts  = explode('.', $token, 3);
    if (count($parts) !== 3) return null;

    [$headerB64, $bodyB64, $sigB64] = $parts;

    // Recompute signature using URL-safe encoding
    $expectedSig = vue_base64url_encode(hash_hmac('sha256', "$headerB64.$bodyB64", $secret, true));
    if (!hash_equals($expectedSig, $sigB64)) return null;

    // Decode payload
    $payload = json_decode(vue_base64url_decode($bodyB64), true);
    if (!$payload) return null;

    // Check expiration
    if (isset($payload['exp']) && time() > (int)$payload['exp']) return null;

    return $payload;
}

/**
 * Extract the bearer token from the Authorization header.
 * Returns null if not present or malformed.
 */
function vue_get_bearer_token(): ?string {
    $header = '';
    // Apache mod_php
    if (function_exists('apache_request_headers')) {
        $headers = apache_request_headers();
        $header  = $headers['Authorization'] ?? $headers['authorization'] ?? '';
    }
    // Fallback for other SAPIs
    if (!$header && !empty($_SERVER['HTTP_AUTHORIZATION'])) {
        $header = $_SERVER['HTTP_AUTHORIZATION'];
    }
    if (!$header && !empty($_SERVER['REDIRECT_HTTP_AUTHORIZATION'])) {
        $header = $_SERVER['REDIRECT_HTTP_AUTHORIZATION'];
    }

    if (preg_match('/Bearer\s+(.+)$/i', $header, $matches)) {
        return trim($matches[1]);
    }
    return null;
}

/**
 * Require a valid auth token and return the decoded user payload.
 * Exits with 401 JSON error if no valid token is found.
 *
 * @return array{user_id:int, email:string, full_name:string, role:string, role_display:string, role_level:int}
 */
function vue_require_auth_token(): array {
    // Try Authorization header first (standard), then POST body token (legacy compat)
    $token = vue_get_bearer_token();

    if (!$token) {
        $input = json_decode(file_get_contents('php://input'), true);
        $token = $input['token'] ?? null;
    }

    if (!$token) {
        http_response_code(401);
        header('Content-Type: application/json');
        echo json_encode(['success' => false, 'error' => 'Authentication required']);
        exit;
    }

    $payload = vue_verify_token((string)$token);
    if (!$payload) {
        http_response_code(401);
        header('Content-Type: application/json');
        echo json_encode(['success' => false, 'error' => 'Invalid or expired token']);
        exit;
    }

    return $payload;
}
