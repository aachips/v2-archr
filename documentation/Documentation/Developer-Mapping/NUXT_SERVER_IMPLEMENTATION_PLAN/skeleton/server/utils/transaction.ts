/**
 * PSEUDOCODE: transaction boundary.
 */
export async function withTransaction<T>(work: (tx: unknown) => Promise<T>): Promise<T> {
  // Acquire a database connection.
  // Begin a transaction with the required isolation level.
  // Run work(tx).
  // Commit on success.
  // Roll back on any error and rethrow a normalized server error.
}

