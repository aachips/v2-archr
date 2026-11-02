# RepairNeed

## Definition

A RepairNeed is a normalized problem reported for an Application, such as a
leaking roof, missing window, or unsafe electrical panel. It describes the
problem to resolve; it does not describe the work that will resolve it.

A RepairNeed can originate from any Submission, be merged with an existing
need, be claimed by an organization, and produce one or more RepairTasks.

## State

```ts
type RepairNeedState =
  | "reported"
  | "needsReview"
  | "assessed"
  | "approved"
  | "deferred"
  | "declined"
  | "claimed"
  | "inProgress"
  | "satisfied"
  | "withdrawn"
  | "duplicate";

type RepairNeedCoverageState =
  | "notClaimable"
  | "available"
  | "claimed"
  | "partiallyClaimed";
```

## Commands

- `recordRepairNeed`
- `editRepairNeed`
- `mergeRepairNeeds`
- `assessRepairNeed`
- `classifyRepairNeed`
- `prioritizeRepairNeed`
- `approveRepairNeed`
- `deferRepairNeed`
- `declineRepairNeed`
- `withdrawRepairNeed`
- `claimRepairNeed`
- `convertRepairNeedToTasks`
- `markRepairNeedSatisfied`
- `reopenRepairNeed`

`claimRepairNeed` is a convenience command that delegates to the Claim
process. The resulting domain event is `claim.activated`.

## Processes

- `extractRepairNeedFromSubmission`
- `matchRepairNeedToTaskLibrary`
- `detectDuplicateRepairNeed`
- `assessRepairNeedDamage`
- `calculateRepairNeedPriority`
- `evaluateRepairNeedEligibility`
- `evaluateRepairNeedClaimability`
- `buildRepairTasksFromNeed`
- `evaluateRepairNeedSatisfaction`

The intake guide's matching flow belongs here:

```text
Repair Request
  -> normalize and classify
  -> match triage keywords and task-library elements
  -> check for an existing duplicate
  -> create or merge RepairNeed
```

## Events

- `repairNeed.recorded`
- `repairNeed.detailsUpdated`
- `repairNeed.merged`
- `repairNeed.assessed`
- `repairNeed.classified`
- `repairNeed.priorityAssigned`
- `repairNeed.approved`
- `repairNeed.deferred`
- `repairNeed.declined`
- `repairNeed.withdrawn`
- `repairNeed.convertedToTasks`
- `repairNeed.satisfied`
- `repairNeed.reopened`

Related events consumed by the RepairNeed projection:

- `claim.activated`
- `claim.repairNeedAdded`
- `claim.repairNeedRemoved`
- `claim.released`
- `claim.expired`
- `repairTask.created`
- `repairTask.verified`
- `repairTask.waived`
- `repairTask.reopened`

## Reducer

`repairNeedReducer` maintains:

- Parent Application ID
- Source Submission and repair-request IDs
- Original and normalized descriptions
- Assessment result and evidence
- Area, trade, item, system, and interaction classifications
- Priority and urgency
- Eligibility/disposition
- Active Claim ID
- Case IDs
- RepairTask IDs
- Satisfaction status

Key projected rules:

```ts
const canClaim =
  need.status === "approved" &&
  !need.activeClaimId;

const isSatisfied =
  requiredRepairTasks.length > 0 &&
  requiredRepairTasks.every(task =>
    task.status === "verified" || task.status === "waived"
  );
```

## Tasks

- `REVIEW_REPAIR_REQUEST` - Review Repair Request
- `IDENTIFY_DUPLICATE_REPAIR_NEED` - Identify Duplicate Repair Need
- `ASSESS_REPAIR_NEED` - Assess Repair Need
- `CLASSIFY_REPAIR_NEED` - Classify Repair Need
- `PRIORITIZE_REPAIR_NEED` - Prioritize Repair Need
- `DECIDE_REPAIR_NEED` - Approve, Defer, or Decline Repair Need
- `CLAIM_REPAIR_NEED` - Claim Repair Need
- `ADD_REPAIR_NEED_TO_SCOPE` - Add Repair Need to Scope
- `CREATE_REPAIR_TASKS_FOR_NEED` - Create Repair Tasks for Need
- `VERIFY_REPAIR_NEED_SATISFIED` - Verify Repair Need Satisfied

## Completion rules

| Task | Completion evidence |
|---|---|
| Assess Repair Need | `repairNeed.assessed` |
| Classify Repair Need | `repairNeed.classified` with required classifications |
| Decide Repair Need | `repairNeed.approved`, `.deferred`, `.declined`, `.withdrawn`, or `.merged` |
| Claim Repair Need | Active `claim.activated` targeting this RepairNeed |
| Create Repair Tasks for Need | `repairNeed.convertedToTasks` after the task set is finalized |
| Verify Repair Need Satisfied | `repairNeed.satisfied` |

The legacy **Repair Claimed** milestone is RepairNeed-scoped and completes when
that specific need has an active Claim. It must not inspect whether a Case has
any arbitrary Claim.

