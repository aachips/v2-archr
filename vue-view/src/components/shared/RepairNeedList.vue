<template>
  <div class="repair-need-list">
    <div
      v-for="need in repairNeeds"
      :key="need.id || need._uid"
      class="repair-need-card"
      :class="{ 'repair-need-card--claimed': need.claimedBy }"
    >
      <!-- Parent repair need -->
      <div class="repair-need-card__parent">
        <div class="repair-need-card__main-info">
          <span class="repair-need-card__trade">{{ need.trade }}</span>
          <span class="repair-need-card__desc" :title="need.description">{{ need.description }}</span>
        </div>

        <div class="repair-need-card__meta-row">
          <span class="repair-need-card__triage" v-if="need.triageScore != null" :class="getTriageClass(need.triageScore)">
            <i class="fas fa-exclamation-triangle"></i> {{ need.triageScore }}
          </span>
          <span class="repair-need-card__date" v-if="need.dateReceived">
            Received {{ formatDate(need.dateReceived) }}
          </span>
          <span class="repair-need-card__claimed" v-if="need.claimedBy">
            <i class="fas fa-hand-holding-heart"></i>
            Claimed by: {{ need.claimedBy }}
          </span>
          <span class="repair-need-card__unclaimed" v-else>
            <i class="fas fa-globe"></i> Unclaimed
          </span>
        </div>

        <div class="repair-need-card__actions">
          <!-- Claim button (unclaimed) -->
          <button
            v-if="!need.claimedBy && showClaim"
            class="btn btn-primary btn-sm"
            @click="$emit('claim-need', need)"
          >
            <i class="fas fa-hand-holding-heart"></i> Claim Need
          </button>

          <!-- Mark Met (claimed by current org) -->
          <button
            v-if="need.claimedBy === currentOrg && showMarkMet"
            class="btn btn-success btn-sm"
            @click="$emit('mark-met', need)"
          >
            <i class="fas fa-check-circle"></i> Mark Met
          </button>

          <button
            v-if="showEdit"
            class="btn btn-sm"
            @click="$emit('edit-need', need)"
          >
            <i class="fas fa-edit"></i> Edit
          </button>
          <button
            v-if="showDelete"
            class="btn btn-sm btn-danger"
            @click="$emit('delete-need', need)"
          >
            <i class="fas fa-trash"></i> Delete
          </button>

          <!-- Expand/collapse child tasks -->
          <button
            v-if="need.childTasks && need.childTasks.length"
            class="btn btn-icon btn-sm"
            @click="toggleExpanded(need.id || need._uid)"
          >
            <i :class="isExpanded(need.id || need._uid) ? 'fas fa-chevron-up' : 'fas fa-chevron-down'"></i>
            {{ need.childTasks.length }} task{{ need.childTasks.length !== 1 ? 's' : '' }}
          </button>
        </div>
      </div>

      <!-- Child tasks (hierarchical) -->
      <div
        v-if="need.childTasks && need.childTasks.length && isExpanded(need.id || need._uid)"
        class="repair-need-card__children"
      >
        <div
          v-for="(task, i) in need.childTasks"
          :key="task.id || task._uid || i"
          class="repair-need-card__child"
        >
          <div class="repair-need-card__child-info">
            <span class="repair-need-card__child-icon"><i class="fas fa-arrow-right"></i></span>
            <span class="repair-need-card__child-desc">{{ task.description || task.title }}</span>
          </div>
          <div class="repair-need-card__child-actions">
            <button
              v-if="showEdit"
              class="btn btn-sm"
              @click="$emit('edit-task', { task: task, parentNeed: need })"
            >
              <i class="fas fa-edit"></i> Edit
            </button>
            <button
              v-if="showDelete"
              class="btn btn-sm btn-danger"
              @click="$emit('delete-task', { task: task, parentNeed: need })"
            >
              <i class="fas fa-trash"></i> Delete
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty state -->
    <div v-if="!repairNeeds.length" class="repair-need-list__empty">
      <i class="fas fa-wrench"></i>
      <p>No repair needs yet.</p>
    </div>
  </div>
</template>

<script>
/**
 * RepairNeedList
 *
 * Displays a list of repair needs with hierarchical parent/child structure.
 * Each parent repair need can have child tasks indented below.
 *
 * Props:
 *   repairNeeds  - Array of repair need objects
 *   currentOrg   - Name of the current organization (for claimed-by matching)
 *   showClaim    - Show "Claim Need" button (default: true)
 *   showMarkMet  - Show "Mark Met" button (default: true)
 *   showEdit     - Show Edit buttons (default: true)
 *   showDelete   - Show Delete buttons (default: false)
 *
 * Repair Need object shape:
 *   {
 *     id: string|number,
 *     trade: string,              // e.g. "Carpentry", "Roofing"
 *     description: string,
 *     triageScore: number|null,
 *     dateReceived: string|null,  // ISO date
 *     claimedBy: string|null,     // Organization name
 *     applicationLink: string,    // Link to parent application
 *     childTasks: [               // Optional child tasks
 *       { id, description/title }
 *     ]
 *   }
 *
 * Emits:
 *   claim-need, mark-met, edit-need, delete-need, edit-task, delete-task
 */
