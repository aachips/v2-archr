<?php
declare(strict_types=1);

/**
 * Volunteer application approval endpoint.
 * Called when an admin approves a volunteer intake submission.
 *
 * POST body: { application_id, notes }
 *
 * Creates: system_users record, user_role_assignments (role_id=11 VOLUNTEER),
 * volunteer_profiles record, and sends confirmation email.
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
if (!is_array($body) || empty($body['application_id'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'application_id required']);
    exit;
}

$applicationId = (int)$body['application_id'];
$notes = trim((string)($body['notes'] ?? ''));

try {
    $pdo = archr_pdo();

    // Fetch the volunteer application
    $stmt = $pdo->prepare("SELECT * FROM volunteer_applications WHERE id = :id");
    $stmt->execute([':id' => $applicationId]);
    $app = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$app) {
        http_response_code(404);
        echo json_encode(['success' => false, 'error' => 'Application not found']);
        exit;
    }

    if ($app['status'] !== 'pending') {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Application already processed (status: ' . $app['status'] . ')']);
        exit;
    }

    $reviewedBy = (int)($body['reviewed_by'] ?? 0);
    if ($reviewedBy <= 0) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'reviewed_by (user id) required']);
        exit;
    }

    $pdo->beginTransaction();
    try {
        // 1. Create system_users record (if not already exists for this email)
        $stmt = $pdo->prepare("SELECT id FROM system_users WHERE email = :email LIMIT 1");
        $stmt->execute([':email' => $app['email']]);
        $userId = (int)($stmt->fetchColumn() ?: 0);

        if ($userId === 0) {
            // Generate a temporary password
            $tempPassword = bin2hex(random_bytes(8));
            $username = 'vol-' . strtolower(preg_replace('/[^a-zA-Z0-9]/', '', $app['full_name']));

            $stmt = $pdo->prepare(
                "INSERT INTO system_users (full_name, email, password_hash, is_active, created_at)
                 VALUES (:name, :email, crypt(:pw, gen_salt('bf')), true, CURRENT_TIMESTAMP)
                 RETURNING id"
            );
            $stmt->execute([':name' => $app['full_name'], ':email' => $app['email'], ':pw' => $tempPassword]);
            $userId = (int)$stmt->fetchColumn();

            error_log("[volunteer-approve] Created user id=$userId for {$app['full_name']} <{$app['email']}>");
        }

        // 2. Assign VOLUNTEER role (role_id = 11)
        $stmt = $pdo->prepare(
            "INSERT INTO user_role_assignments (user_id, role_id, is_active, assigned_at)
             VALUES (:uid, 11, true, CURRENT_TIMESTAMP)
             ON CONFLICT (user_id, role_id) DO UPDATE SET is_active = true, assigned_at = CURRENT_TIMESTAMP"
        );
        $stmt->execute([':uid' => $userId]);

        // 3. Create volunteer_profiles record
        $stmt = $pdo->prepare(
            "INSERT INTO volunteer_profiles (user_id, level, xp, xp_to_next_level, reputation_score, total_quests_completed, total_hours_logged, created_at)
             VALUES (:uid, 1, 0, 100, 0, 0, 0, CURRENT_TIMESTAMP)
             ON CONFLICT (user_id) DO NOTHING"
        );
        $stmt->execute([':uid' => $userId]);

        // 4. Update volunteer_applications status
        $stmt = $pdo->prepare(
            "UPDATE volunteer_applications
             SET status = 'approved', reviewed_by = :by, reviewed_notes = :notes,
                 reviewed_at = CURRENT_TIMESTAMP, user_id = :uid
             WHERE id = :id"
        );
        $stmt->execute([':by' => $reviewedBy, ':notes' => $notes ?: 'Approved via admin dashboard.', ':uid' => $userId, ':id' => $applicationId]);

        $pdo->commit();

        // 5. Send confirmation email to volunteer (outside transaction)
        try {
            $emailer = new ARCHREmailer();
            $emailer->sendVolunteerConfirmation([
                'full_name' => $app['full_name'],
                'email' => $app['email'],
            ]);
            error_log("[volunteer-approve] Confirmation email sent to {$app['email']}");
        } catch (Throwable $e) {
            error_log("[volunteer-approve] Email failed (non-fatal): " . $e->getMessage());
        }

        echo json_encode([
            'success' => true,
            'user_id' => $userId,
            'message' => 'Volunteer account created for ' . $app['full_name'],
        ]);

    } catch (Throwable $e) {
        $pdo->rollBack();
        throw $e;
    }

} catch (Throwable $e) {
    error_log('[volunteer-approve] Error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
