---
document_name: ARCHR Glossary — Terms, Data Structures & Acronyms
short_name: Glossary
document_type: Reference
version: 1
date: 2026-09-25
last_updated: 2026-09-25
author: ARCHR Development Team
excerpt: Definitive reference for the terms, data structures, acronyms, and concepts used throughout the ARCHR platform.
audience: All Platform Users
complexity_level: Reference
estimated_reading_minutes: 10 minutes
tags:
  - glossary
  - reference
  - data-structures
  - terminology
visibility: public
---

# ARCHR Glossary — Terms, Data Structures & Acronyms

This is the definitive reference for the terms, data structures, acronyms, and concepts used throughout the ARCHR platform. If a word appears in the UI, in the code, or in a conversation about the system, its definition lives here.

---

## Core Data Entities

### Application

The **permanent household record**. An application represents one household's submission for home repair assistance. Applications are **never claimed** — they are the source of truth for a household's information, eligibility, and history. One application may generate multiple cases, projects, and repair needs over time.

### Case

A **claimable work stream** derived from an application. When an organization assesses an application and identifies a specific scope of work (e.g., "Roof repair"), they create a case. Cases are what organizations claim, manage, and track through completion. One application can have multiple cases (e.g., a roof case and a plumbing case).

### Project

A **specific scope of work** within a case. A project organizes the actual repair work to be done. Projects are claimable and contain repair needs.

### Repair Need (Parent)

A **category of repair work** that needs to be done. Repair needs are the top level of the work hierarchy — for example, "Carpentry — Replace flooring and rebuild south wall." Repair needs are claimable by organizations or subcontractors. Each repair need has a trade, a description, a triage score, and a claim status.

### Repair Task (Child)

A **sub-task within a repair need**. Repair tasks break a parent repair need into actionable pieces. For example, a "Carpentry" repair need might have child tasks: "Replace flooring," "Rebuild south wall," and "Install new door frame." Tasks are the smallest unit of work tracked in the system.

### PlaceCode

An **immutable identifier for a physical property**. Constructed from the first ten letters of the address in uppercase, with an optional unit number in square brackets (e.g., `247-RIVERSIDE`). PlaceCodes are the primary key for property-level records and follow the household across applications, cases, and projects.

### JobCode

The **organizational identifier** for a case/project. Format: `[Org initials]-[Placecode]` (e.g., `AHFH-247-RIVERSIDE`). Always follows this convention — no exceptions.

### ANCHOR

The **source of all truth** in the project. ANCHOR is the master record system that tracks all entities, relationships, and history. All other systems (Airtable, Fillout, PostgreSQL) sync to or from ANCHOR.

### Progress Tracker

A **ledger-based system** that tracks all changes made to items in the ANCHOR. Every action, status change, and data modification is recorded as an immutable entry in the progress ledger. Enables full auditability.

---

## The Claiming Hierarchy

```
APPLICATION  (Never claimed — household's permanent record)
    │
    ▼  (after assessment)
CASE  (Claimable — e.g., "Roof repair" case)
    │
    ▼
PROJECT  (Claimable — specific scope of work)
    │
    ▼
REPAIR NEED  (Claimable — parent need, e.g., "Carpentry")
    │
    ▼
REPAIR TASK  (Claimable — child task, e.g., "Replace flooring")
```

**Key rule:** The application is never claimed. It is the household's permanent record. Cases, projects, repair needs, and tasks are what get claimed.

### Claim

A **declaration of ownership** over a case, project, or repair need. When an organization claims a record, it appears in their "Your Claims" list and other organizations see it as claimed (with contact info redacted). Claims expire after **90 days of inactivity** (no progress events).

### Claim Status

| Status | Meaning |
|---|---|
| **Active** (green) | Currently claimed, within 90-day window |
| **Expired** (red) | No activity for 90 days, returned to marketplace |
| **Released** (gray) | Voluntarily released by the claiming organization |

### Mark Met

An action that **marks a repair need as resolved**. Distinct from "claiming" — claiming means "I'll do this work," marking met means "this work is done." A claimed need can be marked met by the claiming organization.

