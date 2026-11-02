-- =====================================================
-- ARCHR METRIC TRACKING SYSTEM
-- Live Dashboard Metrics with Algorithm Documentation
-- =====================================================
-- 
-- This file contains all 28 metrics organized into three dashboard sections:
--   1. Dashboard Past Week (7 metrics)
--   2. Dashboard All Time (8 metrics) 
--   3. Organization Specific Dashboard (13 metrics)
--
-- Each metric includes:
--   - Metric name and description
--   - Algorithm explanation
--   - Logic notes for developers
--   - Prepared SQL statement
--   - Expected output format
--
-- Last Updated: 2024-12-01
-- =====================================================

-- =====================================================
-- HELPER FUNCTIONS (Reusable across all metrics)
-- =====================================================

-- Function to get date range for "past week" (last 7 complete days, not including today)
CREATE OR REPLACE FUNCTION get_past_week_range()
RETURNS TABLE(start_date DATE, end_date DATE) AS $$
BEGIN
    start_date := (CURRENT_DATE - INTERVAL '7 days')::DATE;
    end_date := (CURRENT_DATE - INTERVAL '1 day')::DATE;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- Function to get date range for "current week to date" (including partial week)
CREATE OR REPLACE FUNCTION get_current_week_range()
RETURNS TABLE(start_date DATE, end_date DATE) AS $$
BEGIN
    start_date := DATE_TRUNC('week', CURRENT_DATE)::DATE;
    end_date := CURRENT_DATE;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- Helper view for completed assessments with valid triage scores
-- property_assessments uses `id` as its PK; expose it as assessment_id for
-- downstream consumers. assessment_completed_at is populated when the
-- assessor marks the visit complete (see role-based-access.sql).
CREATE OR REPLACE VIEW completed_assessments_with_triage AS
SELECT
    pa.case_id,
    pa.id AS assessment_id,
    pa.total_estimate,
    pa.priority_repairs,
    c.submission_id,
    s.helene_related,
    -- Calculate triage score based on: urgency (40%) + estimate size (30%) + Helene priority (30%)
    -- Formula: (urgent_conditions * 40) + (estimate_percentile * 30) + (helene_bonus * 30)
    -- Where urgent_conditions count is normalized to 0-100 scale
    LEAST(
        COALESCE(
            (SELECT COUNT(*) FROM submission_repair_categories src 
             JOIN repair_categories rc ON src.category_id = rc.id 
             WHERE src.submission_id = s.id 
             AND rc.category_code IN ('unable_to_stay', 'no_hvac', 'no_potable_water', 
                                       'no_bathroom', 'no_kitchen', 'open_to_elements', 'no_entry')
            ) * 12.5, 0
        ) + 
        COALESCE(
            (pa.total_estimate / NULLIF((SELECT MAX(total_estimate) FROM property_assessments), 0)) * 30, 0
        ) +
        CASE WHEN s.helene_related THEN 30 ELSE 0 END,
    100) AS triage_score
FROM property_assessments pa
JOIN cases c ON pa.case_id = c.id
JOIN intake_submissions s ON c.submission_id = s.id
WHERE pa.assessment_completed_at IS NOT NULL;


-- =====================================================
-- SECTION 1: DASHBOARD PAST WEEK METRICS
-- =====================================================

/* ------------------------------------------------------------------------
   METRIC 1: Total Applications
   ------------------------------------------------------------------------
   DESCRIPTION: Number of intake applications submitted in the past 7 days
   
   ALGORITHM: COUNT all intake_submissions where submitted_at falls within
              the past 7 complete days (excluding today to avoid partial data)
   
   LOGIC NOTES: 
   - Uses get_past_week_range() to get consistent date boundaries
   - Excludes test/debug submissions (is_test flag if available)
   - Includes all statuses (no filtering by approval/rejection)
   
   BUSINESS VALUE: Measures application volume and intake demand
   ------------------------------------------------------------------------ */
WITH past_week AS (SELECT * FROM get_past_week_range())
SELECT 
    COUNT(*) AS total_applications
FROM intake_submissions s, past_week pw
WHERE s.submitted_at::DATE BETWEEN pw.start_date AND pw.end_date
  AND (s.is_test IS NULL OR s.is_test = false);

-- PREPARED STATEMENT VERSION:
PREPARE metric_total_applications_past_week AS
    WITH past_week AS (SELECT * FROM get_past_week_range())
    SELECT COUNT(*) AS total_applications
    FROM intake_submissions s, past_week pw
    WHERE s.submitted_at::DATE BETWEEN pw.start_date AND pw.end_date
      AND (s.is_test IS NULL OR s.is_test = false);
-- EXECUTE metric_total_applications_past_week;


/* ------------------------------------------------------------------------
   METRIC 2: Assessments Assigned
   ------------------------------------------------------------------------
   DESCRIPTION: Number of property assessments assigned to assessors in the past week
   
   ALGORITHM: COUNT property_assessments where assigned_at (or created_at for 
              new assessments) is within past 7 days
   
   LOGIC NOTES:
   - An assessment is "assigned" when it has an assessor_id and assigned_at date
   - If assigned_at is NULL, use created_at as proxy
   - Excludes completed assessments from this count (they have their own metric)
   
   BUSINESS VALUE: Tracks assessment workload and assessor capacity
   ------------------------------------------------------------------------ */
WITH past_week AS (SELECT * FROM get_past_week_range())
SELECT 
    COUNT(DISTINCT pa.id) AS assessments_assigned
FROM property_assessments pa, past_week pw
CROSS JOIN cases c
WHERE pa.case_id = c.id
  AND (pa.assigned_at IS NOT NULL AND pa.assigned_at::DATE BETWEEN pw.start_date AND pw.end_date
       OR pa.assigned_at IS NULL AND pa.created_at::DATE BETWEEN pw.start_date AND pw.end_date);

PREPARE metric_assessments_assigned_past_week AS
    WITH past_week AS (SELECT * FROM get_past_week_range())
    SELECT COUNT(DISTINCT pa.id) AS assessments_assigned
    FROM property_assessments pa, past_week pw
    CROSS JOIN cases c
    WHERE pa.case_id = c.id
      AND (pa.assigned_at IS NOT NULL AND pa.assigned_at::DATE BETWEEN pw.start_date AND pw.end_date
           OR pa.assigned_at IS NULL AND pa.created_at::DATE BETWEEN pw.start_date AND pw.end_date);
-- EXECUTE metric_assessments_assigned_past_week;


/* ------------------------------------------------------------------------
   METRIC 3: Assessments Completed
   ------------------------------------------------------------------------
   DESCRIPTION: Number of property assessments completed in the past 7 days
   
   ALGORITHM: COUNT property_assessments where assessment_completed_at is 
              within past 7 days
   
   LOGIC NOTES:
   - "Completed" means the assessment has a non-NULL assessment_completed_at
   - Assessment may have been assigned weeks ago but completed this week
   - This tracks throughput, not just new work
   
   BUSINESS VALUE: Measures assessment completion rate and team productivity
   ------------------------------------------------------------------------ */
WITH past_week AS (SELECT * FROM get_past_week_range())
SELECT 
    COUNT(*) AS assessments_completed
