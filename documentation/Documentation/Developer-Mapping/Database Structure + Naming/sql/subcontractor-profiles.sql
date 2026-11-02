-- Subcontractor profiles (extends system_users)
CREATE TABLE subcontractor_profiles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES system_users(id) UNIQUE,
    
    -- Business info
    company_name VARCHAR(200),
    trade_specialty VARCHAR(100) NOT NULL,
    license_number VARCHAR(50),
    insurance_provider VARCHAR(100),
    insurance_expiration DATE,
    
    -- Contact
    business_phone VARCHAR(20),
    business_email VARCHAR(255),
    business_address TEXT,
    
    -- Preferences
    max_active_tasks INTEGER DEFAULT 5,
    service_radius_miles INTEGER DEFAULT 50,
    available_days TEXT[], -- ['monday', 'wednesday', 'friday']
    
    -- Ratings
    avg_rating DECIMAL(3,2),
    total_rating_count INTEGER DEFAULT 0,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    is_approved BOOLEAN DEFAULT FALSE,
    approval_notes TEXT,
    approved_by INTEGER REFERENCES system_users(id),
    approved_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_subcontractor_trade (trade_specialty),
    INDEX idx_subcontractor_active (is_active, is_approved)
);
-- Task assignments with subcontractor-specific fields
ALTER TABLE work_tasks ADD COLUMN IF NOT EXISTS assigned_to_id INTEGER REFERENCES system_users(id);
ALTER TABLE work_tasks ADD COLUMN IF NOT EXISTS task_type VARCHAR(50); -- plumbing, electrical, etc.
ALTER TABLE work_tasks ADD COLUMN IF NOT EXISTS job_code VARCHAR(50); -- 42-CHERRY format
ALTER TABLE work_tasks ADD COLUMN IF NOT EXISTS todo_list TEXT[]; -- remaining subtasks
ALTER TABLE work_tasks ADD COLUMN IF NOT EXISTS suggested_at TIMESTAMP;
ALTER TABLE work_tasks ADD COLUMN IF NOT EXISTS claimed_at TIMESTAMP;
ALTER TABLE work_tasks ADD COLUMN IF NOT EXISTS accepted_at TIMESTAMP;
ALTER TABLE work_tasks ADD COLUMN IF NOT EXISTS estimate_date DATE;
ALTER TABLE work_tasks ADD COLUMN IF NOT EXISTS work_start_date DATE;
ALTER TABLE work_tasks ADD COLUMN IF NOT EXISTS work_finish_date DATE;
-- Subcontractor quotes
CREATE TABLE subcontractor_quotes (
    id SERIAL PRIMARY KEY,
    task_id INTEGER REFERENCES work_tasks(id) ON DELETE CASCADE,
    subcontractor_id INTEGER REFERENCES system_users(id),
    
    -- Quote details
    quote_amount DECIMAL(12,2) NOT NULL,
    labor_cost DECIMAL(12,2),
    materials_cost DECIMAL(12,2),
    travel_cost DECIMAL(12,2),
    quote_details TEXT,
    valid_until DATE,
    
    -- Status
    status VARCHAR(20) DEFAULT 'submitted', -- submitted, approved, rejected, expired
    approved_by INTEGER REFERENCES system_users(id),
    approved_at TIMESTAMP,
    rejected_reason TEXT,
    
    -- Document
    quote_document_id INTEGER REFERENCES case_documents(id),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_quotes_task (task_id),
    INDEX idx_quotes_status (status)
);
-- Subcontractor invoices
CREATE TABLE subcontractor_invoices (
    id SERIAL PRIMARY KEY,
    task_id INTEGER REFERENCES work_tasks(id) ON DELETE CASCADE,
    subcontractor_id INTEGER REFERENCES system_users(id),
    
    -- Invoice details
    invoice_number VARCHAR(50) NOT NULL,
    invoice_date DATE NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    work_performed TEXT,
    payment_terms VARCHAR(20) DEFAULT 'Net 30',
    
    -- Document
    invoice_document_id INTEGER REFERENCES case_documents(id),
    
    -- Status
    status VARCHAR(20) DEFAULT 'submitted', -- submitted, approved, paid, rejected
    approved_by INTEGER REFERENCES system_users(id),
    approved_at TIMESTAMP,
    paid_by INTEGER REFERENCES system_users(id),
    paid_at TIMESTAMP,
    payment_reference VARCHAR(100),
    rejection_reason TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_invoices_task (task_id),
    INDEX idx_invoices_status (status)
);
-- Subcontractor communications
CREATE TABLE subcontractor_communications (
    id SERIAL PRIMARY KEY,
    task_id INTEGER REFERENCES work_tasks(id) ON DELETE CASCADE,
    subcontractor_id INTEGER REFERENCES system_users(id),
    sender_id INTEGER REFERENCES system_users(id),
    
    communication_type VARCHAR(50), -- email, platform, phone
    subject VARCHAR(500),
    body TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_comm_task (task_id),
    INDEX idx_comm_subcontractor (subcontractor_id, is_read)
);
-- Task status history
CREATE TABLE task_status_history (
    id SERIAL PRIMARY KEY,
    task_id INTEGER REFERENCES work_tasks(id) ON DELETE CASCADE,
    from_status VARCHAR(20),
    to_status VARCHAR(20),
    changed_by INTEGER REFERENCES system_users(id),
    notes TEXT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_status_task (task_id),
    INDEX idx_status_changed (changed_at DESC)
);