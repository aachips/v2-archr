-- =====================================================
-- APPLICATION LIFECYCLE (Submission -> Application -> Case -> Project -> Repair Task)
-- =====================================================
-- Implements "ARCHR Core Terminology and Operational Logic" (2026-08-17):
--
--   * applications          — one deduplicated entry per household/placecode;
--                             the source of truth all cases hang off of.
--   * cases (altered)       — now an ORGANIZATION-SPECIFIC claim instance of an
--                             application. Multiple cases per application are
--                             allowed (one per claiming organization), each with
--                             its own 90-day progress cooldown.
--   * progress_events       — immutable log; any progress event resets the
--                             claiming org's 90-day timer.
--   * Functions             — deduplicate_submissions, claim_application,
--                             log_progress_event, expire_stale_claims,
--                             validate_status_transition, set_application_status.
--
-- Idempotent: safe to run on fresh deploys (via _master.sql) and on existing
-- databases as a migration (php app/apply-migration.php sql/application-lifecycle.sql).
-- =====================================================

-- ---------------------------------------------------------------
-- 0. Defensive columns used by the intake write path that predate
--    this file on live databases but were missing from base schema.
-- ---------------------------------------------------------------
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS placecode VARCHAR(50);
ALTER TABLE application_anchor ADD COLUMN IF NOT EXISTS placecode VARCHAR(50);
ALTER TABLE application_anchor ADD COLUMN IF NOT EXISTS project_code VARCHAR(50);
ALTER TABLE cases ADD COLUMN IF NOT EXISTS placecode VARCHAR(50);
ALTER TABLE cases ADD COLUMN IF NOT EXISTS project_code VARCHAR(50);

-- ---------------------------------------------------------------
-- 1. SUBMISSIONS stay in intake_submissions (raw form responses).
--    Add the deduplication linkage the terminology doc describes.
-- ---------------------------------------------------------------
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS is_duplicate BOOLEAN DEFAULT FALSE;
ALTER TABLE intake_submissions ADD COLUMN IF NOT EXISTS deduplicated_into INTEGER;

-- ---------------------------------------------------------------
-- 2. APPLICATIONS — deduplicated single entry per household/placecode
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS applications (
    id SERIAL PRIMARY KEY,
    application_guid UUID DEFAULT gen_random_uuid() UNIQUE,
    placecode VARCHAR(50) UNIQUE, -- e.g. "145LAKEW" (existing ARCHR format)

    -- Human-friendly label for display, e.g. "42 Cherry Street - Asheville"
    display_name VARCHAR(255),

    -- Core data (deduplicated from submissions)
    property_address TEXT,
    property_city VARCHAR(100),
    property_state VARCHAR(50),
    property_zip VARCHAR(20),
    applicant_first_name VARCHAR(100),
    applicant_last_name VARCHAR(100),
    applicant_email VARCHAR(255),
    applicant_phone VARCHAR(20),
    household_size INTEGER,

    -- Status lifecycle (see validate_status_transition)
    status VARCHAR(20) DEFAULT 'new', -- new, active, concluded, terminated, withdrawn, expired
    status_reason TEXT,
    terminated_reason_checkboxes TEXT[], -- checkbox items explaining a termination

    -- Eligibility (flags, not decisions — humans make final determinations)
    eligibility_flags JSONB DEFAULT '{"green": [], "yellow": [], "red": []}'::jsonb,
    eligibility_report TEXT,

    -- Metadata
    consolidated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    consolidated_by INTEGER REFERENCES system_users(id),
    last_activity_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_applications_placecode     ON applications(placecode);
CREATE INDEX IF NOT EXISTS idx_applications_status        ON applications(status);
CREATE INDEX IF NOT EXISTS idx_applications_zip           ON applications(property_zip);
CREATE INDEX IF NOT EXISTS idx_applications_last_activity ON applications(last_activity_at);

-- Submission -> Application dedup linkage (FK added guardedly: applications
-- must exist first, and live databases may already carry the constraint).
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'intake_submissions_deduplicated_into_fkey'
    ) THEN
        ALTER TABLE intake_submissions
        ADD CONSTRAINT intake_submissions_deduplicated_into_fkey
        FOREIGN KEY (deduplicated_into) REFERENCES applications(id) ON DELETE SET NULL;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_intake_submissions_deduplicated_into ON intake_submissions(deduplicated_into);
