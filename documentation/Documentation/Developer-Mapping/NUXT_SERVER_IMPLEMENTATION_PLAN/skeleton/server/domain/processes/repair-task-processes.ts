/** PSEUDOCODE PROCESS SKELETONS: RepairTask. */

export async function buildRepairTaskFromNeed(context: ProcessContext) {
  // Create one executable scope item linked to its Project and addressed RepairNeeds.
  // Copy selected library classifications while preserving user-entered scope details.
  // Emit repairTask.created.
}

export async function matchRepairTaskToLibrary(context: ProcessContext) {
  // Suggest task-library trade, item, interaction, labor, material, and safety metadata.
  // Retain suggestion confidence and require review according to policy.
}

export async function validateRepairTaskScope(context: ProcessContext) {
  // Confirm the task belongs to the Project scope and addresses at least one included need.
  // Detect duplicate or contradictory tasks before approval/finalization.
}

export async function estimateRepairTaskCostAndDuration(context: ProcessContext) {
  // Calculate labor hours, materials, subcontractor amounts, duration, and estimated cost.
  // Preserve calculation inputs and pricing-library version.
  // Emit repairTask.estimated after acceptance.
}

export async function assignRepairTaskResources(context: ProcessContext) {
  // Validate assignee capability, organization, schedule, and Project access.
  // Store crew/person/subcontractor assignment and emit repairTask.assigned.
}

export async function scheduleRepairTaskWork(context: ProcessContext) {
  // Validate dependencies and resource availability.
  // Set planned start/end dates and emit repairTask.scheduled.
}

export async function trackRepairTaskProgress(context: ProcessContext) {
  // Append progress amount, notes, time, material use, photos, and actor evidence.
  // Update actuals without overwriting previous progress history.
  // Emit repairTask.progressRecorded.
}

export async function verifyRepairTaskEvidence(context: ProcessContext) {
  // Confirm required completion evidence, inspection, and verifier authority.
  // Emit repairTask.verified or return a documented rejection.
}

export async function updateRepairNeedSatisfaction(context: ProcessContext) {
  // Re-evaluate every addressed RepairNeed after task verification, waiver, or reopening.
  // Queue satisfaction/reopening commands only for actual state transitions.
}

export async function updateProjectCompletion(context: ProcessContext) {
  // Recalculate Project work and closeout readiness after RepairTask changes.
  // Queue Project completion evaluation without directly invoking an HTTP route.
}

