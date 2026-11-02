/** PSEUDOCODE PROCESS SKELETONS: Claim. */

export async function validateClaimEligibility(context: ProcessContext) {
  // Confirm actor authority, organization status, target claimability, and service capability.
  // Confirm every selected RepairNeed belongs to the same Application.
  // Return explainable rejection reasons without creating a success event.
}

export async function checkClaimConflicts(context: ProcessContext) {
  // Lock selected RepairNeeds or their active-Claim keys for the transaction.
  // Reject a conflicting active Claim and return the current Claim/need versions.
  // Permit configured shared/partial claims only when the target model explicitly allows them.
}

export async function createOrReuseOrganizationCase(context: ProcessContext) {
  // Locate the organization's active/reusable Case for this Application.
  // Create a new Case when none is eligible for reuse.
  // Preserve old expired/released Case history rather than overwriting it.
  // Emit case.opened only for a genuine open/reactivation transition.
}

export async function activateRepairNeedCoverage(context: ProcessContext) {
  // Create a Claim with organization, Case, target needs, actor, and expiration.
  // Attach the active Claim to each selected RepairNeed projection atomically.
  // Emit claim.activated with explicit RepairNeed IDs.
}

export async function resetClaimProgressDeadline(context: ProcessContext) {
  // Verify that the triggering event qualifies as progress for this Claim and organization.
  // Move expiresAt forward from the qualifying event time under the configured policy.
  // Record the causal event and avoid repeated renewal from replayed evidence.
}

export async function expireInactiveClaims(context: ProcessContext) {
  // Select active Claims whose deadline passed using a locked, retry-safe batch.
  // Recheck qualifying progress before expiry to avoid a scheduling race.
  // Emit claim.expired and release target coverage without deleting history.
}

export async function releaseRepairNeedCoverage(context: ProcessContext) {
  // Validate actor authority and required release reason/evidence.
  // End active target coverage and preserve the historical Claim relationship.
  // Emit claim.repairNeedRemoved or claim.released depending on remaining targets.
}

