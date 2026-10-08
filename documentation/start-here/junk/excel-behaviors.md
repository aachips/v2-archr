

There was a comment during the meeting that things should behave more like Excel.

I hear you. Excel feels familiar and simple. But imagine trying to manage 200 active cases with 12 people all updating the same file at the same time. That's the reality we're trying to avoid. We're not taking away simplicity. We're building a system that gives you the simplicity of Excel without the Excel nightmare.

Here's a scenario to imagine. You are managing home repairs across multiple organizations. Each case has: 

- Applicant information (name, address, contact, income, household size)
- Assessment details (damage type, scope, photos, measurements)
- Funding sources (which organization pays, how much, remaining balance)
- Work orders (tasks, assignments, completion status)
- Invoices and receipts (subcontractors, materials, labor)
- Communications (emails, phone calls, notes)
- Timeline (submission, assessment, planning, execution, completion)

### Imagine doing all of this in Excel.

Here's ten nightmare horror scenarios of if this was in Excel. 

---

You open the master Excel file. It has 47 columns. You scroll right for 30 seconds to find the "Funding Remaining" column. You scroll down for another 30 seconds to find the case you're looking for.

You realize there are 12 different versions of this file floating around because someone saved "master_v3_final_reallyfinal.xlsx" and emailed it to three people.

**This happens every day.**

<hr>

A new application comes in. You open the master spreadsheet. You find the next empty row. You start typing.

- "Applicant Name" → John Henderson
- "Applicant Address" → 42 Cherry St
- "Applicant City" → Asheville
- "Applicant ZIP" → 28801
- "Applicant Phone" → 828-555-0123
- ...and so on through 47 columns.

You accidentally type the phone number into the "Applicant Income" column because the columns are tiny and you can't see the header. You don't notice until later.

**This happens every day.**

---
Three people are trying to update the same spreadsheet at the same time.

- Person 1 is updating the status of 42-CHERRY.
- Person 2 is adding a new invoice for 15-MERRILL.
- Person 3 is running a report for the funder.

Excel tells Person 2: "File is locked by Person 1. Would you like to open a read-only copy?"

Person 2 says: "I'll just update my local version and merge it later."

They forget to merge it.

**This happens every day.**

---

You accidentally sort the spreadsheet by the wrong column. Now all the case numbers are mismatched with their data. You undo. You undo again. You're not sure if you fixed it.

You close without saving. You reopen. You try to remember what you changed.

**This happens every day.**

---

### The Funder Request

A funder asks: "Can you send us a summary of all cases in ZIP code 28804 with funding from the Helene grant?"

You filter the spreadsheet. You scroll. You copy. You paste into a new sheet. You format. You email it.

The funder replies: "Can you also include the total remaining budget for each case?"

You reopen the spreadsheet. You add a column. You calculate. You reformat. You resend.

The funder replies: "Can you also break it down by repair type?"

You reopen. You filter again. You add more columns. You reformat. You resend.

**This happens every day.**

---

### The Duplicate Problem

You're looking at a case. You think: "Haven't I seen this address before?"

You search the spreadsheet. You find it. Same address. Different applicant name. Different status. One case is "In Progress." The other is "Pending Review."

You have no idea if this is a duplicate or two different people at the same address. You spend 20 minutes emailing people to figure it out.

**This happens every day.**

---

### The Inevitable Mistake

You're updating the status for 42-CHERRY. You click on the wrong row. You update 15-MERRILL instead. You don't notice because the rows look identical and there's no visual distinction.

Two days later, someone asks: "Why is 15-MERRILL marked as complete when the roof hasn't been repaired?"

You go back to the spreadsheet. You realize your mistake. You fix it. But you have to email three people to correct the record.

**This happens every day.**

---

### The Locked File

You need to update a case. Excel says: "File is locked for editing by [Person Who Is Out Sick]."

You can't edit. You can't save. You can't do anything until Person Who Is Out Sick comes back and closes the file.

You email Person Who Is Out Sick. They don't respond because they're sick. You wait.

**This happens every day.**

---

### The Data Loss

Your computer crashes. You haven't saved in 20 minutes. You open Excel. It asks: "Would you like to recover the unsaved file?"

You click yes. You look at the recovered file. It's from two hours ago. You lost 40 minutes of work.

**This happens every day.**

---
### The Version Control Nightmare

You open your email. There are three new versions of the master spreadsheet from three different people.

- "master_v4_updated_by_sarah.xlsx"
    
- "master_v4_updated_by_jamie.xlsx"
    
- "master_v4_final_updates.xlsx"
    

You have to manually compare each one to see what changed. You have to merge them all by hand. You spend two hours doing this every week.

**This happens every week.**

---

Excel is great for one person, one file, one task at a time. It's great for simple lists and calculations, quick reports, personal notes, and one-off calculations.

Excel is terrible for working with multiple people in one file with multiple tasks. It's terrible for relational data with complex connections. Excel requires ongoing operational management, real-time collaboration, audit trails, and daily workflows.

---

**The goal isn't to replicate Excel. The goal is to build something better.**

---

## Why Excel Feels "Easier"

When someone says "I wish it were more like Excel," they're usually saying:

|What They Actually Mean|Not What They Mean|
|---|---|
|"I want to be able to see everything at once"|"I want to use Excel"|
|"I want to be able to sort and filter"|"I want to use Excel"|
|"I want something familiar"|"I want to use Excel"|
|"I want to work the way I already work"|"I want to use Excel"|

**The desire is for simplicity and control. The assumption is that Excel provides that. The reality is different.**

---

## The Excel Paradox

**Excel feels simple at first because you can just start typing.**

There's no setup. No configuration. No learning curve. You open a blank sheet and you start typing.

But that simplicity is deceptive. It works for the first 100 rows. It works for the first 10 columns. It works for the first 3 users.

And then it breaks.

**The complexity doesn't go away. It just gets pushed from the software onto the people.**

|In a Proper System|In Excel|
|---|---|
|The software enforces data integrity|The people have to check their own work|
|The software prevents duplicates|The people have to catch duplicates|
|The software maintains an audit trail|The people have to track changes manually|
|The software handles concurrency|The people have to merge changes manually|
|The software handles relationships|The people have to maintain cross-references manually|

**Excel shifts the burden from the software to the people.**

---

## The Moment That Would Absolutely Break

Let's say we actually ran this operation in Excel.

**The breaking point would be the first time three people tried to update the same file at the same time.**

That's when someone would say: "This is impossible. We need a real system."

And then we'd be right back where we started.

---

## Why Airtable Is Better Than Excel

Airtable is already a huge improvement over Excel:

|Excel|Airtable|
|---|---|
|One user at a time|Multiple concurrent users|
|Manual merging|Automatic syncing|
|No data validation|Field types and validation|
|No relationships|Linked records|
|No audit trail|Change history|
|No views|Multiple views for different users|

**Airtable is not the problem. The front-end is the problem.**

---

## What "More Like Excel" Actually Means

When people say they want it to be more like Excel, they're usually asking for:

1. **Visibility** — see everything in one place
2. **Familiarity** — use something they already know
3. **Control** — feel like they're in charge of their data
4. **Simplicity** — fewer clicks, less friction

**A good front-end can provide all of this without the Excel nightmare.**

## The Store Metaphor, Revisited

Excel is like a warehouse where you have to do everything yourself:

- You haul the boxes
- You organize the shelves
- You keep track of inventory
- You fix mistakes
- You remember where things are

A proper system is like a store:

- The shelves are organized
- The signs are clear
- The staff helps you
- The checkout works
- You don't have to go to the back room

**People don't want Excel. They want a store that works.**
