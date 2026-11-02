---
document_name: BURSAR_DASHBOARD_TECHNICAL_PLAN_v1
document_type: Technical Specification
version: 1.0
last_updated: 2024-12-17
author: ARCHR Development Team
contributors: Product Owner, Finance Team, Database Architect
status: Draft for Review
review_date: 2024-12-20
audience: Developers, Database Administrators, Bursars
complexity_level: Advanced
estimated_reading_minutes: 25
tags: [bursar, financial-tracking, reimbursement, claims, project-level-finance]
---
### Problem

As identified in stakeholder feedback:

- **"Can't see funding attached to client"** - No visibility into per-case funding
- **"Don't know who's on first"** - Duplicate outreach, no case locking
- **"No failsafe for claiming a case"** - Two orgs can claim same client
- **"Need to track reimbursement"** - No workflow for invoicing/payment
### Solution

A Bursar dashboard that provides real-time visibility into:

1. **Per-case funding status** - Approved, spent, remaining, outstanding
2. **Reimbursement workflow** - Submit, approve, pay, track
3. **Claim locking** - Prevent duplicate assignments
4. **Funding source tracking** - By grant, by organization, by case
### The Constraint

Each eligible household is capped at **$50,000** for disaster-related repairs. The Bursar must be able to track:

- How much has been approved
- How much has been spent (incurred)
- How much has been reimbursed (paid out)
- What's remaining
- What's on hold (pending approval, pending documentation)

## User Role: Bursar

### Definition

**Bursar** manages financial tracking, payments, invoicing, and funding reconciliation for the ARCHR coalition.

### Primary Responsibilities

| Responsibility                    | Description                                        | Frequency |
| --------------------------------- | -------------------------------------------------- | --------- |
| **Case Funding Oversight**        | Track approved vs. spent vs. remaining per case    | Daily     |
| **Reimbursement Processing**      | Review and approve subcontractor/partner invoices  | Weekly    |
| **Funding Source Reconciliation** | Ensure costs are attributed to correct grants/orgs | Monthly   |
| **Duplicate Prevention**          | Flag and resolve overlapping claims                | Ongoing   |
| **Reporting**                     | Provide funder reports, audit trails               | Quarterly |

### Pain Points (From Feedback)

| Pain Point                              | Translation                                          |
| --------------------------------------- | ---------------------------------------------------- |
| "Can't see funding attached to client"  | Need per-case funding view                           |
| "Failsafe for claiming a case"          | Need case locking mechanism                          |
| "Don't know who's on first"             | Need visibility into which org is working which case |
| "Have to pay for it if already claimed" | Need to prevent duplicate claims                     |

---


---

## Technical Requirements

### Requirement 1: Per-Case Funding View

**User Story:** As a Bursar, I want to see the complete funding picture for each case so I can track approved vs. spent vs. remaining.

**Data Requirements:**

|Field|Type|Source|Definition|
|---|---|---|---|
|`case_id`|UUID|`cases`|Case identifier|
|`approved_amount`|DECIMAL(12,2)|`case_funding`|Total funding approved (all sources)|
|`incurred_amount`|DECIMAL(12,2)|`invoices`, `work_orders`|Actual costs accrued|
|`reimbursed_amount`|DECIMAL(12,2)|`invoices` (paid)|Payments already issued|
|`outstanding_balance`|DECIMAL(12,2)|Calculated: approved - reimbursed|What's left to pay|
|`pending_reimbursement`|DECIMAL(12,2)|`invoices` (pending)|Submitted but not paid|
|`on_hold_amount`|DECIMAL(12,2)|`case_funding` (hold status)|Funds set aside, not yet approved|
|`remaining_available`|DECIMAL(12,2)|Calculated: approved - incurred|What's left to spend|

**Business Rules:**

- Total per case cannot exceed $50,000
- Warning flag if incurred > approved
- Warning flag if approved + pending_approval > $50,000
- Block new invoices if approved >= $50,000



## User Interface Requirements

