<?php
declare(strict_types=1);

/* Searchable case list for office workers and admins. */

require __DIR__ . '/lib/auth.php';
archr_require_auth();

require __DIR__ . '/lib/db.php';
require __DIR__ . '/lib/case-access.php';
require __DIR__ . '/lib/case-review.php';
require __DIR__ . '/lib/case-phases.php';
require __DIR__ . '/lib/portal-layout.php';

$pdo = archr_pdo();
$access = archr_require_staff_access($pdo);

/* ---- Filter inputs ---- */
$search     = trim((string)($_GET['q'] ?? ''));
$statusId   = (int)($_GET['status'] ?? 0);
$orgId      = (int)($_GET['org'] ?? 0);
$city       = trim((string)($_GET['city'] ?? ''));
$zip        = trim((string)($_GET['zip'] ?? ''));
$dateFrom   = trim((string)($_GET['from'] ?? ''));
$dateTo     = trim((string)($_GET['to'] ?? ''));
$urgentOnly = !empty($_GET['urgent']);
$sort       = (string)($_GET['sort'] ?? 'newest');
$export     = (string)($_GET['export'] ?? '');

$statuses = $pdo->query("SELECT id, status_name, status_code FROM case_statuses ORDER BY status_sequence")->fetchAll();
$orgs = $pdo->query("SELECT id, organization_code, organization_name FROM coalition_organizations WHERE is_active = true ORDER BY organization_name")->fetchAll();
$cities = $pdo->query("SELECT DISTINCT home_city FROM intake_submissions WHERE home_city IS NOT NULL AND btrim(home_city) <> '' ORDER BY home_city")->fetchAll(PDO::FETCH_COLUMN);

$pendingStatus = $pdo->query("SELECT id, status_name FROM case_statuses WHERE status_code = 'PENDING_REVIEW' LIMIT 1")->fetch();
$pendingStatusId = (int)($pendingStatus['id'] ?? 0);
$pendingStatusName = (string)($pendingStatus['status_name'] ?? 'Pending Review');

/* True when the applicant flagged any urgent living-condition issue. */
$urgentExpr = "(COALESCE(s.urgent_unable_to_stay,false) OR COALESCE(s.urgent_no_hvac,false)
    OR COALESCE(s.urgent_no_potable_water,false) OR COALESCE(s.urgent_no_bathroom,false)
    OR COALESCE(s.urgent_no_kitchen,false) OR COALESCE(s.urgent_open_to_elements,false)
    OR COALESCE(s.urgent_no_entry,false) OR COALESCE(s.urgent_accessibility,false)
    OR COALESCE(s.urgent_other_issue,false) OR COALESCE(s.urgent_eviction_risk,false))";

$where = ['1=1'];
$params = [':pending_status_name' => $pendingStatusName];
if ($statusId > 0) {
    // $pendingStatusId is an int — inline it to avoid reusing a named
    // placeholder across SELECT + WHERE (unsupported in prepared statements).
    $where[] = 'COALESCE(c.status_id, ' . $pendingStatusId . ') = :status';
    $params[':status'] = $statusId;
}
if ($orgId > 0) {
    // Per-org cases: a claim can live on the case row (new model) or on the
    // anchor (legacy assignment).
    $where[] = '(c.organization_id = :org OR a.assigned_organization_id = :org2)';
    $params[':org'] = $orgId;
    $params[':org2'] = $orgId;
} elseif ($orgId === -1) {
    $where[] = 'c.organization_id IS NULL AND a.assigned_organization_id IS NULL';
}
if ($search !== '') {
    // One named placeholder per occurrence (pdo_pgsql does not support
    // reusing a name). Matches case #, project code, placecode, human-readable
    // display name, address, and applicant name (full name or either part).
    $where[] = "(COALESCE(c.case_number, a.case_number, '') ILIKE :q1
        OR COALESCE(a.project_code, '') ILIKE :q2
        OR COALESCE(a.placecode, '') ILIKE :q3
        OR COALESCE(s.home_address, '') ILIKE :q4
        OR COALESCE(s.applicant_first_name || ' ' || s.applicant_last_name, '') ILIKE :q5
        OR s.applicant_first_name ILIKE :q6
        OR s.applicant_last_name ILIKE :q7
        OR COALESCE(ap.display_name, '') ILIKE :q8)";
    $like = '%' . $search . '%';
    foreach ([':q1', ':q2', ':q3', ':q4', ':q5', ':q6', ':q7', ':q8'] as $k) {
        $params[$k] = $like;
    }
}
if ($city !== '') {
    $where[] = 's.home_city = :city';
    $params[':city'] = $city;
}
if ($zip !== '') {
    // Prefix match so a partial ZIP still narrows the list.
    $where[] = "COALESCE(s.home_zip, '') ILIKE :zip";
    $params[':zip'] = $zip . '%';
}
if (preg_match('/^\d{4}-\d{2}-\d{2}$/', $dateFrom)) {
    $where[] = 's.submitted_at >= :date_from';
    $params[':date_from'] = $dateFrom . ' 00:00:00';
}
if (preg_match('/^\d{4}-\d{2}-\d{2}$/', $dateTo)) {
    $where[] = 's.submitted_at <= :date_to';
    $params[':date_to'] = $dateTo . ' 23:59:59';
}
if ($urgentOnly) {
    $where[] = $urgentExpr;
}

