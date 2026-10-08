<?php
declare(strict_types=1);
/** Case Documents body partial.
 *
 *  Data comes from case-documents.php:
 *    $view        'case' | 'overview'
 *    $bundle      ['case'=>..., 'documents'=>[...]] (live from
 *                 app/lib/case-documents.php, or the sample bundle when the
 *                 document tables are not deployed — $sampleMode flags that)
 *    $cases       org-scoped case list (selector + overview table)
 *    $inventory   case_document_inventory rollups (overview mode)
 *    $queueRows   pending_verification_documents rows
 *    $templates / $tokenMeta  from document-generation/document-tokens.json
 *
 *  Statuses follow document_statuses (sql/document-storage.sql) plus the
 *  derived 'missing' state (required checklist doc with no file yet).
 */

$folders = archr_doc_folders();

if ($view === 'case' && $bundle) {
    $caseRow = $bundle['case'];
    $documents = $bundle['documents'];
    $case = [
        'number'    => (string)$caseRow['case_number'],
        'address'   => trim(($caseRow['home_address'] ?? '') . ', ' . ($caseRow['home_city'] ?? '') . ', ' . ($caseRow['home_state'] ?? '') . ' ' . ($caseRow['home_zip'] ?? ''), ' ,'),
        'requestor' => trim(($caseRow['applicant_first_name'] ?? '') . ' ' . ($caseRow['applicant_last_name'] ?? '')),
        'org'       => $caseRow['organization_name'] ?? '—',
        'phase'     => $caseRow['phase'] ?? '',
    ];
} else {
    $documents = [];
    $case = ['number' => '', 'address' => '', 'requestor' => '', 'org' => '', 'phase' => ''];
}

// $documents rows: folder, icon, name|label, status
// (verified|pending|missing|generated|rejected), origin (generated|uploaded),
// origin_label, meta, expected, note, generate_template, actions[], id (live).



// ---- Derived counts -------------------------------------------------------
$folderCounts = [];
foreach (array_keys($folders) as $f) {
    $folderCounts[$f] = ['present' => 0, 'total' => 0, 'worst' => 'green'];
}
$requiredTotal = 0;
$requiredPresent = 0;
$pendingVerification = 0;
$missingCount = 0;
$generatedCount = 0;
foreach ($documents as $doc) {
    $f = $doc['folder'];
    if (!isset($folderCounts[$f])) continue;
    $folderCounts[$f]['total']++;
    $requiredTotal++;
    if ($doc['status'] !== 'missing') {
        $folderCounts[$f]['present']++;
        $requiredPresent++;
    }
    if ($doc['status'] === 'pending')   $pendingVerification++;
    if ($doc['status'] === 'missing')   $missingCount++;
    if (($doc['origin'] ?? '') === 'generated') $generatedCount++;
}
foreach (array_keys($folderCounts) as $f) {
    $worst = $folderCounts[$f]['total'] === 0 ? 'grey' : 'green';
    foreach ($documents as $doc) {
        if ($doc['folder'] !== $f) continue;
        if ($doc['status'] === 'missing')  $worst = 'red';
        if ($doc['status'] === 'pending' && $worst !== 'red') $worst = 'amber';
    }
    $folderCounts[$f]['worst'] = $worst;
}

/* Status pill + action-row renderers live in lib/case-documents.php
   (shared with the requestor portal). */
?>
<section class="portal-page active" id="caseDocumentsPage" data-page-title="Case Documents">

