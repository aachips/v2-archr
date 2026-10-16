-- Create missing coalition_organizations Table
CREATE TABLE IF NOT EXISTS coalition_organizations (
    id BIGSERIAL PRIMARY KEY,
    organization_code VARCHAR(50) UNIQUE NOT NULL,
    organization_name VARCHAR(255) NOT NULL,
    contact_email VARCHAR(255) NOT NULL,
    contact_phone TEXT,
    is_active BOOLEAN DEFAULT true,
    created_by BIGINT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);  
