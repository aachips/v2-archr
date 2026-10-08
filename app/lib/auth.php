<?php
declare(strict_types=1);

/* Simple session-based authentication for role portals. */

require_once __DIR__ . '/session.php';
require_once __DIR__ . '/permissions.php';

function archr_require_auth(): void {
    archr_session_start();

    if (!isset($_SESSION['archr_role'])) {
        header('Location: login.php');
        exit;
    }
}

function archr_get_current_role(): ?string {
    archr_session_start();
    return $_SESSION['archr_role'] ?? null;
}

function archr_get_current_role_display(): ?string {
    archr_session_start();
    return $_SESSION['archr_role_display'] ?? null;
}

function archr_is_authenticated(): bool {
    archr_session_start();
    return isset($_SESSION['archr_role']);
}

/**
 * Get the permission level (0-3) of the currently authenticated user.
 * Returns 0 if not authenticated or role is unknown.
 */
function archr_current_permission_level(): int {
    archr_session_start();
    return archr_get_permission_level($_SESSION['archr_role'] ?? null);
}

/**
 * Check if the current user has a specific capability.
 * Returns false if not authenticated.
 */
function archr_current_user_has_capability(string $capability): bool {
    archr_session_start();
    return archr_has_capability($_SESSION['archr_role'] ?? null, $capability);
}

/**
 * Require the current user to have a minimum permission level.
 * Sends 403 and exits if the user lacks the required level.
 */
function archr_require_level(int $minLevel): void {
    archr_require_auth();
    $level = archr_current_permission_level();
    if ($level < $minLevel) {
        http_response_code(403);
        require_once __DIR__ . '/layout.php';
        archr_render_header('Access Denied', 'error');
        ?>
        <main class="page-wrap narrow">
            <section class="panel">
                <h1>Insufficient permissions</h1>
                <p>This page requires <strong><?= e(archr_get_level_label($minLevel)) ?></strong>
                   access or higher. Your current role
                   (<strong><?= e($_SESSION['archr_role_display'] ?? $_SESSION['archr_role'] ?? 'unknown') ?></strong>)
                   is at level <?= $level ?>.</p>
                <p><a class="btn primary" href="index.php">Return home</a></p>
            </section>
        </main>
        <?php
        archr_render_footer();
        exit;
    }
}
