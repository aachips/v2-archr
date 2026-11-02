# Suggested Vue and Pinia Structure

This is a proposed frontend structure for the canonical ARCHR object model.
It is a design reference only and does not modify or replace the existing
`vue_fs` or `vue-view` directories.

The structure supports:

```text
Submission -> Application -> RepairNeed -> Claim -> Case -> Project -> RepairTask
```

It does not assume numbered phases. Pages and controls render from object state,
task requirements, permissions, and completion evidence.

## Proposed directory tree

```text
src/
|-- main.ts
|-- App.vue
|-- assets/
|   |-- base.css
|   |-- tokens.css
|   `-- utilities.css
|
|-- router/
|   |-- index.ts
|   `-- routes.ts
|
|-- pages/
|   |-- HomePage.vue
|   |-- SubmissionReviewPage.vue
|   |-- ApplicationWorkspacePage.vue
|   |-- RepairNeedDetailPage.vue
|   |-- ClaimMarketplacePage.vue
|   |-- CaseWorkspacePage.vue
|   |-- ProjectWorkspacePage.vue
|   |-- RepairTaskDetailPage.vue
|   `-- NotFoundPage.vue
|
|-- stores/
|   |-- submissions.ts
|   |-- applications.ts
|   |-- repair-needs.ts
|   |-- claims.ts
|   |-- cases.ts
|   |-- projects.ts
|   |-- repair-tasks.ts
|   |-- events.ts
|   |-- progress-tasks.ts
|   |-- documents.ts
|   |-- assessments.ts
|   |-- communications.ts
|   |-- session.ts
|   |-- workspace.ts
|   |-- operations.ts
|   `-- notifications.ts
|
|-- services/
|   |-- api/
|   |   |-- client.ts
|   |   |-- errors.ts
|   |   `-- endpoints.ts
|   |-- commands/
|   |   |-- submission-commands.ts
|   |   |-- application-commands.ts
|   |   |-- repair-need-commands.ts
|   |   |-- claim-commands.ts
|   |   |-- case-commands.ts
|   |   |-- project-commands.ts
|   |   `-- repair-task-commands.ts
|   |-- events/
|   |   |-- event-router.ts
|   |   |-- event-stream.ts
|   |   `-- event-validator.ts
|   `-- projections/
|       |-- application-projection.ts
|       |-- repair-need-projection.ts
|       |-- claim-projection.ts
|       |-- case-projection.ts
|       |-- project-projection.ts
|       `-- repair-task-projection.ts
|
|-- composables/
|   |-- useCommand.ts
|   |-- useEntity.ts
|   |-- useEntityEvents.ts
|   |-- usePermissions.ts
|   |-- useProgressTasks.ts
|   |-- useReadiness.ts
|   |-- useSelection.ts
|   `-- useUnsavedChanges.ts
|
|-- components/
|   |-- common/
|   |   |-- AsyncContent.vue
|   |   |-- EmptyState.vue
|   |   |-- ErrorAlert.vue
|   |   |-- LoadingIndicator.vue
|   |   |-- StatusBadge.vue
|   |   |-- DateTimeDisplay.vue
|   |   |-- OrganizationBadge.vue
|   |   |-- PersonBadge.vue
|   |   |-- EntityLink.vue
|   |   `-- PaginationControls.vue
|   |
|   |-- layout/
|   |   |-- AppHeader.vue
|   |   |-- AppSidebar.vue
|   |   |-- PageHeader.vue
|   |   |-- WorkspaceLayout.vue
|   |   |-- WorkspaceNavigation.vue
|   |   `-- DetailDrawer.vue
|   |
|   |-- commands/
|   |   |-- CommandButton.vue
|   |   |-- CommandMenu.vue
|   |   |-- CommandConfirmationDialog.vue
|   |   |-- CommandErrorAlert.vue
|   |   |-- ReasonRequiredDialog.vue
|   |   `-- ConcurrentUpdateDialog.vue
|   |
|   |-- activity/
|   |   |-- ActivityTimeline.vue
|   |   |-- ActivityTimelineItem.vue
|   |   |-- EventDetailsDrawer.vue
|   |   |-- ActorDisplay.vue
|   |   `-- ChangeSummary.vue
|   |
|   |-- workflow/
|   |   |-- ProgressTaskList.vue
|   |   |-- ProgressTaskCard.vue
|   |   |-- TaskCompletionBadge.vue
|   |   |-- TaskEvidenceList.vue
|   |   |-- RequirementList.vue
|   |   |-- ReadinessChecklist.vue
|   |   |-- CompletionHistory.vue
|   |   `-- BlockedReasonPanel.vue
|   |
|   |-- evidence/
|   |   |-- EvidenceList.vue
|   |   |-- EvidenceUploader.vue
|   |   |-- EvidenceViewer.vue
|   |   |-- VerificationControl.vue
|   |   |-- SignatureStatus.vue
|   |   |-- PhotoGallery.vue
|   |   `-- PhotoUploader.vue
|   |
|   |-- submissions/
|   |   |-- SubmissionCard.vue
|   |   |-- SubmissionList.vue
|   |   |-- SubmissionRawDataViewer.vue
|   |   |-- SubmissionProcessingStatus.vue
|   |   |-- SubmissionMatchPanel.vue
|   |   `-- SubmissionRepairRequestList.vue
|   |
|   |-- applications/
|   |   |-- ApplicationCard.vue
|   |   |-- ApplicationHeader.vue
|   |   |-- ApplicationSummary.vue
|   |   |-- ApplicationStatusBadge.vue
|   |   |-- ApplicationEligibilityFlags.vue
|   |   |-- ApplicationSubmissionList.vue
|   |   |-- ApplicationRepairNeedBoard.vue
|   |   |-- ApplicationCaseList.vue
|   |   |-- ApplicationConclusionPanel.vue
|   |   `-- ApplicationActionMenu.vue
|   |
|   |-- repair-needs/
|   |   |-- RepairNeedCard.vue
|   |   |-- RepairNeedList.vue
|   |   |-- RepairNeedEditor.vue
|   |   |-- RepairNeedAssessmentForm.vue
|   |   |-- RepairNeedClassificationForm.vue
|   |   |-- RepairNeedDispositionMenu.vue
|   |   |-- RepairNeedCoverageBadge.vue
|   |   |-- RepairNeedTaskList.vue
|   |   |-- ClaimRepairNeedButton.vue
|   |   |-- ConvertNeedToTasksDialog.vue
|   |   `-- RepairNeedSatisfactionPanel.vue
|   |
|   |-- claims/
|   |   |-- ClaimButton.vue
|   |   |-- ClaimConfirmationDialog.vue
|   |   |-- ClaimStatusBadge.vue
|   |   |-- ClaimCountdown.vue
|   |   |-- ClaimSummaryCard.vue
|   |   |-- ClaimedNeedList.vue
|   |   |-- ClaimTargetPicker.vue
|   |   |-- ClaimOwnerPicker.vue
|   |   |-- RenewClaimButton.vue
|   |   |-- ReleaseClaimDialog.vue
|   |   `-- ExpiringClaimAlert.vue
|   |
|   |-- cases/
|   |   |-- CaseCard.vue
|   |   |-- CaseHeader.vue
|   |   |-- CaseReadinessSummary.vue
|   |   |-- CaseClaimedNeedList.vue
|   |   |-- CaseContactPanel.vue
|   |   |-- ContactLogForm.vue
|   |   |-- CaseProgramSelector.vue
|   |   |-- AssessorAssignmentForm.vue
|   |   |-- AssessmentScheduler.vue
|   |   |-- CaseDocumentVerificationPanel.vue
|   |   |-- CaseProjectList.vue
|   |   |-- CreateProjectDialog.vue
|   |   `-- CaseCompletionPanel.vue
|   |
|   |-- projects/
|   |   |-- ProjectCard.vue
|   |   |-- ProjectHeader.vue
|   |   |-- ProjectReadinessPanel.vue
|   |   |-- ProjectScopeBuilder.vue
|   |   |-- ProjectTaskList.vue
|   |   |-- ProjectBudgetEditor.vue
|   |   |-- ProjectTimelineEditor.vue
|   |   |-- ProjectResourcePlanner.vue
|   |   |-- MaterialsListEditor.vue
|   |   |-- WorkCrewAssignment.vue
|   |   |-- VolunteerSlotEditor.vue
|   |   |-- SubcontractorAssignment.vue
|   |   |-- ContractPanel.vue
|   |   |-- ChangeOrderPanel.vue
|   |   |-- ProjectProgressSummary.vue
|   |   |-- PunchListEditor.vue
|   |   |-- FinalWalkthroughForm.vue
|   |   |-- ProjectCloseoutChecklist.vue
|   |   `-- DrawRequestPanel.vue
|   |
|   `-- repair-tasks/
|       |-- RepairTaskCard.vue
|       |-- RepairTaskList.vue
|       |-- RepairTaskEditor.vue
|       |-- RepairTaskLibraryPicker.vue
|       |-- RepairTaskEstimateForm.vue
|       |-- RepairTaskAssignmentForm.vue
|       |-- RepairTaskScheduleForm.vue
|       |-- RepairTaskStatusControl.vue
|       |-- RepairTaskProgressForm.vue
|       |-- RepairTaskEvidencePanel.vue
|       |-- RepairTaskVerificationDialog.vue
|       `-- RepairTaskBlockDialog.vue
|
|-- types/
|   |-- identifiers.ts
|   |-- commands.ts
|   |-- events.ts
|   |-- submission.ts
|   |-- application.ts
|   |-- repair-need.ts
|   |-- claim.ts
|   |-- case.ts
|   |-- project.ts
|   |-- repair-task.ts
|   |-- progress-task.ts
|   |-- evidence.ts
|   `-- api.ts
|
|-- constants/
|   |-- event-types.ts
|   |-- task-codes.ts
|   |-- object-types.ts
|   `-- statuses.ts
|
|-- utils/
|   |-- assertions.ts
|   |-- dates.ts
|   |-- entity-keys.ts
|   |-- event-guards.ts
|   `-- task-scope-keys.ts
|
`-- tests/
    |-- fixtures/
    |   |-- events.ts
    |   `-- entities.ts
    |-- projections/
    |-- stores/
    `-- components/
```

