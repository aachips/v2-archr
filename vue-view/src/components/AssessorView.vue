<template>
  <div class="assessor">
    <!-- Assessment Detail View (offline-capable form) -->
    <template v-if="activeAssessment">
      <div class="assessment-detail">
        <div class="assessment-detail__toolbar">
          <button class="btn btn-sm" @click="closeAssessment"><i class="fas fa-arrow-left"></i> Back</button>
          <h3 class="assessment-detail__title">
            <i class="fas fa-home"></i> {{ activeAssessment.applicant_name || 'Unknown' }}
          </h3>
          <div class="assessment-detail__status">
            <span v-if="!online" class="status-offline"><i class="fas fa-wifi"></i> Offline</span>
            <span v-else class="status-online"><i class="fas fa-wifi"></i> Online</span>
            <span v-if="hasDraft" class="status-draft"><i class="fas fa-floppy-disk"></i> Draft saved</span>
            <button v-if="hasDraft" class="btn btn-sm btn-sync" :disabled="!online || syncing" @click="syncDraft">
              <i :class="syncing ? 'fas fa-spinner fa-spin' : 'fas fa-cloud-arrow-up'"></i>
              {{ syncing ? 'Syncing…' : 'Sync to Server' }}
            </button>
          </div>
        </div>

        <div class="assessment-detail__form">
          <!-- Property Details -->
          <fieldset class="detail-section">
            <legend><i class="fas fa-map-marker-alt"></i> Property Details</legend>
            <div class="form-grid">
              <label class="detail-field">
                Address
                <input v-model="draft.address" type="text" placeholder="Street address" />
              </label>
              <label class="detail-field">
                City
                <input v-model="draft.city" type="text" placeholder="City" />
              </label>
              <label class="detail-field">
                State
                <input v-model="draft.state" type="text" placeholder="State" />
              </label>
              <label class="detail-field">
                ZIP
                <input v-model="draft.zip" type="text" placeholder="ZIP" />
              </label>
            </div>
          </fieldset>

          <!-- Repair Areas (multi-select from spec) -->
          <fieldset class="detail-section">
            <legend><i class="fas fa-tools"></i> Repair Areas</legend>
            <p class="section-hint">Select all areas that need repair. Check each one that applies.</p>
            <div class="repair-areas">
              <label v-for="area in REPAIR_AREAS" :key="area" class="area-check">
                <input type="checkbox" :value="area" v-model="draft.repairAreas" />
                <span>{{ area }}</span>
              </label>
            </div>
          </fieldset>

          <!-- Photos -->
          <fieldset class="detail-section">
            <legend><i class="fas fa-camera"></i> Photos</legend>
            <p class="section-hint">Photos are stored locally and uploaded when you sync. They are NOT stored until you sync.</p>
            <div class="photo-section">
              <div v-for="(cat, catIdx) in PHOTO_CATEGORIES" :key="cat" class="photo-category">
                <h4>{{ cat }}</h4>
                <div class="photo-grid">
                  <div v-for="(photo, pIdx) in draft.photos[catIdx] || []" :key="pIdx" class="photo-thumb">
                    <img :src="photo.preview" :alt="photo.name" />
                    <button class="photo-remove" @click="removePhoto(catIdx, pIdx)" title="Remove">&times;</button>
                  </div>
                  <label class="photo-add">
                    <input type="file" accept="image/*" capture="environment" @change="addPhoto(catIdx, $event)" />
                    <span><i class="fas fa-plus"></i> Add Photo</span>
                  </label>
                </div>
              </div>
            </div>
          </fieldset>

          <!-- Notes -->
          <fieldset class="detail-section">
            <legend><i class="fas fa-sticky-note"></i> Assessment Notes</legend>
            <label class="detail-field">
              Note Type
              <select v-model="draft.noteType">
                <option value="general">General Notes</option>
                <option value="safety">Safety Concerns</option>
                <option value="access">Access Notes</option>
                <option value="structural">Structural Observations</option>
              </select>
            </label>
            <label class="detail-field detail-field--full">
              Notes
              <textarea v-model="draft.notes" rows="6" placeholder="Describe condition, measurements, observations..."></textarea>
            </label>
            <label class="detail-field detail-field--check">
              <input type="checkbox" v-model="draft.notesPublic" />
              <span>Share with caseworkers (public)</span>
            </label>
          </fieldset>

          <!-- Verification -->
          <fieldset class="detail-section">
            <legend><i class="fas fa-clipboard-check"></i> Document Verification</legend>
            <div class="verify-grid">
              <label class="verify-item">
                <input type="checkbox" v-model="draft.verifyID" />
                <span><i class="fas fa-id-card"></i> Client Identity Verified</span>
              </label>
              <label class="verify-item">
                <input type="checkbox" v-model="draft.verifyIncome" />
                <span><i class="fas fa-file-invoice-dollar"></i> Income Verified</span>
              </label>
              <label class="verify-item">
                <input type="checkbox" v-model="draft.verifyOwnership" />
                <span><i class="fas fa-house-chimney"></i> Home Ownership Verified</span>
              </label>
            </div>
          </fieldset>

          <!-- Status -->
          <fieldset class="detail-section">
            <legend><i class="fas fa-flag-checkered"></i> Assessment Status</legend>
            <label class="detail-field">
              Status
              <select v-model="draft.status">
                <option value="scheduled">Scheduled</option>
                <option value="in_progress">In Progress — On Site</option>
                <option value="completed">Completed</option>
              </select>
            </label>
            <label class="detail-field">
              Estimated Hours
              <input v-model.number="draft.estimatedHours" type="number" min="0" step="0.5" placeholder="e.g., 4" />
            </label>
          </fieldset>
        </div>

        <!-- Save bar -->
        <div class="save-bar">
          <span class="save-bar__text">
            <template v-if="!online">
              <i class="fas fa-cloud-arrow-down"></i> Saved offline — will sync when back online
            </template>
            <template v-else-if="hasDraft">
              <i class="fas fa-check-circle"></i> Draft saved — click Sync to push to server
            </template>
            <template v-else>
              <i class="fas fa-pencil"></i> Start filling the form — changes auto-save as drafts
            </template>
          </span>
          <button class="btn btn-primary" :disabled="syncing" @click="saveDraft">
            <i class="fas fa-save"></i> Save Draft
          </button>
        </div>
      </div>
    </template>

    <p class="login-banner" role="status">
      <i class="fas fa-tape"></i>
      <span>Assessor Dashboard — Claim assessments from the Marketplace or manage your current assignments.</span>
    </p>

    <template v-if="loading">
      <p class="loading-text">Loading assessments…</p>
    </template>

    <template v-else>
      <!-- Claimed Assessments -->
      <section v-if="claimed.length" class="dash-section">
        <h3 class="dash-section-title"><i class="fas fa-clipboard-list"></i> My Claimed Assessments ({{ claimed.length }})</h3>
        <div class="assess-list">
          <article v-for="a in claimed" :key="a.id" class="assess-card">
            <div class="assess-card__header">
              <span class="assess-card__name">{{ a.applicant_name || 'Unknown' }}</span>
              <span :class="['pill', statusPill(a.status)]">{{ statusLabel(a.status) }}</span>
            </div>
            <p class="assess-card__address">{{ a.address }}<br>{{ a.city }}, {{ a.state }} {{ a.zip }}</p>
            <div class="assess-card__meta">
              <span v-if="a.case_number"><i class="fas fa-hashtag"></i> {{ a.case_number }}</span>
              <span v-if="a.scheduled_start"><i class="far fa-clock"></i> {{ formatDate(a.scheduled_start) }}</span>
              <span v-if="a.travel_min"><i class="fas fa-car"></i> {{ a.travel_min }} min</span>
              <span v-if="a.estimated_hours"><i class="fas fa-stopwatch"></i> ~{{ a.estimated_hours }}h</span>
            </div>
            <div v-if="a.completion_pct > 0" class="progress-bar">
              <div class="progress-bar__fill" :style="{ width: a.completion_pct + '%' }"></div>
              <span class="progress-bar__label">{{ a.completion_pct }}%</span>
            </div>
            <p v-if="a.notes" class="assess-card__notes"><i class="fas fa-sticky-note"></i> {{ a.notes }}</p>
            <div class="assess-card__actions">
              <button class="btn btn-primary btn-sm" @click="openAssessment(a)">
                <i class="fas fa-folder-open"></i> Open
              </button>
              <span v-if="a.draft" class="draft-badge"><i class="fas fa-cloud-arrow-down"></i> Draft saved offline</span>
            </div>
          </article>
        </div>
      </section>

      <!-- No claimed + Marketplace -->
      <section class="dash-section">
        <h3 class="dash-section-title"><i class="fas fa-store"></i> Marketplace — Available Assessments ({{ marketplace.length }})</h3>
        <p v-if="!claimed.length && !marketplace.length" class="empty-state">
          <i class="fas fa-check-circle"></i>
          <span>No assessments available right now. New submissions will appear here when they need assessment.</span>
        </p>
        <p v-if="!claimed.length && marketplace.length" class="section-hint">
          You haven't claimed any assessments yet. Click <strong>Claim</strong> to take on an assessment.
        </p>
        <div class="market-grid">
          <article v-for="m in marketplace" :key="m.id" :class="['market-card', m.urgent ? 'market-card--urgent' : '']">
            <div class="market-card__header">
              <span class="market-card__name">{{ m.applicant_name }}</span>
              <span v-if="m.urgent" class="pill pill-red"><i class="fas fa-triangle-exclamation"></i> Urgent</span>
              <span v-else-if="m.helene_related" class="pill pill-amber"><i class="fas fa-hurricane"></i> Helene</span>
            </div>
            <p class="market-card__address">{{ m.address }}<br>{{ m.city }}, {{ m.state }} {{ m.zip }}</p>
            <div class="market-card__meta">
              <span v-if="m.case_number"><i class="fas fa-hashtag"></i> {{ m.case_number }}</span>
              <span v-if="m.eligibility_score"><i class="fas fa-gauge-high"></i> Score {{ m.eligibility_score }}</span>
              <span><i class="far fa-clock"></i> {{ formatDate(m.submitted_at) }}</span>
            </div>
            <button class="btn btn-primary btn-sm" @click="claimAssessment(m)"><i class="fas fa-hand-pointer"></i> Claim Assessment</button>
          </article>
        </div>
      </section>

      <!-- Completed Assessments -->
      <section v-if="completed.length" class="dash-section">
        <h3 class="dash-section-title"><i class="fas fa-clock-rotate-left"></i> Completed Assessments ({{ completed.length }})</h3>
        <div class="completed-list">
          <article v-for="c in completed" :key="c.id" class="completed-item">
            <div>
              <strong>{{ c.applicant_name }}</strong>
              <span class="completed-item__addr"> — {{ c.address }}, {{ c.city }}</span>
            </div>
            <div class="completed-item__meta">
              <span v-if="c.case_number">{{ c.case_number }}</span>
              <span>Completed {{ formatDate(c.completed_at) }}</span>
            </div>
          </article>
        </div>
      </section>
    </template>
  </div>
