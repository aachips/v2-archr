---
document_name: Sync Map Data Flows — Base-to-Base Diagrams
document_type: Technical Reference
version: 1.0
last_updated: 2026-08-01
author: ARCHR Development Team
audience: Developers, Admins
complexity_level: Advanced
estimated_reading_minutes: 20
tags: [data-flow, sync, airtable, architecture]
visibility: ["admin", "super-admin"]
---

# Sync Map Data Flows

Source: `C:\Users\bwyatt\Downloads\🔷Tables-Sync Map.csv`

This document translates the Sync Map table into base-level data-flow diagrams. Counts represent the number of sync-map rows/tables connecting two bases, not record volume.

## How to Read This

- **Inbound** means this base has local tables populated from another base through a synced table relationship.
- **Outbound** means this base has source tables that feed synced tables in another base.
- **Automation surface** counts local tables where the CSV shows automation triggers, reads, or writes.
- **Linked record surface** counts local tables where the CSV shows linked-record paths.

## System Overview

```mermaid
flowchart LR
  fillout["🟦(📗) Fillout Results"]
  anchor["🟦[D](v1-2) ANCHOR Records"]
  directory["🟦[D] (v2) ARCHR Directory"]
  documents["🟦[D] ARCHR Project Documents"]
  repairs["🟦[D] ARCHR Repair Requests"]
  eligibility["🟦[P] ARCHR Eligibility"]
  progress["🟦[P] ARCHR Progress Tracker"]
  partners["🟦ARCHR Partner Programs"]
  model["🟦[X] ARCHR Architecture Model"]
  emergency["🟦[A] (v1) ARCHR Emergency"]
  tasks["🟦[D] ARCHR Multi Axis Task Library"]

  model -->|"forms, phases, roles, interfaces"| fillout
  model -->|"architecture refs"| directory
  model -->|"task/phase refs"| progress

  fillout -->|"intake submissions"| eligibility
  fillout -->|"request intake"| repairs
  fillout -->|"anchor intake"| anchor
  fillout -->|"directory sync"| directory

  anchor -->|"anchor/project/place syncs"| progress
  anchor -->|"project docs + anchor records"| documents
  anchor -->|"eligibility anchors"| eligibility
  anchor -->|"fillout backlinks"| fillout
  anchor -->|"repair anchors"| repairs

  directory -->|"people/org/session/project syncs"| progress
  directory -->|"people/org docs"| documents
  directory -->|"eligibility people/orgs"| eligibility
  directory -->|"partner orgs"| partners
  directory -->|"repair directory refs"| repairs

  documents -->|"doc events/doc codes"| progress
  documents -->|"program/doc syncs"| partners

  eligibility -->|"eligibility docs/reports"| documents
  eligibility -->|"fillout result feedback"| fillout
  eligibility -->|"program eligibility"| partners
  eligibility -->|"eligibility event sync"| progress

  progress -->|"task/project/session events"| directory
  progress -->|"repair progress events"| repairs
  progress -->|"anchor progress events"| anchor
  progress -->|"doc progress events"| documents

  emergency -->|"v1 tasks/jobs/events"| tasks
  emergency -->|"v1 events/status"| progress
  emergency -->|"jobs/docs"| documents
  emergency -->|"legacy anchor + fillout"| anchor
  emergency -->|"funding requests"| fillout
```

## Per-Base Diagrams

### 🟦(📗) Fillout Results

```mermaid
flowchart LR
  base["🟦(📗) Fillout Results"]
  anchor["🟦[D](v1-2) ANCHOR Records"] -->|"2 inbound sync tables"| base
  repairs["🟦[D] ARCHR Repair Requests"] -->|"2 inbound sync tables"| base
  emergency["🟦[A] (v1) ARCHR Emergency"] -->|"1 inbound sync table"| base
  partners["🟦ARCHR Partner Programs"] -->|"1 inbound sync table"| base
  model["🟦[X] ARCHR Architecture Model"] -->|"1 inbound sync table"| base
  eligibility["🟦[P] ARCHR Eligibility"] -->|"1 inbound sync table"| base
  base -->|"2 outbound sync tables"| repairs
  base -->|"2 outbound sync tables"| anchor
  base -->|"2 outbound sync tables"| eligibility
  base -->|"1 outbound sync table"| directory["🟦[D] (v2) ARCHR Directory"]
```

