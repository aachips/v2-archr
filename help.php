<?php declare(strict_types=1);
/**
 * ARCHR Support Library (Docs) — standalone public-facing viewer.
 *
 * Reads markdown files from documentation/start-here/ categories,
 * parses YAML frontmatter + markdown body, renders as HTML.
 * Public docs visible to all. Internal/SOP docs require active session.
 *
 * Usage: help.php (home) | help.php?doc=<slug> | help.php?action=search (JSON)
 */

require_once __DIR__ . '/app/lib/Parsedown.php';

// ---------------------------------------------------------------------------
// Session detection (same token verifier as index.php / component-library.php)
// ---------------------------------------------------------------------------

function docs_get_auth_secret(): string {
    $secret = getenv('AUTH_SECRET_KEY');
    if ($secret !== false && $secret !== '') return $secret;
    $envFile = __DIR__ . '/app/.env';
    if (file_exists($envFile)) {
        $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        foreach ($lines as $line) {
            $line = trim($line);
            if (strpos($line, '#') === 0) continue;
            if (preg_match('/^AUTH_SECRET_KEY\s*=\s*(.+)$/', $line, $m)) {
                return trim($m[1]);
            }
        }
    }
    return 'change-me-in-production';
}

function docs_base64url_decode(string $data): string {
    $remainder = strlen($data) % 4;
    if ($remainder) $data .= str_repeat('=', 4 - $remainder);
    return base64_decode($data);
}

function docs_verify_auth_token(string $token): ?array {
    $secret = docs_get_auth_secret();
    $parts  = explode('.', $token, 3);
    if (count($parts) !== 3) return null;
    [$headerB64, $bodyB64, $sigB64] = $parts;
    $expectedSig = rtrim(strtr(base64_encode(hash_hmac('sha256', "$headerB64.$bodyB64", $secret, true)), '+/', '-_'), '=');
    if (!hash_equals($expectedSig, $sigB64)) return null;
    $payload = json_decode(docs_base64url_decode($bodyB64), true);
    if (!$payload) return null;
    if (isset($payload['exp']) && time() > (int)$payload['exp']) return null;
    return $payload;
}

// Check for active session
$docsUser = null;
$cookie = $_COOKIE['archr_session'] ?? null;

// Debug
error_log("[help.php] Cookie present: " . ($cookie ? 'YES (len=' . strlen($cookie) . ')' : 'NO'));
error_log("[help.php] All cookies: " . json_encode($_COOKIE));

if ($cookie) {
    $payload = docs_verify_auth_token($cookie);
    if ($payload) {
        $docsUser = [
            'name' => $payload['full_name'] ?? 'User',
            'role' => $payload['role'] ?? 'viewer',
            'role_level' => (int)($payload['role_level'] ?? 0),
        ];
    }
}

require_once __DIR__ . '/app/lib/Parsedown.php';

define('DOCS_SOURCE_DIR', __DIR__ . '/documentation/start-here');
define('DOCS_CATEGORIES', [
    'start-here'       => ['name' => 'Start Here',                    'order' => 1],
    'archr101'         => ['name' => 'ARCHR 101',                     'order' => 2],
    'setting-up'       => ['name' => 'Setting Up',                    'order' => 3],
    'technical'        => ['name' => 'Technical Guides',              'order' => 4],
    'funding'          => ['name' => 'Funding & Costs',               'order' => 5],
    'sops'             => ['name' => 'Standard Operating Procedures', 'order' => 6],
    'v2-archr'         => ['name' => 'V2 Platform',                   'order' => 7],
]);

// --- Helpers ----------------------------------------------------------------