</template>

<script>
const API = '/app/vue_api/assessor.php';
const DRAFT_KEY_PREFIX = 'archr:assessment-draft:';

// Repair areas from the legacy spec (property-card.json)
const REPAIR_AREAS = [
  'Roof', 'Exterior Walls', 'Foundation', 'Plumbing', 'Electrical',
  'HVAC', 'Kitchen', 'Bathroom', 'Flooring', 'Windows/Doors',
  'Insulation', 'Mold/Moisture', 'Structural', 'Accessibility', 'Other',
];

// Photo categories from the legacy spec
const PHOTO_CATEGORIES = ['Before', 'During', 'After'];

export default {
  name: 'AssessorView',
  data() {
    return {
      claimed: [],
      marketplace: [],
      completed: [],
      loading: true,
      // Assessment detail / offline
      activeAssessment: null,
      draft: this.emptyDraft(),
      syncing: false,
      online: navigator.onLine,
      REPAIR_AREAS,
      PHOTO_CATEGORIES,
    };
  },
  async mounted() {
    window.addEventListener('online', () => { this.online = true; });
    window.addEventListener('offline', () => { this.online = false; });
    await this.loadData();
  },
  beforeDestroy() {
    window.removeEventListener('online', () => {});
    window.removeEventListener('offline', () => {});
  },
  computed: {
    hasDraft() {
      return !!localStorage.getItem(this.draftKey());
    },
  },
  methods: {
    emptyDraft() {
      return {
        address: '', city: '', state: '', zip: '',
        repairAreas: [],
        photos: [[], [], []],  // Before, During, After — each stores {name, preview (data URL), data (base64)}
        noteType: 'general',
        notes: '',
        notesPublic: false,
        verifyID: false,
        verifyIncome: false,
        verifyOwnership: false,
        status: 'scheduled',
        estimatedHours: null,
      };
    },
    draftKey() {
      if (!this.activeAssessment) return '';
      return DRAFT_KEY_PREFIX + this.activeAssessment.id;
    },

    async loadData() {
      this.loading = true;
      try {
        const res = await fetch(API, {
          headers: { 'Authorization': 'Bearer ' + (this.$auth?.token || localStorage.getItem('archr_auth_token')) }
        });
        const data = await res.json();
        if (data.success) {
          this.claimed = (data.claimed || []).map(a => ({
            ...a,
            draft: !!localStorage.getItem(DRAFT_KEY_PREFIX + a.id),
          }));
          this.marketplace = data.marketplace || [];
          this.completed = data.completed || [];
        }
      } catch (_) { /* silent */ } finally { this.loading = false; }
    },

    async claimAssessment(m) {
      if (!confirm('Claim assessment for ' + m.applicant_name + '?')) return;
      try {
        const fd = new FormData();
        fd.append('action', 'claim_assessment');
        fd.append('submission_id', m.id);
        const res = await fetch(API, {
          method: 'POST',
          headers: { 'Authorization': 'Bearer ' + (this.$auth?.token || localStorage.getItem('archr_auth_token')) },
          body: fd,
        });
        const data = await res.json();
        if (data.success) {
          this.marketplace = this.marketplace.filter(x => x.id !== m.id);
          this.claimed.push({
            id: data.assessment_id,
            submission_id: m.id,
            applicant_name: m.applicant_name,
            address: m.address, city: m.city, state: m.state, zip: m.zip,
            case_number: m.case_number,
            status: 'scheduled',
            completion_pct: 0,
            scheduled_start: null,
            travel_min: null, estimated_hours: null, notes: '',
            draft: false,
          });
        }
      } catch (_) { alert('Failed to claim assessment.'); }
    },

    // --- Assessment detail / offline ---
    openAssessment(a) {
      this.activeAssessment = a;
      // Try to load existing draft
      const saved = localStorage.getItem(this.draftKey());
      if (saved) {
        try { this.draft = JSON.parse(saved); } catch (_) { this.draft = this.emptyDraft(); }
      } else {
        // Pre-fill from assessment data
        this.draft = this.emptyDraft();
        this.draft.address = a.address || '';
        this.draft.city = a.city || '';
        this.draft.state = a.state || '';
        this.draft.zip = a.zip || '';
        this.draft.status = a.status || 'scheduled';
        this.draft.estimatedHours = a.estimated_hours || null;
        this.draft.notes = a.notes || '';
      }
    },
    closeAssessment() {
      this.activeAssessment = null;
      this.draft = this.emptyDraft();
    },
    saveDraft() {
      try {
        localStorage.setItem(this.draftKey(), JSON.stringify(this.draft));
        // Update claimed list to show draft badge
        const item = this.claimed.find(c => c.id === this.activeAssessment.id);
        if (item) item.draft = true;
      } catch (e) {
        alert('Could not save draft: ' + e.message);
      }
    },
    async syncDraft() {
      if (!this.online || !this.hasDraft) return;
      this.syncing = true;
      try {
        const saved = JSON.parse(localStorage.getItem(this.draftKey()));
        const fd = new FormData();
        fd.append('action', 'update_assessment_status');
        fd.append('assessment_id', this.activeAssessment.id);
        fd.append('status', saved.status);
        fd.append('notes', saved.notes || '');
        fd.append('estimated_hours', saved.estimatedHours || '0');
        fd.append('address', saved.address || '');
        fd.append('city', saved.city || '');
        fd.append('state', saved.state || '');
        fd.append('zip', saved.zip || '');
        fd.append('repair_areas', JSON.stringify(saved.repairAreas || []));
        fd.append('note_type', saved.noteType || 'general');
        fd.append('notes_public', saved.notesPublic ? '1' : '0');
        fd.append('verified_id', saved.verifyID ? '1' : '0');
        fd.append('verified_income', saved.verifyIncome ? '1' : '0');
        fd.append('verified_ownership', saved.verifyOwnership ? '1' : '0');

        // Attach photos as multipart
        for (let catIdx = 0; catIdx < PHOTO_CATEGORIES.length; catIdx++) {
          const cat = PHOTO_CATEGORIES[catIdx];
          const photos = saved.photos[catIdx] || [];
          for (let pIdx = 0; pIdx < photos.length; pIdx++) {
            const photo = photos[pIdx];
            if (photo.data) {
              // Convert base64 to blob for FormData
              const byteChars = atob(photo.data.split(',')[1] || photo.data);
              const byteArr = [];
              for (let b = 0; b < byteChars.length; b++) byteArr.push(byteChars.charCodeAt(b));
              const blob = new Blob([new Uint8Array(byteArr)], { type: 'image/jpeg' });
              fd.append('photo_' + cat.toLowerCase() + '_' + pIdx, blob, photo.name);
            }
          }
        }

        const res = await fetch(API, {
          method: 'POST',
          headers: { 'Authorization': 'Bearer ' + (this.$auth?.token || localStorage.getItem('archr_auth_token')) },
          body: fd,
        });
        const result = await res.json();
        if (result.success) {
          // Clear the draft after successful sync
          localStorage.removeItem(this.draftKey());
          const item = this.claimed.find(c => c.id === this.activeAssessment.id);
          if (item) item.draft = false;
          alert('Assessment synced successfully!');
        } else {
          alert('Sync failed: ' + (result.message || 'Server error'));
        }
      } catch (e) {
        alert('Sync failed: ' + e.message);
      } finally {
        this.syncing = false;
      }
    },

    // --- Photo handling ---
    addPhoto(catIdx, event) {
      const file = event.target.files[0];
      if (!file) return;
      const reader = new FileReader();
      reader.onload = (e) => {
        if (!this.draft.photos[catIdx]) this.$set(this.draft.photos, catIdx, []);
        this.draft.photos[catIdx].push({
          name: file.name,
          preview: e.target.result,
          data: e.target.result, // base64 data URL
          size: file.size,
        });
      };
      reader.readAsDataURL(file);
      // Reset input so same file can be selected again
      event.target.value = '';
    },
    removePhoto(catIdx, pIdx) {
      this.draft.photos[catIdx].splice(pIdx, 1);
    },

    statusLabel(s) {
      return (s || 'scheduled').replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
    },
    statusPill(s) {
      return { scheduled: 'pill-blue', in_progress: 'pill-amber', completed: 'pill-green' }[s] || 'pill-gray';
    },
    formatDate(d) {
      if (!d) return '—';
      return new Date(d).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
    },
  },
};
</script>

