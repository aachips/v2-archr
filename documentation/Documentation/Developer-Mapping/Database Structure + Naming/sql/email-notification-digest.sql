-- =====================================================
-- EMAIL NOTIFICATION SYSTEM
-- Batch digest for non-urgent notifications
-- =====================================================

-- Email queue table
CREATE TABLE email_queue (
    id SERIAL PRIMARY KEY,
    recipient_email VARCHAR(255),
    recipient_name VARCHAR(200),
    subject VARCHAR(500),
    body TEXT,
    body_html TEXT,
    
    -- Metadata
    notification_type VARCHAR(50),
    related_entity_type VARCHAR(50),
    related_entity_id INTEGER,
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending', -- pending, sent, failed
    attempts INTEGER DEFAULT 0,
    last_attempt_at TIMESTAMP,
    error_message TEXT,
    
    -- Scheduling
    priority INTEGER DEFAULT 5, -- 1=highest
    send_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sent_at TIMESTAMP
);

-- Function to queue new application notification emails
CREATE OR REPLACE FUNCTION queue_new_application_emails(p_submission_id INTEGER)
RETURNS VOID AS $$
DECLARE
    v_submission RECORD;
    v_staff RECORD;
BEGIN
    SELECT * INTO v_submission FROM intake_submissions WHERE id = p_submission_id;
    
    -- Queue emails for each staff role (batched, not immediate)
    FOR v_staff IN 
        SELECT DISTINCT u.email, u.full_name, r.role_code
        FROM system_users u
        JOIN user_role_assignments ura ON u.id = ura.user_id
        JOIN roles r ON ura.role_id = r.id
        WHERE r.role_code IN ('ADMIN', 'CASEWORKER', 'PROJECT_MANAGER')
          AND u.email IS NOT NULL
    LOOP
        INSERT INTO email_queue (
            recipient_email, recipient_name, subject, body,
            notification_type, related_entity_type, related_entity_id,
            priority
        ) VALUES (
            v_staff.email,
            v_staff.full_name,
            '[ARCHR] New Application Ready for Review',
            E'Hello ' || v_staff.full_name || ',\n\n' ||
            'A new application has been submitted and is ready for review.\n\n' ||
            'Applicant: ' || v_submission.applicant_first_name || ' ' || v_submission.applicant_last_name || '\n' ||
            'Address: ' || v_submission.home_address || '\n' ||
            'Submitted: ' || v_submission.submitted_at || '\n\n' ||
            'View in queue: https://apply.archr.org/dashboard/review\n\n' ||
            'ARCHR Platform',
            'new_application',
            'submission',
            p_submission_id,
            3 -- Normal priority
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Function to send daily digest emails
CREATE OR REPLACE FUNCTION send_daily_digest()
RETURNS INTEGER AS $$
DECLARE
    v_user RECORD;
    v_digest_count INTEGER := 0;
    v_digest_body TEXT;
BEGIN
    FOR v_user IN 
        SELECT DISTINCT u.id, u.email, u.full_name
        FROM system_users u
        JOIN user_role_assignments ura ON u.id = ura.user_id
        WHERE u.email_digest_enabled = TRUE
          AND u.is_active = TRUE
    LOOP
        -- Build digest content
        WITH user_notifications AS (
            SELECT * FROM get_unread_notifications(v_user.id, 50)
        ),
        pending_applications AS (
            SELECT COUNT(*) AS pending_count
            FROM review_queue rq
            WHERE rq.status = 'PENDING_REVIEW'
        )
        SELECT 
            'Daily Digest - ' || CURRENT_DATE || E'\n\n' ||
            'Pending Applications: ' || pending_count || E'\n\n' ||
            'Your Notifications:\n' ||
            string_agg('- ' || n.title || ' (' || n.created_at::DATE || ')', E'\n')
        INTO v_digest_body
        FROM pending_applications, user_notifications n;
        
        -- Queue digest email
        INSERT INTO email_queue (
            recipient_email, recipient_name, subject, body,
            notification_type, priority
        ) VALUES (
            v_user.email,
            v_user.full_name,
            '[ARCHR] Daily Digest - ' || CURRENT_DATE,
            v_digest_body,
            'daily_digest',
            5 -- Lower priority, send after urgent emails
        );
        
        v_digest_count := v_digest_count + 1;
    END LOOP;
    
    RETURN v_digest_count;
END;
$$ LANGUAGE plpgsql;

-- Schedule daily digest (to be run by cron/pg_cron)
-- SELECT send_daily_digest();