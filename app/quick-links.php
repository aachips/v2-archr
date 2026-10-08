<?php
declare(strict_types=1);

/* Super-Admin Quick Links page.
 * Curated external resources and internal shortcuts. */

require __DIR__ . '/lib/auth.php';
archr_require_auth();

require_once __DIR__ . '/lib/portal-layout.php';
require_once __DIR__ . '/lib/permissions.php';

$userId = (int)($_SESSION['archr_user_id'] ?? 0);
$pdo = archr_pdo();
$stmt = $pdo->prepare("
    SELECT 1 FROM user_role_assignments ura
    JOIN roles r ON r.id = ura.role_id
   WHERE ura.user_id = :uid AND r.role_code = 'SUPER_ADMIN' AND ura.is_active = true
   LIMIT 1
");
$stmt->execute([':uid' => $userId]);
if (!$stmt->fetch()) {
    http_response_code(403);
    echo 'Access denied.';
    exit;
}

/**
 * Quick link entry.
 *
 * @param string $href     URL (external or internal)
 * @param string $icon     FontAwesome icon class
 * @param string $label    Display text
 * @param string $desc     Short description shown below
 * @param string $category Group category (external, internal, census, etc.)
 * @param string $badge    Optional badge label (e.g., "County", "State")
 */
function ql(string $href, string $icon, string $label, string $desc, string $category = 'external', string $badge = ''): array {
    return ['href' => $href, 'icon' => $icon, 'label' => $label, 'desc' => $desc, 'category' => $category, 'badge' => $badge];
}

$links = [
    // ── AMI / Census Data ─────────────────────────────────────────
    ql('https://www.huduser.gov/portal/datasets/il.html',
        'fa-chart-line', 'HUD Income Limits (AMI by County)',
        'Official HUD/ Census AMI tables — updated annually. Select NC → Buncombe/Madison County.',
        'census', 'HUD'),

    ql('https://www.census.gov/programs-surveys/acs/data/acsdata.html',
        'fa-database', 'Census ACS Data (American Community Survey)',
        'Raw census data source. Used to derive AMI baselines for income eligibility.',
        'census', 'Census'),

    // ── GIS / Property Lookup ──────────────────────────────────────
    ql('https://gis.buncombecounty.org/',
        'fa-map', 'Buncombe County GIS — Property Card Lookup',
        'Search by address or parcel ID. View tax value, lot size, ownership, and property details.',
        'gis', 'Buncombe'),

    ql('https://prc-buncombe.spatialest.com/#/',
        'fa-magnifying-glass-location', 'Buncombe County Property Record Search',
        'Interactive property record search with detailed parcel data, ownership history, and valuation.',
        'gis', 'Buncombe'),

    ql('https://gis.madisoncountync.org/',
        'fa-map-location-dot', 'Madison County GIS — Property Records',
        'Property search for Madison County parcels. Tax assessment and ownership info.',
        'gis', 'Madison'),

    ql('https://www.madisonrod.net/',
        'fa-file-contract', 'Madison County Register of Deeds',
        'Official property records, deeds, liens, and legal documents for Madison County.',
        'gis', 'Madison'),

    ql('https://www.nc.gov/',
        'fa-landmark', 'NC State GIS / Land Records',
        'Statewide land and property record resources for North Carolina.',
        'gis', 'NC State'),

    // ── Internal Shortcuts ─────────────────────────────────────────
    ql('super-admin.php#organizations',
        'fa-building', 'Organization Eligibility Rules',
        'Manage eligibility presets for partner organizations.',
        'internal'),

    ql('super-admin.php#helpdesk-tickets',
        'fa-headset', 'Helpdesk Ticket Queue',
        'Review and resolve support tickets submitted via the chat widget.',
        'internal'),

    ql('audit-log.php',
        'fa-clock-rotate-left', 'Audit Log',
        'Full system audit trail of all user actions and data changes.',
        'internal'),
];

// Group by category
$groups = [];
foreach ($links as $l) {
    $groups[$l['category']][] = $l;
}

$categoryLabels = [
    'census' => '📊 AMI &amp; Census Data',
    'gis' => '🗺️ GIS Property Lookup',
    'internal' => '🏠 Internal Shortcuts',
];

$categoryColors = [
    'census' => '#eff6ff',
    'gis' => '#f0fdf4',
    'internal' => '#fefce8',
];

$categoryBorder = [
    'census' => '#bfdbfe',
    'gis' => '#bbf7d0',
    'internal' => '#fde047',
];

archr_render_portal_header([
    'role' => 'super-admin',
    'role_label' => 'Super Admin',
    'brand' => 'ARCHR Super Admin',
    'page_title' => 'Quick Links',
    'user_name' => $_SESSION['archr_user_name'] ?? '',
    'avatar_initials' => archr_initials_from_name($_SESSION['archr_user_name'] ?? ''),
    'badge_icon' => 'fa-link',
    'extra_head' => '<link rel="stylesheet" href="assets/role-super-admin.css">',
    'nav' => archr_super_admin_nav('quick-links'),
]);
?>
<style>
.ql-grid { display:grid; grid-template-columns:repeat(auto-fill, minmax(320px, 1fr)); gap:1rem; }
.ql-group { margin-bottom:1.5rem; }
.ql-group-title { font-size:0.95rem; font-weight:700; margin-bottom:0.75rem; padding:0.4rem 0.6rem; border-radius:6px; }
.ql-card { display:flex; gap:0.75rem; padding:0.85rem; border:1px solid #e5e7eb; border-radius:8px; background:#fff; text-decoration:none; color:inherit; transition:box-shadow 0.15s, border-color 0.15s; }
.ql-card:hover { box-shadow:0 2px 8px rgba(0,0,0,0.08); border-color:#93c5fd; }
.ql-card__icon { display:flex; align-items:center; justify-content:center; width:2.25rem; height:2.25rem; border-radius:8px; background:#f3f4f6; color:#374151; flex-shrink:0; }
.ql-card__icon i { font-size:1rem; }
.ql-card__body { flex:1; min-width:0; }
.ql-card__label { font-weight:600; font-size:0.9rem; margin-bottom:0.15rem; }
.ql-card__desc { font-size:0.8rem; color:#6b7280; line-height:1.4; }
.ql-card__badge { display:inline-block; padding:0.1rem 0.4rem; border-radius:999px; background:#f3f4f6; color:#374151; font-size:0.7rem; font-weight:600; margin-top:0.3rem; }
.ql-card__ext { font-size:0.7rem; color:#9ca3af; margin-left:0.35rem; }
</style>

<main class="page-wrap">
    <h1 style="font-size:1.25rem;margin-bottom:1rem;"><i class="fas fa-link" aria-hidden="true"></i> Quick Links</h1>
    <p class="muted" style="margin-bottom:1.5rem;font-size:0.9rem;">Curated resources for eligibility checks, property lookups, and internal shortcuts. Add new links as needed.</p>

    <?php foreach ($groups as $cat => $items): ?>
    <div class="ql-group">
        <div class="ql-group-title" style="background:<?= $categoryColors[$cat] ?? '#f9fafb' ?>;border-left:3px solid <?= $categoryBorder[$cat] ?? '#d1d5db' ?>;">
            <?= $categoryLabels[$cat] ?? ucfirst($cat) ?>
        </div>
        <div class="ql-grid">
            <?php foreach ($items as $l): ?>
            <a href="<?= e($l['href']) ?>" class="ql-card" target="_blank" rel="noopener noreferrer">
                <div class="ql-card__icon"><i class="fas <?= e($l['icon']) ?>" aria-hidden="true"></i></div>
                <div class="ql-card__body">
                    <div class="ql-card__label">
                        <?= e($l['label']) ?>
                        <?php if ($l['badge']): ?><span class="ql-card__badge"><?= e($l['badge']) ?></span><?php endif; ?>
                        <?php if (str_starts_with($l['href'], 'http')): ?><span class="ql-card__ext">↗ External</span><?php endif; ?>
                    </div>
                    <div class="ql-card__desc"><?= e($l['desc']) ?></div>
                </div>
            </a>
            <?php endforeach; ?>
        </div>
    </div>
    <?php endforeach; ?>
</main>
<?php
archr_render_portal_footer();
