<!--
  CaseReview — page template for the case review page. Composes the section
  components in ./case-review/ (data sources per component:
  ./case-review/README.md). Section order mirrors
  app/partials/case-review-body.php.

  Page-level component, so it may talk to services directly (same precedent
  as QuickTasks): it owns the event log for SummaryTasks.

  Props:
    caseItem Object  - normalized case item (see caseService.joinCase)
    cases    Array   - all case items (ApplicationCaseList sibling lookup)
    role     String  - staff | org-admin | super-admin (permission preview)
    saving   Boolean - parent is writing contact edits to Airtable

  Emits:
    back                  - user clicked "Back to case list"
    save (contact fields) - user confirmed a contact edit
    open-case (caseItem)  - user opened a sibling case
-->
<template>
  <article v-if="caseItem" class="case-review">
    <CaseBreadcrumbs @back="$emit('back')" />

    <p v-if="!canViewFull" class="alert alert--info">
      Limited case view ({{ role }}). Contact details are hidden.
    </p>
    <p v-if="notice" class="alert alert--info">
      {{ notice }}
      <button type="button" class="notice__dismiss" @click="notice = ''">Dismiss</button>
    </p>

    <UrgentOverview v-if="caseItem.urgentIssues.length" :issues="caseItem.urgentIssues" />

    <SummaryHead :case-item="caseItem" />

    <ApplicationCaseList
      :cases="cases"
      :current-case="caseItem"
      @open-case="$emit('open-case', $event)"
    />

    <PipelineProgress :phase-info="phaseInfo" />

    <DocsList
      @upload="demoNotice('Document upload')"
      @download="demoNotice('Document download')"
    />

    <div class="case-grid">
      <SummaryCase :case-item="caseItem" :phase-info="phaseInfo" />
      <SummaryFunding v-if="canViewFull" :case-item="caseItem" />
      <SummaryApplicant
        :case-item="caseItem"
        :saving="saving"
        :full="canViewFull"
        @save="$emit('save', $event)"
      />
      <SummaryEligibility :case-item="caseItem" />
      <SummaryNeeds :case-item="caseItem" />
    </div>

    <SummaryTasks
      :events="events"
      :events-loading="eventsLoading"
      :case-number="caseItem.caseNumber || caseItem.jobcode || caseItem.placecode || caseItem.id || ''"
      :application-data="caseItem.application || caseItem"
      :org-name="caseItem.organization || caseItem.orgName || ''"
      @log-event="onLogEvent"
      @create-sow="onCreateSow"
      @fork-repair-need="onForkRepairNeed"
    />

    <DangerZone
      v-if="canViewFull"
      @withdraw="demoNotice('Withdrawal')"
      @terminate="demoNotice('Termination')"
    />
  </article>
</template>

<script>
import CaseBreadcrumbs from "./case-review/CaseBreadcrumbs.vue";
import UrgentOverview from "./case-review/UrgentOverview.vue";
import SummaryHead from "./case-review/SummaryHead.vue";
import ApplicationCaseList from "./case-review/ApplicationCaseList.vue";
import PipelineProgress from "./case-review/PipelineProgress.vue";
import DocsList from "./case-review/DocsList.vue";
import SummaryCase from "./case-review/SummaryCase.vue";
import SummaryFunding from "./case-review/SummaryFunding.vue";
import SummaryApplicant from "./case-review/SummaryApplicant.vue";
import SummaryEligibility from "./case-review/SummaryEligibility.vue";
import SummaryNeeds from "./case-review/SummaryNeeds.vue";
import SummaryTasks from "./case-review/SummaryTasks.vue";
import DangerZone from "./case-review/DangerZone.vue";
import { casePhase } from "../config/casePhases";
import { fetchCaseEvents, saveCaseEvent } from "../services/caseService";

// Demo permission model: simplified from app/lib/case-access.php.
// staff = 1 (limited), org-admin = 2, super-admin = 3 (both "full").
const ROLE_LEVELS = { staff: 1, "org-admin": 2, "super-admin": 3 };

export default {
  name: "CaseReview",
  components: {
    CaseBreadcrumbs,
    UrgentOverview,
    SummaryHead,
    ApplicationCaseList,
    PipelineProgress,
    DocsList,
    SummaryCase,
    SummaryFunding,
    SummaryApplicant,
    SummaryEligibility,
    SummaryNeeds,
    SummaryTasks,
    DangerZone
  },
  props: {
    caseItem: { type: Object, required: true },
    cases: { type: Array, default: () => [] },
    role: { type: String, default: "super-admin" },
    saving: { type: Boolean, default: false }
  },
  data() {
    return {
      events: [],
      eventsLoading: false,
      notice: ""
    };
  },
  computed: {
    level() {
      return ROLE_LEVELS[this.role] || 3;
    },
    canViewFull() {
      return this.level >= 2;
    },
    phaseInfo() {
      return casePhase(this.caseItem);
    }
  },
  watch: {
    caseItem: {
      immediate: true,
      handler() {
        this.loadEvents();
      }
    }
  },
  methods: {
    loadEvents() {
      this.eventsLoading = true;
      fetchCaseEvents(this.caseItem)
        .then(events => {
          this.events = events;
        })
        .catch(() => {
          this.events = [];
        })
        .then(() => {
          this.eventsLoading = false;
        });
    },
    onLogEvent(payload) {
      saveCaseEvent(this.caseItem, payload)
        .then(event => {
          this.events = [event, ...this.events];
          payload.done(true);
        })
        .catch(err => {
          this.notice =
            "Couldn't save event: " + ((err && err.message) || String(err));
          payload.done(false);
        });
    },
    onCreateSow(sowData) {
      // TODO: Persist SOW data to assessments + scope_of_work_line_items tables
      // For now, log it and create an event
      console.log('SOW created:', sowData);
      saveCaseEvent(this.caseItem, {
        type: 'assessment_sow',
        description: sowData.description,
        sowData: sowData
      }).then(event => {
        this.events = [event, ...this.events];
        sowData.done(true);
      }).catch(err => {
        this.notice = "Couldn't save SOW: " + ((err && err.message) || String(err));
        sowData.done(false);
      });
    },
    onForkRepairNeed(item) {
      // TODO: Create a repair_need record from the SOW line item
      console.log('Fork repair need:', item);
      this.notice = 'Repair need "' + item.taskName + '" queued for creation (fork from SOW).';
    },
    demoNotice(action) {
      this.notice =
        action +
        " isn't connected to the dummy base yet — see " +
        "src/components/case-review/README.md for what the back end needs.";
    }
  }
};
</script>