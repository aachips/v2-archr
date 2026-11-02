<template>
  <div class="requestor">
    <p class="login-banner" role="status">
      <i class="fas fa-lock"></i>
      <span>You are viewing your private applications. Only you and your assigned ARCHR caseworkers can see this information.</span>
    </p>

    <template v-if="loading">
      <p class="loading-text">Loading your applications…</p>
    </template>

    <!-- List view -->
    <ApplicationsListView
      v-else-if="!selectedApp"
      :applications="applications"
      :loading="loading"
      @select="selectApp"
    />

    <!-- Detail view -->
    <template v-else>
      <div class="back-row">
        <button class="btn btn--sm" @click="selectedApp = null"><i class="fas fa-arrow-left"></i> All Applications</button>
      </div>

      <section class="dash-hero">
        <div>
          <h2>Welcome back, {{ submission.first_name || auth.displayName }}</h2>
          <p>Your application <strong>{{ caseRef }}</strong> is currently <strong>{{ statusLabel }}</strong>.</p>
          <p v-if="submission.submitted_at" class="updated"><i class="far fa-clock"></i> Submitted {{ formatDate(submission.submitted_at) }}</p>
        </div>
        <div class="dash-hero-meta">
          <span class="org-badge"><i class="fas fa-hashtag"></i> {{ caseRef }}</span>
          <span v-if="submission.assigned_organization" class="org-badge"><i class="fas fa-building"></i> {{ submission.assigned_organization }}</span>
        </div>
      </section>

      <!-- KPI Cards -->
      <section class="dash-section">
        <h3 class="dash-section-title"><i class="fas fa-clipboard-list"></i> Application At a Glance</h3>
        <div class="kpi-grid">
          <div class="kpi">
            <span class="kpi-label">Status</span>
            <span class="kpi-value" style="font-size:1.4rem;">{{ statusLabel }}</span>
            <span class="kpi-sub"><span class="pill pill-amber">Documents may be needed</span></span>
          </div>
          <div class="kpi kpi-blue">
            <span class="kpi-label">Days Since Submission</span>
            <span class="kpi-value">{{ daysSince }}</span>
            <span class="kpi-sub">{{ submission.submitted_at ? formatDate(submission.submitted_at) : '-' }}</span>
          </div>
          <div class="kpi kpi-amber">
            <span class="kpi-label">Next Step</span>
            <span class="kpi-value">Upload docs</span>
            <span class="kpi-sub">Income or homeownership proof</span>
          </div>
          <div class="kpi kpi-green">
            <span class="kpi-label">Property</span>
            <span class="kpi-value" style="font-size:1rem;">{{ submission.city }}{{ submission.city ? ',' : '' }} {{ submission.state }}</span>
            <span class="kpi-sub">{{ submission.address || '—' }}</span>
          </div>
        </div>
      </section>

      <!-- Urgency flags -->
      <section v-if="submission.urgent_open_to_elements || submission.urgent_no_hvac || submission.urgent_no_kitchen" class="dash-section">
        <div class="urgency-banner">
          <i class="fas fa-triangle-exclamation"></i>
          <div>
            <strong>Urgent Conditions Flagged:</strong>
            <ul>
              <li v-if="submission.urgent_open_to_elements">Open to the elements</li>
              <li v-if="submission.urgent_no_hvac">No HVAC</li>
              <li v-if="submission.urgent_no_kitchen">No kitchen access</li>
            </ul>
          </div>
        </div>
      </section>

      <!-- Editable Contact Info -->
      <section class="dash-section">
        <article class="panel">
          <div class="panel-header">
            <h3><i class="fas fa-address-book"></i> My Contact Information</h3>
            <button class="btn small" v-if="!editingContact" @click="startEdit"><i class="fas fa-pen"></i> Edit</button>
          </div>
          <div v-if="!editingContact" class="panel-body">
            <div class="info-grid">
              <div class="info-label">Email</div>
              <div class="info-value">{{ submission.contact_email || '—' }}</div>
              <div class="info-label">Home Phone</div>
              <div class="info-value">{{ submission.home_phone || '—' }}</div>
              <div class="info-label">Cell Phone</div>
              <div class="info-value">{{ submission.cell_phone || '—' }}</div>
              <div class="info-label">Preferred Contact</div>
              <div class="info-value">
                <span v-if="submission.preferred_email" class="pill pill-blue">Email</span>
                <span v-if="submission.preferred_phone" class="pill pill-blue">Phone</span>
                <span v-if="!submission.preferred_email && !submission.preferred_phone" class="muted">Not set</span>
              </div>
            </div>
          </div>
          <form v-else @submit.prevent="saveContact" class="edit-form">
            <div class="field"><label>Email</label><input v-model="editDraft.contact_email" type="email"></div>
            <div class="field"><label>Home Phone</label><input v-model="editDraft.home_phone" type="tel"></div>
            <div class="field"><label>Cell Phone</label><input v-model="editDraft.cell_phone" type="tel"></div>
            <div class="field chk"><label><input v-model="editDraft.preferred_email" type="checkbox"> Prefer email</label></div>
            <div class="field chk"><label><input v-model="editDraft.preferred_phone" type="checkbox"> Prefer phone</label></div>
            <div class="edit-actions">
              <button class="btn btn-primary" type="submit" :disabled="saving"><i class="fas fa-check"></i> Save</button>
              <button class="btn btn-secondary" type="button" @click="cancelEdit"><i class="fas fa-xmark"></i> Cancel</button>
            </div>
            <p v-if="saveMsg" :class="['save-msg', saveOk ? 'save-msg--ok' : 'save-msg--err']">{{ saveMsg }}</p>
          </form>
        </article>
      </section>

      <!-- Notice about complex changes -->
      <section class="dash-section">
        <div class="change-notice">
          <i class="fas fa-circle-info"></i>
          <div>
            <strong>Need to update income, eligibility, or repair details?</strong>
            <p>Changes to income, homeownership status, FEMA/insurance claims, or repair descriptions require staff review. Please use the <strong>support chat</strong> (bottom-right corner) to send a message to your caseworker with the correction.</p>
          </div>
        </div>
      </section>

      <!-- Repair Details -->
      <section v-if="submission.repair_details" class="dash-section">
        <article class="panel">
          <div class="panel-header">
            <h3><i class="fas fa-wrench"></i> Repair Details</h3>
          </div>
          <div class="panel-body">
            <p>{{ submission.repair_details }}</p>
          </div>
        </article>
      </section>

      <!-- Next Step + Contact -->
      <section class="dash-section">
        <div class="dash-two-col">
          <div class="callout next-step">
            <h3><i class="fas fa-arrow-right-long"></i> Your Next Step</h3>
            <p><strong>Complete required documentation.</strong> Upload your last three months of bank statements, pay stubs, or homeownership documents. Files are encrypted at rest and visible only to your caseworker.</p>
          </div>
          <article class="panel">
            <div class="panel-header">
              <h3><i class="fas fa-house"></i> Application Property</h3>
            </div>
            <div class="contact-card">
              <ul>
                <li><i class="fas fa-location-dot"></i> {{ submission.address || '—' }}</li>
                <li><i class="fas fa-city"></i> {{ submission.city }}{{ submission.city ? ', ' : '' }}{{ submission.state }} {{ submission.zip }}</li>
                <li><i class="fas fa-envelope"></i> {{ submission.contact_email || '—' }}</li>
                <li v-if="submission.home_phone"><i class="fas fa-phone"></i> {{ submission.home_phone }}</li>
                <li v-if="submission.cell_phone"><i class="fas fa-mobile-screen"></i> {{ submission.cell_phone }}</li>
                <li v-if="submission.home_type"><i class="fas fa-home"></i> {{ submission.home_type }}{{ submission.year_built ? ' (built ' + submission.year_built + ')' : '' }}</li>
                <li v-if="submission.household_size"><i class="fas fa-users"></i> {{ submission.household_size }} household members{{ submission.household_adults ? ' (' + submission.household_adults + ' adults)' : '' }}</li>
                <li v-if="submission.gross_annual_income"><i class="fas fa-dollar-sign"></i> ${{ Number(submission.gross_annual_income).toLocaleString() }}/year income</li>
              </ul>
            </div>
          </article>
        </div>
      </section>

      <!-- Progress Timeline -->
      <section class="dash-section">
        <article class="panel">
          <div class="panel-header">
            <h3><i class="fas fa-clock-rotate-left"></i> Progress Timeline</h3>
          </div>
          <ul class="timeline">
            <li class="timeline-item">
              <span class="dot"></span>
              <div>
                <strong>Application submitted</strong>
                <small>{{ submission.submitted_at ? formatDate(submission.submitted_at) : '—' }} &middot; {{ caseRef }} received</small>
              </div>
            </li>
            <li class="timeline-item is-pending">
              <span class="dot"></span>
              <div>
                <strong>Awaiting review</strong>
                <small>A staff member will review the application and contact you within 3–5 business days.</small>
              </div>
            </li>
          </ul>
        </article>
      </section>

      <!-- Quick Actions -->
      <section class="dash-section">
        <h3 class="dash-section-title"><i class="fas fa-bolt"></i> Quick Actions</h3>
        <div class="action-row">
          <a href="mailto:support@archr.org" class="btn btn-primary"><i class="fas fa-envelope"></i> Contact Support</a>
        </div>
        <p class="role-notice">
          <i class="fas fa-shield-halved"></i>
          <span><strong>Single source of truth:</strong> every email, phone call, and platform message about this case is logged here.</span>
        </p>
      </section>
    </template>
  </div>
