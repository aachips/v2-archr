/** PSEUDOCODE PROCESS SKELETONS: Application. */

export async function consolidateSubmissions(context: ProcessContext) {
  // Load every Submission linked to the Application in deterministic order.
  // Select canonical values by configured source/recency/human-approval rules.
  // Record field-level provenance rather than mutating raw Submissions.
}

export async function deduplicateApplicationData(context: ProcessContext) {
  // Compare candidate values and flag conflicts requiring human resolution.
  // Avoid replacing trusted values with lower-confidence automated values.
  // Produce a normalized Application patch plus provenance metadata.
}

export async function mergeNewSubmissionData(context: ProcessContext) {
  // Apply approved new facts from a later Submission to the Application.
  // Add new documents, contacts, notes, and RepairNeed candidates independently.
  // Emit application.detailsUpdated only for accepted canonical changes.
}

export async function mergeSubmissionDocuments(context: ProcessContext) {
  // De-duplicate files by stable content/source identifiers.
  // Link reusable documents to the Application and preserve every source Submission.
  // Mark replacements as new versions rather than deleting earlier evidence.
}

export async function mergeSubmissionRepairRequests(context: ProcessContext) {
  // Create, merge, or route each request for review against existing RepairNeeds.
  // Reopen a concluded Application if an unresolved RepairNeed is accepted.
}

export async function evaluateApplicationStatus(context: ProcessContext) {
  // Calculate status from human decisions, RepairNeed state, and active Cases.
  // Keep eligibility calculations as flags/evidence rather than automated denials.
  // Recommend commands/events; do not directly mutate state from a read operation.
}

export async function evaluateRepairNeedCoverage(context: ProcessContext) {
  // Select active claimable RepairNeeds and inspect active Claim coverage per need.
  // Calculate hasOpenNeeds, allNeedsAssessed, and allNeedsCovered projections.
  // Update derived milestone/task state without emitting duplicate domain facts.
}

export async function evaluateApplicationConclusion(context: ProcessContext) {
  // Conclude only when all RepairNeeds have a resolved disposition and no active Case work remains.
  // Reopen when a later Submission creates a new unresolved RepairNeed.
  // Emit application.concluded or application.reopened only on an actual transition.
}

