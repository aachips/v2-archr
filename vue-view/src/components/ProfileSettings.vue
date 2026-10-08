<!--
  ProfileSettings — allows an authenticated user to update their basic
  information, toggle indefinite session persistence, and configure
  which columns appear in the case search results table.
-->
<template>
  <div class="profile-settings">
    <!-- Tabs -->
    <div class="profile-tabs">
      <button
        type="button"
        :class="['profile-tab', { active: activeTab === 'profile' }]"
        @click="activeTab = 'profile'"
      >Profile</button>
      <button
        type="button"
        :class="['profile-tab', { active: activeTab === 'security' }]"
        @click="activeTab = 'security'"
      >Security</button>
      <button
        type="button"
        :class="['profile-tab', { active: activeTab === 'data-source' }]"
        @click="activeTab = 'data-source'"
      >Data Source</button>
      <button
        type="button"
        :class="['profile-tab', { active: activeTab === 'columns' }]"
        @click="activeTab = 'columns'"
      >Search Columns</button>
    </div>

    <div class="profile-card">
      <!-- Profile Tab -->
      <template v-if="activeTab === 'profile'">
        <h1>Profile Settings</h1>

        <div v-if="successMsg" class="profile-msg profile-msg--success" role="status">
          {{ successMsg }}
        </div>
        <div v-if="errorMsg" class="profile-msg profile-msg--error" role="alert">
          {{ errorMsg }}
        </div>

        <form v-if="loaded" class="profile-form" @submit.prevent="handleSave">
          <label class="field" for="username">
            Username
            <input id="username" type="text" :value="username" disabled />
          </label>

          <label class="field" for="full_name">
            Full Name
            <input
              id="full_name"
              v-model.trim="fullName"
              type="text"
              placeholder="Your full name"
              required
            />
          </label>

          <label class="field" for="email">
            Email
            <input
              id="email"
              v-model.trim="email"
              type="email"
              placeholder="you@example.com"
              required
            />
          </label>

          <label class="field" for="phone">
            Phone
            <input
              id="phone"
              v-model.trim="phone"
              type="tel"
              placeholder="(optional)"
            />
          </label>

          <label class="field field--check" for="indefinite">
            <input id="indefinite" v-model="sessionIndefinite" type="checkbox" />
            <span>Keep me logged in indefinitely (uses a persistent session)</span>
          </label>

          <div class="form-actions">
            <button type="submit" class="btn-save" :disabled="saving">
              {{ saving ? 'Saving…' : 'Save Settings' }}
            </button>
          </div>
        </form>

        <div v-else class="profile-loading">
          <p>Loading profile…</p>
        </div>
      </template>

      <!-- Security Tab -->
      <template v-if="activeTab === 'security'">
        <h1>Change Password</h1>
        <p class="security-intro">
          Enter your current password, then choose a new one.
          The change takes effect immediately.
        </p>

        <div v-if="pwSuccess" class="profile-msg profile-msg--success" role="status">
          {{ pwSuccess }}
        </div>
        <div v-if="pwError" class="profile-msg profile-msg--error" role="alert">
          {{ pwError }}
        </div>

        <form class="profile-form" @submit.prevent="handleChangePassword">
          <label class="field" for="current_password">
            Current Password
            <input
              id="current_password"
              v-model="currentPassword"
              type="password"
              placeholder="Your current password"
              required
              autocomplete="current-password"
            />
          </label>

          <label class="field" for="new_password">
            New Password
            <input
              id="new_password"
              v-model="newPassword"
              type="password"
              placeholder="At least 8 characters"
              required
              autocomplete="new-password"
              minlength="8"
            />
          </label>

          <label class="field" for="confirm_password">
            Confirm New Password
            <input
              id="confirm_password"
              v-model="confirmPassword"
              type="password"
              placeholder="Repeat the new password"
              required
              autocomplete="new-password"
              minlength="8"
            />
          </label>

          <div class="form-actions">
            <button type="submit" class="btn-save" :disabled="pwSaving">
              {{ pwSaving ? 'Changing…' : 'Change Password' }}
            </button>
          </div>
        </form>
      </template>

      <!-- Data Source Tab -->
      <template v-if="activeTab === 'data-source'">
        <h1>Data Source</h1>
        <p class="columns-intro">
          Choose which database the application reads case data from.
          Changes take effect immediately and persist in your browser.
        </p>

        <div class="data-source-options">
          <label class="data-source-option" :class="{ active: dbSource === 'airtable-dummy' }">
            <input type="radio" name="dbSource" value="airtable-dummy" v-model="dbSource" @change="onDbSourceChange" />
            <div class="data-source-option__info">
              <strong>Airtable — Dummy Base</strong>
              <span>Test/demo data. Safe to experiment with.</span>
            </div>
          </label>

          <label class="data-source-option" :class="{ active: dbSource === 'airtable-anchor' }">
            <input type="radio" name="dbSource" value="airtable-anchor" v-model="dbSource" @change="onDbSourceChange" />
            <div class="data-source-option__info">
              <strong>Airtable — ANCHOR (Production)</strong>
              <span>Real coalition records. Requires valid PAT token.</span>
              <span v-if="!anchorBaseConfigured" class="data-source-option__warn">⚠ ANCHOR base ID not configured</span>
            </div>
          </label>

          <label class="data-source-option" :class="{ active: dbSource === 'postgresql' }">
            <input type="radio" name="dbSource" value="postgresql" v-model="dbSource" disabled />
            <div class="data-source-option__info">
              <strong>PostgreSQL (Coming Soon)</strong>
              <span>Direct PSQL reads via API bridge. Not yet available.</span>
            </div>
          </label>
        </div>

        <div v-if="dbSourceChanged" class="profile-msg profile-msg--success" role="status">
          ✓ Data source changed. Page will refresh in 1 second.
        </div>

        <div class="data-source__env">
          <h3>Environment Variables</h3>
          <table class="data-source__env-table">
            <thead><tr><th>Variable</th><th>Value</th><th>Status</th></tr></thead>
            <tbody>
              <tr><td><code>VUE_APP_AIRTABLE_API_KEY</code></td><td>{{ maskValue(apiKeyStatus) }}</td><td>{{ apiKeyStatus }}</td></tr>
              <tr><td><code>VUE_APP_AIRTABLE_BASE</code></td><td>{{ maskValue(dummyBaseStatus) }}</td><td>{{ dummyBaseStatus }}</td></tr>
              <tr><td><code>VUE_APP_AIRTABLE_ANCHOR_BASE</code></td><td>{{ maskValue(anchorBaseStatus) }}</td><td>{{ anchorBaseStatus }}</td></tr>
            </tbody>
          </table>
        </div>
      </template>

      <!-- Search Columns Tab -->
      <template v-if="activeTab === 'columns'">
        <h1>Search Results Columns</h1>
        <p class="columns-intro">
          Choose which columns appear in the case search results table.
          Changes take effect immediately.
        </p>

        <div v-if="columnsMsg" class="profile-msg profile-msg--success" role="status">
          {{ columnsMsg }}
        </div>

        <div class="columns-grid">
          <label
            v-for="col in allColumns"
            :key="col.key"
            class="col-toggle"
          >
            <input
              type="checkbox"
              :checked="visibleColumns.includes(col.key)"
              @change="toggleColumn(col.key, $event)"
            />
            <span>{{ col.label }}</span>
          </label>
        </div>

        <div class="form-actions">
          <button type="button" class="btn-save" @click="resetColumns">
            Reset to defaults
          </button>
        </div>
      </template>
    </div>
  </div>
