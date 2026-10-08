<?php
/** @var array $sub      Joined intake_submissions row (see dashboard.php). */
/** @var array $repairs  Rows from submission_repair_categories join. */
/** @var array $eligible Rows from eligibility_results join. */
/** @var ?DateTimeImmutable $submittedAt */
?>
<section class="two-col">
    <article class="panel">
        <div class="callout">
            <h3>Your next step</h3>
            <?php if ($sub['has_income'] === false || $sub['income_docs_method'] === 'email_link'): ?>
                <p><strong>Submit income documentation.</strong> Upload your last
                   three months of bank statements and a recent pay stub.</p>
            <?php elseif ($sub['anchor_status'] === 'in_review' || $sub['queue_status'] === 'IN_REVIEW'): ?>
                <p><strong>Awaiting caseworker review.</strong> You will hear from
                   your assigned caseworker once the file has been triaged.</p>
            <?php else: ?>
                <p><strong>Waiting on ARCHR staff.</strong> Your application is in
                   the review queue; expect a follow-up within 3&ndash;5 business days.</p>
            <?php endif; ?>
        </div>

        <h3>Your contact info on file</h3>
        <dl class="def-list">
            <dt>Name</dt>          <dd><?= e($sub['applicant_first_name'] . ' ' . $sub['applicant_last_name']) ?></dd>
            <?php if ($sub['contact_email']): ?>
                <dt>Email</dt>     <dd><?= e($sub['contact_email']) ?></dd>
            <?php endif; ?>
            <?php if ($sub['cell_phone']): ?>
                <dt>Cell</dt>      <dd><?= e($sub['cell_phone']) ?></dd>
            <?php endif; ?>
            <?php if ($sub['home_phone']): ?>
                <dt>Home phone</dt><dd><?= e($sub['home_phone']) ?></dd>
            <?php endif; ?>
            <?php if ($sub['home_address']): ?>
                <dt>Property</dt>  <dd>
                    <?= e($sub['home_address']) ?>,
                    <?= e($sub['home_city']) ?>, <?= e($sub['home_state']) ?>
                    <?= e($sub['home_zip']) ?>
                </dd>
            <?php endif; ?>
        </dl>

        <h3 style="margin-top: var(--space-5);">Repair categories you flagged</h3>
        <?php if ($repairs): ?>
            <ul>
                <?php foreach ($repairs as $r): ?>
                    <li><?= e($r['category_label']) ?></li>
                <?php endforeach; ?>
            </ul>
        <?php else: ?>
            <p class="empty-state">No repair categories on file.</p>
        <?php endif; ?>
    </article>

    <aside>
        <article class="panel">
            <div class="panel-header"><h3>Your caseworker</h3></div>
            <?php if ($sub['caseworker_name']): ?>
                <p><strong><?= e($sub['caseworker_name']) ?></strong></p>
                <?php if ($sub['assigned_org_name']): ?>
                    <p><small><?= e($sub['assigned_org_name']) ?></small></p>
                <?php endif; ?>
                <dl class="def-list">
                    <?php if ($sub['caseworker_email']): ?>
                        <dt>Email</dt> <dd><a href="mailto:<?= e($sub['caseworker_email']) ?>"><?= e($sub['caseworker_email']) ?></a></dd>
                    <?php endif; ?>
                    <?php if ($sub['caseworker_phone']): ?>
                        <dt>Phone</dt> <dd><?= e($sub['caseworker_phone']) ?></dd>
                    <?php endif; ?>
                </dl>
            <?php else: ?>
                <p class="empty-state">A caseworker hasn't been assigned yet.</p>
            <?php endif; ?>
        </article>

        <article class="panel">
            <div class="panel-header"><h3>Eligibility matches</h3></div>
            <?php if ($eligible): ?>
                <ul style="list-style:none; padding:0; margin:0; display:grid; gap: var(--space-3);">
                    <?php foreach ($eligible as $row): ?>
                        <li style="display:flex; justify-content:space-between; gap:var(--space-3);">
                            <span>
                                <strong><?= e($row['organization_name']) ?></strong><br>
                                <small>Match score <?= e((string)$row['match_score']) ?></small>
                            </span>
                            <span class="pill <?= $row['is_eligible'] ? 'green' : 'amber' ?>">
                                <?= $row['is_eligible'] ? 'Eligible' : 'Review needed' ?>
                            </span>
                        </li>
                    <?php endforeach; ?>
                </ul>
            <?php else: ?>
                <p class="empty-state">Eligibility evaluation is pending.</p>
            <?php endif; ?>
        </article>
    </aside>
</section>

<section class="panel">
    <div class="panel-header"><h2>Progress timeline</h2></div>
    <ol class="timeline">
        <?php if ($sub['queue_status'] !== 'COMPLETED'): ?>
            <li class="is-pending">
                <span class="dot"></span>
                <div>
                    <strong>Awaiting next action</strong>
                    <small>Current status: <?= e(ucwords(str_replace('_',' ', (string)($sub['queue_status'] ?: 'pending')))) ?></small>
                </div>
            </li>
        <?php endif; ?>
        <?php if ($sub['queue_assigned_at']): ?>
            <li><span class="dot"></span><div>
                <strong>Assigned to <?= e($sub['assigned_org_name'] ?: 'an ARCHR partner') ?></strong>
                <small><?= e((new DateTimeImmutable($sub['queue_assigned_at']))->format('M j, Y g:i A')) ?></small>
            </div></li>
        <?php endif; ?>
        <?php if ($sub['queued_at']): ?>
            <li><span class="dot"></span><div>
                <strong>Entered review queue</strong>
                <small><?= e((new DateTimeImmutable($sub['queued_at']))->format('M j, Y g:i A')) ?>
                       &middot; priority score <?= e((string)$sub['priority_score']) ?></small>
            </div></li>
        <?php endif; ?>
        <li><span class="dot"></span><div>
            <strong>Application submitted</strong>
            <small>
                <?= $submittedAt ? e($submittedAt->format('M j, Y g:i A')) : '—' ?>
                &middot; Reference <?= e($sub['case_number'] ?: $sub['anchor_id'] ?: ('#' . $sub['id'])) ?>
            </small>
        </div></li>
    </ol>
</section>
