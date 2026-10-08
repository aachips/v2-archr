---
document_name: Financial Management — Budgets, Invoices & Payments SOP
document_type: Standard Operating Procedure
version: 1.0
last_updated: 2026-09-07
author: ARCHR Development Team
audience: Bursars, Admins, Project Managers
complexity_level: Advanced
estimated_reading_minutes: 12
tags: [finance, budget, invoices, grants, audit, SOP]
visibility: authenticated
---

# Financial Management: Budgets, Invoices & Payments

> **Who this is for:** Bursars managing case finances, Admins overseeing budgets, and Project Managers tracking project costs.

## Why This Is Crucial

Grant compliance requires meticulous financial tracking. Errors here can cost funding — and when a funder pulls out, it doesn't just affect one case. It affects every household waiting for help.

**Money is the fuel.** Without it, nothing moves. With it mismanaged, everything crashes.

---

## Understanding Case Budgets

### Where the Money Comes From

Before any repair work starts, funding is secured from:
- **Grants** — Cisco, Land of Sky, Dogwood Trust, City Funds, VOAD partners
- **Donations** — individual, corporate, church groups
- **In-kind contributions** — donated materials, volunteer hours (these count!)
- **Insurance payouts** — when the household has applicable coverage

**The money flows like this:**
```
Funder → Organization Account → Project Budget → Subcontractor/Vendor Payment
```

Each step needs documentation. No step can be skipped.

### Case Budget Structure

Each project within a case has:
- **Budgeted amount** — what was approved for this scope of work
- **Expensed amount** — what's actually been spent
- **Remaining balance** — budget minus expenses

> **Rule:** Expenses cannot exceed the budget without a documented and approved change order. If a project runs over, someone needs to approve where the extra money comes from.

---

## Processing Subcontractor Invoices

### Step-by-Step

1. **Receive the invoice** — from the subcontractor, for work completed
2. **Match to tasks** — which repair tasks does this invoice cover?
3. **Verify completion** — are those tasks marked Complete in the system with photos?
4. **Check the amount** — does it match the quoted/contracted amount?
5. **Log the expense** — enter the invoice amount against the project budget
6. **Upload the invoice** — attach to the case document record
7. **Submit for approval** — PM or Admin approves the payment
8. **Process payment** — bursar issues payment per organizational process
9. **Record the payment** — note payment date, amount, method in the system

### Invoice Red Flags

| Red Flag | What It Means | Action |
|----------|--------------|--------|
| **Amount exceeds quote** | Sub billed more than agreed | Contact sub for explanation before approving |
| **No supporting documentation** | No receipts, no timesheets | Request documentation before processing |
| **Tasks not marked complete** | Billing for unfinished work | Verify completion before paying |
| **Duplicate invoice** | Same work billed twice | Check case history for prior payments |
| **Unapproved change work** | Work outside the scope | Requires change order approval first |

---

## Tracking Expenses Against Grant Restrictions

### Grant Money Comes with Rules

Different grants have different restrictions:
- **Capping per household** — e.g., maximum $50,000 per household
- **Eligible expenses** — some funders only cover materials, not labor
- **Geographic limits** — money can only be spent in certain counties
- **Time limits** — funds must be spent by a certain date
- **Matching requirements** — organization must contribute a percentage

**The bursar's job:** Make sure every expense complies with all applicable restrictions.

### How to Track

1. **Tag each expense** with the funding source it draws from
2. **Monitor caps** — track total spent per household against the cap
3. **Check eligibility** — is this expense covered by the tagged funder?
4. **Watch deadlines** — are funds expiring soon?
5. **Calculate match** — are we meeting matching requirements?

> **When in doubt, over-document.** An expense with too much documentation is never a problem. An expense with too little is an audit finding.

---

## Handling Denied or Partial Payments

### When a Subcontractor's Invoice Is Denied

1. **Document the reason** — why was it denied? (incomplete work, over-billing, missing docs)
2. **Notify the subcontractor** — explain what's needed to resolve
3. **Log the denial** — in the case financial record, note the denied invoice and reason
4. **Track the resolution** — when the sub provides what's needed, re-process

