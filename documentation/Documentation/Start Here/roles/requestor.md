The Single Source of Truth Principle
RULE: All communications about a case MUST be logged in the platform's communication log. Email and phone are delivery methods, NOT storage locations.

Communication Flow Diagram
text
                    ┌─────────────────────────────────────────┐
                    │         CASE COMMUNICATION LOG          │
                    │         (Single Source of Truth)        │
                    └─────────────────────────────────────────┘
                                      │
            ┌─────────────────────────┼─────────────────────────┐
            │                         │                         │
            ▼                         ▼                         ▼
    ┌───────────────┐         ┌───────────────┐         ┌───────────────┐
    │  EMAIL SENT   │         │  SMS SENT     │         │ PHONE CALL    │
    │  (via system) │         │  (via system) │         │  LOGGED MANUAL│
    └───────────────┘         └───────────────┘         └───────────────┘
            │                         │                         │
            └─────────────────────────┼─────────────────────────┘
                                      │
                                      ▼
                            ┌───────────────────┐
                            │  APPLICANT VIEWS  │
                            │  Platform Message │
                            │  Center           │
                            └───────────────────┘
Communication Types & Logging Requirements
Communication Type	Platform Log Required	Auto-Logged?	Manual Entry Required
In-platform message	✓	✓	No
Email sent via system	✓	✓	No
Email sent manually (external)	✓	✗	Yes (copy to platform)
Phone call	✓	✗	Yes (summary required)
SMS/Text	✓	✓ (if using Twilio/etc)	If not integrated
In-person conversation	✓	✗	Yes (notes required)
Mail (physical letter)	✓	✗	Yes (scan & upload)
Staff Protocol for Communication
markdown
## BEFORE ANY COMMUNICATION:

1. CHECK the communication log for the case
   - View last contact date
   - Review outstanding questions
   - Note any pending actions

2. VERIFY no duplicate active threads
   - Same question asked by applicant? (check last 7 days)
   - Same information already provided?

3. CHOOSE appropriate channel
   - Urgent/time-sensitive: Phone call + platform message
   - Documentation needed: Email + platform message
   - Simple update: Platform message only (auto-emailed)

## DURING COMMUNICATION:

4. LOG all interactions IMMEDIATELY
   - Create entry in case_communications table
   - Include timestamp, summary, action items
   - Attach any files or transcripts

5. SET next steps
   - Define who needs to respond
   - Set follow-up reminder if needed

## AFTER COMMUNICATION:

6. SYNCHRONIZE external communications
   - Copy external email to platform (forward to case-specific address)
   - Upload call notes within 1 hour
   - Attach any written correspondence

7. UPDATE applicant dashboard if needed
   - Change status if applicable
   - Update next step indicator
Communication Log Entry Template
yaml
---
communication_id: comm_20241209_001234
case_id: ARCHR-2024-001234
direction: outbound
channel: phone_call
initiated_by: sarah.martinez@archr.org (Caseworker)
recipient: john.smith@email.com (Applicant)
timestamp: 2024-12-09T14:30:00-05:00
duration_minutes: 15
summary: |
  Discussed income documentation requirements. Applicant needs to upload 
  last 3 months of bank statements and most recent pay stub.
action_items:
  - actor: applicant
    action: upload_income_docs
    due_date: 2024-12-20
  - actor: caseworker
    action: review_documents
    due_date: 2024-12-22
follow_up_required: true
follow_up_date: 2024-12-18
transcript_available: false
notes: "Applicant sounded anxious but understood requirements."
---
Preventing Duplicate Communications: The 24-Hour Rule
sql
-- Function to check for recent similar communication
CREATE OR REPLACE FUNCTION check_recent_communication(
    p_case_id INTEGER,
    p_communication_type VARCHAR,
    p_hours_window INTEGER DEFAULT 24
)
RETURNS BOOLEAN AS $$
DECLARE
    v_recent_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_recent_count
    FROM case_communications
    WHERE case_id = p_case_id
      AND communication_type = p_communication_type
      AND sent_at > NOW() - (p_hours_window || ' hours')::INTERVAL
      AND (summary ILIKE '%document%' OR summary ILIKE '%upload%' 
           OR summary ILIKE '%required%' OR summary ILIKE '%need%');
    
    -- Return TRUE if similar communication exists (warning)
    RETURN v_recent_count > 0;
END;
$$ LANGUAGE plpgsql;

