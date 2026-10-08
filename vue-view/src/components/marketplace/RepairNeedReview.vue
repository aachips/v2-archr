<template>
  <div class="repair-need-review">
    <!-- Top section: repair need details -->
    <div class="repair-need-review__header">
      <div class="repair-need-review__info">
        <span class="repair-need-review__trade">{{ need.trade }}</span>
        <span class="repair-need-review__separator">|</span>
        <span class="repair-need-review__description">{{ need.description }}</span>
        <span v-if="need.claimedBy" class="repair-need-review__separator">|</span>
        <span v-if="need.claimedBy" class="repair-need-review__claimed">Claimed by: {{ need.claimedBy }}</span>
      </div>

      <div class="repair-need-review__case">
        Attached to case:
        <router-link v-if="need.caseId" :to="'/case/' + need.caseId" class="repair-need-review__case-link">
          {{ need.caseName || need.caseId }}
        </router-link>
        <span v-else>{{ need.caseName || 'Unknown' }}</span>
      </div>

      <div class="repair-need-review__actions">
        <button class="btn btn-success" @click="$emit('mark-met', need)">
          <i class="fas fa-check-circle"></i> Mark Need Met
        </button>
        <button class="btn btn-primary" @click="$emit('edit-need', need)">
          <i class="fas fa-edit"></i> Edit Repair Need
        </button>
      </div>
    </div>

    <!-- Claims section -->
    <div class="repair-need-review__claims">
      <h3>Claims</h3>

      <div v-if="!claims || claims.length === 0" class="repair-need-review__no-claims">
        No claims have been made on this repair need yet.
      </div>

      <div v-else class="repair-need-review__claims-list">
        <div
          v-for="claim in claims"
          :key="claim.id"
          class="repair-need-review__claim-card"
          :class="{ 'repair-need-review__claim-card--expired': claim.expireDate && new Date(claim.expireDate) < new Date() }"
        >
          <div class="repair-need-review__claim-org">
            {{ claim.organizationName }}
          </div>

          <div class="repair-need-review__claim-details">
            <div class="repair-need-review__claim-row">
              <span class="repair-need-review__claim-label">Claimed by:</span>
              <span class="repair-need-review__claim-value">{{ claim.claimedBy || claim.organizationName }}</span>
            </div>
            <div class="repair-need-review__claim-row">
              <span class="repair-need-review__claim-label">Claim date:</span>
              <span class="repair-need-review__claim-value">{{ claim.claimDate }}</span>
            </div>
            <div class="repair-need-review__claim-row">
              <span class="repair-need-review__claim-label">Expire date:</span>
              <span class="repair-need-review__claim-value">{{ claim.expireDate || 'N/A' }}</span>
            </div>
            <div v-if="claim.releaseDate" class="repair-need-review__claim-row">
              <span class="repair-need-review__claim-label">Release date:</span>
              <span class="repair-need-review__claim-value">{{ claim.releaseDate }}</span>
            </div>
          </div>

          <div class="repair-need-review__claim-actions">
            <button class="btn btn-warning" @click="$emit('renew-claim', claim)">
              <i class="fas fa-redo"></i> Renew
            </button>
            <button class="btn btn-danger" @click="$emit('release-claim', claim)">
              <i class="fas fa-times-circle"></i> Release Claim
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
/**
 * RepairNeedReview
 *
 * Detail page for viewing and managing a specific repair need.
 * Shows trade, description, claim info, attached case, and list of claims.
 *
 * Props:
 *   need (Object, required) — { id, trade, description, triageScore, caseId, caseName, dateReceived, claimedBy }
 *   claims (Array, default: []) — [{ id, organizationName, claimDate, expireDate, releaseDate, claimedBy }]
 *   currentOrg (String, default: '') — current user's organization name
 *
 * Emits:
 *   mark-met(need)
 *   edit-need(need)
 *   renew-claim(claim)
 *   release-claim(claim)
 */
