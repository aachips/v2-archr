<?php
declare(strict_types=1);

/* -----------------------------------------------------------------
 * Case Documents data layer.
 *
 * Reads the document-storage schema (sql/document-storage.sql):
 *   case_documents, document_categories, document_statuses,
 *   document_templates, document_generation_jobs, document_access_log
 *   + views case_document_inventory, pending_verification_documents.
 *
 * Every public function degrades gracefully when the tables are not
 * deployed yet so pages keep working in prototype (sample) mode.
 * ----------------------------------------------------------------- */

// For archr_load_secure_config() (Dropbox credentials). Idempotent.
require_once __DIR__ . '/../config/database.php';

/** Folder taxonomy shared by the page, the API, and the component spec. */
function archr_doc_folders(): array {
    return [
        'application'    => ['label' => 'Application',          'icon' => 'fa-file-signature',      'path' => 'application/'],
        'property'       => ['label' => 'Property',             'icon' => 'fa-house-chimney',       'path' => 'property/'],
        'income'         => ['label' => 'Income Verification',  'icon' => 'fa-hand-holding-dollar', 'path' => 'income/'],
        'assessments'    => ['label' => 'Assessments',          'icon' => 'fa-clipboard-check',     'path' => 'assessments/'],
        'contracts'      => ['label' => 'Contracts',            'icon' => 'fa-file-contract',       'path' => 'contracts/'],
        'work_orders'    => ['label' => 'Work Orders',          'icon' => 'fa-helmet-safety',       'path' => 'work_orders/'],
        'financial'      => ['label' => 'Financial & Grants',   'icon' => 'fa-coins',               'path' => 'financial/'],
        'completion'     => ['label' => 'Completion',           'icon' => 'fa-award',               'path' => 'completion/'],
        'communications' => ['label' => 'Communications',       'icon' => 'fa-comments',            'path' => 'communications/'],
    ];
}

/** document_categories.category_code -> folder key. */
function archr_doc_category_folder(): array {
    return [
        'APPLICATION' => 'application',
        'PROPERTY' => 'property',
        'INCOME' => 'income',
        'ASSESSMENT' => 'assessments', 'ASSESSMENT_PHOTOS_BEFORE' => 'assessments',
        'CONTRACT' => 'contracts', 'CHANGE_ORDER' => 'contracts',
        'WORK_ORDER' => 'work_orders', 'ASSESSMENT_PHOTOS_DURING' => 'work_orders',
        'QUOTE' => 'financial', 'INVOICE' => 'financial', 'GRANT' => 'financial',
        'ENV_REVIEW' => 'financial', 'SHPO' => 'financial',
        'COMPLETION' => 'completion', 'ASSESSMENT_PHOTOS_AFTER' => 'completion',
        'COMMUNICATION' => 'communications',
    ];
}

/** Required-document checklist per folder. 'gen' links a token template
 *  from document-tokens.json; everything else is expected via upload. */
function archr_doc_required_checklist(): array {
    return [
        'application' => [
            ['code' => 'APP',     'label' => 'Application PDF',  'icon' => 'fa-file-pdf'],
            ['code' => 'CONSENT', 'label' => 'Consent Form',     'icon' => 'fa-file-signature'],
        ],
        'property' => [
            ['code' => 'PROP',    'label' => 'Property Card',    'icon' => 'fa-house-chimney'],
            ['code' => 'DEED',    'label' => 'Deed / Title',     'icon' => 'fa-file-circle-plus'],
            ['code' => 'TAX',     'label' => 'Tax Record',       'icon' => 'fa-file-circle-plus'],
        ],
        'income' => [
            ['code' => 'INC_PAYSTUB', 'label' => 'Pay Stub',     'icon' => 'fa-file-invoice-dollar'],
            ['code' => 'INC_W2',      'label' => 'W-2',          'icon' => 'fa-file-circle-plus'],
            ['code' => 'INC_SS',      'label' => 'Social Security / Benefits letter', 'icon' => 'fa-file-circle-plus'],
        ],
        'assessments' => [
            ['code' => 'ASSESS',  'label' => 'Assessment Report', 'icon' => 'fa-clipboard-check'],
            ['code' => 'PH_B',    'label' => 'Before Photos',     'icon' => 'fa-camera'],
        ],
        'contracts' => [
            ['code' => 'CONT',    'label' => 'Repair Contract',  'icon' => 'fa-file-contract', 'gen' => 'Contract'],
            ['code' => 'CO',      'label' => 'Change Order(s)',  'icon' => 'fa-file-circle-plus', 'optional' => true],
        ],
        'work_orders' => [
            ['code' => 'WO',      'label' => 'Work Order',       'icon' => 'fa-helmet-safety', 'optional' => true],
        ],
        'financial' => [
            ['code' => 'QUOTE',       'label' => 'Subcontractor Quote',   'icon' => 'fa-file-circle-plus', 'optional' => true],
            ['code' => 'CDBG_CENST',  'label' => 'CDBG-CENST Form',       'icon' => 'fa-file-circle-plus', 'gen' => 'CDBG-CENST'],
            ['code' => 'CDBG_ERR',    'label' => 'CDBG-ERR Form (Environmental Review)', 'icon' => 'fa-file-circle-plus', 'gen' => 'CDBG-ERR'],
            ['code' => 'CDBG_SHPO',   'label' => 'CDBG-SHPO (Historic Preservation)',    'icon' => 'fa-file-circle-plus', 'gen' => 'CDBG-SHPO'],
        ],
        'completion' => [
            ['code' => 'CERT',    'label' => 'Certificate of Completion', 'icon' => 'fa-award', 'optional' => true],
        ],
        'communications' => [
            ['code' => 'COMM',    'label' => 'Communication Log', 'icon' => 'fa-comments', 'optional' => true],
        ],
    ];
}

