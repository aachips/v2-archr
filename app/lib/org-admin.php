<?php
declare(strict_types=1);

/* -----------------------------------------------------------------
 * Org Admin (permission level 2) helpers: organization context,
 * permission checks, and org-scoped data loaders.
 * ----------------------------------------------------------------- */

require_once __DIR__ . '/db.php';
require_once __DIR__ . '/case-access.php';

/**
 * Resolve the organizations the logged-in user administers.
 * Returns rows of coalition_organizations keyed by id.
 */
function archr_org_admin_orgs(PDO $pdo): array {
    $userId = (int)($_SESSION['archr_user_id'] ?? 0);
    if ($userId === 0) {
        return [];
    }
    $stmt = $pdo->prepare("
        SELECT DISTINCT o.id, o.organization_code, o.organization_name,
               o.contact_email, o.contact_phone, o.notification_email
          FROM user_role_assignments ura
          JOIN roles r ON r.id = ura.role_id
          JOIN coalition_organizations o ON o.id = ura.organization_id
         WHERE ura.user_id = :uid
           AND ura.is_active = true
           AND UPPER(r.role_code) IN ('ADMIN', 'ORG_ADMIN')
           AND ura.organization_id IS NOT NULL
         ORDER BY o.organization_name
    ");
    $stmt->execute([':uid' => $userId]);
    $orgs = [];
    foreach ($stmt->fetchAll() as $row) {
        $orgs[(int)$row['id']] = $row;
    }

    /* Super admins act on behalf of any organization: claims need an org
       context, and archr_org_admin_resolve_org_id() already validates a
       super admin's chosen org. Without this the claim UI never renders
       for super admins (no ADMIN/ORG_ADMIN assignment -> empty org list). */
    if ($orgs === [] && archr_is_super_admin($pdo)) {
        foreach ($pdo->query("SELECT id, organization_code, organization_name, contact_email, contact_phone, notification_email FROM coalition_organizations WHERE is_active = true ORDER BY organization_name")->fetchAll() as $row) {
            $orgs[(int)$row['id']] = $row;
        }
    }
    return $orgs;
}

/**
 * Is the current user a super admin?
 */
function archr_is_super_admin(PDO $pdo): bool {
    return archr_staff_access($pdo)['level'] >= 3;
}

/**
 * Require org-admin capability: level 2 with at least one org, or level 3.
 * Returns ['level'=>int, 'orgs'=>array<id,row>, 'is_super_admin'=>bool].
 */
function archr_require_org_admin(PDO $pdo): array {
    $access = archr_staff_access($pdo);
    $orgs = archr_org_admin_orgs($pdo);
    $isSuperAdmin = $access['level'] >= 3;

    if ((!$isSuperAdmin && $access['level'] < 2) || (!$isSuperAdmin && !$orgs)) {
        http_response_code(403);
        echo 'Forbidden: Organization Administrator access required.';
        exit;
    }

    // Load user's menu configuration.
    $userId = (int)($_SESSION['archr_user_id'] ?? 0);
    $menuConfig = null;
    if ($userId > 0) {
        $mcStmt = $pdo->prepare("SELECT menu_config FROM system_users WHERE id = :id LIMIT 1");
        $mcStmt->execute([':id' => $userId]);
        $row = $mcStmt->fetch();
        $menuConfig = $row['menu_config'] ?? null;
    }

    return ['level' => $access['level'], 'orgs' => $orgs, 'is_super_admin' => $isSuperAdmin, 'user_menu_config' => $menuConfig];
}

/**
 * The organization id a claim/withdrawal action applies to.
 * Never trusts a client-submitted org id — it must be one of the
 * user's own administered orgs (or, for super admins, must exist).
 */
function archr_org_admin_resolve_org_id(PDO $pdo, array $ctx, ?int $requestedOrgId): ?int {
    $orgs = $ctx['orgs'];
    if ($requestedOrgId !== null && $requestedOrgId > 0) {
        if (isset($orgs[$requestedOrgId])) {
            return $requestedOrgId;
        }
        if ($ctx['is_super_admin']) {
            $stmt = $pdo->prepare('SELECT 1 FROM coalition_organizations WHERE id = :id');
            $stmt->execute([':id' => $requestedOrgId]);
            return $stmt->fetchColumn() ? $requestedOrgId : null;
        }
        return null;
    }
    if (count($orgs) === 1) {
        return (int)array_key_first($orgs);
    }
    return null; // ambiguous — caller must fail and ask for organization_id
}

/**
 * Cases claimed by / assigned to one of the user's orgs, plus claimable
 * applications: unclaimed intake cases and expired applications (an expired
 * application can be re-claimed — terminology doc Part 3).
 * Used by the portal pages.
 */
function archr_org_cases(PDO $pdo, array $orgIds, bool $includeUnclaimed): array {
    $params = [];
    // No administered orgs (e.g. a super admin viewing): an org-scoped list
    // would be empty, so only the unclaimed pool applies — but when the
    // caller asked to include unclaimed too, show the full case list.
    if (!$orgIds) {
        $orgCond = $includeUnclaimed ? '1=1' : '1=0';
        $claimableCond = '';
    } else {
        $in = implode(',', array_map('intval', $orgIds));
        $orgCond = "(c.organization_id IN ($in) OR cc.claimed_by_org_id IN ($in) OR a.assigned_organization_id IN ($in))";
        $claimableCond = $includeUnclaimed
            ? "OR ((c.organization_id IS NULL AND cc.claimed_by_org_id IS NULL AND a.assigned_organization_id IS NULL) OR ap.status = 'expired')"
            : '';
    }

    $sql = "
        SELECT s.id AS submission_id, s.submitted_at, s.submission_status,
               s.applicant_first_name, s.applicant_last_name,
               s.home_address, s.home_city, s.home_state,
               c.id AS case_id, c.case_number, c.application_id,
               c.claim_status, c.claimed_at, c.claim_expires_at, c.last_progress_at,
               CASE WHEN c.claim_status = 'active'
                    THEN GREATEST(0, (EXTRACT(EPOCH FROM (c.claim_expires_at - CURRENT_TIMESTAMP)) / 86400)::int)
               END AS days_until_expiry,
               cs.status_code, cs.status_name, cs.status_sequence,
               a.project_code, a.placecode,
               ap.display_name, ap.status AS application_status,
               COALESCE(c.organization_id, cc.claimed_by_org_id, a.assigned_organization_id) AS org_id,
               o.organization_name, o.organization_code
          FROM intake_submissions s
          LEFT JOIN application_anchor a ON a.submission_id = s.id
          LEFT JOIN cases c ON c.submission_id = s.id
          LEFT JOIN applications ap ON ap.id = c.application_id
          LEFT JOIN case_statuses cs ON cs.id = c.status_id
          LEFT JOIN case_claims cc ON cc.case_id = c.id
          LEFT JOIN coalition_organizations o
                 ON o.id = COALESCE(c.organization_id, cc.claimed_by_org_id, a.assigned_organization_id)
         WHERE ($orgCond $claimableCond)
         ORDER BY s.submitted_at DESC
    ";
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    return $stmt->fetchAll();
}

/** Latest status-change events across the user's orgs' cases. */
function archr_org_case_events(PDO $pdo, array $orgIds, int $limit = 8): array {
    if (!$orgIds) {
        return [];
    }
    $in = implode(',', array_map('intval', $orgIds));
    $stmt = $pdo->prepare("
        SELECT csh.changed_at, csh.notes, c.case_number, c.id AS case_id,
               ts.status_name AS to_status, u.full_name AS changed_by_name
          FROM case_status_history csh
          JOIN cases c ON c.id = csh.case_id
          LEFT JOIN case_statuses ts ON ts.id = csh.to_status_id
          LEFT JOIN system_users u ON u.id = csh.changed_by
          LEFT JOIN case_claims cc ON cc.case_id = c.id
          LEFT JOIN application_anchor a ON a.submission_id = c.submission_id
         WHERE COALESCE(c.organization_id, cc.claimed_by_org_id, a.assigned_organization_id) IN ($in)
         ORDER BY csh.changed_at DESC
         LIMIT :lim
    ");
    $stmt->bindValue(':lim', $limit, PDO::PARAM_INT);
    $stmt->execute();
    return $stmt->fetchAll();
}

/** Unread (then recent read) notifications for the logged-in user. */
function archr_org_user_notifications(PDO $pdo, int $limit = 30): array {
    $userId = (int)($_SESSION['archr_user_id'] ?? 0);
    $stmt = $pdo->prepare("
        SELECT id, notification_type, title, body, entity_type, entity_id,
               is_read, priority, created_at
          FROM notifications
         WHERE user_id = :uid
         ORDER BY is_read ASC, created_at DESC
         LIMIT :lim
    ");
    $stmt->bindValue(':uid', $userId, PDO::PARAM_INT);
    $stmt->bindValue(':lim', $limit, PDO::PARAM_INT);
    $stmt->execute();
    return $stmt->fetchAll();
}
