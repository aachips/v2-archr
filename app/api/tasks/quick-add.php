<?php
declare(strict_types=1);

/* Quick task submission endpoint - adds items to task rabbit queue. */

require __DIR__ . '/../../lib/auth.php';
require __DIR__ . '/../../lib/db.php';

archr_require_auth();
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

$pdo = archr_pdo();
$userId = $_SESSION['archr_user_id'] ?? 0;

$taskType = trim($_POST['task_type'] ?? '');
$taskText = trim($_POST['task_text'] ?? '');

if (!in_array($taskType, ['task', 'event', 'log', 'note'], true)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Invalid task type']);
    exit;
}

if ($taskText === '') {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Task description is required']);
    exit;
}

try {
    $stmt = $pdo->prepare("
        INSERT INTO task_rabbit_queue (
            task_type, description, created_by_user_id, status, priority,
            created_at
        ) VALUES (
            :task_type, :description, :user_id, 'pending', 'normal',
            NOW()
        )
    ");

    $stmt->execute([
        ':task_type' => $taskType,
        ':description' => $taskText,
        ':user_id' => $userId,
    ]);

    $taskId = (int)$pdo->lastInsertId();

    echo json_encode([
        'success' => true,
        'message' => 'Task added to queue successfully',
        'data' => [
            'id' => $taskId,
            'type' => $taskType,
        ],
    ], JSON_PRETTY_PRINT);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage(),
    ], JSON_PRETTY_PRINT);
}
