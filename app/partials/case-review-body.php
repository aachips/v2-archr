<?php
/** Body partial for case.php (case review). Expects $case, $permission, $caseOrg,
 *  $repairs, $repairRequests, $repairDetails, $repairClaims, $activeRepairClaims,
 *  $unclaimedRepairs, $withdrawal, $attrs, $eligibility, $statusHistory,
 *  $assignments, $tasks, $documents, $phases, $phaseInfo, $canClaim,
 *  $canWithdraw, $canTerminate, $orgAdminOrgs, $returnTo — plus the application
 *  context: $applicationId, $application, $applicationStatus, $applicationCases,
 *  $applicationTerminal, $eligibilityFlags, $terminationReasons, $myOrgCase. */
$projectCode = $case['project_code'] ?? $case['anchor_project_code'] ?? null;
$placecode   = $case['placecode']   ?? $case['anchor_placecode']   ?? null;

/* Human-first label: the application's address-based display name. */
$displayName = $application['display_name'] ?? null;

/* Application status pill styling (terminology doc lifecycle). */
$appStatusPill = [
    'new'        => ['pill-blue', 'New'],
    'active'     => ['pill-green', 'Active'],
    'concluded'  => ['pill-green', 'Concluded'],
    'terminated' => ['pill-red', 'Terminated'],
    'withdrawn'  => ['pill-amber', 'Withdrawn'],
    'expired'    => ['pill-amber', 'Expired — claim lapsed'],
][$applicationStatus] ?? ['', ucfirst($applicationStatus)];

/* 90-day claim countdown for the viewing org's own case. */
$claimCountdownPill = null;
if ($myOrgCase !== null && $myOrgCase['days_until_expiry'] !== null) {
    $days = (int)$myOrgCase['days_until_expiry'];
    $cls = $days <= 7 ? 'pill-red' : ($days <= 30 ? 'pill-amber' : 'pill-green');
    $claimCountdownPill = '<span class="pill ' . $cls . '" title="Any logged progress (task, communication, document, milestone) resets the 90-day timer."><i class="fas fa-hourglass-half"></i> Claim expires in ' . $days . ' day' . ($days === 1 ? '' : 's') . '</span>';
}

/* Urgent living-condition flags reported on the intake form. */
$urgentLabels = [
    'urgent_unable_to_stay'    => 'Unable to stay in the home',
    'urgent_no_hvac'           => 'No working heat / AC',
    'urgent_no_potable_water'  => 'No potable water',
    'urgent_no_bathroom'       => 'No working bathroom',
    'urgent_no_kitchen'        => 'No working kitchen',
    'urgent_open_to_elements'  => 'Home open to the elements',
    'urgent_no_entry'          => 'No safe entry / exit',
    'urgent_accessibility'     => 'Accessibility emergency',
    'urgent_eviction_risk'     => 'Risk of eviction / displacement',
    'urgent_other_issue'       => 'Other urgent issue',
];
$urgentFlags = [];
foreach ($urgentLabels as $key => $label) {
    if (!empty($case[$key])) $urgentFlags[] = $label;
}

$budget  = $case['total_budget'] !== null ? (float)$case['total_budget'] : null;
$actual  = $case['total_actual_cost'] !== null ? (float)$case['total_actual_cost'] : null;
$remaining = ($budget !== null || $actual !== null) ? (float)$budget - (float)$actual : null;
$pctUsed = ($budget !== null && $budget > 0 && $actual !== null)
    ? min(100, round(($actual / $budget) * 100)) : null;

