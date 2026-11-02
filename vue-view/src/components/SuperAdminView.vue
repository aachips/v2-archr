<template>
  <div class="super-admin">
    <p class="login-banner" role="status">
      <i class="fas fa-shield-halved"></i>
      <span>You are logged in as a Super-Administrator. Changes made here affect every organization in the coalition.</span>
    </p>

    <section class="dash-hero">
      <div>
        <h2>System Dashboard</h2>
        <p>Manage coalition organizations, system accounts, and platform configuration.</p>
      </div>
    </section>

    <!-- KPI Cards -->
    <section class="dash-section">
      <h3 class="dash-section-title"><i class="fas fa-chart-pie"></i> Coalition Overview</h3>
      <div class="kpi-grid">
        <div class="kpi"><span class="kpi-label">Organizations</span><span class="kpi-value">{{ counts.org_count || 0 }}</span></div>
        <div class="kpi kpi-blue"><span class="kpi-label">System Users</span><span class="kpi-value">{{ counts.user_count || 0 }}</span></div>
        <div class="kpi kpi-amber"><span class="kpi-label">Submissions</span><span class="kpi-value">{{ counts.submission_count || 0 }}</span></div>
        <div class="kpi kpi-green"><span class="kpi-label">Cases</span><span class="kpi-value">{{ counts.case_count || 0 }}</span></div>
      </div>
    </section>

    <!-- My Organizations -->
    <section class="dash-section" id="organizations">
      <h3 class="dash-section-title"><i class="fas fa-building"></i> My Organizations</h3>
      <table class="data-table">
        <thead><tr><th>Code</th><th>Name</th><th>Funding</th><th>Max Active</th><th>Auto Claim</th><th>Status</th><th>Actions</th></tr></thead>
        <tbody>
          <template v-for="org in organizations">
            <tr :key="org.id">
              <td>{{ org.organization_code }}</td>
              <td>{{ org.organization_name }}<br><small v-if="org.description">{{ org.description }}</small></td>
              <td>{{ org.funding_limit != null ? '$' + Number(org.funding_limit).toLocaleString('en-US', {minimumFractionDigits:2}) : '—' }}</td>
              <td>{{ org.max_active_applications ?? '—' }}</td>
              <td>{{ org.auto_claim_enabled ? 'Yes' : 'No' }}</td>
              <td><span :class="['pill', org.is_active ? 'pill-green' : 'pill-amber']">{{ org.is_active ? 'Active' : 'Inactive' }}</span></td>
              <td><button class="btn small" @click="toggleOrgEdit(org.id)">Edit</button></td>
            </tr>
            <tr :key="'edit-' + org.id" v-show="editingOrg === org.id" class="edit-row">
              <td colspan="7">
                <form class="inline-form" @submit.prevent="updateOrg(org)">
                  <div class="field"><label>Name</label><input v-model="org.organization_name" type="text" required></div>
                  <div class="field"><label>Contact Email</label><input v-model="org.contact_email" type="email"></div>
                  <div class="field"><label>Phone</label><input v-model="org.contact_phone" type="tel"></div>
                  <div class="field"><label>Description</label><input v-model="org.description" type="text"></div>
                  <div class="field"><label>Funding Limit</label><input v-model.number="org.funding_limit" type="number" step="0.01"></div>
                  <div class="field"><label>Max Active Apps</label><input v-model.number="org.max_active_applications" type="number"></div>
                  <div class="field"><label>Notification Email</label><input v-model="org.notification_email" type="email"></div>
                  <div class="field chk"><label><input v-model="org.auto_claim_enabled" type="checkbox"> Auto-claim</label></div>
                  <div class="field chk"><label><input v-model="org.is_active" type="checkbox"> Active</label></div>
                  <button class="btn btn-primary" type="submit">Save</button>
                </form>

                <hr class="edit-divider">
                <h4>Eligibility rules for {{ org.organization_name }}</h4>

                <!-- Preset loader -->
                <form class="preset-form" @submit.prevent="bulkPreset(org.id)">
                  <div class="preset-field">
                    <label>Load Preset</label>
                    <select :value="orgPresets[org.id] || ''" @input="orgPresets[org.id] = $event.target.value">
                      <option value="">— Select a preset —</option>
                      <option value="habitat_for_humanity">Asheville Habitat for Humanity (10 rules)</option>
                      <option value="community_housing_coalition">Community Housing Coalition (8 rules)</option>
                      <option value="poder_emma">PODER Emma — Disaster (8 rules)</option>
                    </select>
                  </div>
                  <button type="submit" class="btn btn-primary">Load Preset</button>
                </form>

                <table class="data-table small">
                  <thead><tr><th>Criteria</th><th>Operator</th><th>Value</th><th>Priority</th><th>Active</th><th></th></tr></thead>
                  <tbody>
                    <tr v-for="rule in orgEligibilityRules(org.id)" :key="rule.id">
                      <td>{{ rule.type_name }}</td>
                      <td>{{ rule.rule_operator }}</td>
                      <td>{{ rule.rule_value }}</td>
                      <td>{{ rule.priority }}</td>
                      <td><span :class="['pill', rule.is_active ? 'pill-green' : 'pill-amber']">{{ rule.is_active ? 'Yes' : 'No' }}</span></td>
                      <td><button class="btn small" @click="deleteRule(rule.id)">Delete</button></td>
                    </tr>
                    <tr v-if="!orgEligibilityRules(org.id).length"><td colspan="6" class="muted">No rules for this organization.</td></tr>
                  </tbody>
                </table>

                <form class="inline-form" @submit.prevent="addRule(org.id)">
                  <div class="field"><label>Criteria</label>
                    <select v-model="newRuleFor(org.id).criteria_type_id" required>
                      <option value="">— Select —</option>
                      <option v-for="ct in criteriaTypes" :key="ct.id" :value="ct.id">{{ ct.type_name }}</option>
                    </select>
                  </div>
                  <div class="field"><label>Operator</label>
                    <select v-model="newRuleFor(org.id).rule_operator">
                      <option>equals</option><option>not_equals</option><option>greater_than</option>
                      <option>less_than</option><option>between</option><option>in_list</option>
                    </select>
                  </div>
                  <div class="field"><label>Value</label><input v-model="newRuleFor(org.id).rule_value" type="text" required></div>
                  <div class="field"><label>Priority</label><input v-model.number="newRuleFor(org.id).priority" type="number" value="0"></div>
                  <button class="btn btn-primary" type="submit">Add Rule</button>
                </form>

                <hr class="edit-divider">
                <div class="danger-zone-inline">
                  <h4><i class="fas fa-triangle-exclamation"></i> Danger Zone</h4>
                  <p>Deleting this organization will remove its users, eligibility rules, funding sources, assignments, queue entries, and case claims. A server-side backup is saved automatically.</p>
                  <button class="btn btn-danger" @click="deleteOrg(org)">Delete this organization</button>
                </div>
              </td>
            </tr>
          </template>
        </tbody>
      </table>

      <h4 style="margin-top:2rem;">Add Organization</h4>
      <form class="inline-form" @submit.prevent="createOrg">
        <div class="field"><label>Code</label><input v-model="newOrg.organization_code" type="text" required maxlength="20"></div>
        <div class="field"><label>Name</label><input v-model="newOrg.organization_name" type="text" required></div>
        <div class="field"><label>Contact Email</label><input v-model="newOrg.contact_email" type="email"></div>
        <div class="field"><label>Phone</label><input v-model="newOrg.contact_phone" type="tel"></div>
        <div class="field"><label>Description</label><input v-model="newOrg.description" type="text"></div>
        <div class="field"><label>Funding Limit</label><input v-model.number="newOrg.funding_limit" type="number" step="0.01"></div>
        <div class="field"><label>Max Active Apps</label><input v-model.number="newOrg.max_active_applications" type="number"></div>
        <div class="field"><label>Notification Email</label><input v-model="newOrg.notification_email" type="email"></div>
        <div class="field chk"><label><input v-model="newOrg.auto_claim_enabled" type="checkbox"> Auto-claim</label></div>
        <button class="btn btn-primary" type="submit">Add Organization</button>
      </form>
    </section>

    <!-- User Account Directory -->
    <section class="dash-section" id="users">
      <h3 class="dash-section-title"><i class="fas fa-users"></i> User Account Directory</h3>
      <div class="user-tools">
        <form class="inline-form" @submit.prevent="searchUsers" style="margin-bottom:1rem;">
          <div class="field"><label>Search accounts</label><input v-model="userSearch" type="search" placeholder="Name, username, email"></div>
          <button class="btn" type="submit">Search</button>
          <button v-if="!viewAllUsers" class="btn btn-secondary" type="button" @click="viewAllUsers = true; searchUsers()">View all</button>
          <button v-else class="btn btn-secondary" type="button" @click="viewAllUsers = false; searchUsers()">Limit to 100</button>
        </form>
        <form class="inline-form" @submit.prevent="purgeInactive">
          <button class="btn btn-danger small" type="submit">Purge inactive requestor accounts</button>
        </form>
      </div>
      <table class="data-table">
        <thead><tr><th>Name</th><th>Username</th><th>Email</th><th>Roles</th><th>Active</th><th>Actions</th></tr></thead>
        <tbody>
          <tr v-for="u in users" :key="u.id">
            <td>{{ u.full_name }}</td>
            <td><code>{{ u.username }}</code></td>
            <td>{{ u.email }}</td>
            <td>{{ u.roles || '—' }}</td>
            <td><span :class="['pill', u.is_active ? 'pill-green' : 'pill-amber']">{{ u.is_active ? 'Yes' : 'No' }}</span></td>
            <td><button class="btn small" @click="resetPassword(u)">Reset Password</button></td>
          </tr>
        </tbody>
      </table>

      <h4 style="margin-top:2rem;">Create User</h4>
      <form class="inline-form" @submit.prevent="createUser">
        <div class="field"><label>Full Name</label><input v-model="newUser.full_name" type="text" required></div>
        <div class="field"><label>Username</label><input v-model="newUser.username" type="text" required></div>
        <div class="field"><label>Email</label><input v-model="newUser.email" type="email" required></div>
        <div class="field"><label>Phone</label><input v-model="newUser.phone" type="tel"></div>
        <div class="field"><label>Role</label>
          <select v-model="newUser.role_id" required>
            <option value="">— Select —</option>
            <option v-for="r in roles" :key="r.id" :value="r.id">{{ r.role_name }}</option>
          </select>
        </div>
        <div class="field"><label>Organization</label>
          <select v-model="newUser.organization_id" required>
            <option value="">— Select —</option>
            <option v-for="o in organizations" :key="o.id" :value="o.id">{{ o.organization_name }}</option>
          </select>
        </div>
        <button class="btn btn-primary" type="submit">Create User</button>
      </form>
    </section>

    <!-- Helpdesk Tickets -->
    <section class="dash-section" id="helpdesk-tickets">
      <h3 class="dash-section-title"><i class="fas fa-headset"></i> Helpdesk Tickets</h3>
      <p v-if="!tickets.length" class="muted">No support tickets yet. They'll appear here when users submit requests via the chat widget.</p>
      <table v-else class="data-table">
        <thead><tr><th>#</th><th>Category</th><th>Subject</th><th>Submitter</th><th>Priority</th><th>Assigned</th><th>Status</th><th>Created</th></tr></thead>
        <tbody>
          <template v-for="t in tickets">
            <tr :key="t.id">
              <td>{{ t.id }}</td>
              <td>{{ catLabel(t.category) }}</td>
              <td>
                {{ t.subject }}
                <details style="margin-top:0.35rem;">
                  <summary style="cursor:pointer;color:#3b82f6;font-size:0.8rem;">Details</summary>
                  <pre style="white-space:pre-wrap;margin:0.35rem 0;font-size:0.8rem;">{{ t.description }}</pre>
                  <p v-if="t.resolution_note" style="margin-top:0.35rem;"><strong>Resolution:</strong> {{ t.resolution_note }}</p>
                </details>
              </td>
              <td>{{ t.submitter_display_name || t.submitter_name }}<br><small style="color:#6b7280;">{{ t.submitter_email }}</small></td>
              <td><span :style="{display:'inline-block',width:'8px',height:'8px',borderRadius:'50%',background:priorityColor(t.priority),marginRight:'0.35rem'}"></span>{{ t.priority }}</td>
              <td>{{ t.assigned_name || 'Unassigned' }}</td>
              <td><span :class="['pill', statusPill(t.status)]">{{ t.status }}</span></td>
              <td>{{ formatDate(t.created_at) }}</td>
            </tr>
            <tr :key="'actions-' + t.id">
              <td colspan="8" style="padding-bottom:0.75rem;">
                <form class="inline-form" @submit.prevent="assignTicket(t.id)" style="display:flex;gap:0.5rem;align-items:center;flex-wrap:wrap;">
                  <select v-model="ticketAssign[t.id]" style="padding:0.25rem;font-size:0.8rem;border:1px solid #d1d5db;border-radius:4px;">
                    <option value="">— assign —</option>
                    <option v-for="au in allUsers" :key="au.id" :value="au.id">{{ au.full_name }}</option>
                  </select>
                  <button class="btn small" type="submit">Assign</button>
                </form>
                <form v-if="t.status !== 'resolved' && t.status !== 'closed'" class="inline-form" @submit.prevent="resolveTicket(t.id)" style="display:flex;gap:0.5rem;align-items:center;margin-top:0.35rem;flex-wrap:wrap;">
                  <input v-model="ticketResolve[t.id]" type="text" placeholder="Resolution note…" style="flex:1;min-width:12rem;padding:0.25rem;font-size:0.8rem;border:1px solid #d1d5db;border-radius:4px;">
                  <button class="btn small btn-primary" type="submit">Resolve</button>
                </form>
              </td>
            </tr>
          </template>
        </tbody>
      </table>
    </section>

    <!-- Security -->
    <section class="dash-section" id="security-logins">
      <h3 class="dash-section-title"><i class="fas fa-shield-halved"></i> Security — Flagged Login Attempts (24h)</h3>
      <p v-if="!loginAttempts.length" class="muted">No flagged login attempts in the last 24 hours.</p>
      <table v-else class="data-table">
        <thead><tr><th>IP Address</th><th>Attempts</th><th>Targeted Emails</th><th>Last Attempt</th></tr></thead>
        <tbody>
          <tr v-for="la in loginAttempts" :key="la.ip_address">
            <td><code>{{ la.ip_address }}</code></td>
            <td>{{ la.attempt_count }}</td>
            <td>{{ la.targeted_emails }}</td>
            <td>{{ formatDate(la.last_attempt) }}</td>
          </tr>
        </tbody>
      </table>
    </section>

    <!-- Credentials Modal -->
    <div v-if="credentialsShow" class="modal-overlay" role="dialog" aria-modal="true" @click.self="credentialsShow = false">
      <div class="modal-box">
        <div class="modal-header"><h3><i class="fas fa-key"></i> Account credentials</h3></div>
        <div class="modal-body">
          <p>The account is ready. Share these credentials with the user through a direct channel — they are <strong>shown only once</strong>.</p>
          <ul class="danger-list">
            <li><span>Username</span><span class="count">{{ credUsername }}</span></li>
            <li><span>Temporary password</span><span class="count">{{ credPassword }}</span></li>
          </ul>
          <p class="muted">If these credentials are lost, you can reset the password again from User Management.</p>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="copyCredentials"><i class="fas fa-copy"></i> Copy</button>
          <button class="btn btn-primary" @click="credentialsShow = false">Done</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
