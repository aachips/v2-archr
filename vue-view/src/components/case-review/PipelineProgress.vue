<!--
  PipelineProgress — the .pipeline-progress section: six-phase tracker plus
  the active phase's next steps. Phase definitions live in
  src/config/casePhases.js (ported from app/lib/case-phases.php).

  Props:
    phaseInfo Object - { number, exit, exitLabel } from casePhases.casePhase()

  BACK-END NEED: phase is derived from case_statuses.status_sequence; the
  exact app/ derivation uses milestone timestamps on cases that the dummy
  base does not import yet. See README.md.
-->
<template>
  <section class="panel" aria-labelledby="phase-tracker-h">
    <h2 id="phase-tracker-h">Pipeline progress</h2>
    <p v-if="phaseInfo.exit" class="phase-exit">
      This case exited the pipeline: <strong>{{ phaseInfo.exitLabel }}</strong>.
      The furthest phase reached is highlighted below.
    </p>
    <ol class="phase-tracker">
      <li
        v-for="(def, i) in phases"
        :key="i"
        :class="['phase', 'phase--' + stateFor(i)]"
        :title="def.description"
      >
        <span class="phase-num">{{ i }}</span>
        <span class="phase-name">{{ def.name }}</span>
      </li>
    </ol>
    <div class="phase-next">
      <h3 v-if="phaseInfo.exit">
        Phase {{ phaseInfo.number }} — {{ activePhase.fullName }} (reached)
      </h3>
      <h3 v-else>Next steps — Phase {{ phaseInfo.number }}: {{ activePhase.fullName }}</h3>
      <p class="muted">{{ activePhase.description }}</p>
      <ul>
        <li v-for="step in activePhase.nextSteps" :key="step">{{ step }}</li>
      </ul>
    </div>
  </section>
</template>

<script>
import { CASE_PHASES } from "../../config/casePhases";

export default {
  name: "PipelineProgress",
  props: {
    phaseInfo: { type: Object, required: true }
  },
  data() {
    return { phases: CASE_PHASES };
  },
  computed: {
    activePhase() {
      return this.phases[this.phaseInfo.number] || this.phases[0];
    }
  },
  methods: {
    stateFor(i) {
      if (i < this.phaseInfo.number) return "done";
      if (i === this.phaseInfo.number) return "active";
      return "todo";
    }
  }
};
</script>