---
document_name: ARCHR_CORE_TERMINOLOGY_AND_OPERATIONAL_LOGIC
document_type: Technical Reference
version: 1.0
last_updated: 2026-08-17
author: ARCHR Development Team
audience: All Platform Users, Developers, System Administrators
complexity_level: Intermediate
estimated_reading_minutes: 12
tags: [glossary, data-model, logic, workflow, eligibility]
---
### Glossary of Core Terms

#### The Hierarchical Relationship

┌──────────────────────────────────────────────────────────────┐
│                    THE HIERARCHY                                               
├──────────────────────────────────────────────────────────────┤
│                                                                                  
│  SUBMISSION (Form Response)                                                     
│       │                                                                         
│       ▼ (Deduplication)                                                         
│  APPLICATION (Single Entry, All Repair Needs for a Placecode)                  
│       │                                                                         
│       ▼ (Claimed by Organization)                                               
│  CASE (Organization-Specific Instance of Application)                          
│       │                                                                         
│       ▼ (Repair Need Grouped)                                                   
│  PROJECT (Child of Case, Specific Repair Scope)                                
│       │                                                                         
│       ▼ (Individual Work Items)                                                 
│  REPAIR TASK (Smallest Unit of Work)                                           
│                                                                                  
└──────────────────────────────────────────────────────────────┘

### Submission

**Definition:** The raw form response from an applicant.

**Characteristics:**

- One or more submissions may exist for the same household
- Submissions can be duplicates, errors, or follow-ups
- Submissions are the _source material_ for applications

**What It Contains:**

- Form field responses
- Submission timestamp
- IP address / source information
- Raw data before processing

**Example:**

> _"A homeowner submits the intake form on Monday, and again on Wednesday because they forgot to upload their income documents."_

---
### Application

**Definition:** A single, deduplicated entry that holds all repair needs for a location/Placecode at given time.

**Characteristics:**

- Programmatically condensed from one or more submissions
- Unique to a household/property location
- Persistent across time and organizations
- Inactive/Inert when no unmet needs
- The "source of truth" for all case data

**What It Contains:**

- Submissions (links to all form responses)
- Dates (submission, updates, milestones)
- Notes (internal and external)
- Documents (income proof, ID, etc.)
- Before Photos (property condition)
- Eligibility Reports (flags, not decisions)
- Logged Communication (all interactions)
- Assessments (inspection reports)
- Repair Needs (identified issues)
- Claims (which organizations are involved)
- Cases (organization-specific interactions, projects, Scopes of work)

**Example:**

> _"42-CHERRY is an application. It has two submissions (Monday and Wednesday), three repair needs (roof, plumbing, electrical), and has been claimed by two organizations."_

---

### Case

**Definition:** An organization-specific instance of an Application that has been claimed.

**Characteristics:**

- Created when an organization claims Repair Need(s)
- One Application may have multiple Cases (if multiple organizations are involved)
- Cases share documents at the Application layer
- Each Case has its own lifecycle, tasks, and completion status
    

**What It Contains:**

- Reference to the parent Application
- Claiming Organization ID
- Case-specific timeline
- Case-specific documents (program specific & project-level)
- Case-specific tasks (processing) and milestones
- Case-specific completion status

**Example:**

> _"Habitat for Humanity claims 42-CHERRY for the roof repair. CHC claims the same Application for the plumbing repair. Two Cases, one Application."_

---

### Project

**Definition:** A child object of a Case, representing a specific set of repair tasks.

**Characteristics:**

- Created when repair tasks are grouped into a scope
- One Case may have multiple Projects (if multiple programs / funding sources used)
- A Project is essentially a "batch" of repairs
- Contains all financial and operational data for that batch

**What It Contains:**

- Project Name/Code
- Specific Repairs (tasks included)
- Repair Costs (budgeted and expensed)
- Repair Tasks (individual work items)
- Timeline (start, milestones, completion)
- Scope of Work
- Progress Notes and During Photos
- Contract
- Subcontractors Used
- After Photos
- Invoices


**Example:**

> _"The Habitat Case for 42-CHERRY has two Projects: 'Phase 1: Roof Replacement' and 'Phase 2: Interior Restoration'."_

---

### Repair Task

**Definition:** The smallest unit of work. A single, actionable repair item.