$activityCount = count($statusHistory) + count($assignments);
?>
<main class="page-wrap case-review">
    <p><a href="<?= e($returnTo) ?>">&larr; <?= $returnTo === 'case-search.php' ? 'Back to case search' : 'Back to search results' ?></a></p>

    <?php if ($permission['level'] === 1): ?>
        <div class="alert info">Limited case view (office worker). Contact details are hidden.</div>
    <?php elseif ($permission['level'] === 2 && !$permission['full']): ?>
        <div class="alert info">Limited view — this case is outside your organization.</div>
    <?php endif; ?>

    <?php if ($urgentFlags): ?>
        <div class="alert danger urgent-banner" role="alert">
            <strong><i class="fas fa-triangle-exclamation" aria-hidden="true"></i> Urgent action needed</strong>
            — the applicant reported:
            <ul>
                <?php foreach ($urgentFlags as $flag): ?>
                    <li><?= e($flag) ?></li>
                <?php endforeach; ?>
            </ul>
        </div>
    <?php endif; ?>

    <header class="panel case-header">
        <div>
            <h1><?= e($displayName ?? ($case['case_number'] ?? '#' . (int)$case['id'])) ?></h1>
            <p class="case-subtitle"><?= e($case['applicant_first_name'] . ' ' . $case['applicant_last_name']) ?> &middot; <?= e($projectCode ?? '—') ?></p>
            <p class="case-keyfacts">
                <span><i class="fas fa-calendar-day" aria-hidden="true"></i> Applied <?= $case['submitted_at'] ? e(date('M j, Y', strtotime((string)$case['submitted_at']))) : '—' ?></span>
                <span><i class="fas fa-location-dot" aria-hidden="true"></i> <?= e(trim(($case['home_city'] ?? '') . ' ' . ($case['home_zip'] ?? ''))) ?: '—' ?></span>
                <span><i class="fas fa-barcode" aria-hidden="true"></i> <?= e(archr_job_code($caseOrg, $projectCode)) ?></span>
                <?php if ($placecode): ?><span class="muted"><i class="fas fa-map-pin" aria-hidden="true"></i> <?= e($placecode) ?></span><?php endif; ?>
            </p>
        </div>
        <div class="case-meta">
            <?php if ($urgentFlags): ?>
                <span class="pill pill-red">Urgent</span>
            <?php endif; ?>
            <span class="pill <?= e($appStatusPill[0]) ?>"><?= e($appStatusPill[1]) ?></span>
            <span class="pill"><?= e($case['status_name'] ?? '—') ?></span>
            <?= $claimCountdownPill ?? '' ?>
            <?php if ($caseOrg): ?>
                <span class="org-badge"><?= e($caseOrg['organization_name']) ?></span>
            <?php else: ?>
                <span class="org-badge org-badge-unclaimed">Unclaimed</span>
            <?php endif; ?>
        </div>
    </header>

    <?php if ($applicationTerminal): ?>
        <div class="alert danger">
            <strong>This application is <?= e($applicationStatus) ?>.</strong>
            <?php if ($applicationStatus === 'terminated' && !empty($application['terminated_reason_checkboxes'])): ?>
                Reasons: <?= e(implode('; ', $application['terminated_reason_checkboxes'])) ?>.
            <?php endif; ?>
            <?php if (!empty($application['status_reason'])): ?>
                <?= e($application['status_reason']) ?>
            <?php endif; ?>
            No new claims can be made.
        </div>
    <?php elseif ($applicationStatus === 'expired'): ?>
        <div class="alert info">
            <strong>Claim expired.</strong> This application had no logged progress for 90 days, so its claim lapsed.
            It is available for any organization to claim again.
        </div>
    <?php endif; ?>

    <?php if ($applicationCases): ?>
    <section class="panel case-app-cases" aria-labelledby="app-cases-h">
        <h2 id="app-cases-h"><i class="fas fa-layer-group"></i> Cases on this application</h2>
        <p class="muted">One application can be claimed by several organizations — each gets its own case over the repairs it claims. Documents and repair needs are shared at the application layer.</p>
        <div class="table-wrap">
            <table class="data-table">
                <thead>
                    <tr><th>Case</th><th>Organization</th><th>Case status</th><th>Claim</th><th>90-day window</th><th></th></tr>
                </thead>
                <tbody>
                    <?php foreach ($applicationCases as $ac): ?>
                        <tr>
                            <td><?= e($ac['case_number'] ?? ('#' . (int)$ac['id'])) ?></td>
                            <td><?= e($ac['organization_name'] ?? 'Unclaimed intake case') ?></td>
                            <td><span class="pill"><?= e($ac['status_name'] ?? '—') ?></span></td>
                            <td>
                                <?php if ($ac['claim_status'] === 'active'): ?>
                                    <span class="pill pill-green">Active claim</span>
                                <?php elseif ($ac['claim_status'] === 'expired'): ?>
                                    <span class="pill pill-amber">Expired</span>
                                <?php elseif ($ac['claim_status'] === 'released'): ?>
                                    <span class="pill">Released</span>
                                <?php else: ?>
                                    <span class="pill pill-blue">Awaiting claim</span>
                                <?php endif; ?>
                            </td>
                            <td>
                                <?php if ($ac['claim_status'] === 'active' && $ac['days_until_expiry'] !== null): ?>
                                    <?= (int)$ac['days_until_expiry'] ?> day(s) left
                                <?php elseif ($ac['claim_status'] === null): ?>
                                    —
                                <?php else: ?>
                                    <span class="muted">closed</span>
                                <?php endif; ?>
                            </td>
                            <td>
                                <?php if ((int)$ac['id'] !== (int)$case['id']): ?>
                                    <a href="case.php?id=<?= (int)$ac['id'] ?>" class="btn btn-sm btn-secondary">Open</a>
                                <?php else: ?>
                                    <span class="muted">This case</span>
                                <?php endif; ?>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </section>
    <?php endif; ?>

    <?php if ($withdrawal): ?>
        <div class="alert danger">
            <strong>Application withdrawn</strong> by <?= e($withdrawal['withdrawn_by_name'] ?? 'staff') ?>
            on <?= e(date('M j, Y', strtotime($withdrawal['withdrawn_at']))) ?>.
            Applicant confirmation: <?= e(str_replace('_', ' ', $withdrawal['confirmation_method'])) ?> —
            <?= e($withdrawal['confirmation_detail']) ?>
            <?php if ($withdrawal['reason']): ?><br>Reason: <?= e($withdrawal['reason']) ?><?php endif; ?>
        </div>
    <?php endif; ?>

    <section class="panel phase-panel" aria-labelledby="phase-tracker-h">
        <h2 id="phase-tracker-h">Pipeline progress</h2>
        <?php if ($phaseInfo['exit'] !== null): ?>
            <p class="phase-exit-banner"><i class="fas fa-circle-stop"></i> This case exited the pipeline: <strong><?= e($phaseInfo['exit_label']) ?></strong>. The furthest phase reached is highlighted below.</p>
        <?php endif; ?>
        <ol class="phase-tracker">
            <?php foreach ($phases as $num => $def):
                $state = $num < $phaseInfo['number'] ? 'done' : ($num === $phaseInfo['number'] ? 'active' : 'todo');
            ?>
                <li class="phase <?= $state ?>" data-tip="<?= e($def['description']) ?>">
                    <span class="phase-num" title="<?= e($def['full_name']) ?>"><?= (int)$num ?></span>
                    <span class="phase-name"><?= e($def['name']) ?></span>
                </li>
            <?php endforeach; ?>
        </ol>
        <?php $activePhase = $phases[$phaseInfo['number']]; ?>
        <div class="phase-next-steps">
            <h3>
                <?php if ($phaseInfo['exit'] !== null): ?>
                    Phase <?= (int)$phaseInfo['number'] ?> &mdash; <?= e($activePhase['full_name']) ?> (reached)
                <?php else: ?>
                    Next steps &mdash; Phase <?= (int)$phaseInfo['number'] ?>: <?= e($activePhase['full_name']) ?>
                <?php endif; ?>
            </h3>
            <p class="muted"><?= e($activePhase['description']) ?></p>
            <ul>
                <?php foreach ($activePhase['next_steps'] as $step): ?>
                    <li><?= e($step) ?></li>
                <?php endforeach; ?>
            </ul>
        </div>
    </section>

    <?php if (!empty($docUrgent)): ?>
        <section class="panel case-docs-urgent" aria-labelledby="docs-needed-h">
            <div class="section-header-row">
                <h2 id="docs-needed-h"><i class="fas fa-folder-open"></i> Documents needed</h2>
                <a class="btn btn-secondary btn-sm" href="case-documents.php?case=<?= (int)$caseId ?>">
                    View all <i class="fas fa-arrow-right"></i>
                </a>
            </div>
            <ul class="doc-urgent-list">
                <?php foreach ($docUrgent as $item): ?>
                    <li class="doc-urgent-row">
                        <span class="doc-urgent-icon"><i class="fas <?= e($item['icon']) ?>"></i></span>
                        <span class="doc-urgent-main">
                            <strong><?= e($item['label']) ?></strong>
                            <span class="muted"><?= e($item['detail']) ?></span>
                        </span>
                        <span class="doc-urgent-action">
                            <?php if ($item['action'] === 'review' && $item['doc_id'] > 0): ?>
                                <a class="btn btn-accent btn-sm" href="case-documents.php?case=<?= (int)$caseId ?>&review=<?= (int)$item['doc_id'] ?>">
                                    <i class="fas fa-eye"></i> Review
                                </a>
                            <?php elseif ($item['action'] === 'generate'): ?>
                                <a class="btn btn-primary btn-sm" href="case-documents.php?case=<?= (int)$caseId ?>&generate=<?= e(rawurlencode((string)$item['template'])) ?>">
                                    <i class="fas fa-wand-magic-sparkles"></i> Generate
                                </a>
                            <?php else: ?>
                                <a class="btn btn-secondary btn-sm" href="case-documents.php?case=<?= (int)$caseId ?>&upload=<?= e(rawurlencode((string)($item['folder'] ?? ''))) ?>">
                                    <i class="fas fa-upload"></i> Upload
                                </a>
                            <?php endif; ?>
                        </span>
                    </li>
                <?php endforeach; ?>
            </ul>
        </section>
    <?php endif; ?>

    <div class="case-grid">
        <section class="panel case-identity">
            <h2>Application &amp; Case</h2>
            <dl class="def-list">
                <dt>Application</dt>  <dd><?= e($displayName ?? '—') ?><?= $application ? ' <span class="pill ' . e($appStatusPill[0]) . '">' . e($appStatusPill[1]) . '</span>' : '' ?></dd>
                <dt>Case</dt>         <dd><?= e($case['case_number'] ?? ('#' . (int)$case['id'])) ?> — <?= e($caseOrg['organization_name'] ?? 'Unclaimed') ?></dd>
                <dt>Job code</dt>     <dd><?= e(archr_job_code($caseOrg, $projectCode)) ?></dd>
                <dt>Project code</dt> <dd><?= e($projectCode ?? '—') ?></dd>
                <dt>Placecode</dt>    <dd><?= e($placecode ?? '—') ?></dd>
                <?php if ($myOrgCase !== null && $myOrgCase['days_until_expiry'] !== null): ?>
                    <dt>Claim window</dt><dd><?= (int)$myOrgCase['days_until_expiry'] ?> day(s) left — any logged progress resets the 90-day timer</dd>
                <?php endif; ?>
                <dt>Queue status</dt> <dd><?= e($case['queue_status'] ?? '—') ?></dd>
                <dt>Priority score</dt><dd><?= e((string)($case['priority_score'] ?? '—')) ?></dd>
                <dt>Phase</dt>        <dd><?= e('Phase ' . $phaseInfo['number'] . ' — ' . $phases[$phaseInfo['number']]['full_name']) ?><?= $phaseInfo['exit_label'] !== null ? ' (' . e($phaseInfo['exit_label']) . ')' : '' ?></dd>
            </dl>
        </section>

        <?php if ($permission['full']): ?>
            <section class="panel case-funding">
                <h2>Funding &amp; Claims</h2>
                <dl class="def-list">
                    <dt>Approved budget</dt> <dd><?= $budget !== null ? '$' . e(number_format($budget, 2)) : '—' ?></dd>
                    <dt>Spent to date</dt>   <dd><?= $actual !== null ? '$' . e(number_format($actual, 2)) : '—' ?></dd>
                    <dt>Remaining</dt>       <dd><?= $remaining !== null ? '$' . e(number_format($remaining, 2)) : '—' ?></dd>
                    <dt>FEMA claim</dt>      <dd><?= !empty($case['fema_claim_filed']) ? e('Filed' . ($case['fema_outcome'] ? ' — ' . ucwords(str_replace('_', ' ', (string)$case['fema_outcome'])) : '')) : 'Not filed' ?></dd>
                    <dt>Insurance claim</dt> <dd><?= !empty($case['insurance_claim_filed']) ? e('Filed' . ($case['insurance_outcome'] ? ' — ' . ucwords(str_replace('_', ' ', (string)$case['insurance_outcome'])) : '')) : 'Not filed' ?></dd>
                    <dt>Helene-related</dt>  <dd><?= !empty($case['helene_related']) ? 'Yes' : 'No' ?></dd>
                </dl>
                <?php if ($pctUsed !== null): ?>
                    <div class="funding-bar" role="img" aria-label="<?= $pctUsed ?> percent of the approved budget spent">
                        <div class="funding-bar-fill" style="width: <?= $pctUsed ?>%"></div>
                    </div>
                    <p class="muted funding-bar-label"><?= $pctUsed ?>% of the approved budget spent</p>
                <?php endif; ?>
            </section>
        <?php endif; ?>

        <?php if ($permission['full']): ?>
            <section class="panel case-applicant">
                <div class="section-header-row">
                    <h2>Applicant</h2>
                    <button type="button" class="btn btn-sm btn-secondary" id="edit-contact-btn"><?= __('case_review.edit_contact') ?></button>
                </div>
                <dl class="def-list">
                    <dt>Name</dt>               <dd><?= e($case['applicant_first_name'] . ' ' . $case['applicant_last_name']) ?></dd>
                    <dt>Email</dt>              <dd><?= e($case['contact_email'] ?? '—') ?></dd>
                    <dt>Phone</dt>              <dd><?= e(trim((string)($case['home_phone'] ?? '')) !== '' ? $case['home_phone'] : ($case['cell_phone'] ?? '—')) ?></dd>
                    <dt>Address</dt>            <dd><?= e(trim(($case['home_address'] ?? '') . ', ' . ($case['home_city'] ?? ''))) ?></dd>
                    <dt>DOB</dt>                <dd><?= $case['applicant_dob_unknown'] ? 'Unknown' : ($case['applicant_dob'] ? e($case['applicant_dob']) : '—') ?></dd>
                    <dt>Household</dt>          <dd><?= e(($case['household_size'] ?? '—') . ' (' . ($case['household_adults'] ?? '—') . ' adults)') ?></dd>
                    <dt>Income</dt>             <dd><?= $case['has_income'] ? ('$' . e(number_format((float)$case['gross_annual_income']))) : 'No income reported' ?></dd>
                    <dt>Owns home / lot</dt>    <dd><?= ($case['owns_home'] ? 'Yes' : 'No') . ' / ' . ($case['owns_lot'] ? 'Yes' : 'No') ?></dd>
                    <dt>Primary residence</dt>    <dd><?= $case['is_primary_residence'] ? 'Yes' : 'No' ?></dd>
                    <?php if ($attrs): ?>
                        <dt>Household notes</dt>  <dd><?= e(implode(', ', $attrs)) ?></dd>
                    <?php endif; ?>
                </dl>
                <form id="contact-edit-form" class="contact-edit-grid" hidden>
                    <input type="hidden" name="application_id" value="<?= (int)$applicationId ?>">
                    <div class="field">
                        <label for="ce-first"><?= __('case_review.first_name') ?></label>
                        <input id="ce-first" name="first_name" type="text" value="<?= e((string)$case['applicant_first_name']) ?>">
                    </div>
                    <div class="field">
                        <label for="ce-last"><?= __('case_review.last_name') ?></label>
                        <input id="ce-last" name="last_name" type="text" value="<?= e((string)$case['applicant_last_name']) ?>">
                    </div>
                    <div class="field">
                        <label for="ce-email"><?= __('case_review.email') ?></label>
                        <input id="ce-email" name="email" type="email" value="<?= e((string)($case['contact_email'] ?? '')) ?>">
                    </div>
                    <div class="field">
                        <label for="ce-phone"><?= __('case_review.phone') ?></label>
                        <input id="ce-phone" name="phone" type="tel" value="<?= e((string)($case['cell_phone'] ?? '')) ?>">
                    </div>
                    <div class="contact-edit-actions">
                        <button type="submit" class="btn btn-primary btn-sm"><?= __('case_review.save_changes') ?></button>
                        <button type="button" class="btn btn-secondary btn-sm" id="contact-edit-cancel"><?= __('case_review.cancel') ?></button>
                    </div>
                    <p class="muted contact-edit-note"><?= __('case_review.contact_edit_note') ?></p>
                </form>
            </section>
            <script>
            (function () {
                'use strict';
                var btn = document.getElementById('edit-contact-btn');
                var form = document.getElementById('contact-edit-form');
                if (!btn || !form) return;
                var submitBtn = form.querySelector('button[type="submit"]');
                var saveLabel = <?= json_encode(archr_translate('case_review.save_changes')) ?>;
                btn.addEventListener('click', function () { form.hidden = !form.hidden; });
                document.getElementById('contact-edit-cancel').addEventListener('click', function () { form.hidden = true; });
                form.addEventListener('submit', async function (e) {
                    e.preventDefault();
                    submitBtn.disabled = true;
                    submitBtn.textContent = <?= json_encode(archr_translate('case_review.saving')) ?>;
                    try {
                        var res = await fetch('api/application-edit.php', { method: 'POST', body: new FormData(form) });
                        var text = await res.text();
                        var json = null;
                        try { json = JSON.parse(text); } catch (parseErr) { json = null; }
                        if (json && json.success) {
                            location.reload();
                        } else {
                            // Surface the server's actual response when it isn't
                            // JSON (fatal page, 403 text, ...) instead of a bare parse error.
                            alert((json && json.error) ? json.error : 'Save failed (' + res.status + '): ' + text.slice(0, 200));
                            submitBtn.disabled = false;
                            submitBtn.textContent = saveLabel;
                        }
                    } catch (err) {
                        alert('Save failed: ' + err);
                        submitBtn.disabled = false;
                        submitBtn.textContent = saveLabel;
                    }
                });
            })();
            </script>
        <?php else: ?>
            <section class="panel case-applicant-limited">
                <h2>Applicant</h2>
                <dl class="def-list">
                    <dt>Name</dt>  <dd><?= e($case['applicant_first_name'] . ' ' . $case['applicant_last_name']) ?></dd>
                    <dt>City</dt>  <dd><?= e($case['home_city'] ?? '—') ?></dd>
                    <dt>Project type</dt><dd><?= e($projectCode ? substr($projectCode, 0, 1) : '—') ?></dd>
                </dl>
                <p class="muted">Contact details are hidden at your permission level.</p>
            </section>
        <?php endif; ?>

        <section class="panel case-eligibility">
            <h2>Eligibility flags</h2>
            <p class="muted">The system flags, humans decide. Applicants are assumed eligible; flags below guide a human review — nothing here is an automated denial.</p>
            <?php $hasFlags = ($eligibilityFlags['green'] ?? []) || ($eligibilityFlags['yellow'] ?? []) || ($eligibilityFlags['red'] ?? []); ?>
            <?php if ($hasFlags): ?>
                <ul class="flag-list">
                    <?php foreach ($eligibilityFlags['green'] ?? [] as $f): ?>
                        <li><span class="pill pill-green">Green</span> <?= e(ucwords(str_replace('_', ' ', $f))) ?></li>
                    <?php endforeach; ?>
                    <?php foreach ($eligibilityFlags['yellow'] ?? [] as $f): ?>
                        <li><span class="pill pill-amber">Yellow</span> <?= e(ucwords(str_replace('_', ' ', $f))) ?></li>
                    <?php endforeach; ?>
                    <?php foreach ($eligibilityFlags['red'] ?? [] as $f): ?>
                        <li><span class="pill pill-red">Red</span> <?= e(ucwords(str_replace('_', ' ', $f))) ?> — needs human review</li>
                    <?php endforeach; ?>
                </ul>
                <?php if (!empty($application['eligibility_report'])): ?>
                    <p class="muted"><?= e($application['eligibility_report']) ?></p>
                <?php endif; ?>
            <?php else: ?>
                <p class="muted">No flags recorded yet — the eligibility check runs at submission.</p>
            <?php endif; ?>

            <?php if ($eligibility): ?>
                <h3 class="repairs-subhead">Organization match scores</h3>
                <ul class="plain-list">
                    <?php foreach ($eligibility as $er): ?>
                        <li>
                            <strong><?= e($er['organization_name']) ?></strong>
                            <span class="pill <?= $er['is_eligible'] ? 'pill-green' : 'pill-amber' ?>"><?= $er['is_eligible'] ? 'Strong match' : 'Low match' ?></span>
                            <?php if ($er['match_score'] !== null): ?><span class="muted">score <?= e((string)$er['match_score']) ?></span><?php endif; ?>
                        </li>
                    <?php endforeach; ?>
                </ul>
                <p class="muted">Each organization verifies program-specific requirements (e.g. its own income maximum) against its own case before work begins.</p>
            <?php endif; ?>
        </section>

        <section class="panel case-repairs" id="repairs-needed">
            <h2>Repairs Needed</h2>

            <?php if ($repairRequests): ?>
                <h3 class="repairs-subhead">Reported by the applicant</h3>
                <ul class="repair-need-list">
                    <?php foreach ($repairRequests as $rr):
                        $rid = (int)$rr['id'];
                        $claim = null;
                        foreach ($activeRepairClaims as $ac) {
                            if ((int)$ac['repair_request_id'] === $rid) { $claim = $ac; break; }
                        }
                        $claimable = $canClaim && $claim === null;
                    ?>
                        <li class="repair-need-row<?= $claim ? ' is-claimed' : '' ?>">
                            <?php if ($claimable): ?>
                                <input type="checkbox" class="repair-claim-check" value="<?= $rid ?>"
                                       id="repair-claim-<?= $rid ?>" checked
                                       aria-label="Select <?= e($rr['repair_need']) ?> for claiming">
                            <?php endif; ?>
                            <div class="repair-need-main">
                                <strong><?= e($rr['repair_need']) ?></strong>
                                <?php if ($rr['priority']): ?><span class="muted">priority <?= (int)$rr['priority'] ?></span><?php endif; ?>
                            </div>
                            <?php if ($claim): ?>
                                <span class="claim-badge"><i class="fas fa-handshake"></i> Claimed by <?= e($claim['organization_name'] ?? 'another org') ?></span>
                                <?php if ($canClaim || ($permission['level'] >= 2 && isset($orgAdminOrgs[(int)$claim['organization_id']]))): ?>
                                    <button type="button" class="btn btn-sm btn-secondary repair-release-btn"
                                            data-claim-id="<?= (int)$claim['id'] ?>"
                                            data-repair-label="<?= e($rr['repair_need']) ?>">Release</button>
                                <?php endif; ?>
                            <?php elseif (!$claimable): ?>
                                <span class="pill pill-amber">Unclaimed</span>
                            <?php endif; ?>
                        </li>
                    <?php endforeach; ?>
                </ul>
            <?php else: ?>
                <p class="muted">The applicant did not list individual repairs.</p>
            <?php endif; ?>

            <?php if ($repairs): ?>
                <h3 class="repairs-subhead">Urgent conditions</h3>
                <ul class="tag-list">
                    <?php foreach ($repairs as $r): ?>
                        <li class="pill"><?= e($r['category_label']) ?></li>
                    <?php endforeach; ?>
                </ul>
            <?php endif; ?>

            <?php if ($repairDetails): ?>
                <h3 class="repairs-subhead">Condition details</h3>
                <ul class="plain-list">
                    <?php foreach ($repairDetails as $d): ?>
                        <li>
                            <strong><?= e($d['category_label']) ?>:</strong>
                            <?php
                            $bits = [];
                            if ($d['details_text']) $bits[] = $d['details_text'];
                            $heating = [];
                            if ($d['heating_woodstove']) $heating[] = 'woodstove';
                            if ($d['heating_gas_propane']) $heating[] = 'gas/propane';
                            if ($d['heating_electric']) $heating[] = 'electric';
                            if ($d['heating_kerosene']) $heating[] = 'kerosene';
                            if ($heating) $bits[] = 'Heating: ' . implode(', ', $heating);
                            if ($d['water_source']) $bits[] = 'Water source: ' . $d['water_source'];
                            echo e($bits ? implode(' — ', $bits) : 'No additional detail.');
                            ?>
                        </li>
                    <?php endforeach; ?>
                </ul>
            <?php endif; ?>

            <?php if ($permission['full'] && !empty($case['additional_repair_details'])): ?>
                <h3 class="repairs-subhead">Applicant's additional details</h3>
                <p><?= nl2br(e($case['additional_repair_details'])) ?></p>
            <?php endif; ?>

            <?php if ($canClaim): ?>
                <div class="claim-actions">
                    <button type="button" class="btn btn-primary" id="open-claim-modal"
                            data-case-id="<?= (int)$case['id'] ?>"
                            data-application-id="<?= (int)$applicationId ?>"
                            data-case-number="<?= e($displayName ?? ($case['case_number'] ?? ('#' . (int)$case['id']))) ?>"
                            data-is-new-claim="<?= $myOrgCase === null ? '1' : '0' ?>">
                        <i class="fas fa-handshake"></i>
                        <?= $myOrgCase === null ? 'Claim for your organization' : 'Claim selected repairs' ?>
                    </button>
                    <p class="muted">Select individual repairs above to claim only part of the work (e.g. Roofing but not HVAC), or leave all selected to claim everything still unclaimed. Your organization gets its own case on this application; other organizations may claim other repairs.</p>
                </div>
            <?php endif; ?>
        </section>

        <details class="panel case-activity case-collapsible" <?= $activityCount > 0 ? 'open' : '' ?>>
            <summary><h2>Communications &amp; Activity</h2><span class="collapse-count"><?= $activityCount ?></span></summary>
            <?php if ($statusHistory || $assignments): ?>
                <ul class="activity-list">
                    <?php foreach ($statusHistory as $h): ?>
                        <li>
                            <span class="activity-time"><?= e(date('M j, Y g:i A', strtotime($h['changed_at']))) ?></span>
                            <strong><?= e($h['to_status'] ?? 'Status changed') ?></strong>
                            <?php if ($h['changed_by_name']): ?>by <?= e($h['changed_by_name']) ?><?php endif; ?>
                            <?php if ($h['notes']): ?><p class="muted"><?= e($h['notes']) ?></p><?php endif; ?>
                        </li>
                    <?php endforeach; ?>
                    <?php foreach ($assignments as $a): ?>
                        <li>
                            <span class="activity-time"><?= e(date('M j, Y g:i A', strtotime($a['performed_at']))) ?></span>
                            <strong>Assignment activity</strong> — <?= e($a['organization_name'] ?? 'Unknown org') ?>
                            <?php if ($a['performed_by_name']): ?>by <?= e($a['performed_by_name']) ?><?php endif; ?>
                        </li>
                    <?php endforeach; ?>
                </ul>
            <?php else: ?>
                <p class="muted">No activity yet.</p>
            <?php endif; ?>
        </details>

        <details class="panel case-tasks case-collapsible" <?= $tasks ? 'open' : '' ?>>
            <summary><h2>Tasks</h2><span class="collapse-count"><?= count(array_filter($tasks, fn($t) => !empty($t['id']))) ?></span></summary>
            <?php if ($tasks): ?>
                <ul class="plain-list">
                    <?php foreach ($tasks as $t): ?>
                        <?php if (!empty($t['id'])): ?>
                            <li>
                                <strong><?= e($t['description'] ?: 'Task') ?></strong>
                                <span class="pill <?= $t['status'] === 'completed' ? 'pill-green' : 'pill-amber' ?>"><?= e($t['status']) ?></span>
                                <?php if ($t['assigned_to_name']): ?><span class="muted">assigned to <?= e($t['assigned_to_name']) ?></span><?php endif; ?>
                            </li>
                        <?php else: ?>
                            <li><strong>Work order <?= e($t['work_order_number']) ?></strong> <span class="muted">no tasks yet</span></li>
                        <?php endif; ?>
                    <?php endforeach; ?>
                </ul>
            <?php else: ?>
                <p class="muted">No work orders or tasks recorded.</p>
            <?php endif; ?>
        </details>

        <details class="panel case-documents case-collapsible" <?= $documents ? 'open' : '' ?>>
            <summary><h2>Documents</h2><span class="collapse-count"><?= count($documents) ?></span></summary>
            <?php if ($documents): ?>
                <ul class="plain-list">
                    <?php foreach ($documents as $d): ?>
                        <li>
                            <strong><?= e($d['file_name']) ?></strong>
                            <span class="muted"><?= e($d['category_name'] ?? 'Uncategorized') ?></span>
                            <?php if ($d['uploaded_by_name']): ?><span class="muted">by <?= e($d['uploaded_by_name']) ?></span><?php endif; ?>
                        </li>
                    <?php endforeach; ?>
                </ul>
            <?php else: ?>
                <p class="muted">No documents uploaded.</p>
            <?php endif; ?>
        </details>

        <?php if ($permission['full'] && !empty($case['internal_notes'])): ?>
            <section class="panel case-internal-notes">
                <h2>Internal notes</h2>
                <p><?= nl2br(e($case['internal_notes'])) ?></p>
            </section>
        <?php endif; ?>

        <?php if ($canWithdraw || $canTerminate): ?>
            <section class="panel danger-zone-inline">
                <h4><i class="fas fa-triangle-exclamation"></i> Danger zone</h4>
                <?php if ($canWithdraw): ?>
                    <p><strong>Withdraw</strong> — the applicant no longer needs assistance. Only allowed after you have confirmed directly with the applicant — by phone, in person, or in writing. Closes the application and every organization's case on it.</p>
                    <button type="button" class="btn btn-danger btn-sm" id="open-withdraw-modal"
                            data-case-id="<?= (int)$case['id'] ?>"
                            data-case-number="<?= e($displayName ?? ($case['case_number'] ?? ('#' . (int)$case['id']))) ?>">
                        Withdraw application
                    </button>
                <?php endif; ?>
                <?php if ($canTerminate): ?>
                    <p style="margin-top: var(--space-3, 12px);"><strong>Terminate</strong> — the applicant is ineligible or failed to follow up. A human decision: at least one reason checkbox is required, and it is recorded on the application permanently.</p>
                    <button type="button" class="btn btn-danger btn-sm" id="open-terminate-modal"
                            data-application-id="<?= (int)$applicationId ?>"
                            data-case-number="<?= e($displayName ?? ($case['case_number'] ?? ('#' . (int)$case['id']))) ?>">
                        Terminate application
                    </button>
                <?php endif; ?>
            </section>
        <?php endif; ?>
    </div>