<?php if ($view === 'overview'): ?>
    <!-- ============ ORG OVERVIEW (case_document_inventory + pending_verification_documents) ============ -->
    <section class="dash-hero" aria-labelledby="ov-title">
        <div>
            <h2 id="ov-title">Case Documents</h2>
            <p>Document health across your organization's cases. Open a case for its full directory,
               or work the verification queue below.</p>
        </div>
        <div class="dash-hero-meta">
            <span class="hero-count"><?= count($queueRows) ?></span>
            <span class="hero-count-label">awaiting verification</span>
        </div>
    </section>

    <section class="panel" aria-labelledby="ov-cases-h" style="margin-bottom: var(--space-6);">
        <div class="panel-header"><h3 id="ov-cases-h"><i class="fas fa-folder-tree"></i> Cases</h3></div>
        <?php if (!$cases): ?>
            <p class="empty-state">No cases in your organization yet.</p>
        <?php else: ?>
            <div class="table-wrap">
                <table class="data-table">
                    <thead><tr>
                        <th>Case</th><th>Applicant</th><th>Address</th>
                        <th>Docs</th><th>Verified</th><th>Pending</th><th>Last upload</th><th></th>
                    </tr></thead>
                    <tbody>
                        <?php foreach ($cases as $c): $inv = $inventory[(int)$c['case_id']] ?? null; ?>
                            <tr>
                                <td><strong><?= e((string)($c['case_number'] ?? ('#' . $c['case_id']))) ?></strong></td>
                                <td><?= e(trim(($c['applicant_first_name'] ?? '') . ' ' . ($c['applicant_last_name'] ?? ''))) ?></td>
                                <td><?= e((string)($c['home_address'] ?? '')) ?></td>
                                <td><?= $inv ? (int)$inv['present'] : 0 ?></td>
                                <td><span class="pill pill-green"><?= $inv ? (int)$inv['verified'] : 0 ?></span></td>
                                <td><?php if ($inv && (int)$inv['pending'] > 0): ?><span class="pill pill-amber"><?= (int)$inv['pending'] ?></span><?php else: ?><span class="pill">0</span><?php endif; ?></td>
                                <td><?= !empty($inv['last_upload']) ? e((new DateTimeImmutable((string)$inv['last_upload']))->format('M j, Y')) : '—' ?></td>
                                <td><a class="btn btn-secondary btn-sm" href="case-documents.php?case=<?= (int)$c['case_id'] ?>">Open</a></td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        <?php endif; ?>
    </section>

    <section class="panel" aria-labelledby="ov-queue-h">
        <div class="panel-header">
            <h3 id="ov-queue-h"><i class="fas fa-shield-halved"></i> Verification queue</h3>
            <span class="pill pill-amber"><?= count($queueRows) ?> awaiting review</span>
        </div>
        <?php if (!$queueRows): ?>
            <p class="empty-state">Nothing waiting for review.</p>
        <?php else: ?>
            <div class="table-wrap">
                <table class="data-table">
                    <thead><tr><th>Document</th><th>Case</th><th>Applicant</th><th>Category</th><th>Uploaded by</th><th>When</th><th>Actions</th></tr></thead>
                    <tbody>
                        <?php foreach ($queueRows as $q): ?>
                            <tr>
                                <td><code><?= e((string)$q['file_name']) ?></code></td>
                                <td><?= e((string)$q['case_number']) ?></td>
                                <td><?= e(trim(($q['applicant_first_name'] ?? '') . ' ' . ($q['applicant_last_name'] ?? ''))) ?></td>
                                <td><?= e((string)$q['category_name']) ?></td>
                                <td><?= e((string)($q['uploaded_by_name'] ?? '—')) ?></td>
                                <td><?= e((new DateTimeImmutable((string)$q['uploaded_at']))->format('M j, Y')) ?></td>
                                <td>
                                    <a href="case-documents.php?case=<?= (int)($q['case_id'] ?? 0) ?>&review=<?= (int)$q['id'] ?>" class="btn btn-accent btn-sm"><i class="fas fa-eye"></i> Review</a>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        <?php endif; ?>
    </section>

