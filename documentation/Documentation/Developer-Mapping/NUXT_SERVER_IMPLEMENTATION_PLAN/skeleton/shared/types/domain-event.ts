/**
 * PSEUDOCODE CONTRACT ONLY.
 *
 * DomainEvent records one immutable fact that successfully occurred.
 */
export interface DomainEvent {
  schemaVersion: number;
  eventId: string;
  eventType: string;
  subject: {
    type: string;
    id: string;
    version: number;
  };
  occurredAt: string;
  recordedAt: string;
  actor: {
    type: "person" | "system" | "integration";
    id?: string;
    organizationId?: string;
  };
  correlationId: string;
  causationId: string;
  data: Record<string, unknown>;
}

