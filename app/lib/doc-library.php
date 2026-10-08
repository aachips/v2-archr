<?php declare(strict_types=1);
/**
 * ARCHR Help Documentation Library — scanner, frontmatter parser, and PHP generator.
 *
 * Reads markdown from documentation/start-here/ (never modifies originals),
 * includes only files with YAML frontmatter between --- markers at the top,
 * and generates static .php content files + a manifest + a search index
 * into app/help-content/ for the viewer in app/help.php.
 */

require_once __DIR__ . '/Parsedown.php';

/**
 * Library configuration: categories come from start-here subfolder names.
 * visibility: 'public' | 'authenticated' | array of role codes.
 */
function doc_library_config(): array {
    return [
        'source_dir' => realpath(__DIR__ . '/../../documentation/start-here'),
        'output_dir' => __DIR__ . '/../help-content',
        'categories' => [
            'start-here'       => ['name' => 'Start Here',                    'visibility' => 'public',                    'order' => 1],
            'archr101'         => ['name' => 'ARCHR 101',                     'visibility' => 'public',                    'order' => 2],
            'setting-up'       => ['name' => 'Setting Up',                    'visibility' => 'public',                    'order' => 3],
            'technical'        => ['name' => 'Technical Guides',              'visibility' => 'public',                    'order' => 4],
            'sops'             => ['name' => 'Standard Operating Procedures', 'visibility' => 'authenticated',             'order' => 5],
            'roles'            => ['name' => 'Roles & Access',                'visibility' => 'authenticated',             'order' => 6],
            'funding'          => ['name' => 'Funding & Costs',               'visibility' => 'public',                    'order' => 7],
            'platform-anatomy' => ['name' => 'Platform Anatomy',              'visibility' => ['admin', 'super-admin'],    'order' => 8],
            'developers'       => ['name' => 'For Developers',                'visibility' => ['admin', 'super-admin'],    'order' => 9],
            'feedback-meeting' => ['name' => 'Coalition Feedback & Insights', 'visibility' => 'authenticated',             'order' => 10],
        ],
        // Per-document visibility overrides, keyed by document slug.
        'file_visibility' => [],
        'default_doc' => 'start-here',
    ];
}

/** Convert a filename or title into a URL slug. */
function doc_library_slugify(string $name): string {
    $slug = strtolower($name);
    $slug = preg_replace('/[^a-z0-9]+/', '-', $slug) ?? '';
    return trim($slug, '-');
}

/**
 * Split YAML frontmatter from markdown body.
 * Returns ['raw' => string, 'body' => string] or null when there is no
 * --- ... --- block at the top of the file (leading blank lines tolerated).
 */
function doc_library_split_frontmatter(string $content): ?array {
    $content = preg_replace('/^\xEF\xBB\xBF/', '', $content) ?? $content; // strip BOM
    if (!preg_match('/\A\s*\R?---[ \t]*\R(.*?)\R---[ \t]*\R?(.*)\z/s', $content, $m)) {
        return null;
    }
    return ['raw' => $m[1], 'body' => $m[2]];
}

/**
 * Parse the simple YAML subset used in these docs:
 *   key: value
 *   key: [a, b, c]
 *   key: "quoted value" / 'quoted value'
 */
function doc_library_parse_frontmatter(string $raw): array {
    $meta = [];
    foreach (preg_split('/\R/', $raw) as $line) {
        if (!preg_match('/^\s*([A-Za-z0-9_]+)\s*:\s*(.*)$/', $line, $m)) {
            continue; // ignore list items, comments, nested blocks
        }
        $key = $m[1];
        $value = trim($m[2]);
        if (strlen($value) >= 2 && $value[0] === '[' && substr($value, -1) === ']') {
            $items = array_map(function ($item) {
                return trim($item, " \t\"'");
            }, explode(',', substr($value, 1, -1)));
            $meta[$key] = array_values(array_filter($items, fn($i) => $i !== ''));
        } else {
            $meta[$key] = trim($value, "\"'");
        }
    }
    return $meta;
}

/** Recursively list .md files under the source directory. */
function doc_library_scan(string $sourceDir): array {
    $files = [];
    $iterator = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($sourceDir, FilesystemIterator::SKIP_DOTS)
    );
    foreach ($iterator as $file) {
        if ($file->isFile() && strtolower($file->getExtension()) === 'md') {
            $files[] = $file->getPathname();
        }
    }
    sort($files);
    return $files;
}

