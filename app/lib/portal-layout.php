<?php
declare(strict_types=1);

/* Shared scaffolding for the role-portal pages (assessor, bursar, crew-lead,
   crew-member, envoy, org-admin, project-manager, requestor-portal,
   subcontractor, volunteer, tle-poc). The simpler site-chrome lives in
   layout.php; this helper renders the sidebar + topbar + theme-toggle that
   every role dashboard shares. */

require_once __DIR__ . '/layout.php';
require_once __DIR__ . '/language-translations.php';
require_once __DIR__ . '/auth.php';

/**
 * The canonical Org Admin side menu (single source — the org portal,
 * case search, and case review all render this set).
 * $active marks the current entry: 'dashboard', 'applications',
 * 'case-search', 'documents', 'team', 'metrics', 'quick-task', 'help'.
 */
function archr_org_admin_nav(string $active = ''): array {
    return [
        ['href' => 'org-admin.php?page=dashboard',    'icon' => 'fa-gauge-high',       'label' => 'Overview',         'active' => $active === 'dashboard'],
        ['href' => 'org-admin.php?page=applications', 'icon' => 'fa-file-lines',       'label' => 'Applications',     'active' => $active === 'applications'],
        ['href' => 'case-search.php',                 'icon' => 'fa-magnifying-glass', 'label' => 'Case Search',      'active' => $active === 'case-search'],
        ['href' => 'org-admin.php?page=documents',    'icon' => 'fa-bucket',           'label' => 'Documents Bucket', 'active' => $active === 'documents'],
        ['href' => 'org-admin.php?page=team',         'icon' => 'fa-users',            'label' => 'Team Accounts',    'active' => $active === 'team'],
        ['href' => 'org-admin.php?page=metrics',      'icon' => 'fa-chart-line',       'label' => 'Metrics',          'active' => $active === 'metrics'],
        ['href' => 'org-admin.php?page=quick-task',   'icon' => 'fa-list-check',       'label' => 'Quick Task',       'active' => $active === 'quick-task'],
        ['href' => 'help.php',                        'icon' => 'fa-circle-question',  'label' => 'Help',             'active' => $active === 'help'],
    ];
}

/**
 * Super Admin menu items (the system portal's own sections). Anchored to the
 * portal page; when rendered on another page the links carry the fragment so
 * they still land sensibly.
 */
function archr_super_admin_nav(string $active = '', bool $onPortalPage = true): array {
    $base = $onPortalPage ? '' : 'super-admin.php';
    return [
        ['href' => $base . '#dashboard',  'icon' => 'fa-gauge-high',               'label' => 'System Dashboard',  'active' => $active === 'dashboard'],
        ['href' => $base . '#organizations', 'icon' => 'fa-building',              'label' => 'Organizations',     'active' => $active === 'organizations'],
        ['href' => $base . '#users',      'icon' => 'fa-users',                    'label' => 'User Management',   'active' => $active === 'users'],
        ['href' => $base . '#onboarding', 'icon' => 'fa-person-walking-arrow-right', 'label' => 'Onboarding Queue', 'active' => $active === 'onboarding'],
        ['href' => $base . '#helpdesk-tickets', 'icon' => 'fa-headset',                 'label' => 'Helpdesk Tickets',  'active' => $active === 'helpdesk'],
        ['href' => 'quick-links.php',           'icon' => 'fa-link',                    'label' => 'Quick Links',       'active' => $active === 'quick-links'],
        ['href' => 'audit-log.php',      'icon' => 'fa-clock-rotate-left',        'label' => 'Audit Log',         'active' => $active === 'audit'],
    ];
}

/**
 * Shared nav for case-related pages (case-search, case, case-documents).
 * Always shows the same items regardless of which case page you're on.
 */
function archr_case_nav(string $active = ''): array {
    return [
        ['href' => 'dashboard.php',              'icon' => 'fa-gauge-high',       'label' => 'Dashboard',     'active' => $active === 'dashboard'],
        ['href' => 'case-search.php',            'icon' => 'fa-magnifying-glass', 'label' => 'Case Search',   'active' => $active === 'case-search'],
        ['href' => 'org-admin.php?page=dashboard','icon' => 'fa-folder-open',    'label' => 'Case Review',   'active' => $active === 'case'],
        ['href' => 'org-admin.php?page=documents','icon' => 'fa-bucket',         'label' => 'Documents',     'active' => $active === 'case-documents'],
        ['href' => 'help.php',                   'icon' => 'fa-circle-question', 'label' => 'Help',          'active' => $active === 'help'],
    ];
}