**Characteristics:**

- Belongs to a Project
- Assigned to a work crew or subcontractor
- Binary Completion - Yes or No
- Can be tracked independently

**What It Contains:**

- Task Name/Description
- Assigned To (person/role)
- Budgeted Cost and Expensed Cost
- Volunteer Profile (volunteer friendly? how many slots?)
- library item, library trade, library interaction
- Status (pending, in progress, complete, blocked)
- Due Date
- Completion Date
- Notes
- (optional) Repair need being addressed

**Example:**

> _"Replace damaged shingles on the east side of the roof" is a Repair Task within the "Roof Replacement" Project._

## Part 2: Status States & Lifecycle

### Application Statuses

|Status|Definition|Trigger|
|---|---|---|
|**Active**|Default status|Application created|
|**New**|Recently submitted|Within 14 days of submission|
|**Concluded**|All repairs completed|All Cases completed/no unmet needs|
|**Terminated**|Applicant ineligible or failed to follow up|Human decision + checkboxes|
|**Withdrawn**|Applicant no longer needs assistance|Human interaction only|
|**Expired**|Application claim expired after 90-day cooldown|No progress tasks for 90 days|

### Status Flow

┌───────────────────────────────────────────┐
│                    APPLICATION STATUS FLOW                                   
├───────────────────────────────────────────┤
│                                                                                 
│                      ┌─────────────┐                                          
│                      │   NEW       │                                          
│                      │ (0-14 days) │                                          
│                      └──────┬──────┘                                          
│                             │                                                  
│                             ▼                                                  
│                      ┌─────────────┐                                          
│                      │   ACTIVE    │                                          
│                      └──────┬──────┘                                          
│                             │                                                  
│         ┌───────────────────┼───────────────────┐                              
│         │                   │                   │                                                       
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                       
│  │  EXPIRED    │    │  WITHDRAWN  │    │  TERMINATED │                       
│  │(90-day timer│    │(Human only) │    │(Human + why)│                       
│  │  expired)   │    └─────────────┘    └─────────────┘                       
│  └─────────────┘                                                              
│         │                                                                      │
│         ▼                                                                      │
│  ┌────────────────────────────────────────────────────────┐   │
│  │  CONCLUDED  │  (All repairs completed)                                   │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                                                  │
└───────────────────────────────────────────────────────────────────┘

## Part 3: The 90-Day Progress Cooldown

### Concept

When an organization claims an Application, they enter a **90-day window** to make progress. If no progress tasks associated with their Organization ID occur within that window, the claim expires.

### How It Works

┌─────────────────────────────────────────────────────────────────────────────────┐
│                    90-DAY PROGRESS COOLDOWN                                    │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  TIMER STARTS: Organization claims the Application                      │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                   │                                             │
│                                   ▼                                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  PROGRESS EVENT: Any task, communication, milestone , or other interaction               │   │
│  │  → Timer resets to 90 days                                             │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                   │                                             │
│                                   ▼                                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  NO PROGRESS EVENT for 90 days                                          │   │
│  │  → Claim expires                                                       │   │
│  │  → Claimed Repair Needs becomes available for other organizations               │   │
│  │  → Status changes to "Expired"                                         │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘

### Key Rules

|Rule|Description|
|---|---|
|**Claim ownership**|Claim is tied to Organization ID|
|**Progress events**|Any progress task tied to Org ID resets the timer|
|**90-day reset**|Timer resets to 90 days on each progress event|
|**Expiration**|No progress for 90 days → claim expires|
|**Re-claiming**|Expired Applications can be claimed by other organizations|

---

## Part 4: Eligibility Philosophy

### The Problem

> _"We are collecting extra documentation and performing additional admin work in order to have less restrictive funding sources."_

### The Reality

Of 1,000 applications historically in the coalition:

- **60 were deemed ineligible due to income** (0.6%)
    
- **Hundreds of thousands of dollars** spent on administrative labor and verification
    
- **All that work to disqualify less than 1% of applicants**
    

### The Question

> _"Do we keep pumping money into not helping people get home repairs? Or just use that money to repair peoples' homes?"_

### The Tension

Funding sources dictate requirements. Without their capital, the coalition is locked to the most restrictive qualifications.

**The administrative burden of compliance is preventing help from reaching people.**