## Store responsibilities

### Canonical entity stores

| Store | Owns | Important selectors |
|---|---|---|
| `submissions.ts` | Raw submission projections and processing results | `needsMatchReview`, `canRetryProcessing` |
| `applications.ts` | Application identity and aggregate summaries | `allNeedsCovered`, `allNeedsResolved`, `canConclude` |
| `repair-needs.ts` | Need assessment, disposition, coverage, and satisfaction | `canClaim`, `canConvertToTasks`, `isSatisfied` |
| `claims.ts` | Claim targets, organizations, status, and expiration | `getActiveClaimForTarget`, `canRenew`, `remainingClaimTime` |
| `cases.ts` | Organization-specific eligibility and service state | `requiredDocumentsVerified`, `canCreateProject`, `canCompleteCase` |
| `projects.ts` | Scope, budget, resources, contract, work, and closeout | `canStart`, `workComplete`, `closeoutReady` |
| `repair-tasks.ts` | Individual repair execution and verification | `canStart`, `canComplete`, `isAcceptedComplete` |

All entity stores should normalize records by ID:

```ts
interface NormalizedEntityState<T> {
  byId: Record<string, T>;
  ids: string[];
  versionById: Record<string, number>;
  loadingById: Record<string, boolean>;
  errorById: Record<string, string | undefined>;
}
```

