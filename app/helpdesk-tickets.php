<?php
declare(strict_types=1);

/* Super-Admin helpdesk ticket queue.
 * Lists, filters, and resolves support tickets submitted via the Vue chat widget. */

require __DIR__ . '/lib/auth.php';
archr_require_auth();

require __DIR__ . '/lib/db.php';
require_once __DIR__ . '/lib/portal-layout.php';
require_once __DIR__ . '/lib/permissions.php';

$pdo = archr_pdo();
$userId = (int)($_SESSION['archr_user_id'] ?? 0);
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

// ── Handle resolve / assign POST actions ──
$message = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    $ticketId = (int)($_POST['ticket_id'] ?? 0);

    if ($action === 'resolve' && $ticketId > 0) {
        $note = trim((string)($_POST['resolution_note'] ?? ''));
        $upd = $pdo->prepare("
            UPDATE support_tickets
               SET status = 'resolved',
                   resolved_at = CURRENT_TIMESTAMP,
                   resolved_by = :uid,
                   resolution_note = :note,
                   updated_at = CURRENT_TIMESTAMP
             WHERE id = :id
        ");
        $upd->execute([':uid' => $userId, ':note' => $note, ':id' => $ticketId]);
        $message = "Ticket #{$ticketId} resolved.";
    }

    if ($action === 'assign' && $ticketId > 0) {
        $assignTo = (int)($_POST['assigned_to'] ?? 0);
        $upd = $pdo->prepare("
            UPDATE support_tickets
               SET assigned_to = :uid,
                   status = 'in_progress',
                   updated_at = CURRENT_TIMESTAMP
             WHERE id = :id
        ");
        $upd->execute([':uid' => $assignTo ?: null, ':id' => $ticketId]);
        $message = "Ticket #{$ticketId} updated.";
    }
}

// ── Fetch tickets ──
$statusFilter = $_GET['status'] ?? 'open';
$catFilter = $_GET['category'] ?? '';
$priorityFilter = $_GET['priority'] ?? '';

$where = ['1=1'];
$params = [];

if ($statusFilter !== 'all') {
    $where[] = 't.status = :status';
    $params[':status'] = $statusFilter;
}
if ($catFilter) {
    $where[] = 't.category = :cat';
    $params[':cat'] = $catFilter;
}
if ($priorityFilter) {
    $where[] = 't.priority = :pri';
    $params[':pri'] = $priorityFilter;
}

$sql = "
    SELECT t.*,
           su.full_name AS submitter_display_name,
           au.full_name AS assigned_name,
           ru.full_name AS resolver_name
      FROM support_tickets t
      LEFT JOIN system_users su ON su.id = t.submitted_by
      LEFT JOIN system_users au ON au.id = t.assigned_to
      LEFT JOIN system_users ru ON ru.id = t.resolved_by
     WHERE " . implode(' AND ', $where) . "
     ORDER BY
       CASE t.priority
         WHEN 'critical' THEN 1
         WHEN 'high' THEN 2
         WHEN 'normal' THEN 3
         WHEN 'low' THEN 4
         ELSE 5
       END,
       t.created_at DESC
     LIMIT 200
";
$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$tickets = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Super admin user list for assign dropdown
$usersStmt = $pdo->query("SELECT id, full_name FROM system_users WHERE is_active = true ORDER BY full_name");
$allUsers = $usersStmt->fetchAll(PDO::FETCH_ASSOC);

$catLabels = [
    'bug' => '🐛 Bug',
    'feature_request' => '💡 Feature',
    'access_issue' => '🔑 Access',
    'data_error' => '📊 Data',
    'general' => '❓ General',
];

$priorityColors = [
    'critical' => '#dc2626',
    'high' => '#f59e0b',
    'normal' => '#3b82f6',
    'low' => '#6b7280',
];

archr_render_portal_header([
    'role' => 'super-admin',
    'role_label' => 'Super Admin',
    'brand' => 'ARCHR Super Admin',
    'page_title' => 'Helpdesk Tickets',
    'user_name' => $_SESSION['archr_user_name'] ?? '',
    'avatar_initials' => archr_initials_from_name($_SESSION['archr_user_name'] ?? ''),
    'badge_icon' => 'fa-shield-halved',
    'extra_head' => '<link rel="stylesheet" href="assets/role-super-admin.css">',
    'nav' => archr_super_admin_nav('helpdesk'),
]);
?>
<style>
.hdesk-filters { display:flex; gap:0.75rem; flex-wrap:wrap; margin-bottom:1rem; align-items:flex-end; }
.hdesk-filters label { display:flex; flex-direction:column; gap:0.2rem; font-size:0.8rem; font-weight:600; color:#374151; }
.hdesk-filters select { padding:0.3rem 0.5rem; border:1px solid #d1d5db; border-radius:4px; font-size:0.85rem; }
.hdesk-count { margin-left:auto; font-size:0.8rem; color:#6b7280; padding-top:1.2rem; }

.hdesk-table { width:100%; border-collapse:collapse; font-size:0.85rem; }
.hdesk-table th { text-align:left; padding:0.5rem 0.65rem; background:#f3f4f6; font-size:0.75rem; text-transform:uppercase; letter-spacing:0.025em; border-bottom:2px solid #d1d5db; }
.hdesk-table td { padding:0.5rem 0.65rem; border-bottom:1px solid #f3f4f6; vertical-align:top; }
.hdesk-table tbody tr:hover { background:#f9fafb; }

.hdesk-badge { display:inline-block; padding:0.1rem 0.45rem; border-radius:999px; font-size:0.7rem; font-weight:600; }
.hdesk-badge--open { background:#dbeafe; color:#1d4ed8; }
.hdesk-badge--progress { background:#fef3c7; color:#92400e; }
.hdesk-badge--resolved { background:#dcfce7; color:#166534; }
.hdesk-badge--closed { background:#f3f4f6; color:#374151; }

.hdesk-pri { display:inline-block; width:8px; height:8px; border-radius:50%; margin-right:0.35rem; }

.hdesk-expand { cursor:pointer; }
.hdesk-detail { display:none; padding:0.75rem; background:#f9fafb; border-radius:6px; margin-top:0.35rem; font-size:0.85rem; line-height:1.5; }
.hdesk-expand:checked + .hdesk-detail { display:block; }

.hdesk-actions { display:flex; gap:0.5rem; margin-top:0.5rem; }
.hdesk-btn { padding:0.3rem 0.65rem; border:1px solid #d1d5db; border-radius:4px; background:#fff; font-size:0.8rem; cursor:pointer; }
.hdesk-btn:hover { background:#f3f4f6; }
.hdesk-btn--primary { background:#1a56db; color:#fff; border-color:#1a56db; }
.hdesk-btn--primary:hover { background:#1e40af; }
</style>

<main class="page-wrap">
    <section class="panel">
        <h1><i class="fas fa-headset" aria-hidden="true"></i> Helpdesk Tickets</h1>
        <?php if ($message): ?>
            <p style="color:#166534;background:#f0fdf4;padding:0.5rem 0.75rem;border-radius:6px;margin-bottom:1rem;"><?= htmlspecialchars($message) ?></p>
        <?php endif; ?>

        <form class="hdesk-filters" method="get">
            <label>
                Status
                <select name="status">
                    <option value="open" <?= $statusFilter === 'open' ? 'selected' : '' ?>>Open</option>
                    <option value="in_progress" <?= $statusFilter === 'in_progress' ? 'selected' : '' ?>>In Progress</option>
                    <option value="resolved" <?= $statusFilter === 'resolved' ? 'selected' : '' ?>>Resolved</option>
                    <option value="closed" <?= $statusFilter === 'closed' ? 'selected' : '' ?>>Closed</option>
                    <option value="all" <?= $statusFilter === 'all' ? 'selected' : '' ?>>All</option>
                </select>
            </label>
            <label>
                Category
                <select name="category">
                    <option value="">All</option>
                    <?php foreach ($catLabels as $k => $v): ?>
                        <option value="<?= $k ?>" <?= $catFilter === $k ? 'selected' : '' ?>><?= $v ?></option>
                    <?php endforeach; ?>
                </select>
            </label>
            <label>
                Priority
                <select name="priority">
                    <option value="">All</option>
                    <?php foreach (['critical','high','normal','low'] as $p): ?>
                        <option value="<?= $p ?>" <?= $priorityFilter === $p ? 'selected' : '' ?>><?= ucfirst($p) ?></option>
                    <?php endforeach; ?>
                </select>
            </label>
            <button type="submit" class="hdesk-btn hdesk-btn--primary">Filter</button>
            <span class="hdesk-count"><?= count($tickets) ?> tickets</span>
        </form>

        <?php if (empty($tickets)): ?>
            <p class="muted">No tickets match these filters.</p>
        <?php else: ?>
        <div style="overflow-x:auto;">
        <table class="hdesk-table">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Category</th>
                    <th>Subject</th>
                    <th>Submitter</th>
                    <th>Priority</th>
                    <th>Assigned</th>
                    <th>Status</th>
                    <th>Created</th>
                </tr>
            </thead>
            <tbody>
            <?php foreach ($tickets as $t): ?>
                <tr>
                    <td>
                        <label class="hdesk-expand">
                            <input type="checkbox" style="display:none">
                            <?= (int)$t['id'] ?>
                        </label>
                    </td>
                    <td><?= $catLabels[$t['category']] ?? htmlspecialchars($t['category']) ?></td>
                    <td>
                        <?= htmlspecialchars($t['subject']) ?>
                        <details class="hdesk-detail">
                            <summary style="cursor:pointer;color:#3b82f6;font-size:0.8rem;">Show details</summary>
                            <pre style="white-space:pre-wrap;margin:0.5rem 0;font-size:0.85rem;"><?= htmlspecialchars($t['description']) ?></pre>
                            <?php if ($t['resolution_note']): ?>
                                <p style="margin-top:0.5rem;"><strong>Resolution:</strong> <?= htmlspecialchars($t['resolution_note']) ?></p>
                            <?php endif; ?>
                        </details>
                    </td>
                    <td>
                        <?= htmlspecialchars($t['submitter_display_name'] ?: $t['submitter_name']) ?><br>
                        <span style="font-size:0.75rem;color:#6b7280;"><?= htmlspecialchars($t['submitter_email']) ?></span>
                    </td>
                    <td>
                        <span class="hdesk-pri" style="background:<?= $priorityColors[$t['priority']] ?? '#6b7280' ?>"></span>
                        <?= ucfirst($t['priority']) ?>
                    </td>
                    <td><?= $t['assigned_name'] ?: '<span style="color:#9ca3af;">Unassigned</span>' ?></td>
                    <td>
                        <?php
                            $cls = match($t['status']) {
                                'open' => 'open',
                                'in_progress' => 'progress',
                                'resolved' => 'resolved',
                                'closed' => 'closed',
                                default => 'open',
                            };
                        ?>
                        <span class="hdesk-badge hdesk-badge--<?= $cls ?>"><?= ucfirst(str_replace('_',' ', $t['status'])) ?></span>
                    </td>
                    <td><?= date('M j, Y', strtotime($t['created_at'])) ?></td>
                </tr>
                <tr>
                    <td colspan="8" style="padding:0 0.65rem 0.75rem;">
                        <form method="post" class="hdesk-actions">
                            <input type="hidden" name="action" value="assign">
                            <input type="hidden" name="ticket_id" value="<?= (int)$t['id'] ?>">
                            <select name="assigned_to" style="padding:0.25rem;font-size:0.8rem;border:1px solid #d1d5db;border-radius:4px;">
                                <option value="">— assign —</option>
                                <?php foreach ($allUsers as $u): ?>
                                    <option value="<?= (int)$u['id'] ?>" <?= (int)$t['assigned_to'] === (int)$u['id'] ? 'selected' : '' ?>>
                                        <?= htmlspecialchars($u['full_name']) ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                            <button type="submit" class="hdesk-btn">Assign</button>
                        </form>
                        <?php if ($t['status'] !== 'resolved' && $t['status'] !== 'closed'): ?>
                        <form method="post" class="hdesk-actions" style="margin-top:0.35rem;">
                            <input type="hidden" name="action" value="resolve">
                            <input type="hidden" name="ticket_id" value="<?= (int)$t['id'] ?>">
                            <input type="text" name="resolution_note" placeholder="Resolution note…" style="flex:1;padding:0.25rem;font-size:0.8rem;border:1px solid #d1d5db;border-radius:4px;">
                            <button type="submit" class="hdesk-btn hdesk-btn--primary">Resolve</button>
                        </form>
                        <?php endif; ?>
                    </td>
                </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
        </div>
        <?php endif; ?>
    </section>
</main>
<?php
archr_render_portal_footer();