function e(string $s): string {
    return htmlspecialchars($s, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

function slugify(string $name): string {
    $slug = strtolower($name);
    $slug = preg_replace('/[^a-z0-9]+/', '-', $slug) ?? '';
    return trim($slug, '-');
}

function parse_frontmatter(string $content): ?array {
    $content = preg_replace('/^\xEF\xBB\xBF/', '', $content) ?? $content;
    if (!preg_match('/\A\s*\R?---[ \t]*\R(.*?)\R---[ \t]*\R?(.*)\z/s', $content, $m)) {
        return null;
    }
    $yaml = [];
    foreach (preg_split('/\r\n|\r|\n/', $m[1]) as $line) {
        if (preg_match('/^([a-z_]+):\s*(.+)$/', $line, $p)) {
            $yaml[trim($p[1])] = trim($p[2]);
        }
    }
    return ['yaml' => $yaml, 'body' => $m[2]];
}

function load_docs_index(?array $docsUser = null): array {
    $docs = [];

    // Also load root-level .md files as 'start-here' category
    $rootFiles = glob(DOCS_SOURCE_DIR . '/*.md');
    if ($rootFiles !== false) {
        foreach ($rootFiles as $file) {
            $content = file_get_contents($file);
            if ($content === false) continue;
            $parsed = parse_frontmatter($content);
            if ($parsed === null) continue;
            $title = $parsed['yaml']['document_name'] ?? $parsed['yaml']['title'] ?? pathinfo($file, PATHINFO_FILENAME);
            $shortName = $parsed['yaml']['short_name'] ?? null;
            $slug = $parsed['yaml']['slug'] ?? slugify($title);
            $visibility = $parsed['yaml']['visibility'] ?? 'public';
            // public: always visible. internal: only visible when logged in.
            if ($visibility === 'internal' && $docsUser === null) continue;
            if ($visibility !== 'public' && $visibility !== 'internal') continue;
            $docs[] = [
                'slug' => $slug,
                'title' => $title,
                'short_name' => $shortName,
                'category' => 'start-here',
                'category_name' => 'Start Here',
                'file' => $file,
                'order' => 1,
            ];
        }
    }

    foreach (DOCS_CATEGORIES as $catSlug => $cat) {
        $dir = DOCS_SOURCE_DIR . '/' . $catSlug;
        if (!is_dir($dir)) {
            continue;
        }
        $files = glob($dir . '/*.md');
        if ($files === false) {
            continue;
        }
        foreach ($files as $file) {
            $content = file_get_contents($file);
            if ($content === false) {
                continue;
            }
            $parsed = parse_frontmatter($content);
            if ($parsed === null) {
                continue;
            }
            $title = $parsed['yaml']['document_name'] ?? $parsed['yaml']['title'] ?? pathinfo($file, PATHINFO_FILENAME);
            $shortName = $parsed['yaml']['short_name'] ?? null;
            $slug = $parsed['yaml']['slug'] ?? slugify($title);
            // Skip docs marked as non-public
            $visibility = $parsed['yaml']['visibility'] ?? 'public';
            // public: always visible. internal: only visible when logged in.
            if ($visibility === 'internal' && $docsUser === null) continue;
            if ($visibility !== 'public' && $visibility !== 'internal') continue;
            $docs[] = [
                'slug' => $slug,
                'title' => $title,
                'short_name' => $shortName,
                'category' => $catSlug,
                'category_name' => $cat['name'],
                'file' => $file,
                'order' => $cat['order'],
            ];
        }
    }
    // Sort by category order, then title
    usort($docs, function ($a, $b) {
        if ($a['order'] !== $b['order']) {
            return $a['order'] <=> $b['order'];
        }
        return strcasecmp($a['title'], $b['title']);
    });
    return $docs;
}

function load_doc(string $slug, ?array $docsUser = null): ?array {
    $docs = load_docs_index($docsUser);
    foreach ($docs as $doc) {
        if ($doc['slug'] === $slug) {
            $content = file_get_contents($doc['file']);
            if ($content === false) {
                return null;
            }
            $parsed = parse_frontmatter($content);
            if ($parsed === null) {
                return null;
            }
            $pd = new Parsedown();
            $pd->setSafeMode(false);
            $html = $pd->text($parsed['body']);
            return [
                'slug' => $slug,
                'title' => $parsed['yaml']['document_name'] ?? $parsed['yaml']['title'] ?? $doc['title'],
                'short_name' => $doc['short_name'] ?? null,
                'category' => $doc['category'],
                'category_name' => $doc['category_name'],
                'html' => $html,
            ];
        }
    }
    return null;
}

function get_category_groups(array $docs): array {
    $groups = [];
    foreach ($docs as $doc) {
        $groups[$doc['category']][] = $doc;
    }
    return $groups;
}

// --- JSON search endpoint ---------------------------------------------------

if (($_GET['action'] ?? '') === 'search') {
    header('Content-Type: application/json; charset=utf-8');
    $docs = load_docs_index($docsUser);
    echo json_encode($docs, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

// --- Page render ------------------------------------------------------------

$docs = load_docs_index($docsUser);
$groups = get_category_groups($docs);
$slug = $_GET['doc'] ?? 'start-here';
$doc = load_doc($slug);
$title = $doc !== null ? $doc['title'] : 'Support Library';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= e($title) ?> — ARCHR Support Library</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&family=Open+Sans:wght@400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
    <link rel="icon" type="image/svg+xml" href="archr-logo.svg">
    <style>
        .docs-layout {
            display: flex;
            gap: 0;
            min-height: calc(100vh - 200px);
            max-width: 1400px;
            margin: 0 auto;
        }
        .docs-sidebar {
            width: 280px;
            flex-shrink: 0;
            background: var(--color-bg-secondary, #f7f9fc);
            border-right: 1px solid var(--color-border, #e0e0e0);
            padding: 20px 0;
            position: sticky;
            top: 64px;
            height: calc(100vh - 64px);
            overflow-y: auto;
        }
        .docs-sidebar-title {
            font-size: 1.1rem;
            font-weight: 700;
            padding: 0 20px 16px;
            border-bottom: 1px solid var(--color-border, #e0e0e0);
            margin-bottom: 12px;
        }
        .docs-sidebar-title a {
            color: var(--color-text, #222);
            text-decoration: none;
        }
        .docs-search-box {
            padding: 0 16px 16px;
        }
        .docs-search-box input {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid var(--color-border, #ccc);
            border-radius: 6px;
            font-size: 0.9rem;
            background: var(--color-surface, #fff);
            color: var(--color-text, #222);
        }
        .docs-nav-category {
            padding: 8px 20px 4px;
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: var(--color-text-secondary, #666);
        }
        .docs-nav-list {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        .docs-nav-list li a {
            display: block;
            padding: 6px 20px 6px 28px;
            color: var(--color-text, #333);
            text-decoration: none;
            font-size: 0.9rem;
            border-left: 3px solid transparent;
            transition: background 0.15s, border-color 0.15s;
        }
        .docs-nav-list li a:hover {
            background: var(--color-bg-secondary, #f0f4f8);
        }
        .docs-nav-list li a.active {
            border-left-color: var(--color-primary, #2166b7);
            background: var(--color-bg-secondary, #e8f0f8);
            font-weight: 600;
        }
        .docs-main {
            flex: 1;
            padding: 30px 40px;
            min-width: 0;
        }
        .docs-main h1 {
            font-size: 1.8rem;
            margin-bottom: 8px;
        }
        .docs-breadcrumb {
            font-size: 0.85rem;
            color: var(--color-text-secondary, #666);
            margin-bottom: 20px;
        }
        .docs-breadcrumb a {
            color: var(--color-primary, #2166b7);
            text-decoration: none;
        }
        .docs-content {
            line-height: 1.7;
        }
        .docs-content h2 { font-size: 1.4rem; margin-top: 32px; margin-bottom: 12px; }
        .docs-content h3 { font-size: 1.15rem; margin-top: 24px; margin-bottom: 8px; }
        .docs-content p { margin-bottom: 12px; }
        .docs-content ul, .docs-content ol { margin-bottom: 12px; padding-left: 24px; }
        .docs-content code {
            background: var(--color-bg-secondary, #f0f0f0);
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 0.9em;
        }
        .docs-content pre {
            background: #1e1e1e;
            color: #d4d4d4;
            padding: 16px;
            border-radius: 8px;
            overflow-x: auto;
            font-size: 0.9rem;
        }
        .docs-content pre code {
            background: none;
            padding: 0;
        }
        .docs-content table {
            border-collapse: collapse;
            width: 100%;
            margin: 16px 0;
        }
        .docs-content table th, .docs-content table td {
            border: 1px solid var(--color-border, #ddd);
            padding: 8px 12px;
            text-align: left;
        }
        .docs-content table th {
            background: var(--color-bg-secondary, #f5f5f5);
        }
        .docs-pager {
            display: flex;
            justify-content: space-between;
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid var(--color-border, #e0e0e0);
        }
        .docs-pager a {
            color: var(--color-primary, #2166b7);
            text-decoration: none;
            font-weight: 500;
        }
        .docs-pager a:hover { text-decoration: underline; }
        .docs-empty {
            padding: 40px;
            text-align: center;
            color: var(--color-text-secondary, #666);
        }

        [data-theme="dark"] .docs-sidebar {
            background: #111;
            border-color: #2a2a2a;
        }
        [data-theme="dark"] .docs-search-box input {
            background: #1a1a1a;
            border-color: #444;
            color: #eee;
        }
        [data-theme="dark"] .docs-nav-list li a { color: #ccc; }
        [data-theme="dark"] .docs-nav-list li a:hover { background: #1a1a2a; }
        [data-theme="dark"] .docs-nav-list li a.active {
            background: #1a2a3a;
            border-left-color: #4a90d9;
        }
        [data-theme="dark"] .docs-content pre { background: #0d0d0d; }
        [data-theme="dark"] .docs-content code { background: #2a2a2a; }

        @media (max-width: 768px) {
            .docs-layout { flex-direction: column; }
            .docs-sidebar {
                width: 100%;
                position: static;
                height: auto;
                border-right: none;
                border-bottom: 1px solid var(--color-border, #e0e0e0);
            }
            .docs-main { padding: 20px; }
        }
    </style>
    <script>(function(){try{var t=localStorage.getItem('archr-theme');if(t!=='light'&&t!=='dark'){t=window.matchMedia&&window.matchMedia('(prefers-color-scheme: dark)').matches?'dark':'light';}document.documentElement.setAttribute('data-theme',t);}catch(e){}})();</script>
</head>
<body>
    <header class="site-header">
        <div class="container header-container">
            <a href="./" class="logo-link">
                <img src="archr-logo.svg" alt="ARCHR Logo" class="site-logo">
                <div class="logo-text">
                    <h1>ARCHR</h1>
                    <p class="tagline">Asheville Regional Coalition for Home Repair</p>
                </div>
            </a>
            <nav class="main-nav">
                <ul class="nav-list">
                    <li><a href="./" class="nav-link"><i class="fas fa-home"></i> Home</a></li>
                    <li><a href="dashboard.html" class="nav-link">Impact Dashboard</a></li>
                    <li><a href="./help.php" class="nav-link active">Docs</a></li>
                    <?php if ($docsUser): ?>
                        <li>
                            <span style="font-size:0.8rem; color:rgba(255,255,255,0.7); display:flex; align-items:center; gap:6px;">
                                <i class="fas fa-user-check" style="color:#4ade80;"></i>
                                <?= e(explode(' ', $docsUser['name'])[0]) ?>
                                <a href="/portal/" style="color:rgba(255,255,255,0.8); text-decoration:none;">Dashboard</a>
                            </span>
                        </li>
                    <?php endif; ?>
                    <li>
                        <button type="button" class="theme-toggle" aria-label="Toggle dark mode" aria-pressed="false">
                            <i class="fas fa-moon icon-moon" aria-hidden="true"></i>
                            <i class="fas fa-sun icon-sun" aria-hidden="true"></i>
                        </button>
                    </li>
                </ul>
            </nav>
        </div>
    </header>

    <div class="container">
    <div class="docs-layout">
        <aside class="docs-sidebar">
            <div class="docs-sidebar-title"><a href="./help.php">ARCHR Support Library</a></div>
            <div class="docs-search-box">
                <input type="search" id="docs-search" placeholder="Search docs…" aria-label="Search documentation">
            </div>
            <?php foreach ($groups as $catSlug => $catDocs): ?>
                <div class="docs-nav-category"><?= e(DOCS_CATEGORIES[$catSlug]['name']) ?></div>
                <ul class="docs-nav-list">
                    <?php foreach ($catDocs as $d): ?>
                        <?php $displayTitle = $d['short_name'] ?? $d['title']; ?>
                        <li><a href="./help.php?doc=<?= e($d['slug']) ?>"<?= $d['slug'] === $slug ? ' class="active" aria-current="page"' : '' ?>><?= e($displayTitle) ?></a></li>
                    <?php endforeach; ?>
                </ul>
            <?php endforeach; ?>
        </aside>

        <main class="docs-main">
            <?php if ($doc === null): ?>
                <div class="docs-empty">
                    <h1>Page Not Found</h1>
                    <p>No documentation exists for the requested page.</p>
                    <p><a href="./help.php">Back to Support Library</a></p>
                </div>
            <?php else: ?>
                <div class="docs-breadcrumb"><a href="./help.php">Support Library</a> &rsaquo; <?= e($doc['category_name']) ?></div>
                <h1><?= e($doc['title']) ?></h1>
                <div class="docs-content"><?= $doc['html'] ?></div>
                <?php
                // Prev/next navigation
                $flatDocs = [];
                foreach ($groups as $catDocs) {
                    foreach ($catDocs as $d) {
                        $flatDocs[] = $d;
                    }
                }
                $pos = null;
                foreach ($flatDocs as $i => $d) {
                    if ($d['slug'] === $slug) {
                        $pos = $i;
                        break;
                    }
                }
                $prevDoc = ($pos !== null && $pos > 0) ? $flatDocs[$pos - 1] : null;
                $nextDoc = ($pos !== null && $pos < count($flatDocs) - 1) ? $flatDocs[$pos + 1] : null;
                ?>
                <nav class="docs-pager">
                    <span>
                        <?php if ($prevDoc): ?>
                            <?php $prevTitle = $prevDoc['short_name'] ?? $prevDoc['title']; ?>
                            <a href="./help.php?doc=<?= e($prevDoc['slug']) ?>">&larr; <?= e($prevTitle) ?></a>
                        <?php endif; ?>
                    </span>
                    <span>
                        <?php if ($nextDoc): ?>
                            <?php $nextTitle = $nextDoc['short_name'] ?? $nextDoc['title']; ?>
                            <a href="./help.php?doc=<?= e($nextDoc['slug']) ?>"><?= e($nextTitle) ?> &rarr;</a>
                        <?php endif; ?>
                    </span>
                </nav>
            <?php endif; ?>
        </main>
    </div>

    <footer class="site-footer">
        <div class="container">
            <p><strong>ARCHR</strong> – A centralized intake system for home repair assistance in WNC.</p>
            <p class="footer-contact">Need help? Contact the ARCHR Coordinator at <a href="mailto:coordinator@archr.example.org">coordinator@archr.example.org</a> or (828) 555-0123.</p>
            <p class="footer-note"><small>&copy; 2026 ARCHR Coalition. | <a href="privacy.html">Privacy Policy</a></small></p>
        </div>
    </footer>

    <script src="js/script.js"></script>
    <script>
        // Live search filter
        (function() {
            const input = document.getElementById('docs-search');
            if (!input) return;
            const links = document.querySelectorAll('.docs-nav-list li');
            input.addEventListener('input', function() {
                const q = this.value.toLowerCase();
                links.forEach(function(li) {
                    const a = li.querySelector('a');
                    if (!a) return;
                    li.style.display = a.textContent.toLowerCase().includes(q) ? '' : 'none';
                });
            });
        })();
    </script>
</body>
</html>
