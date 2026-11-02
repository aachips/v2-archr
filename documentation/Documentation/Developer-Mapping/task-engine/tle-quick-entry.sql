-- =========================================================================
-- TLE QUICK ENTRIES (Unverified - Raw from users)
-- =========================================================================

CREATE TABLE tle_quick_entries (
    id BIGSERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    
    -- Minimal fields (what the user enters)
    description TEXT NOT NULL,
    entry_date DATE NOT NULL,
    entry_time TIME,
    user_initials VARCHAR(10) NOT NULL,
    created_by INTEGER REFERENCES system_users(id),
    
    -- Entry type
    entry_type VARCHAR(20) DEFAULT 'task', -- task, event, communication
    
    -- Status
    status VARCHAR(20) DEFAULT 'unverified', -- unverified, verified, approved, rejected
    
    -- Review tracking
    reviewed_by INTEGER REFERENCES system_users(id),
    reviewed_at TIMESTAMP,
    review_notes TEXT,
    verified_at TIMESTAMP,
    approved_at TIMESTAMP,
    
    -- For grouping duplicates
    duplicate_group_id UUID,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_quick_entries_case (case_id),
    INDEX idx_quick_entries_status (status),
    INDEX idx_quick_entries_date (entry_date DESC)
);

-- =========================================================================
-- APPROVED TASKS (Generated from quick entries + review)
-- =========================================================================

CREATE TABLE tle_approved_tasks (
    id BIGSERIAL PRIMARY KEY,
    quick_entry_id INTEGER REFERENCES tle_quick_entries(id),
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    
    -- Structured fields
    task_code VARCHAR(50), -- matches task_definitions.task_code
    description TEXT NOT NULL,
    priority INTEGER DEFAULT 2, -- 1=highest, 5=lowest
    status VARCHAR(20) DEFAULT 'active', -- active, in_progress, completed, on_hold, cancelled
    
    -- Assignment
    assigned_to_role VARCHAR(50),
    assigned_to_user_id INTEGER REFERENCES system_users(id),
    assigned_at TIMESTAMP,
    
    -- Dates
    due_date DATE,
    completed_at TIMESTAMP,
    started_at TIMESTAMP,
    
    -- Parent/child relationships
    parent_task_id INTEGER REFERENCES tle_approved_tasks(id),
    
    -- Additional fields
    subtasks JSONB DEFAULT '[]', -- array of subtask objects
    notes TEXT,
    attachments JSONB DEFAULT '[]',
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES system_users(id),
    updated_by INTEGER REFERENCES system_users(id),
    
    INDEX idx_approved_tasks_case (case_id),
    INDEX idx_approved_tasks_status (status),
    INDEX idx_approved_tasks_assigned (assigned_to_role, assigned_to_user_id),
    INDEX idx_approved_tasks_parent (parent_task_id),
    INDEX idx_approved_tasks_due (due_date)
);

-- =========================================================================
-- COMMUNICATION LOGS (Quick entries that become logs)
-- =========================================================================

CREATE TABLE tle_communication_logs (
    id BIGSERIAL PRIMARY KEY,
    quick_entry_id INTEGER REFERENCES tle_quick_entries(id),
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    
    -- Communication details
    channel VARCHAR(30), -- email, phone, sms, in_person, platform
    direction VARCHAR(20), -- inbound, outbound
    with_person VARCHAR(200),
    subject VARCHAR(500),
    body TEXT,
    
    -- Timestamps
    occurred_at TIMESTAMP,
    logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Follow-up
    requires_follow_up BOOLEAN DEFAULT FALSE,
    follow_up_date DATE,
    follow_up_note TEXT,
    follow_up_completed_at TIMESTAMP,
    
    -- Audit
    logged_by INTEGER REFERENCES system_users(id),
    updated_by INTEGER REFERENCES system_users(id),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_comm_logs_case (case_id),
    INDEX idx_comm_logs_date (occurred_at DESC),
    INDEX idx_comm_logs_follow_up (requires_follow_up, follow_up_date)
);

-- =========================================================================
-- REVIEW QUEUE VIEW (For approvers)
-- =========================================================================

CREATE OR REPLACE VIEW tle_review_queue AS
SELECT 
    qe.id AS quick_entry_id,
    qe.case_id,
    qe.description,
    qe.entry_date,
    qe.entry_time,
    qe.user_initials,
    qe.entry_type,
    qe.created_at,
    c.case_number,
    s.applicant_first_name,
    s.applicant_last_name,
    s.home_address,
    -- Time in queue
    EXTRACT(HOUR FROM (CURRENT_TIMESTAMP - qe.created_at)) AS hours_in_queue,
    -- Priority based on aging
    CASE 
        WHEN EXTRACT(HOUR FROM (CURRENT_TIMESTAMP - qe.created_at)) > 48 THEN 'urgent'
        WHEN EXTRACT(HOUR FROM (CURRENT_TIMESTAMP - qe.created_at)) > 24 THEN 'high'
        WHEN EXTRACT(HOUR FROM (CURRENT_TIMESTAMP - qe.created_at)) > 12 THEN 'normal'
        ELSE 'low'
    END AS review_priority