### Workflow and evidence stores

| Store | Responsibility |
|---|---|
| `events.ts` | Deduplicate, order, and route received events; hold recent timeline events. |
| `progress-tasks.ts` | Task definitions, requirements, completion evidence, and readiness summaries. |
| `documents.ts` | Shared Application documents and Case/Project-specific documents, photos, signatures, and versions. |
| `assessments.ts` | Assessment scheduling, reports, evidence, and assessed RepairNeeds. |
| `communications.ts` | Communications, contact attempts, outcomes, and contact summaries. |

The complete immutable ledger remains server-side. `events.ts` only retains the
events needed for current projection, synchronization, and visible timelines.

### Application-shell stores

| Store | Responsibility |
|---|---|
| `session.ts` | Current person, organization, roles, and permissions. |
| `workspace.ts` | Current Application, Case, Project, tab, filters, and panel state. |
| `operations.ts` | Pending command keys, retry state, and command-specific failures. |
| `notifications.ts` | Transient success, warning, conflict, and error notices. |

Domain records do not belong in `workspace.ts`, and domain errors do not belong
in `notifications.ts` as their only persisted representation.

## Store interface pattern

Each canonical entity store should expose a consistent interface:

```ts
interface CanonicalEntityStore<T, E> {
  byId: Record<string, T>;
  ids: string[];
  versionById: Record<string, number>;

  fetchOne(id: string): Promise<void>;
  fetchMany(query?: Record<string, unknown>): Promise<void>;
  upsertSnapshot(entity: T): void;
  applyEvent(event: E): void;
}
```