---

### Eligibility Approach

|Principle|Implementation|
|---|---|
|**Assume eligibility**|Default to "eligible" unless disqualifying evidence exists|
|**Flag, don't decide**|System surfaces green/yellow/red flags for human review|
|**No automated denials**|Final determinations are made by humans, not algorithms|
|**Checkbox denials**|When terminating an application, checkboxes explain why|
|**No withdrawal without interaction**|Withdrawals require human contact with the applicant|

---

## Part 5: Technical Implementation

### Database Schema: Core Tables
```
-- =========================================================================
-- SUBMISSIONS (Raw form responses)
-- =========================================================================
CREATE TABLE submissions (
    id SERIAL PRIMARY KEY,
    submission_guid UUID DEFAULT gen_random_uuid() UNIQUE,
    form_data JSONB NOT NULL,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address INET,
    user_agent TEXT,
    source_url VARCHAR(500),
    is_duplicate BOOLEAN DEFAULT FALSE,
    duplicate_group_id UUID,
    deduplicated_into INTEGER REFERENCES applications(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================================================================
-- APPLICATIONS (Deduplicated single entry per household/placecode)
-- =========================================================================
CREATE TABLE applications (
    id SERIAL PRIMARY KEY,
    application_guid UUID DEFAULT gen_random_uuid() UNIQUE,
    placecode VARCHAR(50) UNIQUE, -- e.g., "42-CHERRY"
    
    -- Core data (deduplicated from submissions)
    property_address TEXT NOT NULL,
    property_city VARCHAR(100),
    property_state VARCHAR(50),
    property_zip VARCHAR(20),
    applicant_first_name VARCHAR(100),
    applicant_last_name VARCHAR(100),
    applicant_email VARCHAR(255),
    applicant_phone VARCHAR(20),
    household_size INTEGER,
    
    -- Status
    status VARCHAR(20) DEFAULT 'new', -- new, active, concluded, terminated, withdrawn, expired
    status_reason TEXT,
    terminated_reason_checkboxes TEXT[], -- Checkbox items explaining denial
    
    -- Eligibility (flags, not decisions)
    eligibility_flags JSONB DEFAULT '{"green": [], "yellow": [], "red": []}'::jsonb,
    eligibility_report TEXT,
    
    -- Metadata
    submission_ids INTEGER[], -- References to all submissions
    consolidated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    consolidated_by INTEGER REFERENCES system_users(id),
    
    -- Lifecycle
    last_activity_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_applications_placecode (placecode),
    INDEX idx_applications_status (status),
    INDEX idx_applications_zip (property_zip),
    INDEX idx_applications_last_activity (last_activity_at)
);

-- =========================================================================
-- CASES (Organization-specific instances of Applications)
-- =========================================================================
CREATE TABLE cases (
    id SERIAL PRIMARY KEY,
    case_guid UUID DEFAULT gen_random_uuid() UNIQUE,
    application_id INTEGER REFERENCES applications(id) ON DELETE CASCADE,
    organization_id INTEGER REFERENCES coalition_organizations(id),
    
    -- Claim tracking
    claimed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    claimed_by INTEGER REFERENCES system_users(id),
    claim_expires_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL '90 days'),
    claim_status VARCHAR(20) DEFAULT 'active', -- active, expired, released
    
    -- Progress tracking
    last_progress_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    progress_events_count INTEGER DEFAULT 0,
    
    -- Status
    case_status VARCHAR(20) DEFAULT 'active',
    completed_at TIMESTAMP,
    
    -- Org-specific notes
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(application_id, organization_id),
    INDEX idx_cases_application (application_id),
    INDEX idx_cases_organization (organization_id),
    INDEX idx_cases_claim_expires (claim_expires_at),
    INDEX idx_cases_last_progress (last_progress_at)
);

-- =========================================================================
-- PROJECTS (Child of Case, specific repair scope)
-- =========================================================================
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    project_guid UUID DEFAULT gen_random_uuid() UNIQUE,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    project_name VARCHAR(200) NOT NULL,
    project_code VARCHAR(50),
    
    -- Scope
    scope_description TEXT,
    repair_tasks JSONB DEFAULT '[]'::jsonb, -- Array of Repair Task objects
    
    -- Financial
    budget_approved DECIMAL(12,2),
    budget_actual DECIMAL(12,2),
    cost_remaining DECIMAL(12,2),
    
    -- Timeline
    start_date DATE,
    estimated_completion DATE,
    actual_completion DATE,
    
    -- Status
    project_status VARCHAR(20) DEFAULT 'planned', -- planned, active, completed, on_hold, cancelled
    
    -- Documents
    after_photos JSONB DEFAULT '[]'::jsonb,
    invoices JSONB DEFAULT '[]'::jsonb,
    completion_certificate_url TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_projects_case (case_id),
    INDEX idx_projects_status (project_status)
);

-- =========================================================================
-- PROGRESS EVENTS (Immutable log for cooldown tracking)
-- =========================================================================
CREATE TABLE progress_events (
    id SERIAL PRIMARY KEY,
    event_guid UUID DEFAULT gen_random_uuid() UNIQUE,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    organization_id INTEGER REFERENCES coalition_organizations(id),
    
    -- Event details
    event_type VARCHAR(50) NOT NULL, -- task_created, task_updated, comm_logged, document_uploaded, assessment_completed, etc.
    event_description TEXT,
    event_source VARCHAR(50), -- system, user, api
    
    -- User context
    performed_by INTEGER REFERENCES system_users(id),
    performed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Tracking
    is_progress_event BOOLEAN DEFAULT TRUE, -- Does this reset the 90-day timer?
    is_immutable BOOLEAN DEFAULT TRUE, -- Cannot be deleted or modified
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_progress_events_case (case_id),
    INDEX idx_progress_events_org (organization_id),
    INDEX idx_progress_events_performed (performed_at DESC),
    INDEX idx_progress_events_type (event_type)
);
```