-- Trigger to warn staff before duplicate
-- (Implementation in application layer)
Progress Tracker & Change Ledger {#progress-tracker}
Ledger Concept
The Progress Tracker is an immutable ledger of all changes to a case file, similar to a blockchain transaction log. Every change is recorded with:

Who made the change

When it was made

What changed (old value → new value)

Why it changed (reason/note)

Which version resulted

Progress Tracker Schema
sql
-- Progress tracker (immutable ledger)
CREATE TABLE progress_tracker (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    
    -- Change metadata
    changed_by INTEGER REFERENCES system_users(id),
    changed_by_role VARCHAR(50), -- requestor, caseworker, assessor, etc.
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- What changed
    entity_type VARCHAR(50), -- application, document, status, assignment, etc.
    entity_id VARCHAR(100), -- specific field or document ID
    field_name VARCHAR(100),
    
    -- Before/after
    old_value TEXT,
    new_value TEXT,
    
    -- Reason
    change_reason TEXT,
    change_type VARCHAR(50), -- user_edit, system_update, staff_review, etc.
    
    -- Versioning
    version_number INTEGER,
    is_current BOOLEAN DEFAULT TRUE,
    
    -- Client visibility
    visible_to_applicant BOOLEAN DEFAULT TRUE,
    internal_note TEXT, -- Staff-only note
    
    INDEX idx_progress_case (case_id, changed_at DESC),
    INDEX idx_progress_version (case_id, version_number)
);

-- Function to add ledger entry
CREATE OR REPLACE FUNCTION log_progress_change(
    p_case_id INTEGER,
    p_entity_type VARCHAR,
    p_entity_id VARCHAR,
    p_field_name VARCHAR,
    p_old_value TEXT,
    p_new_value TEXT,
    p_change_reason TEXT,
    p_changed_by INTEGER,
    p_visible_to_applicant BOOLEAN DEFAULT TRUE
)
RETURNS INTEGER AS $$
DECLARE
    v_new_version INTEGER;
    v_new_id INTEGER;
BEGIN
    -- Get next version number
    SELECT COALESCE(MAX(version_number), 0) + 1 INTO v_new_version
    FROM progress_tracker
    WHERE case_id = p_case_id;
    
    -- Mark previous entry for this field as not current
    UPDATE progress_tracker
    SET is_current = FALSE
    WHERE case_id = p_case_id
      AND entity_type = p_entity_type
      AND entity_id = p_entity_id
      AND field_name = p_field_name
      AND is_current = TRUE;
    
    -- Insert new entry
    INSERT INTO progress_tracker (
        case_id, changed_by, entity_type, entity_id, field_name,
        old_value, new_value, change_reason, version_number,
        visible_to_applicant, changed_at
    ) VALUES (
        p_case_id, p_changed_by, p_entity_type, p_entity_id, p_field_name,
        p_old_value, p_new_value, p_change_reason, v_new_version,
        p_visible_to_applicant, CURRENT_TIMESTAMP
    ) RETURNING id INTO v_new_id;
    
    RETURN v_new_id;
END;
$$ LANGUAGE plpgsql;

-- Example usage:
-- SELECT log_progress_change(123, 'application', 'contact_email', 'email',
--                           'old@email.com', 'new@email.com', 
--                           'Applicant requested update', 456, TRUE);
Progress Tracker UI Display
text
┌─────────────────────────────────────────────────────────────────┐
│  PROGRESS TIMELINE                                              │
│  ─────────────────────────────────────────────────────────────── │
│                                                                  │
│  ┌───┬─────────────────────────────────────────────────────────┐ │
│  │ ✓ │ Dec 5, 2024 - Income Documents Requested               │ │
│  │   │ Caseworker Sarah requested bank statements and pay stub │ │
│  │   │ [View Request Details]                                  │ │
│  ├───┼─────────────────────────────────────────────────────────┤ │
│  │ ✓ │ Dec 3, 2024 - Application Assigned to Habitat           │ │
│  │   │ Your application was matched with Habitat for Humanity  │ │
│  │   │ [View Organization Details]                             │ │
│  ├───┼─────────────────────────────────────────────────────────┤ │
│  │ ✓ │ Nov 28, 2024 - Eligibility Review Started               │ │
│  │   │ Your application is being reviewed by our team          │ │
│  │   │ Estimated completion: 7-10 business days                │ │
│  ├───┼─────────────────────────────────────────────────────────┤ │
│  │ ● │ Nov 15, 2024 - Application Submitted                    │ │
│  │   │ Your application #ARCHR-2024-001234 was received        │ │
│  └───┴─────────────────────────────────────────────────────────┘ │
│                                                                  │
│  [View Full Timeline] [Download Timeline Report]                │
└─────────────────────────────────────────────────────────────────┘
Document Upload & Security {#document-upload}
Document Types & Security Levels
Document Type	Encryption	Retention	Access
Income Verification	AES-256	7 years	Caseworker + Finance
ID/Identification	AES-256	3 years	Caseworker only
Property Photos	AES-256	Permanent	All assigned staff
Signed Contracts	AES-256	Permanent + 10 years	Legal + Caseworker
Medical/Disability Docs	AES-256 + PII	3 years	Restricted
Secure Upload Flow
sql
-- Document upload tracking with encryption metadata
CREATE TABLE secure_document_uploads (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id),
    upload_id UUID DEFAULT gen_random_uuid() UNIQUE,
    
    -- Document metadata
    document_type VARCHAR(50) REFERENCES document_categories(category_code),
    original_filename VARCHAR(255),
    storage_path VARCHAR(1000), -- Encrypted path reference
    
    -- Encryption
    encryption_key_id VARCHAR(100), -- Reference to KMS key
    encrypted_at TIMESTAMP,
    encryption_algorithm VARCHAR(50) DEFAULT 'AES-256-GCM',
    
    -- Status
    status VARCHAR(20) DEFAULT 'uploaded', -- uploaded, processing, verified, rejected
    verified_by INTEGER REFERENCES system_users(id),
    verified_at TIMESTAMP,
    rejection_reason TEXT,
    
    -- Tracking
    uploaded_by INTEGER REFERENCES system_users(id),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    viewed_by TEXT[], -- Audit log of who accessed
    expires_at TIMESTAMP,
    
    INDEX idx_uploads_case (case_id),
    INDEX idx_uploads_status (status)
);
Upload Workflow for Requestors
markdown
## Document Upload Instructions (shown to Requestor)

1. **Click "Upload Documents"** on your dashboard
2. **Select document type** from dropdown
3. **Choose file** from your device
   - Accepted formats: PDF, JPG, PNG
   - Max file size: 25MB per file
4. **Add description** (optional but helpful)
5. **Confirm upload**

## After Upload:

- Documents are encrypted immediately
- Staff will be notified of new upload
- You will receive confirmation email
- Status changes from "Pending" to "Under Review"

## Security Notes:

- All documents are encrypted at rest
- Only assigned caseworkers can view
- Uploads are logged for audit purposes
- You can revoke access at any time
Contract & Document Signing {#contract-signing}
Signing Flow
Signature Schema
sql
-- Signature requests and tracking
CREATE TABLE signature_requests (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id),
    document_id INTEGER REFERENCES case_documents(id),
    
    -- Request details
    requested_by INTEGER REFERENCES system_users(id),
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    required_by DATE, -- Deadline for signature
    
    -- Signer information
    signer_name VARCHAR(200),
    signer_email VARCHAR(255),
    signer_role VARCHAR(50), -- applicant, co-applicant, guarantor
    
    -- Signature data
    signature_type VARCHAR(20), -- typed, drawn, uploaded
    signature_data TEXT, -- Base64 PNG or typed name hash
    signature_ip INET,
    signature_timestamp TIMESTAMP,
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending', -- pending, signed, declined, expired
    declined_reason TEXT,
    
    -- Legal
    ip_address INET,
    user_agent TEXT,
    legal_consent_text TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    
    INDEX idx_signatures_case (case_id, status)
);

-- Generate contract signing URL (time-limited, one-time use)
CREATE OR REPLACE FUNCTION generate_signing_url(
    p_signature_id INTEGER,
    p_expires_hours INTEGER DEFAULT 48
)
RETURNS VARCHAR AS $$
DECLARE
    v_token UUID;
    v_url VARCHAR;
BEGIN
    v_token := gen_random_uuid();
    
    UPDATE signature_requests
    SET signing_token = v_token,
        token_expires_at = NOW() + (p_expires_hours || ' hours')::INTERVAL
    WHERE id = p_signature_id;
    
    v_url := 'https://apply.archr.org/sign/' || v_token;
    
    RETURN v_url;
END;
$$ LANGUAGE plpgsql;
Scheduling & Availability {#scheduling}
Assessment Scheduling Flow
sql
-- Availability windows
CREATE TABLE applicant_availability (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id),
    preferred_days TEXT[], -- ['monday', 'wednesday', 'friday']
    preferred_time_start TIME,
    preferred_time_end TIME,
    blackout_dates DATERANGE[], -- Vacations, medical appointments
    notes TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Scheduled events (assessments, inspections, etc.)
CREATE TABLE scheduled_events (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id),
    event_type VARCHAR(50), -- assessment, final_inspection, material_delivery
    scheduled_start TIMESTAMP NOT NULL,
    scheduled_end TIMESTAMP,
    
    -- Participants
    assigned_staff_id INTEGER REFERENCES system_users(id),
    
    -- Location
    location_address TEXT,
    
    -- Status
    status VARCHAR(20) DEFAULT 'scheduled', -- scheduled, confirmed, rescheduled, completed, cancelled
    confirmation_sent BOOLEAN DEFAULT FALSE,
    confirmed_by_applicant BOOLEAN DEFAULT FALSE,
    confirmed_at TIMESTAMP,
    
    -- Rescheduling
    rescheduled_from_id INTEGER REFERENCES scheduled_events(id),
    reschedule_reason TEXT,
    
    -- Post-event
    completed_at TIMESTAMP,
    completion_notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_events_case (case_id, scheduled_start)
);
Scheduling UI for Requestor
text
┌─────────────────────────────────────────────────────────────────┐
│  SCHEDULE ASSESSMENT                                            │
│  ─────────────────────────────────────────────────────────────── │
│                                                                  │
│  Your caseworker has requested to schedule a home assessment.   │
│                                                                  │
│  Select your preferred date and time:                           │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │  📅 December 2024                                           ││
│  │  ┌────┬────┬────┬────┬────┬────┬────┐                      ││
│  │  │ Mo │ Tu │ We │ Th │ Fr │ Sa │ Su │                      ││
│  │  │ 16 │ 17 │ 18 │ 19 │ 20 │ 21 │ 22 │                      ││
│  │  │    │    │ 🟢 │ 🟢 │ 🟢 │    │    │                      ││
│  │  └────┴────┴────┴────┴────┴────┴────┘                      ││
│  └─────────────────────────────────────────────────────────────┘│
│                                                                  │
│  Available times on Dec 18:                                     │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐            │
│  │ 9:00 AM      │ │ 11:00 AM     │ │ 2:00 PM      │            │
│  │ [Select]     │ │ [Select]     │ │ [Select]     │            │
│  └──────────────┘ └──────────────┘ └──────────────┘            │
│                                                                  │
│  Or suggest alternative: [________________] [Submit Request]    │
│                                                                  │
│  Once confirmed, you will receive:                              │
│  • Email confirmation                                           │
│  • Calendar invitation (.ics)                                   │
│  • Reminder 24 hours before                                     │
└─────────────────────────────────────────────────────────────────┘
Technical Requirements & Schema {#technical-requirements}
Complete Requestor Schema Addition
sql
-- =====================================================
-- REQUESTOR PORTAL SCHEMA EXTENSIONS
-- Extends existing intake_submissions and cases tables
-- =====================================================

-- Requestor-specific profile (extends system_users)
CREATE TABLE requestor_profiles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES system_users(id) UNIQUE,
    
    -- Preferences
    email_notifications_enabled BOOLEAN DEFAULT TRUE,
    sms_notifications_enabled BOOLEAN DEFAULT FALSE,
    portal_access_enabled BOOLEAN DEFAULT TRUE,
    preferred_language VARCHAR(5) DEFAULT 'en',
    
    -- Activity tracking
    last_login TIMESTAMP,
    last_dashboard_view TIMESTAMP,
    total_logins INTEGER DEFAULT 0,
    
    -- Consent
    terms_accepted_version VARCHAR(20),
    terms_accepted_at TIMESTAMP,
    data_processing_consent BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Case assignments (track which org/caseworker owns the case)
CREATE TABLE case_assignments (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id) UNIQUE,
    organization_id INTEGER REFERENCES coalition_organizations(id),
    caseworker_id INTEGER REFERENCES system_users(id),
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_by INTEGER REFERENCES system_users(id),
    is_active BOOLEAN DEFAULT TRUE,
    deassigned_at TIMESTAMP,
    deassign_reason TEXT
);

-- Required actions for applicant
CREATE TABLE required_actions (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id),
    action_type VARCHAR(50) NOT NULL, -- upload_document, sign_contract, confirm_schedule, etc.
    action_description TEXT,
    due_date DATE,
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending', -- pending, completed, waived, expired
    completed_at TIMESTAMP,
    
    -- Related entity
    related_entity_type VARCHAR(50), -- document_id, signature_id, event_id
    related_entity_id INTEGER,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES system_users(id),
    
    INDEX idx_actions_case_status (case_id, status, due_date)
);

