<template>
  <div class="component-library">
    <header class="component-library__header">
      <h1>ARCHR Component Library</h1>
      <p class="component-library__subtitle">
        Vue components — live preview &amp; props inspector
      </p>
      <div class="component-library__filters">
        <label>
          Filter by category:
          <select v-model="filterCategory">
            <option value="">All</option>
            <option value="shared">Shared</option>
            <option value="feature">Feature</option>
            <option value="layout">Layout</option>
          </select>
        </label>
        <label>
          <input type="checkbox" v-model="showSource" /> Show source
        </label>
      </div>
    </header>

    <main class="component-library__grid">
      <div
        v-for="comp in filteredComponents"
        :key="comp.id"
        class="component-library__item"
        :class="{ 'is-active': activeComponent === comp.id }"
      >
        <!-- Component header -->
        <div class="component-library__item-header" @click="toggleComponent(comp.id)">
          <h3>
            <span class="component-library__badge" :class="'badge--' + comp.category">
              {{ comp.category }}
            </span>
            {{ comp.name }}
          </h3>
          <button class="component-library__toggle">
            <i :class="activeComponent === comp.id ? 'fas fa-chevron-up' : 'fas fa-chevron-down'"></i>
          </button>
        </div>

        <!-- Live preview + inspector -->
        <div v-if="activeComponent === comp.id" class="component-library__item-body">
          <p class="component-library__desc">{{ comp.description }}</p>

          <!-- Props editor -->
          <div v-if="comp.props" class="component-library__props">
            <h4>Props</h4>
            <table class="component-library__props-table">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Type</th>
                  <th>Default</th>
                  <th>Edit</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(prop, key) in comp.props" :key="key">
                  <td><code>{{ key }}</code></td>
                  <td>{{ prop.type }}</td>
                  <td>{{ prop.default != null ? prop.default : '—' }}</td>
                  <td>
                    <input
                      v-if="prop.type === 'Boolean'"
                      type="checkbox"
                      :checked="liveProps[comp.id] && liveProps[comp.id][key]"
                      @change="updateProp(comp.id, key, $event.target.checked)"
                    />
                    <input
                      v-else-if="prop.type === 'Number'"
                      type="number"
                      :value="getLiveProp(comp.id, key, prop.default)"
                      @input="updateProp(comp.id, key, parseFloat($event.target.value) || 0)"
                      style="width: 80px;"
                    />
                    <input
                      v-else
                      type="text"
                      :value="getLiveProp(comp.id, key, prop.default)"
                      @input="updateProp(comp.id, key, $event.target.value)"
                      style="width: 120px;"
                    />
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Live preview -->
          <div class="component-library__preview">
            <h4>Preview</h4>
            <div class="component-library__preview-frame">
              <component :is="comp.component" v-bind="getComponentProps(comp)" />
            </div>
          </div>

          <!-- Variant selector -->
          <div v-if="comp.variants && comp.variants.length" class="component-library__variants">
            <h4>Variants</h4>
            <div class="component-library__variant-tabs">
              <button
                v-for="v in comp.variants"
                :key="v.id"
                class="component-library__variant-tab"
                :class="{ 'is-active': (liveProps[comp.id] || {}).variant === v.id }"
                @click="updateProp(comp.id, 'variant', v.id)"
              >
                {{ v.label }}
              </button>
            </div>
          </div>

          <!-- Source code -->
          <div v-if="showSource" class="component-library__source">
            <h4>Source</h4>
            <pre><code>{{ comp.source }}</code></pre>
          </div>

          <!-- Events -->
          <div v-if="comp.events && comp.events.length" class="component-library__events">
            <h4>Emitted Events</h4>
            <ul>
              <li v-for="ev in comp.events" :key="ev">
                <code>{{ ev }}</code>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
// Import shared components
import ApplicationPreviewCard from './shared/ApplicationPreviewCard.vue';
import RepairNeedList from './shared/RepairNeedList.vue';
import ClaimWidget from './shared/ClaimWidget.vue';
import TabbedPanel from './shared/TabbedPanel.vue';
import DocumentCard from './shared/DocumentCard.vue';

// Import existing Vue components (siblings in same directory)
import LoginPage from './LoginPage.vue';
import ProfileSettings from './ProfileSettings.vue';
import SupportChat from './SupportChat.vue';
import DocumentsBucket from './DocumentsBucket.vue';
import FilterableCaseList from './FilterableCaseList.vue';
import QuickTasks from './QuickTasks.vue';
import AppHeader from './layout/AppHeader.vue';

