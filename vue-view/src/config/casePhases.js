// ---------------------------------------------------------------------------
// Six-phase application-to-completed-project pipeline.
//
// JS port of app/lib/case-phases.php (the PHP app is the source of truth —
// keep the two in sync). Upstream: elemental-integration/task-engine/
//   quick-add-progress-tracker/project-phases/p0..p5
//
//   0 Submission & Pre-Screening   3 Planning
//   1 Intake                       4 Project (Execution)
//   2 Processing                   5 Completion & Report
//
// Possible exits: Paused · Withdrawn · Ineligible
// ---------------------------------------------------------------------------

export const CASE_PHASES = [
  {
    name: "Submission",
    fullName: "Submission & Pre-Screening",
    description:
      "Application received. Verify storm-related damage, geographic and income " +
      "eligibility, and collect homeowner / income documents before formal intake.",
    nextSteps: [
      "Verify the damage is storm (Helene) related",
      "Confirm the property is inside the service area",
      "Confirm income eligibility and household demographics",
      "Collect homeowner and income documents (the applicant can upload these through their dashboard link)",
      "Decision point: advance to Intake, or pause / withdraw / mark ineligible"
    ]
  },
  {
    name: "Intake",
    fullName: "Intake",
    description:
      "Establish the case record and assign initial resources: first applicant " +
      "contact, claim decision, assessor assignment, assessment scheduling.",
    nextSteps: [
      "Make initial contact with the applicant",
      "Claim the case for your organization (Repairs Needed section)",
      "Assign an assessor and schedule the home assessment",
      "Collect any outstanding income / ownership documents"
    ]
  },
  {
    name: "Processing",
    fullName: "Processing",
    description:
      "Verify documentation, perform the home assessment, confirm eligibility, " +
      "and build the repair scope, task list, and budget.",
    nextSteps: [
      "Verify income and ownership documents",
      "Perform the on-site assessment and collect before photos",
      "Confirm final eligibility and create the assessment report",
      "Assign a funding source and create the repair task list",
      "Determine labor pool, subcontractor estimates, scope of work, and budget"
    ]
  },
  {
    name: "Planning",
    fullName: "Planning",
    description:
      "Schedule resources, create and sign the repair contract, and prepare for work to begin.",
    nextSteps: [
      "Determine the project timeline and schedule the start date",
      "Assign subcontractors, work crew, and volunteer groups",
      "Create the contract and arrange signing with the homeowner",
      "Create the initial materials list"
    ]
  },
  {
    name: "Project",
    fullName: "Project Execution",
    description:
      "Perform the repair work: site safety, materials and logistics, repair " +
      "tasks, punch list, final walkthrough, and documentation.",
    nextSteps: [
      "Hold safety talks and plan jobsite logistics",
      "Run materials and track supplies / equipment needs",
      "Complete the repair tasks and punch list",
      "Perform the final walkthrough and record progress notes and photos",
      "Get the homeowner completion sign-off"
    ]
  },
  {
    name: "Completion",
    fullName: "Completion & Report",
    description:
      "Close out the project financially and administratively: actual costs, " +
      "draw request workbook, completion certificate, job closed.",
    nextSteps: [
      "Record actual material, labor, and subcontractor expenses",
      "Complete the draw request workbook",
      "Sign the completion certificate with the homeowner",
      "Mark the job complete"
    ]
  }
];

export const PHASE_EXITS = {
  paused: "Paused",
  withdrawn: "Withdrawn",
  ineligible: "Ineligible / Denied"
};

// Derive a case's pipeline position. Mirrors archr_case_phase(): the PHP
// version prefers milestone timestamps on `cases` (intake_completed_at,
// assessment_scheduled_at, approved_at, work_started_at, work_completed_at).
// The dummy base does NOT import those columns yet, so this demo uses only
// the case_statuses.status_sequence fallback mapping (joined onto each case
// item by caseService). BACK-END NEED: export/import the milestone columns
// to make this exact — see src/components/case-review/README.md.
export function casePhase(caseItem) {
  const status = String(caseItem.status || "").toLowerCase();
  let exit = null;
  if (status === "withdrawn") exit = "withdrawn";
  else if (status === "denied" || status === "ineligible") exit = "ineligible";
  else if (status === "on_hold" || status === "on hold" || status === "paused") {
    exit = "paused";
  }

  let phase = 0;
  if (!exit) {
    const seq = Number(caseItem.statusSequence || 1);
    if (seq >= 10) phase = 5;
    else if (seq >= 6) phase = 4;
    else if (seq >= 5) phase = 3;
    else if (seq >= 3) phase = 2;
    else if (seq >= 2) phase = 1;
  }

  return { number: phase, exit, exitLabel: exit ? PHASE_EXITS[exit] : null };
}