</main>

<?php if ($canClaim): ?>
<!-- Consequential action: claim confirmation modal -->
<div class="modal-overlay" id="claim-modal" role="dialog" aria-modal="true" aria-labelledby="claim-modal-title" hidden>
    <div class="modal-box">
        <div class="modal-header">
            <h3 id="claim-modal-title"><i class="fas fa-handshake"></i> Confirm claim</h3>
        </div>
        <div class="modal-body">
            <p>You are claiming <strong id="claim-case-number"></strong><span id="claim-org-line"> for <strong id="claim-org-name"></strong></span>.</p>
            <p><strong>This is a consequential action.</strong> If you proceed:</p>
            <ul class="danger-list">
                <li>The selected repair need(s) — <span id="claim-repair-summary"></span> — become your organization's responsibility.</li>
                <li id="claim-lock-line">Your organization gets its own case on this application. Other organizations may still claim other repair needs on the same application.</li>
                <li id="claim-cooldown-line">A 90-day progress window starts now: if no progress (task, communication, document, or milestone) is logged against your case for 90 days, your claim expires and the application becomes available to other organizations.</li>
                <li>The applicant, your team, and the coalition are notified of the claim.</li>
                <li>Your organization becomes responsible for the next pipeline steps (contact, assessment, scheduling).</li>
                <li>The claim is written to the immutable case ledger with your name.</li>
            </ul>
            <div class="field" id="claim-org-select-wrap" hidden>
                <label for="claim-org-select">Claiming organization</label>
                <select id="claim-org-select"></select>
            </div>
            <div class="field">
                <label for="claim-notes">Notes (optional — recorded with the claim)</label>
                <input type="text" id="claim-notes" maxlength="500" autocomplete="off">
            </div>
            <label class="danger-ack">
                <input type="checkbox" id="claim-ack">
                <span>I understand what claiming means and wish to proceed.</span>
            </label>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-secondary" id="claim-cancel">Cancel</button>
            <button type="button" class="btn btn-primary" id="claim-submit" disabled>Proceed with claim</button>
        </div>
    </div>
