/**
 * PSEUDOCODE: server read-model reducers.
 *
 * These reducers mirror the conceptual client reducers but persist query-ready
 * projections. Each reducer must be deterministic and side-effect free.
 */

export function reduceSubmission(projection: SubmissionProjection, event: DomainEvent) {
  // Apply recognized submission.* facts and ignore unrelated event types.
}

export function reduceApplication(projection: ApplicationProjection, event: DomainEvent) {
  // Apply Application facts plus related RepairNeed, Claim, and Case summary changes.
  // Recalculate need coverage and resolution summaries deterministically.
}

export function reduceRepairNeed(projection: RepairNeedProjection, event: DomainEvent) {
  // Apply need facts, Claim coverage, linked RepairTasks, and satisfaction evidence.
}

export function reduceClaim(projection: ClaimProjection, event: DomainEvent) {
  // Apply Claim target, status, renewal, release, and expiration facts.
}

export function reduceCase(projection: CaseProjection, event: DomainEvent) {
  // Apply organization-specific contact, eligibility, assessment, Claim, and Project facts.
}

export function reduceProject(projection: ProjectProjection, event: DomainEvent) {
  // Apply scope, budget, resource, contract, task, work, and closeout facts.
  // Recalculate independent readiness dimensions without phase numbers.
}

export function reduceRepairTask(projection: RepairTaskProjection, event: DomainEvent) {
  // Apply task scope, assignment, schedule, progress, completion, and verification facts.
}

