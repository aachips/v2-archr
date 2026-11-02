-- =====================================================
-- ARCHR — Master deployment script (PostgreSQL)
-- =====================================================
-- Applies every domain SQL file in dependency order against
-- the currently-connected database. Intended to be run once
-- on a freshly-created `archr` database.
--
-- Usage from psql:
--     \c archr
--     \i sql/_master.sql
--
-- Or from PowerShell:
--     pwsh -File sql/apply.ps1
--
-- The \ir directive includes files relative to THIS script,
-- so psql's current working directory does not matter.
-- ON_ERROR_STOP makes a single failed statement halt the
-- whole run so problems surface immediately.
-- =====================================================

\set ON_ERROR_STOP on
\timing on
\echo ''
\echo '==> ARCHR master deploy starting'

-- ---------------------------------------------------------------
-- Required extensions
-- pgcrypto provides gen_random_uuid() on PG < 13. Harmless on PG 13+.
-- ---------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ---------------------------------------------------------------
-- Tier 0 - intake (no cross-file FK refs)
-- ---------------------------------------------------------------
\echo '--> [Tier 0] intake.sql'
\ir intake.sql

-- ---------------------------------------------------------------
-- Tier 1 - depends only on Tier 0
-- partner-organizations creates coalition_organizations, which
-- role-based-access references, so it must come first.
-- ---------------------------------------------------------------
\echo '--> [Tier 1] partner-organizations.sql'
\ir partner-organizations.sql
\echo '--> [Tier 1] role-based-access.sql'
\ir role-based-access.sql
\echo '--> [Tier 1] anchor-registration.sql'
\ir anchor-registration.sql
\echo '--> [Tier 1] volunteer-gamification.sql'
\ir volunteer-gamification.sql
\echo '--> [Tier 1] notifications.sql'
\ir notifications.sql
\echo '--> [Tier 1] email-notification-digest.sql'
\ir email-notification-digest.sql
\echo '--> [Tier 1] edit-application.sql'
\ir edit-application.sql
\echo '--> [Tier 1] documentation-sops.sql'
\ir documentation-sops.sql
\echo '--> [Tier 1] document-storage.sql'
\ir document-storage.sql
\echo '--> [Tier 1] project-level-finance.sql'
\ir project-level-finance.sql

-- ---------------------------------------------------------------
-- Tier 2 — depend on Tier 0 + Tier 1
-- application-lifecycle (applications/cases-claims/progress_events)
-- comes first so later tiers can rely on the application model.
-- ---------------------------------------------------------------
\echo '--> [Tier 2] application-lifecycle.sql'
\ir application-lifecycle.sql
\echo '--> [Tier 2] review-queue.sql'
\ir review-queue.sql
\echo '--> [Tier 2] requestor-dashboard-access.sql'
\ir requestor-dashboard-access.sql
\echo '--> [Tier 2] volunteer-task-claim.sql'
\ir volunteer-task-claim.sql
\echo '--> [Tier 2] eligibility-tracker.sql'
\ir eligibility-tracker.sql
\echo '--> [Tier 2] org-admin.sql'
\ir org-admin.sql
\echo '--> [Tier 2] feedback-collection.sql'
\ir feedback-collection.sql

-- ---------------------------------------------------------------
-- Tier 3 — cross-cutting handlers, views, metrics
-- ---------------------------------------------------------------
\echo '--> [Tier 3] submission-handler.sql'
\ir submission-handler.sql
\echo '--> [Tier 3] staff-dashboard-queue.sql'
\ir staff-dashboard-queue.sql
\echo '--> [Tier 3] metric-tracking.sql'
\ir metric-tracking.sql

-- ---------------------------------------------------------------
-- Files NOT included in auto-deploy
-- ---------------------------------------------------------------
-- test-case.sql
--   Inserts sample submissions. Run manually after deploy:
--     psql -d archr -f sql/test-case.sql
--
-- dummy-data.sql
--   Additional test data for development
--
-- bursar.sql
--   Bursar-specific views and functions (if needed separately)
-- ---------------------------------------------------------------

-- ---------------------------------------------------------------
-- Airtable Migration
-- ---------------------------------------------------------------
-- This master script can also be used to generate an Airtable
-- database structure. See build-airtable.js in the project root.
--
-- To build Airtable database:
--   1. Create PAT.txt with your Airtable Personal Access Token
--   2. Run: node build-airtable.js
--
-- The script will parse this master file and all referenced SQL
-- files to create 77 tables with 827 fields in Airtable base
-- appiMfIEzULJtmi5v
--
-- For details, see: SETUP-INSTRUCTIONS.md
-- ---------------------------------------------------------------

\echo ''
\echo '==> ARCHR master deploy complete'
\echo '    Validate with:  psql -d archr -f sql/test-case.sql'
\echo '    For Airtable:   node build-airtable.js'
\echo ''