Fillout is the intake and raw-submission hub. It receives reference/sync data from model, eligibility, partner, anchor, repair, and emergency bases, then pushes cleaned intake/request/submission tables into eligibility, repair requests, ANCHOR, and directory flows.

- Tables mapped: 12
- Automation surface: 5 trigger tables, 5 write tables, 5 read tables
- Linked record surface: 12 tables

### 🟦[A] (v1) ARCHR Emergency

```mermaid
flowchart LR
  base["🟦[A] (v1) ARCHR Emergency"]
  base -->|"3 outbound sync tables"| tasks["🟦[D] ARCHR Multi Axis Task Library"]
  base -->|"2 outbound sync tables"| progress["🟦[P] ARCHR Progress Tracker"]
  base -->|"1 outbound sync table"| fillout["🟦(📗) Fillout Results"]
  base -->|"1 outbound sync table"| anchor["🟦[D](v1-2) ANCHOR Records"]
  base -->|"1 outbound sync table"| docs["🟦[D] ARCHR Project Documents"]
```

The v1 emergency base acts mainly as a source into shared systems: task library, progress events, documents, ANCHOR, and Fillout-derived request flows.

- Tables mapped: 6
- Automation surface: none shown in this CSV
- Linked record surface: none shown in this CSV

### 🟦[A] (v2) ARCHR Applicants

```mermaid
flowchart LR
  base["🟦[A] (v2) ARCHR Applicants"]
  base -->|"2 outbound sync tables"| docs["🟦[D] ARCHR Project Documents"]
```

The v2 applicants base feeds applicant home and FEMA/HOI/attestation data into the project document system.

- Tables mapped: 2
- Automation surface: none shown
- Linked record surface: none shown

### 🟦[D] (v1) ARCHR Disaster Funding Sources

```mermaid
flowchart LR
  base["🟦[D] (v1) ARCHR Disaster Funding Sources"]
  base -->|"1 outbound sync table"| anchor["🟦[D](v1-2) ANCHOR Records"]
```

The disaster funding source base contributes draw request data into ANCHOR records.

- Tables mapped: 1
- Automation surface: none shown
- Linked record surface: none shown

### 🟦[D] (v2) AAHH Traditional Home Repair

```mermaid
flowchart LR
  base["🟦[D] (v2) AAHH Traditional Home Repair"]
  base -->|"1 outbound sync table"| anchor["🟦[D](v1-2) ANCHOR Records"]
```

The AAHH traditional home repair base contributes CS/NRI data into ANCHOR records.

- Tables mapped: 1
- Automation surface: none shown
- Linked record surface: none shown

### 🟦[D] (v2) ARCHR Directory

```mermaid
flowchart LR
  base["🟦[D] (v2) ARCHR Directory"]
  progress["🟦[P] ARCHR Progress Tracker"] -->|"4 inbound sync tables"| base
  model["🟦[X] ARCHR Architecture Model"] -->|"3 inbound sync tables"| base
  fillout["🟦(📗) Fillout Results"] -->|"1 inbound sync table"| base
  email["🟦[P] ARCHR Email Handler"] -->|"1 inbound sync table"| base
  base -->|"3 outbound sync tables"| progress
  base -->|"2 outbound sync tables"| docs["🟦[D] ARCHR Project Documents"]
  base -->|"2 outbound sync tables"| eligibility["🟦[P] ARCHR Eligibility"]
  base -->|"1 outbound sync table"| partners["🟦ARCHR Partner Programs"]
  base -->|"1 outbound sync table"| repairs["🟦[D] ARCHR Repair Requests"]
```

Directory is the people/org/session/project coordination layer. It receives architecture definitions and progress events, then republishes people, organizations, projects, sessions, and eligibility/reporting joins across the operational bases.

- Tables mapped: 12
- Automation surface: 6 trigger tables, 6 write tables, 4 read tables
- Linked record surface: 11 tables

### 🟦[D] ARCHR Multi Axis Task Library