### Release Claim

**Returns a record to the marketplace** immediately. The record no longer appears in the claiming organization's list and becomes available for another organization to claim.

### Renew Timer

**Resets the 90-day inactivity clock.** Used when an organization is still actively working on a claim but hasn't logged a progress event recently.

---

## Roles & Permissions

### Role Levels

| Level | Name | Description |
|---|---|---|
| **0** | Basic | Volunteer, Crew Member, Requestor — basic views for what concerns them |
| **1** | Admin Lite | Office workers — partial permissions, can look up cases with limited purview |
| **2** | Organizational Admin | Full admin for an organization — managing cases, users, and settings |
| **3** | Super Admin | IT/platform management, cross-organizational view, configuration |

### Subcontractor

A **future role** for external contractors. Subcontractors will be able to browse the marketplace, claim repair needs, and submit invoices. Not yet implemented.

### DSW

A **third-party assessor** that organizations can refer projects to for professional assessment. Configurable in the Case Review actions.

---

## Eligibility & Income

### AMI (Area Median Income)

The **income benchmark** used to determine eligibility. Applicants' income is expressed as a percentage of AMI (e.g., "80% AMI"). Different organizations have different AMI thresholds.

### Eligibility Presets

**Organization-specific rule sets** that determine which households qualify for which programs. Each preset defines criteria for geography, income, proof-of-income types, proof-of-ownership types, home type, and more.

### POI (Proof of Income)

Documentation that verifies an applicant's income. Examples: pay stubs, tax returns, benefit letters, bank statements.

---

## Documents

### Document Type

**What the document is** — a fixed reference category. Examples: Eligibility Verification, Contract, Site Photo, Estimate, Scope of Work. Document types are defined in the codebase and are not user-creatable.

### Document Folder

**Where the document is stored** — the physical path in the Dropbox (or local) file system. Folder structure is authoritative and based on the Dropbox root directory layout. Document type and folder are not 1:1 — overlap exists.

### Redaction

Documents containing PII (Personally Identifiable Information) can be marked as **redacted**. Redacted documents have sensitive information obscured before sharing with non-authorized roles.

---

## Systems & Platforms

### ARCHR Platform (app/ + vue-view/)

The **production system** being built — PHP backend (`app/`) + Vue frontend (`vue-view/`). PostgreSQL-backed, open-source, and designed to replace Softr/Airtable long-term.

### Softr

The **current production front-end** used by various roles (Admin, PM, Crew, Volunteer) to view and manipulate records. Softr sits on top of Airtable. Being replaced by the ARCHR Platform.

### Airtable

The **current back-end database** where ANCHOR records reside. Rate-limited on the free tier (5 req/s). The Vue app currently talks directly to Airtable as an intermediate step before full PostgreSQL migration.

### Fillout

The **intake form builder** where households submit their applications. Fillout results flow into the ARCHR system.

### PostgreSQL

The **target database** for the ARCHR platform. Self-hosted on the VPS. All data is being migrated from Airtable to PostgreSQL.

### Mailpit

A **local email testing tool** used during development. Captures outgoing emails without actually sending them. Accessible at `http://localhost:8025`.

---

## Acronyms & External Terms

| Acronym | Full Name | Context |
|---|---|---|
| **POI** | Proof of Income | Eligibility verification |
| **CDBG** | Community Development Block Grant | Federal grant program |
| **SHPO** | State Historical Preservation Office | Historic preservation requirements |
| **ERR** | Environmental Review Record | Environmental compliance |
| **IDIS** | Integrative Disbursement and Information System | HUD tracking system |
| **CENST** | Categorically Excluded Not Subject To | Environmental review category |
| **VOAD** | Voluntary Organizations Active in Disaster | Disaster response coalition |
| **COA** | City of Asheville | Municipal partner |
| **CFWNC** | Commons for Water North Carolina | Fund source |
| **AMI** | Area Median Income | Eligibility benchmark |
| **DSW** | Disaster Site Worker (third-party assessor) | External assessment service |
| **GIS** | Geographic Information System | Property mapping and ownership |
| **PII** | Personally Identifiable Information | Data privacy concern |

