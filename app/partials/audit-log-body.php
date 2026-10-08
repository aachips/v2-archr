<?php
declare(strict_types=1);

/**
 * Body partial for audit-log.php (the super-admin Audit Trail).
 * Reuses portal primitives (panel, data-table, pill, alert, btn); the small
 * page-specific styles are scoped below.
 *
 * Provided by audit-log.php before this file is required:
 * @var array $entries    Ledger rows from archr_activity_query()
 * @var array $verify     Chain check: ok, checked, first_bad_id, error
 * @var array $filters    Current GET filters (user_id, application_id, case_id,
 *                        category, action, source, since, until, search)
 * @var array $users      system_users rows for the user dropdown
 * @var array $categories Distinct categories present in the ledger
 * @var array $actions    Distinct actions present in the ledger
 * @var array $sources    Distinct sources present in the ledger
 * @var array $appLabels  application id => display label map
 */
?>
?>
<main class="page-wrap audit-log">
    <h1><?= __('audit.title') ?></h1>
    <p class="muted"><?= __('audit.subtitle') ?></p>

    <?php if ($verify['ok']): ?>
        <div class="alert info"><?= __('audit.chain_ok', ['count' => $verify['checked']]) ?></div>
    <?php else: ?>
        <div class="alert danger"><?= __('audit.chain_bad', ['id' => (string)$verify['first_bad_id'], 'error' => (string)$verify['error']]) ?></div>
    <?php endif; ?>

    <form class="panel audit-filters" method="get" action="audit-log.php">
        <div class="audit-filter-grid">
            <label><span><?= __('audit.user') ?></span>
                <select name="user_id">
                    <option value="">—</option>
                    <?php foreach ($users as $u): ?>
                        <option value="<?= (int)$u['id'] ?>" <?= (int)($filters['user_id'] ?? 0) === (int)$u['id'] ? 'selected' : '' ?>><?= e((string)$u['full_name']) ?></option>
                    <?php endforeach; ?>
                </select>
            </label>
            <label><span><?= __('audit.application') ?> ID</span>
                <input type="number" name="application_id" value="<?= e((string)($filters['application_id'] ?? '')) ?>">
            </label>
            <label><span><?= __('audit.case') ?> ID</span>
                <input type="number" name="case_id" value="<?= e((string)($filters['case_id'] ?? '')) ?>">
            </label>
            <?php foreach ([['category', $categories, 'audit.category'], ['action', $actions, 'audit.action'], ['source', $sources, 'audit.source']] as [$name, $options, $labelKey]): ?>
                <label><span><?= __($labelKey) ?></span>
                    <select name="<?= e($name) ?>">
                        <option value="">—</option>
                        <?php foreach ($options as $opt): ?>
                            <option value="<?= e((string)$opt) ?>" <?= ($filters[$name] ?? '') === $opt ? 'selected' : '' ?>><?= e((string)$opt) ?></option>
                        <?php endforeach; ?>
                    </select>
                </label>
            <?php endforeach; ?>
            <label><span><?= __('audit.since') ?></span>
                <input type="date" name="since" value="<?= e((string)$filters['since']) ?>">
            </label>
            <label><span><?= __('audit.until') ?></span>
                <input type="date" name="until" value="<?= e((string)$filters['until']) ?>">
            </label>
            <label><span><?= __('audit.search') ?></span>
                <input type="search" name="search" value="<?= e((string)$filters['search']) ?>">
            </label>
        </div>
        <div class="audit-filter-actions">
            <button type="submit" class="btn btn-primary"><?= __('audit.apply') ?></button>
            <a class="btn btn-secondary" href="audit-log.php"><?= __('audit.reset') ?></a>
            <span class="muted audit-selected" id="audit-selected"
                  data-label="<?= e(archr_translate('audit.selected', ['count' => '__N__'])) ?>"></span>
        </div>
    </form>

    <section class="panel">
        <div class="table-wrap">
            <table class="data-table audit-table">
                <thead>
                    <tr>
                        <th><input type="checkbox" id="audit-select-all" aria-label="Select all"></th>
                        <th><?= __('audit.col_when') ?></th>
                        <th><?= __('audit.col_who') ?></th>
                        <th><?= __('audit.col_what') ?></th>
                        <th><?= __('audit.col_household') ?></th>
                        <th><?= __('audit.col_source') ?></th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                <?php foreach ($entries as $row): ?>
                    <?php $aid = (int)($row['application_id'] ?? 0); ?>
                    <tr>
                        <td><input type="checkbox" class="audit-row-check" value="<?= (int)$row['id'] ?>"></td>
                        <td><?= e((string)$row['created_at']) ?></td>
                        <td><?= e($row['user_name'] !== null && $row['user_name'] !== '' ? (string)$row['user_name'] : archr_translate('audit.system_user')) ?></td>
                        <td>
                            <span class="pill"><?= e((string)$row['category']) ?></span>
                            <strong><?= e((string)$row['action']) ?></strong>
                            <?php if (!empty($row['summary'])): ?><br><?= e((string)$row['summary']) ?><?php endif; ?>
                        </td>
                        <td><?= $aid ? e((string)($appLabels[$aid] ?? ('#' . $aid))) : '—' ?></td>
                        <td class="muted"><?= e((string)$row['source']) ?></td>
                        <td>
                            <details class="audit-details">
                                <summary><?= __('audit.details_toggle') ?></summary>
                                <pre><?= e(json_encode(json_decode((string)$row['details'], true) ?: [], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES)) ?></pre>
                                <p class="muted">
                                    guid <?= e((string)$row['event_guid']) ?><br>
                                    session <?= e((string)($row['session_id'] ?? '—')) ?> ·
                                    ip <?= e((string)($row['ip_address'] ?? '—')) ?>
                                </p>
                            </details>
                        </td>
                    </tr>
                <?php endforeach; ?>
                <?php if (!$entries): ?>
                    <tr><td colspan="7" class="muted"><?= __('audit.no_results') ?></td></tr>
                <?php endif; ?>
                </tbody>
            </table>
        </div>
    </section>
</main>

<style>
/* Page-specific layout; primitives live in portal.css. Move to
   assets/audit-log.css if this page grows. */
.audit-filter-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(11rem, 1fr));
    gap: 0.75rem;
    margin-bottom: 0.75rem;
}
.audit-filter-grid label { display: flex; flex-direction: column; gap: 0.25rem; }
.audit-filter-grid label span { font-size: 0.8rem; font-weight: 600; color: var(--muted, #6b7280); }
.audit-filter-grid select,
.audit-filter-grid input { padding: 0.4rem 0.6rem; border: 1px solid #d1d5db; border-radius: 4px; font: inherit; }
.audit-filter-actions { display: flex; align-items: center; gap: 0.75rem; }
.audit-selected:empty { display: none; }
.audit-table td { vertical-align: top; }
.audit-details pre { max-width: 22rem; overflow: auto; font-size: 0.8rem; margin: 0.25rem 0; }
</style>

<script>
(function () {
    'use strict';
    var all = document.getElementById('audit-select-all');
    var boxes = document.querySelectorAll('.audit-row-check');
    var label = document.getElementById('audit-selected');
    function update() {
        var n = document.querySelectorAll('.audit-row-check:checked').length;
        label.textContent = n > 0 ? label.dataset.label.replace('__N__', n) : '';
    }
    if (all) {
        all.addEventListener('change', function () {
            boxes.forEach(function (b) { b.checked = all.checked; });
            update();
        });
    }
    boxes.forEach(function (b) { b.addEventListener('change', update); });
})();
</script>