FROM property_assessments pa, past_week pw
WHERE pa.assessment_completed_at::DATE BETWEEN pw.start_date AND pw.end_date;

PREPARE metric_assessments_completed_past_week AS
    WITH past_week AS (SELECT * FROM get_past_week_range())
    SELECT COUNT(*) AS assessments_completed
    FROM property_assessments pa, past_week pw
    WHERE pa.assessment_completed_at::DATE BETWEEN pw.start_date AND pw.end_date;
-- EXECUTE metric_assessments_completed_past_week;


/* ------------------------------------------------------------------------
   METRIC 4: Average Triage Score
   ------------------------------------------------------------------------
   DESCRIPTION: Average triage score of assessments completed in the past week
   
   ALGORITHM: AVG of triage_score from completed assessments in past week
   
   TRIAGE SCORE FORMULA (0-100):
   - Urgent conditions (40% max): Each urgent condition = 12.5 points
     * Conditions: unable_to_stay, no_hvac, no_potable_water, no_bathroom, 
                   no_kitchen, open_to_elements, no_entry (7 total = 87.5 max, capped at 40)
   - Estimate size (30% max): Normalized by max estimate in system
   - Helene-related (30% max): +30 if damage from Hurricane Helene
   
   LOGIC NOTES:
   - Higher score = more urgent need (prioritize these cases)
   - Capped at 100 total points
   - Uses helper view completed_assessments_with_triage for consistency
   
   BUSINESS VALUE: Prioritization tool for resource allocation
   ------------------------------------------------------------------------ */
WITH past_week AS (SELECT * FROM get_past_week_range()),
recent_assessments AS (
    -- Use ANSI JOINs throughout; mixing comma-joins with explicit JOIN ON
    -- breaks scoping of `pa` for the ON clause in PostgreSQL.
    SELECT pa.id, cat.triage_score
    FROM property_assessments pa
    JOIN completed_assessments_with_triage cat ON pa.id = cat.assessment_id
    CROSS JOIN past_week pw
    WHERE pa.assessment_completed_at::DATE BETWEEN pw.start_date AND pw.end_date
)
SELECT
    ROUND(AVG(triage_score), 1) AS avg_triage_score,
    MIN(triage_score) AS min_triage_score,
    MAX(triage_score) AS max_triage_score,
    COUNT(*) AS assessments_in_calc
FROM recent_assessments;

PREPARE metric_avg_triage_score_past_week AS
    WITH past_week AS (SELECT * FROM get_past_week_range()),
    recent_assessments AS (
        SELECT pa.id, cat.triage_score
        FROM property_assessments pa
        JOIN completed_assessments_with_triage cat ON pa.id = cat.assessment_id
        CROSS JOIN past_week pw
        WHERE pa.assessment_completed_at::DATE BETWEEN pw.start_date AND pw.end_date
    )
    SELECT ROUND(AVG(triage_score), 1) AS avg_triage_score
    FROM recent_assessments;
-- EXECUTE metric_avg_triage_score_past_week;


/* ------------------------------------------------------------------------
   METRIC 5: Total # of Individuals (from household size)
   ------------------------------------------------------------------------
   DESCRIPTION: Sum of household sizes from applications submitted in past week
   
   ALGORITHM: SUM(household_size) for all intake submissions in past week
   
   LOGIC NOTES:
   - Household size is self-reported by applicant on Page 5 of intake form
   - This is total people served, not number of households
   - Important for grant reporting and measuring community impact
   
   BUSINESS VALUE: Measures total individuals served/impacted by services
   ------------------------------------------------------------------------ */
WITH past_week AS (SELECT * FROM get_past_week_range())
SELECT 
    SUM(s.household_size) AS total_individuals_served,
    COUNT(*) AS total_households,
    ROUND(AVG(s.household_size), 1) AS avg_household_size
FROM intake_submissions s, past_week pw
WHERE s.submitted_at::DATE BETWEEN pw.start_date AND pw.end_date
  AND s.household_size IS NOT NULL;

PREPARE metric_total_individuals_past_week AS
    WITH past_week AS (SELECT * FROM get_past_week_range())
    SELECT SUM(s.household_size) AS total_individuals_served
    FROM intake_submissions s, past_week pw
    WHERE s.submitted_at::DATE BETWEEN pw.start_date AND pw.end_date
      AND s.household_size IS NOT NULL;
-- EXECUTE metric_total_individuals_past_week;


/* ------------------------------------------------------------------------
   METRIC 6: Income Breakdown
   ------------------------------------------------------------------------
   DESCRIPTION: Distribution of applications by income bracket (past week only)
   
   ALGORITHM: Categorize gross_annual_income into brackets and count
   
   INCOME BRACKETS:
   - $0 (Zero income affidavit)
   - $1 - $15,000 (Extremely low income)
   - $15,001 - $30,000 (Very low income)  
   - $30,001 - $50,000 (Low income)
   - $50,001 - $75,000 (Moderate income)
   - $75,001+ (Above moderate)
   
   LOGIC NOTES:
   - Uses gross_annual_income from Page 12 if available
   - If has_income = false, categorize as $0
   - If income_method = 'calculator', uses sum of income_records annualized
   
   BUSINESS VALUE: Grant eligibility reporting and needs assessment
   ------------------------------------------------------------------------ */
WITH past_week AS (SELECT * FROM get_past_week_range()),
income_data AS (
    SELECT 
        s.id,
        s.has_income,
        s.gross_annual_income,
        CASE 
            WHEN s.has_income = false THEN 0
            WHEN s.gross_annual_income IS NOT NULL THEN s.gross_annual_income
            ELSE (
                SELECT SUM(
                    CASE frequency
                        WHEN 'weekly' THEN amount * 52
                        WHEN 'biweekly' THEN amount * 26
                        WHEN 'monthly' THEN amount * 12
                        WHEN 'annually' THEN amount
                        ELSE amount
                    END
                ) FROM income_records ir WHERE ir.submission_id = s.id
            )
        END AS calculated_income
    FROM intake_submissions s, past_week pw
    WHERE s.submitted_at::DATE BETWEEN pw.start_date AND pw.end_date
)
SELECT 
    CASE 
        WHEN calculated_income = 0 THEN '$0 (Zero income)'
        WHEN calculated_income <= 15000 THEN '$1 - $15,000 (Extremely low)'
        WHEN calculated_income <= 30000 THEN '$15,001 - $30,000 (Very low)'
        WHEN calculated_income <= 50000 THEN '$30,001 - $50,000 (Low)'
        WHEN calculated_income <= 75000 THEN '$50,001 - $75,000 (Moderate)'
        ELSE '$75,001+ (Above moderate)'
    END AS income_bracket,
    COUNT(*) AS application_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM income_data
GROUP BY 
    CASE 
        WHEN calculated_income = 0 THEN '$0 (Zero income)'
        WHEN calculated_income <= 15000 THEN '$1 - $15,000 (Extremely low)'
        WHEN calculated_income <= 30000 THEN '$15,001 - $30,000 (Very low)'
        WHEN calculated_income <= 50000 THEN '$30,001 - $50,000 (Low)'
        WHEN calculated_income <= 75000 THEN '$50,001 - $75,000 (Moderate)'
        ELSE '$75,001+ (Above moderate)'
    END