<style scoped>
.assessor { max-width: 900px; margin: 0 auto; padding: 1.5rem; }
.login-banner { background: #eef2ff; border: 1px solid #c7d2fe; border-radius: 8px; padding: 0.75rem 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; font-size: 0.9rem; color: #3730a3; }
.loading-text { text-align: center; color: #94a3b8; padding: 3rem; }

.dash-section { margin-bottom: 2rem; }
.dash-section-title { font-size: 1.1rem; margin: 0 0 0.75rem; display: flex; align-items: center; gap: 0.5rem; color: #1e293b; }
.dash-section-title i { color: #2563eb; }

.empty-state { text-align: center; padding: 2rem; color: #94a3b8; display: flex; flex-direction: column; align-items: center; gap: 0.5rem; }
.empty-state i { font-size: 2rem; color: #22c55e; }
.section-hint { color: #64748b; font-size: 0.9rem; margin-bottom: 1rem; }

.assess-list { display: flex; flex-direction: column; gap: 0.75rem; }
.assess-card { background: var(--color-surface, #fff); border: 1px solid var(--color-border, #e2e8f0); border-radius: 10px; padding: 1rem; }
.assess-card__header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.3rem; }
.assess-card__name { font-weight: 600; font-size: 1rem; color: #1e293b; }
.assess-card__address { font-size: 0.85rem; color: #64748b; margin: 0 0 0.4rem; }
.assess-card__meta { display: flex; gap: 1rem; font-size: 0.8rem; color: #94a3b8; flex-wrap: wrap; }
.assess-card__meta i { margin-right: 0.25rem; }
.assess-card__notes { font-size: 0.85rem; color: #475569; margin: 0.4rem 0 0; }
.assess-card__notes i { color: #f59e0b; margin-right: 0.25rem; }

.progress-bar { position: relative; height: 6px; background: #e2e8f0; border-radius: 3px; margin: 0.5rem 0; overflow: hidden; }
.progress-bar__fill { height: 100%; background: #2563eb; border-radius: 3px; transition: width 0.3s; }
.progress-bar__label { position: absolute; right: 0; top: -18px; font-size: 0.75rem; color: #64748b; }

.market-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 0.75rem; }
.market-card { background: var(--color-surface, #fff); border: 1px solid var(--color-border, #e2e8f0); border-radius: 10px; padding: 1rem; transition: border-color 0.15s; }
.market-card:hover { border-color: #93c5fd; }
.market-card--urgent { border-left: 3px solid #dc2626; }
.market-card__header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.3rem; flex-wrap: wrap; gap: 0.3rem; }
.market-card__name { font-weight: 600; font-size: 0.95rem; color: #1e293b; }
.market-card__address { font-size: 0.85rem; color: #64748b; margin: 0 0 0.4rem; }
.market-card__meta { display: flex; gap: 0.75rem; font-size: 0.8rem; color: #94a3b8; margin-bottom: 0.5rem; }
.market-card__meta i { margin-right: 0.25rem; }

.completed-list { display: flex; flex-direction: column; gap: 0.5rem; }
.completed-item { padding: 0.5rem 0.75rem; background: #f8fafc; border-radius: 6px; display: flex; justify-content: space-between; align-items: center; font-size: 0.85rem; }
.completed-item__addr { color: #64748b; }
.completed-item__meta { display: flex; gap: 1rem; color: #94a3b8; font-size: 0.8rem; }

.pill { display: inline-block; padding: 0.15rem 0.5rem; border-radius: 999px; font-size: 0.75rem; font-weight: 600; }
.pill-blue { background: #dbeafe; color: #1e40af; }
.pill-amber { background: #fef3c7; color: #92400e; }
.pill-green { background: #dcfce7; color: #166534; }
.pill-red { background: #fee2e2; color: #991b1b; }
.pill-gray { background: #f1f5f9; color: #475569; }

.btn { padding: 0.35rem 0.75rem; border: 1px solid #d1d5db; border-radius: 6px; background: #fff; cursor: pointer; font-size: 0.8rem; }
.btn-primary { background: #2563eb; color: #fff; border-color: #2563eb; }
.btn-sm { padding: 0.2rem 0.5rem; font-size: 0.75rem; }

/* --- Assessment Detail / Offline --- */
.assessment-detail { max-width: 900px; margin: 0 auto; padding: 1.5rem; }
.assessment-detail__toolbar { display: flex; align-items: center; gap: 0.75rem; margin-bottom: 1.5rem; flex-wrap: wrap; }
.assessment-detail__title { font-size: 1.1rem; margin: 0; color: #1e293b; display: flex; align-items: center; gap: 0.4rem; }
.assessment-detail__status { display: flex; align-items: center; gap: 0.5rem; margin-left: auto; flex-wrap: wrap; }
.status-offline { color: #dc2626; font-size: 0.8rem; display: flex; align-items: center; gap: 0.3rem; }
.status-online { color: #16a34a; font-size: 0.8rem; display: flex; align-items: center; gap: 0.3rem; }
.status-draft { color: #2563eb; font-size: 0.8rem; display: flex; align-items: center; gap: 0.3rem; }
.btn-sync { background: #f0fdf4; color: #166534; border-color: #86efac; }
.btn-sync:disabled { opacity: 0.5; cursor: not-allowed; }

.assessment-detail__form { display: flex; flex-direction: column; gap: 1.5rem; }
.detail-section { border: 1px solid #e2e8f0; border-radius: 8px; padding: 1rem; }
.detail-section legend { font-size: 0.95rem; font-weight: 600; color: #1e293b; display: flex; align-items: center; gap: 0.4rem; }
.detail-section legend i { color: #2563eb; }
.section-hint { font-size: 0.8rem; color: #64748b; margin: 0 0 0.5rem; }

.form-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 0.75rem; }
.detail-field { display: flex; flex-direction: column; gap: 0.25rem; font-size: 0.85rem; color: #374151; }
.detail-field input,
.detail-field select,
.detail-field textarea { padding: 0.4rem 0.5rem; border: 1px solid #d1d5db; border-radius: 4px; font-size: 0.85rem; font-family: inherit; }
.detail-field--full { grid-column: 1 / -1; }
.detail-field--full textarea { width: 100%; resize: vertical; }
.detail-field--check { flex-direction: row; align-items: center; gap: 0.4rem; }

/* Repair areas */
.repair-areas { display: flex; flex-direction: column; gap: 0.4rem; }
.area-check { display: flex; align-items: center; gap: 0.5rem; font-size: 0.9rem; padding: 0.3rem 0.5rem; border-radius: 4px; }
.area-check:hover { background: #f0f4ff; }

/* Photos */
.photo-section { display: flex; flex-direction: column; gap: 1rem; }
.photo-category h4 { font-size: 0.85rem; color: #475569; margin: 0 0 0.3rem; }
.photo-grid { display: flex; flex-wrap: wrap; gap: 0.5rem; }
.photo-thumb { position: relative; width: 80px; height: 80px; border-radius: 6px; overflow: hidden; border: 1px solid #e2e8f0; }
.photo-thumb img { width: 100%; height: 100%; object-fit: cover; }
.photo-remove { position: absolute; top: 2px; right: 2px; width: 20px; height: 20px; border-radius: 50%; background: rgba(0,0,0,0.6); color: #fff; border: none; cursor: pointer; font-size: 0.8rem; line-height: 1; display: flex; align-items: center; justify-content: center; }
.photo-add { width: 80px; height: 80px; border: 2px dashed #d1d5db; border-radius: 6px; display: flex; align-items: center; justify-content: center; cursor: pointer; font-size: 0.8rem; color: #64748b; }
.photo-add:hover { border-color: #2563eb; color: #2563eb; }
.photo-add input { display: none; }

/* Verification */
.verify-grid { display: flex; flex-wrap: wrap; gap: 0.75rem; }
.verify-item { display: flex; align-items: center; gap: 0.5rem; padding: 0.5rem 0.75rem; background: #f8fafc; border-radius: 6px; font-size: 0.85rem; cursor: pointer; }
.verify-item:hover { background: #eef2ff; }
.verify-item i { color: #2563eb; }

/* Save bar */
.save-bar { position: sticky; bottom: 0; background: #fff; border-top: 1px solid #e2e8f0; padding: 0.75rem 1rem; display: flex; align-items: center; gap: 1rem; border-radius: 8px; margin-top: 1rem; }
.save-bar__text { font-size: 0.85rem; color: #475569; display: flex; align-items: center; gap: 0.4rem; }
.save-bar__text i { color: #2563eb; }

/* Draft badge */
.assess-card__actions { display: flex; align-items: center; gap: 0.5rem; margin-top: 0.5rem; }
.draft-badge { font-size: 0.75rem; color: #2563eb; display: flex; align-items: center; gap: 0.25rem; }
</style>
