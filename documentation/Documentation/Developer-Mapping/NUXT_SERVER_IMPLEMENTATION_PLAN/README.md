# Nuxt Server Implementation Plan

This directory is a non-runnable architecture and pseudocode skeleton for
replacing ARCHR's Airtable Automation workflows with Nuxt server routes and
Nitro-hosted processes.

Nothing in this directory is wired into the existing Vue applications. The
files under `skeleton/` intentionally contain comment-only method bodies and
are not expected to compile or run.

## Goals

- Expose explicit HTTP routes for queries and commands.
- Keep domain decisions in command handlers and processes, not route files.
- Write record changes and immutable events in one database transaction.
- Replace chained Airtable Automations with idempotent event consumers.
- Project events into the current state consumed by Pinia.
- Resolve progress-task completion from event evidence without phase numbers.
- Support one Application assembled from multiple Submissions.
- Support multiple RepairNeeds, Claims, organization Cases, and Projects.

## Proposed request flow

```text
Vue component
  -> POST command route
  -> authenticate actor and organization
  -> validate command envelope
  -> load current aggregate state and version
  -> authorize command
  -> execute domain process inside transaction
  -> update canonical records
  -> append immutable domain event(s)
  -> add event(s) to transactional outbox
  -> commit
  -> return CommandResult with accepted events
  -> Pinia immediately applies returned events

Outbox worker
  -> claim next unpublished event
  -> run idempotent consumers
  -> update read projections and progress-task completions
  -> enqueue notifications or follow-on commands
  -> mark outbox event published
```

## Why an outbox replaces automation chains

Airtable workflows often depend on one record mutation triggering another
automation. In the replacement design, the initiating transaction records the
business fact once. Independent consumers react after commit.

Each consumer records an idempotency key such as:

```text
consumerName|eventId|consumerVersion
```

Reprocessing an event is therefore safe and does not create duplicate Cases,
Claims, task completions, or notifications.

## Directory contents

```text
NUXT_SERVER_IMPLEMENTATION_PLAN/
|-- README.md
|-- ROUTE_MAP.md
|-- AUTOMATION_REPLACEMENT.md
|-- IMPLEMENTATION_SEQUENCE.md
`-- skeleton/
    |-- shared/
    |   `-- types/
    |       |-- command-envelope.ts
    |       |-- command-result.ts
    |       `-- domain-event.ts
    `-- server/
        |-- api/
        |   |-- commands/[objectType]/[objectId]/[command].post.ts
        |   |-- read-models/[objectType]/[objectId].get.ts
        |   |-- events/[subjectType]/[subjectId].get.ts
        |   `-- internal/automations/[automation].post.ts
        |-- middleware/
        |   `-- request-context.ts
        |-- domain/
        |   |-- command-dispatcher.ts
        |   |-- processes/
        |   |   |-- submission-processes.ts
        |   |   |-- application-processes.ts
        |   |   |-- repair-need-processes.ts
        |   |   |-- claim-processes.ts
        |   |   |-- case-processes.ts
        |   |   |-- project-processes.ts
        |   |   `-- repair-task-processes.ts
        |   `-- reducers/
        |       `-- projection-reducers.ts
        |-- events/
        |   |-- event-router.ts
        |   |-- event-consumers.ts
        |   `-- outbox-worker.ts
        |-- repositories/
        |   `-- repository-contracts.ts
        |-- tasks/
        |   `-- expire-claims.ts
        `-- utils/
            `-- transaction.ts
```

## Nuxt routing convention

Nuxt scans `server/api` and automatically exposes those files under `/api`.
Bracketed filenames provide route parameters, and HTTP method suffixes such as
`.get.ts` and `.post.ts` constrain the route method.

The generic command route in this skeleton demonstrates the shared pipeline.
Production implementation should expose an allowlisted command registry. A
request must never be allowed to invoke an arbitrary function by name.

## Command result contract

```ts
interface CommandResult {
  commandId: string;
  status: "accepted" | "rejected" | "conflict";
  events: DomainEvent[];
  currentVersion?: number;
  validationErrors?: ValidationIssue[];
  rejection?: {
    code: string;
    message: string;
  };
}
```

The accepted events let Pinia update immediately. A snapshot can be returned
when the client is too far behind or cannot safely apply the event sequence.

## Boundaries

- Routes parse HTTP and create a request context.
- Command handlers coordinate one use case.
- Domain processes decide what transformations and events are required.
- Repositories hide PostgreSQL/Airtable persistence details.
- Event consumers perform post-commit reactions.
- Progress-task rules consume evidence; they do not create the original fact.
- Pinia is a client projection and never authorizes server mutations.

## Current-schema migration warning

The existing `claim_application` SQL function claims an entire Application and
stores Claim lifecycle fields on the Case. The target model claims selected
RepairNeeds and gives Claim its own identity.

During migration, use an adapter that can read legacy Case claim columns, but
write new Claims through the target Claim repository. Do not permanently bake
the legacy whole-Application claim behavior into the Nuxt command handlers.