### Core Logic Functions

```
-- =========================================================================
-- DEDUPLICATION: Consolidate Submissions into Applications
-- =========================================================================
CREATE OR REPLACE FUNCTION deduplicate_submissions(
    p_submission_id INTEGER
)
RETURNS INTEGER AS $$
DECLARE
    v_application_id INTEGER;
    v_placecode VARCHAR(50);
    v_submission RECORD;
BEGIN
    -- Get the submission
    SELECT * INTO v_submission FROM submissions WHERE id = p_submission_id;
    
    -- Generate placecode from address
    v_placecode := generate_placecode(
        v_submission.form_data->>'home_address',
        v_submission.form_data->>'home_city'
    );
    
    -- Check if an application already exists for this placecode
    SELECT id INTO v_application_id 
    FROM applications 
    WHERE placecode = v_placecode;
    
    IF v_application_id IS NULL THEN
        -- Create new application
        INSERT INTO applications (
            placecode,
            property_address,
            property_city,
            property_state,
            property_zip,
            applicant_first_name,
            applicant_last_name,
            applicant_email,
            applicant_phone,
            household_size,
            status,
            submission_ids,
            consolidated_at
        ) VALUES (
            v_placecode,
            v_submission.form_data->>'home_address',
            v_submission.form_data->>'home_city',
            v_submission.form_data->>'home_state',
            v_submission.form_data->>'home_zip',
            v_submission.form_data->>'applicant_first_name',
            v_submission.form_data->>'applicant_last_name',
            v_submission.form_data->>'contact_email',
            v_submission.form_data->>'home_phone',
            (v_submission.form_data->>'household_size')::INTEGER,
            'new',
            ARRAY[p_submission_id],
            CURRENT_TIMESTAMP
        ) RETURNING id INTO v_application_id;
        
        -- Mark submission as deduplicated
        UPDATE submissions 
        SET deduplicated_into = v_application_id,
            is_duplicate = FALSE
        WHERE id = p_submission_id;
        
    ELSE
        -- Add to existing application
        UPDATE applications 
        SET submission_ids = array_append(submission_ids, p_submission_id),
            updated_at = CURRENT_TIMESTAMP
        WHERE id = v_application_id;
        
        -- Mark submission as duplicate
        UPDATE submissions 
        SET deduplicated_into = v_application_id,
            is_duplicate = TRUE
        WHERE id = p_submission_id;
    END IF;
    
    RETURN v_application_id;
END;
$$ LANGUAGE plpgsql;

-- =========================================================================
-- CLAIM <strike>APPLICATION</strike> REPAIR NEED  (Create Case)
-- =========================================================================
CREATE OR REPLACE FUNCTION claim_application(
    p_application_id INTEGER,
    p_organization_id INTEGER,
    p_claimed_by INTEGER
)
RETURNS INTEGER AS $$
DECLARE
    v_case_id INTEGER;
    v_application RECORD;
BEGIN
    -- Check if application is already claimed by this org
    SELECT id INTO v_case_id 
    FROM cases 
    WHERE application_id = p_application_id 
      AND organization_id = p_organization_id;
    
    IF v_case_id IS NOT NULL THEN
        -- Case already exists, just reactivate
        UPDATE cases 
        SET claim_status = 'active',
            claim_expires_at = CURRENT_TIMESTAMP + INTERVAL '90 days',
            updated_at = CURRENT_TIMESTAMP
        WHERE id = v_case_id;
        
        RETURN v_case_id;
    END IF;
    
    -- Get application
    SELECT * INTO v_application FROM applications WHERE id = p_application_id;
    
    -- Create case
    INSERT INTO cases (
        application_id,
        organization_id,
        claimed_at,
        claimed_by,
        claim_expires_at,
        claim_status,
        last_progress_at
    ) VALUES (
        p_application_id,
        p_organization_id,
        CURRENT_TIMESTAMP,
        p_claimed_by,
        CURRENT_TIMESTAMP + INTERVAL '90 days',
        'active',
        CURRENT_TIMESTAMP
    ) RETURNING id INTO v_case_id;
    
    -- Update application status to active
    UPDATE applications 
    SET status = 'active',
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_application_id;
    
    -- Log progress event
    INSERT INTO progress_events (
        case_id,
        organization_id,
        event_type,
        event_description,
        performed_by
    ) VALUES (
        v_case_id,
        p_organization_id,
        'case_claimed',
        'Application claimed by organization',
        p_claimed_by
    );
    
    RETURN v_case_id;
END;
$$ LANGUAGE plpgsql;

-- =========================================================================
-- PROGRESS EVENT & COOLDOWN TIMER
(Isolate these two systems. Progress events need to be handling. Timer is separate counter living under claims)
-- =========================================================================
CREATE OR REPLACE FUNCTION log_progress_event(
    p_case_id INTEGER,
    p_event_type VARCHAR,
    p_event_description TEXT,
    p_performed_by INTEGER
)
RETURNS INTEGER AS $$
DECLARE
    v_event_id INTEGER;
    v_organization_id INTEGER;
BEGIN
    -- Get organization ID from case
    SELECT organization_id INTO v_organization_id 
    FROM cases 
    WHERE id = p_case_id;
    
    -- Insert progress event
    INSERT INTO progress_events (
        case_id,
        organization_id,
        event_type,
        event_description,
        performed_by,
        is_progress_event
    ) VALUES (
        p_case_id,
        v_organization_id,
        p_event_type,
        p_event_description,
        p_performed_by,
        TRUE
    ) RETURNING id INTO v_event_id;
    
    -- Reset the 90-day cooldown timer
    UPDATE cases 
    SET last_progress_at = CURRENT_TIMESTAMP,
        claim_expires_at = CURRENT_TIMESTAMP + INTERVAL '90 days',
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_case_id;
    
    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql;

-- =========================================================================
-- CHECK & EXPIRE EXPIRED CLAIMS (Run as scheduled job)
-- =========================================================================
CREATE OR REPLACE FUNCTION expire_stale_claims()
RETURNS TABLE(
    case_id INTEGER,
    application_id INTEGER,
    organization_id INTEGER,
    days_since_progress INTEGER
) AS $$
DECLARE
    v_case RECORD;
BEGIN
    FOR v_case IN 
        SELECT 
            c.id,
            c.application_id,
            c.organization_id,
            EXTRACT(DAY FROM (CURRENT_TIMESTAMP - c.last_progress_at)) AS days_idle
        FROM cases c
        WHERE c.claim_status = 'active'
          AND c.claim_expires_at < CURRENT_TIMESTAMP
    LOOP
        -- Update case status to expired
        UPDATE cases 
        SET claim_status = 'expired',
            updated_at = CURRENT_TIMESTAMP
        WHERE id = v_case.id;
        
        -- Check if any other active claims exist for this application
        IF NOT EXISTS (
            SELECT 1 FROM cases 
            WHERE application_id = v_case.application_id 
              AND claim_status = 'active'
              AND id != v_case.id
        ) THEN
            -- No active claims left, update application status
            UPDATE applications 
            SET status = 'expired',
                updated_at = CURRENT_TIMESTAMP
            WHERE id = v_case.application_id;
        END IF;
        
        -- Return expired case info
        case_id := v_case.id;
        application_id := v_case.application_id;
        organization_id := v_case.organization_id;
        days_since_progress := v_case.days_idle;
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
```