// Sample data for live previews
var sampleApplication = {
  submissionDate: '2026-09-15T10:30:00Z',
  applicantName: 'Eileen Bailey',
  placecode: '247-RIVERSIDE',
  triageScore: 8,
  repairNeeds: [
    { trade: 'Roofing', description: 'Complete roof replacement, storm damage', triageScore: 9 },
    { trade: 'Carpentry', description: 'Replace flooring and rebuild south wall', triageScore: 7 },
    { trade: 'Plumbing', description: 'Replace main water line', triageScore: 6 },
    { trade: 'Electrical', description: 'Rewire damaged circuits', triageScore: 5 },
    { trade: 'Drywall', description: 'Replace ceiling and sheetrock materials', triageScore: 4 },
    { trade: 'Painting', description: 'Interior repaint after water damage', triageScore: 2 }
  ],
  claimed: false
};

var sampleRepairNeeds = [
  {
    id: 'rn-1',
    trade: 'Carpentry',
    description: 'Rental cabin completely destroyed by creek damage',
    triageScore: 8,
    dateReceived: '2026-09-10T14:00:00Z',
    claimedBy: 'Asheville Area Habitat for Humanity',
    childTasks: [
      { id: 't-1', description: 'Replace flooring' },
      { id: 't-2', description: 'Rebuild south wall' },
      { id: 't-3', description: 'Install new door frame' }
    ]
  },
  {
    id: 'rn-2',
    trade: 'Drywall',
    description: 'Replace ceiling and sheetrock materials',
    triageScore: 5,
    dateReceived: '2026-09-12T09:30:00Z',
    claimedBy: null,
    childTasks: []
  },
  {
    id: 'rn-3',
    trade: 'Plumbing',
    description: 'Fix burst pipe in basement, replace water heater',
    triageScore: 9,
    dateReceived: '2026-09-08T11:15:00Z',
    claimedBy: 'AHFH',
    childTasks: [
      { id: 't-4', description: 'Replace main water line' },
      { id: 't-5', description: 'Install new water heater' }
    ]
  }
];

