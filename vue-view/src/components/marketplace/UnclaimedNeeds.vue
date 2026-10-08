<template>
  <div class="unclaimed-needs">
    <!-- Search and filters toolbar -->
    <div class="unclaimed-needs__toolbar">
      <div class="unclaimed-needs__search">
        <i class="fas fa-search unclaimed-needs__search-icon"></i>
        <input
          type="text"
          class="unclaimed-needs__input"
          placeholder="Search by trade or description..."
          :value="searchQuery"
          @input="onSearchInput"
        />
      </div>
      <div class="unclaimed-needs__filters">
        <select
          class="unclaimed-needs__select"
          :value="triageFilter"
          @change="onTriageFilterChange"
        >
          <option value="all">All Triage Levels</option>
          <option value="critical">Critical (8-10)</option>
          <option value="high">High (5-7)</option>
          <option value="medium">Medium (3-4)</option>
          <option value="low">Low (1-2)</option>
        </select>
        <select
          class="unclaimed-needs__select"
          :value="sortBy"
          @change="onSortChange"
        >
          <option value="triage-desc">Triage Score (High to Low)</option>
          <option value="date-desc">Date Received (Newest)</option>
          <option value="date-asc">Date Received (Oldest)</option>
        </select>
      </div>
    </div>

    <!-- Table -->
    <div class="unclaimed-needs__table-wrapper">
      <table class="unclaimed-needs__table">
        <thead>
          <tr>
            <th class="unclaimed-needs__th">Repair Need</th>
            <th class="unclaimed-needs__th">Triage Score</th>
            <th class="unclaimed-needs__th">Application</th>
            <th class="unclaimed-needs__th">Date Received</th>
            <th class="unclaimed-needs__th unclaimed-needs__th--actions">Action</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="need in filteredAndSortedNeeds"
            :key="need.id"
            class="unclaimed-needs__row"
          >
            <td class="unclaimed-needs__td">
              <span class="unclaimed-needs__trade">{{ need.trade }}</span>
              <span class="unclaimed-needs__description">{{ need.description }}</span>
            </td>
            <td class="unclaimed-needs__td unclaimed-needs__td--triage">
              <span class="unclaimed-needs__badge" :class="'badge--' + getTriageLevel(need.triageScore)">
                {{ getTriageLabel(need.triageScore) }} ({{ need.triageScore }})
              </span>
            </td>
            <td class="unclaimed-needs__td">
              <a href="#" class="unclaimed-needs__link" @click.prevent="$emit('open-application', need)">
                {{ need.applicationName }}
              </a>
            </td>
            <td class="unclaimed-needs__td unclaimed-needs__td--date">
              {{ formatDate(need.dateReceived) }}
            </td>
            <td class="unclaimed-needs__td unclaimed-needs__td--actions">
              <button
                class="unclaimed-needs__claim-btn"
                @click="$emit('claim-need', need)"
              >
                <i class="fas fa-hand-holding-heart"></i> Claim Need
              </button>
            </td>
          </tr>
        </tbody>
      </table>

      <!-- Empty state -->
      <div v-if="filteredAndSortedNeeds.length === 0" class="unclaimed-needs__empty">
        <i class="fas fa-inbox"></i>
        <p>No repair needs found</p>
        <p v-if="searchQuery || triageFilter !== 'all'" class="unclaimed-needs__empty-hint">
          Try adjusting your search or filters
        </p>
      </div>
    </div>

    <!-- Results count -->
    <div class="unclaimed-needs__footer">
      Showing {{ filteredAndSortedNeeds.length }} of {{ needs.length }} needs
      <span v-if="currentOrg"> for {{ currentOrg }}</span>
    </div>
  </div>
</template>

<script>
/**
 * UnclaimedNeeds
 *
 * Filterable, searchable table of unclaimed repair needs in the marketplace.
 *
 * Props:
 *   needs      - Array of { id, trade, description, triageScore, applicationId, applicationName, dateReceived, placecode }
 *   currentOrg - String organization name for display filtering
 *
 * Emits:
 *   claim-need(need) — user clicked "Claim Need"
 *   open-application(need) — user clicked the application link
 */
