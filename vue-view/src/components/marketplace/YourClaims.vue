<template>
  <div class="your-claims">
    <!-- Header with search and toggle -->
    <div class="your-claims__header">
      <h2 class="your-claims__title">Your Claims</h2>
      <div class="your-claims__controls">
        <div class="your-claims__search">
          <i class="fas fa-search"></i>
          <input
            type="text"
            class="your-claims__search-input"
            placeholder="Search by name, placecode, or org…"
            :value="searchQuery"
            @input="onSearchInput"
          />
        </div>
        <label class="your-claims__toggle">
          <input
            type="checkbox"
            :checked="showApplications"
            @change="showApplications = $event.target.checked"
          />
          Show applications
        </label>
      </div>
    </div>

    <!-- Claims list -->
    <div class="your-claims__list" v-if="filteredClaims.length > 0">
      <div
        v-for="claim in filteredClaims"
        :key="claim.id"
        class="claim-item"
      >
        <!-- Image placeholder / preview -->
        <div class="claim-item__image">
          <img
            v-if="claim.imageUrl"
            :src="claim.imageUrl"
            :alt="formatApplicantName(claim.applicantName)"
            class="claim-item__img"
            @error="claim.imageUrl = ''"
          />
          <div v-else class="claim-item__img-placeholder">
            <i class="fas fa-user"></i>
          </div>
        </div>

        <!-- Claim info -->
        <div class="claim-item__info">
          <div class="claim-item__meta">
            <span class="claim-item__date">{{ formatDate(claim.submissionDate) }}</span>
            <span class="claim-item__separator">|</span>
            <span class="claim-item__name">{{ formatApplicantName(claim.applicantName) }}</span>
            <span class="claim-item__separator">|</span>
            <span class="claim-item__placecode">{{ claim.placecode || '—' }}</span>
          </div>
          <div class="claim-item__details">
            <span class="claim-item__claim-date">
              <i class="fas fa-calendar-check"></i> Claimed {{ formatDate(claim.claimDate) }}
            </span>
            <ClaimWidget
              :status="getClaimStatus(claim.claimStatus)"
              :claim-date="claim.claimDate"
              :is-current-user-org="true"
              layout="row"
              class="claim-item__status"
            />
            <span class="claim-item__org">{{ claim.claimOrganization || '—' }}</span>
          </div>
        </div>

        <!-- Action buttons -->
        <div class="claim-item__actions">
          <button
            class="btn btn-warning btn-sm"
            @click="openReleaseModal(claim)"
          >
            <i class="fas fa-undo"></i> Release Claim
          </button>
          <button
            class="btn btn-sm"
            @click="$emit('renew-claim', claim)"
          >
            <i class="fas fa-redo"></i> Renew Timer
          </button>
        </div>
      </div>
    </div>

    <!-- Empty state -->
    <div v-else class="your-claims__empty">
      <i class="fas fa-clipboard-list"></i>
      <p>{{ emptyMessage }}</p>
    </div>

    <!-- Release confirmation modal -->
    <div v-if="showReleaseModal" class="claim-modal" @click.self="showReleaseModal = false">
      <div class="claim-modal__content">
        <h4>Release Claim</h4>
        <p>
          Are you sure you want to release your claim to
          <strong>{{ releaseTarget && releaseTarget.applicantName ? formatApplicantName(releaseTarget.applicantName) : 'this record' }}</strong>?
          This application will no longer appear in your [my applicants] list and another
          [organization] will be able to add their [claim] to the project.
        </p>
        <div class="claim-modal__actions">
          <button class="btn btn-sm" @click="showReleaseModal = false">Cancel</button>
          <button class="btn btn-warning btn-sm" @click="confirmRelease">
            <i class="fas fa-undo"></i> Release Claim
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import ClaimWidget from '../shared/ClaimWidget.vue';