`upsertSnapshot` is for initial hydration and server resynchronization.
`applyEvent` is the normal path for accepted domain changes.

## Component design rules

### Components dispatch commands

Components do not directly modify canonical store records:

```text
Component
  -> command service
  -> API validation and transaction
  -> appended event response
  -> event router
  -> store reducers
  -> selector recomputation
  -> component rerender
```

For example:

```text
ClaimRepairNeedButton
  -> claimRepairNeed command
  -> claim.activated + case.opened
  -> claim, RepairNeed, Case, and Application projections
  -> Claim button disappears and Case link appears
```

### Components use selectors

A component asks:

```ts
repairNeedStore.canClaim(repairNeedId);
projectStore.closeoutReady(projectId);
applicationStore.canConclude(applicationId);
```

It does not scan raw historical events or reconstruct state in the template.

### Forms own drafts, stores own accepted state

Editors maintain local form drafts until a command succeeds. The store remains
the projection of accepted server state, preventing cancelled edits from
contaminating canonical state.

### Permissions and availability remain distinct

```vue
<CommandButton
  command="claimRepairNeed"
  :allowed="session.can('claimRepairNeed', repairNeed)"
  :available="repairNeeds.canClaim(repairNeed.id)"
  :loading="operations.isPending(commandKey)"
/>
```

- `allowed` answers whether the actor has permission.
- `available` answers whether current domain state permits the command.
- The API repeats both checks authoritatively.

## Page composition

### Application workspace

```text
ApplicationWorkspacePage
|-- ApplicationHeader
|-- ApplicationEligibilityFlags
|-- ApplicationSubmissionList
|-- ApplicationRepairNeedBoard
|   `-- RepairNeedCard
|       |-- RepairNeedCoverageBadge
|       `-- ClaimRepairNeedButton
|-- ApplicationCaseList
|-- ProgressTaskList
`-- ActivityTimeline
```

### Case workspace

```text
CaseWorkspacePage
|-- CaseHeader
|-- CaseReadinessSummary
|-- CaseClaimedNeedList
|-- CaseContactPanel
|-- CaseDocumentVerificationPanel
|-- CaseProjectList
|-- ProgressTaskList
`-- ActivityTimeline
```

### Project workspace

```text
ProjectWorkspacePage
|-- ProjectHeader
|-- ProjectReadinessPanel
|-- ProjectScopeBuilder
|-- ProjectTaskList
|-- ProjectBudgetEditor
|-- ProjectTimelineEditor
|-- ProjectResourcePlanner
|-- ContractPanel
|-- ProjectProgressSummary
|-- ProjectCloseoutChecklist
|-- ProgressTaskList
`-- ActivityTimeline
```

## Event routing

Stores should not import one another in a circular graph. `event-router.ts`
routes each event to every projection affected by that fact:

```ts
function routeEvent(event: DomainEvent, stores: ProjectionStores) {
  stores.events.applyEvent(event);

  stores.submissions.applyEvent(event);
  stores.applications.applyEvent(event);
  stores.repairNeeds.applyEvent(event);
  stores.claims.applyEvent(event);
  stores.cases.applyEvent(event);
  stores.projects.applyEvent(event);
  stores.repairTasks.applyEvent(event);
  stores.progressTasks.applyEvent(event);
}
```

Each reducer ignores event types it does not consume. Applied event IDs and
subject versions prevent duplicate or out-of-order projection changes.

## Suggested implementation order

1. Shared identifiers, events, commands, statuses, and entity types.
2. API client, command wrapper, operation tracking, and error handling.
3. Event store, event validator, router, and projection tests.
4. Application, RepairNeed, Claim, and Case stores.
5. Shared command, activity, workflow, and evidence components.
6. Application workspace and Claim marketplace.
7. Project and RepairTask stores and workspaces.
8. Submission review, assessment, documents, and communications tooling.
9. Realtime event streaming and conflict-recovery UI.