/** Category slug for a file: its immediate subfolder, or 'start-here' for root files. */
function doc_library_category_of(string $path, string $sourceDir): string {
    $rel = ltrim(substr($path, strlen($sourceDir)), DIRECTORY_SEPARATOR);
    $parts = explode(DIRECTORY_SEPARATOR, $rel);
    return count($parts) > 1 ? doc_library_slugify($parts[0]) : 'start-here';
}

/** Best-effort title: frontmatter document_name, first # heading, else humanized filename. */
function doc_library_title(array $meta, string $body, string $filename): string {
    if (!empty($meta['document_name'])) {
        return (string) $meta['document_name'];
    }
    if (preg_match('/^#\s+(.+)$/m', $body, $m)) {
        return trim($m[1]);
    }
    return ucwords(str_replace('-', ' ', doc_library_slugify($filename)));
}


/**
 * Rewrite markdown links and images before rendering:
 * - .md links → help.php?doc=slug (resolves by path, then by filename)
 * - local images → queued for copy into help-content/assets/, src rewritten
 * Also converts Obsidian-style wiki embeds ![[image.png]] (optionally ![[image.png|alt]])
 * by searching $assetDirs for the file. Returns [rewrittenBody, warnings, images].
 */
function doc_library_rewrite_links(string $body, string $currentPath, array $slugByPath, array $slugByFile, array $assetDirs = []): array {
    $warnings = [];
    $images = [];
    $currentDir = dirname($currentPath);

    // Obsidian wiki embeds: ![[name.png]] or ![[name.png|alt text]]
    $body = preg_replace_callback(
        '/!\[\[([^\]]+)\]\]/',
        function ($m) use (&$images, $currentDir, $assetDirs, &$warnings) {
            $parts = explode('|', $m[1]);
            $name = trim($parts[0]);
            $alt = trim($parts[1] ?? pathinfo($name, PATHINFO_FILENAME));
            $abs = null;
            foreach (array_merge([$currentDir], $assetDirs) as $dir) {
                $candidate = realpath($dir . DIRECTORY_SEPARATOR . $name);
                if ($candidate !== false && is_file($candidate)) {
                    $abs = $candidate;
                    break;
                }
            }
            if ($abs === null) {
                $warnings[] = "Missing image (wiki embed): $name";
                return '';
            }
            $asset = doc_library_slugify(pathinfo($name, PATHINFO_FILENAME)) . '-'
                . substr(md5($abs), 0, 8) . '.' . strtolower(pathinfo($abs, PATHINFO_EXTENSION));
            $images[$abs] = $asset;
            return '![' . $alt . '](help-content/assets/' . $asset . ')';
        },
        $body
    ) ?? $body;

    $body = preg_replace_callback(
        '/!\[([^\]]*)\]\(([^)\s]+)(?:\s+"[^"]*")?\)/',
        function ($m) use (&$images, $currentDir, &$warnings) {
            $src = $m[2];
            if (preg_match('#^(https?:)?//#i', $src) || $src[0] === '/'
                || str_starts_with($src, 'help-content/assets/')) {
                return $m[0]; // external, absolute, or already rewritten by the wiki-embed pass
            }
            $abs = realpath($currentDir . DIRECTORY_SEPARATOR . $src);
            if ($abs === false || !is_file($abs)) {
                $warnings[] = "Missing image: $src";
                return $m[0];
            }
            $asset = doc_library_slugify(pathinfo($src, PATHINFO_FILENAME)) . '-'
                . substr(md5($abs), 0, 8) . '.' . strtolower(pathinfo($abs, PATHINFO_EXTENSION));
            $images[$abs] = $asset;
            return '![' . $m[1] . '](help-content/assets/' . $asset . ')';
        },
        $body
    ) ?? $body;

    $body = preg_replace_callback(
        '/(?<!!)\[([^\]]+)\]\((?!https?:|\/\/|#|\/)([^)\s#]+?\.md)(#[^)]*)?\)/i',
        function ($m) use ($currentDir, $slugByPath, $slugByFile, &$warnings) {
            $target = $m[2];
            $abs = realpath($currentDir . DIRECTORY_SEPARATOR . str_replace('/', DIRECTORY_SEPARATOR, $target));
            $slug = ($abs !== false && isset($slugByPath[$abs])) ? $slugByPath[$abs] : null;
            if ($slug === null) {
                $slug = $slugByFile[doc_library_slugify(pathinfo($target, PATHINFO_FILENAME))] ?? null;
            }
            if ($slug === null) {
                $warnings[] = "Unresolved doc link: $target";
                return $m[0];
            }
            return '[' . $m[1] . '](help.php?doc=' . $slug . ')';
        },
        $body
    ) ?? $body;

    return [$body, $warnings, $images];
}

