<?php
declare(strict_types=1);
require __DIR__ . '/lib/session.php';
archr_session_start();

require __DIR__ . '/lib/db.php';
require __DIR__ . '/lib/permissions.php';

// Require authentication
if (empty($_SESSION['archr_user_id'])) {
    header('Location: /app/login.php');
    exit;
}

$userId    = (int)$_SESSION['archr_user_id'];
$fullName  = (string)($_SESSION['archr_user_full_name'] ?? '');
$email     = (string)($_SESSION['archr_user_email'] ?? '');
$roleCode  = (string)($_SESSION['archr_role'] ?? 'unknown');

// Look up full user record from database
$pdo = archr_pdo();
$userStmt = $pdo->prepare("
    SELECT id, username, email, full_name, is_active, session_indefinite
      FROM system_users
     WHERE id = ?
");
$userStmt->execute([$userId]);
$user = $userStmt->fetch() ?: null;

// Look up all role assignments for this user
$roleStmt = $pdo->prepare("
    SELECT LOWER(r.role_code) AS role_code,
           r.role_name,
           r.role_level,
           ura.organization_id,
           ura.is_active
      FROM user_role_assignments ura
      JOIN roles r ON r.id = ura.role_id
     WHERE ura.user_id = ?
     ORDER BY r.role_level DESC
");
$roleStmt->execute([$userId]);
$allRoles = $roleStmt->fetchAll();

// Determine the primary (highest) role
$primaryRole = $allRoles[0] ?? null;
$primaryRoleCode = $primaryRole ? $primaryRole['role_code'] : $roleCode;
$permissionLevel = archr_get_permission_level($primaryRoleCode);
$levelLabel = archr_get_level_label($permissionLevel);
$capabilities = archr_get_capabilities($primaryRoleCode);
$availableRoles = archr_available_roles_for_level($permissionLevel);

// Menu items available at this level
$menuItems = array_filter(archr_menu_registry(), fn($item) => $item['minLevel'] <= $permissionLevel);

// Token check (for Vue SPA parity)
$tokenFile = __DIR__ . '/.env';
$envVars = [];
if (file_exists($tokenFile)) {
    $lines = file($tokenFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (str_contains($line, '=')) {
            [$key, $val] = explode('=', $line, 2);
            $envVars[trim($key)] = trim($val);
        }
    }
}
$authSecret = $envVars['AUTH_SECRET_KEY'] ?? '(not set)';
$hasSecret = $authSecret !== '(not set)';

// Organization info (if any)
$orgInfo = null;
if ($primaryRole && $primaryRole['organization_id']) {
    $orgStmt = $pdo->prepare("
        SELECT organization_name
          FROM coalition_organizations
         WHERE id = ?
    ");
    $orgStmt->execute([$primaryRole['organization_id']]);
    $orgInfo = $orgStmt->fetch() ?: null;
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ARCHR — Who Am I?</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: system-ui, -apple-system, sans-serif;
            background: #f0f2f5;
            color: #1a1a2e;
            padding: 2rem;
            max-width: 900px;
            margin: 0 auto;
        }
        h1 {
            font-size: 1.8rem;
            margin-bottom: 0.5rem;
            color: #16213e;
        }
        .subtitle {
            color: #666;
            margin-bottom: 2rem;
        }
        .card {
            background: white;
            border-radius: 12px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        .card h2 {
            font-size: 1.1rem;
            color: #16213e;
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid #e2e8f0;
        }
        .badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            border-radius: 999px;
            font-size: 0.85rem;
            font-weight: 600;
            margin: 0.25rem;
        }
        .badge.level-3 { background: #7c3aed; color: white; }
        .badge.level-2 { background: #2563eb; color: white; }
        .badge.level-1 { background: #059669; color: white; }
        .badge.level-0 { background: #64748b; color: white; }
        .badge.role { background: #e0e7ff; color: #3730a3; }
        .badge.active { background: #dcfce7; color: #166534; }
        .badge.inactive { background: #fee2e2; color: #991b1b; }
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 0.5rem;
        }
        .grid-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.4rem 0.6rem;
            background: #f8fafc;
            border-radius: 6px;
            font-size: 0.85rem;
        }
        .grid-item.yes { background: #f0fdf4; border-left: 3px solid #22c55e; }
        .grid-item.no { background: #fef2f2; border-left: 3px solid #ef4444; }
        .grid-item .icon { font-size: 1rem; }
        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.9rem;
        }
        th, td {
            padding: 0.5rem 0.75rem;
            text-align: left;
            border-bottom: 1px solid #e2e8f0;
        }
        th {
            background: #f8fafc;
            font-weight: 600;
            color: #475569;
        }
        .back-link {
            display: inline-block;
            margin-bottom: 1rem;
            color: #2563eb;
            text-decoration: none;
        }
        .back-link:hover { text-decoration: underline; }
        .mono {
            font-family: ui-monospace, 'Cascadia Code', 'Consolas', monospace;
            font-size: 0.85rem;
            background: #f1f5f9;
            padding: 0.15rem 0.4rem;
            border-radius: 4px;
        }
        .debug {
            background: #fffbeb;
            border: 1px solid #fbbf24;
            border-radius: 8px;
            padding: 1rem;
            margin-top: 1rem;
        }
        .debug h3 { color: #92400e; margin-bottom: 0.5rem; }
        .debug pre {
            background: #1e293b;
            color: #e2e8f0;
            padding: 0.75rem;
            border-radius: 6px;
            overflow-x: auto;
            font-size: 0.8rem;
            line-height: 1.5;
        }
    </style>
</head>
<body>

<a href="/portal/" class="back-link">&larr; Back to Portal</a>
<h1>🔍 Who Am I?</h1>
<p class="subtitle">Proof of identity, role, and permission capabilities — <span class="mono"><?= htmlspecialchars($roleCode) ?></span></p>

<!-- Identity Card -->
<div class="card">
    <h2>👤 Identity</h2>
    <table>
        <tr><th style="width:160px">Full Name</th><td><?= htmlspecialchars($fullName) ?></td></tr>
        <tr><th>Email</th><td><span class="mono"><?= htmlspecialchars($email) ?></span></td></tr>
        <tr><th>Username</th><td><span class="mono"><?= htmlspecialchars($user ? $user['username'] : 'N/A') ?></span></td></tr>
        <tr><th>User ID</th><td><span class="mono"><?= $userId ?></span></td></tr>
        <tr><th>Account Status</th><td>
            <?php if ($user && $user['is_active']): ?>
                <span class="badge active">Active</span>
            <?php else: ?>
                <span class="badge inactive">Inactive</span>
            <?php endif; ?>
        </td></tr>
        <tr><th>Session Type</th><td>
            <?php if ($user && $user['session_indefinite']): ?>
                <span class="badge active">Indefinite (Remember Me)</span>
            <?php else: ?>
                <span class="badge role">Standard (24h)</span>
            <?php endif; ?>
        </td></tr>
    </table>
</div>

<!-- Role & Permission Level -->
<div class="card">
    <h2>🔑 Role &amp; Permission Level</h2>
    <table>
        <tr><th style="width:160px">Primary Role</th><td><span class="badge role"><?= htmlspecialchars($primaryRoleCode) ?></span></td></tr>
        <tr><th>Permission Level</th><td><span class="badge level-<?= $permissionLevel ?>"><?= $levelLabel ?> (Level <?= $permissionLevel ?>)</span></td></tr>
        <?php if ($orgInfo): ?>
        <tr><th>Organization</th><td><?= htmlspecialchars($orgInfo['organization_name'] ?? '') ?></td></tr>
        <?php endif; ?>
    </table>

    <?php if (count($allRoles) > 1): ?>
    <h2 style="margin-top:1rem;">📋 All Role Assignments (<?= count($allRoles) ?>)</h2>
    <table>
        <tr><th>Role Code</th><th>Role Name</th><th>Level</th><th>Org ID</th><th>Status</th></tr>
        <?php foreach ($allRoles as $ar): ?>
        <tr>
            <td><span class="badge role"><?= htmlspecialchars($ar['role_code']) ?></span></td>
            <td><?= htmlspecialchars($ar['role_name']) ?></td>
            <td><span class="badge level-<?= (int)$ar['role_level'] ?>"><?= (int)$ar['role_level'] ?></span></td>
            <td><span class="mono"><?= $ar['organization_id'] ?? '—' ?></span></td>
            <td><?= $ar['is_active'] ? '<span class="badge active">Active</span>' : '<span class="badge inactive">Inactive</span>' ?></td>
        </tr>
        <?php endforeach; ?>
    </table>
    <?php endif; ?>
</div>

<!-- Capabilities -->
<div class="card">
    <h2>⚡ Capabilities (<?= count($capabilities) ?> granted)</h2>
    <div class="grid">
        <?php
        $allCaps = [];
        foreach (ARCHR_LEVEL_CAPABILITIES as $lvl => $caps) {
            foreach ($caps as $cap => $granted) {
                $allCaps[$cap] = $cap;
            }
        }
        foreach ($allCaps as $cap):
            $has = $capabilities[$cap] ?? false;
        ?>
        <div class="grid-item <?= $has ? 'yes' : 'no' ?>">
            <span class="icon"><?= $has ? '✅' : '❌' ?></span>
            <span><?= str_replace('_', ' ', $cap) ?></span>
        </div>
        <?php endforeach; ?>
    </div>
</div>

<!-- Available Menu Items -->
<div class="card">
    <h2>📌 Available Menu Items (<?= count($menuItems) ?>)</h2>
    <div class="grid">
        <?php foreach ($menuItems as $item): ?>
        <div class="grid-item yes">
            <span class="icon">📋</span>
            <span><?= htmlspecialchars($item['label']) ?> <span style="color:#999">(Level <?= $item['minLevel'] ?>+)</span></span>
        </div>
        <?php endforeach; ?>
    </div>
</div>

<!-- Roles This Level Can Act As -->
<div class="card">
    <h2>🔄 Available Roles for "View As" (<?= count($availableRoles) ?>)</h2>
    <div>
        <?php foreach ($availableRoles as $ar): ?>
        <span class="badge role"><?= htmlspecialchars($ar) ?></span>
        <?php endforeach; ?>
    </div>
</div>

<!-- Auth System Info -->
<div class="card">
    <h2>🔐 Auth System Info</h2>
    <table>
        <tr><th style="width:160px">Auth Mechanism</th><td>PHP Session (archr_session)</td></tr>
        <tr><th>Session ID</th><td><span class="mono"><?= session_id() ?></span></td></tr>
        <tr><th>Vue Token Auth</th><td><?= $hasSecret ? '<span class="badge active">AUTH_SECRET_KEY configured</span>' : '<span class="badge inactive">No secret key</span>' ?></td></tr>
        <tr><th>Database</th><td>PostgreSQL (archr)</td></tr>
    </table>
</div>

<!-- Debug / Session Dump -->
<div class="card">
    <h2>🐛 Session Data (Raw)</h2>
    <div class="debug">
        <h3>$_SESSION</h3>
        <pre><?php
        $safeSession = [];
        foreach ($_SESSION as $k => $v) {
            $safeSession[$k] = is_string($v) ? $v : (is_array($v) ? json_encode($v, JSON_PRETTY_PRINT) : $v);
        }
        echo htmlspecialchars(json_encode($safeSession, JSON_PRETTY_PRINT));
        ?></pre>
    </div>
</div>

</body>
</html>
