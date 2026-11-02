---
document_name: REQUESTOR_PORTAL_SOP_v1
document_type: Standard Operating Procedure
version: 1.0
last_updated: 2024-12-09
author: ARCHR Development Team
contributors: Product Team, Caseworker Team, Compliance
status: Draft
review_date: 2025-01-15
audience: Applicants (Requestors), Caseworkers, Project Managers, System Administrators
complexity_level: Beginner
estimated_reading_minutes: 20
tags: [requestor, applicant-portal, case-tracking, communication-log, document-upload]
---

A Requestor, or a Referrer, is somebody who fills out and submits the Intake Application for Home Repair Assistance. They might also be referred to as a Homeowner, an Applicant, or a Client. This is a member of our community with unserved home repair needs. They may have some technical literacy and comfort, or none at all. We can help fill out your form if you call our office during work hours.

A Requestor can fill out as many of these forms as they can and want to. Only one application per household will exist at a given time, and we will defer to the most recent submission for accurate up to date information. However, if your entire neighborhood is impacted by an event, and many homes need home repairs, our system is built to facilitate multiple forms being completed. 

Currently there is not an offline sync, meaning if you have no internet, there are challenges to completing and submitting the intake form. We are improving our system and user experience so that this is no longer an issue. 

This includes creating, upon submission of an intake form, a Requestor account on the application. The Requestor can easily opt out and not use this account, but it exists to keep track of where their application is in the pipeline, what communications and alerts need to happen, and what needs to happen to move forward.
## What They Need To Do

+ Submit a home repair application, once, or several times for different households
+ Track application status - Can be done through the application, or by calling our office
+ Upload verification documents - Helpful, but we can also come to the Requestor or reach out to make this happen
+ Review and sign contracts as needed
+ Communicate with case worker or project manager as needed
+ Schedule an assessment or workdays

### Getting Started

 If you fill out an application requestion home repair assistance, you have the option to utilize an application dashboard to track your application eligibility review and status. Whether you participate in the platform or not, we can contact you by email or phone from your contact information provided to get in touch. When there is an interaction, such as with a project manager, those interactions need to get logged in a communication log. This is something that needs to be standardized operating procedure, because the developers look stupid when duplicate and parallel communication occur. You have a way to receive messages on the platform, but those messages also are an email. You can review and edit your application. When those changes occur, they need to be logged in a progress tracker, which is a ledger like tool tracking changes in a case file. You would have a way there to upload your documentation, in a way that is encrypted, safe, and secure. And you can sign onto a contract through the platform, or sign other verification documents. Managing roles could communicate assessment windows and work availability for scheduling purposes. On the dashboard you would have an overview for {myApplication}, having the {nextStep}. There would be a box with contact information for an ARCHR representative. There would be a list of [updates] with rows containing {latestEvents} and a go-to button. There would be a section showing Eligibility array [eligibleFor] with organizations that they qualify for the home repair program. You can see [messages] as a list with {latestMessages} with a go to button. You'd have Button Actions for: Continue (open page:/requiredInfo), Organization (open page:/orgDetails), Read Message (open page:/messageDetails) and Event Details (open page:/eventDetails).  

## What They Need To See (Dashboard)

| Element | What It Shows |
|---------|---------------|
| **My Application** | Case number, status, submission date |
| **Next Step** | What they need to do next |
| **Contact Information** | Who to contact and how |
| **Eligibility Array** | Which organizations they qualify for |
| **Updates** | Recent timeline events |
| **Messages** | Latest communications |

## What They Need To Create/Update

| Action | Description |
|--------|-------------|
| **Submit Application** | Complete all 14 pages of intake form |
| **Upload Documents** | Photos of income proof, ID, etc. |
| **Sign Documents** | e-signature on contracts |
| **Edit Contact Info** | Update phone, email, address |

## Who They Interact With

| Person | Interaction |
|--------|-------------|
| **Caseworker** | Primary point of contact |
| **Assessor** | For home inspection appointments |
| **Project Manager** | For project updates |
| **System** | Automated status updates |

## What Would Frustrate Them

| Frustration | Why It Matters |
|-------------|----------------|
| Too many steps | May abandon application |
| Technical jargon | Won't understand or trust |
| No status updates | Will call staff repeatedly |
| Can't use phone | Many only have mobile access |
| Duplicate requests | Feels like bureaucracy |

## What's The Impact?

| If They Do Well | If They Don't |
|-----------------|---------------|
| Home repaired | Home remains damaged |
| Family safe | Safety risk continues |
| Community trusts us | Community distrusts ARCHR |
| Referrals to others | Negative word of mouth |

---

## Initial Assumptions to Validate