### Daily Expiration Check

```
-- Run daily via cron or pg_cron
-- SELECT * FROM expire_stale_claims();

```

## Part 6: Business Rules Reference

### Status Transition Rules

|From|To|Allowed?|Conditions|
|---|---|---|---|
|New|Active|✅|Claimed by organization|
|New|Expired|❌|Cannot expire before 14 days|
|Active|Expired|✅|No progress events for 90 days|
|Active|Concluded|✅|All repairs completed|
|Active|Terminated|✅|Human decision + checkbox reasons|
|Active|Withdrawn|✅|Human interaction required|
|Expired|Active|✅|Re-claimed by an organization|
|Terminated|Active|❌|Final state|
|Withdrawn|Active|❌|Final state|
|Concluded|Active|❌|Final state| 
(allow if new submission is received)

### Eligibility Decision Rules

| Decision         | Allowed By             | System Behavior                        |
| ---------------- | ---------------------- | -------------------------------------- |
| **Eligible**     | Human reviewer         | System surfaces green flags            |
| **Ineligible**   | Human reviewer         | System surfaces red flags + checkboxes |
| **Needs Review** | Human reviewer         | System surfaces yellow flags           |
| **Withdrawn**    | Human interaction only | System requires contact note           |
| **Terminated**   | Human reviewer         | System requires checkbox reasons       |

