<template>
  <div class="app-preview-card" :class="[variant, { 'is-expanded': expanded }]">
    <!-- Top row: metadata + actions -->
    <div class="app-preview-card__header">
      <div class="app-preview-card__meta">
        <span class="app-preview-card__date">{{ formatDate(submissionDate) }}</span>
        <span class="app-preview-card__name">{{ formatName(applicantName) }}</span>
        <span class="app-preview-card__placecode" v-if="placecode">{{ placecode }}</span>
        <span class="app-preview-card__triage" v-if="triageScore !== null" :class="triageClass">
          <i class="fas fa-exclamation-triangle"></i>
          {{ triageScore }}
        </span>
      </div>
      <div class="app-preview-card__actions">
        <button
          v-if="variant === 'marketplace'"
          class="btn btn-primary btn-sm"
          :disabled="claimed"
          @click="$emit('claim', application)"
        >
          <i class="fas fa-hand-holding-heart"></i> Claim
        </button>
        <button
          v-if="variant === 'case-list'"
          class="btn btn-secondary btn-sm"
          @click="$emit('open', application)"
        >
          Open
        </button>
        <button
          class="btn btn-icon btn-sm"
          title="More options"
          @click="showMore = !showMore"
        >
          <i class="fas fa-ellipsis-v"></i>
        </button>
        <button
          class="btn btn-icon btn-sm"
          :title="expanded ? 'Collapse' : 'Expand'"
          @click="expanded = !expanded"
        >
          <i :class="expanded ? 'fas fa-chevron-up' : 'fas fa-chevron-down'"></i>
        </button>
      </div>
    </div>

    <!-- Expanded content -->
    <div v-if="expanded" class="app-preview-card__body">
      <!-- Repair needs preview (show 4, then "see more") -->
      <ul class="app-preview-card__repairs" v-if="repairNeeds.length">
        <li
          v-for="(need, i) in visibleRepairs"
          :key="need.id || i"
          class="app-preview-card__repair"
        >
          <span class="app-preview-card__trade">{{ need.trade }}</span>
          <span class="app-preview-card__desc">{{ need.description }}</span>
          <span class="app-preview-card__triage-sm" :class="getTriageClass(need.triageScore)" v-if="need.triageScore !== null">
            {{ need.triageScore }}
          </span>
        </li>
        <li v-if="repairNeeds.length > 4" class="app-preview-card__repair--more">
          +{{ repairNeeds.length - 4 }} more repair needs
        </li>
      </ul>

      <!-- Marketplace variant actions -->
      <div v-if="variant === 'marketplace'" class="app-preview-card__footer">
        <button class="btn btn-sm" @click="$emit('review', application)">
          Review
        </button>
        <button class="btn btn-sm" @click="showComments = true">
          Comment
        </button>
      </div>

      <!-- Case List variant actions -->
      <div v-if="variant === 'case-list'" class="app-preview-card__footer">
        <button class="btn btn-sm" @click="$emit('toolbox', application)">
          Toolbox
        </button>
      </div>
    </div>

    <!-- Comment modal (simple inline) -->
    <div v-if="showComments" class="app-preview-card__modal" @click.self="showComments = false">
      <div class="app-preview-card__modal-content">
        <h4>Comment on {{ formatName(applicantName) }}</h4>
        <textarea
          v-model="commentText"
          placeholder="Add a comment..."
          rows="3"
        ></textarea>
        <div class="app-preview-card__modal-actions">
          <button class="btn btn-sm" @click="showComments = false">Cancel</button>
          <button class="btn btn-primary btn-sm" @click="submitComment">Submit</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
/**
 * ApplicationPreviewCard
 *
 * Reusable card showing application summary info.
 * Two variants: 'marketplace' (shows claim action) and 'case-list' (shows open/toolbox).
 *
 * Props:
 *   application   - Object with application data
 *   variant       - 'marketplace' | 'case-list'
 *   claimed       - Boolean, whether this app is already claimed
 *
 * Emits:
 *   claim, open, review, toolbox, comment-submitted
 */
export default {
  name: 'ApplicationPreviewCard',
  props: {
    application: { type: Object, required: true },
    variant: { type: String, default: 'marketplace', validator: function(v) { return ['marketplace', 'case-list'].indexOf(v) !== -1; } },
    claimed: { type: Boolean, default: false }
  },
  data: function() {
    return {
      expanded: false,
      showMore: false,
      showComments: false,
      commentText: ''
    };
  },
  computed: {
    submissionDate: function() {
      return this.application.submissionDate || this.application.created_at || null;
    },
    applicantName: function() {
      return this.application.applicantName || this.application.name || '';
    },
    placecode: function() {
      return this.application.placecode || this.application.place_code || null;
    },
    triageScore: function() {
      return this.application.triageScore != null ? this.application.triageScore : null;
    },
    repairNeeds: function() {
      return this.application.repairNeeds || this.application.repair_needs || [];
    },
    visibleRepairs: function() {
      return this.repairNeeds.slice(0, 4);
    }
  },
  methods: {
    formatDate: function(dateStr) {
      if (!dateStr) return '';
      var d = new Date(dateStr);
      if (isNaN(d.getTime())) return dateStr;
      return d.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
    },
    formatName: function(name) {
      // LAST, F.I. format
      if (!name) return '';
      var parts = name.split(' ');
      if (parts.length === 1) return name.toUpperCase();
      var last = parts[parts.length - 1].toUpperCase();
      var initials = parts.slice(0, -1).map(function(p) { return p.charAt(0).toUpperCase() + '.'; }).join(' ');
      return last + ', ' + initials;
    },
    triageClass: function() {
      return this.getTriageClass(this.triageScore);
    },
    getTriageClass: function(score) {
      if (score == null) return '';
      if (score >= 8) return 'triage--critical';
      if (score >= 5) return 'triage--high';
      if (score >= 3) return 'triage--medium';
      return 'triage--low';
    },
    submitComment: function() {
      if (!this.commentText.trim()) return;
      this.$emit('comment-submitted', {
        application: this.application,
        text: this.commentText.trim()
      });
      this.commentText = '';
      this.showComments = false;
    }
  }
};
</script>

