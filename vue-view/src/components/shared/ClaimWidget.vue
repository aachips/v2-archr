<template>
  <div class="claim-widget">
    <!-- Compact card view -->
    <div v-if="layout === 'card'" class="claim-card" :class="'claim-card--' + statusClass">
      <div class="claim-card__header">
        <div class="claim-card__org" v-if="orgLogo">
          <img :src="orgLogo" :alt="orgName" class="claim-card__logo" />
        </div>
        <div class="claim-card__status" :class="'status--' + statusClass">
          <i :class="statusIcon"></i> {{ statusLabel }}
        </div>
      </div>

      <div class="claim-card__details">
        <div class="claim-card__row">
          <span class="claim-card__label">Claimed by</span>
          <span class="claim-card__value">{{ claimedBy || '—' }}</span>
        </div>
        <div class="claim-card__row">
          <span class="claim-card__label">Claim date</span>
          <span class="claim-card__value">{{ formatDate(claimDate) }}</span>
        </div>
        <div class="claim-card__row" v-if="expireDate">
          <span class="claim-card__label">Expires</span>
          <span class="claim-card__value" :class="{ 'claim-card__value--urgent': isExpiringSoon }">
            {{ formatDate(expireDate) }}
            <span v-if="daysUntilExpiry != null" class="claim-card__countdown">
              ({{ daysUntilExpiry }} days left)
            </span>
          </span>
        </div>
        <div class="claim-card__row" v-if="releaseDate">
          <span class="claim-card__label">Released</span>
          <span class="claim-card__value">{{ formatDate(releaseDate) }}</span>
        </div>
      </div>

      <div class="claim-card__actions">
        <button
          v-if="status === 'unclaimed'"
          class="btn btn-primary btn-sm"
          @click="$emit('claim')"
        >
          <i class="fas fa-hand-holding-heart"></i> Claim
        </button>
        <button
          v-if="status === 'active' && isCurrentUserOrg"
          class="btn btn-warning btn-sm"
          @click="showReleaseModal = true"
        >
          <i class="fas fa-undo"></i> Release Claim
        </button>
        <button
          v-if="status === 'active' && isCurrentUserOrg"
          class="btn btn-sm"
          @click="$emit('renew')"
        >
          <i class="fas fa-redo"></i> Renew Timer
        </button>
      </div>
    </div>

    <!-- Compact row view -->
    <div v-else class="claim-row">
      <div class="claim-row__status" :class="'status--' + statusClass">
        <i :class="statusIcon"></i>
      </div>
      <div class="claim-row__info">
        <span class="claim-row__org">{{ orgName }}</span>
        <span class="claim-row__date" v-if="claimDate">Claimed {{ formatDate(claimDate) }}</span>
        <span class="claim-row__expires" v-if="expireDate" :class="{ 'claim-row__expires--urgent': isExpiringSoon }">
          Expires {{ formatDate(expireDate) }}
        </span>
      </div>
      <div class="claim-row__actions">
        <button v-if="status === 'unclaimed'" class="btn btn-primary btn-sm" @click="$emit('claim')">
          <i class="fas fa-hand-holding-heart"></i> Claim
        </button>
        <button v-if="status === 'active' && isCurrentUserOrg" class="btn btn-warning btn-sm" @click="showReleaseModal = true">
          Release
        </button>
        <button v-if="status === 'active' && isCurrentUserOrg" class="btn btn-sm" @click="$emit('renew')">
          <i class="fas fa-redo"></i>
        </button>
      </div>
    </div>

    <!-- Release confirmation modal -->
    <div v-if="showReleaseModal" class="claim-modal" @click.self="showReleaseModal = false">
      <div class="claim-modal__content">
        <h4>Release Claim</h4>
        <p>
          Are you sure you want to release {{ claimedBy }}'s claim to
          <strong>{{ recordName }}</strong>? {{ recordName }} will no longer appear in your
          [my applicants] list and another [organization] will be able to add their [claim]
          to the project.
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
/**
 * ClaimWidget
 *
 * Displays claim status with actions (Claim, Release, Renew Timer).
 * Two layouts: 'card' (full detail) and 'row' (compact inline).
 *
 * Claim Status Colors:
 *   Active (green)  — Currently claimed, within 90-day window
 *   Expired (red)   — No activity for 90 days, returned to marketplace
 *   Released (gray) — Voluntarily released by the org
 *   Unclaimed (blue) — Available to claim
 *
 * Props:
 *   status       - 'active' | 'expired' | 'released' | 'unclaimed'
 *   claimedBy    - User/org name who claimed
 *   claimDate    - ISO date string
 *   expireDate   - ISO date string (90 days from last activity)
 *   releaseDate  - ISO date string (if released)
 *   orgLogo      - URL to org logo
 *   orgName      - Organization name
 *   recordName   - Name of the record being claimed (for modal)
 *   isCurrentUserOrg - Boolean, whether current user's org is the claiming org
 *   layout       - 'card' | 'row'
 *
 * Emits:
 *   claim, renew, release-confirmed
 */
