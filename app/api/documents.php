<?php declare(strict_types=1);
/**
 * Case Documents API.
 *
 *   upload    POST multipart: file, case_id, folder, doc_code, notes
 *             Staff (org admin) upload anywhere in scope; requestors upload
 *             to their own case only. Files land in app/uploads/ (storage
 *             provider 'local') and register as UPLOADED = pending
 *             verification, feeding the Case Documents verification queue.
 *   verify    POST: document_id                 (staff) -> VERIFIED
 *   reject    POST: document_id, reason         (staff) -> REJECTED
 *   generate  POST: case_id, template, tokens{} (staff) -> generation job
 *             + rendered HTML stored in the case folder, doc PROCESSING.
 *   download  GET:  document_id                 (staff in scope, or the
 *             requestor who owns the case)
 *
 * Storage is provider-agnostic: the 'local' provider is used until the
 * Dropbox / home-server connector lands; storage_path is relative to
 * archr_doc_upload_root().
 */

require_once __DIR__ . '/../lib/auth.php';
archr_require_auth();

require_once __DIR__ . '/../lib/db.php';
require_once __DIR__ . '/../lib/org-admin.php';
require_once __DIR__ . '/../lib/case-documents.php';
require_once __DIR__ . '/../lib/activity-log.php';

function doc_fail(string $message, int $code = 400): void {
    http_response_code($code);
    if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'GET') {
        echo $message;
    } else {
        header('Content-Type: application/json');
        echo json_encode(['success' => false, 'error' => $message]);
    }
    exit;
}

function doc_ok(array $data = []): void {
    header('Content-Type: application/json');
    echo json_encode(array_merge(['success' => true], $data));
    exit;
}

$pdo = archr_pdo();
if (!archr_doc_tables_ready($pdo)) {
    doc_fail('Document storage is not deployed yet (run sql/document-storage.sql).', 503);
}

$userId   = (int)($_SESSION['archr_user_id'] ?? 0);
$userName = (string)($_SESSION['archr_user_name'] ?? 'Unknown user');
$isRequestor = (($_SESSION['archr_role'] ?? '') === 'requestor');

// Staff context (org scope). Requestors get a limited context instead.
$ctx = null;
if (!$isRequestor) {
    $ctx = archr_require_org_admin($pdo);
}

