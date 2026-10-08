<?php
declare(strict_types=1);

/* Staff review queue. Reads from admin_review_queue (a materialized
   view defined in sql/staff-dashboard-queue.sql) so urgency counts,
   FIFO order, and match scores are computed centrally. */

require __DIR__ . '/lib/db.php';
require __DIR__ . '/lib/layout.php';

$pdo = archr_pdo();

$statusFilter = isset($_GET['status']) ? trim((string)$_GET['status']) : '';
$includeTest  = isset($_GET['test']);

$where = [];
$params = [];
if ($statusFilter !== '') {
    $where[] = 'q.status = :status';
    $params[':status'] = $statusFilter;
}
if (!$includeTest) {
    // The admin_review_queue view doesn't expose is_test directly;
    // exclude test rows by joining back to intake_submissions.
    $where[] = 's.is_test = FALSE';
}
$whereSql = $where ? ('WHERE ' . implode(' AND ', $where)) : '';

$rows = $pdo->prepare("
    SELECT q.*, s.is_test
      FROM admin_review_queue q
      JOIN intake_submissions s ON s.id = q.submission_id
      $whereSql
     ORDER BY q.fifo_order");
$rows->execute($params);
$queue = $rows->fetchAll();

$totals = $pdo->query("
    SELECT COUNT(*) FILTER (WHERE status = 'PENDING_REVIEW') AS pending,
           COUNT(*) FILTER (WHERE status = 'IN_REVIEW')      AS in_review,
           COUNT(*) FILTER (WHERE urgent_count > 0)          AS urgent,
           COUNT(*)                                          AS total
      FROM admin_review_queue")->fetch();

archr_render_header('Admin review queue', 'admin');
?>
<main class="page-wrap">
    <section class="panel">
        <header class="panel-header">
            <div>
                <h1>Review queue</h1>
                <p>Incoming applications in FIFO order, weighted by urgency.
                   Click any row to open the case detail.</p>
            </div>
            <span class="role-badge admin">Org admin</span>
        </header>

        <div class="kpi-grid">
            <div class="kpi"><span class="label">Pending review</span>
                <span class="value"><?= e((string)($totals['pending'] ?? 0)) ?></span></div>
            <div class="kpi"><span class="label">In review</span>
                <span class="value"><?= e((string)($totals['in_review'] ?? 0)) ?></span></div>
            <div class="kpi"><span class="label">With urgent conditions</span>
                <span class="value"><?= e((string)($totals['urgent'] ?? 0)) ?></span></div>
            <div class="kpi"><span class="label">Queue total</span>
                <span class="value"><?= e((string)($totals['total'] ?? 0)) ?></span></div>
        </div>
    </section>

    <section class="panel">
        <div class="panel-header">
            <h2>Submissions</h2>
            <form method="get" style="display:flex; gap: var(--space-3); align-items:center;">
                <label>
                    Status
                    <select name="status" onchange="this.form.submit()">
                        <option value="">All</option>
                        <?php foreach (['PENDING_REVIEW', 'IN_REVIEW', 'COMPLETED'] as $s): ?>
                            <option value="<?= e($s) ?>" <?= $statusFilter === $s ? 'selected' : '' ?>>
                                <?= e($s) ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </label>
                <label>
                    <input type="checkbox" name="test" value="1" <?= $includeTest ? 'checked' : '' ?>
                           onchange="this.form.submit()">
                    Include test
                </label>
            </form>
        </div>

        <?php if (!$queue): ?>
            <p class="empty-state">No submissions match the current filters.</p>
        <?php else: ?>
            <div style="overflow-x:auto;">
                <table class="data-table">
                    <thead><tr>
                        <th>#</th><th>Applicant</th><th>Address</th>
                        <th>Submitted</th><th>Primary issue</th>
                        <th>Urgency</th><th>Status</th><th>Best match</th><th></th>
                    </tr></thead>
                    <tbody>
                    <?php foreach ($queue as $row): ?>
                        <?php $caseLink = 'case.php?id=' . (int)$row['submission_id']; ?>
                        <tr>
                            <td><?= e((string)$row['fifo_order']) ?></td>
                            <td>
                                <strong><?= e($row['applicant_first_name'] . ' ' . $row['applicant_last_name']) ?></strong>
                                <?php if ($row['is_test']): ?>
                                    <span class="pill amber" style="margin-left:6px;">TEST</span>
                                <?php endif; ?>
                            </td>
                            <td><?= e($row['home_address'] ?? '') ?></td>
                            <td>
                                <?= e((new DateTimeImmutable($row['submitted_at']))->format('M j, Y')) ?><br>
                                <small><?= e(number_format((float)$row['hours_in_queue'], 1)) ?> h in queue</small>
                            </td>
                            <td><?= e($row['primary_issue'] ?? '—') ?></td>
                            <td>
                                <?php if ((int)$row['urgent_count'] > 0): ?>
                                    <span class="pill red"><?= e((string)$row['urgent_count']) ?> urgent</span>
                                <?php else: ?>
                                    <span class="pill">none</span>
                                <?php endif; ?>
                                <?php if ($row['helene_related']): ?>
                                    <span class="pill blue">Helene</span>
                                <?php endif; ?>
                            </td>
                            <td>
                                <span class="pill <?= $row['status'] === 'IN_REVIEW' ? 'purple' : ($row['status'] === 'COMPLETED' ? 'green' : 'amber') ?>">
                                    <?= e($row['status']) ?>
                                </span>
                            </td>
                            <td>
                                <?php if ($row['best_match_org']): ?>
                                    <strong><?= e($row['best_match_org']) ?></strong><br>
                                    <small>Score <?= e((string)$row['best_match_score']) ?></small>
                                <?php else: ?>
                                    <small>—</small>
                                <?php endif; ?>
                            </td>
                            <td><a class="btn small secondary" href="<?= e($caseLink) ?>">Open</a></td>
                        </tr>
                    <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        <?php endif; ?>
    </section>
</main>
<?php archr_render_footer(); ?>
