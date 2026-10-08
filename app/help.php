<?php declare(strict_types=1);
/**
 * ARCHR Help & Documentation Library viewer.
 *
 * Renders generated documentation (see app/generate-help-docs.php) with a
 * Read-the-Docs-style layout: sidebar category tree, search, content pane.
 * Public docs are visible without login; other docs follow their visibility
 * (authenticated / specific roles) from the generated manifest.
 *
 * URLs: help.php (default doc) | help.php?doc=<slug> | help.php?action=search-index (JSON)
 */

require_once __DIR__ . '/lib/layout.php';
require_once __DIR__ . '/lib/doc-library.php';

archr_session_start();
$role = $_SESSION['archr_role'] ?? null;
$config = doc_library_config();

// JSON search index, filtered server-side by the viewer's role.
if (($_GET['action'] ?? '') === 'search-index') {
    header('Content-Type: application/json; charset=utf-8');
    $manifest = doc_library_load_manifest();
    $visible = [];
    if ($manifest !== null) {
        foreach (doc_library_search_index() as $entry) {
            $info = $manifest['docs'][$entry['slug']] ?? null;
            if ($info !== null && doc_library_can_view($info, $role)) {
                $visible[] = $entry;
            }
        }
    }
    echo json_encode($visible, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

$manifest = doc_library_load_manifest();
$defaultDoc = $config['default_doc'];
$slug = $_GET['doc'] ?? $defaultDoc;
if (!is_string($slug) || $slug === '') {
    $slug = $defaultDoc;
}

$doc = $manifest !== null ? doc_library_load_doc($slug) : null;
$status = 'ok';
if ($manifest === null) {
    $status = 'not-generated';
} elseif ($doc === null) {
    $status = 'not-found';
} elseif (!doc_library_can_view($doc, $role)) {
    $status = 'forbidden';
}

// Sidebar + prev/next: only docs the current viewer may see.
$visibleSlugs = [];
if ($manifest !== null) {
    foreach ($manifest['categories'] as $catSlug => $cat) {
        foreach ($cat['docs'] as $entry) {
            $info = $manifest['docs'][$entry['slug']] ?? null;
            if ($info !== null && doc_library_can_view($info, $role)) {
                $visibleSlugs[] = $entry['slug'];
            }
        }
    }
}
$prevDoc = $nextDoc = null;
$pos = array_search($slug, $visibleSlugs, true);
if ($pos !== false) {
    $prevDoc = $visibleSlugs[$pos - 1] ?? null;
    $nextDoc = $visibleSlugs[$pos + 1] ?? null;
}

$pageTitle = $doc !== null ? $doc['title'] : 'Help & Documentation';
archr_render_header($pageTitle, 'help');
?>
<link rel="stylesheet" href="assets/help.css">
<div class="help-layout">
    <aside class="help-sidebar" aria-label="Documentation navigation">
        <div class="help-sidebar-brand">
            <a href="help.php">ARCHR Help Center</a>
        </div>
        <div class="help-search">
            <input type="search" id="help-search-input" placeholder="Search docs…" aria-label="Search documentation" autocomplete="off">
            <ul id="help-search-results" class="help-search-results" hidden></ul>
        </div>
        <nav class="help-nav">
            <?php if ($manifest !== null): ?>
                <?php foreach ($manifest['categories'] as $catSlug => $cat): ?>
                    <?php
                    $docs = array_filter($cat['docs'], function ($entry) use ($manifest, $role) {
                        $info = $manifest['docs'][$entry['slug']] ?? null;
                        return $info !== null && doc_library_can_view($info, $role);
                    });
                    if (empty($docs)) {
                        continue;
                    }
                    // Check if current doc is in this category (auto-expand it)
                    $isActiveCategory = ($slug === $defaultDoc && $catSlug === 'start-here') ||
                        (array_filter($docs, fn($d) => $d['slug'] === $slug) !== []);
                    ?>
                    <div class="help-nav-category<?= $isActiveCategory ? '' : ' collapsed' ?>"
                         data-category="<?= e($catSlug) ?>">
                        <span><?= e($cat['name']) ?></span>
                        <span class="help-nav-count"><?= count($docs) ?></span>
                    </div>
                    <div class="help-nav-section<?= $isActiveCategory ? '' : ' collapsed' ?>"
                         data-category="<?= e($catSlug) ?>">
                        <ul>
                            <?php foreach ($docs as $entry): ?>
                                <?php
                                $displayTitle = $entry['title'];
                                // Shorten long titles for sidebar display
                                $shortTitle = $displayTitle;
                                $titleAttr = '';
                                if (strlen($displayTitle) > 50) {
                                    // Try to shorten: use part before em-dash or colon
                                    if (preg_match('/^(.+?)\s*[—–:-]\s*(.+)$/', $displayTitle, $m)) {
                                        $shortTitle = trim($m[1]);
                                        if (strlen($shortTitle) > 50) {
                                            $shortTitle = mb_substr($shortTitle, 0, 47) . '…';
                                        }
                                    } else {
                                        $shortTitle = mb_substr($displayTitle, 0, 47) . '…';
                                    }
                                    $titleAttr = $displayTitle;
                                }
                                ?>
                                <li>
                                    <a href="help.php?doc=<?= e($entry['slug']) ?>"
                                       class="<?= $entry['slug'] === $slug ? 'active' : '' ?>"
                                       <?= $entry['slug'] === $slug ? 'aria-current="page"' : '' ?>
                                       <?= $titleAttr !== '' ? 'title="' . e($titleAttr) . '"' : '' ?>>
                                        <?= e($shortTitle) ?>
                                    </a>
                                </li>
                            <?php endforeach; ?>
                        </ul>
                    </div>
                <?php endforeach; ?>
            <?php endif; ?>
        </nav>
    </aside>
    <main class="help-main">
        <?php if ($status === 'not-generated'): ?>
            <h1>Help &amp; Documentation</h1>
            <p>The documentation library has not been generated yet.</p>
            <p>Run <code>php app/generate-help-docs.php</code> from the repository root, or open
               <code>generate-help-docs.php</code> while logged in as an admin.</p>
        <?php elseif ($status === 'not-found'): ?>
            <h1>Document not found</h1>
            <p>No documentation page exists for <code><?= e($slug) ?></code>.</p>
            <p><a href="help.php">Back to the Help Center home</a></p>
        <?php elseif ($status === 'forbidden'): ?>
            <h1>Restricted document</h1>
            <?php if ($role === null): ?>
                <p>This documentation is only available to signed-in platform users.</p>
                <p><a href="login.php">Log in</a> to continue.</p>
            <?php else: ?>
                <p>Your role (<?= e($_SESSION['archr_role_display'] ?? $role) ?>) does not have access to this document.</p>
                <p><a href="help.php">Back to the Help Center home</a></p>
            <?php endif; ?>
        <?php else: ?>
            <div class="help-breadcrumb">
                <a href="help.php">Help Center</a> &rsaquo; <?= e($doc['category_name']) ?>
            </div>
            <h1><?= e($doc['title']) ?></h1>
            <div class="help-meta">
                <?php if (!empty($doc['meta']['last_updated'])): ?>
                    <span>Updated <?= e((string) $doc['meta']['last_updated']) ?></span>
                <?php endif; ?>
                <?php if (!empty($doc['meta']['estimated_reading_minutes'])): ?>
                    <span><?= e((string) $doc['meta']['estimated_reading_minutes']) ?> read</span>
                <?php endif; ?>
                <?php if ($doc['visibility'] !== 'public'): ?>
                    <span class="help-meta-restricted"><i class="fa-solid fa-lock"></i> Restricted</span>
                <?php endif; ?>
            </div>
            <article class="help-content">
                <?= $doc['html'] ?>
            </article>
            <nav class="help-pager" aria-label="More documentation">
                <?php if ($prevDoc !== null): ?>
                    <a class="help-prev" href="help.php?doc=<?= e($prevDoc) ?>">&larr; <?= e($manifest['docs'][$prevDoc]['title']) ?></a>
                <?php else: ?><span></span><?php endif; ?>
                <?php if ($nextDoc !== null): ?>
                    <a class="help-next" href="help.php?doc=<?= e($nextDoc) ?>"><?= e($manifest['docs'][$nextDoc]['title']) ?> &rarr;</a>
                <?php endif; ?>
            </nav>
        <?php endif; ?>
    </main>
</div>
<script src="assets/help.js" defer></script>
<?php
archr_render_footer();
