<?php
declare(strict_types=1);

/* Assessor role portal — mobile-first field-work dashboard.
   Markup ported from templates/assessor.html; the duplicated portal
   scaffolding now lives in lib/portal-layout.php + assets/portal.css,
   and the hard-coded fixture data comes from lib/sample-data.php. */

require __DIR__ . '/lib/auth.php';
archr_require_auth();

require __DIR__ . '/lib/portal-layout.php';
require __DIR__ . '/lib/sample-data.php';

$data = archr_sample_assessor();
$u    = $data['user'];
$s    = $data['today_summary'];
$la   = $data['last_assessment'];

archr_render_portal_header([
    'role'            => 'assessor',
    'role_label'      => 'Assessor',
    'brand'           => 'ARCHR Assessor',
    'page_title'      => 'Assessor Dashboard',
    'org'             => $u['org'],
    'user_name'       => $u['name'],
    'avatar_initials' => $u['initials'],
    'badge_icon'      => 'fa-tape',
    'nav' => [
        ['href'=>'#dashboard',     'icon'=>'fa-gauge-high',       'label'=>'Dashboard', 'active'=>true],
        ['href'=>'#today',         'icon'=>'fa-clipboard-list',   'label'=>"Today's Assessments"],
        ['href'=>'#upcoming',      'icon'=>'fa-calendar-days',    'label'=>'Upcoming'],
        ['href'=>'#previous',      'icon'=>'fa-clock-rotate-left','label'=>'Previous Assessments'],
        ['href'=>'#verify',        'icon'=>'fa-check-double',     'label'=>'Verifications'],
        ['href'=>'tle-poc.php',    'icon'=>'fa-list-check',       'label'=>'Tasks, Logs & Events'],
        ['href'=>'#messages',      'icon'=>'fa-envelope',         'label'=>'Messages'],
        ['href'=>'#subcontractors','icon'=>'fa-hard-hat',         'label'=>'Subcontractors'],
        ['href'=>'#schedule',      'icon'=>'fa-calendar-plus',    'label'=>'Schedule'],
    ],
]);

require __DIR__ . '/partials/assessor-body.php';

archr_render_portal_footer();
