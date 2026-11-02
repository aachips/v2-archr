---
document_name: Roles & Access Levels — Who Sees What in ARCHR
document_type: Standard Operating Procedure
version: 1.0
last_updated: 2026-08-01
author: ARCHR Development Team
audience: Admins, Super-Admins, Organizational Administrators
complexity_level: Intermediate
estimated_reading_minutes: 8
tags: [roles, permissions, access, SOP]
visibility: authenticated
---

## Decision 1 — What's the default landing view per role?

The question: When an Admin / PM / Crew / Volunteer logs into Archer, what's the first thing they see, and in what layout?

  

What Softr offers for collection views:

  

- List (with sub-layouts: cards, small cards, timeline, inbox)
    
- Grid (image-forward cards)
    
- Table (spreadsheet, dense scanning)
    
- Kanban (column-grouped board, drag-to-update)
    
- Calendar (date-anchored)
    
- Map (location-anchored)
    
- Org chart (hierarchical, niche)
    

  

Sub-layout call-outs:

  

- Inbox layout (Pro plan+) — left sidebar list, right pane shows the selected item's details. Strong fit for triage/queue work where users process items one at a time. Worth prototyping for the triage queue.
    
- Timeline (Business plan+) — vertical date-anchored list. Useful for activity history.
    

  

Patrick's starting recommendation:

  

- Admin → Inbox layout for triage; Table view available as a secondary tab for bulk review
    
- PM → Kanban grouped by phase as primary; List as secondary
    
- Crew → List (cards) filtered to "my assigned work this week"
    
- Volunteer → List (cards) filtered to "available to claim"
    

  

Need from Ben: Confirm role priorities, push back where the work pattern is different from what I'm assuming.  
  
  

|   |   |   |   |
|---|---|---|---|
|Role Priority Hierarchy (top 3)|   |   |   |
|Role|1st|2nd|3rd|
|Admin|Confirm Eligibility|Contact/Schedule|Edit Triage|
|Notes:|Filter: Confirmed Eligible!=✅  <br>List: sorted by Triage 9-1, Date1-9|List: sorted by Triage 9-1, Date1-9, last Contact:9-1|List: sorted by Triage 9-1, Date1-9  <br>Automatic Triage will sort “New Applicant List” and will|
|Project Manager|Active Projects|Upcoming Projects|Past Projects|
|Notes|Filter: Projects Status = Active  <br>Cards:|Filter: Confirmed Eligible=✅, Status!=Active\|Closed|Status=Closed|
|Crew|Add Notes, Photos, Timesheets, Mark Repair Tasks Complete|Review Upcoming Projects|Review Past Projects|
|Notes|Details: Mobile Friendly|Cards: Mobile Friendly||
|Volunteer|See Upcoming Projects|Review Past Projects|Set Preferences|
|Notes|No PII, No Address until Signed In|Scope of Work, Site Lead, Dates, Notes|Set Liked&Disliked Trades/Tasks, Emergency Contacts, Dietary Restrictions, etc|


Level 11: ARCHR SuperAdmin
Primary Responsibilities: Oversee system and platform, monitor bug reporting, documentation, and live support as needed.
Information Access: Everything
Action Permissions: Everything

    ↓

Level 10: Admin (Full system access)
Primary Responsibilities: System configuration, user management, org settings, eligibility rules
Information Access: Full system access within organization
Action Permissions: CRUD all records, manage users, configure rules

    ↓

Level 9:  Project Manager (Oversees projects)
Primary Responsibilities: Oversees multiple projects, budget tracking, timeline management
Information Access: All projects within organization, budgets, timelines, subcontractor quotes
Action Permissions: Approve estimates, manage budget, coordinate resources

    ↓

Level 8:  Bursar (Financial - separate track)
Primary Responsibilities: Financial management, payments, invoicing, funding tracking
Information Access: Financial data, payments, invoices, funding sources
Action Permissions: Process payments, create invoices, track expenses

    ↓

Level 7:  Caseworker (Manages cases)
Primary Responsibilities: Primary point of contact, manages, applicant communication, coordinates services
Information Access: All cases assigned to their org, applicant contact info
Action Permissions: Update case status, communicate with applicants, request additional information

    ↓

Level 6:  Assessor (Technical evaluation)
Primary Responsibilities: Conducts home visits, evaluates repair needs, creates estimates
Information Access: Case files assigned to them, property details
Action Permissions: View cases, add assessments, upload photos, create estimates

    ↓

Level 5:  Crew Lead (On-site supervision)
Primary Responsibilities: Manages on-site repair crew, schedules work, ensures quality
Information Access: Active repair projects, crew assignments, materials list
Action Permissions: Assign crew members, update work progress, request materials

    ↓

Level 4:  Subcontractor (Specialized trade)
Primary Responsibilities: External trade specialist (plumbing, electrical, etc.)
Information Access: Specific repair categories assigned to them
Action Permissions: View assigned repairs, submit quotes, report completion

    ↓

Level 3:  Envoy (Community support)
Primary Responsibilities: Community Liaison, outreach, applicant support
Information Access: Basic case information, applicant contact information
Action Permissions: View case status, add notes, assist applicants with forms

Organizational and program specific, not really project oriented


    ↓

Level 2:  Crew Member (Physical work)
Primary Responsibilities: Performs actual repair work
Information Access: Daily assignments, task lists, safety information, hour logging
Action Permissions: View tasks, mark complete, report issues

    ↓

Level 1:  Requestor (Application only)
Primary Responsibilities: Submits initial intake application, uploads documents
Information Access: Own submissions only
Action Permissions: Create, vew own, edit until submitted

    ↓

Level 0:  Volunteer (Limited assistance)
Primary Responsibilities: Unpaid helpers, supervised by Crew Lead
Information Access: Limited task assignments, safety information
Action Permissions: View assigned tasks, log hours