<?php
/** Body partial generated from app/templates/admin.html.
    Hard-coded sample data is preserved as-is (prototype). */
?>
<section class="portal-page active" data-page-title="Organization Admin">
        <p class="login-banner" role="status">
<i class="fas fa-user-shield"></i>
<span>Organization admin view &mdash; manage applications, tasks, communications, and scheduling for your org.</span>
        </p>

        <section class="dash-hero" aria-labelledby="dash-title">
<div>
    <h2 id="dash-title">Welcome back, Alex</h2>
    <p>Habitat for Humanity &middot; Buncombe County &middot; 12 active applications.</p>
    <p class="updated"><i class="far fa-clock"></i> Last updated today, 9:14 AM</p>
</div>
<div class="dash-hero-meta">
    <span class="org-badge"><i class="fas fa-building"></i> Habitat for Humanity</span>
</div>
        </section>

        <!-- ===== 4 task metric counters ===== -->
        <section aria-labelledby="task-metrics-h">
<h3 class="dash-section-title" id="task-metrics-h"><i class="fas fa-list-check"></i> Task Overview</h3>
<div class="task-metrics">
    <div class="task-metric-card">
        <div class="metric-icon"><i class="fas fa-spinner fa-pulse"></i></div>
        <div class="metric-number">8</div>
        <div class="metric-label">Processing Tasks</div>
        <a href="#processList" class="metric-btn">Process <i class="fas fa-arrow-right"></i></a>
    </div>
    <div class="task-metric-card">
        <div class="metric-icon"><i class="fas fa-check-double"></i></div>
        <div class="metric-number">4</div>
        <div class="metric-label">Verification Tasks</div>
        <a href="#verifyList" class="metric-btn">Verify <i class="fas fa-arrow-right"></i></a>
    </div>
    <div class="task-metric-card">
        <div class="metric-icon"><i class="fas fa-comments"></i></div>
        <div class="metric-number">12</div>
        <div class="metric-label">Communication Tasks</div>
        <a href="#commsDashboard" class="metric-btn">Comms <i class="fas fa-arrow-right"></i></a>
    </div>
    <div class="task-metric-card">
        <div class="metric-icon"><i class="fas fa-calendar-week"></i></div>
        <div class="metric-number">3</div>
        <div class="metric-label">Scheduling Tasks</div>
        <a href="#schedulingDashboard" class="metric-btn">Schedule <i class="fas fa-arrow-right"></i></a>
    </div>
</div>
        </section>

        <!-- ===== Recent Applications ===== -->
        <section aria-labelledby="recent-apps-h">
<div class="section-header-row">
    <h3 class="dash-section-title" id="recent-apps-h" style="margin:0;"><i class="fas fa-clock"></i> Recent Applications</h3>
    <a href="#applications" class="see-all-link">View all &rarr;</a>
</div>
<div class="app-list">
    <article class="app-list-item">
        <div class="app-info">
            <div class="app-id">ARCHR-2024-001234 <span class="badge-pending">Pending docs</span></div>
            <div class="app-meta"><span>John Henderson</span><span>42 Cherry St</span><span>Submitted Nov 15</span></div>
        </div>
        <div class="app-nextstep">
            <div class="nextstep-label">Next Step</div>
            <div class="nextstep-text">Upload income verification</div>
            <div class="holdingon-text"><i class="far fa-clock"></i> Holding on: missing bank statements</div>
        </div>
        <div class="app-actions">
            <a href="#appDetails" class="btn btn-secondary btn-sm">Continue</a>
        </div>
    </article>
    <article class="app-list-item">
        <div class="app-info">
            <div class="app-id">ARCHR-2024-001189 <span class="badge-pending">Assessment pending</span></div>
            <div class="app-meta"><span>Sarah Williams</span><span>15 Merrill Ave</span><span>Submitted Nov 10</span></div>
        </div>
        <div class="app-nextstep">
            <div class="nextstep-label">Next Step</div>
            <div class="nextstep-text">Schedule home assessment</div>
            <div class="holdingon-text"><i class="far fa-clock"></i> Holding on: awaiting applicant availability</div>
        </div>
        <div class="app-actions">
            <a href="#appDetails" class="btn btn-secondary btn-sm">Continue</a>
        </div>
    </article>
    <article class="app-list-item">
        <div class="app-info">
            <div class="app-id">ARCHR-2024-001103</div>
            <div class="app-meta"><span>James Thornton</span><span>8 Oakland Rd</span><span>Submitted Nov 5</span></div>
        </div>
        <div class="app-nextstep">
            <div class="nextstep-label">Next Step</div>
            <div class="nextstep-text">Contract review</div>
            <div class="holdingon-text"><i class="far fa-clock"></i> Holding on: awaiting internal approval</div>
        </div>
        <div class="app-actions">
            <a href="#appDetails" class="btn btn-secondary btn-sm">Continue</a>
        </div>
    </article>
