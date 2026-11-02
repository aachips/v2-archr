---
document_name: Application 
document_type: Technical Specification
version: 1.0
last_updated: 2024-12-10
author: ARCHR Development Team
contributors: Product Owner, Database Architect
status: Ready for Implementation
review_date: 2024-12-17
audience: Developers, Database Administrators, System Architects
complexity_level: Intermediate to Advanced
estimated_reading_minutes: 30
tags: [workflow, postgresql, triggers, notifications, eligibility]
---

# Application Submission & Triage Workflow
## PostgreSQL Implementation Guide for ARCHR Platform

### Document Purpose

This document defines the complete submission-to-triage pipeline for home repair applications, including:
- Optional requestor account creation
- Real-time notifications for staff
- FIFO (First-In-First-Out) review queue
- "Accept until disqualification" eligibility logic
- Anchor registration for all applications (including ineligible)

---

## Process Flow Overview

```mermaid
graph TB
    subgraph "Applicant Journey"
        A[Start Intake Form] --> B[Complete 14 Pages]
        B --> C{Create Account?}
        C -->|Yes| D[Set Password]
        C -->|No| E[Continue as Guest]
        D --> F[Requestor Dashboard Access]
        E --> G[Email-only Updates]
    end

    subgraph "System Processing"
        B --> H[Validate Submission]
        H --> I[Generate Application Record]
        I --> J[ANCHOR: Register Application]
        J --> K[Run Eligibility Checker]
        K --> L{Eligible?}
        L -->|Yes| M[Mark: PENDING_REVIEW]
        L -->|No| N[Mark: INELIGIBLE]
        N --> O[Record Reason Codes]
    end

    subgraph "Staff Notifications"
        M --> P[Trigger: NEW_APPLICATION]
        P --> Q[Push to Review Queue]
        Q --> R[Notify Roles via Dashboard]
        R --> S[Email Digest to Staff]
    end

    subgraph "Review Queue"
        Q --> T[FIFO Order by submitted_at]
        T --> U[Admin View]
        T --> V[Caseworker View]
        T --> W[Project Manager View]
        U --> X[Assign to Organization]
        V --> Y[Initial Triage]
        W --> Z[Resource Planning]
    end

    subgraph "Requestor Experience"
        D --> AA[Login to Dashboard]
        F --> AB[View Status]
        G --> AC[Click Email Link]
        AA --> AD[Upload Documents]
        AB --> AE[See Eligibility Results]
        AD --> AF[Secure Document Storage]
    end