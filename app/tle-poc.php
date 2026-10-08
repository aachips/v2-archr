<?php
declare(strict_types=1);

/* TLE POC role portal. Generated wrapper around
   partials/tle-poc-body.php (markup ported from templates/tle-poc.html).
   Page-specific CSS lives in assets/role-tle-poc.css. */

require __DIR__ . '/lib/auth.php';
archr_require_auth();

require __DIR__ . '/lib/portal-layout.php';

archr_render_portal_header([
    'role'            => 'tle-poc',
    'role_label'      => 'TLE POC',
    'brand'           => 'ARCHR TLE POC',
    'page_title'      => 'Tasks, Logs, &amp; Events',
    'user_name'       => 'Jamie Doe',
    'avatar_initials' => 'JD',
    'badge_icon'      => 'fa-list-check',
    'extra_head'      => '<link rel="stylesheet" href="assets/role-tle-poc.css">',
    'nav' => [
    ['href' => '#dashboard', 'icon' => 'fa-gauge-high', 'label' => 'Dashboard'],
    ['href' => '#cases', 'icon' => 'fa-folder-open', 'label' => 'Cases'],
    ['group' => 'Work'],
    ['href' => '#tle', 'icon' => 'fa-list-check', 'label' => 'Tasks, Logs, &amp; Events
                        3
                        
                    
                
                My Tasks', 'active' => true],
    ['href' => '#schedule', 'icon' => 'fa-calendar-days', 'label' => 'Schedule'],
    ['group' => 'Oversight'],
    ['href' => '#metrics', 'icon' => 'fa-chart-pie', 'label' => 'Metrics'],
    ['href' => '#reports', 'icon' => 'fa-file-lines', 'label' => 'Reports'],
    ['group' => 'Reference'],
    ['href' => '#sop', 'icon' => 'fa-book', 'label' => 'SOPs &amp; Guides'],
    ],
]);

require __DIR__ . '/partials/tle-poc-body.php';

archr_render_portal_footer();
