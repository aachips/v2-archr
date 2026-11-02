<?php
declare(strict_types=1);

/* -----------------------------------------------------------------
 * Context Capture form handler
 * Receives POST from context-capture.html, logs it, and emails a copy.
 * ----------------------------------------------------------------- */

// --- Config -------------------------------------------------------
const MAIL_TO       = 'april@aachips.co';
const MAIL_SUBJECT  = 'ARCHR context capture — new story';
// Use an address on YOUR domain as the From, so SPF/DKIM pass.
const MAIL_FROM     = 'no-reply@aachips.co';
const MAIL_FROM_NAME = 'ARCHR Context Capture';
const REDIRECT_AFTER_SUCCESS = ''; // e.g. 'thanks.html' or '' to show inline page
const LOG_DIR  = __DIR__ . '/logs';
const LOG_FILE = 'context-capture-submissions.jsonl';

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

function stripHeaderInjection(string $v): string {
    return preg_replace('/[\r\n]+/', ' ', $v) ?? '';
}

// --- Collect & validate ------------------------------------------
$pain      = field('pain_point', 100);
$painOther = field('other_pain_point', 500);
$story     = field('story');
$impact    = field('impact');
$ideal     = field('ideal');
$context   = field('context');
$name      = field('name', 200);
$email     = field('email', 200);

if ($story === '') {
    http_response_code(400);
    exit('Please go back and tell the story (Step 2) before submitting.');
}

if ($name === '') $name = 'anonymous';

$painLabels = [
    'duplicate_entry'    => 'Duplicate data entry',
    'clutter'            => 'Cluttered / hard to find things',
    'funding_visibility' => 'No funding visibility',
    'no_training'        => 'No guidance / training',
    'fear_of_breaking'   => 'Fear of breaking things',
    'communication_gap'  => 'Communication gaps',
    'reporting'          => 'Reporting is difficult',
    'manual_work'        => 'Too much manual work',
    'other'              => 'Other',
];
$painLabel = $painLabels[$pain] ?? ($pain !== '' ? $pain : '(not specified)');

// --- Build the email body (plain text, easy to read on phone) ---
$lines = [];
$lines[] = "New context capture story";
$lines[] = str_repeat('=', 40);
$lines[] = "Pain point: {$painLabel}";
if ($pain === 'other' && $painOther !== '') $lines[] = "Other:      {$painOther}";
$lines[] = "";
$lines[] = "THE STORY";
$lines[] = str_repeat('-', 40);
$lines[] = $story;
$lines[] = "";
$lines[] = "THE IMPACT";
$lines[] = str_repeat('-', 40);
$lines[] = $impact !== '' ? $impact : '(no answer)';
$lines[] = "";
$lines[] = "THE IDEAL OUTCOME";
$lines[] = str_repeat('-', 40);
$lines[] = $ideal !== '' ? $ideal : '(no answer)';
$lines[] = "";
if ($context !== '') {
    $lines[] = "ADDITIONAL CONTEXT";
    $lines[] = str_repeat('-', 40);
    $lines[] = $context;
    $lines[] = "";
}
$lines[] = str_repeat('=', 40);
$lines[] = "From:      {$name}" . ($email !== '' ? " <{$email}>" : ' (no email given)');
$lines[] = "Submitted: " . date('Y-m-d H:i:s T');
$lines[] = "IP:        " . ($_SERVER['REMOTE_ADDR'] ?? 'unknown');
$lines[] = "UA:        " . ($_SERVER['HTTP_USER_AGENT'] ?? 'unknown');

$body = implode("\r\n", $lines);

// --- Log to JSON Lines file BEFORE sending mail ------------------
$record = [
    'submitted_at'     => date(DATE_ATOM),
    'pain_point'       => $pain !== '' ? $pain : 'not_specified',
    'other_pain_point' => $painOther,
    'story'            => $story,
    'impact'           => $impact,
    'ideal'            => $ideal,
    'context'          => $context,
    'name'             => $name,
    'email'            => $email,
    'ip'               => $_SERVER['REMOTE_ADDR']     ?? null,
    'user_agent'       => $_SERVER['HTTP_USER_AGENT'] ?? null,
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
if (filter_var($email, FILTER_VALIDATE_EMAIL)) {
    $headers[] = "Reply-To: " . stripHeaderInjection($email);
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
 * if (filter_var($email, FILTER_VALIDATE_EMAIL)) $m->addReplyTo($email);
 * $m->Subject = MAIL_SUBJECT;
 * $m->Body    = $body;
 * $sent = $m->send();
 * ----------------------------------------------------------------- */

// --- Respond ------------------------------------------------------
if (!$sent) {
    http_response_code(500);
    exit('Sorry, the story could not be sent. Please email april@aachips.co directly.');
}

if (REDIRECT_AFTER_SUCCESS !== '') {
    header('Location: ' . REDIRECT_AFTER_SUCCESS, true, 303);
    exit;
}

// Minimal inline thank-you page (matches the form's palette)
header('Content-Type: text/html; charset=UTF-8');
?><!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Story captured — thank you</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;
         background:#f5f7fb;color:#1e293b;display:grid;place-items:center;
         min-height:100vh;margin:0;padding:1rem}
    .card{background:#fff;border-radius:0.5rem;padding:2rem;max-width:480px;
          box-shadow:0 8px 20px rgba(0,0,0,.05);text-align:center;
          border-left:4px solid #1d8a3a}
    h1{color:#0f2b3d;margin:0 0 .5rem;font-size:1.5rem}
    a{color:#2A5C82}
  </style>
</head>
<body>
  <main class="card">
    <h1>✅ Story captured</h1>
    <p>Thank you — your story will be reviewed before the coalition feedback meeting. It helps us understand the real moments behind the pain points.</p>
    <p><a href="context-capture.html">← Capture another moment</a></p>
  </main>
</body>
</html>
