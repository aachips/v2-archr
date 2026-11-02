
|#|Question|Why It Matters|
|---|---|---|
|1|"How many records are currently in the Progress Tracker base?"|Understands the scale of the problem|
|2|"What's the busiest table in terms of new records?"|Identify where to optimize first|
|3|"How often do you need to look at historical activity vs. recent activity?"|Design the archive strategy|
|4|"Who looks at the Progress Tracker most often?"|Understand user needs|
|5|"What do they typically search for?"|Design the search/indexing strategy|
|6|"Is there any data in the Progress Tracker that you _never_ need?"|Identify data to not migrate|
|7|"Have you ever needed to go back more than 6 months in the log?"|Set retention policy|

### About the Activity Log (New)

|#|Question|Why It Matters|
|---|---|---|
|8|"What are the top 5 actions you want to track?"|Prioritize initial implementation|
|9|"Who should be able to see the Activity Log?"|Design permissions|
|10|"Should Requestors (applicants) see their own activity log?"|Privacy consideration|
|11|"What's the retention policy for activity logs?"|Storage planning|
|12|"Do you need to export the activity log?"|Reporting requirements|

### About the Milestone Tracker

|#|Question|Why It Matters|
|---|---|---|
|13|"What milestones are most important for tracking progress?"|Define the milestone set|
|14|"How should the milestone tracker be displayed?"|UX design|
|15|"Should milestones be tied to the numbered system (phases) or the new submission/application/case/project system?"|Data model alignment|

### About the Transition

|#|Question|Why It Matters|
|---|---|---|
|16|"How do you want to handle the transition from the old Progress Tracker to the new Activity Log?"|Migration planning|
|17|"Can we run both in parallel during the transition?"|Risk management|
|18|"What's the deadline for migrating off the old Airtable Progress Tracker?"|Timeline planning|
### Key Decision Points

1. **Will Activity Log entries live in Airtable?** (Probably not, due to limits)
2. **What's the retention policy?** (6 months? 1 year? Forever?)
3. **Who can see the Activity Log?** (Admins only? Project managers? Everyone?)
4. **How are milestones defined?** (By phase? By role? By application type?)