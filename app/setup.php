<?php declare(strict_types=1);
/**
 * Onboarding setup page. Shown when no Super-Administrator exists yet.
 * Creates the first coalition organization and the first Super-Admin account.
 */

require_once __DIR__ . '/lib/session.php';
archr_session_start();

require_once __DIR__ . '/lib/db.php';

$pdo = archr_pdo();

// If a super-admin already exists, go to login.
$superAdminCount = (int) $pdo->query("
    SELECT COUNT(*)
      FROM user_role_assignments ura
      JOIN roles r ON r.id = ura.role_id
     WHERE r.role_code = 'SUPER_ADMIN'
       AND ura.is_active = true
")->fetchColumn();
if ($superAdminCount > 0) {
    header('Location: login.php');
    exit;
}

require_once __DIR__ . '/lib/layout.php';

$error = '';
$success = false;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $coalitionName = trim((string)($_POST['coalition_name'] ?? ''));
    $coalitionCode = trim((string)($_POST['coalition_code'] ?? ''));
    $adminEmail    = trim((string)($_POST['admin_email'] ?? ''));
    $adminUsername = trim((string)($_POST['admin_username'] ?? ''));
    $adminPassword = (string)($_POST['admin_password'] ?? '');
    $adminFullName = trim((string)($_POST['admin_full_name'] ?? ''));
    $adminPhone    = trim((string)($_POST['admin_phone'] ?? ''));

    if ($coalitionName === '' || $coalitionCode === '' || $adminEmail === '' ||
        $adminUsername === '' || $adminPassword === '' || $adminFullName === '') {
        $error = 'Please fill in all required fields.';
    } elseif (!filter_var($adminEmail, FILTER_VALIDATE_EMAIL)) {
        $error = 'Please enter a valid email address.';
    } elseif (strlen($adminPassword) < 12) {
        $error = 'Super-Admin password must be at least 12 characters long.';
    } else {
        try {
            $pdo->beginTransaction();

            // Create the first (founding) organization.
            $orgStmt = $pdo->prepare("
                INSERT INTO coalition_organizations
                    (organization_code, organization_name, contact_email, is_active, created_by)
                VALUES (:code, :name, :email, true, NULL)
                RETURNING id
            ");
            $orgStmt->execute([
                ':code'  => $coalitionCode,
                ':name'  => $coalitionName,
                ':email' => $adminEmail,
            ]);
            $organizationId = (int) $orgStmt->fetchColumn();

            // Create the first Super-Admin user.
            $parts = explode(' ', $adminFullName, 2);
            $firstName = $parts[0];
            $lastName  = $parts[1] ?? '';

            $userStmt = $pdo->prepare("
                INSERT INTO system_users
                    (username, email, full_name, first_name, last_name, phone, password_hash, is_active)
                VALUES (:username, :email, :full_name, :first_name, :last_name, :phone, :hash, true)
                RETURNING id
            ");
            $userStmt->execute([
                ':username'   => $adminUsername,
                ':email'      => $adminEmail,
                ':full_name'  => $adminFullName,
                ':first_name' => $firstName,
                ':last_name'  => $lastName,
                ':phone'      => $adminPhone ?: null,
                ':hash'        => password_hash($adminPassword, PASSWORD_DEFAULT),
            ]);
            $userId = (int) $userStmt->fetchColumn();

            // Assign SUPER_ADMIN role.
            $roleStmt = $pdo->prepare("
                INSERT INTO user_role_assignments (user_id, organization_id, role_id, assigned_by)
                VALUES (:uid, :org, (SELECT id FROM roles WHERE role_code = 'SUPER_ADMIN'), :uid)
            ");
            $roleStmt->execute([':uid' => $userId, ':org' => $organizationId]);

            $pdo->commit();
            $success = true;
        } catch (Throwable $e) {
            $pdo->rollBack();
            $error = 'Setup failed: ' . $e->getMessage();
        }
    }
}

archr_render_header('ARCHR Setup', 'setup');
?>
<main class="page-wrap">
    <section class="panel" style="max-width: 700px; margin: 3rem auto;">
        <h1>Welcome to ARCHR</h1>
        <p>This is the one-time platform setup. Create the founding coalition and the first Super-Administrator account.</p>

        <?php if ($success): ?>
            <div class="alert" style="background: #e6f7e6; border-left: 4px solid #2f9e69; padding: 1rem; margin: 1rem 0;">
                <strong>Setup complete!</strong> Your Super-Admin account is ready. <a href="login.php">Log in</a> to continue.
            </div>
        <?php else: ?>
            <?php if ($error): ?>
                <div class="alert" style="background: #fee; border-left: 4px solid #c33; padding: 1rem; margin: 1rem 0;">
                    <?= e($error) ?>
                </div>
            <?php endif; ?>

            <form method="post" style="margin-top: 2rem;">
                <h2>Coalition / Organization</h2>
                <div style="margin-bottom: 1rem;">
                    <label style="display: block; font-weight: 600; margin-bottom: 0.5rem;">Coalition Name *</label>
                    <input type="text" name="coalition_name" required style="width: 100%; padding: 0.75rem; border: 1px solid #ccc; border-radius: 4px;" placeholder="e.g., Buncombe Home Repair Coalition">
                </div>
                <div style="margin-bottom: 1rem;">
                    <label style="display: block; font-weight: 600; margin-bottom: 0.5rem;">Coalition Code *</label>
                    <input type="text" name="coalition_code" required style="width: 100%; padding: 0.75rem; border: 1px solid #ccc; border-radius: 4px;" placeholder="e.g., BHRC">
                    <small>Short unique code used internally.</small>
                </div>

                <h2 style="margin-top: 2rem;">First Super-Administrator</h2>
                <div style="margin-bottom: 1rem;">
                    <label style="display: block; font-weight: 600; margin-bottom: 0.5rem;">Full Name *</label>
                    <input type="text" name="admin_full_name" required style="width: 100%; padding: 0.75rem; border: 1px solid #ccc; border-radius: 4px;">
                </div>
                <div style="margin-bottom: 1rem;">
                    <label style="display: block; font-weight: 600; margin-bottom: 0.5rem;">Username *</label>
                    <input type="text" name="admin_username" required style="width: 100%; padding: 0.75rem; border: 1px solid #ccc; border-radius: 4px;">
                </div>
                <div style="margin-bottom: 1rem;">
                    <label style="display: block; font-weight: 600; margin-bottom: 0.5rem;">Email *</label>
                    <input type="email" name="admin_email" required style="width: 100%; padding: 0.75rem; border: 1px solid #ccc; border-radius: 4px;">
                </div>
                <div style="margin-bottom: 1rem;">
                    <label style="display: block; font-weight: 600; margin-bottom: 0.5rem;">Phone</label>
                    <input type="tel" name="admin_phone" style="width: 100%; padding: 0.75rem; border: 1px solid #ccc; border-radius: 4px;">
                </div>
                <div style="margin-bottom: 1.5rem;">
                    <label style="display: block; font-weight: 600; margin-bottom: 0.5rem;">Password *</label>
                    <input type="password" name="admin_password" required minlength="12" style="width: 100%; padding: 0.75rem; border: 1px solid #ccc; border-radius: 4px;">
                    <small>Minimum 12 characters.</small>
                </div>

                <button type="submit" class="btn primary" style="width: 100%; padding: 0.875rem; font-size: 1rem;">
                    Create Coalition & Super-Admin Account
                </button>
            </form>
        <?php endif; ?>
    </section>
</main>
<?php archr_render_footer(); ?>
