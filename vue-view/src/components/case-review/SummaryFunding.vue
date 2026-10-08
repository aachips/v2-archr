<!--
  SummaryFunding — the .summary-finding section: Funding & Claims, with the
  budget-used bar. Mirrors .case-funding in app/partials/case-review-body.php.
  Rendered only at org-admin level and up (parent gates it).

  Props:
    caseItem Object - normalized case item

  BACK-END NEED: none of these columns exist in the dummy base yet, so every
  row renders "—". app/ reads from cases: total_budget, total_actual_cost,
  fema_claim_filed, fema_outcome, insurance_claim_filed, insurance_outcome,
  helene_related.
-->
<template>
  <section class="panel summary-section">
    <h2>Funding &amp; Claims</h2>
    <dl class="def-list">
      <dt>Approved budget</dt>
      <dd>{{ formatMoney(caseItem.totalBudget) }}</dd>
      <dt>Spent to date</dt>
      <dd>{{ formatMoney(caseItem.totalActualCost) }}</dd>
      <dt>Remaining</dt>
      <dd>{{ remaining !== null ? formatMoney(remaining) : "—" }}</dd>
      <dt>FEMA claim</dt>
      <dd>{{ claimSummary(caseItem.femaClaimFiled, caseItem.femaOutcome) }}</dd>
      <dt>Insurance claim</dt>
      <dd>{{ claimSummary(caseItem.insuranceClaimFiled, caseItem.insuranceOutcome) }}</dd>
      <dt>Helene-related</dt>
      <dd>{{ caseItem.heleneRelated === undefined ? "—" : (caseItem.heleneRelated ? "Yes" : "No") }}</dd>
    </dl>
    <template v-if="pctUsed !== null">
      <div class="funding-bar" role="img" :aria-label="pctUsed + ' percent of the approved budget spent'">
        <div class="funding-bar__fill" :style="{ width: pctUsed + '%' }"></div>
      </div>
      <p class="funding-bar-label muted">{{ pctUsed }}% of the approved budget spent</p>
    </template>
  </section>
</template>

<script>
import { formatMoney } from "../../services/format";

export default {
  name: "SummaryFunding",
  props: {
    caseItem: { type: Object, required: true }
  },
  computed: {
    budget() {
      return this.caseItem.totalBudget != null ? Number(this.caseItem.totalBudget) : null;
    },
    actual() {
      return this.caseItem.totalActualCost != null ? Number(this.caseItem.totalActualCost) : null;
    },
    remaining() {
      if (this.budget === null && this.actual === null) return null;
      return (this.budget || 0) - (this.actual || 0);
    },
    pctUsed() {
      if (!this.budget || this.actual === null) return null;
      return Math.min(100, Math.round((this.actual / this.budget) * 100));
    }
  },
  methods: {
    formatMoney,
    claimSummary(filed, outcome) {
      if (filed === undefined || filed === null) return "—";
      if (!filed) return "Not filed";
      return "Filed" + (outcome ? " — " + String(outcome).replace(/_/g, " ") : "");
    }
  }
};
</script>