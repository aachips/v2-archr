<?php
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// MIME types for static files
$mimeTypes = [
    '.css' => 'text/css',
    '.js'  => 'application/javascript',
    '.png' => 'image/png',
    '.jpg' => 'image/jpeg',
    '.svg' => 'image/svg+xml',
    '.ico' => 'image/x-icon',
    '.woff' => 'font/woff',
    '.woff2' => 'font/woff2',
    '.html' => 'text/html',
];

$ext = pathinfo($uri, PATHINFO_EXTENSION);

// Serve static files directly
if ($ext && isset($mimeTypes['.' . $ext])) {
    $file = __DIR__ . $uri;
    if (file_exists($file)) {
        header('Content-Type: ' . $mimeTypes['.' . $ext]);
        readfile($file);
        exit;
    }
}

// Handle directory index (e.g., /portal/ -> /portal/index.html or /portal/portal.html)
if (is_dir(__DIR__ . $uri)) {
    $indexFile = __DIR__ . $uri . 'index.html';
    if (file_exists($indexFile)) {
        header('Content-Type: text/html');
        readfile($indexFile);
        exit;
    }
    // Try portal.html as fallback
    $portalFile = __DIR__ . $uri . 'portal.html';
    if (file_exists($portalFile)) {
        header('Content-Type: text/html');
        readfile($portalFile);
        exit;
    }
}

// Fall through to index.php
$_GET['_url'] = $uri;
include __DIR__ . '/index.php';