export default {
  name: 'RepairNeedReview',
  props: {
    need: {
      type: Object,
      required: true
    },
    claims: {
      type: Array,
      default: function () {
        return [];
      }
    },
    currentOrg: {
      type: String,
      default: ''
    }
  },
  emits: ['mark-met', 'edit-need', 'renew-claim', 'release-claim']
};
</script>

<style scoped>
.repair-need-review {
  max-width: 800px;
  margin: 0 auto;
  padding: 24px 20px;
}

/* Header section */
.repair-need-review__header {
  background: var(--bg-surface, #fff);
  border: 1px solid var(--color-border, #e5e7eb);
  border-radius: var(--border-radius, 8px);
  padding: 24px;
  margin-bottom: 24px;
}

.repair-need-review__info {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 16px;
}

.repair-need-review__trade {
  font-weight: 700;
  font-size: 1.1rem;
  color: var(--color-primary, #2a5c82);
}

.repair-need-review__separator {
  color: var(--color-border-strong, #d1d5db);
}

.repair-need-review__description {
  font-size: 1rem;
  color: var(--color-text, #333);
}

.repair-need-review__claimed {
  font-size: 0.9rem;
  color: var(--color-text-muted, #6b7280);
  font-style: italic;
}

.repair-need-review__case {
  font-size: 0.9rem;
  color: var(--color-text-muted, #6b7280);
  margin-bottom: 16px;
}

.repair-need-review__case-link {
  color: var(--color-primary, #2a5c82);
  text-decoration: underline;
  font-weight: 600;
}
.repair-need-review__case-link:hover {
  color: var(--color-secondary, #1d4665);
}

.repair-need-review__actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

/* Buttons */
.btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 8px 20px;
  border: none;
  border-radius: 4px;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s;
}

.btn-primary {
  background: var(--color-primary, #2a5c82);
  color: #fff;
}
.btn-primary:hover {
  background: var(--color-secondary, #1d4665);
}

.btn-success {
  background: var(--color-success, #16a34a);
  color: #fff;
}
.btn-success:hover {
  background: #15803d;
}

.btn-warning {
  background: var(--color-warning, #d97706);
  color: #fff;
}
.btn-warning:hover {
  background: #b45309;
}

.btn-danger {
  background: #dc2626;
  color: #fff;
}
.btn-danger:hover {
  background: #b91c1c;
}

/* Claims section */
.repair-need-review__claims {
  background: var(--bg-surface, #fff);
  border: 1px solid var(--color-border, #e5e7eb);
  border-radius: var(--border-radius, 8px);
  padding: 24px;
}

.repair-need-review__claims h3 {
  font-size: 1.2rem;
  color: var(--color-text, #333);
  margin: 0 0 16px;
}

.repair-need-review__no-claims {
  color: var(--color-text-muted, #6b7280);
  font-size: 0.95rem;
  text-align: center;
  padding: 24px 0;
}

.repair-need-review__claims-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.repair-need-review__claim-card {
  border: 1px solid var(--color-border, #e5e7eb);
  border-radius: var(--border-radius, 8px);
  padding: 16px;
  background: var(--bg-surface-alt, #f3f4f6);
}

.repair-need-review__claim-card--expired {
  border-color: var(--color-warning, #d97706);
}

.repair-need-review__claim-org {
  font-size: 1.05rem;
  font-weight: 700;
  color: var(--color-text, #333);
  margin-bottom: 12px;
}

.repair-need-review__claim-details {
  margin-bottom: 12px;
}

.repair-need-review__claim-row {
  display: flex;
  gap: 8px;
  font-size: 0.9rem;
  margin-bottom: 4px;
}

.repair-need-review__claim-label {
  color: var(--color-text-muted, #6b7280);
  min-width: 110px;
}

.repair-need-review__claim-value {
  color: var(--color-text, #333);
}

.repair-need-review__claim-actions {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}
</style>