### Termination Checkboxes (Required Fields)
``` 
{
  "termination_reasons": [
    "Income above program limits",
    "Property outside service area",
    "Damage not within program focus area",
    "Applicant unresponsive after 3 contact attempts",
    "Previously served by another organization",
    "Applicant declined services",
    "Unable to verify homeownership",
    "Other (please specify)"
  ]
}
```

### Example API Response

GET/api/applications/:id

```
{
  "application": {
    "id": 1234,
    "placecode": "42-CHERRY",
    "status": "active",
    "submission_ids": [456, 789],
    "property_address": "42 Cherry St",
    "property_city": "Asheville",
    "property_state": "NC",
    "property_zip": "28801",
    "applicant_first_name": "John",
    "applicant_last_name": "Henderson",
    "household_size": 4,
    "eligibility_flags": {
      "green": ["income_verified", "helene_related"],
      "yellow": ["gis_owner_match_partial"],
      "red": []
    },
    "cases": [
      {
        "id": 5678,
        "organization": "Habitat for Humanity",
        "claim_status": "active",
        "claim_expires_at": "2025-03-15T14:30:00Z",
        "days_until_expiry": 45,
        "last_progress_at": "2025-01-02T09:00:00Z",
        "projects": [
          {
            "id": 9012,
            "name": "Phase 1: Roof Replacement",
            "status": "active",
            "budget_approved": 15000.00,
            "budget_actual": 12000.00,
            "repair_tasks": [
              {
                "id": 1,
                "description": "Remove damaged shingles",
                "status": "completed",
                "completed_at": "2025-01-10"
              },
              {
                "id": 2,
                "description": "Install new underlayment",
                "status": "in_progress"
              }
            ]
          }
        ]
      }
    ]
  }
}
```

## Part 8: Summary Table

|Term|Definition|Contains|Parent Of|
|---|---|---|---|
|**Submission**|Raw form response|Form data, timestamp|Application (via deduplication)|
|**Application**|Deduplicated household entry|Submissions, documents, cases|Cases|
|**Case**|Organization-specific claimed repair needs|Projects, progress events|Projects|
|**Project**|Specific repair scope|Repair tasks, budget, invoices|Repair Tasks|
|**Repair Task**|Smallest work unit|Description, assignee, status|None|

---

_This document is the source of truth for core terminology and operational logic. All system behavior should align with these definitions._`