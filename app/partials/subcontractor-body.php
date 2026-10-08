<?php
/** Body partial generated from app/templates/subcontractor.html.
    Hard-coded sample data is preserved as-is (prototype). */
?>
<section class="portal-page active" id="dashboardPage" data-page-title="Subcontractor Dashboard">

    <!-- Hero: user header + active count -->
    <div class="dash-hero">
        <div>
            <h2>Welcome back, Mike</h2>
            <p>Mike&rsquo;s Plumbing Co. &middot; Trade: Plumbing, Electrical &middot; 5-task limit &middot; Last refreshed today at 8:02 AM</p>
        </div>
        <div class="dash-hero-meta">
            <span class="hero-active-chip"><i class="fas fa-bolt"></i> 2 Active</span>
            <span class="hero-count-label">Open Tasks</span>
            <span class="hero-count">2 / 5</span>
        </div>
    </div>

    <!-- Two-column: Accepted Tasks | Suggested Tasks -->
    <section class="dash-section" aria-label="Tasks">
        <div class="two-col">

            <article class="panel" aria-labelledby="accepted-h">
                <div class="panel-header">
                    <h3 id="accepted-h"><i class="fas fa-clipboard-check"></i> Accepted Tasks <span class="pill pill-amber" style="margin-left:6px;">2</span></h3>
                    <a href="#accepted" class="see-all-link">View all &rarr;</a>
                </div>
                <ul class="task-list">
                    <li class="task-card">
                        <div class="task-card-head">
                            <span class="task-card-job">42-CHERRY</span>
                            <span class="pill pill-amber"><i class="fas fa-clock"></i> In progress</span>
                        </div>
                        <div class="task-card-meta">
                            <span><i class="fas fa-screwdriver-wrench"></i> Plumbing</span>
                            <span><i class="fas fa-calendar-day"></i> Start: Dec 19</span>
                        </div>
                        <div class="task-progress" aria-label="Subtasks 3 of 5 complete">
                            <span>Subtasks</span>
                            <span class="task-progress-bar"><span class="task-progress-fill" style="width:60%"></span></span>
                            <span><strong>3 / 5</strong></span>
                        </div>
                        <div class="task-card-todo">
                            <strong>Todo</strong>
                            Replace sink &middot; Install faucet
                        </div>
                        <div class="task-card-actions">
                            <a href="#status" class="btn btn-primary btn-sm"><i class="fas fa-rotate"></i> Update Status</a>
                            <a href="#task" class="btn btn-secondary btn-sm"><i class="fas fa-eye"></i> View Task</a>
                        </div>
                    </li>
                    <li class="task-card">
                        <div class="task-card-head">
                            <span class="task-card-job">8-OAKLAND</span>
                            <span class="pill pill-blue"><i class="fas fa-flag"></i> Awaiting parts</span>
                        </div>
                        <div class="task-card-meta">
                            <span><i class="fas fa-bolt"></i> Electrical</span>
                            <span><i class="fas fa-calendar-day"></i> Start: Dec 22</span>
                        </div>
                        <div class="task-progress" aria-label="Subtasks 2 of 3 complete">
                            <span>Subtasks</span>
                            <span class="task-progress-bar"><span class="task-progress-fill" style="width:66%"></span></span>
                            <span><strong>2 / 3</strong></span>
                        </div>
                        <div class="task-card-todo">
                            <strong>Todo</strong>
                            Wire new outlet &middot; Install breaker
                        </div>
                        <div class="task-card-actions">
                            <a href="#status" class="btn btn-primary btn-sm"><i class="fas fa-rotate"></i> Update Status</a>
                            <a href="#task" class="btn btn-secondary btn-sm"><i class="fas fa-eye"></i> View Task</a>
                        </div>
                    </li>
                </ul>
            </article>

            <article class="panel" aria-labelledby="suggested-h">
                <div class="panel-header">
                    <h3 id="suggested-h"><i class="fas fa-lightbulb"></i> Suggested Tasks <span class="pill" style="margin-left:6px;">3</span></h3>
                    <a href="#marketplace" class="see-all-link">Open marketplace &rarr;</a>
                </div>
                <ul class="task-list">
                    <li class="task-card is-suggested">
                        <div class="task-card-head">
                            <span class="task-card-job">15-MERRILL</span>
                            <span class="pill pill-blue"><i class="fas fa-droplet"></i> Plumbing</span>
                        </div>
                        <div class="task-card-meta">
                            <span><i class="fas fa-list-check"></i> 0 / 4 subtasks</span>
                            <span><i class="fas fa-clock"></i> Est. 4.5 hrs</span>
                            <span><i class="fas fa-location-dot"></i> 6 mi away</span>
                        </div>
                        <div class="task-card-actions">
                            <a href="#claim" class="btn btn-primary btn-sm"><i class="fas fa-hand"></i> Claim Task</a>
                            <a href="#quote" class="btn btn-secondary btn-sm"><i class="fas fa-file-invoice-dollar"></i> Input Quote</a>
                        </div>
                    </li>
                    <li class="task-card is-suggested">
                        <div class="task-card-head">
                            <span class="task-card-job">23-PARKWAY</span>
                            <span class="pill pill-blue"><i class="fas fa-bolt"></i> Electrical</span>
                        </div>
                        <div class="task-card-meta">
                            <span><i class="fas fa-list-check"></i> 0 / 2 subtasks</span>
                            <span><i class="fas fa-clock"></i> Est. 3.0 hrs</span>
                            <span><i class="fas fa-location-dot"></i> 12 mi away</span>
                        </div>
                        <div class="task-card-actions">
                            <a href="#claim" class="btn btn-primary btn-sm"><i class="fas fa-hand"></i> Claim Task</a>
                            <a href="#quote" class="btn btn-secondary btn-sm"><i class="fas fa-file-invoice-dollar"></i> Input Quote</a>
                        </div>
                    </li>
                    <li class="task-card is-suggested">
                        <div class="task-card-head">
                            <span class="task-card-job">19-RIVERSIDE</span>
                            <span class="pill pill-blue"><i class="fas fa-droplet"></i> Plumbing</span>
                        </div>
                        <div class="task-card-meta">
                            <span><i class="fas fa-list-check"></i> 0 / 3 subtasks</span>
                            <span><i class="fas fa-clock"></i> Est. 6.0 hrs</span>
                            <span><i class="fas fa-location-dot"></i> 3 mi away</span>
                        </div>
                        <div class="task-card-actions">
                            <a href="#claim" class="btn btn-primary btn-sm"><i class="fas fa-hand"></i> Claim Task</a>
                            <a href="#quote" class="btn btn-secondary btn-sm"><i class="fas fa-file-invoice-dollar"></i> Input Quote</a>
                        </div>
                    </li>
                </ul>
            </article>

        </div>
    </section>

    <!-- Messages widget -->
    <section class="dash-section" aria-labelledby="msg-h">
        <div class="section-header-row">
            <h3 class="dash-section-title" id="msg-h" style="margin:0;"><i class="fas fa-comment-dots"></i> Messages <span class="pill pill-amber" style="margin-left:6px;">2 unread</span></h3>
            <a href="#messages" class="see-all-link">View all messages &rarr;</a>
        </div>
        <article class="panel">
            <ul class="msg-list">
                <li class="msg-item is-unread">
                    <span class="msg-dot" aria-hidden="true"></span>
                    <div>
                        <div class="msg-from">Habitat for Humanity</div>
                        <div class="msg-body">&ldquo;Can you provide a quote for 42-CHERRY by Friday?&rdquo;</div>
                    </div>
                    <span class="msg-time">2h ago</span>
                </li>
                <li class="msg-item is-unread">
                    <span class="msg-dot" aria-hidden="true"></span>
                    <div>
                        <div class="msg-from">ARCHR System</div>
                        <div class="msg-body">New task available: 15-MERRILL &middot; Plumbing</div>
                    </div>
                    <span class="msg-time">5h ago</span>
                </li>
                <li class="msg-item">
                    <span class="msg-dot" aria-hidden="true" style="background:var(--color-text-muted);"></span>
                    <div>
                        <div class="msg-from">Sarah (Project Manager)</div>
                        <div class="msg-body">Approved your quote on 8-OAKLAND &mdash; nice work.</div>
                    </div>
                    <span class="msg-time">Yesterday</span>
                </li>
            </ul>
        </article>
    </section>

    <!-- Primary action row (six buttons from the spec) -->
    <nav class="sub-action-row" aria-label="Subcontractor primary actions">
        <a href="#task" class="sub-action-btn"><i class="fas fa-eye"></i> View Task</a>
        <a href="#past-jobs" class="sub-action-btn"><i class="fas fa-clock-rotate-left"></i> Past Jobs</a>
        <a href="#quote" class="sub-action-btn"><i class="fas fa-file-invoice-dollar"></i> Input Quote</a>
        <a href="#schedule" class="sub-action-btn"><i class="fas fa-calendar-plus"></i> Schedule</a>
        <a href="#marketplace" class="sub-action-btn"><i class="fas fa-handshake"></i> Respond</a>
        <a href="#messages" class="sub-action-btn"><i class="fas fa-envelope"></i> Messages</a>
    </nav>

    <!-- Quick Actions: Task Management + Financial -->
    <section class="dash-section" aria-labelledby="quick-h">
        <h3 class="dash-section-title" id="quick-h"><i class="fas fa-bolt"></i> Quick Actions</h3>
        <div class="quick-actions-grid">
            <article class="quick-card">
                <h4><i class="fas fa-screwdriver-wrench"></i> Task Management</h4>
                <ul class="quick-list">
                    <li><a href="#status"><i class="fas fa-rotate"></i> Update Task Status</a></li>
                    <li><a href="#claim"><i class="fas fa-hand"></i> Claim Tasks</a></li>
                    <li><a href="#estimate-date"><i class="fas fa-calendar-day"></i> Set Estimate Date</a></li>
                    <li><a href="#start-date"><i class="fas fa-play"></i> Set Work Start Date</a></li>
                    <li><a href="#finish-date"><i class="fas fa-flag-checkered"></i> Set Work Finish Date</a></li>
                    <li><a href="#after-photos"><i class="fas fa-camera"></i> Upload &lsquo;After Photos&rsquo;</a></li>
                </ul>
            </article>
            <article class="quick-card">
                <h4><i class="fas fa-sack-dollar"></i> Financial</h4>
                <ul class="quick-list">
                    <li><a href="#quote"><i class="fas fa-paper-plane"></i> Send Quote</a></li>
                    <li><a href="#invoice"><i class="fas fa-receipt"></i> Submit Invoice</a></li>
                    <li><a href="#accept"><i class="fas fa-circle-check"></i> Alert Sub Accepted</a></li>
                </ul>
            </article>
        </div>
    </section>

    <p class="role-notice">
        <i class="fas fa-shield-halved"></i>
        <span>
            <strong>Job-centric workspace:</strong>
            You only see tasks that match your trade specialty and tasks you have claimed.
            Active task cap is <strong>5</strong>; quotes are required before claim
            approval. After-photos are encrypted at rest (AES-256) and retained for 7 years
            per ARCHR compliance policy.
        </span>
    </p>
</section>
