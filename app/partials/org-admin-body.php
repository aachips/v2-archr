<?php
/** Body partial for org-admin.php (live data).
 *  Expects: $page, $pageTitles, $orgs, $primaryOrg, $isSuperAdmin, $cases,
 *  $claimedCases, $claimableCases, $activeCases, $completedCases, $exitCases,
 *  $phaseCounts, $recentCases, $events, $notifications, $unreadCount, $team,
 *  $fullName, $firstName. */
$phases = archr_case_phases();
$orgName = $primaryOrg['organization_name'] ?? 'No organization assigned';
$submittedFmt = fn(?string $ts): string => $ts ? date('M j, Y', strtotime($ts)) : '—';

$phasePill = function (array $caseRow) use ($phases): string {
    $info = archr_case_phase($caseRow);
    if ($info['exit'] !== null) {
        return '<span class="pill pill-red">' . e($info['exit_label']) . '</span>';
    }
    $label = 'Phase ' . $info['number'] . ' · ' . $phases[$info['number']]['name'];
    return '<span class="pill phase-pill phase-' . $info['number'] . '">' . e($label) . '</span>';
};

/* Application lifecycle status -> pill (terminology doc Part 2). */
$appStatusPillMap = [
    'new'        => ['pill-blue', 'New'],
    'active'     => ['pill-green', 'Active'],
    'concluded'  => ['pill-green', 'Concluded'],
    'terminated' => ['pill-red', 'Terminated'],
    'withdrawn'  => ['pill-amber', 'Withdrawn'],
    'expired'    => ['pill-amber', 'Expired'],
];

/* 90-day claim window badge for the row. */
$claimWindowPill = function (array $c): string {
    if (($c['claim_status'] ?? null) === 'active' && $c['days_until_expiry'] !== null) {
        $days = (int)$c['days_until_expiry'];
        $cls = $days <= 7 ? 'pill-red' : ($days <= 30 ? 'pill-amber' : 'pill-green');
        return '<span class="pill ' . $cls . '" title="Days left in the 90-day progress window">'
             . $days . 'd left</span>';
    }
    return match ($c['claim_status'] ?? null) {
        'expired'  => '<span class="pill pill-amber">Claim expired</span>',
        'released' => '<span class="pill">Released</span>',
        default    => '<span class="pill pill-blue">Awaiting claim</span>',
    };
};

$caseRow = function (array $c) use ($submittedFmt, $phasePill, $appStatusPillMap, $claimWindowPill): void {
    $reviewUrl = $c['case_id']
        ? 'case.php?id=' . (int)$c['case_id']
        : 'case.php?submission_id=' . (int)$c['submission_id'];
    $name = trim((string)($c['display_name'] ?? ''));
    $appStatus = strtolower((string)($c['application_status'] ?? ''));
    [$pillCls, $pillLabel] = $appStatusPillMap[$appStatus] ?? ['', ''];
    ?>
    <tr>
        <td>
            <a href="<?= e($reviewUrl) ?>"><?= e($name !== '' ? $name : ($c['case_number'] ?: 'Application #' . (int)$c['submission_id'])) ?><?php if ($name !== '' && !empty($c['case_number'])): ?><br><span class="muted"><?= e($c['case_number']) ?></span><?php endif; ?></a>
        </td>
        <td><a href="<?= e($reviewUrl) ?>"><?= e($c['applicant_first_name'] . ' ' . $c['applicant_last_name']) ?></a></td>
        <td><a href="<?= e($reviewUrl) ?>"><?= e($c['home_city'] ?? '—') ?></a></td>
        <td><a href="<?= e($reviewUrl) ?>"><?= e($c['organization_name'] ?? 'Unclaimed') ?></a></td>
        <td><a href="<?= e($reviewUrl) ?>"><?php if ($pillLabel !== ''): ?><span class="pill <?= e($pillCls) ?>"><?= e($pillLabel) ?></span><?php else: ?><span class="pill"><?= e($c['status_name'] ?? ucfirst((string)($c['submission_status'] ?? 'pending'))) ?></span><?php endif; ?></a></td>
        <td><a href="<?= e($reviewUrl) ?>"><?= $phasePill($c) ?></a></td>
        <td><a href="<?= e($reviewUrl) ?>"><?= $claimWindowPill($c) ?></a></td>
        <td><a href="<?= e($reviewUrl) ?>"><?= e($submittedFmt($c['submitted_at'])) ?></a></td>
        <td><a href="<?= e($reviewUrl) ?>" class="btn btn-sm btn-secondary">Review</a></td>
    </tr>
    <?php
};
?>
<section class="portal-page active" data-page-title="<?= e($pageTitles[$page] ?? 'Dashboard') ?>">
    <p class="login-banner" role="status">
        <i class="fas fa-user-shield"></i>
        <span>Organization admin view &mdash; <?= e($orgName) ?>. You can act on any case within your organization.</span>
    </p>