</div>
        </section>

        <!-- ===== Latest Events + Latest Messages (two columns) ===== -->
        <section class="events-messages-grid" aria-label="Recent activity">
<article class="panel" aria-labelledby="events-h">
    <div class="panel-header">
        <h3 id="events-h"><i class="fas fa-history"></i> Latest Events</h3>
        <a href="#appAlerts" class="see-all-link">View all &rarr;</a>
    </div>
    <div class="events-list">
        <div class="event-item">
            <div class="event-icon"><i class="fas fa-file-upload"></i></div>
            <div class="event-content">
                <div class="event-title">Income docs uploaded for ARCHR-2024-001234</div>
                <div class="event-meta">Today, 9:14 AM &middot; John Henderson</div>
            </div>
        </div>
        <div class="event-item">
            <div class="event-icon"><i class="fas fa-handshake"></i></div>
            <div class="event-content">
                <div class="event-title">Eligibility confirmed for ARCHR-2024-001189</div>
                <div class="event-meta">Yesterday, 2:30 PM &middot; Matched with Habitat</div>
            </div>
        </div>
        <div class="event-item">
            <div class="event-icon"><i class="fas fa-calendar-check"></i></div>
            <div class="event-content">
                <div class="event-title">Assessment scheduled for ARCHR-2024-001103</div>
                <div class="event-meta">Dec 5, 2024 &middot; Dec 18 at 2:00 PM</div>
            </div>
        </div>
    </div>
</article>

<article class="panel" aria-labelledby="messages-h">
    <div class="panel-header">
        <h3 id="messages-h"><i class="fas fa-envelope"></i> Latest Messages</h3>
        <a href="#messageDetails" class="see-all-link">View all &rarr;</a>
    </div>
    <ul class="message-list">
        <li class="message-item">
            <strong>John Henderson</strong> &mdash; &ldquo;I&rsquo;ve uploaded my bank statements.&rdquo;
            <div class="message-meta"><a href="#messageDetails" class="btn btn-secondary btn-sm">Read Message</a></div>
        </li>
        <li class="message-item">
            <strong>Sarah Williams</strong> &mdash; &ldquo;Can we reschedule the assessment?&rdquo;
            <div class="message-meta"><a href="#messageDetails" class="btn btn-secondary btn-sm">Read Message</a></div>
        </li>
        <li class="message-item">
            <strong>System Alert</strong> &mdash; &ldquo;New subcontractor application pending review.&rdquo;
            <div class="message-meta"><a href="#messageDetails" class="btn btn-secondary btn-sm">Read Message</a></div>
        </li>
    </ul>
</article>
        </section>

        <!-- ===== 7-button quick action row ===== -->
        <nav class="admin-action-row" aria-label="Quick actions">
<a href="#appDetails" class="admin-action-btn"><i class="fas fa-folder-open"></i> Continue</a>
<a href="#processList" class="admin-action-btn"><i class="fas fa-tasks"></i> Process</a>
<a href="#verifyList" class="admin-action-btn"><i class="fas fa-check-circle"></i> Verify</a>
<a href="#commsDashboard" class="admin-action-btn"><i class="fas fa-comments"></i> Comms</a>
<a href="#schedulingDashboard" class="admin-action-btn"><i class="fas fa-calendar-alt"></i> Schedule</a>
<a href="#appAlerts" class="admin-action-btn"><i class="fas fa-bell"></i> Alerts</a>
<a href="#messageDetails" class="admin-action-btn"><i class="fas fa-envelope-open-text"></i> Message Details</a>
        </nav>

        <!-- ===== Coalition Metrics (KPIs + charts, tab-switched) ===== -->
        <section id="metrics" aria-labelledby="metrics-h">
<h3 class="dash-section-title" id="metrics-h"><i class="fas fa-chart-line"></i> Coalition Metrics</h3>