### Dashboard Component Specifications

|Component|Type|Data Source|Refresh|
|---|---|---|---|
|**Funding Overview**|4 KPI Cards|`case_funding_summary`|Real-time|
|**Active Cases with Funding**|Table|`case_funding_summary`|Real-time|
|**Reimbursement Workflow**|Status List|`reimbursement_aging`|Real-time|
|**Funding Source Breakdown**|Chart|`funding_source_summary`|Daily|
|**Duplicate Alerts**|Alert List|`duplicate_case_alerts`|Hourly|

### Page Navigation

|Page|URL|Purpose|
|---|---|---|
|Bursar Dashboard|`/bursar/dashboard`|Main landing with all metrics|
|Case Funding Detail|`/bursar/case/:caseId`|Per-case funding breakdown|
|Reimbursement Queue|`/bursar/reimbursements`|All pending invoices|
|Reimbursement Review|`/bursar/reimbursements/:id`|Single invoice review|
|Funding Sources|`/bursar/funding-sources`|Manage grants/orgs|
|Duplicate Review|`/bursar/duplicates`|Investigate flagged cases|

### Bursar Dashboard HTML Wireframe

html

<!-- Key sections for Bursar dashboard -->
<!-- 1. Funding Overview KPI Cards -->
<div class="kpi-grid">
    <div class="kpi kpi-blue">
        <span class="kpi-label">Total Approved</span>
        <span class="kpi-value">$2,400,000</span>
        <span class="kpi-sub">Across 48 active cases</span>
    </div>
    <div class="kpi kpi-amber">
        <span class="kpi-label">Pending Reimbursement</span>
        <span class="kpi-value">$350,000</span>
        <span class="kpi-sub">14 invoices awaiting review</span>
    </div>
    <div class="kpi kpi-green">
        <span class="kpi-label">Reimbursed to Date</span>
        <span class="kpi-value">$1,850,000</span>
        <span class="kpi-sub">92% of approved funds</span>
    </div>
    <div class="kpi kpi-red">
        <span class="kpi-label">On Hold</span>
        <span class="kpi-value">$125,000</span>
        <span class="kpi-sub">5 cases with holds</span>
    </div>
</div>
<!-- 2. Active Cases with Funding -->
<div class="panel">
    <div class="panel-header">
        <h3><i class="fas fa-file-invoice-dollar"></i> Active Cases with Funding</h3>
        <a href="/bursar/cases" class="view-all">View All →</a>
    </div>
    <table class="case-funding-table">
        <thead>
            <tr>
                <th>Case #</th>
                <th>Organization</th>
                <th>Approved</th>
                <th>Incurred</th>
                <th>Remaining</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><strong>ARCHR-2024-001234</strong></td>
                <td>Habitat for Humanity</td>
                <td>$45,000</td>
                <td>$12,000</td>
                <td>$33,000</td>
                <td><span class="pill pill-amber">⚠️ Pending Docs</span></td>
            </tr>
            <!-- More rows -->
        </tbody>
    </table>
</div>
<!-- 3. Reimbursement Workflow -->
<div class="panel">
    <div class="panel-header">
        <h3><i class="fas fa-clock-rotate-left"></i> Reimbursement Queue</h3>
        <a href="/bursar/reimbursements" class="view-all">Process Invoices →</a>
    </div>
    <div class="reimbursement-stats">
        <div class="stat">Pending: 8</div>
        <div class="stat">Ready for Review: 4</div>
        <div class="stat">Overdue: 2</div>
    </div>
    <div class="reimbursement-list">
        <!-- List of pending invoices -->
    </div>
</div>

---

## API Requirements


### API Response Examples

json

