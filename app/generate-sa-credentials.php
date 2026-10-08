<?php declare(strict_types=1);
/**
 * Generate a fresh Super-Admin credential set and write it to a local file.
 *
 * Run with: php app/generate-sa-credentials.php
 *
 * The password is generated inside the script and is never printed to the
 * terminal or logged. It is written to app/sa-credentials.txt so you can
 * read it from the workspace.
 */

require __DIR__ . '/lib/db.php';

$pdo = archr_pdo();
$username = 'superadmin';
$password = bin2hex(random_bytes(12)); // 24-character hex password

$superAdminRoleId = (int) $pdo->query("SELECT id FROM roles WHERE role_code = 'SUPER_ADMIN' LIMIT 1")->fetchColumn();
if (!$superAdminRoleId) {
    fwrite(STDERR, "SUPER_ADMIN role not found. Apply sql/add/super-admin-role.sql first.\n");
    exit(1);
}

$orgId = (int) $pdo->query("SELECT id FROM coalition_organizations ORDER BY id LIMIT 1")->fetchColumn();
if (!$orgId) {
    fwrite(STDERR, "No organization exists. Create one via the setup page or Super-Admin portal first.\n");
    exit(1);
}

$pdo->beginTransaction();

$existing = $pdo->prepare("SELECT id FROM system_users WHERE username = :username LIMIT 1");
$existing->execute([':username' => $username]);
$userId = (int) $existing->fetchColumn();

if ($userId) {
    $upd = $pdo->prepare("UPDATE system_users SET password_hash = :hash, is_active = true, updated_at = CURRENT_TIMESTAMP WHERE id = :id");
    $upd->execute([':hash' => password_hash($password, PASSWORD_DEFAULT), ':id' => $userId]);
} else {
    $ins = $pdo->prepare("
        INSERT INTO system_users (username, email, full_name, first_name, last_name, password_hash, is_active)
        VALUES (:username, :email, 'Super Administrator', 'Super', 'Administrator', :hash, true)
        RETURNING id
    ");
    $ins->execute([':username' => $username, ':email' => 'superadmin@archr.local', ':hash' => password_hash($password, PASSWORD_DEFAULT)]);
    $userId = (int) $ins->fetchColumn();
}

$hasRole = $pdo->prepare("
    SELECT 1 FROM user_role_assignments
     WHERE user_id = :uid AND role_id = :rid AND organization_id = :org
     LIMIT 1
");
$hasRole->execute([':uid' => $userId, ':rid' => $superAdminRoleId, ':org' => $orgId]);
if (!$hasRole->fetch()) {
    $assign = $pdo->prepare("
        INSERT INTO user_role_assignments (user_id, role_id, organization_id, assigned_by)
        VALUES (:uid, :rid, :org, :uid)
    ");
    $assign->execute([':uid' => $userId, ':rid' => $superAdminRoleId, ':org' => $orgId]);
}

$pdo->commit();

$credFile = __DIR__ . '/sa-credentials.txt';
$credContent = sprintf(
    "ARCHR Super-Admin Credentials\nGenerated: %s\nUsername: %s\nPassword: %s\n\nLog in at: app/login.php\n",
    date('Y-m-d H:i:s'),
    $username,
    $password
);
file_put_contents($credFile, $credContent);

// Try to restrict read access on Windows (best-effort)
if (function_exists('chmod')) {
    @chmod($credFile, 0600);
}

echo "Super-Admin credentials generated and saved to app/sa-credentials.txt\n";
echo "Username: $username\n";
echo "Password is in the file above. Delete the file after you have recorded it.\n";