<!-- Top-line system KPIs -->
<div class="kpi-grid">
    <div class="kpi"><span class="kpi-label">Active Orgs</span><span class="kpi-value">8</span><span class="kpi-sub">All partners reporting</span></div>
    <div class="kpi kpi-blue"><span class="kpi-label">Open Jobs (Coalition)</span><span class="kpi-value">87</span><span class="kpi-sub">Across all orgs</span></div>
    <div class="kpi kpi-amber"><span class="kpi-label">Overdue Assessments</span><span class="kpi-value">19</span><span class="kpi-sub"><span class="pill pill-red">Action required</span></span></div>
    <div class="kpi kpi-green"><span class="kpi-label">YTD Investment</span><span class="kpi-value">$684K</span><span class="kpi-sub">Funds deployed in 2026</span></div>
</div>

<div class="dash-tabs" role="tablist">
    <button class="dash-tab active" data-section="week" role="tab" aria-selected="true">Past Week</button>
    <button class="dash-tab" data-section="alltime" role="tab" aria-selected="false">All Time</button>
    <button class="dash-tab" data-section="org" role="tab" aria-selected="false">Org-Specific</button>
</div>

<!-- ===== Past Week ===== -->
<section id="week" class="dash-section active" role="tabpanel" aria-label="Past Week metrics">
    <h3 class="dash-section-title"><i class="fas fa-calendar-week"></i> Past 7 Days &ndash; Coalition Intake</h3>
    <div class="kpi-grid">
        <div class="kpi"><span class="kpi-label">Total Applications</span><span class="kpi-value">42</span><span class="kpi-sub"><span class="delta-up">&#9650; 12%</span> vs prior week</span></div>
        <div class="kpi kpi-blue"><span class="kpi-label">Assessments Assigned</span><span class="kpi-value">31</span><span class="kpi-sub">Across 6 partner orgs</span></div>
        <div class="kpi kpi-green"><span class="kpi-label">Assessments Completed</span><span class="kpi-value">24</span><span class="kpi-sub">77% completion rate</span></div>
        <div class="kpi kpi-amber"><span class="kpi-label">Avg. Triage Score</span><span class="kpi-value">7.4<small> /10</small></span><span class="kpi-sub">Higher = greater urgency</span></div>
        <div class="kpi kpi-blue"><span class="kpi-label">Individuals Served</span><span class="kpi-value">118</span><span class="kpi-sub">From 42 households</span></div>
    </div>
    <div class="chart-grid cols-2">
        <article class="chart-card">
            <header><h4><i class="fas fa-dollar-sign"></i> Income Breakdown (% of AMI)</h4><span class="muted">42 applications</span></header>
            <div class="chart-canvas-wrap"><canvas id="weekIncomeChart"></canvas></div>
        </article>
        <article class="chart-card">
            <header><h4><i class="fas fa-map-marker-alt"></i> County Breakdown</h4><span class="muted">WNC service area</span></header>
            <div class="chart-canvas-wrap"><canvas id="weekCountyChart"></canvas></div>
        </article>
        <article class="chart-card">
            <header><h4><i class="fas fa-tools"></i> Issue Type Reported</h4><span class="muted">Primary need per applicant</span></header>
            <div class="chart-canvas-wrap"><canvas id="weekIssueChart"></canvas></div>
        </article>
    </div>
</section>

<!-- ===== All Time ===== -->
<section id="alltime" class="dash-section" role="tabpanel" aria-label="All Time metrics">
    <h3 class="dash-section-title"><i class="fas fa-infinity"></i> All-Time Coalition Outcomes</h3>
    <div class="kpi-grid">
        <div class="kpi"><span class="kpi-label">Total Jobs</span><span class="kpi-value">1,284</span><span class="kpi-sub">Since program launch</span></div>
        <div class="kpi kpi-amber"><span class="kpi-label">In Progress</span><span class="kpi-value">87</span><span class="kpi-sub">Active across partners</span></div>
        <div class="kpi kpi-green"><span class="kpi-label">Completed</span><span class="kpi-value">1,041</span><span class="kpi-sub">81% of all jobs</span></div>
        <div class="kpi kpi-gray"><span class="kpi-label">Withdrawn / Rejected / Ineligible</span><span class="kpi-value">156</span><span class="kpi-sub">12% of all jobs</span></div>
        <div class="kpi kpi-blue"><span class="kpi-label">Average Job Cost</span><span class="kpi-value">$6,420</span><span class="kpi-sub">Per completed job</span></div>
    </div>
    <div class="chart-grid cols-2">
        <article class="chart-card">
            <header><h4><i class="fas fa-dollar-sign"></i> Income Breakdown &ndash; All Jobs</h4><span class="muted">% of AMI</span></header>
            <div class="chart-canvas-wrap"><canvas id="allIncomeChart"></canvas></div>
        </article>
        <article class="chart-card">
            <header><h4><i class="fas fa-map-marker-alt"></i> County Breakdown &ndash; All Jobs</h4><span class="muted">Cumulative</span></header>
            <div class="chart-canvas-wrap"><canvas id="allCountyChart"></canvas></div>
        </article>
        <article class="chart-card" style="grid-column: 1 / -1;">
            <header><h4><i class="fas fa-coins"></i> Job Cost Range</h4><span class="muted">Highest &amp; lowest completed</span></header>
            <div class="cost-extremes">
                <div class="extreme high"><div class="label">Highest Job Cost</div><div class="amount">$28,750</div><div class="meta">Full roof replacement &middot; Buncombe Co. &middot; 2024</div></div>
                <div class="extreme low"><div class="label">Lowest Job Cost</div><div class="amount">$285</div><div class="meta">Wheelchair ramp repair &middot; Madison Co. &middot; 2025</div></div>
            </div>
        </article>
    </div>