const API = '/app/vue_api/super-admin.php';

export default {
  name: 'SuperAdminView',
  data() {
    return {
      counts: {},
      organizations: [],
      roles: [],
      users: [],
      allUsers: [],
      tickets: [],
      loginAttempts: [],
      blockedIps: [],
      criteriaTypes: [],
      eligibilityRules: [],
      userSearch: '',
      viewAllUsers: false,
      editingOrg: null,
      orgPresets: {},
      newRules: {},
      ticketAssign: {},
      ticketResolve: {},
      newOrg: { organization_code: '', organization_name: '', contact_email: '', contact_phone: '', description: '', funding_limit: '', max_active_applications: '', notification_email: '', auto_claim_enabled: false },
      newUser: { full_name: '', username: '', email: '', phone: '', role_id: '', organization_id: '' },
      credentialsShow: false,
      credUsername: '',
      credPassword: '',
      saveMsg: '',
    };
  },
  async mounted() {
    await this.loadData();
  },
  methods: {
    async loadData() {
      try {
        const token = this.$auth?.token || localStorage.getItem('archr_auth_token');
        console.log('[SuperAdmin] token:', token ? token.substring(0, 20) + '...' : 'NONE');
        const res = await fetch(API, {
          headers: { 'Authorization': 'Bearer ' + token }
        });
        console.log('[SuperAdmin] response status:', res.status);
        const text = await res.text();
        console.log('[SuperAdmin] response:', text.substring(0, 200));
        const data = JSON.parse(text);
        if (data.success) {
          this.counts = data.counts || {};
          this.organizations = data.organizations || [];
          this.roles = data.roles || [];
          this.users = data.users || [];
          this.allUsers = data.allUsers || [];
          this.tickets = data.tickets || [];
          this.loginAttempts = data.loginAttempts || [];
          this.blockedIps = data.blockedIps || [];
          this.criteriaTypes = data.criteriaTypes || [];
          this.eligibilityRules = data.eligibilityRules || [];
          // Init per-org state
          this.organizations.forEach(o => {
            this.orgPresets[o.id] = '';
            this.newRules[o.id] = { criteria_type_id: '', rule_operator: 'equals', rule_value: '', priority: 0 };
          });
        }
      } catch (e) { console.error('[SuperAdmin] error:', e); }
    },

    orgEligibilityRules(orgId) {
      if (!orgId) return [];
      return (this.eligibilityRules || []).filter(r => r.organization_id === orgId);
    },

    newRuleFor(orgId) {
      if (!this.newRules[orgId]) {
        this.$set(this.newRules, orgId, { criteria_type_id: '', rule_operator: 'equals', rule_value: '', priority: 0 });
      }
      return this.newRules[orgId];
    },

    toggleOrgEdit(id) {
      this.editingOrg = this.editingOrg === id ? null : id;
    },

    catLabel(cat) {
      const labels = { bug: '🐛 Bug', feature_request: '💡 Feature', access_issue: '🔑 Access', data_error: '📊 Data', general: '❓ General' };
      return labels[cat] || cat;
    },

    priorityColor(p) {
      return { critical: '#dc2626', high: '#f59e0b', normal: '#3b82f6', low: '#6b7280' }[p] || '#6b7280';
    },

    statusPill(s) {
      return { open: 'pill-green', in_progress: 'pill-amber', resolved: 'pill-blue', closed: '' }[s] || 'pill-green';
    },

    formatDate(d) {
      if (!d) return '—';
      return new Date(d).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
    },

    async apiPost(fd) {
      try {
        const res = await fetch(API, {
          method: 'POST',
          headers: { 'Authorization': 'Bearer ' + (this.$auth?.token || localStorage.getItem('archr_auth_token')) },
          body: fd,
        });
        return await res.json();
      } catch (_) { return { success: false, error: 'Network error' }; }
    },

    async updateOrg(org) {
      const fd = new FormData();
      fd.append('action', 'update_organization');
      fd.append('organization_id', org.id);
      for (const [k, v] of Object.entries(org)) {
        if (['id', 'created_at', 'organization_code'].includes(k)) continue;
        fd.append(k, v);
      }
      const r = await this.apiPost(fd);
      if (r.success) { this.saveMsg = 'Organization updated'; await this.loadData(); }
    },

    async createOrg() {
      const fd = new FormData();
      fd.append('action', 'create_organization');
      for (const [k, v] of Object.entries(this.newOrg)) fd.append(k, v);
      const r = await this.apiPost(fd);
      if (r.success) { this.saveMsg = 'Organization created'; this.newOrg = { organization_code: '', organization_name: '', contact_email: '', contact_phone: '', description: '', funding_limit: '', max_active_applications: '', notification_email: '', auto_claim_enabled: false }; await this.loadData(); }
    },

    async deleteOrg(org) {
      if (!confirm('Delete ' + org.organization_name + '? This cannot be undone.')) return;
      const fd = new FormData();
      fd.append('action', 'delete_organization');
      fd.append('organization_id', org.id);
      const r = await this.apiPost(fd);
      if (r.success) { this.saveMsg = 'Organization deleted'; await this.loadData(); }
    },

    async addRule(orgId) {
      const nr = this.newRules[orgId];
      if (!nr.criteria_type_id || !nr.rule_value) return;
      const fd = new FormData();
      fd.append('action', 'create_eligibility_rule');
      fd.append('organization_id', orgId);
      fd.append('criteria_type_id', nr.criteria_type_id);
      fd.append('rule_operator', nr.rule_operator);
      fd.append('rule_value', nr.rule_value);
      fd.append('priority', nr.priority);
      const r = await this.apiPost(fd);
      if (r.success) { this.saveMsg = 'Rule added'; await this.loadData(); }
    },

    async deleteRule(ruleId) {
      const fd = new FormData();
      fd.append('action', 'delete_eligibility_rule');
      fd.append('rule_id', ruleId);
      const r = await this.apiPost(fd);
      if (r.success) { await this.loadData(); }
    },

    async bulkPreset(orgId) {
      const preset = this.orgPresets[orgId];
      if (!preset) return;
      const fd = new FormData();
      fd.append('action', 'bulk_eligibility_preset');
      fd.append('organization_id', orgId);
      fd.append('preset', preset);
      const r = await this.apiPost(fd);
      if (r.success) { this.saveMsg = r.count + ' rules added'; await this.loadData(); }
    },

    async searchUsers() {
      try {
        const url = API + '?action=users' + (this.userSearch ? '&q=' + encodeURIComponent(this.userSearch) : '') + (this.viewAllUsers ? '&all=1' : '');
        const res = await fetch(url, {
          headers: { 'Authorization': 'Bearer ' + (this.$auth?.token || localStorage.getItem('archr_auth_token')) }
        });
        const data = await res.json();
        if (data.success) this.users = data.users || [];
      } catch (e) { console.error('[SuperAdmin] error:', e); }
    },

    async resetPassword(user) {
      const fd = new FormData();
      fd.append('action', 'reset_password');
      fd.append('user_id', user.id);
      const r = await this.apiPost(fd);
      if (r.success) { this.credUsername = r.username; this.credPassword = r.password; this.credentialsShow = true; }
    },

    async createUser() {
      const fd = new FormData();
      fd.append('action', 'create_user');
      for (const [k, v] of Object.entries(this.newUser)) fd.append(k, v);
      const r = await this.apiPost(fd);
      if (r.success) { this.credUsername = r.username; this.credPassword = r.password; this.credentialsShow = true; this.newUser = { full_name: '', username: '', email: '', phone: '', role_id: '', organization_id: '' }; await this.loadData(); }
    },

    async purgeInactive() {
      if (!confirm('Purge inactive requestor accounts?')) return;
      // Use the maintenance endpoint
      try {
        const res = await fetch('/app/api/run-maintenance.php', {
          method: 'POST',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          body: 'action=cleanup_requestor_accounts',
        });
        const data = await res.json();
        if (data.success) { this.saveMsg = (data.purged || 0) + ' accounts purged'; await this.loadData(); }
      } catch (e) { console.error('[SuperAdmin] error:', e); }
    },

    async assignTicket(ticketId) {
      const fd = new FormData();
      fd.append('action', 'assign_ticket');
      fd.append('ticket_id', ticketId);
      fd.append('assigned_to', this.ticketAssign[ticketId] || '');
      const r = await this.apiPost(fd);
      if (r.success) await this.loadData();
    },

    async resolveTicket(ticketId) {
      const fd = new FormData();
      fd.append('action', 'resolve_ticket');
      fd.append('ticket_id', ticketId);
      fd.append('resolution_note', this.ticketResolve[ticketId] || '');
      const r = await this.apiPost(fd);
      if (r.success) await this.loadData();
    },

    async copyCredentials() {
      const text = 'Username: ' + this.credUsername + '\nPassword: ' + this.credPassword;
      try { await navigator.clipboard.writeText(text); } catch (_) { /* clipboard not available */ }
    },
  },
};
</script>

