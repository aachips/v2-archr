<template>
  <div class="assessment-sow">
    <!-- Header info -->
    <div class="assessment-sow__header">
      <h2>Scope of Work</h2>
      <p class="assessment-sow__subtitle">Add repair tasks from the assessment. Each task can be claimed as a separate repair need or grouped into a case.</p>
      <div class="assessment-sow__meta">
        <span class="assessment-sow__meta-item"><i class="fas fa-building"></i> {{ orgName }}</span>
        <span class="assessment-sow__meta-item"><i class="fas fa-hashtag"></i> {{ claimNumber }}</span>
        <span class="assessment-sow__meta-item"><i class="fas fa-calendar"></i> {{ formatDate(dateCreated) }}</span>
      </div>
    </div>

    <!-- SOW Line Items Table -->
    <div class="assessment-sow__table-wrap">
      <table class="assessment-sow__table">
        <thead>
          <tr>
            <th>Task</th>
            <th>Location</th>
            <th>Details</th>
            <th>Estimated</th>
            <th>Quoted</th>
            <th>Actual</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(item, i) in lineItems" :key="item.id || i">
            <td><input type="text" v-model="item.taskName" placeholder="e.g., Debris Removal" class="assessment-sow__input" /></td>
            <td><input type="text" v-model="item.location" placeholder="e.g., Whole property" class="assessment-sow__input" /></td>
            <td><textarea v-model="item.details" rows="2" placeholder="Description of repair..." class="assessment-sow__textarea"></textarea></td>
            <td><input type="text" v-model="item.estimatedCost" placeholder="$0" class="assessment-sow__input--money" @input="onCostChange" /></td>
            <td><input type="text" v-model="item.quotedCost" placeholder="$0" class="assessment-sow__input--money" @input="onCostChange" /></td>
            <td><input type="text" v-model="item.actualCost" placeholder="$0" class="assessment-sow__input--money" @input="onCostChange" /></td>
            <td>
              <div class="assessment-sow__row-actions">
                <button class="btn btn-sm btn-icon" title="Fork into claimable repair need" @click="forkToRepairNeed(item)">
                  <i class="fas fa-code-branch"></i>
                </button>
                <button class="btn btn-sm btn-icon btn-danger" title="Remove" @click="removeLineItem(i)">
                  <i class="fas fa-trash"></i>
                </button>
              </div>
            </td>
          </tr>
        </tbody>
        <tfoot>
          <tr>
            <td colspan="3" style="text-align:right; font-weight:600;">Total Construction Price:</td>
            <td style="font-weight:700; color: var(--color-primary, #2a5c82);">{{ formatCurrency(totalEstimated) }}</td>
            <td style="font-weight:700;">{{ formatCurrency(totalQuoted) }}</td>
            <td style="font-weight:700;">{{ formatCurrency(totalActual) }}</td>
            <td></td>
          </tr>
        </tfoot>
      </table>
    </div>

    <button class="btn btn-sm" @click="addLineItem" style="margin-top: 12px;">
      <i class="fas fa-plus"></i> Add Repair Task
    </button>

    <!-- Assessment metadata (collapsible) -->
    <details class="assessment-sow__meta-details" style="margin-top: 24px;">
      <summary>Assessment Metadata</summary>
      <div class="assessment-sow__meta-form">
        <div class="assessment-sow__field">
          <label>Homeowner(s)</label>
          <input type="text" v-model="homeownerNames" placeholder="e.g., Eileen Bailey" class="assessment-sow__input" />
        </div>
        <div class="assessment-sow__field">
          <label>Full Address</label>
          <input type="text" v-model="fullAddress" placeholder="247 Riverside Drive, Asheville, NC 28801" class="assessment-sow__input" />
        </div>
        <div class="assessment-sow__field">
          <label>Claim Number</label>
          <input type="text" v-model="claimNumber" placeholder="e.g., D245VI" class="assessment-sow__input" />
        </div>
        <div class="assessment-sow__field">
          <label>
            <input type="checkbox" v-model="isEmergency" /> This is an emergency repair to make the home livable
          </label>
        </div>
        <div class="assessment-sow__field" v-if="isEmergency">
          <label>Emergency Description</label>
          <textarea v-model="emergencyDesc" rows="2" placeholder="Brief description of emergency repairs..."></textarea>
        </div>
      </div>
    </details>

    <!-- Documents section -->
    <div class="assessment-sow__docs" style="margin-top: 24px;">
      <h3>Assessment Documents</h3>
      <p class="assessment-sow__doc-hint">Upload the assessment PDF, site photos, and roof diagram here. Files are stored in the Document Bucket.</p>
      <div class="assessment-sow__doc-list">
        <div v-for="(doc, i) in documents" :key="i" class="assessment-sow__doc-item">
          <i :class="docIcon(doc)"></i>
          <span class="assessment-sow__doc-name">{{ doc.name }}</span>
          <span class="assessment-sow__doc-type">{{ doc.type }}</span>
        </div>
      </div>
      <button class="btn btn-sm" style="margin-top: 8px;">
        <i class="fas fa-upload"></i> Upload Document
      </button>
    </div>
  </div>