<?php else: ?>
    <!-- ============ CASE CONTEXT ============ -->
    <section class="dash-hero" aria-labelledby="case-title">
        <div>
            <h2 id="case-title">Case Documents &middot; <?= e($case['number']) ?></h2>
            <p>Structured case directory. Folders and naming follow the document-storage standard; the storage
               provider (Dropbox / home server) sits behind the documents API.</p>
            <?php if ($sampleMode): ?>
                <p><span class="pill pill-amber"><i class="fas fa-flask"></i> Sample data</span>
                   <span class="muted" style="color:#fff;opacity:.85;"> — document tables not deployed; showing the prototype case.</span></p>
            <?php endif; ?>
            <div class="case-meta">
                <span><i class="fas fa-location-dot"></i> <?= e($case['address']) ?></span>
                <span><i class="fas fa-user"></i> <?= e($case['requestor']) ?> (requestor)</span>
                <span><i class="fas fa-building"></i> <?= e($case['org']) ?></span>
                <?php if ($case['phase'] !== ''): ?><span><i class="fas fa-diagram-project"></i> <?= e($case['phase']) ?></span><?php endif; ?>
            </div>
            <?php if ($cases): ?>
                <form method="get" action="case-documents.php" style="margin-top: var(--space-3); display:flex; gap: var(--space-2); align-items:center;">
                    <label for="caseSelect" class="sr-only">Switch case</label>
                    <select id="caseSelect" name="case" onchange="this.form.submit()">
                        <option value="">— Switch case —</option>
                        <?php foreach ($cases as $c): ?>
                            <option value="<?= (int)$c['case_id'] ?>" <?= (int)($caseRow['id'] ?? 0) === (int)$c['case_id'] ? 'selected' : '' ?>>
                                <?= e(($c['case_number'] ?? ('#' . $c['case_id'])) . ' · ' . trim(($c['applicant_first_name'] ?? '') . ' ' . ($c['applicant_last_name'] ?? ''))) ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                    <a class="btn btn-secondary btn-sm" href="case-documents.php"><i class="fas fa-table-list"></i> All cases</a>
                </form>
            <?php endif; ?>
        </div>
        <div class="hero-actions">
            <button type="button" class="btn btn-secondary" id="uploadBtn"><i class="fas fa-upload"></i> Upload Document</button>
            <button type="button" class="btn btn-primary" id="generateBtn"><i class="fas fa-wand-magic-sparkles"></i> Generate Document</button>
        </div>
    </section>

    <!-- ============ KPIs ============ -->
    <div class="kpi-grid" aria-label="Document status summary">
        <div class="kpi kpi-ok"><span class="kpi-label">Required present</span><span class="kpi-value"><?= $requiredPresent ?> / <?= $requiredTotal ?></span><span class="kpi-sub">Across <?= count($folders) ?> case folders</span></div>
        <div class="kpi kpi-warn"><span class="kpi-label">Pending verification</span><span class="kpi-value"><?= $pendingVerification ?></span><span class="kpi-sub">Uploaded by requestor / subcontractor</span></div>
        <div class="kpi"><span class="kpi-label">Missing required</span><span class="kpi-value"><?= $missingCount ?></span><span class="kpi-sub">Need upload or generation</span></div>
        <div class="kpi"><span class="kpi-label">Generated on the spot</span><span class="kpi-value"><?= $generatedCount ?></span><span class="kpi-sub">From token templates</span></div>
    </div>

    <!-- ============ DIRECTORY + DOCUMENTS ============ -->
    <div class="docs-layout">
        <nav class="panel" aria-label="Case folder directory">
            <div class="panel-header"><h3><i class="fas fa-folder-tree"></i> Case Directory</h3></div>
            <ul class="doc-tree" id="docTree">
                <li class="doc-tree-item">
                    <button type="button" class="doc-tree-link active" data-folder="all">
                        <i class="fas fa-layer-group"></i> All documents
                        <span class="doc-tree-count"><?= $requiredTotal ?></span>
                    </button>
                </li>
                <?php foreach ($folders as $key => $f): $c = $folderCounts[$key]; ?>
                <li class="doc-tree-item">
                    <button type="button" class="doc-tree-link" data-folder="<?= e($key) ?>">
                        <span class="doc-tree-dot dot-<?= e($c['worst']) ?>"></span>
                        <i class="fas <?= e($f['icon']) ?>"></i> <?= e($f['label']) ?>
                        <span class="doc-tree-count"><?= $c['present'] . '/' . $c['total'] ?></span>
                    </button>
                </li>
                <?php endforeach; ?>
            </ul>
        </nav>

        <div>
            <?php foreach ($folders as $folderKey => $folder): ?>
                <?php $folderDocs = array_values(array_filter($documents, fn($d) => $d['folder'] === $folderKey)); ?>
                <section class="doc-folder-block" data-folder="<?= e($folderKey) ?>" aria-labelledby="f-<?= e($folderKey) ?>">
                    <h4 class="doc-folder-title" id="f-<?= e($folderKey) ?>">
                        <i class="fas <?= e($folder['icon']) ?>"></i> <?= e($folder['label']) ?>
                        <span class="folder-path">/cases/<?= e($case['number']) ?>/<?= e($folder['path']) ?></span>
                    </h4>
                    <?php if (!$folderDocs): ?>
                        <p class="muted">No documents in this folder yet.</p>
                    <?php else: ?>
                        <ul class="doc-list">
                            <?php foreach ($folderDocs as $doc): [$pillCls, $pillIcon, $pillLabel] = archr_doc_status($doc); ?>
                                <li class="doc-row status-<?= e($doc['status']) ?>">
                                    <span class="doc-icon"><i class="fas <?= e($doc['icon']) ?>"></i></span>
                                    <div>
                                        <?php if ($doc['status'] === 'missing'): ?>
                                            <span class="doc-label"><?= e($doc['label']) ?></span>
                                        <?php else: ?>
                                            <span class="doc-name"><?= e($doc['name']) ?></span>
                                        <?php endif; ?>
                                        <div class="doc-meta">
                                            <span class="pill <?= e($pillCls) ?>"><i class="fas <?= e($pillIcon) ?>"></i> <?= e($doc['status_note'] ?? $pillLabel) ?></span>
                                            <?php if (!empty($doc['origin_label'])): ?>
                                                <span class="pill <?= $doc['origin'] === 'uploaded' ? 'pill-blue' : 'pill-accent' ?>">
                                                    <i class="fas <?= $doc['origin'] === 'uploaded' ? 'fa-upload' : 'fa-wand-magic-sparkles' ?>"></i> <?= e($doc['origin_label']) ?>
                                                </span>
                                            <?php endif; ?>
                                            <?php if (!empty($doc['expected'])): ?>
                                                <span>Expected: <code><?= e($doc['expected']) ?></code></span>
                                            <?php endif; ?>
                                            <?php if (!empty($doc['note'])): ?>
                                                <span><?= e($doc['note']) ?></span>
                                            <?php endif; ?>
                                            <?php if (!empty($doc['meta'])): ?>
                                                <span><?= e($doc['meta']) ?></span>
                                            <?php endif; ?>
                                        </div>
                                    </div>
                                    <div class="doc-actions"><?= archr_doc_actions($doc) ?></div>
                                </li>
                            <?php endforeach; ?>
                        </ul>
                    <?php endif; ?>
                </section>
            <?php endforeach; ?>
        </div>
    </div>

    <!-- ============ VERIFICATION QUEUE ============ -->
    <?php $queueDocs = array_values(array_filter($documents, fn($d) => $d['status'] === 'pending')); ?>
    <section class="panel" style="margin-top: var(--space-6);" aria-labelledby="verify-h">
        <div class="panel-header">
            <h3 id="verify-h"><i class="fas fa-shield-halved"></i> Verification queue</h3>
            <span class="pill pill-amber"><?= count($queueDocs) ?> awaiting review</span>
        </div>
        <p class="muted" style="margin-bottom: var(--space-4);">Uploaded by requestors, assessors, or subcontractors.
           Verify to accept the document as evidence; reject with a reason to notify the uploader.</p>
        <?php if (!$queueDocs): ?>
            <p class="muted">Nothing waiting for review.</p>
        <?php else: ?>
            <div class="table-wrap">
                <table class="data-table" id="verifyTable">
                    <thead><tr><th>Document</th><th>Folder</th><th>Uploaded by</th><th>When</th><th>Actions</th></tr></thead>
                    <tbody>
                        <?php foreach ($queueDocs as $doc): $qid = (int)($doc['id'] ?? 0); ?>
                            <tr>
                                <td><code><?= e($doc['name']) ?></code></td>
                                <td><?= e($folders[$doc['folder']]['label'] ?? $doc['folder']) ?></td>
                                <td><?= e($doc['origin_label'] ?? '') ?></td>
                                <td><?= e($doc['meta'] ?? '') ?></td>
                                <td>
                                    <?php if ($qid > 0): ?>
                                        <button type="button" class="btn btn-accent btn-sm" data-review data-doc-id="<?= $qid ?>"><i class="fas fa-eye"></i> Review</button>
                                    <?php else: ?>
                                        <button type="button" class="btn btn-accent btn-sm" data-demo><i class="fas fa-eye"></i> Review</button>
                                    <?php endif; ?>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        <?php endif; ?>
    </section>