<style scoped>
.super-admin { max-width: 1100px; margin: 0 auto; padding: 1.5rem; }
.login-banner { background: #eef2ff; border: 1px solid #c7d2fe; border-radius: 8px; padding: 0.75rem 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; font-size: 0.9rem; color: #3730a3; }
h2 { font-size: 1.4rem; margin: 0 0 0.25rem; }
.dash-hero p { color: #64748b; margin: 0 0 1.5rem; }
.dash-section { margin-bottom: 2rem; }
.dash-section-title { font-size: 1.1rem; margin: 0 0 0.75rem; display: flex; align-items: center; gap: 0.5rem; color: #1e293b; }
.dash-section-title i { color: #2563eb; }

.kpi-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 0.75rem; margin-bottom: 1.5rem; }
.kpi { background: var(--color-surface, #fff); border: 1px solid var(--color-border, #e2e8f0); border-radius: 10px; padding: 1rem; text-align: center; }
.kpi-label { display: block; font-size: 0.8rem; color: #64748b; margin-bottom: 0.3rem; }
.kpi-value { display: block; font-size: 1.8rem; font-weight: 700; color: #1e293b; }
.kpi-blue { border-left: 3px solid #3b82f6; }
.kpi-amber { border-left: 3px solid #f59e0b; }
.kpi-green { border-left: 3px solid #22c55e; }

.data-table { width: 100%; border-collapse: collapse; font-size: 0.85rem; }
.data-table th { text-align: left; padding: 0.5rem 0.75rem; background: #f8fafc; font-weight: 600; color: #475569; border-bottom: 2px solid #e2e8f0; }
.data-table td { padding: 0.5rem 0.75rem; border-bottom: 1px solid #f1f5f9; vertical-align: top; }
.data-table small { color: #888; }
.data-table code { font-family: ui-monospace, 'Consolas', monospace; font-size: 0.8rem; background: #f1f5f9; padding: 0.1rem 0.3rem; border-radius: 3px; }
.data-table.small { font-size: 0.8rem; }
.data-table.small th, .data-table.small td { padding: 0.3rem 0.5rem; }

.pill { display: inline-block; padding: 0.15rem 0.5rem; border-radius: 999px; font-size: 0.75rem; font-weight: 600; }
.pill-green { background: #dcfce7; color: #166534; }
.pill-amber { background: #fef3c7; color: #92400e; }
.pill-blue { background: #dbeafe; color: #1e40af; }

.btn { padding: 0.35rem 0.75rem; border: 1px solid #d1d5db; border-radius: 6px; background: #fff; cursor: pointer; font-size: 0.8rem; }
.btn:hover { background: #f8fafc; }
.btn-primary { background: #2563eb; color: #fff; border-color: #2563eb; }
.btn-secondary { background: #6b7280; color: #fff; border-color: #6b7280; }
.btn-danger { background: #dc2626; color: #fff; border-color: #dc2626; }
.btn.small { padding: 0.2rem 0.5rem; font-size: 0.75rem; }

.inline-form { display: flex; flex-wrap: wrap; gap: 0.75rem; align-items: flex-end; margin-bottom: 0.75rem; }
.inline-form .field { display: flex; flex-direction: column; gap: 0.2rem; }
.inline-form .field label { font-size: 0.75rem; font-weight: 600; color: #475569; }
.inline-form .field input, .inline-form .field select { padding: 0.3rem 0.5rem; border: 1px solid #d1d5db; border-radius: 4px; font-size: 0.85rem; }
.inline-form .field.chk { flex-direction: row; align-items: center; gap: 0.5rem; }

.preset-form { display: flex; gap: 0.5rem; align-items: flex-end; margin-bottom: 0.75rem; padding: 0.6rem 0.75rem; background: #f0f7ff; border: 1px solid #bfdbfe; border-radius: 6px; }
.preset-field { flex: 1; }
.preset-field label { font-size: 0.75rem; font-weight: 600; color: #1e40af; display: block; margin-bottom: 0.2rem; }
.preset-field select { width: 100%; padding: 0.3rem 0.5rem; border: 1px solid #d1d5db; border-radius: 4px; font-size: 0.85rem; }

.edit-row { background: #fafbfc; }
.edit-divider { border: none; border-top: 1px solid #e2e8f0; margin: 1rem 0; }
.edit-row h4 { font-size: 0.95rem; margin: 0 0 0.5rem; color: #1e293b; }

.danger-zone-inline { background: #fef2f2; border: 1px solid #fecaca; border-radius: 8px; padding: 0.75rem 1rem; margin-top: 1rem; }
.danger-zone-inline h4 { color: #991b1b; margin: 0 0 0.25rem; font-size: 0.9rem; display: flex; align-items: center; gap: 0.4rem; }
.danger-zone-inline p { color: #7f1d1d; font-size: 0.8rem; margin: 0 0 0.5rem; }

.user-tools { display: flex; gap: 1rem; align-items: flex-start; margin-bottom: 1rem; flex-wrap: wrap; }

.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.4); display: flex; align-items: center; justify-content: center; z-index: 1000; }
.modal-box { background: #fff; border-radius: 12px; max-width: 450px; width: 90%; overflow: hidden; }
.modal-header { padding: 1rem 1.25rem; border-bottom: 1px solid #e2e8f0; }
.modal-header h3 { margin: 0; font-size: 1.1rem; color: #1e293b; display: flex; align-items: center; gap: 0.5rem; }
.modal-body { padding: 1rem 1.25rem; }
.modal-body p { color: #64748b; font-size: 0.9rem; margin: 0 0 0.75rem; }
.modal-footer { padding: 0.75rem 1.25rem; border-top: 1px solid #e2e8f0; display: flex; gap: 0.5rem; justify-content: flex-end; }
.danger-list { list-style: none; padding: 0; margin: 0 0 0.75rem; }
.danger-list li { display: flex; justify-content: space-between; padding: 0.3rem 0; }
.danger-list .count { background: #f1f5f9; padding: 0.15rem 0.4rem; border-radius: 3px; font-family: ui-monospace, monospace; font-size: 0.85rem; }

.muted { color: #94a3b8; font-size: 0.9rem; }
.muted td { color: #94a3b8; }
</style>
