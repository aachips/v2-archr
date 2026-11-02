/** PSEUDOCODE PROCESS SKELETONS: Submission. */

export async function ingestSubmission(context: ProcessContext) {
  // Preserve the exact inbound form/referral payload as an immutable Submission.
  // Capture source, received time, submitter metadata, and an idempotency key.
  // Emit submission.received and enqueue normalization after commit.
}

export async function normalizeSubmissionData(context: ProcessContext) {
  // Map source-specific question keys into canonical Application candidate fields.
  // Normalize names, addresses, phones, household data, and uploaded-file references.
  // Preserve both raw values and normalized values for auditability.
  // Emit submission.normalized or submission.processingFailed.
}

export async function resolvePlaceCode(context: ProcessContext) {
  // Normalize the address and query the configured address/GIS providers.
  // Derive the canonical PlaceCode without overwriting the raw submitted address.
  // Store match confidence and evidence; route inconclusive results to review.
  // Emit submission.placeCodeResolved or submission.matchReviewRequired.
}

export async function checkForDuplicateApplication(context: ProcessContext) {
  // Compare PlaceCode and approved identity signals against existing Applications.
  // Distinguish repeat/follow-up Submissions from likely accidental duplicates.
  // Return a proposed match; do not merge uncertain records automatically.
  // Emit application-match-found, no-match, or review-required evidence.
}

export async function extractRepairRequests(context: ProcessContext) {
  // Convert raw repair-request answers into individually addressable request records.
  // Retain the original text, source Submission ID, order, and attachments.
  // Emit submission.repairRequestsExtracted with the created request IDs.
}

export async function matchRepairRequestsToExistingNeeds(context: ProcessContext) {
  // Compare each extracted request with existing Application RepairNeeds.
  // Use normalized area/trade/item/interaction tags plus human-review thresholds.
  // Propose merge, create, or review decisions without silently discarding text.
}

export async function attachSubmissionToApplication(context: ProcessContext) {
  // Lock the Submission and selected Application or create a new Application.
  // Link the immutable Submission, merge approved canonical values, and preserve provenance.
  // Emit application.created when required and submission.linkedToApplication.
}

