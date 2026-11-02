## Complete Task-Phase Mapping

|Phase|Task Type|Quick Add Type|docCode|Condition Check|
|---|---|---|---|---|
|**Phase 0: Submission**|Submit Application|-|APP|displaySubmit|
|**Phase 1: Intake**|Create Project Record|-|-|displayClaim|
||Initial Contact|-|-|displayClaim|
||Claim Assessment|CLAIM|-|displayClaim|
||Assign Assessor|-|-|displayClaim|
||Schedule Assessment|-|-|displayClaim|
||Collect Docs|-|-|displayClaim|
|**Phase 2: Processing**|Verify Income|VERIFY|-|displayAssess|
||Verify Ownership|VERIFY|-|displayAssess|
||Perform Assessment|ASSESS|ASSESS_REPORT|displayAssess|
||Create Assessment Report|ASSESS|ASSESS_REPORT|displayAssess|
||Create Repair Task List|-|-|displayAssess|
||Create Project Budget|-|-|displayAssess|
||Define Scope of Work|SCOPE|SCOPE_DOC|displayScope|
|**Phase 3: Planning**|Create Contract|-|CONTRACT|displayScope|
||Sign Contract|START|CONTRACT|displayStart|
||Schedule Project Start|-|-|displayStart|
||Create Materials List|-|-|displayStart|
|**Phase 4: Project**|Start Work|START|WORK_ORDER|displayStart|
||Complete Repair Tasks|PROGRESS|-|displayStart|
||Complete Punch List|PROGRESS|-|displayStart|
||Final Walkthrough|PROGRESS|-|displayStart|
||Sign Completion|COMPLETE|CERTIFICATE|displayComplete|
|**Phase 5: Completion**|Upload After Photos|COMPLETE|FINAL_PHOTOS|displayComplete|
||Record Costs|-|-|displayComplete|
||Complete Draw Request|-|-|displayComplete|
||Job Complete|COMPLETE|CERTIFICATE|displayComplete|