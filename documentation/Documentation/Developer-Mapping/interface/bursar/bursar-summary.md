---
role_name: Bursar
role_code: BURSAR
version: 1.0
last_updated: 2024-12-18
---

The Bursar is a fluid project-level role relating to financial management, and accounting of funds disbursed. Their interaction with clients is minimal, but they do regularly interact with partners and subcontractors. This role is most likely done from their organization’s office, and requires a medium to high technical comfort. It may be tracking within Habitat for Humanity, or any of the partner programs involved with ARCHR.

The biggest challenge and pain point of the Bursar role is ensuring relevant money data is tracked and visible where it needs to be visible. This may mean being a bridge between organizational financial tracking and ARCHR. The process may vary depending how each organization internally tracks finances and funds within cases. 

Each approved case is allotted up to, and no more than 50,000 dollars. Project Managers, Administrators, and other Bursars, must be able to see what has been spent or allotted, and what is available. To do this, up to date reporting is essential. Each quarter, a report will need to be generated, accounting for how much has been spent, on what, and where. 

Within the system architecture, protections against duplicate claims must be built in. Reimbursements must be able to be processed in a timely way. Metrics must be able to be dynamically generated and displayed. Payment issues need to be resolved as needed. 

For security, practicality, and compliance, the ARCHR platform will not be connected to bank accounts, charge cards, or sensitive client financial information. The platform is not capable of facilitating purchases, wire transfers, or payments. It is restricted to voluntary tracking and limited spreadsheet access. The platform, at the Bursar level, will need to find a safe medium for voluntary reporting, both at the organization and case level, when it comes to ARCHR repair cases. 

What they need to see: 

- Total approved funds allocated
- Pending reimbursements - Invoices awaiting Review
- Reimbursed to Date - Payments already issued
- On Hold Amounts - Funds with Hold Status
- Active Cases with Funding - Per case funding breakdown
- Duplicate Alerts - Overlapping Claims

What they need to create/update:

- Approve Reimbursement - Accept invoice for payment
- Reject Reimbursement - With reason for rejection
- Mark Payment - Record payment issued
- Set Case Cap - $50,000 limit enforcement
- Create Funding Source - Add Grant/Donation
- Allocate Funds - Attach funds to cases
- Resolve Duplicate - Flag and Investigate  

Who they interact with:

- Subcontractors - Invoice Questions
- Project Managers - Budget Questions
- Partner Organizations - Reimbursement Coordination
- Funders - Grant Reporting
- Administrators - Financial Oversight

Possible Frustrations & Pain Points:

- Can’t see funding per cases
- Duplicate Invoices - Risk of financial loss
- Slow Workflow - Partners don’t get paid
- Manual Reconciliation - Waste of time
- No Audit Trail - Can’t prove compliance
- Unclear Cap Tracking - Risk of overfunding

At best, if the Bursar is able to successfully fulfill their role duties: Partners get paid promptly, we pass audits, maintain funder trust, and show we can use funds efficiently. At its worst: partners leave coalition, we fail audits and lose funders, and there is a risk of waste and fraud.

Bursar is not a job description, but a fluid role responsibility that can be fulfilled by Organizational Administrators, Project Managers, or the Envoy. 

## Initial Assumptions to Validate

- Each case has $50,000 cap (per disaster/repair)
- Need to track approved, spent, remaining
- Need to prevent duplicate claims
- Reimbursements need workflow (submit → approve → pay)
- Invoices need line item tracking
- Fund sources need allocation tracking
- Need to handle "on hold" funds
- Need 3-way matching (quote → invoice → payment)