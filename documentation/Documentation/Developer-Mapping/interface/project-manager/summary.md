The Project Manager role varies between office and field visits. It is mostly a hands off office role with periodic client interaction. The Project Manager reports to the Director, or Envoy. This role requires a fairly high technical comfort and in some cases, is directly involved with the platform development. On a given day, the Project Manager must oversee multiple repair projects, coordinate between assessors, crews, and subcontractors, and manage project budgets and timelines. In a given project, the Project Manager must assign work to Crew Leads, Review and approve estimates, and monitor project progress. When there are escalations in a project, the project manager is the first involved. The P.M. also is involved in managing subcontractor relationships.

  

What They Need To See: 

- Active Projects - all projects in progress
    
- Project status - timeline, budget, blockers
    
- Crew assignments - who’s working on what
    
- Budget v Actual - Cost tracking per project
    
- Upcoming Milestones - key dates per project
    
- Risks/Issues - Flagged concerns across projects
    
- Messages - Communications needing response
    

  

What They Need To Create/Update:

- Assign work - Crew leads assignments per project
    
- Review estimates - Approve/modify cost estimates
    
- Approve change orders - scope changes and budget impact
    
- Monitor Progress - Update project status
    
- Project notes - high-level project documentation
    
- Coordinate subcontractors - schedule, assign, approve
    
- Escalations - Flag issues to Envoy/Leadership
    
- Project Closeout - finalize completion documentation
    

  

Who They Interact With:

- Crew lead - Daily coordination & status updates
    
- Assessor - Scope handoff, estimate review
    
- Subcontractors - Scheduling, approvals, payment
    
- Bursar - Budget management and invoicing
    
- Envoy - Reporting, escalations
    
- Caseworker - Client coordination
    
- Homeowner/client - As needed for coordination
    

  

What Would Frustrate Them:

- Can’t see all projects - Missed Deadlines
    
- Poor Budget tracking - cost overruns
    
- No visibility into crew lead progress - can’t manage schedule
    
- Too much manual coordination - wastes time
    
- No subcontractor visibility - delays and poor quality
    
- Duplicate work across projects - wasted resources
    
- Can’t escalate issues easily - problems fester
    

  

If the Project Manager can fulfill their duties successfully: projects are delivered on time, on budget. Crews have what they need. Subcontractors deliver quality, and there are smooth operations. If the Project Manager can’t fulfill what they need to do, there are delays, unhappy clients, cost overruns, crews that are idle, rework, disputes, and chaos across projects.

---

## Key Distinctions

|   |   |   |
|---|---|---|
|Aspect|Project Manager|Crew Lead|
|Focus|Multiple projects|Single site|
|Scope|Full project lifecycle|Daily execution|
|Staff|Manages Crew Leads|Manages Crew Members|
|Budget|Full P&L responsibility|Cost awareness|
|Timeline|Entire project|Daily tasks|
|Client|Periodic contact|Daily contact|

---

## Initial Assumptions to Validate

- Manages 3-10 projects simultaneously    
- Needs both summary view and drill-down    
- Budget tracking is essential    
- Needs to see all active projects    
- Needs to coordinate across roles   
- Needs escalation path    
- Needs subcontractor management    
- Project timeline is critical
- Needs to know about delays immediately

## Success Criteria

| Metric                   | Target                             |
| ------------------------ | ---------------------------------- |
| Project visibility       | All projects visible on one screen |
| Budget tracking          | Real-time % of budget used         |
| Schedule tracking        | 90% of projects on schedule        |
| Crew assignment          | < 24 hours to assign crew          |
| Estimate approval        | < 48 hours from submission         |
| Subcontractor management | All subs visible in queue          |
| Escalation resolution    | < 3 days for critical issues       |


## Schema Mapping

### Existing Tables (Already in System)

|Table|Columns Used|
|---|---|
|`cases`|id, case_number, submission_id, status_id, total_budget, total_actual_cost|
|`intake_submissions`|id, applicant_first_name, applicant_last_name, home_address, home_city, home_zip, assigned_organization|
|`work_orders`|id, case_id, project_manager_id, crew_lead_id, status, approved_budget, current_cost, scheduled_start_date, scheduled_end_date, actual_start_date, actual_end_date|
|`work_tasks`|id, work_order_id, assigned_to_id, task_type, description, status, priority, estimated_hours, actual_hours, due_date, completed_at|
|`property_assessments`|id, case_id, assessor_id, assessment_date, total_estimate, recommended_repairs, priority_repairs|
|`subcontractor_quotes`|id, task_id, subcontractor_id, quote_amount, status, valid_until|
|`system_users`|id, full_name, email, phone|
