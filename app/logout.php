<?php
declare(strict_types=1);

/* Logout: destroy session and redirect to login. */

require_once __DIR__ . '/lib/session.php';
archr_session_start();

// Clear the session-mode cookie so the next login starts with the default 24-hour lifetime.
setcookie(ARCHR_SESSION_MODE_COOKIE, '', [
    'expires'  => 1,
    'path'     => archr_cookie_path(),
    'domain'   => '',
    'secure'   => !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off',
    'httponly' => true,
    'samesite' => 'Lax',
]);

session_destroy();
header('Location: login.php');
exit;
