<?php
declare(strict_types=1);

/* -----------------------------------------------------------------
 * view-submissions.php — password-protected viewer for the
 * discovery-form responses written to logs/submissions.jsonl.
 *
 * ONE-TIME SETUP:
 *   1. From a terminal on your host (or locally, then paste the result):
 *        php -r "echo password_hash('PICK_A_STRONG_PASSWORD', PASSWORD_DEFAULT), PHP_EOL;"
 *   2. Replace the value of PASSWORD_HASH below with the output
 *      (it starts with $2y$ ...). Do NOT store the plaintext password.
 * ----------------------------------------------------------------- */

const PASSWORD_HASH = '$2y$10$CVCXTMG9NnHA25yzo63NJeR7U3wpEEothdxoqGmIYo876tfAXelry';
const SESSION_NAME  = 'archr_admin';
const LOG_FILE      = __DIR__ . '/logs/submissions.jsonl';

// --- Session cookie hardening ------------------------------------
session_name(SESSION_NAME);
session_set_cookie_params([
    'lifetime' => 0,
    'path'     => '/',
    'secure'   => !empty($_SERVER['HTTPS']),
    'httponly' => true,
    'samesite' => 'Strict',
]);
session_start();

$selfUrl = strtok($_SERVER['REQUEST_URI'], '?');

// --- Logout ------------------------------------------------------
if (isset($_GET['logout'])) {
    $_SESSION = [];
    if (ini_get('session.use_cookies')) {
        $p = session_get_cookie_params();
        setcookie(session_name(), '', time() - 42000,
            $p['path'], $p['domain'], $p['secure'], $p['httponly']);
    }
    session_destroy();
    header('Location: ' . $selfUrl);
    exit;
}

// --- Login -------------------------------------------------------
$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST' && empty($_SESSION['authed'])) {
    $pw   = (string)($_POST['password'] ?? '');
    $csrf = (string)($_POST['csrf'] ?? '');
    if (!hash_equals($_SESSION['csrf'] ?? '', $csrf)) {
        $error = 'Session expired. Reload and try again.';
    } elseif (password_verify($pw, PASSWORD_HASH)) {
        session_regenerate_id(true);
        $_SESSION['authed'] = true;
        $_SESSION['csrf']   = bin2hex(random_bytes(16));
        header('Location: ' . $selfUrl);
        exit;
    } else {
        sleep(1); // throttle brute-force
        $error = 'Wrong password.';
    }
}
if (empty($_SESSION['csrf'])) {
    $_SESSION['csrf'] = bin2hex(random_bytes(16));
}
$authed = !empty($_SESSION['authed']);

