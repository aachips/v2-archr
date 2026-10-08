<?php
declare(strict_types=1);

/**
 * Requestor Account Creation
 * Automatically creates user accounts for requestors on successful submission
 */

/**
 * Create requestor account from intake submission
 * 
 * @param PDO $pdo Database connection
 * @param int $submissionId Intake submission ID
 * @param array $submissionData Submission data
 * @return array ['user_id' => int, 'username' => string, 'password' => string]
 * @throws Exception on failure
 */
function create_requestor_account(PDO $pdo, int $submissionId, array $submissionData): array {
    // Support both camelCase (from form) and snake_case (from database)
    $firstName = $submissionData['applicant_first_name'] ?? $submissionData['applicantFirstName'] ?? '';
    $lastName = $submissionData['applicant_last_name'] ?? $submissionData['applicantLastName'] ?? '';
    $email = $submissionData['contact_email'] ?? $submissionData['contactEmail'] ?? '';

    if (!$email || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        throw new Exception('Valid email address required for account creation');
    }
    
    // Generate username from email (before @)
    $username = strtolower(explode('@', $email)[0]);
    
    // Check if username exists, append number if needed
    $baseUsername = $username;
    $counter = 1;
    while (username_exists($pdo, $username)) {
        $username = $baseUsername . $counter;
        $counter++;
    }
    
    // Generate secure random password
    $password = generate_password();
    $passwordHash = password_hash($password, PASSWORD_DEFAULT);
    
    // Get REQUESTOR role ID
    $roleStmt = $pdo->prepare("SELECT id FROM roles WHERE role_code = 'REQUESTOR' LIMIT 1");
    $roleStmt->execute();
    $roleId = $roleStmt->fetchColumn();
    
    if (!$roleId) {
        throw new Exception('REQUESTOR role not found in database');
    }
    
    try {
        $pdo->beginTransaction();
        
        // Insert user
        $userStmt = $pdo->prepare(
            "INSERT INTO system_users (
                username, password_hash, email, full_name,
                first_name, last_name, is_active, created_at
            ) VALUES (
                :username, :password_hash, :email, :full_name,
                :first_name, :last_name, true, CURRENT_TIMESTAMP
            ) RETURNING id"
        );
        
        $userStmt->execute([
            ':username' => $username,
            ':password_hash' => $passwordHash,
            ':email' => $email,
            ':full_name' => trim("$firstName $lastName"),
            ':first_name' => $firstName,
            ':last_name' => $lastName,
        ]);
        
        $userId = (int)$userStmt->fetchColumn();
        
        // Assign REQUESTOR role
        $roleAssignStmt = $pdo->prepare(
            "INSERT INTO user_role_assignments (user_id, role_id, assigned_at)
             VALUES (:user_id, :role_id, CURRENT_TIMESTAMP)"
        );
        $roleAssignStmt->execute([
            ':user_id' => $userId,
            ':role_id' => $roleId,
        ]);
        
        // Link to submission
        $linkStmt = $pdo->prepare(
            "UPDATE intake_submissions 
             SET requestor_user_id = :user_id
             WHERE id = :submission_id"
        );
        $linkStmt->execute([
            ':user_id' => $userId,
            ':submission_id' => $submissionId,
        ]);
        
        $pdo->commit();
        
        error_log("[AccountCreation] Created requestor account: $username (user_id: $userId)");
        
        return [
            'user_id' => $userId,
            'username' => $username,
            'password' => $password, // Return plaintext for email
        ];
        
    } catch (Throwable $e) {
        $pdo->rollBack();
        error_log('[AccountCreation] Failed to create account: ' . $e->getMessage());
        throw $e;
    }
}

/**
 * Check if username exists
 */
function username_exists(PDO $pdo, string $username): bool {
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM system_users WHERE username = :username");
    $stmt->execute([':username' => $username]);
    return (int)$stmt->fetchColumn() > 0;
}

/**
 * Generate secure random password
 */
function generate_password(int $length = 12): string {
    // Generate password with mix of characters
    $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*';
    $password = '';
    $charsLength = strlen($chars);
    
    for ($i = 0; $i < $length; $i++) {
        $password .= $chars[random_int(0, $charsLength - 1)];
    }
    
    // Ensure at least one of each type
    if (!preg_match('/[a-z]/', $password)) {
        $password[random_int(0, $length - 1)] = 'a';
    }
    if (!preg_match('/[A-Z]/', $password)) {
        $password[random_int(0, $length - 1)] = 'A';
    }
    if (!preg_match('/[0-9]/', $password)) {
        $password[random_int(0, $length - 1)] = '1';
    }
    
    return $password;
}
