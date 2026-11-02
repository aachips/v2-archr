-- =====================================================
-- ARCHR Role-Based Access Control Schema
-- Multi-Organization User Management & Case Workflow
-- =====================================================

-- This comprehensive schema provides:
-- 
-- 1) 11 distinct roles with granular permissions (50+ specific permissions)
-- 2) Role hierarchy from Admin down to Volunteer
-- 3) Complete case management workflow with status tracking
-- 4) Assessment and estimation capabilities for home repairs
-- 5) Project and task management for work execution
-- 6) Financial tracking with invoices, budgets, and funding sources
-- 7) Communication logging for audit trails
-- 8) Volunteer-specific tracking (hours, skills)
-- 9) Permission checking functions for API/UI integration
-- 10) Dashboard views for workload and case management
-- 
-- The system is designed to handle the complexity of multiple organizations with different staff roles coordinating on home repair cases from intake through completion.


-- =====================================================
-- USER & ROLE MANAGEMENT
-- =====================================================

-- Core roles definition
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    role_code VARCHAR(50) UNIQUE NOT NULL,
    role_name VARCHAR(100) NOT NULL,
    role_level INTEGER NOT NULL, -- 0-10 for hierarchy
    description TEXT,
    is_system_role BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert all roles
INSERT INTO roles (role_code, role_name, role_level, description, is_system_role) VALUES
    ('ADMIN', 'Administrator', 10, 'Full system administration and configuration', true),
    ('PROJECT_MANAGER', 'Project Manager', 9, 'Oversees multiple projects, budgets, and timelines', true),
    ('BURSAR', 'Bursar', 8, 'Financial management, payments, and invoicing', true),
    ('CASEWORKER', 'Caseworker', 7, 'Primary applicant contact and case coordination', true),
    ('ASSESSOR', 'Assessor', 6, 'Conducts home visits and repair assessments', true),
    ('CREW_LEAD', 'Crew Lead', 5, 'Manages on-site repair crew and work quality', true),
    ('SUBCONTRACTOR', 'Subcontractor', 4, 'External trade specialist', true),
    ('ENVOY', 'Envoy', 3, 'Community liaison and applicant support', true),
    ('CREW_MEMBER', 'Crew Member', 2, 'Performs repair work under supervision', true),
    ('REQUESTOR', 'Requestor', 1, 'Submits initial intake applications', true),
    ('VOLUNTEER', 'Volunteer', 0, 'Unpaid helper with limited access', true);

-- Permission categories
CREATE TABLE permission_categories (
    id SERIAL PRIMARY KEY,
    category_code VARCHAR(50) UNIQUE NOT NULL,
    category_name VARCHAR(100) NOT NULL,
    description TEXT
);

INSERT INTO permission_categories (category_code, category_name) VALUES
    ('CASE', 'Case Management'),
    ('APPLICATION', 'Application Management'),
    ('ASSESSMENT', 'Assessment & Estimation'),
    ('REPAIR', 'Repair Execution'),
    ('FINANCE', 'Financial Management'),
    ('USER', 'User Management'),
    ('ORG', 'Organization Settings'),
    ('REPORT', 'Reporting & Analytics'),
    ('DOCUMENT', 'Document Management'),
    ('COMMUNICATION', 'Communication Tools');

