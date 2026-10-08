<template>
  <div v-if="visible" class="view-edit-modal" @click.self="$emit('close')" @keydown.esc="$emit('close')" tabindex="0">
    <div class="view-edit-modal__content">
      <!-- Header -->
      <div class="view-edit__header">
        <h2>View/Edit Application: {{ applicationName }}</h2>
        <div class="view-edit__meta">
          <span>Status: <strong>{{ application.status || 'Active' }}</strong></span>
          <span>Submitted: {{ formatDate(application.submittedAt || application.created_at) }}</span>
          <button class="btn btn-sm" @click="showOriginal = !showOriginal">
            <i :class="showOriginal ? 'fas fa-chevron-up' : 'fas fa-chevron-down'"></i>
            {{ showOriginal ? 'Hide' : 'View' }} Original Submission
          </button>
        </div>
      </div>

      <!-- Tabs -->
      <div class="view-edit__tabs">
        <button v-for="tab in tabs" :key="tab.id" class="view-edit__tab" :class="{ active: activeTab === tab.id }" @click="activeTab = tab.id">
          {{ tab.label }}
        </button>
      </div>

      <!-- Tab Content -->
      <div class="view-edit__body">
        <!-- Applicant Tab -->
        <div v-if="activeTab === 'applicant'" class="view-edit__section">
          <div class="view-edit__field" v-for="field in applicantFields" :key="field.key">
            <label>{{ field.label }}</label>
            <div class="view-edit__input-row">
              <input v-if="field.type !== 'textarea'" :type="field.type || 'text'" :value="getAppValue(field.key)" @input="onFieldChange(field.key, $event.target.value)" class="view-edit__input" />
              <textarea v-else :value="getAppValue(field.key)" @input="onFieldChange(field.key, $event.target.value)" rows="2" class="view-edit__input"></textarea>
              <button class="btn btn-icon btn-sm view-edit__edit-btn" @click="openEditField(field.key)" title="Edit & log">
                <i class="fas fa-edit"></i>
              </button>
            </div>
          </div>
        </div>

        <!-- Property Tab -->
        <div v-if="activeTab === 'property'" class="view-edit__section">
          <div class="view-edit__field" v-for="field in propertyFields" :key="field.key">
            <label>{{ field.label }}</label>
            <div class="view-edit__input-row">
              <input v-if="field.type !== 'textarea'" :type="field.type || 'text'" :value="getAppValue(field.key)" @input="onFieldChange(field.key, $event.target.value)" class="view-edit__input" />
              <textarea v-else :value="getAppValue(field.key)" @input="onFieldChange(field.key, $event.target.value)" rows="2" class="view-edit__input"></textarea>
              <button class="btn btn-icon btn-sm view-edit__edit-btn" @click="openEditField(field.key)" title="Edit & log">
                <i class="fas fa-edit"></i>
              </button>
            </div>
          </div>
        </div>

        <!-- Household Tab -->
        <div v-if="activeTab === 'household'" class="view-edit__section">
          <div class="view-edit__field" v-for="field in householdFields" :key="field.key">
            <label>{{ field.label }}</label>
            <div class="view-edit__input-row">
              <input :type="field.type || 'number'" :value="getAppValue(field.key)" @input="onFieldChange(field.key, $event.target.value)" class="view-edit__input" />
              <button class="btn btn-icon btn-sm view-edit__edit-btn" @click="openEditField(field.key)" title="Edit & log"><i class="fas fa-edit"></i></button>
            </div>
          </div>
        </div>

        <!-- Income Tab -->
        <div v-if="activeTab === 'income'" class="view-edit__section">
          <div class="view-edit__field" v-for="field in incomeFields" :key="field.key">
            <label>{{ field.label }}</label>
            <div class="view-edit__input-row">
              <input :type="field.type === 'money' ? 'number' : 'text'" :value="getAppValue(field.key)" @input="onFieldChange(field.key, $event.target.value)" class="view-edit__input" />
              <button class="btn btn-icon btn-sm view-edit__edit-btn" @click="openEditField(field.key)" title="Edit & log"><i class="fas fa-edit"></i></button>
            </div>
          </div>
        </div>

        <!-- Repair Needs Tab -->
        <div v-if="activeTab === 'repairs'" class="view-edit__section">
          <div class="view-edit__field">
            <label>Urgent: Unable to Stay</label>
            <textarea :value="getAppValue('urgent_unable_to_stay')" @input="onFieldChange('urgent_unable_to_stay', $event.target.value)" rows="2" class="view-edit__input"></textarea>
          </div>
          <div class="view-edit__field">
            <label>Additional Repair Details</label>
            <textarea :value="getAppValue('additional_repair_details')" @input="onFieldChange('additional_repair_details', $event.target.value)" rows="3" class="view-edit__input"></textarea>
          </div>
          <div class="view-edit__checklist">
            <label v-for="field in urgentFields" :key="field.key">
              <input type="checkbox" :checked="getAppValue(field.key)" @change="onFieldChange(field.key, $event.target.checked)" />
              {{ field.label }}
            </label>
          </div>
        </div>

        <!-- Edit History Tab -->
        <div v-if="activeTab === 'history'" class="view-edit__section">
          <h3>Edit History</h3>
          <div v-if="editHistory.length === 0" class="view-edit__empty">No edits have been made to this application.</div>
          <div v-for="edit in editHistory" :key="edit.id" class="view-edit__edit-entry">
            <div class="view-edit__edit-date">{{ formatDate(edit.edited_at) }} by {{ edit.editedBy || 'Unknown' }}</div>
            <div class="view-edit__edit-detail">
              <strong>{{ edit.field_name }}</strong>: "{{ edit.input_value }}" → "{{ edit.corrected_value }}"
            </div>
            <div v-if="edit.edit_note" class="view-edit__edit-note">Note: {{ edit.edit_note }}</div>
          </div>
        </div>
      </div>

      <!-- Original Submission (collapsible) -->
      <div v-if="showOriginal" class="view-edit__original">
        <h3>Original Submission (Immutable)</h3>
        <pre class="view-edit__original-data">{{ formatJson(originalSubmission) }}</pre>
      </div>

      <!-- Actions -->
      <div class="view-edit__actions">
        <button class="btn" @click="$emit('close')">Cancel</button>
        <button class="btn btn-primary" @click="saveChanges" :disabled="!hasChanges">
          Save Changes ({{ changeCount }} edit{{ changeCount !== 1 ? 's' : '' }})
        </button>
      </div>
    </div>

    <!-- Edit Field Modal -->
    <div v-if="editingField" class="view-edit__field-modal" @click.self="editingField = null">
      <div class="view-edit__field-modal-content">
        <h3>Edit: {{ getFieldLabel(editingField) }}</h3>
        <div class="view-edit__field-compare">
          <div>
            <label>Original Value</label>
            <div class="view-edit__original-value">{{ getAppValue(editingField) || '(empty)' }}</div>
          </div>
          <div>
            <label>New Value</label>
            <input v-model="newValue" class="view-edit__input" />
          </div>
        </div>
        <label class="view-edit__field">
          <span>Edit Note (optional — will be logged)</span>
          <textarea v-model="editNote" rows="2" class="view-edit__input" placeholder="Why is this being changed?"></textarea>
        </label>
        <div class="view-edit__actions">
          <button class="btn" @click="editingField = null">Cancel</button>
          <button class="btn btn-primary" @click="confirmEdit">Confirm Edit</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
