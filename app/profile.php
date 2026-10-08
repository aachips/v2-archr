<?php declare(strict_types=1);
/**
 * Profile Settings page.
 *
 * Allows an authenticated user to update their basic information,
 * toggle an indefinite (persistent) login session, and configure
 * which dashboard menu items appear in their sidebar.
 */

require_once __DIR__ . '/lib/auth.php';
require_once __DIR__ . '/lib/db.php';
require_once __DIR__ . '/lib/layout.php';
require_once __DIR__ . '/lib/permissions.php';

archr_require_auth();

$pdo = archr_pdo();
$userId = (int) $_SESSION['archr_user_id'];
$role = $_SESSION['archr_role'] ?? '';
$permissionLevel = archr_get_permission_level($role);
$message = '';
$messageType = 'info';

// Ensure menu_config column exists (safe to run every request; IF NOT EXISTS).
$pdo->exec("ALTER TABLE system_users ADD COLUMN IF NOT EXISTS menu_config JSONB DEFAULT NULL");

$stmt = $pdo->prepare("
    SELECT id, username, full_name, email, phone, session_indefinite, menu_config
      FROM system_users
     WHERE id = :id
     LIMIT 1
");
$stmt->execute([':id' => $userId]);
$user = $stmt->fetch();

if (!$user) {
    header('Location: logout.php');
    exit;
}

$menuConfig = archr_user_menu_config($user, $permissionLevel);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? 'profile';

    if ($action === 'profile') {
        $fullName = trim((string)($_POST['full_name'] ?? ''));
        $email    = trim((string)($_POST['email'] ?? ''));
        $phone    = trim((string)($_POST['phone'] ?? ''));
        $indefinite = isset($_POST['session_indefinite']) && $_POST['session_indefinite'] === 'on';

        $upd = $pdo->prepare("
            UPDATE system_users
               SET full_name = :full_name,
                   email = :email,
                   phone = :phone,
                   session_indefinite = :session_indefinite,
                   updated_at = CURRENT_TIMESTAMP
             WHERE id = :id
        ");
        $upd->execute([
            ':full_name'          => $fullName,
            ':email'              => $email,
            ':phone'              => $phone ?: null,
            ':session_indefinite' => $indefinite,
            ':id'                 => $userId,
        ]);

        $_SESSION['archr_user_name'] = $fullName;
        $_SESSION['archr_user_email'] = $email;
        archr_set_session_mode($indefinite);

        $message = 'Profile settings saved.';
        $messageType = 'success';

        $user['full_name'] = $fullName;
        $user['email'] = $email;
        $user['phone'] = $phone;
        $user['session_indefinite'] = $indefinite;
    } elseif ($action === 'menu') {
        // Collect enabled menu items
        $enabled = [];
        foreach (archr_menu_registry() as $item) {
            if ($item['minLevel'] <= $permissionLevel) {
                $enabled[$item['key']] = isset($_POST['menu_' . $item['key']]);
            }
        }
        $upd = $pdo->prepare("
            UPDATE system_users
               SET menu_config = :menu_config,
                   updated_at = CURRENT_TIMESTAMP
             WHERE id = :id
        ");
        $upd->execute([
            ':menu_config' => json_encode($enabled, JSON_UNESCAPED_UNICODE),
            ':id'          => $userId,
        ]);

        $user['menu_config'] = json_encode($enabled, JSON_UNESCAPED_UNICODE);
        $menuConfig = $enabled;

        $message = 'Menu configuration saved.';
        $messageType = 'success';
    }
}

archr_render_header('Profile Settings', 'profile');
?>
<style>
.menu-config-section { margin-bottom: 1.5rem; }
.menu-config-section h3 { margin: 0 0 0.5rem; font-size: 0.95rem; }
.menu-config-group { margin: 0.75rem 0 0.25rem; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.06em; color: var(--color-text-muted, #888); }
.menu-config-items { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 0.3rem 1rem; }
.menu-config-item { display: flex; align-items: center; gap: 0.5rem; padding: 0.3rem 0; font-size: 0.88rem; }
.menu-config-item input[type="checkbox"] { margin: 0; }
.menu-config-item i { width: 1.1em; text-align: center; color: var(--color-text-muted, #888); }
.tab-bar { display: flex; gap: 0; border-bottom: 2px solid var(--color-border, #e0e0e0); margin-bottom: 1.5rem; }
.tab-bar a { padding: 0.6rem 1.2rem; font-size: 0.9rem; text-decoration: none; color: var(--color-text-muted, #888); border-bottom: 2px solid transparent; margin-bottom: -2px; }
.tab-bar a.active { color: var(--color-primary, #1c7a5c); border-bottom-color: var(--color-primary, #1c7a5c); font-weight: 600; }
.tab-bar a:hover { color: var(--color-text, #333); }
.tab-panel { display: none; }
.tab-panel.active { display: block; }
</style>

<main class="page-wrap narrow">
    <section class="panel">
        <h1>Profile Settings</h1>

        <?php if ($message): ?>
            <p class="alert <?= e($messageType) ?>" role="status"><?= e($message) ?></p>
        <?php endif; ?>

        <div class="tab-bar" id="profileTabs">
            <a href="#tab-profile" class="active" data-tab="tab-profile">Profile</a>
            <a href="#tab-menu" data-tab="tab-menu">Menu Configuration</a>
        </div>

        <!-- ===== Profile Tab ===== -->
        <div class="tab-panel active" id="tab-profile">
            <form method="post" action="profile.php" class="stack-form">
                <input type="hidden" name="action" value="profile">
                <div class="field">
                    <label for="username">Username</label>
                    <input type="text" id="username" value="<?= e($user['username']) ?>" disabled>
                </div>

                <div class="field">
                    <label for="full_name">Full Name</label>
                    <input type="text" id="full_name" name="full_name" value="<?= e($user['full_name'] ?? '') ?>">
                </div>

                <div class="field">
                    <label for="email">Email</label>
                    <input type="email" id="email" name="email" value="<?= e($user['email'] ?? '') ?>">
                </div>

                <div class="field">
                    <label for="phone">Phone</label>
                    <input type="tel" id="phone" name="phone" value="<?= e($user['phone'] ?? '') ?>">
                </div>

                <div class="field checkbox">
                    <label>
                        <input type="checkbox" name="session_indefinite" value="on" <?= ($user['session_indefinite'] ?? false) ? 'checked' : '' ?>>
                        Keep me logged in indefinitely (uses a persistent session cookie)
                    </label>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn primary">Save Settings</button>
                </div>
            </form>
        </div>

        <!-- ===== Menu Configuration Tab ===== -->
        <div class="tab-panel" id="tab-menu">
            <p style="font-size:0.88rem; color: var(--color-text-muted, #888); margin-bottom: 1rem;">
                Choose which items appear in your dashboard sidebar.
                Only menu items available at your permission level (<strong><?= e(archr_get_level_label($permissionLevel)) ?></strong>) are shown.
                Check items as you build and test them. Unchecked items are hidden from the sidebar.
            </p>
            <form method="post" action="profile.php" class="stack-form">
                <input type="hidden" name="action" value="menu">
                <?php
                $currentGroup = null;
                foreach (archr_menu_registry() as $item) {
                    if ($item['minLevel'] > $permissionLevel) {
                        continue;
                    }
                    if ($item['group'] !== $currentGroup) {
                        $currentGroup = $item['group'];
                        if ($currentGroup !== null) {
                            echo '<div class="menu-config-group">' . e($currentGroup) . '</div>';
                        }
                        if ($currentGroup === null) {
                            // No group label for core items
                        }
                    }
                    $isChecked = $menuConfig[$item['key']] ?? false;
                    ?>
                    <div class="menu-config-item">
                        <input type="checkbox" id="menu_<?= e($item['key']) ?>" name="menu_<?= e($item['key']) ?>" <?= $isChecked ? 'checked' : '' ?>>
                        <label for="menu_<?= e($item['key']) ?>">
                            <i class="fas <?= e($item['icon']) ?>"></i>
                            <?= e($item['label']) ?>
                        </label>
                    </div>
                    <?php
                }
                ?>
                <div class="form-actions" style="margin-top: 1.5rem;">
                    <button type="submit" class="btn primary">Save Menu</button>
                    <button type="button" class="btn secondary" onclick="checkAllMenu()">Enable All</button>
                    <button type="button" class="btn secondary" onclick="resetMenuDefaults()">Reset to Defaults</button>
                </div>
            </form>
        </div>
    </section>
</main>

<script>
// Tab switching
(function() {
    var tabs = document.querySelectorAll('#profileTabs a');
    tabs.forEach(function(tab) {
        tab.addEventListener('click', function(e) {
            e.preventDefault();
            tabs.forEach(function(t) { t.classList.remove('active'); });
            document.querySelectorAll('.tab-panel').forEach(function(p) { p.classList.remove('active'); });
            tab.classList.add('active');
            var panel = document.getElementById(tab.dataset.tab);
            if (panel) panel.classList.add('active');
        });
    });
})();

function checkAllMenu() {
    document.querySelectorAll('#tab-menu input[type="checkbox"]').forEach(function(cb) { cb.checked = true; });
}

function resetMenuDefaults() {
    // Uncheck all Level 2+ items, keep core items checked
    var defaults = <?= json_encode(array_keys(archr_default_menu($permissionLevel)), JSON_UNESCAPED_UNICODE) ?>;
    document.querySelectorAll('#tab-menu input[type="checkbox"]').forEach(function(cb) {
        var key = cb.name.replace('menu_', '');
        cb.checked = defaults.includes(key);
    });
}
</script>

<?php archr_render_footer(); ?>