/**
 * YourClaims
 *
 * Displays all cases and repair projects the user's organization has claimed.
 * Searchable, filterable list with release and renew actions per row.
 *
 * Props:
 *   claims       - Array of claim objects
 *   currentOrg   - String, the current user's organization name
 *
 * Each claim object shape:
 *   { id, applicationId, applicantName, placecode, submissionDate, claimDate, claimStatus, claimOrganization, imageUrl }
 *
 * Emits:
 *   release-claim(claim) — when release is confirmed
 *   renew-claim(claim)   — when renew timer is clicked
 */
export default {
  name: 'YourClaims',
  components: {
    ClaimWidget: ClaimWidget
  },
  props: {
    claims: {
      type: Array,
      default: function() { return []; }
    },
    currentOrg: {
      type: String,
      default: ''
    }
  },
  data: function() {
    return {
      searchQuery: '',
      showApplications: true,
      showReleaseModal: false,
      releaseTarget: null
    };
  },
  computed: {
    filteredClaims: function() {
      var self = this;
      var query = this.searchQuery.toLowerCase();
      return this.claims.filter(function(claim) {
        var matchesSearch = !query ||
          (claim.applicantName && claim.applicantName.toLowerCase().indexOf(query) !== -1) ||
          (claim.placecode && claim.placecode.toLowerCase().indexOf(query) !== -1) ||
          (claim.claimOrganization && claim.claimOrganization.toLowerCase().indexOf(query) !== -1);
        return matchesSearch;
      });
    },
    emptyMessage: function() {
      if (this.searchQuery) {
        return 'No claims match "' + this.searchQuery + '".';
      }
      return 'No active claims. Claim work from the Marketplace to get started.';
    }
  },
  methods: {
    onSearchInput: function(event) {
      this.searchQuery = event.target.value;
    },
    formatDate: function(dateStr) {
      if (!dateStr) return '—';
      var d = new Date(dateStr);
      if (isNaN(d.getTime())) return dateStr;
      return d.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
    },
    formatApplicantName: function(name) {
      if (!name) return '—';
      // Convert "First Last" → "LAST, F.I."
      var parts = name.trim().split(/\s+/);
      if (parts.length === 0) return '—';
      var last = parts[parts.length - 1].toUpperCase();
      var initials = parts.slice(0, parts.length - 1).map(function(p) {
        return p.charAt(0).toUpperCase() + '.';
      }).join(' ');
      return initials ? last + ', ' + initials : last;
    },
    getClaimStatus: function(status) {
      // Map raw claim status to ClaimWidget status values
      if (!status) return 'unclaimed';
      var s = status.toLowerCase();
      if (s === 'active') return 'active';
      if (s === 'expired') return 'expired';
      if (s === 'released') return 'released';
      return 'unclaimed';
    },
    openReleaseModal: function(claim) {
      this.releaseTarget = claim;
      this.showReleaseModal = true;
    },
    confirmRelease: function() {
      this.showReleaseModal = false;
      if (this.releaseTarget) {
        this.$emit('release-claim', this.releaseTarget);
        this.releaseTarget = null;
      }
    }
  }
};
</script>

<style scoped>
.your-claims {
  padding: 24px 0;
}

/* Header */
.your-claims__header {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 20px;
}

