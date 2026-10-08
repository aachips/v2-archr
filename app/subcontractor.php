<?php
declare(strict_types=1);

/* Subcontractor role portal. Generated wrapper around
   partials/subcontractor-body.php (markup ported from templates/subcontractor.html).
   Page-specific CSS lives in assets/role-subcontractor.css. */

require __DIR__ . '/lib/auth.php';
archr_require_auth();

require __DIR__ . '/lib/portal-layout.php';

archr_render_portal_header([
    'role'            => 'subcontractor',
    'role_label'      => 'Subcontractor',
    'brand'           => 'ARCHR Subcontractor',
    'page_title'      => 'Subcontractor Dashboard',
    'user_name'       => 'Mike Rivera',
    'avatar_initials' => 'MR',
    'badge_icon'      => 'fa-hammer',
    'extra_head'      => '<link rel="stylesheet" href="assets/role-subcontractor.css">',
    'nav' => [
    ['href' => '#dashboard', 'icon' => 'fa-gauge-high', 'label' => 'Dashboard', 'active' => true],
    ['href' => '#accepted', 'icon' => 'fa-clipboard-check', 'label' => 'My Tasks'],
    ['href' => '#marketplace', 'icon' => 'fa-handshake', 'label' => 'Marketplace'],
    ['href' => '#schedule', 'icon' => 'fa-calendar-plus', 'label' => 'Schedule'],
    ['href' => '#quotes', 'icon' => 'fa-file-invoice-dollar', 'label' => 'Quotes'],
    ['href' => '#invoices', 'icon' => 'fa-receipt', 'label' => 'Invoices'],
    ['href' => '#past-jobs', 'icon' => 'fa-clock-rotate-left', 'label' => 'Past Jobs'],
    ['href' => '../../documentation/task-engine/tle-poc.html', 'icon' => 'fa-list-check', 'label' => 'Tasks, Logs &amp; Events'],
    ['href' => '#messages', 'icon' => 'fa-envelope', 'label' => 'Messages'],
    ],
]);

require __DIR__ . '/partials/subcontractor-body.php';

archr_render_portal_footer();
