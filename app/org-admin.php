<?php
declare(strict_types=1);

/* Org Admin role portal (live data).
 *
 * Permission level 2 of the four-tier structure: an Organization
 * Administrator can act on any case within their organization — review
 * submitted applications, claim them (in whole or per-repair), and manage
 * them through the six-phase pipeline.
 *
 * The controller renders each side-menu item as its own display via
 * ?page= (dashboard, applications, team, messages, metrics, help).
 * Consequential actions (claim, withdraw) POST to api/org-admin.php. */

require __DIR__ . '/lib/auth.php';
archr_require_auth();

require __DIR__ . '/lib/db.php';
require __DIR__ . '/lib/case-phases.php';
require __DIR__ . '/lib/case-review.php';
require __DIR__ . '/lib/org-admin.php';
require __DIR__ . '/lib/case-documents.php';
require __DIR__ . '/lib/portal-layout.php';
require_once __DIR__ . '/lib/permissions.php';

$pdo = archr_pdo();
$ctx = archr_require_org_admin($pdo);
$userId = (int)($_SESSION['archr_user_id'] ?? 0);

$orgs = $ctx['orgs'];
$orgIds = array_map('intval', array_keys($orgs));
$primaryOrg = $orgs ? $orgs[array_key_first($orgs)] : null;
$isSuperAdmin = $ctx['is_super_admin'];

$page = trim((string)($_GET['page'] ?? 'dashboard'));
$validPages = [
    'dashboard', 'applications', 'documents', 'team', 'messages', 'metrics', 'help',
    // Level 2 consolidated pages (formerly separate role portals):
    'projects', 'schedule', 'workflows', 'unclaimed', 'escalations',
    'funding', 'reimbursements', 'invoices',
    'marketplace', 'eligible-jobs',
    'review-queue',
];
if (!in_array($page, $validPages, true)) {
    $page = 'dashboard';
}

// ----- Live data -----------------------------------------------------
// Multi-org model: an application can carry several cases (one per claiming
// org). "Claimable" = application not terminal, and my org holds no active
// case on it — including expired applications, which are re-claimable.
$cases = archr_org_cases($pdo, $orgIds, true);
$claimedCases = array_values(array_filter($cases, fn($c) => $c['org_id'] !== null && in_array((int)$c['org_id'], $orgIds, true)));

$myActiveAppIds = [];
foreach ($claimedCases as $c) {
    if (($c['claim_status'] ?? null) === 'active' && !empty($c['application_id'])) {
        $myActiveAppIds[(int)$c['application_id']] = true;
    }
}

$claimableMap = [];
foreach ($cases as $c) {
    $appStatus = strtolower((string)($c['application_status'] ?? ''));
    $appId = (int)($c['application_id'] ?? 0);
    if ($appStatus !== '' && !in_array($appStatus, ['new', 'expired'], true)) {
        continue; // active or terminal application
    }
    if ($appStatus === '' && strtolower((string)$c['submission_status']) === 'withdrawn') {
        continue; // legacy row without an application link
    }
    if ($appId !== 0 && isset($myActiveAppIds[$appId])) {
        continue; // my org already holds an active case on this application
    }
    $key = $appId !== 0 ? ('app-' . $appId) : ('sub-' . (int)$c['submission_id']);
    if (!isset($claimableMap[$key])) {
        $claimableMap[$key] = $c;
    }
}
$claimableCases = array_values($claimableMap);

$activeCases = array_values(array_filter($claimedCases, fn($c) => !in_array(strtoupper((string)($c['status_code'] ?? '')), ['COMPLETED', 'DENIED', 'WITHDRAWN'], true)));
$completedCases = array_values(array_filter($claimedCases, fn($c) => strtoupper((string)($c['status_code'] ?? '')) === 'COMPLETED'));
$exitCases = array_values(array_filter($claimedCases, fn($c) => in_array(strtoupper((string)($c['status_code'] ?? '')), ['DENIED', 'WITHDRAWN'], true)));

// Claims running low on their 90-day progress window (attention needed).
$expiringClaims = array_values(array_filter($claimedCases, fn($c) => ($c['claim_status'] ?? null) === 'active' && $c['days_until_expiry'] !== null && (int)$c['days_until_expiry'] <= 14));
usort($expiringClaims, fn($a, $b) => (int)$a['days_until_expiry'] <=> (int)$b['days_until_expiry']);

