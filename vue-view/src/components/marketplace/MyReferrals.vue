<template>
  <div class="my-referrals">
    <div class="my-referrals__header">
      <h2>My Referrals</h2>
    </div>

    <!-- Tabs -->
    <div class="my-referrals__tabs">
      <button
        :class="['my-referrals__tab', { 'my-referrals__tab--active': activeTab === 'inbox' }]"
        @click="activeTab = 'inbox'"
      >
        Inbox
        <span class="my-referrals__count">{{ filteredInbox.length }}</span>
      </button>
      <button
        :class="['my-referrals__tab', { 'my-referrals__tab--active': activeTab === 'outbox' }]"
        @click="activeTab = 'outbox'"
      >
        Outbox
        <span class="my-referrals__count">{{ filteredOutbox.length }}</span>
      </button>
    </div>

    <!-- Search -->
    <div class="my-referrals__search">
      <input
        v-model="searchQuery"
        type="text"
        class="my-referrals__search-input"
        :placeholder="activeTab === 'inbox' ? 'Search inbox...' : 'Search outbox...'"
      />
    </div>

    <!-- Referral list -->
    <div class="my-referrals__list">
      <div
        v-for="referral in activeReferrals"
        :key="referral.id"
        class="my-referrals__card"
      >
        <div class="my-referrals__card-header">
          <span class="my-referrals__org">
            <template v-if="referral.type === 'inbound'">
              From: {{ referral.fromOrg }}
            </template>
            <template v-else>
              To: {{ referral.toOrg }}
            </template>
          </span>
          <span :class="['my-referrals__badge', 'my-referrals__badge--' + referral.status]">
            {{ referral.status }}
          </span>
        </div>

        <div class="my-referrals__card-body">
          <p class="my-referrals__request">{{ referral.requestText }}</p>
          <p class="my-referrals__scope" v-if="referral.scopeOfWork">
            <strong>Scope:</strong> {{ referral.scopeOfWork }}
          </p>
          <p class="my-referrals__meta">
            {{ referral.applicationName }} &middot; {{ referral.date }}
          </p>
        </div>

        <div class="my-referrals__card-footer">
          <button
            class="btn btn-primary"
            @click="$emit('open-application', referral.applicationId)"
          >
            Open Application
          </button>
        </div>
      </div>

      <!-- Empty state -->
      <div v-if="activeReferrals.length === 0" class="my-referrals__empty">
        <p>No {{ activeTab }} referrals found.</p>
      </div>
    </div>
  </div>
</template>

<script>
/**
 * MyReferrals
 *
 * Shows referral inbox (received) and outbox (sent) with tab switching,
 * search filtering, and status badges.
 *
 * Props:
 *   inbox  — Array of inbound referral objects
 *   outbox — Array of outbound referral objects
 *
 * Referral shape:
 *   { id, type: 'inbound'|'outbound', fromOrg, toOrg, requestText,
 *     scopeOfWork, applicationId, applicationName, date, status }
 *
 * Emits:
 *   open-application(applicationId)
 */
export default {
  name: 'MyReferrals',
  props: {
    inbox: {
      type: Array,
      default: function () { return []; }
    },
    outbox: {
      type: Array,
      default: function () { return []; }
    }
  },
  emits: ['open-application'],
  data: function () {
    return {
      activeTab: 'inbox',
      searchQuery: ''
    };
  },
  computed: {
    filteredInbox: function () {
      return this.filterReferrals(this.inbox);
    },
    filteredOutbox: function () {
      return this.filterReferrals(this.outbox);
    },
    activeReferrals: function () {
      return this.activeTab === 'inbox' ? this.filteredInbox : this.filteredOutbox;
    }
  },
  methods: {
    filterReferrals: function (referrals) {
      var query = this.searchQuery.toLowerCase();
      if (!query) {
        return referrals;
      }
      return referrals.filter(function (ref) {
        var matchesText = ref.requestText && ref.requestText.toLowerCase().indexOf(query) !== -1;
        var matchesFromOrg = ref.fromOrg && ref.fromOrg.toLowerCase().indexOf(query) !== -1;
        var matchesToOrg = ref.toOrg && ref.toOrg.toLowerCase().indexOf(query) !== -1;
        var matchesApp = ref.applicationName && ref.applicationName.toLowerCase().indexOf(query) !== -1;
        return matchesText || matchesFromOrg || matchesToOrg || matchesApp;
      });
    }
  }
};
</script>

