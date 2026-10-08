<?php
declare(strict_types=1);

/* Project Manager role portal. Generated wrapper around
   partials/project-manager-body.php (markup ported from templates/project-manager.html).
   Page-specific CSS lives in assets/role-project-manager.css. */

require __DIR__ . '/lib/auth.php';
archr_require_auth();

require __DIR__ . '/lib/portal-layout.php';

archr_render_portal_header([
    'role'            => 'project-manager',
    'role_label'      => 'Project Manager',
    'brand'           => 'ARCHR Project Manager',
    'page_title'      => 'Project Manager Dashboard',
    'user_name'       => 'Jamie Rivera',
    'avatar_initials' => 'JR',
    'badge_icon'      => 'fa-diagram-project',
    'extra_head'      => '<link rel="stylesheet" href="assets/role-project-manager.css">',
    'nav' => [
    ['href' => '#dashboard', 'icon' => 'fa-gauge-high', 'label' => 'Dashboard', 'active' => true],
    ['href' => '#caseSearchAdvanced', 'icon' => 'fa-magnifying-glass-plus', 'label' => 'Advanced Case Search'],
    ['group' => 'Projects'],
    ['href' => '#projects', 'icon' => 'fa-diagram-project', 'label' => 'Active Projects'],
    ['href' => '#unclaimed', 'icon' => 'fa-hand-pointer', 'label' => 'Unclaimed Jobs'],
    ['href' => '#ongoing', 'icon' => 'fa-person-digging', 'label' => 'Ongoing Work'],
    ['href' => '#workflows', 'icon' => 'fa-sitemap', 'label' => 'Task Workflows'],
    ['href' => '#schedule', 'icon' => 'fa-calendar-days', 'label' => 'Schedule'],
    ['group' => 'Requestor &amp; Case'],
    ['href' => '#claimJobs', 'icon' => 'fa-hand-holding-heart', 'label' => 'Claim Jobs'],
    ['href' => '#caseNotes', 'icon' => 'fa-sticky-note', 'label' => 'Case Notes'],
    ['href' => '#scheduleAssessment', 'icon' => 'fa-clipboard-list', 'label' => 'Schedule Assessments'],
    ['group' => 'Budget &amp; Estimates'],
    ['href' => '#estimates', 'icon' => 'fa-file-invoice-dollar', 'label' => 'Estimates'],
    ['href' => '#changeOrders', 'icon' => 'fa-file-pen', 'label' => 'Change Orders'],
    ['href' => '#contracts', 'icon' => 'fa-file-signature', 'label' => 'Contracts'],
    ['group' => 'Teams'],
    ['href' => '#crew', 'icon' => 'fa-people-group', 'label' => 'Crew Assignments'],
    ['href' => '#subcontractors', 'icon' => 'fa-hard-hat', 'label' => 'Subcontractors'],
    ['href' => '#volunteers', 'icon' => 'fa-hands-helping', 'label' => 'Volunteers'],
    ['group' => 'Communications'],
    ['href' => '#alerts', 'icon' => 'fa-bell', 'label' => 'Alerts'],
    ['href' => '#messages', 'icon' => 'fa-envelope', 'label' => 'Messages'],
    ['href' => 'tle-poc.php', 'icon' => 'fa-list-check', 'label' => 'Tasks, Logs &amp; Events'],
    ['group' => 'Oversight'],
    ['href' => '#escalations', 'icon' => 'fa-triangle-exclamation', 'label' => 'Escalations'],
    ['href' => '#reports', 'icon' => 'fa-chart-line', 'label' => 'Reports'],
    ],
]);

require __DIR__ . '/partials/project-manager-body.php';

archr_render_portal_footer();
