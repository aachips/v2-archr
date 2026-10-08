<template>
  <div class="case-review" v-if="caseItem">
    <!-- Header -->
    <div class="case-review__header">
      <button class="case-review__back" @click="$emit('back')"><i class="fas fa-arrow-left"></i> Back to Cases</button>
      <h1>Case Review: {{ caseItem.placecode }}</h1>
      <div class="case-review__meta">
        <span>{{ caseItem.applicantName }}</span>
        <span class="case-review__status" :class="'status--' + caseItem.status">{{ caseItem.status }}</span>
        <button class="btn btn-sm" @click="showViewEditModal = true">
          <i class="fas fa-edit"></i> View/Edit Application
        </button>
      </div>
    </div>

    <!-- Tabs -->
    <div class="case-review__tabs">
      <button v-for="tab in tabs" :key="tab.id" :class="['case-review__tab', { active: activeTab === tab.id }]" @click="activeTab = tab.id">
        {{ tab.label }}
        <span v-if="tab.badge" class="case-review__badge">{{ tab.badge }}</span>
      </button>
    </div>

    <!-- Tab Content -->
    <div class="case-review__content">
      <!-- Case Overview -->
      <div v-if="activeTab === 'overview'" class="case-review__tab-content">
        <h2>Case Overview</h2>
        <div class="case-review__info-grid">
          <div class="case-review__info-item"><label>Placecode</label><span>{{ caseItem.placecode }}</span></div>
          <div class="case-review__info-item"><label>Applicant</label><span>{{ caseItem.applicantName }}</span></div>
          <div class="case-review__info-item"><label>Status</label><span>{{ caseItem.status }}</span></div>
          <div class="case-review__info-item"><label>Created</label><span>{{ formatDate(caseItem.createdAt) }}</span></div>
          <div class="case-review__info-item"><label>Application ID</label><span>{{ caseItem.applicationId }}</span></div>
        </div>

        <!-- Projects in this case -->
        <h3 style="margin-top: 24px;">Projects ({{ projects.length }})</h3>
        <div v-if="projects.length === 0" class="case-review__empty">
          <p>No projects created yet. Projects are created from SOW line items.</p>
        </div>
        <div v-for="project in projects" :key="project.id" class="case-review__project-card">
          <h4>{{ project.name }}</h4>
          <p>{{ project.description }}</p>
          <div class="case-review__project-meta">
            <span>Estimated: {{ formatCurrency(project.estimatedCost) }}</span>
            <span>Status: {{ project.status }}</span>
          </div>
        </div>
      </div>

      <!-- Repair Needs -->
      <div v-if="activeTab === 'repair-needs'" class="case-review__tab-content">
        <h2>Repair Needs</h2>
        <RepairNeedList
          :repair-needs="repairNeeds"
          :current-org="caseItem.organization"
          :show-claim="false"
          @edit-need="onEditNeed"
          @edit-task="onEditTask"
        />
      </div>

      <!-- Documents -->
      <div v-if="activeTab === 'documents'" class="case-review__tab-content">
        <h2>Documents</h2>
        <DocumentsBucket :case-id="caseItem.id" />
      </div>

      <!-- Activity Log -->
      <div v-if="activeTab === 'activity'" class="case-review__tab-content">
        <h2>Activity Log</h2>
        <SummaryTasks :events="events" :case-number="caseItem.placecode" />
      </div>
    </div>

    <!-- Parse SOW into Cases/Projects Modal -->
    <div v-if="showParseModal" class="case-review__modal" @click.self="showParseModal = false">
      <div class="case-review__modal-content">
        <h3>Parse SOW into Cases & Projects</h3>
        <p>This will create one case per SOW line item. Each case can have its own projects and repair tasks.</p>
        
        <div class="case-review__parse-preview">
          <div v-for="item in sowLineItems" :key="item.id" class="case-review__parse-item">
            <input type="checkbox" :checked="selectedItems.includes(item.id)" @change="toggleItem(item.id)" />
            <span class="case-review__parse-task">{{ item.taskName }}</span>
            <span class="case-review__parse-cost">{{ formatCurrency(item.estimatedCost) }}</span>
          </div>
        </div>

        <div class="case-review__modal-actions">
          <button class="btn" @click="showParseModal = false">Cancel</button>
          <button class="btn btn-primary" :disabled="selectedItems.length === 0" @click="parseSow">
            Create {{ selectedItems.length }} Case{{ selectedItems.length !== 1 ? 's' : '' }}
          </button>
        </div>
      </div>
    </div>

    <!-- View/Edit Application Modal -->
    <ViewEditSubmission
      :visible="showViewEditModal"
      :application="application || {}"
      :original-submission="originalSubmission"
      :edit-history="editHistory"
      @close="showViewEditModal = false"
      @save="onSaveApplication"
      @log-edit="onLogEdit"
    />
  </div>
</template>

<script>
import RepairNeedList from './shared/RepairNeedList.vue';
import DocumentsBucket from './DocumentsBucket.vue';
import SummaryTasks from './case-review/SummaryTasks.vue';
import ViewEditSubmission from './ViewEditSubmission.vue';

