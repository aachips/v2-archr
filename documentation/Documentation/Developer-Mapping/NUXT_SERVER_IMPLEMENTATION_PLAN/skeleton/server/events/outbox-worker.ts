/**
 * PSEUDOCODE: transactional outbox worker.
 */
export async function processOutboxBatch(options: { batchSize: number }) {
  // Claim a retry-safe batch of unpublished outbox rows.
  // Route each event through configured consumers.
  // Mark the row published only when required consumers succeed.
  // Schedule exponential retry for transient failures.
  // Move permanently failing rows to dead-letter review with diagnostics.
  // Return processed, retried, failed, and remaining counts.
}