<?php endif; ?>
</section>


<!-- ============ GENERATE DOCUMENT MODAL ============ -->
<div class="doc-modal-backdrop" id="generateModal" role="dialog" aria-modal="true" aria-labelledby="gen-h">
    <div class="doc-modal">
        <div class="doc-modal-head">
            <h3 id="gen-h"><i class="fas fa-wand-magic-sparkles"></i> Generate document</h3>
            <button type="button" class="doc-modal-close" data-close aria-label="Close"><i class="fas fa-xmark"></i></button>
        </div>
        <div class="doc-modal-body">
            <?php if ($templates === []): ?>
                <p class="pill pill-red" style="margin-bottom: var(--space-3);"><i class="fas fa-triangle-exclamation"></i>
                    Token registry failed to load — check document-tokens.json for valid JSON.</p>
            <?php endif; ?>
            <div class="cmp-field">
                <label for="templateSelect">Template (DocCode)</label>
                <select id="templateSelect"></select>
                <span class="muted" id="templateMeta"></span>
            </div>
            <p class="muted" style="margin-bottom: var(--space-3);">
                Token fields load from <code>elemental-integration/document-generation/document-tokens.json</code>.
                Values marked <span class="pill pill-green">auto</span> resolve from case/org data;
                <span class="pill pill-amber">input</span> fields are entered on the spot.
            </p>
            <div id="tokenFields"></div>
        </div>
        <div class="doc-modal-foot">
            <span class="muted" id="genStatus">No missing values</span>
            <div style="display:flex; gap: var(--space-2);">
                <button type="button" class="btn btn-secondary" id="previewBtn"><i class="fas fa-eye"></i> Preview payload</button>
                <button type="button" class="btn btn-primary" id="generateNowBtn"><i class="fas fa-bolt"></i> Generate &amp; store in case folder</button>
            </div>
        </div>
    </div>