/** Status -> [pill class, icon, label] (shared by admin + requestor pages). */
function archr_doc_status(array $doc): array {
    return match ($doc['status']) {
        'verified'  => ['pill-green',  'fa-circle-check',       'Verified'],
        'pending'   => ['pill-amber',  'fa-hourglass-half',     'Pending verification'],
        'missing'   => ['pill-red',    'fa-circle-exclamation', 'Missing'],
        'rejected'  => ['pill-red',    'fa-xmark',              'Rejected'],
        'generated' => ['pill-accent', 'fa-wand-magic-sparkles','Generated'],
        default     => ['',            'fa-file',               ucfirst($doc['status'])],
    };
}

/** Render the action buttons valid for a document's status.
 *  Live rows carry $doc['id'] and act via api/documents.php; sample-mode
 *  rows (no id) trigger the prototype notice instead. */
function archr_doc_actions(array $doc): string {
    $id = (int)($doc['id'] ?? 0);
    $view = $id > 0
        ? '<a href="api/documents.php?action=download&document_id=' . $id . '" target="_blank" rel="noopener" class="btn btn-secondary btn-sm"><i class="fas fa-eye"></i> View</a>'
        : '<button type="button" class="btn btn-secondary btn-sm" data-demo><i class="fas fa-eye"></i> View</button>';
    $btn = fn(string $cls, string $icon, string $label, string $extra = '') =>
        '<button type="button" class="btn ' . $cls . ' btn-sm" ' . $extra . '><i class="fas ' . $icon . '"></i> ' . e($label) . '</button>';
    $actions = $doc['actions'] ?? [];
    if (!empty($doc['generate_template'])) {
        return $btn('btn-primary', 'fa-wand-magic-sparkles', 'Generate ' . ($doc['label'] ?? ''), 'data-template="' . e($doc['generate_template']) . '" data-generate');
    }
    if ($doc['status'] === 'missing') {
        $out = '';
        if (in_array('request', $actions, true)) $out .= $btn('btn-secondary', 'fa-paper-plane', 'Request Upload', 'data-request');
        if (in_array('upload', $actions, true))  $out .= $btn('btn-secondary', 'fa-upload', 'Upload', 'data-upload data-doc-code="' . e($doc['expected'] ?? ($doc['label'] ?? '')) . '"');
        if (in_array('new_change_order', $actions, true)) $out .= $btn('btn-secondary', 'fa-plus', 'New Change Order', 'data-demo');
        return $out;
    }
    // Pending/generated docs get ONE action: Review opens the review modal,
    // where the reviewer sees the document itself before deciding.
    if ($doc['status'] === 'pending' || $doc['status'] === 'generated') {
        return $btn('btn-accent', 'fa-eye', 'Review', $id > 0 ? 'data-review data-doc-id="' . $id . '"' : 'data-demo');
    }
    $out = $view;
    if (in_array('refresh', $actions, true))    $out .= $btn('btn-secondary', 'fa-rotate', 'Refresh', 'data-demo');
    if (in_array('regenerate', $actions, true)) $out .= $btn('btn-secondary', 'fa-rotate', 'Regenerate', 'data-demo');
    if (in_array('gallery', $actions, true))    $out  = $btn('btn-secondary', 'fa-images', 'Open gallery', 'data-demo');
    return $out;
}

/** True when the document-storage tables are deployed. */
function archr_doc_tables_ready(PDO $pdo): bool {
    try {
        $row = $pdo->query("SELECT to_regclass('case_documents') AS cd, to_regclass('document_categories') AS dc, to_regclass('document_statuses') AS ds")->fetch();
        return !empty($row['cd']) && !empty($row['dc']) && !empty($row['ds']);
    } catch (Throwable) {
        return false;
    }
}


/** Map a case_documents row (+ category/status joins) to the render shape. */
function archr_doc_row_to_render(array $row, array $catFolder): array {
    $meta = [];
    if (!empty($row['metadata'])) {
        $decoded = json_decode((string)$row['metadata'], true);
        if (is_array($decoded)) $meta = $decoded;
    }
    $folder = $catFolder[$row['category_code'] ?? ''] ?? 'application';
    $generated = !empty($meta['generated']);

    // document_statuses -> render status
    $status = match (strtoupper((string)($row['status_code'] ?? ''))) {
        'VERIFIED'   => 'verified',
        'REJECTED'   => 'rejected',
        'PROCESSING' => $generated ? 'generated' : 'pending',
        'UPLOADED'   => 'pending',
        'PENDING'    => 'pending',
        default      => 'pending',
    };

    $origin = $generated ? 'generated' : 'uploaded';
    $bits = [];
    if (!empty($row['version_number'])) $bits[] = 'v' . (int)$row['version_number'];
    $stamp = $row['generated_at'] ?? $row['uploaded_at'] ?? null;
    if ($stamp) $bits[] = (new DateTimeImmutable((string)$stamp))->format('M j, Y');
    if (!empty($row['file_size_bytes'])) $bits[] = archr_doc_human_size((int)$row['file_size_bytes']);
    if ($row['status_code'] === 'VERIFIED' && !empty($row['verified_by_name'])) $bits[] = 'verified by ' . $row['verified_by_name'];
    if ($row['status_code'] === 'REJECTED' && !empty($row['notes'])) $bits[] = 'reason: ' . $row['notes'];

    return [
        'id'           => (int)$row['id'],
        'folder'       => $folder,
        'icon'         => archr_doc_icon($row['mime_type'] ?? '', (string)($row['file_name'] ?? '')),
        'name'         => (string)$row['file_name'],
        'mime'         => (string)($row['mime_type'] ?? ''),
        'code'         => (string)($row['category_code'] ?? ''),
        'status'       => $status,
        'origin'       => $origin,
        'origin_label' => $generated ? ('Generated' . (!empty($meta['template']) ? ' · ' . $meta['template'] : '')) : ('Uploaded by ' . ($row['uploaded_by_name'] ?? 'staff')),
        'meta'         => implode(' · ', $bits),
    ];
}

