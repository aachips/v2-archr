-- =====================================================================
-- ARCHR sync for EXISTING databases (local dev copies, deployed hosts)
-- =====================================================================
-- Contains ONLY the idempotent deltas from the webhost-readiness work.
-- Safe to run repeatedly. Requires the base schema to already exist.
-- For a FRESH/empty database, use sql/_master.phppgadmin.sql instead.
--
-- Intentionally NOT included: the EXECUTE FUNCTION -> EXECUTE PROCEDURE
-- trigger syntax change. It is purely syntactic (for PG < 11 hosts);
-- existing triggers keep working and PG 11+ accepts both forms, so
-- existing databases need no action for it.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. refresh_match_scores(): drop CONCURRENTLY. A concurrent refresh
--    requires a UNIQUE index the view does not have, so every call failed
--    and took the triggering intake INSERT down with it. (Masked locally
--    by the superuser trigger bypass in app/lib/intake-save.php.)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION refresh_match_scores()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW application_match_scores;
END;
$$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------------
-- 2. Requestor account link (from sql/requestor-account-link.sql)
-- ---------------------------------------------------------------------
ALTER TABLE intake_submissions
ADD COLUMN IF NOT EXISTS requestor_user_id INTEGER;

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

INSERT INTO roles (role_code, role_name, role_level, description, is_system_role)
VALUES ('REQUESTOR', 'Requestor', 1, 'Homeowner who has submitted an application for repair services', true)
ON CONFLICT (role_code) DO NOTHING;

COMMENT ON COLUMN intake_submissions.requestor_user_id IS
'Link to system_users table for requestor portal access. Set automatically on submission.';

-- ---------------------------------------------------------------------
-- 3. SUPER_ADMIN role + permissions (from sql/add/super-admin-role.sql)
-- ---------------------------------------------------------------------
INSERT INTO roles (role_code, role_name, role_level, description, is_system_role)
SELECT 'SUPER_ADMIN', 'Super Administrator', 15, 'System-level administrator across all organizations and the entire platform', true
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE role_code = 'SUPER_ADMIN');

INSERT INTO permission_categories (category_code, category_name) VALUES
    ('SYSTEM', 'System Administration'),
    ('AUDIT', 'Audit & Logs'),
    ('DATA', 'Data Management'),
    ('SUPPORT', 'Support & Maintenance')
ON CONFLICT (category_code) DO NOTHING;

INSERT INTO permissions (permission_code, permission_name, category_id) VALUES
    ('SYSTEM_VIEW', 'View system status', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('SYSTEM_EDIT', 'Edit system configuration', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('SYSTEM_BACKUP', 'Trigger system backups', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('SYSTEM_RESTORE', 'Restore from backup', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('SYSTEM_CONFIG', 'Manage system-wide settings', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('ORG_VIEW_ALL', 'View all organizations', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('ORG_CREATE', 'Create organizations', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('ORG_EDIT', 'Edit organizations', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('ORG_ARCHIVE', 'Archive organizations', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('ORG_RESTORE', 'Restore archived organizations', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('USER_VIEW_ALL', 'View all users', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('USER_CREATE', 'Create users', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('USER_EDIT', 'Edit users', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('USER_DEACTIVATE', 'Deactivate users', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('USER_IMPERSONATE', 'Impersonate users', (SELECT id FROM permission_categories WHERE category_code = 'SYSTEM')),
    ('AUDIT_VIEW_ALL', 'View all audit logs', (SELECT id FROM permission_categories WHERE category_code = 'AUDIT')),
    ('AUDIT_EXPORT', 'Export audit logs', (SELECT id FROM permission_categories WHERE category_code = 'AUDIT')),
    ('AUDIT_CONFIG', 'Configure audit retention', (SELECT id FROM permission_categories WHERE category_code = 'AUDIT')),
    ('DATA_VIEW_ALL', 'View all data', (SELECT id FROM permission_categories WHERE category_code = 'DATA')),
    ('DATA_EXPORT', 'Export data', (SELECT id FROM permission_categories WHERE category_code = 'DATA')),
    ('DATA_IMPORT', 'Import data', (SELECT id FROM permission_categories WHERE category_code = 'DATA')),
    ('DATA_ARCHIVE', 'Archive data', (SELECT id FROM permission_categories WHERE category_code = 'DATA')),
    ('SUPPORT_TICKET_VIEW_ALL', 'View all support tickets', (SELECT id FROM permission_categories WHERE category_code = 'SUPPORT')),
    ('SYSTEM_LOGS_VIEW', 'View system logs', (SELECT id FROM permission_categories WHERE category_code = 'SUPPORT'))
ON CONFLICT (permission_code) DO NOTHING;

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.role_code = 'SUPER_ADMIN'
  AND NOT EXISTS (
      SELECT 1 FROM role_permissions rp
      WHERE rp.role_id = r.id AND rp.permission_id = p.id
  );

-- ---------------------------------------------------------------------
-- 4. system_users username/first/last (sql/add/system-users-username-fields.sql)
-- ---------------------------------------------------------------------
ALTER TABLE system_users
ADD COLUMN IF NOT EXISTS username VARCHAR(100) UNIQUE;

ALTER TABLE system_users
ADD COLUMN IF NOT EXISTS first_name VARCHAR(100);

ALTER TABLE system_users
ADD COLUMN IF NOT EXISTS last_name VARCHAR(100);

CREATE INDEX IF NOT EXISTS idx_system_users_username ON system_users(username);

UPDATE system_users
SET username = LOWER(SPLIT_PART(email, '@', 1))
WHERE username IS NULL;

COMMENT ON COLUMN system_users.username IS 'Unique username for login (auto-generated from email on creation)';
COMMENT ON COLUMN system_users.first_name IS 'User first name';
COMMENT ON COLUMN system_users.last_name IS 'User last name';

ALTER TABLE user_role_assignments
DROP CONSTRAINT IF EXISTS user_role_assignments_user_id_organization_id_role_id_key;

CREATE UNIQUE INDEX IF NOT EXISTS idx_user_role_org_unique
ON user_role_assignments (user_id, role_id, organization_id)
WHERE organization_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_user_role_null_org_unique
ON user_role_assignments (user_id, role_id)
WHERE organization_id IS NULL;

COMMENT ON COLUMN user_role_assignments.organization_id IS
'Organization affiliation (NULL for requestors who are not part of an organization)';

-- ---------------------------------------------------------------------
-- 5. session_indefinite (sql/add/session-indefinite.sql)
-- ---------------------------------------------------------------------
ALTER TABLE system_users
    ADD COLUMN IF NOT EXISTS session_indefinite BOOLEAN DEFAULT FALSE;

COMMENT ON COLUMN system_users.session_indefinite IS 'When true, the login session cookie should be persisted for a long duration instead of the default 24-hour expiry.';
