# Implementation Sequence

## 1. Freeze contracts

- Confirm canonical object identifiers and statuses.
- Confirm command names and required payloads.
- Confirm event envelope and event type registry.
- Confirm Claim target rules and qualifying progress types.
- Confirm progress-task scope and completion keys.

Deliverable: shared types and JSON-schema/runtime-validation definitions.

## 2. Establish server infrastructure

- Nuxt server request context and authentication middleware.
- Organization/role authorization service.
- PostgreSQL transaction wrapper.
- Repository contracts.
- Immutable event repository.
- Transactional outbox repository.
- Command idempotency repository.

Deliverable: a no-op command can pass through the pipeline safely.

## 3. Build command dispatch

- Create an explicit `(objectType, command)` allowlist.
- Validate the command envelope and object ID.
- Resolve the correct handler without dynamic function execution.
- Enforce expected aggregate version.
- Standardize accepted, rejected, and conflict results.

Deliverable: route skeleton can dispatch a registered test command.

## 4. Implement Submission to Application

- Receive immutable Submission.
- Normalize intake values.
- Resolve PlaceCode.
- locate or create Application.
- Link repeat Submissions.
- Extract and review repair requests.
- Create or merge RepairNeeds.

Deliverable: multiple Submissions safely consolidate into one Application.

## 5. Implement RepairNeed and Claim branching

- Assess/classify RepairNeeds.
- Determine claimability.
- Lock selected needs against conflicting active Claims.
- Create Claim and organization Case atomically.
- Add/remove needs from an existing active Claim.

Deliverable: separate organizations can claim different needs on the same
Application without claiming the entire Application.

## 6. Implement Case and Project creation

- Record Case-specific eligibility and document verification.
- Convert selected RepairNeeds to a Project and RepairTasks.
- Establish independent scope, budget, labor, contract, and schedule readiness.

Deliverable: one Case can contain multiple independently progressing Projects.

## 7. Implement RepairTask execution

- Assignment, schedule, progress, blocking, completion, and verification.
- Project aggregate progress.
- RepairNeed satisfaction evaluation.

Deliverable: verified/waived RepairTasks resolve RepairNeeds correctly.

## 8. Implement task resolver

- Load task definitions and completion rules.
- Match event evidence to scope.
- Write deterministic active completion records.
- Support revoked and superseded evidence.
- Calculate readiness without phase numbers.

Deliverable: Pinia receives task/readiness projections instead of scanning the
ledger.

## 9. Implement lifecycle automation

- Claim progress-deadline reset.
- Claim expiration scheduling.
- Case completion.
- Application conclusion and reopening.
- Notification and external-sync consumers.

Deliverable: Airtable Automation chains can be disabled one responsibility at
a time.

## 10. Migrate safely

- Run Nuxt consumers in observation mode against copied events.
- Compare projected results with existing Airtable outputs.
- Enable one command family at a time.
- Preserve legacy event-code aliases at ingestion boundaries.
- Keep an integration outbox for temporary Airtable dual-write.
- Disable matching Airtable Automations only after reconciliation passes.

Deliverable: controlled cutover with replay and rollback options.

