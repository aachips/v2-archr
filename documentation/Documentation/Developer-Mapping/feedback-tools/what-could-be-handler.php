<?php
declare(strict_types=1);

/* -----------------------------------------------------------------
 * "What could be" feedback meeting form handler
 * Receives POST from what-could-be.html, logs it, and emails a copy.
 * ----------------------------------------------------------------- */

// --- Config -------------------------------------------------------
const MAIL_TO       = 'april@aachips.co';
const MAIL_SUBJECT  = 'ARCHR feedback meeting — new response';
// Use an address on YOUR domain as the From, so SPF/DKIM pass.
const MAIL_FROM     = 'no-reply@aachips.co';
const MAIL_FROM_NAME = 'ARCHR What-Could-Be Form';
const REDIRECT_AFTER_SUCCESS = ''; // e.g. 'thanks.html' or '' to show inline page
const LOG_DIR  = __DIR__ . '/logs';
const LOG_FILE = 'what-could-be-submissions.jsonl';

// --- Guard: only accept POST -------------------------------------
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    header('Allow: POST');
    exit('Method Not Allowed');
}

// --- Honeypot: silently accept then drop bot submissions ---------
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
    return $v;
}

function fieldArray(string $key, int $maxItems = 20): array {
    $v = $_POST[$key] ?? [];
    if (!is_array($v)) return [];
    $out = [];
    foreach ($v as $item) {
        if (!is_string($item)) continue;
        $item = trim($item);
        if ($item !== '') $out[] = substr($item, 0, 200);
        if (count($out) >= $maxItems) break;
    }
    return $out;
}

function stripHeaderInjection(string $v): string {
    return preg_replace('/[\r\n]+/', ' ', $v) ?? '';
}

// --- Collect & validate ------------------------------------------
$name       = field('name', 200);
$contact    = field('contact', 200);
$role       = field('role', 200);
$attendance = field('attendance', 50);
$topics     = fieldArray('topics');
$pain       = field('painPriority', 200);
$painOther  = field('painOther', 500);
$questions  = field('questions');
$mustDo     = field('mustDo');
$anything   = field('anythingElse');

if ($name === '' || $contact === '') {
    http_response_code(400);
    exit('Please go back and provide at least a name and a way to contact you.');
}

$attendanceLabels = [
    'yes-in-person' => 'Yes — in person',
    'yes-remote'    => 'Yes — remotely',
    'no-recap'      => "Can't make it — wants the recap",
];
$attendanceLabel = $attendanceLabels[$attendance] ?? ($attendance !== '' ? $attendance : '(no answer)');

// --- Build the email body (plain text, easy to read on phone) ---
$lines = [];
$lines[] = "New feedback-meeting response";
$lines[] = str_repeat('=', 40);
$lines[] = "Name:       {$name}";
$lines[] = "Contact:    {$contact}";
if ($role !== '') $lines[] = "Role:       {$role}";
$lines[] = "Attendance: {$attendanceLabel}";
$lines[] = "";
$lines[] = "Wants to see / discuss:";
$lines[] = $topics !== [] ? '  - ' . implode("\r\n  - ", $topics) : '  (nothing selected)';
$lines[] = "";
$lines[] = "Pain point to fix first: " . ($pain !== '' ? $pain : '(no answer)');
if ($pain === 'other' && $painOther !== '') $lines[] = "  Other: {$painOther}";
$lines[] = "";
$lines[] = "Questions for the meeting:";
$lines[] = $questions !== '' ? $questions : '(none)';
$lines[] = "";
$lines[] = "ONE thing the system must do:";
$lines[] = $mustDo !== '' ? $mustDo : '(none)';
$lines[] = "";
if ($anything !== '') {
    $lines[] = "Anything else:";
    $lines[] = $anything;
    $lines[] = "";
}
$lines[] = str_repeat('=', 40);
$lines[] = "Submitted: " . date('Y-m-d H:i:s T');
$lines[] = "IP:        " . ($_SERVER['REMOTE_ADDR'] ?? 'unknown');
$lines[] = "UA:        " . ($_SERVER['HTTP_USER_AGENT'] ?? 'unknown');

$body = implode("\r\n", $lines);

// --- Log to JSON Lines file BEFORE sending mail ------------------
$record = [
    'submitted_at' => date(DATE_ATOM),
    'name'         => $name,
    'contact'      => $contact,
    'role'         => $role,
    'attendance'   => $attendance,
    'topics'       => $topics,
    'painPriority' => $pain,
    'painOther'    => $painOther,
    'questions'    => $questions,
    'mustDo'       => $mustDo,
    'anythingElse' => $anything,
    'ip'           => $_SERVER['REMOTE_ADDR']     ?? null,
    'user_agent'   => $_SERVER['HTTP_USER_AGENT'] ?? null,
];

if (!is_dir(LOG_DIR)) {
    @mkdir(LOG_DIR, 0750, true);
}
@file_put_contents(
    LOG_DIR . '/' . LOG_FILE,
    json_encode($record, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES) . "\n",
    FILE_APPEND | LOCK_EX
);

// --- Headers ------------------------------------------------------
$fromName = stripHeaderInjection(MAIL_FROM_NAME);
$fromAddr = stripHeaderInjection(MAIL_FROM);
$subject  = stripHeaderInjection(MAIL_SUBJECT);

$headers   = [];
$headers[] = "From: {$fromName} <{$fromAddr}>";
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
    <p>Your input is shaping the meeting agenda. See you there — or watch for the recap.</p>
    <p><a href="what-could-be.html">← Back to the form</a></p>
  </main>
</body>
</html>