</div>

<!-- ============ UPLOAD DOCUMENT MODAL ============ -->
<div class="doc-modal-backdrop" id="uploadModal" role="dialog" aria-modal="true" aria-labelledby="up-h">
    <div class="doc-modal">
        <div class="doc-modal-head">
            <h3 id="up-h"><i class="fas fa-upload"></i> Upload document</h3>
            <button type="button" class="doc-modal-close" data-close aria-label="Close"><i class="fas fa-xmark"></i></button>
        </div>
        <form id="uploadForm" enctype="multipart/form-data">
            <div class="doc-modal-body">
                <p class="muted" style="margin-bottom: var(--space-3);">
                    The file lands in the case folder and enters the verification queue as
                    <span class="pill pill-amber">pending verification</span> until a staff member verifies it.
                </p>
                <div class="cmp-field">
                    <label for="uploadDocCode">Document code</label>
                    <select id="uploadDocCode" name="doc_code" required>
                        <?php foreach ($docCodes as $code => $label): ?>
                            <option value="<?= e($code) ?>"><?= e($code . ' — ' . $label) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="cmp-field">
                    <label for="uploadFile">File <span style="color:var(--color-danger)">*</span></label>
                    <input type="file" id="uploadFile" name="file" accept=".pdf,.jpg,.jpeg,.png,.docx" required>
                    <span class="muted">PDF, JPG, PNG, or DOCX &middot; max 25 MB</span>
                </div>
                <div class="cmp-field">
                    <label for="uploadNotes">Notes for the reviewer</label>
                    <textarea id="uploadNotes" name="notes" rows="2" placeholder="Optional context (source, date range covered, &hellip;)"></textarea>
                </div>
            </div>
            <div class="doc-modal-foot">
                <span class="muted">Stored under the active storage provider (local until Dropbox/home-server sync lands).</span>
                <button type="submit" class="btn btn-primary"><i class="fas fa-cloud-arrow-up"></i> Upload to case folder</button>
            </div>
        </form>
    </div>
</div>

<!-- ============ DOCUMENT REVIEW MODAL ============ -->
<div class="doc-modal-backdrop" id="reviewModal" role="dialog" aria-modal="true" aria-labelledby="rev-h">
    <div class="doc-modal">
        <div class="doc-modal-head">
            <h3 id="rev-h"><i class="fas fa-eye"></i> Review document</h3>
            <button type="button" class="doc-modal-close" data-close aria-label="Close"><i class="fas fa-xmark"></i></button>
        </div>
        <div class="doc-modal-body">
            <div class="review-meta" id="reviewMeta"></div>
            <div class="review-viewer" id="reviewViewer">
                <div class="review-viewer-fallback">Loading…</div>
            </div>
            <div class="cmp-field">
                <label for="reviewComment">Comment <span class="muted">(required when not verifying — sent to the uploader)</span></label>
                <textarea id="reviewComment" class="review-comment" rows="3" placeholder="e.g. Pay stub is cut off — please re-upload the full page"></textarea>
            </div>
        </div>
        <div class="doc-modal-foot">
            <span class="muted" id="reviewStatus"></span>
            <div class="review-actions">
                <button type="button" class="btn btn-amber" id="reviewNeedsInfo"><i class="fas fa-circle-question"></i> Request more info</button>
                <button type="button" class="btn btn-danger" id="reviewReject"><i class="fas fa-xmark"></i> Reject</button>
                <button type="button" class="btn btn-accent" id="reviewVerify"><i class="fas fa-shield-halved"></i> Verify</button>
            </div>
        </div>
    </div>
</div>

<?php
/* Auto-fill values: what the case/org records already know. In live case
   mode these come from the case row; sample values cover the demo bundle. */
