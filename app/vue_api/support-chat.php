<?php declare(strict_types=1);
/**
 * Support Chat endpoint for the Vue app.
 *
 * POST /app/vue_api/support-chat.php  { "action": "submit", "category": "bug", "subject": "...", "description": "..." }
 *
 * If the user is authenticated via token, their user_id/name/email are pulled
 * from the session. Otherwise the caller supplies name+email.
 *
 * Returns:
 *   { "success": true, "ticket_id": 42 }
 *   { "success": false, "error": "..." }
 */

require_once __DIR__ . '/token-middleware.php';
require_once __DIR__ . '/../lib/db.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: ' . ($_SERVER['HTTP_ORIGIN'] ?? '*'));
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit;
}

$raw = json_decode(file_get_contents('php://input'), true);
$action = $raw['action'] ?? 'submit';
$pdo = archr_pdo();

if ($action === 'submit') {
    $subject     = trim((string) ($raw['subject'] ?? ''));
    $description = trim((string) ($raw['description'] ?? ''));
    $category    = trim((string) ($raw['category'] ?? 'general'));
    $name        = trim((string) ($raw['name'] ?? ''));
    $email       = trim((string) ($raw['email'] ?? ''));

    // Validate
    if ($description === '') {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Description is required']);
        exit;
    }

    // Validate category
    $validCategories = ['bug', 'feature_request', 'access_issue', 'data_error', 'general'];
    if (!in_array($category, $validCategories, true)) {
        $category = 'general';
    }

    // Try to get user from token (optional — anonymous submissions allowed)
    $userId = null;
    try {
        $user = vue_require_auth_token();
        $userId = (int) $user['user_id'];
        // Pre-fill name/email from system_users
        if ($name === '') {
            $stmt = $pdo->prepare("SELECT full_name, email FROM system_users WHERE id = :id");
            $stmt->execute([':id' => $userId]);
            $u = $stmt->fetch(PDO::FETCH_ASSOC);
            if ($u) {
                $name  = $u['full_name'] ?: $u['email'];
                $email = $u['email'];
            }
        }
    } catch (Throwable $_) {
        // Not authenticated — anonymous is fine if name+email provided
    }

    // Auto-priority: "bug" with "crash" or "broken" in description → high
    $priority = 'normal';
    $descLower = strtolower($description);
    if ($category === 'bug' && (strpos($descLower, 'crash') !== false || strpos($descLower, 'broken') !== false || strpos($descLower, 'cant log') !== false)) {
        $priority = 'high';
    }

    // Ensure table exists (safe to run every request during rollout)
    $pdo->exec("CREATE TABLE IF NOT EXISTS support_tickets (
        id              SERIAL PRIMARY KEY,
        submitted_by    INTEGER REFERENCES system_users(id) ON DELETE SET NULL,
        submitter_name  VARCHAR(128) NOT NULL DEFAULT '',
        submitter_email VARCHAR(256) NOT NULL DEFAULT '',
        category        VARCHAR(32) NOT NULL DEFAULT 'general',
        subject         VARCHAR(256) NOT NULL DEFAULT '',
        description     TEXT NOT NULL,
        screenshot_url  TEXT,
        status          VARCHAR(20) NOT NULL DEFAULT 'open',
        priority        VARCHAR(10) NOT NULL DEFAULT 'normal',
        assigned_to     INTEGER REFERENCES system_users(id) ON DELETE SET NULL,
        resolved_at     TIMESTAMPTZ,
        resolved_by     INTEGER REFERENCES system_users(id) ON DELETE SET NULL,
        resolution_note TEXT,
        created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
    )");

    $ins = $pdo->prepare("
        INSERT INTO support_tickets
            (submitted_by, submitter_name, submitter_email, category, subject, description, priority)
        VALUES (:uid, :name, :email, :category, :subject, :description, :priority)
        RETURNING id
    ");
    $ins->execute([
        ':uid'        => $userId,
        ':name'       => $name,
        ':email'      => $email,
        ':category'   => $category,
        ':subject'    => $subject ?: substr($description, 0, 80),
        ':description' => $description,
        ':priority'   => $priority,
    ]);
    $ticketId = (int) $ins->fetchColumn();

    // Send email alert to all Super Admins
    require_once __DIR__ . '/../lib/email.php';
    $emailer = new ARCHREmailer();
    $emailer->sendSupportTicketAlert(
        $ticketId,
        $category,
        $subject ?: substr($description, 0, 80),
        $description,
        $name,
        $email,
        $priority
    );

    echo json_encode(['success' => true, 'ticket_id' => $ticketId]);
    exit;
}

http_response_code(400);
echo json_encode(['success' => false, 'error' => 'Unknown action: ' . $action]);
