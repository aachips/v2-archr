--Immutability is Built In
-- The ledger pattern means you never lose history. Every change is a new row. You can always see:
-- Who created a task
-- When it was created
-- Every status change
-- Who made each change
-- Why they made it

-- Airtable: 50 API calls or copy-paste
-- PostgreSQL: One JSON blob, one transaction
SELECT create_bulk_tasks(p_case_id, '[{...50 tasks...}]', p_user_id);

-- Before creating a task, check for duplicates
SELECT * FROM detect_duplicate_tasks(p_case_id, 'REPAIR_ROOF', 'leaking roof');
-- Returns existing similar tasks

-- Airtable: Refresh views, manual recalc
-- PostgreSQL: Materialized views, auto-refresh
SELECT * FROM task_metrics; -- Always current

-- Need to prove what happened?
SELECT * FROM progress_ledger 
WHERE case_id = 123 
ORDER BY event_timestamp DESC;
-- Complete history, immutable, auditable