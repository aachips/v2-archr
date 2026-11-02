<template>
  <div class="who-am-i">
    <div class="who-header">
      <h2>🔍 Who Am I?</h2>
      <p class="subtitle">Proof of identity, role, and capabilities</p>
    </div>

    <!-- Identity Card -->
    <div class="card">
      <h3>👤 Identity</h3>
      <div class="info-grid">
        <div class="info-label">Full Name</div>
        <div class="info-value">{{ auth.displayName }}</div>
        <div class="info-label">Email</div>
        <div class="info-value mono">{{ auth.user?.email || '—' }}</div>
        <div class="info-label">Status</div>
        <div class="info-value">
          <span class="badge active">Logged In</span>
        </div>
      </div>
    </div>

    <!-- Role & Permission Level -->
    <div class="card">
      <h3>🔑 Role &amp; Permission Level</h3>
      <div class="info-grid">
        <div class="info-label">Role</div>
        <div class="info-value">
          <span class="badge role">{{ auth.user?.role_display || formatRole(auth.user?.role) }}</span>
        </div>
        <div class="info-label">Role Code</div>
        <div class="info-value mono">{{ auth.user?.role || '—' }}</div>
        <div class="info-label">Permission Level</div>
        <div class="info-value">
          <span :class="['badge', 'level-' + roleLevel]">{{ roleLevelName }} (Level {{ roleLevel }})</span>
        </div>
      </div>
    </div>

    <!-- Capabilities -->
    <div class="card">
      <h3>⚡ Capabilities ({{ grantedCount }} granted)</h3>
      <div class="cap-grid">
        <div
          v-for="cap in allCapabilities"
          :key="cap.key"
          :class="['cap-item', cap.granted ? 'yes' : 'no']"
        >
          <span class="cap-icon">{{ cap.granted ? '✅' : '❌' }}</span>
          <span class="cap-label">{{ cap.label }}</span>
        </div>
      </div>
    </div>

    <!-- Available Menu Items -->
    <div class="card">
      <h3>📌 Available Menu Items ({{ menuCount }})</h3>
      <div class="cap-grid">
        <div
          v-for="item in availableMenuItems"
          :key="item.key"
          class="cap-item yes"
        >
          <span class="cap-icon">📋</span>
          <span class="cap-label">{{ item.label }} <span class="min-level">(Level {{ item.minLevel }}+)</span></span>
        </div>
      </div>
    </div>

    <!-- Debug Info -->
    <div class="card">
      <h3>🐛 Auth Store Data</h3>
      <pre class="debug-pre">{{ debugJson }}</pre>
    </div>
  </div>
</template>

<script>
/**
 * WhoAmI — proof-of-identity component for the Vue SPA.
 * Reads from the shared $auth store and shows role, level, and capabilities.
 */

// Capability definitions — must match app/lib/permissions.php ARCHR_LEVEL_CAPABILITIES
const LEVEL_CAPABILITIES = {
  0: {
    view_own_cases: 'View own cases',
    view_own_profile: 'View own profile',
  },
  1: {
    view_org_cases_limited: 'View org cases (limited)',
    edit_cases_logged: 'Edit cases (logged)',
    create_tasks: 'Create tasks',
    view_assessments: 'View assessments',
    upload_documents: 'Upload documents',
    log_hours: 'Log hours',
    view_assigned_tasks: 'View assigned tasks',
  },
  2: {
    claim_cases: 'Claim cases',
    manage_org_team: 'Manage org team',
    view_org_metrics: 'View org metrics',
    manage_documents: 'Manage documents',
    approve_expenses: 'Approve expenses',
    change_case_status: 'Change case status',
    assign_staff: 'Assign staff',
  },
  3: {
    view_all_orgs: 'View all orgs',
    manage_users: 'Manage users',
    manage_orgs: 'Manage orgs',
    platform_config: 'Platform config',
    manage_documentation: 'Manage documentation',
    view_audit_log: 'View audit log',
    handle_helpdesk: 'Handle helpdesk',
    onboarding_queue: 'Onboarding queue',
  },
};

