-- Migration: Add assessment SOW fields to existing assessments table
-- The assessments table already exists with crew scheduling fields.
-- This adds the application/SOW-related columns from assessment-anatomy.md.

-- Add missing columns to assessments (all IF NOT EXISTS for safety)
ALTER TABLE assessments ADD COLUMN IF NOT EXISTS application_id      BIGINT;
ALTER TABLE assessments ADD COLUMN IF NOT EXISTS organization_id     BIGINT;
ALTER TABLE assessments ADD COLUMN IF NOT EXISTS claim_number        VARCHAR(32);
ALTER TABLE assessments ADD COLUMN IF NOT EXISTS date_created        TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE assessments ADD COLUMN IF NOT EXISTS date_of_loss        DATE;
ALTER TABLE assessments ADD COLUMN IF NOT EXISTS date_inspected      DATE;
ALTER TABLE assessments ADD COLUMN IF NOT EXISTS date_received       DATE;
ALTER TABLE assessments ADD COLUMN IF NOT EXISTS date_entered        DATE;
ALTER TABLE assessments ADD COLUMN IF NOT EXISTS policy_number       VARCHAR(64);
ALTER TABLE assessments ADD COLUMN IF NOT EXISTS homeowner_names     JSONB DEFAULT '[]';
ALTER TABLE assessments ADD COLUMN IF NOT EXISTS full_address        TEXT;
ALTER TABLE assessments ADD COLUMN IF NOT EXISTS street              TEXT;
ALTER TABLE assessments ADD COLUMN IF NOT EXISTS city                TEXT;
ALTER TABLE assessments ADD COLUMN IF NOT EXISTS state               TEXT DEFAULT 'NC';
ALTER TABLE assessments ADD COLUMN IF NOT EXISTS zip                 TEXT;
ALTER TABLE assessments ADD COLUMN IF NOT EXISTS phone               TEXT;
ALTER TABLE assessments ADD COLUMN IF NOT EXISTS is_emergency        BOOLEAN DEFAULT false;
ALTER TABLE assessments ADD COLUMN IF NOT EXISTS emergency_desc      TEXT;
ALTER TABLE assessments ADD COLUMN IF NOT EXISTS total_construction_price  NUMERIC(12,2);
ALTER TABLE assessments ADD COLUMN IF NOT EXISTS assessor_name       TEXT;

-- Add indexes for new columns
CREATE INDEX IF NOT EXISTS idx_assessments_application ON assessments(application_id);
CREATE INDEX IF NOT EXISTS idx_assessments_claim_number ON assessments(claim_number);
CREATE INDEX IF NOT EXISTS idx_assessments_org ON assessments(organization_id);

-- scope_of_work_line_items already exists from the prior migration.
-- Add the cost-tracking columns if missing.
ALTER TABLE scope_of_work_line_items ADD COLUMN IF NOT EXISTS task_name         TEXT;
ALTER TABLE scope_of_work_line_items ADD COLUMN IF NOT EXISTS location          TEXT;
ALTER TABLE scope_of_work_line_items ADD COLUMN IF NOT EXISTS details           TEXT;
ALTER TABLE scope_of_work_line_items ADD COLUMN IF NOT EXISTS estimated_cost    NUMERIC(12,2);
ALTER TABLE scope_of_work_line_items ADD COLUMN IF NOT EXISTS quoted_cost       NUMERIC(12,2);
ALTER TABLE scope_of_work_line_items ADD COLUMN IF NOT EXISTS actual_cost       NUMERIC(12,2);
ALTER TABLE scope_of_work_line_items ADD COLUMN IF NOT EXISTS status            VARCHAR(20) DEFAULT 'pending';
ALTER TABLE scope_of_work_line_items ADD COLUMN IF NOT EXISTS repair_need_id    BIGINT;
ALTER TABLE scope_of_work_line_items ADD COLUMN IF NOT EXISTS case_id           BIGINT;

CREATE INDEX IF NOT EXISTS idx_sow_line_items_assessment ON scope_of_work_line_items(assessment_id);
CREATE INDEX IF NOT EXISTS idx_sow_line_items_status ON scope_of_work_line_items(status);
CREATE INDEX IF NOT EXISTS idx_sow_line_items_repair_need ON scope_of_work_line_items(repair_need_id);

-- materials_inventory already exists. Add columns if missing.
ALTER TABLE materials_inventory ADD COLUMN IF NOT EXISTS sow_line_item_id  BIGINT;
ALTER TABLE materials_inventory ADD COLUMN IF NOT EXISTS material_name     TEXT;
ALTER TABLE materials_inventory ADD COLUMN IF NOT EXISTS quantity          NUMERIC(10,2);
ALTER TABLE materials_inventory ADD COLUMN IF NOT EXISTS unit              TEXT;
ALTER TABLE materials_inventory ADD COLUMN IF NOT EXISTS unit_cost         NUMERIC(10,2);

CREATE INDEX IF NOT EXISTS idx_materials_sow ON materials_inventory(sow_line_item_id);

-- assessment_documents already exists. Add columns if missing.
ALTER TABLE assessment_documents ADD COLUMN IF NOT EXISTS document_type  VARCHAR(40);
ALTER TABLE assessment_documents ADD COLUMN IF NOT EXISTS file_path      TEXT;
ALTER TABLE assessment_documents ADD COLUMN IF NOT EXISTS file_name      TEXT;
ALTER TABLE assessment_documents ADD COLUMN IF NOT EXISTS file_size      BIGINT;
ALTER TABLE assessment_documents ADD COLUMN IF NOT EXISTS mime_type      VARCHAR(100);
ALTER TABLE assessment_documents ADD COLUMN IF NOT EXISTS uploaded_at    TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE assessment_documents ADD COLUMN IF NOT EXISTS uploaded_by    BIGINT;
ALTER TABLE assessment_documents ADD COLUMN IF NOT EXISTS metadata       JSONB DEFAULT '{}';

CREATE INDEX IF NOT EXISTS idx_assessment_docs_assessment ON assessment_documents(assessment_id);

-- site_photos table — create if not exists (depends on repair_needs which may not exist yet)
-- Use a DO block to handle the conditional creation gracefully.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'site_photos') THEN
        CREATE TABLE site_photos (
            id              BIGSERIAL PRIMARY KEY,
            assessment_id   BIGINT,  -- references assessments(id) — add constraint later when tables are stable
            repair_need_id  BIGINT,  -- references repair_needs(id) — add constraint later
            file_path       TEXT NOT NULL,
            file_name       TEXT NOT NULL,
            title           TEXT,
            date_taken      TIMESTAMPTZ,
            taken_by        TEXT,
            photo_type      VARCHAR(20) DEFAULT 'before',
            created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
        );
        CREATE INDEX idx_site_photos_assessment ON site_photos(assessment_id);
        CREATE INDEX idx_site_photos_repair_need ON site_photos(repair_need_id);
    END IF;
END
$$;