export default {
  name: 'UnclaimedNeeds',
  props: {
    needs: {
      type: Array,
      default: function() {
        return [];
      }
    },
    currentOrg: {
      type: String,
      default: ''
    }
  },
  data: function() {
    return {
      searchQuery: '',
      triageFilter: 'all',
      sortBy: 'triage-desc'
    };
  },
  computed: {
    filteredAndSortedNeeds: function() {
      var self = this;
      var results = this.needs;

      // Filter by organization if currentOrg is set
      if (this.currentOrg) {
        results = results.filter(function(need) {
          return need.placecode && need.placecode.toLowerCase() === self.currentOrg.toLowerCase();
        });
      }

      // Search filter
      if (this.searchQuery) {
        var query = this.searchQuery.toLowerCase();
        results = results.filter(function(need) {
          var trade = need.trade || '';
          var description = need.description || '';
          return trade.toLowerCase().indexOf(query) !== -1 || description.toLowerCase().indexOf(query) !== -1;
        });
      }

      // Triage filter
      if (this.triageFilter !== 'all') {
        results = results.filter(function(need) {
          return self.getTriageLevel(need.triageScore) === self.triageFilter;
        });
      }

      // Sort
      if (this.sortBy === 'triage-desc') {
        results = results.slice().sort(function(a, b) {
          return (b.triageScore || 0) - (a.triageScore || 0);
        });
      } else if (this.sortBy === 'date-desc') {
        results = results.slice().sort(function(a, b) {
          return new Date(b.dateReceived).getTime() - new Date(a.dateReceived).getTime();
        });
      } else if (this.sortBy === 'date-asc') {
        results = results.slice().sort(function(a, b) {
          return new Date(a.dateReceived).getTime() - new Date(b.dateReceived).getTime();
        });
      }

      return results;
    }
  },
  methods: {
    onSearchInput: function(event) {
      this.searchQuery = event.target.value;
    },
    onTriageFilterChange: function(event) {
      this.triageFilter = event.target.value;
    },
    onSortChange: function(event) {
      this.sortBy = event.target.value;
    },
    getTriageLevel: function(score) {
      if (score >= 8) return 'critical';
      if (score >= 5) return 'high';
      if (score >= 3) return 'medium';
      return 'low';
    },
    getTriageLabel: function(score) {
      var level = this.getTriageLevel(score);
      var labels = { critical: 'Critical', high: 'High', medium: 'Medium', low: 'Low' };
      return labels[level] || 'Unknown';
    },
    formatDate: function(dateStr) {
      if (!dateStr) return '';
      var d = new Date(dateStr);
      if (isNaN(d.getTime())) return dateStr;
      return d.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
    }
  }
};
</script>

<style scoped>
.unclaimed-needs {
  font-family: var(--font-sans, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif);
}

/* Toolbar */
.unclaimed-needs__toolbar {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 16px;
  align-items: center;
}

.unclaimed-needs__search {
  flex: 1;
  min-width: 220px;
  position: relative;
}

