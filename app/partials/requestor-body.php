<?php
/** Body partial generated from app/templates/requestor.html.
    Hard-coded sample data is preserved as-is (prototype). */
?>
<section class="portal-page active" data-page-title="My Application">
        <p class="login-banner" role="status">
            <i class="fas fa-lock"></i>
            <span>You are viewing your private application dashboard. Only you and your assigned ARCHR caseworker can see this information.</span>
        </p>

        <section class="dash-hero" aria-labelledby="req-welcome">
            <div>
                <h2 id="req-welcome">Welcome back, John</h2>
                <p>Your application <strong>ARCHR-2024-001234</strong> is in review. Your assigned caseworker has requested income documentation &mdash; please upload by Dec 20.</p>
                <p class="updated"><i class="far fa-clock"></i> Submitted Nov 15, 2024 &middot; Updated today, 9:14 AM</p>
            </div>
            <div class="dash-hero-meta">
                <span class="org-badge"><i class="fas fa-hashtag"></i> ARCHR-2024-001234</span>
                <a href="#documents" class="btn btn-secondary"><i class="fas fa-cloud-arrow-up"></i> Upload Documents</a>
            </div>
        </section>

        <section class="dash-section active" aria-label="At-a-glance application status">
            <h3 class="dash-section-title"><i class="fas fa-clipboard-list"></i> Application At a Glance</h3>
            <div class="kpi-grid">
                <div class="kpi"><span class="kpi-label">Status</span><span class="kpi-value" style="font-size:1.4rem;">In Review</span><span class="kpi-sub"><span class="pill pill-amber">Documents needed</span></span></div>
                <div class="kpi kpi-blue"><span class="kpi-label">Days Since Submission</span><span class="kpi-value">24</span><span class="kpi-sub">Submitted Nov 15, 2024</span></div>
                <div class="kpi kpi-amber"><span class="kpi-label">Next Step Due</span><span class="kpi-value">Dec 20</span><span class="kpi-sub">Income documentation</span></div>
                <div class="kpi kpi-green"><span class="kpi-label">Eligible Orgs</span><span class="kpi-value">3</span><span class="kpi-sub">Partners that match you</span></div>
            </div>
        </section>

        <section class="dash-section active" aria-label="Next step and contact">
            <div class="dash-two-col">
                <div class="callout next-step">
                    <h3><i class="fas fa-arrow-right-long"></i> Your Next Step</h3>
                    <p><strong>Complete Income Documentation.</strong> Upload your last three months of bank statements and your most recent pay stub. Files are encrypted at rest and visible only to your caseworker.</p>
                    <p><small><i class="far fa-clock"></i> Due Dec 20, 2024 &middot; ~5 minutes</small></p>
                    <div class="action-row" style="margin-top: var(--space-4);">
                        <a href="#documents" class="btn btn-primary"><i class="fas fa-cloud-arrow-up"></i> Continue</a>
                        <a href="#messages" class="btn btn-secondary"><i class="fas fa-envelope"></i> Message my caseworker</a>
                    </div>
                </div>

                <article class="panel" aria-labelledby="contact-h">
                    <div class="panel-header">
                        <h3 id="contact-h"><i class="fas fa-user-tie"></i> Your Caseworker</h3>
                    </div>
                    <div class="contact-card">
                        <div class="who">
                            <span class="avatar">SM</span>
                            <div>
                                <strong>Sarah Martinez</strong>
                                <small>Habitat for Humanity &middot; Buncombe County</small>
                            </div>
                        </div>
                        <ul>
                            <li><i class="fas fa-envelope"></i> sarah.martinez@archr.org</li>
                            <li><i class="fas fa-phone"></i> (828) 555-0123</li>
                            <li><i class="far fa-clock"></i> Mon&ndash;Fri, 9 AM &ndash; 5 PM</li>
                        </ul>
                    </div>
                </article>
            </div>
        </section>

        <section class="dash-section active" aria-labelledby="eligibility-h">
            <h3 class="dash-section-title" id="eligibility-h"><i class="fas fa-handshake"></i> Eligibility &mdash; Organizations You Qualify For</h3>
            <article class="panel">
                <ul class="eligibility-list">
                    <li class="eligibility-item">
                        <div class="org">
                            <i class="fas fa-circle-check"></i>
                            <div>
                                <strong>Habitat for Humanity &mdash; Buncombe County</strong>
                                <small>Match score: 92 &middot; Ready for assignment</small>
                            </div>
                        </div>
                        <a href="#eligibility" class="btn btn-secondary btn-sm">Org Details</a>
                    </li>
                    <li class="eligibility-item">
                        <div class="org">
                            <i class="fas fa-circle-check"></i>
                            <div>
                                <strong>Mountain Housing Opportunities</strong>
                                <small>Match score: 84 &middot; Ready for assignment</small>
                            </div>
                        </div>
                        <a href="#eligibility" class="btn btn-secondary btn-sm">Org Details</a>
                    </li>
                    <li class="eligibility-item">
                        <div class="org">
                            <i class="fas fa-circle-exclamation" style="color: var(--color-warning);"></i>
                            <div>
                                <strong>Community Action Opportunities</strong>
                                <small>Match score: 68 &middot; Additional income documentation needed</small>
                            </div>
                        </div>
                        <a href="#documents" class="btn btn-secondary btn-sm">Add Docs</a>
                    </li>
                </ul>
            </article>
        </section>


        <section class="dash-section active">
            <div class="dash-two-col">

                <article class="panel" aria-labelledby="updates-h">
                    <div class="panel-header">
                        <h3 id="updates-h"><i class="fas fa-clock-rotate-left"></i> Progress Timeline</h3>
                        <a href="#progress">View all updates</a>
                    </div>
                    <ul class="timeline">
                        <li class="timeline-item is-pending">
                            <span class="dot" aria-hidden="true"></span>
                            <div>
                                <strong>Awaiting income documents</strong>
                                <small>Pending your upload &middot; Due Dec 20, 2024</small>
                            </div>
                        </li>
                        <li class="timeline-item">
                            <span class="dot" aria-hidden="true"></span>
                            <div>
                                <strong>Income documents requested</strong>
                                <small>Dec 5, 2024 &middot; Sarah Martinez requested bank statements and pay stub</small>
                            </div>
                        </li>
                        <li class="timeline-item">
                            <span class="dot" aria-hidden="true"></span>
                            <div>
                                <strong>Application assigned to Habitat for Humanity</strong>
                                <small>Dec 3, 2024 &middot; Matched on county, income tier, and repair type</small>
                            </div>
                        </li>
                        <li class="timeline-item">
                            <span class="dot" aria-hidden="true"></span>
                            <div>
                                <strong>Eligibility review started</strong>
                                <small>Nov 28, 2024 &middot; Estimated 7&ndash;10 business days</small>
                            </div>
                        </li>
                        <li class="timeline-item">
                            <span class="dot" aria-hidden="true"></span>
                            <div>
                                <strong>Application submitted</strong>
                                <small>Nov 15, 2024 &middot; ARCHR-2024-001234 received</small>
                            </div>
                        </li>
                    </ul>
                </article>

                <article class="panel" aria-labelledby="messages-h">
                    <div class="panel-header">
                        <h3 id="messages-h"><i class="fas fa-envelope"></i> Messages <span class="pill pill-amber">2 unread</span></h3>
                        <a href="#messages">Open inbox</a>
                    </div>
                    <ul class="message-list">
                        <li class="message-item is-unread">
                            <strong>Sarah Martinez &middot; Habitat for Humanity</strong>
                            <p>Your home assessment has been scheduled for Dec 18 at 2:00 PM. Please confirm.</p>
                            <div class="meta-row">
                                <span class="pill pill-blue"><i class="far fa-calendar"></i> Schedule</span>
                                <a href="#messages" class="btn btn-secondary btn-sm">Read Message</a>
                            </div>
                        </li>
                        <li class="message-item is-unread">
                            <strong>ARCHR System</strong>
                            <p>Reminder: income documents are due Dec 20. Files are encrypted before storage.</p>
                            <div class="meta-row">
                                <span class="pill pill-amber"><i class="fas fa-circle-exclamation"></i> Action needed</span>
                                <a href="#documents" class="btn btn-secondary btn-sm">Read Message</a>
                            </div>
                        </li>
                        <li class="message-item">
                            <strong>ARCHR System</strong>
                            <p>Your application was received on Nov 15, 2024. We will follow up within 3&ndash;5 business days.</p>
                            <div class="meta-row">
                                <span class="pill"><i class="fas fa-check"></i> Read</span>
                            </div>
                        </li>
                    </ul>
                </article>

            </div>
        </section>

        <section class="dash-section active" aria-labelledby="actions-h">
            <h3 class="dash-section-title" id="actions-h"><i class="fas fa-bolt"></i> Quick Actions</h3>
            <div class="action-row">
                <a href="#documents" class="btn btn-primary"><i class="fas fa-cloud-arrow-up"></i> Continue Required Info</a>
                <a href="#eligibility" class="btn btn-secondary"><i class="fas fa-handshake"></i> Organization Details</a>
                <a href="#messages" class="btn btn-secondary"><i class="fas fa-envelope-open-text"></i> Read Messages</a>
                <a href="#schedule" class="btn btn-secondary"><i class="far fa-calendar"></i> Event Details</a>
            </div>

            <p class="role-notice">
                <i class="fas fa-shield-halved"></i>
                <span><strong>Single source of truth:</strong> every email, phone call, and platform message about your case is logged here. If a staff member reaches you outside the platform, the conversation will appear in your timeline within 1 hour.</span>
            </p>
        </section>
    </section>