<style scoped>
.app-preview-card {
  background: var(--bg-surface, #fff);
  border: 1px solid var(--color-border, #e5e7eb);
  border-radius: var(--border-radius, 8px);
  padding: 16px;
  margin-bottom: 12px;
  transition: box-shadow 0.2s ease;
}
.app-preview-card:hover {
  box-shadow: var(--shadow, 0 2px 8px rgba(0,0,0,0.08));
}

.app-preview-card__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.app-preview-card__meta {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
  font-size: 0.9rem;
}

.app-preview-card__date {
  color: var(--color-text-muted, #6b7280);
  font-weight: 500;
}

.app-preview-card__name {
  font-weight: 600;
  color: var(--color-text, #333);
}

.app-preview-card__placecode {
  font-family: monospace;
  font-size: 0.8rem;
  background: var(--bg-surface-alt, #f3f4f6);
  padding: 2px 6px;
  border-radius: 4px;
  color: var(--color-text-muted, #6b7280);
}

.app-preview-card__triage {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-weight: 700;
  font-size: 0.85rem;
  padding: 2px 8px;
  border-radius: 12px;
}
.app-preview-card__triage.triage--critical { background: #fee2e2; color: #dc2626; }
.app-preview-card__triage.triage--high { background: #fef3c7; color: #d97706; }
.app-preview-card__triage.triage--medium { background: #dbeafe; color: #2563eb; }
.app-preview-card__triage.triage--low { background: #d1fae5; color: #059669; }

.app-preview-card__actions {
  display: flex;
  gap: 4px;
}

.app-preview-card__body {
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid var(--color-border, #e5e7eb);
}

.app-preview-card__repairs {
  list-style: none;
  padding: 0;
  margin: 0 0 12px;
}

.app-preview-card__repair {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 0;
  border-bottom: 1px solid var(--color-border, #e5e7eb);
  font-size: 0.85rem;
}
.app-preview-card__repair:last-child { border-bottom: 0; }

.app-preview-card__trade {
  font-weight: 600;
  color: var(--color-primary, #2a5c82);
  min-width: 80px;
}

.app-preview-card__desc {
  flex: 1;
  color: var(--color-text, #333);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.app-preview-card__triage-sm {
  font-weight: 700;
  font-size: 0.8rem;
  padding: 2px 6px;
  border-radius: 10px;
}
.app-preview-card__triage-sm.triage--critical { background: #fee2e2; color: #dc2626; }
.app-preview-card__triage-sm.triage--high { background: #fef3c7; color: #d97706; }
.app-preview-card__triage-sm.triage--medium { background: #dbeafe; color: #2563eb; }
.app-preview-card__triage-sm.triage--low { background: #d1fae5; color: #059669; }

.app-preview-card__repair--more {
  color: var(--color-text-muted, #6b7280);
  font-style: italic;
  font-size: 0.85rem;
  padding: 6px 0;
}

.app-preview-card__footer {
  display: flex;
  gap: 8px;
}

.app-preview-card__modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0,0,0,0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.app-preview-card__modal-content {
  background: var(--bg-surface, #fff);
  border-radius: var(--border-radius, 8px);
  padding: 24px;
  width: 90%;
  max-width: 480px;
}
.app-preview-card__modal-content h4 {
  margin: 0 0 12px;
  font-size: 1.1rem;
}
.app-preview-card__modal-content textarea {
  width: 100%;
  border: 1px solid var(--color-border-strong, #d1d5db);
  border-radius: 4px;
  padding: 8px;
  font-family: inherit;
  font-size: 0.9rem;
  resize: vertical;
}
.app-preview-card__modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 12px;
}

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
.btn:disabled { opacity: 0.5; cursor: not-allowed; }
.btn-primary { background: var(--color-primary, #2a5c82); color: #fff; border-color: var(--color-primary, #2a5c82); }
.btn-primary:hover { background: #1e4461; }
.btn-secondary { background: var(--color-secondary, #1d4665); color: #fff; border-color: var(--color-secondary, #1d4665); }
.btn-secondary:hover { background: #153450; }
.btn-sm { padding: 4px 10px; font-size: 0.8rem; }
.btn-icon { padding: 4px 8px; min-width: 32px; justify-content: center; }
</style>
