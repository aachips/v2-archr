/** PSEUDOCODE PROCESS SKELETONS: RepairNeed. */

export async function extractRepairNeedFromSubmission(context: ProcessContext) {
  // Create a RepairNeed from an approved repair request with source provenance.
  // Preserve original language and add normalized searchable fields separately.
  // Emit repairNeed.recorded.
}

export async function matchRepairNeedToTaskLibrary(context: ProcessContext) {
  // Compare need text/classification with task-library/library entries.
  // Produce suggestions for trade, area, item, interaction, and possible RepairTasks.
  // Keep suggestions unapproved until confidence or human-review rules are met.
}

export async function detectDuplicateRepairNeed(context: ProcessContext) {
  // Compare the candidate with active and resolved needs on the Application.
  // Consider location, trade, item, description, and source timing.
  // Propose merge or independent-need disposition with supporting evidence.
}

export async function assessRepairNeedDamage(context: ProcessContext) {
  // Attach assessment findings, severity, evidence, eligibility flags, and recommendations.
  // Preserve the assessment version used for the determination.
  // Emit repairNeed.assessed.
}

export async function calculateRepairNeedPriority(context: ProcessContext) {
  // Apply configured urgency, safety, habitability, demographic, and wait-time rules.
  // Store contributing factors so the score remains explainable.
  // Emit repairNeed.priorityAssigned when the accepted priority changes.
}

export async function evaluateRepairNeedEligibility(context: ProcessContext) {
  // Combine assessment evidence with applicable program/service constraints.
  // Produce flags and a human decision recommendation, not an automatic denial.
}

export async function evaluateRepairNeedClaimability(context: ProcessContext) {
  // Require an approved, unresolved need with no conflicting active Claim.
  // Apply visibility rules for organization service area, trade, and program capability.
}

export async function buildRepairTasksFromNeed(context: ProcessContext) {
  // Validate the selected Case and Project grouping strategy.
  // Convert approved scope suggestions into RepairTask records linked to this need.
  // Create the Project atomically when no appropriate Project exists.
  // Emit project.created, repairTask.created, and repairNeed.convertedToTasks as appropriate.
}

export async function evaluateRepairNeedSatisfaction(context: ProcessContext) {
  // Load every required RepairTask linked to the need.
  // Treat verified or explicitly waived tasks as satisfied evidence.
  // Emit repairNeed.satisfied once; emit repairNeed.reopened if evidence is later invalidated.
}

