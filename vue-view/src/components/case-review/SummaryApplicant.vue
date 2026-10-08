<!--
  SummaryApplicant — the .summary-applicant section: applicant + household.
  Mirrors .case-applicant (and the limited .case-applicant-limited) in
  app/partials/case-review-body.php, and keeps the demo's contact-edit flow:
  edits write to the `applications` table, never the raw submission.

  Props:
    caseItem Object  - normalized case item
    saving   Boolean - parent is writing to Airtable; disables the form
    full     Boolean - false renders the limited (staff) view

  Emits:
    save ({firstName, lastName, email, phone}) - user confirmed an edit

  BACK-END NEED: DOB, owns home/lot, primary residence, and household notes
  (veteran, disability, etc.) are not in the dummy base — app/ reads them
  from intake_submissions columns. See README.md.
-->
<template>
  <section class="panel summary-section">
    <div class="section-head">
      <h2>Applicant</h2>
      <button v-if="full && !editing" type="button" class="btn btn--sm" @click="startEdit">
        Edit contact info
      </button>
    </div>

    <form v-if="full && editing" class="edit-form" @submit.prevent="saveEdit">
      <label>
        <span>First name</span>
        <input v-model.trim="form.firstName" type="text" />
      </label>
      <label>
        <span>Last name</span>
        <input v-model.trim="form.lastName" type="text" />
      </label>
      <label>
        <span>Email</span>
        <input v-model.trim="form.email" type="email" />
      </label>
      <label>
        <span>Phone</span>
        <input v-model.trim="form.phone" type="tel" />
      </label>
      <div class="edit-actions">
        <button type="submit" class="btn btn--primary" :disabled="saving">
          {{ saving ? "Saving…" : "Save to Airtable" }}
        </button>
        <button type="button" class="btn" :disabled="saving" @click="editing = false">
          Cancel
        </button>
      </div>
      <p class="edit-note">
        Writes to the <code>applications</code> table (created from the raw
        submission on first edit if missing). The original submission is
        never modified.
      </p>
    </form>

    <dl v-else-if="full" class="def-list">
      <dt>Name</dt>
      <dd>
        {{ caseItem.applicantName || "—" }}
        <span v-if="caseItem.hasApplication" class="edited-flag">edited</span>
      </dd>
      <dt>Email</dt>
      <dd>{{ caseItem.email || "—" }}</dd>
      <dt>Phone</dt>
      <dd>{{ caseItem.phone || caseItem.homePhone || "—" }}</dd>
      <dt>Address</dt>
      <dd>
        {{ caseItem.address || "—" }}
        <template v-if="caseItem.city">
          <br />{{ caseItem.city }}<template v-if="caseItem.state">, {{ caseItem.state }}</template>
          {{ caseItem.zip }}
        </template>
      </dd>
      <dt>Household size</dt>
      <dd>{{ caseItem.householdSize || "—" }}</dd>
      <dt>Annual income</dt>
      <dd>{{ formatMoney(caseItem.annualIncome) }}</dd>
      <dt>Home type</dt>
      <dd>{{ caseItem.homeType || "—" }}</dd>
      <dt>Year built</dt>
      <dd>{{ caseItem.yearBuilt || "—" }}</dd>
    </dl>

    <!-- Limited view (staff / outside-org), mirrors case-applicant-limited -->
    <template v-else>
      <dl class="def-list">
        <dt>Name</dt>
        <dd>{{ caseItem.applicantName || "—" }}</dd>
        <dt>City</dt>
        <dd>{{ caseItem.city || "—" }}</dd>
        <dt>Project type</dt>
        <dd>{{ caseItem.projectCode ? caseItem.projectCode.charAt(0) : "—" }}</dd>
      </dl>
      <p class="muted">Contact details are hidden at your permission level.</p>
    </template>
  </section>
</template>

<script>
import { formatMoney } from "../../services/format";

export default {
  name: "SummaryApplicant",
  props: {
    caseItem: { type: Object, required: true },
    saving: { type: Boolean, default: false },
    full: { type: Boolean, default: true }
  },
  data() {
    return {
      editing: false,
      form: { firstName: "", lastName: "", email: "", phone: "" }
    };
  },
  methods: {
    formatMoney,
    startEdit() {
      this.form = {
        firstName: this.caseItem.firstName || "",
        lastName: this.caseItem.lastName || "",
        email: this.caseItem.email || "",
        phone: this.caseItem.phone || ""
      };
      this.editing = true;
    },
    saveEdit() {
      this.$emit("save", { ...this.form });
      this.editing = false;
    }
  }
};
</script>