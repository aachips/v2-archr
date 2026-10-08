<?php
declare(strict_types=1);

/* Login portal for role-based demo dashboards.
   Simple authentication: username = role name, password = '12345'.
   Sets session and redirects to the appropriate dashboard. */

require_once __DIR__ . '/lib/session.php';
archr_session_start();

// If no super-admin exists yet, force the onboarding/setup flow.
try {
    require_once __DIR__ . '/lib/db.php';
    $pdo = archr_pdo();
    $superAdminCount = (int) $pdo->query("
        SELECT COUNT(*)
          FROM user_role_assignments ura
          JOIN roles r ON r.id = ura.role_id
         WHERE r.role_code = 'SUPER_ADMIN'
           AND ura.is_active = true
    ")->fetchColumn();
    if ($superAdminCount === 0 && basename($_SERVER['PHP_SELF']) !== 'setup.php') {
        header('Location: setup.php');
        exit;
    }
} catch (Exception $e) {
    // If DB is unreachable, continue to login so the user can see the error.
    error_log('Setup redirect check failed: ' . $e->getMessage());
}

// If already logged in, redirect to the central dashboard dispatcher
if (isset($_SESSION['archr_role'])) {
    header('Location: dashboard.php');
    exit;
}

require __DIR__ . '/lib/layout.php';

$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = trim((string)($_POST['username'] ?? ''));
    $password = (string)($_POST['password'] ?? '');

    // Role mapping: role_code => [display_name, dashboard_file]
    $role_dashboards = [
        'SUPER_ADMIN'     => ['Super Admin', 'super-admin.php'],
        'ASSESSOR'        => ['Assessor', 'assessor.php'],
        'BURSAR'          => ['Bursar', 'bursar.php'],
        'CASEWORKER'      => ['Caseworker', 'case-search.php'],
        'CREW_LEAD'       => ['Crew Lead', 'crew-lead.php'],
        'CREW_MEMBER'     => ['Crew Member', 'crew-member.php'],
        'SUBCONTRACTOR'   => ['Subcontractor', 'subcontractor.php'],
        'ENVOY'           => ['Envoy', 'envoy.php'],
        'PROJECT_MGR'     => ['Project Manager', 'project-manager.php'],
        'PROJECT_MANAGER' => ['Project Manager', 'project-manager.php'],
        'VOLUNTEER'       => ['Volunteer', 'volunteer.php'],
        'ADMIN'           => ['Org Admin', 'org-admin.php'],
        'ORG_ADMIN'       => ['Org Admin', 'org-admin.php'],
        'REQUESTOR'       => ['Requestor', 'requestor-portal.php'],
    ];

    // Fallback hardcoded login for prototype mode
    $legacy_roles = [
        'assessor' => 'ASSESSOR', 'bursar' => 'BURSAR', 'caseworker' => 'CASEWORKER', 'crew-lead' => 'CREW_LEAD',
        'crew lead' => 'CREW_LEAD', 'crew-member' => 'CREW_MEMBER', 'crew member' => 'CREW_MEMBER',
        'subcontractor' => 'SUBCONTRACTOR', 'envoy' => 'ENVOY',
        'project-manager' => 'PROJECT_MGR', 'project manager' => 'PROJECT_MGR',
        'volunteer' => 'VOLUNTEER', 'org-admin' => 'ORG_ADMIN', 'org admin' => 'ORG_ADMIN',
        'admin' => 'ORG_ADMIN', 'tle-poc' => 'ORG_ADMIN', 'requestor' => 'REQUESTOR'
    ];

    $userLower = strtolower($username);
    $authenticated = false;
    $role_code = null;

    // Try database authentication first
    try {
        require_once __DIR__ . '/lib/db.php';
        $pdo = archr_pdo();

        // Match by email OR username (so generated usernames and dummy
        // usernames like john.smith both work).
        $stmt = $pdo->prepare("
            SELECT id, full_name, email, password_hash, session_indefinite
            FROM system_users
            WHERE (email = :email OR username = :username)
              AND is_active = true
            LIMIT 1
        ");
        $stmt->execute([':email' => $username, ':username' => $username]);
        $user = $stmt->fetch() ?: null;

        if ($user) {
            // Verify the password. Hashed passwords are checked with password_verify();
            // for legacy/dev accounts that have no hash, the hardcoded dev password
            // '12345' is still accepted as a fallback.
            $hasHash = !empty($user['password_hash']);
            $passwordOk = $hasHash
                ? password_verify($password, $user['password_hash'])
                : ($password === '12345');

            if ($passwordOk) {
                // Get user's role from user_role_assignments
                $roleStmt = $pdo->prepare("
                    SELECT r.role_code, r.role_name
                    FROM user_role_assignments ura
                    JOIN roles r ON ura.role_id = r.id
                    WHERE ura.user_id = ? AND ura.is_active = true
                    LIMIT 1
                ");
                $roleStmt->execute([$user['id']]);
                $roleRow = $roleStmt->fetch();

                if ($roleRow) {
                    $role_code = $roleRow['role_code'];
                    $authenticated = true;
                    $_SESSION['archr_user_id'] = $user['id'];
                    $_SESSION['archr_user_name'] = $user['full_name'];
                    $_SESSION['archr_user_email'] = $user['email'];
                }
            }
        }
    } catch (Exception $e) {
        error_log("Database login failed: " . $e->getMessage());
        // Fall through to legacy login
    }

    // Fallback to legacy hardcoded login
    if (!$authenticated && $password === '12345' && isset($legacy_roles[$userLower])) {
        $role_code = $legacy_roles[$userLower];
        $authenticated = true;
        $_SESSION['archr_user_name'] = ucwords(str_replace('-', ' ', $username));
    }

    // If authenticated, set session and redirect to the central dashboard dispatcher
    if ($authenticated && $role_code && isset($role_dashboards[$role_code])) {
        $_SESSION['archr_role'] = strtolower(str_replace('_', '-', $role_code));
        $_SESSION['archr_role_display'] = $role_dashboards[$role_code][0];
        $_SESSION['archr_dashboard'] = $role_dashboards[$role_code][1];
        if (!empty($user)) {
            $_SESSION['archr_user_id']    = $user['id'];
            $_SESSION['archr_user_name']  = $user['full_name'];
            $_SESSION['archr_user_email'] = $user['email'];
            archr_set_session_mode((bool) ($user['session_indefinite'] ?? false));
        }
        header('Location: dashboard.php');
        exit;
    } else {
        $error = 'Invalid username or password. Please try again.';
    }
}

function get_dashboard_for_role(string $role): string {
    $roles = [
        'super-admin'     => 'super-admin.php',
        'super_admin'     => 'super-admin.php',
        'assessor'        => 'assessor.php',
        'bursar'          => 'bursar.php',
        'crew-lead'       => 'crew-lead.php',
        'crew lead'       => 'crew-lead.php',
        'crew-member'     => 'crew-member.php',
        'crew member'     => 'crew-member.php',
        'subcontractor'   => 'subcontractor.php',
        'envoy'           => 'envoy.php',
        'project-manager' => 'project-manager.php',
        'project manager' => 'project-manager.php',
        'requestor'       => 'requestor-portal.php',
        'volunteer'       => 'volunteer.php',
        'org-admin'       => 'org-admin.php',
        'org admin'       => 'org-admin.php',
        'admin'           => 'org-admin.php',
        'tle-poc'         => 'tle-poc.php',
    ];
    return $roles[$role] ?? 'index.php';
}

archr_render_header('Login', 'login');
?>
<main class="page-wrap">
    <section class="panel" style="max-width: 500px; margin: 3rem auto;">
        <h1>ARCHR Login Portal</h1>
        <p>Welcome to the ARCHR platform demo. Log in with any role to explore the dashboard.</p>
        
        <?php if ($error): ?>
            <div class="alert error" style="background: #fee; border-left: 4px solid #c33; padding: 1rem; margin: 1rem 0;">
                <?= e($error) ?>
            </div>
        <?php endif; ?>
        
        <form method="post" style="margin-top: 2rem;">
            <div style="margin-bottom: 1.5rem;">
                <label for="username" style="display: block; font-weight: 600; margin-bottom: 0.5rem;">Username (Role)</label>
                <input type="text" id="username" name="username" required 
                       style="width: 100%; padding: 0.75rem; border: 1px solid #ccc; border-radius: 4px; font-size: 1rem;"
                       placeholder="e.g., assessor, bursar, volunteer">
            </div>
            
            <div style="margin-bottom: 1.5rem;">
                <label for="password" style="display: block; font-weight: 600; margin-bottom: 0.5rem;">Password</label>
                <input type="password" id="password" name="password" required 
                       style="width: 100%; padding: 0.75rem; border: 1px solid #ccc; border-radius: 4px; font-size: 1rem;"
                       placeholder="Enter password">
            </div>
            
            <button type="submit" class="btn primary" style="width: 100%; padding: 0.875rem; font-size: 1rem;">
                Log In
            </button>
        </form>
        
        <div style="margin-top: 2rem; padding: 1.5rem; background: #f8f9fa; border-radius: 4px;">
            <h3 style="margin-top: 0; font-size: 1rem; color: #555;">Demo Accounts</h3>
            <p style="margin: 0.5rem 0; font-size: 0.9rem; color: #666;">
                <strong>Password for all accounts:</strong> <code style="background: #fff; padding: 0.2rem 0.4rem; border-radius: 3px;">12345</code>
            </p>
            <p style="margin: 1rem 0 0.5rem 0; font-weight: 600; font-size: 0.9rem; color: #555;">Available roles:</p>
            <ul style="margin: 0; padding-left: 1.5rem; font-size: 0.875rem; color: #666; columns: 2; column-gap: 1rem;">
                <li>assessor</li>
                <li>bursar</li>
                <li>caseworker</li>
                <li>crew-lead</li>
                <li>crew-member</li>
                <li>subcontractor</li>
                <li>envoy</li>
                <li>project-manager</li>
                <li>requestor</li>
                <li>volunteer</li>
                <li>org-admin</li>
                <li>tle-poc</li>
            </ul>
        </div>
    </section>
</main>
<?php archr_render_footer(); ?>
