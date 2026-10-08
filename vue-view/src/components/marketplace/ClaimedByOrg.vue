<template>
  <div class="claimed-by-org">
    <div class="claimed-by-org__header">
      <h2>Claims by Your Organization</h2>
      <p class="claimed-by-org__subtitle">
        All repair needs claimed by {{ currentOrg || 'your organization' }}
      </p>
    </div>

    <!-- Controls bar -->
    <div class="claimed-by-org__controls">
      <div class="claimed-by-org__search">
        <input
          v-model.trim="searchQuery"
          type="text"
          class="claimed-by-org__search-input"
          placeholder="Search by trade or description..."
        />
      </div>
      <div class="claimed-by-org__filters">
        <select v-model="statusFilter" class="claimed-by-org__select">
          <option value="all">All Statuses</option>
          <option value="active">Active</option>
          <option value="expiring">Expiring Soon</option>
          <option value="expired">Expired</option>
        </select>
        <select v-model="sortBy" class="claimed-by-org__select">
          <option value="dateClaimed-desc">Date Claimed (Newest)</option>
          <option value="dateClaimed-asc">Date Claimed (Oldest)</option>
          <option value="triageScore-desc">Triage Score (Highest)</option>
          <option value="triageScore-asc">Triage Score (Lowest)</option>
        </select>
      </div>
    </div>

    <!-- Summary -->
    <div class="claimed-by-org__summary">
      Showing {{ filteredClaims.length }} of {{ claims.length }} claims
      <span v-if="expiringCount > 0" class="claimed-by-org__expiring-badge">
        {{ expiringCount }} expiring soon
      </span>
    </div>

    <!-- Table -->
    <div class="claimed-by-org__table-wrap">
      <table class="claimed-by-org__table">
        <thead>
          <tr>
            <th>Trade</th>
            <th>Description</th>
            <th>Application</th>
            <th>Date Claimed</th>
            <th>Claim Status</th>
            <th>Renew / Release</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="filteredClaims.length === 0">
            <td colspan="6" class="claimed-by-org__empty">
              No claims match your filters.
            </td>
          </tr>
          <tr
            v-for="claim in filteredClaims"
            :key="claim.id"
            :class="{
              'claimed-by-org__row--expiring': isExpiring(claim),
              'claimed-by-org__row--expired': isExpired(claim)
            }"
          >
            <td>
              <span class="claimed-by-org__trade">{{ claim.trade }}</span>
            </td>
            <td class="claimed-by-org__desc">{{ claim.description }}</td>
            <td>{{ claim.applicationName }}</td>
            <td>{{ formatDate(claim.dateClaimed) }}</td>
            <td>
              <span
                :class="[
                  'claimed-by-org__status',
                  'claimed-by-org__status--' + getStatusClass(claim)
                ]"
              >
                {{ getStatusLabel(claim) }}
              </span>
              <span
                v-if="isExpiring(claim)"
                class="claimed-by-org__expiry-timer"
                :title="getExpiryTooltip(claim)"
              >
                {{ getDaysRemaining(claim) }}d left
              </span>
            </td>
            <td class="claimed-by-org__actions">
              <button
                v-if="!isExpired(claim)"
                class="btn btn-renew"
                @click="$emit('renew-claim', claim)"
                :title="'Renew claim for ' + claim.trade"
              >
                Renew
              </button>
              <button
                class="btn btn-release"
                @click="openReleaseModal(claim)"
                :title="'Release claim for ' + claim.trade"
              >
                Release
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Release confirmation modal -->
    <div
      v-if="showReleaseModal"
      class="claimed-by-org__modal-backdrop"
      @click.self="closeReleaseModal"
    >
      <div class="claimed-by-org__modal">
        <h3>Release Claim</h3>
        <p>
          Are you sure you want to release the claim for
          <strong>{{ pendingRelease && pendingRelease.trade }}</strong>
          <span v-if="pendingRelease && pendingRelease.description">
            — {{ pendingRelease.description }}
          </span>
          ?
        </p>
        <p class="claimed-by-org__modal-warning">
          This action cannot be undone. The repair need will become available
          for other organizations to claim.
        </p>
        <div class="claimed-by-org__modal-actions">
          <button class="btn btn-cancel" @click="closeReleaseModal">
            Cancel
          </button>
          <button class="btn btn-release-confirm" @click="confirmRelease">
            Confirm Release
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
/**
 * ClaimedByOrg
 *
 * Shows all repair needs claimed by the user's organization across all applications.
 * Organized by repair need rather than by application.
 *
 * Props:
 *   claims     — Array of { id, trade, description, applicationId, applicationName, dateClaimed, claimStatus, triageScore, daysUntilExpiry }
 *   currentOrg — String organization name/identifier
 *
 * Emits:
 *   renew-claim(claim)
 *   release-claim(claim)
 */
