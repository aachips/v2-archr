<?php
declare(strict_types=1);

/**
 * ARCHR Permission Layer — maps 12 role strings to 4 permission levels.
 *
 * Level 0 — Viewer (Volunteer, Requestor, Crew Member)
 *   Basic views for what concerns them: own application status, shifts, tasks.
 *
 * Level 1 — Office Worker (Assessor, Subcontractor, Envoy, Crew Lead, TLE-POC)
 *   "Admin lite" — can look up cases with limited purview, make changes that
 *   are logged in the immutable progress ledger. Partial permissions.
 *
 * Level 2 — Organizational Admin (Project Manager, Bursar, Org Admin, Admin)
 *   Full org-scoped case management. Can administer and review cases across
 *   all existing office tasks for their organization(s).
 *
 * Level 3 — Super Admin
 *   IT/account management, cross-organizational data view, platform
 *   configuration, user management, documentation/SOP management.
 *
 * All existing role strings continue to work — this layer adds a
 * permission_level on top without breaking backward compatibility.
 */

// ---------------------------------------------------------------------------
// Canonical role → permission level map
// ---------------------------------------------------------------------------

/** @var array<string, int> Role slug to permission level (0-3) */
const ARCHR_ROLE_LEVELS = [
    // Level 0 — Viewer
    'volunteer'     => 0,
    'requestor'     => 0,
    'crew-member'   => 0,

    // Level 1 — Office Worker
    'assessor'      => 1,
    'subcontractor' => 1,
    'envoy'         => 1,
    'crew-lead'     => 1,
    'tle-poc'       => 1,

    // Level 2 — Organizational Admin
    'project-manager' => 2,
    'bursar'        => 2,
    'org-admin'     => 2,
    'admin'         => 2,
    'caseworker'    => 2,

    // Level 3 — Super Admin
    'super-admin'   => 3,
];

/** Human-readable labels for each permission level */
const ARCHR_LEVEL_LABELS = [
    0 => 'Viewer',
    1 => 'Office Worker',
    2 => 'Organizational Admin',
    3 => 'Super Administrator',
];

/**
 * Capabilities each level grants. Higher levels inherit all lower capabilities.
 * Keys are capability flags used throughout the app.
 */
const ARCHR_LEVEL_CAPABILITIES = [
    0 => [
        'view_own_cases'      => true,
        'view_own_profile'    => true,
        'log_hours'           => true,
        'view_assigned_tasks' => true,
    ],
    1 => [
        'view_own_cases'      => true,
        'view_own_profile'    => true,
        'log_hours'           => true,
        'view_assigned_tasks' => true,
        // Level 1 adds:
        'view_org_cases'      => true,   // limited case lookup within org
        'edit_cases'          => true,   // changes logged in progress ledger
        'create_tasks'        => true,
        'log_progress'        => true,
        'view_assessments'    => true,
        'upload_documents'    => true,
    ],
    2 => [
        'view_own_cases'      => true,
        'view_own_profile'    => true,
        'log_hours'           => true,
        'view_assigned_tasks' => true,
        'view_org_cases'      => true,
        'edit_cases'          => true,
        'create_tasks'        => true,
        'log_progress'        => true,
        'view_assessments'    => true,
        'upload_documents'    => true,
        // Level 2 adds:
        'claim_cases'         => true,   // claim applications for org
        'manage_org_team'     => true,   // manage team accounts within org
        'view_org_metrics'    => true,   // org-level reports
        'manage_org_documents'=> true,   // full document management
        'approve_expenses'    => true,   // bursar/PM financial actions
        'change_case_status'  => true,
        'assign_staff'        => true,
    ],
    3 => [
        'view_own_cases'      => true,
        'view_own_profile'    => true,
        'log_hours'           => true,
        'view_assigned_tasks' => true,
        'view_org_cases'      => true,
        'edit_cases'          => true,
        'create_tasks'        => true,
        'log_progress'        => true,
        'view_assessments'    => true,
        'upload_documents'    => true,
        'claim_cases'         => true,
        'manage_org_team'     => true,
        'view_org_metrics'    => true,
        'manage_org_documents'=> true,
        'approve_expenses'    => true,
        'change_case_status'  => true,
        'assign_staff'        => true,
        // Level 3 adds:
        'view_all_orgs'       => true,   // cross-org data visibility
        'manage_users'        => true,   // create/edit/delete user accounts
        'manage_organizations'=> true,   // add/remove orgs from coalition
        'platform_config'     => true,   // system-wide settings
        'manage_documentation'=> true,   // help library & SOP management
        'view_audit_log'      => true,   // full activity ledger access
        'handle_helpdesk'     => true,   // support ticket management
        'onboarding_queue'    => true,   // new org/user onboarding
    ],
];

/**
 * Get the permission level (0-3) for a given role string.
 * Returns 0 for unknown roles (most restrictive default).
 */
function archr_get_permission_level(?string $role): int {
    if ($role === null || $role === '') {
        return 0;
    }
    $normalized = strtolower(trim($role));
    // Handle space-separated variants ("crew lead" → "crew-lead")
    $normalized = str_replace(' ', '-', $normalized);
    return ARCHR_ROLE_LEVELS[$normalized] ?? 0;
}

/**
 * Get the human-readable label for a permission level.
 */
function archr_get_level_label(int $level): string {
    return ARCHR_LEVEL_LABELS[$level] ?? 'Unknown';
}

/**
 * Check if the current user's role has a specific capability.
 * Higher levels inherit all lower-level capabilities.
 */
function archr_has_capability(?string $role, string $capability): bool {
    $level = archr_get_permission_level($role);
    return archr_has_capability_at_level($level, $capability);
}

/**
 * Check if a permission level grants a specific capability.
 */
