-- Assessment and Scope of Work schema
-- Supports the intake → assessment → SOW → case pipeline
-- Each assessment is attached to an application and produces claimable repair needs

-- ============================================================================
-- ASSESSMENTS
-- One assessment per application (assessor visits and produces the SOW)
-- ============================================================================
CREATE TABLE IF NOT EXISTS assessments (
    id                  BIGSERIAL PRIMARY KEY,
    application_id      BIGINT NOT NULL REFERENCES applications(id),
    organization_id     BIGINT NOT NULL REFERENCES organizations(id),
    claim_number        VARCHAR(32) NOT NULL UNIQUE,  -- e.g., "D245VI"
    date_created        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    date_of_loss        DATE,
    date_inspected      DATE,
    date_received       DATE,
    date_entered        DATE,
    policy_number       VARCHAR(64),
    homeowner_names     JSONB NOT NULL DEFAULT '[]',  -- array of strings
    full_address        TEXT NOT NULL,
    street              TEXT,
    city                TEXT,
    state               TEXT DEFAULT 'NC',
    zip                 TEXT,
    phone               TEXT,
    is_emergency        BOOLEAN NOT NULL DEFAULT false,
    emergency_desc      TEXT,
    total_construction_price  NUMERIC(12,2),
    assessor_name       TEXT,
    notes               TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- SCOPE_OF_WORK_LINE_ITEMS
-- Each row: one repair task from the SOW table
-- These become claimable Repair Needs or Cases
-- ============================================================================
CREATE TABLE IF NOT EXISTS scope_of_work_line_items (
    id                  BIGSERIAL PRIMARY KEY,
    assessment_id       BIGINT NOT NULL REFERENCES assessments(id) ON DELETE CASCADE,
    task_name           TEXT NOT NULL,          -- e.g., "Debris Removal"
    location            TEXT,                    -- e.g., "Whole property", "North side"
    details             TEXT,                    -- Description of the repair
    estimated_cost      NUMERIC(12,2),           -- Assessor's budget estimate
    quoted_cost         NUMERIC(12,2),           -- Subcontractor/org quote (filled later)
    actual_cost         NUMERIC(12,2),           -- Final invoice amount (filled after completion)
    status              VARCHAR(20) NOT NULL DEFAULT 'pending',  -- pending, claimed, in_progress, completed
    repair_need_id      BIGINT,                  -- Links to repair_needs.id when forked into a claimable need
    case_id             BIGINT,                  -- Links to cases.id if grouped into a case
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- MATERIALS_INVENTORY
-- Itemized breakdown of materials per SOW line item
-- ============================================================================
CREATE TABLE IF NOT EXISTS materials_inventory (
    id                  BIGSERIAL PRIMARY KEY,
    sow_line_item_id    BIGINT NOT NULL REFERENCES scope_of_work_line_items(id) ON DELETE CASCADE,
    material_name       TEXT NOT NULL,           -- e.g., "2x4 Lumber", "Roofing Shingles"
    quantity            NUMERIC(10,2) NOT NULL,
    unit                TEXT,                    -- e.g., "ft", "sqft", "each", "box"
    unit_cost           NUMERIC(10,2) NOT NULL,
    total_cost          NUMERIC(10,2) GENERATED ALWAYS AS (quantity * unit_cost) STORED,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- ASSESSMENT_DOCUMENTS
-- Links assessment-related files to the Document Bucket
-- ============================================================================
CREATE TABLE IF NOT EXISTS assessment_documents (
    id                  BIGSERIAL PRIMARY KEY,
    assessment_id       BIGINT NOT NULL REFERENCES assessments(id) ON DELETE CASCADE,
    document_type       VARCHAR(40) NOT NULL,   -- 'assessment', 'sow', 'verification', 'materials', 'roof_diagram'
    file_path           TEXT NOT NULL,           -- Dropbox path or local file path
    file_name           TEXT NOT NULL,
    file_size           BIGINT,
    mime_type           VARCHAR(100),
    uploaded_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    uploaded_by         BIGINT REFERENCES system_users(id),
    metadata            JSONB DEFAULT '{}'       -- Extra metadata: title, date_taken, taken_by for photos
);

-- ============================================================================
-- SITE_PHOTOS
-- Before/after photos with metadata, linked to assessments and/or repair needs
-- ============================================================================
CREATE TABLE IF NOT EXISTS site_photos (
    id                  BIGSERIAL PRIMARY KEY,
    assessment_id       BIGINT REFERENCES assessments(id),
    repair_need_id      BIGINT REFERENCES repair_needs(id),
    file_path           TEXT NOT NULL,
    file_name           TEXT NOT NULL,
    title               TEXT,                    -- Descriptive title for the photo
    date_taken          TIMESTAMPTZ,
    taken_by            TEXT,                    -- Photographer name
    photo_type          VARCHAR(20) DEFAULT 'before',  -- 'before' or 'after'
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- Indexes for performance
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_assessments_application ON assessments(application_id);
CREATE INDEX IF NOT EXISTS idx_assessments_claim_number ON assessments(claim_number);
CREATE INDEX IF NOT EXISTS idx_assessments_org ON assessments(organization_id);
CREATE INDEX IF NOT EXISTS idx_sow_line_items_assessment ON scope_of_work_line_items(assessment_id);
CREATE INDEX IF NOT EXISTS idx_sow_line_items_status ON scope_of_work_line_items(status);
CREATE INDEX IF NOT EXISTS idx_sow_line_items_repair_need ON scope_of_work_line_items(repair_need_id);
CREATE INDEX IF NOT EXISTS idx_materials_sow ON materials_inventory(sow_line_item_id);
CREATE INDEX IF NOT EXISTS idx_assessment_docs_assessment ON assessment_documents(assessment_id);
CREATE INDEX IF NOT EXISTS idx_site_photos_assessment ON site_photos(assessment_id);
CREATE INDEX IF NOT EXISTS idx_site_photos_repair_need ON site_photos(repair_need_id);
