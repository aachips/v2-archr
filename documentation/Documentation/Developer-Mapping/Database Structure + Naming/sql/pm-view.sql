-- Project status view (combines all project data)
CREATE OR REPLACE VIEW project_status_view AS
SELECT 
    c.id AS case_id,
    c.case_number,
    c.total_budget AS approved_budget,
    c.total_actual_cost AS current_cost,
    COALESCE(c.total_budget - c.total_actual_cost, 0) AS remaining_budget,
    ROUND(COALESCE(c.total_actual_cost / NULLIF(c.total_budget, 0) * 100, 0), 1) AS budget_used_percentage,
    
    s.applicant_first_name,
    s.applicant_last_name,
    s.home_address,
    s.home_city,
    s.home_zip,
    
    -- Timeline
    wo.scheduled_start_date,
    wo.scheduled_end_date,
    wo.actual_start_date,
    wo.actual_end_date,
    COALESCE(wo.status, 'pending') AS work_order_status,
    CASE 
        WHEN wo.actual_end_date IS NOT NULL THEN 'completed'
        WHEN wo.actual_start_date IS NOT NULL THEN 'in_progress'
        WHEN wo.scheduled_start_date > CURRENT_DATE THEN 'scheduled'
        WHEN wo.scheduled_start_date <= CURRENT_DATE THEN 'overdue'
        ELSE 'pending'
    END AS project_phase,
    
    -- Crew
    pa.crew_lead_id,
    cl.full_name AS crew_lead_name,
    pa.crew_member_ids,
    
    -- Assessment
    ass.total_estimate,
    ass.assessment_date,
    ass.priority_repairs,
    
    -- Alert flags
    CASE WHEN c.total_actual_cost > c.total_budget THEN true ELSE false END AS budget_alert,
    CASE WHEN wo.scheduled_end_date < CURRENT_DATE AND wo.actual_end_date IS NULL THEN true ELSE false END AS schedule_alert,
    CASE WHEN EXISTS (SELECT 1 FROM project_escalations WHERE case_id = c.id AND resolved_at IS NULL AND severity = 'critical') THEN true ELSE false END AS critical_alert,
    CASE WHEN c.total_budget > 50000 THEN true ELSE false END AS cap_alert
    
FROM cases c
JOIN intake_submissions s ON c.submission_id = s.id
LEFT JOIN work_orders wo ON c.id = wo.case_id
LEFT JOIN project_assignments pa ON c.id = pa.case_id
LEFT JOIN system_users cl ON pa.crew_lead_id = cl.id
LEFT JOIN property_assessments ass ON c.id = ass.case_id
WHERE c.status_id NOT IN (SELECT id FROM case_statuses WHERE status_code IN ('COMPLETED', 'DENIED'));

-- Project metrics view (for dashboard KPIs)
CREATE OR REPLACE VIEW project_metrics_view AS
SELECT 
    COUNT(DISTINCT case_id) AS active_projects,
    COALESCE(SUM(total_budget), 0) AS total_budget,
    COALESCE(SUM(total_actual_cost), 0) AS total_spent,
    COALESCE(SUM(total_budget - total_actual_cost), 0) AS total_remaining,
    ROUND(COALESCE(SUM(total_actual_cost) / NULLIF(SUM(total_budget), 0) * 100, 0), 1) AS overall_utilization,
    COUNT(DISTINCT CASE WHEN total_actual_cost > total_budget THEN case_id END) AS over_budget_count,
    COUNT(DISTINCT CASE WHEN scheduled_end_date < CURRENT_DATE AND actual_end_date IS NULL THEN case_id END) AS overdue_count,
    COUNT(DISTINCT CASE WHEN status = 'in_progress' THEN case_id END) AS in_progress_count,
    COUNT(DISTINCT CASE WHEN status = 'completed' THEN case_id END) AS completed_count
FROM project_status_view;