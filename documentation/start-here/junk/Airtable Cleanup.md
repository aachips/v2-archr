Airtable is like my kitchen. Every view, every filter, every script that someone created for a one time task is another unlabeled mystery jar. Something someone else has to sift through, that nobody can explain or justify. When someone attempts to go on Airtable, they see a crowded cabinet full of mystery jars. Some are useful, most are obsolete and no longer needed. All of them take time to identify, sort through, and decide whether to keep or discard. The system has become a maze, and for many who use it, it means automatic shut down. 

A new perspective. The default should be "delete." Not recklessly, but as the starting assumption. If you can't explain what something is, why it exists, and why you still need it, it should go.

Good tools are labeled and organized. That which stays should be clearly named, documented, and categorized. They should be easy to find and understand. Context matters. Having the habit of labeling or adding a context comment goes a long way. 

```
-- Case export for Grant Application XYZ
-- Requested by: Boss's Boss
-- Date: 2024-07-20
-- Filter: Cases in ZIP code 28804 with status = 'eligible'
-- This is a one-time export for grant reporting.
-- Query will be archived after use.
```

The system is broken, not because the data is bad, but because the organization of the system is bad. Admit it loudly: We have accumulated a lot of one-off solutions, and it's making it harder for others to use the system. We need to clean this up.

The next step is auditing everything. Every Airtable View, every filter, every script/query, every relationship. Does it have a clear name/description? Is it documented? Does it have a purpose comment? Is it still in use? We cannot fix what we cannot understand. 

We can establish a naming convention: 

|Type|Format|Example|
|---|---|---|
|Views|`[Purpose] - [User] - [Date]`|`Income Verification - Finance - Dec 2024`|
|Filters|`[Status] - [Category]`|`Active - Helene Cases`|
|Scripts|`[Function] - [Description]`|`Export - Grant Application XYZ`|
|Queries|`[Purpose] - [Requester] - [Date]`|`Case Export - Boss's Boss - 2024-07-20`|

**Make it easy to understand at a glance.**


### Step 4: Establish a Deletion Policy

|Rule|Applies To|Action|
|---|---|---|
|No clear purpose|Any view/script/filter|Delete|
|No documentation|Any query|Add documentation or delete|
|Created >6 months ago|One-time use items|Archive or delete|
|Created >1 year ago|Everything not explicitly documented|Delete|

**If you can't explain it, you don't need it.**

---

### Step 5: Build for the Future

**When you create something new, ask yourself:**

1. Does this need to be permanent, or is it temporary?
2. If temporary, when will it be deleted?
3. Is there a clear name and description?
4. Is the context documented?
5. Does someone else need to understand this?

**If you can't answer all five questions, don't create it yet.**

---
## Questions to Ask When Cleaning Up

### For Everything You Find

|Question|What It Reveals|
|---|---|
|What is this?|Purpose|
|Why does it exist?|Original need|
|Who uses it?|Stakeholders|
|When was it last used?|Relevance|
|If it disappeared tomorrow, who would notice?|Criticality|

### For Your Boss

|Question|What It Reveals|
|---|---|
|When you build these views, do you ever go back and clean them up?|Habits|
|Is there a way to make this easier for you?|Pain points|
|Do you know what everything in the system does?|Overwhelm|
|Would you like help organizing it?|Openness to change|

### For Your Team

|Question|What It Reveals|
|---|---|
|What's the hardest thing to find in Airtable?|Usability|
|Have you ever been afraid to delete something?|Culture of clutter|
|If you could wave a magic wand, what would you change?|Vision|

---

## The Hard Truth

Nobody created this mess on purpose. It accumulated. One view at a time. One jar at a time. One query at a time.

The people who built it were trying to help. They solved a problem, didn't clean up after themselves, and moved on.

And now we're the ones who have to deal with it.

**Cleaning up the mystery jars is not punishment. It's a gift to your future self.**

---

## A New Mantra

> _"If it doesn't have a name, it's a jar."_

> _"If it doesn't have a date, it's old."_

> _"If nobody knows what it is, it's clutter."_

> _"If we don't need it now, we can let it go."_

---

## The PostgreSQL Difference

sql

-- ================================================
-- Grant Application Export
-- Requested by: Boss's Boss
-- Date: 2024-07-20
-- Purpose: Provide case list for funding application
-- Filter: ZIP = 28804, Status = 'eligible'
-- Frequency: One-time export (will archive after)
-- ================================================
SELECT 
    case_number,
    applicant_name,
    address,
    status,
    submitted_at
FROM intake_submissions
WHERE home_zip = '28804'
  AND submission_status = 'eligible'
ORDER BY submitted_at DESC;



---

## Next Steps

1. **Inventory the current system.** What's in Airtable that nobody uses?
    
2. **Audit everything.** Label, document, or delete.
    
3. **Create a deletion policy.** Decide what stays and what goes.
    
4. **Build new habits.** When you create something, label and document it.
    
5. **Share this perspective.** Help your team understand the "unlabeled jars" problem.
    

---

## Final Thought

The kitchen is getting better. We're labeling the jars we keep, throwing away the ones we can't identify, and building a system that actually works. It takes time. It's not glamorous. But it's better than living with mystery jars forever.

Your Airtable can get better too. One view at a time. One query at a time. One conversation at a time.

**Start today.**