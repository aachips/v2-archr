---
document_name: The Money Trail -- How Do We Track Financial Metrics for Quarterly Reporting and Case Management?
document_type: Speculative Planning Document
version: 1.0
last_updated: 2026-08-06
author: April Chips
audience: Staff involved with ARCHR Platform
complexity_level: Beginner
estimated_reading_minutes: 3
tags: [tasks, logs, events, documentation, SOP]
---

One of the biggest pain points and priorities brought to my attention is around financial tracking. 

We are actively building a practical framework for chaos.

## The Problem, As I Understand It

We have:

- A coalition of organizations doing home repairs
- A central finance/accounting team for each partner organization with their own systems
- A process that relies on spreadsheets, receipts, invoices, and timesheets
- A need to keep track on a project-level of what gets spent, held, or is left for a household we are serving.

What's difficult:

- Finance team doesn't participate in Airtable
- Spreadsheets arrive in various formats
- Receipts, invoices, timesheets come from multiple sources
- Someone (office worker, volunteer) has to manually connect everything
- Duplicate work happens across organizations

The core tension:

> _"Two entities doing the same exact financial work is impractical."_

---
## The Reality

You can't force the finance team to change their system. They have their own processes, their own security requirements, and their own way of working. They will continue to send spreadsheets. They will continue to work in their own tools.

**You need to work with what you have, not what you wish you had.**

---

## A Helpful Mindset

### 1. Treat External Systems as Suppliers, Not Adversaries

The finance team isn't "uncooperative"—they have different priorities, different constraints, and different tools. They're not trying to make your life harder. They're trying to do their job in a system that has its own logic.

**Instead of expecting them to change, design your system to accept their output.**

### 2. Accept That Some Work Will Be Manual

Automation is great. But when you're dealing with external departments, spreadsheets, and legacy systems, some manual work is inevitable.

**The goal isn't zero manual work. The goal is reducing it to the minimum necessary, and making the manual work easy.**

### 3. Think Like a Data Pipeline, Not a Single System

Data flows from one place to another, often in imperfect formats. Your job is to make that flow reliable, consistent, and auditable.

**Design for transformation, not integration.**

---

## Five Practical Habits to Start Now

### Habit 1: Standardize the Spreadsheet Import Process

**Current state:** Finance sends spreadsheets in various formats. Someone has to manually interpret them.

**Better habit:**

|Step|Action|
|---|---|
|1|Create a **blank template** for what you need (columns, formats, naming)|
|2|Send the template to finance: "This is how we'll receive data. You can keep your system, but please export in this format."|
|3|If they won't use your template, **build a conversion script** that maps their columns to yours|
|4|Document the mapping so you can re-run it each month|

**The habit:** One conversion script per finance partner. Never manually reformat the same spreadsheet twice.

---

### Habit 2: Use Case Codes (Placecodes) as the Universal Key

**The problem:** Receipts, invoices, and timesheets come from different sources and need to be connected.

**The solution:** The placecode (e.g., 42-CHERRY) becomes the one consistent identifier across all documents.

|Document Type|Has Placecode?|Need To Add|
|---|---|---|
|Receipts (photos)|❌ No|Add placecode to filename|
|Invoices|⚠️ Maybe|Ensure placecode is in invoice reference|
|Timesheets|⚠️ Maybe|Add placecode to each entry|
|Spreadsheets from finance|❌ No|Add column for placecode|

**The habit:** Every incoming document gets a placecode assigned before it enters your system. Train finance to include it (even as a reference number), or add it yourself as soon as you receive the document.

---

### Habit 3: Create a "Staging Table" for External Data

Instead of trying to merge external spreadsheets directly into your database, create a staging area where you can review, validate, and transform data before importing.

**Structure:**

text

┌─────────────────────────────────────────────────────────────────────────────────┐
│                    DATA PIPELINE                                               │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  1. RECEIVE              2. STAGE               3. VALIDATE         4. IMPORT   │
│  ┌─────────────┐      ┌─────────────┐      ┌─────────────┐      ┌───────────┐ │
│  │ Spreadsheet │ →    │ Staging     │ →    │ Review &    │ →    │ Live      │ │
│  │ from Finance│      │ Table       │      │ Transform   │      │ Database  │ │
│  └─────────────┘      └─────────────┘      └─────────────┘      └───────────┘ │
│                            │                                            │        │
│                            ▼                                            │        │
│                      ┌─────────────┐                                    │        │
│                      │ Issues Log  │                                    │        │
│                      │ (fix later) │                                    │        │
│                      └─────────────┘                                    │        │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘

**The habit:** Never import external data directly. Always stage it, review it, and then import.

---

### Habit 4: Create a "Simple Reporting" Data Mart

Instead of requiring finance to participate in Airtable, build a lightweight, read-only view that they can access without learning the system.

**What this looks like:**