.unclaimed-needs__search-icon {
  position: absolute;
  left: 10px;
  top: 50%;
  transform: translateY(-50%);
  color: var(--color-text-muted, #6b7280);
  font-size: 0.85rem;
}

.unclaimed-needs__input {
  width: 100%;
  padding: 8px 12px 8px 32px;
  border: 1px solid var(--color-border, #e5e7eb);
  border-radius: var(--border-radius, 8px);
  font-size: 0.9rem;
  color: var(--color-text, #333);
  background: var(--bg-surface, #fff);
}
.unclaimed-needs__input:focus {
  outline: none;
  border-color: var(--color-primary, #2a5c82);
  box-shadow: 0 0 0 2px rgba(42, 92, 130, 0.15);
}

.unclaimed-needs__filters {
  display: flex;
  gap: 8px;
}

.unclaimed-needs__select {
  padding: 8px 12px;
  border: 1px solid var(--color-border, #e5e7eb);
  border-radius: var(--border-radius, 8px);
  font-size: 0.85rem;
  color: var(--color-text, #333);
  background: var(--bg-surface, #fff);
  cursor: pointer;
}
.unclaimed-needs__select:focus {
  outline: none;
  border-color: var(--color-primary, #2a5c82);
}

/* Table */
.unclaimed-needs__table-wrapper {
  overflow-x: auto;
  border: 1px solid var(--color-border, #e5e7eb);
  border-radius: var(--border-radius, 8px);
  background: var(--bg-surface, #fff);
}

.unclaimed-needs__table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.9rem;
}

.unclaimed-needs__th {
  text-align: left;
  padding: 12px 16px;
  background: var(--bg-surface-alt, #f3f4f6);
  color: var(--color-text-muted, #6b7280);
  font-weight: 600;
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border-bottom: 1px solid var(--color-border, #e5e7eb);
  white-space: nowrap;
}

.unclaimed-needs__th--actions {
  width: 140px;
}

.unclaimed-needs__row {
  border-bottom: 1px solid var(--color-border, #e5e7eb);
  transition: background-color 0.15s;
}
.unclaimed-needs__row:last-child {
  border-bottom: none;
}
.unclaimed-needs__row:hover {
  background: var(--bg-surface-alt, #f3f4f6);
}

.unclaimed-needs__td {
  padding: 12px 16px;
  vertical-align: middle;
  color: var(--color-text, #333);
}

.unclaimed-needs__trade {
  display: inline-block;
  font-weight: 600;
  color: var(--color-secondary, #1d4665);
  font-size: 0.85rem;
  margin-right: 8px;
  white-space: nowrap;
}

.unclaimed-needs__description {
  display: block;
  font-size: 0.85rem;
  color: var(--color-text-muted, #6b7280);
  margin-top: 2px;
  line-height: 1.4;
}

/* Triage badge */
.unclaimed-needs__td--triage {
  white-space: nowrap;
}

.unclaimed-needs__badge {
  display: inline-block;
  padding: 3px 10px;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 700;
}
.badge--critical {
  background: #fee2e2;
  color: #dc2626;
}
.badge--high {
  background: #fef3c7;
  color: #d97706;
}
.badge--medium {
  background: #dbeafe;
  color: #2563eb;
}
.badge--low {
  background: #d1fae5;
  color: #16a34a;
}

/* Application link */
.unclaimed-needs__link {
  color: var(--color-primary, #2a5c82);
  text-decoration: none;
  font-weight: 500;
}
.unclaimed-needs__link:hover {
  text-decoration: underline;
}

/* Date */
.unclaimed-needs__td--date {
  white-space: nowrap;
  color: var(--color-text-muted, #6b7280);
  font-size: 0.85rem;
}

/* Actions */
.unclaimed-needs__td--actions {
  white-space: nowrap;
}

.unclaimed-needs__claim-btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 14px;
  border: 1px solid var(--color-primary, #2a5c82);
  border-radius: 4px;
  background: var(--color-primary, #2a5c82);
  color: #fff;
  font-size: 0.8rem;
  font-weight: 600;
  cursor: pointer;
  white-space: nowrap;
  transition: background-color 0.15s;
}
.unclaimed-needs__claim-btn:hover {
  background: #1e4461;
}

/* Empty state */
.unclaimed-needs__empty {
  text-align: center;
  padding: 48px 20px;
  color: var(--color-text-muted, #6b7280);
}
.unclaimed-needs__empty i {
  font-size: 2rem;
  margin-bottom: 8px;
  opacity: 0.4;
}
.unclaimed-needs__empty p {
  margin: 0;
  font-size: 0.95rem;
}
.unclaimed-needs__empty-hint {
  font-size: 0.85rem !important;
  margin-top: 4px;
}

/* Footer */
.unclaimed-needs__footer {
  margin-top: 12px;
  font-size: 0.8rem;
  color: var(--color-text-muted, #6b7280);
}
</style>
