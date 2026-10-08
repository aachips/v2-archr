<?php
declare(strict_types=1);

/* Crew Member role portal. Generated wrapper around
   partials/crew-member-body.php (markup ported from templates/crew-member.html).
   Page-specific CSS lives in assets/role-crew-member.css. */

require __DIR__ . '/lib/auth.php';
archr_require_auth();

require __DIR__ . '/lib/portal-layout.php';

archr_render_portal_header([
    'role'            => 'crew-member',
    'role_label'      => 'Crew Member',
    'brand'           => 'ARCHR Crew Member',
    'page_title'      => 'Crew Member Dashboard',
    'user_name'       => '',
    'avatar_initials' => 'AH',
    'badge_icon'      => 'fa-helmet-safety',
    'extra_head'      => '<link rel="stylesheet" href="assets/role-crew-member.css">',
    'nav' => [
    ['href' => '#dashboard', 'icon' => 'fa-gauge-high', 'label' => 'Today', 'active' => true],
    ['href' => '#currentJob', 'icon' => 'fa-helmet-safety', 'label' => 'Current Job'],
    ['href' => '#tomorrow', 'icon' => 'fa-calendar-day', 'label' => 'Tomorrow'],
    ['group' => 'On the Job'],
    ['href' => '#tasks', 'icon' => 'fa-list-check', 'label' => 'My Tasks'],
    ['href' => '#photos', 'icon' => 'fa-camera', 'label' => 'Upload Photo'],
    ['href' => '#dailyLog', 'icon' => 'fa-pen-to-square', 'label' => 'Daily Log'],
    ['href' => '#hours', 'icon' => 'fa-clock', 'label' => 'Clock In / Out'],
    ['group' => 'People'],
    ['href' => '#volunteers', 'icon' => 'fa-hands-helping', 'label' => 'Volunteers View'],
    ['group' => 'Help &amp; Safety'],
    ['href' => '#safetyTalk', 'icon' => 'fa-shield-halved', 'label' => 'Safety Talk'],
    ['href' => '#incident', 'icon' => 'fa-triangle-exclamation', 'label' => 'Incident Report'],
    ['href' => '#handbook', 'icon' => 'fa-book', 'label' => 'Handbook'],
    ['href' => '#emergency', 'icon' => 'fa-phone', 'label' => 'Emergency'],
    ['group' => 'Communications'],
    ['href' => '#messages', 'icon' => 'fa-envelope', 'label' => 'Messages'],
    ],
]);

require __DIR__ . '/partials/crew-member-body.php';

archr_render_portal_footer();
