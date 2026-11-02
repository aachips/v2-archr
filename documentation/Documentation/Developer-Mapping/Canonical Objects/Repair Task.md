# RepairTask

## Definition

A RepairTask is the smallest executable unit of repair work, such as "Replace
bathroom window." It belongs to a Project and normally addresses one or more
RepairNeeds.

A RepairTask is distinct from a Progress Task. A Progress Task describes
workflow work such as "Finalize Repair Task List"; a RepairTask describes the
actual repair.

## State

```ts
type RepairTaskState =
  | "proposed"
  | "ready"
  | "assigned"
  | "scheduled"
  | "inProgress"
  | "blocked"
  | "completed"
  | "verified"
  | "waived"
  | "cancelled";
```

## Commands

- `createRepairTask`
- `editRepairTask`
- `estimateRepairTask`
- `approveRepairTask`
- `assignRepairTask`
- `scheduleRepairTask`
- `startRepairTask`
- `recordRepairTaskProgress`
- `blockRepairTask`
- `unblockRepairTask`
- `completeRepairTask`
- `verifyRepairTask`
- `reopenRepairTask`
- `waiveRepairTask`
- `cancelRepairTask`

## Processes

- `buildRepairTaskFromNeed`
- `matchRepairTaskToLibrary`
- `validateRepairTaskScope`
- `estimateRepairTaskCostAndDuration`
- `assignRepairTaskResources`
- `scheduleRepairTaskWork`
- `trackRepairTaskProgress`
- `verifyRepairTaskEvidence`
- `updateRepairNeedSatisfaction`
- `updateProjectCompletion`

## Events

- `repairTask.created`
- `repairTask.detailsUpdated`
- `repairTask.estimated`
- `repairTask.approved`
- `repairTask.assigned`
- `repairTask.scheduled`
- `repairTask.started`
- `repairTask.progressRecorded`
- `repairTask.blocked`
- `repairTask.unblocked`
- `repairTask.completed`
- `repairTask.verified`
- `repairTask.reopened`
- `repairTask.waived`
- `repairTask.cancelled`

Related Claim events may set or clear the active Claim for a RepairTask when
task-level claims are supported.

## Reducer

`repairTaskReducer` maintains:

- Parent Project ID
- Addressed RepairNeed IDs
- Scope details
- Task-library, trade, area, item, and interaction classifications
- Estimated and actual labor, materials, duration, and cost
- Crew, person, organization, or subcontractor assignment
- Schedule
- Progress and completion evidence
- Blocking reason
- Current status

| Event | Projected change |
|---|---|
| `repairTask.created` | Set `status = "proposed"` and link Project/RepairNeeds. |
| `repairTask.approved` | Set `status = "ready"`. |
| `repairTask.assigned` | Store assignment and set `status = "assigned"`. |
| `repairTask.scheduled` | Store scheduled dates. |
| `repairTask.started` | Set `status = "inProgress"`. |
| `repairTask.progressRecorded` | Update percent complete, evidence, and latest activity. |
| `repairTask.blocked` | Set `status = "blocked"` and store reason. |
| `repairTask.unblocked` | Restore the prior actionable state. |
| `repairTask.completed` | Set `status = "completed"`; verification may still be required. |
| `repairTask.verified` | Set `status = "verified"`. |
| `repairTask.reopened` | Set `status = "inProgress"`. |
| `repairTask.waived` | Set `status = "waived"`. |
| `repairTask.cancelled` | Set `status = "cancelled"`. |

## Tasks

RepairTask instances are contextual, for example:

- Replace Bathroom Window
- Repair Roof Damage
- Replace Damaged Subfloor
- Install Accessible Ramp
- Repair Electrical Service
- Resolve Punch-List Item
- Verify Completed Repair

The generic workflow mapping is:

```text
Progress Task: Complete Project Repair Tasks
RepairTask instance: Replace bathroom window
Domain event: repairTask.completed
Verification event: repairTask.verified
Project projection: required work complete when all required tasks are
                    verified or waived
```

## Completion rules

- `repairTask.completed` records that the worker reports the work complete.
- `repairTask.verified` records acceptance of the evidence or inspection.
- Projects and RepairNeeds should normally depend on `verified` rather than
  merely `completed` when verification is required.
- `repairTask.reopened` invalidates active completion evidence without deleting
  the historical completion event.

