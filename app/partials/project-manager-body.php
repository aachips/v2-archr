<?php
/** Body partial generated from app/templates/project-manager.html.
    Hard-coded sample data is preserved as-is (prototype). */
?>
<section class="portal-page active" id="dashboardPage" data-page-title="Project Manager Dashboard">

    <!-- Hero / PM context (welcome message comes first) -->
    <div class="dash-hero mobile-show">
        <div>
            <h2>Good morning, Jamie</h2>
            <p>Operations &middot; 8 active projects &middot; 3 estimates awaiting approval &middot; Last sync 9:14 AM</p>
        </div>
        <div class="dash-hero-meta">
            <span class="hero-count-label">Active</span>
            <span class="hero-count">8</span>
        </div>
    </div>

    <!-- Global Case Search (kept visible on mobile per landing-page spec) -->
    <section class="case-search mobile-show" aria-labelledby="case-search-h">
        <h2 id="case-search-h" class="sr-only" style="position:absolute; left:-9999px;">Global Case Search</h2>
        <div class="case-search-row">
            <span class="case-search-icon" aria-hidden="true"><i class="fas fa-magnifying-glass"></i></span>
            <input type="search" class="case-search-input" id="globalCaseSearch"
                placeholder="Search cases by case # &middot; address &middot; applicant name &middot; phone"
                aria-label="Global case search">
            <a href="#caseSearchAdvanced" class="case-search-advanced"><i class="fas fa-sliders"></i> Advanced</a>
            <button type="button" class="btn btn-primary btn-sm" id="globalCaseSearchBtn"><i class="fas fa-arrow-right"></i> Search</button>
        </div>
        <div class="case-search-filters" role="group" aria-label="Quick filters">
            <button type="button" class="case-search-filter is-active">All cases</button>
            <button type="button" class="case-search-filter">My projects</button>
            <button type="button" class="case-search-filter">Unclaimed</button>
            <button type="button" class="case-search-filter">Awaiting approval</button>
            <button type="button" class="case-search-filter">Subcontractor-led</button>
            <button type="button" class="case-search-filter">At risk</button>
        </div>
    </section>

    <!-- Mobile-only hint: surfaces the hamburger as the path to every other feature -->
    <p class="mobile-hint mobile-show" role="note">
        <i class="fas fa-circle-info" aria-hidden="true"></i>
        <span>Tap <i class="fas fa-bars" aria-hidden="true"></i> to open projects, alerts, messages, and every other tool. Each menu item is its own page.</span>
    </p>

    <!-- Command Cards: Unclaimed Jobs + Accepted Jobs (per data-flow spec) -->
    <section class="dash-section" aria-labelledby="cmd-h">
        <h3 class="dash-section-title" id="cmd-h"><i class="fas fa-bullseye"></i> Command Center</h3>
        <div class="command-grid">
            <article class="command-card" aria-labelledby="unclaimed-h">
                <div class="command-card-head">
                    <div>
                        <div class="command-card-label" id="unclaimed-h">Unclaimed Jobs</div>
                        <div class="command-card-count">5</div>
                        <div class="command-card-sub">Awaiting PM claim &middot; oldest 4 days</div>
                    </div>
                    <span class="command-card-icon" aria-hidden="true"><i class="fas fa-hand-pointer"></i></span>
                </div>
                <div class="command-card-actions">
                    <a href="#claimJobs" class="btn btn-primary"><i class="fas fa-hand-holding-heart"></i> Claim</a>
                    <a href="#subcontractors" class="btn btn-secondary"><i class="fas fa-hard-hat"></i> Subcontractors</a>
                    <a href="#workflows" class="btn btn-secondary"><i class="fas fa-sitemap"></i> Workflows</a>
                    <a href="#crew" class="btn btn-secondary"><i class="fas fa-people-group"></i> Work Crews</a>
                </div>
            </article>
            <article class="command-card is-accepted" aria-labelledby="accepted-h">
                <div class="command-card-head">
                    <div>
                        <div class="command-card-label" id="accepted-h">Accepted Jobs</div>
                        <div class="command-card-count">8</div>
                        <div class="command-card-sub">In your portfolio &middot; 6 in progress</div>
                    </div>
                    <span class="command-card-icon" aria-hidden="true"><i class="fas fa-circle-check"></i></span>
                </div>
                <div class="command-card-actions">
                    <a href="#projects" class="btn btn-primary"><i class="fas fa-folder-open"></i> View</a>
                    <a href="#volunteers" class="btn btn-secondary"><i class="fas fa-hands-helping"></i> Volunteers</a>
                    <a href="#contracts" class="btn btn-secondary"><i class="fas fa-file-signature"></i> Contracts</a>
                </div>
            </article>
        </div>
    </section>

    <!-- KPI strip -->
    <section class="dash-section" aria-labelledby="kpi-h">
        <h3 class="dash-section-title" id="kpi-h"><i class="fas fa-chart-pie"></i> Portfolio Snapshot</h3>
        <div class="kpi-grid">
            <div class="kpi kpi-active">
                <span class="kpi-label">Active Projects</span>
                <span class="kpi-value">8</span>
                <span class="kpi-sub">2 starting this week</span>
                <span class="kpi-foot"><a href="#projects">View all &rarr;</a></span>
            </div>
            <div class="kpi kpi-budget">
                <span class="kpi-label">On Budget</span>
                <span class="kpi-value">$1.2M<span style="font-size:var(--fs-md); color:var(--color-text-muted); font-weight:500;"> / $1.5M</span></span>
                <span class="kpi-sub">80% utilized portfolio-wide</span>
                <span class="kpi-foot"><a href="#reports">Budget report &rarr;</a></span>
            </div>
            <div class="kpi kpi-schedule">
                <span class="kpi-label">On Schedule</span>
                <span class="kpi-value">6<span style="font-size:var(--fs-md); color:var(--color-text-muted); font-weight:500;"> / 8</span></span>
                <span class="kpi-sub">75% on track &middot; 2 at risk</span>
                <span class="kpi-foot"><a href="#projects">See delays &rarr;</a></span>
            </div>
            <div class="kpi kpi-approve">
                <span class="kpi-label">Awaiting Approval</span>
                <span class="kpi-value">3</span>
                <span class="kpi-sub">Oldest 4 days &middot; SLA &lt; 48 hrs</span>
                <span class="kpi-foot"><a href="#estimates">Review queue &rarr;</a></span>
            </div>
        </div>
    </section>

    <!-- Project Status Overview -->
    <section class="dash-section" aria-labelledby="proj-h">
        <div class="section-header-row">
            <h3 class="dash-section-title" id="proj-h" style="margin:0;"><i class="fas fa-diagram-project"></i> Project Status Overview</h3>
            <a href="#projects" class="see-all-link">View all projects &rarr;</a>
        </div>
        <article class="panel" style="padding:0;">
            <div style="overflow-x:auto;">
            <table class="project-table">
                <thead>
                    <tr>
                        <th>Case</th>
                        <th>Scope</th>
                        <th>Crew Lead</th>
                        <th>Progress</th>
                        <th class="col-num">Budget</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><span class="case-id">42-CHERRY</span><div style="font-size:var(--fs-xs); color:var(--color-text-muted);">42 Cherry St</div></td>
                        <td>Roofing</td>
                        <td>Sarah M.</td>
                        <td><div class="progress-cell"><span class="meter"><span class="meter-fill" style="width:60%;"></span></span><span class="pct">60%</span></div></td>
                        <td class="col-num">$45k / $50k</td>
                        <td><span class="pill pill-amber"><i class="fas fa-clock"></i> 3 days behind</span></td>
                    </tr>
                    <tr>
                        <td><span class="case-id">15-MERRILL</span><div style="font-size:var(--fs-xs); color:var(--color-text-muted);">15 Merrill Ave</div></td>
                        <td>Plumbing</td>
                        <td>David C.</td>
                        <td><div class="progress-cell"><span class="meter"><span class="meter-fill is-success" style="width:90%;"></span></span><span class="pct">90%</span></div></td>
                        <td class="col-num">$48k / $50k</td>
                        <td><span class="pill pill-green"><i class="fas fa-circle-check"></i> On track</span></td>
                    </tr>
                    <tr>
                        <td><span class="case-id">8-OAKLAND</span><div style="font-size:var(--fs-xs); color:var(--color-text-muted);">8 Oakland Rd</div></td>
                        <td>Electrical</td>
                        <td>Lisa K.</td>
                        <td><div class="progress-cell"><span class="meter"><span class="meter-fill is-warning" style="width:25%;"></span></span><span class="pct">25%</span></div></td>
                        <td class="col-num">$35k / $50k</td>
                        <td><span class="pill pill-amber"><i class="fas fa-hourglass-half"></i> Awaiting permit</span></td>
                    </tr>
                    <tr>
                        <td><span class="case-id">23-PARKWAY</span><div style="font-size:var(--fs-xs); color:var(--color-text-muted);">23 Parkway Dr</div></td>
                        <td>HVAC</td>
                        <td>Mike T.</td>
                        <td><div class="progress-cell"><span class="meter"><span class="meter-fill is-success" style="width:100%;"></span></span><span class="pct">100%</span></div></td>
                        <td class="col-num">$50k / $50k</td>
                        <td><span class="pill pill-green"><i class="fas fa-circle-check"></i> Complete</span></td>
                    </tr>
                    <tr>
                        <td><span class="case-id">19-RIVERSIDE</span><div style="font-size:var(--fs-xs); color:var(--color-text-muted);">19 Riverside Dr</div></td>
                        <td>Roofing + Siding</td>
                        <td><span class="pill pill-red"><i class="fas fa-user-slash"></i> Unassigned</span></td>
                        <td><div class="progress-cell"><span class="meter"><span class="meter-fill is-danger" style="width:5%;"></span></span><span class="pct">5%</span></div></td>
                        <td class="col-num">$0 / $48k</td>
                        <td><span class="pill pill-red"><i class="fas fa-triangle-exclamation"></i> Needs crew</span></td>
                    </tr>
                    <tr>
                        <td><span class="case-id">3-SUNSET</span><div style="font-size:var(--fs-xs); color:var(--color-text-muted);">3 Sunset Ln</div></td>
                        <td>Accessibility ramp</td>
                        <td>Sarah M.</td>
                        <td><div class="progress-cell"><span class="meter"><span class="meter-fill" style="width:45%;"></span></span><span class="pct">45%</span></div></td>
                        <td class="col-num">$18k / $22k</td>
                        <td><span class="pill pill-blue"><i class="fas fa-person-digging"></i> In progress</span></td>
                    </tr>
                </tbody>
            </table>
            </div>
        </article>
    </section>

    <!-- Ongoing Work table (Crew | Job | Next Up per data-flow spec) -->
    <section class="dash-section" aria-labelledby="ongoing-h">
        <div class="section-header-row">
            <h3 class="dash-section-title" id="ongoing-h" style="margin:0;"><i class="fas fa-person-digging"></i> Ongoing Work</h3>
            <a href="#ongoing" class="see-all-link">View all work &rarr;</a>
        </div>
        <article class="panel" style="padding:0; overflow:hidden;">
            <div style="overflow-x:auto;">
            <table class="ongoing-table">
                <thead>
                    <tr>
                        <th>Crew</th>
                        <th>Job</th>
                        <th>Next Up</th>
                        <th class="col-num">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><div class="crew-cell"><span class="crew-dot">SM</span> Sarah M.</div></td>
                        <td>
                            <div class="job-case">42-CHERRY</div>
                            <div class="job-meta">Roofing &middot; 3 days remaining</div>
                        </td>
                        <td>
                            <div class="next-up-date">Dec 13 &middot; 8:00 AM</div>
                            <div class="next-up-task">Decking replacement &mdash; await change order</div>
                        </td>
                        <td class="col-num"><a href="#schedule" class="btn btn-secondary btn-sm"><i class="fas fa-calendar-plus"></i> Schedule</a></td>
                    </tr>
                    <tr>
                        <td><div class="crew-cell"><span class="crew-dot">DC</span> David C.</div></td>
                        <td>
                            <div class="job-case">15-MERRILL</div>
                            <div class="job-meta">Plumbing &middot; 1 day remaining</div>
                        </td>
                        <td>
                            <div class="next-up-date">Dec 12 &middot; 9:30 AM</div>
                            <div class="next-up-task">Final fixture install + walkthrough</div>
                        </td>
                        <td class="col-num"><a href="#schedule" class="btn btn-secondary btn-sm"><i class="fas fa-calendar-plus"></i> Schedule</a></td>
                    </tr>
                    <tr>
                        <td><div class="crew-cell"><span class="crew-dot">LK</span> Lisa K.</div></td>
                        <td>
                            <div class="job-case">8-OAKLAND</div>
                            <div class="job-meta">Electrical &middot; 14 days remaining</div>
                        </td>
                        <td>
                            <div class="next-up-date">Pending permit</div>
                            <div class="next-up-task">Panel upgrade &mdash; city inspection scheduled</div>
                        </td>
                        <td class="col-num"><a href="#schedule" class="btn btn-secondary btn-sm"><i class="fas fa-calendar-plus"></i> Schedule</a></td>
                    </tr>
                    <tr>
                        <td><div class="crew-cell"><span class="crew-dot">MT</span> Mike T.</div></td>
                        <td>
                            <div class="job-case">3-SUNSET</div>
                            <div class="job-meta">Accessibility ramp &middot; 6 days remaining</div>
                        </td>
                        <td>
                            <div class="next-up-date">Dec 14 &middot; 7:30 AM</div>
                            <div class="next-up-task">Frame inspection + concrete pour</div>
                        </td>
                        <td class="col-num"><a href="#schedule" class="btn btn-secondary btn-sm"><i class="fas fa-calendar-plus"></i> Schedule</a></td>
                    </tr>
                </tbody>
            </table>
            </div>
            <div class="ongoing-foot">
                <span><strong>3 ready jobs</strong> awaiting crew start &middot; 1 blocked by permit</span>
                <a href="#scheduleReadyJobs" class="btn btn-primary btn-sm"><i class="fas fa-calendar-plus"></i> Schedule Ready Jobs</a>
            </div>
        </article>
    </section>

    <!-- Two-column: Crew Assignments + Subcontractor Queue -->
    <section class="dash-section">
        <div class="two-col">
            <article class="panel" aria-labelledby="crew-h">
                <div class="panel-header">
                    <h3 id="crew-h"><i class="fas fa-people-group"></i> Crew Assignments</h3>
                    <a href="#crew" class="see-all-link">Manage crews &rarr;</a>
                </div>
                <ul class="crew-list">
                    <li class="crew-item">
                        <span class="crew-avatar">SM</span>
                        <div>
                            <div><span class="crew-case">42-CHERRY</span> &rarr; <span class="crew-name">Sarah M.</span></div>
                            <div class="crew-meta">3 crew members &middot; On site since Dec 9</div>
                        </div>
                        <a href="#reassign" class="btn btn-secondary btn-sm">Reassign</a>
                    </li>
                    <li class="crew-item">
                        <span class="crew-avatar">DC</span>
                        <div>
                            <div><span class="crew-case">15-MERRILL</span> &rarr; <span class="crew-name">David C.</span></div>
                            <div class="crew-meta">2 crew members &middot; Wrapping up</div>
                        </div>
                        <a href="#reassign" class="btn btn-secondary btn-sm">Reassign</a>
                    </li>
                    <li class="crew-item">
                        <span class="crew-avatar">LK</span>
                        <div>
                            <div><span class="crew-case">8-OAKLAND</span> &rarr; <span class="crew-name">Lisa K.</span></div>
                            <div class="crew-meta">4 crew members &middot; Idle while waiting permit</div>
                        </div>
                        <a href="#reassign" class="btn btn-secondary btn-sm">Reassign</a>
                    </li>
                    <li class="crew-item is-unassigned">
                        <span class="crew-avatar"><i class="fas fa-user-slash"></i></span>
                        <div>
                            <div><span class="crew-case">19-RIVERSIDE</span> &rarr; <span class="crew-name">Unassigned</span></div>
                            <div class="crew-meta">SLA: assign within 24 hrs</div>
                        </div>
                        <a href="#assignCrew" class="btn btn-primary btn-sm"><i class="fas fa-user-plus"></i> Assign</a>
                    </li>
                </ul>
            </article>

            <article class="panel" aria-labelledby="subs-h">
                <div class="panel-header">
                    <h3 id="subs-h"><i class="fas fa-hard-hat"></i> Subcontractor Queue</h3>
                    <a href="#subcontractors" class="see-all-link">View queue &rarr;</a>
                </div>
                <ul class="sub-list">
                    <li class="sub-item is-pending">
                        <div class="sub-trade">HVAC &middot; <span class="pill pill-amber"><i class="fas fa-clock"></i> Quote pending</span></div>
                        <div class="sub-body">23-PARKWAY change order quote requested from Anchor HVAC.</div>
                        <div class="sub-meta"><span>Requested 3 days ago</span><a href="#sub-detail" class="btn btn-secondary btn-sm">Nudge</a></div>
                    </li>
                    <li class="sub-item is-active">
                        <div class="sub-trade">Roofing &middot; <span class="pill pill-green"><i class="fas fa-circle-check"></i> Approved</span></div>
                        <div class="sub-body">Mountain Roof Co. approved for 19-RIVERSIDE &mdash; waiting on start date.</div>
                        <div class="sub-meta"><span>Start: Dec 16</span><a href="#sub-detail" class="btn btn-secondary btn-sm">Schedule</a></div>
                    </li>
                    <li class="sub-item">
                        <div class="sub-trade">Electrical &middot; <span class="pill pill-blue"><i class="fas fa-bolt"></i> On site</span></div>
                        <div class="sub-body">Bright Spark Electric assigned to 8-OAKLAND.</div>
                        <div class="sub-meta"><span>Day 2 of 5</span><a href="#sub-detail" class="btn btn-secondary btn-sm">Check in</a></div>
                    </li>
                </ul>
            </article>
        </div>
    </section>

    <!-- Two-column: Alerts (latest events) + Messages -->
    <section class="dash-section">
        <div class="two-col">
            <article class="panel" aria-labelledby="alerts-h">
                <div class="panel-header">
                    <h3 id="alerts-h"><i class="fas fa-bell"></i> Alerts</h3>
                    <a href="#eventDetails" class="see-all-link">Event details &rarr;</a>
                </div>
                <ul class="alert-list">
                    <li class="alert-row is-success">
                        <span class="alert-dot" aria-hidden="true"><i class="fas fa-hand-holding-heart"></i></span>
                        <div>
                            <div class="alert-title">Job claimed &middot; 19-RIVERSIDE</div>
                            <div class="alert-detail">Eileen Bailey (Envoy) claimed and routed to your queue. 12 min ago</div>
                        </div>
                        <a href="#eventDetails" class="btn btn-secondary btn-sm">Open</a>
                    </li>
                    <li class="alert-row">
                        <span class="alert-dot" aria-hidden="true"><i class="fas fa-user-plus"></i></span>
                        <div>
                            <div class="alert-title">Crew assigned &middot; 3-SUNSET</div>
                            <div class="alert-detail">Mike T. accepted assignment. Volunteer slot manager notified. 47 min ago</div>
                        </div>
                        <a href="#eventDetails" class="btn btn-secondary btn-sm">Open</a>
                    </li>
                    <li class="alert-row is-warning">
                        <span class="alert-dot" aria-hidden="true"><i class="fas fa-file-signature"></i></span>
                        <div>
                            <div class="alert-title">Subcontractor quote received</div>
                            <div class="alert-detail">Anchor HVAC submitted $8,450 quote for 23-PARKWAY change order. 2 hrs ago</div>
                        </div>
                        <a href="#eventDetails" class="btn btn-secondary btn-sm">Open</a>
                    </li>
                    <li class="alert-row is-danger">
                        <span class="alert-dot" aria-hidden="true"><i class="fas fa-triangle-exclamation"></i></span>
                        <div>
                            <div class="alert-title">Volunteer slot unfilled &middot; 15-MERRILL</div>
                            <div class="alert-detail">2 of 4 required L2+ volunteers confirmed for Dec 12 walkthrough. 3 hrs ago</div>
                        </div>
                        <a href="#eventDetails" class="btn btn-secondary btn-sm">Open</a>
                    </li>
                </ul>
            </article>

            <article class="panel" aria-labelledby="msg-h">
                <div class="panel-header">
                    <h3 id="msg-h"><i class="fas fa-envelope"></i> Messages</h3>
                    <a href="#messageDetails" class="see-all-link">Message details &rarr;</a>
                </div>
                <ul class="msg-list">
                    <li class="msg-item">
                        <div class="msg-from">Sarah M. <span class="pill pill-blue" style="margin-left:6px;">Crew Lead</span></div>
                        <div class="msg-body">"42-CHERRY roof decking is more rotted than estimated. Need a change order before noon."</div>
                        <div class="msg-meta"><span>22 min ago</span><a href="#message-detail" class="btn btn-secondary btn-sm">Reply</a></div>
                    </li>
                    <li class="msg-item is-system">
                        <div class="msg-from">System <span class="pill pill-grey" style="margin-left:6px;">Estimate</span></div>
                        <div class="msg-body">Assessor submitted estimate for <strong>19 Riverside Dr</strong> &mdash; $48,200. Awaiting your approval.</div>
                        <div class="msg-meta"><span>Today, 8:47 AM</span><a href="#estimateApproval" class="btn btn-secondary btn-sm">Review</a></div>
                    </li>
                    <li class="msg-item">
                        <div class="msg-from">Eileen Bailey <span class="pill pill-blue" style="margin-left:6px;">Envoy</span></div>
                        <div class="msg-body">"Need weekly portfolio status by Friday EOD &mdash; board meeting Monday."</div>
                        <div class="msg-meta"><span>Yesterday, 4:12 PM</span><a href="#message-detail" class="btn btn-secondary btn-sm">Read</a></div>
                    </li>
                </ul>
            </article>
        </div>
    </section>

    <!-- Risks & Escalations (full width, prominent) -->
    <section class="dash-section" aria-labelledby="esc-h">
        <div class="section-header-row">
            <h3 class="dash-section-title" id="esc-h" style="margin:0;"><i class="fas fa-triangle-exclamation"></i> Risks &amp; Escalations</h3>
            <a href="#escalations" class="see-all-link">View all &rarr;</a>
        </div>
        <article class="panel">
            <ul class="escalation-list">
                <li class="escalation-item">
                    <i class="esc-icon fas fa-circle-exclamation"></i>
                    <div>
                        <div class="esc-title">Budget overrun &middot; 42-CHERRY</div>
                        <div class="esc-detail">Roofing subcontractor invoice 12% above approved estimate. Requires change order.</div>
                    </div>
                    <a href="#escalation-detail" class="btn btn-secondary btn-sm">Resolve</a>
                </li>
                <li class="escalation-item is-major">
                    <i class="esc-icon fas fa-hourglass-half"></i>
                    <div>
                        <div class="esc-title">Schedule delay &middot; 8-OAKLAND</div>
                        <div class="esc-detail">Electrical permit pending 9 days &mdash; blocking crew. City inspector contacted.</div>
                    </div>
                    <a href="#escalation-detail" class="btn btn-secondary btn-sm">Update</a>
                </li>
                <li class="escalation-item is-major">
                    <i class="esc-icon fas fa-user-slash"></i>
                    <div>
                        <div class="esc-title">Unassigned crew &middot; 19-RIVERSIDE</div>
                        <div class="esc-detail">Project approved 2 days ago. No crew lead assigned.</div>
                    </div>
                    <a href="#assignCrew" class="btn btn-secondary btn-sm">Assign</a>
                </li>
            </ul>
        </article>
    </section>

    <!-- 5-Button Action Row (per technical blueprint) -->
    <nav class="pm-action-row" aria-label="Project Manager quick actions">
        <a href="#projectHammer" class="pm-action-btn"><i class="fas fa-folder-open"></i> View Project</a>
        <a href="#crewAssignment" class="pm-action-btn"><i class="fas fa-user-plus"></i> Assign Crew</a>
        <a href="#estimateApproval" class="pm-action-btn"><i class="fas fa-stamp"></i> Approve Estimate</a>
        <a href="#subcontractorManagement" class="pm-action-btn"><i class="fas fa-hard-hat"></i> Manage Subs</a>
        <a href="#projectReports" class="pm-action-btn"><i class="fas fa-chart-line"></i> Report</a>
    </nav>

    <!-- Task Context Groups (capability domains from data-flow-chart.md) -->
    <section class="dash-section" aria-labelledby="tasks-h">
        <h3 class="dash-section-title" id="tasks-h"><i class="fas fa-layer-group"></i> Task Context Groups</h3>
        <div class="task-groups cols-3">
            <article class="task-group-card is-domain-requestor">
                <h4><i class="fas fa-hand-holding-heart"></i> Requestor &amp; Case</h4>
                <ul class="task-action-list">
                    <li><a href="#claimJobs"><i class="fas fa-hand-pointer"></i> Claim Jobs</a></li>
                    <li><a href="#updateInfo"><i class="fas fa-pen"></i> Update Information</a></li>
                    <li><a href="#caseNotes"><i class="fas fa-sticky-note"></i> Take Case Notes</a></li>
                    <li><a href="#scheduleAssessment"><i class="fas fa-clipboard-list"></i> Schedule Assessment</a></li>
                    <li><a href="#signOffSchedule"><i class="fas fa-signature"></i> Sign Off on Schedule</a></li>
                    <li><a href="#scheduleJobStart"><i class="fas fa-play"></i> Schedule Job Start</a></li>
                </ul>
            </article>
            <article class="task-group-card is-domain-internal">
                <h4><i class="fas fa-people-arrows"></i> Internal Coalition</h4>
                <ul class="task-action-list">
                    <li><a href="#updateTaskStatus"><i class="fas fa-list-check"></i> Update Task &amp; Job Status</a></li>
                    <li><a href="#updateEstimatedCost"><i class="fas fa-calculator"></i> Update Estimated Costs</a></li>
                    <li><a href="#updateActualCost"><i class="fas fa-coins"></i> Update Actual Costs</a></li>
                    <li><a href="#timeAppraisal"><i class="fas fa-stopwatch"></i> Time Appraisal (crew + volunteer size)</a></li>
                    <li><a href="#budgetVsActual"><i class="fas fa-chart-column"></i> Budget vs. Actual</a></li>
                    <li><a href="#bursarHandoff"><i class="fas fa-paper-plane"></i> Hand off to Bursar</a></li>
                </ul>
            </article>
            <article class="task-group-card is-domain-partner">
                <h4><i class="fas fa-building"></i> Partner / Parent Org</h4>
                <ul class="task-action-list">
                    <li><a href="#createContract"><i class="fas fa-file-signature"></i> Create Contract</a></li>
                    <li><a href="#assignCrew"><i class="fas fa-user-plus"></i> Assign Crew</a></li>
                    <li><a href="#createWorkflow"><i class="fas fa-sitemap"></i> Create Task Workflow</a></li>
                    <li><a href="#scheduleCrewStart"><i class="fas fa-calendar-plus"></i> Schedule Crew Start</a></li>
                    <li><a href="#alertJobClaim"><i class="fas fa-bell"></i> Job-Claim Alerts</a></li>
                    <li><a href="#alertCrewAssign"><i class="fas fa-bell"></i> Crew-Assigned Alerts</a></li>
                </ul>
            </article>
            <article class="task-group-card is-domain-subcontractor">
                <h4><i class="fas fa-hard-hat"></i> Subcontractors</h4>
                <ul class="task-action-list">
                    <li><a href="#suggestSubTasks"><i class="fas fa-lightbulb"></i> Suggest Tasks to Sub</a></li>
                    <li><a href="#uploadQuotes"><i class="fas fa-file-arrow-up"></i> Upload Quotes &amp; Estimates</a></li>
                    <li><a href="#alertSub"><i class="fas fa-bell"></i> Alert Sub of Changes</a></li>
                    <li><a href="#scheduleSubQuote"><i class="fas fa-calendar-day"></i> Schedule Sub Quote</a></li>
                    <li><a href="#scheduleSubStart"><i class="fas fa-calendar-plus"></i> Schedule Sub Start</a></li>
                    <li><a href="#approveSubInvoice"><i class="fas fa-circle-check"></i> Approve Sub Invoice</a></li>
                </ul>
            </article>
            <article class="task-group-card is-domain-volunteer">
                <h4><i class="fas fa-hands-helping"></i> Volunteers</h4>
                <ul class="task-action-list">
                    <li><a href="#setVolunteerSlots"><i class="fas fa-user-group"></i> Set Volunteer Slots</a></li>
                    <li><a href="#setExperienceLevel"><i class="fas fa-medal"></i> Set Required Experience Level</a></li>
                    <li><a href="#alertVolunteers"><i class="fas fa-bell"></i> Alert Capable Volunteers</a></li>
                    <li><a href="#scheduleVolunteerGroup"><i class="fas fa-calendar-week"></i> Schedule Volunteer Groups</a></li>
                    <li><a href="#alertSlotManager"><i class="fas fa-user-tie"></i> Notify Slot Manager</a></li>
                </ul>
            </article>
            <article class="task-group-card is-domain-reports">
                <h4><i class="fas fa-chart-line"></i> Reports &amp; Escalations</h4>
                <ul class="task-action-list">
                    <li><a href="#flagIssue"><i class="fas fa-flag"></i> Flag Issue</a></li>
                    <li><a href="#escalateEnvoy"><i class="fas fa-arrow-up-right-from-square"></i> Escalate to Envoy</a></li>
                    <li><a href="#weeklyReport"><i class="fas fa-file-lines"></i> Weekly Status Report</a></li>
                    <li><a href="#teamPerformance"><i class="fas fa-chart-line"></i> Team Performance</a></li>
                    <li><a href="#projectCloseout"><i class="fas fa-flag-checkered"></i> Project Closeout</a></li>
                </ul>
            </article>
        </div>
    </section>

    <p class="role-notice">
        <i class="fas fa-circle-info"></i>
        <span>
            <strong>Portfolio-first view:</strong>
            This dashboard surfaces all active projects, their crew assignments, budgets,
            and risks on a single screen so a PM can triage in under a minute. Data joins
            <code>cases</code>, <code>work_orders</code>, <code>project_assignments</code>,
            and <code>project_escalations</code> via the <code>project_status_view</code>.
            See <code>technical-plan-project-manager.md</code> for the full schema.
        </span>
    </p>
</section>