// Role-specific capability overrides (roles that diverge from their level defaults)
const ROLE_CAPABILITY_OVERRIDES = {
  volunteer: {
    remove: ['view_own_cases'],
    add: ['view_assigned_tasks', 'log_hours'],
  },
  requestor: {
    remove: ['log_hours', 'view_assigned_tasks'],
    add: ['upload_documents', 'view_own_cases'],
  },
  'crew-member': {
    remove: ['view_own_cases'],
    add: ['view_assigned_tasks', 'log_hours', 'upload_documents'],
  },
  envoy: {
    add: ['view_all_orgs', 'manage_documentation', 'view_audit_log'],
  },
};

// Menu definitions — must match app/lib/permissions.php archr_menu_registry()
const MENU_ITEMS = [
  { key: 'dashboard',    label: 'Overview',          minLevel: 0 },
  { key: 'applications', label: 'Applications',      minLevel: 2 },
  { key: 'case-search',  label: 'Case Search',       minLevel: 1 },
  { key: 'documents',    label: 'Documents Bucket',  minLevel: 2 },
  { key: 'projects',     label: 'Active Projects',   minLevel: 2 },
  { key: 'unclaimed',    label: 'Unclaimed Jobs',    minLevel: 2 },
  { key: 'escalations',  label: 'Escalations',       minLevel: 2 },
  { key: 'schedule',     label: 'Schedule',          minLevel: 2 },
  { key: 'workflows',    label: 'Task Workflows',    minLevel: 2 },
  { key: 'funding',      label: 'Funding & Budgets', minLevel: 2 },
  { key: 'reimbursements', label: 'Reimbursements',  minLevel: 2 },
  { key: 'invoices',     label: 'Invoices',          minLevel: 2 },
  { key: 'marketplace',  label: 'Marketplace',       minLevel: 2 },
  { key: 'eligible-jobs', label: 'Eligible Jobs',    minLevel: 2 },
  { key: 'team',         label: 'Team',              minLevel: 2 },
  { key: 'review-queue', label: 'Review Queue',      minLevel: 2 },
  { key: 'messages',     label: 'Messages',          minLevel: 2 },
  { key: 'metrics',      label: 'Metrics',           minLevel: 2 },
  { key: 'help',         label: 'Help',              minLevel: 0 },
];

const LEVEL_LABELS = {
  0: 'Viewer',
  1: 'Office Worker',
  2: 'Organizational Admin',
  3: 'Super Administrator',
};

export default {
  name: 'WhoAmI',
  computed: {
    auth() {
      return this.$auth;
    },

    roleLevel() {
      return this.auth?.roleLevel ?? 0;
    },

    levelLabel() {
      return LEVEL_LABELS[this.roleLevel] || 'Unknown';
    },

    roleLevelName() {
      // Use the role_display from auth (e.g. "Subcontractor", "Volunteer")
      // rather than the generic level label (e.g. "Office Worker")
      const roleDisplay = this.auth?.user?.role_display;
      if (roleDisplay) return roleDisplay;
      return LEVEL_LABELS[this.roleLevel] || 'Unknown';
    },

    allCapabilities() {
      const caps = [];
      for (let lvl = 0; lvl <= this.roleLevel; lvl++) {
        const levelCaps = LEVEL_CAPABILITIES[lvl] || {};
        for (const [key, label] of Object.entries(levelCaps)) {
          if (!caps.find(c => c.key === key)) {
            caps.push({ key, label, granted: true });
          }
        }
      }
      // Now add all known capabilities, marking ungranted ones
      const allKnown = new Set();
      for (const levelCaps of Object.values(LEVEL_CAPABILITIES)) {
        for (const key of Object.keys(levelCaps)) {
          allKnown.add(key);
        }
      }
      const grantedKeys = new Set(caps.filter(c => c.granted).map(c => c.key));
      for (const key of allKnown) {
        if (!grantedKeys.has(key)) {
          const label = this.findLabel(key);
          caps.push({ key, label, granted: false });
        }
      }

      // Apply role-specific overrides
      const role = this.auth?.user?.role || '';
      const overrides = ROLE_CAPABILITY_OVERRIDES[role];
      if (overrides) {
        for (const key of (overrides.remove || [])) {
          const cap = caps.find(c => c.key === key);
          if (cap) cap.granted = false;
          allKnown.add(key);
        }
        for (const key of (overrides.add || [])) {
          const existing = caps.find(c => c.key === key);
          if (existing) {
            existing.granted = true;
          } else {
            caps.push({ key, label: this.findLabel(key), granted: true });
          }
        }
      }

      return caps.sort((a, b) => (b.granted ? 1 : 0) - (a.granted ? 1 : 0) || a.label.localeCompare(b.label));
    },

    grantedCount() {
      return this.allCapabilities.filter(c => c.granted).length;
    },

    availableMenuItems() {
      return MENU_ITEMS.filter(item => item.minLevel <= this.roleLevel);
    },

    menuCount() {
      return this.availableMenuItems.length;
    },

    debugJson() {
      return JSON.stringify(
        {
          user: this.auth?.user,
          isLoggedIn: this.auth?.isLoggedIn,
          role: this.auth?.role,
          roleLevel: this.auth?.roleLevel,
          displayName: this.auth?.displayName,
        },
        null,
        2
      );
    },
  },
  methods: {
    formatRole(role) {
      if (!role) return '—';
      return role.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
    },

    findLabel(key) {
      for (const levelCaps of Object.values(LEVEL_CAPABILITIES)) {
        if (levelCaps[key]) return levelCaps[key];
      }
      return key;
    },
  },
};
</script>