function archr_doc_icon(string $mime, string $name): string {
    $ext = strtolower(pathinfo($name, PATHINFO_EXTENSION));
    return match ($ext) {
        'pdf'          => 'fa-file-pdf',
        'jpg', 'jpeg', 'png', 'gif', 'webp' => 'fa-file-image',
        'doc', 'docx'  => 'fa-file-word',
        'json'         => 'fa-file-code',
        default        => str_starts_with($mime, 'image/') ? 'fa-file-image' : 'fa-file-lines',
    };
}

function archr_doc_human_size(int $bytes): string {
    if ($bytes >= 1048576) return number_format($bytes / 1048576, 1) . ' MB';
    if ($bytes >= 1024)    return number_format($bytes / 1024, 0) . ' KB';
    return $bytes . ' B';
}

/** All live document rows for a case, mapped to the render shape. */
function archr_doc_case_rows(PDO $pdo, int $caseId): array {
    $catFolder = archr_doc_category_folder();
    $docStmt = $pdo->prepare("
        SELECT d.id, d.file_name, d.mime_type, d.file_size_bytes, d.version_number,
               d.metadata, d.notes, d.uploaded_at, d.verified_at,
               dc.category_code, ds.status_code,
               up.full_name AS uploaded_by_name, vf.full_name AS verified_by_name
          FROM case_documents d
          LEFT JOIN document_categories dc ON dc.id = d.category_id
          LEFT JOIN document_statuses ds ON ds.id = d.status_id
          LEFT JOIN system_users up ON up.id = d.uploaded_by
          LEFT JOIN system_users vf ON vf.id = d.verified_by
         WHERE d.case_id = :case AND d.deleted_at IS NULL
         ORDER BY d.uploaded_at DESC
    ");
    $docStmt->execute([':case' => $caseId]);
    $rows = [];
    foreach ($docStmt->fetchAll() as $row) {
        $rows[] = archr_doc_row_to_render($row, $catFolder);
    }
    return $rows;
}

/**
 * Live bundle for one case: documents rows merged with the required
 * checklist so missing required docs render as dashed placeholder rows.
 * Returns ['case'=>..., 'documents'=>array] or null when the case is missing.
 */
function archr_doc_load_case_bundle(PDO $pdo, int $caseId): ?array {
    $caseStmt = $pdo->prepare("
        SELECT c.id, c.case_number, s.applicant_first_name, s.applicant_last_name,
               s.home_address, s.home_city, s.home_state, s.home_zip,
               ap.display_name,
               o.organization_name
          FROM cases c
          JOIN intake_submissions s ON s.id = c.submission_id
          LEFT JOIN application_anchor a ON a.submission_id = s.id
          LEFT JOIN applications ap ON ap.id = c.application_id
          LEFT JOIN case_claims cc ON cc.case_id = c.id
          LEFT JOIN coalition_organizations o
                 ON o.id = COALESCE(c.organization_id, cc.claimed_by_org_id, a.assigned_organization_id)
         WHERE c.id = :id
         LIMIT 1
    ");
    $caseStmt->execute([':id' => $caseId]);
    $case = $caseStmt->fetch();
    if (!$case) return null;

    $documents = archr_doc_case_rows($pdo, $caseId);
    $presentByCodeFolder = [];
    foreach ($documents as $render) {
        $presentByCodeFolder[$render['folder'] . '|' . $render['code']] = true;
    }

    // Derived "missing" rows for required docs with no file yet.
    foreach (archr_doc_required_checklist() as $folder => $items) {
        foreach ($items as $item) {
            $catCode = archr_doc_code_to_category($item['code']);
            if (!empty($presentByCodeFolder[$folder . '|' . $catCode])) continue;
            $entry = [
                'folder' => $folder,
                'icon'   => $item['icon'],
                'label'  => $item['label'],
                'status' => 'missing',
                'expected' => $case['case_number'] . '_' . $item['code'] . '_v1.pdf',
            ];
            if (!empty($item['gen'])) {
                $entry['generate_template'] = $item['gen'];
                $entry['note'] = 'Generatable from the token template.';
            } else {
                $entry['actions'] = ['request', 'upload'];
            }
            if (!empty($item['optional'])) $entry['optional'] = true;
            $documents[] = $entry;
        }
    }

    return ['case' => $case, 'documents' => $documents];
}

/** Checklist DocCode (or a template name uppercased by the generator) ->
 *  document_categories.category_code. Unknown codes file under
 *  COMMUNICATION with the original code kept in metadata.doc_code. */
function archr_doc_code_to_category(string $code): string {
    return match (true) {
        str_starts_with($code, 'INC'), $code === 'ZERO_INCOME_AFFIDAVIT' => 'INCOME',
        str_starts_with($code, 'PH_B') => 'ASSESSMENT_PHOTOS_BEFORE',
        str_starts_with($code, 'PH_D') => 'ASSESSMENT_PHOTOS_DURING',
        str_starts_with($code, 'PH_A') => 'ASSESSMENT_PHOTOS_AFTER',
        $code === 'APP' || $code === 'CONSENT' || $code === 'NC_HABITAT_FORM' => 'APPLICATION',
        $code === 'PROP' || $code === 'DEED' || $code === 'TAX' => 'PROPERTY',
        $code === 'ASSESS' => 'ASSESSMENT',
        $code === 'CONT' => 'CONTRACT',
        $code === 'CO'   => 'CHANGE_ORDER',
        $code === 'WO'   => 'WORK_ORDER',
        $code === 'CERT' => 'COMPLETION',
        $code === 'COMM' => 'COMMUNICATION',
        $code === 'CDBG_CENST' || $code === 'CDBG_ERR' || $code === 'CDBG_SHPO'
            || $code === 'CDBG_IDIS' || $code === 'DRAW_REQUEST_REPORTING_WORKBOOK' => 'GRANT',
        $code === 'FINAL_NOTICE_LETTER' => 'COMMUNICATION',
        default => in_array($code, ['APPLICATION','PROPERTY','INCOME','ASSESSMENT','ASSESSMENT_PHOTOS_BEFORE','ASSESSMENT_PHOTOS_DURING','CONTRACT','CHANGE_ORDER','WORK_ORDER','QUOTE','INVOICE','GRANT','ENV_REVIEW','SHPO','COMPLETION','COMMUNICATION','TEMPLATE'], true)
            ? $code : 'COMMUNICATION',
    };
}


/**
 * Org-wide overview rows from the case_document_inventory view
 * (per-case per-category document counts). Grouped per case for the
 * landing table. Empty when the view/tables are missing.
 */
function archr_doc_inventory_by_case(PDO $pdo, array $caseIds): array {
    if (!$caseIds) return [];
    $in = implode(',', array_map('intval', $caseIds));
    try {
        $rows = $pdo->query("
            SELECT case_id, case_number, category_code, category_name,
                   document_count, verified_count, pending_count, last_upload
              FROM case_document_inventory
             WHERE case_id IN ($in)
             ORDER BY case_number, category_code
        ")->fetchAll();
    } catch (Throwable) {
        return [];
    }
    $byCase = [];
    foreach ($rows as $r) {
        $id = (int)$r['case_id'];
        $byCase[$id] ??= ['case_number' => $r['case_number'], 'present' => 0, 'verified' => 0, 'pending' => 0, 'last_upload' => null];
        $byCase[$id]['present']  += (int)$r['document_count'];
        $byCase[$id]['verified'] += (int)$r['verified_count'];
        $byCase[$id]['pending']  += (int)$r['pending_count'];
        if ($r['last_upload'] && ($byCase[$id]['last_upload'] === null || $r['last_upload'] > $byCase[$id]['last_upload'])) {
            $byCase[$id]['last_upload'] = $r['last_upload'];
        }
    }
    return $byCase;
}

/** Pending-verification queue rows (view: pending_verification_documents),
 *  joined back to case_documents for case_id so rows can deep-link. */
function archr_doc_pending_queue(PDO $pdo, ?int $caseId = null): array {
    try {
        $sql = "SELECT v.id, d2.case_id, v.case_number, v.applicant_first_name, v.applicant_last_name,
                       v.category_name, v.file_name, v.uploaded_by_name, v.uploaded_at
                  FROM pending_verification_documents v
                  JOIN case_documents d2 ON d2.id = v.id";
        if ($caseId !== null) {
            $sql .= " WHERE d2.case_id = :case";
        }
        $stmt = $pdo->prepare($sql);
        $caseId !== null ? $stmt->execute([':case' => $caseId]) : $stmt->execute();
        return $stmt->fetchAll();
    } catch (Throwable) {
        return [];
    }
}

/**
 * Most-urgent document action items for a case, for the case-review widget.
 * Pending-verification docs first (they block progress), then missing
 * required checklist items. Each row: label, detail, kind, doc id (when the
 * file exists), folder, and a one-tap action.
 */
function archr_doc_urgent_items(PDO $pdo, int $caseId, array $documents, int $limit = 5): array {
    $items = [];
    // $documents here are raw case_documents rows (case-review loader shape).
    $presentCategories = [];
    foreach ($documents as $d) {
        if (!empty($d['category_code'])) $presentCategories[$d['category_code']] = true;
        $statusCode = strtoupper((string)($d['status_code'] ?? ''));
        if (in_array($statusCode, ['UPLOADED', 'PROCESSING'], true)) {
            $items[] = [
                'kind' => 'pending',
                'icon' => archr_doc_icon((string)($d['mime_type'] ?? ''), (string)$d['file_name']),
                'label' => (string)$d['file_name'],
                'detail' => 'Awaiting verification' . (!empty($d['uploaded_by_name']) ? ' · uploaded by ' . $d['uploaded_by_name'] : ''),
                'doc_id' => (int)$d['id'],
                'action' => 'review',
            ];
        }
    }
    foreach (archr_doc_required_checklist() as $folder => $reqs) {
        foreach ($reqs as $req) {
            if (!empty($req['optional'])) continue;
            $catCode = archr_doc_code_to_category($req['code']);
            if (!empty($presentCategories[$catCode])) continue;
            $items[] = [
                'kind' => 'missing',
                'icon' => $req['icon'],
                'label' => $req['label'],
                'detail' => 'Missing · ' . archr_doc_folders()[$folder]['label'],
                'doc_id' => 0,
                'folder' => $folder,
                'action' => !empty($req['gen']) ? 'generate' : 'upload',
                'template' => $req['gen'] ?? null,
            ];
        }
    }
    return array_slice($items, 0, $limit);
}

/**
 * All documents for a set of cases (bucket drive view), mapped to render
 * rows with the case number attached.
 */
function archr_doc_bucket_rows(PDO $pdo, array $caseIds): array {
    if (!$caseIds) return [];
    $in = implode(',', array_map('intval', $caseIds));
    $docStmt = $pdo->query("
        SELECT d.id, d.case_id, d.file_name, d.mime_type, d.file_size_bytes, d.version_number,
               d.metadata, d.notes, d.uploaded_at, d.verified_at,
               dc.category_code, ds.status_code, c.case_number,
               up.full_name AS uploaded_by_name, vf.full_name AS verified_by_name
          FROM case_documents d
          LEFT JOIN document_categories dc ON dc.id = d.category_id
          LEFT JOIN document_statuses ds ON ds.id = d.status_id
          LEFT JOIN cases c ON c.id = d.case_id
          LEFT JOIN system_users up ON up.id = d.uploaded_by
          LEFT JOIN system_users vf ON vf.id = d.verified_by
         WHERE d.case_id IN ($in) AND d.deleted_at IS NULL
         ORDER BY d.uploaded_at DESC
    ");
    $rows = [];
    $catFolder = archr_doc_category_folder();
    foreach ($docStmt->fetchAll() as $row) {
        $render = archr_doc_row_to_render($row, $catFolder);
        $render['case_number'] = (string)($row['case_number'] ?? '');
        $rows[] = $render;
    }
    return $rows;
}

/**
 * Build the Bucket drive tree:
 *   organizations / {org} / shared / templates
 *   organizations / {org} / cases / {case_number} / {folder} / files
 * The standard folder skeleton is always present (empty folders included),
 * matching document-storage.md; files are whatever is in case_documents.
 *
 * $cases: org-scoped case rows (need case_id, case_number, organization_name).
 * $docs:  archr_doc_bucket_rows() output.
 * Returns nested ['folders' => [name => node], 'files' => [...]].
 */
function archr_doc_bucket_tree(array $cases, array $docs): array {
    $root = ['folders' => [], 'files' => []];
    foreach ($cases as $c) {
        $org = (string)($c['organization_name'] ?? '') ?: 'Unassigned';
        $caseNumber = (string)($c['case_number'] ?? ('case-' . (int)$c['case_id']));
        // ??= at every level so every node always has the full shape
        // (folders + files); reference auto-vivification would leave bare
        // arrays that break count() at render time.
        $root['folders']['organizations'] ??= ['folders' => [], 'files' => []];
        $root['folders']['organizations']['folders'][$org] ??= ['folders' => [], 'files' => []];
        $orgNode = &$root['folders']['organizations']['folders'][$org];
        $orgNode['folders']['shared'] ??= ['folders' => [], 'files' => []];
        $orgNode['folders']['shared']['folders']['templates'] ??= ['folders' => [], 'files' => []];
        $orgNode['folders']['cases'] ??= ['folders' => [], 'files' => []];
        $orgNode['folders']['cases']['folders'][$caseNumber] ??= ['folders' => [], 'files' => []];
        $caseNode = &$orgNode['folders']['cases']['folders'][$caseNumber];
        foreach (archr_doc_folders() as $folderKey => $f) {
            $caseNode['folders'][$folderKey] ??= ['folders' => [], 'files' => [], 'label' => $f['label'], 'icon' => $f['icon']];
        }
        unset($orgNode, $caseNode);
    }
    foreach ($docs as $doc) {
        // Resolve org + case from the doc's case number.
        $caseNumber = (string)($doc['case_number'] ?? '');
        $orgName = 'Unassigned';
        foreach ($cases as $c) {
            if ((string)$c['case_number'] === $caseNumber) {
                $orgName = (string)($c['organization_name'] ?? '') ?: 'Unassigned';
                break;
            }
        }
        $folder = (string)($doc['folder'] ?? 'application');
        // Only file docs onto in-scope cases (which always exist from the
        // skeleton pass above, with the standard folder present).
        if (isset($root['folders']['organizations']['folders'][$orgName]['folders']['cases']['folders'][$caseNumber]['folders'][$folder])) {
            $root['folders']['organizations']['folders'][$orgName]['folders']['cases']['folders'][$caseNumber]['folders'][$folder]['files'][] = $doc;
        }
    }
    return $root;
}

/** Walk a bucket tree to a '/'-joined path of folder names. */
function archr_doc_bucket_at(array $tree, string $path): ?array {
    $node = $tree;
    foreach (array_values(array_filter(explode('/', $path), fn($p) => $p !== '')) as $seg) {
        if (!isset($node['folders'][$seg])) return null;
        $node = $node['folders'][$seg];
    }
    return $node;
}


/** The case id owned by a logged-in requestor, if any. */
function archr_doc_requestor_case_id(PDO $pdo, int $userId): ?int {
    $stmt = $pdo->prepare("
        SELECT c.id
          FROM cases c
          JOIN intake_submissions s ON s.id = c.submission_id
         WHERE s.requestor_user_id = :uid
         ORDER BY s.submitted_at DESC
         LIMIT 1
    ");
    $stmt->execute([':uid' => $userId]);
    $id = $stmt->fetchColumn();
    return $id !== false ? (int)$id : null;
}

/** Where uploaded files live until Dropbox/home-server sync lands.
 *  Stored relative to the app root; storage_provider 'local'.
 *  Direct web access is denied — files stream through
 *  api/documents.php?action=download with auth + scope checks. */
function archr_doc_upload_root(): string {
    $root = dirname(__DIR__) . '/uploads';
    if (!is_dir($root)) {
        mkdir($root, 0750, true);
    }
    $guard = $root . '/.htaccess';
    if (!is_file($guard)) {
        file_put_contents($guard, "# Case documents are private. Downloads go through api/documents.php.\nRequire all denied\nDeny from all\n");
    }
    return $root;
}


/**
 * Sample bundle used when the document tables are not deployed (or there is
 * no case to show). Keeps the Case Documents page demonstrable in prototype
 * mode; the UI flags it as sample data.
 */
function archr_doc_sample_bundle(): array {
    $case = [
        'id' => 0,
        'case_number' => 'ARCHR-2026-000042',
        'applicant_first_name' => 'Maria', 'applicant_last_name' => 'Lopez',
        'home_address' => '42 Cherry St', 'home_city' => 'Asheville',
        'home_state' => 'NC', 'home_zip' => '28801',
        'organization_name' => 'Habitat for Humanity',
        'phase' => 'Phase 3 · Assessment',
    ];
    $documents = [
        ['folder' => 'application', 'icon' => 'fa-file-pdf', 'name' => 'ARCHR-2026-000042_APP_v1.pdf',
         'status' => 'verified', 'origin' => 'generated', 'origin_label' => 'Generated on submission', 'meta' => 'v1 · Jul 28, 2026 · 241 KB'],
        ['folder' => 'application', 'icon' => 'fa-file-pdf', 'name' => 'ARCHR-2026-000042_CONSENT_v1.pdf',
         'status' => 'verified', 'origin' => 'uploaded', 'origin_label' => 'Uploaded by requestor', 'meta' => 'v1 · Jul 28, 2026 · 96 KB · verified by A. Lee'],

        ['folder' => 'property', 'icon' => 'fa-file-pdf', 'name' => 'ARCHR-2026-000042_PROP_20260802.pdf',
         'status' => 'verified', 'origin' => 'generated', 'origin_label' => 'Generated from county data', 'meta' => 'Aug 2, 2026 · 118 KB', 'actions' => ['view', 'refresh']],
        ['folder' => 'property', 'icon' => 'fa-file-circle-plus', 'label' => 'Deed / Title', 'expected' => 'ARCHR-2026-000042_DEED_v1.pdf',
         'status' => 'missing', 'actions' => ['request', 'upload']],
        ['folder' => 'property', 'icon' => 'fa-file-circle-plus', 'label' => 'Tax Record (2025)', 'expected' => 'ARCHR-2026-000042_TAX_2025.pdf',
         'status' => 'missing', 'actions' => ['request', 'upload']],

        ['folder' => 'income', 'icon' => 'fa-file-image', 'name' => 'ARCHR-2026-000042_INC_PAYSTUB_20260801.pdf',
         'status' => 'pending', 'origin' => 'uploaded', 'origin_label' => 'Uploaded by requestor', 'meta' => 'Aug 1, 2026 · 410 KB'],
        ['folder' => 'income', 'icon' => 'fa-file-pdf', 'name' => 'ARCHR-2026-000042_INC_SS_20260801.pdf',
         'status' => 'pending', 'origin' => 'uploaded', 'origin_label' => 'Uploaded by requestor', 'meta' => 'Aug 1, 2026 · 233 KB'],
        ['folder' => 'income', 'icon' => 'fa-file-circle-plus', 'label' => 'W-2 (most recent)', 'expected' => 'ARCHR-2026-000042_INC_W2_2025.pdf',
         'status' => 'missing', 'actions' => ['request']],

        ['folder' => 'assessments', 'icon' => 'fa-file-pdf', 'name' => 'ARCHR-2026-000042_ASSESS_v1.pdf',
         'status' => 'generated', 'origin' => 'generated', 'origin_label' => 'Generated', 'status_note' => 'Draft · pending review', 'meta' => 'v1 · Aug 5, 2026 · by J. Assessor', 'actions' => ['view', 'regenerate']],
        ['folder' => 'assessments', 'icon' => 'fa-camera', 'name' => '/initial/photos/ · 12 before photos',
         'status' => 'verified', 'origin' => 'uploaded', 'origin_label' => 'Uploaded by assessor', 'meta' => 'Aug 5, 2026 · 18.2 MB total', 'actions' => ['gallery']],

        ['folder' => 'contracts', 'icon' => 'fa-file-circle-plus', 'label' => 'Repair Contract',
         'status' => 'missing', 'note' => 'Eligible to generate — assessment complete Aug 5', 'generate_template' => 'Contract'],
        ['folder' => 'contracts', 'icon' => 'fa-file-circle-plus', 'label' => 'Change Orders',
         'status' => 'missing', 'note' => 'Created when scope changes during work', 'actions' => ['new_change_order']],

        ['folder' => 'financial', 'icon' => 'fa-file-pdf', 'name' => 'ABC-Roofing_QUOTE_001.pdf',
         'status' => 'pending', 'origin' => 'uploaded', 'origin_label' => 'Uploaded by subcontractor', 'meta' => 'Aug 8, 2026 · 122 KB · in /financial/quotes/'],
        ['folder' => 'financial', 'icon' => 'fa-file-circle-plus', 'label' => 'CDBG-CENST Form',
         'status' => 'missing', 'note' => 'Generatable — eligibility data present', 'generate_template' => 'CDBG-CENST'],
        ['folder' => 'financial', 'icon' => 'fa-file-circle-plus', 'label' => 'CDBG-ERR Form (Environmental Review)',
         'status' => 'missing', 'note' => 'Generatable — 2 fields still blank in case data', 'generate_template' => 'CDBG-ERR'],
        ['folder' => 'financial', 'icon' => 'fa-file-circle-plus', 'label' => 'CDBG-SHPO (Historic Preservation)',
         'status' => 'missing', 'note' => 'Generatable — requires scope categories + photos', 'generate_template' => 'CDBG-SHPO'],

        ['folder' => 'communications', 'icon' => 'fa-file-lines', 'name' => 'ARCHR-2026-000042_COMM_20260814.pdf',
         'status' => 'generated', 'origin' => 'generated', 'origin_label' => 'Generated', 'meta' => 'Communication log export · auto-updated daily', 'actions' => ['view', 'regenerate']],
    ];
    return ['case' => $case, 'documents' => $documents];
}

/* =================================================================
 * Dropbox Business connector (read-only for now).
 *
 * Credentials come from environment / secure_config (never committed):
 *   DROPBOX_ACCESS_TOKEN   - a direct access token, if you have one
 *   or the OAuth triple:
 *   DROPBOX_APP_KEY, DROPBOX_APP_SECRET, DROPBOX_REFRESH_TOKEN
 * Optional:
 *   DROPBOX_ROOT_PATH      - folder inside Dropbox to treat as the
 *                            Bucket root (e.g. "/ARCHR"). Default: account root.
 * ================================================================= */

/** True when enough credential material exists to call the API. */
function archr_dropbox_configured(): bool {
    archr_load_secure_config();
    if (getenv('DROPBOX_ACCESS_TOKEN')) return true;
    return (bool)(getenv('DROPBOX_APP_KEY') && getenv('DROPBOX_APP_SECRET') && getenv('DROPBOX_REFRESH_TOKEN'));
}

/** Folder inside Dropbox that the Bucket treats as root ('' = account root). */
function archr_dropbox_root(): string {
    archr_load_secure_config();
    return trim((string)(getenv('DROPBOX_ROOT_PATH') ?: ''), '/');
}

/** Resolve an access token: static token, or refresh-token OAuth exchange. */
function archr_dropbox_access_token(): string {
    archr_load_secure_config();
    $static = getenv('DROPBOX_ACCESS_TOKEN');
    if ($static) return $static;

    $key = getenv('DROPBOX_APP_KEY') ?: '';
    $secret = getenv('DROPBOX_APP_SECRET') ?: '';
    $refresh = getenv('DROPBOX_REFRESH_TOKEN') ?: '';
    if ($key === '' || $secret === '' || $refresh === '') return '';

    $ch = curl_init('https://api.dropboxapi.com/oauth2/token');
    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_USERPWD => $key . ':' . $secret,
        CURLOPT_POSTFIELDS => http_build_query(['grant_type' => 'refresh_token', 'refresh_token' => $refresh]),
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 20,
    ]);
    $resp = curl_exec($ch);
    $code = (int)curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
    curl_close($ch);
    if ($code !== 200 || !is_string($resp)) return '';
    $data = json_decode($resp, true);
    return (string)($data['access_token'] ?? '');
}

/** POST to a Dropbox API endpoint; returns [http_code, decoded_array|null]. */
function archr_dropbox_post(string $endpoint, array $body): array {
    $token = archr_dropbox_access_token();
    if ($token === '') return [0, null];
    $ch = curl_init('https://api.dropboxapi.com/2/' . $endpoint);
    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 30,
        CURLOPT_HTTPHEADER => [
            'Authorization: Bearer ' . $token,
            'Content-Type: application/json',
        ],
        CURLOPT_POSTFIELDS => json_encode($body, JSON_FORCE_OBJECT),
    ]);
    $resp = curl_exec($ch);
    $code = (int)curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
    curl_close($ch);
    return [$code, is_string($resp) ? json_decode($resp, true) : null];
}

/** Connection check: account display name/email for the status banner.
 *  Returns ['name','email','team'] or null on failure. */
function archr_dropbox_account(): ?array {
    [$code, $data] = archr_dropbox_post('users/get_current_account', []);
    if ($code === 200 && is_array($data)) {
        return [
            'name'  => (string)($data['name']['display_name'] ?? 'Dropbox account'),
            'email' => (string)($data['email'] ?? ''),
            'team'  => (string)($data['team']['name'] ?? ''),
        ];
    }
    return null;
}

/**
 * List one folder of the Dropbox drive.
 * $path is relative to DROPBOX_ROOT_PATH ('' = root). Returns
 * ['ok'=>bool, 'entries'=>[['tag'=>'folder'|'file','name','path','size','modified']], 'error'=>?string]
 * with Dropbox paths converted back to root-relative.
 */
function archr_dropbox_list(string $path): array {
    $root = archr_dropbox_root();
    $full = '/' . trim(($root !== '' ? $root . '/' : '') . trim($path, '/'), '/');
    if ($full === '/') $full = ''; // Dropbox API wants "" for the account root

    $entries = [];
    $body = ['path' => $full, 'recursive' => false, 'include_deleted' => false, 'limit' => 200];
    $pages = 0;
    do {
        if (isset($cursor)) {
            [$code, $data] = archr_dropbox_post('files/list_folder/continue', ['cursor' => $cursor]);
        } else {
            [$code, $data] = archr_dropbox_post('files/list_folder', $body);
        }
        if ($code !== 200 || !is_array($data)) {
            $summary = is_array($data) ? (string)($data['error_summary'] ?? 'unknown error') : 'no response';
            return ['ok' => false, 'entries' => [], 'error' => trim($summary)];
        }
        foreach (($data['entries'] ?? []) as $e) {
            $rel = preg_replace('#^/' . preg_quote($root, '#') . '#', '', (string)($e['path_display'] ?? ''));
            $rel = trim((string)$rel, '/');
            $entries[] = [
                'tag'      => ($e['.tag'] ?? '') === 'folder' ? 'folder' : 'file',
                'name'     => (string)($e['name'] ?? ''),
                'path'     => $rel,
                'size'     => isset($e['size']) ? archr_doc_human_size((int)$e['size']) : '',
                'modified' => !empty($e['server_modified']) ? (new DateTimeImmutable((string)$e['server_modified']))->format('M j, Y') : '',
            ];
        }
        $cursor = $data['cursor'] ?? null;
        $hasMore = !empty($data['has_more']) && $cursor;
        $pages++;
    } while ($hasMore && $pages < 10);

    return ['ok' => true, 'entries' => $entries, 'error' => null];
}

/** Temporary view link for a root-relative path (redirect target). */
function archr_dropbox_temporary_link(string $path): ?string {
    $root = archr_dropbox_root();
    $full = '/' . trim(($root !== '' ? $root . '/' : '') . trim($path, '/'), '/');
    [$code, $data] = archr_dropbox_post('files/get_temporary_link', ['path' => $full]);
    if ($code === 200 && is_array($data) && !empty($data['link'])) {
        return (string)$data['link'];
    }
    return null;
}



/** The OAuth consent URL (offline access => a refresh token comes back). */
function archr_dropbox_authorize_url(): string {
    archr_load_secure_config();
    $key = getenv('DROPBOX_APP_KEY') ?: '';
    return 'https://www.dropbox.com/oauth2/authorize?' . http_build_query([
        'client_id' => $key,
        'response_type' => 'code',
        'token_access_type' => 'offline',
    ]);
}

/**
 * Exchange a one-time authorization code for tokens.
 * Returns ['ok'=>bool, 'refresh_token'=>?string, 'error'=>?string].
 * The refresh token is returned to the admin exactly once, to be saved into
 * secure_config as DROPBOX_REFRESH_TOKEN. Nothing is logged or stored here.
 */
function archr_dropbox_exchange_code(string $code): array {
    archr_load_secure_config();
    $key = getenv('DROPBOX_APP_KEY') ?: '';
    $secret = getenv('DROPBOX_APP_SECRET') ?: '';
    if ($key === '' || $secret === '') {
        return ['ok' => false, 'refresh_token' => null, 'error' => 'DROPBOX_APP_KEY and DROPBOX_APP_SECRET must be configured first.'];
    }
    $ch = curl_init('https://api.dropboxapi.com/oauth2/token');
    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_USERPWD => $key . ':' . $secret,
        CURLOPT_POSTFIELDS => http_build_query(['grant_type' => 'authorization_code', 'code' => trim($code)]),
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 20,
    ]);
    $resp = curl_exec($ch);
    $http = (int)curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
    curl_close($ch);
    $data = is_string($resp) ? json_decode($resp, true) : null;
    if ($http !== 200 || !is_array($data)) {
        $err = is_array($data) ? (string)($data['error_description'] ?? $data['error'] ?? 'exchange failed') : 'no response';
        if (str_contains($err, 'invalid_grant')) {
            $err = 'That code has expired or was already used — authorize again to get a fresh one.';
        }
        return ['ok' => false, 'refresh_token' => null, 'error' => $err];
    }
    $refresh = (string)($data['refresh_token'] ?? '');
    if ($refresh === '') {
        return ['ok' => false, 'refresh_token' => null,
                'error' => 'Dropbox returned no refresh token — re-authorize using the offline-access link on this page.'];
    }
    return ['ok' => true, 'refresh_token' => $refresh, 'error' => null];
}