</template>

<script>
import ApplicationsListView from './ApplicationsListView.vue';

const API = '/app/vue_api/requestor.php';

export default {
  name: 'RequestorView',
  components: { ApplicationsListView },
  data() {
    return {
      applications: [],
      submission: null,
      selectedApp: null,
      loading: true,
      editingContact: false,
      editDraft: {},
      saving: false,
      saveMsg: '',
      saveOk: false,
    };
  },
  computed: {
    auth() { return this.$auth || {}; },
    caseRef() {
      return this.submission?.case_number || this.submission?.anchor_id || ('#' + (this.submission?.id || 'N/A'));
    },
    statusLabel() {
      const s = this.submission?.status || 'pending';
      return s.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
    },
    daysSince() {
      if (!this.submission?.submitted_at) return '-';
      const diff = Math.floor((Date.now() - new Date(this.submission.submitted_at).getTime()) / 86400000);
      return diff >= 0 ? String(diff) : '-';
    },
  },
  async mounted() { await this.loadData(); },
  methods: {
    async loadData() {
      this.loading = true;
      try {
        const res = await fetch(API, {
          headers: { 'Authorization': 'Bearer ' + (this.$auth?.token || localStorage.getItem('archr_auth_token')) }
        });
        const data = await res.json();
        if (data.success) {
          this.applications = data.submissions || [];
          this.submission = data.submission || null;
          // If only one app, auto-select it
          if (this.applications.length === 1 && !this.selectedApp) {
            this.selectedApp = this.applications[0];
          }
        }
      } catch (_) { /* silent */ } finally { this.loading = false; }
    },

    selectApp(app) {
      this.selectedApp = app;
      // Find full submission detail from the list
      this.submission = this.applications.find(a => a.id === app.id) || app;
      // Fetch full detail
      this.loadDetail(app.id);
    },

    async loadDetail(id) {
      try {
        const res = await fetch(API + '?submission_id=' + id, {
          headers: { 'Authorization': 'Bearer ' + (this.$auth?.token || localStorage.getItem('archr_auth_token')) }
        });
        const data = await res.json();
        if (data.success && data.submission) this.submission = data.submission;
      } catch (_) { /* silent */ }
    },

    formatDate(d) {
      if (!d) return '—';
      return new Date(d).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
    },

    startEdit() {
      this.editDraft = {
        contact_email: this.submission.contact_email || '',
        home_phone: this.submission.home_phone || '',
        cell_phone: this.submission.cell_phone || '',
        preferred_email: !!this.submission.preferred_email,
        preferred_phone: !!this.submission.preferred_phone,
      };
      this.editingContact = true;
      this.saveMsg = '';
    },

    cancelEdit() { this.editingContact = false; this.saveMsg = ''; },

    async saveContact() {
      this.saving = true; this.saveMsg = '';
      try {
        const fd = new FormData();
        fd.append('action', 'update_contact');
        fd.append('submission_id', this.submission.id);
        for (const [k, v] of Object.entries(this.editDraft)) {
          fd.append(k, typeof v === 'boolean' ? (v ? '1' : '0') : (v || ''));
        }
        const res = await fetch(API, {
          method: 'POST',
          headers: { 'Authorization': 'Bearer ' + (this.$auth?.token || localStorage.getItem('archr_auth_token')) },
          body: fd,
        });
        const data = await res.json();
        if (data.success) {
          this.saveMsg = 'Contact information updated.';
          this.saveOk = true;
          Object.assign(this.submission, this.editDraft);
          this.editingContact = false;
        } else { this.saveMsg = data.error || 'Update failed.'; this.saveOk = false; }
      } catch (_) { this.saveMsg = 'Network error — please try again.'; this.saveOk = false; }
      finally { this.saving = false; }
    },
  },
};
</script>