<style scoped>
.who-am-i {
  max-width: 800px;
  margin: 0 auto;
  padding: 1.5rem;
}

.who-header {
  margin-bottom: 1.5rem;
}

.who-header h2 {
  font-size: 1.5rem;
  color: var(--color-text, #1a1a2e);
  margin: 0 0 0.25rem;
}

.subtitle {
  color: var(--color-text-secondary, #666);
  margin: 0;
  font-size: 0.9rem;
}

.card {
  background: var(--color-surface, white);
  border: 1px solid var(--color-border, #e2e8f0);
  border-radius: 10px;
  padding: 1.25rem;
  margin-bottom: 1rem;
}

.card h3 {
  font-size: 1rem;
  color: var(--color-text, #16213e);
  margin: 0 0 0.75rem;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid var(--color-border, #e2e8f0);
}

.info-grid {
  display: grid;
  grid-template-columns: 140px 1fr;
  gap: 0.4rem 0.75rem;
  font-size: 0.9rem;
}

.info-label {
  color: var(--color-text-secondary, #64748b);
  font-weight: 500;
}

.info-value {
  color: var(--color-text, #1a1a2e);
}

.mono {
  font-family: ui-monospace, 'Cascadia Code', 'Consolas', monospace;
  font-size: 0.85rem;
}

.badge {
  display: inline-block;
  padding: 0.2rem 0.6rem;
  border-radius: 999px;
  font-size: 0.8rem;
  font-weight: 600;
}

.badge.role {
  background: #e0e7ff;
  color: #3730a3;
}

.badge.active {
  background: #dcfce7;
  color: #166534;
}

.badge.level-0 { background: #64748b; color: white; }
.badge.level-1 { background: #059669; color: white; }
.badge.level-2 { background: #2563eb; color: white; }
.badge.level-3 { background: #7c3aed; color: white; }

.cap-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 0.4rem;
}

.cap-item {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  padding: 0.35rem 0.5rem;
  border-radius: 6px;
  font-size: 0.8rem;
}

.cap-item.yes {
  background: var(--color-surface-alt, #f0fdf4);
  border-left: 3px solid #22c55e;
}

.cap-item.no {
  background: var(--color-surface-warn, #fef2f2);
  border-left: 3px solid #ef4444;
}

.min-level {
  color: var(--color-text-secondary, #999);
  font-size: 0.75rem;
}

.debug-pre {
  background: #1e293b;
  color: #e2e8f0;
  padding: 0.75rem;
  border-radius: 6px;
  overflow-x: auto;
  font-size: 0.75rem;
  line-height: 1.5;
  margin: 0;
}
</style>
