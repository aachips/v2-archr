### What It Is

Milestones are **checkpoints** in the process. They represent "big picture" progress, not every little action.

┌─────────────────────────────────────────────────────────────────────────────────┐
│  MILESTONES IN A HOME REPAIR PROCESS                                           │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  Phase 0: Submission                                                            │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  M1: Application Submitted  →  (triggered by first submission)         │   │
│  │  M2: Eligibility Checked    →  (triggered by eligibility report)       │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
│  Phase 1: Intake                                                               │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  M3: Claimed by Organization  →  (triggered by claim)                  │   │
│  │  M4: Assessor Assigned        →  (triggered by assignment)             │   │
│  │  M5: Assessment Scheduled     →  (triggered by scheduling)             │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
│  Phase 2: Processing                                                           │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  M6: Assessment Completed     →  (triggered by assessment report)      │   │
│  │  M7: Documents Verified       →  (triggered by verification)           │   │
│  │  M8: Budget Approved          →  (triggered by budget approval)        │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
│  Phase 3: Planning                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  M9: Contract Signed          →  (triggered by contract signing)       │   │
│  │  M10: Work Scheduled          →  (triggered by schedule)               │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
│  Phase 4: Execution                                                            │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  M11: Work Started            →  (triggered by first task start)       │   │
│  │  M12: Work Completed          →  (triggered by final task complete)    │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
│  Phase 5: Completion                                                            │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  M13: Final Inspection Passed →  (triggered by inspection)             │   │
│  │  M14: Certificate Signed      →  (triggered by signature)              │   │
│  │  M15: Case Closed             →  (triggered by completion)             │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘

### Milestone Data Model

|Field|Type|Example|
|---|---|---|
|**id**|UUID|`ms_12345678`|
|**milestone_name**|String|`Assessment Completed`|
|**milestone_code**|String|`M6`|
|**phase**|Integer|`2`|
|**order**|Integer|`3`|
|**application_id**|UUID|`app_42CHERRY`|
|**completed_at**|DateTime|`2026-09-01 10:00:00`|
|**completed_by**|UUID|`usr_abcdefg`|
|**completed**|Boolean|`true`|

### How Milestones Get Completed

Milestones are **triggered** by Activity Log events.

When an Activity Log entry is created, the system checks:

> _"Does this action complete a milestone?"_

If yes → mark the milestone as complete.