// --- Helpers -----------------------------------------------------
function h(?string $s): string {
    return htmlspecialchars((string)$s, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}
function fmtTime(?string $iso): string {
    if (!$iso) return '';
    $t = strtotime($iso);
    return $t ? date('D M j, Y · g:i a', $t) : h($iso);
}

// --- Load submissions (newest first) -----------------------------
$entries = [];
if ($authed && is_readable(LOG_FILE)) {
    $fh = @fopen(LOG_FILE, 'r');
    if ($fh) {
        while (($line = fgets($fh)) !== false) {
            $line = trim($line);
            if ($line === '') continue;
            $row = json_decode($line, true);
            if (is_array($row)) $entries[] = $row;
        }
        fclose($fh);
    }
    $entries = array_reverse($entries);
}

header('Content-Type: text/html; charset=UTF-8');
?><!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="robots" content="noindex, nofollow">
  <title><?= $authed ? 'Submissions · ARCHR Discovery' : 'Sign in' ?></title>
  <style>
    *{margin:0;padding:0;box-sizing:border-box}
    body{background:#f4f7fb;color:#1e2a3a;
         font-family:system-ui,-apple-system,'Segoe UI',Roboto,sans-serif;
         padding:2rem 1rem;line-height:1.5}
    .container{max-width:880px;margin:0 auto}
    header.bar{display:flex;justify-content:space-between;align-items:center;
               margin-bottom:1.5rem;gap:1rem;flex-wrap:wrap}
    header.bar h1{font-size:1.4rem;color:#1e3a2f}
    header.bar .count{color:#5f7f6b;font-size:0.9rem}
    a.logout{color:#2c5f2d;text-decoration:none;font-weight:600;font-size:0.9rem}
    a.logout:hover{text-decoration:underline}
    .card{background:#fff;border:1px solid #e2edf2;border-radius:24px;
          padding:1.5rem;margin-bottom:1.25rem;box-shadow:0 4px 12px rgba(0,0,0,.04)}
    .card h2{font-size:1.1rem;color:#1f3b4c;margin-bottom:.25rem}
    .meta{color:#5f7f6b;font-size:.85rem;margin-bottom:1rem}
    .badge{display:inline-block;background:#2c5f2d;color:#fff;font-size:.75rem;
           padding:.15rem .65rem;border-radius:20px;margin-left:.5rem;vertical-align:middle}
    .badge.muted{background:#e6f0f5;color:#1e5a3a}
    .row{display:flex;gap:.5rem;flex-wrap:wrap;font-size:.92rem;margin:.35rem 0}
    .row .k{font-weight:600;color:#1f3b4c;min-width:7rem}
    .answers{margin-top:1rem;border-top:1px solid #e2edf2;padding-top:1rem}
    .answers .q{margin-bottom:.85rem}
    .answers .q-label{font-weight:600;font-size:.88rem;color:#1f3b4c}
    .answers .q-text{white-space:pre-wrap;color:#2b3d4f;margin-top:.15rem}
    .footer-meta{margin-top:1rem;padding-top:.75rem;border-top:1px dashed #e2edf2;
                 font-size:.75rem;color:#8aa39a;font-family:ui-monospace,monospace;
                 word-break:break-all}
    .empty{background:#fff;border-radius:24px;padding:3rem 2rem;text-align:center;color:#5f7f6b}
    /* Login form */
    .login-card{max-width:380px;margin:4rem auto;background:#fff;border-radius:28px;
                padding:2rem;box-shadow:0 8px 20px rgba(0,0,0,.05);border:1px solid #e2edf2}
    .login-card h1{color:#1e3a2f;font-size:1.4rem;margin-bottom:1.25rem;text-align:center}
    .login-card label{display:block;font-weight:600;font-size:.9rem;margin-bottom:.5rem;color:#1f3b4c}
    .login-card input[type=password]{width:100%;padding:.85rem 1rem;border:1px solid #cbdde6;
                border-radius:20px;font-size:1rem;font-family:inherit}
    .login-card input[type=password]:focus{outline:none;border-color:#2c5f2d;
                box-shadow:0 0 0 3px rgba(44,95,45,.2)}
    .login-card button{width:100%;margin-top:1rem;background:#2c5f2d;color:#fff;border:none;
                padding:.9rem;border-radius:40px;font-size:1rem;font-weight:600;cursor:pointer}
    .login-card button:hover{background:#1e4620}
    .err{background:#fde8e8;color:#9b2c2c;border-radius:14px;padding:.6rem .9rem;
         font-size:.88rem;margin-bottom:1rem;text-align:center}
  </style>
</head>
<body>
<div class="container">
<?php if (!$authed): ?>
  <form class="login-card" method="post" autocomplete="off">
    <h1>🔒 Sign in</h1>
    <?php if ($error !== ''): ?>
      <div class="err"><?= h($error) ?></div>
    <?php endif; ?>
    <label for="pw">Password</label>
    <input id="pw" type="password" name="password" required autofocus>
    <input type="hidden" name="csrf" value="<?= h($_SESSION['csrf']) ?>">
    <button type="submit">Sign in</button>
  </form>
<?php else: ?>
  <header class="bar">
    <div>
      <h1>📥 Discovery submissions</h1>
      <div class="count"><?= count($entries) ?> total · newest first</div>
    </div>
    <a class="logout" href="?logout=1">Sign out →</a>
  </header>

  <?php if (!$entries): ?>
    <div class="empty">No submissions yet. They'll show up here as people respond.</div>
  <?php else: foreach ($entries as $e):
        $answers = is_array($e['answers'] ?? null) ? $e['answers'] : [];
        $contact = (string)($e['contact'] ?? '');
        $isEmail = (bool)filter_var($contact, FILTER_VALIDATE_EMAIL);
        $want    = (string)($e['wantInterview'] ?? '');
  ?>
    <article class="card">
      <h2>
        <?= h($e['name'] ?? '(no name)') ?>
        <?php if (!empty($e['storyInPerson'])): ?>
          <span class="badge">🎥 wants in-person</span>
        <?php endif; ?>
        <?php if ($want === 'yes'): ?>
          <span class="badge muted">📅 wants interview</span>
        <?php endif; ?>
      </h2>
      <div class="meta"><?= h(fmtTime($e['submitted_at'] ?? null)) ?></div>

      <div class="row"><span class="k">Contact:</span>
        <span><?= $isEmail
              ? '<a href="mailto:' . h($contact) . '">' . h($contact) . '</a>'
              : h($contact) ?></span>
      </div>
      <?php if (!empty($e['role'])): ?>
        <div class="row"><span class="k">Role:</span><span><?= h($e['role']) ?></span></div>
      <?php endif; ?>
      <?php if ($want !== ''): ?>
        <div class="row"><span class="k">Interview:</span><span><?= h($want) ?></span></div>
      <?php endif; ?>
      <?php if (!empty($e['availability'])): ?>
        <div class="row"><span class="k">Availability:</span><span><?= h($e['availability']) ?></span></div>
      <?php endif; ?>

      <?php
        $hasAny = false;
        foreach ($answers as $v) { if (trim((string)$v) !== '') { $hasAny = true; break; } }
      ?>
      <?php if ($hasAny): ?>
        <div class="answers">
          <?php foreach ($answers as $label => $val):
                if (trim((string)$val) === '') continue; ?>
            <div class="q">
              <div class="q-label"><?= h((string)$label) ?></div>
              <div class="q-text"><?= h((string)$val) ?></div>
            </div>
          <?php endforeach; ?>
        </div>
      <?php endif; ?>

      <div class="footer-meta">
        IP: <?= h($e['ip'] ?? 'unknown') ?> ·
        UA: <?= h($e['user_agent'] ?? 'unknown') ?>
      </div>
    </article>
  <?php endforeach; endif; ?>
<?php endif; ?>
</div>
</body>
</html>
