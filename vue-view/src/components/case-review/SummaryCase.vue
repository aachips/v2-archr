<!--
  SummaryCase — the .summary-case section: Application & Case identity.
  Mirrors .case-identity in app/partials/case-review-body.php.

  Props:
    caseItem  Object - normalized case item
    phaseInfo Object - { number, exit, exitLabel } from casePhases.casePhase()

  BACK-END NEED: queue status and priority score have no columns in the
  dummy base yet (app/ reads cases.queue_status / cases.priority_score).
-->
<template>
  <section class="panel summary-section">
    <h2>Application &amp; Case</h2>
    <dl class="def-list">
      <dt>Application</dt>
      <dd>{{ caseItem.displayName || "—" }}</dd>
      <dt>Case</dt>
      <dd>{{ caseItem.caseNumber || "#" + caseItem.id }} — {{ caseItem.organization || "Unclaimed" }}</dd>
      <dt>Job code</dt>
      <dd>{{ jobCode }}</dd>
      <dt>Project code</dt>
      <dd>{{ caseItem.projectCode || "—" }}</dd>
      <dt>Placecode</dt>
      <dd>{{ caseItem.placecode || "—" }}</dd>
      <dt>Queue status</dt>
      <dd>{{ caseItem.queueStatus || "—" }}</dd>
      <dt>Priority score</dt>
      <dd>{{ caseItem.priorityScore || "—" }}</dd>
      <dt>Phase</dt>
      <dd>{{ phaseLabel }}</dd>
    </dl>
  </section>
</template>

<script>
import { CASE_PHASES } from "../../config/casePhases";

export default {
  name: "SummaryCase",
  props: {
    caseItem: { type: Object, required: true },
    phaseInfo: { type: Object, required: true }
  },
  computed: {
    // Mirrors archr_job_code(): [ORG_CODE]-PROJECT_CODE, UNCLAIMED fallback.
    jobCode() {
      const c = this.caseItem;
      if (!c.projectCode) return "—";
      return "[" + (c.organizationCode || "UNCLAIMED") + "]-" + c.projectCode;
    },
    phaseLabel() {
      const phase = CASE_PHASES[this.phaseInfo.number] || CASE_PHASES[0];
      let label = "Phase " + this.phaseInfo.number + " — " + phase.fullName;
      if (this.phaseInfo.exitLabel) label += " (" + this.phaseInfo.exitLabel + ")";
      return label;
    }
  }
};
</script>