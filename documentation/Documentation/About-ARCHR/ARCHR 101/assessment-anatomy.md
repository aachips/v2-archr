---
document_name: Assessment Anatomy — Structure, Data Flow, and Document Generation
short_name: Assessment Anatomy
document_type: Technical Specification
version: 1
date: 2026-09-28
last_updated: 2026-09-28
author: ARCHR Development Team
excerpt: Breakdown of what goes into a finalized home repair assessment, the data fields collected, and how they map to the ARCHR platform's Scope of Work, Cases, and Costing Engine.
visibility: internal
tags:
  - assessment
  - scope-of-work
  - data-model
  - document-generation
  - costing
---

# Assessment Anatomy — Structure, Data Flow, and Document Generation

## Overview

A home repair assessment is the bridge between **intake** (a household submits an application) and **execution** (an organization claims and completes the repair work). The assessment produces a Scope of Work (SOW) — an itemized list of what needs to be fixed, with estimated costs — which then becomes the basis for claiming, contracting, and costing.

This document describes the anatomy of a typical assessment, the data fields it captures, and how those fields map to ARCHR's platform.

---

## Assessment Document Structure

A complete assessment typically produces several modular documents:

### 1. Contract Signing Confirmation
- Email/notification to all parties confirming contract execution
- Indicates the household will receive support for qualified repairs
- Generated after intake documents are verified and the SOW is approved

### 2. Scope of Work (SOW)
The core assessment output. Think of it as an invoice table with a robust header:

**Header fields:**
- Organization Name — which organization governed/completed the assessment
- Claim Number (Project Code) — e.g., `D245VI` (Disaster · 245 Virginia Avenue)
- Document Title — "Scope of Work"
- Date Created
- Homeowner(s) — full name(s)
- Full Address — postage-complete address

**Line items table:**
| Task | Location | Details | Budget |
|------|----------|---------|--------|
| Debris Removal | Whole property | Remove fallen trees and debris from access road | $X,XXX |
| Soffit, Fascia, Gutters | North side | Repair damaged soffit, fascia, and gutter system | $X,XXX |
| Deck Replacement | Rear | Full deck replacement due to water damage | $X,XXX |
| Door Replacement | Front entry | Replace front door and frame | $X,XXX |

**Footer:** Total Construction Price (sum of all line item budgets)

### 3. Assessment Verification Page
Letter-format page confirming the assessment was completed and repairs are necessary:
- Insured party / homeowner name
- Property address
- Contact information
- Claim / policy number
- Dates: loss, inspected, received, entered
- Price list document name
- Estimate document name
- Scope of Work statement — verifying these are emergency repairs to make the home livable
- Estimated cost and total cost
- Signature lines: homeowner + program representative

### 4. Materials Inventory
Itemized breakdown of materials, quantities, unit costs, and totals per line item. Each area of the home is a separate table section.

### 5. Site Photos
Before-repair photos with metadata: title, date taken, taken by. Typically 2 photos per 8.5"×11" page with labels.

### 6. Roof Mapping / Diagram
A visual diagram of the roof showing damage areas and repair zones.

---

## Data Fields Extracted from Assessment

These are the canonical data fields that ARCHR needs to capture from any assessment, regardless of format:

| Field | Type | Source | Notes |
|---|---|---|---|
| `organization_name` | String | Header | Organization conducting assessment |
| `claim_number` | String | Header | Unique project identifier (e.g., D245VI) |
| `homeowner_names` | String[] | Header | One or more homeowner names |
| `full_address` | String | Header | Complete postal address |
| `date_created` | Date | Header | Assessment creation date |
| `sow_line_items[]` | Array | Table | Each row: task, location, details, budget |
| `total_construction_price` | Number | Footer | Sum of all line item budgets |
| `date_of_loss` | Date | Verification | When the damage occurred |
| `date_inspected` | Date | Verification | When assessor visited |
| `policy_number` | String | Verification | Same as claim number in many cases |
| `materials_inventory[]` | Array | Inventory | Itemized materials with quantities/costs |
| `site_photos[]` | File[] | Photos | Images with title, date, photographer |
| `roof_diagram` | File | Diagram | Roof map image |
| `is_emergency` | Boolean | Verification | Whether repairs are classified as emergency |
| `emergency_description` | Text | Verification | Short description of emergency repairs |

---

## Price Tracking: Estimated → Quoted → Actual

The assessment produces an **estimated** cost per repair task. As work progresses, two more price points are captured:

| Price Type | When Captured | Source |
|---|---|---|
| **Estimated** | Assessment / SOW creation | Assessor's initial appraisal |
| **Quoted** | Subcontractor or org provides a formal quote | Quote document |
| **Actual** | After repair is completed | Invoice / receipt |

Each repair task in the SOW tracks all three. The estimated price is stable enough to base financial decisions on, but the quoted and actual prices provide accountability and variance tracking.

---

## How Assessment Data Maps to ARCHR

### Application → Assessment → Scope of Work → Cases

```
APPLICATION (intake submission — never claimed)
    │
    ▼  (assessor visits, produces SOW)
ASSESSMENT (attached to application, stores SOW data)
    │
    ▼  (SOW line items become claimable work)
SCOPE OF WORK (itemized repair tasks with estimates)
    │
    ▼  (each SOW line item forks into claimable work)
CASE(s) — one per repair task or grouped tasks
    │
    ▼
PROJECT(s) — specific repair scopes
    │
    ▼
REPAIR NEED(s) — claimable, with estimated/quoted/actual costs
```

**Key rule:** SOW line items become either:
- Individual **Repair Needs** that can be claimed separately (e.g., "Deck Replacement" claimed by one org, "Door Replacement" by another)
- Grouped into a single **Case** if one org handles all items

### Document Bucket Integration

Assessment documents are stored in the Document Bucket with:
- **Document Type:** "Assessment" or "Scope of Work"
- **Folder path:** `/organizations/{org}/cases/{placecode}/assessment/`
- **Metadata:** claim number, date created, assessor name, linked application
- **Site photos:** stored in `/organizations/{org}/cases/{placecode}/photo-unprocessed/` before case linking, then moved to `/property/` or `/repair-photos/`

### Future Costing Engine

Each Repair Need tracks:
- `estimated_cost` — from the SOW budget
- `quoted_cost` — from subcontractor/org quote
- `actual_cost` — from final invoice

Variance reporting: `(actual - estimated) / estimated * 100` shows cost accuracy per org and per trade.

---

## Document Generation Readiness

When ARCHR eventually generates documents, it will need these data pools:

| Document | Required Data |
|---|---|
| **Scope of Work** | org name, claim number, homeowner, address, SOW line items, total |
| **Assessment Verification** | homeowner, address, claim/policy #, dates, emergency flag, signatures |
| **Materials Inventory** | materials array with quantities, unit costs, totals |
| **Contract** | SOW, total cost, homeowner sig, org sig, dates |
| **Invoice** | actual costs, materials used, labor hours |

Until document generation is built, the platform tracks which documents exist, where they're stored, and what metadata they contain.

---

## What Happens After the Assessment: The Contract

The next step after the SOW is the **Contract** — a binding agreement between the organization and the homeowner for the scoped repairs. The contract pulls from:
- SOW line items (what will be done)
- Total construction price (what it will cost)
- Homeowner info (who it's for)
- Org info (who is doing it)
- Dates (when it starts, when it ends)

Contracts are not yet in scope, but the data collected here sets the foundation for them.