/**
 * ViewEditSubmission
 *
 * Full application view with tabs for Applicant, Property, Household, Income, Repairs, and Edit History.
 * Allows inline editing with full audit logging to application_field_edits table.
 * Shows original submission as immutable reference.
 *
 * Props:
 *   visible           - Boolean
 *   application       - Application object with all fields
 *   originalSubmission - Raw intake_submissions data (immutable)
 *   editHistory       - Array of past edits
 *
 * Emits:
 *   close
 *   save(changes) — array of { field_name, corrected_value, edit_note }
 */
export default {
  name: 'ViewEditSubmission',
  props: {
    visible: { type: Boolean, default: false },
    application: { type: Object, default: function() { return {}; } },
    originalSubmission: { type: Object, default: function() { return {}; } },
    editHistory: { type: Array, default: function() { return []; } }
  },
  data: function() {
    return {
      activeTab: 'applicant',
      showOriginal: false,
      editingField: null,
      newValue: '',
      editNote: '',
      changes: {}
    };
  },
  computed: {
    tabs: function() {
      return [
        { id: 'applicant', label: 'Applicant' },
        { id: 'property', label: 'Property' },
        { id: 'household', label: 'Household' },
        { id: 'income', label: 'Income' },
        { id: 'repairs', label: 'Repair Needs' },
        { id: 'history', label: 'Edit History' }
      ];
    },
    applicantFields: function() {
      return [
        { key: 'applicant_first_name', label: 'First Name' },
        { key: 'applicant_last_name', label: 'Last Name' },
        { key: 'applicant_dob', label: 'Date of Birth', type: 'date' },
        { key: 'primary_spoken_language', label: 'Primary Spoken Language' },
        { key: 'home_phone', label: 'Home Phone' },
        { key: 'cell_phone', label: 'Cell Phone' },
        { key: 'email_address', label: 'Email Address' },
        { key: 'contact_method', label: 'Preferred Contact Method' },
        { key: 'contact_notes', label: 'Contact Notes', type: 'textarea' }
      ];
    },
    propertyFields: function() {
      return [
        { key: 'street_address', label: 'Street Address' },
        { key: 'unit', label: 'Unit' },
        { key: 'city_town', label: 'City/Town' },
        { key: 'state_province', label: 'State/Province' },
        { key: 'zip_postal_code', label: 'Zip/Postal Code' },
        { key: 'primary_residence', label: 'Primary Residence', type: 'checkbox' },
        { key: 'lived_one_year', label: 'Lived in Home 1+ Year', type: 'checkbox' },
        { key: 'move_in_date', label: 'Move-In Date', type: 'date' },
        { key: 'home_type', label: 'Type of Home' },
        { key: 'other_home_type', label: 'Other Home Type' },
        { key: 'year_built', label: 'Year Built', type: 'number' },
        { key: 'owns_home', label: 'Applicant Owns Home', type: 'checkbox' },
        { key: 'owns_lot', label: 'Applicant Owns Lot', type: 'checkbox' },
        { key: 'insurance_provider', label: 'Homeowner Insurance Provider' }
      ];
    },
    householdFields: function() {
      return [
        { key: 'household_size', label: 'Household Size', type: 'number' },
        { key: 'household_adults', label: 'Number of Adults', type: 'number' },
        { key: 'language', label: 'Language', type: 'text' },
        { key: 'is_referral', label: 'Is Referral', type: 'checkbox' },
        { key: 'referrer_name', label: 'Referrer Name' },
        { key: 'referrer_organization', label: 'Referrer Organization' },
        { key: 'referrer_email', label: 'Referrer Email' },
        { key: 'referrer_notes', label: 'Referrer Notes', type: 'textarea' }
      ];
    },
    incomeFields: function() {
      return [
        { key: 'gross_annual_income', label: 'Gross Annual Income', type: 'money' },
        { key: 'gross_monthly_income', label: 'Gross Monthly Income', type: 'money' },
        { key: 'ami_percent', label: 'AMI %', type: 'number' },
        { key: 'ami_year', label: 'AMI Year', type: 'number' },
        { key: 'ami_group', label: 'AMI Group' },
        { key: 'zero_income_agreed', label: 'Zero Income Agreed', type: 'checkbox' }
      ];
    },
    urgentFields: function() {
      return [
        { key: 'urgent_no_hvac', label: 'No HVAC' },
        { key: 'urgent_no_potable_water', label: 'No Potable Water' },
        { key: 'urgent_no_bathroom', label: 'No Bathroom' },
        { key: 'urgent_no_kitchen', label: 'No Kitchen' },
        { key: 'urgent_open_to_elements', label: 'Open to Elements' },
        { key: 'urgent_no_entry', label: 'No Entry/Exit' },
        { key: 'urgent_accessibility', label: 'Accessibility Issue' },
        { key: 'urgent_other_issue', label: 'Other Issue' },
        { key: 'urgent_eviction_risk', label: 'Eviction Risk' }
      ];
    },
    applicationName: function() {
      var app = this.application;
      return (app.applicant_first_name || '') + ' ' + (app.applicant_last_name || '') + ' — ' + (app.placecode || '');
    },
    hasChanges: function() {
      return Object.keys(this.changes).length > 0;
    },
    changeCount: function() {
      return Object.keys(this.changes).length;
    }
  },
  methods: {
    getAppValue: function(key) {
      return this.application[key] || '';
    },
    onFieldChange: function(key, value) {
      this.changes[key] = value;
    },
    openEditField: function(key) {
      this.editingField = key;
      this.newValue = this.getAppValue(key);
      this.editNote = '';
    },
    getFieldLabel: function(key) {
      var allFields = this.applicantFields.concat(this.propertyFields, this.householdFields, this.incomeFields, this.urgentFields);
      var field = allFields.find(function(f) { return f.key === key; });
      return field ? field.label : key;
    },
    confirmEdit: function() {
      if (!this.editingField) return;
      this.changes[this.editingField] = this.newValue;
      // Log the edit with note
      this.$emit('log-edit', {
        field_name: this.editingField,
        input_value: this.getAppValue(this.editingField),
        corrected_value: this.newValue,
        edit_note: this.editNote
      });
      this.editingField = null;
      this.newValue = '';
      this.editNote = '';
    },
    saveChanges: function() {
      var changes = Object.keys(this.changes).map(function(key) {
        return { field_name: key, corrected_value: self.changes[key] };
      });
      var self = this;
      this.$emit('save', {
        changes: changes,
        done: function(ok) {
          if (ok) {
            self.changes = {};
            self.$emit('close');
          }
        }
      });
    },
    formatDate: function(dateStr) {
      if (!dateStr) return '';
      var d = new Date(dateStr);
      if (isNaN(d.getTime())) return dateStr;
      return d.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
    },
    formatJson: function(obj) {
      if (!obj) return 'No original submission data.';
      try { return JSON.stringify(obj, null, 2); } catch (e) { return String(obj); }
    }
  }
};
</script>

