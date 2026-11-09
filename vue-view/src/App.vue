<template>
  <!-- Show login when not authenticated -->
  <LoginPage
    v-if="!authenticated && !initializing"
    @logged-in="onLoginSuccess"
  />

  <!-- Show loading spinner while verifying stored token -->
  <div v-else-if="initializing" class="auth-init">
    <p>Loading…</p>
  </div>

  <!-- Show the app when authenticated -->
  <div v-else-if="authenticated" id="app" class="shell" :data-theme="theme">
    <AppHeader
      :cases="cases"
      :role="effectiveRole"
      :theme="theme"
      :lang="lang"
      :user-name="$auth.displayName"
      @open-case="openCase"
      @set-role="handleRoleSwitch"
      @toggle-theme="toggleTheme"
      @set-lang="lang = $event"
      @logout="onLogout"
      @open-profile="go('profile')"
      @toggle-mobile="mobileSidebarOpen = !mobileSidebarOpen"
    />

    <div class="shell__body">
      <AppSidebar
        :nav="navItems"
        :view="view"
        :case-open="Boolean(selectedCase)"
        :mobile-open="mobileSidebarOpen"
        @go="handleNav"
        @close-mobile="mobileSidebarOpen = false"
      />
      <div v-if="mobileSidebarOpen" class="sidebar-overlay" @click="mobileSidebarOpen = false"></div>

      <main class="content">
        <!-- Heads Up Display — context bar for the current view -->
        <AppHUD :view="view" :user-name="$auth.displayName" :role="effectiveRole" />

        <!-- Airtable warning only shows when on an Airtable-dependent view -->
        <p v-if="!configured && needsAirtable" class="notice">
          Airtable isn't configured yet. Copy <code>.env.example</code> to
          <code>.env</code>, fill in your credentials, set your field names in
          <code>src/config/caseFields.js</code>, then restart the dev server.
        </p>
        <p v-else-if="error" class="notice notice--error">
          {{ error }}
          <button type="button" class="notice__dismiss" @click="error = ''">Dismiss</button>
        </p>

        <!-- Views that don't need Airtable — always render when their view is active -->
        <SuperAdminView v-if="view === 'superadmin-orgs' || view === 'superadmin-users'" ref="superAdmin" />
        <RequestorView v-else-if="view === 'requestor'" />
        <AssessorView v-else-if="view === 'assessor'" />
        <WhoAmI v-else-if="view === 'whoami'" />
        <VolunteerWelcome v-else-if="view === 'volunteer-welcome'" />
        <VolunteerIntakeForm v-else-if="view === 'volunteer-intake'" />
        <VolunteerApplications v-else-if="view === 'volunteer-apps'" />
        <AMICalculator v-else-if="view === 'helpful-tools'" />
        <WelcomeView v-else-if="view === 'welcome'" />
        <ProfileSettings v-else-if="view === 'profile'" />
        <ActivityLog v-else-if="view === 'activity'" />

        <!-- Views that DO need Airtable — only render when configured -->
        <template v-if="configured">
          <CaseReview
            v-if="selectedCase"
            :case-item="selectedCase"
            :cases="cases"
            :role="role"
            :saving="saving"
            @back="selectedCase = null"
            @save="onSaveContact"
            @open-case="openCase"
          />
          <FilterableCaseList
            v-else-if="view === 'search' && effectiveRole !== 'volunteer'"
            :cases="cases"
            :loading="loading"
            @select="openCase"
          />
          <Marketplace
            v-else-if="view === 'marketplace'"
            :cases="cases"
            @open-application="openCase"
          />
          <QuickTasks v-else-if="view === 'tasks'" :cases="cases" />
          <DocumentsBucket v-else-if="view === 'documents'" />
          <ComponentLibrary v-else-if="view === 'components'" :cases="cases" />
        </template>
      </main>
    </div>
    <SupportChat v-if="authenticated" />
  </div>
