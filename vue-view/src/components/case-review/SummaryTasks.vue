<!--
  SummaryTasks — the .summary-tasks section: the case's event log plus a
  Quick Task modal ("+ Log event" button). Mirrors .case-tasks in
  app/partials/case-review-body.php; the event model (communication logs,
  assessment events, progress tasks, notes) is the same one the QuickTasks
  view uses, scoped to this case.

  Props:
    events        Array   - newest first: { id, type, description, performedAt }
    eventsLoading Boolean - show a loading hint

  Emits:
    log-event ({ type, description, done }) - parent persists via
      caseService.saveCaseEvent, then calls done(true) on success or
      done(false) on failure (keeps the modal open so text isn't lost).
    create-sow (sowData) - when an Assessment - Scope of Work is submitted
-->
<template>
  <section class="panel summary-section">
    <div class="section-head">
      <h2>Tasks &amp; Activity</h2>
      <button type="button" class="btn btn--sm btn--primary" @click="openModal">
        + Log event
      </button>
    </div>

    <p v-if="eventsLoading" class="muted">Loading events…</p>
    <p v-else-if="events.length === 0" class="muted">No work orders or tasks recorded.</p>
    <ul v-else class="tasks__list">
      <li v-for="e in events" :key="e.id" class="event">
        <span class="event__type" :data-type="e.type">{{ typeLabel(e.type) }}</span>
        <span class="event__desc">{{ e.description }}</span>
        <span class="event__date">{{ formatDateTime(e.performedAt) }}</span>
      </li>
    </ul>

    <!-- Modal backdrop -->
    <div v-if="modalOpen" class="modal-backdrop" @click.self="attemptClose">
      <div class="modal modal--lg" role="dialog" aria-label="Log event">
        <div class="modal__header">
          <h2>Log event — {{ caseNumber }}</h2>
          <button type="button" class="modal__close" @click="attemptClose" title="Close">
            <i class="fas fa-times"></i>
          </button>
        </div>

        <form @submit.prevent="submit">
          <label class="modal__field">
            <span>Event type</span>
            <select v-model="form.type">
              <option v-for="(label, value) in EVENT_TYPES" :key="value" :value="value">
                {{ label }}
              </option>
            </select>
          </label>

          <!-- AssessmentSOW component (full form) -->
          <AssessmentSOW
            v-if="form.type === 'assessment_sow'"
            ref="sowForm"
            :application="applicationData"
            :org-name="orgName"
            :existing-sow="cachedSowItems"
            @fork-repair-need="onForkRepairNeed"
            @unsaved-changes="onUnsavedChanges"
          />

          <!-- Description for non-SOW types -->
          <label v-else class="modal__field">
            <span>Description</span>
            <textarea
              v-model.trim="form.description"
              rows="4"
              placeholder="What happened? Who did you talk to?"
            ></textarea>
          </label>

          <div class="modal__actions">
            <button type="submit" class="btn btn--primary" :disabled="savingLocal || !canSubmit">
              {{ savingLocal ? "Saving…" : "Save event" }}
            </button>
            <button type="button" class="btn" :disabled="savingLocal" @click="attemptClose">
              Cancel
            </button>
          </div>
        </form>
      </div>
    </div>
  </section>
</template>

<script>
import { formatDateTime } from "../../services/format";
import AssessmentSOW from "../AssessmentSOW.vue";

const EVENT_TYPES = {
  comm_logged: "Communication log",
  assessment_sow: "Assessment — Scope of Work",
  progress_task: "Progress task",
  note: "Note"
};

// Cache key for localStorage
const CACHE_KEY_PREFIX = 'archr-sow-draft-';

export default {
  name: "SummaryTasks",
  components: {
    AssessmentSOW
  },
  props: {
    events: { type: Array, default: () => [] },
    eventsLoading: { type: Boolean, default: false },
    caseNumber: { type: String, default: "" },
    applicationData: { type: Object, default: null },
    orgName: { type: String, default: "" }
  },
  data() {
    return {
      EVENT_TYPES,
      modalOpen: false,
      savingLocal: false,
      hasUnsavedSowChanges: false,
      form: { type: "comm_logged", description: "" },
      cachedSowItems: []
    };
  },
  computed: {
    canSubmit: function() {
      if (this.form.type === 'assessment_sow') {
        // Require at least one line item with a task name
        if (!this.$refs.sowForm || !this.$refs.sowForm.lineItems) return false;
        return this.$refs.sowForm.lineItems.some(function(item) {
          return item && item.taskName && item.taskName.trim() !== '';
        });
      }
      return !!this.form.description;
    }
  },
  methods: {
    formatDateTime,
    typeLabel(type) {
      return EVENT_TYPES[type] || "Note";
    },
    openModal() {
      // Restore cached SOW data if available
      var cached = this.loadCachedSow();
      this.cachedSowItems = cached && cached.length ? cached : [];
      this.form = { type: "comm_logged", description: "" };
      this.hasUnsavedSowChanges = false;
      this.modalOpen = true;
    },
    attemptClose() {
      if (this.form.type === 'assessment_sow' && this.hasUnsavedSowChanges) {
        if (confirm('You have unsaved changes in the Scope of Work. Are you sure you want to close? Your work will be cached and restored when you return.')) {
          this.saveSowCache();
          this.modalOpen = false;
        }
      } else {
        this.modalOpen = false;
      }
    },
    saveSowCache() {
      if (this.$refs.sowForm && this.$refs.sowForm.lineItems) {
        var items = this.$refs.sowForm.lineItems.filter(function(item) {
          return item.taskName || item.details || item.estimatedCost;
        });
        if (items.length) {
          try {
            localStorage.setItem(CACHE_KEY_PREFIX + this.caseNumber, JSON.stringify(items));
          } catch (e) { /* storage full or unavailable */ }
        }
      }
    },
    loadCachedSow() {
      try {
        var raw = localStorage.getItem(CACHE_KEY_PREFIX + this.caseNumber);
        return raw ? JSON.parse(raw) : null;
      } catch (e) { return null; }
    },
    clearSowCache() {
      try {
        localStorage.removeItem(CACHE_KEY_PREFIX + this.caseNumber);
      } catch (e) { /* ignore */ }
    },
    onForkRepairNeed(item) {
      this.$emit('fork-repair-need', item);
    },
    onUnsavedChanges(val) {
      this.hasUnsavedSowChanges = val;
    },
    submit() {
      if (this.form.type === 'assessment_sow') {
        // Submit SOW data
        if (!this.$refs.sowForm) return;
        var sowData = {
          type: 'assessment_sow',
          description: 'Scope of Work created with ' + this.$refs.sowForm.lineItems.filter(function(i) { return i.taskName; }).length + ' line items',
          lineItems: this.$refs.sowForm.lineItems,
          homeownerNames: this.$refs.sowForm.homeownerNames,
          fullAddress: this.$refs.sowForm.fullAddress,
          claimNumber: this.$refs.sowForm.claimNumber,
          isEmergency: this.$refs.sowForm.isEmergency,
          emergencyDesc: this.$refs.sowForm.emergencyDesc,
          totalEstimated: this.$refs.sowForm.totalEstimated,
          totalQuoted: this.$refs.sowForm.totalQuoted,
          totalActual: this.$refs.sowForm.totalActual
        };
        this.savingLocal = true;
        this.$emit('create-sow', Object.assign(sowData, {
          done: function(ok) {
            if (ok) {
              this.clearSowCache();
              this.savingLocal = false;
              this.modalOpen = false;
            } else {
              this.savingLocal = false;
            }
          }.bind(this)
        }));
      } else {
        // Standard event submit
        if (!this.form.description) return;
        this.savingLocal = true;
        this.$emit("log-event", {
          type: this.form.type,
          description: this.form.description,
          done: function(ok) {
            this.savingLocal = false;
            if (ok) this.modalOpen = false;
          }.bind(this)
        });
      }
    }
  },
  beforeDestroy: function() {
    // Cache SOW data if modal is open with unsaved changes
    if (this.modalOpen && this.form.type === 'assessment_sow') {
      this.saveSowCache();
    }
  }
};
</script>

<style scoped>
.modal--lg {
  max-width: 960px;
  width: 95%;
  max-height: 90vh;
  overflow-y: auto;
}
.modal__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}
.modal__header h2 {
  margin: 0;
  font-size: 1.2rem;
}
.modal__close {
  background: none;
  border: none;
  font-size: 1.1rem;
  color: var(--color-text-muted, #6b7280);
  cursor: pointer;
  padding: 4px 8px;
}
.modal__close:hover { color: var(--color-text, #333); }
.modal__field {
  display: block;
  margin-bottom: 12px;
}
.modal__field > span {
  display: block;
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--color-text, #333);
  margin-bottom: 4px;
}
.modal__field textarea,
.modal__field select {
  width: 100%;
  padding: 8px 10px;
  border: 1px solid var(--color-border-strong, #d1d5db);
  border-radius: 4px;
  font-size: 0.9rem;
  font-family: inherit;
}
</style>