</template>

<script>
import { getProfile, updateProfile } from '../services/profileService';
import { getAuthHeaders } from '../services/authService';

const COLUMN_PREF_KEY = 'archr:case-columns';

const ALL_COLUMNS = [
  { key: 'placecode',      label: 'Placecode' },
  { key: 'applicantName',  label: 'Applicant' },
  { key: 'address',        label: 'Address' },
  { key: 'city',           label: 'City' },
  { key: 'status',         label: 'Status' },
  { key: 'phase',          label: 'Phase' },
  { key: 'organization',   label: 'Organization' },
  { key: 'submittedAt',    label: 'Submitted' },
];

const DEFAULT_COLUMNS = ['placecode', 'applicantName', 'city', 'status', 'phase', 'organization', 'submittedAt'];

export default {
  name: 'ProfileSettings',

  data() {
    return {
      // Profile
      username: '',
      fullName: '',
      email: '',
      phone: '',
      sessionIndefinite: false,
      loaded: false,
      saving: false,
      successMsg: '',
      errorMsg: '',
      // Security
      currentPassword: '',
      newPassword: '',
      confirmPassword: '',
      pwSaving: false,
      pwSuccess: '',
      pwError: '',
      // Tabs
      activeTab: 'profile',
      // Data source
      dbSource: 'airtable-dummy',
      dbSourceChanged: false,
      anchorBaseConfigured: false,
      apiKeyStatus: '—',
      dummyBaseStatus: '—',
      anchorBaseStatus: '—',
      // Columns
      allColumns: ALL_COLUMNS,
      visibleColumns: [...DEFAULT_COLUMNS],
      columnsMsg: '',
    };
  },

  async created() {
    await this.loadProfile();
    this.loadColumns();
    this.loadDbSource();
  },

  methods: {
    // --- Profile ---
    async loadProfile() {
      try {
        const { user } = await getProfile();
        this.username = user.username || '';
        this.fullName = user.full_name || '';
        this.email = user.email || '';
        this.phone = user.phone || '';
        this.sessionIndefinite = !!user.session_indefinite;
        this.loaded = true;
      } catch (err) {
        this.errorMsg = err.message;
        this.loaded = true;
      }
    },

    async handleSave() {
      this.successMsg = '';
      this.errorMsg = '';
      this.saving = true;

      try {
        const { user } = await updateProfile({
          full_name: this.fullName,
          email: this.email,
          phone: this.phone,
          session_indefinite: this.sessionIndefinite,
        });

        if (this.$auth.user) {
          this.$auth.user.full_name = user.full_name;
          this.$auth.user.email = user.email;
        }

        this.successMsg = 'Profile settings saved.';
      } catch (err) {
        this.errorMsg = err.message;
      } finally {
        this.saving = false;
      }
    },

    async handleChangePassword() {
      this.pwSuccess = '';
      this.pwError = '';
      this.pwSaving = true;

      try {
        const res = await fetch('../app/vue_api/profile.php', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            ...getAuthHeaders(),
          },
          body: JSON.stringify({
            action: 'change_password',
            current_password: this.currentPassword,
            new_password: this.newPassword,
            confirm_password: this.confirmPassword,
          }),
        });

        const data = await res.json();
        if (!res.ok || !data.success) {
          throw new Error(data.error || 'Password change failed');
        }

        this.pwSuccess = data.message;
        this.currentPassword = '';
        this.newPassword = '';
        this.confirmPassword = '';
      } catch (err) {
        this.pwError = err.message;
      } finally {
        this.pwSaving = false;
      }
    },

    // --- Column preferences ---
    loadColumns() {
      try {
        const saved = JSON.parse(localStorage.getItem(COLUMN_PREF_KEY));
        if (Array.isArray(saved) && saved.length > 0) {
          this.visibleColumns = saved;
        }
      } catch (_) {
        // use defaults
      }
    },

    toggleColumn(key, event) {
      const checked = event.target.checked;
      if (checked && !this.visibleColumns.includes(key)) {
        this.visibleColumns.push(key);
      } else if (!checked) {
        this.visibleColumns = this.visibleColumns.filter(k => k !== key);
      }
      this.saveColumns();
    },

    resetColumns() {
      this.visibleColumns = [...DEFAULT_COLUMNS];
      this.saveColumns();
    },

    saveColumns() {
      localStorage.setItem(COLUMN_PREF_KEY, JSON.stringify(this.visibleColumns));
      this.columnsMsg = 'Column preferences saved.';
      // Notify the case list to re-render
      window.dispatchEvent(new CustomEvent('archr:columns-changed', {
        detail: { columns: [...this.visibleColumns] }
      }));
      setTimeout(() => { this.columnsMsg = ''; }, 2000);
    },
    // --- Data Source ---
    loadDbSource() {
      try {
        this.dbSource = localStorage.getItem('archr-db-source') || 'airtable-dummy';
      } catch (e) { this.dbSource = 'airtable-dummy'; }

      // Check env var status
      this.apiKeyStatus = process.env.VUE_APP_AIRTABLE_API_KEY ? 'Configured' : 'Not set';
      this.dummyBaseStatus = process.env.VUE_APP_AIRTABLE_BASE ? 'Configured' : 'Not set';
      this.anchorBaseConfigured = Boolean(process.env.VUE_APP_AIRTABLE_ANCHOR_BASE);
      this.anchorBaseStatus = process.env.VUE_APP_AIRTABLE_ANCHOR_BASE ? 'Configured' : 'Not set (placeholder)';
    },
    onDbSourceChange() {
      try {
        localStorage.setItem('archr-db-source', this.dbSource);
      } catch (e) { /* ignore */ }
      this.dbSourceChanged = true;
      setTimeout(function() {
        window.location.reload();
      }, 1000);
    },
    maskValue(val) {
      if (!val || val === 'Not set' || val === 'Not set (placeholder)') return val;
      return val.substring(0, 6) + '...' + val.substring(val.length - 4);
    }
  },
};
</script>