</section>

<!-- ===== Org-Specific (admin-filtered) ===== -->
<section id="org" class="dash-section" role="tabpanel" aria-label="Org-Specific metrics">
    <h3 class="dash-section-title"><i class="fas fa-building"></i> Org Drill-Down: Asheville Habitat for Humanity</h3>
    <p class="muted"><i class="fas fa-info-circle"></i> Use the organization filter at the top of the page to switch which partner's data is shown here.</p>

    <div class="kpi-grid">
        <div class="kpi"><span class="kpi-label">Total Jobs</span><span class="kpi-value">312</span><span class="kpi-sub">Lifetime, this org</span></div>
        <div class="kpi kpi-amber"><span class="kpi-label">In Progress</span><span class="kpi-value">28</span><span class="kpi-sub"><span class="pill pill-amber">9 awaiting funds</span></span></div>
        <div class="kpi kpi-green"><span class="kpi-label">Completed</span><span class="kpi-value">241</span><span class="kpi-sub">77% of all jobs</span></div>
        <div class="kpi kpi-blue"><span class="kpi-label">Suggested to Org</span><span class="kpi-value">14</span><span class="kpi-sub">Pending acceptance</span></div>
    </div>

    <h3 class="dash-section-title"><i class="fas fa-clipboard-check"></i> Assessments</h3>
    <div class="kpi-grid">
        <div class="kpi kpi-blue"><span class="kpi-label">Assigned (Total)</span><span class="kpi-value">312</span><span class="kpi-sub">Lifetime</span></div>
        <div class="kpi kpi-green"><span class="kpi-label">Completed (Total)</span><span class="kpi-value">247</span><span class="kpi-sub">79% completion</span></div>
        <div class="kpi kpi-amber"><span class="kpi-label">Pending</span><span class="kpi-value">65</span><span class="kpi-sub"><span class="pill pill-red">7 overdue</span></span></div>
    </div>

    <div class="chart-grid cols-2">
        <article class="chart-card">
            <header><h4><i class="fas fa-chart-bar"></i> Assessment Status</h4><span class="muted">Lifetime totals</span></header>
            <div class="chart-canvas-wrap"><canvas id="orgAssessmentsChart"></canvas></div>
        </article>
        <article class="chart-card">
            <header><h4><i class="fas fa-coins"></i> Job Cost Range</h4><span class="muted">Org's completed jobs</span></header>
            <div class="cost-extremes">
                <div class="extreme high"><div class="label">Highest Job Cost</div><div class="amount">$24,300</div><div class="meta">Foundation stabilization &middot; Buncombe Co.</div></div>
                <div class="extreme low"><div class="label">Lowest Job Cost</div><div class="amount">$410</div><div class="meta">Smoke detector install &middot; Yancey Co.</div></div>
            </div>
            <p class="muted"><strong>Average job cost:</strong> $5,890</p>
        </article>
    </div>

    <h3 class="dash-section-title"><i class="fas fa-chart-pie"></i> Demographics &ndash; Org Jobs</h3>
    <div class="chart-grid cols-2">
        <article class="chart-card">
            <header><h4><i class="fas fa-dollar-sign"></i> Income Breakdown</h4><span class="muted">% of AMI</span></header>
            <div class="chart-canvas-wrap"><canvas id="orgIncomeChart"></canvas></div>
        </article>
        <article class="chart-card">
            <header><h4><i class="fas fa-map-marker-alt"></i> County Breakdown</h4><span class="muted">Service distribution</span></header>
            <div class="chart-canvas-wrap"><canvas id="orgCountyChart"></canvas></div>
        </article>
    </div>
