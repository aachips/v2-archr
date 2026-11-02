-- =====================================================
-- STAFF QUEUE VIEW
-- For Admin, Caseworker, Project Manager dashboards
-- =====================================================

CREATE OR REPLACE VIEW staff_review_queue AS
SELECT 
    rq.fifo_order,
    s.id AS submission_id,
    s.applicant_first_name,
    s.applicant_last_name,
    s.home_address,
    s.submitted_at,
    s.helene_related,
    rq.status,
    rq.priority_score,
    -- Calculate time in queue
    EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - rq.queued_at))/3600 AS hours_in_queue,
    -- Get primary repair issue. submission_repair_categories has no id column
    -- (composite PK on submission_id+category_id), so order by category_id for
    -- a deterministic pick.
    (SELECT rc.category_label
     FROM submission_repair_categories src
     JOIN repair_categories rc ON src.category_id = rc.id
     WHERE src.submission_id = s.id
     ORDER BY src.category_id ASC LIMIT 1) AS primary_issue,
    -- Count of urgent conditions
    (SELECT COUNT(*) 
     FROM submission_repair_categories src
     JOIN repair_categories rc ON src.category_id = rc.id
     WHERE src.submission_id = s.id
       AND rc.category_code IN ('unable_to_stay', 'no_hvac', 'no_potable_water')) AS urgent_count,
    -- Eligibility result
    er.is_eligible,
    er.match_score AS best_match_score,
    co.organization_name AS best_match_org
FROM review_queue rq
JOIN intake_submissions s ON rq.submission_id = s.id
LEFT JOIN eligibility_results er ON s.id = er.submission_id
LEFT JOIN coalition_organizations co ON er.organization_id = co.id
WHERE rq.status IN ('PENDING_REVIEW', 'IN_REVIEW')
ORDER BY rq.priority_score DESC, rq.fifo_order ASC;

-- Role-specific queue filters
CREATE OR REPLACE VIEW admin_review_queue AS
SELECT * FROM staff_review_queue;

CREATE OR REPLACE VIEW caseworker_review_queue AS
SELECT * FROM staff_review_queue 
WHERE is_eligible = TRUE; -- Caseworkers only see eligible applications

CREATE OR REPLACE VIEW project_manager_review_queue AS
SELECT * FROM staff_review_queue 
WHERE is_eligible = TRUE 
  AND primary_issue IS NOT NULL; -- PMs see eligible with identified issues