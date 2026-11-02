-- =========================================================================
-- PROGRESS LEDGER (Immutable - INSERT ONLY)
-- The single source of truth for all case activity
-- =========================================================================

CREATE TABLE progress_ledger (
    id BIGSERIAL PRIMARY KEY,
    
    -- Core identity
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    event_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    event_by INTEGER REFERENCES system_users(id),
    event_by_role VARCHAR(50),
    
    -- Event classification
    event_category VARCHAR(50) NOT NULL, -- task, communication, assessment, document, etc.
    event_type VARCHAR(50) NOT NULL,     -- task_created, task_updated, comm_logged, etc.
    event_action VARCHAR(50),            -- create, update, delete, complete, assign, etc.
    
    -- What changed
    entity_type VARCHAR(50) NOT NULL,    -- task, subtask, communication, document
    entity_id VARCHAR(100) NOT NULL,     -- T001, S001, C001, etc.
    field_name VARCHAR(100),             -- status, assignee, description, etc.
    
    -- Before/After (immutable record)
    old_value TEXT,
    new_value TEXT,
    
    -- Full snapshot (for complex changes)
    snapshot JSONB,
    
    -- Metadata
    change_reason TEXT,
    is_automatic BOOLEAN DEFAULT FALSE,
    source_system VARCHAR(50) DEFAULT 'platform',
    
    -- For duplicate detection
    duplicate_group_id UUID,
    is_duplicate BOOLEAN DEFAULT FALSE,
    merged_into_id BIGINT REFERENCES progress_ledger(id),
    
    INDEX idx_ledger_case (case_id, event_timestamp DESC),
    INDEX idx_ledger_entity (entity_type, entity_id),
    INDEX idx_ledger_event (event_type, event_category),
    INDEX idx_ledger_duplicate (duplicate_group_id)
);

-- =========================================================================
-- TASK DEFINITIONS (What types of tasks exist, with templates)
-- =========================================================================

