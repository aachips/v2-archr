<template>
  <div class="vol-applications">
    <header class="vol-header">
      <h2><i class="fas fa-hand-holding-heart"></i> Volunteer Applications</h2>
      <p class="subtitle">Review and approve volunteer intake form submissions.</p>
    </header>

    <!-- Vetting Standards HUD -->
    <section class="vetting-hud">
      <div class="hud-icon"><i class="fas fa-shield-halved"></i></div>
      <div class="hud-body">
        <h3>Vetting Standard</h3>
        <p>Volunteers work in private homes and around vulnerable populations. <strong>Do not approve</strong> any applicant with:</p>
        <ul class="red-flags">
          <li><i class="fas fa-ban"></i> <strong>Sex offenses</strong> — any conviction or registration requirement</li>
          <li><i class="fas fa-ban"></i> <strong>Violent felonies</strong> — assault, battery, homicide, armed robbery</li>
          <li><i class="fas fa-ban"></i> <strong>Property crimes against persons</strong> — breaking &amp; entering, burglary, home invasion</li>
          <li><i class="fas fa-ban"></i> <strong>Theft/larceny</strong> — especially when unsupervised access to property is involved</li>
        </ul>
        <p class="hud-note">Background checks should be completed before granting dashboard access. This queue flags applications for review only — the admin must verify through your organization's background check process.</p>
      </div>
    </section>

    <!-- Stats -->
    <div class="vol-stats">
      <div class="stat" :class="{ pending: counts.pending > 0 }">
        <span class="stat-num">{{ counts.pending }}</span>
        <span class="stat-label">Pending</span>
      </div>
      <div class="stat">
        <span class="stat-num">{{ counts.approved }}</span>
        <span class="stat-label">Approved</span>
      </div>
      <div class="stat">
        <span class="stat-num">{{ counts.rejected }}</span>
        <span class="stat-label">Rejected</span>
      </div>
      <div class="stat">
        <span class="stat-num">{{ counts.total }}</span>
        <span class="stat-label">Total</span>
      </div>
    </div>

    <!-- Filter tabs -->
    <div class="vol-tabs">
      <button
        v-for="tab in tabs"
        :key="tab.key"
        :class="['vol-tab', { active: activeTab === tab.key }]"
        @click="activeTab = tab.key"
      >
        {{ tab.label }} <span v-if="tab.count" class="tab-count">{{ tab.count }}</span>
      </button>
    </div>

    <!-- Applications list -->
    <div v-if="loading" class="vol-loading">Loading applications...</div>
    <div v-else-if="filtered.length === 0" class="vol-empty">
      <i class="fas fa-inbox"></i>
      <p>No {{ activeTab === 'all' ? '' : activeTab }} applications found.</p>
    </div>
    <div v-else class="vol-list">
      <div
        v-for="app in filtered"
        :key="app.id"
        class="vol-card"
        :class="'status-' + app.status"
      >
        <div class="vol-card-header">
          <div class="vol-card-name">
            <strong>{{ app.full_name }}</strong>
            <span class="vol-card-date">Applied {{ formatDate(app.created_at) }}</span>
          </div>
          <span :class="['vol-status', 'status-' + app.status]">{{ app.status }}</span>
        </div>

        <div class="vol-card-body">
          <div class="vol-row"><span class="vol-k">Email</span><span class="vol-v">{{ app.email }}</span></div>
          <div class="vol-row"><span class="vol-k">Phone</span><span class="vol-v">{{ app.phone }}</span></div>
          <div class="vol-row" v-if="app.location"><span class="vol-k">Location</span><span class="vol-v">{{ app.location }}</span></div>
          <div class="vol-row" v-if="app.motivation"><span class="vol-k">Motivation</span><span class="vol-v">{{ app.motivation }}</span></div>
          <div class="vol-row" v-if="app.skills && app.skills.length">
            <span class="vol-k">Skills</span>
            <span class="vol-v">
              <span v-for="s in app.skills" :key="s" class="skill-tag">{{ formatSkill(s) }}</span>
            </span>
          </div>
          <div class="vol-row" v-if="app.availability && app.availability.length">
            <span class="vol-k">Availability</span>
            <span class="vol-v">
              <span v-for="a in app.availability" :key="a" class="avail-tag">{{ formatAvail(a) }}</span>
            </span>
          </div>
          <div class="vol-row" v-if="app.interest_type"><span class="vol-k">Interest</span><span class="vol-v">{{ formatInterest(app.interest_type) }}</span></div>
          <div class="vol-row" v-if="app.physical_limits"><span class="vol-k">Accommodations</span><span class="vol-v">{{ app.physical_limits }}</span></div>
          <div class="vol-row" v-if="app.tools_notes"><span class="vol-k">Tools/Transport</span><span class="vol-v">{{ app.tools_notes }}</span></div>
          <div class="vol-row" v-if="app.referral_name"><span class="vol-k">Referred by</span><span class="vol-v">{{ app.referral_name }}</span></div>
        </div>

        <!-- Action area for pending applications -->
        <div v-if="app.status === 'pending'" class="vol-card-actions">
          <div class="vetting-checklist">
            <h4><i class="fas fa-clipboard-check"></i> Pre-Approval Checklist</h4>
            <label><input type="checkbox" v-model="checklists[app.id].background"> Background check completed — no disqualifying offenses</label>
            <label><input type="checkbox" v-model="checklists[app.id].identity"> Identity verified (government ID matches application)</label>
            <label><input type="checkbox" v-model="checklists[app.id].orientation"> Safety orientation scheduled or completed</label>
            <label><input type="checkbox" v-model="checklists[app.id].references"> References checked (if applicable)</label>
          </div>
          <div class="vol-actions-col">
            <button class="btn-approve" @click="approve(app)" :disabled="!isReadyToApprove(app) || acting === app.id">
              {{ acting === app.id ? 'Processing...' : 'Approve & Create Account' }}
            </button>
            <button class="btn-reject" @click="reject(app)" :disabled="acting === app.id">
              Reject
            </button>
          </div>
        </div>

        <!-- Modal for approval notes -->
        <div v-if="showModal === app.id" class="modal-overlay" @click.self="showModal = null">
          <div class="modal-dialog">
            <h3>Approval Notes</h3>
            <textarea v-model="modalNotes" rows="3" placeholder="Optional notes about this volunteer..."></textarea>
            <div class="modal-actions">
              <button class="btn-secondary" @click="showModal = null">Cancel</button>
              <button class="btn-primary" @click="confirmApprove(app)">Confirm</button>
            </div>
          </div>
        </div>

        <!-- Reviewed info for approved/rejected -->
        <div v-if="app.status !== 'pending' && app.reviewed_at" class="vol-reviewed">
          <i class="fas" :class="app.status === 'approved' ? 'fa-circle-check' : 'fa-circle-xmark'"></i>
          <span>{{ app.status === 'approved' ? 'Approved' : 'Rejected' }} on {{ formatDate(app.reviewed_at) }}</span>
          <span v-if="app.reviewed_notes" class="reviewed-notes">{{ app.reviewed_notes }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
/**
 * VolunteerApplications — Admin (level 2+) dashboard for reviewing volunteer intake submissions.
 *
 * Features:
 * - Vetting standards HUD (background check requirements)
 * - Pre-approval checklist (must be checked before approve button enables)
 * - Approve creates: system_users record + user_role_assignments (role_id=11) + volunteer_profiles
 * - Reject marks application and notifies applicant
 */
export default {
  name: 'VolunteerApplications',
  data() {
    return {
      applications: [],
      loading: true,
      activeTab: 'pending',
      acting: null,
      showModal: null,
      modalNotes: '',
      checklists: {},  // { [appId]: { background, identity, orientation, references } }
      tabs: [
        { key: 'pending', label: 'Pending' },
        { key: 'approved', label: 'Approved' },
        { key: 'rejected', label: 'Rejected' },
        { key: 'all', label: 'All' },
      ],
    };
  },
  computed: {
    filtered() {
      if (this.activeTab === 'all') return this.applications;
      return this.applications.filter(a => a.status === this.activeTab);
    },
    counts() {
      const c = { pending: 0, approved: 0, rejected: 0, total: this.applications.length };
      for (const a of this.applications) {
        if (c[a.status] !== undefined) c[a.status]++;
      }
      return c;
    },
  },
  created() {
    this.loadApplications();
  },
  methods: {
    async loadApplications() {
      this.loading = true;
      try {
        this.applications = await this.fetchFromApi();
        // Initialize checklists
        for (const app of this.applications) {
          this.checklists[app.id] = {
            background: false,
            identity: false,
            orientation: false,
            references: false,
          };
        }
      } catch (e) {
        console.error('Failed to load volunteer applications:', e);
      } finally {
        this.loading = false;
      }
    },

    async fetchFromApi() {
      // TODO: Replace with real API call:
      // const res = await fetch('/app/vue_api/volunteer-applications.php');
      // return res.json();

      // For now, load from mock data (will be replaced once backend endpoint exists)
      return this.getMockData();
    },

    getMockData() {
      return [
        {
          id: 1,
          full_name: 'Riley Park',
          email: 'riley.park@test.archr',
          phone: '(828) 555-0101',
          location: 'Asheville 28801',
          motivation: 'I want to help my neighbors rebuild after Helene. I have construction experience and flexible weekends.',
          hear_about: 'friend',
          skills: ['carpentry', 'power-tools', 'roofing'],
          availability: ['weekend-am', 'weekend-pm', 'flexible'],
          has_tools: true,
          tools_notes: 'Own truck, basic hand tools, reliable transport',
          interest_type: 'field',
          physical_limits: null,
          referral_name: null,
          agreed_terms: true,
          status: 'approved',
          reviewed_at: new Date(Date.now() - 90 * 86400000).toISOString(),
          reviewed_notes: 'Experienced volunteer, background check clear. Fast-tracked.',
          created_at: new Date(Date.now() - 100 * 86400000).toISOString(),
        },
        {
          id: 2,
          full_name: 'Mary Chen',
          email: 'mary.chen@test.archr',
          phone: '(828) 555-0202',
          location: 'Hendersonville 28792',
          motivation: 'New to the area and want to meet people while giving back. Happy to help wherever needed.',
          hear_about: 'social-media',
          skills: ['none'],
          availability: ['weekday-pm', 'flexible'],
          has_tools: false,
          tools_notes: null,
          interest_type: 'any',
          physical_limits: null,
          referral_name: null,
          agreed_terms: true,
          status: 'pending',
          reviewed_at: null,
          reviewed_notes: null,
          created_at: new Date(Date.now() - 3 * 86400000).toISOString(),
        },
      ];
    },

    isReadyToApprove(app) {
      const cl = this.checklists[app.id];
      if (!cl) return false;
      return cl.background && cl.identity && cl.orientation;
    },

    approve(app) {
      if (!this.isReadyToApprove(app)) return;
      this.showModal = app.id;
      this.modalNotes = '';
    },

    async confirmApprove(app) {
      this.acting = app.id;
      this.showModal = null;
      try {
        const res = await fetch('/app/vue_api/volunteer-approve.php', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            application_id: app.id,
            notes: this.modalNotes,
            reviewed_by: this.$auth?.user?.id ?? 0,
          }),
        });
        const result = await res.json();
        if (!result.success) {
          alert('Approval failed: ' + (result.error || 'Unknown error'));
          return;
        }
        app.status = 'approved';
        app.reviewed_at = new Date().toISOString();
        app.reviewed_notes = this.modalNotes || 'Approved — background check clear.';
      } catch (e) {
        console.error('Approval failed:', e);
        alert('Approval request failed. Check console for details.');
      } finally {
        this.acting = null;
        this.modalNotes = '';
      }
    },

    async reject(app) {
      this.acting = app.id;
      const reason = prompt('Reason for rejection (optional):');
      if (reason === null) { this.acting = null; return; }
      try {
        // TODO: POST /app/vue_api/volunteer-reject.php
        console.log('Rejecting:', app.full_name, app.email);
        app.status = 'rejected';
        app.reviewed_at = new Date().toISOString();
        app.reviewed_notes = reason || 'Rejected — does not meet requirements at this time.';
      } finally {
        this.acting = null;
      }
    },

    formatDate(iso) {
      if (!iso) return '—';
      const d = new Date(iso);
      return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
    },

    formatSkill(s) {
      const map = {
        'demo': 'Demolition',
        'carpentry': 'Carpentry',
        'roofing': 'Roofing',
        'painting': 'Painting/Drywall',
        'landscaping': 'Landscaping',
        'debris': 'Debris removal',
        'power-tools': 'Power tools',
        'none': 'No experience',
      };
      return map[s] || s;
    },

    formatAvail(a) {
      const map = {
        'weekday-am': 'Weekday mornings',
        'weekday-pm': 'Weekday afternoons',
        'weekend-am': 'Weekend mornings',
        'weekend-pm': 'Weekend afternoons',
        'flexible': 'Flexible',
      };
      return map[a] || a;
    },

    formatInterest(t) {
      const map = {
        'field': 'Field work',
        'office': 'Office/Admin',
        'outreach': 'Community outreach',
        'writing': 'Writing/Storytelling',
        'any': 'Whatever is needed',
      };
      return map[t] || t;
    },
  },
};
</script>

