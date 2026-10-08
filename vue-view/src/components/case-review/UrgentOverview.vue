<!--
  UrgentOverview — "Urgent action needed" banner. An OVERVIEW: it explains
  the context (what the applicant reported) rather than summarizing data.
  Mirrors .urgent-banner in app/partials/case-review-body.php.

  Props:
    issues Array - urgent_* flag keys (caseItem.urgentIssues from caseService)
-->
<template>
  <div class="alert alert--danger urgent-banner" role="alert">
    <strong>Urgent action needed</strong> — the applicant reported:
    <ul>
      <li v-for="issue in issues" :key="issue">{{ label(issue) }}</li>
    </ul>
  </div>
</template>

<script>
import { URGENT_FLAG_LABELS } from "../../config/caseFields";

export default {
  name: "UrgentOverview",
  props: {
    issues: { type: Array, default: () => [] }
  },
  methods: {
    // Flag keys arrive raw (e.g. "urgent_no_hvac"); render the human label.
    label(flag) {
      return URGENT_FLAG_LABELS[flag] || flag;
    }
  }
};
</script>