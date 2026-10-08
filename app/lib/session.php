<?php declare(strict_types=1);
/**
 * Centralized session management for ARCHR.
 *
 * Default session lifetime: 24 hours.
 * Indefinite (persistent) session lifetime: 30 days.
 *
 * The chosen mode is stored in a small companion cookie so the correct
 * lifetime can be applied before session_start() on every request.
 */

const ARCHR_SESSION_DEFAULT_LIFETIME = 86400;      // 24 hours
const ARCHR_SESSION_INDEFINITE_LIFETIME = 2592000; // 30 days
const ARCHR_SESSION_MODE_COOKIE = 'archr_session_mode';

/**
 * Determine the application's cookie path from the request URL.
 * This supports deployments where the app is in a subdirectory
 * (e.g., /archr/repo/app/) instead of the domain root /app/.
 */
function archr_cookie_path(): string {
    $script = $_SERVER['SCRIPT_NAME'] ?? '/';
    $appPos = strpos($script, '/app/');
    if ($appPos !== false) {
        return substr($script, 0, $appPos + 5); // include trailing slash
    }
    return '/';
}

/**
 * Determine the intended session lifetime from the session-mode cookie.
 */
function archr_session_lifetime(): int {
    $mode = $_COOKIE[ARCHR_SESSION_MODE_COOKIE] ?? 'default';
    return $mode === 'indefinite' ? ARCHR_SESSION_INDEFINITE_LIFETIME : ARCHR_SESSION_DEFAULT_LIFETIME;
}

/**
 * Configure session cookie parameters before starting the session.
 */
function archr_configure_session(): void {
    if (session_status() !== PHP_SESSION_NONE) {
        return;
    }

    $lifetime = archr_session_lifetime();
    $secure = !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off';
    $httponly = true;
    $samesite = 'Lax';

    // Use the PHP 7.3+ signature with an options array.
    session_set_cookie_params([
        'lifetime' => $lifetime,
        'path'     => archr_cookie_path(),
        'domain'   => '',
        'secure'   => $secure,
        'httponly' => $httponly,
        'samesite' => $samesite,
    ]);

    ini_set('session.gc_maxlifetime', (string) $lifetime);
}

/**
 * Start the session with the correct lifetime.
 */
function archr_session_start(): void {
    if (session_status() === PHP_SESSION_NONE) {
        archr_configure_session();
        session_start();
    }
}

/**
 * Set or clear the indefinite session mode for the current user.
 * Updates the companion cookie and refreshes the session cookie lifetime.
 */
function archr_set_session_mode(bool $indefinite): void {
    $lifetime = $indefinite ? ARCHR_SESSION_INDEFINITE_LIFETIME : ARCHR_SESSION_DEFAULT_LIFETIME;
    $mode = $indefinite ? 'indefinite' : 'default';
    $secure = !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off';
    $path = archr_cookie_path();

    setcookie(
        ARCHR_SESSION_MODE_COOKIE,
        $mode,
        [
            'expires'  => time() + $lifetime,
            'path'     => $path,
            'domain'   => '',
            'secure'   => $secure,
            'httponly' => true,
            'samesite' => 'Lax',
        ]
    );

    $_COOKIE[ARCHR_SESSION_MODE_COOKIE] = $mode;
    $_SESSION['archr_session_indefinite'] = $indefinite;
}