<style scoped>
.requestor { max-width: 900px; margin: 0 auto; padding: 1.5rem; }
.login-banner { background: #eef2ff; border: 1px solid #c7d2fe; border-radius: 8px; padding: 0.75rem 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; font-size: 0.9rem; color: #3730a3; }
h2 { font-size: 1.4rem; margin: 0 0 0.25rem; }
.dash-hero p { color: #64748b; margin: 0 0 0.5rem; }
.dash-hero .updated { color: #94a3b8; font-size: 0.85rem; margin: 0; }
.dash-hero-meta { display: flex; gap: 0.75rem; align-items: center; margin-top: 0.75rem; }
.org-badge { background: #f1f5f9; padding: 0.3rem 0.6rem; border-radius: 6px; font-size: 0.85rem; font-family: ui-monospace, monospace; }
.back-row { margin-bottom: 1rem; }

.dash-section { margin-bottom: 2rem; }
.dash-section-title { font-size: 1.1rem; margin: 0 0 0.75rem; display: flex; align-items: center; gap: 0.5rem; color: #1e293b; }
.dash-section-title i { color: #2563eb; }

.kpi-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 0.75rem; }
.kpi { background: var(--color-surface, #fff); border: 1px solid var(--color-border, #e2e8f0); border-radius: 10px; padding: 1rem; text-align: center; }
.kpi-label { display: block; font-size: 0.8rem; color: #64748b; margin-bottom: 0.3rem; }
.kpi-value { display: block; font-size: 1.8rem; font-weight: 700; color: #1e293b; }
.kpi-sub { display: block; font-size: 0.75rem; color: #94a3b8; margin-top: 0.2rem; }
.kpi-blue { border-left: 3px solid #3b82f6; }
.kpi-amber { border-left: 3px solid #f59e0b; }
.kpi-green { border-left: 3px solid #22c55e; }

.dash-two-col { display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem; }
@media (max-width: 700px) { .dash-two-col { grid-template-columns: 1fr; } }

.callout { background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 10px; padding: 1.25rem; }
.callout h3 { font-size: 1rem; margin: 0 0 0.5rem; color: #166534; }
.callout p { color: #166534; font-size: 0.9rem; margin: 0; line-height: 1.6; }

.panel { background: var(--color-surface, #fff); border: 1px solid var(--color-border, #e2e8f0); border-radius: 10px; }
.panel-header { padding: 0.75rem 1rem; border-bottom: 1px solid var(--color-border, #e2e8f0); display: flex; justify-content: space-between; align-items: center; }
.panel-header h3 { font-size: 1rem; margin: 0; display: flex; align-items: center; gap: 0.5rem; color: #1e293b; }
.panel-body { padding: 1rem; }
.panel-body p { margin: 0; line-height: 1.6; color: #334155; }
.contact-card ul { list-style: none; padding: 1rem; margin: 0; }
.contact-card li { padding: 0.4rem 0; font-size: 0.9rem; display: flex; gap: 0.5rem; }
.contact-card li i { color: #2563eb; width: 1.2rem; text-align: center; }

.pill { display: inline-block; padding: 0.15rem 0.5rem; border-radius: 999px; font-size: 0.75rem; font-weight: 600; }
.pill-amber { background: #fef3c7; color: #92400e; }
.pill-blue { background: #dbeafe; color: #1e40af; }
.muted { color: #94a3b8; }

.urgency-banner { background: #fef2f2; border: 1px solid #fecaca; border-radius: 10px; padding: 1rem; display: flex; gap: 0.75rem; color: #991b1b; }
.urgency-banner i { font-size: 1.2rem; margin-top: 0.1rem; }
.urgency-banner ul { margin: 0.25rem 0 0; padding-left: 1.2rem; }

.info-grid { display: grid; grid-template-columns: 120px 1fr; gap: 0.4rem 0.75rem; font-size: 0.9rem; }
.info-label { color: #64748b; font-weight: 500; }
.info-value { color: #1e293b; }

.edit-form { padding: 1rem; display: flex; flex-wrap: wrap; gap: 0.75rem; align-items: flex-end; }
.edit-form .field { display: flex; flex-direction: column; gap: 0.2rem; min-width: 180px; flex: 1; }
.edit-form .field label { font-size: 0.75rem; font-weight: 600; color: #475569; }
.edit-form .field input[type="email"], .edit-form .field input[type="tel"] { padding: 0.35rem 0.5rem; border: 1px solid #d1d5db; border-radius: 4px; font-size: 0.85rem; }
.edit-form .field.chk { flex-direction: row; align-items: center; gap: 0.5rem; min-width: auto; flex: none; }
.edit-actions { display: flex; gap: 0.5rem; width: 100%; margin-top: 0.5rem; }
.save-msg { margin: 0.5rem 0 0; font-size: 0.85rem; font-weight: 500; }
.save-msg--ok { color: #166534; }
.save-msg--err { color: #991b1b; }

.change-notice { background: #f0f9ff; border: 1px solid #bae6fd; border-radius: 10px; padding: 1rem; display: flex; gap: 0.75rem; color: #0369a1; }
.change-notice i { font-size: 1.2rem; margin-top: 0.1rem; }
.change-notice strong { display: block; margin-bottom: 0.25rem; }
.change-notice p { margin: 0; font-size: 0.85rem; line-height: 1.5; }

.timeline { list-style: none; padding: 1rem; margin: 0; }
.timeline-item { position: relative; padding-left: 1.5rem; padding-bottom: 1rem; }
.timeline-item:last-child { padding-bottom: 0; }
.timeline-item .dot { position: absolute; left: 0; top: 0.3rem; width: 10px; height: 10px; border-radius: 50%; background: #2563eb; }
.timeline-item.is-pending .dot { background: #f59e0b; animation: pulse 2s infinite; }
@keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.4; } }
.timeline-item strong { display: block; font-size: 0.9rem; color: #1e293b; }
.timeline-item small { color: #94a3b8; font-size: 0.8rem; }

.btn { padding: 0.5rem 1rem; border: 1px solid #d1d5db; border-radius: 6px; background: #fff; cursor: pointer; font-size: 0.9rem; text-decoration: none; display: inline-flex; align-items: center; gap: 0.4rem; }
.btn:hover { background: #f8fafc; }
.btn-primary { background: #2563eb; color: #fff; border-color: #2563eb; }
.btn-secondary { background: #6b7280; color: #fff; border-color: #6b7280; }
.btn.small { padding: 0.2rem 0.5rem; font-size: 0.75rem; }
.action-row { display: flex; gap: 0.75rem; flex-wrap: wrap; }

.role-notice { background: #f0f9ff; border: 1px solid #bae6fd; border-radius: 8px; padding: 0.75rem 1rem; margin-top: 1rem; font-size: 0.85rem; color: #0369a1; display: flex; gap: 0.5rem; }
.role-notice i { margin-top: 0.1rem; }
.loading-text { text-align: center; color: #94a3b8; padding: 3rem; }
</style>
