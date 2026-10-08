<?php
declare(strict_types=1);

/* Case Documents portal. Structured per-case document directory with:
   - the folder layout + naming convention from document-storage.md,
   - live reads from case_documents / case_document_inventory /
     pending_verification_documents (sql/document-storage.sql),
   - an on-the-spot Generate modal whose token fields load live from
     elemental-integration/document-generation/document-tokens.json and
     POST to api/documents.php (generate / upload / verify / reject).

   Two modes:
     ?case=<id>  the per-case directory (live bundle; sample bundle when
                 the document tables are not deployed yet)
     (no param)  org overview: per-case document health from
                 case_document_inventory + the org-wide verification queue */

require __DIR__ . '/lib/auth.php';
archr_require_auth();

require __DIR__ . '/lib/db.php';
require __DIR__ . '/lib/org-admin.php';
require __DIR__ . '/lib/case-documents.php';
require __DIR__ . '/lib/portal-layout.php';

$pdo = archr_pdo();
$ctx = archr_require_org_admin($pdo);
$orgIds = array_map('intval', array_keys($ctx['orgs']));

$tablesReady = archr_doc_tables_ready($pdo);
$sampleMode = !$tablesReady;

// Org-scoped case list for the selector / overview.
$orgCases = archr_org_cases($pdo, $orgIds, false);
$cases = array_values(array_filter($orgCases, fn($c) => !empty($c['case_id'])));
usort($cases, fn($a, $b) => strcmp((string)($b['submitted_at'] ?? ''), (string)($a['submitted_at'] ?? '')));

$selectedCaseId = isset($_GET['case']) ? (int)$_GET['case'] : null;
if ($selectedCaseId !== null && $selectedCaseId <= 0) {
    $selectedCaseId = null;
}

$bundle = null;
$queueRows = [];
$inventory = [];
if ($tablesReady) {
    if ($selectedCaseId !== null) {
        $bundle = archr_doc_load_case_bundle($pdo, $selectedCaseId);
        if ($bundle !== null) {
            $queueRows = archr_doc_pending_queue($pdo, $selectedCaseId);
        }
    } else {
        $inventory = archr_doc_inventory_by_case($pdo, array_map(fn($c) => (int)$c['case_id'], $cases));
        $queueRows = archr_doc_pending_queue($pdo, null);
    }
}

// Fallbacks to the sample bundle: document tables not deployed, or a
// requested case id could not be loaded. The hero flags sample mode.
if ($bundle === null && (!$tablesReady || $selectedCaseId !== null)) {
    $bundle = archr_doc_sample_bundle();
    $sampleMode = true;
}

$view = $bundle !== null ? 'case' : 'overview';

// Token registry -> JS map for the generate modal. If the JSON is missing
// (e.g. partial deploy), the modal still works with an empty registry.
$tokensPath = realpath(__DIR__ . '/../elemental-integration/document-generation/document-tokens.json');
$docTokens = $tokensPath ? json_decode((string)file_get_contents($tokensPath), true) : null;

$templates = [];
$tokenMeta = [];
if (is_array($docTokens)) {
    foreach (($docTokens['templates'] ?? []) as $name => $t) {
        $templates[$name] = $t['tokens'] ?? [];
    }
    foreach (($docTokens['document_tokens'] ?? []) as $group => $tokens) {
        foreach ($tokens as $token => $def) {
            if (!empty($def['elements'])) {
                $labels = array_map(fn($e) => $e['key'] ?? '', $def['elements']);
                $def['label'] = ($def['label'] ?? $token) . ' (' . implode(', ', array_filter($labels)) . ')';
            }
            $tokenMeta[$token] = [
                'type'  => $def['type'] ?? 'string',
                'label' => $def['label'] ?? $token,
                'group' => $group,
            ];
        }
    }
}

$fullName = $_SESSION['archr_user_name'] ?? 'Org Admin';

archr_render_portal_header([
    'role'            => 'org-admin',
    'role_label'      => 'Org Admin',
    'brand'           => 'ARCHR Org Admin',
    'page_title'      => 'Case Documents',
    'user_name'       => $fullName,
    'avatar_initials' => archr_initials_from_name($fullName),
    'badge_icon'      => 'fa-user-shield',
    'extra_head'      => '<link rel="stylesheet" href="assets/case-documents.css">',
    'nav' => archr_case_nav('case-documents'),
]);

require __DIR__ . '/partials/case-documents-body.php';

archr_render_portal_footer();
