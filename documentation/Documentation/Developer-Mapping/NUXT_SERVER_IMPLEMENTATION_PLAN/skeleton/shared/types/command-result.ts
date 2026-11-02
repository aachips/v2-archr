import type { DomainEvent } from "./domain-event";

/** PSEUDOCODE CONTRACT ONLY. */
export interface CommandResult {
  commandId: string;
  status: "accepted" | "rejected" | "conflict";
  events: DomainEvent[];
  currentVersion?: number;
  snapshot?: Record<string, unknown>;
  validationErrors?: Array<{ path: string; message: string }>;
  rejection?: { code: string; message: string };
}

