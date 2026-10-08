<?php
declare(strict_types=1);

/* Bursar role portal — funding overview, reimbursement queue,
   duplicate/overlap alerts. Ported from templates/bursar-min.html
   and bursar-max.html into a single PHP page. */

require __DIR__ . '/lib/auth.php';
archr_require_auth();

require __DIR__ . '/lib/portal-layout.php';
require __DIR__ . '/lib/sample-data.php';

$data = archr_sample_bursar();
$u    = $data['user'];

/* Finance-only components stay scoped to this page. */
$pageCss = <<<CSS
.funding-table { width: 100%; border-collapse: collapse; font-variant-numeric: tabular-nums; }
.funding-table thead th { text-align: left; font-size: var(--fs-xs); text-transform: uppercase; letter-spacing: 0.04em; color: var(--color-text-muted); font-weight: 600; padding: var(--space-3); border-bottom: 1px solid var(--color-border-strong); }
.funding-table tbody td { padding: var(--space-3); border-bottom: 1px dashed var(--color-border); }
.funding-table tbody tr:hover { background: var(--bg-surface-alt); }
.funding-table .col-num  { text-align: right; }
.funding-table .case-id  { font-family: var(--font-display); font-weight: 700; }
.funding-table .org-name { color: var(--color-text-muted); font-size: var(--fs-sm); }

.cap-meter { display: inline-block; width: 80px; height: 6px; background: var(--bg-surface-alt); border-radius: var(--radius-pill); overflow: hidden; vertical-align: middle; }
.cap-meter-fill { display: block; height: 100%; background: var(--role-accent-deep); }
.cap-meter-fill.is-warning { background: var(--color-warning); }
.cap-meter-fill.is-danger  { background: var(--color-danger); }

.reimb-list { list-style: none; padding: 0; margin: 0; display: grid; gap: var(--space-3); }
.reimb-item { display: grid; grid-template-columns: 36px 1fr auto; gap: var(--space-3); align-items: center; padding: var(--space-3) var(--space-4); background: var(--bg-surface-alt); border: 1px solid var(--color-border-strong); border-radius: var(--radius-md); border-left: 4px solid var(--role-accent-deep); }
.reimb-item.is-overdue  { border-left-color: var(--color-danger); }
.reimb-item.is-critical { border-left-color: var(--color-warning); }
.reimb-item .alert-icon { color: var(--color-danger); font-size: 1.25rem; }
.reimb-item .reimb-id   { font-family: var(--font-display); font-weight: 700; }
.reimb-item .reimb-meta { font-size: var(--fs-xs); color: var(--color-text-muted); display: flex; flex-wrap: wrap; gap: var(--space-2); margin-top: 2px; }
.reimb-item .reimb-amount { font-family: var(--font-display); font-weight: 700; font-size: var(--fs-lg); }

.fund-bar { display: flex; width: 100%; height: 14px; border-radius: var(--radius-pill); overflow: hidden; background: var(--bg-surface-alt); margin-bottom: var(--space-4); }
.fund-bar-slice { display: block; height: 100%; }
.fund-legend { list-style: none; padding: 0; margin: 0; display: grid; gap: var(--space-2); }
.fund-legend li { display: grid; grid-template-columns: 14px 1fr auto auto; gap: var(--space-3); align-items: center; font-size: var(--fs-sm); }
.fund-legend-swatch { width: 14px; height: 14px; border-radius: 3px; }
.fund-legend-amount { font-family: var(--font-display); font-weight: 700; font-variant-numeric: tabular-nums; }

.alert-list { list-style: none; padding: 0; margin: 0; display: grid; gap: var(--space-3); }
.alert-item { display: grid; grid-template-columns: 28px 1fr auto; gap: var(--space-3); align-items: center; padding: var(--space-3) var(--space-4); background: var(--bg-surface-alt); border: 1px solid var(--color-border-strong); border-radius: var(--radius-md); border-left: 4px solid var(--color-danger); }
.alert-item .alert-icon { color: var(--color-danger); font-size: 1.25rem; }
.alert-item .alert-title  { font-weight: 700; }
.alert-item .alert-detail { font-size: var(--fs-sm); color: var(--color-text-muted); }

.bursar-action-row { display: flex; flex-wrap: wrap; gap: var(--space-3); margin: var(--space-6) 0 var(--space-5); padding: var(--space-4) 0; border-top: 2px solid var(--color-border-strong); border-bottom: 2px solid var(--color-border-strong); }
.bursar-action-btn { display: inline-flex; align-items: center; gap: var(--space-2); padding: var(--space-3) var(--space-5); background: var(--bg-surface); border: 1px solid var(--color-border-strong); border-radius: var(--radius-md); font-weight: 600; color: var(--color-text); text-decoration: none; transition: var(--transition); }
.bursar-action-btn:hover { background: var(--role-accent-deep); border-color: var(--role-accent-deep); color: #fff; transform: translateY(-2px); }

.kpi.kpi-approved { border-top-color: var(--color-secondary); }
.kpi.kpi-pending  { border-top-color: var(--color-warning); }
.kpi.kpi-paid     { border-top-color: var(--role-accent-deep); }
.kpi.kpi-hold     { border-top-color: var(--color-danger); }
.kpi-grid { grid-template-columns: repeat(4, 1fr); }
@media (max-width: 1100px) { .kpi-grid { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 600px)  { .kpi-grid { grid-template-columns: 1fr; } }
CSS;

archr_render_portal_header([
    'role'            => 'bursar',
    'role_label'      => 'Bursar',
    'brand'           => 'ARCHR Bursar',
    'page_title'      => 'Bursar Dashboard',
    'org'             => $u['org'],
    'user_name'       => $u['name'],
    'avatar_initials' => $u['initials'],
    'badge_icon'      => 'fa-coins',
    'extra_css'       => $pageCss,
    'nav' => [
        ['href'=>'#dashboard',     'icon'=>'fa-gauge-high',           'label'=>'Dashboard', 'active'=>true],
        ['href'=>'#cases',         'icon'=>'fa-file-invoice-dollar',  'label'=>'Case Funding'],
        ['href'=>'#reimbursements','icon'=>'fa-clock-rotate-left',    'label'=>'Reimbursements'],
        ['href'=>'#sources',       'icon'=>'fa-hand-holding-dollar',  'label'=>'Funding Sources'],
        ['href'=>'#duplicates',    'icon'=>'fa-triangle-exclamation', 'label'=>'Duplicate Review'],
        ['href'=>'#reports',       'icon'=>'fa-chart-line',           'label'=>'Reports'],
        ['href'=>'tle-poc.php',    'icon'=>'fa-list-check',           'label'=>'Tasks, Logs & Events'],
        ['href'=>'#audit',         'icon'=>'fa-shield-halved',        'label'=>'Audit Log'],
    ],
]);

require __DIR__ . '/partials/bursar-body.php';

archr_render_portal_footer();