<style scoped>
.profile-settings {
  max-width: 640px;
  margin: 0 auto;
  padding: 2rem 1rem;
}

.profile-tabs {
  display: flex;
  gap: 0.25rem;
  margin-bottom: 0;
}

.profile-tab {
  padding: 0.6rem 1.2rem;
  border: 1px solid #d1d5db;
  border-bottom: none;
  border-radius: 8px 8px 0 0;
  background: #f9fafb;
  font-size: 0.9rem;
  font-weight: 500;
  color: #6b7280;
  cursor: pointer;
  transition: background 0.15s, color 0.15s;
}

.profile-tab.active {
  background: #fff;
  color: #1a1a1a;
  border-color: #e5e7eb;
  position: relative;
}

.profile-tab.active::after {
  content: '';
  position: absolute;
  bottom: -1px;
  left: 0;
  right: 0;
  height: 1px;
  background: #fff;
}

.profile-card {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  padding: 2rem;
  border: 1px solid #e5e7eb;
}

.profile-card h1 {
  font-size: 1.35rem;
  margin: 0 0 1.5rem;
  color: #1a1a1a;
}

.columns-intro {
  color: #6b7280;
  font-size: 0.875rem;
  margin: -0.75rem 0 1.25rem;
}

.security-intro {
  color: #6b7280;
  font-size: 0.875rem;
  margin: -0.75rem 0 1.25rem;
}