CREATE INDEX IF NOT EXISTS idx_intake_submissions_placecode ON intake_submissions(placecode);
-- ---------------------------------------------------------------
-- 3. CASES — organization-specific claim instances of an application
--    (terminology doc: one Application may have multiple Cases,
--    one per claiming organization, each with its own lifecycle
--    and 90-day progress cooldown).
-- ---------------------------------------------------------------
ALTER TABLE cases ADD COLUMN IF NOT EXISTS application_id INTEGER;
ALTER TABLE cases ADD COLUMN IF NOT EXISTS organization_id INTEGER;
ALTER TABLE cases ADD COLUMN IF NOT EXISTS claimed_at TIMESTAMP;
ALTER TABLE cases ADD COLUMN IF NOT EXISTS claimed_by INTEGER;
ALTER TABLE cases ADD COLUMN IF NOT EXISTS claim_expires_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL '90 days');
ALTER TABLE cases ADD COLUMN IF NOT EXISTS claim_status VARCHAR(20); -- NULL = unclaimed intake case; else active, expired, released
ALTER TABLE cases ADD COLUMN IF NOT EXISTS last_progress_at TIMESTAMP;
ALTER TABLE cases ADD COLUMN IF NOT EXISTS progress_events_count INTEGER DEFAULT 0;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'cases_application_id_fkey') THEN
        ALTER TABLE cases ADD CONSTRAINT cases_application_id_fkey
        FOREIGN KEY (application_id) REFERENCES applications(id) ON DELETE CASCADE;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'cases_organization_id_fkey') THEN
        ALTER TABLE cases ADD CONSTRAINT cases_organization_id_fkey
        FOREIGN KEY (organization_id) REFERENCES coalition_organizations(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'cases_claimed_by_fkey') THEN
        ALTER TABLE cases ADD CONSTRAINT cases_claimed_by_fkey
        FOREIGN KEY (claimed_by) REFERENCES system_users(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'cases_claim_status_check') THEN
        ALTER TABLE cases ADD CONSTRAINT cases_claim_status_check
        CHECK (claim_status IS NULL OR claim_status IN ('active', 'expired', 'released'));
    END IF;
END $$;

-- Drop the legacy one-case-per-submission uniqueness (a deduplicated
-- application may now host several cases — one per claiming org).
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN
        SELECT c.conname
          FROM pg_constraint c
         WHERE c.conrelid = 'cases'::regclass AND c.contype = 'u'
           AND (
               SELECT array_agg(a.attname ORDER BY a.attname)
                 FROM unnest(c.conkey) AS k(attnum)
                 JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = k.attnum
           ) = ARRAY['submission_id']::name[]
    LOOP
        EXECUTE format('ALTER TABLE cases DROP CONSTRAINT %I', r.conname);
    END LOOP;

    FOR r IN
        SELECT i.indexname
          FROM pg_indexes i
         WHERE i.tablename = 'cases'
           AND i.indexdef ILIKE 'CREATE UNIQUE INDEX%'
           AND i.indexdef ILIKE '%(submission_id)%'
    LOOP
        EXECUTE format('DROP INDEX IF EXISTS %I', r.indexname);
    END LOOP;
END $$;

-- One case per (application, organization). The unclaimed intake case is
-- guarded in code (select-then-insert), not by a unique index: backfilling
-- historical rows can legitimately surface several unclaimed cases per
-- application, which must not break the migration.
DROP INDEX IF EXISTS uq_cases_unclaimed_app; -- superseded (was unique in early revisions)
CREATE UNIQUE INDEX IF NOT EXISTS uq_cases_app_org
    ON cases (application_id, organization_id)
    WHERE organization_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_cases_unclaimed_app
    ON cases (application_id)
    WHERE organization_id IS NULL;

