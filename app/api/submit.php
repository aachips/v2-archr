<?php
declare(strict_types=1);

/* -----------------------------------------------------------------
 * Intake submission endpoint
 * Receives the JSON payload from /app/intake.php (built by
 * assets/intake.js) and writes it via archr_save_intake_submission().
 *
 * Complete submission workflow:
 * 1. Dual-write to PostgreSQL and Airtable
 * 2. Create requestor account with credentials
 * 3. Send confirmation email to requestor
 * 4. Send alert emails to admin/office staff
 * 5. Log to review queue
 * 6. Run eligibility checker
 *
 * Returns { success, submission_id, anchor_id, case_number,
 *           dashboard_url, credentials }.
 * ----------------------------------------------------------------- */

require __DIR__ . '/../lib/db.php';
require __DIR__ . '/../lib/intake-save.php';
require __DIR__ . '/../lib/intake-duplicate.php';
require __DIR__ . '/../lib/dual-write.php';
require __DIR__ . '/../lib/account-creation.php';
require __DIR__ . '/../lib/email.php';
require __DIR__ . '/../lib/eligibility.php';

header('Content-Type: application/json; charset=UTF-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    header('Allow: POST');
    echo json_encode(['success' => false, 'error' => 'Method Not Allowed']);
    exit;
}

$raw = file_get_contents('php://input') ?: '';
$payload = json_decode($raw, true);
if (!is_array($payload)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Invalid JSON body']);
    exit;
}

// Honeypot: silently accept-then-drop bot submissions.
if (!empty($payload['website'] ?? '')) {
    echo json_encode(['success' => true, 'submission_id' => 0, 'bot' => true]);
    exit;
}
unset($payload['website']);

// Log submission before touching the DB so we always keep a paper trail
$logDir = __DIR__ . '/../logs';
if (!is_dir($logDir)) {
    @mkdir($logDir, 0750, true);
}

// Remove signature data URLs before logging (they're huge and unreadable)
$loggablePayload = $payload;
unset($loggablePayload['applicantSignature'], $loggablePayload['zeroIncomeSignature']);

// Human-readable log
@file_put_contents(
    $logDir . '/intake-submissions.log',
    sprintf(
        "[%s] NEW SUBMISSION | %s %s | Email: %s | Phone: %s | City: %s | Referral: %s\n",
        date('Y-m-d H:i:s'),
        $payload['applicantFirstName'] ?? '',
        $payload['applicantLastName'] ?? '',
        $payload['contactEmail'] ?? 'N/A',
        $payload['homePhone'] ?? $payload['cellPhone'] ?? 'N/A',
        $payload['homeCity'] ?? 'N/A',
        ($payload['isReferral'] === 'yes') ? 'YES' : 'NO'
    ),
    FILE_APPEND | LOCK_EX
);

// Detailed JSON log (one per line, prettified for readability, no signatures)
@file_put_contents(
    $logDir . '/intake-submissions.jsonl',
    json_encode([
        'received_at' => date(DATE_ATOM),
        'ip'          => $_SERVER['REMOTE_ADDR']     ?? null,
        'applicant'   => [
            'name' => trim(($payload['applicantFirstName'] ?? '') . ' ' . ($payload['applicantLastName'] ?? '')),
            'email' => $payload['contactEmail'] ?? null,
            'phone' => $payload['homePhone'] ?? $payload['cellPhone'] ?? null,
        ],
        'address'     => [
            'street' => $payload['homeAddress'] ?? null,
            'city' => $payload['homeCity'] ?? null,
            'zip' => $payload['homeZip'] ?? null,
        ],
        'is_referral' => $payload['isReferral'] ?? null,
        'helene_related' => $payload['heleneRelated'] ?? null,
        'has_signature' => !empty($payload['applicantSignature']),
        'urgent_conditions' => $payload['urgentConditions'] ?? [],
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT) . "\n",
    FILE_APPEND | LOCK_EX
);

// Initialize services
$dualWriter = null;
$emailer = null;
$credentials = null;
$credentialsError = '';

try {
    // The intake write path is always PostgreSQL-primary (the dual writer
    // fans out to Airtable), independent of which driver the app READS
    // from, so use the dual writer's connection rather than archr_pdo().
    $dualWriter = new DualDatabaseWriter();
    $pdo = $dualWriter->getPdo();
    if (!$pdo) {
        throw new RuntimeException('PostgreSQL connection unavailable');
    }
    $emailer = new ARCHREmailer();
} catch (Throwable $e) {
    error_log('[app/submit] Service initialization failed: ' . $e->getMessage());
    http_response_code(503);
    echo json_encode(['success' => false, 'error' => 'Service unavailable']);
    exit;
}

// Validate email early — a requestor account cannot be created without it.
$email = trim((string)($payload['contactEmail'] ?? ''));
if ($email === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'A valid email address is required to submit and create your requestor account.']);
    exit;
}