<style scoped>
.view-edit-modal { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; z-index: 1000; }
.view-edit-modal__content { background: var(--bg-surface, #fff); border-radius: 8px; padding: 24px; width: 95%; max-width: 900px; max-height: 90vh; overflow-y: auto; }
.view-edit__header h2 { margin: 0 0 8px; font-size: 1.2rem; }
.view-edit__meta { display: flex; gap: 16px; font-size: 0.85rem; color: var(--color-text-muted, #6b7280); align-items: center; flex-wrap: wrap; }
.view-edit__tabs { display: flex; border-bottom: 1px solid var(--color-border, #e5e7eb); margin: 16px 0; overflow-x: auto; }
.view-edit__tab { padding: 8px 16px; border: none; background: none; font-size: 0.85rem; font-weight: 500; color: var(--color-text-muted, #6b7280); cursor: pointer; border-bottom: 2px solid transparent; white-space: nowrap; }
.view-edit__tab.active { color: var(--color-primary, #2a5c82); font-weight: 600; border-bottom-color: var(--color-primary, #2a5c82); }
.view-edit__section { display: flex; flex-direction: column; gap: 12px; padding: 8px 0; }
.view-edit__field { display: flex; flex-direction: column; gap: 4px; }
.view-edit__field label { font-size: 0.8rem; font-weight: 600; color: var(--color-text, #333); }
.view-edit__input-row { display: flex; gap: 6px; align-items: center; }
.view-edit__input { flex: 1; padding: 6px 10px; border: 1px solid var(--color-border-strong, #d1d5db); border-radius: 4px; font-size: 0.85rem; }
.view-edit__edit-btn { flex-shrink: 0; }
.view-edit__checklist { display: flex; flex-wrap: wrap; gap: 12px; margin-top: 8px; }
.view-edit__checklist label { display: flex; align-items: center; gap: 6px; font-size: 0.85rem; }
.view-edit__original { margin-top: 16px; padding: 16px; background: var(--bg-surface-alt, #f8f9fa); border-radius: 6px; }
.view-edit__original-data { background: #1e293b; color: #e2e8f0; padding: 12px; border-radius: 4px; font-size: 0.75rem; overflow-x: auto; max-height: 400px; }
.view-edit__actions { display: flex; justify-content: flex-end; gap: 8px; margin-top: 16px; padding-top: 16px; border-top: 1px solid var(--color-border, #e5e7eb); }
.view-edit__empty { text-align: center; padding: 20px; color: var(--color-text-muted, #6b7280); }
.view-edit__edit-entry { padding: 12px; border: 1px solid var(--color-border, #e5e7eb); border-radius: 6px; margin-bottom: 8px; }
.view-edit__edit-date { font-size: 0.8rem; color: var(--color-text-muted, #6b7280); }
.view-edit__edit-detail { font-size: 0.9rem; margin: 4px 0; }
.view-edit__edit-note { font-size: 0.8rem; color: var(--color-text-muted, #6b7280); font-style: italic; margin-top: 4px; }
.view-edit__field-modal { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; z-index: 1100; }
.view-edit__field-modal-content { background: var(--bg-surface, #fff); border-radius: 8px; padding: 24px; width: 90%; max-width: 500px; }
.view-edit__field-compare { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 12px; }
.view-edit__original-value { padding: 8px; background: var(--bg-surface-alt, #f8f9fa); border-radius: 4px; font-size: 0.85rem; min-height: 36px; }

.btn { display: inline-flex; align-items: center; gap: 6px; padding: 6px 14px; border: 1px solid var(--color-border-strong, #d1d5db); border-radius: 4px; background: var(--bg-surface, #fff); color: var(--color-text, #333); font-size: 0.85rem; font-weight: 500; cursor: pointer; }
.btn:hover { background: var(--bg-surface-alt, #f3f4f6); }
.btn:disabled { opacity: 0.5; cursor: not-allowed; }
.btn-sm { padding: 4px 10px; font-size: 0.8rem; }
.btn-primary { background: var(--color-primary, #2a5c82); color: #fff; border-color: var(--color-primary, #2a5c82); }
.btn-primary:hover { background: #1e4461; }
.btn-icon { padding: 4px 8px; min-width: 32px; justify-content: center; }
</style>
