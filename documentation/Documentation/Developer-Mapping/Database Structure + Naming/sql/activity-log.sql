-- =====================================================
-- ACTIVITY LOG — the immutable ledger + 30-day detail tier
-- =====================================================
-- Two tables, two hash chains:
--
--   activity_log     The permanent, curated ledger. One row per concrete
--                    action (application claimed, document verified,
--                    application withdrawn...). Never edited, never deleted.
--                    This is the record that makes actions accountable.
--
--   activity_detail  The granular "history panel" tier: field-level diffs,
--                    session IDs, IP addresses, sub-actions bundled under a
--                    ledger entry (ledger_id). Rows expire and are purged
--                    after 30 days — enough to detect fraud while it is
--                    fresh, without drowning the permanent record in noise.
--
-- Tamper evidence: every row stores entry_hash = sha256(canonical contents
-- + prev_hash of the previous row). Editing or deleting any historical row
-- breaks the chain; admins can verify with archr_activity_verify_chain().
-- The UNIQUE(prev_hash) constraint prevents forked chains under concurrent
-- writes (the writer retries once on conflict).
--
-- Household anchoring: the application IS the household container (see
-- activity-log-progress-tracker notes), so both tables anchor on
-- application_id; case_id is set when the action is case-scoped.
--
-- Requires: system_users, applications, cases, coalition_organizations
-- (role-based-access.sql + application-lifecycle.sql — already deployed).
-- Idempotent: safe to run via app/apply-migration.php on fresh deploys and
-- existing databases.
-- =====================================================

-- ---------------------------------------------------------------
-- 1. PERMANENT LEDGER
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS activity_log (
    id BIGSERIAL PRIMARY KEY,
    event_guid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- WHO (null user_id = system / automated action; the name snapshot
    -- survives renames and account deactivation)
    user_id INTEGER REFERENCES system_users(id),
    user_name VARCHAR(200),
    session_id VARCHAR(128),
    ip_address INET,

    -- WHAT IT BELONGS TO (application = Household)
    application_id INTEGER REFERENCES applications(id),
    case_id INTEGER REFERENCES cases(id),
    organization_id INTEGER REFERENCES coalition_organizations(id),

    -- WHAT HAPPENED
    category VARCHAR(50) NOT NULL,   -- client|application|case|project|task|repair|document|communication|schedule|user|system
    action VARCHAR(100) NOT NULL,    -- application_claimed, document_uploaded, ...
    summary TEXT,                    -- one human-readable line for feeds
    details JSONB NOT NULL DEFAULT '{}'::jsonb,

    -- WHERE IT CAME FROM
    source VARCHAR(50) NOT NULL DEFAULT 'web',  -- web | api | system | migration

    -- TAMPER EVIDENCE
    prev_hash CHAR(64),
    entry_hash CHAR(64) NOT NULL,
    CONSTRAINT uq_activity_log_prev_hash UNIQUE (prev_hash)
);

CREATE INDEX IF NOT EXISTS idx_activity_log_created     ON activity_log (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_activity_log_user        ON activity_log (user_id);
CREATE INDEX IF NOT EXISTS idx_activity_log_application ON activity_log (application_id);
CREATE INDEX IF NOT EXISTS idx_activity_log_case        ON activity_log (case_id);
CREATE INDEX IF NOT EXISTS idx_activity_log_category    ON activity_log (category);
CREATE INDEX IF NOT EXISTS idx_activity_log_action      ON activity_log (action);

-- ---------------------------------------------------------------
-- 2. ROLLING 30-DAY DETAIL TIER (the granular history panel)
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS activity_detail (
    id BIGSERIAL PRIMARY KEY,
    event_guid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP + INTERVAL '30 days'),

    -- Optional link to the curated ledger entry this detail belongs to
    ledger_id BIGINT REFERENCES activity_log(id),

    -- WHO / context (the fraud-detection payload)
    user_id INTEGER REFERENCES system_users(id),
    user_name VARCHAR(200),
    session_id VARCHAR(128),
    ip_address INET,

    application_id INTEGER REFERENCES applications(id),
    case_id INTEGER REFERENCES cases(id),

    -- WHAT CHANGED (field-level when relevant)
    action VARCHAR(100) NOT NULL,
    field_name VARCHAR(100),
    old_value TEXT,
    new_value TEXT,
    details JSONB NOT NULL DEFAULT '{}'::jsonb,
    source VARCHAR(50) NOT NULL DEFAULT 'web',

    -- TAMPER EVIDENCE (own chain, so purging never disturbs the ledger)
    prev_hash CHAR(64),
    entry_hash CHAR(64) NOT NULL,
    CONSTRAINT uq_activity_detail_prev_hash UNIQUE (prev_hash)
);

CREATE INDEX IF NOT EXISTS idx_activity_detail_expires ON activity_detail (expires_at);
CREATE INDEX IF NOT EXISTS idx_activity_detail_ledger  ON activity_detail (ledger_id);
CREATE INDEX IF NOT EXISTS idx_activity_detail_session ON activity_detail (session_id);
CREATE INDEX IF NOT EXISTS idx_activity_detail_created ON activity_detail (created_at DESC);

-- ---------------------------------------------------------------
-- 3. PURGE — erase expired detail rows. Returns the count deleted.
--    Run from a cron/scheduler; the permanent ledger is untouched.
-- ---------------------------------------------------------------
CREATE OR REPLACE FUNCTION archr_activity_purge_expired() RETURNS INTEGER AS $$
DECLARE
    purged INTEGER;
BEGIN
    DELETE FROM activity_detail WHERE expires_at < CURRENT_TIMESTAMP;
    GET DIAGNOSTICS purged = ROW_COUNT;
    RETURN purged;
END;
$$ LANGUAGE plpgsql;