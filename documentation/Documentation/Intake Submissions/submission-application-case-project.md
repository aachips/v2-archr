 Let's say one application, has two repair needs. They fulfill eligibility with two different partners. One partner claims one repair need, another claims the other. Two cases are created. They share documents, as those live on the application layer. Specific validation (under maximum income) are case-specific. So both organizations need to verify income, but they can use the same documents attached to the application. Project is a list of repair tasks. Becomes a project once a repair task is created. Project is a child object of the Case, with specific Repairs, Repair Costs, Timeline, Subcontractors Used, After Photos, Invoices.

Submission = plain text form response. could have multiple for a single application. Could be error could be someone adding another thing. 

Application - Normalized de-duplicated single entry that owns all of the repair needs, and has a placecode. Contains: Submissions, Dates, Notes, Documents, Photos, Eligibility Reports, Logged Communications, Assessments, Repair Needs, Claims, Cases, Projects, Scopes of Work, Repair Tasks

Placeholder question

Case - Data tied to organization via a claim. Owns projects, and claims, and repair needs related to what was claimed.

Amanda - Raw data is really important to me see exactly what is on submission. easy cnosistent access - Purple view very difficult to get all of the infomr

Adjusting Scope in Application in Shared Projects/ Multiple Subs