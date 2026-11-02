
---
  "document_name": "ASSESSOR_ROLE_TECHNICAL_BLUEPRINT_v1",
  "document_type": "Technical Specification",
  "version": "1.0",
  "last_updated": "2024-12-18",
  "author": "ARCHR Development Team",
  "contributors": "Product Owner, UX Designer, Database Architect",
  "status": "Draft for Review",
  "review_date": "2024-12-23",
  "audience": "Developers, UX/UI Designers, Assessor Role Stakeholders",
  "complexity_level": "Advanced",
  "estimated_reading_minutes": 30,
  "tags": ["assessor", "field-work", "mobile-first", "doorDash-analogy", "document-verification"]
---

# Assessor Role

The Assessor role is designed for **field-based, non-technical users** who may not be employees of ARCHR. The interface must be:

- **Mobile-first** (works on phone in the field)
- **Simple** (one primary action per screen)
- **Offline-capable** (can work without internet)
- **Photo-heavy** (upload before/during/after)
- **Low-barrier** (minimal training required)

### Who is an Assessor?

|Type|Example|Engagement Model|
|---|---|---|
|**Staff Assessor**|ARCHR employee|Full-time, salaried|
|**Contract Assessor**|Independent inspector|Per-assessment fee|
|**Community Assessor**|Pastor with a tape measure|Volunteer/stipend|
|**Crew Lead**|Construction supervisor|Part of repair team|

## Assessor Dashboard Layout

### Heads UP Display

Message at top of page. Can be welcome message. Can be helpful context for navigating the dashboard and knowing what you can do.
### Sidebar
+ Who Am I?
+ Todays Assessments
+ Assessment Marketplace
+ Last Assessment Overview
+ Assessment Calendar
+ Messages and Alerts
### Last Assessment Overview
**Purpose:** Quick resume of most recent work

| Field      | Data Source                       | Display                       |
| ---------- | --------------------------------- | ----------------------------- |
| Address    | `intake_submissions.home_address` | Bold, large text              |
| Next Step  | `progress_tracker` latest action  | Action required               |
| Holding On | `progress_tracker` blocker        | What's preventing progress    |
| Status     | `cases.status`                    | Visual indicator (pill/badge) |
Includes option to edit if information is wrong. That activity is logged in activity log.

### Assessment Calendar 
Calendar keeps schedule of assessments, sends out reminder day before. Option to add assessment into calendar.
### Todays Assessments
Messages - For ARCHR Internal, if you want for messages to display to recipient in dashboard, please cc mailserver email.
### Action Buttons
+ Assess
+ Verify
+ Read Message
+ Schedule
+ Process
+ Edit
### Assessment Actions
+ Assess Issue
+ Create Tasks
+ Take Notes
### Document Verification
+ Verify Income
+ Verify Ownership
+ Collect Photo ID
### Communications
+ With Requestor
+ With Organization
+ Schedule Assessment
### Subcontractors
+ Review New Subcontractor
+ Communicate with Subcontractor
+ Schedule Quote

### Mobile Phone + Tablet Display

Assessment Display
+ Address
+ Time
+ Distance
+ Start Action Button

Photo Capture
+ Before Photos
+ Take Photos on Solocator
+ Download Solocator App

Task Review
 + List of reported issues and basic application info with option to edit or dispute or flag
 + Name of homeowner and address, option to pull up address on default map app
 + Session persistence, and offline app persistence. If app recaches/resets on device, and requestor is offline with no internet, need way to ensure hope is not lost.

## What They Need To See (Dashboard)

| Element | What It Shows |
|---------|---------------|
| **Last Assessment** | Quick resume of most recent work |
| **Assessment Calendar** | Today's schedule with times |
| **Today's Assessments** | List with address, time, distance |
| **Previous Assessments** | History of completed assessments |
| **Messages** | Latest communications |

## What They Need To Create/Update

| Action | Description |
|--------|-------------|
| **Create Assessment** | New property inspection record |
| **Upload Photos** | Before, during, after documentation |
| **Record Measurements** | Room dimensions, damage area, etc. |
| **Create Tasks** | Repair task list from assessment |
| **Take Notes** | Client conversations, observations |
| **Verify Documents** | Income, ownership, ID |
| **Update Schedule** | Mark complete, reschedule |

## Who They Interact With

