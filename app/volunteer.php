<?php
declare(strict_types=1);

/* Volunteer role portal. Wrapper around partials/volunteer-body.php
   (markup ported from templates/volunteer.php). */

require __DIR__ . '/lib/auth.php';
archr_require_auth();

require __DIR__ . '/lib/portal-layout.php';

archr_render_portal_header([
    'role'            => 'volunteer',
    'role_label'      => 'Volunteer',
    'brand'           => 'ARCHR Volunteer',
    'page_title'      => 'My Dashboard',
    'user_name'       => 'Riley Park',
    'avatar_initials' => 'RP',
    'badge_icon'      => 'fa-hand-holding-heart',
    'extra_head'      => '<link rel="stylesheet" href="assets/role-volunteer.css">',
    'nav' => [
    ['href' => '#dashboard', 'icon' => 'fa-gauge-high', 'label' => 'My Dashboard', 'active' => true],
    ['href' => '#shifts', 'icon' => 'fa-calendar-day', 'label' => 'My Shifts'],
    ['href' => '#quests', 'icon' => 'fa-hand-holding-heart', 'label' => 'Find Opportunities'],
    ['href' => '#orientations', 'icon' => 'fa-graduation-cap', 'label' => 'Orientations'],
    ['href' => 'tle-poc.php', 'icon' => 'fa-list-check', 'label' => 'Tasks, Logs & Events'],
    ['href' => '#hours', 'icon' => 'fa-clock', 'label' => 'Hours Log'],
    ['href' => '#profile', 'icon' => 'fa-user', 'label' => 'My Profile'],
    ['href' => '#help', 'icon' => 'fa-circle-question', 'label' => 'Help'],
    ],
]);

require __DIR__ . '/partials/volunteer-body.php';

archr_render_portal_footer();
