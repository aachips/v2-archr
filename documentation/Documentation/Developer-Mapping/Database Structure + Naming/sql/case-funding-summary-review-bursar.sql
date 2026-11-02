CREATE OR REPLACE VIEW case_funding_summary AS
SELECT 
    c.id AS case_id,
    c.case_number,
    c.submission_id,
    s.applicant_first_name,
    s.applicant_last_name,
    s.assigned_organization,
    -- Funding totals
    COALESCE(SUM(cf.allocated_amount), 0) AS approved_amount,
    COALESCE(SUM(cf.spent_amount), 0) AS incurred_amount,
    COALESCE(SUM(i.total_amount), 0) AS reimbursed_amount,
    COALESCE(SUM(i.total_amount), 0) AS pending_reimbursement,
    -- Calculated fields
    (COALESCE(SUM(cf.allocated_amount), 0) - COALESCE(SUM(i.total_amount), 0)) AS outstanding_balance,
    (COALESCE(SUM(cf.allocated_amount), 0) - COALESCE(SUM(cf.spent_amount), 0)) AS remaining_available,
    -- Flags
    CASE 
        WHEN COALESCE(SUM(cf.allocated_amount), 0) > 50000 THEN 'EXCEEDS_CAP'
        WHEN COALESCE(SUM(cf.allocated_amount), 0) = 50000 THEN 'AT_CAP'
        ELSE 'UNDER_CAP'
    END AS cap_status,
    -- Hold tracking
    CASE 
        WHEN EXISTS (SELECT 1 FROM case_funding WHERE case_id = c.id AND status = 'on_hold') 
        THEN TRUE 
        ELSE FALSE 
    END AS has_hold_amount
FROM cases c
JOIN intake_submissions s ON c.submission_id = s.id
LEFT JOIN case_funding cf ON c.id = cf.case_id
LEFT JOIN invoices i ON c.id = i.case_id AND i.status IN ('pending', 'approved', 'paid')
GROUP BY c.id, c.case_number, s.applicant_first_name, s.applicant_last_name, s.assigned_organization;