ORDER BY MIN(calculated_income);

PREPARE metric_income_breakdown_past_week AS
    WITH past_week AS (SELECT * FROM get_past_week_range()),
    income_data AS (
        SELECT 
            s.id,
            CASE 
                WHEN s.has_income = false THEN 0
                WHEN s.gross_annual_income IS NOT NULL THEN s.gross_annual_income
                ELSE (
                    SELECT SUM(
                        CASE frequency
                            WHEN 'weekly' THEN amount * 52
                            WHEN 'biweekly' THEN amount * 26
                            WHEN 'monthly' THEN amount * 12
                            WHEN 'annually' THEN amount
                            ELSE amount
                        END
                    ) FROM income_records ir WHERE ir.submission_id = s.id
                )
            END AS calculated_income
        FROM intake_submissions s, past_week pw
        WHERE s.submitted_at::DATE BETWEEN pw.start_date AND pw.end_date
    )
    SELECT 
        CASE 
            WHEN calculated_income = 0 THEN '$0'
            WHEN calculated_income <= 15000 THEN '$1-15k'
            WHEN calculated_income <= 30000 THEN '$15k-30k'
            WHEN calculated_income <= 50000 THEN '$30k-50k'
            WHEN calculated_income <= 75000 THEN '$50k-75k'
            ELSE '$75k+'
        END AS bracket,
        COUNT(*) AS count
    FROM income_data
    GROUP BY 1
    ORDER BY MIN(calculated_income);
-- EXECUTE metric_income_breakdown_past_week;


/* ------------------------------------------------------------------------
   METRIC 7: County Breakdown
   ------------------------------------------------------------------------
   DESCRIPTION: Distribution of applications by county (past week only)
   
   ALGORITHM: Extract county from home_city or use home_county field, group by county
   
   LOGIC NOTES:
   - Primary service area: Buncombe County (Asheville)
   - Also tracks Madison, Henderson, Haywood, Transylvania, Yancey, Mitchell
   - Uses home_city to infer county for Buncombe (Asheville, Black Mountain, etc.)
   - Future improvement: add explicit home_county field to intake form
   
   BUSINESS VALUE: Geographic coverage analysis and resource planning
   ------------------------------------------------------------------------ */
WITH past_week AS (SELECT * FROM get_past_week_range()),
county_mapping AS (
    SELECT 
        s.id,
        s.home_city,
        s.home_zip,
        CASE 
            WHEN s.home_city ILIKE '%Asheville%' OR s.home_city ILIKE '%Black Mountain%' 
                 OR s.home_city ILIKE '%Weaverville%' OR s.home_city ILIKE '%Woodfin%'
                 OR s.home_city ILIKE '%Swannanoa%' OR s.home_zip IN ('28801','28803','28804','28805','28806','28711')
                THEN 'Buncombe'
            WHEN s.home_city ILIKE '%Mars Hill%' OR s.home_city ILIKE '%Marshall%' 
                 OR s.home_zip LIKE '287%' AND s.home_zip BETWEEN '28700' AND '28799'
                THEN 'Madison'
            WHEN s.home_city ILIKE '%Hendersonville%' OR s.home_zip LIKE '287%' 
                THEN 'Henderson'
            WHEN s.home_city ILIKE '%Waynesville%' OR s.home_city ILIKE '%Maggie Valley%'
                THEN 'Haywood'
            WHEN s.home_city ILIKE '%Brevard%' THEN 'Transylvania'
            WHEN s.home_city ILIKE '%Burnsville%' THEN 'Yancey'
            WHEN s.home_city ILIKE '%Spruce Pine%' THEN 'Mitchell'
            ELSE 'Other / Unknown'
        END AS county
    FROM intake_submissions s, past_week pw
    WHERE s.submitted_at::DATE BETWEEN pw.start_date AND pw.end_date
)
SELECT 
    county,
    COUNT(*) AS application_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM county_mapping
GROUP BY county
ORDER BY application_count DESC;

PREPARE metric_county_breakdown_past_week AS
    WITH past_week AS (SELECT * FROM get_past_week_range()),
    county_mapping AS (
        SELECT 
            CASE 
                WHEN s.home_city ILIKE '%Asheville%' OR s.home_zip IN ('28801','28803','28804','28805','28806') THEN 'Buncombe'
                WHEN s.home_city ILIKE '%Mars Hill%' OR s.home_city ILIKE '%Marshall%' THEN 'Madison'
                WHEN s.home_city ILIKE '%Hendersonville%' THEN 'Henderson'
                ELSE 'Other'
            END AS county
        FROM intake_submissions s, past_week pw
        WHERE s.submitted_at::DATE BETWEEN pw.start_date AND pw.end_date
    )
    SELECT county, COUNT(*) AS count
    FROM county_mapping
    GROUP BY county
    ORDER BY count DESC;
-- EXECUTE metric_county_breakdown_past_week;


/* ------------------------------------------------------------------------
   METRIC 8: Issue Type Pie
   ------------------------------------------------------------------------
   DESCRIPTION: Distribution of applications by primary repair issue type
   
   ALGORITHM: Count most frequently selected repair_category for each application
   
   LOGIC NOTES:
   - Each application can select multiple repair categories (Page 7)
   - This metric counts the PRIMARY issue (first selected or highest priority)
   - Categories: unable_to_stay, no_hvac, no_potable_water, no_bathroom, 
                 no_kitchen, open_to_elements, no_entry, accessibility, other_issue
   - For pie chart visualization
   
   BUSINESS VALUE: Resource planning (e.g., need more HVAC contractors vs roofers)
   ------------------------------------------------------------------------ */
WITH past_week AS (SELECT * FROM get_past_week_range()),
primary_issues AS (
    -- ANSI joins only; submission_repair_categories has a composite PK and no
    -- `id` column, so order by category_id for a deterministic primary pick.
    SELECT DISTINCT ON (s.id)
        s.id,
        rc.category_code,
        rc.category_label
    FROM intake_submissions s
    JOIN submission_repair_categories src ON s.id = src.submission_id
    JOIN repair_categories rc ON src.category_id = rc.id
    CROSS JOIN past_week pw
    WHERE s.submitted_at::DATE BETWEEN pw.start_date AND pw.end_date
    ORDER BY s.id, src.category_id
)
SELECT
    category_label AS issue_type,
    COUNT(*) AS application_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM primary_issues
GROUP BY category_code, category_label
ORDER BY application_count DESC;

PREPARE metric_issue_type_pie_past_week AS
    WITH past_week AS (SELECT * FROM get_past_week_range()),
    primary_issues AS (
        SELECT DISTINCT ON (s.id) s.id, rc.category_label
        FROM intake_submissions s
        JOIN submission_repair_categories src ON s.id = src.submission_id
        JOIN repair_categories rc ON src.category_id = rc.id
        CROSS JOIN past_week pw
        WHERE s.submitted_at::DATE BETWEEN pw.start_date AND pw.end_date
        ORDER BY s.id, src.category_id
    )
    SELECT category_label, COUNT(*) AS count
    FROM primary_issues
    GROUP BY category_label
    ORDER BY count DESC;
