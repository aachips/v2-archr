-- =========================================================================
-- CREW DASHBOARD SCHEMA EXTENSIONS
-- =========================================================================

-- Job cards (for warehouse view)
CREATE TABLE crew_job_cards (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    crew_lead_id INTEGER REFERENCES system_users(id),
    
    -- Job metadata
    placecode VARCHAR(50),
    address TEXT,
    homeowner_name VARCHAR(200),
    homeowner_phone VARCHAR(20),
    
    -- Weather
    weather_indoor_outdoor VARCHAR(20), -- indoor, outdoor
    weather_icon VARCHAR(10),
    weather_temperature INTEGER,
    
    -- Progress
    progress_percentage INTEGER DEFAULT 0,
    total_tasks INTEGER DEFAULT 0,
    completed_tasks INTEGER DEFAULT 0,
    estimated_hours DECIMAL(5,2),
    remaining_hours DECIMAL(5,2),
    
    -- Status
    job_status VARCHAR(20) DEFAULT 'active', -- active, in_progress, completed, on_hold
    
    -- Active job flag
    is_current_job BOOLEAN DEFAULT FALSE,
    current_phase VARCHAR(50),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_crew_jobs_lead (crew_lead_id),
    INDEX idx_crew_jobs_status (job_status),
    INDEX idx_crew_jobs_current (is_current_job)
);

-- Volunteer sign-in tracking
CREATE TABLE crew_volunteer_signin (
    id SERIAL PRIMARY KEY,
    job_id INTEGER REFERENCES crew_job_cards(id) ON DELETE CASCADE,
    volunteer_id INTEGER REFERENCES system_users(id),
    
    -- Sign-in details
    sign_in_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sign_out_time TIMESTAMP,
    hours_worked DECIMAL(5,2),
    
    -- Safety talk confirmation
    safety_talk_confirmed BOOLEAN DEFAULT FALSE,
    safety_talk_topics TEXT,
    safety_talk_confirmed_at TIMESTAMP,
    
    -- Tasks assigned
    assigned_task_ids INTEGER[],
    
    -- Verification
    verified_by INTEGER REFERENCES system_users(id),
    verified_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_volunteer_signin_job (job_id),
    INDEX idx_volunteer_signin_volunteer (volunteer_id)
);

-- Daily logs
CREATE TABLE crew_daily_logs (
    id SERIAL PRIMARY KEY,
    job_id INTEGER REFERENCES crew_job_cards(id) ON DELETE CASCADE,
    crew_lead_id INTEGER REFERENCES system_users(id),
    log_date DATE DEFAULT CURRENT_DATE,
    
    -- Log content
    log_text TEXT,
    work_summary TEXT,
    issues_encountered TEXT,
    tomorrow_plan TEXT,
    
    -- Photos
    photo_urls TEXT[],
    
    -- Verification
    verified BOOLEAN DEFAULT FALSE,
    verified_by INTEGER REFERENCES system_users(id),
    verified_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(job_id, log_date),
    INDEX idx_daily_logs_job (job_id),
    INDEX idx_daily_logs_date (log_date DESC)
);

-- Completion documents
CREATE TABLE crew_completion_documents (
    id SERIAL PRIMARY KEY,
    job_id INTEGER REFERENCES crew_job_cards(id) ON DELETE CASCADE,
    
    -- Document details
    document_type VARCHAR(50), -- completion, inspection, signoff
    document_url TEXT,
    document_name VARCHAR(200),
    
    -- Signatures
    client_signed_at TIMESTAMP,
    client_signature_url TEXT,
    crew_lead_signed_at TIMESTAMP,
    crew_lead_signature_url TEXT,
    
    -- Verification
    is_final BOOLEAN DEFAULT FALSE,
    verified_by INTEGER REFERENCES system_users(id),
    verified_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_completion_job (job_id)
);

-- Incident reports
CREATE TABLE crew_incident_reports (
    id SERIAL PRIMARY KEY,
    job_id INTEGER REFERENCES crew_job_cards(id) ON DELETE CASCADE,
    reported_by INTEGER REFERENCES system_users(id),
    
    -- Incident details
    incident_date DATE NOT NULL,
    incident_time TIME,
    incident_type VARCHAR(50), -- injury, property_damage, near_miss, other
    severity VARCHAR(20), -- minor, moderate, severe, critical
    
    -- Description
    description TEXT NOT NULL,
    location TEXT,
    witnesses TEXT[],
    
    -- Actions
    immediate_action_taken TEXT,
    follow_up_required BOOLEAN DEFAULT FALSE,
    follow_up_notes TEXT,
    
    -- Status
    status VARCHAR(20) DEFAULT 'reported', -- reported, investigating, resolved, closed
    
    -- Photos
    photo_urls TEXT[],
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP,
    resolved_by INTEGER REFERENCES system_users(id),
    
    INDEX idx_incident_job (job_id),
    INDEX idx_incident_date (incident_date DESC)
);

-- Tomorrow view (pre-calculated)
CREATE VIEW crew_tomorrow_view AS
SELECT 
    cjc.id AS job_id,
    cjc.placecode,
    cjc.address,
    cjc.crew_lead_id,
    cl.full_name AS crew_lead_name,
    cjc.weather_indoor_outdoor,
    cjc.weather_icon,
    cjc.weather_temperature,
    cjc.progress_percentage,
    cjc.estimated_hours,
    COUNT(DISTINCT cvs.volunteer_id) AS volunteer_count,
    STRING_AGG(DISTINCT u.full_name, ', ') AS volunteer_names
FROM crew_job_cards cjc
LEFT JOIN system_users cl ON cjc.crew_lead_id = cl.id
LEFT JOIN crew_volunteer_signin cvs ON cjc.id = cvs.job_id 
    AND cvs.sign_in_time::DATE = CURRENT_DATE + INTERVAL '1 day'
LEFT JOIN system_users u ON cvs.volunteer_id = u.id
WHERE cjc.job_status IN ('active', 'in_progress')
  AND cjc.is_current_job = FALSE
GROUP BY cjc.id, cjc.placecode, cjc.address, cjc.crew_lead_id, cl.full_name,
         cjc.weather_indoor_outdoor, cjc.weather_icon, cjc.weather_temperature,
         cjc.progress_percentage, cjc.estimated_hours
ORDER BY cjc.estimated_hours ASC;

-- Job phases configuration
CREATE TABLE crew_job_phases (
    id SERIAL PRIMARY KEY,
    phase_code VARCHAR(50) UNIQUE NOT NULL,
    phase_name VARCHAR(100) NOT NULL,
    phase_order INTEGER NOT NULL,
    description TEXT,
    
    -- Required tasks for this phase
    required_tasks JSONB,
    
    -- Completion criteria
    completion_criteria TEXT,
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO crew_job_phases (phase_code, phase_name, phase_order, description) VALUES
('PREP', 'Preparation', 1, 'Gather materials, review scope'),
('SETUP', 'Site Setup', 2, 'Set up ladders, safety equipment'),
('WORK', 'Active Work', 3, 'Perform repairs'),
('CLEANUP', 'Cleanup', 4, 'Clean site, dispose of debris'),
('INSPECT', 'Final Inspection', 5, 'Quality check, client walkthrough'),
('COMPLETE', 'Completed', 6, 'Job complete, documents signed');