- [ ] Most requestors have mobile phones, not computers
- [ ] Many have limited digital literacy
- [ ] Spanish language support is essential
- [ ] Email is not reliable for all
- [ ] They need clear, simple instructions
- [ ] They want to know "what happens next"
- [ ] They may not understand "caseworker" or "eligibility"
- [ ] They may not know which organization serves them

---


heads up display

My Application - A Requestor should be able to see the page and details of their own Applications they have submitted. With the ability to make edits on certain fields, and reach out via our chat support to dispute other information and request changes. The short of this is a box containing the status, application number, and submission date, with an option link to see more.

Next Step - view the next step needed to move application along pipeline, with due date and action item such as Upload Now

Contact information - contact for a case worker or project manager at office who can take your call during working hours. Has name, email, phone number, and hours available.

Eligibility - Views current up to date Eligibility Report on who they qualify for home repair assistance from, along with their green yellow and red flags. Robots don't determine eligibility, but they flag criteria for human review and determination. From this widget you can click a link to view eligibility details for each organization.

Updates / Timeline - Views latest three timestamped updates on your application, with option to view all updates

Messages - Messages sent to your email. Helpful if homeowner isn't one filling out intake, or able to check email. Standard practice to cc the mailserver host email for this to operate.

Action Buttons:
+ Continue
+ Organization
+ Read Message
+ Event Details


# Requestor (Applicant) Portal Standard Operating Procedure
## Application Tracking, Communication, & Document Management for Home Repair Applicants

### Document Purpose

This SOP defines the Requestor-facing interface of the ARCHR platform, allowing applicants to track their application status, communicate with staff, upload documents, sign contracts, and manage their case. It establishes standardized communication logging procedures to prevent duplicate or parallel communications across email, phone, and platform messaging.

---

## Table of Contents

- [Requestor (Applicant) Portal Standard Operating Procedure](#requestor-applicant-portal-standard-operating-procedure)
  - [Application Tracking, Communication, \& Document Management for Home Repair Applicants](#application-tracking-communication--document-management-for-home-repair-applicants)
    - [Document Purpose](#document-purpose)
  - [Table of Contents](#table-of-contents)
  - [Portal Overview \& User Journey {#portal-overview}](#portal-overview--user-journey-portal-overview)
    - [Requestor Role Definition](#requestor-role-definition)
    - [User Journey Map](#user-journey-map)

---

## Portal Overview & User Journey {#portal-overview}

### Requestor Role Definition

**Requestor** - An individual who has submitted an ARCHR intake application for home repair assistance. Requestors may:
- Track application status through eligibility review
- Receive and respond to communications from ARCHR staff
- Upload required documentation (income proof, photos, etc.)
- Review and sign contracts and verification documents
- View which organizations they qualify for
- Schedule assessment appointments

### User Journey Map

```mermaid
graph TD
    A[Submit Application] --> B[Access Dashboard]
    B --> C{Application Status}
    C -->|Pending Review| D[View Eligibility Array]
    C -->|Assessment Scheduled| E[Schedule/Confirm Appointment]
    C -->|Approved| F[Review Contract]
    C -->|Documents Needed| G[Upload Documentation]
    C -->|Denied/Ineligible| H[View Reason & Appeal]
    
    D --> I[Wait for Assignment]
    I --> J[Organization Claims Case]
    J --> K[Caseworker Assigned]
    K --> E
    
    E --> L[Assessment Complete]
    L --> M[Estimate Approved]
    M --> F
    
    F --> N[Sign Contract]
    N --> O[Work Scheduled]
    O --> P[Work In Progress]
    P --> Q[Final Inspection]
    Q --> R[Certificate of Completion]
    
    subgraph "Communication Flow"
        S[Platform Message] --> T[Email Sent]
        U[Phone Call] --> V[Log Added]
        W[Staff Note] --> X[Visible to Applicant]
    end


    ### Dashboard Component Specifications

| Component               | Description                           | Data Source                               | Refresh Rate         |
| ----------------------- | ------------------------------------- | ----------------------------------------- | -------------------- |
| **My Application**      | Case number, status, submission date  | `cases` table                             | Real-time            |
| **Next Step**           | Action required from applicant        | `case_statuses`, `required_actions`       | Real-time            |
| **Contact Information** | Assigned caseworker details           | `case_assignments`, `system_users`        | On assignment change |
| **Eligibility Array**   | Organizations applicant qualifies for | `application_match_scores`                | On review completion |
| **Updates**             | Timeline of case events               | `case_status_history`, `progress_tracker` | Real-time            |
| **Messages**            | Communication threads                 | `case_communications`                     | Real-time            |
| **Action Buttons**      | Contextual navigation                 | Dynamic based on status                   |                      |
