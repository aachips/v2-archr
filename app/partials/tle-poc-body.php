<?php
/** Body partial generated from app/templates/tle-poc.html.
    Hard-coded sample data is preserved as-is (prototype). */
?>
<section class="portal-page" id="tlePage" data-page-title="Tasks, Logs, &amp; Events">

    <!-- ============ QUICK ENTRY (one or two clicks from anywhere) ============ -->
    <section class="quick-entry" aria-labelledby="qe-h">
        <div class="quick-entry-head">
            <h2 id="qe-h"><i class="fas fa-bolt"></i> Quick Entry</h2>
            <div class="quick-entry-stamp" aria-live="polite">
                <span class="stamp-chip" id="stampWho">JD</span>
                <span id="stampWhen">Auto-stamped on submit</span>
            </div>
        </div>

        <form id="quickEntryForm" novalidate>
            <label for="quickEntryText" class="sr-only" style="position:absolute;left:-9999px;">What needs to be done, what happened, or what was said?</label>
            <textarea id="quickEntryText"
                placeholder="Type one or more entries. Each new line is a separate entry. e.g.&#10;42-CHERRY roof needs tarping before storm&#10;Called Mrs. Lopez at 2:10pm &mdash; confirmed Thursday assessment&#10;Photos uploaded to 15-MERRILL"
                aria-describedby="qeHelper"></textarea>

            <div class="quick-entry-helper" id="qeHelper">
                <span><i class="fas fa-circle-info"></i> Each new line becomes its own entry. A Task Rabbit will parse, categorize, and verify before it counts toward metrics.</span>
                <a href="sop-entries.md" class="sop-link" id="sopLink" target="_blank" rel="noopener"><i class="fas fa-book-open"></i> SOP &middot; Good vs bad entries</a>
            </div>

            <!-- Advanced (a.k.a. Task Rabbit fields). Hidden by default;
                 same shape the Task Rabbit uses during triage. -->
            <div class="quick-entry-advanced">
                <button type="button" class="adv-toggle" id="advToggle" aria-expanded="false" aria-controls="advFields">
                    <i class="fas fa-chevron-right chevron" aria-hidden="true"></i>
                    Add structure now (skip if you're in a hurry)
                </button>
                <p class="adv-note">Same panel the Task Rabbit uses during review. Anything you fill in here pre-fills triage and may auto-verify.</p>

                <div class="adv-fields" id="advFields" role="group" aria-label="Advanced entry fields">
                    <label>Case
                        <input type="text" name="case" placeholder="42-CHERRY or address">
                    </label>
                    <label>Type
                        <select name="type">
                            <option value="">Let Rabbit decide</option>
                            <option value="task">Task</option>
                            <option value="event">Event</option>
                            <option value="comm">Communication</option>
                            <option value="mixed">Mixed (parse into many)</option>
                        </select>
                    </label>
                    <label>Priority
                        <select name="priority">
                            <option value="">Default</option>
                            <option value="p0">P0 &middot; Urgent</option>
                            <option value="p1">P1 &middot; High</option>
                            <option value="p2">P2 &middot; Normal</option>
                            <option value="p3">P3 &middot; Low</option>
                        </select>
                    </label>
                    <label>Assign to
                        <input type="text" name="assignee" placeholder="Initials, role, or org">
                    </label>
                </div>
            </div>

            <div class="quick-entry-actions">
                <button type="button" class="btn btn-outline" id="qeClear"><i class="fas fa-rotate-left"></i> Clear</button>
                <button type="submit" class="btn btn-secondary" id="qeAddAnother"><i class="fas fa-plus"></i> Save &amp; Add Another</button>
                <button type="submit" class="btn btn-primary" id="qeSubmit"><i class="fas fa-paper-plane"></i> Submit to Unverified</button>
            </div>
        </form>
    </section>

    <!-- ============ TABS ============ -->
    <div class="tle-tabs" role="tablist" aria-label="Task views">
        <button type="button" class="tle-tab is-active" role="tab" aria-selected="true" data-view="unverified" data-warning="1">
            <i class="fas fa-hourglass-half"></i> Unverified <span class="tab-count" id="countUnverified">3</span>
        </button>
        <button type="button" class="tle-tab" role="tab" aria-selected="false" data-view="all">
            <i class="fas fa-list-check"></i> All Verified <span class="tab-count">12</span>
        </button>
        <button type="button" class="tle-tab" role="tab" aria-selected="false" data-view="mine">
            <i class="fas fa-user-check"></i> My Submissions <span class="tab-count">5</span>
        </button>
        <button type="button" class="tle-tab" role="tab" aria-selected="false" data-view="completed">
            <i class="fas fa-circle-check"></i> Completed <span class="tab-count">27</span>
        </button>
    </div>

    <!-- ============ UNVERIFIED QUEUE ============ -->
    <section class="tle-view is-active" id="view-unverified" role="tabpanel" aria-label="Unverified entries">
        <div class="review-banner">
            <i class="fas fa-circle-info"></i>
            <span><strong>Task Rabbit role:</strong> A second pair of eyes parses each raw entry, decides whether it's a task, event, communication, or several of those together, fills missing fields, then verifies. Verified entries count toward metrics.</span>
        </div>

        <ul class="unverified-list" id="unverifiedList">
            <li class="unverified-card" data-entry-id="u-1001">
                <div class="unverified-card-head">
                    <span class="submitter"><span class="avatar">JD</span> Jamie Doe</span>
                    <span class="stamp"><i class="fas fa-clock"></i> Dec 15, 2024 &middot; 2:34 PM</span>
                    <span class="raw-tag"><i class="fas fa-hourglass-half"></i> Unverified</span>
                </div>
                <div class="unverified-card-body">42-CHERRY roof needs tarping before storm. Tarp + 4 sandbags in the van. Called Mrs. Lopez at 2:10pm &mdash; she's home all afternoon, will let crew in.</div>
                <div class="unverified-card-foot">
                    <div class="quick-verify-row" role="group" aria-label="Suggested type">
                        <button type="button" class="quick-verify-chip is-on"><i class="fas fa-list-check"></i> Task</button>
                        <button type="button" class="quick-verify-chip is-on"><i class="fas fa-phone"></i> Comm</button>
                        <button type="button" class="quick-verify-chip"><i class="fas fa-calendar-check"></i> Event</button>
                    </div>
                    <div style="display:flex; gap:var(--space-2); flex-wrap:wrap;">
                        <button type="button" class="btn btn-secondary btn-sm js-triage"><i class="fas fa-scissors"></i> Triage &amp; Parse</button>
                        <button type="button" class="btn btn-primary btn-sm js-verify"><i class="fas fa-circle-check"></i> Verify as Task + Comm</button>
                    </div>
                </div>
            </li>

            <li class="unverified-card" data-entry-id="u-1002">
                <div class="unverified-card-head">
                    <span class="submitter"><span class="avatar">AL</span> Aisha Lee</span>
                    <span class="stamp"><i class="fas fa-clock"></i> Dec 15, 2024 &middot; 10:48 AM</span>
                    <span class="raw-tag"><i class="fas fa-hourglass-half"></i> Unverified</span>
                </div>
                <div class="unverified-card-body">15-MERRILL: client called about timeline; wants confirmation by Friday. Also reminder to upload income verification &mdash; she sent W-2 last week, still in inbox. And schedule final walkthrough w/ David.</div>
                <div class="unverified-card-foot">
                    <div class="quick-verify-row" role="group" aria-label="Suggested type">
                        <button type="button" class="quick-verify-chip is-on"><i class="fas fa-phone"></i> Comm</button>
                        <button type="button" class="quick-verify-chip is-on"><i class="fas fa-list-check"></i> Task</button>
                        <button type="button" class="quick-verify-chip is-on"><i class="fas fa-calendar-check"></i> Event</button>
                    </div>
                    <div style="display:flex; gap:var(--space-2); flex-wrap:wrap;">
                        <button type="button" class="btn btn-warn btn-sm js-triage"><i class="fas fa-scissors"></i> Triage (3 items)</button>
                        <button type="button" class="btn btn-outline btn-sm">Reject</button>
                    </div>
                </div>
            </li>

            <li class="unverified-card" data-entry-id="u-1003">
                <div class="unverified-card-head">
                    <span class="submitter"><span class="avatar">SM</span> Sarah M.</span>
                    <span class="stamp"><i class="fas fa-clock"></i> Dec 14, 2024 &middot; 5:12 PM</span>
                    <span class="raw-tag"><i class="fas fa-hourglass-half"></i> Unverified</span>
                </div>
                <div class="unverified-card-body">8-OAKLAND need to verify deed before crew can start panel upgrade. Title company says 3 business days.</div>
                <div class="unverified-card-foot">
                    <div class="quick-verify-row" role="group" aria-label="Suggested type">
                        <button type="button" class="quick-verify-chip is-on"><i class="fas fa-list-check"></i> Task</button>
                        <button type="button" class="quick-verify-chip"><i class="fas fa-phone"></i> Comm</button>
                        <button type="button" class="quick-verify-chip"><i class="fas fa-calendar-check"></i> Event</button>
                    </div>
                    <div style="display:flex; gap:var(--space-2); flex-wrap:wrap;">
                        <button type="button" class="btn btn-secondary btn-sm js-triage"><i class="fas fa-scissors"></i> Triage</button>
                        <button type="button" class="btn btn-primary btn-sm js-verify"><i class="fas fa-circle-check"></i> Verify as Task</button>
                    </div>
                </div>
            </li>
        </ul>
    </section>

    <!-- ============ ALL VERIFIED (table) ============ -->
    <section class="tle-view" id="view-all" role="tabpanel" aria-label="All verified entries" hidden>
        <article class="panel" style="padding:0;">
            <div style="overflow-x:auto;">
            <table class="verified-table">
                <thead>
                    <tr>
                        <th>Case</th>
                        <th>Type</th>
                        <th>Entry</th>
                        <th>Submitted</th>
                        <th>Verified by</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><span class="case-tag">42-CHERRY</span></td>
                        <td><span class="type-pill is-task"><i class="fas fa-list-check"></i> Task</span></td>
                        <td>Schedule assessment &mdash; roof inspection + estimate. Due Dec 20.</td>
                        <td>JD &middot; Dec 12, 9:14 AM</td>
                        <td>AL</td>
                        <td><span class="status-pill is-progress"><i class="fas fa-spinner"></i> In progress</span></td>
                    </tr>
                    <tr>
                        <td><span class="case-tag">15-MERRILL</span></td>
                        <td><span class="type-pill is-comm"><i class="fas fa-phone"></i> Comm</span></td>
                        <td>Client requested timeline confirmation. Replied with Friday EOD commitment.</td>
                        <td>AL &middot; Dec 14, 10:48 AM</td>
                        <td>JD</td>
                        <td><span class="status-pill is-done"><i class="fas fa-circle-check"></i> Closed</span></td>
                    </tr>
                    <tr>
                        <td><span class="case-tag">15-MERRILL</span></td>
                        <td><span class="type-pill is-task"><i class="fas fa-list-check"></i> Task</span></td>
                        <td>Verify income (W-2 already in inbox).</td>
                        <td>AL &middot; Dec 14, 10:48 AM</td>
                        <td>JD</td>
                        <td><span class="status-pill is-active"><i class="fas fa-circle-dot"></i> Active</span></td>
                    </tr>
                    <tr>
                        <td><span class="case-tag">15-MERRILL</span></td>
                        <td><span class="type-pill is-event"><i class="fas fa-calendar-check"></i> Event</span></td>
                        <td>Final walkthrough scheduled with David C., Dec 12 9:30 AM.</td>
                        <td>AL &middot; Dec 14, 10:48 AM</td>
                        <td>JD</td>
                        <td><span class="status-pill is-active"><i class="fas fa-circle-dot"></i> Active</span></td>
                    </tr>
                    <tr>
                        <td><span class="case-tag">8-OAKLAND</span></td>
                        <td><span class="type-pill is-task"><i class="fas fa-list-check"></i> Task</span></td>
                        <td>Electrical estimate, due Dec 22 (Mike).</td>
                        <td>SM &middot; Dec 14, 5:12 PM</td>
                        <td>AL</td>
                        <td><span class="status-pill is-progress"><i class="fas fa-spinner"></i> In progress</span></td>
                    </tr>
                </tbody>
            </table>
            </div>
        </article>
    </section>

    <section class="tle-view" id="view-mine" role="tabpanel" aria-label="My submissions" hidden>
        <article class="panel"><p style="margin:0; color:var(--color-text-muted);">Your 5 most recent submissions appear here once you submit through Quick Entry.</p></article>
    </section>
    <section class="tle-view" id="view-completed" role="tabpanel" aria-label="Completed" hidden>
        <article class="panel"><p style="margin:0; color:var(--color-text-muted);">Completed entries auto-archive here for audit history.</p></article>
    </section>

    <p class="role-notice">
        <i class="fas fa-circle-info"></i>
        <span>
            <strong>Two-phase capture &middot; POC:</strong>
            Phase 1 (everyone) drops raw notes into the queue with zero ceremony.
            Phase 2 (Task Rabbit) parses each entry into one-or-more structured
            tasks, events, and communication logs &mdash; then verifies. Only verified
            items count toward metrics and appear on case to-do lists. See
            <code>tle-table.md</code> and <code>quick-add-form-specs.json</code>
            for the spec this POC implements.
        </span>
    </p>
</section>