// Prevent duplicate submissions within the last 24 hours for the same email, address, or phone.
$duplicate = archr_intake_find_duplicate(
    $pdo,
    $email,
    trim((string)($payload['homeAddress'] ?? '')),
    trim((string)($payload['homePhone'] ?? '')),
    trim((string)($payload['cellPhone'] ?? ''))
);
if ($duplicate) {
    $matchLabel = archr_intake_duplicate_match_label(
        $duplicate,
        $email,
        trim((string)($payload['homeAddress'] ?? '')),
        trim((string)($payload['homePhone'] ?? '')),
        trim((string)($payload['cellPhone'] ?? ''))
    );
    http_response_code(409);
    echo json_encode([
        'success' => false,
        'error' => 'A submission for this ' . $matchLabel . ' was already received within the last 24 hours (submission #' . (int)$duplicate['id'] . '). Please call ' . archr_intake_call_in_number() . ' if you need to update your application.',
    ]);
    exit;
}

try {
    // Step 1: Dual-write to PostgreSQL and Airtable
    $writeResult = $dualWriter->dualWrite($payload, function($pdo, $data) {
        return archr_save_intake_submission(
            $pdo,
            $data,
            $_SERVER['REMOTE_ADDR'] ?? null,
            $_SERVER['HTTP_USER_AGENT'] ?? null
        );
    });

    if (!$writeResult['postgres_success']) {
        throw new Exception('Primary database write failed');
    }

    $submissionId = $writeResult['submission_id'];
    $anchorId = $writeResult['anchor_id'] ?? null;
    $caseNumber = $writeResult['case_number'] ?? null;

    // Prepare submission data for subsequent steps
    $submissionData = array_merge($payload, [
        'submission_id' => $submissionId,
        'case_number' => $caseNumber,
        'submitted_at' => date('Y-m-d H:i:s'),
        'urgent_condition_count' => count($payload['urgentConditions'] ?? []),
    ]);

    // Step 2: Create requestor account
    try {
        $credentials = create_requestor_account($pdo, $submissionId, $submissionData);
        error_log('[app/submit] Requestor account created: ' . $credentials['username'] . ' / ' . $credentials['password']);

        // Log to readable file for testing
        @file_put_contents(
            $logDir . '/account-credentials.log',
            sprintf(
                "[%s] ACCOUNT CREATED | Submission: %d | Username: %s | Password: %s | Email: %s\n",
                date('Y-m-d H:i:s'),
                $submissionId,
                $credentials['username'],
                $credentials['password'],
                $submissionData['contact_email'] ?? $submissionData['contactEmail'] ?? ''
            ),
            FILE_APPEND | LOCK_EX
        );
    } catch (Throwable $e) {
        // Account creation failure is non-fatal
        $credentialsError = $e->getMessage();
        error_log('[app/submit] Account creation failed (non-fatal): ' . $credentialsError);
        @file_put_contents(
            $logDir . '/account-credentials.log',
            sprintf(
                "[%s] ❌ ACCOUNT CREATION FAILED | Submission: %d | Error: %s\n",
                date('Y-m-d H:i:s'),
                $submissionId,
                $credentialsError
            ),
            FILE_APPEND | LOCK_EX
        );
        $credentials = null;
    }

    // Step 3: Send confirmation email to requestor
    $email = $submissionData['contact_email'] ?? $submissionData['contactEmail'] ?? '';
    if ($credentials && !empty($email)) {
        try {
            $emailer->sendRequestorConfirmation($submissionData, $credentials);
            error_log('[app/submit] Confirmation email sent to requestor');
        } catch (Throwable $e) {
            error_log('[app/submit] Confirmation email failed (non-fatal): ' . $e->getMessage());
        }
    }

    // Step 4: Send alert emails to admin/office staff
    try {
        $emailer->sendAdminAlert($submissionData);
        error_log('[app/submit] Admin alert emails sent');
    } catch (Throwable $e) {
        error_log('[app/submit] Admin alert emails failed (non-fatal): ' . $e->getMessage());
    }

    // Step 5: Run eligibility checker (flags, not decisions — the system
    // never auto-denies; red flags route the application to human review)
    try {
        $eligibilityResult = check_eligibility($pdo, $submissionId);
        $flagCounts = array_map('count', $eligibilityResult['flags'] ?? []);
        error_log('[app/submit] Eligibility flags: ' .
                  'green=' . ($flagCounts['green'] ?? 0) .
                  ' yellow=' . ($flagCounts['yellow'] ?? 0) .
                  ' red=' . ($flagCounts['red'] ?? 0) .
                  ' | action: ' . ($eligibilityResult['recommended_action'] ?? 'n/a') .
                  ' (priority score: ' . ($eligibilityResult['priority_score'] ?? 0) . ')');
    } catch (Throwable $e) {
        error_log('[app/submit] Eligibility check failed (non-fatal): ' . $e->getMessage());
    }

    // Step 6: Queue logging (already done in intake-save.php)

    // Log warnings if any secondary operations failed
    $warnings = [];
    if (!$writeResult['airtable_success']) {
        $warnings[] = 'Airtable write failed (queued for retry)';
    }
    if (!$credentials) {
        $warnings[] = 'Account creation failed';
    }

    if (!empty($warnings)) {
        error_log('[app/submit] Submission completed with warnings: ' . implode(', ', $warnings));
    }

    // Log successful submission to readable log
    @file_put_contents(
        $logDir . '/intake-submissions.log',
        sprintf(
            "[%s] ✅ SUBMISSION SUCCESS | ID: %d | Case: %s | %s %s\n",
            date('Y-m-d H:i:s'),
            $submissionId,
            $caseNumber ?? 'N/A',
            $submissionData['applicant_first_name'] ?? '',
            $submissionData['applicant_last_name'] ?? ''
        ),
        FILE_APPEND | LOCK_EX
    );

} catch (Throwable $e) {
    error_log('[app/submit] Submission failed: ' . $e->getMessage());
    error_log('[app/submit] Stack trace: ' . $e->getTraceAsString());

    // Attempt rollback
    if ($dualWriter) {
        $dualWriter->rollback();
    }

    http_response_code(500);

    // In development, show actual error for debugging
    $errorMsg = 'Submission processing failed';
    if (getenv('APP_ENV') === 'development' || getenv('APP_DEBUG') === 'true') {
        $errorMsg .= ': ' . $e->getMessage();
    }

    echo json_encode(['success' => false, 'error' => $errorMsg, 'debug' => [
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ]]);
    exit;
}

// Success response
$placecode = $writeResult['placecode'] ?? null;
$projectCode = $writeResult['project_code'] ?? null;
$displayRef  = $placecode ?? $caseNumber ?? $anchorId ?? ('#' . $submissionId);

$response = [
    'success'           => true,
    'submission_id'     => $submissionId,
    'anchor_id'         => $anchorId,
    'case_number'       => $caseNumber,
    'placecode'         => $placecode,
    'project_code'      => $projectCode,
    'application_id'    => $writeResult['application_id'] ?? null,
    'display_ref'       => $displayRef,
    'dashboard_url'     => 'requestor-portal.php',  // Relative to app/ directory
    'credentials'       => $credentials ? [
        'username' => $credentials['username'],
        'password' => $credentials['password'],
    ] : null,
    'credentials_error' => $credentialsError ?: null,
];

// Log response for debugging
error_log('[app/submit] Response: ' . json_encode($response));

echo json_encode($response);
