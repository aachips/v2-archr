<?php
/**
 * Router for PHP built-in development server.
 * Serves static files with correct MIME types and routes
 * API requests through their PHP handlers.
 */

$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// MIME types for static files
$mimeTypes = [
    '.css'  => 'text/css',
    '.js'   => 'application/javascript',
    '.png'  => 'image/png',
    '.jpg'  => 'image/jpeg',
    '.jpeg' => 'image/jpeg',
    '.gif'  => 'image/gif',
    '.svg'  => 'image/svg+xml',
    '.ico'  => 'image/x-icon',
    '.woff'  => 'font/woff',
    '.woff2' => 'font/woff2',
    '.ttf'   => 'font/ttf',
    '.html' => 'text/html',
    '.json' => 'application/json',
];

// Serve static files from portal/ directory
$basePath = __DIR__;

// API routes — let PHP handle these
if (preg_match('#^/app/#', $uri)) {
    $file = $basePath . $uri;
    if (is_file($file)) {
        require $file;
        return true;
    }
    http_response_code(404);
    header('Content-Type: application/json');
    echo json_encode(['error' => 'Not found']);
    return true;
}

// Static file serving
if ($uri === '/' || $uri === '/index.php') {
    $file = $basePath . '/index.php';
    if (is_file($file)) {
        require $file;
        return true;
    }
}

// Serve portal files
if (preg_match('#^/portal/#', $uri)) {
    $file = $basePath . $uri;
    if (is_file($file)) {
        $ext = strtolower(pathinfo($file, PATHINFO_EXTENSION));
        if (isset($mimeTypes[$ext])) {
            header('Content-Type: ' . $mimeTypes[$ext]);
        }
        readfile($file);
        return true;
    }
    // Try serving /portal/ as /portal/portal.html
    if ($uri === '/portal' || $uri === '/portal/') {
        $file = $basePath . '/portal/portal.html';
        if (is_file($file)) {
            header('Content-Type: text/html');
            readfile($file);
            return true;
        }
    }
    http_response_code(404);
    header('Content-Type: text/html');
    echo '<h1>404 Not Found</h1><p>' . htmlspecialchars($uri) . ' was not found.</p>';
    return true;
}

// Serve other static files
$file = $basePath . $uri;
if (is_file($file)) {
    $ext = strtolower(pathinfo($file, PATHINFO_EXTENSION));
    if (isset($mimeTypes[$ext])) {
        header('Content-Type: ' . $mimeTypes[$ext]);
    }
    readfile($file);
    return true;
}

// Default: let PHP handle it (will 404)
return false;
