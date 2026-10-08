<?php
declare(strict_types=1);

/* -----------------------------------------------------------------
 * Case viewing permissions and organization resolution.
 *
 * Levels:
 *   1 = office worker / staff (limited case details)
 *   2 = org admin (full view of their own org's cases)
 *   3 = super admin (full system view)
 * ----------------------------------------------------------------- */

require_once __DIR__ . '/auth.php';

function archr_staff_access(PDO $pdo): array {
    $userId = (int)($_SESSION['archr_user_id'] ?? 0);
    if ($userId === 0) {
        return ['level' => 0, 'orgs' => [], 'role_code' => null];
    }

    $stmt = $pdo->prepare("
        SELECT r.role_code, ura.organization_id
          FROM user_role_assignments ura
          JOIN roles r ON r.id = ura.role_id
         WHERE ura.user_id = :uid
           AND ura.is_active = true
         ORDER BY r.role_level DESC
    ");
    $stmt->execute([':uid' => $userId]);
    $rows = $stmt->fetchAll();

    $level = 0;
    $orgs = [];
    $roleCode = null;

    foreach ($rows as $row) {
        $code = strtoupper((string)$row['role_code']);
        if ($roleCode === null) {
            $roleCode = $code;
        }

        if ($code === 'SUPER_ADMIN') {
            $level = max($level, 3);
        } elseif (in_array($code, ['ADMIN', 'ORG_ADMIN'], true)) {
            $level = max($level, 2);
            if (!empty($row['organization_id'])) {
                $orgs[] = (int)$row['organization_id'];
            }
        } else {
            $level = max($level, 1);
            if (!empty($row['organization_id'])) {
                $orgs[] = (int)$row['organization_id'];
            }
        }
    }

    return [
        'level' => $level,
        'orgs' => array_values(array_unique($orgs)),
        'role_code' => $roleCode,
    ];
}

function archr_case_organization_id(PDO $pdo, int $caseId): ?int {
    // Organization-specific claim (cases.organization_id) is authoritative;
    // case_claims / application_anchor remain as fallbacks for legacy rows.
    $stmt = $pdo->prepare("
        SELECT COALESCE(
            c.organization_id,
            (SELECT claimed_by_org_id FROM case_claims WHERE case_id = :id LIMIT 1),
            (SELECT assigned_organization_id FROM application_anchor WHERE submission_id = c.submission_id LIMIT 1)
        ) AS org_id
          FROM cases c
         WHERE c.id = :id
    ");
    $stmt->execute([':id' => $caseId]);
    $orgId = $stmt->fetchColumn();
    return $orgId ? (int)$orgId : null;
}

function archr_case_view_permission(PDO $pdo, int $caseId): array {
    $access = archr_staff_access($pdo);
    $caseOrg = archr_case_organization_id($pdo, $caseId);
    $level = $access['level'];

    // Full view: super admins everywhere; org admins (level 2) for cases
    // claimed by their own org, and for UNCLAIMED cases so they can review
    // the full application (including Repairs Needed) before claiming it.
    $ownsCase = $caseOrg !== null && in_array($caseOrg, $access['orgs'], true);
    $full = $level >= 3 || ($level >= 2 && ($ownsCase || $caseOrg === null));

    return [
        'level' => $level,
        'case_org' => $caseOrg,
        'user_orgs' => $access['orgs'],
        'owns_case' => $ownsCase,
        'full' => $full,
        'can_view' => $level >= 1,
        'role_code' => $access['role_code'],
    ];
}

function archr_require_staff_access(PDO $pdo): array {
    $access = archr_staff_access($pdo);
    if ($access['level'] < 1) {
        http_response_code(403);
        echo 'Access denied.';
        exit;
    }
    return $access;
}

/**
 * Role-aware side menu for shared staff pages (case search, case review):
 *   level 3 → super admin menu with the org admin menu grouped beneath it
 *   level 2 → the org admin menu
 *   level 1 → dashboard + case search
 */
function archr_staff_portal_nav(PDO $pdo, string $active = ''): array {
    // Nav builders live in portal-layout.php; loaded lazily here because many
    // pages require that file with a plain (non-once) require of their own.
    require_once __DIR__ . '/portal-layout.php';
    $access = archr_staff_access($pdo);
    if ($access['level'] >= 3) {
        return array_merge(
            archr_super_admin_nav('', false),
            [['group' => 'Org Admin']],
            archr_org_admin_nav($active)
        );
    }
    if ($access['level'] >= 2) {
        return archr_org_admin_nav($active);
    }
    return [
        ['href' => 'dashboard.php',   'icon' => 'fa-gauge-high',       'label' => 'Dashboard',   'active' => $active === 'dashboard'],
        ['href' => 'case-search.php', 'icon' => 'fa-magnifying-glass', 'label' => 'Case Search', 'active' => $active === 'case-search'],
    ];
}