```mermaid
flowchart LR
  emergency["🟦[A] (v1) ARCHR Emergency"] -->|"3 inbound sync tables"| base["🟦[D] ARCHR Multi Axis Task Library"]
  subcontractors["🟦[P] Subcontractor Log"] -->|"1 inbound sync table"| base
```

The task library receives v1 task/job/library data and subcontractor task data. In this CSV it appears as a sink rather than a source.

- Tables mapped: 4
- Automation surface: none shown
- Linked record surface: 4 tables

### 🟦[D] ARCHR Project Documents

```mermaid
flowchart LR
  base["🟦[D] ARCHR Project Documents"]
  eligibility["🟦[P] ARCHR Eligibility"] -->|"3 inbound sync tables"| base
  directory["🟦[D] (v2) ARCHR Directory"] -->|"2 inbound sync tables"| base
  anchor["🟦[D](v1-2) ANCHOR Records"] -->|"2 inbound sync tables"| base
  applicants["🟦[A] (v2) ARCHR Applicants"] -->|"2 inbound sync tables"| base
  progress["🟦[P] ARCHR Progress Tracker"] -->|"2 inbound sync tables"| base
  emergency["🟦[A] (v1) ARCHR Emergency"] -->|"1 inbound sync table"| base
  subcontractors["🟦[P] Subcontractor Log"] -->|"1 inbound sync table"| base
  email["🟦[P] ARCHR Email Handler"] -->|"1 inbound sync table"| base
  partners["🟦ARCHR Partner Programs"] -->|"1 inbound sync table"| base
  base -->|"3 outbound sync tables"| progress
  base -->|"2 outbound sync tables"| partners
```

Project Documents is the document/document-event hub. It receives applicant, eligibility, anchor, directory, email, subcontractor, emergency, partner, and progress context, then pushes document events and document-code/program data back to Progress Tracker and Partner Programs.

- Tables mapped: 19
- Automation surface: 7 trigger tables, 7 write tables, 6 read tables
- Linked record surface: 16 tables

### 🟦[D] ARCHR Repair Requests

```mermaid
flowchart LR
  base["🟦[D] ARCHR Repair Requests"]
  progress["🟦[P] ARCHR Progress Tracker"] -->|"3 inbound sync tables"| base
  fillout["🟦(📗) Fillout Results"] -->|"2 inbound sync tables"| base
  anchor["🟦[D](v1-2) ANCHOR Records"] -->|"1 inbound sync table"| base
  directory["🟦[D] (v2) ARCHR Directory"] -->|"1 inbound sync table"| base
  marketplace["🟦[P] ARCHR Marketplace"] -->|"1 inbound sync table"| base
  base -->|"2 outbound sync tables"| fillout
```

Repair Requests consolidates request intake, marketplace events, anchor links, directory context, and progress status. It also sends repair/request tables back toward Fillout.

- Tables mapped: 10
- Automation surface: none shown
- Linked record surface: 7 tables

### 🟦[D] ARCHR Reports

```mermaid
flowchart LR
  base["🟦[D] ARCHR Reports"]
  base -->|"1 outbound sync table"| progress["🟦[P] ARCHR Progress Tracker"]
```

Reports contributes financial/reporting progress data into Progress Tracker.

- Tables mapped: 1
- Automation surface: none shown
- Linked record surface: none shown

### 🟦[D] DSW Updates Sheet

```mermaid
flowchart LR
  base["🟦[D] DSW Updates Sheet"]
  base -->|"1 outbound sync table"| anchor["🟦[D](v1-2) ANCHOR Records"]
  base -->|"1 outbound sync table"| progress["🟦[P] ARCHR Progress Tracker"]
```

DSW updates are shared into both ANCHOR and Progress Tracker.

- Tables mapped: 2
- Automation surface: none shown
- Linked record surface: none shown

### 🟦[D](v1-2) ANCHOR Records