// Per-phase breakdown for metrics + dashboard.
$phaseCounts = array_fill(0, 6, 0);
foreach ($activeCases as $c) {
    $phaseCounts[archr_case_phase($c)['number']]++;
}

$recentCases = array_merge($claimedCases, $claimableCases);
usort($recentCases, fn($a, $b) => strcmp((string)$b['submitted_at'], (string)$a['submitted_at']));
$recentCases = array_slice($recentCases, 0, 6);

$events = archr_org_case_events($pdo, $orgIds, 8);
$notifications = archr_org_user_notifications($pdo);
$unreadCount = count(array_filter($notifications, fn($n) => !$n['is_read']));

// Team page: staff assigned to the user's orgs.
$team = [];
if ($page === 'team' && $orgIds) {
    $in = implode(',', $orgIds);
    $team = $pdo->query("
        SELECT u.id, u.full_name, u.email, u.phone, u.last_login, u.is_active,
               o.organization_name,
               string_agg(DISTINCT r.role_name, ', ' ORDER BY r.role_name) AS roles
          FROM user_role_assignments ura
          JOIN system_users u ON u.id = ura.user_id
          JOIN roles r ON r.id = ura.role_id
          JOIN coalition_organizations o ON o.id = ura.organization_id
         WHERE ura.organization_id IN ($in) AND ura.is_active = true
         GROUP BY u.id, u.full_name, u.email, u.phone, u.last_login, u.is_active, o.organization_name
         ORDER BY o.organization_name, u.full_name
    ")->fetchAll();
}

$fullName = $_SESSION['archr_user_name'] ?? 'Org Admin';
$initials = archr_initials_from_name($fullName);
$firstName = explode(' ', trim($fullName))[0];

// Read user's menu configuration (saved in profile.php).
$menuConfigRaw = $ctx['user_menu_config'] ?? null;
if (is_string($menuConfigRaw)) {
    $menuConfig = json_decode($menuConfigRaw, true) ?: [];
} elseif (is_array($menuConfigRaw)) {
    $menuConfig = $menuConfigRaw;
} else {
    // Default: all Level 2 items enabled (backward compat).
    $menuConfig = [];
    $level = archr_current_permission_level();
    foreach (archr_menu_registry() as $item) {
        if ($item['minLevel'] <= $level) {
            $menuConfig[$item['key']] = true;
        }
    }
}

/**
 * Build the nav array filtered by the user's menu config.
 * Items not checked in the user's menu config are excluded.
 * The 'group' separator is only rendered if at least one item in the group is visible.
 */
function archr_build_filtered_nav(string $page, array $menuConfig): array {
    $registry = archr_menu_registry();
    $nav = [];
    $lastGroup = null;
    $pendingGroup = null;

    foreach ($registry as $item) {
        if (empty($menuConfig[$item['key']])) {
            continue; // User has this item disabled
        }

        // If there's a group change, add the group separator
        if ($item['group'] !== $lastGroup) {
            if ($lastGroup !== null) {
                // Close previous group implicitly (no action needed, just track)
            }
            if ($item['group'] !== null) {
                $nav[] = ['group' => $item['group']];
            }
            $lastGroup = $item['group'];
        }

        $isActive = ($page === $item['key']) ||
                    ($item['key'] === 'dashboard' && $page === 'dashboard');
        if ($item['key'] === 'case-search') {
            $href = 'case-search.php';
        } elseif ($item['key'] === 'help') {
            $href = 'help.php';
        } else {
            $href = 'org-admin.php?page=' . $item['key'];
        }

        $nav[] = [
            'href' => $href,
            'icon' => $item['icon'],
            'label' => $item['label'],
            'active' => $isActive,
        ];
    }

    return $nav;
}

$filteredNav = archr_build_filtered_nav($page, $menuConfig);

// Documents Bucket (drive view) data — only loaded on the documents page.
// When Dropbox credentials are configured, the Bucket browses the Dropbox
// Business drive directly; otherwise it shows the local document tree.
$bucketNode = null;
$bucketPath = '';
$bucketSample = false;
$driveMode = 'local';
$driveAccount = null;
$driveError = null;
$driveEntries = [];
if ($page === 'documents') {
    $bucketPath = trim((string)($_GET['path'] ?? ''), '/');
    if (archr_dropbox_configured()) {
        $driveMode = 'dropbox';
        $driveAccount = archr_dropbox_account();
        if ($driveAccount === null) {
            $driveError = 'Could not reach Dropbox with the configured credentials. Check the app key/secret/refresh token.';
        } else {
            $listing = archr_dropbox_list($bucketPath);
            if (!$listing['ok']) {
                $driveError = 'Dropbox error: ' . ($listing['error'] ?? 'unknown');
                if (str_contains((string)$listing['error'], 'not_found')) {
                    $driveError = 'That folder does not exist in the Dropbox drive.';
                }
            } else {
                $driveEntries = $listing['entries'];
            }
        }
    } else {
        $docTablesReady = archr_doc_tables_ready($pdo);
        $bucketSample = !$docTablesReady;
        if ($docTablesReady) {
            $bucketDocs = archr_doc_bucket_rows($pdo, array_map(fn($c) => (int)$c['case_id'], $claimedCases));
            $bucketTree = archr_doc_bucket_tree($claimedCases, $bucketDocs);
        } else {
            // Sample drive content (prototype) until the document tables deploy.
            $sampleCases = [[
                'case_id' => 0, 'case_number' => 'ARCHR-2026-000042',
                'organization_name' => $primaryOrg['organization_name'] ?? 'Habitat for Humanity',
            ]];
            $sampleDocs = [
                ['id' => 0, 'folder' => 'application', 'icon' => 'fa-file-pdf', 'name' => 'ARCHR-2026-000042_APP_v1.pdf',
                 'status' => 'verified', 'origin' => 'generated', 'meta' => 'v1 · Jul 28, 2026 · 241 KB', 'case_number' => 'ARCHR-2026-000042'],
                ['id' => 0, 'folder' => 'income', 'icon' => 'fa-file-image', 'name' => 'ARCHR-2026-000042_INC_PAYSTUB_20260801.pdf',
                 'status' => 'pending', 'origin' => 'uploaded', 'meta' => 'Aug 1, 2026 · 410 KB', 'case_number' => 'ARCHR-2026-000042'],
                ['id' => 0, 'folder' => 'property', 'icon' => 'fa-file-pdf', 'name' => 'ARCHR-2026-000042_PROP_20260802.pdf',
                 'status' => 'verified', 'origin' => 'generated', 'meta' => 'Aug 2, 2026 · 118 KB', 'case_number' => 'ARCHR-2026-000042'],
            ];
            $bucketTree = archr_doc_bucket_tree($sampleCases, $sampleDocs);
        }
        $bucketNode = archr_doc_bucket_at($bucketTree, $bucketPath);
        if ($bucketNode === null) {
            $bucketPath = '';
            $bucketNode = $bucketTree;
        }
    }
}

$pageTitles = [
    'dashboard' => 'Dashboard',
    'applications' => 'Applications',
    'documents' => 'Documents Bucket',
    'team' => 'Team',
    'messages' => 'Messages',
    'metrics' => 'Metrics',
    'help' => 'Help',
    // Consolidated Level 2 pages:
    'projects' => 'Active Projects',
    'schedule' => 'Schedule',
    'workflows' => 'Task Workflows',
    'unclaimed' => 'Unclaimed Jobs',
    'escalations' => 'Escalations',
    'funding' => 'Funding & Budgets',
    'reimbursements' => 'Reimbursements',
    'invoices' => 'Invoices',
    'marketplace' => 'Marketplace',
    'eligible-jobs' => 'Eligible Jobs',
    'review-queue' => 'Review Queue',
];

archr_render_portal_header([
    'role'            => 'org-admin',
    'role_label'      => 'Org Admin',
    'brand'           => 'ARCHR Org Admin',
    'page_title'      => $pageTitles[$page],
    'org'             => $primaryOrg['organization_name'] ?? null,
    'user_name'       => $fullName,
    'avatar_initials' => $initials,
    'badge_icon'      => 'fa-user-shield',
    'extra_head'      => '<link rel="stylesheet" href="assets/role-org-admin.css"><link rel="stylesheet" href="assets/case-documents.css">',
    'nav'             => $filteredNav,
]);

require __DIR__ . '/partials/org-admin-body.php';

archr_render_portal_footer();
