-- Add funding and extended operational settings to coalition organizations
-- so the Super-Admin can configure each partner's limits and claim behavior.

ALTER TABLE coalition_organizations
    ADD COLUMN IF NOT EXISTS funding_limit NUMERIC(12, 2),
    ADD COLUMN IF NOT EXISTS description TEXT;

COMMENT ON COLUMN coalition_organizations.funding_limit IS 'Maximum funding this organization can commit to repairs';
COMMENT ON COLUMN coalition_organizations.description IS 'Public/internal description of the organization';
