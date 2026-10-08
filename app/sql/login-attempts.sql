-- Login attempt rate limiting table
-- Run: psql archr -f sql/login-attempts.sql

BEGIN;

CREATE TABLE IF NOT EXISTS login_attempts (
    id          BIGSERIAL PRIMARY KEY,
    ip_address  VARCHAR(45) NOT NULL,
    email       VARCHAR(255) NOT NULL,
    attempted_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for fast rate limit lookups (only create if it doesn't exist)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes WHERE indexname = 'idx_login_attempts_ip_time'
    ) THEN
        CREATE INDEX idx_login_attempts_ip_time
            ON login_attempts (ip_address, attempted_at);
    END IF;
END
$$;

COMMIT;
