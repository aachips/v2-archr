/** PSEUDOCODE PROCESS SKELETONS: Project. */

export async function createProjectFromRepairNeeds(context: ProcessContext) {
  // Validate Case ownership and active Claim coverage for every included RepairNeed.
  // Create the Project and link the selected needs in one transaction.
  // Optionally create initial RepairTasks from approved task-library suggestions.
  // Emit project.created and any repairTask.created events.
}

export async function buildProjectTaskList(context: ProcessContext) {
  // Assemble RepairTasks required to address the included RepairNeeds.
  // Validate that each need has adequate task coverage or an explicit exception.
  // Emit project.taskListFinalized only when the user finalizes the list.
}

export async function calculateProjectBudget(context: ProcessContext) {
  // Aggregate RepairTask labor/material estimates and subcontractor estimates.
  // Preserve line-level inputs, contingency, funding constraints, and calculation version.
  // Emit project.budgetDetermined after approval.
}

export async function planProjectResources(context: ProcessContext) {
  // Match tasks with work crews, volunteers, subcontractors, vehicles, and equipment.
  // Detect schedule/capacity conflicts and keep each assignment independently editable.
  // Emit the applicable labor/resource assignment events.
}

export async function generateProjectDocuments(context: ProcessContext) {
  // Build contract, scope, work-order, or completion document inputs from current projections.
  // Record the exact source versions used and create a versioned Document record.
  // Emit document/project generation evidence without marking unsigned documents complete.
}

export async function manageContractDecision(context: ProcessContext) {
  // Validate the active contract version and decision authority.
  // Record approval, rejection, or signature with actor and evidence.
  // Supersede task completion tied to a rejected/replaced version when necessary.
}

export async function manageScopeChanges(context: ProcessContext) {
  // Create a versioned Change Order rather than mutating the accepted scope silently.
  // Apply approved task, cost, material, and timeline changes together.
  // Emit creation and decision events for the Change Order lifecycle.
}

export async function aggregateRepairTaskProgress(context: ProcessContext) {
  // Aggregate required RepairTask counts and verified/waived/blocked status.
  // Calculate progress without treating one created task as a finalized task list.
  // Update the Project read projection and readiness tasks idempotently.
}

export async function evaluateProjectReadiness(context: ProcessContext) {
  // Independently calculate scope, budget, labor, contract, schedule, work, and closeout readiness.
  // Do not require a universal ordering between unrelated readiness dimensions.
}

export async function evaluateProjectCompletion(context: ProcessContext) {
  // Require verified/waived repair work, completion evidence, photos, and configured closeout items.
  // Emit project.workCompleted and project.closed only on their respective transitions.
}

export async function reconcileProjectCosts(context: ProcessContext) {
  // Aggregate actual labor, material, subcontractor, invoice, and draw-request values.
  // Compare actuals to the approved budget and surface unresolved discrepancies.
}