</section>
        </section>

        <!-- ===== Admin task context groups (collapsible) ===== -->
        <section aria-labelledby="task-groups-h">
<h3 class="dash-section-title" id="task-groups-h"><i class="fas fa-layer-group"></i> Task Contexts</h3>

<details class="task-group" id="taskGroupRequestors" open>
    <summary>
        <span class="task-group-title"><i class="fas fa-user-check"></i> Requestors</span>
        <span class="toggle-icon" aria-hidden="true"><i class="fas fa-chevron-down"></i></span>
    </summary>
    <div class="task-group-body">
        <div class="task-subgroup">
            <h4><i class="fas fa-clipboard-list"></i> Application Review</h4>
            <ul class="task-action-list">
                <li><a href="#eligibilityReview"><i class="fas fa-balance-scale"></i> Review &amp; confirm eligibility</a></li>
                <li><a href="#triage"><i class="fas fa-chart-simple"></i> Set request triage</a></li>
                <li><a href="#updateInfo"><i class="fas fa-pen"></i> Update information</a></li>
                <li><a href="#notes"><i class="fas fa-sticky-note"></i> Take notes</a></li>
            </ul>
        </div>
        <div class="task-subgroup">
            <h4><i class="fas fa-calendar-check"></i> Requestor Actions</h4>
            <ul class="task-action-list">
                <li><a href="#viewComm"><i class="fas fa-envelope"></i> View communication</a></li>
                <li><a href="#scheduleAssessment"><i class="fas fa-home"></i> Schedule assessment</a></li>
            </ul>
        </div>
    </div>
</details>

<details class="task-group" id="taskGroupOrg">
    <summary>
        <span class="task-group-title"><i class="fas fa-building"></i> Organization</span>
        <span class="toggle-icon" aria-hidden="true"><i class="fas fa-chevron-down"></i></span>
    </summary>
    <div class="task-group-body">
        <div class="task-subgroup">
            <h4><i class="fas fa-bullhorn"></i> Coalition &amp; Internal</h4>
            <ul class="task-action-list">
                <li><a href="#orgComm"><i class="fas fa-comments"></i> View communication</a></li>
                <li><a href="#coalitionEvents"><i class="fas fa-calendar-week"></i> Schedule coalition events</a></li>
            </ul>
        </div>
    </div>
</details>

<details class="task-group" id="taskGroupSubcontractors">
    <summary>
        <span class="task-group-title"><i class="fas fa-hard-hat"></i> Subcontractors</span>
        <span class="toggle-icon" aria-hidden="true"><i class="fas fa-chevron-down"></i></span>
    </summary>
    <div class="task-group-body">
        <div class="task-subgroup">
            <h4><i class="fas fa-user-plus"></i> Subcontractor Management</h4>
            <ul class="task-action-list">
                <li><a href="#reviewSub"><i class="fas fa-clipboard"></i> Review new subcontractor</a></li>
                <li><a href="#subComm"><i class="fas fa-comment-dots"></i> View communication</a></li>
                <li><a href="#scheduleQuote"><i class="fas fa-file-signature"></i> Schedule subcontractor quote</a></li>
                <li><a href="#attachDocs"><i class="fas fa-paperclip"></i> Attach quotes &amp; invoices</a></li>
            </ul>
        </div>
    </div>
</details>

<details class="task-group" id="taskGroupVolunteers">
    <summary>
        <span class="task-group-title"><i class="fas fa-hands-helping"></i> Volunteers</span>
        <span class="toggle-icon" aria-hidden="true"><i class="fas fa-chevron-down"></i></span>
    </summary>
    <div class="task-group-body">
        <div class="task-subgroup">
            <h4><i class="fas fa-users"></i> Volunteer Coordination</h4>
            <ul class="task-action-list">
                <li><a href="#volunteerComm"><i class="fas fa-envelope"></i> Manage volunteer communication</a></li>
                <li><a href="#scheduleVolunteers"><i class="fas fa-calendar-alt"></i> Schedule volunteers</a></li>
            </ul>
        </div>
    </div>
</details>
        </section>

        <p class="role-notice">
<i class="fas fa-database"></i>
<span><strong>Task &amp; Ledger Integration:</strong> All actions here update the Progress Tracker and trigger notifications. Changes are logged to the immutable case ledger.</span>
        </p>
    </section><!-- /.portal-page -->