-- Eligibility results (cached for dashboard display)
CREATE TABLE eligibility_results (
    id SERIAL PRIMARY KEY,
    submission_id INTEGER REFERENCES intake_submissions(id),
    organization_id INTEGER REFERENCES coalition_organizations(id),
    match_score INTEGER,
    is_eligible BOOLEAN,
    eligible_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP, -- Eligibility recertification date
    notes TEXT,
    
    -- Detailed breakdown
    criteria_met JSONB,
    criteria_missing JSONB,
    
    INDEX idx_eligibility_submission (submission_id, organization_id)
);

-- Function to get eligible organizations for a requestor
CREATE OR REPLACE FUNCTION get_eligible_organizations(p_submission_id INTEGER)
RETURNS TABLE(
    organization_name VARCHAR,
    match_score INTEGER,
    next_steps TEXT,
    contact_info JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        co.organization_name,
        ams.match_score,
        CASE 
            WHEN ams.match_score >= 80 THEN 'Ready for assignment'
            WHEN ams.match_score >= 60 THEN 'Additional documentation needed'
            ELSE 'Manual review required'
        END AS next_steps,
        jsonb_build_object(
            'email', co.contact_email,
            'phone', co.contact_phone,
            'website', co.website_url
        ) AS contact_info
    FROM application_match_scores ams
    JOIN coalition_organizations co ON ams.organization_id = co.id
    WHERE ams.submission_id = p_submission_id
      AND ams.match_score >= 50 -- Show any with reasonable match
    ORDER BY ams.match_score DESC;
END;
$$ LANGUAGE plpgsql;

-- Function to get latest updates for dashboard
CREATE OR REPLACE FUNCTION get_case_updates(p_case_id INTEGER, p_limit INTEGER DEFAULT 10)
RETURNS TABLE(
    event_date TIMESTAMP,
    event_type VARCHAR,
    event_summary TEXT,
    event_details JSONB,
    is_read BOOLEAN
) AS $$
BEGIN
    -- Union of progress tracker and communications
    RETURN QUERY
    SELECT 
        pt.changed_at AS event_date,
        'progress' AS event_type,
        pt.field_name || ' changed from ' || COALESCE(pt.old_value, 'empty') || 
        ' to ' || COALESCE(pt.new_value, 'empty') AS event_summary,
        jsonb_build_object('old', pt.old_value, 'new', pt.new_value, 'reason', pt.change_reason) AS event_details,
        FALSE AS is_read -- Would join to read receipts table
    FROM progress_tracker pt
    WHERE pt.case_id = p_case_id AND pt.visible_to_applicant = TRUE
    
    UNION ALL
    
    SELECT 
        cc.sent_at AS event_date,
        'message' AS event_type,
        cc.subject AS event_summary,
        jsonb_build_object('message_id', cc.id, 'body_preview', LEFT(cc.body, 200)) AS event_details,
        cr.is_read
    FROM case_communications cc
    LEFT JOIN communication_read_receipts cr ON cc.id = cr.communication_id 
        AND cr.user_id = (SELECT user_id FROM cases WHERE id = p_case_id LIMIT 1)
    WHERE cc.case_id = p_case_id AND cc.to_applicant = TRUE
    
    ORDER BY event_date DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;
User Stories & Workflows {#user-stories}
Story 1: First-Time Applicant Dashboard Access
text
As a: Homeowner named Robert
I want to: Access my application dashboard
So that: I can track my repair request status

Acceptance Criteria:
1. Robert submits application and receives confirmation email
2. Email contains unique dashboard link
3. Robert clicks link and sets up password
4. Dashboard shows application status: "Submitted - Pending Review"
5. Next Step displays: "Wait for eligibility determination (3-5 days)"
6. Contact info shows generic ARCHR support (no caseworker yet)
7. Messages show system confirmation of submission
8. Eligible organizations section shows "In Review"
Story 2: Document Request and Upload
text
As a: Applicant named Maria
I want to: Upload requested income documents
So that: My application can proceed to approval

Acceptance Criteria:
1. Dashboard shows "Action Required" banner
2. Next Step shows "Income Documentation Required"
3. Clicking Continue opens document upload page
4. Upload page shows specific requirements
5. Maria uploads 3 PDF files
6. System shows encryption notice and confirmation
7. Status updates to "Documents Received - Under Review"
8. Caseworker receives notification
9. Progress tracker shows document upload event
10. Maria receives confirmation email
Story 3: Communication Logging (Preventing Duplicates)
text
As a: Caseworker named David
I want to: Log a phone call with an applicant
So that: Other staff don't duplicate the conversation

Acceptance Criteria:
1. David calls Maria about missing signature
2. After call, David opens case in staff view
3. David clicks "Log Communication"
4. Selects "Phone Call" as type
5. Enters summary: "Discussed missing signature on page 4"
6. Notes action item: "Resend contract for signature"
7. System checks for recent similar communications
8. No warning (last call was 5 days ago)
9. Log saves to communication_log table
10. Applicant dashboard shows "New Update"
11. If another staff tries to call about same issue, warning appears
Story 4: Contract Signing
text
As a: Approved applicant named James
I want to: Review and sign my repair contract online
So that: Work can begin on my home

Acceptance Criteria:
1. Dashboard shows "Contract Ready for Signature"
2. Next Step shows "Review and Sign Contract (Due: Dec 20)"
3. Clicking Continue opens contract viewer
4. Contract displays all terms, scope, and costs
5. Scroll to bottom for signature field
6. James types name 6. James types name (or draws with mouse/finger)
7. System captures IP address and timestamp
8. "I agree to terms" checkbox required
9. Submit button enabled after all fields complete
10. Confirmation screen shows "Contract Signed"
11. Email with attached PDF sent to James
12. Caseworker notified of completed signature
13. Case status updates to "Contract Signed - Scheduling Work"
14. Progress tracker shows signing event with version

### Story 5: Scheduling Assessment

text

As a: Applicant named Patricia
I want to: Schedule my home assessment
So that: The repair estimate can be completed
Acceptance Criteria:
1. Dashboard shows "Schedule Your Home Assessment"
2. Calendar view with available dates
3. Patricia selects Dec 18, 2:00 PM
4. System confirms availability with staff
5. Patricia receives confirmation email with .ics attachment
6. Dashboard updates Next Step to "Assessment Scheduled for Dec 18"
7. Reminder email sent 24 hours before
8. If Patricia needs to reschedule, she can click "Request Change"
9. Reschedule request logged and staff notified
10. Progress tracker shows scheduling and any changes

---

## Error Handling & Edge Cases

|Scenario|Expected Behavior|
|---|---|
|Applicant forgets password|Password reset via email link (no staff intervention)|
|Document upload fails|Clear error message, retry option, contact support fallback|
|Session timeout|Auto-save draft, redirect to login with return URL|
|Contract signing interrupted|Save progress, resume with same token|
|Duplicate application detection|Warning message, link to existing dashboard|
|Caseworker reassignment|Old caseworker removed, new assigned, notification to applicant|
|Application denied|Clear explanation, appeal button, resources for alternatives|

---

## Document Sign-off

|Role|Name|Date|Signature|
|---|---|---|---|
|Product Owner|________|________|________|
|Compliance Officer|________|________|________|
|Technical Lead|________|________|________|

---

_This SOP is a living document. All communication protocol changes must be reviewed by the Compliance team before implementation._

text

This comprehensive SOP provides:
1. **Complete Requestor Portal specification** with dashboard layout and components
2. **Critical communication protocol** with the "Single Source of Truth" principle to prevent duplicate communications
3. **Immutable progress tracker ledger** for all case changes
4. **Secure document upload** with encryption standards
5. **Contract signing workflow** with legal tracking
6. **Scheduling system** for assessments and appointments
7. **Full SQL schema extensions** for all new functionality
8. **User stories** covering all major workflows
9. **Error handling** for edge cases
The communication logging protocol is particularly important - it establishes clear rules that prevent the duplicate and parallel communications that make developers "look stupid." Every call, email, and message must be logged in the platform as the source of truth.