```mermaid
flowchart LR
  base["🟦[D](v1-2) ANCHOR Records"]
  progress["🟦[P] ARCHR Progress Tracker"] -->|"2 inbound sync tables"| base
  fillout["🟦(📗) Fillout Results"] -->|"2 inbound sync tables"| base
  emergency["🟦[A] (v1) ARCHR Emergency"] -->|"1 inbound sync table"| base
  partners["🟦ARCHR Partner Programs"] -->|"1 inbound sync table"| base
  funding["🟦[D] (v1) ARCHR Disaster Funding Sources"] -->|"1 inbound sync table"| base
  dsw["🟦[D] DSW Updates Sheet"] -->|"1 inbound sync table"| base
  aahh["🟦[D] (v2) AAHH Traditional Home Repair"] -->|"1 inbound sync table"| base
  base -->|"3 outbound sync tables"| progress
  base -->|"2 outbound sync tables"| eligibility["🟦[P] ARCHR Eligibility"]
  base -->|"2 outbound sync tables"| docs["🟦[D] ARCHR Project Documents"]
  base -->|"2 outbound sync tables"| fillout
  base -->|"1 outbound sync table"| repairs["🟦[D] ARCHR Repair Requests"]
```

ANCHOR is a central record spine for projects, places, dates, DSW updates, draw requests, and anchor/project backlinks. It both receives project context and republishes anchor-level relationships to Progress Tracker, Documents, Eligibility, Fillout, and Repair Requests.

- Tables mapped: 12
- Automation surface: 7 trigger tables, 6 write tables, 7 read tables
- Linked record surface: 12 tables

### 🟦[P] ARCHR Eligibility

```mermaid
flowchart LR
  base["🟦[P] ARCHR Eligibility"]
  directory["🟦[D] (v2) ARCHR Directory"] -->|"2 inbound sync tables"| base
  fillout["🟦(📗) Fillout Results"] -->|"2 inbound sync tables"| base
  partners["🟦ARCHR Partner Programs"] -->|"2 inbound sync tables"| base
  anchor["🟦[D](v1-2) ANCHOR Records"] -->|"2 inbound sync tables"| base
  base -->|"3 outbound sync tables"| docs["🟦[D] ARCHR Project Documents"]
  base -->|"1 outbound sync table"| fillout
  base -->|"1 outbound sync table"| partners
  base -->|"1 outbound sync table"| progress["🟦[P] ARCHR Progress Tracker"]
```

Eligibility sits between intake, programs, directory identity, ANCHOR records, reports, and project documents. It pushes eligibility/report/document context to Project Documents and Progress Tracker while also maintaining partner and Fillout feedback loops.

- Tables mapped: 10
- Automation surface: 3 trigger tables, 5 write tables, 3 read tables
- Linked record surface: 9 tables

### 🟦[P] ARCHR Email Handler

```mermaid
flowchart LR
  base["🟦[P] ARCHR Email Handler"]
  base -->|"1 outbound sync table"| directory["🟦[D] (v2) ARCHR Directory"]
  base -->|"1 outbound sync table"| docs["🟦[D] ARCHR Project Documents"]
```

Email Handler sends received-message and alert-log data into Directory and Project Documents.

- Tables mapped: 2
- Automation surface: none shown
- Linked record surface: none shown

### 🟦[P] ARCHR Marketplace

```mermaid
flowchart LR
  base["🟦[P] ARCHR Marketplace"]
  base -->|"1 outbound sync table"| repairs["🟦[D] ARCHR Repair Requests"]
```

Marketplace events feed Repair Requests.

- Tables mapped: 1
- Automation surface: none shown
- Linked record surface: none shown

### 🟦[P] ARCHR Progress Tracker

```mermaid
flowchart LR
  base["🟦[P] ARCHR Progress Tracker"]
  docs["🟦[D] ARCHR Project Documents"] -->|"3 inbound sync tables"| base
  directory["🟦[D] (v2) ARCHR Directory"] -->|"3 inbound sync tables"| base
  anchor["🟦[D](v1-2) ANCHOR Records"] -->|"3 inbound sync tables"| base
  emergency["🟦[A] (v1) ARCHR Emergency"] -->|"2 inbound sync tables"| base
  model["🟦[X] ARCHR Architecture Model"] -->|"2 inbound sync tables"| base
  assessments["🟦[R] ARCHR Assessments"] -->|"1 inbound sync table"| base
  partners["🟦ARCHR Partner Programs"] -->|"1 inbound sync table"| base
  eligibility["🟦[P] ARCHR Eligibility"] -->|"1 inbound sync table"| base
  dsw["🟦[D] DSW Updates Sheet"] -->|"1 inbound sync table"| base
  reports["🟦[D] ARCHR Reports"] -->|"1 inbound sync table"| base
  base -->|"4 outbound sync tables"| directory
  base -->|"3 outbound sync tables"| repairs["🟦[D] ARCHR Repair Requests"]
  base -->|"2 outbound sync tables"| anchor
  base -->|"2 outbound sync tables"| docs
```

