-- Add missing username, first_name, and last_name fields to system_users
-- Required for account creation from intake submissions

-- Add username column (unique identifier for login)
ALTER TABLE system_users 
ADD COLUMN IF NOT EXISTS username VARCHAR(100) UNIQUE;

-- Add first_name and last_name columns
ALTER TABLE system_users 
ADD COLUMN IF NOT EXISTS first_name VARCHAR(100);

ALTER TABLE system_users 
ADD COLUMN IF NOT EXISTS last_name VARCHAR(100);

-- Create index on username for fast lookups
CREATE INDEX IF NOT EXISTS idx_system_users_username ON system_users(username);

-- Update existing records to have usernames if they don't
-- (using email prefix as username for existing users)
UPDATE system_users 
SET username = LOWER(SPLIT_PART(email, '@', 1))
WHERE username IS NULL;

COMMENT ON COLUMN system_users.username IS 'Unique username for login (auto-generated from email on creation)';
COMMENT ON COLUMN system_users.first_name IS 'User first name';
COMMENT ON COLUMN system_users.last_name IS 'User last name';

-- Fix user_role_assignments to allow NULL organization_id for requestors
-- Drop the old unique constraint that includes organization_id
ALTER TABLE user_role_assignments
DROP CONSTRAINT IF EXISTS user_role_assignments_user_id_organization_id_role_id_key;

-- Add a new unique constraint that handles NULLs properly
-- Multiple users can have the same role with NULL organization
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_role_org_unique
ON user_role_assignments (user_id, role_id, organization_id)
WHERE organization_id IS NOT NULL;

-- For NULL organization_id, only one role per user (for requestors)
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_role_null_org_unique
ON user_role_assignments (user_id, role_id)
WHERE organization_id IS NULL;

COMMENT ON COLUMN user_role_assignments.organization_id IS
'Organization affiliation (NULL for requestors who are not part of an organization)';