/** The org that owns a case (per-org claim, legacy claim, or anchor assignment), if any. */
function doc_case_org(PDO $pdo, int $caseId): ?int {
    $stmt = $pdo->prepare("
        SELECT COALESCE(c.organization_id, cc.claimed_by_org_id, a.assigned_organization_id) AS org_id
          FROM cases c
          LEFT JOIN case_claims cc ON cc.case_id = c.id
          LEFT JOIN application_anchor a ON a.submission_id = c.submission_id
         WHERE c.id = :id
    ");
    $stmt->execute([':id' => $caseId]);
    $org = $stmt->fetchColumn();
    return $org !== false && $org !== null ? (int)$org : null;
}

/** Staff may act when the case's org is one they administer (or super admin). */
function doc_staff_can(int $caseId, ?array $ctx, PDO $pdo): bool {
    if ($ctx === null) return false;
    if ($ctx['is_super_admin']) return true;
    $orgId = doc_case_org($pdo, $caseId);
    return $orgId !== null && isset($ctx['orgs'][$orgId]);
}

function doc_status_id(PDO $pdo, string $code): int {
    $id = $pdo->prepare("SELECT id FROM document_statuses WHERE status_code = :c");
    $id->execute([':c' => $code]);
    $val = $id->fetchColumn();
    if (!$val) doc_fail("Document status $code missing — check document_statuses seed.", 500);
    return (int)$val;
}

function doc_category_id(PDO $pdo, string $categoryCode): int {
    $id = $pdo->prepare("SELECT id FROM document_categories WHERE category_code = :c");
    $id->execute([':c' => $categoryCode]);
    $val = $id->fetchColumn();
    if (!$val) doc_fail("Unknown document category $categoryCode.", 400);
    return (int)$val;
}

function doc_notify(PDO $pdo, ?int $toUserId, string $type, string $title, string $body, int $docId): void {
    if (!$toUserId) return;
    $pdo->prepare("
        INSERT INTO notifications (user_id, notification_type, title, body, entity_type, entity_id, priority)
        VALUES (:uid, :type, :title, :body, 'document', :did, 'high')
    ")->execute([':uid' => $toUserId, ':type' => $type, ':title' => $title, ':body' => $body, ':did' => $docId]);
}

$action = trim((string)($_POST['action'] ?? $_GET['action'] ?? ''));

try {
    switch ($action) {

        // ------------------------------------------------ upload ----
        case 'upload': {
            $caseId = (int)($_POST['case_id'] ?? 0);
            $docCode = strtoupper(trim((string)($_POST['doc_code'] ?? '')));
            $notes = trim((string)($_POST['notes'] ?? ''));
            if ($caseId === 0) doc_fail('Case ID is required.');
            if ($docCode === '') doc_fail('Document code is required.');

            // Scope check
            if ($isRequestor) {
                $ownCase = archr_doc_requestor_case_id($pdo, $userId);
                if ($ownCase === null || $ownCase !== $caseId) {
                    doc_fail('You can only upload to your own case.', 403);
                }
            } elseif (!doc_staff_can($caseId, $ctx, $pdo)) {
                doc_fail('This case is not in your organization\'s scope.', 403);
            }

            $caseNumber = (string)$pdo->query("SELECT case_number FROM cases WHERE id = " . $caseId)->fetchColumn();
            if ($caseNumber === '') doc_fail('Case not found.', 404);

            // File validation
            if (empty($_FILES['file']) || $_FILES['file']['error'] !== UPLOAD_ERR_OK) {
                doc_fail('No file received (or upload error ' . (int)($_FILES['file']['error'] ?? -1) . ').');
            }
            $file = $_FILES['file'];
            $maxBytes = 25 * 1024 * 1024; // 25MB dev cap (storage_providers default 100MB)
            if ($file['size'] > $maxBytes) doc_fail('File exceeds the 25 MB limit.');
            $origName = basename((string)$file['name']);
            $ext = strtolower(pathinfo($origName, PATHINFO_EXTENSION));
            if (!in_array($ext, ['pdf', 'jpg', 'jpeg', 'png', 'docx'], true)) {
                doc_fail('Unsupported file type. Allowed: pdf, jpg, jpeg, png, docx.');
            }

            $hash = hash_file('sha256', $file['tmp_name']);
            $categoryCode = archr_doc_code_to_category($docCode);
            $folder = archr_doc_category_folder()[$categoryCode] ?? 'application';

            // Duplicate detection (same content already on this case)
            $dup = $pdo->prepare("SELECT id, file_name FROM case_documents WHERE case_id = :c AND file_hash = :h AND deleted_at IS NULL LIMIT 1");
            $dup->execute([':c' => $caseId, ':h' => $hash]);
            if ($existing = $dup->fetch()) {
                doc_fail('This exact file is already on the case as ' . $existing['file_name'] . ' (document #' . $existing['id'] . ').', 409);
            }

            // Store: uploads/cases/{case_number}/{folder}/{random}.{ext}
            $relDir = 'cases/' . $caseNumber . '/' . $folder;
            $absDir = archr_doc_upload_root() . '/' . $relDir;
            if (!is_dir($absDir) && !mkdir($absDir, 0750, true)) {
                doc_fail('Could not create the case folder on the server.', 500);
            }
            $storedName = bin2hex(random_bytes(8)) . '_' . preg_replace('/[^A-Za-z0-9._-]+/', '_', $origName);
            $relPath = $relDir . '/' . $storedName;
            if (!move_uploaded_file($file['tmp_name'], archr_doc_upload_root() . '/' . $relPath)) {
                doc_fail('Could not store the uploaded file.', 500);
            }

            $version = 1 + (int)$pdo->query(
                "SELECT COUNT(*) FROM case_documents d
                   JOIN document_categories dc ON dc.id = d.category_id
                  WHERE d.case_id = $caseId AND dc.category_code = " . $pdo->quote($categoryCode)
            )->fetchColumn();

            $pdo->beginTransaction();
            $ins = $pdo->prepare("
                INSERT INTO case_documents
                    (case_id, category_id, status_id, file_name, file_size_bytes, file_hash,
                     mime_type, storage_path, storage_provider, version_number,
                     metadata, uploaded_by, notes)
                VALUES
                    (:case, :cat, :status, :name, :size, :hash, :mime, :path, 'local', :ver,
                     :meta, :by, :notes)
                RETURNING id
            ");
            $ins->execute([
                ':case' => $caseId,
                ':cat' => doc_category_id($pdo, $categoryCode),
                ':status' => doc_status_id($pdo, 'UPLOADED'),
                ':name' => $origName,
                ':size' => (int)$file['size'],
                ':hash' => $hash,
                ':mime' => (string)($file['type'] ?? ''),
                ':path' => $relPath,
                ':ver' => $version,
                ':meta' => json_encode(['doc_code' => $docCode, 'source' => $isRequestor ? 'requestor' : 'staff']),
                ':by' => $userId,
                ':notes' => $notes ?: null,
            ]);
            $docId = (int)$ins->fetchColumn();
            $pdo->prepare("INSERT INTO document_access_log (document_id, accessed_by, access_type) VALUES (:d, :u, 'upload')")
                ->execute([':d' => $docId, ':u' => $userId]);
            // Immutable ledger: uploads are permanent record (verified or not).
            archr_log_event($pdo, 'document_uploaded', [
                'application_id' => (int)$pdo->query("SELECT application_id FROM cases WHERE id = " . $caseId)->fetchColumn() ?: null,
                'case_id'        => $caseId,
                'summary'        => $origName . ' uploaded (' . $categoryCode . ', v' . $version . ')',
                'details'        => [
                    'document_id' => $docId,
                    'doc_code'    => $docCode,
                    'category'    => $categoryCode,
                    'file_name'   => $origName,
                    'size_bytes'  => (int)$file['size'],
                    'version'     => $version,
                    'uploader'    => $isRequestor ? 'requestor' : 'staff',
                ],
                'user_id'        => $userId,
            ]);
            $pdo->commit();
            doc_ok(['document_id' => $docId, 'status' => 'UPLOADED', 'version' => $version]);
        }


        // ------------------------------------------------ review ----
        /* Staff review of an uploaded document, from the review modal (the
           reviewer is looking at the actual file when deciding):
             verified   -> VERIFIED, evidence accepted
             needs_info -> soft deny: stays UPLOADED (still pending), comment
                           tells the uploader what to send; they can re-upload
             rejected   -> hard deny: REJECTED
           Comment is required for needs_info and rejected; it is sent to the
           uploader via notifications. */
        case 'review': {
            if ($isRequestor) doc_fail('Review is a staff action.', 403);
            $docId = (int)($_POST['document_id'] ?? 0);
            $decision = strtolower(trim((string)($_POST['decision'] ?? '')));
            $comment = trim((string)($_POST['comment'] ?? ''));
            if ($docId === 0) doc_fail('Document ID is required.');
            if (!in_array($decision, ['verified', 'needs_info', 'rejected'], true)) {
                doc_fail('Decision must be verified, needs_info, or rejected.');
            }
            if ($decision !== 'verified' && $comment === '') {
                doc_fail('A comment is required when you are not verifying — it is sent to the uploader.');
            }

            $doc = $pdo->prepare("SELECT id, case_id, file_name, uploaded_by FROM case_documents WHERE id = :id AND deleted_at IS NULL");
            $doc->execute([':id' => $docId]);
            $d = $doc->fetch();
            if (!$d) doc_fail('Document not found.', 404);
            if (!doc_staff_can((int)$d['case_id'], $ctx, $pdo)) doc_fail('Not in your scope.', 403);

            $pdo->beginTransaction();
            if ($decision === 'verified') {
                $pdo->prepare("UPDATE case_documents SET status_id = :s, verified_by = :by, verified_at = CURRENT_TIMESTAMP,
                                  notes = COALESCE(NULLIF(:comment, ''), notes), updated_at = CURRENT_TIMESTAMP WHERE id = :id")
                    ->execute([':s' => doc_status_id($pdo, 'VERIFIED'), ':by' => $userId, ':comment' => $comment, ':id' => $docId]);
            } elseif ($decision === 'needs_info') {
                // Stays pending: UPLOADED + note. Uploader re-uploads a new version.
                $pdo->prepare("UPDATE case_documents SET notes = :comment, updated_at = CURRENT_TIMESTAMP WHERE id = :id")
                    ->execute([':comment' => $comment, ':id' => $docId]);
            } else {
                $pdo->prepare("UPDATE case_documents SET status_id = :s, notes = :comment, updated_at = CURRENT_TIMESTAMP WHERE id = :id")
                    ->execute([':s' => doc_status_id($pdo, 'REJECTED'), ':comment' => $comment, ':id' => $docId]);
            }
            $pdo->prepare("INSERT INTO document_access_log (document_id, accessed_by, access_type) VALUES (:d, :u, :t)")
                ->execute([':d' => $docId, ':u' => $userId, ':t' => 'review_' . $decision]);

            // Immutable ledger: the review decision is a curated event.
            archr_log_event($pdo, 'document_' . $decision, [
                'application_id' => (int)$pdo->query("SELECT application_id FROM cases WHERE id = " . (int)$d['case_id'])->fetchColumn() ?: null,
                'case_id'        => (int)$d['case_id'],
                'summary'        => $titles[$decision] . ' — by ' . $userName,
                'details'        => [
                    'document_id' => $docId,
                    'decision'    => $decision,
                    'file_name'   => $d['file_name'],
                    'comment'     => $comment !== '' ? $comment : null,
                ],
                'user_id'        => $userId,
            ]);

            $titles = [
                'verified'   => 'Document verified: ' . $d['file_name'],
                'needs_info' => 'More information needed: ' . $d['file_name'],
                'rejected'   => 'Document not accepted: ' . $d['file_name'],
            ];
            $bodies = [
                'verified'   => $d['file_name'] . ' was verified by ' . $userName . '.' . ($comment !== '' ? ' Note: ' . $comment : ''),
                'needs_info' => $userName . ' reviewed ' . $d['file_name'] . ' and needs more information: ' . $comment,
                'rejected'   => $d['file_name'] . ' was not accepted by ' . $userName . '. Reason: ' . $comment,
            ];
            doc_notify($pdo, $d['uploaded_by'] ? (int)$d['uploaded_by'] : null,
                'document_' . $decision, $titles[$decision], $bodies[$decision], $docId);
            $pdo->commit();
            doc_ok(['document_id' => $docId, 'decision' => $decision]);
        }

        // ------------------------------------------------ generate ----
        case 'generate': {
            if ($isRequestor) doc_fail('Generation is a staff action.', 403);
            $caseId = (int)($_POST['case_id'] ?? 0);
            $template = trim((string)($_POST['template'] ?? ''));
            $tokens = json_decode((string)($_POST['tokens'] ?? '{}'), true);
            if ($caseId === 0) doc_fail('Case ID is required.');
            if ($template === '') doc_fail('Template is required.');
            if (!is_array($tokens)) doc_fail('Tokens payload must be a JSON object.');
            if (!doc_staff_can($caseId, $ctx, $pdo)) doc_fail('Not in your scope.', 403);

            // Validate the template against the token registry.
            $tokensPath = realpath(__DIR__ . '/../../elemental-integration/document-generation/document-tokens.json');
            $registry = $tokensPath ? json_decode((string)file_get_contents($tokensPath), true) : null;
            if (!is_array($registry) || empty($registry['templates'][$template])) {
                doc_fail('Unknown template — not present in document-tokens.json.', 400);
            }
            $requiredTokens = $registry['templates'][$template]['tokens'] ?? [];
            $missing = array_values(array_filter($requiredTokens, fn($t) => !isset($tokens[$t]) || $tokens[$t] === ''));
            if ($missing && empty($_POST['allow_incomplete'])) {
                doc_fail('Missing token values: ' . implode(', ', array_slice($missing, 0, 8)) . (count($missing) > 8 ? '…' : ''));
            }

            $case = $pdo->prepare("SELECT id, case_number FROM cases WHERE id = :id");
            $case->execute([':id' => $caseId]);
            $c = $case->fetch();
            if (!$c) doc_fail('Case not found.', 404);

            // Render: simple local token replacement (same {{token}} method as
            // the local Docupilot renderer) into a printable HTML proof.
            $docCode = preg_replace('/[^A-Za-z0-9]+/', '_', strtoupper($template));
            $version = 1 + (int)$pdo->query(
                "SELECT COUNT(*) FROM case_documents WHERE case_id = $caseId AND file_name LIKE " . $pdo->quote('%_' . $docCode . '_v%')
            )->fetchColumn();
            $fileName = $c['case_number'] . '_' . $docCode . '_v' . $version . '.html';

            $rowsHtml = '';
            foreach ($tokens as $k => $v) {
                $safeK = htmlspecialchars((string)$k, ENT_QUOTES, 'UTF-8');
                $safeV = nl2br(htmlspecialchars(is_scalar($v) ? (string)$v : json_encode($v), ENT_QUOTES, 'UTF-8'));
                $rowsHtml .= "<tr><th>{{{$safeK}}}</th><td>{$safeV}</td></tr>";
            }
            $html = "<!DOCTYPE html><html><head><meta charset=\"utf-8\"><title>" . htmlspecialchars($fileName) . "</title>"
                . "<style>body{font-family:sans-serif;margin:2rem;}h1{font-size:1.2rem;}table{border-collapse:collapse;width:100%;}th,td{border:1px solid #ccc;padding:6px 10px;text-align:left;font-size:.9rem;}th{background:#f3f5fa;width:280px;font-family:monospace;}</style>"
                . "</head><body><h1>" . htmlspecialchars($template) . " — " . htmlspecialchars((string)$c['case_number']) . "</h1>"
                . "<p>Generated " . date('Y-m-d H:i') . " by " . htmlspecialchars($userName) . ". Missing tokens: " . ($missing ? htmlspecialchars(implode(', ', $missing)) : 'none') . ".</p>"
                . "<table>{$rowsHtml}</table></body></html>";

            $relDir = 'cases/' . $c['case_number'] . '/generated';
            $absDir = archr_doc_upload_root() . '/' . $relDir;
            if (!is_dir($absDir) && !mkdir($absDir, 0750, true)) doc_fail('Could not create the case folder on the server.', 500);
            $relPath = $relDir . '/' . $fileName;
            if (file_put_contents(archr_doc_upload_root() . '/' . $relPath, $html) === false) {
                doc_fail('Could not write the generated document.', 500);
            }

            $pdo->beginTransaction();
            // Generation job (async-by-design table from document-storage.sql)
            $job = $pdo->prepare("
                INSERT INTO document_generation_jobs (case_id, template_id, status, data_source, created_by)
                VALUES (:case, NULL, 'completed', :data, :by)
                RETURNING id
            ");
            $job->execute([':case' => $caseId, ':data' => json_encode(['template' => $template, 'tokens' => $tokens, 'missing' => $missing]), ':by' => $userId]);
            $jobId = (int)$job->fetchColumn();

            $ins = $pdo->prepare("
                INSERT INTO case_documents
                    (case_id, category_id, status_id, file_name, file_size_bytes,
                     mime_type, storage_path, storage_provider, version_number, metadata, uploaded_by)
                VALUES
                    (:case, :cat, :status, :name, :size, 'text/html', :path, 'local', :ver, :meta, :by)
                RETURNING id
            ");
            $ins->execute([
                ':case' => $caseId,
                ':cat' => doc_category_id($pdo, archr_doc_code_to_category($docCode)),
                ':status' => doc_status_id($pdo, 'PROCESSING'),
                ':name' => $fileName,
                ':size' => filesize(archr_doc_upload_root() . '/' . $relPath) ?: 0,
                ':path' => $relPath,
                ':ver' => $version,
                ':meta' => json_encode(['generated' => true, 'template' => $template, 'doc_code' => $docCode, 'generation_job_id' => $jobId]),
                ':by' => $userId,
            ]);
            $docId = (int)$ins->fetchColumn();
            $pdo->prepare("UPDATE document_generation_jobs SET output_document_id = :doc, completed_at = CURRENT_TIMESTAMP WHERE id = :job")
                ->execute([':doc' => $docId, ':job' => $jobId]);
            $pdo->prepare("INSERT INTO document_access_log (document_id, accessed_by, access_type) VALUES (:d, :u, 'generate')")
                ->execute([':d' => $docId, ':u' => $userId]);
            $pdo->commit();
            doc_ok(['document_id' => $docId, 'job_id' => $jobId, 'file' => $fileName, 'missing_tokens' => $missing]);
        }


        // ------------------------------------------------ download ----
        case 'download': {
            $docId = (int)($_GET['document_id'] ?? 0);
            if ($docId === 0) doc_fail('Document ID is required.');

            $doc = $pdo->prepare("SELECT id, case_id, file_name, mime_type, storage_path FROM case_documents WHERE id = :id AND deleted_at IS NULL");
            $doc->execute([':id' => $docId]);
            $d = $doc->fetch();
            if (!$d) doc_fail('Document not found.', 404);

            if ($isRequestor) {
                $ownCase = archr_doc_requestor_case_id($pdo, $userId);
                if ($ownCase === null || (int)$d['case_id'] !== $ownCase) doc_fail('Not your document.', 403);
            } elseif (!doc_staff_can((int)$d['case_id'], $ctx, $pdo)) {
                doc_fail('Not in your scope.', 403);
            }

            // Path traversal guard: the stored path must stay under uploads/.
            $root = realpath(archr_doc_upload_root());
            $abs = realpath($root . '/' . (string)$d['storage_path']);
            if ($root === false || $abs === false || !str_starts_with($abs, $root . DIRECTORY_SEPARATOR)) {
                doc_fail('Stored file not found.', 404);
            }

            $pdo->prepare("INSERT INTO document_access_log (document_id, accessed_by, access_type) VALUES (:d, :u, 'download')")
                ->execute([':d' => $docId, ':u' => $userId]);

            header('Content-Type: ' . ($d['mime_type'] ?: 'application/octet-stream'));
            header('Content-Disposition: inline; filename="' . preg_replace('/[^A-Za-z0-9._-]+/', '_', (string)$d['file_name']) . '"');
            header('Content-Length: ' . (string)filesize($abs));
            readfile($abs);
            exit;
        }

        // ---------------------------------------- dropbox_open ----
        /* Resolve a Dropbox temporary link for a drive path and redirect to
           it. Staff only; the access token never leaves the server. */
        case 'dropbox_open': {
            if ($isRequestor) doc_fail('Staff only.', 403);
            if ($ctx === null) doc_fail('Staff only.', 403);
            $path = (string)($_GET['path'] ?? '');
            // Path safety: no traversal, must stay a plain relative path.
            if ($path === '' || str_contains($path, '..') || str_starts_with($path, '/') || str_contains($path, '\\')) {
                doc_fail('Invalid path.');
            }
            if (!archr_dropbox_configured()) doc_fail('Dropbox is not configured.', 503);
            $link = archr_dropbox_temporary_link($path);
            if ($link === null) doc_fail('Could not open that file in Dropbox.', 404);
            header('Location: ' . $link, true, 302);
            exit;
        }

        // ---------------------------------------- dropbox_exchange ----
        /* One-time setup: exchange a Dropbox authorization code for a
           refresh token. Super admin only. The refresh token is returned
           once for the admin to save into secure_config; never stored or
           logged by the app. */
        case 'dropbox_exchange': {
            if ($isRequestor || $ctx === null || !$ctx['is_super_admin']) {
                doc_fail('Super Admin only.', 403);
            }
            $code = trim((string)($_POST['code'] ?? ''));
            if ($code === '') doc_fail('Paste the authorization code from Dropbox.');
            $result = archr_dropbox_exchange_code($code);
            if (!$result['ok']) doc_fail((string)$result['error']);
            doc_ok(['refresh_token' => $result['refresh_token']]);
        }

        default:
            doc_fail('Unknown action.');
    }
} catch (Throwable $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    error_log('[documents] ' . $e->getMessage());
    doc_fail('Server error: ' . $e->getMessage(), 500);
}
