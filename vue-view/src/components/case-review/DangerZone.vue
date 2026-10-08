<!--
  DangerZone — the .danger-zone section: withdraw / terminate. Consequential,
  human-decision actions. Mirrors .danger-zone-inline in
  app/partials/case-review-body.php; rendered only at org-admin level and up
  (the parent gates it).

  Emits:
    withdraw / terminate - intent only. The demo has no consequential-action
    endpoint, so the parent shows a "not connected" notice. BACK-END NEED:
    an org-admin API equivalent to app/api/org-admin.php, with the same
    human-confirmation gates (contact method + ack checkbox for withdraw;
    canonical reason checkboxes for terminate).
-->
<template>
  <section class="panel danger-zone">
    <h2>Danger zone</h2>
    <div class="danger-zone__item">
      <p>
        <strong>Withdraw</strong> — the applicant no longer needs assistance.
        Only allowed after you have confirmed directly with the applicant — by
        phone, in person, or in writing. Closes the application and every
        organization's case on it.
      </p>
      <button type="button" class="btn btn--danger btn--sm" @click="$emit('withdraw')">
        Withdraw application
      </button>
    </div>
    <div class="danger-zone__item">
      <p>
        <strong>Terminate</strong> — the applicant is ineligible or failed to
        follow up. A human decision: at least one reason is required, and it
        is recorded on the application permanently.
      </p>
      <button type="button" class="btn btn--danger btn--sm" @click="$emit('terminate')">
        Terminate application
      </button>
    </div>
  </section>
</template>

<script>
export default {
  name: "DangerZone"
};
</script>