.your-claims__title {
  font-size: 1.4rem;
  color: var(--color-primary, #2a5c82);
  margin: 0;
}

.your-claims__controls {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
}

.your-claims__search {
  position: relative;
  display: flex;
  align-items: center;
}

.your-claims__search i {
  position: absolute;
  left: 10px;
  color: var(--color-text-muted, #6b7280);
  font-size: 0.85rem;
  pointer-events: none;
}

.your-claims__search-input {
  padding: 8px 12px 8px 32px;
  border: 1px solid var(--color-border-strong, #d1d5db);
  border-radius: var(--border-radius, 8px);
  font-size: 0.9rem;
  color: var(--color-text, #333);
  background: var(--bg-surface, #fff);
  width: 260px;
}

.your-claims__search-input:focus {
  outline: none;
  border-color: var(--color-primary, #2a5c82);
  box-shadow: 0 0 0 2px rgba(42, 92, 130, 0.15);
}

.your-claims__toggle {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.85rem;
  color: var(--color-text-muted, #6b7280);
  cursor: pointer;
  user-select: none;
}

.your-claims__toggle input[type="checkbox"] {
  accent-color: var(--color-primary, #2a5c82);
}

/* Claim list */
.your-claims__list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.claim-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  background: var(--bg-surface, #fff);
  border: 1px solid var(--color-border, #e5e7eb);
  border-radius: var(--border-radius, 8px);
  transition: box-shadow 0.15s;
}

.claim-item:hover {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

/* Image */
.claim-item__image {
  flex-shrink: 0;
}

.claim-item__img {
  width: 48px;
  height: 48px;
  border-radius: 6px;
  object-fit: cover;
  border: 1px solid var(--color-border, #e5e7eb);
}

.claim-item__img-placeholder {
  width: 48px;
  height: 48px;
  border-radius: 6px;
  background: var(--bg-surface-alt, #f3f4f6);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--color-text-muted, #6b7280);
  font-size: 1.1rem;
  border: 1px solid var(--color-border, #e5e7eb);
}

/* Info */
.claim-item__info {
  flex: 1;
  min-width: 0;
}

.claim-item__meta {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.85rem;
  flex-wrap: wrap;
  margin-bottom: 4px;
}

.claim-item__date {
  color: var(--color-text-muted, #6b7280);
  font-weight: 500;
}

.claim-item__separator {
  color: var(--color-border-strong, #d1d5db);
}

.claim-item__name {
  font-weight: 700;
  color: var(--color-text, #333);
}

.claim-item__placecode {
  font-weight: 600;
  color: var(--color-secondary, #1d4665);
}

.claim-item__details {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 0.8rem;
  color: var(--color-text-muted, #6b7280);
  flex-wrap: wrap;
}

.claim-item__claim-date {
  display: inline-flex;
  align-items: center;
  gap: 4px;
}

.claim-item__status {
  min-width: 0;
}

.claim-item__org {
  font-weight: 500;
  color: var(--color-text, #333);
}

/* Actions */
.claim-item__actions {
  display: flex;
  gap: 8px;
  flex-shrink: 0;
}

/* Empty state */
.your-claims__empty {
  text-align: center;
  padding: 48px 20px;
  color: var(--color-text-muted, #6b7280);
}

.your-claims__empty i {
  font-size: 2.5rem;
  margin-bottom: 12px;
  opacity: 0.5;
}

.your-claims__empty p {
  font-size: 0.95rem;
  margin: 0;
}

/* Modal */
.claim-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.claim-modal__content {
  background: var(--bg-surface, #fff);
  border-radius: var(--border-radius, 8px);
  padding: 24px;
  width: 90%;
  max-width: 480px;
}

.claim-modal__content h4 {
  margin: 0 0 12px;
  font-size: 1.1rem;
  color: var(--color-text, #333);
}

.claim-modal__content p {
  color: var(--color-text-muted, #6b7280);
  font-size: 0.9rem;
  line-height: 1.5;
  margin-bottom: 16px;
}

.claim-modal__actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}

/* Buttons */
.btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  border: 1px solid var(--color-border-strong, #d1d5db);
  border-radius: 4px;
  background: var(--bg-surface, #fff);
  color: var(--color-text, #333);
  font-size: 0.85rem;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.15s;
}

.btn:hover {
  background: var(--bg-surface-alt, #f3f4f6);
}

.btn-sm {
  padding: 6px 12px;
  font-size: 0.8rem;
}

.btn-warning {
  background: #d97706;
  color: #fff;
  border-color: #d97706;
}

.btn-warning:hover {
  background: #b45309;
}

/* Responsive */
@media (max-width: 768px) {
  .claim-item {
    flex-direction: column;
    align-items: flex-start;
  }

  .claim-item__actions {
    width: 100%;
    justify-content: flex-end;
  }

  .your-claims__header {
    flex-direction: column;
    align-items: flex-start;
  }

  .your-claims__controls {
    width: 100%;
    justify-content: space-between;
  }

  .your-claims__search-input {
    width: 100%;
  }
}
</style>
