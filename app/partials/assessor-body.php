<?php
/** Assessor dashboard body. Receives $data, $u, $s, $la from assessor.php. */
/** @var array $data */
/** @var array $u */
/** @var array $s */
/** @var array $la */
$pillTone = $la['status_pill'][0] ?? 'amber';
?>
<section class="portal-page active" id="dashboardPage" data-page-title="Assessor Dashboard">

    <!-- Hero -->
    <div class="dash-hero">
        <div>
            <h2>Good morning, <?= e(explode(' ', $u['name'])[0]) ?></h2>
            <p><?= e($u['territory']) ?> &middot; <?= e((string)$s['scheduled']) ?> assessments scheduled today
               &middot; <?= e((string)$s['in_progress']) ?> in progress &middot; Last sync <?= e($s['last_sync']) ?></p>
        </div>
        <div class="dash-hero-meta">
            <span class="hero-count-label">Today</span>
            <span class="hero-count"><?= e((string)$s['scheduled']) ?></span>
        </div>
    </div>

    <!-- Last Assessment -->
    <section class="dash-section" aria-labelledby="last-h">
        <h3 class="dash-section-title" id="last-h"><i class="fas fa-house-chimney"></i> Last Assessment</h3>
        <article class="last-assessment">
            <div>
                <div class="la-address"><?= e($la['address']) ?></div>
                <div class="la-row">
                    <span class="la-label">Next Step</span>
                    <span class="la-value"><?= e($la['next_step']) ?></span>
                </div>
                <div class="la-row">
                    <span class="la-label">Holding On</span>
                    <span class="la-value holding"><i class="fas fa-hourglass-half"></i> <?= e($la['holding_on']) ?></span>
                </div>
                <div class="la-row">
                    <span class="la-label">Status</span>
                    <span class="la-value">
                        <span class="pill pill-<?= e($pillTone) ?>"><i class="fas <?= e($la['status_pill'][1]) ?>"></i> <?= e($la['status_pill'][2]) ?></span>
                    </span>
                </div>
            </div>
            <div class="la-actions">
                <a href="#assessmentBuilder" class="btn btn-secondary btn-sm"><i class="fas fa-pen"></i> Edit</a>
                <a href="#assessmentBuilder?resume=true" class="btn btn-primary btn-sm"><i class="fas fa-play"></i> Continue</a>
            </div>
        </article>
    </section>

    <!-- Week calendar -->
    <section class="dash-section" aria-labelledby="cal-h">
        <div class="section-header-row">
            <h3 class="dash-section-title" id="cal-h" style="margin:0;"><i class="fas fa-calendar-week"></i> Assessment Calendar</h3>
            <a href="#schedule" class="see-all-link">Open scheduler &rarr;</a>
        </div>
        <article class="panel">
            <div class="week-cal" role="list" aria-label="This week">
                <?php foreach ($data['week'] as $d): ?>
                    <div class="week-day<?= $d['today'] ? ' is-today' : '' ?>" role="listitem"
                         <?= $d['today'] ? 'aria-current="date"' : '' ?>>
                        <div class="wd-name"><?= e($d['name']) ?></div>
                        <div class="wd-num"><?= e((string)$d['num']) ?></div>
                        <div class="wd-dots">
                            <?php for ($i = 0; $i < (int)$d['count']; $i++): ?>
                                <span class="wd-dot"></span>
                            <?php endfor; ?>
                        </div>
                    </div>
                <?php endforeach; ?>
            </div>
            <p class="week-cal-foot">
                <strong>Today:</strong> <?= e((string)$s['scheduled']) ?> assessments &middot;
                <strong>This week:</strong> <?= e((string)array_sum(array_column($data['week'], 'count'))) ?> total
            </p>
        </article>
    </section>

    <!-- Two-column: Today + Messages -->
    <section class="dash-section">
        <div class="two-col">
            <article class="panel" aria-labelledby="today-h">
                <div class="panel-header">
                    <h3 id="today-h"><i class="fas fa-clipboard-list"></i> Today's Assessments</h3>
                    <a href="#today" class="see-all-link">View all &rarr;</a>
                </div>
                <p style="font-size:var(--fs-sm); color:var(--color-text-muted); margin-bottom:var(--space-3);">
                    <strong><?= e((string)$s['in_progress']) ?> in progress</strong> &middot;
                    <strong><?= e((string)max(0, $s['scheduled'] - $s['in_progress'])) ?> scheduled</strong> &middot;
                    Total drive time ~ <?= e((string)$s['drive_min']) ?> min
                </p>
                <ul class="assess-list">
                    <?php foreach ($data['today'] as $t): ?>
                        <li class="assess-item is-<?= e($t['status']) ?>">
                            <div class="ai-time"><?= e($t['time']) ?></div>
                            <div>
                                <div class="ai-addr"><?= e($t['addr']) ?></div>
                                <div class="ai-meta">
                                    <span><i class="fas fa-stopwatch"></i> <?= e($t['hours']) ?> hours</span>
                                    <span><i class="fas fa-location-dot"></i> <?= e($t['miles']) ?> mi</span>
                                    <span class="pill pill-<?= $t['status'] === 'in_progress' ? 'amber' : 'accent' ?>">
                                        <i class="fas <?= $t['status'] === 'in_progress' ? 'fa-spinner' : 'fa-calendar-check' ?>"></i>
                                        <?= e($t['status_label']) ?>
                                    </span>
                                </div>
                            </div>
                            <div class="ai-actions">
                                <a href="#assessmentBuilder" class="btn btn-secondary btn-sm">
                                    <i class="fas <?= e($t['action_icon']) ?>"></i> <?= e($t['action_label']) ?>
                                </a>
                            </div>
                        </li>
                    <?php endforeach; ?>
                </ul>
            </article>

            <article class="panel" aria-labelledby="msgs-h">
                <div class="panel-header">
                    <h3 id="msgs-h"><i class="fas fa-envelope"></i> Messages</h3>
                    <a href="#messages" class="see-all-link">View all &rarr;</a>
                </div>
                <ul class="msg-list">
                    <?php foreach ($data['messages'] as $m): ?>
                        <li class="msg-item<?= $m['system'] ? ' is-system' : '' ?>">
                            <div class="msg-from">
                                <?= e($m['from']) ?>
                                <?php if ($m['kind']): ?>
                                    <span class="pill" style="margin-left:6px;"><?= e($m['kind']) ?></span>
                                <?php endif; ?>
                            </div>
                            <div class="msg-body"><?= e($m['body']) ?></div>
                            <div class="msg-meta">
                                <span><?= e($m['meta']) ?></span>
                                <a href="#messageDetails" class="btn btn-secondary btn-sm">Read</a>
                            </div>
                        </li>
                    <?php endforeach; ?>
                </ul>
            </article>
        </div>
    </section>

    <!-- Previous Assessments -->
    <section class="dash-section" aria-labelledby="prev-h">
        <div class="section-header-row">
            <h3 class="dash-section-title" id="prev-h" style="margin:0;"><i class="fas fa-clock-rotate-left"></i> Previous Assessments</h3>
            <a href="#previous" class="see-all-link">View all &rarr;</a>
        </div>
        <article class="panel" style="padding:0;">
            <ul class="assess-list" style="padding:var(--space-4); gap:var(--space-2);">
                <?php foreach ($data['previous'] as $p): ?>
                    <li class="assess-item is-<?= $p['state'] === 'completed' ? 'completed' : 'draft' ?>">
                        <div class="ai-time"><?= e($p['date']) ?></div>
                        <div>
                            <div class="ai-addr"><?= e($p['addr']) ?></div>
                            <div class="ai-meta">
                                <span><?= e($p['client']) ?></span>
                                <?php if ($p['photos'] > 0): ?>
                                    <span><i class="fas fa-camera"></i> <?= e((string)$p['photos']) ?> photos</span>
                                <?php else: ?>
                                    <span><i class="fas fa-pen"></i> Draft — needs photos</span>
                                <?php endif; ?>
                                <?php if ($p['state'] === 'completed'): ?>
                                    <span class="pill pill-green"><i class="fas fa-circle-check"></i> Completed</span>
                                <?php else: ?>
                                    <span class="pill pill-amber"><i class="fas fa-pen-to-square"></i> Draft</span>
                                <?php endif; ?>
                            </div>
                        </div>
                        <div class="ai-actions">
                            <a href="#assessmentViewer" class="btn btn-secondary btn-sm">
                                <?= $p['state'] === 'completed' ? 'View' : 'Resubmit' ?>
                            </a>
                        </div>
                    </li>
                <?php endforeach; ?>
            </ul>
        </article>
    </section>

    <!-- 6-Button Action Row -->
    <nav class="assessor-action-row" aria-label="Assessor quick actions">
        <a href="#upcomingAssessmentsList" class="assessor-action-btn"><i class="fas fa-tape"></i> Assess</a>
        <a href="#verifyList" class="assessor-action-btn"><i class="fas fa-check-double"></i> Verify</a>
        <a href="#messageDetails" class="assessor-action-btn"><i class="fas fa-envelope-open"></i> Read Message</a>
        <a href="#schedulingDashboard" class="assessor-action-btn"><i class="fas fa-calendar-plus"></i> Schedule</a>
        <a href="#processList" class="assessor-action-btn"><i class="fas fa-list-check"></i> Process</a>
        <a href="#assessmentBuilder" class="assessor-action-btn"><i class="fas fa-pen"></i> Edit</a>
    </nav>

    <!-- Task Context Groups -->
    <section class="dash-section" aria-labelledby="tasks-h">
        <h3 class="dash-section-title" id="tasks-h"><i class="fas fa-layer-group"></i> Task Context Groups</h3>
        <div class="task-groups">
            <article class="task-group-card">
                <h4><i class="fas fa-clipboard-check"></i> Assessment Actions</h4>
                <ul class="task-action-list">
                    <li><a href="#assessIssue"><i class="fas fa-magnifying-glass"></i> Assess Issue</a></li>
                    <li><a href="#createTasks"><i class="fas fa-list-ul"></i> Create Tasks</a></li>
                    <li><a href="#takeNotes"><i class="fas fa-sticky-note"></i> Take Notes</a></li>
                </ul>
            </article>
            <article class="task-group-card">
                <h4><i class="fas fa-check-double"></i> Document Verification</h4>
                <ul class="task-action-list">
                    <li><a href="#verifyIncome"><i class="fas fa-dollar-sign"></i> Verify Income (POI)</a></li>
                    <li><a href="#verifyOwnership"><i class="fas fa-house"></i> Verify Ownership</a></li>
                    <li><a href="#collectId"><i class="fas fa-id-card"></i> Collect Photo ID</a></li>
                </ul>
            </article>
            <article class="task-group-card">
                <h4><i class="fas fa-comments"></i> Communications</h4>
                <ul class="task-action-list">
                    <li><a href="#commRequestor"><i class="fas fa-user"></i> With Requestor</a></li>
                    <li><a href="#commOrg"><i class="fas fa-building"></i> With Organization</a></li>
                    <li><a href="#scheduleAssessment"><i class="fas fa-calendar-day"></i> Schedule Assessment</a></li>
                </ul>
            </article>
            <article class="task-group-card">
                <h4><i class="fas fa-hard-hat"></i> Subcontractors</h4>
                <ul class="task-action-list">
                    <li><a href="#reviewSub"><i class="fas fa-user-plus"></i> Review New Subcontractor</a></li>
                    <li><a href="#commSub"><i class="fas fa-comment-dots"></i> Communicate with Subcontractor</a></li>
                    <li><a href="#scheduleQuote"><i class="fas fa-file-signature"></i> Schedule Quote</a></li>
                    <li><a href="#attachDocs"><i class="fas fa-paperclip"></i> Attach Quotes &amp; Invoices</a></li>
                </ul>
            </article>
        </div>
    </section>

    <p class="role-notice">
        <i class="fas fa-mobile-screen-button"></i>
        <span>
            <strong>Field-first &amp; offline-capable:</strong>
            This dashboard is the desktop preview of a mobile-first interface.
            Photos, notes, and check-in/out actions cache locally and sync when the
            device reconnects. All document verifications are logged to
            <code>document_verifications</code> with timestamp, GPS, and actor.
        </span>
    </p>
</section>
