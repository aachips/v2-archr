### Purpose

These condition checks determine which tasks are visible and available in the Quick Add interface based on the case's current progress.

|Check|Description|When True|When False|
|---|---|---|---|
|**displayClaim**|Case claimed by this org|Shows Claim phase tasks|Hides claim options|
|**displayAssess**|Assessment complete|Shows Processing phase tasks|Shows Assessment task|
|**displayScope**|Scope defined|Shows Planning phase tasks|Shows Scope task|
|**displayStart**|Work started|Shows Project phase tasks|Shows Start task|
|**displayComplete**|Work complete|Shows Completion phase tasks|Shows Complete task|

```
// Simplified condition check logic
function getAvailableTasks(caseId, orgId) {
    const caseStatus = getCaseStatus(caseId, orgId);
    const availableTasks = [];
    
    if (caseStatus.claimed === false) {
        availableTasks.push({ type: 'CLAIM', label: 'Claim Case' });
    }
    
    if (caseStatus.claimed === true && caseStatus.assessment_complete === false) {
        availableTasks.push({ type: 'ASSESS', label: 'Complete Assessment' });
    }
    
    if (caseStatus.assessment_complete === true && caseStatus.scope_complete === false) {
        availableTasks.push({ type: 'SCOPE', label: 'Define Scope of Work' });
    }
    
    if (caseStatus.scope_complete === true && caseStatus.work_started === false) {
        availableTasks.push({ type: 'START', label: 'Start Work' });
    }
    
    if (caseStatus.work_started === true && caseStatus.work_complete === false) {
        availableTasks.push({ type: 'COMPLETE', label: 'Complete Work' });
    }
    
    // Also show any active tasks in progress
    if (caseStatus.work_started === true && caseStatus.work_complete === false) {
        availableTasks.push({ type: 'PROGRESS', label: 'Update Progress' });
    }
    
    return availableTasks;
}
```