</template>

<script>
// The demo is self-contained: views and components live in ./components,
// docs in ./docs. Canonical library versions of the list/review components
// remain in elemental-integration/components/working-components/.
//
// Shell: AppHeader (topbar) + AppSidebar (nav) + the active view. Demo-wide
// chrome state lives here: role (permission preview), theme, lang. The
// theme/lang choices persist in localStorage; role always starts at the
// fullest view (super-admin).
//
// The Component Library is a hidden/dev-only view accessible via #components
// hash in the URL (e.g. http://v2-archr.test/portal/#components).
import AppHeader from "./components/layout/AppHeader.vue";
import AppSidebar from "./components/layout/AppSidebar.vue";
import AppHUD from "./components/layout/AppHUD.vue";
import FilterableCaseList from "./components/FilterableCaseList.vue";
import CaseReview from "./components/CaseReview.vue";
import QuickTasks from "./components/QuickTasks.vue";
import ActivityLog from "./components/ActivityLog.vue";
import LoginPage from "./components/LoginPage.vue";
import DocumentsBucket from "./components/DocumentsBucket.vue";
import ProfileSettings from "./components/ProfileSettings.vue";
import SupportChat from "./components/SupportChat.vue";
import ComponentLibrary from "./components/ComponentLibrary.vue";
import Marketplace from "./components/Marketplace.vue";
import WhoAmI from "./components/WhoAmI.vue";
import WelcomeView from "./components/WelcomeView.vue";
import SuperAdminView from "./components/SuperAdminView.vue";
import RequestorView from "./components/RequestorView.vue";
import AssessorView from "./components/AssessorView.vue";
import VolunteerWelcome from "./components/VolunteerWelcome.vue";
import VolunteerIntakeForm from "./components/VolunteerIntakeForm.vue";
import VolunteerApplications from "./components/VolunteerApplications.vue";
import AMICalculator from "./components/AMICalculator.vue";
import { fetchCases, isConfigured, saveCaseContact } from "./services/caseService";
import { translate } from "./config/i18n";
import { logActivity } from "./services/authService";