|Element|Description|
|---|---|
|**Read-Only Dashboard**|Finance can view, not edit. It's safe, so security is less of a concern.|
|**Pre-Built Reports**|The reports they need most (case costs by period, funding by source, etc.)|
|**Export to CSV**|They can download data in their preferred format|
|**Weekly Email Digest**|Key numbers sent directly to them|

**The habit:** Make it easier for finance to get what they need from your system than to send you spreadsheets.

---

### Habit 5: Log Everything (Especially the Inconsistent Stuff)

If you have to manually reconcile receipts, invoices, and timesheets, **document what you did.**

|What to Log|Why|
|---|---|
|When you received a spreadsheet|Track timing and delays|
|What you changed|Proof of work|
|What was missing|Flag recurring issues|
|Who you talked to|Follow-up and accountability|

**The habit:** Every manual reconciliation takes < 5 minutes to document. This creates a trail that eventually reveals patterns and automation opportunities.

---

## Bridging the Gap: Specific Suggestions

### Suggestion 1: The "One Big Table" Approach

Instead of trying to link everything automatically, create one master table that tracks case-level finances with a single row per case per month.

**Columns:**

- Case Number
- Month/Year
- Total Receipts (sum)
- Total Invoices (sum)
- Total Timesheets (sum)
- Notes (anything unusual)
    

**How it helps:**

- Finance can review one row per case per month
- You can quickly check if numbers add up
- Discrepancies are easy to spot

**Implementation:**

- Start with last quarter's data manually (15-30 minutes)
- Update monthly (5-10 minutes)
- Look for patterns: which cases are most expensive? Which funding sources are tapped out?

---

### Suggestion 2: The "Staging Table" Alternative

If you can't get finance to use your tools, you can create a lightweight import system using a spreadsheet that you control.

**Columns:**

- A timestamp for when the row was created in your system    
- The case code
- The amount
- The category (receipt/invoice/timesheet)
- The source (which finance sheet)
- The original row ID (to prevent duplicates)
- Notes/Date/Etc.

**How to maintain it:**

1. Keep a "copy" of the finance data (which is the same spreadsheets)
2. Use a script to parse it automatically (or manually, if you can't)
3. Load it into a PostgreSQL staging table    
4. Use the staging table for reporting
    
**How it helps:**

- Once you have the data in a staging table, you can join it with other tables in PostgreSQL
- You can run reports on the staging table (as if it were the main database)
- You don't need to run queries on Airtable or the finance system

**Important:** Make sure the staging table is read-only and can be "recreated" from the source data at any time (e.g., you can drop and recreate it).

---

### Suggestion 3: The "Reconciliation Report" Approach

Instead of trying to integrate finance's data, create a reconciliation report that tracks what's missing.

**What the report shows:**

- Receipts uploaded, but not yet reconciled
- Invoices sent, but not yet paid
- Timesheets submitted, but not yet approved
- Spreadsheets received, but not yet imported

**How it helps:**

- You can see where the gaps are
- You can follow up with finance (or your team) about missing items
- The report itself documents the reconciliation process

**Implementation:**

1. Create a view that shows all receipts, invoices, and timesheets for a given period (this is just a reporting view)
    
2. Create a view that shows what's missing (by comparing finance data with your own records)
    
3. Share the report with finance (it shows them what they need to provide)
    

---

## The Conversation to Have with Finance

Instead of asking finance to join your system, ask them:

> _"We need to track project-level expenses by case code. What's the easiest way for us to get that data from you on a regular basis?"_

**Let them propose the solution.** They'll likely suggest a periodic export (weekly, monthly, quarterly) in a specific format.

**If they propose the format, they'll be more likely to provide it consistently.**

---

## The "Jar" Parallel

The financial data is like the mystery jars in the kitchen:

- Some of it is old and no longer needed
- Some of it is labeled poorly or not at all
- Some of it is essential but hard to find
- Some of it is duplicated in multiple places
    

**The solution is the same:**

1. Label everything clearly (placecodes, dates, categories)
2. Organize what you keep (staging tables, master tables)
3. Throw away what you don't need (archive or delete)
    

---

## Summary: What You Can Do

|Action|Effort|Impact|
|---|---|---|
|Create a blank template for finance exports|Low|High|
|Build a conversion script for each finance partner|Medium|High|
|Use placecodes as the universal key|Low|High|
|Create a staging table for external data|Medium|High|
|Build a reconciliation report|Medium|Medium|
|Make it easy for finance to get what they need|Low|Medium|

---

## Final Thought

You're right—I don't have the answers. But I know this problem is common, and it's not a failure of your team or your partners. It's a failure of the systems we've inherited.

The goal isn't perfection. The goal is reducing the friction.

**Every month, you'll get spreadsheets. Every month, you'll reconcile them. But over time, you'll get faster, more accurate, and less frustrated.**