-- Granular permissions
CREATE TABLE permissions (
    id SERIAL PRIMARY KEY,
    permission_code VARCHAR(100) UNIQUE NOT NULL,
    permission_name VARCHAR(200) NOT NULL,
    category_id INTEGER REFERENCES permission_categories(id),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO permissions (permission_code, permission_name, category_id) VALUES
    -- Case permissions
    ('CASE_VIEW', 'View case details', 1),
    ('CASE_CREATE', 'Create new case', 1),
    ('CASE_UPDATE', 'Update case information', 1),
    ('CASE_DELETE', 'Delete case', 1),
    ('CASE_ASSIGN', 'Assign cases to users', 1),
    ('CASE_STATUS_UPDATE', 'Update case status', 1),
    
    -- Application permissions
    ('APP_SUBMIT', 'Submit intake application', 2),
    ('APP_VIEW_OWN', 'View own applications', 2),
    ('APP_VIEW_ALL', 'View all applications', 2),
    ('APP_REVIEW', 'Review applications', 2),
    ('APP_APPROVE', 'Approve applications', 2),
    
    -- Assessment permissions
    ('ASSESS_CREATE', 'Create assessments', 3),
    ('ASSESS_VIEW', 'View assessments', 3),
    ('ASSESS_UPDATE', 'Update assessments', 3),
    ('ESTIMATE_CREATE', 'Create estimates', 3),
    ('ESTIMATE_APPROVE', 'Approve estimates', 3),
    ('PHOTO_UPLOAD', 'Upload photos', 3),
    
    -- Repair permissions
    ('REPAIR_VIEW', 'View repair tasks', 4),
    ('REPAIR_ASSIGN', 'Assign repair tasks', 4),
    ('REPAIR_UPDATE_STATUS', 'Update repair status', 4),
    ('REPAIR_COMPLETE', 'Mark repair complete', 4),
    ('MATERIAL_REQUEST', 'Request materials', 4),
    ('MATERIAL_APPROVE', 'Approve material requests', 4),
    
    -- Finance permissions
    ('FINANCE_VIEW', 'View financial data', 5),
    ('INVOICE_CREATE', 'Create invoices', 5),
    ('INVOICE_PROCESS', 'Process payments', 5),
    ('BUDGET_VIEW', 'View budgets', 5),
    ('BUDGET_UPDATE', 'Update budgets', 5),
    ('EXPENSE_TRACK', 'Track expenses', 5),
    
    -- User permissions
    ('USER_VIEW', 'View users', 6),
    ('USER_CREATE', 'Create users', 6),
    ('USER_UPDATE', 'Update users', 6),
    ('USER_DELETE', 'Delete users', 6),
    ('ROLE_ASSIGN', 'Assign roles', 6),
    
    -- Organization permissions
    ('ORG_VIEW', 'View organization settings', 7),
    ('ORG_UPDATE', 'Update organization settings', 7),
    ('RULE_CONFIG', 'Configure eligibility rules', 7),
    
    -- Reporting permissions
    ('REPORT_VIEW', 'View reports', 8),
    ('REPORT_EXPORT', 'Export reports', 8),
    ('REPORT_SCHEDULE', 'Schedule reports', 8),
    
    -- Document permissions
    ('DOC_UPLOAD', 'Upload documents', 9),
    ('DOC_VIEW', 'View documents', 9),
    ('DOC_DELETE', 'Delete documents', 9),
    
    -- Communication permissions
    ('COMM_VIEW', 'View communications', 10),
    ('COMM_SEND', 'Send communications', 10),
    ('COMM_BROADCAST', 'Broadcast to org', 10);

-- Role-permission assignments
CREATE TABLE role_permissions (
    id SERIAL PRIMARY KEY,
    role_id INTEGER REFERENCES roles(id) ON DELETE CASCADE,
    permission_id INTEGER REFERENCES permissions(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(role_id, permission_id)
);

-- Assign permissions to roles (comprehensive mapping)
-- ADMIN gets everything
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.role_code = 'ADMIN';

-- PROJECT_MANAGER permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.role_code = 'PROJECT_MANAGER'
    AND p.permission_code IN (
        'CASE_VIEW', 'CASE_UPDATE', 'CASE_ASSIGN', 'CASE_STATUS_UPDATE',
        'ASSESS_VIEW', 'ESTIMATE_APPROVE',
        'REPAIR_VIEW', 'REPAIR_ASSIGN', 'REPAIR_UPDATE_STATUS', 'MATERIAL_APPROVE',
        'FINANCE_VIEW', 'BUDGET_VIEW', 'BUDGET_UPDATE',
        'REPORT_VIEW', 'REPORT_EXPORT',
        'DOC_VIEW', 'COMM_VIEW', 'COMM_SEND'
    );

-- BURSAR permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.role_code = 'BURSAR'
    AND p.permission_code IN (
        'CASE_VIEW', 'FINANCE_VIEW', 'INVOICE_CREATE', 'INVOICE_PROCESS',
        'BUDGET_VIEW', 'EXPENSE_TRACK', 'REPORT_VIEW', 'REPORT_EXPORT'
    );

-- CASEWORKER permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.role_code = 'CASEWORKER'
    AND p.permission_code IN (
        'CASE_VIEW', 'CASE_UPDATE', 'CASE_STATUS_UPDATE',
        'APP_VIEW_ALL', 'APP_REVIEW',
        'ASSESS_VIEW',
        'DOC_VIEW', 'DOC_UPLOAD',
        'COMM_VIEW', 'COMM_SEND'
    );

-- ASSESSOR permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.role_code = 'ASSESSOR'
    AND p.permission_code IN (
        'CASE_VIEW', 'ASSESS_CREATE', 'ASSESS_VIEW', 'ASSESS_UPDATE',
        'ESTIMATE_CREATE', 'PHOTO_UPLOAD', 'DOC_VIEW', 'DOC_UPLOAD'
    );

-- CREW_LEAD permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.role_code = 'CREW_LEAD'
    AND p.permission_code IN (
        'CASE_VIEW', 'REPAIR_VIEW', 'REPAIR_ASSIGN', 'REPAIR_UPDATE_STATUS',
        'REPAIR_COMPLETE', 'MATERIAL_REQUEST', 'DOC_VIEW', 'COMM_VIEW'
    );

-- SUBCONTRACTOR permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.role_code = 'SUBCONTRACTOR'
    AND p.permission_code IN (
        'CASE_VIEW', 'REPAIR_VIEW', 'REPAIR_UPDATE_STATUS',
        'ESTIMATE_CREATE', 'DOC_VIEW', 'COMM_VIEW'
    );

-- ENVOY permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.role_code = 'ENVOY'
    AND p.permission_code IN (
        'CASE_VIEW', 'CASE_UPDATE', 'COMM_VIEW', 'COMM_SEND',
        'DOC_VIEW', 'DOC_UPLOAD'
    );

-- CREW_MEMBER permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.role_code = 'CREW_MEMBER'
    AND p.permission_code IN ('REPAIR_VIEW', 'REPAIR_UPDATE_STATUS', 'DOC_VIEW');

-- REQUESTOR permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.role_code = 'REQUESTOR'
    AND p.permission_code IN ('APP_SUBMIT', 'APP_VIEW_OWN', 'DOC_UPLOAD');

-- VOLUNTEER permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.role_code = 'VOLUNTEER'
    AND p.permission_code IN ('REPAIR_VIEW', 'DOC_VIEW');

-- =====================================================
-- USERS & ORGANIZATION ASSIGNMENTS
-- =====================================================

-- Users table (extends beyond organization_users)
CREATE TABLE system_users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(200) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    avatar_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP,
    last_ip INET,
    password_hash VARCHAR(255),
    reset_token VARCHAR(255),
    reset_token_expires TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES system_users(id),
    updated_by INTEGER REFERENCES system_users(id)
);

-- User role assignments (can have multiple roles across organizations)
CREATE TABLE user_role_assignments (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES system_users(id) ON DELETE CASCADE,
    organization_id INTEGER REFERENCES coalition_organizations(id) ON DELETE CASCADE,
    role_id INTEGER REFERENCES roles(id),
    assigned_by INTEGER REFERENCES system_users(id),
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP, -- For temporary assignments (e.g., volunteers)
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    UNIQUE(user_id, organization_id, role_id)
);

-- =====================================================
-- CASE MANAGEMENT WORKFLOW
-- =====================================================

-- Case status definitions
CREATE TABLE case_statuses (
    id SERIAL PRIMARY KEY,
    status_code VARCHAR(50) UNIQUE NOT NULL,
    status_name VARCHAR(100) NOT NULL,
    status_sequence INTEGER NOT NULL, -- For workflow order
    is_terminal BOOLEAN DEFAULT FALSE,
    allowed_roles_for_transition TEXT[], -- Which roles can move to this status
    description TEXT
);

INSERT INTO case_statuses (status_code, status_name, status_sequence, allowed_roles_for_transition, description) VALUES
    ('PENDING_REVIEW', 'Pending Review', 1, ARRAY['ADMIN', 'CASEWORKER'], 'New application awaiting initial review'),
    ('INTAKE_COMPLETE', 'Intake Complete', 2, ARRAY['ADMIN', 'CASEWORKER'], 'Initial eligibility determined'),
    ('ASSESSMENT_SCHEDULED', 'Assessment Scheduled', 3, ARRAY['ADMIN', 'ASSESSOR', 'CASEWORKER'], 'Home visit scheduled'),
    ('ASSESSMENT_COMPLETE', 'Assessment Complete', 4, ARRAY['ADMIN', 'ASSESSOR', 'CASEWORKER'], 'Home assessment finished, estimate created'),
    ('APPROVED', 'Approved', 5, ARRAY['ADMIN', 'PROJECT_MANAGER', 'CASEWORKER'], 'Case approved for repair work'),
    ('DENIED', 'Denied', 99, ARRAY['ADMIN', 'CASEWORKER'], 'Application denied - terminal'),
    ('ASSIGNED_TO_CREW', 'Assigned to Crew', 6, ARRAY['ADMIN', 'PROJECT_MANAGER', 'CREW_LEAD'], 'Repair team assigned'),
    ('IN_PROGRESS', 'In Progress', 7, ARRAY['CREW_LEAD', 'CREW_MEMBER', 'SUBCONTRACTOR'], 'Repair work underway'),
    ('QUALITY_CHECK', 'Quality Check', 8, ARRAY['CREW_LEAD', 'PROJECT_MANAGER'], 'Final inspection before completion'),
    ('COMPLETED', 'Completed', 10, ARRAY['ADMIN', 'PROJECT_MANAGER', 'CASEWORKER'], 'All work completed - terminal'),
    ('ON_HOLD', 'On Hold', 50, ARRAY['ADMIN', 'PROJECT_MANAGER', 'CASEWORKER'], 'Temporary hold - not terminal');

-- Extended case information
CREATE TABLE cases (
    id SERIAL PRIMARY KEY,
    submission_id INTEGER REFERENCES intake_submissions(id) ON DELETE CASCADE,
    case_number VARCHAR(50) UNIQUE NOT NULL,
    status_id INTEGER REFERENCES case_statuses(id),
    
    -- Assignment tracking
    assigned_caseworker_id INTEGER REFERENCES system_users(id),
    assigned_project_manager_id INTEGER REFERENCES system_users(id),
    assigned_assessor_id INTEGER REFERENCES system_users(id),
    
    -- Dates
    intake_completed_at TIMESTAMP,
    assessment_scheduled_at TIMESTAMP,
    assessment_completed_at TIMESTAMP,
    approved_at TIMESTAMP,
    work_started_at TIMESTAMP,
    work_completed_at TIMESTAMP,
    
    -- Metadata
    total_budget DECIMAL(12,2),
    total_actual_cost DECIMAL(12,2),
    notes TEXT,
    internal_notes TEXT, -- Staff-only notes
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES system_users(id),
    updated_by INTEGER REFERENCES system_users(id)
);

-- Generate case number function
CREATE OR REPLACE FUNCTION generate_case_number()
RETURNS TRIGGER AS $$
BEGIN
    NEW.case_number := 'ARCHR-' || TO_CHAR(NEW.created_at, 'YYYY') || '-' || LPAD(NEW.id::TEXT, 6, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_case_number
    BEFORE INSERT ON cases
    FOR EACH ROW
    EXECUTE PROCEDURE generate_case_number();

-- Case status history (audit trail)
CREATE TABLE case_status_history (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    from_status_id INTEGER REFERENCES case_statuses(id),
    to_status_id INTEGER REFERENCES case_statuses(id),
    changed_by INTEGER REFERENCES system_users(id),
    notes TEXT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- ASSESSMENT & ESTIMATES
-- =====================================================

-- Property assessment records
CREATE TABLE property_assessments (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    assessor_id INTEGER REFERENCES system_users(id),
    assessment_date DATE NOT NULL,
    
    -- Assessment findings
    property_condition TEXT,
    structural_issues TEXT,
    electrical_issues TEXT,
    plumbing_issues TEXT,
    hvac_issues TEXT,
    roofing_issues TEXT,
    accessibility_needs TEXT,
    safety_hazards TEXT,
    photos JSONB, -- Array of photo URLs
    
    -- Measurements
    square_footage DECIMAL(10,2),
    num_bedrooms INTEGER,
    num_bathrooms INTEGER,
    
    -- Recommendations
    recommended_repairs TEXT,
    priority_repairs TEXT,
    estimated_hours DECIMAL(10,2),
    estimated_material_cost DECIMAL(12,2),
    estimated_labor_cost DECIMAL(12,2),
    total_estimate DECIMAL(12,2),
    
    assessment_notes TEXT,
    assigned_at TIMESTAMP, -- set when the assessment is assigned to an assessor; metric-tracking.sql reads this
    assessment_completed_at TIMESTAMP, -- set when the assessor marks the visit complete; metric-tracking.sql filters on this
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Repair estimates (detailed line items)
CREATE TABLE repair_estimates (
    id SERIAL PRIMARY KEY,
    assessment_id INTEGER REFERENCES property_assessments(id) ON DELETE CASCADE,
    repair_category_id INTEGER REFERENCES repair_categories(id),
    description TEXT NOT NULL,
    quantity DECIMAL(10,2),
    unit_cost DECIMAL(10,2),
    material_cost DECIMAL(12,2),
    labor_hours DECIMAL(10,2),
    labor_rate DECIMAL(10,2),
    labor_cost DECIMAL(12,2),
    total_cost DECIMAL(12,2),
    is_approved BOOLEAN DEFAULT FALSE,
    approved_by INTEGER REFERENCES system_users(id),
    approved_at TIMESTAMP,
    notes TEXT
);

-- =====================================================
-- PROJECT & TASK MANAGEMENT
-- =====================================================

-- Work orders / projects
CREATE TABLE work_orders (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    work_order_number VARCHAR(50) UNIQUE NOT NULL,
    project_manager_id INTEGER REFERENCES system_users(id),
    crew_lead_id INTEGER REFERENCES system_users(id),
    
    -- Scheduling
    scheduled_start_date DATE,
    scheduled_end_date DATE,
    actual_start_date DATE,
    actual_end_date DATE,
    
    -- Status
    status VARCHAR(50) DEFAULT 'planned', -- planned, in_progress, on_hold, completed, cancelled
    
    -- Budget
    approved_budget DECIMAL(12,2),
    current_cost DECIMAL(12,2),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tasks assigned to crew members and subcontractors
CREATE TABLE work_tasks (
    id SERIAL PRIMARY KEY,
    work_order_id INTEGER REFERENCES work_orders(id) ON DELETE CASCADE,
    assigned_to_id INTEGER REFERENCES system_users(id), -- Can be crew member or subcontractor
    task_type VARCHAR(50), -- repair, inspection, material_delivery, etc.
    description TEXT,
    
    -- Repair categorization
    repair_category_id INTEGER REFERENCES repair_categories(id),
    estimate_id INTEGER REFERENCES repair_estimates(id),
    
    -- Status tracking
    status VARCHAR(50) DEFAULT 'assigned', -- assigned, in_progress, completed, blocked, cancelled
    priority INTEGER DEFAULT 1, -- 1=highest
    
    -- Timing
    estimated_hours DECIMAL(10,2),
    actual_hours DECIMAL(10,2),
    due_date DATE,
    completed_at TIMESTAMP,
    
    -- Notes
    instructions TEXT,
    completion_notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES system_users(id)
);

-- Task status history
CREATE TABLE task_status_history (
    id SERIAL PRIMARY KEY,
    task_id INTEGER REFERENCES work_tasks(id) ON DELETE CASCADE,
    from_status VARCHAR(50),
    to_status VARCHAR(50),
    changed_by INTEGER REFERENCES system_users(id),
    notes TEXT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Material requests
CREATE TABLE material_requests (
    id SERIAL PRIMARY KEY,
    task_id INTEGER REFERENCES work_tasks(id) ON DELETE CASCADE,
    requested_by INTEGER REFERENCES system_users(id),
    material_name VARCHAR(200),
    quantity DECIMAL(10,2),
    unit VARCHAR(20),
    estimated_cost DECIMAL(12,2),
    supplier VARCHAR(200),
    status VARCHAR(50) DEFAULT 'pending', -- pending, approved, ordered, received
    approved_by INTEGER REFERENCES system_users(id),
    approved_at TIMESTAMP,
    order_date DATE,
    received_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- FINANCIAL TRACKING
-- =====================================================

-- Funding sources
CREATE TABLE funding_sources (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER REFERENCES coalition_organizations(id) ON DELETE CASCADE,
    source_name VARCHAR(200) NOT NULL,
    source_type VARCHAR(50), -- grant, donation, government, partner, other
    total_amount DECIMAL(12,2),
    remaining_amount DECIMAL(12,2),
    start_date DATE,
    end_date DATE,
    restrictions TEXT,
    contact_name VARCHAR(200),
    contact_email VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Case funding allocation
CREATE TABLE case_funding (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    funding_source_id INTEGER REFERENCES funding_sources(id),
    allocated_amount DECIMAL(12,2),
    spent_amount DECIMAL(12,2) DEFAULT 0,
    allocated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    allocated_by INTEGER REFERENCES system_users(id),
    notes TEXT
);

-- Invoices and payments
CREATE TABLE invoices (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    vendor_name VARCHAR(200),
    vendor_type VARCHAR(50), -- subcontractor, supplier, etc.
    invoice_date DATE,
    due_date DATE,
    paid_date DATE,
    subtotal DECIMAL(12,2),
    tax DECIMAL(12,2),
    total_amount DECIMAL(12,2),
    status VARCHAR(50) DEFAULT 'pending', -- pending, approved, paid, rejected
    approved_by INTEGER REFERENCES system_users(id),
    approved_at TIMESTAMP,
    paid_by INTEGER REFERENCES system_users(id),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Invoice line items
CREATE TABLE invoice_line_items (
    id SERIAL PRIMARY KEY,
    invoice_id INTEGER REFERENCES invoices(id) ON DELETE CASCADE,
    task_id INTEGER REFERENCES work_tasks(id),
    description TEXT,
    quantity DECIMAL(10,2),
    unit_price DECIMAL(12,2),
    total DECIMAL(12,2)
);

-- =====================================================
-- COMMUNICATION LOGGING
-- =====================================================

-- Track all communications related to a case
CREATE TABLE case_communications (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    from_user_id INTEGER REFERENCES system_users(id),
    to_user_id INTEGER REFERENCES system_users(id),
    to_applicant BOOLEAN DEFAULT FALSE,
    communication_type VARCHAR(50), -- email, phone, sms, in_person, portal_message
    subject VARCHAR(500),
    body TEXT,
    attachments JSONB, -- Array of attachment URLs
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    notes TEXT
);

-- =====================================================
-- VOLUNTEER SPECIFIC TRACKING
-- =====================================================

CREATE TABLE volunteer_hours (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES system_users(id),
    work_order_id INTEGER REFERENCES work_orders(id),
    date DATE NOT NULL,
    hours DECIMAL(5,2),
    task_description TEXT,
    verified_by INTEGER REFERENCES system_users(id), -- Crew lead or project manager
    verified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- volunteer_skills is defined in volunteer-gamification.sql with a richer
-- schema (FK to a skills lookup, endorsements, uniqueness). Kept there as
-- the single source of truth.

-- =====================================================
-- FUNCTIONS AND TRIGGERS
-- =====================================================

-- Function to check user permissions
CREATE OR REPLACE FUNCTION user_has_permission(
    p_user_id INTEGER,
    p_permission_code VARCHAR,
    p_organization_id INTEGER DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    v_has_permission BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1
        FROM user_role_assignments ura
        JOIN role_permissions rp ON ura.role_id = rp.role_id
        JOIN permissions p ON rp.permission_id = p.id
        WHERE ura.user_id = p_user_id
            AND p.permission_code = p_permission_code
            AND ura.is_active = true
            AND (p_organization_id IS NULL OR ura.organization_id = p_organization_id)
            AND (ura.expires_at IS NULL OR ura.expires_at > CURRENT_TIMESTAMP)
    ) INTO v_has_permission;
    
    RETURN v_has_permission;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get user's role at an organization
CREATE OR REPLACE FUNCTION get_user_role_at_org(
    p_user_id INTEGER,
    p_organization_id INTEGER
)
RETURNS TABLE(
    role_code VARCHAR,
    role_level INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.role_code, r.role_level
    FROM user_role_assignments ura
    JOIN roles r ON ura.role_id = r.id
    WHERE ura.user_id = p_user_id
        AND ura.organization_id = p_organization_id
        AND ura.is_active = true
        AND (ura.expires_at IS NULL OR ura.expires_at > CURRENT_TIMESTAMP)
    ORDER BY r.role_level DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update case updated_at
CREATE OR REPLACE FUNCTION update_case_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_case_timestamp
    BEFORE UPDATE ON cases
    FOR EACH ROW
    EXECUTE PROCEDURE update_case_timestamp();

-- =====================================================
-- VIEWS FOR DASHBOARDS
-- =====================================================

-- Case assignment dashboard
CREATE VIEW case_assignment_dashboard AS
SELECT 
    c.id as case_id,
    c.case_number,
    cs.status_name as case_status,
    s.applicant_first_name,
    s.applicant_last_name,
    s.home_city,
    u1.full_name as caseworker_name,
    u2.full_name as project_manager_name,
    u3.full_name as assessor_name,
    c.approved_at,
    c.total_budget,
    c.total_actual_cost,
    CASE 
        WHEN c.work_completed_at IS NOT NULL THEN 'Completed'
        WHEN c.work_started_at IS NOT NULL THEN 'In Progress'
        WHEN c.approved_at IS NOT NULL THEN 'Approved'
        ELSE 'In Pipeline'
    END as project_phase
FROM cases c
JOIN case_statuses cs ON c.status_id = cs.id
JOIN intake_submissions s ON c.submission_id = s.id
LEFT JOIN system_users u1 ON c.assigned_caseworker_id = u1.id
LEFT JOIN system_users u2 ON c.assigned_project_manager_id = u2.id
LEFT JOIN system_users u3 ON c.assigned_assessor_id = u3.id;

-- Organization workload view
CREATE VIEW organization_workload AS
SELECT 
    o.id as organization_id,
    o.organization_name,
    COUNT(DISTINCT c.id) as total_cases,
    COUNT(DISTINCT CASE WHEN cs.status_sequence < 10 THEN c.id END) as active_cases,
    COUNT(DISTINCT CASE WHEN cs.status_code = 'COMPLETED' THEN c.id END) as completed_cases,
    COUNT(DISTINCT wo.id) as active_work_orders,
    COUNT(DISTINCT wt.id) as pending_tasks,
    SUM(CASE WHEN wt.status = 'in_progress' THEN 1 ELSE 0 END) as tasks_in_progress,
    SUM(CASE WHEN vh.id IS NOT NULL THEN vh.hours ELSE 0 END) as volunteer_hours_ytd
FROM coalition_organizations o
LEFT JOIN cases c ON EXISTS (
    SELECT 1 FROM intake_submissions s 
    WHERE s.id = c.submission_id 
    AND s.assigned_organization = o.organization_name
)
LEFT JOIN case_statuses cs ON c.status_id = cs.id
LEFT JOIN work_orders wo ON c.id = wo.case_id
LEFT JOIN work_tasks wt ON wo.id = wt.work_order_id
LEFT JOIN volunteer_hours vh ON vh.work_order_id = wo.id AND vh.date >= DATE_TRUNC('year', CURRENT_DATE)
GROUP BY o.id, o.organization_name;

-- Role-based access control policies (Row Level Security examples)
-- Note: These would be implemented based on specific database system (PostgreSQL RLS)

/*
-- Example RLS policy for cases table
CREATE POLICY case_access_policy ON cases
    USING (
        user_has_permission(current_user_id(), 'CASE_VIEW', get_user_org()) 
        OR assigned_caseworker_id = current_user_id()
        OR assigned_project_manager_id = current_user_id()
    );
*/