-- EXECUTE metric_issue_type_pie_past_week;


-- =====================================================
-- SECTION 2: DASHBOARD ALL TIME METRICS
-- =====================================================

/* ------------------------------------------------------------------------
   METRIC 9: Total Jobs
   ------------------------------------------------------------------------
   DESCRIPTION: Total number of work orders/jobs ever created
   
   ALGORITHM: COUNT all work_orders (distinct jobs, not individual tasks)
   
   LOGIC NOTES:
   - A "job" = one work_order record (may contain multiple tasks)
   - Counts all work orders regardless of status
   - Does not count applications that never became work orders
   
   BUSINESS VALUE: Total organizational output since inception
   ------------------------------------------------------------------------ */
SELECT 
    COUNT(*) AS total_jobs,
    COUNT(DISTINCT case_id) AS unique_cases_with_jobs
FROM work_orders;

PREPARE metric_total_jobs_all_time AS
    SELECT COUNT(*) AS total_jobs FROM work_orders;
-- EXECUTE metric_total_jobs_all_time;


/* ------------------------------------------------------------------------
   METRIC 10: Jobs in Progress
   ------------------------------------------------------------------------
   DESCRIPTION: Number of work orders currently in progress
   
   ALGORITHM: COUNT work_orders where status IN ('in_progress', 'assigned', 'planned')
   
   LOGIC NOTES:
   - Excludes completed, cancelled, and on_hold work orders
   - "In progress" means active work happening now
   - Does not include assessments or applications (different pipeline stage)
   
   BUSINESS VALUE: Current workload and capacity utilization
   ------------------------------------------------------------------------ */
SELECT 
    COUNT(*) AS jobs_in_progress,
    status,
    COUNT(*) AS count_by_status
FROM work_orders
WHERE status IN ('in_progress', 'assigned', 'planned')
GROUP BY ROLLUP(status)
ORDER BY status;

PREPARE metric_jobs_in_progress_all_time AS
    SELECT COUNT(*) AS jobs_in_progress
    FROM work_orders
    WHERE status IN ('in_progress', 'assigned', 'planned');
-- EXECUTE metric_jobs_in_progress_all_time;


/* ------------------------------------------------------------------------
   METRIC 11: Jobs Completed
   ------------------------------------------------------------------------
   DESCRIPTION: Number of work orders successfully completed
   
   ALGORITHM: COUNT work_orders where status = 'completed'
   
   LOGIC NOTES:
   - Completion requires final inspection and applicant sign-off
   - Work order completion triggers certificate generation
   - Does not include jobs that were cancelled or rejected
   
   BUSINESS VALUE: Total successful project completions (key performance metric)
   ------------------------------------------------------------------------ */
SELECT 
    COUNT(*) AS jobs_completed,
    DATE_TRUNC('month', actual_end_date) AS completion_month,
    COUNT(*) AS monthly_completions
FROM work_orders
WHERE status = 'completed'
  AND actual_end_date IS NOT NULL
GROUP BY DATE_TRUNC('month', actual_end_date)
ORDER BY completion_month DESC;

PREPARE metric_jobs_completed_all_time AS
    SELECT COUNT(*) AS jobs_completed FROM work_orders WHERE status = 'completed';
-- EXECUTE metric_jobs_completed_all_time;


/* ------------------------------------------------------------------------
   METRIC 12: Jobs Withdrawn/Rejected/Ineligible
   ------------------------------------------------------------------------
   DESCRIPTION: Number of work orders that were not completed (negative outcomes)
   
   ALGORITHM: COUNT work_orders where status IN ('cancelled', 'rejected') 
              OR applications where final_status = 'denied' or 'withdrawn'
   
   LOGIC NOTES:
   - Captures all applications that didn't result in completed work
   - Categories: Withdrawn (applicant withdrew), Rejected (by organization), 
                 Ineligible (screened out), Cancelled (after start)
   - Important for understanding pipeline leakage
   
   BUSINESS VALUE: Quality of intake screening and resource efficiency
   ------------------------------------------------------------------------ */
SELECT 
    'Withdrawn' AS outcome_type,
    COUNT(*) AS count
FROM intake_submissions
WHERE submission_status = 'withdrawn'
UNION ALL
SELECT 
    'Rejected by Org' AS outcome_type,
    COUNT(*) AS count
FROM application_assignments aa
JOIN intake_submissions s ON aa.submission_id = s.id
WHERE aa.status = 'rejected'
  AND s.submission_status != 'withdrawn'
UNION ALL
SELECT 
    'Ineligible' AS outcome_type,
    COUNT(*) AS count
FROM intake_submissions
WHERE submission_status = 'denied'
  AND submission_status NOT IN ('withdrawn', 'approved')
UNION ALL
SELECT 
    'Cancelled Work Order' AS outcome_type,
    COUNT(*) AS count
FROM work_orders
WHERE status = 'cancelled';

PREPARE metric_jobs_negative_outcomes_all_time AS
    SELECT 
        SUM(CASE WHEN submission_status = 'withdrawn' THEN 1 ELSE 0 END) AS withdrawn,
        SUM(CASE WHEN submission_status = 'denied' THEN 1 ELSE 0 END) AS ineligible
    FROM intake_submissions;
-- EXECUTE metric_jobs_negative_outcomes_all_time;


/* ------------------------------------------------------------------------
   METRIC 13: Average Job Cost
   ------------------------------------------------------------------------
   DESCRIPTION: Average cost of completed jobs (actual, not estimated)
   
   ALGORITHM: AVG(total_actual_cost) for completed work_orders
   
   LOGIC NOTES:
   - Uses total_actual_cost from cases table (sum of all expenses)
   - Only includes COMPLETED jobs (final actual cost known)
   - Excludes jobs with zero cost (data errors)
   
   BUSINESS VALUE: Budget planning and cost forecasting
   ------------------------------------------------------------------------ */
SELECT 
    ROUND(AVG(c.total_actual_cost), 2) AS avg_job_cost,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY c.total_actual_cost) AS median_job_cost,
    MIN(c.total_actual_cost) AS min_job_cost,
    MAX(c.total_actual_cost) AS max_job_cost,
    COUNT(*) AS number_of_jobs,
    SUM(c.total_actual_cost) AS total_spent
FROM cases c
JOIN work_orders wo ON c.id = wo.case_id
WHERE wo.status = 'completed'
  AND c.total_actual_cost IS NOT NULL
  AND c.total_actual_cost > 0;

PREPARE metric_avg_job_cost_all_time AS
    SELECT ROUND(AVG(c.total_actual_cost), 2) AS avg_job_cost
    FROM cases c
    JOIN work_orders wo ON c.id = wo.case_id
    WHERE wo.status = 'completed'
      AND c.total_actual_cost IS NOT NULL
      AND c.total_actual_cost > 0;
-- EXECUTE metric_avg_job_cost_all_time;


/* ------------------------------------------------------------------------
   METRIC 14: All Jobs Income Breakdown
   ------------------------------------------------------------------------
   DESCRIPTION: Distribution of ALL completed jobs by applicant income bracket
   
   ALGORITHM: Same as Metric 6, but for ALL completed jobs (not just past week)
   
   LOGIC NOTES:
   - Only includes cases with completed work orders
   - Shows who we're serving at macro level
   - Important for grant compliance (serving low-moderate income households)
   
   BUSINESS VALUE: Grant reporting and mission alignment verification
   ------------------------------------------------------------------------ */
