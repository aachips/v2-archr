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
      :role="role"
      :theme="theme"
      :lang="lang"
      :user-name="$auth.displayName"
      @open-case="openCase"
      @set-role="role = $event"
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
        <p v-if="!configured" class="notice">
          Airtable isn't configured yet. Copy <code>.env.example</code> to
          <code>.env</code>, fill in your credentials, set your field names in
          <code>src/config/caseFields.js</code>, then restart the dev server.
        </p>
        <p v-else-if="error" class="notice notice--error">
          {{ error }}
          <button type="button" class="notice__dismiss" @click="error = ''">Dismiss</button>
        </p>
        <template v-else>
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
            v-else-if="view === 'search'"
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
          <ActivityLog v-else-if="view === 'activity'" />
          <DocumentsBucket v-else-if="view === 'documents'" />
          <ProfileSettings v-else-if="view === 'profile'" />
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
import { fetchCases, isConfigured, saveCaseContact } from "./services/caseService";
import { translate } from "./config/i18n";
import { logActivity } from "./services/authService";

export default {
  name: "App",
  components: {
    AppHeader,
    AppSidebar,
    FilterableCaseList,
    CaseReview,
    QuickTasks,
    ActivityLog,
    LoginPage,
    DocumentsBucket,
    ProfileSettings,
    SupportChat,
    ComponentLibrary,
    Marketplace
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

    navItems() {
      return [
        { view: "search", label: this.t("nav.search") },
        { view: "marketplace", label: "Marketplace" },
        { view: null, label: this.t("nav.help"), href: "../help.php", external: true },
        { view: "tasks", label: this.t("nav.tasks") },
        { view: "activity", label: "Activity Log" },
        { view: "documents", label: "Documents Bucket" }
      ];
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

    // Initialize auth (checks for stored token)
    this.$auth.init().then(() => {
      // Try to load cases after auth restores
      if (this.$auth.isLoggedIn) {
        this.loadCases();
      }
    });
  },

  methods: {
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
    go(view) {
      this.view = view;
      this.selectedCase = null;
      this.error = "";
    },

    handleNav(item) {
      if (item.external && item.href) {
        window.open(item.href, '_blank');
      } else {
        this.go(item.view);
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