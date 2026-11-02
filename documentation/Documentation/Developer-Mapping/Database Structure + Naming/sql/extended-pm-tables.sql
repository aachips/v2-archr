-- 1. Project Assignments (crew + PM assignment)
CREATE TABLE project_assignments (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    project_manager_id INTEGER REFERENCES system_users(id),
    crew_lead_id INTEGER REFERENCES system_users(id),
    crew_member_ids INTEGER[], -- Array of crew member user IDs
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_project_assignments_case (case_id),
    INDEX idx_project_assignments_pm (project_manager_id)
);

-- 2. Project Milestones (for timeline tracking)
CREATE TABLE project_milestones (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    milestone_type VARCHAR(50), -- assessment_complete, estimate_approved, work_start, work_complete, final_inspection
    milestone_date DATE,
    milestone_notes TEXT,
    is_complete BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_milestones_case (case_id),
    INDEX idx_milestones_complete (is_complete)
);

-- 3. Escalation/Issues (for PM flags)
CREATE TABLE project_escalations (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    raised_by INTEGER REFERENCES system_users(id),
    issue_type VARCHAR(50), -- budget_overrun, schedule_delay, quality_issue, client_dispute
    severity VARCHAR(20), -- minor, major, critical
    description TEXT,
    action_taken TEXT,
    resolved_at TIMESTAMP,
    resolved_by INTEGER REFERENCES system_users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_escalations_case (case_id),
    INDEX idx_escalations_severity (severity),
    INDEX idx_escalations_resolved (resolved_at)
);

-- 4. Project Reporting Snapshots (for daily/weekly summary)
CREATE TABLE project_snapshots (
    id SERIAL PRIMARY KEY,
    snapshot_date DATE NOT NULL,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    
    -- Status at snapshot time
    progress_percentage INTEGER,
    budget_used DECIMAL(12,2),
    budget_remaining DECIMAL(12,2),
    
    -- Milestones completed since last snapshot
    milestones_completed_since_last INTEGER,
    
    -- Flags
    is_on_schedule BOOLEAN,
    is_on_budget BOOLEAN,
    days_until_deadline INTEGER,
    days_since_started INTEGER,
    
    -- Calculated fields
    calculated_cost_percentage DECIMAL(5,2),
    calculated_time_percentage DECIMAL(5,2),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(snapshot_date, case_id),
    INDEX idx_snapshots_date (snapshot_date),
    INDEX idx_snapshots_case (case_id)
);