| Person | Interaction |
|--------|-------------|
| **Requestor** | On-site at their home |
| **Caseworker** | Share assessment findings |
| **Project Manager** | Coordinate repair scope |
| **Subcontractors** | Quote coordination |
| **Administrator** | Status reporting |

## What Would Frustrate Them

| Frustration          | Why It Matters             |
| -------------------- | -------------------------- |
| Can't work offline   | No internet in some areas  |
| Complex forms        | Wastes time in the field   |
| Duplicate data entry | Adds extra work            |
| Can't upload photos  | Core part of their job     |
| Poor navigation      | Hard to find appointment   |
| No phone support     | Most use phone, not laptop |

## What's The Impact?

| If They Do Well           | If They Don't               |
| ------------------------- | --------------------------- |
| Accurate repair estimates | Wrong scope of work         |
| Clear task assignments    | Confusion on site           |
| Happy clients             | Unhappy, frustrated clients |
| Efficient process         | Delays and rework           |

---

## Initial Assumptions to Validate

- [ ] Most work from mobile phone (not computer)
- [ ] Need offline capability in rural areas
- [ ] Photos are essential documentation
- [ ] Assessment takes 30-60 minutes on site
- [ ] Travel between appointments is significant
- [ ] They need directions to properties
- [ ] Some may be non-staff contractors
- [ ] Spanish speaking may be needed
- [ ] They need to collect physical documents




### Component 4: Previous Assessments List

**Purpose:** History of completed assessments

|Column|Data Source|Display|
|---|---|---|
|Date|`property_assessments.assessment_date`|Formatted date|
|Address|`intake_submissions.home_address`|Short address|
|Status|`property_assessments.status`|completed, draft, rejected|
|Actions|-|View, Edit, Resubmit|



### Component 5: Messages List

Latest communications requiring attention

Sender - `case_communications.from_user_id` - |Name + role|
Subject - `case_communications.subject` - |Truncated|
Time - `case_communications.sent_at` - |Relative time|
Unread - `case_communications.is_read` - |Indicator|




## Implementation 

+ [_] Create Assessment Schema Tables for Tasks, Assessments, Verifications
+ [ ] Build Assessment list View for Today and Upcoming Assessments
+ [ ] Build Assessment Detail View - Single Assessment with all data
+ [ ] Implement a check-in/out for location tracking and timestamps
+ [ ] Build mobile assessment form  for repair areas, photos, measurements
+ [ ] Implement offline caching to store data locally and sync later
+ [ ] Build photo upload flow for before/during/after categories
+ [ ] Implement notes system for structured and free text notes
+ [ ] Build verification list for pending verificatoins
+ [ ] Implement income verification for POI verification flow
+ [ ] Implement ownership verification for deed/tax record verification
+ [ ] Implement ID collection - photo ID upload and verification
+ [ ] Build subcontractor review for reviewing new subcontractor applications
+ [ ] Implement quote scheduling for scheduling subcontractor visits and quote bidding
+ [ ] Build communication logs for auto-logging all interactions
+ [ ] Implement calendar sync for Assessment calendar integration


## User Persona: The Assessor

### Role Definition

**Assessor** conducts property inspections, documents repair needs, verifies applicant information, and collects evidence for case determination.

### Primary Responsibilities

|Responsibility|Description|Frequency|
|---|---|---|
|**Property Assessment**|Visit site, take measurements, photos, notes|Per assignment|
|**Document Verification**|Verify income, ownership, identity in person|Per assignment|
|**Task Creation**|Create repair task list from assessment|Per assignment|
|**Communication**|Schedule visits, follow up with clients|Ongoing|
|**Subcontractor Coordination**|Review, communicate, schedule quotes|As needed|

### Key Characteristics

- **Field-based** - Works outside the office
- **Mobile-dependent** - Primary interface is phone/tablet
- **Time-constrained** - Travel + assessment windows
- **Non-technical** - May not be comfortable with complex software
- **High-touch** - Direct client interaction required

## Success Criteria

### Quantitative

|Metric|Target|
|---|---|
|Assessment completion time|< 60 minutes average|
|Photo upload success rate|> 95%|
|Offline sync success|> 99%|
|Verification accuracy|> 98%|
|User satisfaction|> 4/5 stars|

### Qualitative

- Assessor can complete assessment with one hand (phone in other)
- Assessor can work offline and sync later
- All communications are automatically logged
- Documents are verified once, no duplicate work
- Assessment creates actionable repair tasks automatically