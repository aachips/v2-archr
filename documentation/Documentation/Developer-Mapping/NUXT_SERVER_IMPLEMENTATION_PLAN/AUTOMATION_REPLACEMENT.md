# Airtable Automation Replacement Map

The replacement unit is an idempotent command handler or event consumer, not a
field-change trigger.

## Automation map

| Existing workflow responsibility | Nuxt/Nitro replacement | Trigger | Primary output |
|---|---|---|---|
| Receive intake form | `ingestSubmission` | Webhook or `POST /api/submissions` | `submission.received` |
| Normalize form fields | `normalizeSubmissionData` | `submission.received` consumer | `submission.normalized` |
| Resolve PlaceCode/address | `resolvePlaceCode` | Normalized Submission | `submission.placeCodeResolved` |
| Detect duplicate/repeat | `checkForDuplicateApplication` | PlaceCode resolved | Match/no-match event |
| Create/link Application | `attachSubmissionToApplication` | Confirmed match decision | `application.created` and/or `submission.linkedToApplication` |
| Extract repair requests | `extractRepairRequests` | Submission normalized | `submission.repairRequestsExtracted` |
| AI/keyword need matching | `matchRepairRequestsToExistingNeeds` | Requests extracted | RepairNeed create/merge suggestion |
| Create RepairNeed | `extractRepairNeedFromSubmission` | Approved request result | `repairNeed.recorded` |
| Eligibility calculations | `evaluateApplicationStatus` and Case eligibility processes | Data/evidence change | Eligibility flags or verification events |
| Claim button workflow | `validateClaimEligibility` plus `activateRepairNeedCoverage` | Claim command | `claim.activated` and `case.opened` |
| Create/reuse org Case | `createOrReuseOrganizationCase` | Claim activation transaction | Case ID linked to Claim |
| Reset 90-day timer | `resetClaimProgressDeadline` | Qualifying progress event | `claim.renewed` or deadline projection update |
| Expire stale claims | `expireInactiveClaims` | Scheduled internal command | `claim.expired` |
| Assessment completion | `performAssessment` | Case command | Assessment/Case events and assessed needs |
| Generate task list | `buildRepairTasksFromNeed` and `createProjectFromRepairNeeds` | Approved conversion command | Project and RepairTask events |
| Complete Progress Task | Progress-task event consumer | Any qualifying evidence event | Deterministic task completion record |
| Revoke completion | Progress-task event consumer | Reopen/revoke/supersede event | Revoked/superseded completion record |
| Aggregate Project progress | `aggregateRepairTaskProgress` | RepairTask event | Updated Project projection |
| Mark need satisfied | `evaluateRepairNeedSatisfaction` | RepairTask verified/waived | `repairNeed.satisfied` |
| Complete Case | `evaluateCaseCompletion` | Need/Project/Claim event | `case.completed` when rule passes |
| Conclude Application | `evaluateApplicationConclusion` | Need/Case event | `application.concluded` when rule passes |
| Reopen Application | `evaluateApplicationConclusion` | New unresolved RepairNeed | `application.reopened` |
| Notifications | Notification consumer | Selected domain events | Durable notification/outbound message |
| Sync external Airtable data | Integration outbox consumer | Selected domain events | Idempotent Airtable upsert |

## Consumer groups

### Projection consumers

- Update normalized current-state tables used by query routes.
- Apply events in subject-version order.
- Reject gaps and request a replay rather than guessing state.

### Progress-task consumers

- Match event type and evidence predicates against task definitions.
- Write deterministic completion keys.
- Mark prior completion evidence revoked or superseded when required.
- Never mutate or delete the event that originally supplied evidence.

### Lifecycle consumers

- Evaluate RepairNeed satisfaction after task changes.
- Evaluate Project readiness and completion after scope/task/document changes.
- Evaluate Case completion after Project or Claim changes.
- Evaluate Application conclusion after RepairNeed or Case changes.
- Emit follow-on commands through the outbox rather than recursively calling
  route handlers.

### Integration consumers

- Upsert mapped records to Airtable while Airtable remains in use.
- Store external record IDs and synchronization checkpoints.
- Record retryable failures without changing the accepted domain event.

### Notification consumers

- Notify actors of assignments, Claim expiration, blocked work, and required
  review.
- Use a notification idempotency key so event retries do not send duplicates.

## Transaction requirements

The following must be atomic:

- Claim creation, target locking, and Case creation/reuse.
- Project creation and initial RepairTask creation.
- RepairTask completion and evidence attachment.
- Canonical record update, immutable event append, and outbox insertion.

If any part fails, none of those writes should commit.

## Failure behavior

- Validation failure: reject command; append no success domain event.
- Authorization failure: return forbidden; append no domain event.
- Expected-version mismatch: return conflict and current version/snapshot.
- Post-commit consumer failure: retain outbox item for retry.
- Permanent integration failure: move to a dead-letter queue and alert an
  operator; do not roll back the already accepted domain fact.

