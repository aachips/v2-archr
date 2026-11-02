# Case

## Definition

A Case is one organization's service relationship with an Application. It is
created or reactivated when that organization claims one or more RepairNeeds.
One Application may therefore have several Cases operating independently.

Cases use shared Application documents but own organization-specific program
decisions, document verifications, communications, claims, and Projects.

## State

```ts
type CaseState =
  | "open"
  | "active"
  | "paused"
  | "completed"
  | "released"
  | "expired"
  | "closed";
```

The Case has independent readiness dimensions rather than one sequential stage:

```ts
interface CaseReadiness {
  contactState: string;
  eligibilityState: string;
  assessmentState: string;
  documentationState: string;
  claimState: string;
  projectSummary: string;
}
```

## Commands

- `openCase`
- `recordContactAttempt`
- `recordSuccessfulContact`
- `assignProgram`
- `assignAssessor`
- `scheduleAssessment`
- `completeAssessment`
- `verifyIncomeForCase`
- `verifyOwnershipForCase`
- `assignFundingSource`
- `pauseCase`
- `resumeCase`
- `completeCase`
- `closeCase`

## Processes

- `openCaseFromClaim`
- `manageCaseContact`
- `evaluateProgramEligibility`
- `verifySharedApplicationDocuments`
- `performAssessment`
- `createAssessedRepairNeeds`
- `groupRepairNeedsIntoProjects`
- `evaluateCaseCompletion`

## Events

- `case.opened`
- `case.contactAttempted`
- `case.contactMade`
- `case.programAssigned`
- `case.assessorAssigned`
- `case.assessmentScheduled`
- `case.assessmentCompleted`
- `case.incomeVerified`
- `case.incomeVerificationRevoked`
- `case.ownershipVerified`
- `case.ownershipVerificationRevoked`
- `case.fundingSourceAssigned`
- `case.paused`
- `case.resumed`
- `case.completed`
- `case.closed`

Related events consumed by the Case projection:

- `claim.activated`
- `claim.renewed`
- `claim.released`
- `claim.expired`
- `project.created`
- `project.completed`
- `project.closed`

## Reducer

`caseReducer` maintains:

- Parent Application ID
- Organization ID
- Claim IDs and claimed RepairNeed IDs
- Program-specific eligibility and verification results
- Contact summary
- Assessment status
- Project IDs and aggregate Project status
- Claim deadline and latest qualifying progress
- Current Case status

Important ownership distinction:

```text
Application owns the shared income document.
Case owns Organization A's verification of that document for Program X.
```

Therefore, `document.uploaded` updates the Application projection, while
`case.incomeVerified` updates the Case projection.

## Tasks

- `MAKE_INITIAL_CONTACT` - Make Contact
- `ASSIGN_PROGRAM` - Assign Program
- `ASSIGN_ASSESSOR` - Assign Assessor
- `SCHEDULE_ASSESSMENT` - Schedule Assessment
- `COMPLETE_ASSESSMENT` - Complete Assessment
- `VERIFY_INCOME` - Verify Proof of Income
- `VERIFY_OWNERSHIP` - Verify Ownership Documentation
- `REVIEW_PROGRAM_DOCUMENTS` - Review Program-Specific Documents
- `ASSIGN_FUNDING_SOURCE` - Assign Funding Source
- `GROUP_NEEDS_INTO_PROJECT` - Group Claimed Needs into Project
- `COMPLETE_ORGANIZATION_CASE` - Complete Organization Case
- `RENEW_OR_RELEASE_CASE_CLAIM` - Renew or Release Claim

## Completion rules

| Task | Completion evidence |
|---|---|
| Make Contact | `case.contactMade` |
| Assign Program | `case.programAssigned` |
| Assign Assessor | `case.assessorAssigned` |
| Schedule Assessment | `case.assessmentScheduled` |
| Complete Assessment | `case.assessmentCompleted` or a qualifying shared Assessment event |
| Verify Income | Active `case.incomeVerified` for the applicable program/rule version |
| Verify Ownership | Active `case.ownershipVerified` for the applicable program/rule version |
| Assign Funding Source | `case.fundingSourceAssigned`, unless funding is intentionally Project-specific |
| Group Needs into Project | Every active claimed need is assigned to a Project or has another disposition |
| Complete Organization Case | All of this Case's claimed needs are resolved and its Projects are closed |

The legacy **Application -> Case Opened** milestone becomes **Organization Case
Opened** and is completed directly by `case.opened`.