</template>

<script>
/**
 * AssessmentSOW
 *
 * Form for adding/editing a Scope of Work attached to an application.
 * Line items can be forked into claimable Repair Needs.
 * Tracks estimated, quoted, and actual costs for the future costing engine.
 *
 * Props:
 *   application  - Object with application data
 *   orgName      - Organization conducting the assessment
 *   existingSow  - Array of existing SOW line items (optional)
 *
 * Emits:
 *   save(sowData)
 *   fork-repair-need(lineItem)
 *   remove-line-item(lineItem)
 */
export default {
  name: 'AssessmentSOW',
  props: {
    application: { type: Object, default: null },
    orgName: { type: String, default: '' },
    existingSow: { type: Array, default: function() { return []; } }
  },
  data: function() {
    var items = this.existingSow.length ? this.existingSow : [
      { taskName: '', location: '', details: '', estimatedCost: null, quotedCost: null, actualCost: null }
    ];
    return {
      lineItems: items,
      homeownerNames: this.application && this.application.applicantName ? this.application.applicantName : '',
      fullAddress: this.application && this.application.address ? this.application.address : '',
      claimNumber: '',
      dateCreated: new Date().toISOString(),
      isEmergency: false,
      emergencyDesc: '',
      documents: []
    };
  },
  watch: {
    homeownerNames: function() { this.$emit('unsaved-changes', true); },
    fullAddress: function() { this.$emit('unsaved-changes', true); },
    claimNumber: function() { this.$emit('unsaved-changes', true); }
  },
  computed: {
    totalEstimated: function() {
      return this.lineItems.reduce(function(sum, item) {
        var val = parseFloat(item.estimatedCost);
        return sum + (isNaN(val) ? 0 : val);
      }, 0);
    },
    totalQuoted: function() {
      return this.lineItems.reduce(function(sum, item) {
        var val = parseFloat(item.quotedCost);
        return sum + (isNaN(val) ? 0 : val);
      }, 0);
    },
    totalActual: function() {
      return this.lineItems.reduce(function(sum, item) {
        var val = parseFloat(item.actualCost);
        return sum + (isNaN(val) ? 0 : val);
      }, 0);
    }
  },
  methods: {
    addLineItem: function() {
      var newItem = { taskName: '', location: '', details: '', estimatedCost: null, quotedCost: null, actualCost: null };
      this.lineItems.push(newItem);
      // Force Vue reactivity
      this.$set(this.lineItems, this.lineItems.length - 1, newItem);
    },
    removeLineItem: function(index) {
      this.lineItems.splice(index, 1);
    },
    forkToRepairNeed: function(item) {
      this.$emit('fork-repair-need', item);
    },
    onCostChange: function() {
      this.$emit('unsaved-changes', true);
    },
    formatDate: function(dateStr) {
      if (!dateStr) return '';
      var d = new Date(dateStr);
      if (isNaN(d.getTime())) return dateStr;
      return d.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
    },
    formatCurrency: function(val) {
      if (val == null || val === 0) return '—';
      return '$' + Number(val).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    },
    docIcon: function(doc) {
      var name = (doc.name || '').toLowerCase();
      if (name.endsWith('.pdf')) return 'fas fa-file-pdf';
      if (name.endsWith('.jpg') || name.endsWith('.jpeg') || name.endsWith('.png')) return 'fas fa-file-image';
      return 'fas fa-file';
    }
  }
};
</script>

