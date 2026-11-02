-- Add a per-user preference for an indefinite (persistent) login session.

ALTER TABLE system_users
    ADD COLUMN IF NOT EXISTS session_indefinite BOOLEAN DEFAULT FALSE;

COMMENT ON COLUMN system_users.session_indefinite IS 'When true, the login session cookie should be persisted for a long duration instead of the default 24-hour expiry.';