function archr_has_capability_at_level(int $level, string $capability): bool {
    // Each level includes all capabilities of lower levels.
    // Walk from the given level down to 0, returning true on first match.
    for ($i = $level; $i >= 0; $i--) {
        if (!empty(ARCHR_LEVEL_CAPABILITIES[$i][$capability])) {
            return true;
        }
    }
    return false;
}

/**
 * Get all capabilities for the current role.
 * Returns the union of capabilities from level 0 up to the role's level.
 */
function archr_get_capabilities(?string $role): array {
    $level = archr_get_permission_level($role);
    $caps = [];
    for ($i = 0; $i <= $level; $i++) {
        foreach (ARCHR_LEVEL_CAPABILITIES[$i] as $cap => $granted) {
            if ($granted) {
                $caps[$cap] = true;
            }
        }
    }
    return $caps;
}

/**
 * Determine which roles a permission level can "act as."
 * Level 2 can act as any Level 0-2 role; Level 3 can act as any role.
 * This enables the "view as" / role-switching feature for admins.
 */
function archr_available_roles_for_level(int $level): array {
    $roles = [];
    foreach (ARCHR_ROLE_LEVELS as $role => $roleLevel) {
        if ($roleLevel <= $level) {
            $roles[] = $role;
        }
    }
    return $roles;
}

// ---------------------------------------------------------------------------
// Menu registry — canonical definition of all dashboard menu items
// ---------------------------------------------------------------------------

/**
 * All available menu items for the org-admin / Level 2+ dashboard.
 * Each item: key, icon, label, group, minLevel (0-3).
 * Only items at or below the user's permission level are shown.
 */
function archr_menu_registry(): array {
    return [
        // Core (always visible)
        ['key' => 'dashboard',    'icon' => 'fa-gauge-high',         'label' => 'Overview',         'group' => null,          'minLevel' => 0],
        ['key' => 'applications', 'icon' => 'fa-file-lines',        'label' => 'Applications',     'group' => null,          'minLevel' => 2],
        ['key' => 'case-search',  'icon' => 'fa-magnifying-glass',  'label' => 'Case Search',      'group' => null,          'minLevel' => 1],
        ['key' => 'documents',    'icon' => 'fa-bucket',            'label' => 'Documents Bucket', 'group' => null,          'minLevel' => 2],

        // Projects group
        ['key' => 'projects',     'icon' => 'fa-diagram-project',   'label' => 'Active Projects',  'group' => 'Projects',    'minLevel' => 2],
        ['key' => 'unclaimed',    'icon' => 'fa-hand-pointer',      'label' => 'Unclaimed Jobs',   'group' => 'Projects',    'minLevel' => 2],
        ['key' => 'escalations',  'icon' => 'fa-triangle-exclamation', 'label' => 'Escalations',   'group' => 'Projects',    'minLevel' => 2],
        ['key' => 'schedule',     'icon' => 'fa-calendar-days',     'label' => 'Schedule',         'group' => 'Projects',    'minLevel' => 2],
        ['key' => 'workflows',    'icon' => 'fa-sitemap',           'label' => 'Task Workflows',   'group' => 'Projects',    'minLevel' => 2],

        // Finance group
        ['key' => 'funding',       'icon' => 'fa-coins',             'label' => 'Funding & Budgets', 'group' => 'Finance',    'minLevel' => 2],
        ['key' => 'reimbursements','icon' => 'fa-money-bill-transfer','label' => 'Reimbursements',  'group' => 'Finance',    'minLevel' => 2],
        ['key' => 'invoices',      'icon' => 'fa-file-invoice-dollar','label' => 'Invoices',        'group' => 'Finance',    'minLevel' => 2],

        // Marketplace group
        ['key' => 'marketplace',   'icon' => 'fa-briefcase',        'label' => 'Marketplace',      'group' => 'Marketplace', 'minLevel' => 2],
        ['key' => 'eligible-jobs', 'icon' => 'fa-circle-check',     'label' => 'Eligible Jobs',    'group' => 'Marketplace', 'minLevel' => 2],

        // Admin group
        ['key' => 'team',         'icon' => 'fa-users',             'label' => 'Team',             'group' => 'Admin',       'minLevel' => 2],
        ['key' => 'review-queue', 'icon' => 'fa-clipboard-list',   'label' => 'Review Queue',     'group' => 'Admin',       'minLevel' => 2],
        ['key' => 'messages',     'icon' => 'fa-envelope',          'label' => 'Messages',         'group' => 'Admin',       'minLevel' => 2],
        ['key' => 'metrics',      'icon' => 'fa-chart-line',        'label' => 'Metrics',          'group' => 'Admin',       'minLevel' => 2],

        // Help
        ['key' => 'help',         'icon' => 'fa-circle-question',   'label' => 'Help',             'group' => null,          'minLevel' => 0],
    ];
}

/**
 * Get the default enabled menu items for a permission level.
 * Core items (dashboard, case-search, help) are always on by default.
 * Level 2+ items default to off until explicitly enabled.
 */
function archr_default_menu(int $level): array {
    $defaults = [];
    foreach (archr_menu_registry() as $item) {
        if ($item['minLevel'] <= $level) {
            if ($item['minLevel'] <= 1 || $item['key'] === 'dashboard' || $item['key'] === 'help') {
                $defaults[$item['key']] = true;
            }
        }
    }
    return $defaults;
}

/**
 * Get the user's effective menu config (saved prefs merged with defaults).
 */
function archr_user_menu_config(array $user, int $level): array {
    $saved = $user['menu_config'] ?? null;
    if (is_string($saved)) {
        $saved = json_decode($saved, true) ?: [];
    }
    if (!is_array($saved)) {
        $saved = [];
    }
    $defaults = archr_default_menu($level);
    return array_merge($defaults, $saved);
}
