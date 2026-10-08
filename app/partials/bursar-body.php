<?php
/** @var array $data */
/** @var array $u */
$kpis     = $data['kpis'];
$funding  = $data['funding'];
$reimb    = $data['reimbursements'];
?>
<section class="portal-page active" id="dashboardPage" data-page-title="Bursar Dashboard">

    <div class="dash-hero">
        <div>
            <h2>Welcome back, <?= e(explode(' ', $u['name'])[0]) ?></h2>
            <p><?= e($u['org']) ?> &middot; Buncombe County &middot; 48 active cases with funding &middot; Last refreshed today at 9:14 AM</p>
        </div>
        <div class="dash-hero-meta">
            <span class="hero-count-label">Total Approved</span>
            <span class="hero-count"><?= e($kpis[0]['value']) ?></span>
        </div>
    </div>

    <section class="dash-section" aria-labelledby="kpis-h">
        <h3 class="dash-section-title" id="kpis-h"><i class="fas fa-chart-pie"></i> Funding Overview</h3>
        <div class="kpi-grid">
            <?php foreach ($kpis as $k): ?>
                <article class="kpi kpi-<?= e($k['tone']) ?>">
                    <span class="kpi-label"><?= e($k['label']) ?></span>
                    <span class="kpi-value"><?= e($k['value']) ?></span>
                    <span class="kpi-sub"><?= e($k['sub']) ?></span>
                    <span class="kpi-foot"><a href="<?= e($k['href']) ?>"><?= e($k['link_label']) ?> &rarr;</a></span>
                </article>
            <?php endforeach; ?>
        </div>
    </section>

    <section class="dash-section" aria-labelledby="cases-h">
        <div class="section-header-row">
            <h3 class="dash-section-title" id="cases-h" style="margin:0;"><i class="fas fa-file-invoice-dollar"></i> Active Cases with Funding</h3>
            <a href="#cases" class="see-all-link">View all 48 cases &rarr;</a>
        </div>
        <article class="panel" style="padding:0;">
            <div style="overflow-x:auto;">
                <table class="funding-table">
                    <thead><tr>
                        <th scope="col">Case #</th>
                        <th scope="col">Organization</th>
                        <th scope="col" class="col-num">Approved</th>
                        <th scope="col" class="col-num">Incurred</th>
                        <th scope="col" class="col-num">Pending</th>
                        <th scope="col" class="col-num">Remaining</th>
                        <th scope="col">Cap</th>
                        <th scope="col">Status</th>
                    </tr></thead>
                    <tbody>
                        <?php foreach ($funding as $row): ?>
                            <?php
                            $remaining = $row['approved'] - $row['spent'] - $row['pending'];
                            $capPct = $row['approved'] > 0 ? round(($row['spent'] + $row['pending']) / $row['approved'] * 100) : 0;
                            $capClass = $capPct >= 95 ? 'is-danger' : ($capPct >= 75 ? 'is-warning' : '');
                            ?>
                            <tr>
                                <td><span class="case-id"><?= e($row['case_id']) ?></span></td>
                                <td><?= e($row['org']) ?></td>
                                <td class="col-num">$<?= e(number_format($row['approved'])) ?></td>
                                <td class="col-num">$<?= e(number_format($row['spent'])) ?></td>
                                <td class="col-num">$<?= e(number_format($row['pending'])) ?></td>
                                <td class="col-num">$<?= e(number_format($remaining)) ?></td>
                                <td>
                                    <span class="cap-meter" aria-label="<?= e((string)$capPct) ?>% of cap">
                                        <span class="cap-meter-fill <?= e($capClass) ?>" style="width:<?= e((string)$capPct) ?>%"></span>
                                    </span>
                                </td>
                                <td><span class="pill pill-accent"><?= e($row['status']) ?></span></td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </article>
    </section>

    <section class="dash-section">
        <div class="two-col">
            <article class="panel" aria-labelledby="reimb-h">
                <div class="panel-header">
                    <h3 id="reimb-h"><i class="fas fa-clock-rotate-left"></i> Reimbursement Queue</h3>
                    <a href="#reimbursements" class="see-all-link">Process invoices &rarr;</a>
                </div>
                <p style="font-size:var(--fs-sm); color:var(--color-text-muted); margin-bottom:var(--space-3);">
                    <strong><?= e((string)count($reimb)) ?> pending</strong> &middot; SLA target: 30 days
                </p>
                <ul class="reimb-list">
                    <?php foreach ($reimb as $r): ?>
                        <?php
                        $cls = $r['status'] === 'On Hold' ? ' is-overdue' : ($r['days'] >= 5 ? ' is-critical' : '');
                        $pillCls = $r['days'] >= 30 ? 'pill-red' : ($r['days'] >= 14 ? 'pill-amber' : '');
                        ?>
                        <li class="reimb-item<?= $cls ?>">
                            <i class="fas fa-receipt" aria-hidden="true" style="color:var(--role-accent-deep);font-size:1.25rem;"></i>
                            <div>
                                <div class="reimb-id"><?= e($r['vendor']) ?></div>
                                <div class="reimb-meta">
                                    <span>Case <?= e($r['case_id']) ?></span>
                                    <span class="pill <?= e($pillCls) ?>"><?= e((string)$r['days']) ?> days aging</span>
                                </div>
                            </div>
                            <div style="text-align:right;">
                                <div class="reimb-amount">$<?= e(number_format($r['amount'])) ?></div>
                                <a href="#reimbursements" class="btn btn-secondary btn-sm" style="margin-top:4px;">Review</a>
                            </div>
                        </li>
                    <?php endforeach; ?>
                </ul>
            </article>

            <article class="panel" aria-labelledby="sources-h">
                <div class="panel-header">
                    <h3 id="sources-h"><i class="fas fa-hand-holding-dollar"></i> Funding Sources</h3>
                    <a href="#sources" class="see-all-link">Manage &rarr;</a>
                </div>
                <div class="fund-bar" role="img" aria-label="Funding source breakdown">
                    <span class="fund-bar-slice" style="background:#3366CC; width:35.4%;" title="Habitat Grant"></span>
                    <span class="fund-bar-slice" style="background:#E04E39; width:25.0%;" title="FEMA DR-1234"></span>
                    <span class="fund-bar-slice" style="background:#2f9e69; width:22.9%;" title="State Grant"></span>
                    <span class="fund-bar-slice" style="background:#d99518; width:16.7%;" title="Donations"></span>
                </div>
                <ul class="fund-legend">
                    <li><span class="fund-legend-swatch" style="background:#3366CC;"></span><span>Habitat Grant 2024</span><span class="fund-legend-amount">$850,000</span><span class="pill pill-green">Healthy</span></li>
                    <li><span class="fund-legend-swatch" style="background:#E04E39;"></span><span>FEMA DR-1234</span><span class="fund-legend-amount">$600,000</span><span class="pill pill-amber">Depleted</span></li>
                    <li><span class="fund-legend-swatch" style="background:#2f9e69;"></span><span>State Grant</span><span class="fund-legend-amount">$550,000</span><span class="pill pill-green">Healthy</span></li>
                    <li><span class="fund-legend-swatch" style="background:#d99518;"></span><span>Donations Pool</span><span class="fund-legend-amount">$400,000</span><span class="pill pill-green">Healthy</span></li>
                </ul>
            </article>
        </div>
    </section>

    <nav class="bursar-action-row" aria-label="Bursar quick actions">
        <a href="#reimbursements" class="bursar-action-btn"><i class="fas fa-circle-check"></i> Approve Invoice</a>
        <a href="#reimbursements" class="bursar-action-btn"><i class="fas fa-money-bill-transfer"></i> Mark Paid</a>
        <a href="#reimbursements" class="bursar-action-btn"><i class="fas fa-circle-xmark"></i> Reject with Reason</a>
        <a href="#cases" class="bursar-action-btn"><i class="fas fa-pause"></i> Place On Hold</a>
        <a href="#duplicates" class="bursar-action-btn"><i class="fas fa-unlock"></i> Override Claim Lock</a>
        <a href="#sources" class="bursar-action-btn"><i class="fas fa-plus"></i> Allocate Funds</a>
        <a href="#reports" class="bursar-action-btn"><i class="fas fa-file-export"></i> Export Report</a>
    </nav>

    <p class="role-notice">
        <i class="fas fa-shield-halved"></i>
        <span>
            <strong>Role-based access &amp; audit trail:</strong>
            Every approval, payment, lock override, and manual allocation is written to
            <code>bursar_action_audit</code> with timestamp, actor, and reason. Per-case funding
            is capped at <strong>$50,000</strong>; allocations that would exceed the cap are
            blocked by the database.
        </span>
    </p>
</section>