export default {
  name: "App",
  components: {
    AppHeader,
    AppSidebar,
    AppHUD,
    FilterableCaseList,
    CaseReview,
    QuickTasks,
    ActivityLog,
    LoginPage,
    DocumentsBucket,
    ProfileSettings,
    SupportChat,
    ComponentLibrary,
    Marketplace,
    WhoAmI,
    WelcomeView,
    SuperAdminView,
    RequestorView,
    AssessorView,
    VolunteerWelcome,
    VolunteerIntakeForm,
    VolunteerApplications,
    AMICalculator
  },
  data() {
    return {
      view: "search",
      cases: [],
      selectedCase: null,
      loading: false,
      saving: false,
      error: "",
      configured: isConfigured(),
      role: "super-admin",
      theme: "light",
      lang: "en",
      mobileSidebarOpen: false,
    };
  },

  computed: {
    // Reactive auth state from the shared store
    authenticated() {
      return this.$auth.isLoggedIn;
    },
    initializing() {
      return this.$auth.initializing;
    },
    needsAirtable() {
      // These views require Airtable data
      return ['search', 'marketplace', 'tasks', 'documents', 'components', 'caseReview'].includes(this.view);
    },

    // The effective role — always use $auth.role as source of truth.
    // The local `role` data only matters for multi-role preview switching.
    effectiveRole() {
      const level = this.$auth?.roleLevel ?? 0;
      const authRole = this.$auth?.role || '';
      return (level >= 2) ? this.role : authRole;
    },

    navItems() {
      const level = this.$auth?.roleLevel ?? 0;
      const effectiveRole = this.effectiveRole;

      // Super Admin gets a special nav (only when not viewing as another role)
      if (level >= 3 && effectiveRole === 'super-admin') {
        return [
          { view: 'superadmin-orgs', label: 'My Organizations',       minLevel: 3 },
          { view: 'superadmin-users', label: 'User Account Directory', minLevel: 3 },
          { view: 'volunteer-apps',  label: 'Volunteer Applications', minLevel: 3 },
          { view: 'whoami',           label: 'Who Am I?',              minLevel: 0 },
          { view: 'profile',          label: 'Profile',                minLevel: 0 },
        ];
      }

      // Role-specific nav items
      if (effectiveRole === 'subcontractor') {
        return [
          { view: 'marketplace', label: 'Marketplace', minLevel: 1 },
          { view: 'welcome',     label: 'Welcome',     minLevel: 0 },
          { view: 'whoami',      label: 'Who Am I?',   minLevel: 0 },
          { view: 'profile',     label: 'Profile',     minLevel: 0 },
        ];
      }

      if (effectiveRole === 'volunteer') {
        return [
          { view: 'volunteer-welcome', label: 'Welcome',      minLevel: 0 },
          { view: 'volunteer-intake',  label: 'Apply',        minLevel: 0 },
          { view: 'profile',           label: 'Profile',      minLevel: 0 },
        ];
      }

      if (effectiveRole === 'requestor') {
        return [
          { view: 'requestor', label: 'My Application',  minLevel: 0 },
          { view: 'whoami',    label: 'Who Am I?',        minLevel: 0 },
          { view: 'profile',   label: 'Profile',          minLevel: 0 },
        ];
      }

      // Level 2 admins (org-admin, admin, project-manager, bursar, caseworker, envoy)
      const level2Roles = ['org-admin', 'admin', 'project-manager', 'bursar', 'caseworker', 'envoy'];
      if (level2Roles.includes(effectiveRole)) {
        return [
          { view: 'search',          label: 'Case Search',           minLevel: 2 },
          { view: 'volunteer-apps',  label: 'Volunteers',            minLevel: 2 },
          { view: 'helpful-tools',   label: 'Helpful Tools',         minLevel: 2 },
          { view: 'whoami',          label: 'Who Am I?',             minLevel: 0 },
          { view: 'profile',         label: 'Profile',               minLevel: 0 },
        ];
      }

      if (effectiveRole === 'assessor') {
        return [
          { view: 'whoami',              label: 'Who Am I?',              minLevel: 0 },
          { view: 'assessor',            label: "Today's Assessments",     minLevel: 1 },
          { view: 'marketplace',         label: 'Assessment Marketplace', minLevel: 1 },
          { view: 'assessor-last',       label: 'Last Assessment',        minLevel: 1 },
          { view: 'assessor-calendar',   label: 'Assessment Calendar',    minLevel: 1 },
          { view: 'assessor-messages',   label: 'Messages & Alerts',      minLevel: 1 },
          { view: 'profile',             label: 'Profile',                minLevel: 0 },
        ];
      }

      // Default: level-gated items for org admins, super admins, and office workers
      const all = [
        { view: 'welcome',     label: 'Welcome',             minLevel: 0 },
        { view: 'search',      label: this.t('nav.search'),  minLevel: 0 },
        { view: 'marketplace', label: 'Marketplace',         minLevel: 1 },
        { view: 'whoami',      label: 'Who Am I?',           minLevel: 0 },
        { view: 'tasks',       label: this.t('nav.tasks'),   minLevel: 0 },
        { view: 'activity',    label: 'Activity Log',        minLevel: 1 },
        { view: 'documents',   label: 'Documents Bucket',    minLevel: 2 },
        { view: 'profile',     label: 'Profile',             minLevel: 0 },
      ];
      return all.filter(item => item.minLevel <= level);
    },
  },
  watch: {
    theme(value) {
      localStorage.setItem("archr-theme", value);
    },
    lang(value) {
      localStorage.setItem("archr-lang", value);
    }
  },
  created() {
    this.theme = localStorage.getItem("archr-theme") || "light";
    this.lang = localStorage.getItem("archr-lang") || "en";

    // Check URL hash for hidden routes (e.g. #components)
    if (window.location.hash === '#components') {
      this.view = 'components';
    }

    // Listen for hash changes
    var self = this;
    window.addEventListener('hashchange', function() {
      if (window.location.hash === '#components') {
        self.view = 'components';
      } else if (self.view === 'components') {
        self.view = 'search';
      }
    });

    // Set default view based on stored token (sync check)
    const storedToken = localStorage.getItem('archr_auth_token');
    if (storedToken) {
      try {
        const parts = storedToken.split('.');
        if (parts.length === 3) {
          const payload = JSON.parse(atob(parts[1].replace(/-/g, '+').replace(/_/g, '/')));
          if (payload.role_level >= 3) {
            this.view = 'superadmin-orgs';
          } else if (payload.role === 'requestor') {
            this.view = 'requestor';
          }
        }
      } catch (_) { /* ignore decode errors */ }
    }

    // Initialize auth (checks for stored token, verifies it)
    this.$auth.init().then(() => {
      // If not already set to a role-specific view, re-check after auth resolves
      if (!['superadmin-orgs', 'superadmin-users', 'requestor'].includes(this.view) && this.$auth.isLoggedIn) {
        const level = this.$auth?.roleLevel ?? 0;
        const role = this.$auth?.role || '';

        // Check user's default page preference first
        const savedDefault = localStorage.getItem('archr-default-page');
        if (savedDefault && ['whoami', 'welcome', 'marketplace'].includes(savedDefault)) {
          this.view = savedDefault;
        } else if (level >= 3) {
          this.view = 'superadmin-orgs';
        } else if (role === 'requestor') {
          this.view = 'requestor';
        } else if (role === 'assessor') {
          this.view = savedDefault || 'whoami';
        } else if (role === 'volunteer') {
          this.view = 'volunteer-welcome';
        }
      }
      // Try to load cases after auth restores
      if (this.$auth.isLoggedIn) {
        const role = this.$auth?.role || '';
        if (role !== 'volunteer') {
          this.loadCases();
        }
      }
    });
  },

  methods: {
    handleRoleSwitch(newRole) {
      // Role switch from header — change the active view based on the selected role context
      this.role = newRole;
      const roleMap = {
        'super-admin': 'superadmin-orgs',
        'org-admin': 'search',
        'staff': 'search',
        'assessor': 'assessor',
        'requestor': 'requestor',
        'volunteer': 'volunteer-welcome',
        'subcontractor': 'marketplace',
      };
      const defaultView = roleMap[newRole] || 'search';
      // Always switch to the target view when changing roles
      this.view = defaultView;
    },

    loadCases() {
      this.loading = true;
      fetchCases()
        .then(cases => {
          this.cases = cases;
          this.loading = false;
        })
        .catch(err => {
          this.error = "Couldn't load cases: " + ((err && err.message) || String(err));
          this.loading = false;
        });
    },

    onLoginSuccess() {
      // After successful login, always try to load cases
      // fetchCases() handles the unconfigured case gracefully
      this.loadCases();
    },

    async onLogout() {
      await this.$auth.logout();
      this.cases = [];
      this.selectedCase = null;
      this.view = "search";
    },

    t(key) {
      return translate(this.lang, key);
    },
    go(view, section) {
      this.view = view;
      this.selectedCase = null;
      this.error = "";
      if (section) {
        this.$nextTick(() => {
          const el = document.getElementById(section);
          if (el) el.scrollIntoView({ behavior: 'smooth' });
        });
      }
      // If switching to superadmin-users, scroll to users section
      if (view === 'superadmin-users') {
        this.$nextTick(() => {
          const el = document.getElementById('users');
          if (el) el.scrollIntoView({ behavior: 'smooth' });
        });
      }
    },

    handleNav(item) {
      if (item.external && item.href) {
        window.open(item.href, '_blank');
      } else {
        this.go(item.view, item.targetSection);
      }
    },
    openCase(caseItem) {
      this.selectedCase = caseItem;
      this.error = "";
    },
    toggleTheme() {
      this.theme = this.theme === "dark" ? "light" : "dark";
    },
    // CaseReview emitted edited contact fields. Persist to the Airtable
    // `applications` table, then reflect the change locally.
    onSaveContact(changes) {
      const current = this.selectedCase;
      this.saving = true;

      // Capture old values before applying changes
      const fieldMap = {
        firstName: 'first name',
        lastName: 'last name',
        email: 'email',
        phone: 'phone',
      };
      const oldValues = {};
      const newValues = {};
      for (const key of Object.keys(changes)) {
        oldValues[key] = current[key] !== null && current[key] !== undefined ? current[key] : '';
        newValues[key] = changes[key];
      }

      saveCaseContact(current, changes)
        .then(() => {
          // Log to the PostgreSQL activity_log (audit trail)
          const changedFields = Object.keys(changes);
          if (changedFields.length > 0) {
            // Ledger entry (summary)
            const prettyNames = changedFields.map(f => fieldMap[f] || f);
            logActivity({
              category: 'application',
              action: 'application_updated',
              summary: `Applicant contact updated: ${prettyNames.join(', ')}`,
              application_id: null, // Vue doesn't know PostgreSQL applications.id
              case_id: Number(current.id) || null,
              details: { changed_fields: changedFields, household: current.displayName || current.applicantName || '' },
              source: 'vue',
            }).then(ledgerResult => {
              // Log granular detail rows (old → new) for each changed field
              if (ledgerResult && ledgerResult.event_id) {
                const detailPromises = changedFields.map(field =>
                  logActivity({
                    category: 'application',
                    action: 'application_field_changed',
                    summary: `${fieldMap[field] || field}: "${oldValues[field]}" → "${newValues[field]}"`,
                    application_id: null, // Vue doesn't know PostgreSQL applications.id
                    case_id: Number(current.id) || null,
                    // Top-level fields for the PHP endpoint to detect detail row
                    ledger_id: ledgerResult.event_id,
                    field_name: field,
                    old_value: String(oldValues[field] || ''),
                    new_value: String(newValues[field] || ''),
                    details: {
                      ledger_id: ledgerResult.event_id,
                      field_name: field,
                      old_value: String(oldValues[field] || ''),
                      new_value: String(newValues[field] || ''),
                      household: current.displayName || current.applicantName || '',
                    },
                    source: 'vue',
                  })
                );
                Promise.all(detailPromises).catch(() => {});
              }
            });
          }

          const first = changes.firstName !== undefined ? changes.firstName : current.firstName;
          const last = changes.lastName !== undefined ? changes.lastName : current.lastName;
          const updated = Object.assign({}, current, changes, {
            firstName: first,
            lastName: last,
            applicantName: [first, last].filter(Boolean).join(" "),
            hasApplication: true
          });
          this.selectedCase = updated;
          const idx = this.cases.findIndex(c => c.id === updated.id);
          if (idx !== -1) this.$set(this.cases, idx, updated);
          this.saving = false;
        })
        .catch(err => {
          this.error = "Couldn't save to Airtable: " + ((err && err.message) || String(err));
          this.saving = false;
        });
    }
  }
};
</script>

<style scoped>
.auth-init {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  color: #666;
  font-size: 1rem;
}

.shell {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.shell__body {
  display: flex;
  flex: 1;
}

.content {
  flex: 1;
  min-width: 0;
  padding: 1rem;
  background: #f9fafb;
}

.sidebar-overlay {
  display: none;
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.3);
  z-index: 150;
}

@media (max-width: 992px) {
  .sidebar-overlay {
    display: block;
  }

  .shell__body {
    position: relative;
  }

  .content {
    padding: 0.75rem;
  }
}
</style>