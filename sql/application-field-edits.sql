-- Application Field Edits table
-- Stores the input/corrected pattern for all application fields.
-- Every edit is logged with who, when, and optional note.

CREATE TABLE IF NOT EXISTS application_field_edits (
    id                  BIGSERIAL PRIMARY KEY,
    application_id      BIGINT NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
    field_name          VARCHAR(100) NOT NULL,
    input_value         TEXT,               -- Original value from form submission
    corrected_value     TEXT,               -- Corrected value after admin edit
    edit_note           TEXT,               -- Optional note explaining the change
    edited_by           BIGINT REFERENCES system_users(id),
    edited_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_app_edits_application ON application_field_edits(application_id);
CREATE INDEX IF NOT EXISTS idx_app_edits_field ON application_field_edits(application_id, field_name);
CREATE INDEX IF NOT EXISTS idx_app_edits_edited_at ON application_field_edits(edited_at DESC);

-- Add missing columns to applications table (canonical field set from the reconciliation doc)
ALTER TABLE applications ADD COLUMN IF NOT EXISTS applicant_dob              DATE;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS primary_spoken_language    VARCHAR(50);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS home_phone                 VARCHAR(20);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS cell_phone                 VARCHAR(20);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS unit                       VARCHAR(50);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS city_town                  VARCHAR(100);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS state_province             VARCHAR(50);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS zip_postal_code            VARCHAR(20);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS primary_residence          BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS lived_one_year             BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS move_in_date               DATE;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS home_type                  VARCHAR(50);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS other_home_type            VARCHAR(100);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS year_built                 INTEGER;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS owns_home                  BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS owns_lot                   BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS insurance_provider         VARCHAR(255);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS household_size             INTEGER;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS household_adults           INTEGER;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS gross_annual_income        NUMERIC(12,2);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS gross_monthly_income       NUMERIC(12,2);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS ami_percent                NUMERIC(5,2);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS ami_year                   INTEGER;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS ami_group                  VARCHAR(20);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS helene_related             BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS insurance_claim_filed      BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS insurance_settlement_amount NUMERIC(12,2);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS fema_claim_filed           BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS fema_settlement_amount     NUMERIC(12,2);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS zero_income_agreed         BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS additional_repair_details  TEXT;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS urgent_unable_to_stay      TEXT;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS urgent_no_hvac             BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS urgent_no_potable_water    BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS urgent_no_bathroom         BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS urgent_no_kitchen          BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS urgent_open_to_elements    BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS urgent_no_entry            BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS urgent_accessibility       BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS urgent_other_issue         BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS urgent_eviction_risk       BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS language                   VARCHAR(3);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS is_referral                BOOLEAN;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS referrer_name              VARCHAR(255);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS referrer_organization      VARCHAR(255);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS referrer_email             VARCHAR(255);
ALTER TABLE applications ADD COLUMN IF NOT EXISTS referrer_notes             TEXT;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS consent_agreed             BOOLEAN;