<?php if ($page === 'dashboard'): ?>
    <section class="dash-hero" aria-labelledby="dash-title">
        <div>
            <h2 id="dash-title">Welcome back, <?= e($firstName) ?></h2>
            <p><?= e($orgName) ?> &middot; <?= count($activeCases) ?> active case(s) &middot; <?= count($claimableCases) ?> awaiting claim<?= $expiringClaims ? ' &middot; <strong>' . count($expiringClaims) . ' claim(s) expiring soon</strong>' : '' ?>.</p>
        </div>
        <div class="dash-hero-meta">
            <span class="org-badge"><i class="fas fa-building"></i> <?= e($orgName) ?></span>
            <a href="case-search.php" class="btn btn-secondary"><i class="fas fa-magnifying-glass"></i> Case Search</a>
        </div>
    </section>

    <section aria-labelledby="oa-metrics-h">
        <h3 class="dash-section-title" id="oa-metrics-h"><i class="fas fa-list-check"></i> Case Overview</h3>
        <div class="task-metrics">
            <div class="task-metric-card">
                <div class="metric-icon"><i class="fas fa-folder-open"></i></div>
                <div class="metric-number"><?= count($activeCases) ?></div>
                <div class="metric-label">Active Cases</div>
                <a href="org-admin.php?page=applications" class="metric-btn">View <i class="fas fa-arrow-right"></i></a>
            </div>
            <div class="task-metric-card">
                <div class="metric-icon"><i class="fas fa-hand-pointer"></i></div>
                <div class="metric-number"><?= count($claimableCases) ?></div>
                <div class="metric-label">Awaiting Claim</div>
                <a href="org-admin.php?page=applications" class="metric-btn">Claim <i class="fas fa-arrow-right"></i></a>
            </div>
            <div class="task-metric-card">
                <div class="metric-icon"><i class="fas fa-check-double"></i></div>
                <div class="metric-number"><?= count($completedCases) ?></div>
                <div class="metric-label">Completed</div>
                <a href="org-admin.php?page=metrics" class="metric-btn">Metrics <i class="fas fa-arrow-right"></i></a>
            </div>
            <div class="task-metric-card">
                <div class="metric-icon"><i class="fas fa-hourglass-half"></i></div>
                <div class="metric-number"><?= count($expiringClaims) ?></div>
                <div class="metric-label">Claims expiring &le; 14 days</div>
                <a href="org-admin.php?page=applications" class="metric-btn">Review <i class="fas fa-arrow-right"></i></a>
            </div>
            <div class="task-metric-card">
                <div class="metric-icon"><i class="fas fa-envelope"></i></div>
                <div class="metric-number"><?= (int)$unreadCount ?></div>
                <div class="metric-label">Unread Messages</div>
                <a href="org-admin.php?page=messages" class="metric-btn">Read <i class="fas fa-arrow-right"></i></a>
            </div>
        </div>
    </section>

    <section aria-labelledby="oa-recent-h">
        <div class="section-header-row">
            <h3 class="dash-section-title" id="oa-recent-h" style="margin:0;"><i class="fas fa-clock"></i> Recent Applications</h3>
            <a href="org-admin.php?page=applications" class="see-all-link">View all &rarr;</a>
        </div>
        <div class="table-wrap">
            <table class="data-table case-list-table case-list-table-linked">
                <thead>
                    <tr><th>Application</th><th>Applicant</th><th>City</th><th>Claimed org</th><th>App status</th><th>Phase</th><th>Claim window</th><th>Submitted</th><th></th></tr>
                </thead>
                <tbody>
                    <?php if ($recentCases): foreach ($recentCases as $c): $caseRow($c); endforeach; else: ?>
                        <tr><td colspan="9" class="muted">No applications for your organization yet.</td></tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </section>

    <section class="events-messages-grid" aria-label="Recent activity">
        <article class="panel" aria-labelledby="oa-events-h">
            <div class="panel-header"><h3 id="oa-events-h"><i class="fas fa-history"></i> Latest Events</h3></div>
            <div class="events-list">
                <?php if ($events): foreach ($events as $ev): ?>
                    <div class="event-item">
                        <div class="event-icon"><i class="fas fa-circle-info"></i></div>
                        <div class="event-content">
                            <div class="event-title"><?= e($ev['to_status'] ?? 'Update') ?> &mdash; <?= e($ev['case_number'] ?? '') ?></div>
                            <div class="event-meta">
                                <?= e(date('M j, Y g:i A', strtotime($ev['changed_at']))) ?>
                                <?php if ($ev['changed_by_name']): ?> &middot; <?= e($ev['changed_by_name']) ?><?php endif; ?>
                                <?php if ($ev['notes']): ?><br><?= e($ev['notes']) ?><?php endif; ?>
                            </div>
                        </div>
                    </div>
                <?php endforeach; else: ?>
                    <p class="muted">No events yet for your organization's cases.</p>
                <?php endif; ?>
            </div>
        </article>

        <article class="panel" aria-labelledby="oa-msgs-h">
            <div class="panel-header">
                <h3 id="oa-msgs-h"><i class="fas fa-envelope"></i> Latest Messages</h3>
                <a href="org-admin.php?page=messages" class="see-all-link">View all &rarr;</a>
            </div>
            <ul class="message-list">
                <?php $preview = array_slice($notifications, 0, 4); ?>
                <?php if ($preview): foreach ($preview as $n): ?>
                    <li class="message-item<?= $n['is_read'] ? '' : ' unread' ?>">
                        <strong><?= e($n['title']) ?></strong> &mdash; <?= e($n['body'] ?? '') ?>
                        <div class="message-meta"><a href="org-admin.php?page=messages" class="btn btn-secondary btn-sm">Open Messages</a></div>
                    </li>
                <?php endforeach; else: ?>
                    <li class="message-item">No messages yet.</li>
                <?php endif; ?>
            </ul>
        </article>
    </section>