WITH completed_cases AS (
    SELECT DISTINCT c.submission_id
    FROM cases c
    JOIN work_orders wo ON c.id = wo.case_id
    WHERE wo.status = 'completed'
),
income_data AS (
    SELECT 
        s.id,
        CASE 
            WHEN s.has_income = false THEN 0
            WHEN s.gross_annual_income IS NOT NULL THEN s.gross_annual_income
            ELSE (
                SELECT SUM(
                    CASE frequency
                        WHEN 'weekly' THEN amount * 52
                        WHEN 'biweekly' THEN amount * 26
                        WHEN 'monthly' THEN amount * 12
                        WHEN 'annually' THEN amount
                        ELSE amount
                    END
                ) FROM income_records ir WHERE ir.submission_id = s.id
            )
        END AS calculated_income
    FROM intake_submissions s
    JOIN completed_cases cc ON s.id = cc.submission_id
)
SELECT 
    CASE 
        WHEN calculated_income = 0 THEN '$0 (Zero income)'
        WHEN calculated_income <= 15000 THEN '$1 - $15,000'
        WHEN calculated_income <= 30000 THEN '$15,001 - $30,000'
        WHEN calculated_income <= 50000 THEN '$30,001 - $50,000'
        WHEN calculated_income <= 75000 THEN '$50,001 - $75,000'
        ELSE '$75,001+'
    END AS income_bracket,
    COUNT(*) AS completed_jobs,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM income_data
GROUP BY 
    CASE 
        WHEN calculated_income = 0 THEN '$0 (Zero income)'
        WHEN calculated_income <= 15000 THEN '$1 - $15,000'
        WHEN calculated_income <= 30000 THEN '$15,001 - $30,000'
        WHEN calculated_income <= 50000 THEN '$30,001 - $50,000'
        WHEN calculated_income <= 75000 THEN '$50,001 - $75,000'
        ELSE '$75,001+'
    END
ORDER BY MIN(calculated_income);

PREPARE metric_all_jobs_income_breakdown AS
    WITH completed_cases AS (
        SELECT DISTINCT c.submission_id
        FROM cases c
        JOIN work_orders wo ON c.id = wo.case_id
        WHERE wo.status = 'completed'
    ),
    income_data AS (
        SELECT 
            CASE 
                WHEN s.has_income = false THEN 0
                ELSE COALESCE(s.gross_annual_income, 0)
            END AS calculated_income
        FROM intake_submissions s
        JOIN completed_cases cc ON s.id = cc.submission_id
    )
    SELECT 
        CASE 
            WHEN calculated_income <= 15000 THEN 'Low (0-15k)'
            WHEN calculated_income <= 50000 THEN 'Moderate (15k-50k)'
            ELSE 'Higher (50k+)'
        END AS bracket,
        COUNT(*) AS count
    FROM income_data
    GROUP BY 1;
-- EXECUTE metric_all_jobs_income_breakdown;


/* ------------------------------------------------------------------------
   METRIC 15: All Jobs County Breakdown
   ------------------------------------------------------------------------
   DESCRIPTION: Distribution of ALL completed jobs by county
   
   ALGORITHM: Same as Metric 7, but for ALL completed jobs
   
   LOGIC NOTES:
   - Geographic distribution of where work was actually performed
   - May differ from application distribution (some counties harder to serve)
   
   BUSINESS VALUE: Geographic coverage analysis and resource allocation
   ------------------------------------------------------------------------ */
WITH completed_cases AS (
    SELECT DISTINCT c.submission_id
    FROM cases c
    JOIN work_orders wo ON c.id = wo.case_id
    WHERE wo.status = 'completed'
),
county_mapping AS (
    SELECT 
        s.id,
        CASE 
            WHEN s.home_city ILIKE '%Asheville%' OR s.home_zip IN ('28801','28803','28804','28805','28806') THEN 'Buncombe'
            WHEN s.home_city ILIKE '%Mars Hill%' OR s.home_city ILIKE '%Marshall%' THEN 'Madison'
            WHEN s.home_city ILIKE '%Hendersonville%' THEN 'Henderson'
            WHEN s.home_city ILIKE '%Waynesville%' THEN 'Haywood'
            ELSE 'Other'
        END AS county
    FROM intake_submissions s
    JOIN completed_cases cc ON s.id = cc.submission_id
)
SELECT 
    county,
    COUNT(*) AS completed_jobs,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM county_mapping
GROUP BY county
ORDER BY completed_jobs DESC;

PREPARE metric_all_jobs_county_breakdown AS
    WITH completed_cases AS (
        SELECT DISTINCT c.submission_id
        FROM cases c
        JOIN work_orders wo ON c.id = wo.case_id
        WHERE wo.status = 'completed'
    ),
    county_mapping AS (
        SELECT 
            CASE 
                WHEN s.home_city ILIKE '%Asheville%' THEN 'Buncombe'
                ELSE 'Other'
            END AS county
        FROM intake_submissions s
        JOIN completed_cases cc ON s.id = cc.submission_id
    )
    SELECT county, COUNT(*) AS count
    FROM county_mapping
    GROUP BY county;
-- EXECUTE metric_all_jobs_county_breakdown;


/* ------------------------------------------------------------------------
   METRIC 16: Highest and Lowest Job Costs
   ------------------------------------------------------------------------
   DESCRIPTION: Most expensive and least expensive completed jobs
   
   ALGORITHM: MAX(total_actual_cost) and MIN(total_actual_cost) from completed cases
   
   LOGIC NOTES:
   - Excludes zero-cost jobs (likely data errors)
   - Returns both the values AND the case identifiers for drill-down
   
   BUSINESS VALUE: Identify cost outliers, large/complex projects, small quick wins
   ------------------------------------------------------------------------ */
WITH completed_job_costs AS (
    SELECT 
        c.id AS case_id,
        c.case_number,
        c.total_actual_cost,
        s.applicant_first_name,
        s.applicant_last_name,
        s.home_address
    FROM cases c
    JOIN intake_submissions s ON c.submission_id = s.id
    JOIN work_orders wo ON c.id = wo.case_id
    WHERE wo.status = 'completed'
      AND c.total_actual_cost IS NOT NULL
      AND c.total_actual_cost > 0
)
SELECT 
    'Highest' AS metric_type,
    case_id,
    case_number,
    total_actual_cost AS cost,
    applicant_first_name || ' ' || applicant_last_name AS applicant_name,
    home_address
FROM completed_job_costs
WHERE total_actual_cost = (SELECT MAX(total_actual_cost) FROM completed_job_costs)
UNION ALL
SELECT 
    'Lowest' AS metric_type,
    case_id,
    case_number,
    total_actual_cost AS cost,
    applicant_first_name || ' ' || applicant_last_name AS applicant_name,
    home_address
FROM completed_job_costs
WHERE total_actual_cost = (SELECT MIN(total_actual_cost) FROM completed_job_costs);