export default {
  name: 'CaseReview',
  components: { RepairNeedList, DocumentsBucket, SummaryTasks, ViewEditSubmission },
  props: {
    caseItem: { type: Object, default: null },
    application: { type: Object, default: null },
    originalSubmission: { type: Object, default: function() { return {}; } },
    editHistory: { type: Array, default: function() { return []; } },
    sowLineItems: { type: Array, default: function() { return []; } }
  },
  data: function() {
    return {
      activeTab: 'overview',
      showParseModal: false,
      showViewEditModal: false,
      selectedItems: [],
      projects: [],
      repairNeeds: [],
      events: []
    };
  },
  computed: {
    tabs: function() {
      return [
        { id: 'overview', label: 'Overview' },
        { id: 'repair-needs', label: 'Repair Needs', badge: this.repairNeeds.length },
        { id: 'documents', label: 'Documents' },
        { id: 'activity', label: 'Activity' }
      ];
    }
  },
  methods: {
    toggleItem: function(id) {
      var idx = this.selectedItems.indexOf(id);
      if (idx === -1) this.selectedItems.push(id);
      else this.selectedItems.splice(idx, 1);
    },
    parseSow: function() {
      var self = this;
      var itemsToParse = this.sowLineItems.filter(function(item) {
        return self.selectedItems.indexOf(item.id) !== -1;
      });

      // Emit event to parent to create cases
      this.$emit('parse-sow', {
        items: itemsToParse,
        applicationId: this.application && this.application.id,
        done: function(cases) {
          self.projects = cases.map(function(c) { return { id: c.id, name: c.placecode, description: c.repairType, estimatedCost: 0, status: 'active' }; });
          self.showParseModal = false;
          self.selectedItems = [];
        }
      });
    },
    onEditNeed: function(need) { console.log('Edit need:', need); },
    onEditTask: function(task) { console.log('Edit task:', task); },
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
    onSaveApplication: function(payload) {
      // TODO: API call to save application field edits
      console.log('Save application changes:', payload.changes);
      payload.done(true);
    },
    onLogEdit: function(editData) {
      // TODO: API call to log edit to application_field_edits
      console.log('Log edit:', editData);
    }
  }
};
</script>

<style scoped>
.case-review { max-width: 1000px; margin: 0 auto; padding: 24px 20px; }
.case-review__header { margin-bottom: 24px; }
.case-review__back { background: none; border: none; color: var(--color-primary, #2a5c82); cursor: pointer; font-size: 0.9rem; padding: 4px 0; margin-bottom: 8px; }
.case-review__header h1 { margin: 0 0 8px; font-size: 1.4rem; }
.case-review__meta { display: flex; gap: 16px; align-items: center; font-size: 0.9rem; color: var(--color-text-muted, #6b7280); }
.case-review__status { font-size: 0.75rem; font-weight: 700; padding: 2px 8px; border-radius: 10px; text-transform: uppercase; }
.status--active { background: #d1fae5; color: #059669; }
.status--completed { background: #dbeafe; color: #2563eb; }
.status--on-hold { background: #fef3c7; color: #d97706; }

.case-review__tabs { display: flex; border-bottom: 1px solid var(--color-border, #e5e7eb); margin-bottom: 24px; }
.case-review__tab { padding: 10px 20px; border: none; background: none; font-size: 0.9rem; font-weight: 500; color: var(--color-text-muted, #6b7280); cursor: pointer; border-bottom: 2px solid transparent; }
.case-review__tab.active { color: var(--color-primary, #2a5c82); font-weight: 600; border-bottom-color: var(--color-primary, #2a5c82); }
.case-review__badge { display: inline-block; font-size: 0.7rem; font-weight: 700; background: var(--color-primary, #2a5c82); color: #fff; padding: 1px 6px; border-radius: 10px; margin-left: 6px; }

.case-review__info-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; }
.case-review__info-item { display: flex; flex-direction: column; gap: 4px; }
.case-review__info-item label { font-size: 0.75rem; text-transform: uppercase; color: var(--color-text-muted, #6b7280); font-weight: 600; }
.case-review__info-item span { font-size: 0.95rem; }

.case-review__project-card { background: var(--bg-surface-alt, #f3f4f6); border: 1px solid var(--color-border, #e5e7eb); border-radius: 6px; padding: 16px; margin-bottom: 12px; }
.case-review__project-card h4 { margin: 0 0 4px; font-size: 1rem; }
.case-review__project-card p { margin: 0 0 8px; font-size: 0.85rem; color: var(--color-text-muted, #6b7280); }
.case-review__project-meta { display: flex; gap: 16px; font-size: 0.8rem; }

.case-review__modal { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; z-index: 1000; }
.case-review__modal-content { background: var(--bg-surface, #fff); border-radius: 8px; padding: 24px; width: 90%; max-width: 600px; max-height: 90vh; overflow-y: auto; }
.case-review__parse-preview { margin: 16px 0; max-height: 300px; overflow-y: auto; }
.case-review__parse-item { display: flex; align-items: center; gap: 8px; padding: 8px 0; border-bottom: 1px solid var(--color-border, #e5e7eb); }
.case-review__parse-task { flex: 1; font-size: 0.9rem; }
.case-review__parse-cost { font-size: 0.85rem; font-weight: 600; color: var(--color-primary, #2a5c82); }
.case-review__modal-actions { display: flex; justify-content: flex-end; gap: 8px; margin-top: 16px; }

.case-review__empty { text-align: center; padding: 20px; color: var(--color-text-muted, #6b7280); font-size: 0.9rem; }

.btn { display: inline-flex; align-items: center; gap: 6px; padding: 6px 14px; border: 1px solid var(--color-border-strong, #d1d5db); border-radius: 4px; background: var(--bg-surface, #fff); color: var(--color-text, #333); font-size: 0.85rem; font-weight: 500; cursor: pointer; }
.btn:hover { background: var(--bg-surface-alt, #f3f4f6); }
.btn:disabled { opacity: 0.5; cursor: not-allowed; }
.btn-primary { background: var(--color-primary, #2a5c82); color: #fff; border-color: var(--color-primary, #2a5c82); }
.btn-primary:hover { background: #1e4461; }
</style>