FROM tle_quick_entries qe
JOIN cases c ON qe.case_id = c.id
JOIN intake_submissions s ON c.submission_id = s.id
WHERE qe.status = 'unverified'
ORDER BY qe.created_at ASC;

-- =========================================================================
-- METRICS VIEWS (Only includes approved tasks)
-- =========================================================================

CREATE OR REPLACE VIEW tle_task_metrics AS
SELECT 
    -- Status counts
    COUNT(*) FILTER (WHERE status = 'active') AS active_tasks,
    COUNT(*) FILTER (WHERE status = 'in_progress') AS in_progress_tasks,
    COUNT(*) FILTER (WHERE status = 'completed') AS completed_tasks,
    COUNT(*) FILTER (WHERE status = 'on_hold') AS on_hold_tasks,
    
    -- Overdue
    COUNT(*) FILTER (WHERE due_date < CURRENT_DATE AND status NOT IN ('completed', 'cancelled')) AS overdue_tasks,
    
    -- By role
    jsonb_object_agg(
        assigned_to_role,
        COUNT(*)
    ) FILTER (WHERE assigned_to_role IS NOT NULL) AS tasks_by_role,
    
    -- Recently updated
    COUNT(*) FILTER (WHERE updated_at > CURRENT_TIMESTAMP - INTERVAL '7 days') AS updated_this_week,
    
    -- Total
    COUNT(*) AS total_approved_tasks
FROM tle_approved_tasks;

-- =========================================================================
-- QUICK ADD FUNCTION
-- =========================================================================

CREATE OR REPLACE FUNCTION tle_quick_add(
    p_case_id INTEGER,
    p_description TEXT,
    p_user_id INTEGER,
    p_user_initials VARCHAR(10)
)
RETURNS JSONB AS $$
DECLARE
    v_entry_id INTEGER;
BEGIN
    INSERT INTO tle_quick_entries (
        case_id,
        description,
        entry_date,
        entry_time,
        user_initials,
        created_by,
        entry_type,
        status
    ) VALUES (
        p_case_id,
        p_description,
        CURRENT_DATE,
        CURRENT_TIME,
        p_user_initials,
        p_user_id,
        'task',
        'unverified'
    ) RETURNING id INTO v_entry_id;
    
    RETURN jsonb_build_object(
        'success', true,
        'entry_id', v_entry_id,
        'message', 'Task added to unverified queue. A reviewer will standardize and approve it.'
    );
END;
$$ LANGUAGE plpgsql;

-- =========================================================================
-- REVIEW & APPROVE FUNCTION
-- =========================================================================

CREATE OR REPLACE FUNCTION tle_approve_task(
    p_quick_entry_id INTEGER,
    p_reviewer_id INTEGER,
    p_structured_data JSONB
)
RETURNS JSONB AS $$
DECLARE
    v_quick_entry RECORD;
    v_new_task_id INTEGER;
BEGIN
    -- Get the quick entry
    SELECT * INTO v_quick_entry 
    FROM tle_quick_entries 
    WHERE id = p_quick_entry_id AND status = 'unverified';
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Quick entry not found or already verified'
        );
    END IF;
    
    -- Mark quick entry as verified
    UPDATE tle_quick_entries 
    SET 
        status = 'verified',
        reviewed_by = p_reviewer_id,
        reviewed_at = CURRENT_TIMESTAMP,
        verified_at = CURRENT_TIMESTAMP
    WHERE id = p_quick_entry_id;
    
    -- Create approved task from structured data
    INSERT INTO tle_approved_tasks (
        quick_entry_id,
        case_id,
        task_code,
        description,
        priority,
        status,
        assigned_to_role,
        assigned_to_user_id,
        due_date,
        subtasks,
        notes,
        created_by
    ) VALUES (
        p_quick_entry_id,
        v_quick_entry.case_id,
        p_structured_data->>'task_code',
        COALESCE(p_structured_data->>'description', v_quick_entry.description),
        (p_structured_data->>'priority')::INTEGER,
        p_structured_data->>'status',
        p_structured_data->>'assigned_to_role',
        NULL,
        (p_structured_data->>'due_date')::DATE,
        COALESCE(p_structured_data->'subtasks', '[]'::JSONB),
        p_structured_data->>'notes',
        p_reviewer_id
    ) RETURNING id INTO v_new_task_id;
    
    -- Update the quick entry with reference
    UPDATE tle_quick_entries 
    SET approved_at = CURRENT_TIMESTAMP 
    WHERE id = p_quick_entry_id;
    
    RETURN jsonb_build_object(
        'success', true,
        'task_id', v_new_task_id,
        'message', 'Task approved and added to active tasks'
    );
END;
$$ LANGUAGE plpgsql;