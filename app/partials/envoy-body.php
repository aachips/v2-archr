<?php
/** Body partial generated from app/templates/envoy.html.
    Hard-coded sample data is preserved as-is (prototype). */
?>
<section class="portal-page active" id="dashboardPage" data-page-title="Envoy Dashboard">

    <!-- Hero / Envoy context (welcome message comes first) -->
    <div class="dash-hero mobile-show">
        <div>
            <h2>Good morning, Eileen</h2>
            <p>Coalition oversight &middot; 6 partner orgs &middot; 4 contracts awaiting signature &middot; Last sync 9:02 AM</p>
        </div>
        <div class="dash-hero-meta">
            <span class="hero-count-label">Active Cases (Coalition)</span>
            <span class="hero-count">142</span>
        </div>
    </div>

    <!-- Global Case Search (kept visible on mobile per landing-page spec) -->
    <section class="case-search mobile-show" aria-labelledby="case-search-h">
        <h2 id="case-search-h" class="sr-only" style="position:absolute; left:-9999px;">Global Case Search</h2>
        <div class="case-search-row">
            <span class="case-search-icon" aria-hidden="true"><i class="fas fa-magnifying-glass"></i></span>
            <input type="search" class="case-search-input" id="globalCaseSearch"
                placeholder="Search coalition by case # &middot; org &middot; contract &middot; funder"
                aria-label="Global case search">
            <a href="#caseSearchAdvanced" class="case-search-advanced"><i class="fas fa-sliders"></i> Advanced</a>
            <button type="button" class="btn btn-primary btn-sm" id="globalCaseSearchBtn"><i class="fas fa-arrow-right"></i> Search</button>
        </div>
        <div class="case-search-filters" role="group" aria-label="Quick filters">
            <button type="button" class="case-search-filter is-active">Coalition-wide</button>
            <button type="button" class="case-search-filter">By org</button>
            <button type="button" class="case-search-filter">Awaiting approval</button>
            <button type="button" class="case-search-filter">Funder reports</button>
            <button type="button" class="case-search-filter">Eligibility flagged</button>
            <button type="button" class="case-search-filter">At risk</button>
        </div>
    </section>

    <!-- Mobile-only hint: surfaces the hamburger as the path to every other feature -->
    <p class="mobile-hint mobile-show" role="note">
        <i class="fas fa-circle-info" aria-hidden="true"></i>
        <span>Tap <i class="fas fa-bars" aria-hidden="true"></i> to open approvals, funding, org health, and every other tool. Each menu item is its own page.</span>
    </p>

    <!-- Command Cards: Eligible/Accepted Jobs + Tasks (per data-flow-chart.md) -->
    <section class="dash-section" aria-labelledby="cmd-h">
        <h3 class="dash-section-title" id="cmd-h"><i class="fas fa-bullseye"></i> Command Center</h3>
        <div class="command-grid">
            <article class="command-card" aria-labelledby="elig-jobs-h">
                <div class="command-card-head">
                    <div>
                        <div class="command-card-label" id="elig-jobs-h">Eligible Jobs</div>
                        <div class="command-card-count">7</div>
                        <div class="command-card-sub">Match coalition eligibility &middot; oldest 5 days</div>
                    </div>
                    <span class="command-card-icon" aria-hidden="true"><i class="fas fa-briefcase"></i></span>
                </div>
                <div class="command-card-actions">
                    <a href="#marketplaceJobs" class="btn btn-primary"><i class="fas fa-hand-holding-heart"></i> Claim</a>
                    <a href="#suggestJobOrg" class="btn btn-secondary"><i class="fas fa-share-from-square"></i> Suggest</a>
                </div>
            </article>
            <article class="command-card is-accepted" aria-labelledby="acc-jobs-h">
                <div class="command-card-head">
                    <div>
                        <div class="command-card-label" id="acc-jobs-h">Accepted Jobs</div>
                        <div class="command-card-count">12</div>
                        <div class="command-card-sub">Routed to PMs &middot; 9 in progress</div>
                    </div>
                    <span class="command-card-icon" aria-hidden="true"><i class="fas fa-circle-check"></i></span>
                </div>
                <div class="command-card-actions">
                    <a href="#acceptedJobs" class="btn btn-primary"><i class="fas fa-folder-open"></i> View</a>
                    <a href="#notifyPM" class="btn btn-secondary"><i class="fas fa-bell"></i> Notify PM</a>
                </div>
            </article>
            <article class="command-card is-tasks" aria-labelledby="elig-tasks-h">
                <div class="command-card-head">
                    <div>
                        <div class="command-card-label" id="elig-tasks-h">Eligible Tasks</div>
                        <div class="command-card-count">23</div>
                        <div class="command-card-sub">Across 4 capability domains</div>
                    </div>
                    <span class="command-card-icon" aria-hidden="true"><i class="fas fa-list-check"></i></span>
                </div>
                <div class="command-card-actions">
                    <a href="#marketplaceTasks" class="btn btn-primary"><i class="fas fa-hand-holding-heart"></i> Claim</a>
                    <a href="#suggestTaskOrg" class="btn btn-secondary"><i class="fas fa-share-from-square"></i> Suggest</a>
                </div>
            </article>
            <article class="command-card is-tasks is-accepted" aria-labelledby="acc-tasks-h">
                <div class="command-card-head">
                    <div>
                        <div class="command-card-label" id="acc-tasks-h">Accepted Tasks</div>
                        <div class="command-card-count">31</div>
                        <div class="command-card-sub">Assigned to subcontractors &middot; 4 due this week</div>
                    </div>
                    <span class="command-card-icon" aria-hidden="true"><i class="fas fa-square-check"></i></span>
                </div>
                <div class="command-card-actions">
                    <a href="#acceptedTasks" class="btn btn-primary"><i class="fas fa-folder-open"></i> View</a>
                    <a href="#notifySub" class="btn btn-secondary"><i class="fas fa-bell"></i> Notify Sub</a>
                </div>
            </article>
        </div>
    </section>

    <!-- Coalition KPI strip -->
    <section class="dash-section" aria-labelledby="kpi-h">
        <h3 class="dash-section-title" id="kpi-h"><i class="fas fa-chart-pie"></i> Coalition Overview</h3>
        <div class="kpi-grid">
            <div class="kpi kpi-coalition">
                <span class="kpi-label">Active Cases</span>
                <span class="kpi-value">142</span>
                <span class="kpi-sub">Across 6 partner orgs &middot; +14 this month</span>
                <span class="kpi-foot"><a href="#coalition">Coalition view &rarr;</a></span>
            </div>
            <div class="kpi kpi-funding">
                <span class="kpi-label">Coalition Funding</span>
                <span class="kpi-value">$3.8M<span style="font-size:var(--fs-md); color:var(--color-text-muted); font-weight:500;"> / $4.6M</span></span>
                <span class="kpi-sub">83% utilized &middot; $820k remaining</span>
                <span class="kpi-foot"><a href="#fundingOverview">Funding dashboard &rarr;</a></span>
            </div>
            <div class="kpi kpi-pending">
                <span class="kpi-label">Pending Approvals</span>
                <span class="kpi-value">9</span>
                <span class="kpi-sub">4 contracts &middot; 3 program changes &middot; 2 budgets</span>
                <span class="kpi-foot"><a href="#contracts">Review queue &rarr;</a></span>
            </div>
            <div class="kpi kpi-orgs">
                <span class="kpi-label">Org Health</span>
                <span class="kpi-value">5<span style="font-size:var(--fs-md); color:var(--color-text-muted); font-weight:500;"> / 6</span></span>
                <span class="kpi-sub">Strong/steady &middot; 1 org on watch</span>
                <span class="kpi-foot"><a href="#orgHealth">Org health &rarr;</a></span>
            </div>
        </div>
    </section>

    <!-- Pending Approvals + Funding by Org (two-col) -->
    <section class="dash-section">
        <div class="two-col">
            <article class="panel" aria-labelledby="approvals-h">
                <div class="panel-header">
                    <h3 id="approvals-h"><i class="fas fa-stamp"></i> Pending Approvals</h3>
                    <a href="#contracts" class="see-all-link">View all &rarr;</a>
                </div>
                <ul class="approval-list">
                    <li class="approval-item is-urgent">
                        <span class="appr-icon" aria-hidden="true"><i class="fas fa-file-signature"></i></span>
                        <div>
                            <div class="appr-title">Subcontractor MSA &middot; Mountain Roof Co.</div>
                            <div class="appr-meta">Coalition-wide master agreement &middot; SLA: 48 hrs &middot; 38 hrs left</div>
                        </div>
                        <a href="#contract-msa" class="btn btn-primary btn-sm"><i class="fas fa-pen-nib"></i> Sign</a>
                    </li>
                    <li class="approval-item">
                        <span class="appr-icon" aria-hidden="true"><i class="fas fa-file-signature"></i></span>
                        <div>
                            <div class="appr-title">Funder agreement &middot; Bright Future Trust</div>
                            <div class="appr-meta">$420k programmatic grant &middot; renewal</div>
                        </div>
                        <a href="#contract-bft" class="btn btn-secondary btn-sm">Review</a>
                    </li>
                    <li class="approval-item is-policy">
                        <span class="appr-icon" aria-hidden="true"><i class="fas fa-file-pen"></i></span>
                        <div>
                            <div class="appr-title">Eligibility change &middot; AMI &lt; 80%</div>
                            <div class="appr-meta">Proposed by Hilltop CDC &middot; affects 3 orgs</div>
                        </div>
                        <a href="#programChanges" class="btn btn-secondary btn-sm">Review</a>
                    </li>
                    <li class="approval-item is-policy">
                        <span class="appr-icon" aria-hidden="true"><i class="fas fa-coins"></i></span>
                        <div>
                            <div class="appr-title">Budget revision &middot; Eastside Habitat</div>
                            <div class="appr-meta">+$65k contingency for Q1 emergency repairs</div>
                        </div>
                        <a href="#budgetApproval" class="btn btn-secondary btn-sm">Review</a>
                    </li>
                </ul>
            </article>

            <article class="panel" aria-labelledby="funding-h">
                <div class="panel-header">
                    <h3 id="funding-h"><i class="fas fa-sack-dollar"></i> Funding by Org</h3>
                    <a href="#fundingByOrg" class="see-all-link">Full report &rarr;</a>
                </div>
                <div style="overflow-x:auto;">
                <table class="funding-table">
                    <thead>
                        <tr><th>Organization</th><th>Utilization</th><th class="col-num">Spent / Budget</th></tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><span class="org-name">Hilltop CDC</span></td>
                            <td><div class="progress-cell"><span class="meter"><span class="meter-fill is-success" style="width:74%;"></span></span><span class="pct">74%</span></div></td>
                            <td class="col-num">$890k / $1.2M</td>
                        </tr>
                        <tr>
                            <td><span class="org-name">Eastside Habitat</span></td>
                            <td><div class="progress-cell"><span class="meter"><span class="meter-fill is-warning" style="width:92%;"></span></span><span class="pct">92%</span></div></td>
                            <td class="col-num">$735k / $800k</td>
                        </tr>
                        <tr>
                            <td><span class="org-name">Riverside Renew</span></td>
                            <td><div class="progress-cell"><span class="meter"><span class="meter-fill" style="width:55%;"></span></span><span class="pct">55%</span></div></td>
                            <td class="col-num">$385k / $700k</td>
                        </tr>
                        <tr>
                            <td><span class="org-name">Southside Build</span></td>
                            <td><div class="progress-cell"><span class="meter"><span class="meter-fill is-success" style="width:68%;"></span></span><span class="pct">68%</span></div></td>
                            <td class="col-num">$612k / $900k</td>
                        </tr>
                        <tr>
                            <td><span class="org-name">North Park Coalition</span></td>
                            <td><div class="progress-cell"><span class="meter"><span class="meter-fill is-danger" style="width:98%;"></span></span><span class="pct">98%</span></div></td>
                            <td class="col-num">$588k / $600k</td>
                        </tr>
                        <tr>
                            <td><span class="org-name">Anchor Community</span></td>
                            <td><div class="progress-cell"><span class="meter"><span class="meter-fill" style="width:60%;"></span></span><span class="pct">60%</span></div></td>
                            <td class="col-num">$240k / $400k</td>
                        </tr>
                    </tbody>
                </table>
                </div>
            </article>
        </div>
    </section>

    <!-- Org Health Summary -->
    <section class="dash-section" aria-labelledby="orghealth-h">
        <div class="section-header-row">
            <h3 class="dash-section-title" id="orghealth-h" style="margin:0;"><i class="fas fa-heart-pulse"></i> Org Health Summary</h3>
            <a href="#orgHealth" class="see-all-link">All orgs &rarr;</a>
        </div>
        <article class="panel">
            <ul class="org-list">
                <li class="org-item is-strong">
                    <div class="org-head"><span class="org-title">Hilltop CDC</span><span class="pill pill-green"><i class="fas fa-circle-check"></i> Strong</span></div>
                    <div class="org-body">Steady throughput, on budget, no escalations this month.</div>
                    <div class="org-stats"><span>Active cases: <strong>38</strong></span><span>Completion: <strong>92%</strong></span><span>Avg cycle: <strong>54d</strong></span></div>
                </li>
                <li class="org-item is-strong">
                    <div class="org-head"><span class="org-title">Southside Build</span><span class="pill pill-green"><i class="fas fa-circle-check"></i> Strong</span></div>
                    <div class="org-body">Volunteer pipeline healthy, contracts current.</div>
                    <div class="org-stats"><span>Active cases: <strong>27</strong></span><span>Completion: <strong>88%</strong></span><span>Avg cycle: <strong>61d</strong></span></div>
                </li>
                <li class="org-item">
                    <div class="org-head"><span class="org-title">Riverside Renew</span><span class="pill pill-gold"><i class="fas fa-circle-info"></i> Steady</span></div>
                    <div class="org-body">Slower intake; eligibility rules under review.</div>
                    <div class="org-stats"><span>Active cases: <strong>19</strong></span><span>Completion: <strong>81%</strong></span><span>Avg cycle: <strong>68d</strong></span></div>
                </li>
                <li class="org-item is-watch">
                    <div class="org-head"><span class="org-title">Eastside Habitat</span><span class="pill pill-amber"><i class="fas fa-eye"></i> On watch</span></div>
                    <div class="org-body">92% budget utilization with 3 months remaining in cycle.</div>
                    <div class="org-stats"><span>Active cases: <strong>31</strong></span><span>Completion: <strong>76%</strong></span><span>Avg cycle: <strong>72d</strong></span></div>
                </li>
                <li class="org-item is-risk">
                    <div class="org-head"><span class="org-title">North Park Coalition</span><span class="pill pill-red"><i class="fas fa-triangle-exclamation"></i> At risk</span></div>
                    <div class="org-body">Budget 98% spent &middot; 2 open escalations &middot; needs envoy review.</div>
                    <div class="org-stats"><span>Active cases: <strong>17</strong></span><span>Completion: <strong>64%</strong></span><span>Avg cycle: <strong>89d</strong></span></div>
                </li>
                <li class="org-item">
                    <div class="org-head"><span class="org-title">Anchor Community</span><span class="pill pill-gold"><i class="fas fa-seedling"></i> New</span></div>
                    <div class="org-body">Onboarded last quarter &middot; ramping eligibility coverage.</div>
                    <div class="org-stats"><span>Active cases: <strong>10</strong></span><span>Completion: <strong>70%</strong></span><span>Avg cycle: <strong>58d</strong></span></div>
                </li>
            </ul>
        </article>
    </section>

    <!-- Ongoing Work table (Crew | Job + days remaining | Next Up per data-flow spec) -->
    <section class="dash-section" aria-labelledby="ongoing-h">
        <div class="section-header-row">
            <h3 class="dash-section-title" id="ongoing-h" style="margin:0;"><i class="fas fa-person-digging"></i> Ongoing Work</h3>
            <a href="#acceptedJobs" class="see-all-link">View all work &rarr;</a>
        </div>
        <article class="panel" style="padding:0; overflow:hidden;">
            <div style="overflow-x:auto;">
            <table class="ongoing-table">
                <thead>
                    <tr>
                        <th>Work Crew</th>
                        <th>Job &middot; Time Remaining</th>
                        <th>Next Up (Crew Lead)</th>
                        <th class="col-num">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><div class="crew-cell"><span class="crew-dot">HC</span> Hilltop &mdash; Crew A</div></td>
                        <td>
                            <div class="job-case">42-CHERRY</div>
                            <div class="job-meta">Roofing &middot; <strong>3 days remaining</strong></div>
                        </td>
                        <td>
                            <div class="next-up-date">Sarah M. &middot; Dec 13, 8:00 AM</div>
                            <div class="next-up-task">Decking replacement &mdash; awaiting change order</div>
                        </td>
                        <td class="col-num">
                            <a href="#taskCapacity" class="btn btn-secondary btn-sm"><i class="fas fa-scale-balanced"></i> Capacity</a>
                        </td>
                    </tr>
                    <tr>
                        <td><div class="crew-cell"><span class="crew-dot">EH</span> Eastside &mdash; Crew B</div></td>
                        <td>
                            <div class="job-case">15-MERRILL</div>
                            <div class="job-meta">Plumbing &middot; <strong>1 day remaining</strong></div>
                        </td>
                        <td>
                            <div class="next-up-date">David C. &middot; Dec 12, 9:30 AM</div>
                            <div class="next-up-task">Final fixture install + walkthrough</div>
                        </td>
                        <td class="col-num">
                            <a href="#programRequirements" class="btn btn-secondary btn-sm"><i class="fas fa-sliders"></i> Eligibility</a>
                        </td>
                    </tr>
                    <tr>
                        <td><div class="crew-cell"><span class="crew-dot">SB</span> Southside &mdash; Crew C</div></td>
                        <td>
                            <div class="job-case">8-OAKLAND</div>
                            <div class="job-meta">Electrical &middot; <strong>14 days remaining</strong></div>
                        </td>
                        <td>
                            <div class="next-up-date">Lisa K. &middot; Pending permit</div>
                            <div class="next-up-task">Panel upgrade &mdash; city inspection scheduled</div>
                        </td>
                        <td class="col-num">
                            <a href="#taskCapacity" class="btn btn-secondary btn-sm"><i class="fas fa-scale-balanced"></i> Capacity</a>
                        </td>
                    </tr>
                    <tr>
                        <td><div class="crew-cell"><span class="crew-dot">RR</span> Riverside &mdash; Crew A</div></td>
                        <td>
                            <div class="job-case">3-SUNSET</div>
                            <div class="job-meta">Accessibility ramp &middot; <strong>6 days remaining</strong></div>
                        </td>
                        <td>
                            <div class="next-up-date">Mike T. &middot; Dec 14, 7:30 AM</div>
                            <div class="next-up-task">Frame inspection + concrete pour</div>
                        </td>
                        <td class="col-num">
                            <a href="#programRequirements" class="btn btn-secondary btn-sm"><i class="fas fa-sliders"></i> Eligibility</a>
                        </td>
                    </tr>
                </tbody>
            </table>
            </div>
            <div class="ongoing-foot">
                <span><strong>4 active crews</strong> across 4 orgs &middot; 1 blocked by permit</span>
                <div style="display:flex; gap:var(--space-2); flex-wrap:wrap;">
                    <a href="#taskCapacity" class="btn btn-secondary btn-sm"><i class="fas fa-scale-balanced"></i> Edit Task Capacity</a>
                    <a href="#programRequirements" class="btn btn-primary btn-sm"><i class="fas fa-sliders"></i> Edit Program Requirements</a>
                </div>
            </div>
        </article>
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
                            <div class="alert-detail">Routed to Hilltop CDC PM queue. 12 min ago</div>
                        </div>
                        <a href="#eventDetails" class="btn btn-secondary btn-sm">Open</a>
                    </li>
                    <li class="alert-row is-warning">
                        <span class="alert-dot" aria-hidden="true"><i class="fas fa-file-signature"></i></span>
                        <div>
                            <div class="alert-title">Contract awaiting signature</div>
                            <div class="alert-detail">Mountain Roof MSA &mdash; SLA 38 hrs remaining. 1 hr ago</div>
                        </div>
                        <a href="#contract-msa" class="btn btn-secondary btn-sm">Open</a>
                    </li>
                    <li class="alert-row is-warning">
                        <span class="alert-dot" aria-hidden="true"><i class="fas fa-sliders"></i></span>
                        <div>
                            <div class="alert-title">Eligibility change proposed</div>
                            <div class="alert-detail">Hilltop CDC proposed AMI threshold update. 3 hrs ago</div>
                        </div>
                        <a href="#programChanges" class="btn btn-secondary btn-sm">Open</a>
                    </li>
                    <li class="alert-row is-danger">
                        <span class="alert-dot" aria-hidden="true"><i class="fas fa-triangle-exclamation"></i></span>
                        <div>
                            <div class="alert-title">Budget threshold &middot; North Park Coalition</div>
                            <div class="alert-detail">98% of cycle budget consumed with 11 weeks remaining. 5 hrs ago</div>
                        </div>
                        <a href="#orgHealth" class="btn btn-secondary btn-sm">Open</a>
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
                        <div class="msg-from">Jamie Rivera <span class="pill pill-blue" style="margin-left:6px;">Project Manager</span></div>
                        <div class="msg-body">"42-CHERRY change order requires envoy sign-off &mdash; subcontractor cost 12% over MSA cap."</div>
                        <div class="msg-meta"><span>22 min ago</span><a href="#message-detail" class="btn btn-secondary btn-sm">Reply</a></div>
                    </li>
                    <li class="msg-item is-system">
                        <div class="msg-from">System <span class="pill pill-grey" style="margin-left:6px;">Funder report</span></div>
                        <div class="msg-body">Quarterly funder summary for <strong>Bright Future Trust</strong> compiled &mdash; ready to review.</div>
                        <div class="msg-meta"><span>Today, 8:47 AM</span><a href="#reports" class="btn btn-secondary btn-sm">Review</a></div>
                    </li>
                    <li class="msg-item">
                        <div class="msg-from">Renee O. <span class="pill pill-gold" style="margin-left:6px;">Org Admin &middot; North Park</span></div>
                        <div class="msg-body">"Requesting emergency budget revision &mdash; two storm-damage cases came in last week."</div>
                        <div class="msg-meta"><span>Yesterday, 4:12 PM</span><a href="#budgetApproval" class="btn btn-secondary btn-sm">Read</a></div>
                    </li>
                    <li class="msg-item">
                        <div class="msg-from">Board Liaison <span class="pill pill-blue" style="margin-left:6px;">Board</span></div>
                        <div class="msg-body">"Need coalition performance summary by Friday EOD &mdash; board meeting Monday."</div>
                        <div class="msg-meta"><span>Yesterday, 11:04 AM</span><a href="#reports" class="btn btn-secondary btn-sm">Read</a></div>
                    </li>
                </ul>
            </article>
        </div>
    </section>

    <!-- Envoy Action Row -->
    <nav class="envoy-action-row" aria-label="Envoy quick actions">
        <a href="#contracts" class="envoy-action-btn"><i class="fas fa-pen-nib"></i> Approve Contract</a>
        <a href="#programRequirements" class="envoy-action-btn"><i class="fas fa-sliders"></i> Set Eligibility</a>
        <a href="#reports" class="envoy-action-btn"><i class="fas fa-chart-line"></i> Pull Report</a>
        <a href="#orgOnboarding" class="envoy-action-btn"><i class="fas fa-building-circle-arrow-right"></i> Onboard Org</a>
        <a href="#budgetApproval" class="envoy-action-btn"><i class="fas fa-sack-dollar"></i> Approve Budget</a>
        <a href="#policyUpdates" class="envoy-action-btn"><i class="fas fa-book"></i> Update Policy</a>
    </nav>

    <!-- Task Context Groups (from data-flow-chart.md + notes.md) -->
    <section class="dash-section" aria-labelledby="tasks-h">
        <h3 class="dash-section-title" id="tasks-h"><i class="fas fa-layer-group"></i> Task Context Groups</h3>
        <div class="task-groups">
            <article class="task-group-card is-domain-jobs">
                <h4><i class="fas fa-briefcase"></i> Jobs &amp; Tasks</h4>
                <ul class="task-action-list">
                    <li><a href="#marketplaceJobs"><i class="fas fa-hand-holding-heart"></i> Claim Jobs</a></li>
                    <li><a href="#rejectJobs"><i class="fas fa-circle-xmark"></i> Reject Jobs</a></li>
                    <li><a href="#marketplaceTasks"><i class="fas fa-hand-pointer"></i> Claim Tasks</a></li>
                    <li><a href="#rejectTasks"><i class="fas fa-square-xmark"></i> Reject Tasks</a></li>
                    <li><a href="#justifyJobReject"><i class="fas fa-comment-dots"></i> Justify Job Rejection</a></li>
                    <li><a href="#justifyTaskReject"><i class="fas fa-comment-dots"></i> Justify Task Rejection</a></li>
                </ul>
            </article>
            <article class="task-group-card is-domain-orgs">
                <h4><i class="fas fa-share-from-square"></i> Suggest &amp; Route</h4>
                <ul class="task-action-list">
                    <li><a href="#suggestJobOrg"><i class="fas fa-arrow-right-arrow-left"></i> Suggest Job to Org</a></li>
                    <li><a href="#suggestTaskOrg"><i class="fas fa-arrow-right-arrow-left"></i> Suggest Task to Org</a></li>
                    <li><a href="#sendSuggestion"><i class="fas fa-paper-plane"></i> Send Suggestion Notification</a></li>
                    <li><a href="#orgOnboarding"><i class="fas fa-user-plus"></i> Org Onboarding</a></li>
                    <li><a href="#orgHealth"><i class="fas fa-heart-pulse"></i> Review Org Health</a></li>
                </ul>
            </article>
            <article class="task-group-card is-domain-eligibility">
                <h4><i class="fas fa-sliders"></i> Eligibility &amp; Capacity</h4>
                <ul class="task-action-list">
                    <li><a href="#programRequirements"><i class="fas fa-list-check"></i> Update Program Eligibility</a></li>
                    <li><a href="#taskCapacity"><i class="fas fa-scale-balanced"></i> Update Org Task Capacity</a></li>
                    <li><a href="#policyUpdates"><i class="fas fa-book"></i> Update Policy &amp; Guidelines</a></li>
                    <li><a href="#programChanges"><i class="fas fa-file-pen"></i> Approve Program Changes</a></li>
                </ul>
            </article>
            <article class="task-group-card is-domain-notify">
                <h4><i class="fas fa-bell"></i> Notifications</h4>
                <ul class="task-action-list">
                    <li><a href="#notifyPM"><i class="fas fa-bullhorn"></i> Notify PM of Claimed Job/Task</a></li>
                    <li><a href="#notifySub"><i class="fas fa-hard-hat"></i> Notify Capable Subcontractor</a></li>
                    <li><a href="#alerts"><i class="fas fa-bell"></i> Manage Alerts</a></li>
                    <li><a href="#messages"><i class="fas fa-envelope"></i> Messages</a></li>
                </ul>
            </article>
            <article class="task-group-card is-domain-policy">
                <h4><i class="fas fa-pen-nib"></i> Approvals &amp; Contracts</h4>
                <ul class="task-action-list">
                    <li><a href="#contracts"><i class="fas fa-file-signature"></i> Approve Contracts (e-sign)</a></li>
                    <li><a href="#budgetApproval"><i class="fas fa-coins"></i> Approve Budget</a></li>
                    <li><a href="#funderRelations"><i class="fas fa-handshake"></i> Funder Agreements</a></li>
                    <li><a href="#strategicNotes"><i class="fas fa-lightbulb"></i> Strategic Notes</a></li>
                </ul>
            </article>
            <article class="task-group-card is-domain-reports">
                <h4><i class="fas fa-chart-line"></i> Reports &amp; Performance</h4>
                <ul class="task-action-list">
                    <li><a href="#performanceMetrics"><i class="fas fa-chart-pie"></i> Performance Metrics</a></li>
                    <li><a href="#fundingOverview"><i class="fas fa-sack-dollar"></i> Funding Dashboard</a></li>
                    <li><a href="#reports"><i class="fas fa-file-lines"></i> Pull Summary Reports</a></li>
                    <li><a href="#coalition"><i class="fas fa-globe"></i> Coalition Overview</a></li>
                </ul>
            </article>
        </div>
    </section>

    <p class="role-notice">
        <i class="fas fa-circle-info"></i>
        <span>
            <strong>Helicopter view:</strong>
            The Envoy dashboard surfaces coalition-wide totals, pending approvals, funding
            utilization by org, and org health on a single screen so a leader can triage
            in under a minute &mdash; without diving into individual case details. Data
            joins <code>orgs</code>, <code>contracts</code>, <code>program_eligibility</code>,
            <code>budget_cycles</code>, and the <code>coalition_health_view</code>.
            See <code>notes.md</code> and <code>data-flow-chart.md</code> for the source spec.
        </span>
    </p>
</section>
