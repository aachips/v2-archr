/** PSEUDOCODE PROCESS SKELETONS: Case. */

export async function openCaseFromClaim(context: ProcessContext) {
  // Create or reactivate one organization-specific Case for the Application.
  // Link Claim and selected RepairNeeds without copying shared Application documents.
  // Emit case.opened with organization, Application, Claim, and RepairNeed IDs.
}

export async function manageCaseContact(context: ProcessContext) {
  // Append an immutable communication/contact record with channel and outcome.
  // Distinguish attempted contact from successful contact.
  // Emit case.contactAttempted or case.contactMade.
}

export async function evaluateProgramEligibility(context: ProcessContext) {
  // Evaluate this organization's program rules against shared Application evidence.
  // Store Case-specific decisions and the rule/version used.
  // Require human confirmation where policy does not permit automatic approval.
}

export async function verifySharedApplicationDocuments(context: ProcessContext) {
  // Load the selected Application document version without moving document ownership.
  // Record a Case/program-specific verification, verifier, rule version, and evidence.
  // Emit case.incomeVerified, case.ownershipVerified, or the applicable revocation event.
}

export async function performAssessment(context: ProcessContext) {
  // Record assessment report, findings, photos, and assessor identity.
  // Create or update assessed RepairNeed proposals with traceable evidence.
  // Emit assessment/case completion facts only after required evidence is present.
}

export async function createAssessedRepairNeeds(context: ProcessContext) {
  // Translate accepted assessment findings into Application-owned RepairNeeds.
  // Merge duplicate findings and preserve Case/assessment provenance.
}

export async function groupRepairNeedsIntoProjects(context: ProcessContext) {
  // Validate that needs are covered by this Case's active Claim.
  // Group needs by scope, funding, program, schedule, or explicit user choice.
  // Create Projects and their initial RepairTasks atomically.
}

export async function evaluateCaseCompletion(context: ProcessContext) {
  // Confirm every RepairNeed assigned to the Case has a resolved disposition.
  // Confirm all required Projects are closed and no blocking Claim work remains.
  // Emit case.completed once, followed by case.closed when closeout policy is satisfied.
}

