# Route Map

This route map separates read models from commands. Query routes return current
projected state. Command routes request changes and return accepted events.

## General routes

| Method | Route | Purpose |
|---|---|---|
| `GET` | `/api/read-models/:objectType/:objectId` | Load one canonical object projection. |
| `GET` | `/api/events/:subjectType/:subjectId` | Load a paginated immutable activity timeline. |
| `GET` | `/api/progress-tasks/:scopeType/:scopeId` | Load available, completed, and blocked tasks for a scope. |
| `POST` | `/api/commands/:objectType/:objectId/:command` | Shared allowlisted command entry point. |

The generic command URL is useful while designing the system. Explicit route
files can later wrap the same dispatcher for stronger generated API typing.

## Submission commands

| Method | Route | Command |
|---|---|---|
| `POST` | `/api/submissions` | `receiveSubmission` |
| `POST` | `/api/submissions/:id/retry-processing` | `retrySubmissionProcessing` |
| `POST` | `/api/submissions/:id/confirm-application-match` | `confirmSubmissionMatch` |
| `POST` | `/api/submissions/:id/reject-application-match` | `rejectSubmissionMatch` |
| `POST` | `/api/submissions/:id/withdraw` | `withdrawSubmission` |

## Application commands

| Method | Route | Command |
|---|---|---|
| `POST` | `/api/applications/:id/link-submission` | `linkSubmission` |
| `PATCH` | `/api/applications/:id/details` | `updateApplicationDetails` |
| `POST` | `/api/applications/:id/pause` | `pauseApplication` |
| `POST` | `/api/applications/:id/resume` | `resumeApplication` |
| `POST` | `/api/applications/:id/withdraw` | `withdrawApplication` |
| `POST` | `/api/applications/:id/terminate` | `terminateApplication` |
| `POST` | `/api/applications/:id/conclude` | `concludeApplication` |
| `POST` | `/api/applications/:id/reopen` | `reopenApplication` |

## RepairNeed commands

| Method | Route | Command |
|---|---|---|
| `POST` | `/api/applications/:id/repair-needs` | `recordRepairNeed` |
| `PATCH` | `/api/repair-needs/:id` | `editRepairNeed` |
| `POST` | `/api/repair-needs/:id/merge` | `mergeRepairNeeds` |
| `POST` | `/api/repair-needs/:id/assess` | `assessRepairNeed` |
| `POST` | `/api/repair-needs/:id/classify` | `classifyRepairNeed` |
| `POST` | `/api/repair-needs/:id/prioritize` | `prioritizeRepairNeed` |
| `POST` | `/api/repair-needs/:id/decide` | Approve, defer, decline, or withdraw. |
| `POST` | `/api/repair-needs/:id/convert-to-tasks` | `convertRepairNeedToTasks` |
| `POST` | `/api/repair-needs/:id/satisfy` | `markRepairNeedSatisfied` |
| `POST` | `/api/repair-needs/:id/reopen` | `reopenRepairNeed` |

## Claim commands

| Method | Route | Command |
|---|---|---|
| `POST` | `/api/claims` | `requestClaim` or `activateClaim` |
| `POST` | `/api/claims/:id/repair-needs` | `addRepairNeedToClaim` |
| `DELETE` | `/api/claims/:id/repair-needs/:needId` | `removeRepairNeedFromClaim` |
| `POST` | `/api/claims/:id/renew` | `renewClaim` |
| `POST` | `/api/claims/:id/release` | `releaseClaim` |
| `POST` | `/api/claims/:id/cancel` | `cancelClaim` |

Claim expiration is a system command, not a public user route.

## Case commands

| Method | Route | Command |
|---|---|---|
| `POST` | `/api/cases/:id/contact-attempts` | `recordContactAttempt` |
| `POST` | `/api/cases/:id/successful-contact` | `recordSuccessfulContact` |
| `POST` | `/api/cases/:id/assign-program` | `assignProgram` |
| `POST` | `/api/cases/:id/assign-assessor` | `assignAssessor` |
| `POST` | `/api/cases/:id/schedule-assessment` | `scheduleAssessment` |
| `POST` | `/api/cases/:id/complete-assessment` | `completeAssessment` |
| `POST` | `/api/cases/:id/verify-income` | `verifyIncomeForCase` |
| `POST` | `/api/cases/:id/verify-ownership` | `verifyOwnershipForCase` |
| `POST` | `/api/cases/:id/assign-funding-source` | `assignFundingSource` |
| `POST` | `/api/cases/:id/pause` | `pauseCase` |
| `POST` | `/api/cases/:id/resume` | `resumeCase` |
| `POST` | `/api/cases/:id/complete` | `completeCase` |
| `POST` | `/api/cases/:id/close` | `closeCase` |

