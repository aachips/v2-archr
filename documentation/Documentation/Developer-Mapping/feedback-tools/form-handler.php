<?php
declare(strict_types=1);

/* -----------------------------------------------------------------
 * Discovery form handler
 * Receives POST from discovery-form.html and emails the responses.
 * ----------------------------------------------------------------- */

// --- Config -------------------------------------------------------
const MAIL_TO       = 'april@aachips.co';
const MAIL_SUBJECT  = 'ARCHR discovery form — new response';
// Use an address on YOUR domain as the From, so SPF/DKIM pass.
// Many hosts let you create a no-reply mailbox; otherwise reuse your own.
const MAIL_FROM     = 'no-reply@aachips.co';
const MAIL_FROM_NAME = 'ARCHR Discovery Form';
const REDIRECT_AFTER_SUCCESS = ''; // e.g. 'thanks.html' or '' to show inline page
const LOG_DIR  = __DIR__ . '/logs';
const LOG_FILE = 'submissions.jsonl';

// --- Guard: only accept POST -------------------------------------
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    header('Allow: POST');
    exit('Method Not Allowed');
}

// --- Honeypot: silently accept then drop bot submissions ---------
// Real users never see the "website" field. If it's filled in, it's a bot.
// We return 200 + the normal thank-you so the bot thinks it succeeded.
if (!empty($_POST['website'] ?? '')) {
    header('Content-Type: text/html; charset=UTF-8');
    echo '<!doctype html><title>Thanks</title><p>Thanks!</p>';
    exit;
}

// --- Helpers ------------------------------------------------------
function field(string $key, int $maxLen = 5000): string {
    $v = $_POST[$key] ?? '';
    if (!is_string($v)) return '';
    $v = trim($v);
    if (strlen($v) > $maxLen) $v = substr($v, 0, $maxLen);
    // Strip CR/LF from short fields used in headers later (defense in depth)
    return $v;
}

function stripHeaderInjection(string $v): string {
    return preg_replace('/[\r\n]+/', ' ', $v) ?? '';
}

// --- Collect & validate ------------------------------------------
$name    = field('name', 200);
$contact = field('contact', 200);
$role    = field('role', 200);
$want    = field('wantInterview', 20);
$avail   = field('availability', 500);

$storyInPerson = (($_POST['storyInPerson'] ?? '') === 'yes');

$answers = [
    '1. First thing you do when logging in' => field('q_firstAction'),
    '2. Part you avoid or dread'            => field('q_avoid'),
    '3. Recent frustration'                 => field('q_frustration'),
    '4. One thing you would change'         => field('q_oneChange'),
    '5. Wishlist / wild ideas'              => field('q_wishlist'),
    '6. Craziest / coolest story'           => field('q_story'),
];

if ($name === '' || $contact === '') {
    http_response_code(400);
    exit('Please go back and provide at least a name and a way to contact you.');
}

// --- Build the email body (plain text, easy to read on phone) ---
$lines = [];
$lines[] = "New discovery form response";
$lines[] = str_repeat('=', 40);
$lines[] = "Name:    {$name}";
$lines[] = "Contact: {$contact}";
if ($role !== '')  $lines[] = "Role:    {$role}";
$lines[] = "";
$lines[] = "Wants interview: {$want}";
if ($avail !== '') $lines[] = "Availability:    {$avail}";
$lines[] = "";
$lines[] = "Written answers";
$lines[] = str_repeat('-', 40);
foreach ($answers as $label => $val) {
    $lines[] = $label;
    $lines[] = $val !== '' ? $val : '(no answer)';
    $lines[] = "";
}
if ($storyInPerson) {
    $lines[] = "*** Wants to tell the story in person — open to video recording. ***";
    $lines[] = "";
}
$lines[] = str_repeat('=', 40);
$lines[] = "Submitted: " . date('Y-m-d H:i:s T');
$lines[] = "IP:        " . ($_SERVER['REMOTE_ADDR'] ?? 'unknown');
$lines[] = "UA:        " . ($_SERVER['HTTP_USER_AGENT'] ?? 'unknown');

$body = implode("\r\n", $lines);

