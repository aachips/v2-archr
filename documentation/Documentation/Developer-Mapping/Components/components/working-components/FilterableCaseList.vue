<!--
  FilterableCaseList (working-components)
  ---------------------------------------
  Repeatable, filterable case list. Data source: Airtable "Anchor.Cases".

  Presentational only: the parent fetches and normalizes records
  (see vue-view/src/services/caseService.js for the reference normalizer).

  Props:
    cases   Array  - normalized case items:
                     { id, caseNumber, applicantName, city, state, status,
                       organization, submittedAt, isUrgent, ... }
    loading Boolean - show a loading notice instead of the list.

  Emits:
    select (caseItem) - user clicked a case row.
-->
<template>
  <section class="case-list">
    <div class="case-list__filters">
      <label class="filter">
        <span class="filter__label">Organization</span>
        <select v-model="selectedOrg">
          <option value="">All organizations</option>
          <option v-for="org in orgOptions" :key="org" :value="org">{{ org }}</option>
        </select>
      </label>
      <label class="filter">
        <span class="filter__label">Search</span>
        <input
          v-model.trim="search"
          type="text"
          placeholder="Case #, name, or city"
        />
      </label>
      <span class="case-list__count">{{ filteredCases.length }} of {{ cases.length }} cases</span>
    </div>

    <p v-if="loading" class="case-list__notice">Loading cases…</p>
    <p v-else-if="filteredCases.length === 0" class="case-list__notice">
      No cases match these filters.
    </p>

    <ul v-else class="case-list__rows">
      <li v-for="c in filteredCases" :key="c.id">
        <button type="button" class="case-row" @click="$emit('select', c)">
          <span class="case-row__cell case-row__id">{{ c.caseNumber }}</span>
          <span class="case-row__cell case-row__name">{{ c.applicantName }}</span>
          <span class="case-row__cell case-row__city">
            {{ c.city }}<template v-if="c.state">, {{ c.state }}</template>
          </span>
          <span class="case-row__cell case-row__status">{{ c.status || "Unknown" }}</span>
          <span class="case-row__cell case-row__org">{{ c.organization }}</span>
          <span v-if="c.isUrgent" class="case-row__urgent">Urgent</span>
        </button>
      </li>
    </ul>
  </section>
</template>

<script>
export default {
  name: "FilterableCaseList",
  props: {
    cases: { type: Array, default: () => [] },
    loading: { type: Boolean, default: false }
  },
  data() {
    return {
      selectedOrg: "",
      search: ""
    };
  },
  computed: {
    orgOptions() {
      const orgs = this.cases.map(c => c.organization).filter(Boolean);
      return [...new Set(orgs)].sort();
    },
    filteredCases() {
      const term = this.search.toLowerCase();
      return this.cases.filter(c => {
        const orgOk = !this.selectedOrg || c.organization === this.selectedOrg;
        const termOk =
          !term ||
          [c.caseNumber, c.applicantName, c.city]
            .filter(Boolean)
            .some(v => v.toLowerCase().includes(term));
        return orgOk && termOk;
      });
    }
  }
};
</script>

<style scoped>
.case-list__filters {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  align-items: flex-end;
  margin-bottom: 1rem;
}

.filter {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.filter__label {
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: uppercase;
  color: #6b7280;
}

.filter select,
.filter input {
  padding: 0.4rem 0.6rem;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  min-width: 12rem;
}

.case-list__count {
  margin-left: auto;
  font-size: 0.85rem;
  color: #6b7280;
}

.case-list__notice {
  color: #6b7280;
  font-style: italic;
}

.case-list__rows {
  list-style: none;
  margin: 0;
  padding: 0;
}

.case-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  width: 100%;
  padding: 0.6rem 0.8rem;
  margin-bottom: 0.4rem;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  background: #fff;
  font: inherit;
  text-align: left;
  cursor: pointer;
}

.case-row:hover {
  background: #f9fafb;
  border-color: #9ca3af;
}

.case-row__id { flex: 0 0 8rem; font-weight: 600; }
.case-row__name { flex: 1; }
.case-row__city { flex: 0 0 10rem; color: #4b5563; }
.case-row__status { flex: 0 0 8rem; font-style: italic; color: #4b5563; }
.case-row__org { flex: 0 0 8rem; color: #4b5563; }

.case-row__urgent {
  padding: 0.1rem 0.5rem;
  border-radius: 999px;
  background: #fee2e2;
  color: #b91c1c;
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
}
</style>
