<?php declare(strict_types=1);
/**
 * Root entry point for ARCHR.
 *
 * Always serves the public site. If there's an active session cookie,
 * includes a small "session bar" at the top letting the user know they're
 * logged in, with links to Dashboard and Logout.
 *
 * Used on both local (Apache) and VPS (Nginx).
 */

// ---------------------------------------------------------------------------
// Token verifier (duplicated from auth.php to avoid cross-directory includes)
// ---------------------------------------------------------------------------

function get_auth_secret(): string {
    $secret = getenv('AUTH_SECRET_KEY');
    if ($secret !== false && $secret !== '') {
        return $secret;
    }
    $envFile = __DIR__ . '/app/.env';
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
    return 'change-me-in-production';
}

function base64url_decode(string $data): string {
    $remainder = strlen($data) % 4;
    if ($remainder) {
        $data .= str_repeat('=', 4 - $remainder);
    }
    return base64_decode($data);
}

function verify_auth_token(string $token): ?array {
    $secret = get_auth_secret();
    $parts  = explode('.', $token, 3);
    if (count($parts) !== 3) return null;

    [$headerB64, $bodyB64, $sigB64] = $parts;

    $expectedSig = rtrim(strtr(base64_encode(hash_hmac('sha256', "$headerB64.$bodyB64", $secret, true)), '+/', '-_'), '=');
    if (!hash_equals($expectedSig, $sigB64)) return null;

    $payload = json_decode(base64url_decode($bodyB64), true);
    if (!$payload) return null;

    if (isset($payload['exp']) && time() > (int)$payload['exp']) return null;

    return $payload;
}

// ---------------------------------------------------------------------------
// Main — check cookie, serve public site with optional session bar
// ---------------------------------------------------------------------------

$cookieName = 'archr_session';
$cookie = $_COOKIE[$cookieName] ?? null;
$sessionBar = '';

if ($cookie) {
    $payload = verify_auth_token($cookie);
    if ($payload) {
        $fullName = htmlspecialchars($payload['full_name'] ?? 'User', ENT_QUOTES, 'UTF-8');
        $firstName = explode(' ', $fullName)[0];
        $sessionBar = <<<HTML
<style>.nav-dropdown, li.nav-dropdown { display: none !important; }</style>
<!-- Logged-in session bar -->
<div id="archr-session-bar" style="position:sticky;top:0;z-index:9999;background:#1a56db;color:#fff;display:flex;align-items:center;justify-content:space-between;padding:0.5rem 1.5rem;font-family:system-ui,sans-serif;font-size:0.85rem;box-shadow:0 2px 4px rgba(0,0,0,0.1);">
    <span>
        <i class="fas fa-user-check" style="margin-right:0.4rem;"></i>
        Signed in as <strong>$firstName</strong>
    </span>
    <span style="display:flex;gap:0.75rem;">
        <a href="/portal/" style="color:#fff;text-decoration:none;font-weight:600;padding:0.3rem 0.8rem;background:rgba(255,255,255,0.15);border-radius:4px;">
            <i class="fas fa-tachometer-alt" style="margin-right:0.3rem;"></i> Dashboard
        </a>
        <a href="/portal/" id="archr-logout-btn" style="color:#fff;text-decoration:none;font-weight:500;padding:0.3rem 0.8rem;background:rgba(255,255,255,0.1);border-radius:4px;opacity:0.85;">
            <i class="fas fa-sign-out-alt" style="margin-right:0.3rem;"></i> Logout
        </a>
    </span>
</div>
<script>
(function(){
    var btn = document.getElementById('archr-logout-btn');
    if (btn) {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            // Call backend to clear cookie
            fetch('/app/vue_api/auth.php', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({action: 'logout'})
            }).then(function(){
                window.location.reload();
            });
        });
    }
})();
</script>
<script>
// Hide the login dropdown in the header when logged in
(function() {
    var hideLogin = function() {
        var items = document.querySelectorAll('.nav-dropdown, li.nav-dropdown');
        for (var i = 0; i < items.length; i++) {
            items[i].style.display = 'none';
        }
    };
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', hideLogin);
    } else {
        hideLogin();
    }
})();
</script>
<!-- Font Awesome for icons (only if not already loaded) -->
<script>
(function(){
    if (!document.querySelector('.fa-user-check')) {
        var link = document.createElement('link');
        link.rel = 'stylesheet';
        link.href = 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css';
        document.head.appendChild(link);
    }
})();
</script>
HTML;
    } else {
        // Invalid/expired cookie — clear it
        setcookie($cookieName, '', time() - 3600, '/', '', !empty($_SERVER['HTTPS']), true);
    }
}

// Read the public site HTML
$html = file_get_contents(__DIR__ . '/index.html');
if ($html === false) {
    http_response_code(500);
    echo 'Server error';
    exit;
}

// Inject session bar right after <body> if logged in
if ($sessionBar !== '') {
    $html = str_replace('<body>', "<body>\n$sessionBar", $html);
}

echo $html;

