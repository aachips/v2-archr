-- Migration: volunteer_applications table + test seed data
-- Run: psql -d archr -f migrations/volunteer_applications.sql
-- (Or via deploy.bat: deploy.bat migrations/volunteer_applications.sql)

BEGIN;

-- ============================================================================
-- Volunteer Applications Table
-- ============================================================================
-- Stores intake form submissions from people who want to volunteer.
-- An Admin reviews these and, upon approval, creates a system_users record
-- + user_role_assignments (role_id = 11, VOLUNTEER) + volunteer_profiles record.

CREATE TABLE IF NOT EXISTS public.volunteer_applications (
    id                  SERIAL PRIMARY KEY,
    full_name           VARCHAR(255) NOT NULL,
    email               VARCHAR(255) NOT NULL,
    phone               VARCHAR(50) NOT NULL,
    location            VARCHAR(255),
    motivation          TEXT,
    hear_about          VARCHAR(50),
    skills              TEXT[],
    availability        TEXT[],
    has_tools           BOOLEAN DEFAULT FALSE,
    tools_notes         TEXT,
    interest_type       VARCHAR(50),
    physical_limits     TEXT,
    referral_name       VARCHAR(255),
    agreed_terms        BOOLEAN DEFAULT FALSE,
    status              VARCHAR(50) DEFAULT 'pending',  -- pending, approved, rejected
    reviewed_by         INTEGER REFERENCES public.system_users(id),
    reviewed_notes      TEXT,
    reviewed_at         TIMESTAMP,
    user_id             INTEGER REFERENCES public.system_users(id),  -- set when approved
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_vol_apps_status ON public.volunteer_applications(status);
CREATE INDEX IF NOT EXISTS idx_vol_apps_email ON public.volunteer_applications(email);

-- ============================================================================
-- Seed: Two test volunteer applications
-- ============================================================================

-- 1. "Riley Park" — already approved, has a user account and volunteer profile
--    (simulates a volunteer who has been active for a while)
INSERT INTO public.volunteer_applications
    (full_name, email, phone, location, motivation, hear_about,
     skills, availability, has_tools, tools_notes, interest_type,
     agreed_terms, status, reviewed_at, created_at)
VALUES
    ('Riley Park', 'riley.park@test.archr', '(828) 555-0101', 'Asheville 28801',
     'I want to help my neighbors rebuild after Helene. I have construction experience and flexible weekends.',
     'friend',
     '{"carpentry","power-tools","roofing"}',
     '{"weekend-am","weekend-pm","flexible"}',
     TRUE,
     'Own truck, basic hand tools, reliable transport',
     'field',
     TRUE,
     'approved',
     NOW() - INTERVAL '90 days',
     NOW() - INTERVAL '100 days')
ON CONFLICT DO NOTHING;

-- 2. "Mary Chen" — pending, just submitted intake, waiting for admin review
INSERT INTO public.volunteer_applications
    (full_name, email, phone, location, motivation, hear_about,
     skills, availability, has_tools, interest_type,
     agreed_terms, status, created_at)
VALUES
    ('Mary Chen', 'mary.chen@test.archr', '(828) 555-0202', 'Hendersonville 28792',
     'New to the area and want to meet people while giving back. Happy to help wherever needed.',
     'social-media',
     '{"none"}',
     '{"weekday-pm","flexible"}',
     FALSE,
     'any',
     TRUE,
     'pending',
     NOW() - INTERVAL '3 days')
ON CONFLICT DO NOTHING;

COMMIT;
