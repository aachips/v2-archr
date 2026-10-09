-- Seed superadmin account
-- Password: 12345678 (CHANGE IMMEDIATELY after first login!)

-- Create the user
INSERT INTO system_users (username, email, password_hash, full_name, is_active)
VALUES (
    'admin',
    'admin@archr.org',
    '$2y$10$1lflvHzWm2onouLjXCRGwO3v69woXPPGqyzuLVWXkLMXpqy0NptE2',
    'System Administrator',
    true
)
ON CONFLICT (username) DO UPDATE SET
    password_hash = EXCLUDED.password_hash,
    full_name = EXCLUDED.full_name,
    is_active = true;

-- Assign Super Admin role (role_level = 3)
INSERT INTO user_role_assignments (user_id, role_id)
SELECT u.id, r.id
FROM system_users u, roles r
WHERE u.username = 'admin' AND r.role_code = 'super_admin'
ON CONFLICT (user_id, role_id) DO NOTHING;

-- Verify
SELECT u.id, u.username, u.email, u.full_name, r.role_name, r.role_level
FROM system_users u
LEFT JOIN user_role_assignments ura ON ura.user_id = u.id
LEFT JOIN roles r ON r.id = ura.role_id
WHERE u.username = 'admin';