// --- Log to JSON Lines file (one record per line) ----------------
// Written BEFORE sending mail so a mail failure never loses a submission.
$record = [
    'submitted_at'    => date(DATE_ATOM),
    'name'            => $name,
    'contact'         => $contact,
    'role'            => $role,
    'wantInterview'   => $want,
    'availability'    => $avail,
    'answers'         => $answers,
    'storyInPerson'   => $storyInPerson,
    'ip'              => $_SERVER['REMOTE_ADDR']     ?? null,
    'user_agent'      => $_SERVER['HTTP_USER_AGENT'] ?? null,
];

if (!is_dir(LOG_DIR)) {
    @mkdir(LOG_DIR, 0750, true);
}
$logPath = LOG_DIR . '/' . LOG_FILE;
@file_put_contents(
    $logPath,
    json_encode($record, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES) . "\n",
    FILE_APPEND | LOCK_EX
);

// --- Headers ------------------------------------------------------
$fromName  = stripHeaderInjection(MAIL_FROM_NAME);
$fromAddr  = stripHeaderInjection(MAIL_FROM);
$subject   = stripHeaderInjection(MAIL_SUBJECT);

$headers   = [];
$headers[] = "From: {$fromName} <{$fromAddr}>";
// Only set Reply-To if the contact field looks like an email
if (filter_var($contact, FILTER_VALIDATE_EMAIL)) {
    $headers[] = "Reply-To: " . stripHeaderInjection($contact);
}
$headers[] = "Content-Type: text/plain; charset=UTF-8";
$headers[] = "MIME-Version: 1.0";
$headers[] = "X-Mailer: PHP/" . phpversion();

// --- Send ---------------------------------------------------------
$sent = @mail(MAIL_TO, $subject, $body, implode("\r\n", $headers), '-f' . MAIL_FROM);

/* -----------------------------------------------------------------
 * SMTP ALTERNATIVE (use this block if mail() is unreliable)
 * -----------------------------------------------------------------
 * 1. Install PHPMailer:  composer require phpmailer/phpmailer
 * 2. Comment out the $sent = @mail(...) line above.
 * 3. Uncomment and fill in:
 *
 * require __DIR__ . '/vendor/autoload.php';
 * $m = new PHPMailer\PHPMailer\PHPMailer(true);
 * $m->isSMTP();
 * $m->Host       = 'mail.aachips.co';   // from cPanel
 * $m->SMTPAuth   = true;
 * $m->Username   = 'april@aachips.co';
 * $m->Password   = getenv('SMTP_PASS'); // set in a .env or host config, NOT in code
 * $m->SMTPSecure = PHPMailer\PHPMailer\PHPMailer::ENCRYPTION_STARTTLS;
 * $m->Port       = 587;                 // or 465 with ENCRYPTION_SMTPS
 * $m->setFrom(MAIL_FROM, MAIL_FROM_NAME);
 * $m->addAddress(MAIL_TO);
 * if (filter_var($contact, FILTER_VALIDATE_EMAIL)) $m->addReplyTo($contact);
 * $m->Subject = MAIL_SUBJECT;
 * $m->Body    = $body;
 * $sent = $m->send();
 * ----------------------------------------------------------------- */

// --- Respond ------------------------------------------------------
if (!$sent) {
    http_response_code(500);
    exit('Sorry, the message could not be sent. Please email april@aachips.co directly.');
}

if (REDIRECT_AFTER_SUCCESS !== '') {
    header('Location: ' . REDIRECT_AFTER_SUCCESS, true, 303);
    exit;
}

// Minimal inline thank-you page
header('Content-Type: text/html; charset=UTF-8');
?><!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Thanks!</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body{font-family:system-ui,sans-serif;background:#f4f7fb;color:#1e2a3a;
         display:grid;place-items:center;min-height:100vh;margin:0;padding:1rem}
    .card{background:#fff;border-radius:28px;padding:2rem;max-width:480px;
          box-shadow:0 8px 20px rgba(0,0,0,.05);text-align:center}
    h1{color:#2c5f2d;margin:0 0 .5rem}
    a{color:#2c5f2d}
  </style>
</head>
<body>
  <main class="card">
    <h1>🎉 Thank you</h1>
    <p>Your feedback is on its way to April. She'll be in touch soon.</p>
    <p><a href="discovery-form.html">← Back to the form</a></p>
  </main>
</body>
</html>
