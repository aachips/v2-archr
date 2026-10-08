<?php
/** Body partial for case-search.php. Every variable it uses ($search,
 *  $statusId, $orgId, $city, $zip, $dateFrom, $dateTo, $urgentOnly, $sort,
 *  $statuses, $orgs, $cities, $cases with per-row 'phase' /
 *  'contact_visible' / 'funding_visible', $level, $phases, $filterQuery,
 *  $hasFilters, $returnTo) is provided by case-search.php, which requires
 *  this file. UI text is translated via __() from
 *  lib/language-translations.php (loaded by lib/portal-layout.php). */
?>
<main class="page-wrap case-search">
    <header class="panel case-search-header">
        <h1><?= __('case_search.title') ?></h1>
        <p><?= __('case_search.intro') ?></p>
    </header>

    <section class="panel" aria-label="<?= __('case_search.filters_aria') ?>">
        <form class="case-search-form" method="get" action="case-search.php">
            <div class="field field-wide">
                <label for="q"><?= __('common.search') ?></label>
                <input type="search" id="q" name="q" value="<?= e($search) ?>" placeholder="<?= __('case_search.search_placeholder') ?>">
            </div>
            <div class="field">
                <label for="status"><?= __('case_search.status') ?></label>
                <select id="status" name="status">
                    <option value=""><?= __('case_search.all_statuses') ?></option>
                    <?php foreach ($statuses as $s): ?>
                        <option value="<?= (int)$s['id'] ?>" <?= $statusId === (int)$s['id'] ? 'selected' : '' ?>><?= e($s['status_name']) ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="field">
                <label for="org"><?= __('case_search.claimed_org') ?></label>
                <select id="org" name="org">
                    <option value=""><?= __('case_search.all_orgs') ?></option>
                    <option value="-1" <?= $orgId === -1 ? 'selected' : '' ?>><?= __('case_search.unclaimed') ?></option>
                    <?php foreach ($orgs as $o): ?>
                        <option value="<?= (int)$o['id'] ?>" <?= $orgId === (int)$o['id'] ? 'selected' : '' ?>><?= e($o['organization_name']) ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="field">
                <label for="city"><?= __('case_search.city') ?></label>
                <select id="city" name="city">
                    <option value=""><?= __('case_search.all_cities') ?></option>
                    <?php foreach ($cities as $cname): ?>
                        <option value="<?= e($cname) ?>" <?= $city === $cname ? 'selected' : '' ?>><?= e($cname) ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="field">
                <label for="zip"><?= __('case_search.zip') ?></label>
                <input type="text" id="zip" name="zip" value="<?= e($zip) ?>" inputmode="numeric" pattern="[0-9]*" maxlength="10" placeholder="<?= __('case_search.zip_placeholder') ?>">
            </div>
            <div class="field">
                <label for="from"><?= __('case_search.date_from') ?></label>
                <input type="date" id="from" name="from" value="<?= e($dateFrom) ?>">
            </div>
            <div class="field">
                <label for="to"><?= __('case_search.date_to') ?></label>
                <input type="date" id="to" name="to" value="<?= e($dateTo) ?>">
            </div>
            <div class="field">
                <label for="sort"><?= __('case_search.sort') ?></label>
                <select id="sort" name="sort">
                    <option value="newest" <?= $sort === 'newest' ? 'selected' : '' ?>><?= __('case_search.sort_newest') ?></option>
                    <option value="updated" <?= $sort === 'updated' ? 'selected' : '' ?>><?= __('case_search.sort_updated') ?></option>
                    <option value="priority" <?= $sort === 'priority' ? 'selected' : '' ?>><?= __('case_search.sort_priority') ?></option>
                    <option value="oldest" <?= $sort === 'oldest' ? 'selected' : '' ?>><?= __('case_search.sort_oldest') ?></option>
                    <option value="name" <?= $sort === 'name' ? 'selected' : '' ?>><?= __('case_search.sort_name') ?></option>
                </select>
            </div>
            <div class="field field-check">
                <label class="check-label" for="urgent">
                    <input type="checkbox" id="urgent" name="urgent" value="1" <?= $urgentOnly ? 'checked' : '' ?>>
                    <?= __('case_search.urgent_only') ?>
                </label>
            </div>
            <div class="form-actions">
                <button type="submit" class="btn btn-primary"><i class="fas fa-magnifying-glass" aria-hidden="true"></i> <?= __('common.search') ?></button>
                <?php if ($hasFilters): ?>
                    <a href="case-search.php" class="btn btn-secondary"><?= __('case_search.clear') ?></a>
                <?php endif; ?>
            </div>
        </form>
    </section>

    <section class="panel" aria-label="<?= __('case_search.results_aria') ?>">
        <div class="results-bar">
            <p class="results-count"><?= __('case_search.results_found', ['count' => count($cases)]) ?><?= count($cases) >= 200 ? ' ' . __('case_search.results_limit') : '' ?></p>
            <?php if ($cases): ?>
                <div class="export-actions">
                    <a class="btn btn-sm btn-secondary" href="case-search.php?<?= e($filterQuery . ($hasFilters ? '&' : '')) ?>export=csv" download>
                        <i class="fas fa-file-csv" aria-hidden="true"></i> <?= __('case_search.export_csv') ?>
                    </a>
                    <a class="btn btn-sm btn-secondary" href="case-search.php?<?= e($filterQuery . ($hasFilters ? '&' : '')) ?>export=xlsx" download>
                        <i class="fas fa-file-excel" aria-hidden="true"></i> <?= __('case_search.export_excel') ?>
                    </a>
                </div>
            <?php endif; ?>
        </div>
        <?php if ($level < 3): ?>
            <p class="muted visibility-note">
                <i class="fas fa-eye-low-vision" aria-hidden="true"></i>
                <?= $level === 1
                    ? __('case_search.restricted_note_staff')
                    : __('case_search.restricted_note_org_admin') ?>
            </p>
        <?php endif; ?>
        <?php if ($cases): ?>
            <div class="table-wrap">
                <table class="case-list-table case-list-table-linked">
                    <thead>
                        <tr>
                            <th><?= __('case_search.col_case_number') ?></th>
                            <th><?= __('case_search.col_job_code') ?></th>
                            <th><?= __('case_search.col_homeowner') ?></th>
                            <th><?= __('case_search.col_address') ?></th>
                            <th><?= __('case_search.col_township') ?></th>
                            <th><?= __('case_search.col_zip') ?></th>
                            <th><?= __('case_search.col_phone') ?></th>
                            <th><?= __('case_search.col_claimed_org') ?></th>
                            <th><?= __('case_search.col_status') ?></th>
                            <th><?= __('case_search.col_phase') ?></th>
                            <th><?= __('case_search.col_submitted') ?></th>
                            <th><?= __('case_search.col_updated') ?></th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($cases as $c): ?>
                            <?php
                            $org = $c['org_id'] ? ['id' => $c['org_id'], 'organization_code' => $c['organization_code'], 'organization_name' => $c['organization_name']] : null;
                            $isUrgent = !empty($c['is_urgent']);
                            $phaseLabel = 'Phase ' . $c['phase']['number'] . ' · ' . $phases[$c['phase']['number']]['name'];
                            $phone = $c['home_phone'] ?: $c['cell_phone'];
                            $caseUrl = 'case.php?submission_id=' . (int)$c['submission_id'] . '&return=' . urlencode($returnTo);
                            ?>
                                <tr<?= $isUrgent ? ' class="row-urgent"' : '' ?>>
                                    <td>
                                        <a href="<?= e($caseUrl) ?>">
                                            <?= e($c['case_number'] ?: archr_translate('case_search.application_fallback', ['id' => (int)$c['submission_id']])) ?>
                                            <?php if ($isUrgent): ?>
                                                <i class="fas fa-triangle-exclamation urgent-flag" title="<?= e(archr_translate('case_search.urgent_flag_title')) ?>" aria-label="<?= e(archr_translate('case_search.urgent_only')) ?>"></i>
                                            <?php endif; ?>
                                        </a>
                                    </td>
                                    <td><a href="<?= e($caseUrl) ?>"><?= e(archr_job_code($org, $c['project_code'])) ?></a></td>
                                    <td><a href="<?= e($caseUrl) ?>"><?= e($c['applicant_first_name'] . ' ' . $c['applicant_last_name']) ?></a></td>
                                    <td><a href="<?= e($caseUrl) ?>"><?= e($c['home_address'] ?: '—') ?></a></td>
                                    <td><a href="<?= e($caseUrl) ?>"><?= e($c['home_city'] ?: '—') ?></a></td>
                                    <td><a href="<?= e($caseUrl) ?>"><?= e($c['home_zip'] ?: '—') ?></a></td>
                                    <td><a href="<?= e($caseUrl) ?>">
                                        <?php if ($c['contact_visible']): ?>
                                            <?= e($phone ?: '—') ?>
                                        <?php else: ?>
                                            <span class="muted"><?= __('case_search.restricted') ?></span>
                                        <?php endif; ?>
                                    </a></td>
                                    <td><a href="<?= e($caseUrl) ?>"><?= e($c['organization_name'] ?? archr_translate('case_search.unclaimed')) ?></a></td>
                                    <td><a href="<?= e($caseUrl) ?>"><span class="pill"><?= e($c['status_name'] ?? '—') ?></span></a></td>
                                    <td><a href="<?= e($caseUrl) ?>">
                                        <span class="pill pill-blue phase-pill" title="<?= e(($phases[$c['phase']['number']] ?? [])['full_name'] ?? '') ?><?= $c['phase']['exit_label'] !== null ? ' — ' . e($c['phase']['exit_label']) : '' ?>">
                                            <?= e($phaseLabel) ?>
                                        </span>
                                        <?php if ($c['phase']['exit_label'] !== null): ?>
                                            <span class="pill pill-amber"><?= e($c['phase']['exit_label']) ?></span>
                                        <?php endif; ?>
                                    </a></td>
                                    <td><a href="<?= e($caseUrl) ?>"><?= $c['submitted_at'] ? e(date('M j, Y', strtotime((string)$c['submitted_at']))) : '—' ?></a></td>
                                    <td><a href="<?= e($caseUrl) ?>"><?= $c['case_updated_at'] ? e(date('M j, Y', strtotime((string)$c['case_updated_at']))) : '—' ?></a></td>
                                </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        <?php else: ?>
            <p class="muted"><?= __('case_search.no_results') ?></p>
        <?php endif; ?>
    </section>
</main>