export default {
  name: 'ClaimWidget',
  props: {
    status: { type: String, default: 'unclaimed', validator: function(v) { return ['active', 'expired', 'released', 'unclaimed'].indexOf(v) !== -1; } },
    claimedBy: { type: String, default: '' },
    claimDate: { type: String, default: null },
    expireDate: { type: String, default: null },
    releaseDate: { type: String, default: null },
    orgLogo: { type: String, default: '' },
    orgName: { type: String, default: '' },
    recordName: { type: String, default: 'this record' },
    isCurrentUserOrg: { type: Boolean, default: false },
    layout: { type: String, default: 'card', validator: function(v) { return ['card', 'row'].indexOf(v) !== -1; } }
  },
  data: function() {
    return {
      showReleaseModal: false
    };
  },
  computed: {
    statusClass: function() {
      return this.status;
    },
    statusLabel: function() {
      var labels = { active: 'Active', expired: 'Expired', released: 'Released', unclaimed: 'Unclaimed' };
      return labels[this.status] || 'Unknown';
    },
    statusIcon: function() {
      var icons = {
        active: 'fas fa-circle-check',
        expired: 'fas fa-circle-xmark',
        released: 'fas fa-circle-minus',
        unclaimed: 'fas fa-circle-plus'
      };
      return icons[this.status] || 'fas fa-circle';
    },
    daysUntilExpiry: function() {
      if (!this.expireDate) return null;
      var exp = new Date(this.expireDate);
      var now = new Date();
      var diff = Math.ceil((exp - now) / (1000 * 60 * 60 * 24));
      return diff > 0 ? diff : 0;
    },
    isExpiringSoon: function() {
      return this.daysUntilExpiry != null && this.daysUntilExpiry <= 14;
    }
  },
  methods: {
    formatDate: function(dateStr) {
      if (!dateStr) return '';
      var d = new Date(dateStr);
      if (isNaN(d.getTime())) return dateStr;
      return d.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
    },
    confirmRelease: function() {
      this.showReleaseModal = false;
      this.$emit('release-confirmed');
    }
  }
};
</script>

<style scoped>
.claim-card {
  background: var(--bg-surface, #fff);
  border: 1px solid var(--color-border, #e5e7eb);
  border-radius: var(--border-radius, 8px);
  padding: 16px;
  border-top: 3px solid var(--color-text-muted, #6b7280);
}
.claim-card--active { border-top-color: var(--color-success, #16a34a); }
.claim-card--expired { border-top-color: #dc2626; }
.claim-card--released { border-top-color: var(--color-text-muted, #9ca3af); }
.claim-card--unclaimed { border-top-color: var(--color-primary, #2a5c82); }

.claim-card__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}

.claim-card__logo {
  width: 40px;
  height: 40px;
  border-radius: 6px;
  object-fit: contain;
  background: var(--bg-surface-alt, #f3f4f6);
}

.claim-card__status {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 0.8rem;
  font-weight: 700;
  padding: 4px 10px;
  border-radius: 12px;
}
.status--active { background: #d1fae5; color: #059669; }
.status--expired { background: #fee2e2; color: #dc2626; }
.status--released { background: #f3f4f6; color: #6b7280; }
.status--unclaimed { background: #dbeafe; color: #2563eb; }

.claim-card__details {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 12px;
}

.claim-card__row {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  font-size: 0.85rem;
}

.claim-card__label {
  color: var(--color-text-muted, #6b7280);
  font-weight: 500;
}

.claim-card__value {
  font-weight: 600;
  color: var(--color-text, #333);
}
.claim-card__value--urgent { color: #dc2626; }

.claim-card__countdown {
  font-size: 0.75rem;
  color: var(--color-text-muted, #6b7280);
  font-weight: 400;
}

.claim-card__actions {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}

/* Row layout */
.claim-row {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px 0;
}

.claim-row__status {
  font-size: 1rem;
}
.claim-row__status.status--active { color: var(--color-success, #16a34a); }
.claim-row__status.status--expired { color: #dc2626; }
.claim-row__status.status--released { color: var(--color-text-muted, #9ca3af); }
.claim-row__status.status--unclaimed { color: var(--color-primary, #2a5c82); }

.claim-row__info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 2px;
  font-size: 0.8rem;
}
.claim-row__org { font-weight: 600; color: var(--color-text, #333); }
.claim-row__date { color: var(--color-text-muted, #6b7280); }
.claim-row__expires { color: var(--color-text-muted, #6b7280); }
.claim-row__expires--urgent { color: #dc2626; font-weight: 600; }

.claim-row__actions {
  display: flex;
  gap: 4px;
}

/* Modal */
.claim-modal {
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
.btn-warning { background: #d97706; color: #fff; border-color: #d97706; }
.btn-warning:hover { background: #b45309; }
</style>
