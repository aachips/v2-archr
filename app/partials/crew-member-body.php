<?php
/** Body partial generated from app/templates/crew-member.html.
    Hard-coded sample data is preserved as-is (prototype). */
?>
<section class="portal-page active" id="dashboardPage" data-page-title="Crew Member Dashboard">

    <!-- Hero: welcome + today's conditions (otg-project.md header) -->
    <div class="dash-hero mobile-show">
        <div>
            <h2>Welcome back, Alex</h2>
            <p>Tue, Dec 19 &middot; Partly Cloudy 48&deg;F &middot; Assigned to <strong>42-CHERRY</strong> &middot; Lead: <strong>Mike</strong></p>
        </div>
        <div class="dash-hero-meta">
            <span class="hero-count-label">My Tasks</span>
            <span class="hero-count">3</span>
        </div>
    </div>

    <!-- Battle-mode action bar: the 4 things a Crew Member does most on-site.
         Mark Task Done, Take Photo, Clock In/Out, Acknowledge Safety. -->
    <section class="battle-bar mobile-show" aria-label="Quick on-site actions">
        <a href="#tasks" class="battle-btn"><i class="fas fa-circle-check"></i> Mark Done</a>
        <a href="#photos" class="battle-btn"><i class="fas fa-camera"></i> Take Photo</a>
        <a href="#hours" class="battle-btn"><i class="fas fa-clock"></i> Clock In</a>
        <a href="#safetyTalk" class="battle-btn"><i class="fas fa-shield-halved"></i> Safety</a>
    </section>

    <!-- Mobile-only hint: points to the hamburger drawer + bottom nav -->
    <p class="mobile-hint mobile-show" role="note">
        <i class="fas fa-circle-info" aria-hidden="true"></i>
        <span>Tap <i class="fas fa-bars" aria-hidden="true"></i> for incident reports, daily log, handbook &amp; more.</span>
    </p>

    <!-- KPI strip: self-only metrics per the comparison table. -->
    <section class="dash-section" aria-labelledby="kpi-h">
        <h3 class="dash-section-title" id="kpi-h"><i class="fas fa-chart-pie"></i> My Day</h3>
        <div class="kpi-grid">
            <div class="kpi kpi-tasks">
                <span class="kpi-label">My Tasks</span>
                <span class="kpi-value">3</span>
                <span class="kpi-sub">1 done &middot; 1 in progress &middot; 1 pending</span>
                <span class="kpi-foot"><a href="#tasks">Open list &rarr;</a></span>
            </div>
            <div class="kpi kpi-hours">
                <span class="kpi-label">Hours Today</span>
                <span class="kpi-value">2:18</span>
                <span class="kpi-sub">clocked in at 7:42 AM</span>
                <span class="kpi-foot"><a href="#hours">Clock out &rarr;</a></span>
            </div>
            <div class="kpi kpi-jobs">
                <span class="kpi-label">Active Job</span>
                <span class="kpi-value">1</span>
                <span class="kpi-sub">42-CHERRY &middot; Roof repair</span>
                <span class="kpi-foot"><a href="#currentJob">Open job &rarr;</a></span>
            </div>
            <div class="kpi kpi-photos">
                <span class="kpi-label">Photos Uploaded</span>
                <span class="kpi-value">4</span>
                <span class="kpi-sub">of my work today</span>
                <span class="kpi-foot"><a href="#photos">Add more &rarr;</a></span>
            </div>
        </div>
    </section>

    <!-- Current Job: read-only meta + only OWN tasks are tap-completable.
         Per comparison table: Crew Member can update their own tasks,
         upload limited photos. No phase change, no completion sign-off. -->
    <section class="dash-section" id="currentJob" aria-labelledby="cur-h">
        <div class="section-header-row">
            <h3 class="dash-section-title" id="cur-h" style="margin:0;"><i class="fas fa-helmet-safety"></i> Current Job</h3>
            <a href="#tasks" class="see-all-link">All my tasks &rarr;</a>
        </div>
        <article class="current-job">
            <div class="current-job-head">
                <div>
                    <span class="case-id">42-CHERRY</span>
                    <span class="case-scope">&middot; Roof Repair &middot; 42 Cherry St</span>
                </div>
                <span class="lead-card"><span class="lead-avatar">M</span> Lead: Mike &middot; <a href="tel:8285550123" style="color:inherit;">(828) 555-0123</a></span>
            </div>
            <div class="current-job-meta">
                <span><i class="fas fa-cloud-sun"></i> Outdoor &middot; 48&deg;F</span>
                <span><i class="fas fa-clock"></i> 4h est. remaining</span>
                <span class="progress-cell" style="display:inline-flex; align-items:center; gap:8px;">
                    <span class="meter" aria-hidden="true"><span class="meter-fill" style="width:65%;"></span></span>
                    <strong style="color:var(--color-text);">65%</strong>
                    <span>&middot; job overall</span>
                </span>
            </div>

            <ul class="task-row-list" aria-label="Tasks on 42-CHERRY (yours highlighted)">
                <li class="task-row is-mine is-done" data-task="shingles-remove" data-mine="1">
                    <button type="button" class="task-check" aria-label="Toggle task complete" aria-pressed="true"><i class="fas fa-check"></i></button>
                    <div>
                        <div class="task-title">Remove damaged shingles <span class="pill pill-orange" style="margin-left:6px;">Mine</span></div>
                        <div class="task-meta">
                            <span><i class="fas fa-clock"></i> 2 hrs</span>
                            <span><i class="fas fa-circle-check"></i> Completed 9:32 AM</span>
                        </div>
                    </div>
                    <div class="task-actions">
                        <button type="button" class="icon-btn" data-task="shingles-remove" data-action="photo" aria-label="Upload photo of my work"><i class="fas fa-camera"></i></button>
                        <button type="button" class="icon-btn" data-task="shingles-remove" data-action="note" aria-label="Add note"><i class="fas fa-pen"></i></button>
                    </div>
                </li>
                <li class="task-row is-mine" data-task="underlayment" data-mine="1">
                    <button type="button" class="task-check" aria-label="Mark task complete" aria-pressed="false"><i class="far fa-circle"></i></button>
                    <div>
                        <div class="task-title">Install underlayment <span class="pill pill-orange" style="margin-left:6px;">Mine</span></div>
                        <div class="task-meta">
                            <span><i class="fas fa-clock"></i> 1.5 hrs</span>
                            <span><i class="fas fa-hammer"></i> In progress</span>
                        </div>
                    </div>
                    <div class="task-actions">
                        <button type="button" class="icon-btn" data-task="underlayment" data-action="photo" aria-label="Upload photo"><i class="fas fa-camera"></i></button>
                        <button type="button" class="icon-btn" data-task="underlayment" data-action="note" aria-label="Add note"><i class="fas fa-pen"></i></button>
                    </div>
                </li>
                <li class="task-row is-others" data-task="shingles-install" data-mine="0">
                    <button type="button" class="task-check" aria-label="Not assigned to you" disabled><i class="far fa-circle"></i></button>
                    <div>
                        <div class="task-title">Install new shingles <span class="pill pill-grey" style="margin-left:6px;">Lead: Mike</span></div>
                        <div class="task-meta">
                            <span><i class="fas fa-clock"></i> 3 hrs</span>
                            <span><i class="fas fa-hourglass-half"></i> Pending</span>
                        </div>
                    </div>
                    <div class="task-actions">
                        <button type="button" class="icon-btn" disabled aria-label="Photo upload limited to your tasks"><i class="fas fa-camera"></i></button>
                    </div>
                </li>
            </ul>

            <!-- Safety-talk acknowledgement (self only; the Lead verifies others) -->
            <div class="safety-ack" id="safetyTalk" data-acked="false">
                <i class="fas fa-shield-halved" style="font-size:1.5rem; color:var(--color-warning);" aria-hidden="true"></i>
                <div class="safety-ack-text">
                    <strong>Daily safety talk &mdash; 42-CHERRY</strong>
                    Topic: Ladder safety &amp; fall prevention. Mike led at 7:50 AM.
                </div>
                <button type="button" class="safety-ack-btn" data-action="ack-safety">I attended</button>
            </div>
        </article>
    </section>

    <!-- Today's jobs + Hours / Sign-In (two-col). Hours panel is self-only. -->
    <section class="dash-section two-col">
        <article class="panel" aria-labelledby="today-h">
            <div class="panel-header">
                <h3 id="today-h"><i class="fas fa-clipboard-list"></i> Today&rsquo;s Jobs</h3>
                <a href="#tomorrow" class="see-all-link">See tomorrow &rarr;</a>
            </div>
            <ul class="job-list">
                <li class="job-item is-current">
                    <span class="job-icon" aria-hidden="true"><i class="fas fa-house-chimney"></i></span>
                    <div>
                        <span class="job-case">42-CHERRY</span> <span class="pill pill-green">Current</span>
                        <div class="job-scope">Roof repair &middot; Lead: Mike</div>
                        <div class="job-meta">
                            <span><i class="fas fa-clock"></i> 4 hrs left</span>
                            <span><i class="fas fa-location-dot"></i> on site</span>
                            <span><i class="fas fa-cloud-sun"></i> Outdoor</span>
                        </div>
                    </div>
                    <a href="#currentJob" class="job-cta">Open <i class="fas fa-arrow-right"></i></a>
                </li>
                <li class="job-item is-upnext">
                    <span class="job-icon" aria-hidden="true"><i class="fas fa-house-chimney"></i></span>
                    <div>
                        <span class="job-case">15-MERRILL</span> <span class="pill pill-amber">Up next</span>
                        <div class="job-scope">Plumbing assist &middot; Lead: Mike</div>
                        <div class="job-meta">
                            <span><i class="fas fa-clock"></i> 1 hr est.</span>
                            <span><i class="fas fa-route"></i> 4.1 mi</span>
                            <span><i class="fas fa-house"></i> Indoor</span>
                        </div>
                    </div>
                    <a href="#tomorrow" class="job-cta">View <i class="fas fa-arrow-right"></i></a>
                </li>
            </ul>
        </article>

        <article class="panel hours-panel" id="hours" aria-labelledby="hours-h">
            <div class="panel-header" style="justify-content:center;">
                <h3 id="hours-h"><i class="fas fa-clock"></i> My Hours</h3>
            </div>
            <span class="hours-label">Clocked in today</span>
            <div class="hours-display" id="hoursDisplay">2:18</div>
            <span class="hours-label" id="clockStatus">In since 7:42 AM &middot; 42-CHERRY</span>
            <button type="button" class="clock-btn is-clocked-in" id="clockBtn" data-clocked="true">
                <i class="fas fa-stop-circle"></i> <span id="clockBtnLabel">Clock Out</span>
            </button>
            <p class="hours-meta">Self-reported hours sync to your timesheet for PM review.</p>
        </article>
    </section>

    <!-- Messages + Volunteers (read-only roster). -->
    <section class="dash-section two-col">
        <article class="panel" id="messages" aria-labelledby="msg-h">
            <div class="panel-header">
                <h3 id="msg-h"><i class="fas fa-envelope"></i> Messages <span class="pill pill-red" style="margin-left:6px;">1 new</span></h3>
                <a href="#messages" class="see-all-link">All messages &rarr;</a>
            </div>
            <ul class="msg-list">
                <li class="msg-item">
                    <div class="msg-from">Mike &middot; <span style="color:var(--color-text-muted); font-weight:500;">Crew Lead</span></div>
                    <div class="msg-body">"Once underlayment is down, grab a photo before we cover it. Thanks, Alex."</div>
                    <div class="msg-meta"><span>10:02 AM</span><a href="#messages" class="see-all-link">Reply</a></div>
                </li>
                <li class="msg-item is-system">
                    <div class="msg-from">ARCHR System</div>
                    <div class="msg-body">Reminder &mdash; clock out before leaving the site so your hours post correctly.</div>
                    <div class="msg-meta"><span>8:30 AM</span><a href="#hours" class="see-all-link">Open</a></div>
                </li>
            </ul>
        </article>

        <article class="panel" id="volunteers" aria-labelledby="vol-h">
            <div class="panel-header">
                <h3 id="vol-h"><i class="fas fa-hands-helping"></i> Volunteers Today <span class="pill pill-grey" style="margin-left:6px;">View only</span></h3>
                <a href="#volunteers" class="see-all-link">Full roster &rarr;</a>
            </div>
            <ul class="vol-list" aria-label="Volunteers on 42-CHERRY (read-only)">
                <li class="vol-item">
                    <span class="vol-avatar" aria-hidden="true">BP</span>
                    <div>
                        <div class="vol-name">Bri Park</div>
                        <div class="vol-meta">In since 7:55 AM &middot; helping with shingles</div>
                    </div>
                    <span class="pill pill-green"><i class="fas fa-circle-check"></i> Safety done</span>
                </li>
                <li class="vol-item">
                    <span class="vol-avatar" aria-hidden="true">CL</span>
                    <div>
                        <div class="vol-name">Casey Lin</div>
                        <div class="vol-meta">Just arrived &middot; awaiting check-in</div>
                    </div>
                    <span class="pill pill-amber"><i class="fas fa-hourglass-half"></i> Pending</span>
                </li>
            </ul>
        </article>
    </section>

    <!-- Tomorrow quick cards (no volunteer management, no sub view) -->
    <section class="dash-section" id="tomorrow" aria-labelledby="tom-h">
        <div class="section-header-row">
            <h3 class="dash-section-title" id="tom-h" style="margin:0;"><i class="fas fa-calendar-day"></i> Tomorrow</h3>
            <a href="#tomorrow" class="see-all-link">Full schedule &rarr;</a>
        </div>
        <div class="quick-grid">
            <a href="#tomorrow" class="quick-card">
                <span class="quick-label">My Jobs</span>
                <span class="quick-value">2</span>
                <span class="quick-sub">First: 8:00 AM at 21-MAPLE</span>
            </a>
            <a href="#tomorrow" class="quick-card">
                <span class="quick-label">Lead</span>
                <span class="quick-value">Mike</span>
                <span class="quick-sub">same crew as today</span>
            </a>
            <a href="#tomorrow" class="quick-card">
                <span class="quick-label">Weather</span>
                <span class="quick-value">52&deg;</span>
                <span class="quick-sub">Sunny &middot; outdoor work OK</span>
            </a>
        </div>
    </section>

    <p class="role-notice">
        <i class="fas fa-circle-info"></i>
        <span>
            <strong>POC dashboard:</strong>
            Feature surface trimmed to the Crew Member rights in
            <code>interface/crew-lead/core-features-comparison.md</code>:
            own task updates, limited photo upload, view-only volunteers, self-only
            hours &amp; sign-in, safety-talk <em>acknowledge</em> (not verify),
            incident report only if involved. No completion sign-off, change orders,
            subcontractor management, workflow phase changes, alerts, or budget.
            Mobile blueprints: <code>interface/crew-member/otg-project.md</code>,
            <code>task-row-otg.md</code>, <code>job-card-warehouse-view.md</code>,
            <code>bottom-nav.md</code>. Below 700&thinsp;px the page collapses to
            welcome + battle-bar + bottom nav.
        </span>
    </p>
</section>