/**
 * Generate the whole library. Returns a report:
 * ['included'=>[...], 'skipped'=>[...], 'warnings'=>[...], 'images'=>int, 'output_dir'=>string]
 */
function doc_library_generate(): array {
    $config = doc_library_config();
    $sourceDir = $config['source_dir'];
    $outputDir = $config['output_dir'];
    $report = ['included' => [], 'skipped' => [], 'warnings' => [], 'images' => 0, 'output_dir' => $outputDir];
    if ($sourceDir === false || !is_dir($sourceDir)) {
        $report['warnings'][] = 'Source directory not found: documentation/start-here';
        return $report;
    }
    if (!is_dir($outputDir)) {
        mkdir($outputDir, 0775, true);
    }
    if (!is_dir($outputDir . '/assets')) {
        mkdir($outputDir . '/assets', 0775, true);
    }

    // Pass 1: include only files with frontmatter; assign unique slugs.
    $parsed = [];
    $usedSlugs = [];
    foreach (doc_library_scan($sourceDir) as $path) {
        $content = file_get_contents($path);
        $split = $content === false ? null : doc_library_split_frontmatter($content);
        if ($split === null) {
            $report['skipped'][] = ['file' => basename($path), 'reason' => 'no YAML frontmatter block'];
            continue;
        }
        $category = doc_library_category_of($path, $sourceDir);
        $filename = pathinfo($path, PATHINFO_FILENAME);
        $base = strtolower($filename) === 'index' ? $category : (doc_library_slugify($filename) ?: 'doc');
        $slug = $base;
        $n = 2;
        while (isset($usedSlugs[$slug])) {
            $slug = $base . '-' . $category;
            if (!isset($usedSlugs[$slug])) {
                break;
            }
            $slug = $base . '-' . $n++;
        }
        $usedSlugs[$slug] = true;
        $parsed[] = [
            'path'     => $path,
            'slug'     => $slug,
            'filebase' => doc_library_slugify($filename),
            'category' => $category,
            'meta'     => doc_library_parse_frontmatter($split['raw']),
            'body'     => $split['body'],
        ];
    }
    $slugByPath = [];
    $slugByFile = [];
    foreach ($parsed as $p) {
        $slugByPath[realpath($p['path']) ?: $p['path']] = $p['slug'];
        $slugByFile[$p['filebase']] = $slugByFile[$p['filebase']] ?? $p['slug'];
    }

    // Pass 2: render and write content files, manifest, and search index.
    $parsedown = new Parsedown();
    $manifest = ['generated_at' => date('c'), 'categories' => [], 'docs' => []];
    $searchIndex = [];
    foreach ($config['categories'] as $slug => $cat) {
        $manifest['categories'][$slug] = ['name' => $cat['name'], 'order' => $cat['order'], 'docs' => []];
    }
    foreach ($parsed as $p) {
        $catSlug = $p['category'];
        if (!isset($config['categories'][$catSlug])) {
            $config['categories'][$catSlug] = [
                'name' => ucwords(str_replace('-', ' ', $catSlug)),
                'visibility' => 'authenticated',
                'order' => 50,
            ];
            $manifest['categories'][$catSlug] = ['name' => $config['categories'][$catSlug]['name'], 'order' => 50, 'docs' => []];
            $report['warnings'][] = "Unknown category '$catSlug' defaulted to authenticated visibility";
        }
        $visibility = $config['file_visibility'][$p['slug']] ?? $config['categories'][$catSlug]['visibility'];
        $roles = is_array($visibility) ? array_values($visibility) : [];
        $repoRoot = realpath($sourceDir . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . '..') ?: $sourceDir;
        $assetDirs = [$sourceDir, $repoRoot . DIRECTORY_SEPARATOR . 'img'];
        [$body, $warnings, $images] = doc_library_rewrite_links($p['body'], $p['path'], $slugByPath, $slugByFile, $assetDirs);
        foreach ($warnings as $w) {
            $report['warnings'][] = $p['slug'] . ': ' . $w;
        }
        foreach ($images as $abs => $asset) {
            if (copy($abs, $outputDir . '/assets/' . $asset)) {
                $report['images']++;
            }
        }
        $html = $parsedown->text($body);
        $text = trim(preg_replace('/\s+/', ' ', strip_tags($html)) ?? '');
        $title = doc_library_title($p['meta'], $p['body'], pathinfo($p['path'], PATHINFO_FILENAME));
        $visibilityCode = is_array($visibility) ? 'roles' : $visibility;
        $doc = [
            'slug'          => $p['slug'],
            'title'         => $title,
            'category'      => $catSlug,
            'category_name' => $config['categories'][$catSlug]['name'],
            'visibility'    => $visibilityCode,
            'roles'         => $roles,
            'meta'          => $p['meta'],
            'source'        => ltrim(substr($p['path'], strlen($sourceDir)), DIRECTORY_SEPARATOR),
            'html'          => $html,
        ];
        file_put_contents(
            $outputDir . '/' . $p['slug'] . '.php',
            "<?php\n// AUTO-GENERATED by app/generate-help-docs.php — do not edit by hand.\nreturn " . var_export($doc, true) . ";\n"
        );
        $manifest['docs'][$p['slug']] = ['title' => $title, 'category' => $catSlug, 'visibility' => $visibilityCode, 'roles' => $roles];
        $manifest['categories'][$catSlug]['docs'][] = ['slug' => $p['slug'], 'title' => $title];
        $tags = $p['meta']['tags'] ?? [];
        $searchIndex[] = [
            'slug'     => $p['slug'],
            'title'    => $title,
            'category' => $config['categories'][$catSlug]['name'],
            'tags'     => is_array($tags) ? $tags : [$tags],
            'excerpt'  => substr($text, 0, 180),
            'text'     => substr($text, 0, 20000),
        ];
        $report['included'][] = ['slug' => $p['slug'], 'title' => $title, 'category' => $catSlug, 'visibility' => $visibilityCode];
    }
    foreach ($manifest['categories'] as &$cat) {
        usort($cat['docs'], fn($a, $b) => strcmp($a['title'], $b['title']));
    }
    unset($cat);
    uasort($manifest['categories'], fn($a, $b) => $a['order'] <=> $b['order']);
    $manifest['categories'] = array_filter($manifest['categories'], fn($c) => !empty($c['docs']));
    $header = "<?php\n// AUTO-GENERATED by app/generate-help-docs.php — do not edit by hand.\nreturn ";
    file_put_contents($outputDir . '/manifest.php', $header . var_export($manifest, true) . ";\n");
    file_put_contents($outputDir . '/search-index.php', $header . var_export($searchIndex, true) . ";\n");
    return $report;
}

/** Load the generated manifest, or null when the library has not been generated yet. */
function doc_library_load_manifest(): ?array {
    $file = __DIR__ . '/../help-content/manifest.php';
    return is_file($file) ? (require $file) : null;
}

/** Load one generated document by slug (validated), or null. */
function doc_library_load_doc(string $slug): ?array {
    if (!preg_match('/^[a-z0-9-]+$/', $slug)) {
        return null;
    }
    $file = __DIR__ . '/../help-content/' . $slug . '.php';
    return is_file($file) ? (require $file) : null;
}

/** Load the generated full search index (unfiltered). */
function doc_library_search_index(): array {
    $file = __DIR__ . '/../help-content/search-index.php';
    return is_file($file) ? (require $file) : [];
}

/** Role-aware visibility: public for everyone, authenticated for any logged-in role, else role list. */
function doc_library_can_view(array $doc, ?string $role): bool {
    $visibility = $doc['visibility'] ?? 'public';
    if ($visibility === 'public') {
        return true;
    }
    if ($role === null) {
        return false;
    }
    if ($visibility === 'authenticated') {
        return true;
    }
    return in_array($role, $doc['roles'] ?? [], true);
}