<style scoped>
.assessment-sow__header { margin-bottom: 20px; }
.assessment-sow__header h2 { font-size: 1.3rem; color: var(--color-primary, #2a5c82); margin-bottom: 4px; }
.assessment-sow__subtitle { font-size: 0.9rem; color: var(--color-text-muted, #6b7280); margin-bottom: 12px; }
.assessment-sow__meta { display: flex; gap: 16px; font-size: 0.85rem; color: var(--color-text-muted, #6b7280); }
.assessment-sow__meta-item { display: inline-flex; align-items: center; gap: 4px; }

.assessment-sow__table-wrap { overflow-x: auto; }
.assessment-sow__table { width: 100%; border-collapse: collapse; min-width: 800px; }
.assessment-sow__table th,
.assessment-sow__table td { padding: 8px 10px; border-bottom: 1px solid var(--color-border, #e5e7eb); vertical-align: top; }
.assessment-sow__table th { text-align: left; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--color-text-muted, #6b7280); background: var(--bg-surface-alt, #f3f4f6); }
.assessment-sow__table tfoot td { font-size: 0.95rem; border-top: 2px solid var(--color-border-strong, #d1d5db); padding-top: 12px; }

.assessment-sow__input,
.assessment-sow__textarea,
.assessment-sow__input--money {
  width: 100%;
  padding: 6px 8px;
  border: 1px solid var(--color-border-strong, #d1d5db);
  border-radius: 4px;
  font-size: 0.85rem;
  font-family: inherit;
}
.assessment-sow__input--money { text-align: right; width: 90px; }
.assessment-sow__textarea { resize: vertical; min-height: 50px; }

.assessment-sow__row-actions { display: flex; gap: 4px; }

.assessment-sow__meta-details { border: 1px solid var(--color-border, #e5e7eb); border-radius: 6px; padding: 12px 16px; }
.assessment-sow__meta-details summary { cursor: pointer; font-weight: 600; font-size: 0.9rem; color: var(--color-primary, #2a5c82); }
.assessment-sow__meta-form { margin-top: 12px; display: flex; flex-direction: column; gap: 12px; }
.assessment-sow__field label { display: block; font-size: 0.8rem; font-weight: 600; color: var(--color-text, #333); margin-bottom: 4px; }
.assessment-sow__field input[type="text"],
.assessment-sow__field textarea { width: 100%; padding: 8px 10px; border: 1px solid var(--color-border-strong, #d1d5db); border-radius: 4px; font-size: 0.85rem; }
.assessment-sow__field textarea { resize: vertical; }
.assessment-sow__field label input[type="checkbox"] { margin-right: 6px; }

.assessment-sow__docs h3 { font-size: 1rem; color: var(--color-text, #333); margin-bottom: 4px; }
.assessment-sow__doc-hint { font-size: 0.8rem; color: var(--color-text-muted, #6b7280); margin-bottom: 8px; }
.assessment-sow__doc-list { display: flex; flex-direction: column; gap: 4px; }
.assessment-sow__doc-item { display: flex; align-items: center; gap: 8px; padding: 6px 10px; background: var(--bg-surface-alt, #f3f4f6); border-radius: 4px; font-size: 0.85rem; }
.assessment-sow__doc-item i { color: var(--color-text-muted, #6b7280); min-width: 20px; text-align: center; }
.assessment-sow__doc-name { flex: 1; font-weight: 500; }
.assessment-sow__doc-type { font-size: 0.75rem; color: var(--color-text-muted, #6b7280); }

.btn { display: inline-flex; align-items: center; gap: 6px; padding: 6px 14px; border: 1px solid var(--color-border-strong, #d1d5db); border-radius: 4px; background: var(--bg-surface, #fff); color: var(--color-text, #333); font-size: 0.85rem; font-weight: 500; cursor: pointer; }
.btn:hover { background: var(--bg-surface-alt, #f3f4f6); }
.btn-sm { padding: 4px 10px; font-size: 0.8rem; }
.btn-icon { padding: 4px 8px; min-width: 32px; justify-content: center; }
.btn-danger { color: #dc2626; border-color: #fca5a5; }
.btn-danger:hover { background: #fee2e2; }
</style>