export default {
  name: 'ComponentLibrary',
  props: {
    cases: { type: Array, default: function() { return []; } }
  },
  components: {
    ApplicationPreviewCard,
    RepairNeedList,
    ClaimWidget,
    TabbedPanel,
    DocumentCard,
    LoginPage,
    ProfileSettings,
    SupportChat,
    DocumentsBucket,
    FilterableCaseList,
    QuickTasks,
    AppHeader
  },
  data: function() {
    return {
      filterCategory: '',
      showSource: false,
      activeComponent: null,
      liveProps: {}
    };
  },
  computed: {
    components: function() {
      return [
        // --- Shared Components ---
        {
          id: 'ApplicationPreviewCard',
          name: 'Application Preview Card',
          category: 'shared',
          description: 'Reusable card showing application summary. Two variants: marketplace (claim action) and case-list (open/toolbox actions).',
          component: 'ApplicationPreviewCard',
          props: {
            application: { type: 'Object', default: sampleApplication },
            variant: { type: 'String', default: 'marketplace' },
            claimed: { type: 'Boolean', default: false }
          },
          variants: [
            { id: 'marketplace', label: 'Marketplace' },
            { id: 'case-list', label: 'Case List' }
          ],
          events: ['claim', 'open', 'review', 'toolbox', 'comment-submitted'],
          source: '<ApplicationPreviewCard\n  :application="app"\n  variant="marketplace"\n  @claim="onClaim"\n/>'
        },
        {
          id: 'RepairNeedList',
          name: 'Repair Need List / Card',
          category: 'shared',
          description: 'Hierarchical list of repair needs with parent/child task structure. Shows trade, description, triage score, claim status, and action buttons.',
          component: 'RepairNeedList',
          props: {
            repairNeeds: { type: 'Array', default: sampleRepairNeeds },
            currentOrg: { type: 'String', default: 'AHFH' },
            showClaim: { type: 'Boolean', default: true },
            showMarkMet: { type: 'Boolean', default: true },
            showEdit: { type: 'Boolean', default: true },
            showDelete: { type: 'Boolean', default: false }
          },
          events: ['claim-need', 'mark-met', 'edit-need', 'delete-need', 'edit-task', 'delete-task'],
          source: '<RepairNeedList\n  :repair-needs="needs"\n  current-org="AHFH"\n  @claim-need="onClaim"\n/>'
        },
        {
          id: 'ClaimWidget',
          name: 'Claim Widget / Card',
          category: 'shared',
          description: 'Shows claim status with color coding (Active/Expired/Released/Unclaimed). Actions: Claim, Release Claim (with confirmation modal), Renew Timer. Two layouts: card (full detail) and row (compact).',
          component: 'ClaimWidget',
          props: {
            status: { type: 'String', default: "'unclaimed'" },
            claimedBy: { type: 'String', default: "''" },
            claimDate: { type: 'String', default: null },
            expireDate: { type: 'String', default: null },
            orgName: { type: 'String', default: "''" },
            isCurrentUserOrg: { type: 'Boolean', default: false },
            layout: { type: 'String', default: "'card'" }
          },
          variants: [
            { id: 'card', label: 'Card' },
            { id: 'row', label: 'Row' }
          ],
          events: ['claim', 'renew', 'release-confirmed'],
          source: '<ClaimWidget\n  status="active"\n  claimed-by="AHFH"\n  @release-confirmed="onRelease"\n  @renew="onRenew"\n/>'
        },
        {
          id: 'TabbedPanel',
          name: 'Tabbed Information Panel',
          category: 'shared',
          description: 'Reusable tabbed container driven by configuration. Tabs can render child Vue components, slot content, or empty state. Supports badges and custom descriptions.',
          component: 'TabbedPanel',
          props: {
            tabs: { type: 'Array', default: '—' },
            initial: { type: 'String', default: "''" }
          },
          events: ['tab-changed'],
          source: '<TabbedPanel\n  :tabs="caseReviewTabs"\n  @tab-changed="onTabChange"\n/>'
        },
        {
          id: 'DocumentCard',
          name: 'Document Card + Metadata Modal',
          category: 'shared',
          description: 'Single document row with file icon, type badge, redaction status. Clicking opens the consolidated "Edit Document Metadata" modal (replaces 5 separate widgets).',
          component: 'DocumentCard',
          props: {
            doc: { type: 'Object', default: '—' },
            docTypes: { type: 'Array', default: 'Reference table' },
            folders: { type: 'Array', default: 'Dropbox paths' },
            placecodes: { type: 'Array', default: '—' },
            projects: { type: 'Array', default: '—' }
          },
          events: ['save', 'download', 'delete'],
          source: '<DocumentCard\n  :doc="file"\n  :doc-types="types"\n  @save="onSave"\n/>'
        },

        // --- Feature Components ---
        {
          id: 'DocumentsBucket',
          name: 'Documents Bucket',
          category: 'feature',
          description: 'Document management with upload, folder navigation, metadata editing, and redaction.',
          component: 'DocumentsBucket',
          events: ['file-uploaded', 'metadata-updated']
        },
        {
          id: 'FilterableCaseList',
          name: 'Filterable Case List',
          category: 'feature',
          description: 'Searchable, filterable table of cases with CSV/Excel export and column visibility toggles.',
          component: 'FilterableCaseList'
        },
        {
          id: 'QuickTasks',
          name: 'Quick Tasks (TLE-POC)',
          category: 'feature',
          description: 'Two-phase task engine with Quick Entry, Unverified Queue, and Triage Modal.',
          component: 'QuickTasks'
        },

        // --- Layout / Page Components ---
        {
          id: 'LoginPage',
          name: 'Login Page',
          category: 'layout',
          description: 'Authentication form with remember-me, email/password, and error handling.',
          component: 'LoginPage',
          events: ['logged-in']
        },
        {
          id: 'ProfileSettings',
          name: 'Profile Settings',
          category: 'layout',
          description: 'Tabbed profile with Profile Info, Menu Configuration, Search Columns, and session settings.',
          component: 'ProfileSettings'
        },
        {
          id: 'SupportChat',
          name: 'Support Chat Widget',
          category: 'layout',
          description: 'Floating bottom-right chat panel with bot greeting, category selector, and submit form.',
          component: 'SupportChat'
        },
        {
          id: 'AppHeader',
          name: 'App Header',
          category: 'layout',
          description: 'Top navigation bar with case selector, role dropdown, theme toggle, and avatar menu.',
          component: 'AppHeader'
        }
      ];
    },
    filteredComponents: function() {
      if (!this.filterCategory) return this.components;
      return this.components.filter(function(c) { return c.category === this.filterCategory; }.bind(this));
    }
  },
  methods: {
    toggleComponent: function(id) {
      this.activeComponent = this.activeComponent === id ? null : id;
    },
    getLiveProp: function(compId, propKey, defaultVal) {
      var compProps = this.liveProps[compId];
      if (!compProps || compProps[propKey] === undefined) return defaultVal;
      return compProps[propKey];
    },
    updateProp: function(compId, propKey, value) {
      if (!this.liveProps[compId]) this.liveProps[compId] = {};
      this.liveProps[compId][propKey] = value;
    },
    getComponentProps: function(comp) {
      var props = this.liveProps[comp.id] || {};
      // For components that need specific data, provide defaults or real data
      if (comp.id === 'ApplicationPreviewCard' && !props.application) {
        props.application = sampleApplication;
      }
      if (comp.id === 'RepairNeedList' && !props.repairNeeds) {
        props.repairNeeds = sampleRepairNeeds;
      }
      // Pass real cases if available
      if (comp.id === 'FilterableCaseList' || comp.id === 'QuickTasks') {
        if (this.cases && this.cases.length) {
          props.cases = this.cases;
        }
      }
      return props;
    }
  }
};
</script>

