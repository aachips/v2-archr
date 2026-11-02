/**
 * PSEUDOCODE: command pipeline coordinator.
 */
export async function dispatchCommand(envelope: CommandEnvelope): Promise<CommandResult> {
  // Check whether this idempotency key already has a stored result.
  // Resolve an allowlisted handler for subject.type + commandType.
  // Validate the command payload using its command-specific schema.
  // Load current aggregate state and compare expectedVersion.
  // Authorize the actor against both permission and current domain state.
  // Begin one database transaction.
  // Invoke the domain handler to calculate canonical writes and events.
  // Persist canonical record changes.
  // Append immutable events with consecutive subject versions.
  // Insert the same events into the transactional outbox.
  // Save the idempotent CommandResult.
  // Commit and return accepted events for immediate Pinia projection.
}