<?php endif; ?>

<?php if ($page === 'applications'): ?>
    <section class="dash-section active" aria-labelledby="oa-claimable-h">
        <h3 class="dash-section-title" id="oa-claimable-h"><i class="fas fa-hand-pointer"></i> Claimable Applications</h3>
        <p class="muted">Applications your organization can claim — unclaimed ones, and expired ones whose previous claim lapsed after 90 days without progress. Open one to review the full Repairs Needed list and claim it — in whole or per repair — for <?= e($orgName) ?>. Claiming starts a 90-day progress window: log progress (a task, note, or document) to keep the claim alive.</p>
        <div class="table-wrap">
            <table class="data-table case-list-table case-list-table-linked">
                <thead>
                    <tr><th>Application</th><th>Applicant</th><th>City</th><th>Claimed org</th><th>App status</th><th>Phase</th><th>Claim window</th><th>Submitted</th><th></th></tr>
                </thead>
                <tbody>
                    <?php if ($claimableCases): foreach ($claimableCases as $c): $caseRow($c); endforeach; else: ?>
                        <tr><td colspan="9" class="muted">No unclaimed applications right now.</td></tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </section>

    <section class="dash-section active" aria-labelledby="oa-org-cases-h">
        <h3 class="dash-section-title" id="oa-org-cases-h"><i class="fas fa-building"></i> <?= e($orgName) ?> Cases</h3>
        <div class="table-wrap">
            <table class="data-table case-list-table case-list-table-linked">
                <thead>
                    <tr><th>Application</th><th>Applicant</th><th>City</th><th>Claimed org</th><th>App status</th><th>Phase</th><th>Claim window</th><th>Submitted</th><th></th></tr>
                </thead>
                <tbody>
                    <?php if ($claimedCases): foreach ($claimedCases as $c): $caseRow($c); endforeach; else: ?>
                        <tr><td colspan="9" class="muted">Your organization has not claimed any cases yet.</td></tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </section>
