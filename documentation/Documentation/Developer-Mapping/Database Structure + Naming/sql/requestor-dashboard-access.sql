-- Generate temporary access token for guest users
CREATE OR REPLACE FUNCTION generate_guest_access_token(p_submission_id INTEGER)
RETURNS VARCHAR AS $$
DECLARE
    v_token UUID;
    v_expires TIMESTAMP;
BEGIN
    v_token := gen_random_uuid();
    v_expires := CURRENT_TIMESTAMP + INTERVAL '30 days';
    
    INSERT INTO guest_access_tokens (submission_id, token, expires_at)
    VALUES (p_submission_id, v_token, v_expires)
    ON CONFLICT (submission_id) DO UPDATE
    SET token = EXCLUDED.token,
        expires_at = EXCLUDED.expires_at,
        last_accessed = NULL;
    
    RETURN '/track/' || v_token;
END;
$$ LANGUAGE plpgsql;

-- Guest access tokens table
CREATE TABLE guest_access_tokens (
    id SERIAL PRIMARY KEY,
    submission_id INTEGER REFERENCES intake_submissions(id) UNIQUE,
    token UUID UNIQUE DEFAULT gen_random_uuid(),
    expires_at TIMESTAMP,
    last_accessed TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Function to validate guest access
CREATE OR REPLACE FUNCTION validate_guest_access(p_token UUID)
RETURNS TABLE(
    valid BOOLEAN,
    submission_id INTEGER,
    case_number VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        gat.expires_at > CURRENT_TIMESTAMP AS valid,
        s.id,
        c.case_number
    FROM guest_access_tokens gat
    JOIN intake_submissions s ON gat.submission_id = s.id
    LEFT JOIN cases c ON s.id = c.submission_id
    WHERE gat.token = p_token;
    
    -- Update last accessed
    UPDATE guest_access_tokens 
    SET last_accessed = CURRENT_TIMESTAMP
    WHERE token = p_token;
END;
$$ LANGUAGE plpgsql;