<?php declare(strict_types=1);
/**
 * Single entry point for all authenticated role dashboards.
 *
 * Resolves the user's role (or an explicit ?view= parameter) to the
 * appropriate legacy role portal and redirects there. In later phases,
 * each portal will be refactored into a view rendered directly by this
 * controller.
 */

require_once __DIR__ . '/lib/auth.php';
archr_require_auth();

require_once __DIR__ . '/config/dashboard-routes.php';

$role = $_SESSION['archr_role'] ?? '';
$view = trim((string)($_GET['view'] ?? ''));
$target = archr_dashboard_target($role, $view);

if ($target) {
    header('Location: ' . $target);
    exit;
}

http_response_code(404);
require_once __DIR__ . '/lib/layout.php';
archr_render_header('Dashboard Not Found', 'error');
?>
<main class="page-wrap narrow">
    <section class="panel">
        <h1>Dashboard unavailable</h1>
        <p>No dashboard view is configured for the role <strong><?= e($view ?: $role) ?></strong>.</p>
        <p><a class="btn primary" href="index.php">Return home</a></p>
    </section>
</main>
<?php archr_render_footer(); ?>