<?php endif; ?>

<?php if ($page === 'team'): ?>
    <section class="dash-section active" aria-labelledby="oa-team-h">
        <h3 class="dash-section-title" id="oa-team-h"><i class="fas fa-users"></i> Team</h3>
        <p class="muted">Staff with an active role assignment in your organization. New accounts are created by the Super-Administrator.</p>
        <div class="table-wrap">
            <table class="data-table">
                <thead><tr><th>Name</th><th>Roles</th><th>Organization</th><th>Email</th><th>Phone</th><th>Last login</th><th>Status</th></tr></thead>
                <tbody>
                    <?php if ($team): foreach ($team as $m): ?>
                        <tr>
                            <td><?= e($m['full_name']) ?></td>
                            <td><?= e($m['roles'] ?? '—') ?></td>
                            <td><?= e($m['organization_name']) ?></td>
                            <td><?= e($m['email']) ?></td>
                            <td><?= e($m['phone'] ?? '—') ?></td>
                            <td><?= $m['last_login'] ? e(date('M j, Y', strtotime($m['last_login']))) : 'Never' ?></td>
                            <td><span class="pill <?= $m['is_active'] ? 'pill-green' : 'pill-amber' ?>"><?= $m['is_active'] ? 'Active' : 'Inactive' ?></span></td>
                        </tr>
                    <?php endforeach; else: ?>
                        <tr><td colspan="7" class="muted">No staff found for your organization.</td></tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </section>
<?php endif; ?>

<?php if ($page === 'messages'): ?>
    <section class="dash-section active" aria-labelledby="oa-messages-h">
        <div class="section-header-row">
            <h3 class="dash-section-title" id="oa-messages-h" style="margin:0;"><i class="fas fa-envelope"></i> Messages &amp; Notifications</h3>
            <?php if ($unreadCount): ?>
                <button type="button" class="btn btn-secondary btn-sm" id="mark-all-read">Mark all read</button>
            <?php endif; ?>
        </div>
        <p class="muted">Case events that involve your organization. These are dashboard records — applicants are always contacted by a person, never a do-not-reply address.</p>
        <ul class="message-list">
            <?php if ($notifications): foreach ($notifications as $n): ?>
                <li class="message-item<?= $n['is_read'] ? '' : ' unread' ?>">
                    <strong><?= e($n['title']) ?></strong>
                    <?php if (!$n['is_read']): ?><span class="pill pill-amber">New</span><?php endif; ?>
                    <?php if ($n['body']): ?> &mdash; <?= e($n['body']) ?><?php endif; ?>
                    <div class="message-meta">
                        <?= e(date('M j, Y g:i A', strtotime($n['created_at']))) ?>
                        <?php if ($n['entity_type'] === 'case' && $n['entity_id']): ?>
                            &middot; <a href="case.php?id=<?= (int)$n['entity_id'] ?>">Open case</a>
                        <?php endif; ?>
                    </div>
                </li>
            <?php endforeach; else: ?>
                <li class="message-item">No messages yet.</li>
            <?php endif; ?>
        </ul>
    </section>

    <script>
    (function () {
        const btn = document.getElementById('mark-all-read');
        if (!btn) return;
        btn.addEventListener('click', async () => {
            const form = new FormData();
            form.append('action', 'mark_notifications_read');
            const res = await fetch('api/org-admin.php', { method: 'POST', body: form });
            const json = await res.json().catch(() => ({}));
            if (json.success) location.reload(); else alert(json.error || 'Request failed.');
        });
    })();
    </script>
<?php endif; ?>