<style scoped>
.vol-applications {
  max-width: 900px;
  margin: 0 auto;
  padding: 1.5rem;
}

.vol-header h2 {
  font-size: 1.4rem;
  color: var(--color-text, #1a1a2e);
  margin: 0 0 0.25rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.subtitle {
  color: var(--color-text-secondary, #64748b);
  margin: 0;
  font-size: 0.9rem;
}

/* Vetting HUD */
.vetting-hud {
  display: flex;
  gap: 1rem;
  background: #fff7ed;
  border: 1px solid #fed7aa;
  border-left: 4px solid #f97316;
  border-radius: 10px;
  padding: 1rem 1.25rem;
  margin: 1rem 0 1.25rem;
}

.hud-icon {
  flex-shrink: 0;
  width: 40px;
  height: 40px;
  background: #f97316;
  color: #fff;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
}

.hud-body h3 {
  font-size: 0.95rem;
  color: #431407;
  margin: 0 0 0.5rem;
}

.hud-body > p {
  font-size: 0.85rem;
  color: #78350f;
  margin: 0 0 0.5rem;
  line-height: 1.5;
}

.red-flags {
  list-style: none;
  padding: 0;
  margin: 0 0 0.5rem;
}

.red-flags li {
  font-size: 0.82rem;
  color: #9a3412;
  padding: 0.25rem 0;
  display: flex;
  align-items: flex-start;
  gap: 0.4rem;
}

.red-flags li i {
  color: #dc2626;
  margin-top: 0.15rem;
}

.hud-note {
  font-size: 0.78rem;
  color: #b45309;
  font-style: italic;
  margin: 0;
}

/* Stats */
.vol-stats {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 0.75rem;
  margin-bottom: 1.25rem;
}

.stat {
  background: var(--color-surface, #fff);
  border: 1px solid var(--color-border, #e2e8f0);
  border-radius: 8px;
  padding: 0.75rem;
  text-align: center;
}

.stat.pending {
  border-color: #f59e0b;
  background: #fffbeb;
}

.stat-num {
  display: block;
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--color-text, #1a1a2e);
}

.stat-label {
  font-size: 0.75rem;
  color: var(--color-text-secondary, #64748b);
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

/* Tabs */
.vol-tabs {
  display: flex;
  gap: 4px;
  border-bottom: 2px solid var(--color-border, #e2e8f0);
  margin-bottom: 1.25rem;
}

.vol-tab {
  background: none;
  border: none;
  padding: 0.6rem 1rem;
  font-family: inherit;
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--color-text-secondary, #64748b);
  cursor: pointer;
  border-bottom: 3px solid transparent;
  margin-bottom: -2px;
  transition: color 0.2s;
}

.vol-tab:hover { color: var(--color-text, #1a1a2e); }

.vol-tab.active {
  color: var(--color-accent, #2563eb);
  border-bottom-color: var(--color-accent, #2563eb);
}

.tab-count {
  display: inline-block;
  background: var(--color-border, #e2e8f0);
  color: var(--color-text-secondary, #64748b);
  padding: 0.1rem 0.4rem;
  border-radius: 999px;
  font-size: 0.7rem;
  margin-left: 0.3rem;
}

.vol-tab.active .tab-count {
  background: #dbeafe;
  color: #1e40af;
}

/* Loading / empty */
.vol-loading {
  text-align: center;
  padding: 2rem;
  color: var(--color-text-secondary, #64748b);
}

.vol-empty {
  text-align: center;
  padding: 3rem 1rem;
  color: var(--color-text-secondary, #64748b);
}

.vol-empty i {
  font-size: 2.5rem;
  margin-bottom: 0.75rem;
  opacity: 0.5;
}

/* Application cards */
.vol-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.vol-card {
  background: var(--color-surface, #fff);
  border: 1px solid var(--color-border, #e2e8f0);
  border-radius: 10px;
  overflow: hidden;
}

.vol-card.status-pending {
  border-left: 4px solid #f59e0b;
}

.vol-card.status-approved {
  border-left: 4px solid #22c55e;
}

.vol-card.status-rejected {
  border-left: 4px solid #ef4444;
}

.vol-card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem 1.25rem 0.5rem;
  gap: 0.75rem;
}

.vol-card-name {
  display: flex;
  flex-direction: column;
  gap: 0.15rem;
}

.vol-card-name strong {
  font-size: 1rem;
  color: var(--color-text, #1a1a2e);
}

.vol-card-date {
  font-size: 0.8rem;
  color: var(--color-text-secondary, #64748b);
}

.vol-status {
  padding: 0.2rem 0.6rem;
  border-radius: 999px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
}

.vol-status.status-pending {
  background: #fef3c7;
  color: #92400e;
}

.vol-status.status-approved {
  background: #dcfce7;
  color: #166534;
}

.vol-status.status-rejected {
  background: #fee2e2;
  color: #991b1b;
}

.vol-card-body {
  padding: 0.5rem 1.25rem;
}

.vol-row {
  display: flex;
  padding: 0.3rem 0;
  border-bottom: 1px dashed var(--color-border, #e2e8f0);
  font-size: 0.85rem;
  gap: 0.5rem;
}

.vol-row:last-child {
  border-bottom: none;
}

.vol-k {
  flex: 0 0 120px;
  font-weight: 600;
  color: var(--color-text-secondary, #64748b);
  text-transform: uppercase;
  font-size: 0.75rem;
  letter-spacing: 0.03em;
}

.vol-v {
  flex: 1;
  color: var(--color-text, #1a1a2e);
  line-height: 1.5;
}

.skill-tag,
.avail-tag {
  display: inline-block;
  background: var(--color-surface-alt, #f1f5f9);
  border: 1px solid var(--color-border, #e2e8f0);
  padding: 0.15rem 0.5rem;
  border-radius: 4px;
  font-size: 0.8rem;
  margin: 0.15rem 0.25rem 0.15rem 0;
}

/* Action area */
.vol-card-actions {
  display: flex;
  gap: 1.25rem;
  padding: 0.75rem 1.25rem 1rem;
  border-top: 1px solid var(--color-border, #e2e8f0);
  background: var(--color-surface-alt, #f8fafc);
}

.vetting-checklist {
  flex: 1;
  min-width: 0;
}

.vetting-checklist h4 {
  font-size: 0.8rem;
  color: var(--color-text-secondary, #64748b);
  text-transform: uppercase;
  letter-spacing: 0.04em;
  margin: 0 0 0.5rem;
  display: flex;
  align-items: center;
  gap: 0.35rem;
}

.vetting-checklist h4 i {
  color: #22c55e;
}

.vetting-checklist label {
  display: block;
  font-size: 0.8rem;
  color: var(--color-text, #1a1a2e);
  padding: 0.2rem 0;
  cursor: pointer;
}

.vetting-checklist input[type="checkbox"] {
  margin-right: 0.4rem;
}

.vol-actions-col {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  justify-content: center;
}

.vol-card-actions button {
  padding: 0.5rem 1.25rem;
  border-radius: 6px;
  font-weight: 600;
  font-size: 0.85rem;
  cursor: pointer;
  border: none;
  transition: opacity 0.2s;
  white-space: nowrap;
}

.vol-card-actions button:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.btn-approve {
  background: #22c55e;
  color: #fff;
}

.btn-approve:hover:not(:disabled) {
  background: #16a34a;
}

.btn-reject {
  background: var(--color-surface, #fff);
  color: #ef4444;
  border: 1px solid #fecaca;
}

.btn-reject:hover:not(:disabled) {
  background: #fee2e2;
}

/* Modal */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-dialog {
  background: var(--color-surface, #fff);
  border-radius: 12px;
  padding: 1.5rem;
  width: 90%;
  max-width: 420px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.modal-dialog h3 {
  margin: 0 0 0.75rem;
  font-size: 1.1rem;
  color: var(--color-text, #1a1a2e);
}

.modal-dialog textarea {
  width: 100%;
  padding: 0.6rem 0.75rem;
  border: 1px solid var(--color-border, #e2e8f0);
  border-radius: 6px;
  font-family: inherit;
  font-size: 0.9rem;
  resize: vertical;
  margin-bottom: 1rem;
}

.modal-actions {
  display: flex;
  gap: 0.75rem;
  justify-content: flex-end;
}

.modal-actions button {
  padding: 0.5rem 1.25rem;
  border-radius: 6px;
  font-weight: 600;
  font-size: 0.85rem;
  cursor: pointer;
  border: none;
}

.btn-secondary {
  background: var(--color-surface-alt, #f1f5f9);
  color: var(--color-text, #1a1a2e);
  border: 1px solid var(--color-border, #e2e8f0);
}

.btn-primary {
  background: var(--color-accent, #2563eb);
  color: #fff;
}

/* Reviewed info */
.vol-reviewed {
  padding: 0.5rem 1.25rem 1rem;
  font-size: 0.8rem;
  color: var(--color-text-secondary, #64748b);
  display: flex;
  align-items: center;
  gap: 0.4rem;
}

.vol-reviewed i.fa-circle-check {
  color: #22c55e;
}

.vol-reviewed i.fa-circle-xmark {
  color: #ef4444;
}

.vol.reviewed .reviewed-notes {
  display: block;
  margin-left: 1.4rem;
  font-style: italic;
}
</style>