</div>
<?php endif; ?>

<?php if ($canWithdraw): ?>
<!-- Consequential action: withdraw confirmation modal -->
<div class="modal-overlay" id="withdraw-modal" role="dialog" aria-modal="true" aria-labelledby="withdraw-modal-title" hidden>
    <div class="modal-box">
        <div class="modal-header">
            <h3 id="withdraw-modal-title"><i class="fas fa-triangle-exclamation"></i> Withdraw application</h3>
        </div>
        <div class="modal-body">
            <p>You are about to withdraw <strong id="withdraw-case-number"></strong>. This cancels the application and closes every organization's case on it.</p>
            <p><strong>Human confirmation required.</strong> ARCHR never withdraws an application through automated processes or do-not-reply messages. You must have confirmed with the applicant directly before proceeding.</p>
            <div class="field">
                <label for="withdraw-method">How did the applicant confirm?</label>
                <select id="withdraw-method">
                    <option value="">— Select —</option>
                    <option value="phone">By phone</option>
                    <option value="in_person">In person</option>
                    <option value="written">In writing (letter / email from the applicant)</option>
                </select>
            </div>
            <div class="field">
                <label for="withdraw-detail">Confirmation details (who, how, when)</label>
                <input type="text" id="withdraw-detail" maxlength="500" autocomplete="off" placeholder="e.g. Spoke with the applicant by phone on Jul 28, 2026">
            </div>
            <div class="field">
                <label for="withdraw-reason">Reason (optional)</label>
                <input type="text" id="withdraw-reason" maxlength="500" autocomplete="off">
            </div>
            <label class="danger-ack">
                <input type="checkbox" id="withdraw-ack">
                <span>I confirmed this withdrawal directly with the applicant.</span>
            </label>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-secondary" id="withdraw-cancel">Cancel</button>
            <button type="button" class="btn btn-danger" id="withdraw-submit" disabled>Withdraw application</button>
        </div>
    </div>
