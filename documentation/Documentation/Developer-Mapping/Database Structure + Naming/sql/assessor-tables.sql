-- Assessments table (extends property_assessments)
CREATE TABLE assessments (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    assessor_id INTEGER REFERENCES system_users(id),
    
    -- Scheduling
    scheduled_start TIMESTAMP,
    scheduled_end TIMESTAMP,
    actual_start TIMESTAMP,
    actual_end TIMESTAMP,
    estimated_duration_hours DECIMAL(3,1),
    
    -- Status
    status VARCHAR(20) DEFAULT 'scheduled', -- scheduled, in_progress, completed, cancelled
    completion_percentage INTEGER DEFAULT 0,
    
    -- Location
    check_in_location POINT,
    check_out_location POINT,
    check_in_at TIMESTAMP,
    check_out_at TIMESTAMP,
    
    -- Assessment data
    repair_areas TEXT[],
    measurements JSONB,
    notes TEXT,
    
    -- Travel
    travel_distance_miles DECIMAL(5,1),
    travel_time_minutes INTEGER,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_assessments_date (scheduled_start),
    INDEX idx_assessments_status (status),
    INDEX idx_assessments_assessor (assessor_id)
);
-- Assessment tasks (generated from assessment)
CREATE TABLE assessment_tasks (
    id SERIAL PRIMARY KEY,
    assessment_id INTEGER REFERENCES assessments(id) ON DELETE CASCADE,
    
    -- Task details
    description TEXT NOT NULL,
    priority VARCHAR(20) DEFAULT 'normal', -- urgent, high, normal, low
    estimated_hours DECIMAL(4,1),
    
    -- Status
    status VARCHAR(20) DEFAULT 'draft', -- draft, assigned, in_progress, completed
    
    -- Dependencies
    parent_task_id INTEGER REFERENCES assessment_tasks(id),
    
    -- Material/scope notes
    materials_needed TEXT,
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Document verification records
CREATE TABLE document_verifications (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    verified_by INTEGER REFERENCES system_users(id),
    
    -- Document info
    document_code VARCHAR(20) NOT NULL, -- POI, OWN, ID, etc.
    document_id INTEGER REFERENCES case_documents(id),
    
    -- Verification
    verification_type VARCHAR(20), -- in_person, uploaded, reviewed
    verification_status VARCHAR(20) DEFAULT 'pending', -- pending, verified, rejected, needs_clarification
    
    -- Verification data
    findings TEXT,
    notes TEXT,
    is_reversible BOOLEAN DEFAULT TRUE,
    verified_at TIMESTAMP,
    
    -- For physical document collection
    collected_physically BOOLEAN DEFAULT FALSE,
    collected_at TIMESTAMP,
    collected_by VARCHAR(100),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_verifications_case (case_id),
    INDEX idx_verifications_status (verification_status)
);
-- Assessment notes (free text + structured)
CREATE TABLE assessment_notes (
    id SERIAL PRIMARY KEY,
    assessment_id INTEGER REFERENCES assessments(id) ON DELETE CASCADE,
    author_id INTEGER REFERENCES system_users(id),
    
    note_type VARCHAR(50), -- client_conversation, property_observation, safety_concern, follow_up
    content TEXT NOT NULL,
    is_public BOOLEAN DEFAULT FALSE, -- visible to client
    is_action_item BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);