.profile-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.field {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  font-size: 0.875rem;
  font-weight: 500;
  color: #333;
}

.field input[type="text"],
.field input[type="email"],
.field input[type="tel"] {
  padding: 0.5rem 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 0.95rem;
  transition: border-color 0.15s;
}

.field input:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.15);
}

.field input:disabled {
  background: #f3f4f6;
  color: #6b7280;
  cursor: not-allowed;
}

.field--check {
  flex-direction: row;
  align-items: center;
  gap: 0.5rem;
}

.field--check input {
  margin: 0;
}

.profile-msg {
  padding: 0.6rem 0.8rem;
  border-radius: 6px;
  font-size: 0.875rem;
  margin-bottom: 1rem;
}

.profile-msg--success {
  background: #f0fdf4;
  color: #166534;
  border: 1px solid #bbf7d0;
}

.profile-msg--error {
  background: #fef2f2;
  color: #b91c1c;
  border: 1px solid #fecaca;
}

.columns-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.col-toggle {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 0.75rem;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  font-size: 0.875rem;
  cursor: pointer;
  transition: background 0.15s, border-color 0.15s;
}

.col-toggle:hover {
  background: #f9fafb;
  border-color: #9ca3af;
}

.col-toggle input {
  margin: 0;
}

.form-actions {
  margin-top: 0.5rem;
}

