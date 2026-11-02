# Project

## Definition

A Project is a package of RepairTasks within a Case. One Case may contain
several Projects when repair work is split by program, funding source,
organization workflow, schedule, or scope.

A Project is created when claimed RepairNeeds are converted into an actionable
repair package. Project readiness is multidimensional rather than sequential.

## State

```ts
type ProjectState =
  | "draft"
  | "planning"
  | "ready"
  | "active"
  | "paused"
  | "workComplete"
  | "closed"
  | "cancelled";
```

```ts
interface ProjectReadiness {
  scopeReady: boolean;
  budgetReady: boolean;
  laborReady: boolean;
  contractReady: boolean;
  scheduleReady: boolean;
  workComplete: boolean;
  closeoutReady: boolean;
}
```

## Commands

- `createProject`
- `finalizeTaskList`
- `setProjectBudget`
- `setProjectTimeline`
- `createMaterialsList`
- `selectLaborGroup`
- `assignWorkCrew`
- `setVolunteerSlots`
- `assignSubcontractor`
- `generateContract`
- `approveContract`
- `rejectContract`
- `signContract`
- `createChangeOrder`
- `approveChangeOrder`
- `rejectChangeOrder`
- `startProject`
- `pauseProject`
- `resumeProject`
- `createPunchList`
- `completeFinalWalkthrough`
- `submitDrawRequest`
- `completeProject`
- `closeProject`

## Processes

- `createProjectFromRepairNeeds`
- `buildProjectTaskList`
- `calculateProjectBudget`
- `planProjectResources`
- `generateProjectDocuments`
- `manageContractDecision`
- `manageScopeChanges`
- `aggregateRepairTaskProgress`
- `evaluateProjectReadiness`
- `evaluateProjectCompletion`
- `reconcileProjectCosts`

## Events

- `project.created`
- `project.taskListFinalized`
- `project.budgetDetermined`
- `project.timelineDetermined`
- `project.materialsListCreated`
- `project.laborGroupSelected`
- `project.workCrewAssigned`
- `project.volunteerSlotsSet`
- `project.subcontractorAssigned`
- `project.contractGenerated`
- `project.contractApproved`
- `project.contractRejected`
- `project.contractSigned`
- `project.changeOrderCreated`
- `project.changeOrderApproved`
- `project.changeOrderRejected`
- `project.started`
- `project.paused`
- `project.resumed`
- `project.punchListCreated`
- `project.finalWalkthroughCompleted`
- `project.drawRequestSubmitted`
- `project.workCompleted`
- `project.closed`

The Project projection may instead consume canonical supporting-object events
such as `document.signed`, `photo.uploaded`, `estimate.approved`, and
`invoice.approved`. Do not emit a duplicate Project event solely to copy the
same fact unless it represents a separate Project decision.

## Reducer

`projectReducer` maintains:

- Parent Case ID
- Included RepairNeed and RepairTask IDs
- Program and funding configuration
- Scope version
- Budget and actual costs
- Timeline
- Labor, volunteer, and subcontractor assignments
- Materials
- Contract and change-order state
- Task completion summary
- Punch-list and walkthrough state
- Photo and document coverage
- Draw-request state
- Readiness and completion state

Key projected rules:

```ts
const contractReady = contract.status === "signed";

const workComplete =
  requiredRepairTasks.length > 0 &&
  requiredRepairTasks.every(task =>
    task.status === "verified" || task.status === "waived"
  );

const closeoutReady =
  workComplete &&
  completionCertificateSigned &&
  afterPhotosComplete &&
  costsReconciled;
```

## Tasks

Derived from `progress_tasks_simplified.csv`:

- `FINALIZE_TASK_LIST` - Finalize Repair Task List
- `DETERMINE_PROJECT_BUDGET` - Determine Project Budget
- `CREATE_MATERIALS_LIST` - Create Materials List
- `ESTABLISH_LABOR_PLAN` - Establish Labor Plan
- `ASSIGN_WORK_CREW` - Assign Work Crew
- `SET_VOLUNTEER_SLOTS` - Set Volunteer Slots
- `ASSIGN_SUBCONTRACTOR` - Assign Subcontractor
- `GENERATE_CONTRACT` - Generate Contract
- `DECIDE_CONTRACT` - Approve or Reject Contract
- `SIGN_CONTRACT` - Sign Contract
- `UPLOAD_SUBCONTRACTOR_ESTIMATE` - Upload Subcontractor Estimate
- `DECIDE_SUBCONTRACTOR_ESTIMATE` - Approve or Reject Subcontractor Estimate
- `CREATE_SCOPE_CHANGE_ORDER` - Create Scope Change Order
- `SIGN_SCOPE_CHANGE_ORDER` - Sign Scope Change Order
- `CREATE_SUBCONTRACTOR_CHANGE_ORDER` - Create Subcontractor Change Order
- `DECIDE_SUBCONTRACTOR_CHANGE_ORDER` - Approve or Reject Subcontractor Change Order
- `DOCUMENT_PROJECT_PROGRESS` - Upload Progress Photos
- `CREATE_PUNCH_LIST` - Create Punch List
- `COMPLETE_FINAL_WALKTHROUGH` - Complete Final Walkthrough
- `UPLOAD_AFTER_PHOTOS` - Upload After Photos
- `SIGN_COMPLETION_CERTIFICATE` - Sign Certificate of Completion
- `SUBMIT_DRAW_REQUEST` - Submit Draw Request
- `CLOSE_PROJECT` - Close Project

## Completion-rule corrections

- **Task List Created** should complete on `project.taskListFinalized`, not when
  `project.tasks` merely becomes non-empty.
- **Subcontractor Assigned** must test for a subcontractor assignment, not the
  CSV's current `labor.type = "volunteer"` predicate.
- Contract and completion tasks should use active signature/document evidence,
  allowing a rejected, revoked, or superseded document to invalidate the
  completion projection.

