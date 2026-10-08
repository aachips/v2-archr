<?php
declare(strict_types=1);

/* Crew Lead role portal. Generated wrapper around
   partials/crew-lead-body.php (markup ported from templates/crew-lead.html).
   Page-specific CSS lives in assets/role-crew-lead.css. */

require __DIR__ . '/lib/auth.php';
archr_require_auth();

require __DIR__ . '/lib/portal-layout.php';

archr_render_portal_header([
    'role'            => 'crew-lead',
    'role_label'      => 'Crew Lead',
    'brand'           => 'ARCHR Crew Lead',
    'page_title'      => 'Crew Lead Dashboard',
    'user_name'       => 'Mike Rivera',
    'avatar_initials' => 'MR',
    'badge_icon'      => 'fa-helmet-safety',
    'extra_head'      => '<link rel="stylesheet" href="assets/role-crew-lead.css">',
    'nav' => [
    ['href' => '#dashboard', 'icon' => 'fa-gauge-high', 'label' => 'Today', 'active' => true],
    ['href' => '#currentJob', 'icon' => 'fa-helmet-safety', 'label' => 'Current Job'],
    ['href' => '#tomorrow', 'icon' => 'fa-calendar-day', 'label' => 'Tomorrow'],
    ['group' => 'Site Operations'],
    ['href' => '#tasks', 'icon' => 'fa-list-check', 'label' => 'Task Updates'],
    ['href' => '#photos', 'icon' => 'fa-camera', 'label' => 'Upload Photos'],
    ['href' => '#dailyLog', 'icon' => 'fa-pen-to-square', 'label' => 'Daily Log'],
    ['href' => '#safetyTalk', 'icon' => 'fa-shield-halved', 'label' => 'Safety Talk'],
    ['href' => '#completion', 'icon' => 'fa-file-signature', 'label' => 'Completion &amp; Sign-off'],
    ['group' => 'People'],
    ['href' => '#volunteers', 'icon' => 'fa-hands-helping', 'label' => 'Volunteers'],
    ['href' => '#crew', 'icon' => 'fa-people-group', 'label' => 'Crew Members'],
    ['href' => '#subcontractors', 'icon' => 'fa-hard-hat', 'label' => 'Subcontractors'],
    ['group' => 'Field Reports'],
    ['href' => '#changeOrder', 'icon' => 'fa-file-pen', 'label' => 'Change Order'],
    ['href' => '#incident', 'icon' => 'fa-triangle-exclamation', 'label' => 'Incident Report'],
    ['href' => '#materials', 'icon' => 'fa-toolbox', 'label' => 'Material Request'],
    ['group' => 'Communications'],
    ['href' => '#messages', 'icon' => 'fa-envelope', 'label' => 'Messages'],
    ['href' => '#alerts', 'icon' => 'fa-bell', 'label' => 'Alerts'],
    ],
]);

require __DIR__ . '/partials/crew-lead-body.php';

archr_render_portal_footer();