$tokenAuto = [
    'docHomeFullName' => 'Maria Lopez', 'docHomeFirstName' => 'Maria',
    'docHomeFullAddress' => '42 Cherry St, Asheville, NC 28801', 'docHomeStreetAddress' => '42 Cherry St',
    'docHomeCity' => 'Asheville', 'docHomeState' => 'NC', 'docHomeZip' => '28801', 'docHomeCounty' => 'Buncombe',
    'docHomeGIS_PIN' => '0609867552345562',
    'docOrgShort' => 'AAHH', 'docOrgLong' => 'Asheville Area Habitat for Humanity',
    'docAuthor' => 'Alex Lee', 'docAuthorEmail' => 'alee@aahh.example.org', 'docAuthorTitle' => 'Program Coordinator',
    'docDate' => date('Y-m-d'),
    'grantNumber' => 'CDBG-B-26-0017', 'docGrantFY' => 'FY27', 'docGrantCategoryYear' => '2026',
];
if ($view === 'case' && !$sampleMode && $bundle) {
    $cr = $bundle['case'];
    $fullName = trim(($cr['applicant_first_name'] ?? '') . ' ' . ($cr['applicant_last_name'] ?? ''));
    $addr = trim((string)($cr['home_address'] ?? ''));
    $cityState = trim(($cr['home_city'] ?? '') . ', ' . ($cr['home_state'] ?? '') . ' ' . ($cr['home_zip'] ?? ''), ' ,');
    $tokenAuto['docHomeFullName'] = $fullName !== '' ? $fullName : $tokenAuto['docHomeFullName'];
    $tokenAuto['docHomeFirstName'] = (string)($cr['applicant_first_name'] ?? $tokenAuto['docHomeFirstName']);
    $tokenAuto['docHomeFullAddress'] = trim($addr . ', ' . $cityState, ' ,') ?: $tokenAuto['docHomeFullAddress'];
    if ($addr !== '') $tokenAuto['docHomeStreetAddress'] = $addr;
    if (!empty($cr['home_city']))  $tokenAuto['docHomeCity'] = $cr['home_city'];
    if (!empty($cr['home_state'])) $tokenAuto['docHomeState'] = $cr['home_state'];
    if (!empty($cr['home_zip']))   $tokenAuto['docHomeZip'] = (string)$cr['home_zip'];
    if (!empty($cr['organization_name'])) $tokenAuto['docOrgLong'] = $cr['organization_name'];
    $tokenAuto['docAuthor'] = $_SESSION['archr_user_name'] ?? $tokenAuto['docAuthor'];
    unset($tokenAuto['grantNumber'], $tokenAuto['docGrantFY'], $tokenAuto['docGrantCategoryYear'], $tokenAuto['docHomeGIS_PIN']);
}
$docCodes = [];
foreach (archr_doc_required_checklist() as $folderKey => $items) {
    foreach ($items as $item) {
        $docCodes[$item['code']] = $item['label'] . ' · ' . $folders[$folderKey]['label'];
    }
}
$docCodes['OTHER'] = 'Other document';
?>
<script>
/* Token registry loaded from document-generation/document-tokens.json by
   case-documents.php — update the JSON and this UI follows. */
const DOC_TOKENS = <?= json_encode([
    'templates' => $templates,
    'meta'      => $tokenMeta,
    'auto'      => $tokenAuto,
], JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) ?>;
const DOC_CASE_ID = <?= (int)($caseRow['id'] ?? 0) ?>;
const DOC_API = 'api/documents.php';

function docDemo(){ alert('Sample data mode — deploy the document tables (sql/document-storage.sql) to act on real documents.'); }
document.querySelectorAll('[data-demo]').forEach(function(b){ b.addEventListener('click', docDemo); });
document.querySelectorAll('[data-request]').forEach(function(b){ b.addEventListener('click', function(){ alert('Prototype: sends the requestor an upload request for this document.'); }); });

function docPost(payload, onSuccess){
    fetch(DOC_API, { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: new URLSearchParams(payload) })
        .then(function(r){ return r.json(); })
        .then(function(res){
            if (res && res.success) { onSuccess(res); }
            else { alert((res && res.error) ? res.error : 'Request failed.'); }
        })
        .catch(function(){ alert('Network error — please try again.'); });
}

// Folder tree filter
(function(){
    var links = document.querySelectorAll('.doc-tree-link');
    links.forEach(function(link){
        link.addEventListener('click', function(){
            links.forEach(function(l){ l.classList.remove('active'); });
            link.classList.add('active');
            var folder = link.getAttribute('data-folder');
            document.querySelectorAll('.doc-folder-block').forEach(function(block){
                block.style.display = (folder === 'all' || block.getAttribute('data-folder') === folder) ? '' : 'none';
            });
        });
    });
})();

