-- Migration: add the Super-Administrator role and permissions to existing databases.

-- 1. Insert the SUPER_ADMIN role (highest level)
INSERT INTO roles (role_code, role_name, role_level, description, is_system_role)
SELECT 'SUPER_ADMIN', 'Super Administrator', 15, 'System-level administrator across all organizations and the entire platform', true
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE role_code = 'SUPER_ADMIN');

-- 2. Insert new permission categories (idempotent)
INSERT INTO permission_categories (category_code, category_name) VALUES
    ('SYSTEM', 'System Administration'),
    ('AUDIT', 'Audit & Logs'),
    ('DATA', 'Data Management'),
    ('SUPPORT', 'Support & Maintenance')
ON CONFLICT (category_code) DO NOTHING;

-- 3. Insert Super-Admin permissions (idempotent)
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

-- 4. Grant all current and future permissions to SUPER_ADMIN
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.role_code = 'SUPER_ADMIN'
  AND NOT EXISTS (
      SELECT 1 FROM role_permissions rp
      WHERE rp.role_id = r.id AND rp.permission_id = p.id
  );