PREPARE metric_extreme_job_costs_all_time AS
    WITH costs AS (
        SELECT c.total_actual_cost
        FROM cases c
        JOIN work_orders wo ON c.id = wo.case_id
        WHERE wo.status = 'completed' AND c.total_actual_cost > 0
    )
    SELECT 
        MAX(total_actual_cost) AS highest_cost,
        MIN(total_actual_cost) AS lowest_cost
    FROM costs;
-- EXECUTE metric_extreme_job_costs_all_time;


-- =====================================================
-- SECTION 3: ORGANIZATION SPECIFIC DASHBOARD
-- =====================================================

/* ------------------------------------------------------------------------
   METRIC 17: Org Specific - Total Jobs
   ------------------------------------------------------------------------
   DESCRIPTION: Total work orders assigned to a specific organization
   
   ALGORITHM: COUNT work_orders WHERE organization_id = target_org
   
   LOGIC NOTES:
   - Filter by the organization's ID (passed as parameter)
   - Includes all work orders regardless of status
   
   BUSINESS VALUE: Per-org productivity measurement
   ------------------------------------------------------------------------ */
-- Parameter: $1 = organization_id
-- Illustrative query only; $1 is only bound inside a PREPARE, so executing this
-- standalone fails at deploy time. The runnable form is the PREPARE below.
/*
SELECT
    o.organization_name,
    COUNT(DISTINCT wo.id) AS total_jobs,
    COUNT(DISTINCT wo.case_id) AS unique_cases
FROM coalition_organizations o
LEFT JOIN application_assignments aa ON o.id = aa.organization_id
LEFT JOIN cases c ON aa.submission_id = c.submission_id
LEFT JOIN work_orders wo ON c.id = wo.case_id
WHERE o.id = $1
GROUP BY o.id, o.organization_name;
*/

PREPARE metric_org_total_jobs(INTEGER) AS
    SELECT COUNT(DISTINCT wo.id) AS total_jobs
    FROM coalition_organizations o
    LEFT JOIN application_assignments aa ON o.id = aa.organization_id
    LEFT JOIN cases c ON aa.submission_id = c.submission_id
    LEFT JOIN work_orders wo ON c.id = wo.case_id
    WHERE o.id = $1;
-- EXECUTE metric_org_total_jobs(1);


/* ------------------------------------------------------------------------
   METRIC 18: Org Specific - Jobs in Progress
   ------------------------------------------------------------------------
   DESCRIPTION: Active work orders for a specific organization
   
   ALGORITHM: COUNT work_orders WHERE org = target AND status in progress
   
   BUSINESS VALUE: Org-specific workload monitoring
   ------------------------------------------------------------------------ */
PREPARE metric_org_jobs_in_progress(INTEGER) AS
    SELECT COUNT(DISTINCT wo.id) AS jobs_in_progress
    FROM coalition_organizations o
    LEFT JOIN application_assignments aa ON o.id = aa.organization_id
    LEFT JOIN cases c ON aa.submission_id = c.submission_id
    LEFT JOIN work_orders wo ON c.id = wo.case_id
    WHERE o.id = $1
      AND wo.status IN ('in_progress', 'assigned', 'planned');
-- EXECUTE metric_org_jobs_in_progress(1);


/* ------------------------------------------------------------------------
   METRIC 19: Org Specific - Jobs Completed
   ------------------------------------------------------------------------
   DESCRIPTION: Completed work orders for a specific organization
   
   ALGORITHM: COUNT work_orders WHERE org = target AND status = 'completed'
   
   BUSINESS VALUE: Org-specific success rate tracking
   ------------------------------------------------------------------------ */
PREPARE metric_org_jobs_completed(INTEGER) AS
    SELECT COUNT(DISTINCT wo.id) AS jobs_completed
    FROM coalition_organizations o
    LEFT JOIN application_assignments aa ON o.id = aa.organization_id
    LEFT JOIN cases c ON aa.submission_id = c.submission_id
    LEFT JOIN work_orders wo ON c.id = wo.case_id
    WHERE o.id = $1
      AND wo.status = 'completed';
-- EXECUTE metric_org_jobs_completed(1);


/* ------------------------------------------------------------------------
   METRIC 20: Org Specific - Jobs Suggested
   ------------------------------------------------------------------------
   DESCRIPTION: Number of jobs that were suggested/assigned to this org (may not have been claimed)
   
   ALGORITHM: COUNT application_assignments WHERE org = target AND status = 'pending'
   
   LOGIC NOTES:
   - Jobs "suggested" = assigned by system but not yet claimed/rejected
   - Important for measuring org responsiveness
   
   BUSINESS VALUE: Measure how quickly orgs claim assignments
   ------------------------------------------------------------------------ */
PREPARE metric_org_jobs_suggested(INTEGER) AS
    SELECT COUNT(*) AS jobs_suggested
    FROM application_assignments aa
    WHERE aa.organization_id = $1
      AND aa.status = 'pending'
      AND aa.expires_at > CURRENT_TIMESTAMP;
-- EXECUTE metric_org_jobs_suggested(1);


/* ------------------------------------------------------------------------
   METRIC 21: Org Specific - Assessments Assigned Total
   ------------------------------------------------------------------------
   DESCRIPTION: Total property assessments assigned to this org's assessors
   
   ALGORITHM: COUNT property_assessments WHERE organization derived from case
   
   BUSINESS VALUE: Assessment workload by organization
   ------------------------------------------------------------------------ */
PREPARE metric_org_assessments_assigned(INTEGER) AS
    SELECT COUNT(DISTINCT pa.id) AS assessments_assigned_total
    FROM coalition_organizations o
    LEFT JOIN application_assignments aa ON o.id = aa.organization_id
    LEFT JOIN cases c ON aa.submission_id = c.submission_id
    LEFT JOIN property_assessments pa ON c.id = pa.case_id
    WHERE o.id = $1
      AND pa.id IS NOT NULL;
-- EXECUTE metric_org_assessments_assigned(1);


/* ------------------------------------------------------------------------
   METRIC 22: Org Specific - Assessments Completed Total
   ------------------------------------------------------------------------
   DESCRIPTION: Total completed assessments for this organization
   
   ALGORITHM: COUNT property_assessments WHERE completed AND org = target
   
   BUSINESS VALUE: Assessment completion rate by organization
   ------------------------------------------------------------------------ */
PREPARE metric_org_assessments_completed(INTEGER) AS
    SELECT COUNT(DISTINCT pa.id) AS assessments_completed_total
    FROM coalition_organizations o
    LEFT JOIN application_assignments aa ON o.id = aa.organization_id
    LEFT JOIN cases c ON aa.submission_id = c.submission_id
    LEFT JOIN property_assessments pa ON c.id = pa.case_id
    WHERE o.id = $1
      AND pa.assessment_completed_at IS NOT NULL;
-- EXECUTE metric_org_assessments_completed(1);


/* ------------------------------------------------------------------------
   METRIC 23: Org Specific - Assessments Total Pending
   ------------------------------------------------------------------------
   DESCRIPTION: Assessments assigned but not yet completed
   
   ALGORITHM: assigned_total - completed_total
   
   LOGIC NOTES:
   - Backlog indicator for each organization
   - High pending may indicate need for more assessors
   
   BUSINESS VALUE: Resource allocation and backlog management
   ------------------------------------------------------------------------ */
