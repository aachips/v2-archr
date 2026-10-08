<?php
/** Body partial generated from app/templates/crew-lead.html.
    Hard-coded sample data is preserved as-is (prototype). */
?>
<section class="portal-page active" id="dashboardPage" data-page-title="Crew Lead Dashboard">

    <!-- Hero: welcome + today's conditions (crew-lead-summary.md "Today's Jobs" header) -->
    <div class="dash-hero mobile-show">
        <div>
            <h2>Welcome back, Mike</h2>
            <p>Tue, Dec 19 &middot; Partly Cloudy 48&deg;F &middot; Leading <strong>3 jobs</strong> &middot; <strong>4 volunteers</strong> signed in</p>
        </div>
        <div class="dash-hero-meta">
            <span class="hero-count-label">Active</span>
            <span class="hero-count">3</span>
        </div>
    </div>

    <!-- Battle-mode action bar: the 4 things a Crew Lead does most on-site,
         per battle-mode.md (Attack / Item / Defend / Run). Kept on mobile. -->
    <section class="battle-bar mobile-show" aria-label="Quick on-site actions">
        <a href="#tasks" class="battle-btn"><i class="fas fa-list-check"></i> Update Task</a>
        <a href="#photos" class="battle-btn"><i class="fas fa-camera"></i> Add Photos</a>
        <a href="#dailyLog" class="battle-btn"><i class="fas fa-pen-to-square"></i> Daily Log</a>
        <a href="#nextJob" class="battle-btn"><i class="fas fa-forward"></i> Next Job</a>
    </section>

    <!-- Mobile-only hint: points to the hamburger drawer + bottom nav -->
    <p class="mobile-hint mobile-show" role="note">
        <i class="fas fa-circle-info" aria-hidden="true"></i>
        <span>Tap <i class="fas fa-bars" aria-hidden="true"></i> for incident reports, change orders, sign-off &amp; more.</span>
    </p>

    <!-- KPI strip: counts from crew_job_cards + crew_volunteer_signin (crew-dash-schema.md) -->
    <section class="dash-section" aria-labelledby="kpi-h">
        <h3 class="dash-section-title" id="kpi-h"><i class="fas fa-chart-pie"></i> My Stats</h3>
        <div class="kpi-grid">
            <div class="kpi kpi-assigned">
                <span class="kpi-label">Assigned</span>
                <span class="kpi-value">5</span>
                <span class="kpi-sub">jobs in your queue</span>
                <span class="kpi-foot"><a href="#tomorrow">View schedule &rarr;</a></span>
            </div>
            <div class="kpi kpi-progress">
                <span class="kpi-label">In Progress</span>
                <span class="kpi-value">3</span>
                <span class="kpi-sub">active sites today</span>
                <span class="kpi-foot"><a href="#currentJob">Open current job &rarr;</a></span>
            </div>
            <div class="kpi kpi-complete">
                <span class="kpi-label">Completed</span>
                <span class="kpi-value">12</span>
                <span class="kpi-sub">last 30 days</span>
                <span class="kpi-foot"><a href="#completion">Sign-off log &rarr;</a></span>
            </div>
            <div class="kpi kpi-volunteers">
                <span class="kpi-label">Volunteers</span>
                <span class="kpi-value">4</span>
                <span class="kpi-sub">signed in today &middot; 2 need safety talk</span>
                <span class="kpi-foot"><a href="#volunteers">Manage roster &rarr;</a></span>
            </div>
        </div>
    </section>

    <!-- Current Job: the site the Crew Lead is on right now. Pulls
         crew_job_cards.is_current_job + tasks + phase. Action chips map
         to the dashboard requirements in crew-lead-summary.md. -->
    <section class="dash-section" id="currentJob" aria-labelledby="cur-h">
        <div class="section-header-row">
            <h3 class="dash-section-title" id="cur-h" style="margin:0;"><i class="fas fa-helmet-safety"></i> Current Job</h3>
            <a href="#tasks" class="see-all-link">All task updates &rarr;</a>
        </div>
        <article class="current-job">
            <div class="current-job-head">
                <div>
                    <span class="case-id">42-CHERRY</span>
                    <span class="case-scope">&middot; Roof Repair &middot; 42 Cherry St &middot; Homeowner: J. Patel</span>
                </div>
                <span class="pill pill-orange"><i class="fas fa-circle-play"></i> Phase 3 &middot; Active Work</span>
            </div>
            <div class="current-job-meta">
                <span><i class="fas fa-cloud-sun"></i> Outdoor &middot; 48&deg;F</span>
                <span><i class="fas fa-clock"></i> 4h est. remaining</span>
                <span><i class="fas fa-user-group"></i> 2 crew &middot; 2 volunteers</span>
                <span class="progress-cell" style="display:inline-flex; align-items:center; gap:8px;">
                    <span class="meter" aria-hidden="true"><span class="meter-fill" style="width:65%;"></span></span>
                    <strong style="color:var(--color-text);">65%</strong>
                    <span>&middot; 2 of 3 tasks done</span>
                </span>
            </div>

            <div style="overflow-x:auto;">
            <table class="task-table" aria-label="Tasks for 42-CHERRY">
                <thead>
                    <tr>
                        <th>Task</th>
                        <th>Est.</th>
                        <th>Status</th>
                        <th style="text-align:right;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td class="task-name">Tarp &amp; secure perimeter</td>
                        <td>2 hrs</td>
                        <td><span class="pill pill-green"><i class="fas fa-circle-check"></i> Done</span></td>
                        <td><div class="task-actions"><button type="button" class="btn-tap is-done" aria-label="Tarp task completed"><i class="fas fa-check"></i> Completed</button></div></td>
                    </tr>
                    <tr>
                        <td class="task-name">Replace damaged shingles</td>
                        <td>3 hrs</td>
                        <td><span class="pill pill-amber"><i class="fas fa-hammer"></i> In Progress</span></td>
                        <td><div class="task-actions">
                            <button type="button" class="btn-tap" data-task="shingles" data-action="complete"><i class="fas fa-check"></i> Mark Done</button>
                            <button type="button" class="btn-tap" data-task="shingles" data-action="photo"><i class="fas fa-camera"></i> Photo</button>
                        </div></td>
                    </tr>
                    <tr>
                        <td class="task-name">Clean up &amp; haul debris</td>
                        <td>1 hr</td>
                        <td><span class="pill pill-grey"><i class="fas fa-hourglass-half"></i> Pending</span></td>
                        <td><div class="task-actions">
                            <button type="button" class="btn-tap" data-task="cleanup" data-action="start"><i class="fas fa-play"></i> Start</button>
                        </div></td>
                    </tr>
                </tbody>
            </table>
            </div>

            <div class="current-job-actions">
                <a href="#dailyLog" class="chip"><i class="fas fa-pen-to-square"></i> Daily Log</a>
                <a href="#photos" class="chip"><i class="fas fa-camera"></i> Photos</a>
                <a href="#safetyTalk" class="chip"><i class="fas fa-shield-halved"></i> Safety Talk</a>
                <a href="#completion" class="chip"><i class="fas fa-file-signature"></i> Get Sign-off</a>
                <a href="#incident" class="chip"><i class="fas fa-triangle-exclamation"></i> Report Incident</a>
                <a href="#changeOrder" class="chip"><i class="fas fa-file-pen"></i> Change Order</a>
            </div>
        </article>
    </section>

    <!-- Today's jobs + Volunteers / Messages (warehouse view, two-column) -->
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
                        <div class="job-scope">Roof repair &middot; Lead: you</div>
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
                        <div class="job-scope">Plumbing &middot; Lead: you</div>
                        <div class="job-meta">
                            <span><i class="fas fa-clock"></i> 1 hr est.</span>
                            <span><i class="fas fa-route"></i> 4.1 mi</span>
                            <span><i class="fas fa-house"></i> Indoor</span>
                        </div>
                    </div>
                    <a href="#nextJob" class="job-cta">Travel <i class="fas fa-arrow-right"></i></a>
                </li>
                <li class="job-item">
                    <span class="job-icon" aria-hidden="true"><i class="fas fa-house-chimney"></i></span>
                    <div>
                        <span class="job-case">8-OAKLAND</span> <span class="pill pill-grey">Scheduled</span>
                        <div class="job-scope">Window replacement &middot; Sub: Pinetree Glass</div>
                        <div class="job-meta">
                            <span><i class="fas fa-clock"></i> 2 hrs est.</span>
                            <span><i class="fas fa-route"></i> 6.8 mi</span>
                            <span><i class="fas fa-hard-hat"></i> Subcontractor</span>
                        </div>
                    </div>
                    <a href="#jobs" class="job-cta">View <i class="fas fa-arrow-right"></i></a>
                </li>
            </ul>
        </article>

        <article class="panel" aria-labelledby="vol-h">
            <div class="panel-header">
                <h3 id="vol-h"><i class="fas fa-hands-helping"></i> Volunteers Today</h3>
                <a href="#volunteers" class="see-all-link">Roster &rarr;</a>
            </div>
            <ul class="vol-list" id="volunteerList">
                <li class="vol-item" data-vol="ah">
                    <span class="vol-avatar" aria-hidden="true">AH</span>
                    <div>
                        <div class="vol-name">Alex Hernandez</div>
                        <div class="vol-meta">In since 7:42 AM &middot; 42-CHERRY</div>
                    </div>
                    <label class="safety-check is-checked"><input type="checkbox" checked> Safety</label>
                </li>
                <li class="vol-item" data-vol="bp">
                    <span class="vol-avatar" aria-hidden="true">BP</span>
                    <div>
                        <div class="vol-name">Bri Park</div>
                        <div class="vol-meta">In since 7:55 AM &middot; 42-CHERRY</div>
                    </div>
                    <label class="safety-check is-checked"><input type="checkbox" checked> Safety</label>
                </li>
                <li class="vol-item" data-vol="cl">
                    <span class="vol-avatar" aria-hidden="true">CL</span>
                    <div>
                        <div class="vol-name">Casey Lin</div>
                        <div class="vol-meta">Just arrived &middot; awaiting check-in</div>
                    </div>
                    <label class="safety-check"><input type="checkbox"> Safety</label>
                </li>
                <li class="vol-item" data-vol="dn">
                    <span class="vol-avatar" aria-hidden="true">DN</span>
                    <div>
                        <div class="vol-name">Devon Nguyen</div>
                        <div class="vol-meta">Expected 1:00 PM &middot; 15-MERRILL</div>
                    </div>
                    <label class="safety-check"><input type="checkbox"> Safety</label>
                </li>
            </ul>
        </article>
    </section>

    <!-- Messages + Tomorrow / quick chips -->
    <section class="dash-section two-col">
        <article class="panel" id="messages" aria-labelledby="msg-h">
            <div class="panel-header">
                <h3 id="msg-h"><i class="fas fa-envelope"></i> Messages <span class="pill pill-red" style="margin-left:6px;">2 new</span></h3>
                <a href="#messages" class="see-all-link">All messages &rarr;</a>
            </div>
            <ul class="msg-list">
                <li class="msg-item">
                    <div class="msg-from">Sarah Bell &middot; <span style="color:var(--color-text-muted); font-weight:500;">Project Manager</span></div>
                    <div class="msg-body">"Can you confirm timeline for 42-CHERRY? Homeowner asked about Friday walk-through."</div>
                    <div class="msg-meta"><span>9:14 AM</span><a href="#messages" class="see-all-link">Reply</a></div>
                </li>
                <li class="msg-item is-system">
                    <div class="msg-from">ARCHR System</div>
                    <div class="msg-body">Subcontractor quote approved for 8-OAKLAND &mdash; Pinetree Glass scheduled for 1:30 PM.</div>
                    <div class="msg-meta"><span>8:31 AM</span><a href="#subcontractors" class="see-all-link">Open job</a></div>
                </li>
            </ul>
        </article>

        <article class="panel" id="tomorrow" aria-labelledby="tom-h">
            <div class="panel-header">
                <h3 id="tom-h"><i class="fas fa-calendar-day"></i> Tomorrow</h3>
                <a href="#tomorrow" class="see-all-link">Full schedule &rarr;</a>
            </div>
            <div class="quick-grid" style="grid-template-columns:repeat(2,1fr); margin-bottom:0;">
                <a href="#tomorrow" class="quick-card">
                    <span class="quick-label">Jobs</span>
                    <span class="quick-value">3</span>
                    <span class="quick-sub">First: 7:30 AM at 21-MAPLE</span>
                </a>
                <a href="#volunteers" class="quick-card">
                    <span class="quick-label">Volunteers</span>
                    <span class="quick-value">5</span>
                    <span class="quick-sub">3 returning &middot; 2 new</span>
                </a>
                <a href="#subcontractors" class="quick-card">
                    <span class="quick-label">Subs</span>
                    <span class="quick-value">1</span>
                    <span class="quick-sub">Pinetree Glass &middot; 9 AM</span>
                </a>
                <a href="#tomorrow" class="quick-card">
                    <span class="quick-label">Weather</span>
                    <span class="quick-value">52&deg;</span>
                    <span class="quick-sub">Light rain AM &middot; plan indoor</span>
                </a>
            </div>
        </article>
    </section>

    <p class="role-notice">
        <i class="fas fa-circle-info"></i>
        <span>
            <strong>POC dashboard:</strong>
            Layout follows the blueprints in <code>interface/crew-lead/</code> &mdash;
            <code>crew-lead-summary.md</code>, <code>project-view-otg.md</code>,
            <code>battle-mode.md</code>, <code>mobile-first-requirements.md</code> &mdash;
            and the warehouse view in <code>interface/crew-member/warehouse-view.md</code>.
            Data joins <code>crew_job_cards</code>, <code>crew_volunteer_signin</code>,
            <code>crew_daily_logs</code>, and <code>crew_tomorrow_view</code> from
            <code>crew-dash-schema.md</code>. Below 700&thinsp;px the page collapses to
            welcome + battle-bar + bottom nav (per <code>bottom-nav.md</code>).
        </span>
    </p>
</section>
