<template>
  <div class="tabbed-panel">
    <!-- Tab bar -->
    <div class="tabbed-panel__tabs" role="tablist">
      <button
        v-for="(tab, i) in tabs"
        :key="tab.id"
        role="tab"
        class="tabbed-panel__tab"
        :class="{ 'tabbed-panel__tab--active': activeTab === tab.id }"
        :aria-selected="activeTab === tab.id"
        @click="activeTab = tab.id"
      >
        {{ tab.label }}
        <span v-if="tab.badge" class="tabbed-panel__badge">{{ tab.badge }}</span>
      </button>
    </div>

    <!-- Tab content -->
    <div class="tabbed-panel__content" role="tabpanel">
      <!-- If tab has a component, render it -->
      <component
        v-if="activeTabComponent"
        :is="activeTabComponent"
        v-bind="activeTabProps"
      />
      <!-- If tab has raw slot content, render that -->
      <slot v-else-if="activeTabSlotName" :name="activeTabSlotName" />
      <!-- Fallback: show tab description or empty state -->
      <div v-else class="tabbed-panel__empty">
        <i class="fas fa-folder-open"></i>
        <p>{{ activeTabDescription || 'No content for this tab.' }}</p>
      </div>
    </div>
  </div>
</template>

<script>
/**
 * TabbedPanel
 *
 * Reusable tabbed container driven by configuration.
 * Tabs can render child components, slot content, or empty state.
 *
 * Props:
 *   tabs     - Array of tab config objects: { id, label, component?, props?, badge?, description?, slot? }
 *   initial  - ID of the tab to activate first (default: first tab)
 *
 * Tab config shape:
 *   {
 *     id:          string (unique)
 *     label:       string (display text)
 *     component:   Vue component name (optional)
 *     props:       Object of props to pass to component (optional)
 *     badge:       string | number (optional badge text)
 *     description: string (shown when no component/slot)
 *     slot:        string (slot name for custom content)
 *   }
 *
 * Emits:
 *   tab-changed (tabId)
 */
export default {
  name: 'TabbedPanel',
  props: {
    tabs: { type: Array, default: function() { return []; } },
    initial: { type: String, default: '' }
  },
  data: function() {
    return {
      activeTab: ''
    };
  },
  computed: {
    activeTabConfig: function() {
      for (var i = 0; i < this.tabs.length; i++) {
        if (this.tabs[i].id === this.activeTab) return this.tabs[i];
      }
      return null;
    },
    activeTabComponent: function() {
      return this.activeTabConfig ? this.activeTabConfig.component : null;
    },
    activeTabProps: function() {
      return this.activeTabConfig ? (this.activeTabConfig.props || {}) : {};
    },
    activeTabSlotName: function() {
      return this.activeTabConfig ? this.activeTabConfig.slot : null;
    },
    activeTabDescription: function() {
      return this.activeTabConfig ? this.activeTabConfig.description : null;
    }
  },
  watch: {
    activeTab: function(newTab) {
      this.$emit('tab-changed', newTab);
    }
  },
  created: function() {
    this.activeTab = this.initial || (this.tabs.length ? this.tabs[0].id : '');
  }
};
</script>

<style scoped>
.tabbed-panel {
  background: var(--bg-surface, #fff);
  border: 1px solid var(--color-border, #e5e7eb);
  border-radius: var(--border-radius, 8px);
  overflow: hidden;
}

.tabbed-panel__tabs {
  display: flex;
  border-bottom: 1px solid var(--color-border, #e5e7eb);
  background: var(--bg-surface-alt, #f8f9fa);
  overflow-x: auto;
  scrollbar-width: thin;
}

.tabbed-panel__tab {
  padding: 12px 20px;
  border: none;
  background: none;
  font-size: 0.85rem;
  font-weight: 500;
  color: var(--color-text-muted, #6b7280);
  cursor: pointer;
  white-space: nowrap;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  border-bottom: 2px solid transparent;
  transition: color 0.2s, border-color 0.2s;
}
.tabbed-panel__tab:hover {
  color: var(--color-text, #333);
}
.tabbed-panel__tab--active {
  color: var(--color-primary, #2a5c82);
  font-weight: 600;
  border-bottom-color: var(--color-primary, #2a5c82);
  background: var(--bg-surface, #fff);
}

.tabbed-panel__badge {
  display: inline-block;
  font-size: 0.7rem;
  font-weight: 700;
  background: var(--color-primary, #2a5c82);
  color: #fff;
  padding: 1px 7px;
  border-radius: 10px;
  min-width: 18px;
  text-align: center;
}

.tabbed-panel__content {
  padding: 20px;
  min-height: 200px;
}

.tabbed-panel__empty {
  text-align: center;
  padding: 40px 20px;
  color: var(--color-text-muted, #6b7280);
}
.tabbed-panel__empty i {
  font-size: 2rem;
  opacity: 0.3;
  display: block;
  margin-bottom: 12px;
}
</style>