// Generate modal
(function(){
    var modal = document.getElementById('generateModal');
    var select = document.getElementById('templateSelect');
    var meta = document.getElementById('templateMeta');
    var fieldsWrap = document.getElementById('tokenFields');
    var status = document.getElementById('genStatus');

    Object.keys(DOC_TOKENS.templates).forEach(function(name){
        var opt = document.createElement('option');
        opt.value = name; opt.textContent = name;
        select.appendChild(opt);
    });

    function inputFor(type, token, value){
        if (type === 'num') return '<input type="number" step="0.01" data-token="' + token + '" value="' + (value || '') + '">';
        if (type === 'date') return '<input type="date" data-token="' + token + '" value="' + (value || '') + '">';
        if (type === 'obj') return '<input type="file" data-token="' + token + '">';
        if (type === 'array') return '<textarea rows="3" data-token="' + token + '" placeholder="One line item per row">' + (value || '') + '</textarea>';
        return '<input type="text" data-token="' + token + '" value="' + (value || '') + '">';
    }

    function renderTokens(){
        var name = select.value;
        var tokens = DOC_TOKENS.templates[name] || [];
        meta.textContent = tokens.length + ' tokens';
        var missing = 0;
        fieldsWrap.innerHTML = tokens.map(function(token){
            var m = DOC_TOKENS.meta[token] || { type: 'string', label: token, group: '' };
            var auto = Object.prototype.hasOwnProperty.call(DOC_TOKENS.auto, token);
            if (!auto) missing++;
            return '<div class="token-field">'
                + '<label for="t_' + token + '">' + m.label
                + '<code>{{' + token + '}} &middot; ' + m.type + (m.group ? ' &middot; ' + m.group : '') + '</code></label>'
                + inputFor(m.type, token, auto ? DOC_TOKENS.auto[token] : '')
                + (auto ? '<span class="pill pill-green token-src">auto</span>' : '<span class="pill pill-amber token-src">input</span>')
                + '</div>';
        }).join('');
        status.textContent = missing ? (missing + ' field(s) need live input') : 'All values resolved from case data';
    }

    select.addEventListener('change', renderTokens);

    function openModal(template){
        if (template && DOC_TOKENS.templates[template]) select.value = template;
        renderTokens();
        modal.classList.add('open');
    }
    var genBtn = document.getElementById('generateBtn');
    if (genBtn) genBtn.addEventListener('click', function(){ openModal(null); });
    document.querySelectorAll('[data-generate]').forEach(function(btn){
        btn.addEventListener('click', function(){ openModal(btn.getAttribute('data-template')); });
    });
    modal.querySelector('[data-close]').addEventListener('click', function(){ modal.classList.remove('open'); });
    modal.addEventListener('click', function(e){ if (e.target === modal) modal.classList.remove('open'); });
    document.addEventListener('keydown', function(e){ if (e.key === 'Escape') modal.classList.remove('open'); });

    document.getElementById('previewBtn').addEventListener('click', function(){
        var data = {};
        fieldsWrap.querySelectorAll('[data-token]').forEach(function(el){ data[el.getAttribute('data-token')] = el.value; });
        var w = window.open('', '_blank');
        w.document.write('<pre style="font:14px monospace;white-space:pre-wrap;">' + JSON.stringify(data, null, 2).replace(/</g,'&lt;') + '</pre>');
    });

    document.getElementById('generateNowBtn').addEventListener('click', function(){
        if (DOC_CASE_ID === 0) { docDemo(); return; }
        var data = {};
        fieldsWrap.querySelectorAll('[data-token]').forEach(function(el){ data[el.getAttribute('data-token')] = el.value; });
        var send = function(allowIncomplete){
            docPost({
                action: 'generate',
                case_id: DOC_CASE_ID,
                template: select.value,
                tokens: JSON.stringify(data),
                allow_incomplete: allowIncomplete ? '1' : ''
            }, function(res){
                modal.classList.remove('open');
                alert('Generated ' + res.file + ' and stored it in the case folder.');
                location.reload();
            });
        };
        var missingCount = fieldsWrap.querySelectorAll('[data-token]').length
            - Array.prototype.filter.call(fieldsWrap.querySelectorAll('[data-token]'), function(el){ return el.value !== ''; }).length;
        if (missingCount > 0 && !window.confirm(missingCount + ' token(s) are blank. Generate anyway?')) return;
        send(missingCount > 0);
    });

    // Deep link: ?case=N&generate=Contract opens the modal preselected.
    var genParam = new URLSearchParams(location.search).get('generate');
    if (genParam) openModal(genParam);
})();