<?php if ($page === 'metrics'): ?>
    <section class="dash-section active" aria-labelledby="oa-metrics2-h">
        <h3 class="dash-section-title" id="oa-metrics2-h"><i class="fas fa-chart-line"></i> <?= e($orgName) ?> Metrics</h3>
        <div class="kpi-grid">
            <div class="kpi"><span class="kpi-label">Active Cases</span><span class="kpi-value"><?= count($activeCases) ?></span></div>
            <div class="kpi kpi-blue"><span class="kpi-label">Awaiting Claim</span><span class="kpi-value"><?= count($claimableCases) ?></span></div>
            <div class="kpi kpi-green"><span class="kpi-label">Completed</span><span class="kpi-value"><?= count($completedCases) ?></span></div>
            <div class="kpi kpi-amber"><span class="kpi-label">Withdrawn / Denied</span><span class="kpi-value"><?= count($exitCases) ?></span></div>
        </div>
    </section>

    <section class="dash-section active" aria-labelledby="oa-phase-h">
        <h3 class="dash-section-title" id="oa-phase-h"><i class="fas fa-diagram-project"></i> Active Cases by Pipeline Phase</h3>
        <ol class="phase-metrics">
            <?php foreach ($phases as $num => $def): ?>
                <li class="phase-metric-row">
                    <span class="phase-num phase-<?= (int)$num ?>"><?= (int)$num ?></span>
                    <span class="phase-metric-name" title="<?= e($def['description']) ?>"><?= e($def['full_name']) ?></span>
                    <span class="phase-metric-count"><?= (int)$phaseCounts[$num] ?> case(s)</span>
                </li>
            <?php endforeach; ?>
        </ol>
    </section>
<?php endif; ?>

<?php if ($page === 'help'): ?>
    <section class="dash-section active" aria-labelledby="oa-help-h">
        <h3 class="dash-section-title" id="oa-help-h"><i class="fas fa-circle-question"></i> Help</h3>
        <div class="panel" style="padding:1rem;">
            <h4>What you can do here</h4>
            <ul class="plain-list">
                <li><strong>Applications</strong> — review submitted applications and claim them for your organization, in whole or per repair need. Several organizations can hold cases on the same application over different repairs.</li>
                <li><strong>Case Review</strong> — full case details, the six-phase progress tracker, repair claims, termination (with reason checkboxes), and (with applicant confirmation) withdrawal.</li>
                <li><strong>Team</strong> — see who in your organization has access. New accounts are created by the Super-Administrator.</li>
                <li><strong>Messages</strong> — case events involving your organization.</li>
            </ul>
            <h4>The 90-day progress window</h4>
            <p class="muted">Every claim carries a 90-day window. Any logged progress — a task, communication, document, or milestone — resets it. If 90 days pass with no progress, the claim expires and the application becomes available for other organizations to claim.</p>
            <h4>Consequential actions</h4>
            <p class="muted">Claiming creates your organization's case on an application and notifies the coalition. Terminating requires at least one reason checkbox and is a human decision — the system never denies anyone automatically. Withdrawing an application is only allowed after you have confirmed directly with the applicant (phone, in person, or in writing) — never through automated messages. All three are recorded in the immutable case ledger.</p>
            <h4>Support</h4>
            <p class="muted">For access issues or corrections, contact your ARCHR Super-Administrator.</p>
        </div>
    </section>
<?php endif; ?>

