-- AMI (Area Median Income) lookup table.
-- Stores the annual AMI dollar amounts per county, sourced from census.gov.
-- Used by the eligibility engine to evaluate "X% AMI" income rules.
--
-- The eligibility rule stores the percentage (e.g., 80 for 80% AMI).
-- The resolver multiplies: threshold = AMI * (percentage / 100).
-- Update this table each year when Census publishes new figures.

CREATE TABLE IF NOT EXISTS ami_lookup (
    id          SERIAL PRIMARY KEY,
    county      VARCHAR(64) NOT NULL,
    state       CHAR(2) NOT NULL DEFAULT 'NC',
    ami_1person INTEGER,       -- 1-person household AMI
    ami_2person INTEGER,       -- 2-person household AMI
    ami_3person INTEGER,       -- 3-person household AMI
    ami_4person INTEGER,       -- 4-person household AMI
    ami_5person INTEGER,       -- 5-person household AMI
    ami_6person INTEGER,       -- 6-person household AMI
    ami_7person INTEGER,       -- 7-person household AMI
    ami_8person INTEGER,       -- 8-person household AMI
    year        INTEGER NOT NULL DEFAULT EXTRACT(YEAR FROM CURRENT_DATE),
    source_url  TEXT,
    UNIQUE(county, state, year)
);

COMMENT ON TABLE ami_lookup IS 'Annual Area Median Income values per county. Update when Census releases new figures.';

-- 2026 AMI values from census.gov
-- Buncombe County: $66,531 (1-person baseline, scales by household size)
-- Madison County: $56,641 (1-person baseline, scales by household size)
-- Note: HUD publishes the actual income limits. These are the 2026 baselines.
-- For now, we store the 1-person baseline. The eligibility resolver scales
-- by household size using HUD's published ratios.

INSERT INTO ami_lookup (county, state, ami_1person, ami_2person, ami_3person, ami_4person, ami_5person, ami_6person, ami_7person, ami_8person, year, source_url) VALUES
    ('Buncombe County', 'NC', 66531, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2026, 'https://www.census.gov/'),
    ('Madison County', 'NC', 56641, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2026, 'https://www.census.gov/')
ON CONFLICT (county, state, year) DO UPDATE SET
    ami_1person = EXCLUDED.ami_1person,
    ami_2person = EXCLUDED.ami_2person,
    ami_3person = EXCLUDED.ami_3person,
    ami_4person = EXCLUDED.ami_4person,
    ami_5person = EXCLUDED.ami_5person,
    ami_6person = EXCLUDED.ami_6person,
    ami_7person = EXCLUDED.ami_7person,
    ami_8person = EXCLUDED.ami_8person,
    source_url = EXCLUDED.source_url;