/**
 * Render the <head>, sidebar, and topbar for a role-portal page.
 *
 * @param array{
 *   role:string,          // slug, drives <body class="role-{slug}">
 *   role_label:string,    // human label shown in the badge
 *   brand:string,         // "ARCHR Assessor", etc.
 *   page_title:string,    // <h1> in the topbar
 *   org:?string,          // optional organization name in the badge
 *   user_name:?string,    // optional logged-in user name (avatar tooltip)
 *   avatar_initials:?string,
 *   badge_icon:?string,   // FA icon class (e.g. "fa-tape")
 *   nav:array,            // [['href','icon','label','active'?bool], ...]
 *   extra_css:?string,    // optional <style>...</style> block injected in <head>
 *   extra_head:?string,   // optional raw HTML appended in <head>
 * } $opts
 */
function archr_render_portal_header(array $opts): void {
    $role        = (string)($opts['role'] ?? 'generic');
    $roleLabel   = (string)($opts['role_label'] ?? ucfirst($role));
    $brand       = (string)'ARCHR';
    $pageTitle   = (string)($opts['page_title'] ?? $brand);
    $org         = $opts['org'] ?? null;
    $userName    = $opts['user_name'] ?? null;
    $initials    = (string)($opts['avatar_initials'] ?? archr_initials_from_name((string)$userName));
    $badgeIcon   = (string)($opts['badge_icon'] ?? 'fa-user');
    $nav         = (array)($opts['nav'] ?? []);
    $extraCss    = (string)($opts['extra_css'] ?? '');
    $extraHead   = (string)($opts['extra_head'] ?? '');
    $currentLang = archr_current_language();

    // Build role switcher links based on the user's permission level.
    // Consolidated admin roles (bursar, project-manager, envoy, crew-lead)
    // are removed from the dropdown — they're accessed via the org-admin
    // page's top navigation bar.
    // TLE-POC is excluded (it's a page, not a role).
    $consolidatedRoles = ['bursar', 'project-manager', 'envoy', 'crew-lead'];
    $allRoles = [
        'super-admin'    => ['icon' => 'fa-shield-halved',       'label' => archr_translate('roles.super_admin')],
        'org-admin'      => ['icon' => 'fa-user-shield',         'label' => archr_translate('roles.org_admin')],
        'assessor'       => ['icon' => 'fa-tape',                'label' => archr_translate('roles.assessor')],
        'crew-member'    => ['icon' => 'fa-user-hard-hat',       'label' => archr_translate('roles.crew_member')],
        'subcontractor'  => ['icon' => 'fa-hard-hat',            'label' => archr_translate('roles.subcontractor')],
        'volunteer'      => ['icon' => 'fa-hand-holding-heart',  'label' => archr_translate('roles.volunteer')],
        'requestor'      => ['icon' => 'fa-house-chimney-medical', 'label' => archr_translate('roles.requestor')],
    ];
    $currentLevel = archr_current_permission_level();
    $roleSwitcherLinks = [];
    foreach ($allRoles as $roleCode => $roleInfo) {
        $roleLevel = archr_get_permission_level($roleCode);
        if ($roleLevel <= $currentLevel && !in_array($roleCode, $consolidatedRoles, true)) {
            $roleSwitcherLinks[] = [
                'href' => $roleCode . '.php',
                'icon' => $roleInfo['icon'],
                'label' => $roleInfo['label'],
            ];
        }
    }
    $badgeText   = $org ? ($org . ' · ' . $roleLabel) : $roleLabel;

    // Consolidated admin role bar — shown for Level 2+ users on ANY role page.
    $consolidatedRoleLinks = [
        ['href' => 'org-admin.php',       'icon' => 'fa-user-shield',     'label' => 'Org Admin'],
        ['href' => 'bursar.php',          'icon' => 'fa-coins',           'label' => 'Bursar'],
        ['href' => 'project-manager.php', 'icon' => 'fa-diagram-project', 'label' => 'Project Manager'],
        ['href' => 'envoy.php',           'icon' => 'fa-handshake',       'label' => 'Envoy'],
        ['href' => 'crew-lead.php',       'icon' => 'fa-helmet-safety',   'label' => 'Crew Lead'],
    ];
    $showConsolidatedBar = $currentLevel >= 2;
    ?>
    <!DOCTYPE html>
    <html lang="<?= e($currentLang) ?>">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title><?= e($pageTitle) ?> &middot; ARCHR</title>
        <link rel="icon" type="image/svg+xml" href="assets/archr-logo.svg">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&family=Open+Sans:wght@400;600&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="assets/portal.css">
        <script>(function(){try{var t=localStorage.getItem('archr-theme');if(t!=='light'&&t!=='dark'){t=window.matchMedia&&window.matchMedia('(prefers-color-scheme: dark)').matches?'dark':'light';}document.documentElement.setAttribute('data-theme',t);}catch(e){}})();</script>
        <?= $extraHead /* trusted: pages pass their own snippet */ ?>
        <?php if ($extraCss !== ''): ?><style><?= $extraCss ?></style><?php endif; ?>
    </head>
    <body class="role-<?= e($role) ?>">
    <?php if ($showConsolidatedBar): ?>
    <div style="display:flex;gap:6px;padding:6px 16px;background:#f0f4f2;border-bottom:1px solid #ddd;font-family:system-ui,sans-serif;align-items:center;">
        <label style="font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.06em;color:#888;margin-right:4px;">Admin:</label>
        <?php foreach ($consolidatedRoleLinks as $crl): ?>
            <a href="<?= e($crl['href']) ?>" style="padding:3px 10px;font-size:11px;border:1px solid <?= $role === str_replace('.php','',$crl['href']) || ($role === 'org-admin' && $crl['href'] === 'org-admin.php') ? '#1c7a5c' : '#ccc' ?>;border-radius:3px;background:<?= $role === str_replace('.php','',$crl['href']) || ($role === 'org-admin' && $crl['href'] === 'org-admin.php') ? '#1c7a5c' : '#fff' ?>;color:<?= $role === str_replace('.php','',$crl['href']) || ($role === 'org-admin' && $crl['href'] === 'org-admin.php') ? '#fff' : '#333' ?>;text-decoration:none;"><?= e($crl['label']) ?></a>
        <?php endforeach; ?>
    </div>
    <?php endif; ?>
    <div class="portal-app">
        <aside class="portal-sidebar" id="portalSidebar" aria-label="Portal navigation">
            <div class="portal-sidebar-header">
                <a href="dashboard.php" class="portal-brand">
                    <img src="assets/archr-logo.svg" alt="" class="portal-brand-mark" style="height:24px;">
                    <span><?= e($brand) ?></span>
                </a>
                <button type="button" class="portal-sidebar-close" id="portalSidebarClose" aria-label="<?= e(archr_translate('sidebar.close_menu')) ?>">
                    <i class="fas fa-xmark" aria-hidden="true"></i>
                </button>
            </div>
            <nav class="portal-nav">
                <?php
                /* Nav items may include separators of the form ['group' => 'Label']
                   to start a new visually grouped <ul>. */
                $openList = false;
                foreach ($nav as $item):
                    if (isset($item['group'])):
                        if ($openList) { echo "</ul>\n"; }
                        ?><div class="portal-nav-group-label"><?= e((string)$item['group']) ?></div><ul><?php
                        $openList = true;
                        continue;
                    endif;
                    if (!$openList) { echo "<ul>\n"; $openList = true; }
                    $href   = (string)($item['href'] ?? '#');
                    $icon   = (string)($item['icon'] ?? 'fa-circle');
                    $label  = (string)($item['label'] ?? '');
                    $active = !empty($item['active']);
                    ?>
                    <li><a href="<?= e($href) ?>" class="portal-nav-link<?= $active ? ' active' : '' ?>">
                        <i class="fas <?= e($icon) ?>" aria-hidden="true"></i><span><?= e($label) ?></span>
                    </a></li>
                <?php endforeach; if ($openList) { echo "</ul>\n"; } ?>
            </nav>
        </aside>

        <div class="portal-main">
            <header class="portal-topbar">
                <div class="portal-topbar-left">
                    <button type="button" class="portal-mobile-toggle" id="portalMobileToggle"
                            aria-label="<?= e(archr_translate('sidebar.open_menu')) ?>" aria-controls="portalSidebar" aria-expanded="false">
                        <i class="fas fa-bars" aria-hidden="true"></i>
                    </button>
                    <?php if (($_SESSION['archr_role'] ?? '') !== 'requestor'): ?>
                        <form class="topbar-search" method="get" action="case-search.php" role="search" aria-label="<?= e(archr_translate('topbar.quick_search_aria')) ?>">
                            <i class="fas fa-magnifying-glass" aria-hidden="true"></i>
                            <input type="search" name="q" id="topbar-search-input"
                                   placeholder="<?= e(archr_translate('topbar.search_placeholder')) ?>"
                                   aria-label="<?= e(archr_translate('topbar.search_placeholder')) ?>"
                                   autocomplete="off">
                            <button type="submit" class="topbar-search-btn"><?= e(archr_translate('common.search')) ?></button>
                        </form>
                        
                    <?php endif; ?>
                </div>
                <div class="portal-topbar-right">
                    <a href="index.php?public=1" class="btn small secondary">
                        <i class="fas fa-house" aria-hidden="true"></i> <?= e(archr_translate('topbar.website')) ?>
                    </a>
                    <div class="role-switcher" id="roleSwitcher">
                        <button type="button" class="role-badge" aria-haspopup="true" aria-expanded="false">
                            <i class="fas <?= e($badgeIcon) ?>" aria-hidden="true"></i>
                            <span><?= e($badgeText) ?></span>
                            <i class="fas fa-chevron-down" aria-hidden="true"></i>
                        </button>
                        <ul class="role-switcher-menu" role="menu" hidden>
                            <li class="role-switcher-label"><?= e(archr_translate('topbar.view_as')) ?></li>
                            <?php foreach ($roleSwitcherLinks as $link): ?>
                                <li><a href="<?= e($link['href']) ?>" role="menuitem" class="role-switcher-item">
                                    <i class="fas <?= e($link['icon']) ?>" aria-hidden="true"></i>
                                    <span><?= e($link['label']) ?></span>
                                </a></li>
                            <?php endforeach; ?>
                        </ul>
                    </div>
                    <button type="button" class="theme-toggle" id="themeToggle" aria-label="<?= e(archr_translate('topbar.toggle_theme')) ?>">
                        <i class="fas fa-circle-half-stroke" aria-hidden="true"></i>
                    </button>

                    <!-- Language switcher: a menu of links carrying ?lang= so the
                         server re-renders in the chosen language (remembered in
                         the session by lib/language-translations.php). -->
                    <div class="lang-switcher" id="langSwitcher">
                        <button type="button" class="lang-toggle" aria-haspopup="true" aria-expanded="false"
                                aria-label="<?= e(archr_translate('topbar.language_menu')) ?>">
                            <i class="fas fa-globe" aria-hidden="true"></i>
                        </button>
                        <ul class="lang-switcher-menu" role="menu" hidden>
                            <li class="lang-switcher-label"><?= e(archr_translate('topbar.language')) ?></li>
                            <?php foreach (ARCHR_LANGUAGES as $langCode => $langName): ?>
                                <li><a href="<?= e(archr_language_url($langCode)) ?>" role="menuitem"
                                       class="lang-switcher-item<?= $langCode === $currentLang ? ' active' : '' ?>">
                                    <span><?= e($langName) ?></span>
                                    <?php if ($langCode === $currentLang): ?>
                                        <i class="fas fa-check" aria-hidden="true"></i>
                                    <?php endif; ?>
                                </a></li>
                            <?php endforeach; ?>
                        </ul>
                    </div>

                    <!-- Account menu: avatar button opens Profile Settings / Log-Out. -->
                    <div class="avatar-dropdown" id="avatarDropdown">
                        <button type="button" class="avatar-dropdown-toggle" aria-haspopup="true" aria-expanded="false"
                                aria-label="<?= e($userName !== null && $userName !== '' ? (string)$userName : archr_translate('topbar.account_menu')) ?>">
                            <span class="portal-avatar" aria-hidden="true"><?= e($initials) ?></span>
                        </button>
                        <ul class="avatar-dropdown-menu" role="menu" hidden>
                            <li><a href="profile.php" role="menuitem" class="avatar-dropdown-item">
                                <i class="fas fa-user" aria-hidden="true"></i>
                                <span><?= e(archr_translate('topbar.profile_settings')) ?></span>
                            </a></li>
                            <li><a href="logout.php" role="menuitem" class="avatar-dropdown-item">
                                <i class="fas fa-sign-out-alt" aria-hidden="true"></i>
                                <span><?= e(archr_translate('topbar.log_out')) ?></span>
                            </a></li>
                        </ul>
                    </div>
                </div>
            </header>
            <div class="portal-content">
    <?php
}

function archr_render_portal_footer(): void {
    ?>
            </div><!-- /.portal-content -->
        </div><!-- /.portal-main -->
    </div><!-- /.portal-app -->
    <script src="assets/portal.js" defer></script>
    </body>
    </html>
    <?php
}

function archr_initials_from_name(string $name): string {
    $name = trim($name);
    if ($name === '') return '··';
    $parts = preg_split('/\s+/', $name) ?: [];
    $first = $parts[0] ?? '';
    $last  = count($parts) > 1 ? $parts[count($parts) - 1] : '';
    $ini = strtoupper(mb_substr($first, 0, 1) . mb_substr($last, 0, 1));
    return $ini !== '' ? $ini : '··';
}