<style scoped>
.component-library {
  max-width: 960px;
  margin: 0 auto;
  padding: 40px 20px;
  font-family: var(--font-display, 'Poppins', sans-serif);
}

.component-library__header {
  margin-bottom: 40px;
  text-align: center;
}
.component-library__header h1 {
  font-size: 2rem;
  color: var(--color-primary, #2a5c82);
  margin-bottom: 8px;
}
.component-library__subtitle {
  font-size: 1.1rem;
  color: var(--color-text-muted, #6b7280);
  margin-bottom: 20px;
}
.component-library__filters {
  display: flex;
  gap: 20px;
  justify-content: center;
  align-items: center;
  font-size: 0.9rem;
}
.component-library__filters select,
.component-library__filters input[type="text"] {
  padding: 4px 8px;
  border: 1px solid var(--color-border-strong, #d1d5db);
  border-radius: 4px;
  margin-left: 8px;
}

.component-library__grid {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.component-library__item {
  background: var(--bg-surface, #fff);
  border: 1px solid var(--color-border, #e5e7eb);
  border-radius: var(--border-radius, 8px);
  overflow: hidden;
}

.component-library__item-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 20px;
  cursor: pointer;
  transition: background 0.2s;
}
.component-library__item-header:hover {
  background: var(--bg-surface-alt, #f3f4f6);
}
.component-library__item-header h3 {
  margin: 0;
  font-size: 1.1rem;
  display: flex;
  align-items: center;
  gap: 10px;
}

.component-library__badge {
  display: inline-block;
  font-size: 0.7rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  padding: 2px 8px;
  border-radius: 10px;
}
.badge--shared { background: #dbeafe; color: #1d4ed8; }
.badge--feature { background: #fef3c7; color: #92400e; }
.badge--layout { background: #e0e7ff; color: #4338ca; }

.component-library__toggle {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 1rem;
  color: var(--color-text-muted, #6b7280);
}

.component-library__item-body {
  padding: 0 20px 20px;
  border-top: 1px solid var(--color-border, #e5e7eb);
}

.component-library__desc {
  color: var(--color-text-muted, #6b7280);
  margin: 12px 0 20px;
  font-size: 0.95rem;
  line-height: 1.5;
}

.component-library__props { margin-bottom: 20px; }
.component-library__props h4,
.component-library__preview h4,
.component-library__variants h4,
.component-library__source h4,
.component-library__events h4 {
  font-size: 0.85rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--color-text-muted, #6b7280);
  margin-bottom: 8px;
}

.component-library__props-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.85rem;
}
.component-library__props-table th,
.component-library__props-table td {
  text-align: left;
  padding: 8px 12px;
  border-bottom: 1px solid var(--color-border, #e5e7eb);
}
.component-library__props-table th {
  background: var(--bg-surface-alt, #f3f4f6);
  font-weight: 600;
}
.component-library__props-table code {
  background: var(--bg-surface-alt, #f3f4f6);
  padding: 2px 6px;
  border-radius: 3px;
  font-size: 0.8rem;
}

.component-library__preview { margin-bottom: 20px; }
.component-library__preview-frame {
  border: 2px dashed var(--color-border-strong, #d1d5db);
  border-radius: var(--border-radius, 8px);
  padding: 20px;
  background: var(--bg-surface-alt, #f3f4f6);
}

.component-library__variant-tabs {
  display: flex;
  gap: 4px;
}
.component-library__variant-tab {
  padding: 6px 16px;
  border: 1px solid var(--color-border-strong, #d1d5db);
  border-radius: 4px 4px 0 0;
  background: var(--bg-surface-alt, #f3f4f6);
  cursor: pointer;
  font-size: 0.85rem;
  font-weight: 500;
  color: var(--color-text-muted, #6b7280);
}
.component-library__variant-tab.is-active {
  background: var(--color-primary, #2a5c82);
  color: #fff;
  border-color: var(--color-primary, #2a5c82);
}

.component-library__source pre {
  background: #1e293b;
  color: #e2e8f0;
  padding: 16px;
  border-radius: 6px;
  overflow-x: auto;
  font-size: 0.8rem;
  line-height: 1.5;
}

.component-library__events {
  margin-top: 16px;
}
.component-library__events ul {
  list-style: none;
  padding: 0;
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}
.component-library__events code {
  background: #fef3c7;
  color: #92400e;
  padding: 2px 10px;
  border-radius: 10px;
  font-size: 0.8rem;
  font-weight: 600;
}
</style>
