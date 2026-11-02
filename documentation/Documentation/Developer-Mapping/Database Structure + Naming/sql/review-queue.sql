-- =====================================================
-- FIFO REVIEW QUEUE
-- Applications appear in order received
-- =====================================================

CREATE SEQUENCE fifo_sequence START 1;

CREATE TABLE review_queue (
    id SERIAL PRIMARY KEY,
    submission_id INTEGER REFERENCES intake_submissions(id) UNIQUE,
    
    -- Queue position (FIFO)
    fifo_order BIGINT DEFAULT nextval('fifo_sequence'),
    
    -- Status tracking
    status VARCHAR(50) DEFAULT 'PENDING_REVIEW', -- PENDING_REVIEW, IN_REVIEW, REVIEWED, ASSIGNED, INELIGIBLE
    
    -- Assignment
    assigned_to_id INTEGER REFERENCES system_users(id),
    assigned_at TIMESTAMP,
    organization_id INTEGER REFERENCES coalition_organizations(id),
    
    -- Timestamps
    queued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP,
    completed_at TIMESTAMP,
    
    -- Metadata
    priority_score INTEGER DEFAULT 0, -- Calculated from triage score
    notes TEXT
);

CREATE INDEX idx_queue_order  ON review_queue (fifo_order);
CREATE INDEX idx_queue_status ON review_queue (status, priority_score DESC);

-- Function to get next application in queue (FIFO with priority)
CREATE OR REPLACE FUNCTION get_next_in_queue(p_organization_id INTEGER DEFAULT NULL)
RETURNS TABLE(
    submission_id INTEGER,
    case_number VARCHAR,
    applicant_name VARCHAR,
    fifo_order BIGINT,
    priority_score INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        rq.submission_id,
        c.case_number,
        s.applicant_first_name || ' ' || s.applicant_last_name AS applicant_name,
        rq.fifo_order,
        rq.priority_score
    FROM review_queue rq
    JOIN intake_submissions s ON rq.submission_id = s.id
    LEFT JOIN cases c ON s.id = c.submission_id
    WHERE rq.status = 'PENDING_REVIEW'
      AND (p_organization_id IS NULL OR rq.organization_id = p_organization_id)
    ORDER BY rq.priority_score DESC, rq.fifo_order ASC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;