</div>
<?php endif; ?>

<?php if ($canTerminate): ?>
<!-- Consequential action: terminate confirmation modal (checkbox reasons) -->
<div class="modal-overlay" id="terminate-modal" role="dialog" aria-modal="true" aria-labelledby="terminate-modal-title" hidden>
    <div class="modal-box">
        <div class="modal-header">
            <h3 id="terminate-modal-title"><i class="fas fa-circle-xmark"></i> Terminate application</h3>
        </div>
        <div class="modal-body">
            <p>You are about to terminate <strong id="terminate-case-number"></strong>. The applicant is deemed ineligible or has failed to follow up. This is a <strong>human decision</strong> — the system never terminates automatically — and it is recorded on the application permanently.</p>
            <fieldset class="field termination-reasons">
                <legend>Why is this application being terminated? <span class="muted">(select at least one)</span></legend>
                <?php foreach ($terminationReasons as $reason): ?>
                    <label class="termination-reason">
                        <input type="checkbox" class="terminate-reason-check" value="<?= e($reason) ?>">
                        <span><?= e($reason) ?></span>
                    </label>
                <?php endforeach; ?>
            </fieldset>
            <div class="field" id="terminate-other-wrap" hidden>
                <label for="terminate-other">Please specify the other reason</label>
                <input type="text" id="terminate-other" maxlength="500" autocomplete="off">
            </div>
            <div class="field">
                <label for="terminate-notes">Notes (optional — recorded with the termination)</label>
                <input type="text" id="terminate-notes" maxlength="500" autocomplete="off">
            </div>
            <label class="danger-ack">
                <input type="checkbox" id="terminate-ack">
                <span>I have reviewed the application and confirm this termination.</span>
            </label>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-secondary" id="terminate-cancel">Cancel</button>
            <button type="button" class="btn btn-danger" id="terminate-submit" disabled>Terminate application</button>
        </div>
    </div>
