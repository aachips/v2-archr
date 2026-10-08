<template>
  <div class="case-list">
    <!-- Filters -->
    <div class="case-list__filters">
      <input type="text" v-model="search" placeholder="Search cases..." class="case-list__search" />
      <select v-model="filterStatus" class="case-list__filter">
        <option value="">All Statuses</option>
        <option value="active">Active</option>
        <option value="completed">Completed</option>
        <option value="on-hold">On Hold</option>
      </select>
      <select v-model="sortBy" class="case-list__filter">
        <option value="newest">Newest First</option>
        <option value="oldest">Oldest First</option>
        <option value="placecode">By Placecode</option>
      </select>
    </div>

    <!-- Case cards -->
    <div v-if="filteredCases.length === 0" class="case-list__empty">
      <i class="fas fa-folder-open"></i>
      <p>No cases found.</p>
    </div>

    <div v-for="caseItem in filteredCases" :key="caseItem.id" class="case-list__card" @click="$emit('open-case', caseItem)">
      <div class="case-list__card-header">
        <span class="case-list__placecode">{{ caseItem.placecode }}</span>
        <span class="case-list__status" :class="'status--' + caseItem.status">{{ caseItem.status }}</span>
      </div>
      <div class="case-list__card-body">
        <div class="case-list__applicant">{{ caseItem.applicantName }}</div>
        <div class="case-list__repair">{{ caseItem.repairType || 'Multiple repair types' }}</div>
        <div class="case-list__meta">
          <span>Created {{ formatDate(caseItem.createdAt) }}</span>
          <span v-if="caseItem.projectCount">({{ caseItem.projectCount }} project{{ caseItem.projectCount !== 1 ? 's' : '' }})</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
/**
 * CaseList
 *
 * Displays cases created from parsed SOW line items.
 * Each case represents a distinct scope of work from an application.
 *
 * Props:
 *   cases - Array of case objects
 *
 * Emits:
 *   open-case(caseItem)
 */
export default {
  name: 'CaseList',
  props: {
    cases: { type: Array, default: function() { return []; } }
  },
  data: function() {
    return {
      search: '',
      filterStatus: '',
      sortBy: 'newest'
    };
  },
  computed: {
    filteredCases: function() {
      var self = this;
      var results = this.cases.filter(function(c) {
        var term = self.search.toLowerCase();
        var termOk = !term ||
          (c.placecode && c.placecode.toLowerCase().indexOf(term) !== -1) ||
          (c.applicantName && c.applicantName.toLowerCase().indexOf(term) !== -1) ||
          (c.repairType && c.repairType.toLowerCase().indexOf(term) !== -1);
        var statusOk = !self.filterStatus || c.status === self.filterStatus;
        return termOk && statusOk;
      });

      if (self.sortBy === 'newest') {
        results.sort(function(a, b) { return new Date(b.createdAt) - new Date(a.createdAt); });
      } else if (self.sortBy === 'oldest') {
        results.sort(function(a, b) { return new Date(a.createdAt) - new Date(b.createdAt); });
      } else if (self.sortBy === 'placecode') {
        results.sort(function(a, b) { return (a.placecode || '').localeCompare(b.placecode || ''); });
      }

      return results;
    }
  },
  methods: {
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
.case-list { padding: 16px 0; }
.case-list__filters { display: flex; gap: 8px; margin-bottom: 16px; flex-wrap: wrap; }
.case-list__search { flex: 1; min-width: 200px; padding: 8px 12px; border: 1px solid var(--color-border-strong, #d1d5db); border-radius: 4px; font-size: 0.9rem; }
.case-list__filter { padding: 8px 12px; border: 1px solid var(--color-border-strong, #d1d5db); border-radius: 4px; font-size: 0.9rem; background: var(--bg-surface, #fff); }

.case-list__card {
  background: var(--bg-surface, #fff);
  border: 1px solid var(--color-border, #e5e7eb);
  border-radius: var(--border-radius, 8px);
  padding: 16px;
  margin-bottom: 12px;
  cursor: pointer;
  transition: box-shadow 0.2s, border-color 0.2s;
}
.case-list__card:hover {
  box-shadow: var(--shadow, 0 2px 8px rgba(0,0,0,0.08));
  border-color: var(--color-primary, #2a5c82);
}

.case-list__card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
.case-list__placecode { font-family: monospace; font-size: 0.85rem; font-weight: 600; color: var(--color-primary, #2a5c82); }
.case-list__status { font-size: 0.75rem; font-weight: 700; padding: 2px 8px; border-radius: 10px; text-transform: uppercase; }
.status--active { background: #d1fae5; color: #059669; }
.status--completed { background: #dbeafe; color: #2563eb; }
.status--on-hold { background: #fef3c7; color: #d97706; }

.case-list__applicant { font-weight: 600; font-size: 1rem; margin-bottom: 4px; }
.case-list__repair { font-size: 0.9rem; color: var(--color-text-muted, #6b7280); margin-bottom: 8px; }
.case-list__meta { font-size: 0.8rem; color: var(--color-text-muted, #6b7280); display: flex; gap: 12px; }

.case-list__empty { text-align: center; padding: 40px 20px; color: var(--color-text-muted, #6b7280); }
.case-list__empty i { font-size: 2rem; opacity: 0.3; display: block; margin-bottom: 12px; }
</style>