export default {
  name: 'RepairNeedList',
  props: {
    repairNeeds: { type: Array, default: function() { return []; } },
    currentOrg: { type: String, default: '' },
    showClaim: { type: Boolean, default: true },
    showMarkMet: { type: Boolean, default: true },
    showEdit: { type: Boolean, default: true },
    showDelete: { type: Boolean, default: false }
  },
  data: function() {
    return {
      expandedIds: {}
    };
  },
  methods: {
    toggleExpanded: function(id) {
      this.$set(this.expandedIds, id, !this.expandedIds[id]);
    },
    isExpanded: function(id) {
      return !!this.expandedIds[id];
    },
    formatDate: function(dateStr) {
      if (!dateStr) return '';
      var d = new Date(dateStr);
      if (isNaN(d.getTime())) return dateStr;
      return d.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
    },
    getTriageClass: function(score) {
      if (score == null) return '';
      if (score >= 8) return 'triage--critical';
      if (score >= 5) return 'triage--high';
      if (score >= 3) return 'triage--medium';
      return 'triage--low';
    }
  }
};
</script>

<style scoped>
.repair-need-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.repair-need-card {
  background: var(--bg-surface, #fff);
  border: 1px solid var(--color-border, #e5e7eb);
  border-radius: var(--border-radius, 8px);
  padding: 16px;
  transition: box-shadow 0.2s ease;
}
.repair-need-card:hover {
  box-shadow: var(--shadow, 0 2px 8px rgba(0,0,0,0.08));
}
.repair-need-card--claimed {
  border-left: 3px solid var(--color-success, #16a34a);
}

.repair-need-card__parent {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.repair-need-card__main-info {
  display: flex;
  align-items: baseline;
  gap: 10px;
}

.repair-need-card__trade {
  font-weight: 700;
  font-size: 0.95rem;
  color: var(--color-primary, #2a5c82);
  min-width: 90px;
}

.repair-need-card__desc {
  flex: 1;
  font-size: 0.9rem;
  color: var(--color-text, #333);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.repair-need-card__meta-row {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
  font-size: 0.8rem;
}

.repair-need-card__triage {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-weight: 700;
  padding: 2px 8px;
  border-radius: 10px;
}
.triage--critical { background: #fee2e2; color: #dc2626; }
.triage--high { background: #fef3c7; color: #d97706; }
.triage--medium { background: #dbeafe; color: #2563eb; }
.triage--low { background: #d1fae5; color: #059669; }

.repair-need-card__date {
  color: var(--color-text-muted, #6b7280);
}

.repair-need-card__claimed {
  color: var(--color-success, #16a34a);
  font-weight: 600;
  display: inline-flex;
  align-items: center;
  gap: 4px;
}
.repair-need-card__unclaimed {
  color: var(--color-text-muted, #6b7280);
  font-style: italic;
  display: inline-flex;
  align-items: center;
  gap: 4px;
}

.repair-need-card__actions {
  display: flex;
  align-items: center;
  gap: 6px;
  flex-wrap: wrap;
}

/* Child tasks */
.repair-need-card__children {
  margin-top: 12px;
  padding: 12px 16px;
  background: var(--bg-surface-alt, #f8f9fa);
  border-radius: 6px;
  border: 1px solid var(--color-border, #e5e7eb);
}

.repair-need-card__child {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  padding: 6px 0;
  border-bottom: 1px solid var(--color-border, #e5e7eb);
  font-size: 0.85rem;
}
.repair-need-card__child:last-child { border-bottom: 0; }

.repair-need-card__child-info {
  display: flex;
  align-items: center;
  gap: 8px;
  flex: 1;
}

.repair-need-card__child-icon {
  color: var(--color-text-muted, #9ca3af);
  font-size: 0.7rem;
  margin-left: 12px;
}

.repair-need-card__child-desc {
  color: var(--color-text, #333);
}

.repair-need-card__child-actions {
  display: flex;
  gap: 4px;
}

/* Empty state */
.repair-need-list__empty {
  text-align: center;
  padding: 40px 20px;
  color: var(--color-text-muted, #6b7280);
}
.repair-need-list__empty i {
  font-size: 2rem;
  opacity: 0.3;
  display: block;
  margin-bottom: 12px;
}

/* Buttons (scoped overrides) */
.btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 14px;
  border: 1px solid var(--color-border-strong, #d1d5db);
  border-radius: 4px;
  background: var(--bg-surface, #fff);
  color: var(--color-text, #333);
  font-size: 0.85rem;
  font-weight: 500;
  cursor: pointer;
}
.btn:hover { background: var(--bg-surface-alt, #f3f4f6); }
.btn-sm { padding: 4px 10px; font-size: 0.8rem; }
.btn-primary { background: var(--color-primary, #2a5c82); color: #fff; border-color: var(--color-primary, #2a5c82); }
.btn-primary:hover { background: #1e4461; }
.btn-success { background: var(--color-success, #16a34a); color: #fff; border-color: var(--color-success, #16a34a); }
.btn-success:hover { background: #15803d; }
.btn-danger { color: #dc2626; border-color: #fca5a5; }
.btn-danger:hover { background: #fee2e2; }
.btn-icon { padding: 4px 8px; min-width: 32px; justify-content: center; }
</style>