</div>
<?php endif; ?>

<script>
(function () {
    'use strict';

    function wireModal(modal, onOpen) {
        if (!modal) return null;
        function open() {
            modal.hidden = false;
            void modal.offsetWidth;
            modal.classList.add('open');
            if (onOpen) onOpen();
        }
        function close() {
            modal.classList.remove('open');
            setTimeout(() => { modal.hidden = true; }, 200);
        }
        modal.addEventListener('click', (e) => { if (e.target === modal) close(); });
        return { open, close };
    }

    async function postAction(form) {
        const res = await fetch('api/org-admin.php', { method: 'POST', body: form });
        return res.json().catch(() => ({}));
    }

    // ---------- Claim modal ----------
    const claimBtn = document.getElementById('open-claim-modal');
    if (claimBtn) {
        const modal = document.getElementById('claim-modal');
        const ack = document.getElementById('claim-ack');
        const submit = document.getElementById('claim-submit');
        const cancel = document.getElementById('claim-cancel');
        const orgWrap = document.getElementById('claim-org-select-wrap');
        const orgSelect = document.getElementById('claim-org-select');
        const orgLine = document.getElementById('claim-org-line');
        const orgNameEl = document.getElementById('claim-org-name');
        const orgs = <?= json_encode(array_values(array_map(fn($o) => ['id' => (int)$o['id'], 'name' => $o['organization_name']], $orgAdminOrgs)), JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) ?>;
        const isNewClaim = claimBtn.dataset.isNewClaim === '1';

        const repairBoxes = () => [...document.querySelectorAll('.repair-claim-check')];

        function updateClaimSubmit() {
            const boxes = repairBoxes();
            const anyChecked = boxes.some(cb => cb.checked);
            // With repair checkboxes present, at least one must stay selected;
            // with none (no repair rows listed), the case itself is claimed.
            submit.disabled = !(ack.checked && (boxes.length === 0 || anyChecked));
        }

        const ctl = wireModal(modal, () => {
            document.getElementById('claim-case-number').textContent = claimBtn.dataset.caseNumber;
            // Both notes always apply in the multi-org model: your org gets its
            // own case, and every claim carries the 90-day progress window.
            document.getElementById('claim-lock-line').style.display = '';
            document.getElementById('claim-cooldown-line').style.display = '';
            const selected = repairBoxes().filter(cb => cb.checked)
                .map(cb => cb.closest('.repair-need-row').querySelector('.repair-need-main strong').textContent);
            document.getElementById('claim-repair-summary').textContent =
                selected.length ? selected.join(', ') : 'the entire case (all repair needs)';
            if (orgs.length > 1) {
                orgWrap.hidden = false;
                orgSelect.innerHTML = orgs.map(o => `<option value="${o.id}">${o.name}</option>`).join('');
                orgNameEl.textContent = orgs[0].name;
                orgSelect.onchange = () => { orgNameEl.textContent = orgSelect.options[orgSelect.selectedIndex].text; };
            } else if (orgs.length === 1) {
                orgNameEl.textContent = orgs[0].name;
            } else {
                orgLine.style.display = 'none';
            }
            updateClaimSubmit();
        });

        claimBtn.addEventListener('click', ctl.open);
        cancel.addEventListener('click', ctl.close);
        ack.addEventListener('change', updateClaimSubmit);
        document.querySelectorAll('.repair-claim-check').forEach(cb => cb.addEventListener('change', updateClaimSubmit));

        submit.addEventListener('click', async () => {
            submit.disabled = true;
            submit.textContent = 'Claiming…';
            const form = new FormData();
            form.append('action', 'claim_case');
            form.append('application_id', claimBtn.dataset.applicationId);
            form.append('case_id', claimBtn.dataset.caseId);
            document.querySelectorAll('.repair-claim-check:checked').forEach(cb => form.append('repair_request_ids[]', cb.value));
            if (!orgWrap.hidden && orgSelect.value) form.append('organization_id', orgSelect.value);
            const notes = document.getElementById('claim-notes').value.trim();
            if (notes) form.append('notes', notes);
            const json = await postAction(form);
            if (json.success) {
                location.reload();
            } else {
                alert(json.error || 'Claim failed.');
                submit.disabled = false;
                submit.textContent = 'Proceed with claim';
            }
        });
    }

    // ---------- Release a repair claim ----------
    document.querySelectorAll('.repair-release-btn').forEach(btn => {
        btn.addEventListener('click', async () => {
            const label = btn.dataset.repairLabel || 'this repair';
            if (!window.confirm('Release your organization\'s claim on "' + label + '"? This is recorded in the case ledger.')) return;
            const form = new FormData();
            form.append('action', 'release_repair_claim');
            form.append('claim_id', btn.dataset.claimId);
            const json = await postAction(form);
            if (json.success) location.reload(); else alert(json.error || 'Release failed.');
        });
    });

    // ---------- Terminate modal (checkbox reasons) ----------
    const terminateBtn = document.getElementById('open-terminate-modal');
    if (terminateBtn) {
        const modal = document.getElementById('terminate-modal');
        const ack = document.getElementById('terminate-ack');
        const submit = document.getElementById('terminate-submit');
        const cancel = document.getElementById('terminate-cancel');
        const otherWrap = document.getElementById('terminate-other-wrap');
        const otherInput = document.getElementById('terminate-other');
        const notesInput = document.getElementById('terminate-notes');
        const reasonBoxes = () => [...document.querySelectorAll('.terminate-reason-check')];

        function update() {
            const checked = reasonBoxes().filter(cb => cb.checked);
            const otherChecked = checked.some(cb => cb.value === 'Other (please specify)');
            otherWrap.hidden = !otherChecked;
            const otherOk = !otherChecked || otherInput.value.trim().length >= 3;
            submit.disabled = !(ack.checked && checked.length > 0 && otherOk);
        }

        const ctl = wireModal(modal, () => {
            document.getElementById('terminate-case-number').textContent = terminateBtn.dataset.caseNumber;
            update();
        });

        terminateBtn.addEventListener('click', ctl.open);
        cancel.addEventListener('click', ctl.close);
        ack.addEventListener('change', update);
        otherInput.addEventListener('input', update);
        reasonBoxes().forEach(cb => cb.addEventListener('change', update));

        submit.addEventListener('click', async () => {
            submit.disabled = true;
            submit.textContent = 'Terminating…';
            const form = new FormData();
            form.append('action', 'terminate_application');
            form.append('application_id', terminateBtn.dataset.applicationId);
            reasonBoxes().filter(cb => cb.checked).forEach(cb => form.append('reasons[]', cb.value));
            if (!otherWrap.hidden && otherInput.value.trim()) form.append('other_reason', otherInput.value.trim());
            if (notesInput.value.trim()) form.append('notes', notesInput.value.trim());
            const json = await postAction(form);
            if (json.success) {
                location.reload();
            } else {
                alert(json.error || 'Termination failed.');
                submit.disabled = false;
                submit.textContent = 'Terminate application';
            }
        });
    }

    // ---------- Withdraw modal ----------
    const withdrawBtn = document.getElementById('open-withdraw-modal');
    if (withdrawBtn) {
        const modal = document.getElementById('withdraw-modal');
        const method = document.getElementById('withdraw-method');
        const detail = document.getElementById('withdraw-detail');
        const reason = document.getElementById('withdraw-reason');
        const ack = document.getElementById('withdraw-ack');
        const submit = document.getElementById('withdraw-submit');
        const cancel = document.getElementById('withdraw-cancel');

        function update() {
            submit.disabled = !(ack.checked && method.value && detail.value.trim().length >= 8);
        }

        const ctl = wireModal(modal, () => {
            document.getElementById('withdraw-case-number').textContent = withdrawBtn.dataset.caseNumber;
            update();
        });

        withdrawBtn.addEventListener('click', ctl.open);
        cancel.addEventListener('click', ctl.close);
        [method, detail].forEach(el => { el.addEventListener('input', update); el.addEventListener('change', update); });
        ack.addEventListener('change', update);

        submit.addEventListener('click', async () => {
            submit.disabled = true;
            submit.textContent = 'Withdrawing…';
            const form = new FormData();
            form.append('action', 'withdraw_case');
            form.append('case_id', withdrawBtn.dataset.caseId);
            form.append('requestor_confirmed', ack.checked ? '1' : '0');
            form.append('confirmation_method', method.value);
            form.append('confirmation_detail', detail.value.trim());
            if (reason.value.trim()) form.append('reason', reason.value.trim());
            const json = await postAction(form);
            if (json.success) {
                location.reload();
            } else {
                alert(json.error || 'Withdrawal failed.');
                submit.disabled = false;
                submit.textContent = 'Withdraw application';
            }
        });
    }
})();
</script>
