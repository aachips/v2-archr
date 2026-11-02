/** PSEUDOCODE: automation consumers replacing Airtable triggers. */

export async function projectCurrentState(event: DomainEvent) {
  // Route the event to every affected current-state projection reducer.
  // Store the last applied subject version and event ID.
}

export async function resolveProgressTaskEvidence(event: DomainEvent) {
  // Find active completion rules matching eventType and event evidence.
  // Calculate deterministic scope and completion keys.
  // Insert active completion or revoke/supersede prior evidence idempotently.
}

export async function evaluateDependentLifecycles(event: DomainEvent) {
  // RepairTask changes may trigger RepairNeed and Project evaluation.
  // RepairNeed/Project changes may trigger Case evaluation.
  // RepairNeed/Case changes may trigger Application evaluation.
  // Enqueue follow-on commands; never call API routes recursively.
}

export async function resetQualifyingClaimDeadlines(event: DomainEvent) {
  // Find active Claims affected by the event's Case, organization, or target.
  // Apply the configured qualifying-progress policy and enqueue renewal commands.
}

export async function synchronizeAirtable(event: DomainEvent) {
  // Map selected canonical changes to temporary Airtable dual-write operations.
  // Upsert using stable external keys and store sync checkpoints.
  // Retry transient failures without duplicating Airtable records.
}

export async function deliverNotifications(event: DomainEvent) {
  // Match notification policies for assignment, expiry, blocking, and review events.
  // Resolve recipients and delivery channels.
  // Insert durable, idempotent notification deliveries.
}

