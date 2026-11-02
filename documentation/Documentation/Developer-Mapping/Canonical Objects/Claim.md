# Claim

## Definition

A Claim is an organization's time-bounded commitment to serve one or more
RepairNeeds or another explicitly identified target. Activating a RepairNeed
Claim creates or reactivates the organization's Case for the parent Application.

A Claim is not a status field embedded in a RepairNeed. It has its own identity,
actor, organization, timestamps, expiration, targets, and history.

## State

```ts
type ClaimState =
  | "pending"
  | "active"
  | "released"
  | "expired"
  | "rejected"
  | "cancelled";
```

## Commands

- `requestClaim`
- `activateClaim`
- `addRepairNeedToClaim`
- `removeRepairNeedFromClaim`
- `renewClaim`
- `releaseClaim`
- `expireClaim`
- `cancelClaim`

UI convenience commands such as `claimRepairNeed`, `claimRepairTask`, or
`claimScope` delegate to the same underlying Claim process.

## Processes

- `validateClaimEligibility`
- `checkClaimConflicts`
- `createOrReuseOrganizationCase`
- `activateRepairNeedCoverage`
- `resetClaimProgressDeadline`
- `expireInactiveClaims`
- `releaseRepairNeedCoverage`

## Events

- `claim.requested`
- `claim.activated`
- `claim.repairNeedAdded`
- `claim.repairNeedRemoved`
- `claim.renewed`
- `claim.released`
- `claim.expired`
- `claim.rejected`
- `claim.cancelled`

`claim.requested` is only necessary when a Claim requires approval. An
immediately accepted Claim can begin with `claim.activated`.

Example:

```json
{
  "eventType": "claim.activated",
  "subject": {
    "type": "claim",
    "id": "claim_123",
    "version": 1
  },
  "data": {
    "applicationId": "app_123",
    "caseId": "case_123",
    "organizationId": "org_123",
    "repairNeedIds": ["need_roof", "need_window"],
    "expiresAt": "2026-12-02T14:00:00.000Z"
  }
}
```

## Reducer

`claimReducer` maintains:

- Application and Case IDs
- Organization and responsible-person IDs
- Claimed RepairNeed or other target IDs
- Current status
- Claimed, renewed, released, and expiration timestamps
- Last qualifying progress timestamp

| Event | Projected change |
|---|---|
| `claim.requested` | Set `status = "pending"`. |
| `claim.activated` | Set `status = "active"`, targets, claimant, and expiration. |
| `claim.repairNeedAdded` | Add the target need after conflict validation. |
| `claim.repairNeedRemoved` | Remove the target need and release its coverage. |
| `claim.renewed` | Update `renewedAt` and `expiresAt`. |
| `claim.released` | Set `status = "released"`. |
| `claim.expired` | Set `status = "expired"`. |
| `claim.rejected` | Set `status = "rejected"`. |
| `claim.cancelled` | Set `status = "cancelled"`. |

Cross-object projectors apply Claim events to Application, RepairNeed, Case,
Project, and organization-workload projections.

## Tasks

- `REVIEW_CLAIM_ELIGIBILITY` - Review Repair Need Eligibility
- `REVIEW_ORGANIZATION_CAPACITY` - Review Organization Capacity
- `CONFIRM_CLAIM` - Confirm Claim
- `ASSIGN_CLAIM_OWNER` - Assign Claim Owner
- `ADD_NEED_TO_CLAIM` - Add Repair Need to Existing Claim
- `REVIEW_EXPIRING_CLAIM` - Review Expiring Claim
- `RENEW_OR_RELEASE_CLAIM` - Renew or Release Claim
- `RESOLVE_CLAIM_CONFLICT` - Resolve Claim Conflict

## Progress deadline

Only qualifying progress events reset Claim expiration. Viewing a record,
changing a label, or other administrative activity should not reset the timer.

Qualifying activity can include verified task progress, successful contact,
assessment completion, document verification, project work, or another
configured milestone for the claiming organization.

