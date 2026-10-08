<?php
declare(strict_types=1);

/* Envoy role portal. Generated wrapper around
   partials/envoy-body.php (markup ported from templates/envoy.html).
   Page-specific CSS lives in assets/role-envoy.css. */

require __DIR__ . '/lib/auth.php';
archr_require_auth();

require __DIR__ . '/lib/portal-layout.php';

archr_render_portal_header([
    'role'            => 'envoy',
    'role_label'      => 'Envoy',
    'brand'           => 'ARCHR Envoy',
    'page_title'      => 'Envoy Dashboard',
    'user_name'       => 'Eileen Bailey',
    'avatar_initials' => 'EB',
    'badge_icon'      => 'fa-flag',
    'extra_head'      => '<link rel="stylesheet" href="assets/role-envoy.css">',
    'nav' => [
    ['href' => '#dashboard', 'icon' => 'fa-gauge-high', 'label' => 'Dashboard', 'active' => true],
    ['href' => '#coalition', 'icon' => 'fa-globe', 'label' => 'Coalition Overview'],
    ['href' => '#caseSearchAdvanced', 'icon' => 'fa-magnifying-glass-plus', 'label' => 'Advanced Case Search'],
    ['group' => 'Marketplace'],
    ['href' => '#marketplaceJobs', 'icon' => 'fa-briefcase', 'label' => 'Eligible Jobs'],
    ['href' => '#acceptedJobs', 'icon' => 'fa-circle-check', 'label' => 'Accepted Jobs'],
    ['href' => '#marketplaceTasks', 'icon' => 'fa-list-check', 'label' => 'Eligible Tasks'],
    ['href' => '#acceptedTasks', 'icon' => 'fa-square-check', 'label' => 'Accepted Tasks'],
    ['group' => 'Approvals'],
    ['href' => '#contracts', 'icon' => 'fa-file-signature', 'label' => 'Contracts'],
    ['href' => '#programChanges', 'icon' => 'fa-file-pen', 'label' => 'Program Changes'],
    ['href' => '#budgetApproval', 'icon' => 'fa-stamp', 'label' => 'Budget Approvals'],
    ['group' => 'Eligibility &amp; Capacity'],
    ['href' => '#programRequirements', 'icon' => 'fa-sliders', 'label' => 'Program Eligibility'],
    ['href' => '#taskCapacity', 'icon' => 'fa-scale-balanced', 'label' => 'Org Task Capacity'],
    ['href' => '#policyUpdates', 'icon' => 'fa-book', 'label' => 'Policy &amp; Guidelines'],
    ['group' => 'Funding'],
    ['href' => '#fundingOverview', 'icon' => 'fa-sack-dollar', 'label' => 'Funding Overview'],
    ['href' => '#fundingByOrg', 'icon' => 'fa-building-columns', 'label' => 'Funding by Org'],
    ['href' => '#funderRelations', 'icon' => 'fa-handshake', 'label' => 'Funder Relations'],
    ['group' => 'Partner Orgs'],
    ['href' => '#orgs', 'icon' => 'fa-building', 'label' => 'Partner Organizations'],
    ['href' => '#orgHealth', 'icon' => 'fa-heart-pulse', 'label' => 'Org Health Summary'],
    ['href' => '#orgOnboarding', 'icon' => 'fa-user-plus', 'label' => 'Org Onboarding'],
    ['group' => 'Performance'],
    ['href' => '#performanceMetrics', 'icon' => 'fa-chart-line', 'label' => 'Performance Metrics'],
    ['href' => '#reports', 'icon' => 'fa-file-lines', 'label' => 'Reports'],
    ['href' => '#strategicNotes', 'icon' => 'fa-lightbulb', 'label' => 'Strategic Notes'],
    ['group' => 'Communications'],
    ['href' => '#alerts', 'icon' => 'fa-bell', 'label' => 'Alerts'],
    ['href' => '#messages', 'icon' => 'fa-envelope', 'label' => 'Messages'],
    ['href' => '../../documentation/task-engine/tle-poc.html', 'icon' => 'fa-list-check', 'label' => 'Tasks, Logs &amp; Events'],
    ],
]);

require __DIR__ . '/partials/envoy-body.php';

archr_render_portal_footer();
