-- Add requestor_user_id column to link intake submissions to system_users
-- This allows requestors to track their case through the portal

ALTER TABLE intake_submissions
ADD COLUMN IF NOT EXISTS requestor_user_id INTEGER;

-- FK added separately: intake.sql creates the column WITHOUT the constraint
-- (system_users does not exist yet at that point in a fresh deploy), and
-- ADD COLUMN IF NOT EXISTS is a no-op when the column already exists, so a
-- combined statement could never add the constraint. This DO block adds it
-- exactly once, on both fresh and existing databases.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'intake_submissions_requestor_user_id_fkey'
    ) THEN
        ALTER TABLE intake_submissions
        ADD CONSTRAINT intake_submissions_requestor_user_id_fkey
        FOREIGN KEY (requestor_user_id) REFERENCES system_users(id) ON DELETE SET NULL;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_intake_submissions_requestor_user_id 
ON intake_submissions(requestor_user_id);

-- Add REQUESTOR role if it doesn't exist
INSERT INTO roles (role_code, role_name, role_level, description, is_system_role)
VALUES ('REQUESTOR', 'Requestor', 1, 'Homeowner who has submitted an application for repair services', true)
ON CONFLICT (role_code) DO NOTHING;

-- Grant REQUESTOR role appropriate permissions to view their own case
-- Requestors should be able to:
-- 1. View their own intake submission
-- 2. Upload documents to their case
-- 3. View their case status and progress
-- 4. Communicate with assigned staff

COMMENT ON COLUMN intake_submissions.requestor_user_id IS 
'Link to system_users table for requestor portal access. Set automatically on submission.';