$orderBy = match ($sort) {
    'oldest'   => 's.submitted_at ASC',
    'updated'  => 'COALESCE(c.updated_at, s.submitted_at) DESC',
    'priority' => 'q.priority_score DESC NULLS LAST, s.submitted_at DESC',
    'name'     => "COALESCE(s.applicant_last_name, '') ASC, COALESCE(s.applicant_first_name, '') ASC",
    default    => 's.submitted_at DESC',
};

$sql = "
    SELECT s.id AS submission_id,
           c.id AS case_id,
           COALESCE(c.case_number, a.case_number) AS case_number,
           a.project_code,
           a.placecode,
           s.applicant_first_name,
           s.applicant_last_name,
           s.home_address,
           s.home_city,
           s.home_zip,
           s.home_phone,
           s.cell_phone,
           s.contact_email,
           s.submitted_at,
           s.submission_status,
           $urgentExpr AS is_urgent,
           q.status AS queue_status,
           q.priority_score,
           COALESCE(c.status_id, $pendingStatusId) AS status_id,
           cs.status_code,
           cs.status_sequence,
           COALESCE(cs.status_name, :pending_status_name) AS status_name,
           c.updated_at AS case_updated_at,
           c.total_budget,
           c.total_actual_cost,
           c.intake_completed_at,
           c.assessment_scheduled_at,
           c.assessment_completed_at,
           c.approved_at,
           c.work_started_at,
           c.work_completed_at,
           c.application_id,
           c.claim_status,
           c.claim_expires_at,
           ap.display_name,
           ap.status AS application_status,
           COALESCE(c.organization_id, a.assigned_organization_id) AS org_id,
           o.organization_name,
           o.organization_code
      FROM intake_submissions s
      LEFT JOIN application_anchor a ON a.submission_id = s.id
      LEFT JOIN cases c ON c.submission_id = s.id
      LEFT JOIN applications ap ON ap.id = c.application_id
      LEFT JOIN review_queue q ON q.submission_id = s.id
      LEFT JOIN coalition_organizations o ON o.id = COALESCE(c.organization_id, a.assigned_organization_id)
      LEFT JOIN case_statuses cs ON cs.id = c.status_id
     WHERE " . implode(' AND ', $where) . "
     ORDER BY $orderBy
     LIMIT 200
";
$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$cases = $stmt->fetchAll();

/* ---- Per-row phase + role-based visibility ----
   Level 1 (office worker): contact info redacted, funding summarized.
   Level 2 (org admin): full data for own org's cases and unclaimed cases;
                        contact info redacted for cases claimed by other orgs.
   Level 3 (super admin): full data. */
$level = (int)$access['level'];
$userOrgs = array_map('intval', (array)$access['orgs']);
$phases = archr_case_phases();

foreach ($cases as &$row) {
    $row['phase'] = archr_case_phase($row);
    $ownOrg = $row['org_id'] !== null && in_array((int)$row['org_id'], $userOrgs, true);
    $row['contact_visible'] = $level >= 3 || ($level >= 2 && ($ownOrg || $row['org_id'] === null));
    $row['funding_visible'] = $level >= 2;
    if (!$row['contact_visible']) {
        $row['home_phone'] = $row['cell_phone'] = $row['contact_email'] = null;
    }
}
unset($row);