### When Only Partial Payment Is Approved

1. **Pay the approved amount** — process the portion that's valid
2. **Document the reduction** — note why the full amount wasn't approved
3. **Notify the subcontractor** — explain the partial payment and what's needed for the remainder
4. **Keep the invoice open** — until fully resolved

---

## Generating Financial Reports

### For Grant Reporting

Funders typically need:
- **Total spent** — how much of their grant has been used
- **Cases served** — how many households benefited
- **Average cost per case** — total spent ÷ number of cases
- **Expense breakdown** — by category (materials, labor, admin)
- **Geographic distribution** — where was the money spent?
- **Timeline** — when was money spent?

**The platform should generate these reports from case data.** If it doesn't, the bursar compiles them manually from the financial records.

### For Internal Use

- **Budget vs. actual** — per project and per organization
- **Outstanding payables** — what invoices are waiting for payment?
- **Funding availability** — how much money is still available to spend?
- **Volunteer hour value** — volunteer hours × reasonable hourly rate = in-kind contribution

---

## The Audit Trail: What Gets Logged and Why

### Every Financial Action Is Logged

| Action | What's Logged | Why |
|--------|--------------|-----|
| Invoice created | Amount, vendor, case, date | Proof of obligation |
| Invoice approved | Approver, date, any notes | Chain of authorization |
| Payment made | Amount, date, method, reference | Proof of payment |
| Budget adjusted | Old amount, new amount, reason, approver | Change documentation |
| Expense denied | Reason, denied by, date | Decision record |
| Refund issued | Amount, reason, recipient | Reversal documentation |

**The immutable activity log records all of this automatically.** You can't delete a financial entry — you can only add a correcting entry. This is by design.

### What Auditors Look For

- **Matching amounts** — invoice = approved amount = payment amount
- **Supporting docs** — every expense has a receipt or invoice
- **Proper authorization** — someone approved each payment
- **Timely recording** — expenses logged when they occurred, not added later
- **Budget compliance** — no over-spending without documented approval

> **Audit tip:** If an auditor asks "why did you do it this way?" the answer "because that's how the system works" is much stronger when the system has been doing it right from the start.

---

## Common Financial Scenarios

### Scenario 1: Project Goes Over Budget
The assessment estimated $3,000 for roof repair. The actual cost is $4,500 because the damage was worse than expected.

**Process:**
1. PM creates a change order documenting the additional cost
2. Admin approves the change order (confirming funding is available)
3. Project budget is increased
4. Additional funding source is tagged if needed
5. Expense is logged against the new budget

### Scenario 2: Two Funders, One Case
A household qualifies for both Cisco funding and a local church grant.

**Process:**
1. Tag expenses to specific funders (e.g., materials from Cisco, labor from church)
2. Track each funder's cap separately
3. Report to each funder only on their portion
4. Ensure no double-counting of expenses

### Scenario 3: Volunteer Labor as In-Kind Contribution
A volunteer team spends 40 hours on a case. Their labor has value.

**Process:**
1. Log volunteer hours against the case tasks
2. Apply a reasonable hourly rate (e.g., $25/hr for general labor)
3. Record the in-kind value ($1,000) in the case financial record
4. Report to funders as in-kind contribution (many funders count this toward matching requirements)

---

## Quick Reference

| Action | Where | Who |
|--------|-------|-----|
| View case budget | Case detail → Financial tab | Everyone |
| Log expense | Case detail → "Add Expense" | Bursar, PM |
| Upload invoice | Case detail → Documents | Anyone |
| Approve payment | Case detail → Financial → "Approve" | PM, Admin |
| Process payment | Financial module → "Pay Invoice" | Bursar |
| Generate report | Reports → Financial | Bursar, Admin |
| Adjust budget | Project detail → "Change Order" | PM, Admin |
| View audit trail | Case detail → Activity Log | Everyone |

---

**Remember:** Every dollar spent is a dollar donated by someone who believes in this work. Treat it like the trust it represents.
