-- Reimbursement Workflow

-- User Story: As a Bursar, I want to process reimbursement requests from partners and subcontractors so that they get paid promptly.

-- Data Requirements:

-- |Field|Type|Source|Definition|
-- |---|---|---|---|
-- |`reimbursement_request_id`|UUID|`reimbursement_requests`|Unique identifier|
-- |`case_id`|UUID|`reimbursement_requests`|Which case this is for|
-- |`requesting_org_id`|UUID|`reimbursement_requests`|Who is asking for money|
-- |`invoice_number`|VARCHAR(100)|`reimbursement_requests`|Partner's invoice #|
-- |`invoice_amount`|DECIMAL(12,2)|`reimbursement_requests`|Amount requested|
-- |`invoice_date`|DATE|`reimbursement_requests`|Date of invoice|
-- |`submitted_at`|TIMESTAMP|`reimbursement_requests`|When submitted|
-- |`status`|VARCHAR(20)|`reimbursement_requests`|pending, approved, rejected, paid|
-- |`approved_by`|UUID|`reimbursement_requests`|Who approved it|
-- |`approved_at`|TIMESTAMP|`reimbursement_requests`|When approved|
-- |`paid_at`|TIMESTAMP|`reimbursement_requests`|When paid|
-- |`rejection_reason`|TEXT|`reimbursement_requests`|Why it was rejected|
-- |`aging_days`|INTEGER|Calculated|Days since submission|

-- Business Rules:

-- + Cannot submit reimbursement if total approved would exceed $50,000 
-- + Cannot submit reimbursement if case is not claimed by requesting org
-- + Invoices must be approved within 30 days (SLA target)
-- + Rejected invoices can be resubmitted with corrections
    
-- Reimbursement requests table
CREATE TABLE reimbursement_requests (
    id SERIAL PRIMARY KEY,
    request_id VARCHAR(50) UNIQUE NOT NULL, -- Format: REIMB-YYYY-XXXXX
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    organization_id INTEGER REFERENCES coalition_organizations(id),
    submitted_by INTEGER REFERENCES system_users(id),
    
    -- Invoice details
    invoice_number VARCHAR(100),
    invoice_date DATE,
    invoice_amount DECIMAL(12,2) NOT NULL,
    invoice_document_id INTEGER REFERENCES case_documents(id),
    
    -- Description
    line_items JSONB, -- Array of {description, quantity, rate, total}
    notes TEXT,
    
    -- Status tracking
    status VARCHAR(20) DEFAULT 'pending', -- pending, review, approved, rejected, paid
    approved_by INTEGER REFERENCES system_users(id),
    approved_at TIMESTAMP,
    rejected_by INTEGER REFERENCES system_users(id),
    rejected_at TIMESTAMP,
    rejection_reason TEXT,
    paid_by INTEGER REFERENCES system_users(id),
    paid_at TIMESTAMP,
    payment_reference VARCHAR(100),
    
    -- Audit
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_reimbursement_case (case_id),
    INDEX idx_reimbursement_org (organization_id),
    INDEX idx_reimbursement_status (status)
);
-- Generate request ID
CREATE OR REPLACE FUNCTION generate_reimbursement_id()
RETURNS TRIGGER AS $$
BEGIN
    NEW.request_id := 'REIMB-' || TO_CHAR(NEW.submitted_at, 'YYYY') || '-' || LPAD(NEW.id::TEXT, 5, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trigger_reimbursement_id
    BEFORE INSERT ON reimbursement_requests
    FOR EACH ROW
    EXECUTE PROCEDURE generate_reimbursement_id();
-- Reimbursement aging view
CREATE OR REPLACE VIEW reimbursement_aging AS
SELECT 
    rr.id,
    rr.request_id,
    rr.case_id,
    c.case_number,
    co.organization_name,
    rr.invoice_amount,
    rr.status,
    rr.submitted_at,
    EXTRACT(DAY FROM (CURRENT_TIMESTAMP - rr.submitted_at)) AS days_aging,
    CASE 
        WHEN EXTRACT(DAY FROM (CURRENT_TIMESTAMP - rr.submitted_at)) > 30 THEN 'OVERDUE'
        WHEN EXTRACT(DAY FROM (CURRENT_TIMESTAMP - rr.submitted_at)) > 20 THEN 'CRITICAL'
        WHEN EXTRACT(DAY FROM (CURRENT_TIMESTAMP - rr.submitted_at)) > 10 THEN 'URGENT'
        ELSE 'NORMAL'
    END AS aging_priority,
    rr.approved_at,
    rr.paid_at
FROM reimbursement_requests rr
JOIN cases c ON rr.case_id = c.id
JOIN coalition_organizations co ON rr.organization_id = co.id
WHERE rr.status NOT IN ('paid', 'rejected');