// GET /api/bursar/funding-overview
{
    "total_approved": 2400000.00,
    "pending_reimbursement": 350000.00,
    "reimbursed_to_date": 1850000.00,
    "on_hold_amount": 125000.00,
    "active_cases": 48,
    "over_cap_cases": 2,
    "funding_by_source": [
        {"source": "Habitat Grant", "amount": 850000.00, "remaining": 150000.00},
        {"source": "FEMA", "amount": 600000.00, "remaining": 20000.00},
        {"source": "State Grant", "amount": 550000.00, "remaining": 50000.00},
        {"source": "Donations", "amount": 400000.00, "remaining": 100000.00}
    ]
}
// GET /api/bursar/cases/funding?status=active&limit=20
{
    "cases": [
        {
            "case_id": "550e8400-e29b-41d4-a716-446655440000",
            "case_number": "ARCHR-2024-001234",
            "organization": "Habitat for Humanity",
            "approved_amount": 45000.00,
            "incurred_amount": 12000.00,
            "remaining_amount": 33000.00,
            "cap_status": "UNDER_CAP",
            "has_hold": false,
            "claiming_org": "Habitat for Humanity",
            "duplicate_flag": false
        }
    ]
}

---

## Data Migration Requirements

### From Existing Systems

|Source|What to Migrate|Priority|
|---|---|---|
|**Airtable**|Funding allocations per case|High|
|**Podio**|Case notes, contractor info|Medium|
|**Spreadsheets**|Invoice data, grant info|High|
|**QuickBooks/Accounting**|Payment records|High|

### Migration Steps

1. **Export funding data** from existing spreadsheets/Airtable
    
2. **Map fields** to new schema
    
3. **Validate** against $50,000 cap
    
4. **Import** with audit trail
    
5. **Verify** balances match known records
    

---

## Implementation Phases

### Phase 1: Foundation (2-3 weeks)

|Task|Description|Dependencies|
|---|---|---|
|Create `case_funding` table|Schema for case-level funding|None|
|Create `reimbursement_requests` table|Schema for invoices|None|
|Create funding summary view|Aggregated funding data|Tables complete|
|Implement case claim locking|Prevent duplicate claims|Application layer|

### Phase 2: Dashboard MVP (2-3 weeks)

|Task|Description|Dependencies|
|---|---|---|
|Build 4 KPI cards|Total approved, pending, paid, on hold|Views complete|
|Build active cases table|List with funding amounts|Views complete|
|Build reimbursement queue|Pending invoice list|Views complete|
|Build duplicate alerts|Flag overlaps|Views complete|

### Phase 3: Workflow (2 weeks)

|Task|Description|Dependencies|
|---|---|---|
|Implement invoice approval|Review, approve, reject|Queue built|
|Implement payment marking|Mark as paid|Queue built|
|Implement duplicate resolution|Flag, investigate, resolve|Alerts built|
|Implement email notifications|Status change alerts|Workflow complete|

### Phase 4: Reporting (2 weeks)

|Task|Description|Dependencies|
|---|---|---|
|Funding source breakdown|By grant/org|Data complete|
|Aging report|Days pending|Data complete|
|Export functionality|CSV/PDF reports|All data available|

---

## Success Criteria

### Quantitative

|Metric|Target|Measurement|
|---|---|---|
|Cases with funding visible|100%|All active cases have funding data|
|Reimbursement processing time|< 14 days|Average from submission to payment|
|Duplicate claims|0|No cases claimed by two orgs|
|Over-cap cases|0|No case > $50,000 approved|

### Qualitative

- Bursar can see funding for any case within 2 clicks
- Bursar can process a reimbursement in < 10 minutes
- Bursar is alerted to duplicates before money is spent
- Bursar can generate a report on demand
- Partners trust that invoices will be paid

---
## Appendix: Related Documents

|Document|Location|
|---|---|
|`metric-tracking-goals-reverse-engineer.md`|Organization-level metrics|
|`project-level-finance.sql`|Schema implementation|
|`sc_feedback.md`|Partner feedback|
|`project-level-financial-tracking.md`|Full requirements|

---

## Sign-off

|Role|Name|Date|Signature|
|---|---|---|---|
|Product Owner|________|________|________|
|Finance Lead|________|________|________|
|Technical Lead|________|________|________|
|Database Architect|________|________|________|