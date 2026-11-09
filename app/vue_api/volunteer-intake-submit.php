<?php
declare(strict_types=1);

/**
 * Volunteer intake submission endpoint.
 * Receives the volunteer application form data and stores it in
 * volunteer_applications table. Sends confirmation email to applicant
 * and admin alert.
 *
 * POST body: JSON with form fields (see VolunteerIntakeForm.vue)
 */

require __DIR__ . '/../lib/db.php';
require __DIR__ . '/../lib/email.php';

header('Content-Type: application/json; charset=UTF-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit;
}

$raw = file_get_contents('php://input') ?: '';
$body = json_decode($raw, true);
if (!is_array($body)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Invalid JSON body']);
    exit;
}

// Validate required fields
$email = trim((string)($body['email'] ?? ''));
$fullName = trim((string)($body['fullName'] ?? ''));
$phone = trim((string)($body['phone'] ?? ''));

if ($email === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'A valid email address is required.']);
    exit;
}
if ($fullName === '') {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Full name is required.']);
    exit;
}
if ($phone === '') {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Phone number is required.']);
    exit;
}

try {
    $pdo = archr_pdo();

    // Check for duplicate (same email, pending status, within 7 days)
    $dupStmt = $pdo->prepare(
        "SELECT id FROM volunteer_applications
         WHERE email = :email AND status = 'pending'
           AND created_at > CURRENT_TIMESTAMP - INTERVAL '7 days'
         LIMIT 1"
    );
    $dupStmt->execute([':email' => $email]);
    if ($dupStmt->fetchColumn()) {
        http_response_code(409);
        echo json_encode(['success' => false, 'error' => 'A volunteer application with this email was already submitted recently. Please wait for review.']);
        exit;
    }

    // Insert into volunteer_applications
    $stmt = $pdo->prepare("
        INSERT INTO volunteer_applications (
            full_name, email, phone, location, motivation, hear_about,
            skills, availability, has_tools, tools_notes, interest_type,
            physical_limits, referral_name, agreed_terms, status
        ) VALUES (
            :name, :email, :phone, :location, :motivation, :hear,
            :skills, :avail, :tools, :tools_notes, :interest,
            :limits, :referral, :agreed, 'pending'
        ) RETURNING id
    ");

    $stmt->execute([
        ':name'         => $fullName,
        ':email'        => $email,
        ':phone'        => $phone,
        ':location'     => trim((string)($body['location'] ?? '')) ?: null,
        ':motivation'   => trim((string)($body['motivation'] ?? '')) ?: null,
        ':hear'         => trim((string)($body['hearAbout'] ?? '')) ?: null,
        ':skills'       => !empty($body['skills']) ? '{' . implode(',', array_map(fn($s) => '"' . str_replace('"', '\\"', $s) . '"', $body['skills'])) . '}' : null,
        ':avail'        => !empty($body['availability']) ? '{' . implode(',', array_map(fn($a) => '"' . str_replace('"', '\\"', $a) . '"', $body['availability'])) . '}' : null,
        ':tools'        => !empty($body['tools']),
        ':tools_notes'  => trim((string)($body['tools'] ?? '')) ?: null,
        ':interest'     => trim((string)($body['interest'] ?? '')) ?: null,
        ':limits'       => trim((string)($body['limits'] ?? '')) ?: null,
        ':referral'     => trim((string)($body['referral'] ?? '')) ?: null,
        ':agreed'       => !empty($body['agree']) ? 't' : 'f',
    ]);

    $applicationId = (int)$stmt->fetchColumn();

    // Send emails (non-fatal)
    try {
        $emailer = new ARCHREmailer();
        $emailer->sendVolunteerConfirmation([
            'full_name' => $fullName,
            'email' => $email,
        ]);
    } catch (Throwable $e) {
        error_log('[volunteer-intake] Confirmation email failed (non-fatal): ' . $e->getMessage());
    }

    try {
        $emailer = new ARCHREmailer();
        $emailer->sendVolunteerAdminAlert([
            'full_name' => $fullName,
            'email' => $email,
            'phone' => $phone,
            'location' => $body['location'] ?? null,
            'motivation' => $body['motivation'] ?? null,
            'skills' => $body['skills'] ?? [],
            'availability' => $body['availability'] ?? [],
            'interest_type' => $body['interest'] ?? null,
            'tools_notes' => $body['tools'] ?? null,
            'referral_name' => $body['referral'] ?? null,
        ]);
    } catch (Throwable $e) {
        error_log('[volunteer-intake] Admin alert email failed (non-fatal): ' . $e->getMessage());
    }

    error_log("[volunteer-intake] Application #$applicationId submitted by $fullName <$email>");

    echo json_encode([
        'success' => true,
        'application_id' => $applicationId,
        'message' => 'Application submitted successfully.',
    ]);

} catch (Throwable $e) {
    error_log('[volunteer-intake] Submission failed: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Submission failed. Please try again.']);
}