<style scoped>
.my-referrals {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
}

.my-referrals__header h2 {
  font-family: var(--font-display, 'Poppins', sans-serif);
  font-size: 1.5rem;
  color: var(--color-primary, #2a5c82);
  margin: 0 0 16px 0;
}

/* Tabs */
.my-referrals__tabs {
  display: flex;
  gap: 4px;
  border-bottom: 2px solid var(--color-border, #e5e7eb);
  margin-bottom: 16px;
}

.my-referrals__tab {
  padding: 10px 20px;
  background: none;
  border: none;
  border-bottom: 2px solid transparent;
  margin-bottom: -2px;
  cursor: pointer;
  font-size: 0.95rem;
  font-weight: 500;
  color: var(--color-text-muted, #6b7280);
  transition: color 0.2s, border-color 0.2s;
  display: flex;
  align-items: center;
  gap: 8px;
}

.my-referrals__tab:hover {
  color: var(--color-text, #333);
}

.my-referrals__tab--active {
  color: var(--color-primary, #2a5c82);
  border-bottom-color: var(--color-primary, #2a5c82);
  font-weight: 600;
}

.my-referrals__count {
  background: var(--bg-surface-alt, #f3f4f6);
  color: var(--color-text-muted, #6b7280);
  font-size: 0.75rem;
  padding: 2px 8px;
  border-radius: 12px;
  font-weight: 600;
}

.my-referrals__tab--active .my-referrals__count {
  background: var(--color-primary, #2a5c82);
  color: #fff;
}

/* Search */
.my-referrals__search {
  margin-bottom: 16px;
}

.my-referrals__search-input {
  width: 100%;
  padding: 10px 14px;
  border: 1px solid var(--color-border-strong, #d1d5db);
  border-radius: var(--border-radius, 8px);
  font-size: 0.9rem;
  color: var(--color-text, #333);
  background: var(--bg-surface, #fff);
  transition: border-color 0.2s;
  box-sizing: border-box;
}

.my-referrals__search-input:focus {
  outline: none;
  border-color: var(--color-primary, #2a5c82);
}

/* Cards */
.my-referrals__list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.my-referrals__card {
  background: var(--bg-surface, #fff);
  border: 1px solid var(--color-border, #e5e7eb);
  border-radius: var(--border-radius, 8px);
  padding: 16px 20px;
  transition: box-shadow 0.2s;
}

.my-referrals__card:hover {
  box-shadow: var(--shadow, 0 2px 8px rgba(0, 0, 0, 0.08));
}

.my-referrals__card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.my-referrals__org {
  font-weight: 600;
  font-size: 0.9rem;
  color: var(--color-text, #333);
}

.my-referrals__badge {
  font-size: 0.75rem;
  font-weight: 600;
  padding: 3px 10px;
  border-radius: 12px;
  text-transform: capitalize;
}

.my-referrals__badge--pending {
  background: #fef3c7;
  color: #92400e;
}

.my-referrals__badge--accepted {
  background: #dcfce7;
  color: #166534;
}

.my-referrals__badge--declined {
  background: #fee2e2;
  color: #991b1b;
}

.my-referrals__card-body {
  margin-bottom: 12px;
}

.my-referrals__request {
  font-size: 0.95rem;
  color: var(--color-text, #333);
  margin: 0 0 6px 0;
  line-height: 1.5;
}

.my-referrals__scope {
  font-size: 0.85rem;
  color: var(--color-text-muted, #6b7280);
  margin: 0 0 6px 0;
  line-height: 1.4;
}

.my-referrals__meta {
  font-size: 0.8rem;
  color: var(--color-text-muted, #6b7280);
  margin: 0;
}

.my-referrals__card-footer {
  display: flex;
  justify-content: flex-end;
}

/* Button */
.btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 8px 20px;
  border: 1px solid var(--color-primary, #2a5c82);
  border-radius: 4px;
  background: var(--color-primary, #2a5c82);
  color: #fff;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s;
}

.btn:hover {
  background: var(--color-secondary, #1d4665);
  border-color: var(--color-secondary, #1d4665);
}

/* Empty state */
.my-referrals__empty {
  text-align: center;
  padding: 40px 20px;
  color: var(--color-text-muted, #6b7280);
  font-size: 0.95rem;
}
</style>