<?php if ($page === 'documents'): ?>
    <section class="dash-section active" aria-labelledby="oa-docs-h">
        <div class="section-header-row">
            <h3 class="dash-section-title" id="oa-docs-h" style="margin:0;"><i class="fas fa-bucket"></i> Documents Bucket</h3>
            <div class="bucket-view-toggle" role="group" aria-label="View mode">
                <button type="button" class="btn btn-secondary btn-sm bucket-view-btn is-active" data-view="rows"><i class="fas fa-list"></i> Rows</button>
                <button type="button" class="btn btn-secondary btn-sm bucket-view-btn" data-view="grid"><i class="fas fa-grip"></i> Icons</button>
            </div>
        </div>

        <?php
        // Dropbox connect panel: super admins only, shown until a refresh
        // token exists (a static access token works but expires in hours).
        $dropboxHasRefresh = (bool)getenv('DROPBOX_REFRESH_TOKEN');
        $dropboxHasAppPair = (bool)(getenv('DROPBOX_APP_KEY') && getenv('DROPBOX_APP_SECRET'));
        ?>
        <?php if ($isSuperAdmin && !$dropboxHasRefresh): ?>
            <div class="panel bucket-connect" id="dropboxConnect" style="margin-bottom: var(--space-4);">
                <h4 style="margin:0 0 var(--space-2);"><i class="fab fa-dropbox"></i> Connect Dropbox Business</h4>
                <?php if (!$dropboxHasAppPair): ?>
                    <p class="muted" style="margin:0;">Set <code>DROPBOX_APP_KEY</code> and <code>DROPBOX_APP_SECRET</code> in the secure config first, then reload this page.</p>
                <?php else: ?>
                    <ol class="bucket-connect-steps">
                        <li><a href="<?= e(archr_dropbox_authorize_url()) ?>" target="_blank" rel="noopener">Authorize ARCHR on Dropbox</a> (offline access — this is what issues a refresh token).</li>
                        <li>Paste the authorization code Dropbox gives you:
                            <span class="bucket-connect-row">
                                <input type="text" id="dropboxCode" class="review-comment" style="max-width: 360px;" placeholder="Authorization code" autocomplete="off">
                                <button type="button" class="btn btn-accent btn-sm" id="dropboxExchangeBtn"><i class="fas fa-plug"></i> Connect</button>
                            </span>
                        </li>
                    </ol>
                    <div id="dropboxConnectResult" style="display:none;">
                        <p class="bucket-connected" style="margin-bottom: var(--space-2);"><i class="fas fa-circle-check"></i> Connected. Save this refresh token in <code>secure_config/archr_connect.php</code> as <code>DROPBOX_REFRESH_TOKEN</code> — it is shown once and never stored by the app:</p>
                        <div class="bucket-connect-row">
                            <input type="text" id="dropboxRefreshToken" class="review-comment" readonly onclick="this.select()">
                            <button type="button" class="btn btn-secondary btn-sm" id="dropboxCopyBtn"><i class="fas fa-copy"></i> Copy</button>
                        </div>
                        <p class="muted" style="margin-top: var(--space-2);">Then reload this page — the Bucket will browse the live drive.</p>
                    </div>
                    <p class="muted" id="dropboxConnectStatus" role="status" style="margin: var(--space-2) 0 0;"></p>
                <?php endif; ?>
            </div>
        <?php endif; ?>
        <?php if ($driveMode === 'dropbox'): ?>
            <?php if ($driveAccount !== null): ?>
                <p class="bucket-connected" role="status">
                    <i class="fas fa-circle-check"></i>
                    Connected to <strong><?= e($driveAccount['name']) ?></strong><?= $driveAccount['team'] !== '' ? ' · ' . e($driveAccount['team']) : '' ?><?= $driveAccount['email'] !== '' ? ' (' . e($driveAccount['email']) . ')' : '' ?> — showing the live Dropbox drive.
                </p>
            <?php endif; ?>
            <?php if ($driveError !== null): ?>
                <p class="role-notice" style="background:#fbe7e3; border-color:#f0c6bd; color:#8a2818;"><i class="fas fa-triangle-exclamation"></i>
                    <span><?= e($driveError) ?></span></p>
            <?php endif; ?>
        <?php else: ?>
            <p class="muted" style="margin-bottom: var(--space-4);">
                No storage provider connected yet — showing the local document tree. Add Dropbox credentials
                (<code>DROPBOX_APP_KEY</code>, <code>DROPBOX_APP_SECRET</code>, <code>DROPBOX_REFRESH_TOKEN</code>
                or <code>DROPBOX_ACCESS_TOKEN</code>) to the secure config to browse the live drive here.
                <?php if ($bucketSample): ?>
                    <span class="pill pill-amber"><i class="fas fa-flask"></i> Sample data</span> — document tables not deployed; showing a demo drive.
                <?php endif; ?>
            </p>
        <?php endif; ?>

        <?php $segments = array_values(array_filter(explode('/', (string)$bucketPath), fn($p) => $p !== '')); ?>
        <nav class="bucket-crumbs" aria-label="Drive path">
            <a href="org-admin.php?page=documents" class="crumb"><i class="fas fa-hard-drive"></i> The Bucket</a>
            <?php $crumbPath = ''; foreach ($segments as $seg): $crumbPath .= ($crumbPath === '' ? '' : '/') . $seg; ?>
                <span class="crumb-sep">/</span>
                <a href="org-admin.php?page=documents&path=<?= e(rawurlencode($crumbPath)) ?>" class="crumb"><?= e($seg) ?></a>
            <?php endforeach; ?>
        </nav>

        <?php if ($driveMode === 'dropbox'): ?>
            <div class="panel bucket-panel view-rows" id="bucketPanel">
                <?php
                $driveFolders = array_values(array_filter($driveEntries, fn($e) => $e['tag'] === 'folder'));
                $driveFiles = array_values(array_filter($driveEntries, fn($e) => $e['tag'] === 'file'));
                usort($driveFolders, fn($a, $b) => strcasecmp($a['name'], $b['name']));
                usort($driveFiles, fn($a, $b) => strcasecmp($a['name'], $b['name']));
                ?>
                <?php if ($driveError === null && !$driveFolders && !$driveFiles): ?>
                    <p class="empty-state">This folder is empty.</p>
                <?php endif; ?>
                <?php if ($driveFolders): ?>
                    <ul class="bucket-list">
                        <?php foreach ($driveFolders as $f): ?>
                            <li class="bucket-row is-folder">
                                <a class="bucket-link" href="org-admin.php?page=documents&path=<?= e(rawurlencode($f['path'])) ?>">
                                    <span class="bucket-icon"><i class="fas fa-folder"></i></span>
                                    <span class="bucket-name"><?= e($f['name']) ?></span>
                                    <span class="bucket-meta muted">folder</span>
                                </a>
                            </li>
                        <?php endforeach; ?>
                    </ul>
                <?php endif; ?>
                <?php if ($driveFiles): ?>
                    <ul class="bucket-list">
                        <?php foreach ($driveFiles as $f): ?>
                            <li class="bucket-row is-file">
                                <span class="bucket-icon"><i class="fas <?= e(archr_doc_icon('', (string)$f['name'])) ?>"></i></span>
                                <span class="bucket-name"><code><?= e($f['name']) ?></code></span>
                                <span class="bucket-meta muted"><?= e(trim(($f['size'] ?? '') . ' · ' . ($f['modified'] ?? ''), ' ·')) ?></span>
                                <span class="bucket-actions">
                                    <a class="btn btn-secondary btn-sm" href="api/documents.php?action=dropbox_open&path=<?= e(rawurlencode($f['path'])) ?>" target="_blank" rel="noopener"><i class="fas fa-eye"></i> View</a>
                                </span>
                            </li>
                        <?php endforeach; ?>
                    </ul>
                <?php endif; ?>
            </div>
        <?php else: ?>
        <div class="panel bucket-panel view-rows" id="bucketPanel">
            <?php $folderCount = count($bucketNode['folders']); $fileCount = count($bucketNode['files']); ?>
            <?php if ($folderCount === 0 && $fileCount === 0): ?>
                <p class="empty-state">This folder is empty.</p>
            <?php endif; ?>

            <?php if ($folderCount > 0): ?>
                <ul class="bucket-list">
                    <?php foreach ($bucketNode['folders'] as $name => $child): ?>
                        <?php
                        $childPath = ($bucketPath === '' ? '' : $bucketPath . '/') . $name;
                        $subCount = count($child['folders']) + count($child['files']);
                        $icon = $child['icon'] ?? 'fa-folder';
                        ?>
                        <li class="bucket-row is-folder">
                            <a class="bucket-link" href="org-admin.php?page=documents&path=<?= e(rawurlencode($childPath)) ?>">
                                <span class="bucket-icon"><i class="fas <?= e($icon) ?>"></i></span>
                                <span class="bucket-name"><?= e($child['label'] ?? $name) ?></span>
                                <span class="bucket-meta muted"><?= $subCount ?> item<?= $subCount === 1 ? '' : 's' ?></span>
                            </a>
                        </li>
                    <?php endforeach; ?>
                </ul>
            <?php endif; ?>

            <?php if ($fileCount > 0): ?>
                <ul class="bucket-list">
                    <?php foreach ($bucketNode['files'] as $doc): [$pillCls, $pillIcon, $pillLabel] = archr_doc_status($doc); ?>
                        <li class="bucket-row is-file">
                            <span class="bucket-icon"><i class="fas <?= e($doc['icon']) ?>"></i></span>
                            <span class="bucket-name"><code><?= e($doc['name']) ?></code></span>
                            <span class="pill <?= e($pillCls) ?> bucket-status"><i class="fas <?= e($pillIcon) ?>"></i> <?= e($pillLabel) ?></span>
                            <span class="bucket-meta muted"><?= e($doc['meta'] ?? '') ?></span>
                            <span class="bucket-actions">
                                <?php if ((int)($doc['id'] ?? 0) > 0): ?>
                                    <a class="btn btn-secondary btn-sm" href="api/documents.php?action=download&document_id=<?= (int)$doc['id'] ?>" target="_blank" rel="noopener"><i class="fas fa-eye"></i> View</a>
                                <?php else: ?>
                                    <button type="button" class="btn btn-secondary btn-sm" data-demo><i class="fas fa-eye"></i> View</button>
                                <?php endif; ?>
                            </span>
                        </li>
                    <?php endforeach; ?>
                </ul>
            <?php endif; ?>
        </div>
        <?php endif; ?>
    </section>

    <script>
    (function(){
        var panel = document.getElementById('bucketPanel');
        document.querySelectorAll('.bucket-view-btn').forEach(function(btn){
            btn.addEventListener('click', function(){
                document.querySelectorAll('.bucket-view-btn').forEach(function(b){ b.classList.remove('is-active'); });
                btn.classList.add('is-active');
                panel.classList.toggle('view-grid', btn.getAttribute('data-view') === 'grid');
                panel.classList.toggle('view-rows', btn.getAttribute('data-view') !== 'grid');
            });
        });
        document.querySelectorAll('[data-demo]').forEach(function(b){
            b.addEventListener('click', function(){ alert('Sample data mode — deploy the document tables to open real files.'); });
        });

        // Dropbox connect: exchange the authorization code for a refresh token.
        var exBtn = document.getElementById('dropboxExchangeBtn');
        if (exBtn) {
            var codeInput = document.getElementById('dropboxCode');
            var status = document.getElementById('dropboxConnectStatus');
            var result = document.getElementById('dropboxConnectResult');
            exBtn.addEventListener('click', function(){
                var code = codeInput.value.trim();
                if (!code) { status.textContent = 'Paste the authorization code first.'; return; }
                exBtn.disabled = true;
                status.textContent = 'Exchanging…';
                fetch('api/documents.php', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: new URLSearchParams({ action: 'dropbox_exchange', code: code })
                })
                .then(function(r){ return r.json(); })
                .then(function(res){
                    exBtn.disabled = false;
                    if (res && res.success && res.refresh_token) {
                        document.getElementById('dropboxRefreshToken').value = res.refresh_token;
                        result.style.display = '';
                        status.textContent = '';
                    } else {
                        status.textContent = (res && res.error) ? res.error : 'Exchange failed.';
                    }
                })
                .catch(function(){ exBtn.disabled = false; status.textContent = 'Network error — please try again.'; });
            });
            var copyBtn = document.getElementById('dropboxCopyBtn');
            copyBtn.addEventListener('click', function(){
                var t = document.getElementById('dropboxRefreshToken');
                t.select();
                navigator.clipboard && navigator.clipboard.writeText(t.value);
                copyBtn.textContent = 'Copied';
            });
        }
    })();
    </script>
<?php endif; ?>
</section><!-- /.portal-page -->
