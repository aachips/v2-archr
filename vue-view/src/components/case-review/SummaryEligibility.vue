<!--
  SummaryEligibility — the .summary-eligibility section: green/yellow/red
  eligibility flags. "The system flags, humans decide." Mirrors
  .case-eligibility in app/partials/case-review-body.php.

  Props:
    caseItem Object - normalized case item

  BACK-END NEED: flags live on the application as JSON —
  applications.eligibility_flags ({green:[], yellow:[], red:[]}) and
  applications.eligibility_report — neither is in the dummy base yet, so
  this renders the same empty state app/ shows before the check runs.
  app/ also lists per-organization match scores (eligibility table) — not
  ported; add when the table lands.
-->
<template>
  <section class="panel summary-section">
    <h2>Eligibility flags</h2>
    <p class="muted">
      The system flags, humans decide. Applicants are assumed eligible; flags
      below guide a human review — nothing here is an automated denial.
    </p>
    <ul v-if="hasFlags" class="flag-list">
      <li v-for="f in flags.green" :key="'g' + f">
        <span class="pill pill--green">Green</span> {{ fmt(f) }}
      </li>
      <li v-for="f in flags.yellow" :key="'y' + f">
        <span class="pill pill--amber">Yellow</span> {{ fmt(f) }}
      </li>
      <li v-for="f in flags.red" :key="'r' + f">
        <span class="pill pill--red">Red</span> {{ fmt(f) }} — needs human review
      </li>
    </ul>
    <p v-else class="muted">
      No flags recorded yet — the eligibility check runs at submission.
    </p>
    <p v-if="caseItem.eligibilityReport" class="muted">{{ caseItem.eligibilityReport }}</p>
  </section>
</template>

<script>
export default {
  name: "SummaryEligibility",
  props: {
    caseItem: { type: Object, required: true }
  },
  computed: {
    flags() {
      return this.caseItem.eligibilityFlags || { green: [], yellow: [], red: [] };
    },
    hasFlags() {
      const f = this.flags;
      return f.green.length > 0 || f.yellow.length > 0 || f.red.length > 0;
    }
  },
  methods: {
    // snake_case flag -> "Snake Case Flag" (mirrors the PHP ucwords call)
    fmt(flag) {
      return String(flag)
        .replace(/_/g, " ")
        .replace(/\b\w/g, ch => ch.toUpperCase());
    }
  }
};
</script>