/**
 * PSEUDOCODE CONTRACT ONLY.
 *
 * expectedVersion provides optimistic concurrency protection.
 * idempotencyKey prevents retries from executing a command twice.
 */
export interface CommandEnvelope<TPayload = Record<string, unknown>> {
  commandId: string;
  commandType: string;
  subject: {
    type: string;
    id: string;
    expectedVersion?: number;
  };
  idempotencyKey: string;
  payload: TPayload;
}

