# Application

## Definition

An Application is the durable, normalized record for one household/property at
a PlaceCode. It consolidates one or more Submissions and owns shared documents,
photos, eligibility flags, communications, assessments, and RepairNeeds.

An Application can branch into several organization-specific Cases. It remains
active while any unresolved RepairNeed exists.

## State

```ts
type ApplicationState =
  | "new"
  | "active"
  | "paused"
  | "concluded"
  | "terminated"
  | "withdrawn";
```

`new` may be computed from age instead of stored as a lifecycle state.

Recommended derived state:

```ts
interface ApplicationSummary {
  hasOpenNeeds: boolean;
  allNeedsAssessed: boolean;
  allNeedsCovered: boolean;
  allNeedsResolved: boolean;
  activeCaseCount: number;
  activeProjectCount: number;
}
```

## Commands

- `createApplication`
- `linkSubmission`
- `updateApplicationDetails`
- `addRepairNeed`
- `mergeRepairNeeds`
- `pauseApplication`
- `resumeApplication`
- `withdrawApplication`
- `terminateApplication`
- `concludeApplication`
- `reopenApplication`

## Processes

- `consolidateSubmissions`
- `deduplicateApplicationData`
- `mergeNewSubmissionData`
- `mergeSubmissionDocuments`
- `mergeSubmissionRepairRequests`
- `evaluateApplicationStatus`
- `evaluateRepairNeedCoverage`
- `evaluateApplicationConclusion`

## Events

- `application.created`
- `application.submissionLinked`
- `application.detailsUpdated`
- `application.paused`
- `application.resumed`
- `application.withdrawn`
- `application.terminated`
- `application.concluded`
- `application.reopened`

The Application projection also consumes:

- `repairNeed.recorded`
- `repairNeed.satisfied`
- `repairNeed.declined`
- `repairNeed.withdrawn`
- `claim.activated`
- `claim.released`
- `claim.expired`
- `case.opened`
- `case.closed`
- Application-scoped `document.uploaded`
- Application-scoped `assessment.completed`

## Reducer

`applicationReducer` maintains:

- Linked Submission IDs
- Shared household/property information
- Shared documents, photos, communications, and assessments
- RepairNeed IDs
- Claim and Case IDs
- Eligibility flags
- Current aggregate status
- RepairNeed coverage and resolution summaries
- Latest activity timestamp

Key projected rules:

```ts
const claimableNeeds = repairNeeds.filter(isClaimable);

const allNeedsCovered =
  claimableNeeds.length > 0 &&
  claimableNeeds.every(need => Boolean(need.activeClaimId));

const allNeedsResolved =
  repairNeeds.length > 0 &&
  repairNeeds.every(need =>
    ["satisfied", "declined", "withdrawn", "duplicate"]
      .includes(need.status)
  );

const canConclude =
  allNeedsResolved && activeCaseCount === 0;
```

If a new Submission adds an unresolved RepairNeed to a concluded Application,
the responsible process emits `application.reopened`.

## Tasks

- `REVIEW_APPLICATION` - Review Application
- `RESOLVE_ELIGIBILITY_FLAGS` - Resolve Eligibility Flags
- `COLLECT_INCOME_EVIDENCE` - Collect Proof of Income
- `COLLECT_OWNERSHIP_EVIDENCE` - Collect Ownership Documentation
- `COLLECT_PROGRAM_DOCUMENTS` - Upload Program-Specific Documents
- `COLLECT_ASSESSMENT_PHOTOS` - Collect Assessment Photos
- `REVIEW_REPAIR_REQUESTS` - Review Repair Requests
- `CONFIRM_REPAIR_NEEDS` - Confirm Repair Needs
- `REVIEW_APPLICATION_CONCLUSION` - Review Application for Conclusion

Administrative actions such as pause, withdrawal, and termination are commands,
not standing tasks unless a review workflow explicitly requires them.

## Progress-task reinterpretation

The legacy **Application Claimed** milestone becomes **All Active Repair Needs
Covered**.

It is a derived Application milestone:

```ts
claimableNeeds.every(need => Boolean(need.activeClaimId));
```

It is not completed merely because one Claim exists.

