-- Edit request tracking
CREATE TABLE edit_requests (
    id SERIAL PRIMARY KEY,
    case_id INTEGER REFERENCES cases(id),
    requested_by INTEGER REFERENCES system_users(id),
    field_name VARCHAR(100),
    old_value TEXT,
    new_value TEXT,
    reason TEXT,
    status VARCHAR(20) DEFAULT 'pending', -- pending, approved, denied
    reviewed_by INTEGER REFERENCES system_users(id),
    reviewed_at TIMESTAMP,
    approved_at TIMESTAMP,
    change_incorporated BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);