/* ---- Export (CSV / Excel) of the filtered, redacted result set ---- */
if ($export === 'csv' || $export === 'xlsx') {
    // Level 1 sees summarized funding; levels 2-3 see exact amounts.
    $fundingOut = static function ($value, bool $visible) {
        if (!$visible) {
            if ($value === null) return '—';
            $v = (float)$value;
            return $v < 10000 ? 'Under $10k' : ($v <= 50000 ? '$10k–$50k' : 'Over $50k');
        }
        return $value === null ? '' : number_format((float)$value, 2, '.', '');
    };

    $headers = ['Case Number', 'First Name', 'Last Name', 'Address', 'City', 'ZIP',
                'Phone', 'Email', 'Organization', 'Status', 'Phase', 'Urgent Action Needed',
                'Submitted', 'Last Updated', 'Funding Approved', 'Funding Spent', 'Funding Remaining'];
    $rows = [];
    foreach ($cases as $r) {
        $approved = $r['total_budget'];
        $spent = $r['total_actual_cost'];
        $remaining = ($approved !== null || $spent !== null)
            ? (float)$approved - (float)$spent : null;
        $rows[] = [
            $r['case_number'] ?: 'Application #' . (int)$r['submission_id'],
            (string)$r['applicant_first_name'],
            (string)$r['applicant_last_name'],
            (string)($r['home_address'] ?? ''),
            (string)($r['home_city'] ?? ''),
            (string)($r['home_zip'] ?? ''),
            $r['contact_visible'] ? (string)($r['home_phone'] ?? $r['cell_phone'] ?? '') : 'RESTRICTED',
            $r['contact_visible'] ? (string)($r['contact_email'] ?? '') : 'RESTRICTED',
            (string)($r['organization_name'] ?? 'Unclaimed'),
            (string)($r['status_name'] ?? ''),
            'Phase ' . $r['phase']['number'] . ' - ' . $phases[$r['phase']['number']]['name']
                . ($r['phase']['exit_label'] !== null ? ' (' . $r['phase']['exit_label'] . ')' : ''),
            !empty($r['is_urgent']) ? 'Yes' : 'No',
            $r['submitted_at'] ? date('Y-m-d', strtotime((string)$r['submitted_at'])) : '',
            $r['case_updated_at'] ? date('Y-m-d', strtotime((string)$r['case_updated_at'])) : '',
            $fundingOut($approved, $r['funding_visible']),
            $fundingOut($spent, $r['funding_visible']),
            $fundingOut($remaining, $r['funding_visible']),
        ];
    }

    $filename = 'cases_export_' . date('Y-m-d') . '.' . $export;
    if ($export === 'csv') {
        header('Content-Type: text/csv; charset=UTF-8');
        header('Content-Disposition: attachment; filename="' . $filename . '"');
        header('Cache-Control: no-store');
        $out = fopen('php://output', 'w');
        fwrite($out, "\xEF\xBB\xBF"); // BOM so Excel reads UTF-8 correctly
        fputcsv($out, $headers);
        foreach ($rows as $line) {
            fputcsv($out, $line);
        }
        fclose($out);
    } else {
        require __DIR__ . '/lib/xlsx-writer.php';
        archr_xlsx_download($filename, $headers, $rows);
    }
    exit;
}

/* Query string of the current filters, reused by the export buttons and
   by the "back to results" link carried into the case review page. */
$filterQuery = http_build_query(array_filter([
    'q' => $search !== '' ? $search : null,
    'status' => $statusId > 0 ? $statusId : null,
    'org' => $orgId !== 0 ? $orgId : null,
    'city' => $city !== '' ? $city : null,
    'zip' => $zip !== '' ? $zip : null,
    'from' => $dateFrom !== '' ? $dateFrom : null,
    'to' => $dateTo !== '' ? $dateTo : null,
    'urgent' => $urgentOnly ? '1' : null,
    'sort' => $sort !== 'newest' ? $sort : null,
], static fn($v) => $v !== null));
$hasFilters = $filterQuery !== '';
$returnTo = 'case-search.php' . ($hasFilters ? '?' . $filterQuery : '');

$roleSlug = strtolower(str_replace('_', '-', (string)($access['role_code'] ?? 'staff')));
$roleLabel = match ((int)$access['level']) {
    3 => 'Super Admin',
    2 => 'Org Admin',
    default => 'Staff',
};

archr_render_portal_header([
    'role' => $roleSlug,
    'role_label' => $roleLabel,
    'brand' => 'ARCHR',
    'page_title' => 'Case Search',
    'user_name' => $_SESSION['archr_user_name'] ?? '',
    'badge_icon' => 'fa-magnifying-glass',
    'nav' => archr_case_nav('case-search'),
]);

require __DIR__ . '/partials/case-search-body.php';

archr_render_portal_footer();