---

## Project Codes

Project codes indicate the **track or category** a project falls under. They start with a letter prefix:

| Prefix | Meaning |
|---|---|
| **D-** | Disaster track |
| **H-** | Mobile Home & Park track |
| **A-** | Traditional Home Repair track |
| **X-** | Unclaimed / Marketplace |

---

## Task Anatomy

Every task (or repair task) in the system has the following attributes:

| Attribute | Description |
|---|---|
| **Title** | What the task is |
| **State** | Complete / In Progress / Not Started |
| **Actor (byWho)** | Who performed or is responsible |
| **When** | Timestamp of action or deadline |
| **Dependencies** | Parent-child relationships (e.g., task B requires task A) |
| **Notes** | Free-form context |
| **Supporting Documents** | Uploaded files that verify completion |
| **Admin Flag** | Whether an admin has reviewed or flagged the task |

**Key principle:** The system assumes certain roles have verified tasks. It doesn't need peer review — it needs an **audit trail**.

### Task Flavors (Categorization)

| Version | Categories |
|---|---|
| **V1** | Action, Decision, Calculation, Scheduling, Automation, Verification, Photo |
| **V2** | By role — Admin tasks, Project Manager tasks, Crew tasks, etc. |
| **V3** | By data object — Applicant, Projected Cost, Repair Task, Document Task, Person |

---

## Fund Sources

Organizations track where funding comes from. Common fund sources:

| Code | Name |
|---|---|
| **CFWNC** | Commons for Water North Carolina |
| **KEENAN/JP** | Keenan / JP Foundation |
| **VOAD** | Voluntary Organizations Active in Disaster |
| **COA** | City of Asheville |

---

## Legacy & Historical Terms

### Red Table

The **original ARCHR emergency table** created two weeks after Hurricane Helene. Grew organically as columns were added. The "stacking dependencies" problem — adding a column every time a new need arose.

### Purple Table

A subsequent attempt to organize data. Less structured than the current system.

### Legacy Neighborhood

**Historic neighborhoods with grant coverage.** Being part of a legacy neighborhood extends a household's eligibility for certain programs. Tracked as a field in the Home Info section of an application.

### GIS_OWNER

The **property owner name** pulled from the county GIS system. Used to verify ownership during the eligibility process.

---

## UI Patterns

### Application Preview Card

A **reusable component** that displays key application info. Two variants:
- **Marketplace variant** — shows claim action
- **Case List variant** — shows "Open" and "Toolbox" actions

### Repair Need Row

A **hierarchical component** showing a parent repair need with its child repair tasks indented below. Displays trade, description, triage score, claim status, and action buttons.

### Tabbed Information Panel

A **reusable tabbed container** configured per page. The case review page has tabs for Eligibility Summary, Comments, Communications, Documents, Property Card, Requests, and Progress Events. The edit application page has tabs for Applicant, Home, Household, Income, and Repair Requests.

### Case Toolbox

A **role-specific action menu** accessible from the Case Review page. Contents vary by user role. (Exact contents TBD.)

### Marketplace

The **central hub** where organizations browse and claim applications and repair needs. Contains tabs for Your Claims, Unclaimed Needs, and Claimed by My Org.

---

## Referrals

A **referral** is a directed opportunity to claim a job. Referrals can go to:
- **Partner organizations** — another coalition member
- **Subcontractors** — external contractors (future)

When a referral is sent, it creates a record in the recipient's "My Referrals" inbox with the request text, scope of work, and a link to open the application.

---

## The Pipeline (Application Lifecycle)

```
Intake Submission (Fillout)
    → Application created (never claimed)
    → Eligibility Processing (human determinations + robot guidance)
    → Case(s) created (claimable)
    → Project(s) created (claimable)
    → Repair Needs parsed (claimable)
    → Repair Tasks assigned (claimable)
    → Crew dispatch / Weekly assignments
```

The current focus is building the pipeline that makes it possible to get to **assignable home repair tasks**. Dispatch and weekly crew assignment do not exist yet.
