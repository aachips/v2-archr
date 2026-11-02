I am taking notes going through the current Progress Tracker on Airtable. There are 41 tables, some of which I have no idea how to make sense of.

### Sync  
This appears to be a table with a bunch of concurrent primary keys, tying this system to many other systems and tables. There are tons of views. The primary key seems to be anchor project record IDs. So you have 1607 rows each with different application records. And on each of these, the progress is being tracked on. They have different Status Labels demarkating the status of this application. Each of these is paired with an emoji. 

"✅", "✅Project Completed", 
"⏸", "⏸Paused",
"⚙️", "⚙️Active "&IF({⚙️Phase}, {⚙️PhaseLabel}, "[Phase Unknown]"), 
"❓", "❓Unclaimed", 
"❌", "❌Ineligible/Withdrawn")

This appears to be the master table within the Progress Tracker, seeing where each application that lives on this system is at currently. There is a column for when a given application was screened, the problem is that a bunch of them are marked 4/28/2026. This would be literally impossible, as hundreds of cases have this Screened Date. If this was true, hundreds of cases would have had to be screened the week before I started working.

There are a bunch of Unnamed Events in one column, and when I go to look at more information, these may be things such as 'Application Submitted' or 'Case Claimed', or 'Application Paused'. Here's a list from Progress Tasks which has a complete list of different possible events for a Record in the phases between Submission, Application, Case, Project, and Completion.

0. Submission: Application Ineligible
1. Submission: Application Paused
2. Submission: Application Submitted
3. Submission: Application Withdrawn
4. Submission: Check Helene Related
5. Submission: Demographic Check
6. Submission: GIS Check
7. Submission: Income Check
8. Submission: Location Check
9. Intake: ✅Eligibility Check Performed
10. Intake: 🎯Project Record Created
11. Intake: Assign Assessor
12. Intake: Claim Assessment
13. Intake: Collect Income Documents
14. Intake: Collect Ownership Documents
15. Intake: Initial Contact
16. Intake: Phase 1 Complete
17. Intake: Schedule Assessment
18. Processing: Collect Program Specific Paperwork
19. Processing: Confirm Eligibility
20. Processing: Create Assessment Report
21. Processing: Assign Funding Source
22. Processing: Create Project Scope of Work
23. Processing: Create Repair Task List
24. Processing: Determine Labor Pool
25. Processing: Determine Project Budget
26. Processing: Determine Volunteer Slots
27. Processing: Perform Assessment
28. Processing: Phase 2 Complete
29. Processing: Schedule Subcontractor Estimate
30. Processing: Upload Before Photos
31. Processing: Upload Subcontractor Estimate
32. Processing: Verify Income Documents
33. Processing: Verify Ownership Documents
34. Planning: Approve Contract
35. Planning: Approve Subcontractor Estimate
36. Planning: Assign Subcontractor
37. Planning: Assign Volunteer Groups
38. Planning: Assign Work Crew
39. Planning: Create Contract
40. Planning: Create Initial Materiasl List
41. Planning: Determine Project Timeline
42. Planning: Phase 3 Complete
43. Planning: Reject Contract
44. Planning: Reject Subcontractor Estimate
45. Planning: Schedule Contract Signing
46. Planning: Schedule Project Start
47. Planning: Schedule Subcontractor Start
48. Planning: Sign Contract
49. Project:  Assign Tomorrow Volunteers
50. Project: Approve Subcontractor Invoice
51. Project: Assign Vehicle Drivers
52. Project: Check Supplies Stock
53. Project: Code Receipts
54. Project: Complete Project Repair Tasks
55. Project: Complete Punch List
56. Project: Create Scope of Work Change Order
57. Project: Create Subcontractor Change Order
58. Project: Determine Equipment Needs
59. Project: Determine Jobsite Hazards
60. Project: Determine Tomorrow Materials Needs
61. Project: Determine Tomorrow Weather Needs
62. Project: Fill Timesheet
63. Project: Initial Material Run
64. Project: Material Run
65. Project: Perform Final Walkthrough
66. Project: Phase 4 Complete
67. Project: Record Progress Notes
68. Project: Resupply Run
69. Project: Safety Talk
70. Project: Sign Completion
71. Project: Sign In Volunteers
72. Project: Update Project Timeline
73. Project: Upload After Photos
74. Project: Upload Progress Photos
75. Report: Complete ARCHR Draw Request Workbook
76. Report: Phase 5 Complete
77. Report: Record Actual Labor Expenses
78. Report: Record Actual Material Expenses
79. Report: Record Actual Subcontractor Expenses

+ Check Out
+ Claim
+ Communication Log Event
+ Contact Attempt
+ Contact Made








### People and Organizations

The Progress Tracker has tables for Organizations and People, of whom are working on Home Repairs. 


Placecode as main storage of events. Possibly instead of client use PlaceCode.


Punchlist - add completion walkthrough. Touching up paint. Removing tape. Finishing touches. Site supervisor at very end of the project. 

Client vs Placecode distinction

Event Definition: 

State Mutator for Objects. The thing that changes the object as things happen. Knowing that a task has been completed and controls available interactions in UI. 

If we don't have a clear definition of state, Pinia won't have anything to work with. 

State Declarations. 

Resolvers and Emitters. 
Emitters - 

Event:
Date:
User: 
Key: 
Type::

CRUD Events:


PR



[Client, Application, Case]


Necessary Clarity:
Defining Events


Defining Tasks.
Standardized - Completing a Repair Task (standard) vs Replacing the Toilet (contextual)

Sufficient Filtering

Filter feed by organization

Task Library/Multi-Access Task Library

Multi axis task library - list of home repair tasks with axial robot processing

Office / Case Task vs Project / Site Task

Signing Office Contract? Happens on site but is office task. Mitigate confusion. 

Make buttons different colors - Orange on the Ground. Purple = something to do with filing cabinet. 

Holding Area - Task Rabbit Human Review Area