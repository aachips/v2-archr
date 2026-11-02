<!--
  CaseReview (working-components)
  -------------------------------
  Read-only review of a single case's core fields. Companion to
  FilterableCaseList. Data source: Airtable "Anchor.Cases".

  Presentational only: the parent fetches and normalizes the record
  (see vue-view/src/services/caseService.js for the reference normalizer).

  Props:
    caseItem Object - normalized case item:
                      { id, caseNumber, projectCode, placecode, applicantName,
                        email, phone, address, city, state, zip, status,
                        organization, householdSize, annualIncome, homeType,
                        yearBuilt, repairNeeds[], urgentIssues[], isUrgent,
                        submittedAt, additionalDetails }

  Emits:
    back - user clicked "Back to case list".
-->
<template>
  <article v-if="caseItem" class="case-review">
    <button type="button" class="case-review__back" @click="$emit('back')">
      &larr; Back to case list
    </button>

    <header class="case-review__header">
      <h1 class="case-review__title">{{ caseItem.caseNumber }}</h1>
      <span class="case-review__status">{{ caseItem.status || "Unknown" }}</span>
      <span v-if="caseItem.isUrgent" class="case-review__urgent">Urgent</span>
    </header>

    <section class="case-review__section">
      <h2>Applicant</h2>
      <dl>
        <div><dt>Name</dt><dd>{{ caseItem.applicantName || "—" }}</dd></div>
        <div><dt>Email</dt><dd>{{ caseItem.email || "—" }}</dd></div>
        <div><dt>Phone</dt><dd>{{ caseItem.phone || "—" }}</dd></div>
        <div>
          <dt>Address</dt>
          <dd>
            {{ caseItem.address || "—" }}
            <template v-if="caseItem.city">
              <br />{{ caseItem.city }}<template v-if="caseItem.state">, {{ caseItem.state }}</template>
              {{ caseItem.zip }}
            </template>
          </dd>
        </div>
      </dl>
    </section>

    <section class="case-review__section">
      <h2>Household &amp; Property</h2>
      <dl>
        <div><dt>Household size</dt><dd>{{ caseItem.householdSize || "—" }}</dd></div>
        <div><dt>Annual income</dt><dd>{{ formatIncome(caseItem.annualIncome) }}</dd></div>
        <div><dt>Home type</dt><dd>{{ caseItem.homeType || "—" }}</dd></div>
        <div><dt>Year built</dt><dd>{{ caseItem.yearBuilt || "—" }}</dd></div>
      </dl>
    </section>

    <section class="case-review__section">
      <h2>Case Details</h2>
      <dl>
        <div><dt>Organization</dt><dd>{{ caseItem.organization || "Unassigned" }}</dd></div>
        <div><dt>Submitted</dt><dd>{{ formatDate(caseItem.submittedAt) }}</dd></div>
        <div v-if="caseItem.projectCode"><dt>Project code</dt><dd>{{ caseItem.projectCode }}</dd></div>
        <div v-if="caseItem.placecode"><dt>Placecode</dt><dd>{{ caseItem.placecode }}</dd></div>
      </dl>
      <div v-if="caseItem.repairNeeds.length" class="chips">
        <h3>Repair needs</h3>
        <span v-for="need in caseItem.repairNeeds" :key="need" class="chip">{{ need }}</span>
      </div>
      <div v-if="caseItem.urgentIssues.length" class="chips">
        <h3>Urgent issues</h3>
        <span v-for="issue in caseItem.urgentIssues" :key="issue" class="chip chip--urgent">{{ issue }}</span>
      </div>
      <p v-if="caseItem.additionalDetails" class="case-review__notes">
        {{ caseItem.additionalDetails }}
      </p>
    </section>
  </article>
</template>

<script>
export default {
  name: "CaseReview",
  props: {
    caseItem: { type: Object, required: true }
  },
  methods: {
    formatDate(value) {
      if (!value) return "—";
      const date = new Date(value);
      return isNaN(date) ? String(value) : date.toLocaleDateString();
    },
    formatIncome(value) {
      if (value === null || value === undefined || value === "") return "—";
      const num = Number(value);
      return isNaN(num) ? String(value) : "$" + num.toLocaleString();
    }
  }
};
</script>

<style scoped>
.case-review__back {
  margin-bottom: 1rem;
  padding: 0.4rem 0.8rem;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  background: #fff;
  font: inherit;
  cursor: pointer;
}

.case-review__back:hover {
  background: #f9fafb;
}

.case-review__header {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.case-review__title {
  margin: 0;
}

.case-review__status {
  font-style: italic;
  color: #4b5563;
}

.case-review__urgent {
  padding: 0.1rem 0.5rem;
  border-radius: 999px;
  background: #fee2e2;
  color: #b91c1c;
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
}

.case-review__section {
  margin-bottom: 1.5rem;
  padding: 1rem;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
}

.case-review__section h2 {
  margin-top: 0;
  font-size: 1rem;
  text-transform: uppercase;
  color: #6b7280;
}

dl {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(14rem, 1fr));
  gap: 0.75rem;
  margin: 0;
}

dt {
  font-size: 0.8rem;
  font-weight: 600;
  color: #6b7280;
}

dd {
  margin: 0;
}

.chips h3 {
  font-size: 0.85rem;
  margin-bottom: 0.4rem;
}

.chip {
  display: inline-block;
  margin: 0 0.4rem 0.4rem 0;
  padding: 0.15rem 0.6rem;
  border-radius: 999px;
  background: #e5e7eb;
  font-size: 0.85rem;
}

.chip--urgent {
  background: #fee2e2;
  color: #b91c1c;
}

.case-review__notes {
  margin-top: 0.75rem;
  color: #374151;
}
</style>
