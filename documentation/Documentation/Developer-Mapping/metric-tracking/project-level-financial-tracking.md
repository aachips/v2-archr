When you look up case - not sure when some of that 50,000 has been used. Assume that money is there, but may not be the case. Chart or field with remaining ARCHR funds available. If CHC submits invoice for 20,000. Start broad. Track basic invoicing details for what has been spent by who. Use tracking sheet with Habitat. 

[Feedback from Community Housing Coalition - Madison](sc_feedback.md)

For Bursar role on dashboard, job would be to make sure this information is accounted for and up to date. Way to hold money until it's billed. More clarity on what's been spent. How to define a claim?

Is it 50,000 per project cap or per home cap. Technically per home per disaster repair. 

That information would be reflected on Case View, not on dashboard view. 
We have a schema that is compatible with this through project-level-finance.sql

Currently we are missing data visibility for project-level financial tracking. Funding metric tracking for organizations, funders, and region breakdowns is important, but not the entire scope of necessary financial tracking.

In this document we are looking at necessary additions for project-level financial tracking. For [Organizational Metrics for Funders, please click here](metric-tracking-goals-reverse-engineer.md).

One of our stakeholders brought up that we can't see funding attached to the client. What does this entail?:

+ Who pays what?
+ Who owes what?
+ Who's been reimbursed?
+ Who claims what?

Here's a list of project-level financial metrics, organized by the questions they answer:

## "Who Owes Whom What, and Has It Been Paid?"

|Question|Metric|Definition|
|---|---|---|
|How much has been approved for this repair?|**Approved funding amount**|Total funds allocated to a specific case from all sources (Habitat, grants, other orgs)|
|How much has actually been spent?|**Actual incurred costs**|Sum of invoices, materials, labor already billed|
|How much has been reimbursed?|**Reimbursed amount**|Funds already paid out to contractors or partners|
|What's still owed?|**Outstanding balance**|Approved - (Reimbursed + Incurred but not yet claimed)|
|Who approved which portion?|**Funding source breakdown**|By grant, by organization, by funding category|
|Is there duplicate funding?|**Duplicate assignment flag**|Same repair claimed by two orgs, or same cost claimed twice|

---

## Project-Level Financial Metrics (Full List)

### Category A: Per-Case Funding Status

|#|Metric|Definition|Why It Matters|
|---|---|---|---|
|A1|Total approved per case|Sum of all funding commitments (all sources)|Know your ceiling|
|A2|Total incurred per case|Actual costs accrued (invoices, labor, materials)|Track spending against approval|
|A3|Total reimbursed per case|Payments already issued|Cash flow tracking|
|A4|Outstanding balance per case|Approved - Reimbursed|What's left to pay|
|A5|Pending reimbursement requests|Submitted but not yet paid|Workflow bottleneck|
|A6|Aging of reimbursement requests|Days since submitted|Measure processing speed|

### Category B: Funding Source Breakdown

|#|Metric|Definition|Why It Matters|
|---|---|---|---|
|B1|Funding source by case|Which grant/org is paying for which portion|Don't mix restricted funds|
|B2|Unmatched costs|Expenses not yet assigned to a funding source|Risk of unfunded work|
|B3|Cost share / match amount|Portion covered by homeowner or other non-grant sources|Grant compliance|
|B4|In-kind contributions|Volunteer hours, donated materials, waived fees|Match reporting|

### Category C: Duplicate & Overlap Detection

|#|Metric|Definition|Why It Matters|
|---|---|---|---|
|C1|Duplicate case flag|Same address/property appears in system twice|Prevent double-serving|
|C2|Overlapping funding flag|Same repair cost claimed to two different funders|Fraud prevention|
|C3|Cross-org duplicate assignment|Two organizations working on same property simultaneously|Coordination failure|
|C4|Claim lock status|Whether a case is currently "claimed" by an org|Prevent double work|

### Category D: Reimbursement Workflow

|#|Metric|Definition|Why It Matters|
|---|---|---|---|
|D1|Reimbursement requests submitted|Count by period|Volume tracking|
|D2|Average reimbursement processing time|Days from submission to payment|Partner satisfaction|
|D3|Reimbursement approval rate|% approved vs. denied/resubmitted|Quality of documentation|
|D4|Most common denial reasons|Categorized reasons (missing receipt, wrong amount, etc.)|Training opportunity|
|D5|Reimbursement by funding source|Breakdown of requests by which grant/org is paying|Ensure funders pay their share|

### Category E: Budget vs. Actual (Per Project)

|#|Metric|Definition|Why It Matters|
|---|---|---|---|
|E1|Estimated vs. actual cost|(Actual - Estimate) / Estimate|Accuracy of assessment|
|E2|Cost overrun flag|Actual > Approved|Alert for management|
|E3|Change order count|Number of scope changes|Project complexity|
|E4|Cost per square foot (if applicable)|Normalized cost metric|Benchmarking|

### Category F: Partner & Contractor Financial Tracking

|#|Metric|Definition|Why It Matters|
|---|---|---|---|
|F1|Contractor payment status|Paid, pending, disputed|Don't owe contractors|
|F2|Outstanding by partner|What each org is owed or owes|Inter-org settlements|
|F3|Partner aging report|How long each partner has been waiting for reimbursement|Don't strain relationships|

### Category G: Funder-Specific Reporting (The "Ask" View)

|#|Metric|Definition|Why It Matters|
|---|---|---|---|
|G1|Funds drawn vs. committed|% of grant already spent|Don't leave money on table|
|G2|Match requirement status|Met or unmet|Compliance|
|G3|Eligible vs. ineligible costs|What the funder will/won't pay|Avoid unallowable charges|
|G4|Reporting period actuals|Costs incurred in this grant period|Timely claiming|

---

## How These Map to User Feedback

|Feedback from Partner|Related Metric|What's Missing Now|
|---|---|---|
|"Can't see funding attached to client"|A1, A2, A3, B1|No funding view per case|
|"Need to track reimbursement"|A5, A6, D1-D5|No reimbursement workflow|
|"Failsafe for claiming a case"|C4, C1|No locking mechanism|
|"Don't know who's on first" (duplicate outreach)|C2, C3|No overlap detection|
|"Have to pay for it if already claimed"|C4|No claim lock|

---

[SQL-Friendly Schema Additions (What You'd Need to Track)](project-level-finance.sql)




---

+ Review document with boss. Ask: "Which of these are most urgent for partners?"
+ Pick 3-5 metrics to prototype first
+ Document where each piece of data currently lives (or doesn't)
+ Build a simple 'funding view' for a single case'
+ Iterate. Then scale.

---

## For Boss

**Subject:** Project-Level Financial Metrics We Need to Track

**Current gap:** We track organizational metrics (total jobs, avg cost, income breakdown) but not project-level financials. Partners can't see funding attached to cases, track reimbursements, or know if a case is already claimed.

**Proposed metrics (MVP for next quarter):**

|Priority|Metric|What We Need|
|---|---|---|
|P0|Total approved per case|Add funding table linked to cases|
|P0|Outstanding balance|Approved - reimbursed|
|P0|Case lock / claimed status|Simple flag: who owns this case?|
|P1|Reimbursement aging|Days from submission to payment|
|P1|Funding source breakdown|By grant, by org|
|P2|Duplicate assignment detection|Same address, different orgs|

**Next step:** Meet for 30 minutes to review the full list and pick our top 3 to build.

---

You're right to shift focus. Funders want to know _how many homes_. Partners want to know _who pays for this repair and when do I get my money back_. Both matter. But right now, you're missing the second. This list fills that gap.