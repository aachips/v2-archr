Categorizing Events: 

+ ClientEvent
+ ApplicationEvent
+ ~~CaseEvent~~
+ ~~ProjectEvent~~
+ TaskEvent
+ RepairEvent - Claim, Mark 'Need Met', Edit/Update/Delete
+ ~~MilestoneEvent~~
+ DocumentEvent
+ CommunicationEvent
+ ScheduleEvent

### MilestoneEvent

 ✅PreScreening Complete! - client.application[current].case[current].eligibility[] is not empty
⚒️Repair 🪝Claimed! - client.application[current].case[current].claims is not empty
👤Application 🪝Claimed! - client.application[current].requests[].needs[].orgClaimed is not empty for all "requests[]" and "requests[].needs[]"
👤Application  → 💼Case Opened! - client.application[current].claims[] is not empty
📞Contact Made! - client.application[current].case[current].communication[] contains "outcome":"success"
🔍Assessment Completed! - client.application[current].case[current].assessment.report
💼Case → 🎯Project Created! - client.application[current].case[current].project[current]
🎯Project 🕰️Timeline Set!
🎯Project 💲Budget Determined! - client.application[current].case[current].project[current].cost.est
📜Contract ✒️Signed! - "client.application[current].case[current].project[current].tasks[].task.duration is not null for for each ""tasks[]"" array item 
AND
client.application[current].case[current].dates[] contains ""type:""projectStart"""client.application[current].case[current].documents.project[current].prj.con.evt.sig
📋Final Walkthrough Performed! - client.application[current].case[current].dates[] contains "type:"finalWalk"
📜Certificate of Completion Signed! - client.application[current].case[current].documents.project[current].prj.coc.evt.sig
💸Draw Request Submitted! - client.application[current].case[current].project[current].draw.status = "submitted"

👊Punch List Created! - client.application[current].case[current].project[current].punchlist[] is not empty
🛒Materials List Created! - client.application[current].case[current].project[current].materials[] is not empty

### CaseEvent

Assign 💛 Program - client.application[current].case[current].project[current].program.Id
📎Proof of Income Collected! - client.application[current].case[current].documents.poi
📎Ownership Documentation Collected! - client.application[current].case[current].documents.own
💛Program Specific 📎Documents Uploaded! - client.application[current].case[current].documents.xtr.prog[selectedProgram]
Assign 💰Funding Source - client.application[current].case[current].project[current].program.funder.Id
📎Proof of Income ✔️Verified! - client.application[current].case[current].documents.poi.evt.ver
📎Ownership Documentation✔️Verified! - client.application[current].case[current].documents.own.evt.ver
🔍Assessment 📷Photos Uploaded! - client.application[current].case[current].photos[] contains "type:"assessment"

### ProjectEvent

📜Contract 🪄Generated!	- client.application[current].case[current].documents.project[current].prj.con
🔶Task List Created!	client.application[current].case[current].project[current].tasks[] is not empty
💪Labor Group Selected!	client.application[current].case[current].project[current].labor[] is not empty
📜Contract ❌Rejected!	client.application[current].case[current].documents.project[current].prj.con.evt.rej
🧰Work Crew Assigned!	client.application[current].case[current].project[current].labor[] contains "type":"workcrew"
🔨Volunteer Slots Set!	client.application[current].case[current].project[current].labor[] contains "type":"volunteer"
📜Contract 👍Approved!	client.application[current].case[current].documents.project[current].prj.con.evt.app
🚚Subcontractor Assigned!	client.application[current].case[current].project[current].labor[] contains "type":"volunteer"
📙Scope Of Work 📎Change Order Created!	client.application[current].case[current].documents.project[current].prj.cor
🚚Subcontractor 📎Estimate Uploaded!	client.application[current].case[current].documents.project[current].sub[].est
🚚Subcontractor 📎Estimate 👍Approved!	client.application[current].case[current].documents.project[current].sub[].est.evt.app
🚚Subcontractor 📎Estimate ❌Rejected!	client.application[current].case[current].documents.project[current].sub[].est.evt.rej
📙Scope Of Work 📎Change Order Signed!	client.application[current].case[current].documents.project[current].prj.cor.evt.sig
🚚Subcontractor 📎Change Order Created!	client.application[current].case[current].documents.project[current].sub[].sco
🚚Subcontractor 📎Change Order 👍Approved!	client.application[current].case[current].documents.project[current].sub[].sco[current].evt.app
🚚Subcontractor 📎Change Order ❌Rejected!	client.application[current].case[current].documents.project[current].sub[].sco[current].evt.rej
After 📷Photos Uploaded!	client.application[current].case[current].project[current].photos[] contains "type:"after"
Progress 📷Photos Uploaded!	client.application[current].case[current].project[current].photos[] contains "type:"progress"