// Upload modal
(function(){
    var modal = document.getElementById('uploadModal');
    if (!modal) return;
    var form = document.getElementById('uploadForm');
    var codeSelect = document.getElementById('uploadDocCode');
    function open(preselect){
        if (DOC_CASE_ID === 0) { docDemo(); return; }
        if (preselect && codeSelect) codeSelect.value = preselect;
        modal.classList.add('open');
    }
    var upBtn = document.getElementById('uploadBtn');
    if (upBtn) upBtn.addEventListener('click', function(){ open(null); });
    document.querySelectorAll('[data-upload]').forEach(function(btn){
        btn.addEventListener('click', function(){ open(null); });
    });
    modal.querySelector('[data-close]').addEventListener('click', function(){ modal.classList.remove('open'); });
    modal.addEventListener('click', function(e){ if (e.target === modal) modal.classList.remove('open'); });
    form.addEventListener('submit', function(e){
        e.preventDefault();
        var fd = new FormData(form);
        fd.set('action', 'upload');
        fd.set('case_id', DOC_CASE_ID);
        fetch(DOC_API, { method: 'POST', body: fd })
            .then(function(r){ return r.json(); })
            .then(function(res){
                if (res && res.success) { modal.classList.remove('open'); location.reload(); }
                else { alert((res && res.error) ? res.error : 'Upload failed.'); }
            })
            .catch(function(){ alert('Network error — please try again.'); });
    });

    // Deep link: ?case=N&upload=<folder> opens the upload dialog.
    if (new URLSearchParams(location.search).get('upload') !== null && new URLSearchParams(location.search).get('upload') !== '') open(null);
})();

// Document review modal — the reviewer looks at the document, then verifies,
// requests more info (soft deny), or rejects (hard deny) with a comment.
var DOCS_INDEX = <?= json_encode(array_column(array_filter($documents, fn($d) => (int)($d['id'] ?? 0) > 0), null, 'id'), JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) ?>;
(function(){
    var modal = document.getElementById('reviewModal');
    if (!modal) return;
    var viewer = document.getElementById('reviewViewer');
    var meta = document.getElementById('reviewMeta');
    var comment = document.getElementById('reviewComment');
    var status = document.getElementById('reviewStatus');
    var currentId = 0;

    function openReview(id){
        var doc = DOCS_INDEX[id];
        if (!doc) { docDemo(); return; }
        currentId = id;
        comment.value = '';
        status.textContent = '';
        meta.innerHTML = '<span><code>' + (doc.name || '') + '</code></span>'
            + (doc.origin_label ? '<span>' + doc.origin_label + '</span>' : '')
            + (doc.meta ? '<span>' + doc.meta + '</span>' : '');
        var url = DOC_API + '?action=download&document_id=' + id;
        var mime = doc.mime || '';
        if (mime.indexOf('image/') === 0) {
            viewer.innerHTML = '<img src="' + url + '" alt="Document preview">';
        } else if (mime === 'application/pdf' || mime === 'text/html' || mime === '') {
            viewer.innerHTML = '<iframe src="' + url + '" title="Document preview"></iframe>';
        } else {
            viewer.innerHTML = '<div class="review-viewer-fallback">No inline preview for this file type.<br><a class="btn btn-secondary btn-sm" style="margin-top:8px;" href="' + url + '" target="_blank" rel="noopener"><i class="fas fa-download"></i> Download to review</a></div>';
        }
        modal.classList.add('open');
    }

    document.querySelectorAll('[data-review]').forEach(function(btn){
        btn.addEventListener('click', function(){ openReview(btn.getAttribute('data-doc-id')); });
    });
    modal.querySelector('[data-close]').addEventListener('click', function(){ modal.classList.remove('open'); });
    modal.addEventListener('click', function(e){ if (e.target === modal) modal.classList.remove('open'); });
    document.addEventListener('keydown', function(e){ if (e.key === 'Escape') modal.classList.remove('open'); });

    function decide(decision){
        if (!currentId) return;
        var note = comment.value.trim();
        if (decision !== 'verified' && note === '') {
            status.textContent = 'A comment is required — it goes to the uploader.';
            comment.focus();
            return;
        }
        docPost({ action: 'review', document_id: currentId, decision: decision, comment: note }, function(){
            location.reload();
        });
    }
    document.getElementById('reviewVerify').addEventListener('click', function(){ decide('verified'); });
    document.getElementById('reviewNeedsInfo').addEventListener('click', function(){ decide('needs_info'); });
    document.getElementById('reviewReject').addEventListener('click', function(){ decide('rejected'); });

    // Deep link: case-documents.php?case=N&review=ID opens the modal directly.
    var params = new URLSearchParams(location.search);
    if (params.get('review')) openReview(params.get('review'));
})();
</script>