export default {
  name: 'ClaimedByOrg',

  props: {
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

  emits: ['renew-claim', 'release-claim'],

  data: function () {
    return {
      searchQuery: '',
      statusFilter: 'all',
      sortBy: 'dateClaimed-desc',
      showReleaseModal: false,
      pendingRelease: null
    };
  },

  computed: {
    filteredClaims: function () {
      var self = this;
      var items = this.claims.slice();

      // Search filter
      if (this.searchQuery) {
        var q = this.searchQuery.toLowerCase();
        items = items.filter(function (c) {
          var trade = c.trade && c.trade.toLowerCase ? c.trade.toLowerCase() : '';
          var desc = c.description && c.description.toLowerCase ? c.description.toLowerCase() : '';
          return trade.indexOf(q) !== -1 || desc.indexOf(q) !== -1;
        });
      }

      // Status filter
      if (this.statusFilter !== 'all') {
        items = items.filter(function (c) {
          if (self.statusFilter === 'active') {
            return !self.isExpired(c) && !self.isExpiring(c);
          }
          if (self.statusFilter === 'expiring') {
            return self.isExpiring(c);
          }
          if (self.statusFilter === 'expired') {
            return self.isExpired(c);
          }
          return true;
        });
      }

      // Sort
      var parts = this.sortBy.split('-');
      var field = parts[0];
      var dir = parts[1] === 'asc' ? 1 : -1;

      items.sort(function (a, b) {
        if (field === 'dateClaimed') {
          var da = a.dateClaimed ? new Date(a.dateClaimed).getTime() : 0;
          var db = b.dateClaimed ? new Date(b.dateClaimed).getTime() : 0;
          return (da - db) * dir;
        }
        if (field === 'triageScore') {
          var sa = typeof a.triageScore === 'number' ? a.triageScore : 0;
          var sb = typeof b.triageScore === 'number' ? b.triageScore : 0;
          return (sa - sb) * dir;
        }
        return 0;
      });

      return items;
    },

    expiringCount: function () {
      var self = this;
      return this.claims.filter(function (c) {
        return self.isExpiring(c);
      }).length;
    }
  },

  methods: {
    isExpiring: function (claim) {
      return (
        typeof claim.daysUntilExpiry === 'number' &&
        claim.daysUntilExpiry >= 0 &&
        claim.daysUntilExpiry < 14
      );
    },

    isExpired: function (claim) {
      return (
        typeof claim.daysUntilExpiry === 'number' &&
        claim.daysUntilExpiry < 0
      );
    },

    getStatusClass: function (claim) {
      if (this.isExpired(claim)) return 'expired';
      if (this.isExpiring(claim)) return 'expiring';
      return 'active';
    },

    getStatusLabel: function (claim) {
      if (this.isExpired(claim)) return 'Expired';
      if (this.isExpiring(claim)) return 'Expiring Soon';
      return 'Active';
    },

    getDaysRemaining: function (claim) {
      return typeof claim.daysUntilExpiry === 'number'
        ? Math.max(0, claim.daysUntilExpiry)
        : 0;
    },

    getExpiryTooltip: function (claim) {
      return (
        'Expires in ' + this.getDaysRemaining(claim) + ' days'
      );
    },

    formatDate: function (dateStr) {
      if (!dateStr) return '';
      try {
        var d = new Date(dateStr);
        if (isNaN(d.getTime())) return dateStr;
        var month = ('0' + (d.getMonth() + 1)).slice(-2);
        var day = ('0' + d.getDate()).slice(-2);
        var year = d.getFullYear();
        return month + '/' + day + '/' + year;
      } catch (e) {
        return dateStr;
      }
    },

    openReleaseModal: function (claim) {
      this.pendingRelease = claim;
      this.showReleaseModal = true;
    },

    closeReleaseModal: function () {
      this.pendingRelease = null;
      this.showReleaseModal = false;
    },

    confirmRelease: function () {
      if (this.pendingRelease) {
        this.$emit('release-claim', this.pendingRelease);
      }
      this.closeReleaseModal();
    }
  }
};
</script>

<style scoped>
.claimed-by-org {
  max-width: 1100px;
  margin: 0 auto;
  padding: 24px 20px;
}

.claimed-by-org__header {
  margin-bottom: 24px;
}

.claimed-by-org__header h2 {
  font-size: 1.5rem;
  color: var(--color-primary, #2a5c82);
  margin: 0 0 4px;
}

.claimed-by-org__subtitle {
  margin: 0;
  font-size: 0.95rem;
  color: var(--color-text-muted, #6b7280);
}

/* Controls bar */
.claimed-by-org__controls {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  align-items: center;
  margin-bottom: 16px;
}

.claimed-by-org__search {
  flex: 1 1 280px;
}

.claimed-by-org__search-input {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid var(--color-border-strong, #d1d5db);
  border-radius: var(--border-radius, 8px);
  font-size: 0.9rem;
  color: var(--color-text, #333);
  background: var(--bg-surface, #fff);
  box-sizing: border-box;
}

.claimed-by-org__search-input:focus {
  outline: none;
  border-color: var(--color-primary, #2a5c82);
  box-shadow: 0 0 0 2px rgba(42, 92, 130, 0.15);
}

.claimed-by-org__filters {
  display: flex;
  gap: 8px;
}

.claimed-by-org__select {
  padding: 8px 12px;
  border: 1px solid var(--color-border-strong, #d1d5db);
  border-radius: var(--border-radius, 8px);
  font-size: 0.9rem;
  color: var(--color-text, #333);
  background: var(--bg-surface, #fff);
  cursor: pointer;
}

.claimed-by-org__select:focus {
  outline: none;
  border-color: var(--color-primary, #2a5c82);
}

/* Summary */
.claimed-by-org__summary {
  font-size: 0.85rem;
  color: var(--color-text-muted, #6b7280);
  margin-bottom: 12px;
  display: flex;
  align-items: center;
  gap: 12px;
}

.claimed-by-org__expiring-badge {
  background: var(--color-warning, #d97706);
  color: #fff;
  padding: 2px 8px;
  border-radius: 4px;
  font-weight: 600;
  font-size: 0.8rem;
}

/* Table */
.claimed-by-org__table-wrap {
  overflow-x: auto;
  border: 1px solid var(--color-border, #e5e7eb);
  border-radius: var(--border-radius, 8px);
  background: var(--bg-surface, #fff);
}

.claimed-by-org__table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.9rem;
}

.claimed-by-org__table th {
  text-align: left;
  padding: 12px 16px;
  background: var(--bg-surface-alt, #f3f4f6);
  color: var(--color-text, #333);
  font-weight: 600;
  border-bottom: 2px solid var(--color-border-strong, #d1d5db);
  white-space: nowrap;
}

.claimed-by-org__table td {
  padding: 10px 16px;
  border-bottom: 1px solid var(--color-border, #e5e7eb);
  vertical-align: middle;
}

.claimed-by-org__table tbody tr:last-child td {
  border-bottom: none;
}

.claimed-by-org__trade {
  font-weight: 600;
  color: var(--color-secondary, #1d4665);
}

.claimed-by-org__desc {
  max-width: 260px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* Status badges */
.claimed-by-org__status {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 600;
  margin-right: 6px;
}

.claimed-by-org__status--active {
  background: var(--color-success, #16a34a);
  color: #fff;
}

.claimed-by-org__status--expiring {
  background: var(--color-warning, #d97706);
  color: #fff;
}

.claimed-by-org__status--expired {
  background: #991b1b;
  color: #fff;
}

.claimed-by-org__expiry-timer {
  font-size: 0.78rem;
  color: var(--color-warning, #d97706);
  font-weight: 500;
}

/* Row highlights */
.claimed-by-org__row--expiring {
  background: rgba(217, 119, 6, 0.04);
}

.claimed-by-org__row--expired {
  background: rgba(153, 27, 27, 0.04);
}

/* Actions */
.claimed-by-org__actions {
  white-space: nowrap;
}

.claimed-by-org__actions .btn {
  padding: 5px 12px;
  font-size: 0.8rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 600;
  margin-right: 4px;
}

.btn-renew {
  background: var(--color-primary, #2a5c82);
  color: #fff;
}

.btn-renew:hover {
  background: var(--color-secondary, #1d4665);
}

.btn-release {
  background: transparent;
  color: #991b1b;
  border: 1px solid #991b1b !important;
}

.btn-release:hover {
  background: #991b1b;
  color: #fff;
}

/* Empty state */
.claimed-by-org__empty {
  text-align: center;
  padding: 32px 16px !important;
  color: var(--color-text-muted, #6b7280);
}

/* Modal */
.claimed-by-org__modal-backdrop {
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

.claimed-by-org__modal {
  background: var(--bg-surface, #fff);
  border-radius: var(--border-radius, 8px);
  padding: 24px 28px;
  max-width: 460px;
  width: 90%;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
}

.claimed-by-org__modal h3 {
  margin: 0 0 12px;
  font-size: 1.2rem;
  color: var(--color-text, #333);
}

.claimed-by-org__modal p {
  margin: 0 0 8px;
  font-size: 0.9rem;
  color: var(--color-text, #333);
  line-height: 1.5;
}

.claimed-by-org__modal-warning {
  color: var(--color-warning, #d97706) !important;
  font-weight: 500;
}

.claimed-by-org__modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 20px;
}

.claimed-by-org__modal-actions .btn {
  padding: 8px 18px;
  border: none;
  border-radius: 4px;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
}

.btn-cancel {
  background: var(--bg-surface-alt, #f3f4f6);
  color: var(--color-text, #333);
  border: 1px solid var(--color-border-strong, #d1d5db) !important;
}

.btn-cancel:hover {
  background: var(--color-border, #e5e7eb);
}

.btn-release-confirm {
  background: #991b1b;
  color: #fff;
}

.btn-release-confirm:hover {
  background: #7f1d1d;
}
</style>