CREATE INDEX IF NOT EXISTS idx_cases_application   ON cases(application_id);
CREATE INDEX IF NOT EXISTS idx_cases_organization  ON cases(organization_id);
CREATE INDEX IF NOT EXISTS idx_cases_claim_expires ON cases(claim_expires_at);
CREATE INDEX IF NOT EXISTS idx_cases_last_progress ON cases(last_progress_at);

-- ---------------------------------------------------------------
-- 4. PROGRESS EVENTS — immutable log driving the 90-day cooldown
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS progress_events (
    id SERIAL PRIMARY KEY,
    event_guid UUID DEFAULT gen_random_uuid() UNIQUE,
    case_id INTEGER REFERENCES cases(id) ON DELETE CASCADE,
    organization_id INTEGER REFERENCES coalition_organizations(id),

    -- Event details
    event_type VARCHAR(50) NOT NULL, -- case_claimed, task_created, comm_logged, document_uploaded, assessment_completed, status_changed, claim_expired, ...
    event_description TEXT,
    event_source VARCHAR(50) DEFAULT 'user', -- system, user, api

    -- User context
    performed_by INTEGER REFERENCES system_users(id),
    performed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb,

    -- Tracking
    is_progress_event BOOLEAN DEFAULT TRUE,  -- does this reset the 90-day timer?
    is_immutable BOOLEAN DEFAULT TRUE,       -- cannot be deleted or modified

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_progress_events_case      ON progress_events(case_id);
CREATE INDEX IF NOT EXISTS idx_progress_events_org       ON progress_events(organization_id);
CREATE INDEX IF NOT EXISTS idx_progress_events_performed ON progress_events(performed_at DESC);
CREATE INDEX IF NOT EXISTS idx_progress_events_type      ON progress_events(event_type);
-- ---------------------------------------------------------------
-- 5. HELPERS
-- ---------------------------------------------------------------
-- Placecode generator mirroring the canonical PHP implementation
-- (_archr_placecode in app/lib/intake-save.php): leading address number +
-- street-name letters, 8 chars, uppercased; unit appended in brackets.
-- NOTE: the terminology doc's sample "42-CHERRY" format was reviewed and
-- the existing ARCHR format was explicitly kept (2026-08-19 decision).
CREATE OR REPLACE FUNCTION archr_generate_placecode(p_address TEXT)
RETURNS VARCHAR(50) AS $func$
DECLARE
    v_addr TEXT;
    v_unit TEXT;
    v_number TEXT;
    v_street TEXT;
    v_code TEXT;
    m TEXT[];
BEGIN
    IF p_address IS NULL OR btrim(p_address) = '' THEN
        RETURN NULL;
    END IF;

    v_addr := upper(btrim(p_address));

    -- Extract unit/apartment number and remove it from the address.
    m := regexp_match(v_addr, '\y(?:APT|UNIT|SUITE|STE|#)\s*(\w+)\y');
    IF m IS NOT NULL THEN
        v_unit := m[1];
        v_addr := regexp_replace(v_addr, '\s*(APT|UNIT|SUITE|STE|#)\s*\w+', '', 'g');
    END IF;

    -- Extract leading number (supports ranges like 123-125).
    m := regexp_match(v_addr, '^([0-9]+(-[0-9]+)?)');
    v_number := COALESCE(m[1], '');

    -- Remove the number, directionals, and any remaining non-letters.
    v_street := regexp_replace(v_addr, '^[0-9]+(-[0-9]+)?\s*', '');
    v_street := regexp_replace(v_street, '\y(NORTH|SOUTH|EAST|WEST|NORTHEAST|NORTHWEST|SOUTHEAST|SOUTHWEST|NE|NW|SE|SW|N|S|E|W)\y', '', 'g');
    v_street := regexp_replace(v_street, '[^A-Z]', '', 'g');

    v_code := left(v_number || left(v_street, GREATEST(0, 8 - length(v_number))), 8);
    IF v_unit IS NOT NULL THEN
        v_code := v_code || '[' || v_unit || ']';
    END IF;

    RETURN NULLIF(v_code, '');
END;
$func$ LANGUAGE plpgsql IMMUTABLE;

-- Human-readable label, e.g. "42 Cherry Street - Asheville".
CREATE OR REPLACE FUNCTION archr_display_name(p_address TEXT, p_city TEXT)
RETURNS VARCHAR(255) AS $func$
    SELECT NULLIF(btrim(concat_ws(' - ', NULLIF(btrim(COALESCE(p_address, '')), ''), NULLIF(btrim(COALESCE(p_city, '')), ''))), '');
$func$ LANGUAGE sql IMMUTABLE;

-- Canonical termination checkbox reasons (terminology doc Part 6).
-- Single source of truth — the PHP layer reads this via
-- archr_termination_reasons() in app/lib/applications.php.
CREATE OR REPLACE FUNCTION canonical_termination_reasons()
RETURNS TEXT[] AS $func$
    SELECT ARRAY[
        'Income above program limits',
        'Property outside service area',
        'Damage not Helene-related',
        'Applicant unresponsive after 3 contact attempts',
        'Duplicate application',
        'Previously served by another organization',
        'Applicant declined services',
        'Unable to verify homeownership',
        'Other (please specify)'
    ];
$func$ LANGUAGE sql IMMUTABLE;

-- ---------------------------------------------------------------
-- 6. DEDUPLICATION — consolidate submissions into applications
-- ---------------------------------------------------------------
CREATE OR REPLACE FUNCTION deduplicate_submissions(p_submission_id INTEGER)
RETURNS INTEGER AS $func$
DECLARE
    v_sub RECORD;
    v_application_id INTEGER;
    v_placecode VARCHAR(50);
BEGIN
    SELECT * INTO v_sub FROM intake_submissions WHERE id = p_submission_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Submission % not found', p_submission_id;
    END IF;

    -- Already consolidated? Return the existing application.
    IF v_sub.deduplicated_into IS NOT NULL THEN
        RETURN v_sub.deduplicated_into;
    END IF;

    -- Placecode: prefer the value the PHP intake path already derived;
    -- fall back to the SQL implementation of the same algorithm.
    v_placecode := COALESCE(v_sub.placecode, archr_generate_placecode(v_sub.home_address));
    IF v_sub.placecode IS NULL AND v_placecode IS NOT NULL THEN
        UPDATE intake_submissions SET placecode = v_placecode WHERE id = p_submission_id;
    END IF;

    -- An application is unique per placecode. NULL placecodes never match,
    -- so address-less submissions each become their own application.
    IF v_placecode IS NOT NULL THEN
        SELECT id INTO v_application_id FROM applications WHERE placecode = v_placecode;
    END IF;

    IF v_application_id IS NULL THEN
        INSERT INTO applications (
            placecode, display_name,
            property_address, property_city, property_state, property_zip,
            applicant_first_name, applicant_last_name, applicant_email, applicant_phone,
            household_size, status, consolidated_at, last_activity_at
        ) VALUES (
            v_placecode, archr_display_name(v_sub.home_address, v_sub.home_city),
            v_sub.home_address, v_sub.home_city, v_sub.home_state, v_sub.home_zip,
            v_sub.applicant_first_name, v_sub.applicant_last_name,
            v_sub.contact_email, COALESCE(v_sub.home_phone, v_sub.cell_phone),
            v_sub.household_size, 'new', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        ) RETURNING id INTO v_application_id;

        UPDATE intake_submissions
           SET deduplicated_into = v_application_id, is_duplicate = FALSE
         WHERE id = p_submission_id;
    ELSE
        UPDATE applications
           SET last_activity_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP
         WHERE id = v_application_id;

        UPDATE intake_submissions
           SET deduplicated_into = v_application_id, is_duplicate = TRUE
         WHERE id = p_submission_id;
    END IF;

    RETURN v_application_id;
END;
$func$ LANGUAGE plpgsql;
-- ---------------------------------------------------------------
-- 7. CLAIM APPLICATION — create (or reactivate) the org's case
-- ---------------------------------------------------------------
-- One case per (application, organization). If the application still has
-- its unclaimed intake case, the first claiming org adopts it (preserving
-- its case number, documents, and history); later claims by other orgs
-- create their own case rows. Claiming sets/refreshes the 90-day timer
-- and moves the application to 'active' (from 'new' or 'expired').
CREATE OR REPLACE FUNCTION claim_application(
    p_application_id INTEGER,
    p_organization_id INTEGER,
    p_claimed_by INTEGER
)
RETURNS INTEGER AS $func$
DECLARE
    v_case_id INTEGER;
    v_app RECORD;
    v_sub_id INTEGER;
    v_status_id INTEGER;
    v_project_code VARCHAR(50);
BEGIN
    SELECT * INTO v_app FROM applications WHERE id = p_application_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Application % not found', p_application_id;
    END IF;
    IF v_app.status IN ('terminated', 'withdrawn', 'concluded') THEN
        RAISE EXCEPTION 'Application % is % and cannot be claimed', p_application_id, v_app.status;
    END IF;

    -- Existing case for this (application, org)? Reactivate it.
    SELECT id INTO v_case_id
      FROM cases
     WHERE application_id = p_application_id
       AND organization_id = p_organization_id
     ORDER BY id DESC LIMIT 1;

    IF v_case_id IS NOT NULL THEN
        UPDATE cases
           SET claim_status = 'active',
               claim_expires_at = CURRENT_TIMESTAMP + INTERVAL '90 days',
               last_progress_at = CURRENT_TIMESTAMP,
               claimed_at = COALESCE(claimed_at, CURRENT_TIMESTAMP),
               claimed_by = COALESCE(claimed_by, p_claimed_by),
               updated_at = CURRENT_TIMESTAMP
         WHERE id = v_case_id;
    ELSE
        -- Adopt the unclaimed intake case when one exists.
        SELECT id INTO v_case_id
          FROM cases
         WHERE application_id = p_application_id
           AND organization_id IS NULL
         ORDER BY id LIMIT 1;

        IF v_case_id IS NOT NULL THEN
            UPDATE cases
               SET organization_id = p_organization_id,
                   claimed_at = CURRENT_TIMESTAMP,
                   claimed_by = p_claimed_by,
                   claim_expires_at = CURRENT_TIMESTAMP + INTERVAL '90 days',
                   claim_status = 'active',
                   last_progress_at = CURRENT_TIMESTAMP,
                   updated_at = CURRENT_TIMESTAMP
             WHERE id = v_case_id;
        ELSE
            -- First submission of the application carries the shared data.
            SELECT MIN(id) INTO v_sub_id FROM intake_submissions WHERE deduplicated_into = p_application_id;
            SELECT id INTO v_status_id FROM case_statuses WHERE status_code = 'PENDING_REVIEW' LIMIT 1;
            SELECT project_code INTO v_project_code FROM application_anchor WHERE submission_id = v_sub_id LIMIT 1;

            INSERT INTO cases (
                submission_id, application_id, organization_id, status_id,
                placecode, project_code,
                claimed_at, claimed_by, claim_expires_at, claim_status, last_progress_at,
                created_by, updated_by
            ) VALUES (
                v_sub_id, p_application_id, p_organization_id, v_status_id,
                v_app.placecode, v_project_code,
                CURRENT_TIMESTAMP, p_claimed_by, CURRENT_TIMESTAMP + INTERVAL '90 days', 'active', CURRENT_TIMESTAMP,
                p_claimed_by, p_claimed_by
            ) RETURNING id INTO v_case_id;
        END IF;
    END IF;

    -- Application becomes active once claimed (new -> active, expired -> active).
    IF v_app.status IN ('new', 'expired') THEN
        UPDATE applications
           SET status = 'active', updated_at = CURRENT_TIMESTAMP, last_activity_at = CURRENT_TIMESTAMP
         WHERE id = p_application_id;
    END IF;

    PERFORM log_progress_event(v_case_id, 'case_claimed', 'Application claimed by organization', p_claimed_by, TRUE, 'user');

    RETURN v_case_id;
END;
$func$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------
-- 8. PROGRESS EVENTS + 90-DAY COOLDOWN TIMER
-- ---------------------------------------------------------------
-- Logging a progress event (task, communication, milestone, document, ...)
-- resets the claiming organization's 90-day timer. Administrative entries
-- (is_progress_event = FALSE) are recorded but do not extend the claim.
CREATE OR REPLACE FUNCTION log_progress_event(
    p_case_id INTEGER,
    p_event_type VARCHAR,
    p_event_description TEXT,
    p_performed_by INTEGER,
    p_is_progress BOOLEAN DEFAULT TRUE,
    p_source VARCHAR DEFAULT 'user'
)
RETURNS INTEGER AS $func$
DECLARE
    v_event_id INTEGER;
    v_organization_id INTEGER;
    v_application_id INTEGER;
BEGIN
    SELECT organization_id, application_id INTO v_organization_id, v_application_id
      FROM cases WHERE id = p_case_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Case % not found', p_case_id;
    END IF;

    INSERT INTO progress_events (
        case_id, organization_id, event_type, event_description,
        event_source, performed_by, is_progress_event
    ) VALUES (
        p_case_id, v_organization_id, p_event_type, p_event_description,
        p_source, p_performed_by, p_is_progress
    ) RETURNING id INTO v_event_id;

    IF p_is_progress THEN
        -- Reset the 90-day cooldown timer (only on live claims).
        UPDATE cases
           SET last_progress_at = CURRENT_TIMESTAMP,
               claim_expires_at = CASE
                   WHEN claim_status = 'active' THEN CURRENT_TIMESTAMP + INTERVAL '90 days'
                   ELSE claim_expires_at
               END,
               progress_events_count = COALESCE(progress_events_count, 0) + 1,
               updated_at = CURRENT_TIMESTAMP
         WHERE id = p_case_id;
    END IF;

    IF v_application_id IS NOT NULL THEN
        UPDATE applications
           SET last_activity_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP
         WHERE id = v_application_id;
    END IF;

    RETURN v_event_id;
END;
$func$ LANGUAGE plpgsql;
-- ---------------------------------------------------------------
-- 9. EXPIRE STALE CLAIMS — scheduled job (run daily)
-- ---------------------------------------------------------------
-- SELECT * FROM expire_stale_claims();
-- Or via pg_cron:  SELECT cron.schedule('expire-stale-claims', '0 3 * * *', 'SELECT expire_stale_claims();');
-- Or via the app: POST app/api/run-maintenance.php  action=expire_stale_claims
CREATE OR REPLACE FUNCTION expire_stale_claims()
RETURNS TABLE(
    case_id INTEGER,
    application_id INTEGER,
    organization_id INTEGER,
    days_since_progress INTEGER
) AS $func$
DECLARE
    v_case RECORD;
BEGIN
    FOR v_case IN
        SELECT c.id,
               c.application_id,
               c.organization_id,
               EXTRACT(DAY FROM (CURRENT_TIMESTAMP - c.last_progress_at))::INTEGER AS days_idle
          FROM cases c
         WHERE c.claim_status = 'active'
           AND c.claim_expires_at < CURRENT_TIMESTAMP
    LOOP
        UPDATE cases
           SET claim_status = 'expired', updated_at = CURRENT_TIMESTAMP
         WHERE id = v_case.id;

        -- Immutable record of the expiry (not itself a progress event).
        INSERT INTO progress_events (
            case_id, organization_id, event_type, event_description,
            event_source, is_progress_event
        ) VALUES (
            v_case.id, v_case.organization_id, 'claim_expired',
            'Claim expired after ' || v_case.days_idle || ' days without progress',
            'system', FALSE
        );

        -- When no active claims remain, the application itself expires and
        -- becomes available for other organizations to claim.
        -- (Table aliases required: this function's RETURNS TABLE out-params
        -- share names with these columns — bare references are ambiguous.)
        IF NOT EXISTS (
            SELECT 1 FROM cases c2
             WHERE c2.application_id = v_case.application_id
               AND c2.claim_status = 'active'
               AND c2.id <> v_case.id
        ) THEN
            UPDATE applications a
               SET status = 'expired', updated_at = CURRENT_TIMESTAMP
             WHERE a.id = v_case.application_id
               AND a.status = 'active'; -- transition guard: only active -> expired
        END IF;

        case_id := v_case.id;
        application_id := v_case.application_id;
        organization_id := v_case.organization_id;
        days_since_progress := v_case.days_idle;
        RETURN NEXT;
    END LOOP;
END;
$func$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------
-- 10. APPLICATION STATUS TRANSITIONS
-- ---------------------------------------------------------------
-- Allowed transitions (terminology doc Part 6). Deliberate extensions:
-- 'new' and 'expired' may also go to withdrawn/terminated so a
-- never-claimed or lapsed application can still be closed by a human
-- decision (an applicant can withdraw at any point in reality).
CREATE OR REPLACE FUNCTION validate_status_transition(
    p_application_id INTEGER,
    p_new_status VARCHAR
)
RETURNS BOOLEAN AS $func$
DECLARE
    v_current_status VARCHAR;
BEGIN
    SELECT status INTO v_current_status FROM applications WHERE id = p_application_id;
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    CASE v_current_status
        WHEN 'new' THEN
            RETURN p_new_status IN ('active', 'withdrawn', 'terminated');
        WHEN 'active' THEN
            RETURN p_new_status IN ('concluded', 'terminated', 'withdrawn', 'expired');
        WHEN 'expired' THEN
            RETURN p_new_status IN ('active', 'withdrawn', 'terminated');
        ELSE
            -- terminated / withdrawn / concluded are terminal
            RETURN FALSE;
    END CASE;
END;
$func$ LANGUAGE plpgsql;

-- Enforced status change: validates the transition and the human-decision
-- requirements (termination checkbox reasons; withdrawal contact note).
CREATE OR REPLACE FUNCTION set_application_status(
    p_application_id INTEGER,
    p_new_status VARCHAR,
    p_reason TEXT DEFAULT NULL,
    p_checkboxes TEXT[] DEFAULT NULL,
    p_changed_by INTEGER DEFAULT NULL
)
RETURNS BOOLEAN AS $func$
DECLARE
    v_old_status VARCHAR;
    v_reason TEXT;
BEGIN
    SELECT status INTO v_old_status FROM applications WHERE id = p_application_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Application % not found', p_application_id;
    END IF;

    IF NOT validate_status_transition(p_application_id, p_new_status) THEN
        RAISE EXCEPTION 'Invalid application status transition: % -> %', v_old_status, p_new_status;
    END IF;

    IF p_new_status = 'terminated' THEN
        IF p_checkboxes IS NULL OR array_length(p_checkboxes, 1) IS NULL THEN
            RAISE EXCEPTION 'Terminating an application requires at least one checkbox reason';
        END IF;
        IF EXISTS (
            SELECT 1 FROM unnest(p_checkboxes) AS r
             WHERE NOT (r = ANY (canonical_termination_reasons()))
        ) THEN
            RAISE EXCEPTION 'Unknown termination reason. Use canonical_termination_reasons() values';
        END IF;
        IF 'Other (please specify)' = ANY (p_checkboxes)
           AND (p_reason IS NULL OR btrim(p_reason) = '') THEN
            RAISE EXCEPTION '"Other (please specify)" requires a reason note';
        END IF;
    END IF;

    IF p_new_status = 'withdrawn' AND (p_reason IS NULL OR btrim(p_reason) = '') THEN
        RAISE EXCEPTION 'Withdrawal requires a human contact note (who confirmed, how, when)';
    END IF;

    UPDATE applications
       SET status = p_new_status,
           status_reason = p_reason,
           terminated_reason_checkboxes = CASE WHEN p_new_status = 'terminated' THEN p_checkboxes ELSE terminated_reason_checkboxes END,
           last_activity_at = CURRENT_TIMESTAMP,
           updated_at = CURRENT_TIMESTAMP
     WHERE id = p_application_id;

    -- Application-level audit entry (never a claim-timer progress event).
    INSERT INTO progress_events (
        case_id, organization_id, event_type, event_description,
        event_source, performed_by, is_progress_event, metadata
    ) VALUES (
        NULL, NULL, 'status_changed',
        'Application status: ' || v_old_status || ' -> ' || p_new_status,
        'user', p_changed_by, FALSE,
        jsonb_build_object('application_id', p_application_id, 'from', v_old_status, 'to', p_new_status)
    );

    RETURN TRUE;
END;
$func$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------
-- Daily expiration check: run SELECT * FROM expire_stale_claims();
-- via cron / pg_cron, or the super-admin maintenance endpoint.
-- ---------------------------------------------------------------
-- ---------------------------------------------------------------
-- 11. BACKFILL (idempotent) — consolidate existing submissions into
--     applications and link existing cases/claims to them.
-- ---------------------------------------------------------------
-- Every historical submission gets consolidated (duplicates share the
-- application of their placecode).
SELECT deduplicate_submissions(s.id)
  FROM intake_submissions s
 WHERE s.deduplicated_into IS NULL;

-- Link existing cases to their application.
UPDATE cases c
   SET application_id = s.deduplicated_into
  FROM intake_submissions s
 WHERE s.id = c.submission_id
   AND c.application_id IS NULL;

-- Adopt legacy claim rows (case_claims) onto the case as the owning org,
-- starting the 90-day window from the original claim time.
UPDATE cases c
   SET organization_id = cc.claimed_by_org_id,
       claimed_at = cc.claimed_at,
       claim_status = 'active',
       claim_expires_at = COALESCE(cc.expires_at, cc.claimed_at + INTERVAL '90 days'),
       last_progress_at = COALESCE(cc.claimed_at, c.created_at)
  FROM case_claims cc
 WHERE cc.case_id = c.id
   AND c.organization_id IS NULL
   AND NOT EXISTS (
       SELECT 1 FROM cases c2
        WHERE c2.application_id = c.application_id
          AND c2.organization_id = cc.claimed_by_org_id
   );

-- Adopt legacy anchor assignments the same way.
UPDATE cases c
   SET organization_id = a.assigned_organization_id,
       claimed_at = COALESCE(a.assigned_at, c.created_at),
       claim_status = 'active',
       claim_expires_at = COALESCE(a.assigned_at, c.created_at) + INTERVAL '90 days',
       last_progress_at = COALESCE(a.assigned_at, c.created_at)
  FROM application_anchor a
 WHERE a.submission_id = c.submission_id
   AND c.organization_id IS NULL
   AND a.assigned_organization_id IS NOT NULL
   AND NOT EXISTS (
       SELECT 1 FROM cases c2
        WHERE c2.application_id = c.application_id
          AND c2.organization_id = a.assigned_organization_id
   );

-- Applications that hold at least one claimed case are active, not new.
UPDATE applications a
   SET status = 'active', updated_at = CURRENT_TIMESTAMP
 WHERE a.status = 'new'
   AND EXISTS (SELECT 1 FROM cases c WHERE c.application_id = a.id AND c.organization_id IS NOT NULL);