## Project commands

| Method | Route | Command |
|---|---|---|
| `POST` | `/api/cases/:id/projects` | `createProject` |
| `POST` | `/api/projects/:id/finalize-task-list` | `finalizeTaskList` |
| `POST` | `/api/projects/:id/budget` | `setProjectBudget` |
| `POST` | `/api/projects/:id/timeline` | `setProjectTimeline` |
| `POST` | `/api/projects/:id/materials-list` | `createMaterialsList` |
| `POST` | `/api/projects/:id/labor-plan` | `selectLaborGroup` |
| `POST` | `/api/projects/:id/work-crew` | `assignWorkCrew` |
| `POST` | `/api/projects/:id/volunteer-slots` | `setVolunteerSlots` |
| `POST` | `/api/projects/:id/subcontractor` | `assignSubcontractor` |
| `POST` | `/api/projects/:id/contracts/generate` | `generateContract` |
| `POST` | `/api/projects/:id/contracts/decision` | Approve or reject Contract. |
| `POST` | `/api/projects/:id/contracts/sign` | `signContract` |
| `POST` | `/api/projects/:id/change-orders` | `createChangeOrder` |
| `POST` | `/api/projects/:id/change-orders/:changeId/decision` | Approve or reject Change Order. |
| `POST` | `/api/projects/:id/start` | `startProject` |
| `POST` | `/api/projects/:id/pause` | `pauseProject` |
| `POST` | `/api/projects/:id/resume` | `resumeProject` |
| `POST` | `/api/projects/:id/punch-list` | `createPunchList` |
| `POST` | `/api/projects/:id/final-walkthrough` | `completeFinalWalkthrough` |
| `POST` | `/api/projects/:id/draw-request` | `submitDrawRequest` |
| `POST` | `/api/projects/:id/complete` | `completeProject` |
| `POST` | `/api/projects/:id/close` | `closeProject` |

## RepairTask commands

| Method | Route | Command |
|---|---|---|
| `POST` | `/api/projects/:id/repair-tasks` | `createRepairTask` |
| `PATCH` | `/api/repair-tasks/:id` | `editRepairTask` |
| `POST` | `/api/repair-tasks/:id/estimate` | `estimateRepairTask` |
| `POST` | `/api/repair-tasks/:id/approve` | `approveRepairTask` |
| `POST` | `/api/repair-tasks/:id/assign` | `assignRepairTask` |
| `POST` | `/api/repair-tasks/:id/schedule` | `scheduleRepairTask` |
| `POST` | `/api/repair-tasks/:id/start` | `startRepairTask` |
| `POST` | `/api/repair-tasks/:id/progress` | `recordRepairTaskProgress` |
| `POST` | `/api/repair-tasks/:id/block` | `blockRepairTask` |
| `POST` | `/api/repair-tasks/:id/unblock` | `unblockRepairTask` |
| `POST` | `/api/repair-tasks/:id/complete` | `completeRepairTask` |
| `POST` | `/api/repair-tasks/:id/verify` | `verifyRepairTask` |
| `POST` | `/api/repair-tasks/:id/reopen` | `reopenRepairTask` |
| `POST` | `/api/repair-tasks/:id/waive` | `waiveRepairTask` |
| `POST` | `/api/repair-tasks/:id/cancel` | `cancelRepairTask` |

## Internal automation routes

These routes require service authentication and are not exposed to ordinary
browser sessions.

| Method | Route | Purpose |
|---|---|---|
| `POST` | `/api/internal/automations/process-outbox` | Process pending event-consumer work. |
| `POST` | `/api/internal/automations/expire-claims` | Find and expire inactive Claims. |
| `POST` | `/api/internal/automations/evaluate-applications` | Re-evaluate conclusion/reopening rules. |
| `POST` | `/api/internal/automations/rebuild-projection` | Replay events into one projection. |
| `POST` | `/api/internal/automations/retry-failures` | Retry recoverable integration failures. |

An external scheduler can call these routes. A Nitro task may wrap the same
services when the selected deployment target supports scheduled tasks.

