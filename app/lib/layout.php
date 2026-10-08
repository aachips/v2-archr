<?php
declare(strict_types=1);

/* Shared header/footer helpers + tiny escape shortcut for the /app pages. */

require_once __DIR__ . '/session.php';
require_once __DIR__ . '/language-translations.php';

function e(?string $s): string {
    return htmlspecialchars((string)$s, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

function archr_render_header(string $title, string $activeNav = ''): void {
    archr_session_start();
    $isAuthenticated = isset($_SESSION['archr_role']);

    $items = [
        'home'   => ['label' => 'Home',          'href' => 'index.php'],
        'intake' => ['label' => 'Start Intake',  'href' => 'intake.php'],
        'help'   => ['label' => 'Help',          'href' => 'help.php'],
    ];

    if ($isAuthenticated) {
        $items['dashboard'] = ['label' => 'Dashboard', 'href' => 'dashboard.php'];
        $items['logout']    = ['label' => 'Logout',    'href' => 'logout.php'];
    } else {
        $items['login'] = ['label' => 'Log In', 'href' => 'login.php'];
    }
    ?>
    <!DOCTYPE html>
    <html lang="<?= e(archr_current_language()) ?>">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title><?= e($title) ?> &middot; ARCHR</title>
        <link rel="icon" type="image/svg+xml" href="assets/archr-logo.svg">
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&family=Open+Sans:wght@400;600&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="assets/app.css">
    </head>
    <body>
        <header class="site-header">
            <a class="brand" href="index.php">
                <img src="assets/archr-logo.svg" alt="ARCHR">
                <span>ARCHR</span>
            </a>
            <nav aria-label="Primary">
                <ul>
                <?php foreach ($items as $code => $item): ?>
                    <li>
                        <a href="<?= e($item['href']) ?>"
                           <?= $code === $activeNav ? 'aria-current="page"' : '' ?>>
                            <?= e($item['label']) ?>
                        </a>
                    </li>
                <?php endforeach; ?>
                </ul>
            </nav>
        </header>
    <?php
}

function archr_render_footer(): void {
    ?>
    </body>
    </html>
    <?php
}