PREPARE metric_org_assessments_pending(INTEGER) AS
    WITH org_assessments AS (
        SELECT 
            COUNT(DISTINCT pa.id) FILTER (WHERE pa.id IS NOT NULL) AS total_assigned,
            COUNT(DISTINCT pa.id) FILTER (WHERE pa.assessment_completed_at IS NOT NULL) AS total_completed
        FROM coalition_organizations o
        LEFT JOIN application_assignments aa ON o.id = aa.organization_id
        LEFT JOIN cases c ON aa.submission_id = c.submission_id
        LEFT JOIN property_assessments pa ON c.id = pa.case_id
        WHERE o.id = $1
    )
    SELECT (total_assigned - total_completed) AS assessments_pending
    FROM org_assessments;
-- EXECUTE metric_org_assessments_pending(1);


/* ------------------------------------------------------------------------
   METRIC 24: Org Specific - Highest Job Cost
   ------------------------------------------------------------------------
   DESCRIPTION: Most expensive completed job for this organization
   
   ALGORITHM: MAX(total_actual_cost) WHERE org = target AND job completed
   
   BUSINESS VALUE: Understand org's capacity for large projects
   ------------------------------------------------------------------------ */
PREPARE metric_org_highest_job_cost(INTEGER) AS
    SELECT 
        MAX(c.total_actual_cost) AS highest_job_cost,
        c.case_number,
        s.applicant_first_name || ' ' || s.applicant_last_name AS applicant_name
    FROM coalition_organizations o
    JOIN application_assignments aa ON o.id = aa.organization_id
    JOIN cases c ON aa.submission_id = c.submission_id
    JOIN intake_submissions s ON c.submission_id = s.id
    JOIN work_orders wo ON c.id = wo.case_id
    WHERE o.id = $1
      AND wo.status = 'completed'
      AND c.total_actual_cost IS NOT NULL
    GROUP BY c.id, c.case_number, s.applicant_first_name, s.applicant_last_name
    ORDER BY c.total_actual_cost DESC
    LIMIT 1;
-- EXECUTE metric_org_highest_job_cost(1);


/* ------------------------------------------------------------------------
   METRIC 25: Org Specific - Lowest Job Cost
   ------------------------------------------------------------------------
   DESCRIPTION: Least expensive completed job for this organization
   
   ALGORITHM: MIN(total_actual_cost) WHERE org = target AND job completed AND cost > 0
   
   BUSINESS VALUE: Identify small project capabilities
   ------------------------------------------------------------------------ */
PREPARE metric_org_lowest_job_cost(INTEGER) AS
    SELECT 
        MIN(c.total_actual_cost) AS lowest_job_cost,
        c.case_number,
        s.applicant_first_name || ' ' || s.applicant_last_name AS applicant_name
    FROM coalition_organizations o
    JOIN application_assignments aa ON o.id = aa.organization_id
    JOIN cases c ON aa.submission_id = c.submission_id
    JOIN intake_submissions s ON c.submission_id = s.id
    JOIN work_orders wo ON c.id = wo.case_id
    WHERE o.id = $1
      AND wo.status = 'completed'
      AND c.total_actual_cost IS NOT NULL
      AND c.total_actual_cost > 0
    GROUP BY c.id, c.case_number, s.applicant_first_name, s.applicant_last_name
    ORDER BY c.total_actual_cost ASC
    LIMIT 1;
-- EXECUTE metric_org_lowest_job_cost(1);


/* ------------------------------------------------------------------------
   METRIC 26: Org Specific - Average Job Cost
   ------------------------------------------------------------------------
   DESCRIPTION: Average cost of completed jobs for this organization
   
   ALGORITHM: AVG(total_actual_cost) WHERE org = target AND job completed
   
   BUSINESS VALUE: Benchmarking orgs against each other
   ------------------------------------------------------------------------ */
PREPARE metric_org_avg_job_cost(INTEGER) AS
    SELECT 
        ROUND(AVG(c.total_actual_cost), 2) AS avg_job_cost,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY c.total_actual_cost) AS median_job_cost
    FROM coalition_organizations o
    JOIN application_assignments aa ON o.id = aa.organization_id
    JOIN cases c ON aa.submission_id = c.submission_id
    JOIN work_orders wo ON c.id = wo.case_id
    WHERE o.id = $1
      AND wo.status = 'completed'
      AND c.total_actual_cost IS NOT NULL
      AND c.total_actual_cost > 0;
-- EXECUTE metric_org_avg_job_cost(1);


/* ------------------------------------------------------------------------
   METRIC 27: Org Specific - All Jobs Income Breakdown
   ------------------------------------------------------------------------
   DESCRIPTION: Distribution of completed jobs by income bracket for this org
   
   ALGORITHM: Same as Metric 14 but filtered by organization
   
   BUSINESS VALUE: Ensure org is serving appropriate income demographics
   ------------------------------------------------------------------------ */
PREPARE metric_org_income_breakdown(INTEGER) AS
    WITH org_completed_cases AS (
        SELECT DISTINCT c.submission_id
        FROM coalition_organizations o
        JOIN application_assignments aa ON o.id = aa.organization_id
        JOIN cases c ON aa.submission_id = c.submission_id
        JOIN work_orders wo ON c.id = wo.case_id
        WHERE o.id = $1
          AND wo.status = 'completed'
    ),
    income_data AS (
        SELECT 
            CASE 
                WHEN s.has_income = false THEN 0
                ELSE COALESCE(s.gross_annual_income, 0)
            END AS calculated_income
        FROM intake_submissions s
        JOIN org_completed_cases occ ON s.id = occ.submission_id
    )
    SELECT 
        CASE 
            WHEN calculated_income <= 15000 THEN 'Low (0-15k)'
            WHEN calculated_income <= 50000 THEN 'Moderate (15k-50k)'
            ELSE 'Higher (50k+)'
        END AS income_bracket,
        COUNT(*) AS completed_jobs,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
    FROM income_data
    GROUP BY 
        CASE 
            WHEN calculated_income <= 15000 THEN 'Low (0-15k)'
            WHEN calculated_income <= 50000 THEN 'Moderate (15k-50k)'
            ELSE 'Higher (50k+)'
        END;
-- EXECUTE metric_org_income_breakdown(1);


/* ------------------------------------------------------------------------
   METRIC 28: Org Specific - All Jobs County Breakdown
   ------------------------------------------------------------------------
   DESCRIPTION: Distribution of completed jobs by county for this organization
   
   ALGORITHM: Same as Metric 15 but filtered by organization
   
   BUSINESS VALUE: Geographic service area analysis per organization
   ------------------------------------------------------------------------ */
