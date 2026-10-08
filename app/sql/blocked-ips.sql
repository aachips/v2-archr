-- Blocked IPs table for Super Admin security management
-- Run: psql archr -f sql/blocked-ips.sql

BEGIN;

CREATE TABLE IF NOT EXISTS blocked_ips (
    id          BIGSERIAL PRIMARY KEY,
    ip_address  VARCHAR(45) NOT NULL UNIQUE,
    blocked_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    blocked_by  BIGINT REFERENCES system_users(id),
    reason      TEXT,
    is_active   BOOLEAN NOT NULL DEFAULT true,
    expires_at  TIMESTAMPTZ,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for active blocked IP lookups
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes WHERE indexname = 'idx_blocked_ips_active'
    ) THEN
        CREATE INDEX idx_blocked_ips_active
            ON blocked_ips (ip_address, is_active);
    END IF;
END
$$;

COMMIT;