Progress Tracker is the cross-system event and task state hub. It receives events from documents, directory, ANCHOR, emergency, model, assessments, eligibility, DSW, reports, and partner programs, then republishes task/project/session/anchor/document progress state back to Directory, Repair Requests, ANCHOR, and Project Documents.

- Tables mapped: 19
- Automation surface: 13 trigger tables, 3 write tables, 14 read tables
- Linked record surface: 19 tables

### 🟦[P] Subcontractor Log

```mermaid
flowchart LR
  base["🟦[P] Subcontractor Log"]
  base -->|"1 outbound sync table"| tasks["🟦[D] ARCHR Multi Axis Task Library"]
  base -->|"1 outbound sync table"| docs["🟦[D] ARCHR Project Documents"]
```

Subcontractor jobs/tasks feed the task library and project document system.

- Tables mapped: 2
- Automation surface: none shown
- Linked record surface: none shown

### 🟦[R] ARCHR Assessments

```mermaid
flowchart LR
  base["🟦[R] ARCHR Assessments"]
  base -->|"1 outbound sync table"| progress["🟦[P] ARCHR Progress Tracker"]
```

Assessment reports feed Progress Tracker.

- Tables mapped: 1
- Automation surface: none shown
- Linked record surface: none shown

### 🟦[X] ARCHR Architecture Model

```mermaid
flowchart LR
  base["🟦[X] ARCHR Architecture Model"]
  base -->|"3 outbound sync tables"| directory["🟦[D] (v2) ARCHR Directory"]
  base -->|"2 outbound sync tables"| progress["🟦[P] ARCHR Progress Tracker"]
  base -->|"1 outbound sync table"| fillout["🟦(📗) Fillout Results"]
```

Architecture Model publishes definitions for progress tasks, roles, phases, interfaces, and Fillout forms into the runtime bases.

- Tables mapped: 5
- Automation surface: none shown
- Linked record surface: none shown

### 🟦ARCHR Partner Programs

```mermaid
flowchart LR
  base["🟦ARCHR Partner Programs"]
  docs["🟦[D] ARCHR Project Documents"] -->|"2 inbound sync tables"| base
  directory["🟦[D] (v2) ARCHR Directory"] -->|"1 inbound sync table"| base
  eligibility["🟦[P] ARCHR Eligibility"] -->|"1 inbound sync table"| base
  base -->|"2 outbound sync tables"| eligibility
  base -->|"1 outbound sync table"| anchor["🟦[D](v1-2) ANCHOR Records"]
  base -->|"1 outbound sync table"| fillout["🟦(📗) Fillout Results"]
  base -->|"1 outbound sync table"| docs
  base -->|"1 outbound sync table"| progress["🟦[P] ARCHR Progress Tracker"]
```

Partner Programs is a program/organization reference base with loops into Eligibility, ANCHOR, Fillout, Documents, and Progress Tracker.

- Tables mapped: 6
- Automation surface: none shown in this CSV
- Linked record surface: 5 tables

## High-Level Roles

- **Reference/config publishers:** Architecture Model, Partner Programs, Multi Axis Task Library.
- **Intake and source capture:** Fillout Results, Email Handler, Marketplace, Applicant bases, DSW Updates, Assessments.
- **Operational record hubs:** Directory, ANCHOR Records, Repair Requests, Eligibility.
- **Document hub:** Project Documents.
- **Event/task hub:** Progress Tracker.

## Notes and Caveats

- The Sync Map CSV describes discovered table-level relationships. It does not prove direction of individual field formulas or automation side effects beyond the explicit sync parent/child and automation read/write columns.
- Some bases are both upstream and downstream of each other. Those are intentional feedback loops, especially around Fillout, ANCHOR, Eligibility, Project Documents, and Progress Tracker.
- Automation counts are local table counts with automation metadata, not automation step counts.