.btn-save {
  background: #1a56db;
  color: #fff;
  border: none;
  border-radius: 6px;
  padding: 0.6rem 1.2rem;
  font-size: 0.95rem;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.15s;
}

.btn-save:hover:not(:disabled) {
  background: #1e40af;
}

.btn-save:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.profile-loading {
  text-align: center;
  padding: 2rem 0;
  color: #666;
  font-size: 0.95rem;
}

@media (max-width: 992px) {
  .profile-settings {
    padding: 1rem 0.75rem;
    max-width: 100%;
  }

  .profile-card {
    padding: 1.25rem;
  }

  .profile-form {
    gap: 0.75rem;
  }

  .columns-grid {
    grid-template-columns: 1fr;
  }

  .profile-tabs {
    overflow-x: auto;
  }

  .profile-tab {
    white-space: nowrap;
    padding: 0.5rem 0.9rem;
    font-size: 0.85rem;
  }
}

@media (max-width: 480px) {
  .profile-settings {
    padding: 0.75rem 0.5rem;
  }

  .profile-card {
    padding: 1rem;
  }

  .profile-card h1 {
    font-size: 1.15rem;
  }
}

/* Data Source Tab */
.data-source-options { display: flex; flex-direction: column; gap: 12px; margin: 16px 0; }
.data-source-option { display: flex; align-items: flex-start; gap: 12px; padding: 16px; border: 2px solid var(--color-border-strong, #d1d5db); border-radius: 8px; cursor: pointer; transition: border-color 0.2s, background 0.2s; }
.data-source-option:hover { border-color: var(--color-accent, #3b82f6); }
.data-source-option.active { border-color: var(--color-accent, #3b82f6); background: var(--color-surface-alt, #f8fafc); }
.data-source-option input[type="radio"] { margin-top: 4px; accent-color: var(--color-accent, #3b82f6); }
.data-source-option input[type="radio"]:disabled { opacity: 0.4; cursor: not-allowed; }
.data-source-option__info { display: flex; flex-direction: column; gap: 2px; }
.data-source-option__info strong { font-size: 0.95rem; color: var(--color-text, #1e293b); }
.data-source-option__info span { font-size: 0.85rem; color: var(--color-text-muted, #64748b); }
.data-source-option__warn { color: var(--color-warning, #f59e0b) !important; font-weight: 600; font-size: 0.8rem !important; }
.data-source__env { margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--color-border, #e2e8f0); }
.data-source__env h3 { font-size: 0.9rem; color: var(--color-text-muted, #64748b); margin-bottom: 8px; }
.data-source__env-table { width: 100%; border-collapse: collapse; font-size: 0.8rem; }
.data-source__env-table th, .data-source__env-table td { text-align: left; padding: 6px 10px; border: 1px solid var(--color-border, #e2e8f0); }
.data-source__env-table th { background: var(--color-surface-alt, #f8fafc); font-weight: 600; }
.data-source__env-table code { font-family: monospace; font-size: 0.75rem; }
</style>