CREATE TABLE task_definitions (
    id SERIAL PRIMARY KEY,
    task_code VARCHAR(50) UNIQUE NOT NULL, -- ASSESSMENT, VERIFY_INCOME, REPAIR_ROOF
    task_name VARCHAR(200) NOT NULL,
    task_category VARCHAR(50),             -- assessment, verification, repair, communication
    description TEXT,
    
    -- Template structure
    default_priority INTEGER DEFAULT 2,    -- 1=highest, 5=lowest
    estimated_hours DECIMAL(5,2),
    required_roles TEXT[],                 -- who can create/update this task type
    default_subtasks JSONB,                -- array of subtask templates
    
    -- Recurring/repeating
    can_recur BOOLEAN DEFAULT FALSE,
    recurrence_pattern VARCHAR(50),        -- daily, weekly, monthly
    
    -- Constraints
    requires_approval BOOLEAN DEFAULT FALSE,
    max_attempts INTEGER,
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seed default task definitions
INSERT INTO task_definitions (task_code, task_name, task_category, required_roles, default_subtasks) VALUES
('ASSESSMENT', 'Complete Home Assessment', 'assessment', ARRAY['ASSESSOR', 'ADMIN'], 
 '["Schedule appointment", "Conduct inspection", "Take photos", "Submit report"]'),
('VERIFY_INCOME', 'Verify Income Documents', 'verification', ARRAY['CASEWORKER', 'BURSAR', 'ADMIN'],
 '["Request documents", "Receive documents", "Verify documents", "Update eligibility"]'),
('VERIFY_OWNERSHIP', 'Verify Home Ownership', 'verification', ARRAY['CASEWORKER', 'BURSAR', 'ADMIN'],
 '["Request deed/tax record", "Verify ownership", "Update case status"]'),
('CONTRACT_SIGN', 'Contract Signing', 'documentation', ARRAY['PROJECT_MANAGER', 'CASEWORKER'],
 '["Generate contract", "Send to client", "Client signs", "Store signed copy"]'),
('REPAIR_ROOF', 'Roof Repair', 'repair', ARRAY['CREW_LEAD', 'SUBCONTRACTOR'],
 '["Material request", "Schedule work", "Perform repairs", "Final inspection"]'),
('REPAIR_PLUMBING', 'Plumbing Repair', 'repair', ARRAY['CREW_LEAD', 'SUBCONTRACTOR'],
 '["Material request", "Schedule work", "Perform repairs", "Final inspection"]'),
('REPAIR_ELECTRICAL', 'Electrical Repair', 'repair', ARRAY['CREW_LEAD', 'SUBCONTRACTOR'],
 '["Material request", "Schedule work", "Perform repairs", "Final inspection"]');

-- =========================================================================
-- CURRENT TASK STATE (Derived view from ledger)
-- =========================================================================

CREATE OR REPLACE VIEW current_tasks AS
WITH task_events AS (
    SELECT DISTINCT ON (entity_id)
        entity_id AS task_id,
        case_id,
        event_by,
        event_timestamp,
        new_value AS current_status,
        snapshot->>'assignee' AS assignee,
        snapshot->>'priority' AS priority,
        snapshot->>'description' AS description,
        snapshot->'subtasks' AS subtasks,
        snapshot->>'due_date' AS due_date,
        snapshot->>'created_at' AS created_at,
        event_type
    FROM progress_ledger
    WHERE entity_type = 'task'
      AND event_type IN ('task_created', 'task_updated')
    ORDER BY entity_id, event_timestamp DESC
)
SELECT 
    task_id,
    case_id,
    current_status,
    assignee,
    priority,
    description,
    subtasks,
    due_date,
    created_at,
    -- Calculated fields
    CASE 
        WHEN current_status = 'complete' THEN 'completed'
        WHEN due_date < CURRENT_DATE AND current_status != 'complete' THEN 'overdue'
        WHEN current_status = 'in_progress' THEN 'in_progress'
        WHEN current_status = 'pending' THEN 'pending'
        ELSE 'unknown'
    END AS task_phase,
    -- Subtask completion
    CASE 
        WHEN subtasks IS NULL OR jsonb_array_length(subtasks) = 0 THEN 0
        ELSE jsonb_array_length(subtasks) 
    END AS total_subtasks,
    CASE 
        WHEN subtasks IS NULL OR jsonb_array_length(subtasks) = 0 THEN 0
        ELSE (
            SELECT COUNT(*) 
            FROM jsonb_array_elements(subtasks) AS subtask
            WHERE subtask->>'status' = 'complete'
        )
    END AS completed_subtasks
FROM task_events
WHERE current_status != 'deleted';

-- =========================================================================
-- TASK METRICS VIEW (Pre-calculated for dashboard)
-- =========================================================================

CREATE OR REPLACE VIEW task_metrics AS
WITH metrics AS (
    SELECT 
        -- Status counts
        COUNT(*) FILTER (WHERE task_phase = 'pending') AS pending_count,
        COUNT(*) FILTER (WHERE task_phase = 'in_progress') AS in_progress_count,
        COUNT(*) FILTER (WHERE task_phase = 'completed') AS completed_count,
        COUNT(*) FILTER (WHERE task_phase = 'overdue') AS overdue_count,
        
        -- By role
        jsonb_object_agg(
            assignee, 
            jsonb_build_object(
                'pending', COUNT(*) FILTER (WHERE task_phase = 'pending'),
                'in_progress', COUNT(*) FILTER (WHERE task_phase = 'in_progress'),
                'overdue', COUNT(*) FILTER (WHERE task_phase = 'overdue')
            )
        ) FILTER (WHERE assignee IS NOT NULL) AS by_assignee,
        
        -- By category (from task_definitions)
        jsonb_object_agg(
            td.task_category,
            COUNT(*)
        ) FILTER (WHERE td.task_category IS NOT NULL) AS by_category,
        
        -- Priority breakdown
        jsonb_object_agg(
            'priority_' || priority,
            COUNT(*)
        ) FILTER (WHERE priority IS NOT NULL) AS by_priority
        
    FROM current_tasks ct
    LEFT JOIN task_definitions td ON ct.task_id = td.task_code
)
SELECT 
    *,
    -- Calculated rate
    CASE 
        WHEN pending_count + in_progress_count > 0 
        THEN ROUND(completed_count * 100.0 / (pending_count + in_progress_count + completed_count), 1)
        ELSE 0
    END AS completion_rate
FROM metrics;

-- =========================================================================
-- COMMUNICATION LOG (Also stored in ledger)
-- =========================================================================

CREATE OR REPLACE VIEW communication_log AS
SELECT 
    entity_id AS communication_id,
    case_id,
    event_timestamp AS sent_at,
    event_by AS from_user,
    snapshot->>'to_user' AS to_user,
    snapshot->>'channel' AS channel,  -- email, phone, sms, platform, in_person
    snapshot->>'subject' AS subject,
    snapshot->>'body' AS body,
    snapshot->>'is_read' AS is_read,
    snapshot->>'read_at' AS read_at
FROM progress_ledger
WHERE entity_type = 'communication'
  AND event_type = 'comm_logged'
ORDER BY event_timestamp DESC;

-- =========================================================================
-- DUPLICATE DETECTION
-- =========================================================================

CREATE OR REPLACE FUNCTION detect_duplicate_tasks(
    p_case_id INTEGER,
    p_task_type VARCHAR,
    p_description TEXT
)
RETURNS TABLE(duplicate_id VARCHAR, duplicate_status VARCHAR, created_at TIMESTAMP) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ct.task_id,
        ct.current_status,
        ct.created_at::TIMESTAMP
    FROM current_tasks ct
    JOIN progress_ledger pl ON ct.task_id = pl.entity_id
    WHERE ct.case_id = p_case_id
      AND pl.snapshot->>'task_type' = p_task_type
      AND pl.snapshot->>'description' ILIKE '%' || p_description || '%'
      AND ct.current_status != 'completed'
      AND ct.task_phase != 'overdue'
    ORDER BY ct.created_at ASC
    LIMIT 3;
END;
$$ LANGUAGE plpgsql;

-- =========================================================================
-- BULK TASK CREATION
-- =========================================================================

CREATE OR REPLACE FUNCTION create_bulk_tasks(
    p_case_id INTEGER,
    p_task_data JSONB,  -- Array of tasks with subtasks
    p_created_by INTEGER
)
RETURNS TABLE(task_id VARCHAR, success BOOLEAN, message TEXT) AS $$
DECLARE
    v_task JSONB;
    v_task_id VARCHAR;
    v_subtasks JSONB;
BEGIN
    FOR v_task IN SELECT * FROM jsonb_array_elements(p_task_data)
    LOOP
        -- Generate task ID
        v_task_id := 'T' || LPAD(nextval('task_sequence')::TEXT, 5, '0');
        v_subtasks := v_task->'subtasks';
        
        -- Insert into ledger
        INSERT INTO progress_ledger (
            case_id,
            event_by,
            event_by_role,
            event_category,
            event_type,
            entity_type,
            entity_id,
            field_name,
            new_value,
            snapshot,
            change_reason
        ) VALUES (
            p_case_id,
            p_created_by,
            (SELECT role_code FROM user_role_assignments WHERE user_id = p_created_by LIMIT 1),
            'task',
            'task_created',
            'task',
            v_task_id,
            'status',
            'pending',
            jsonb_build_object(
                'task_type', v_task->>'task_type',
                'description', v_task->>'description',
                'priority', COALESCE(v_task->>'priority', '2'),
                'subtasks', v_subtasks,
                'created_at', CURRENT_TIMESTAMP,
                'created_by', p_created_by
            ),
            'Bulk creation'
        );
        
        -- Log each subtask separately
        FOR i IN 0..jsonb_array_length(v_subtasks) - 1 LOOP
            INSERT INTO progress_ledger (
                case_id,
                event_by,
                event_by_role,
                event_category,
                event_type,
                entity_type,
                entity_id,
                field_name,
                new_value,
                snapshot,
                change_reason
            ) VALUES (
                p_case_id,
                p_created_by,
                (SELECT role_code FROM user_role_assignments WHERE user_id = p_created_by LIMIT 1),
                'task',
                'subtask_added',
                'subtask',
                v_task_id || '-' || LPAD(i::TEXT, 2, '0'),
                'description',
                v_subtasks->i->>'description',
                jsonb_build_object(
                    'parent_task', v_task_id,
                    'status', 'pending',
                    'description', v_subtasks->i->>'description'
                ),
                'Bulk creation'
            );
        END LOOP;
        
        task_id := v_task_id;
        success := TRUE;
        message := 'Task created successfully';
        RETURN NEXT;
        
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- =========================================================================
-- ROLE-BASED PERMISSIONS (Row Level Security)
-- =========================================================================

-- Enable RLS on all tables
ALTER TABLE progress_ledger ENABLE ROW LEVEL SECURITY;

-- Only admins can see all events
CREATE POLICY admin_ledger_all ON progress_ledger
    FOR ALL
    USING (current_setting('app.current_role') IN ('ADMIN', 'ENVOY'));

-- Users see events for their cases
CREATE POLICY user_ledger_cases ON progress_ledger
    FOR SELECT
    USING (
        case_id IN (
            SELECT case_id FROM case_assignments WHERE assigned_to = current_setting('app.current_user')::INTEGER
            UNION
            SELECT case_id FROM project_assignments WHERE project_manager_id = current_setting('app.current_user')::INTEGER
            UNION
            SELECT case_id FROM project_assignments WHERE crew_lead_id = current_setting('app.current_user')::INTEGER
        )
    );

-- Only assigned users can update tasks
CREATE POLICY user_update_tasks ON progress_ledger
    FOR INSERT
    WITH CHECK (
        (event_type = 'task_updated' OR event_type = 'task_status_changed') AND
        ( 
            (SELECT assignee FROM current_tasks WHERE task_id = NEW.entity_id) = current_setting('app.current_user')::INTEGER
            OR current_setting('app.current_role') IN ('ADMIN', 'PROJECT_MANAGER')
        )
    );