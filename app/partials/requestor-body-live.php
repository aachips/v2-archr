<section class="portal-page active" data-page-title="My Application">
    <p class="login-banner" role="status">
        <i class="fas fa-lock"></i>
        <span>You are viewing your private application dashboard. Only you and your assigned ARCHR caseworker can see this information.</span>
    </p>

    <?php if (empty($submission)): ?>
        <section class="dash-hero" aria-labelledby="req-welcome">
            <div>
                <h2 id="req-welcome">Welcome, <?= e($fullName) ?></h2>
                <p>We don't have an application on file for this account yet. Once you submit a screening form, this page will show your status and next steps.</p>
            </div>
            <div class="dash-hero-meta">
                <a href="intake.php" class="btn btn-primary"><i class="fas fa-file-lines"></i> Start Application</a>
            </div>
        </section>
    <?php else: ?>
        <section class="dash-hero" aria-labelledby="req-welcome">
            <div>
                <h2 id="req-welcome">Welcome back, <?= e($firstName ?: $fullName) ?></h2>
                <p>Your application <strong><?= e($caseRef) ?></strong> is currently <strong><?= e(ucwords(str_replace('_', ' ', (string)$status))) ?></strong>.</p>
                <?php if ($submittedAt): ?>
                    <p class="updated"><i class="far fa-clock"></i> Submitted <?= e($submittedAt->format('M j, Y')) ?></p>
                <?php endif; ?>
            </div>
            <div class="dash-hero-meta">
                <span class="org-badge"><i class="fas fa-hashtag"></i> <?= e($caseRef) ?></span>
                <a href="#documents" class="btn btn-secondary"><i class="fas fa-cloud-arrow-up"></i> Upload Documents</a>
            </div>
        </section>

        <section class="dash-section active" aria-label="At-a-glance application status">
            <h3 class="dash-section-title"><i class="fas fa-clipboard-list"></i> Application At a Glance</h3>
            <div class="kpi-grid">
                <div class="kpi">
                    <span class="kpi-label">Status</span>
                    <span class="kpi-value" style="font-size:1.4rem;"><?= e(ucwords(str_replace('_', ' ', (string)$status))) ?></span>
                    <span class="kpi-sub"><span class="pill pill-amber">Documents may be needed</span></span>
                </div>
                <div class="kpi kpi-blue">
                    <span class="kpi-label">Days Since Submission</span>
                    <span class="kpi-value"><?= $submittedAt ? e((string)(int)$submittedAt->diff(new DateTimeImmutable())->format('%a')) : '-' ?></span>
                    <span class="kpi-sub"><?= $submittedAt ? e($submittedAt->format('M j, Y')) : '-' ?></span>
                </div>
                <div class="kpi kpi-amber">
                    <span class="kpi-label">Next Step</span>
                    <span class="kpi-value">Upload docs</span>
                    <span class="kpi-sub">Income or homeownership proof</span>
                </div>
                <div class="kpi kpi-green">
                    <span class="kpi-label">Property</span>
                    <span class="kpi-value" style="font-size:1rem;"><?= e(($submission['home_city'] ?? '') . ', ' . ($submission['home_state'] ?? '')) ?></span>
                    <span class="kpi-sub"><?= e($submission['home_address'] ?? '') ?></span>
                </div>
            </div>
        </section>

        <section class="dash-section active" aria-label="Next step and contact">
            <div class="dash-two-col">
                <div class="callout next-step">
                    <h3><i class="fas fa-arrow-right-long"></i> Your Next Step</h3>
                    <p><strong>Complete required documentation.</strong> Upload your last three months of bank statements, pay stubs, or homeownership documents. Files are encrypted at rest and visible only to your caseworker.</p>
                    <div class="action-row" style="margin-top: var(--space-4);">
                        <a href="#documents" class="btn btn-primary"><i class="fas fa-cloud-arrow-up"></i> Upload Documents</a>
                        <a href="mailto:support@archr.org" class="btn btn-secondary"><i class="fas fa-envelope"></i> Email Support</a>
                    </div>
                </div>

                <article class="panel" aria-labelledby="contact-h">
                    <div class="panel-header">
                        <h3 id="contact-h"><i class="fas fa-house"></i> Application Property</h3>
                    </div>
                    <div class="contact-card">
                        <ul>
                            <li><i class="fas fa-location-dot"></i> <?= e($submission['home_address'] ?? '—') ?></li>
                            <li><i class="fas fa-city"></i> <?= e(($submission['home_city'] ?? '') . ', ' . ($submission['home_state'] ?? '') . ' ' . ($submission['home_zip'] ?? '')) ?></li>
                            <li><i class="fas fa-envelope"></i> <?= e($submission['contact_email'] ?? '—') ?></li>
                        </ul>
                    </div>
                </article>
            </div>
        </section>

        <section class="dash-section active" id="documents" aria-labelledby="docs-h">
            <article class="panel">
                <div class="panel-header">
                    <h3 id="docs-h"><i class="fas fa-folder-open"></i> My Documents</h3>
                    <?php if (!empty($requestorDocs)): ?>
                        <span class="pill pill-accent"><?= count($requestorDocs) ?> on file</span>
                    <?php endif; ?>
                </div>
                <p class="muted" style="margin-bottom: var(--space-4);">
                    Upload proof of income (pay stubs, W-2, benefits letter, bank statements), homeownership
                    documents, or anything your caseworker asked for. Files are encrypted at rest and reviewed
                    by staff — you'll see their status here as soon as they're checked.
                </p>

                <?php if (!$docTablesReady): ?>
                    <p class="role-notice"><i class="fas fa-flask"></i>
                        <span>The document upload system is being rolled out. For now, please email documents to your caseworker.</span></p>
                <?php elseif ($requestorCaseId === null): ?>
                    <p class="role-notice"><i class="fas fa-circle-info"></i>
                        <span>Document upload opens once your application becomes an active case.</span></p>
                <?php else: ?>
                    <form id="docUploadForm" enctype="multipart/form-data" style="display:grid; gap: var(--space-3); max-width: 560px;">
                        <label style="display:grid; gap: var(--space-1); font-weight:600; font-size: var(--fs-sm);">
                            Document type
                            <select name="doc_code" required style="font:inherit; padding: 8px 10px; border:1px solid var(--color-border-strong); border-radius: var(--radius-sm); background: var(--bg-surface); color: var(--color-text);">
                                <?php foreach ($requestorDocCodes as $code => $label): ?>
                                    <option value="<?= e($code) ?>"><?= e($label) ?></option>
                                <?php endforeach; ?>
                            </select>
                        </label>
                        <label style="display:grid; gap: var(--space-1); font-weight:600; font-size: var(--fs-sm);">
                            File
                            <input type="file" name="file" accept=".pdf,.jpg,.jpeg,.png,.docx" required>
                            <small class="muted">PDF, JPG, PNG, or DOCX &middot; max 25 MB</small>
                        </label>
                        <label style="display:grid; gap: var(--space-1); font-weight:600; font-size: var(--fs-sm);">
                            Note for your caseworker (optional)
                            <textarea name="notes" rows="2" style="font:inherit; padding: 8px 10px; border:1px solid var(--color-border-strong); border-radius: var(--radius-sm); background: var(--bg-surface); color: var(--color-text);" placeholder="e.g. pay stubs for June–August"></textarea>
                        </label>
                        <div>
                            <button type="submit" class="btn btn-primary" id="docUploadBtn"><i class="fas fa-cloud-arrow-up"></i> Upload for review</button>
                            <span class="muted" id="docUploadStatus" role="status" style="margin-left: var(--space-3);"></span>
                        </div>
                    </form>

                    <?php if (!empty($requestorDocs)): ?>
                        <div class="table-wrap" style="margin-top: var(--space-5);">
                            <table class="data-table">
                                <thead><tr><th>Document</th><th>Type</th><th>Uploaded</th><th>Status</th></tr></thead>
                                <tbody>
                                    <?php foreach ($requestorDocs as $doc): ?>
                                        <tr>
                                            <td><code><?= e($doc['name']) ?></code></td>
                                            <td><?= e($doc['code'] !== '' ? $doc['code'] : '—') ?></td>
                                            <td><?= e($doc['meta'] !== '' ? $doc['meta'] : '—') ?></td>
                                            <td>
                                                <?php [$pillCls, $pillIcon, $pillLabel] = archr_doc_status($doc); ?>
                                                <span class="pill <?= e($pillCls) ?>"><i class="fas <?= e($pillIcon) ?>"></i> <?= e($pillLabel) ?></span>
                                                <?php if ($doc['status'] === 'pending'): ?>
                                                    <br><small class="muted">Under review — no action needed.</small>
                                                <?php endif; ?>
                                            </td>
                                        </tr>
                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        </div>
                    <?php endif; ?>
                <?php endif; ?>
            </article>
        </section>

        <section class="dash-section active" aria-label="Progress timeline">
            <article class="panel" aria-labelledby="updates-h">
                <div class="panel-header">
                    <h3 id="updates-h"><i class="fas fa-clock-rotate-left"></i> Progress Timeline</h3>
                </div>
                <ul class="timeline">
                    <li class="timeline-item">
                        <span class="dot" aria-hidden="true"></span>
                        <div>
                            <strong>Application submitted</strong>
                            <small><?= $submittedAt ? e($submittedAt->format('M j, Y')) : '—' ?> &middot; <?= e($caseRef) ?> received</small>
                        </div>
                    </li>
                    <li class="timeline-item is-pending">
                        <span class="dot" aria-hidden="true"></span>
                        <div>
                            <strong>Awaiting review</strong>
                            <small>A staff member will review your application and contact you within 3&ndash;5 business days.</small>
                        </div>
                    </li>
                </ul>
            </article>
        </section>

        <section class="dash-section active" aria-labelledby="actions-h">
            <h3 class="dash-section-title" id="actions-h"><i class="fas fa-bolt"></i> Quick Actions</h3>
            <div class="action-row">
                <a href="#documents" class="btn btn-primary"><i class="fas fa-cloud-arrow-up"></i> Upload Documents</a>
                <a href="mailto:support@archr.org" class="btn btn-secondary"><i class="fas fa-envelope"></i> Contact Support</a>
            </div>
            <p class="role-notice">
                <i class="fas fa-shield-halved"></i>
                <span><strong>Single source of truth:</strong> every email, phone call, and platform message about your case is logged here.</span>
            </p>
        </section>
    <?php endif; ?>
</section>

<?php if (!empty($requestorCaseId)): ?>
<script>
(function(){
    var form = document.getElementById('docUploadForm');
    if (!form) return;
    var btn = document.getElementById('docUploadBtn');
    var status = document.getElementById('docUploadStatus');
    form.addEventListener('submit', function(e){
        e.preventDefault();
        var fd = new FormData(form);
        fd.set('action', 'upload');
        fd.set('case_id', '<?= (int)$requestorCaseId ?>');
        btn.disabled = true;
        status.textContent = 'Uploading…';
        fetch('api/documents.php', { method: 'POST', body: fd })
            .then(function(r){ return r.json(); })
            .then(function(res){
                if (res && res.success) {
                    status.textContent = 'Received — pending staff review.';
                    setTimeout(function(){ location.reload(); }, 900);
                } else {
                    status.textContent = (res && res.error) ? res.error : 'Upload failed.';
                    btn.disabled = false;
                }
            })
            .catch(function(){
                status.textContent = 'Network error — please try again.';
                btn.disabled = false;
            });
    });
})();
</script>
<?php endif; ?>
