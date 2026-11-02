# ARCHR project costing and reimbursement flow

The Project Costing Database is a reporting and automation system. It does not
replace the AAHH Finance accounting ledger. `projectKey` is the pivot used to
join task planning, project evidence, funding selection, document generation,
payment confirmation, and downstream reporting.

```mermaid
flowchart TD
    Funders[Funders<br/>grants and direct donations]
    Fundraising[ARCHR fundraising<br/>requests and awards]
    Finance[AAHH Finance<br/>separate ARCHR account]
    FundingDB[Funding Sources Database<br/>awards, restrictions, balances]

    TaskLibrary[Task Library<br/>sizes, materials, severity rules]
    Assessment[Assessment and scope building]
    PM[Project Manager<br/>budget and contract preparation]
    Contract[One ARCHR-client contract<br/>per Project KEY]
    Completion[Certificate of Completion]

    Costing[(Project Costing Database<br/>Project KEY pivot)]
    Robo[costEntries: robo<br/>future-spend projection]
    Estimate[costEntries: est<br/>PM or contract-informed]
    Actual[costEntries: act<br/>attributed reporting actual]
    Evidence[Evidence<br/>invoices, receipts, timesheets,<br/>task start/end events and notes]

    Selection[Funding-source eligibility<br/>and selection]
    Draw[Draw Request<br/>expense total, eligible amount,<br/>requested amount and evidence]
    DocumentBuilder[Document Builder<br/>draw workbook and packet]
    Review[Accounting and Grants review]
    Payment[AAHH Finance payment<br/>after approved source selection]
    Tracker[Funding Source Tracker<br/>draw number, bill date,<br/>actual bill amount and categories]
    Reporting[(Reporting Database)]

    Funders --> Fundraising
    Fundraising --> Finance
    Fundraising --> FundingDB
    Finance --> FundingDB

    TaskLibrary --> Assessment
    Assessment --> Robo
    Robo --> Costing
    Costing -. projected need .-> Fundraising

    Assessment --> PM
    PM --> Estimate
    Estimate --> Costing
    PM --> Contract
    Contract --> Completion

    Completion --> Evidence
    Evidence --> Actual
    Actual --> Costing

    Costing --> Selection
    FundingDB --> Selection
    Selection --> Draw
    Evidence --> Draw
    Contract --> Draw
    Draw --> DocumentBuilder
    DocumentBuilder --> Review
    Review -->|approved| Payment
    FundingDB --> Payment
    Finance --> Payment

    Payment --> Tracker
    Payment --> Costing
    Tracker --> FundingDB
    Costing --> Reporting
    FundingDB --> Reporting
    Tracker --> Reporting
```

## Cost resolution

Cost entries are append-only reporting observations. For the same task, the
resolver normally prefers `act` over `est`, and `est` over `robo`; it does not
delete the earlier entries. An attributed `act` entry should identify its
calculation method and the evidence or task events used as its basis.

```mermaid
flowchart LR
    Scope[Assessment and scope] --> Robo[robo]
    Robo --> Estimate[est]
    Estimate --> Completed[Project completed]
    Completed --> Inputs[Receipts + invoices + timesheets<br/>+ task duration]
    Inputs --> Actual[act]
    Actual --> Resolution[Resolved task/project reporting cost]
```

## Sparse input versus resolved snapshot

- `schemas/costing-input.schema.json` describes partial, idempotent writes to
  the automation engine.
- `schemas/costing-snapshot.schema.json` describes the fully resolved
  Project-KEY-centered reporting object.
- Missing properties in an input event mean “unchanged.” Array members are
  upserted by their stable IDs. Removal or voiding must be explicit.
- Funding-source balances and bank activity remain authoritative in their
  respective systems. The costing snapshot contains references and reporting
  values needed to prepare and explain reimbursement.