PREPARE metric_org_county_breakdown(INTEGER) AS
    WITH org_completed_cases AS (
        SELECT DISTINCT c.submission_id
        FROM coalition_organizations o
        JOIN application_assignments aa ON o.id = aa.organization_id
        JOIN cases c ON aa.submission_id = c.submission_id
        JOIN work_orders wo ON c.id = wo.case_id
        WHERE o.id = $1
          AND wo.status = 'completed'
    ),
    county_mapping AS (
        SELECT 
            CASE 
                WHEN s.home_city ILIKE '%Asheville%' OR s.home_zip IN ('28801','28803','28804','28805','28806') THEN 'Buncombe'
                WHEN s.home_city ILIKE '%Mars Hill%' OR s.home_city ILIKE '%Marshall%' THEN 'Madison'
                WHEN s.home_city ILIKE '%Hendersonville%' THEN 'Henderson'
                ELSE 'Other'
            END AS county
        FROM intake_submissions s
        JOIN org_completed_cases occ ON s.id = occ.submission_id
    )
    SELECT 
        county,
        COUNT(*) AS completed_jobs,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
    FROM county_mapping
    GROUP BY county
    ORDER BY completed_jobs DESC;
-- EXECUTE metric_org_county_breakdown(1);


-- =====================================================
-- DASHBOARD AGGREGATION FUNCTION
-- =====================================================
-- This function returns ALL metrics in a single call for dashboard display
-- =====================================================

CREATE OR REPLACE FUNCTION get_all_dashboard_metrics(p_organization_id INTEGER DEFAULT NULL)
RETURNS JSONB AS $$
DECLARE
    v_result JSONB;
    v_past_week_start DATE;
    v_past_week_end DATE;
BEGIN
    -- Get date range
    SELECT start_date, end_date INTO v_past_week_start, v_past_week_end FROM get_past_week_range();
    
    -- Build complete dashboard JSON
    SELECT jsonb_build_object(
        -- Section 1: Past Week Metrics
        'past_week', jsonb_build_object(
            'total_applications', (SELECT COUNT(*) FROM intake_submissions WHERE submitted_at::DATE BETWEEN v_past_week_start AND v_past_week_end),
            'assessments_assigned', (SELECT COUNT(*) FROM property_assessments WHERE assigned_at::DATE BETWEEN v_past_week_start AND v_past_week_end),
            'assessments_completed', (SELECT COUNT(*) FROM property_assessments WHERE assessment_completed_at::DATE BETWEEN v_past_week_start AND v_past_week_end),
            'avg_triage_score', (SELECT ROUND(AVG(triage_score), 1) FROM completed_assessments_with_triage WHERE assessment_completed_at::DATE BETWEEN v_past_week_start AND v_past_week_end),
            'total_individuals', (SELECT SUM(household_size) FROM intake_submissions WHERE submitted_at::DATE BETWEEN v_past_week_start AND v_past_week_end),
            'income_breakdown', (SELECT jsonb_agg(jsonb_build_object('bracket', bracket, 'count', count)) FROM metric_income_breakdown_past_week()),
            'county_breakdown', (SELECT jsonb_agg(jsonb_build_object('county', county, 'count', count)) FROM metric_county_breakdown_past_week()),
            'issue_breakdown', (SELECT jsonb_agg(jsonb_build_object('issue', category_label, 'count', count)) FROM metric_issue_type_pie_past_week())
        ),
        -- Section 2: All Time Metrics
        'all_time', jsonb_build_object(
            'total_jobs', (SELECT total_jobs FROM metric_total_jobs_all_time()),
            'jobs_in_progress', (SELECT jobs_in_progress FROM metric_jobs_in_progress_all_time()),
            'jobs_completed', (SELECT jobs_completed FROM metric_jobs_completed_all_time()),
            'avg_job_cost', (SELECT avg_job_cost FROM metric_avg_job_cost_all_time()),
            'highest_job_cost', (SELECT highest_cost FROM metric_extreme_job_costs_all_time()),
            'lowest_job_cost', (SELECT lowest_cost FROM metric_extreme_job_costs_all_time())
        )
    ) INTO v_result;
    
    -- Add org-specific metrics if organization ID provided
    IF p_organization_id IS NOT NULL THEN
        v_result := v_result || jsonb_build_object(
            'organization_specific', jsonb_build_object(
                'total_jobs', (SELECT total_jobs FROM metric_org_total_jobs(p_organization_id)),
                'jobs_in_progress', (SELECT jobs_in_progress FROM metric_org_jobs_in_progress(p_organization_id)),
                'jobs_completed', (SELECT jobs_completed FROM metric_org_jobs_completed(p_organization_id)),
                'jobs_suggested', (SELECT jobs_suggested FROM metric_org_jobs_suggested(p_organization_id)),
                'assessments_assigned', (SELECT assessments_assigned_total FROM metric_org_assessments_assigned(p_organization_id)),
                'assessments_completed', (SELECT assessments_completed_total FROM metric_org_assessments_completed(p_organization_id)),
                'assessments_pending', (SELECT assessments_pending FROM metric_org_assessments_pending(p_organization_id)),
                'avg_job_cost', (SELECT avg_job_cost FROM metric_org_avg_job_cost(p_organization_id)),
                'highest_job_cost', (SELECT highest_job_cost FROM metric_org_highest_job_cost(p_organization_id)),
                'lowest_job_cost', (SELECT lowest_job_cost FROM metric_org_lowest_job_cost(p_organization_id))
            )
        );
    END IF;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Example usage:
-- SELECT get_all_dashboard_metrics();  -- No org filter
-- SELECT get_all_dashboard_metrics(1); -- Filter for organization_id = 1


-- =====================================================
-- METRICS INDEX FOR DEVELOPERS
-- =====================================================
/*
Quick Reference Guide:

SECTION 1: DASHBOARD PAST WEEK (7 metrics)
-------------------------------------------
1. total_applications_past_week      - Metric 1
2. assessments_assigned_past_week    - Metric 2  
3. assessments_completed_past_week   - Metric 3
4. avg_triage_score_past_week        - Metric 4
5. total_individuals_past_week       - Metric 5
6. income_breakdown_past_week        - Metric 6
7. county_breakdown_past_week        - Metric 7
8. issue_type_pie_past_week          - Metric 8

SECTION 2: DASHBOARD ALL TIME (8 metrics)
------------------------------------------
9. total_jobs_all_time               - Metric 9
10. jobs_in_progress_all_time        - Metric 10
11. jobs_completed_all_time          - Metric 11
12. jobs_negative_outcomes_all_time  - Metric 12
13. avg_job_cost_all_time            - Metric 13
14. all_jobs_income_breakdown        - Metric 14
15. all_jobs_county_breakdown        - Metric 15
16. extreme_job_costs_all_time       - Metric 16

SECTION 3: ORGANIZATION SPECIFIC (12 metrics)
-----------------------------------------------
17. org_total_jobs                   - Metric 17
18. org_jobs_in_progress             - Metric 18
19. org_jobs_completed               - Metric 19
20. org_jobs_suggested               - Metric 20
21. org_assessments_assigned         - Metric 21
22. org_assessments_completed        - Metric 22
23. org_assessments_pending          - Metric 23
24. org_highest_job_cost             - Metric 24
25. org_lowest_job_cost              - Metric 25
26. org_avg_job_cost                 - Metric 26
27. org_income_breakdown             - Metric 27
28. org_county_breakdown             - Metric 28

To execute any prepared statement:
EXECUTE metric_name(param_if_needed);

To get all metrics at once:
SELECT get_all_dashboard_metrics();
SELECT get_all_dashboard_metrics(organization_id);
*/