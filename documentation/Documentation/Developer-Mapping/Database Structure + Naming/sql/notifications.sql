-- =====================================================
-- NOTIFICATION SYSTEM
-- Real-time alerts for staff roles
-- =====================================================

-- Notifications table
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES system_users(id),
    notification_type VARCHAR(50) NOT NULL, -- new_application, assignment, deadline, etc.
    title VARCHAR(255) NOT NULL,
    body TEXT,
    
    -- Related entity
    entity_type VARCHAR(50), -- submission, case, work_order
    entity_id INTEGER,
    
    -- Status
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    is_archived BOOLEAN DEFAULT FALSE,
    
    -- Priority
    priority VARCHAR(20) DEFAULT 'normal', -- urgent, high, normal, low
    
    -- Delivery
    email_sent BOOLEAN DEFAULT FALSE,
    sms_sent BOOLEAN DEFAULT FALSE,
    in_app_delivered BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user ON notifications (user_id, is_read, created_at DESC);

-- Trigger notifications on new application
CREATE OR REPLACE FUNCTION trigger_new_application_notifications(p_submission_id INTEGER)
RETURNS VOID AS $$
DECLARE
    v_submission RECORD;
    v_role_codes VARCHAR[] := ARRAY['ADMIN', 'CASEWORKER', 'PROJECT_MANAGER', 'BURSAR'];
    v_role_id INTEGER;
    v_user RECORD;
BEGIN
    SELECT * INTO v_submission FROM intake_submissions WHERE id = p_submission_id;
    
    -- Notify all users with relevant roles
    FOR v_user IN 
        SELECT DISTINCT u.id, u.email, u.full_name, ura.role_id
        FROM system_users u
        JOIN user_role_assignments ura ON u.id = ura.user_id
        JOIN roles r ON ura.role_id = r.id
        WHERE r.role_code = ANY(v_role_codes)
          AND u.is_active = TRUE
    LOOP
        -- In-app notification
        INSERT INTO notifications (
            user_id, 
            notification_type, 
            title, 
            body, 
            entity_type, 
            entity_id,
            priority
        ) VALUES (
            v_user.id,
            'new_application',
            'New Application Submitted',
            'Application #' || v_submission.id || ' from ' || 
            v_submission.applicant_first_name || ' ' || v_submission.applicant_last_name,
            'submission',
            p_submission_id,
            'high'
        );
        
        -- Email notification (batch send, not per-record)
        -- Would be handled by a separate email worker
    END LOOP;
    
    -- Also trigger webhook for external integrations
    PERFORM trigger_webhook('new_application', p_submission_id);
END;
$$ LANGUAGE plpgsql;

-- Get unread notifications for a user
CREATE OR REPLACE FUNCTION get_unread_notifications(p_user_id INTEGER, p_limit INTEGER DEFAULT 20)
RETURNS TABLE(
    notification_id INTEGER,
    notification_type VARCHAR,
    title VARCHAR,
    body TEXT,
    created_at TIMESTAMP,
    priority VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        n.id,
        n.notification_type,
        n.title,
        n.body,
        n.created_at,
        n.priority
    FROM notifications n
    WHERE n.user_id = p_user_id
      AND n.is_read = FALSE
      AND n.is_archived = FALSE
    ORDER BY 
        CASE n.priority 
            WHEN 'urgent' THEN 1
            WHEN 'high' THEN 2
            WHEN 'normal' THEN 3
            ELSE 4
        END,
        n.created_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Mark notification as read
CREATE OR REPLACE FUNCTION mark_notification_read(p_notification_id INTEGER, p_user_id INTEGER)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE notifications 
    SET is_read = TRUE, read_at = CURRENT_TIMESTAMP
    WHERE id = p_notification_id AND user_id = p_user_id;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;