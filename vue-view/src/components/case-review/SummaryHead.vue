<!--
  SummaryHead — the .summary-head block: address-first title, homeowner name,
  project code, key facts, and status pills. Mirrors .case-header in
  app/partials/case-review-body.php.

  Props:
    caseItem Object - normalized case item (see caseService.joinCase)

  BACK-END NEED: projectCode is "" in the dummy base (it lives in
  application_anchor, not imported), so the job code renders "—" for now.
-->
<template>
  <header class="panel summary-head">
    <div>
      <h1 class="summary-head__title">{{ titleText }}</h1>
      <p class="summary-head__subtitle">{{ subtitle }}</p>
      <p class="summary-head__keyfacts">
        <span>Applied {{ appliedDate }}</span>
        <span>{{ location }}</span>
        <span>{{ jobCode }}</span>
        <span v-if="caseItem.placecode">{{ caseItem.placecode }}</span>
      </p>
    </div>
    <div class="summary-head__meta">
      <span v-if="caseItem.isUrgent" class="pill pill--red">Urgent</span>
      <span v-if="caseItem.applicationStatus" :class="['pill', appStatusClass]">
        {{ appStatusLabel }}
      </span>
      <span class="pill">{{ caseItem.status || "—" }}</span>
      <span v-if="caseItem.organization" class="org-badge">{{ caseItem.organization }}</span>
      <span v-else class="org-badge org-badge--unclaimed">Unclaimed</span>
    </div>
  </header>
</template>

<script>
import { formatDate } from "../../services/format";

// Application status pill styling, mirroring the lifecycle map in app/.
const APP_STATUS_PILLS = {
  new: ["pill--blue", "New"],
  active: ["pill--green", "Active"],
  concluded: ["pill--green", "Concluded"],
  terminated: ["pill--red", "Terminated"],
  withdrawn: ["pill--amber", "Withdrawn"],
  expired: ["pill--amber", "Expired — claim lapsed"]
};

export default {
  name: "SummaryHead",
  props: {
    caseItem: { type: Object, required: true }
  },
  computed: {
    // Human-first label: the application's address-based display name,
    // falling back to the case number (same order as app/).
    titleText() {
      const c = this.caseItem;
      return (
        c.displayName ||
        [c.address, c.city].filter(Boolean).join(", ") ||
        c.caseNumber ||
        "#" + c.id
      );
    },
    subtitle() {
      return [this.caseItem.applicantName, this.caseItem.projectCode || "—"]
        .filter(Boolean)
        .join(" · ");
    },
    appliedDate() {
      return formatDate(this.caseItem.submittedAt);
    },
    location() {
      return [this.caseItem.city, this.caseItem.zip].filter(Boolean).join(" ") || "—";
    },
    // Mirrors archr_job_code(): [ORG_CODE]-PROJECT_CODE, UNCLAIMED fallback.
    jobCode() {
      const c = this.caseItem;
      if (!c.projectCode) return "—";
      return "[" + (c.organizationCode || "UNCLAIMED") + "]-" + c.projectCode;
    },
    appStatusClass() {
      const entry = APP_STATUS_PILLS[this.caseItem.applicationStatus] || ["", ""];
      return entry[0];
    },
    appStatusLabel() {
      const s = this.caseItem.applicationStatus;
      const entry = APP_STATUS_PILLS[s];
      return entry ? entry[1] : s.charAt(0).toUpperCase() + s.slice(1);
    }
  }
};
</script>