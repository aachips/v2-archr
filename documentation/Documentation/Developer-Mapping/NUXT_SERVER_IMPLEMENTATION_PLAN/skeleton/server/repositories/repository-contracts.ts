/**
 * PSEUDOCODE: persistence ports implemented later with PostgreSQL.
 */
export interface CanonicalRepository<T> {
  // Load one canonical record with its current aggregate version.
  // Save validated changes using optimistic concurrency.
  // Load scoped relationships needed to enforce domain invariants.
}

export interface EventRepository {
  // Append immutable events with unique IDs and sequential subject versions.
  // Load a subject stream from a version or pagination cursor.
}

export interface OutboxRepository {
  // Insert events in the same transaction as canonical record changes.
  // Claim unpublished rows without allowing two workers to process one row.
  // Mark rows published or record retry/dead-letter information.
}

export interface IdempotencyRepository {
  // Load a prior CommandResult by actor/organization/idempotency key.
  // Store the result before the transaction commits.
}

