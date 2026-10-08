# Event Resolver

The system that observes applications, evaluates events, determines the current
stage (phase), and advances applications from submission to completion.

## What It Does

1. **Reads** the `progress_events` ledger for a given application
2. **Evaluates** milestone completion rules against those events
3. **Updates** the `cases` table milestone timestamp columns
4. **Returns** `{ phase, milestones, next_actions, blocked }`

## Architecture

```
Event sources                          Event Resolver
─────────────                          ──────────────
intake-save.php     ────┐
case-review.php     ────┤
eligibility.php     ────┤    archr_resolve($case_id)
tle-poc.php         ────┤    │
user uploads        ────┘    ├─ 1. Load events from progress_events
                             ├─ 2. Evaluate each milestone rule
                             ├─ 3. Update milestone timestamps on cases
                             ├─ 4. Compute current phase
                             └─ 5. Return { phase, milestones[], next_actions[] }
```

## Milestone Pipeline

An application flows through 6 phases (0–5), each containing milestones:

| Phase | Name | Milestones |
|-------|------|-----------|
| P0 | Submission | M1: Application Submitted, M2: Eligibility Checked |
| P1 | Intake | M3: Claimed by Org, M4: Assessor Assigned, M5: Assessment Scheduled |
| P2 | Processing | M6: Assessment Completed, M7: Docs Verified, M8: Budget Approved |
| P3 | Planning | M9: Contract Signed, M10: Work Scheduled |
| P4 | Execution | M11: Work Started, M12: Work Completed |
| P5 | Completion | M13: Final Inspection, M14: Certificate Signed, M15: Case Closed |

## Milestone Timestamps on `cases` table

Each milestone completion writes a timestamp to the `cases` table:

| Column | Milestone |
|--------|-----------|
| `intake_completed_at` | M3+M4+M5 (Intake phase complete) |
| `assessment_scheduled_at` | M5 |
| `assessment_completed_at` | M6 |
| `approved_at` | M8+M9 (Budget + Contract) |
| `work_started_at` | M11 |
| `work_completed_at` | M12+M13+M14 |

## How Milestones Are Evaluated

Each milestone has a **rule** — a PHP function that returns `true` when the
milestone is complete. Rules check the `progress_events` table for specific
event types and data.

Example: **M6 (Assessment Completed)**
- Rule: An event of type `assessment_event` exists for this case with
  `status = 'completed'`

## Files

| File | Purpose |
|------|---------|
| `milestones.php` | Milestone definitions and evaluation rules |
| `resolver.php` | Core `archr_resolve()` function |
| `mutator.php` | State mutator — updates `cases` table when milestones complete |

## Usage

```php
require_once __DIR__ . '/lib/event-resolver/resolver.php';

$result = archr_resolve($pdo, $caseId);
// Returns:
// {
//   "phase": 2,
//   "phase_name": "Processing",
//   "milestones": [
//     { "code": "M1", "name": "Application Submitted", "completed": true, "at": "2026-09-01" },
//     ...
//   ],
//   "next_actions": ["Perform on-site assessment", "Collect before photos"],
//   "blocked": false
// }
```

## Design Decisions

- **Append-only events**: `progress_events` is never mutated. Events are evidence.
- **Idempotent resolution**: calling `archr_resolve()` multiple times produces
  the same result. It reads, evaluates, and updates timestamps — safe to call
  on every page load, after every save, or on cron.
- **Phase derived from timestamps**: the `archr_case_phase()` function in
  `case-phases.php` already derives phase from milestone columns. The resolver
  updates those columns; `archr_case_phase()` reads them. Clean separation.
- **No Vue duplication**: Vue reads the resolved state via API. All logic lives
  in PHP.
