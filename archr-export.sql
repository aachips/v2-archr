--
-- PostgreSQL database dump
--

\restrict sy1QOrLSo4Kr3wK3ZZx6J8ygzg28Gaff7EufdBmiWadKjVTuOggFim9Gi4jydbu

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.work_tasks DROP CONSTRAINT IF EXISTS work_tasks_work_order_id_fkey;
ALTER TABLE IF EXISTS ONLY public.work_tasks DROP CONSTRAINT IF EXISTS work_tasks_repair_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.work_tasks DROP CONSTRAINT IF EXISTS work_tasks_estimate_id_fkey;
ALTER TABLE IF EXISTS ONLY public.work_tasks DROP CONSTRAINT IF EXISTS work_tasks_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.work_tasks DROP CONSTRAINT IF EXISTS work_tasks_assigned_to_id_fkey;
ALTER TABLE IF EXISTS ONLY public.work_orders DROP CONSTRAINT IF EXISTS work_orders_project_manager_id_fkey;
ALTER TABLE IF EXISTS ONLY public.work_orders DROP CONSTRAINT IF EXISTS work_orders_crew_lead_id_fkey;
ALTER TABLE IF EXISTS ONLY public.work_orders DROP CONSTRAINT IF EXISTS work_orders_case_id_fkey;
ALTER TABLE IF EXISTS ONLY public.weekly_digests DROP CONSTRAINT IF EXISTS weekly_digests_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.volunteer_skills DROP CONSTRAINT IF EXISTS volunteer_skills_volunteer_id_fkey;
ALTER TABLE IF EXISTS ONLY public.volunteer_skills DROP CONSTRAINT IF EXISTS volunteer_skills_skill_id_fkey;
ALTER TABLE IF EXISTS ONLY public.volunteer_skills DROP CONSTRAINT IF EXISTS volunteer_skills_endorsed_by_fkey;
ALTER TABLE IF EXISTS ONLY public.volunteer_profiles DROP CONSTRAINT IF EXISTS volunteer_profiles_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.volunteer_hours DROP CONSTRAINT IF EXISTS volunteer_hours_work_order_id_fkey;
ALTER TABLE IF EXISTS ONLY public.volunteer_hours DROP CONSTRAINT IF EXISTS volunteer_hours_verified_by_fkey;
ALTER TABLE IF EXISTS ONLY public.volunteer_hours DROP CONSTRAINT IF EXISTS volunteer_hours_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.volunteer_feedback DROP CONSTRAINT IF EXISTS volunteer_feedback_volunteer_id_fkey;
ALTER TABLE IF EXISTS ONLY public.volunteer_feedback DROP CONSTRAINT IF EXISTS volunteer_feedback_quest_id_fkey;
ALTER TABLE IF EXISTS ONLY public.volunteer_feedback DROP CONSTRAINT IF EXISTS volunteer_feedback_beneficiary_id_fkey;
ALTER TABLE IF EXISTS ONLY public.volunteer_content DROP CONSTRAINT IF EXISTS volunteer_content_reviewed_by_fkey;
ALTER TABLE IF EXISTS ONLY public.volunteer_content DROP CONSTRAINT IF EXISTS volunteer_content_author_id_fkey;
ALTER TABLE IF EXISTS ONLY public.volunteer_badges DROP CONSTRAINT IF EXISTS volunteer_badges_volunteer_id_fkey;
ALTER TABLE IF EXISTS ONLY public.volunteer_badges DROP CONSTRAINT IF EXISTS volunteer_badges_badge_id_fkey;
ALTER TABLE IF EXISTS ONLY public.volunteer_badges DROP CONSTRAINT IF EXISTS volunteer_badges_awarded_by_fkey;
ALTER TABLE IF EXISTS ONLY public.user_role_assignments DROP CONSTRAINT IF EXISTS user_role_assignments_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_role_assignments DROP CONSTRAINT IF EXISTS user_role_assignments_role_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_role_assignments DROP CONSTRAINT IF EXISTS user_role_assignments_organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_role_assignments DROP CONSTRAINT IF EXISTS user_role_assignments_assigned_by_fkey;
ALTER TABLE IF EXISTS ONLY public.task_status_history DROP CONSTRAINT IF EXISTS task_status_history_task_id_fkey;
ALTER TABLE IF EXISTS ONLY public.task_status_history DROP CONSTRAINT IF EXISTS task_status_history_changed_by_fkey;
ALTER TABLE IF EXISTS ONLY public.system_users DROP CONSTRAINT IF EXISTS system_users_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY public.system_users DROP CONSTRAINT IF EXISTS system_users_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.support_tickets DROP CONSTRAINT IF EXISTS support_tickets_submitted_by_fkey;
ALTER TABLE IF EXISTS ONLY public.support_tickets DROP CONSTRAINT IF EXISTS support_tickets_resolved_by_fkey;
ALTER TABLE IF EXISTS ONLY public.support_tickets DROP CONSTRAINT IF EXISTS support_tickets_assigned_to_fkey;
ALTER TABLE IF EXISTS ONLY public.submission_repair_categories DROP CONSTRAINT IF EXISTS submission_repair_categories_submission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.submission_repair_categories DROP CONSTRAINT IF EXISTS submission_repair_categories_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.submission_household_attributes DROP CONSTRAINT IF EXISTS submission_household_attributes_submission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.submission_household_attributes DROP CONSTRAINT IF EXISTS submission_household_attributes_attribute_id_fkey;
ALTER TABLE IF EXISTS ONLY public.submission_contact_methods DROP CONSTRAINT IF EXISTS submission_contact_methods_submission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.submission_contact_methods DROP CONSTRAINT IF EXISTS submission_contact_methods_method_id_fkey;
ALTER TABLE IF EXISTS ONLY public.subcontractor_quotes DROP CONSTRAINT IF EXISTS subcontractor_quotes_task_id_fkey;
ALTER TABLE IF EXISTS ONLY public.subcontractor_quotes DROP CONSTRAINT IF EXISTS subcontractor_quotes_subcontractor_id_fkey;
ALTER TABLE IF EXISTS ONLY public.subcontractor_quotes DROP CONSTRAINT IF EXISTS subcontractor_quotes_quote_document_id_fkey;
ALTER TABLE IF EXISTS ONLY public.subcontractor_quotes DROP CONSTRAINT IF EXISTS subcontractor_quotes_approved_by_fkey;
ALTER TABLE IF EXISTS ONLY public.subcontractor_profiles DROP CONSTRAINT IF EXISTS subcontractor_profiles_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.subcontractor_profiles DROP CONSTRAINT IF EXISTS subcontractor_profiles_approved_by_fkey;
ALTER TABLE IF EXISTS ONLY public.subcontractor_invoices DROP CONSTRAINT IF EXISTS subcontractor_invoices_task_id_fkey;
ALTER TABLE IF EXISTS ONLY public.subcontractor_invoices DROP CONSTRAINT IF EXISTS subcontractor_invoices_subcontractor_id_fkey;
ALTER TABLE IF EXISTS ONLY public.subcontractor_invoices DROP CONSTRAINT IF EXISTS subcontractor_invoices_paid_by_fkey;
ALTER TABLE IF EXISTS ONLY public.subcontractor_invoices DROP CONSTRAINT IF EXISTS subcontractor_invoices_invoice_document_id_fkey;
ALTER TABLE IF EXISTS ONLY public.subcontractor_invoices DROP CONSTRAINT IF EXISTS subcontractor_invoices_approved_by_fkey;
ALTER TABLE IF EXISTS ONLY public.subcontractor_communications DROP CONSTRAINT IF EXISTS subcontractor_communications_task_id_fkey;
ALTER TABLE IF EXISTS ONLY public.subcontractor_communications DROP CONSTRAINT IF EXISTS subcontractor_communications_subcontractor_id_fkey;
ALTER TABLE IF EXISTS ONLY public.subcontractor_communications DROP CONSTRAINT IF EXISTS subcontractor_communications_sender_id_fkey;
ALTER TABLE IF EXISTS ONLY public.scope_of_work_line_items DROP CONSTRAINT IF EXISTS scope_of_work_line_items_assessment_id_fkey;
ALTER TABLE IF EXISTS ONLY public.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_role_id_fkey;
ALTER TABLE IF EXISTS ONLY public.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_permission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.review_queue DROP CONSTRAINT IF EXISTS review_queue_submission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.review_queue DROP CONSTRAINT IF EXISTS review_queue_organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.review_queue DROP CONSTRAINT IF EXISTS review_queue_assigned_to_id_fkey;
ALTER TABLE IF EXISTS ONLY public.repair_requests DROP CONSTRAINT IF EXISTS repair_requests_submission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.repair_estimates DROP CONSTRAINT IF EXISTS repair_estimates_repair_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.repair_estimates DROP CONSTRAINT IF EXISTS repair_estimates_assessment_id_fkey;
ALTER TABLE IF EXISTS ONLY public.repair_estimates DROP CONSTRAINT IF EXISTS repair_estimates_approved_by_fkey;
ALTER TABLE IF EXISTS ONLY public.repair_category_details DROP CONSTRAINT IF EXISTS repair_category_details_submission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.repair_category_details DROP CONSTRAINT IF EXISTS repair_category_details_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reimbursement_requests DROP CONSTRAINT IF EXISTS reimbursement_requests_organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reimbursement_requests DROP CONSTRAINT IF EXISTS reimbursement_requests_funding_source_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reimbursement_requests DROP CONSTRAINT IF EXISTS reimbursement_requests_case_id_fkey;
ALTER TABLE IF EXISTS ONLY public.quests DROP CONSTRAINT IF EXISTS quests_work_task_id_fkey;
ALTER TABLE IF EXISTS ONLY public.quests DROP CONSTRAINT IF EXISTS quests_quest_giver_id_fkey;
ALTER TABLE IF EXISTS ONLY public.quests DROP CONSTRAINT IF EXISTS quests_parent_quest_id_fkey;
ALTER TABLE IF EXISTS ONLY public.quests DROP CONSTRAINT IF EXISTS quests_case_id_fkey;
ALTER TABLE IF EXISTS ONLY public.quest_assignments DROP CONSTRAINT IF EXISTS quest_assignments_volunteer_id_fkey;
ALTER TABLE IF EXISTS ONLY public.quest_assignments DROP CONSTRAINT IF EXISTS quest_assignments_verified_by_fkey;
ALTER TABLE IF EXISTS ONLY public.quest_assignments DROP CONSTRAINT IF EXISTS quest_assignments_quest_id_fkey;
ALTER TABLE IF EXISTS ONLY public.property_assessments DROP CONSTRAINT IF EXISTS property_assessments_case_id_fkey;
ALTER TABLE IF EXISTS ONLY public.property_assessments DROP CONSTRAINT IF EXISTS property_assessments_assessor_id_fkey;
ALTER TABLE IF EXISTS ONLY public.project_snapshots DROP CONSTRAINT IF EXISTS project_snapshots_case_id_fkey;
ALTER TABLE IF EXISTS ONLY public.project_milestones DROP CONSTRAINT IF EXISTS project_milestones_case_id_fkey;
ALTER TABLE IF EXISTS ONLY public.project_escalations DROP CONSTRAINT IF EXISTS project_escalations_resolved_by_fkey;
ALTER TABLE IF EXISTS ONLY public.project_escalations DROP CONSTRAINT IF EXISTS project_escalations_raised_by_fkey;
ALTER TABLE IF EXISTS ONLY public.project_escalations DROP CONSTRAINT IF EXISTS project_escalations_case_id_fkey;
ALTER TABLE IF EXISTS ONLY public.project_assignments DROP CONSTRAINT IF EXISTS project_assignments_project_manager_id_fkey;
ALTER TABLE IF EXISTS ONLY public.project_assignments DROP CONSTRAINT IF EXISTS project_assignments_crew_lead_id_fkey;
ALTER TABLE IF EXISTS ONLY public.project_assignments DROP CONSTRAINT IF EXISTS project_assignments_case_id_fkey;
ALTER TABLE IF EXISTS ONLY public.progress_events DROP CONSTRAINT IF EXISTS progress_events_performed_by_fkey;
ALTER TABLE IF EXISTS ONLY public.progress_events DROP CONSTRAINT IF EXISTS progress_events_organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.progress_events DROP CONSTRAINT IF EXISTS progress_events_case_id_fkey;
ALTER TABLE IF EXISTS ONLY public.permissions DROP CONSTRAINT IF EXISTS permissions_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.organization_users DROP CONSTRAINT IF EXISTS organization_users_organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.organization_metrics DROP CONSTRAINT IF EXISTS organization_metrics_organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.organization_eligibility_rules DROP CONSTRAINT IF EXISTS organization_eligibility_rules_organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.organization_eligibility_rules DROP CONSTRAINT IF EXISTS organization_eligibility_rules_criteria_type_id_fkey;
ALTER TABLE IF EXISTS ONLY public.notifications DROP CONSTRAINT IF EXISTS notifications_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.materials_inventory DROP CONSTRAINT IF EXISTS materials_inventory_sow_line_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.material_requests DROP CONSTRAINT IF EXISTS material_requests_task_id_fkey;
ALTER TABLE IF EXISTS ONLY public.material_requests DROP CONSTRAINT IF EXISTS material_requests_requested_by_fkey;
ALTER TABLE IF EXISTS ONLY public.material_requests DROP CONSTRAINT IF EXISTS material_requests_approved_by_fkey;
ALTER TABLE IF EXISTS ONLY public.invoices DROP CONSTRAINT IF EXISTS invoices_paid_by_fkey;
ALTER TABLE IF EXISTS ONLY public.invoices DROP CONSTRAINT IF EXISTS invoices_case_id_fkey;
ALTER TABLE IF EXISTS ONLY public.invoices DROP CONSTRAINT IF EXISTS invoices_approved_by_fkey;
ALTER TABLE IF EXISTS ONLY public.invoice_line_items DROP CONSTRAINT IF EXISTS invoice_line_items_task_id_fkey;
ALTER TABLE IF EXISTS ONLY public.invoice_line_items DROP CONSTRAINT IF EXISTS invoice_line_items_invoice_id_fkey;
ALTER TABLE IF EXISTS ONLY public.intake_submissions DROP CONSTRAINT IF EXISTS intake_submissions_requestor_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.intake_submissions DROP CONSTRAINT IF EXISTS intake_submissions_deduplicated_into_fkey;
ALTER TABLE IF EXISTS ONLY public.income_records DROP CONSTRAINT IF EXISTS income_records_submission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.help_user_progress DROP CONSTRAINT IF EXISTS help_user_progress_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.help_user_progress DROP CONSTRAINT IF EXISTS help_user_progress_document_id_fkey;
ALTER TABLE IF EXISTS ONLY public.help_search_log DROP CONSTRAINT IF EXISTS help_search_log_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.help_search_log DROP CONSTRAINT IF EXISTS help_search_log_clicked_document_id_fkey;
ALTER TABLE IF EXISTS ONLY public.help_documents DROP CONSTRAINT IF EXISTS help_documents_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY public.help_documents DROP CONSTRAINT IF EXISTS help_documents_reviewer_id_fkey;
ALTER TABLE IF EXISTS ONLY public.help_documents DROP CONSTRAINT IF EXISTS help_documents_reviewed_by_fkey;
ALTER TABLE IF EXISTS ONLY public.help_documents DROP CONSTRAINT IF EXISTS help_documents_previous_version_id_fkey;
ALTER TABLE IF EXISTS ONLY public.help_documents DROP CONSTRAINT IF EXISTS help_documents_owner_role_id_fkey;
ALTER TABLE IF EXISTS ONLY public.help_documents DROP CONSTRAINT IF EXISTS help_documents_original_document_id_fkey;
ALTER TABLE IF EXISTS ONLY public.help_documents DROP CONSTRAINT IF EXISTS help_documents_doc_type_id_fkey;
ALTER TABLE IF EXISTS ONLY public.help_documents DROP CONSTRAINT IF EXISTS help_documents_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.help_documents DROP CONSTRAINT IF EXISTS help_documents_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.help_documents DROP CONSTRAINT IF EXISTS help_documents_archived_by_fkey;
ALTER TABLE IF EXISTS ONLY public.help_document_versions DROP CONSTRAINT IF EXISTS help_document_versions_document_id_fkey;
ALTER TABLE IF EXISTS ONLY public.help_document_versions DROP CONSTRAINT IF EXISTS help_document_versions_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.help_document_reviews DROP CONSTRAINT IF EXISTS help_document_reviews_reviewer_id_fkey;
ALTER TABLE IF EXISTS ONLY public.help_document_reviews DROP CONSTRAINT IF EXISTS help_document_reviews_document_id_fkey;
ALTER TABLE IF EXISTS ONLY public.help_document_feedback DROP CONSTRAINT IF EXISTS help_document_feedback_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.help_document_feedback DROP CONSTRAINT IF EXISTS help_document_feedback_document_id_fkey;
ALTER TABLE IF EXISTS ONLY public.help_document_attachments DROP CONSTRAINT IF EXISTS help_document_attachments_uploaded_by_fkey;
ALTER TABLE IF EXISTS ONLY public.help_document_attachments DROP CONSTRAINT IF EXISTS help_document_attachments_document_id_fkey;
ALTER TABLE IF EXISTS ONLY public.help_categories DROP CONSTRAINT IF EXISTS help_categories_parent_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.guest_access_tokens DROP CONSTRAINT IF EXISTS guest_access_tokens_submission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.funding_sources DROP CONSTRAINT IF EXISTS funding_sources_organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.eligibility_results DROP CONSTRAINT IF EXISTS eligibility_results_submission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.eligibility_results DROP CONSTRAINT IF EXISTS eligibility_results_organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.edit_requests DROP CONSTRAINT IF EXISTS edit_requests_reviewed_by_fkey;
ALTER TABLE IF EXISTS ONLY public.edit_requests DROP CONSTRAINT IF EXISTS edit_requests_requested_by_fkey;
ALTER TABLE IF EXISTS ONLY public.edit_requests DROP CONSTRAINT IF EXISTS edit_requests_case_id_fkey;
ALTER TABLE IF EXISTS ONLY public.document_verifications DROP CONSTRAINT IF EXISTS document_verifications_verified_by_fkey;
ALTER TABLE IF EXISTS ONLY public.document_verifications DROP CONSTRAINT IF EXISTS document_verifications_document_id_fkey;
ALTER TABLE IF EXISTS ONLY public.document_verifications DROP CONSTRAINT IF EXISTS document_verifications_case_id_fkey;
ALTER TABLE IF EXISTS ONLY public.document_templates DROP CONSTRAINT IF EXISTS document_templates_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.document_share_links DROP CONSTRAINT IF EXISTS document_share_links_shared_by_fkey;
ALTER TABLE IF EXISTS ONLY public.document_share_links DROP CONSTRAINT IF EXISTS document_share_links_document_id_fkey;
ALTER TABLE IF EXISTS ONLY public.document_generation_jobs DROP CONSTRAINT IF EXISTS document_generation_jobs_template_id_fkey;
ALTER TABLE IF EXISTS ONLY public.document_generation_jobs DROP CONSTRAINT IF EXISTS document_generation_jobs_output_document_id_fkey;
ALTER TABLE IF EXISTS ONLY public.document_generation_jobs DROP CONSTRAINT IF EXISTS document_generation_jobs_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.document_generation_jobs DROP CONSTRAINT IF EXISTS document_generation_jobs_case_id_fkey;
ALTER TABLE IF EXISTS ONLY public.document_categories DROP CONSTRAINT IF EXISTS document_categories_parent_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.document_access_log DROP CONSTRAINT IF EXISTS document_access_log_document_id_fkey;
ALTER TABLE IF EXISTS ONLY public.document_access_log DROP CONSTRAINT IF EXISTS document_access_log_accessed_by_fkey;
ALTER TABLE IF EXISTS ONLY public.crew_volunteer_signin DROP CONSTRAINT IF EXISTS crew_volunteer_signin_volunteer_id_fkey;
ALTER TABLE IF EXISTS ONLY public.crew_volunteer_signin DROP CONSTRAINT IF EXISTS crew_volunteer_signin_verified_by_fkey;
ALTER TABLE IF EXISTS ONLY public.crew_volunteer_signin DROP CONSTRAINT IF EXISTS crew_volunteer_signin_job_id_fkey;
ALTER TABLE IF EXISTS ONLY public.crew_job_cards DROP CONSTRAINT IF EXISTS crew_job_cards_crew_lead_id_fkey;
ALTER TABLE IF EXISTS ONLY public.crew_job_cards DROP CONSTRAINT IF EXISTS crew_job_cards_case_id_fkey;
ALTER TABLE IF EXISTS ONLY public.crew_incident_reports DROP CONSTRAINT IF EXISTS crew_incident_reports_resolved_by_fkey;
ALTER TABLE IF EXISTS ONLY public.crew_incident_reports DROP CONSTRAINT IF EXISTS crew_incident_reports_reported_by_fkey;
ALTER TABLE IF EXISTS ONLY public.crew_incident_reports DROP CONSTRAINT IF EXISTS crew_incident_reports_job_id_fkey;
ALTER TABLE IF EXISTS ONLY public.crew_daily_logs DROP CONSTRAINT IF EXISTS crew_daily_logs_verified_by_fkey;
ALTER TABLE IF EXISTS ONLY public.crew_daily_logs DROP CONSTRAINT IF EXISTS crew_daily_logs_job_id_fkey;
ALTER TABLE IF EXISTS ONLY public.crew_daily_logs DROP CONSTRAINT IF EXISTS crew_daily_logs_crew_lead_id_fkey;
ALTER TABLE IF EXISTS ONLY public.crew_completion_documents DROP CONSTRAINT IF EXISTS crew_completion_documents_verified_by_fkey;
ALTER TABLE IF EXISTS ONLY public.crew_completion_documents DROP CONSTRAINT IF EXISTS crew_completion_documents_job_id_fkey;
ALTER TABLE IF EXISTS ONLY public.content_reads DROP CONSTRAINT IF EXISTS content_reads_volunteer_id_fkey;
ALTER TABLE IF EXISTS ONLY public.content_reads DROP CONSTRAINT IF EXISTS content_reads_content_id_fkey;
ALTER TABLE IF EXISTS ONLY public.cases DROP CONSTRAINT IF EXISTS cases_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY public.cases DROP CONSTRAINT IF EXISTS cases_submission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.cases DROP CONSTRAINT IF EXISTS cases_status_id_fkey;
ALTER TABLE IF EXISTS ONLY public.cases DROP CONSTRAINT IF EXISTS cases_organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.cases DROP CONSTRAINT IF EXISTS cases_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.cases DROP CONSTRAINT IF EXISTS cases_claimed_by_fkey;
ALTER TABLE IF EXISTS ONLY public.cases DROP CONSTRAINT IF EXISTS cases_assigned_project_manager_id_fkey;
ALTER TABLE IF EXISTS ONLY public.cases DROP CONSTRAINT IF EXISTS cases_assigned_caseworker_id_fkey;
ALTER TABLE IF EXISTS ONLY public.cases DROP CONSTRAINT IF EXISTS cases_assigned_assessor_id_fkey;
ALTER TABLE IF EXISTS ONLY public.cases DROP CONSTRAINT IF EXISTS cases_application_id_fkey;
ALTER TABLE IF EXISTS ONLY public.case_withdrawals DROP CONSTRAINT IF EXISTS case_withdrawals_withdrawn_by_fkey;
ALTER TABLE IF EXISTS ONLY public.case_withdrawals DROP CONSTRAINT IF EXISTS case_withdrawals_case_id_fkey;
ALTER TABLE IF EXISTS ONLY public.case_status_history DROP CONSTRAINT IF EXISTS case_status_history_to_status_id_fkey;
ALTER TABLE IF EXISTS ONLY public.case_status_history DROP CONSTRAINT IF EXISTS case_status_history_from_status_id_fkey;
ALTER TABLE IF EXISTS ONLY public.case_status_history DROP CONSTRAINT IF EXISTS case_status_history_changed_by_fkey;
ALTER TABLE IF EXISTS ONLY public.case_status_history DROP CONSTRAINT IF EXISTS case_status_history_case_id_fkey;
ALTER TABLE IF EXISTS ONLY public.case_repair_claims DROP CONSTRAINT IF EXISTS case_repair_claims_repair_request_id_fkey;
ALTER TABLE IF EXISTS ONLY public.case_repair_claims DROP CONSTRAINT IF EXISTS case_repair_claims_released_by_fkey;
ALTER TABLE IF EXISTS ONLY public.case_repair_claims DROP CONSTRAINT IF EXISTS case_repair_claims_organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.case_repair_claims DROP CONSTRAINT IF EXISTS case_repair_claims_claimed_by_fkey;
ALTER TABLE IF EXISTS ONLY public.case_repair_claims DROP CONSTRAINT IF EXISTS case_repair_claims_case_id_fkey;
ALTER TABLE IF EXISTS ONLY public.case_funding DROP CONSTRAINT IF EXISTS case_funding_funding_source_id_fkey;
ALTER TABLE IF EXISTS ONLY public.case_funding DROP CONSTRAINT IF EXISTS case_funding_case_id_fkey;
ALTER TABLE IF EXISTS ONLY public.case_funding DROP CONSTRAINT IF EXISTS case_funding_allocated_by_fkey;
ALTER TABLE IF EXISTS ONLY public.case_documents DROP CONSTRAINT IF EXISTS case_documents_verified_by_fkey;
ALTER TABLE IF EXISTS ONLY public.case_documents DROP CONSTRAINT IF EXISTS case_documents_uploaded_by_fkey;
ALTER TABLE IF EXISTS ONLY public.case_documents DROP CONSTRAINT IF EXISTS case_documents_status_id_fkey;
ALTER TABLE IF EXISTS ONLY public.case_documents DROP CONSTRAINT IF EXISTS case_documents_parent_document_id_fkey;
ALTER TABLE IF EXISTS ONLY public.case_documents DROP CONSTRAINT IF EXISTS case_documents_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.case_documents DROP CONSTRAINT IF EXISTS case_documents_case_id_fkey;
ALTER TABLE IF EXISTS ONLY public.case_communications DROP CONSTRAINT IF EXISTS case_communications_to_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.case_communications DROP CONSTRAINT IF EXISTS case_communications_from_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.case_communications DROP CONSTRAINT IF EXISTS case_communications_case_id_fkey;
ALTER TABLE IF EXISTS ONLY public.case_claims DROP CONSTRAINT IF EXISTS case_claims_claimed_by_org_id_fkey;
ALTER TABLE IF EXISTS ONLY public.case_claims DROP CONSTRAINT IF EXISTS case_claims_case_id_fkey;
ALTER TABLE IF EXISTS ONLY public.blocked_ips DROP CONSTRAINT IF EXISTS blocked_ips_blocked_by_fkey;
ALTER TABLE IF EXISTS ONLY public.beneficiary_feedback DROP CONSTRAINT IF EXISTS beneficiary_feedback_volunteer_id_fkey;
ALTER TABLE IF EXISTS ONLY public.beneficiary_feedback DROP CONSTRAINT IF EXISTS beneficiary_feedback_quest_id_fkey;
ALTER TABLE IF EXISTS ONLY public.beneficiary_feedback DROP CONSTRAINT IF EXISTS beneficiary_feedback_beneficiary_id_fkey;
ALTER TABLE IF EXISTS ONLY public.audit_log DROP CONSTRAINT IF EXISTS audit_log_submission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.assignment_log DROP CONSTRAINT IF EXISTS assignment_log_performed_by_fkey;
ALTER TABLE IF EXISTS ONLY public.assignment_log DROP CONSTRAINT IF EXISTS assignment_log_assignment_id_fkey;
ALTER TABLE IF EXISTS ONLY public.assessments DROP CONSTRAINT IF EXISTS assessments_case_id_fkey;
ALTER TABLE IF EXISTS ONLY public.assessments DROP CONSTRAINT IF EXISTS assessments_assessor_id_fkey;
ALTER TABLE IF EXISTS ONLY public.assessment_tasks DROP CONSTRAINT IF EXISTS assessment_tasks_parent_task_id_fkey;
ALTER TABLE IF EXISTS ONLY public.assessment_tasks DROP CONSTRAINT IF EXISTS assessment_tasks_assessment_id_fkey;
ALTER TABLE IF EXISTS ONLY public.assessment_notes DROP CONSTRAINT IF EXISTS assessment_notes_author_id_fkey;
ALTER TABLE IF EXISTS ONLY public.assessment_notes DROP CONSTRAINT IF EXISTS assessment_notes_assessment_id_fkey;
ALTER TABLE IF EXISTS ONLY public.assessment_documents DROP CONSTRAINT IF EXISTS assessment_documents_uploaded_by_fkey;
ALTER TABLE IF EXISTS ONLY public.assessment_documents DROP CONSTRAINT IF EXISTS assessment_documents_assessment_id_fkey;
ALTER TABLE IF EXISTS ONLY public.applications DROP CONSTRAINT IF EXISTS applications_consolidated_by_fkey;
ALTER TABLE IF EXISTS ONLY public.application_assignments DROP CONSTRAINT IF EXISTS application_assignments_submission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.application_assignments DROP CONSTRAINT IF EXISTS application_assignments_rejected_by_fkey;
ALTER TABLE IF EXISTS ONLY public.application_assignments DROP CONSTRAINT IF EXISTS application_assignments_organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.application_assignments DROP CONSTRAINT IF EXISTS application_assignments_claimed_by_fkey;
ALTER TABLE IF EXISTS ONLY public.application_anchor DROP CONSTRAINT IF EXISTS application_anchor_submission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.activity_log DROP CONSTRAINT IF EXISTS activity_log_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.activity_log DROP CONSTRAINT IF EXISTS activity_log_organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.activity_log DROP CONSTRAINT IF EXISTS activity_log_case_id_fkey;
ALTER TABLE IF EXISTS ONLY public.activity_log DROP CONSTRAINT IF EXISTS activity_log_application_id_fkey;
ALTER TABLE IF EXISTS ONLY public.activity_detail DROP CONSTRAINT IF EXISTS activity_detail_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.activity_detail DROP CONSTRAINT IF EXISTS activity_detail_ledger_id_fkey;
ALTER TABLE IF EXISTS ONLY public.activity_detail DROP CONSTRAINT IF EXISTS activity_detail_case_id_fkey;
ALTER TABLE IF EXISTS ONLY public.activity_detail DROP CONSTRAINT IF EXISTS activity_detail_application_id_fkey;
DROP TRIGGER IF EXISTS trigger_version_help_document ON public.help_documents;
DROP TRIGGER IF EXISTS trigger_reimbursement_id ON public.reimbursement_requests;
DROP TRIGGER IF EXISTS trigger_new_submission ON public.intake_submissions;
DROP TRIGGER IF EXISTS trigger_help_doc_timestamp ON public.help_documents;
DROP TRIGGER IF EXISTS trigger_case_timestamp ON public.cases;
DROP TRIGGER IF EXISTS trigger_case_number ON public.cases;
DROP TRIGGER IF EXISTS trigger_anchor_id ON public.application_anchor;
CREATE OR REPLACE VIEW public.case_funding_summary AS
SELECT
    NULL::integer AS case_id,
    NULL::character varying(50) AS case_number,
    NULL::integer AS submission_id,
    NULL::character varying(100) AS applicant_first_name,
    NULL::character varying(100) AS applicant_last_name,
    NULL::character varying(100) AS assigned_organization,
    NULL::numeric AS approved_amount,
    NULL::numeric AS incurred_amount,
    NULL::numeric AS reimbursed_amount,
    NULL::numeric AS pending_reimbursement,
    NULL::numeric AS outstanding_balance,
    NULL::numeric AS remaining_available,
    NULL::text AS cap_status,
    NULL::boolean AS has_hold_amount;
DROP INDEX IF EXISTS public.uq_cases_app_org;
DROP INDEX IF EXISTS public.uq_case_repair_claims_active;
DROP INDEX IF EXISTS public.idx_volunteer_signin_volunteer;
DROP INDEX IF EXISTS public.idx_volunteer_signin_job;
DROP INDEX IF EXISTS public.idx_verifications_status;
DROP INDEX IF EXISTS public.idx_verifications_case;
DROP INDEX IF EXISTS public.idx_user_role_org_unique;
DROP INDEX IF EXISTS public.idx_user_role_null_org_unique;
DROP INDEX IF EXISTS public.idx_system_users_username;
DROP INDEX IF EXISTS public.idx_subcontractor_trade;
DROP INDEX IF EXISTS public.idx_subcontractor_active;
DROP INDEX IF EXISTS public.idx_status_task;
DROP INDEX IF EXISTS public.idx_status_changed;
DROP INDEX IF EXISTS public.idx_sow_line_items_status;
DROP INDEX IF EXISTS public.idx_sow_line_items_repair_need;
DROP INDEX IF EXISTS public.idx_sow_line_items_assessment;
DROP INDEX IF EXISTS public.idx_snapshots_date;
DROP INDEX IF EXISTS public.idx_snapshots_case;
DROP INDEX IF EXISTS public.idx_site_photos_repair_need;
DROP INDEX IF EXISTS public.idx_site_photos_assessment;
DROP INDEX IF EXISTS public.idx_repair_requests_submission_id;
DROP INDEX IF EXISTS public.idx_repair_category_details_submission_id;
DROP INDEX IF EXISTS public.idx_reimbursement_status;
DROP INDEX IF EXISTS public.idx_reimbursement_org;
DROP INDEX IF EXISTS public.idx_reimbursement_case;
DROP INDEX IF EXISTS public.idx_quotes_task;
DROP INDEX IF EXISTS public.idx_quotes_status;
DROP INDEX IF EXISTS public.idx_queue_status;
DROP INDEX IF EXISTS public.idx_queue_order;
DROP INDEX IF EXISTS public.idx_quests_status_expires;
DROP INDEX IF EXISTS public.idx_quests_skills;
DROP INDEX IF EXISTS public.idx_quests_location;
DROP INDEX IF EXISTS public.idx_project_assignments_pm;
DROP INDEX IF EXISTS public.idx_project_assignments_case;
DROP INDEX IF EXISTS public.idx_progress_events_type;
DROP INDEX IF EXISTS public.idx_progress_events_performed;
DROP INDEX IF EXISTS public.idx_progress_events_org;
DROP INDEX IF EXISTS public.idx_progress_events_case;
DROP INDEX IF EXISTS public.idx_notifications_user;
DROP INDEX IF EXISTS public.idx_milestones_complete;
DROP INDEX IF EXISTS public.idx_milestones_case;
DROP INDEX IF EXISTS public.idx_materials_sow;
DROP INDEX IF EXISTS public.idx_match_scores_submission;
DROP INDEX IF EXISTS public.idx_match_scores_score;
DROP INDEX IF EXISTS public.idx_match_scores_organization;
DROP INDEX IF EXISTS public.idx_login_attempts_ip_time;
DROP INDEX IF EXISTS public.idx_invoices_task;
DROP INDEX IF EXISTS public.idx_invoices_status;
DROP INDEX IF EXISTS public.idx_intake_submissions_submitted_at;
DROP INDEX IF EXISTS public.idx_intake_submissions_status;
DROP INDEX IF EXISTS public.idx_intake_submissions_requestor_user_id;
DROP INDEX IF EXISTS public.idx_intake_submissions_placecode;
DROP INDEX IF EXISTS public.idx_intake_submissions_helene_related;
DROP INDEX IF EXISTS public.idx_intake_submissions_has_income;
DROP INDEX IF EXISTS public.idx_intake_submissions_deduplicated_into;
DROP INDEX IF EXISTS public.idx_income_records_submission_id;
DROP INDEX IF EXISTS public.idx_incident_job;
DROP INDEX IF EXISTS public.idx_incident_date;
DROP INDEX IF EXISTS public.idx_feedback_volunteer;
DROP INDEX IF EXISTS public.idx_escalations_severity;
DROP INDEX IF EXISTS public.idx_escalations_resolved;
DROP INDEX IF EXISTS public.idx_escalations_case;
DROP INDEX IF EXISTS public.idx_eligibility_results_submission;
DROP INDEX IF EXISTS public.idx_eligibility_results_org;
DROP INDEX IF EXISTS public.idx_daily_logs_job;
DROP INDEX IF EXISTS public.idx_daily_logs_date;
DROP INDEX IF EXISTS public.idx_crew_jobs_status;
DROP INDEX IF EXISTS public.idx_crew_jobs_lead;
DROP INDEX IF EXISTS public.idx_crew_jobs_current;
DROP INDEX IF EXISTS public.idx_content_tags;
DROP INDEX IF EXISTS public.idx_content_published;
DROP INDEX IF EXISTS public.idx_completion_job;
DROP INDEX IF EXISTS public.idx_comm_task;
DROP INDEX IF EXISTS public.idx_comm_subcontractor;
DROP INDEX IF EXISTS public.idx_cases_unclaimed_app;
DROP INDEX IF EXISTS public.idx_cases_organization;
DROP INDEX IF EXISTS public.idx_cases_last_progress;
DROP INDEX IF EXISTS public.idx_cases_claim_expires;
DROP INDEX IF EXISTS public.idx_cases_application;
DROP INDEX IF EXISTS public.idx_case_withdrawals_case;
DROP INDEX IF EXISTS public.idx_case_repair_claims_org;
DROP INDEX IF EXISTS public.idx_case_repair_claims_case;
DROP INDEX IF EXISTS public.idx_blocked_ips_active;
DROP INDEX IF EXISTS public.idx_assignments_volunteer;
DROP INDEX IF EXISTS public.idx_assessments_status;
DROP INDEX IF EXISTS public.idx_assessments_org;
DROP INDEX IF EXISTS public.idx_assessments_date;
DROP INDEX IF EXISTS public.idx_assessments_claim_number;
DROP INDEX IF EXISTS public.idx_assessments_assessor;
DROP INDEX IF EXISTS public.idx_assessments_application;
DROP INDEX IF EXISTS public.idx_assessment_docs_assessment;
DROP INDEX IF EXISTS public.idx_applications_zip;
DROP INDEX IF EXISTS public.idx_applications_status;
DROP INDEX IF EXISTS public.idx_applications_placecode;
DROP INDEX IF EXISTS public.idx_applications_last_activity;
DROP INDEX IF EXISTS public.idx_activity_log_user;
DROP INDEX IF EXISTS public.idx_activity_log_created;
DROP INDEX IF EXISTS public.idx_activity_log_category;
DROP INDEX IF EXISTS public.idx_activity_log_case;
DROP INDEX IF EXISTS public.idx_activity_log_application;
DROP INDEX IF EXISTS public.idx_activity_log_action;
DROP INDEX IF EXISTS public.idx_activity_detail_session;
DROP INDEX IF EXISTS public.idx_activity_detail_ledger;
DROP INDEX IF EXISTS public.idx_activity_detail_expires;
DROP INDEX IF EXISTS public.idx_activity_detail_created;
ALTER TABLE IF EXISTS ONLY public.work_tasks DROP CONSTRAINT IF EXISTS work_tasks_pkey;
ALTER TABLE IF EXISTS ONLY public.work_orders DROP CONSTRAINT IF EXISTS work_orders_work_order_number_key;
ALTER TABLE IF EXISTS ONLY public.work_orders DROP CONSTRAINT IF EXISTS work_orders_pkey;
ALTER TABLE IF EXISTS ONLY public.weekly_digests DROP CONSTRAINT IF EXISTS weekly_digests_pkey;
ALTER TABLE IF EXISTS ONLY public.weekly_digests DROP CONSTRAINT IF EXISTS weekly_digests_digest_week_key;
ALTER TABLE IF EXISTS ONLY public.volunteer_skills DROP CONSTRAINT IF EXISTS volunteer_skills_volunteer_id_skill_id_key;
ALTER TABLE IF EXISTS ONLY public.volunteer_skills DROP CONSTRAINT IF EXISTS volunteer_skills_pkey;
ALTER TABLE IF EXISTS ONLY public.volunteer_profiles DROP CONSTRAINT IF EXISTS volunteer_profiles_user_id_key;
ALTER TABLE IF EXISTS ONLY public.volunteer_profiles DROP CONSTRAINT IF EXISTS volunteer_profiles_pkey;
ALTER TABLE IF EXISTS ONLY public.volunteer_hours DROP CONSTRAINT IF EXISTS volunteer_hours_pkey;
ALTER TABLE IF EXISTS ONLY public.volunteer_feedback DROP CONSTRAINT IF EXISTS volunteer_feedback_quest_id_volunteer_id_beneficiary_id_key;
ALTER TABLE IF EXISTS ONLY public.volunteer_feedback DROP CONSTRAINT IF EXISTS volunteer_feedback_pkey;
ALTER TABLE IF EXISTS ONLY public.volunteer_content DROP CONSTRAINT IF EXISTS volunteer_content_pkey;
ALTER TABLE IF EXISTS ONLY public.volunteer_content DROP CONSTRAINT IF EXISTS volunteer_content_content_id_key;
ALTER TABLE IF EXISTS ONLY public.volunteer_badges DROP CONSTRAINT IF EXISTS volunteer_badges_volunteer_id_badge_id_key;
ALTER TABLE IF EXISTS ONLY public.volunteer_badges DROP CONSTRAINT IF EXISTS volunteer_badges_pkey;
ALTER TABLE IF EXISTS ONLY public.user_role_assignments DROP CONSTRAINT IF EXISTS user_role_assignments_pkey;
ALTER TABLE IF EXISTS ONLY public.activity_log DROP CONSTRAINT IF EXISTS uq_activity_log_prev_hash;
ALTER TABLE IF EXISTS ONLY public.activity_detail DROP CONSTRAINT IF EXISTS uq_activity_detail_prev_hash;
ALTER TABLE IF EXISTS ONLY public.task_status_history DROP CONSTRAINT IF EXISTS task_status_history_pkey;
ALTER TABLE IF EXISTS ONLY public.system_users DROP CONSTRAINT IF EXISTS system_users_username_key;
ALTER TABLE IF EXISTS ONLY public.system_users DROP CONSTRAINT IF EXISTS system_users_pkey;
ALTER TABLE IF EXISTS ONLY public.system_users DROP CONSTRAINT IF EXISTS system_users_email_key;
ALTER TABLE IF EXISTS ONLY public.support_tickets DROP CONSTRAINT IF EXISTS support_tickets_pkey;
ALTER TABLE IF EXISTS ONLY public.submission_repair_categories DROP CONSTRAINT IF EXISTS submission_repair_categories_pkey;
ALTER TABLE IF EXISTS ONLY public.submission_household_attributes DROP CONSTRAINT IF EXISTS submission_household_attributes_pkey;
ALTER TABLE IF EXISTS ONLY public.submission_contact_methods DROP CONSTRAINT IF EXISTS submission_contact_methods_pkey;
ALTER TABLE IF EXISTS ONLY public.subcontractor_quotes DROP CONSTRAINT IF EXISTS subcontractor_quotes_pkey;
ALTER TABLE IF EXISTS ONLY public.subcontractor_profiles DROP CONSTRAINT IF EXISTS subcontractor_profiles_user_id_key;
ALTER TABLE IF EXISTS ONLY public.subcontractor_profiles DROP CONSTRAINT IF EXISTS subcontractor_profiles_pkey;
ALTER TABLE IF EXISTS ONLY public.subcontractor_invoices DROP CONSTRAINT IF EXISTS subcontractor_invoices_pkey;
ALTER TABLE IF EXISTS ONLY public.subcontractor_communications DROP CONSTRAINT IF EXISTS subcontractor_communications_pkey;
ALTER TABLE IF EXISTS ONLY public.storage_providers DROP CONSTRAINT IF EXISTS storage_providers_provider_name_key;
ALTER TABLE IF EXISTS ONLY public.storage_providers DROP CONSTRAINT IF EXISTS storage_providers_pkey;
ALTER TABLE IF EXISTS ONLY public.skills DROP CONSTRAINT IF EXISTS skills_skill_code_key;
ALTER TABLE IF EXISTS ONLY public.skills DROP CONSTRAINT IF EXISTS skills_pkey;
ALTER TABLE IF EXISTS ONLY public.site_photos DROP CONSTRAINT IF EXISTS site_photos_pkey;
ALTER TABLE IF EXISTS ONLY public.scope_of_work_line_items DROP CONSTRAINT IF EXISTS scope_of_work_line_items_pkey;
ALTER TABLE IF EXISTS ONLY public.roles DROP CONSTRAINT IF EXISTS roles_role_code_key;
ALTER TABLE IF EXISTS ONLY public.roles DROP CONSTRAINT IF EXISTS roles_pkey;
ALTER TABLE IF EXISTS ONLY public.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_role_id_permission_id_key;
ALTER TABLE IF EXISTS ONLY public.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_pkey;
ALTER TABLE IF EXISTS ONLY public.review_queue DROP CONSTRAINT IF EXISTS review_queue_submission_id_key;
ALTER TABLE IF EXISTS ONLY public.review_queue DROP CONSTRAINT IF EXISTS review_queue_pkey;
ALTER TABLE IF EXISTS ONLY public.repair_requests DROP CONSTRAINT IF EXISTS repair_requests_pkey;
ALTER TABLE IF EXISTS ONLY public.repair_estimates DROP CONSTRAINT IF EXISTS repair_estimates_pkey;
ALTER TABLE IF EXISTS ONLY public.repair_category_details DROP CONSTRAINT IF EXISTS repair_category_details_submission_id_category_id_key;
ALTER TABLE IF EXISTS ONLY public.repair_category_details DROP CONSTRAINT IF EXISTS repair_category_details_pkey;
ALTER TABLE IF EXISTS ONLY public.repair_categories DROP CONSTRAINT IF EXISTS repair_categories_pkey;
ALTER TABLE IF EXISTS ONLY public.repair_categories DROP CONSTRAINT IF EXISTS repair_categories_category_code_key;
ALTER TABLE IF EXISTS ONLY public.reimbursement_requests DROP CONSTRAINT IF EXISTS reimbursement_requests_pkey;
ALTER TABLE IF EXISTS ONLY public.quests DROP CONSTRAINT IF EXISTS quests_quest_number_key;
ALTER TABLE IF EXISTS ONLY public.quests DROP CONSTRAINT IF EXISTS quests_pkey;
ALTER TABLE IF EXISTS ONLY public.quest_assignments DROP CONSTRAINT IF EXISTS quest_assignments_quest_id_volunteer_id_key;
ALTER TABLE IF EXISTS ONLY public.quest_assignments DROP CONSTRAINT IF EXISTS quest_assignments_pkey;
ALTER TABLE IF EXISTS ONLY public.property_assessments DROP CONSTRAINT IF EXISTS property_assessments_pkey;
ALTER TABLE IF EXISTS ONLY public.project_snapshots DROP CONSTRAINT IF EXISTS project_snapshots_snapshot_date_case_id_key;
ALTER TABLE IF EXISTS ONLY public.project_snapshots DROP CONSTRAINT IF EXISTS project_snapshots_pkey;
ALTER TABLE IF EXISTS ONLY public.project_milestones DROP CONSTRAINT IF EXISTS project_milestones_pkey;
ALTER TABLE IF EXISTS ONLY public.project_escalations DROP CONSTRAINT IF EXISTS project_escalations_pkey;
ALTER TABLE IF EXISTS ONLY public.project_assignments DROP CONSTRAINT IF EXISTS project_assignments_pkey;
ALTER TABLE IF EXISTS ONLY public.progress_events DROP CONSTRAINT IF EXISTS progress_events_pkey;
ALTER TABLE IF EXISTS ONLY public.progress_events DROP CONSTRAINT IF EXISTS progress_events_event_guid_key;
ALTER TABLE IF EXISTS ONLY public.permissions DROP CONSTRAINT IF EXISTS permissions_pkey;
ALTER TABLE IF EXISTS ONLY public.permissions DROP CONSTRAINT IF EXISTS permissions_permission_code_key;
ALTER TABLE IF EXISTS ONLY public.permission_categories DROP CONSTRAINT IF EXISTS permission_categories_pkey;
ALTER TABLE IF EXISTS ONLY public.permission_categories DROP CONSTRAINT IF EXISTS permission_categories_category_code_key;
ALTER TABLE IF EXISTS ONLY public.organization_users DROP CONSTRAINT IF EXISTS organization_users_pkey;
ALTER TABLE IF EXISTS ONLY public.organization_users DROP CONSTRAINT IF EXISTS organization_users_organization_id_email_key;
ALTER TABLE IF EXISTS ONLY public.organization_metrics DROP CONSTRAINT IF EXISTS organization_metrics_pkey;
ALTER TABLE IF EXISTS ONLY public.organization_metrics DROP CONSTRAINT IF EXISTS organization_metrics_organization_id_metric_date_key;
ALTER TABLE IF EXISTS ONLY public.organization_eligibility_rules DROP CONSTRAINT IF EXISTS organization_eligibility_rules_pkey;
ALTER TABLE IF EXISTS ONLY public.notifications DROP CONSTRAINT IF EXISTS notifications_pkey;
ALTER TABLE IF EXISTS ONLY public.materials_inventory DROP CONSTRAINT IF EXISTS materials_inventory_pkey;
ALTER TABLE IF EXISTS ONLY public.material_requests DROP CONSTRAINT IF EXISTS material_requests_pkey;
ALTER TABLE IF EXISTS ONLY public.login_attempts DROP CONSTRAINT IF EXISTS login_attempts_pkey;
ALTER TABLE IF EXISTS ONLY public.invoices DROP CONSTRAINT IF EXISTS invoices_pkey;
ALTER TABLE IF EXISTS ONLY public.invoices DROP CONSTRAINT IF EXISTS invoices_invoice_number_key;
ALTER TABLE IF EXISTS ONLY public.invoice_line_items DROP CONSTRAINT IF EXISTS invoice_line_items_pkey;
ALTER TABLE IF EXISTS ONLY public.intake_submissions DROP CONSTRAINT IF EXISTS intake_submissions_submission_uuid_key;
ALTER TABLE IF EXISTS ONLY public.intake_submissions DROP CONSTRAINT IF EXISTS intake_submissions_pkey;
ALTER TABLE IF EXISTS ONLY public.income_records DROP CONSTRAINT IF EXISTS income_records_pkey;
ALTER TABLE IF EXISTS ONLY public.household_attributes DROP CONSTRAINT IF EXISTS household_attributes_pkey;
ALTER TABLE IF EXISTS ONLY public.household_attributes DROP CONSTRAINT IF EXISTS household_attributes_attribute_name_key;
ALTER TABLE IF EXISTS ONLY public.help_user_progress DROP CONSTRAINT IF EXISTS help_user_progress_user_id_document_id_key;
ALTER TABLE IF EXISTS ONLY public.help_user_progress DROP CONSTRAINT IF EXISTS help_user_progress_pkey;
ALTER TABLE IF EXISTS ONLY public.help_search_log DROP CONSTRAINT IF EXISTS help_search_log_pkey;
ALTER TABLE IF EXISTS ONLY public.help_documents DROP CONSTRAINT IF EXISTS help_documents_pkey;
ALTER TABLE IF EXISTS ONLY public.help_documents DROP CONSTRAINT IF EXISTS help_documents_document_id_key;
ALTER TABLE IF EXISTS ONLY public.help_document_versions DROP CONSTRAINT IF EXISTS help_document_versions_pkey;
ALTER TABLE IF EXISTS ONLY public.help_document_types DROP CONSTRAINT IF EXISTS help_document_types_type_code_key;
ALTER TABLE IF EXISTS ONLY public.help_document_types DROP CONSTRAINT IF EXISTS help_document_types_pkey;
ALTER TABLE IF EXISTS ONLY public.help_document_reviews DROP CONSTRAINT IF EXISTS help_document_reviews_pkey;
ALTER TABLE IF EXISTS ONLY public.help_document_feedback DROP CONSTRAINT IF EXISTS help_document_feedback_pkey;
ALTER TABLE IF EXISTS ONLY public.help_document_attachments DROP CONSTRAINT IF EXISTS help_document_attachments_pkey;
ALTER TABLE IF EXISTS ONLY public.help_categories DROP CONSTRAINT IF EXISTS help_categories_pkey;
ALTER TABLE IF EXISTS ONLY public.help_categories DROP CONSTRAINT IF EXISTS help_categories_category_code_key;
ALTER TABLE IF EXISTS ONLY public.guest_access_tokens DROP CONSTRAINT IF EXISTS guest_access_tokens_token_key;
ALTER TABLE IF EXISTS ONLY public.guest_access_tokens DROP CONSTRAINT IF EXISTS guest_access_tokens_submission_id_key;
ALTER TABLE IF EXISTS ONLY public.guest_access_tokens DROP CONSTRAINT IF EXISTS guest_access_tokens_pkey;
ALTER TABLE IF EXISTS ONLY public.funding_sources DROP CONSTRAINT IF EXISTS funding_sources_pkey;
ALTER TABLE IF EXISTS ONLY public.email_queue DROP CONSTRAINT IF EXISTS email_queue_pkey;
ALTER TABLE IF EXISTS ONLY public.eligibility_results DROP CONSTRAINT IF EXISTS eligibility_results_submission_id_organization_id_key;
ALTER TABLE IF EXISTS ONLY public.eligibility_results DROP CONSTRAINT IF EXISTS eligibility_results_pkey;
ALTER TABLE IF EXISTS ONLY public.edit_requests DROP CONSTRAINT IF EXISTS edit_requests_pkey;
ALTER TABLE IF EXISTS ONLY public.document_verifications DROP CONSTRAINT IF EXISTS document_verifications_pkey;
ALTER TABLE IF EXISTS ONLY public.document_templates DROP CONSTRAINT IF EXISTS document_templates_template_code_key;
ALTER TABLE IF EXISTS ONLY public.document_templates DROP CONSTRAINT IF EXISTS document_templates_pkey;
ALTER TABLE IF EXISTS ONLY public.document_statuses DROP CONSTRAINT IF EXISTS document_statuses_status_code_key;
ALTER TABLE IF EXISTS ONLY public.document_statuses DROP CONSTRAINT IF EXISTS document_statuses_pkey;
ALTER TABLE IF EXISTS ONLY public.document_share_links DROP CONSTRAINT IF EXISTS document_share_links_share_token_key;
ALTER TABLE IF EXISTS ONLY public.document_share_links DROP CONSTRAINT IF EXISTS document_share_links_pkey;
ALTER TABLE IF EXISTS ONLY public.document_generation_jobs DROP CONSTRAINT IF EXISTS document_generation_jobs_pkey;
ALTER TABLE IF EXISTS ONLY public.document_categories DROP CONSTRAINT IF EXISTS document_categories_pkey;
ALTER TABLE IF EXISTS ONLY public.document_categories DROP CONSTRAINT IF EXISTS document_categories_category_code_key;
ALTER TABLE IF EXISTS ONLY public.document_access_log DROP CONSTRAINT IF EXISTS document_access_log_pkey;
ALTER TABLE IF EXISTS ONLY public.criteria_types DROP CONSTRAINT IF EXISTS criteria_types_type_code_key;
ALTER TABLE IF EXISTS ONLY public.criteria_types DROP CONSTRAINT IF EXISTS criteria_types_pkey;
ALTER TABLE IF EXISTS ONLY public.crew_volunteer_signin DROP CONSTRAINT IF EXISTS crew_volunteer_signin_pkey;
ALTER TABLE IF EXISTS ONLY public.crew_job_phases DROP CONSTRAINT IF EXISTS crew_job_phases_pkey;
ALTER TABLE IF EXISTS ONLY public.crew_job_phases DROP CONSTRAINT IF EXISTS crew_job_phases_phase_code_key;
ALTER TABLE IF EXISTS ONLY public.crew_job_cards DROP CONSTRAINT IF EXISTS crew_job_cards_pkey;
ALTER TABLE IF EXISTS ONLY public.crew_incident_reports DROP CONSTRAINT IF EXISTS crew_incident_reports_pkey;
ALTER TABLE IF EXISTS ONLY public.crew_daily_logs DROP CONSTRAINT IF EXISTS crew_daily_logs_pkey;
ALTER TABLE IF EXISTS ONLY public.crew_daily_logs DROP CONSTRAINT IF EXISTS crew_daily_logs_job_id_log_date_key;
ALTER TABLE IF EXISTS ONLY public.crew_completion_documents DROP CONSTRAINT IF EXISTS crew_completion_documents_pkey;
ALTER TABLE IF EXISTS ONLY public.content_reads DROP CONSTRAINT IF EXISTS content_reads_pkey;
ALTER TABLE IF EXISTS ONLY public.content_reads DROP CONSTRAINT IF EXISTS content_reads_content_id_volunteer_id_key;
ALTER TABLE IF EXISTS ONLY public.contact_methods DROP CONSTRAINT IF EXISTS contact_methods_pkey;
ALTER TABLE IF EXISTS ONLY public.contact_methods DROP CONSTRAINT IF EXISTS contact_methods_method_code_key;
ALTER TABLE IF EXISTS ONLY public.coalition_organizations DROP CONSTRAINT IF EXISTS coalition_organizations_pkey;
ALTER TABLE IF EXISTS ONLY public.coalition_organizations DROP CONSTRAINT IF EXISTS coalition_organizations_organization_code_key;
ALTER TABLE IF EXISTS ONLY public.cases DROP CONSTRAINT IF EXISTS cases_pkey;
ALTER TABLE IF EXISTS ONLY public.cases DROP CONSTRAINT IF EXISTS cases_case_number_key;
ALTER TABLE IF EXISTS ONLY public.case_withdrawals DROP CONSTRAINT IF EXISTS case_withdrawals_pkey;
ALTER TABLE IF EXISTS ONLY public.case_statuses DROP CONSTRAINT IF EXISTS case_statuses_status_code_key;
ALTER TABLE IF EXISTS ONLY public.case_statuses DROP CONSTRAINT IF EXISTS case_statuses_pkey;
ALTER TABLE IF EXISTS ONLY public.case_status_history DROP CONSTRAINT IF EXISTS case_status_history_pkey;
ALTER TABLE IF EXISTS ONLY public.case_repair_claims DROP CONSTRAINT IF EXISTS case_repair_claims_pkey;
ALTER TABLE IF EXISTS ONLY public.case_funding DROP CONSTRAINT IF EXISTS case_funding_pkey;
ALTER TABLE IF EXISTS ONLY public.case_documents DROP CONSTRAINT IF EXISTS case_documents_pkey;
ALTER TABLE IF EXISTS ONLY public.case_communications DROP CONSTRAINT IF EXISTS case_communications_pkey;
ALTER TABLE IF EXISTS ONLY public.case_claims DROP CONSTRAINT IF EXISTS case_claims_pkey;
ALTER TABLE IF EXISTS ONLY public.blocked_ips DROP CONSTRAINT IF EXISTS blocked_ips_pkey;
ALTER TABLE IF EXISTS ONLY public.blocked_ips DROP CONSTRAINT IF EXISTS blocked_ips_ip_address_key;
ALTER TABLE IF EXISTS ONLY public.beneficiary_feedback DROP CONSTRAINT IF EXISTS beneficiary_feedback_pkey;
ALTER TABLE IF EXISTS ONLY public.badges DROP CONSTRAINT IF EXISTS badges_pkey;
ALTER TABLE IF EXISTS ONLY public.badges DROP CONSTRAINT IF EXISTS badges_badge_code_key;
ALTER TABLE IF EXISTS ONLY public.audit_log DROP CONSTRAINT IF EXISTS audit_log_pkey;
ALTER TABLE IF EXISTS ONLY public.assignment_log DROP CONSTRAINT IF EXISTS assignment_log_pkey;
ALTER TABLE IF EXISTS ONLY public.assessments DROP CONSTRAINT IF EXISTS assessments_pkey;
ALTER TABLE IF EXISTS ONLY public.assessment_tasks DROP CONSTRAINT IF EXISTS assessment_tasks_pkey;
ALTER TABLE IF EXISTS ONLY public.assessment_notes DROP CONSTRAINT IF EXISTS assessment_notes_pkey;
ALTER TABLE IF EXISTS ONLY public.assessment_documents DROP CONSTRAINT IF EXISTS assessment_documents_pkey;
ALTER TABLE IF EXISTS ONLY public.applications DROP CONSTRAINT IF EXISTS applications_placecode_key;
ALTER TABLE IF EXISTS ONLY public.applications DROP CONSTRAINT IF EXISTS applications_pkey;
ALTER TABLE IF EXISTS ONLY public.applications DROP CONSTRAINT IF EXISTS applications_application_guid_key;
ALTER TABLE IF EXISTS ONLY public.application_assignments DROP CONSTRAINT IF EXISTS application_assignments_submission_id_organization_id_key;
ALTER TABLE IF EXISTS ONLY public.application_assignments DROP CONSTRAINT IF EXISTS application_assignments_pkey;
ALTER TABLE IF EXISTS ONLY public.application_anchor DROP CONSTRAINT IF EXISTS application_anchor_submission_id_key;
ALTER TABLE IF EXISTS ONLY public.application_anchor DROP CONSTRAINT IF EXISTS application_anchor_pkey;
ALTER TABLE IF EXISTS ONLY public.application_anchor DROP CONSTRAINT IF EXISTS application_anchor_anchor_id_key;
ALTER TABLE IF EXISTS ONLY public.activity_log DROP CONSTRAINT IF EXISTS activity_log_pkey;
ALTER TABLE IF EXISTS ONLY public.activity_log DROP CONSTRAINT IF EXISTS activity_log_event_guid_key;
ALTER TABLE IF EXISTS ONLY public.activity_detail DROP CONSTRAINT IF EXISTS activity_detail_pkey;
ALTER TABLE IF EXISTS ONLY public.activity_detail DROP CONSTRAINT IF EXISTS activity_detail_event_guid_key;
ALTER TABLE IF EXISTS public.work_tasks ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.work_orders ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.weekly_digests ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.volunteer_skills ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.volunteer_profiles ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.volunteer_hours ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.volunteer_feedback ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.volunteer_content ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.volunteer_badges ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.user_role_assignments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.task_status_history ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.system_users ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.support_tickets ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.subcontractor_quotes ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.subcontractor_profiles ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.subcontractor_invoices ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.subcontractor_communications ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.storage_providers ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.skills ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.site_photos ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.scope_of_work_line_items ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.roles ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.role_permissions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.review_queue ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.repair_requests ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.repair_estimates ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.repair_category_details ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.repair_categories ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.reimbursement_requests ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.quest_assignments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.property_assessments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.project_snapshots ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.project_milestones ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.project_escalations ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.project_assignments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.progress_events ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.permissions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.permission_categories ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.organization_users ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.organization_metrics ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.organization_eligibility_rules ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.notifications ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.materials_inventory ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.material_requests ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.login_attempts ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.invoices ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.invoice_line_items ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.intake_submissions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.income_records ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.household_attributes ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.help_user_progress ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.help_search_log ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.help_documents ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.help_document_versions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.help_document_types ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.help_document_reviews ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.help_document_feedback ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.help_document_attachments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.help_categories ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.guest_access_tokens ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.funding_sources ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.email_queue ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.eligibility_results ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.edit_requests ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.document_verifications ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.document_templates ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.document_statuses ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.document_share_links ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.document_generation_jobs ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.document_categories ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.document_access_log ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.criteria_types ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.crew_volunteer_signin ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.crew_job_phases ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.crew_job_cards ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.crew_incident_reports ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.crew_daily_logs ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.crew_completion_documents ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.content_reads ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.contact_methods ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.coalition_organizations ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.cases ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.case_withdrawals ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.case_statuses ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.case_status_history ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.case_repair_claims ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.case_funding ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.case_documents ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.case_communications ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.blocked_ips ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.beneficiary_feedback ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.badges ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.audit_log ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.assignment_log ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.assessments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.assessment_tasks ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.assessment_notes ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.assessment_documents ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.applications ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.application_assignments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.application_anchor ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.activity_log ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.activity_detail ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.work_tasks_id_seq;
DROP SEQUENCE IF EXISTS public.work_orders_id_seq;
DROP SEQUENCE IF EXISTS public.weekly_digests_id_seq;
DROP TABLE IF EXISTS public.weekly_digests;
DROP SEQUENCE IF EXISTS public.volunteer_skills_id_seq;
DROP TABLE IF EXISTS public.volunteer_skills;
DROP SEQUENCE IF EXISTS public.volunteer_profiles_id_seq;
DROP TABLE IF EXISTS public.volunteer_profiles;
DROP SEQUENCE IF EXISTS public.volunteer_hours_id_seq;
DROP SEQUENCE IF EXISTS public.volunteer_feedback_id_seq;
DROP TABLE IF EXISTS public.volunteer_feedback;
DROP SEQUENCE IF EXISTS public.volunteer_content_id_seq;
DROP TABLE IF EXISTS public.volunteer_content;
DROP SEQUENCE IF EXISTS public.volunteer_badges_id_seq;
DROP TABLE IF EXISTS public.volunteer_badges;
DROP SEQUENCE IF EXISTS public.user_role_assignments_id_seq;
DROP TABLE IF EXISTS public.user_role_assignments;
DROP VIEW IF EXISTS public.urgent_conditions_view;
DROP SEQUENCE IF EXISTS public.task_status_history_id_seq;
DROP TABLE IF EXISTS public.task_status_history;
DROP SEQUENCE IF EXISTS public.system_users_id_seq;
DROP SEQUENCE IF EXISTS public.support_tickets_id_seq;
DROP TABLE IF EXISTS public.support_tickets;
DROP VIEW IF EXISTS public.submission_full_view;
DROP TABLE IF EXISTS public.submission_contact_methods;
DROP SEQUENCE IF EXISTS public.subcontractor_quotes_id_seq;
DROP TABLE IF EXISTS public.subcontractor_quotes;
DROP SEQUENCE IF EXISTS public.subcontractor_profiles_id_seq;
DROP TABLE IF EXISTS public.subcontractor_profiles;
DROP SEQUENCE IF EXISTS public.subcontractor_invoices_id_seq;
DROP TABLE IF EXISTS public.subcontractor_invoices;
DROP SEQUENCE IF EXISTS public.subcontractor_communications_id_seq;
DROP TABLE IF EXISTS public.subcontractor_communications;
DROP SEQUENCE IF EXISTS public.storage_providers_id_seq;
DROP TABLE IF EXISTS public.storage_providers;
DROP SEQUENCE IF EXISTS public.skills_id_seq;
DROP TABLE IF EXISTS public.skills;
DROP SEQUENCE IF EXISTS public.site_photos_id_seq;
DROP TABLE IF EXISTS public.site_photos;
DROP SEQUENCE IF EXISTS public.scope_of_work_line_items_id_seq;
DROP TABLE IF EXISTS public.scope_of_work_line_items;
DROP SEQUENCE IF EXISTS public.roles_id_seq;
DROP TABLE IF EXISTS public.roles;
DROP SEQUENCE IF EXISTS public.role_permissions_id_seq;
DROP TABLE IF EXISTS public.role_permissions;
DROP SEQUENCE IF EXISTS public.review_queue_id_seq;
DROP SEQUENCE IF EXISTS public.repair_requests_id_seq;
DROP TABLE IF EXISTS public.repair_requests;
DROP SEQUENCE IF EXISTS public.repair_estimates_id_seq;
DROP TABLE IF EXISTS public.repair_estimates;
DROP SEQUENCE IF EXISTS public.repair_category_details_id_seq;
DROP TABLE IF EXISTS public.repair_category_details;
DROP SEQUENCE IF EXISTS public.repair_categories_id_seq;
DROP SEQUENCE IF EXISTS public.reimbursement_requests_id_seq;
DROP TABLE IF EXISTS public.reimbursement_requests;
DROP VIEW IF EXISTS public.recently_updated_docs;
DROP TABLE IF EXISTS public.quests;
DROP SEQUENCE IF EXISTS public.quest_assignments_id_seq;
DROP TABLE IF EXISTS public.quest_assignments;
DROP SEQUENCE IF EXISTS public.property_assessments_id_seq;
DROP VIEW IF EXISTS public.project_status_view;
DROP SEQUENCE IF EXISTS public.project_snapshots_id_seq;
DROP TABLE IF EXISTS public.project_snapshots;
DROP SEQUENCE IF EXISTS public.project_milestones_id_seq;
DROP TABLE IF EXISTS public.project_milestones;
DROP VIEW IF EXISTS public.project_manager_review_queue;
DROP SEQUENCE IF EXISTS public.project_escalations_id_seq;
DROP TABLE IF EXISTS public.project_escalations;
DROP SEQUENCE IF EXISTS public.project_assignments_id_seq;
DROP TABLE IF EXISTS public.project_assignments;
DROP SEQUENCE IF EXISTS public.progress_events_id_seq;
DROP TABLE IF EXISTS public.progress_events;
DROP SEQUENCE IF EXISTS public.permissions_id_seq;
DROP TABLE IF EXISTS public.permissions;
DROP SEQUENCE IF EXISTS public.permission_categories_id_seq;
DROP TABLE IF EXISTS public.permission_categories;
DROP VIEW IF EXISTS public.pending_verification_documents;
DROP VIEW IF EXISTS public.organization_workload;
DROP TABLE IF EXISTS public.work_tasks;
DROP TABLE IF EXISTS public.work_orders;
DROP TABLE IF EXISTS public.volunteer_hours;
DROP SEQUENCE IF EXISTS public.organization_users_id_seq;
DROP TABLE IF EXISTS public.organization_users;
DROP SEQUENCE IF EXISTS public.organization_metrics_id_seq;
DROP TABLE IF EXISTS public.organization_metrics;
DROP SEQUENCE IF EXISTS public.organization_eligibility_rules_id_seq;
DROP SEQUENCE IF EXISTS public.notifications_id_seq;
DROP TABLE IF EXISTS public.notifications;
DROP SEQUENCE IF EXISTS public.materials_inventory_id_seq;
DROP TABLE IF EXISTS public.materials_inventory;
DROP SEQUENCE IF EXISTS public.material_requests_id_seq;
DROP TABLE IF EXISTS public.material_requests;
DROP SEQUENCE IF EXISTS public.login_attempts_id_seq;
DROP TABLE IF EXISTS public.login_attempts;
DROP SEQUENCE IF EXISTS public.invoices_id_seq;
DROP TABLE IF EXISTS public.invoices;
DROP SEQUENCE IF EXISTS public.invoice_line_items_id_seq;
DROP TABLE IF EXISTS public.invoice_line_items;
DROP SEQUENCE IF EXISTS public.intake_submissions_id_seq;
DROP SEQUENCE IF EXISTS public.income_records_id_seq;
DROP TABLE IF EXISTS public.income_records;
DROP SEQUENCE IF EXISTS public.household_attributes_id_seq;
DROP SEQUENCE IF EXISTS public.help_user_progress_id_seq;
DROP TABLE IF EXISTS public.help_user_progress;
DROP SEQUENCE IF EXISTS public.help_search_log_id_seq;
DROP TABLE IF EXISTS public.help_search_log;
DROP SEQUENCE IF EXISTS public.help_documents_id_seq;
DROP SEQUENCE IF EXISTS public.help_document_versions_id_seq;
DROP TABLE IF EXISTS public.help_document_versions;
DROP SEQUENCE IF EXISTS public.help_document_types_id_seq;
DROP TABLE IF EXISTS public.help_document_types;
DROP SEQUENCE IF EXISTS public.help_document_reviews_id_seq;
DROP TABLE IF EXISTS public.help_document_reviews;
DROP SEQUENCE IF EXISTS public.help_document_feedback_id_seq;
DROP TABLE IF EXISTS public.help_document_feedback;
DROP SEQUENCE IF EXISTS public.help_document_attachments_id_seq;
DROP TABLE IF EXISTS public.help_document_attachments;
DROP VIEW IF EXISTS public.help_center_overview;
DROP SEQUENCE IF EXISTS public.help_categories_id_seq;
DROP TABLE IF EXISTS public.help_categories;
DROP SEQUENCE IF EXISTS public.guest_access_tokens_id_seq;
DROP TABLE IF EXISTS public.guest_access_tokens;
DROP SEQUENCE IF EXISTS public.funding_sources_id_seq;
DROP VIEW IF EXISTS public.funding_source_summary;
DROP TABLE IF EXISTS public.funding_sources;
DROP SEQUENCE IF EXISTS public.email_queue_id_seq;
DROP TABLE IF EXISTS public.email_queue;
DROP SEQUENCE IF EXISTS public.eligibility_results_id_seq;
DROP SEQUENCE IF EXISTS public.edit_requests_id_seq;
DROP TABLE IF EXISTS public.edit_requests;
DROP VIEW IF EXISTS public.duplicate_case_alerts;
DROP VIEW IF EXISTS public.documents_needing_review;
DROP TABLE IF EXISTS public.help_documents;
DROP SEQUENCE IF EXISTS public.document_verifications_id_seq;
DROP TABLE IF EXISTS public.document_verifications;
DROP SEQUENCE IF EXISTS public.document_templates_id_seq;
DROP TABLE IF EXISTS public.document_templates;
DROP SEQUENCE IF EXISTS public.document_statuses_id_seq;
DROP SEQUENCE IF EXISTS public.document_share_links_id_seq;
DROP TABLE IF EXISTS public.document_share_links;
DROP SEQUENCE IF EXISTS public.document_generation_jobs_id_seq;
DROP TABLE IF EXISTS public.document_generation_jobs;
DROP SEQUENCE IF EXISTS public.document_categories_id_seq;
DROP SEQUENCE IF EXISTS public.document_access_log_id_seq;
DROP TABLE IF EXISTS public.document_access_log;
DROP SEQUENCE IF EXISTS public.criteria_types_id_seq;
DROP SEQUENCE IF EXISTS public.crew_volunteer_signin_id_seq;
DROP VIEW IF EXISTS public.crew_tomorrow_view;
DROP TABLE IF EXISTS public.crew_volunteer_signin;
DROP SEQUENCE IF EXISTS public.crew_job_phases_id_seq;
DROP TABLE IF EXISTS public.crew_job_phases;
DROP SEQUENCE IF EXISTS public.crew_job_cards_id_seq;
DROP TABLE IF EXISTS public.crew_job_cards;
DROP SEQUENCE IF EXISTS public.crew_incident_reports_id_seq;
DROP TABLE IF EXISTS public.crew_incident_reports;
DROP SEQUENCE IF EXISTS public.crew_daily_logs_id_seq;
DROP TABLE IF EXISTS public.crew_daily_logs;
DROP SEQUENCE IF EXISTS public.crew_completion_documents_id_seq;
DROP TABLE IF EXISTS public.crew_completion_documents;
DROP SEQUENCE IF EXISTS public.content_reads_id_seq;
DROP TABLE IF EXISTS public.content_reads;
DROP SEQUENCE IF EXISTS public.contact_methods_id_seq;
DROP TABLE IF EXISTS public.contact_methods;
DROP VIEW IF EXISTS public.completed_assessments_with_triage;
DROP TABLE IF EXISTS public.property_assessments;
DROP SEQUENCE IF EXISTS public.coalition_organizations_id_seq;
DROP VIEW IF EXISTS public.caseworker_review_queue;
DROP SEQUENCE IF EXISTS public.cases_id_seq;
DROP SEQUENCE IF EXISTS public.case_withdrawals_id_seq;
DROP TABLE IF EXISTS public.case_withdrawals;
DROP SEQUENCE IF EXISTS public.case_statuses_id_seq;
DROP SEQUENCE IF EXISTS public.case_status_history_id_seq;
DROP TABLE IF EXISTS public.case_status_history;
DROP SEQUENCE IF EXISTS public.case_repair_claims_id_seq;
DROP TABLE IF EXISTS public.case_repair_claims;
DROP VIEW IF EXISTS public.case_funding_summary;
DROP SEQUENCE IF EXISTS public.case_funding_id_seq;
DROP TABLE IF EXISTS public.case_funding;
DROP SEQUENCE IF EXISTS public.case_documents_id_seq;
DROP VIEW IF EXISTS public.case_document_inventory;
DROP TABLE IF EXISTS public.document_statuses;
DROP TABLE IF EXISTS public.document_categories;
DROP TABLE IF EXISTS public.case_documents;
DROP SEQUENCE IF EXISTS public.case_communications_id_seq;
DROP TABLE IF EXISTS public.case_communications;
DROP TABLE IF EXISTS public.case_claims;
DROP VIEW IF EXISTS public.case_claim_status;
DROP VIEW IF EXISTS public.case_assignment_dashboard;
DROP TABLE IF EXISTS public.system_users;
DROP TABLE IF EXISTS public.cases;
DROP TABLE IF EXISTS public.case_statuses;
DROP SEQUENCE IF EXISTS public.blocked_ips_id_seq;
DROP TABLE IF EXISTS public.blocked_ips;
DROP SEQUENCE IF EXISTS public.beneficiary_feedback_id_seq;
DROP TABLE IF EXISTS public.beneficiary_feedback;
DROP SEQUENCE IF EXISTS public.badges_id_seq;
DROP TABLE IF EXISTS public.badges;
DROP SEQUENCE IF EXISTS public.audit_log_id_seq;
DROP TABLE IF EXISTS public.audit_log;
DROP SEQUENCE IF EXISTS public.assignment_log_id_seq;
DROP TABLE IF EXISTS public.assignment_log;
DROP SEQUENCE IF EXISTS public.assessments_id_seq;
DROP TABLE IF EXISTS public.assessments;
DROP SEQUENCE IF EXISTS public.assessment_tasks_id_seq;
DROP TABLE IF EXISTS public.assessment_tasks;
DROP SEQUENCE IF EXISTS public.assessment_notes_id_seq;
DROP TABLE IF EXISTS public.assessment_notes;
DROP SEQUENCE IF EXISTS public.assessment_documents_id_seq;
DROP TABLE IF EXISTS public.assessment_documents;
DROP SEQUENCE IF EXISTS public.applications_id_seq;
DROP TABLE IF EXISTS public.applications;
DROP MATERIALIZED VIEW IF EXISTS public.application_match_scores;
DROP TABLE IF EXISTS public.submission_household_attributes;
DROP TABLE IF EXISTS public.organization_eligibility_rules;
DROP TABLE IF EXISTS public.household_attributes;
DROP TABLE IF EXISTS public.criteria_types;
DROP SEQUENCE IF EXISTS public.application_assignments_id_seq;
DROP TABLE IF EXISTS public.application_assignments;
DROP SEQUENCE IF EXISTS public.application_anchor_id_seq;
DROP TABLE IF EXISTS public.application_anchor;
DROP VIEW IF EXISTS public.admin_review_queue;
DROP VIEW IF EXISTS public.staff_review_queue;
DROP TABLE IF EXISTS public.submission_repair_categories;
DROP TABLE IF EXISTS public.review_queue;
DROP TABLE IF EXISTS public.repair_categories;
DROP TABLE IF EXISTS public.intake_submissions;
DROP SEQUENCE IF EXISTS public.fifo_sequence;
DROP TABLE IF EXISTS public.eligibility_results;
DROP TABLE IF EXISTS public.coalition_organizations;
DROP SEQUENCE IF EXISTS public.activity_log_id_seq;
DROP TABLE IF EXISTS public.activity_log;
DROP SEQUENCE IF EXISTS public.activity_detail_id_seq;
DROP TABLE IF EXISTS public.activity_detail;
DROP FUNCTION IF EXISTS public.version_help_document();
DROP FUNCTION IF EXISTS public.validate_status_transition(p_application_id integer, p_new_status character varying);
DROP FUNCTION IF EXISTS public.validate_guest_access(p_token uuid);
DROP FUNCTION IF EXISTS public.validate_document_name(p_filename character varying);
DROP FUNCTION IF EXISTS public.user_has_permission(p_user_id integer, p_permission_code character varying, p_organization_id integer);
DROP FUNCTION IF EXISTS public.update_organization_metrics();
DROP FUNCTION IF EXISTS public.update_help_doc_timestamp();
DROP FUNCTION IF EXISTS public.update_case_timestamp();
DROP FUNCTION IF EXISTS public.trigger_new_application_notifications(p_submission_id integer);
DROP FUNCTION IF EXISTS public.submit_intake_application(p_form_data jsonb, p_create_account boolean, p_email character varying, p_password_hash character varying, p_ip_address inet, p_user_agent text);
DROP FUNCTION IF EXISTS public.set_application_status(p_application_id integer, p_new_status character varying, p_reason text, p_checkboxes text[], p_changed_by integer);
DROP FUNCTION IF EXISTS public.send_daily_digest();
DROP FUNCTION IF EXISTS public.seed_demo_submission(p_config jsonb);
DROP FUNCTION IF EXISTS public.seed_dashboard_placeholder();
DROP FUNCTION IF EXISTS public.register_site_photos(p_case_id integer, p_photos jsonb, p_uploaded_by integer);
DROP FUNCTION IF EXISTS public.register_application_anchor(p_submission_id integer, p_eligibility_result jsonb);
DROP FUNCTION IF EXISTS public.refresh_match_scores();
DROP FUNCTION IF EXISTS public.record_help_feedback(p_document_id integer, p_user_id integer, p_is_helpful boolean, p_rating integer, p_comment text);
DROP FUNCTION IF EXISTS public.queue_new_application_emails(p_submission_id integer);
DROP FUNCTION IF EXISTS public.on_new_submission();
DROP FUNCTION IF EXISTS public.mark_notification_read(p_notification_id integer, p_user_id integer);
DROP FUNCTION IF EXISTS public.log_progress_event(p_case_id integer, p_event_type character varying, p_event_description text, p_performed_by integer, p_is_progress boolean, p_source character varying);
DROP FUNCTION IF EXISTS public.is_in_service_area(p_zip character varying, p_city character varying);
DROP FUNCTION IF EXISTS public.increment_help_view(p_document_id integer);
DROP FUNCTION IF EXISTS public.has_received_previous_assistance(p_first_name character varying, p_last_name character varying, p_address character varying);
DROP FUNCTION IF EXISTS public.get_user_role_at_org(p_user_id integer, p_organization_id integer);
DROP FUNCTION IF EXISTS public.get_unread_notifications(p_user_id integer, p_limit integer);
DROP FUNCTION IF EXISTS public.get_primary_repair_type(p_submission_id integer);
DROP FUNCTION IF EXISTS public.get_past_week_range();
DROP FUNCTION IF EXISTS public.get_next_in_queue(p_organization_id integer);
DROP FUNCTION IF EXISTS public.get_income_bucket(p_income numeric);
DROP FUNCTION IF EXISTS public.get_docs_for_role(p_role_code character varying);
DROP FUNCTION IF EXISTS public.get_current_week_range();
DROP FUNCTION IF EXISTS public.get_county_bucket(p_city character varying, p_zip character varying);
DROP FUNCTION IF EXISTS public.get_all_dashboard_metrics(p_organization_id integer);
DROP FUNCTION IF EXISTS public.generate_reimbursement_id();
DROP FUNCTION IF EXISTS public.generate_property_card(p_case_id integer, p_parcel_id character varying);
DROP FUNCTION IF EXISTS public.generate_project_prefix(p_helene boolean, p_home_type text);
DROP FUNCTION IF EXISTS public.generate_project_prefix(p_helene boolean);
DROP FUNCTION IF EXISTS public.generate_placecode(p_address text);
DROP FUNCTION IF EXISTS public.generate_guest_access_token(p_submission_id integer);
DROP FUNCTION IF EXISTS public.generate_dummy_submissions(p_count integer);
DROP FUNCTION IF EXISTS public.generate_dummy_submission(p_config jsonb);
DROP FUNCTION IF EXISTS public.generate_contract(p_case_id integer, p_template_version integer);
DROP FUNCTION IF EXISTS public.generate_case_number();
DROP FUNCTION IF EXISTS public.generate_anchor_id();
DROP FUNCTION IF EXISTS public.expire_stale_claims();
DROP FUNCTION IF EXISTS public.deduplicate_submissions(p_submission_id integer);
DROP FUNCTION IF EXISTS public.cleanup_old_login_attempts();
DROP FUNCTION IF EXISTS public.claim_quest(p_quest_id uuid, p_volunteer_id uuid);
DROP FUNCTION IF EXISTS public.claim_application(p_application_id integer, p_organization_id integer, p_claimed_by integer);
DROP FUNCTION IF EXISTS public.check_eligibility(p_submission_id integer);
DROP FUNCTION IF EXISTS public.canonical_termination_reasons();
DROP FUNCTION IF EXISTS public.calculate_match_score(p_submission_id integer, p_organization_id integer);
DROP FUNCTION IF EXISTS public.award_quest_completion(p_assignment_id integer, p_hours_logged numeric, p_photos text[]);
DROP FUNCTION IF EXISTS public.auto_assign_applications();
DROP FUNCTION IF EXISTS public.archr_generate_placecode(p_address text);
DROP FUNCTION IF EXISTS public.archr_display_name(p_address text, p_city text);
DROP FUNCTION IF EXISTS public.archr_activity_purge_expired();
DROP FUNCTION IF EXISTS public._ensure_dummy_partner_orgs();
DROP EXTENSION IF EXISTS pgcrypto;
--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: _ensure_dummy_partner_orgs(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._ensure_dummy_partner_orgs() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO coalition_organizations
        (organization_code, organization_name, contact_email, max_active_applications, is_active)
    VALUES
        ('AHFH', 'Asheville Habitat for Humanity', 'intake@ashevillehabitat.org', 60, TRUE),
        ('MHO',  'Mountain Housing Opportunities', 'help@mtnhousing.org',         40, TRUE),
        ('CAO',  'Community Action Opportunities', 'intake@caoinc.org',           30, TRUE)
    ON CONFLICT (organization_code) DO NOTHING;
END;
$$;


--
-- Name: archr_activity_purge_expired(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.archr_activity_purge_expired() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    purged INTEGER;
BEGIN
    DELETE FROM activity_detail WHERE expires_at < CURRENT_TIMESTAMP;
    GET DIAGNOSTICS purged = ROW_COUNT;
    RETURN purged;
END;
$$;


--
-- Name: archr_display_name(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.archr_display_name(p_address text, p_city text) RETURNS character varying
    LANGUAGE sql IMMUTABLE
    AS $$
    SELECT NULLIF(btrim(concat_ws(' - ', NULLIF(btrim(COALESCE(p_address, '')), ''), NULLIF(btrim(COALESCE(p_city, '')), ''))), '');
$$;


--
-- Name: archr_generate_placecode(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.archr_generate_placecode(p_address text) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE
    AS $$
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
$$;


--
-- Name: auto_assign_applications(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.auto_assign_applications() RETURNS TABLE(submission_id integer, organization_id integer, match_score integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Insert assignments for unmatched applications with high match scores
    INSERT INTO application_assignments (submission_id, organization_id, match_score, expires_at)
    SELECT 
        ams.submission_id,
        ams.organization_id,
        ams.match_score,
        CURRENT_TIMESTAMP + INTERVAL '14 days' -- 2 weeks to claim
    FROM application_match_scores ams
    WHERE NOT EXISTS (
        SELECT 1 FROM application_assignments aa
        WHERE aa.submission_id = ams.submission_id
    )
    AND ams.match_score >= 80 -- Only high-quality matches
    AND ams.has_capacity = true
    ORDER BY ams.match_score DESC;
    
    -- Auto-claim for organizations with auto_claim_enabled
    INSERT INTO application_assignments (submission_id, organization_id, status, claimed_at, match_score)
    SELECT 
        ams.submission_id,
        ams.organization_id,
        'claimed',
        CURRENT_TIMESTAMP,
        ams.match_score
    FROM application_match_scores ams
    WHERE ams.auto_claim_enabled = true
        AND ams.match_score >= 90 -- Perfect or near-perfect matches
        AND ams.has_capacity = true
        AND NOT EXISTS (
            SELECT 1 FROM application_assignments aa
            WHERE aa.submission_id = ams.submission_id
            AND aa.status = 'claimed'
        )
    -- ON CONFLICT ON CONSTRAINT: the function's RETURNS TABLE out-params share
    -- names with these columns, making the column-list form ambiguous (42702).
    ON CONFLICT ON CONSTRAINT application_assignments_submission_id_organization_id_key DO UPDATE
    SET status = 'claimed', claimed_at = CURRENT_TIMESTAMP;
    
    RETURN QUERY
    SELECT aa.submission_id, aa.organization_id, aa.match_score
    FROM application_assignments aa
    WHERE aa.assigned_at > CURRENT_TIMESTAMP - INTERVAL '1 minute';
END;
$$;


--
-- Name: award_quest_completion(integer, numeric, text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.award_quest_completion(p_assignment_id integer, p_hours_logged numeric, p_photos text[]) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_assignment RECORD;
    v_quest RECORD;
    v_volunteer RECORD;
    v_new_xp INTEGER;
    v_new_level INTEGER;
    v_xp_needed INTEGER;
    v_new_reputation INTEGER;
    v_new_total_hours DECIMAL;
BEGIN
    -- Get assignment and quest details
    SELECT * INTO v_assignment FROM quest_assignments WHERE id = p_assignment_id;
    SELECT * INTO v_quest FROM quests WHERE id = v_assignment.quest_id;
    SELECT * INTO v_volunteer FROM volunteer_profiles WHERE user_id = v_assignment.volunteer_id;
    
    -- Update assignment
    UPDATE quest_assignments SET
        status = 'completed',
        completed_at = NOW(),
        hours_logged = p_hours_logged,
        before_photo_urls = p_photos[1:array_length(p_photos, 1)/3],
        during_photo_urls = p_photos[array_length(p_photos, 1)/3+1:2*array_length(p_photos, 1)/3],
        after_photo_urls = p_photos[2*array_length(p_photos, 1)/3+1:array_length(p_photos, 1)],
        xp_awarded = v_quest.xp_reward,
        reputation_awarded = v_quest.reputation_reward,
        rewards_claimed = TRUE
    WHERE id = p_assignment_id;
    
    -- Update volunteer stats
    v_new_xp := v_volunteer.xp + v_quest.xp_reward;
    v_new_reputation := v_volunteer.reputation_score + v_quest.reputation_reward;
    v_new_total_hours := v_volunteer.total_hours_logged + p_hours_logged;
    
    -- Check level-up
    v_new_level := v_volunteer.level;
    v_xp_needed := v_volunteer.xp_to_next_level;
    
    WHILE v_new_xp >= v_xp_needed LOOP
        v_new_level := v_new_level + 1;
        v_new_xp := v_new_xp - v_xp_needed;
        v_xp_needed := 100 * v_new_level; -- Simple formula: next level needs 100 * level
    END LOOP;
    
    UPDATE volunteer_profiles SET
        xp = v_new_xp,
        level = v_new_level,
        xp_to_next_level = v_xp_needed,
        reputation_score = v_new_reputation,
        total_hours_logged = v_new_total_hours,
        total_quests_completed = total_quests_completed + 1,
        last_active_at = NOW(),
        updated_at = NOW()
    WHERE user_id = v_assignment.volunteer_id;
    
    -- Check for badge awards (simplified - would call separate function)
    
    RETURN jsonb_build_object(
        'success', true,
        'xp_gained', v_quest.xp_reward,
        'reputation_gained', v_quest.reputation_reward,
        'new_level', v_new_level,
        'level_up', (v_new_level > v_volunteer.level),
        'total_xp', v_new_xp,
        'next_level_xp', v_xp_needed
    );
END;
$$;


--
-- Name: calculate_match_score(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_match_score(p_submission_id integer, p_organization_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_score INTEGER := 100; -- Start at 100, subtract for mismatches
    v_submission RECORD;
    v_org_criteria RECORD;
BEGIN
    SELECT * INTO v_submission FROM intake_submissions WHERE id = p_submission_id;
    
    -- Check each criterion and reduce score for mismatches
    FOR v_org_criteria IN 
        SELECT * FROM organization_eligibility_rules 
        WHERE organization_id = p_organization_id AND is_active = TRUE
    LOOP
        CASE v_org_criteria.criteria_type_id
            WHEN (SELECT id FROM criteria_types WHERE type_code = 'income_max') THEN
                IF v_submission.gross_annual_income > v_org_criteria.rule_value::INTEGER THEN
                    v_score := v_score - 20;
                END IF;
                
            WHEN (SELECT id FROM criteria_types WHERE type_code = 'geography_zipcodes') THEN
                IF v_submission.home_zip != ANY(string_to_array(v_org_criteria.rule_value, ',')) THEN
                    v_score := v_score - 30;
                END IF;
                
            WHEN (SELECT id FROM criteria_types WHERE type_code = 'urgent_only') THEN
                -- Check if submission has urgent conditions
                IF v_org_criteria.rule_value = 'true' THEN
                    IF NOT EXISTS (
                        SELECT 1 FROM submission_repair_categories src
                        JOIN repair_categories rc ON src.category_id = rc.id
                        WHERE src.submission_id = p_submission_id
                          AND rc.category_code IN ('unable_to_stay', 'no_hvac', 'no_potable_water')
                    ) THEN
                        v_score := v_score - 50;
                    END IF;
                END IF;
                
            -- Add more criteria as needed
            ELSE
                -- Unknown criteria, ignore
                CONTINUE;
        END CASE;
    END LOOP;
    
    -- Ensure score is between 0 and 100
    RETURN GREATEST(0, LEAST(100, v_score));
END;
$$;


--
-- Name: canonical_termination_reasons(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.canonical_termination_reasons() RETURNS text[]
    LANGUAGE sql IMMUTABLE
    AS $$
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
$$;


--
-- Name: check_eligibility(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_eligibility(p_submission_id integer) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_submission RECORD;
    v_eligibility_result JSONB;
    v_green TEXT[] := '{}';
    v_yellow TEXT[] := '{}';
    v_red TEXT[] := '{}';
    v_ami_threshold INTEGER;
BEGIN
    -- Fetch submission data
    SELECT * INTO v_submission FROM intake_submissions WHERE id = p_submission_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Submission % not found', p_submission_id;
    END IF;

    -- =====================================================
    -- FLAGS (never hard stops — humans make final decisions)
    -- =====================================================

    -- 1. Geographic eligibility (service area check)
    IF is_in_service_area(v_submission.home_zip, v_submission.home_city) THEN
        v_green := array_append(v_green, 'in_service_area');
    ELSE
        v_red := array_append(v_red, 'outside_service_area');
    END IF;

    -- 2. Homeowner status
    IF v_submission.owns_home IS TRUE THEN
        v_green := array_append(v_green, 'homeownership_confirmed');
    ELSIF v_submission.owns_home IS FALSE THEN
        v_red := array_append(v_red, 'not_homeowner');
    END IF;

    -- 3. Primary residence
    IF v_submission.is_primary_residence IS TRUE THEN
        v_green := array_append(v_green, 'primary_residence_confirmed');
    ELSIF v_submission.is_primary_residence IS FALSE THEN
        v_red := array_append(v_red, 'not_primary_residence');
    END IF;

    -- 4. Income vs 80% AMI for household size (same table as the PHP checker)
    v_ami_threshold := CASE LEAST(COALESCE(v_submission.household_size, 1), 8)
        WHEN 1 THEN 48800 WHEN 2 THEN 55800 WHEN 3 THEN 62750 WHEN 4 THEN 69700
        WHEN 5 THEN 75300 WHEN 6 THEN 80900 WHEN 7 THEN 86500 ELSE 92050
    END;
    IF v_submission.gross_annual_income IS NOT NULL THEN
        IF v_submission.gross_annual_income <= v_ami_threshold THEN
            v_green := array_append(v_green, 'income_within_80pct_ami');
        ELSE
            v_red := array_append(v_red, 'income_above_80pct_ami');
        END IF;
    END IF;

    -- 5. Property type restrictions (mobile homes require lot ownership)
    IF v_submission.home_type = 'mobile' AND v_submission.owns_lot IS FALSE THEN
        v_red := array_append(v_red, 'mobile_home_no_lot_ownership');
    END IF;

    -- 6. Previous assistance (humans verify before terminating as duplicate)
    IF has_received_previous_assistance(v_submission.applicant_first_name,
                                        v_submission.applicant_last_name,
                                        v_submission.home_address) THEN
        v_red := array_append(v_red, 'previous_assistance_received');
    END IF;

    -- 7. Helene-related damage (context flag from the doc's example payload)
    IF v_submission.helene_related IS TRUE THEN
        v_green := array_append(v_green, 'helene_related');
    END IF;

    -- 8. Age requirement (under 18 needs a guardian — review flag only)
    IF v_submission.applicant_dob IS NOT NULL
       AND v_submission.applicant_dob > CURRENT_DATE - INTERVAL '18 years' THEN
        v_yellow := array_append(v_yellow, 'applicant_under_18_guardian_required');
    END IF;

    -- =====================================================
    -- CONDITIONAL ELIGIBILITY (Org-specific matching)
    -- These affect which organizations can serve, not overall eligibility
    -- =====================================================

    INSERT INTO eligibility_results (submission_id, organization_id, match_score, is_eligible, checked_at)
    SELECT
        p_submission_id,
        co.id,
        calculate_match_score(p_submission_id, co.id),
        CASE WHEN calculate_match_score(p_submission_id, co.id) >= 50 THEN TRUE ELSE FALSE END,
        CURRENT_TIMESTAMP
    FROM coalition_organizations co
    WHERE co.is_active = TRUE
    ON CONFLICT (submission_id, organization_id) DO UPDATE
    SET match_score = EXCLUDED.match_score,
        is_eligible = EXCLUDED.is_eligible,
        checked_at = EXCLUDED.checked_at;

    -- =====================================================
    -- PREPARE RESULT
    -- =====================================================

    -- Red flags route to human review ('needs_review'); the system never
    -- writes 'ineligible'. Legacy columns mirror red/yellow flags.
    UPDATE intake_submissions
    SET
        submission_status = CASE
            WHEN array_length(v_red, 1) IS NOT NULL THEN 'needs_review'
            ELSE 'eligible'
        END,
        eligibility_checked_at = CURRENT_TIMESTAMP,
        disqualification_reasons = v_red,
        eligibility_warnings = v_yellow
    WHERE id = p_submission_id;

    -- Store flags on the Application (the deduplicated source of truth).
    UPDATE applications
       SET eligibility_flags = jsonb_build_object('green', v_green, 'yellow', v_yellow, 'red', v_red),
           eligibility_report = left(
               (CASE WHEN array_length(v_green, 1)  IS NOT NULL THEN 'Green: '  || array_to_string(v_green, ', ')  || '. ' ELSE '' END)
             ||(CASE WHEN array_length(v_yellow, 1) IS NOT NULL THEN 'Yellow: ' || array_to_string(v_yellow, ', ') || '. ' ELSE '' END)
             ||(CASE WHEN array_length(v_red, 1)    IS NOT NULL THEN 'Red: '    || array_to_string(v_red, ', ')           ELSE '' END),
               4000),
           updated_at = CURRENT_TIMESTAMP
     WHERE id = (SELECT deduplicated_into FROM intake_submissions WHERE id = p_submission_id);

    v_eligibility_result := jsonb_build_object(
        'is_eligible', TRUE, -- assume eligibility: no automated denials
        'flags', jsonb_build_object('green', v_green, 'yellow', v_yellow, 'red', v_red),
        'recommended_action', CASE WHEN array_length(v_red, 1) IS NOT NULL THEN 'review_manually' ELSE 'approve' END,
        'eligible_organizations', (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'organization_id', er.organization_id,
                    'organization_name', co.organization_name,
                    'match_score', er.match_score
                )
            )
            FROM eligibility_results er
            JOIN coalition_organizations co ON er.organization_id = co.id
            WHERE er.submission_id = p_submission_id AND er.is_eligible = TRUE
        ),
        'checked_at', CURRENT_TIMESTAMP
    );

    RETURN v_eligibility_result;
END;
$$;


--
-- Name: claim_application(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.claim_application(p_application_id integer, p_organization_id integer, p_claimed_by integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: claim_quest(uuid, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.claim_quest(p_quest_id uuid, p_volunteer_id uuid) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_current_count INTEGER;
    v_max_volunteers INTEGER;
    v_result JSONB;
BEGIN
    -- Lock the quest row to prevent race conditions
    SELECT max_volunteers, current_volunteers 
    INTO v_max_volunteers, v_current_count
    FROM quests WHERE id = p_quest_id FOR UPDATE;
    
    -- Check availability
    IF v_current_count >= v_max_volunteers THEN
        RETURN jsonb_build_object('success', false, 'error', 'Quest is full');
    END IF;
    
    -- Check volunteer hasn't already claimed
    IF EXISTS (SELECT 1 FROM quest_assignments 
               WHERE quest_id = p_quest_id AND volunteer_id = p_volunteer_id) THEN
        RETURN jsonb_build_object('success', false, 'error', 'Already claimed');
    END IF;
    
    -- Assign the quest
    INSERT INTO quest_assignments (quest_id, volunteer_id, assigned_at, status)
    VALUES (p_quest_id, p_volunteer_id, NOW(), 'assigned');
    
    -- Update current count
    UPDATE quests 
    SET current_volunteers = current_volunteers + 1
    WHERE id = p_quest_id;
    
    RETURN jsonb_build_object('success', true, 'message', 'Quest claimed!');
END;
$$;


--
-- Name: cleanup_old_login_attempts(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cleanup_old_login_attempts() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM login_attempts WHERE attempted_at < NOW() - INTERVAL '24 hours';
END;
$$;


--
-- Name: deduplicate_submissions(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.deduplicate_submissions(p_submission_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: expire_stale_claims(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.expire_stale_claims() RETURNS TABLE(case_id integer, application_id integer, organization_id integer, days_since_progress integer)
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: generate_anchor_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_anchor_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.anchor_id := 'ANCHOR-' || TO_CHAR(NEW.submitted_at, 'YYYYMMDD') || '-' || LPAD(NEW.id::TEXT, 5, '0');
    RETURN NEW;
END;
$$;


--
-- Name: generate_case_number(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_case_number() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.case_number := 'ARCHR-' || TO_CHAR(NEW.created_at, 'YYYY') || '-' || LPAD(NEW.id::TEXT, 6, '0');
    RETURN NEW;
END;
$$;


--
-- Name: generate_contract(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_contract(p_case_id integer, p_template_version integer DEFAULT 1) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_document_id INTEGER;
    v_case_record RECORD;
    v_assessment RECORD;
    v_contract_data JSONB;
BEGIN
    -- Get case and assessment data
    SELECT c.*, s.applicant_first_name, s.applicant_last_name, s.home_address
    INTO v_case_record
    FROM cases c
    JOIN intake_submissions s ON c.submission_id = s.id
    WHERE c.id = p_case_id;
    
    -- Get approved assessment
    SELECT * INTO v_assessment
    FROM property_assessments
    WHERE case_id = p_case_id
    ORDER BY assessment_date DESC
    LIMIT 1;
    
    -- Build contract data
    v_contract_data = jsonb_build_object(
        'case_number', v_case_record.case_number,
        'applicant_name', v_case_record.applicant_first_name || ' ' || v_case_record.applicant_last_name,
        'property_address', v_case_record.home_address,
        'repair_scope', v_assessment.recommended_repairs,
        'total_estimate', v_assessment.total_estimate,
        'estimated_hours', v_assessment.estimated_hours,
        'start_date', (CURRENT_DATE + INTERVAL '14 days'),
        'completion_target', (CURRENT_DATE + INTERVAL '60 days'),
        'terms_and_conditions', 'Standard repair terms apply...',
        'generated_at', CURRENT_TIMESTAMP,
        'template_version', p_template_version
    );
    
    -- Queue for PDF generation
    INSERT INTO document_generation_jobs (
        case_id, template_id, data_source, created_by
    ) VALUES (
        p_case_id,
        (SELECT id FROM document_templates WHERE template_code = 'REPAIR_CONTRACT' AND is_active = true),
        v_contract_data,
        NULL
    );
    
    -- Create document record (PDF will be linked when generation completes)
    INSERT INTO case_documents (
        case_id, category_id, status_id, file_name, storage_path,
        metadata, access_roles
    ) VALUES (
        p_case_id,
        (SELECT id FROM document_categories WHERE category_code = 'CONTRACT'),
        (SELECT id FROM document_statuses WHERE status_code = 'PENDING'),
        v_case_record.case_number || '_contract_v1.pdf',
        '/cases/' || v_case_record.case_number || '/contracts/' || v_case_record.case_number || '_contract_v1.pdf',
        v_contract_data,
        ARRAY['ADMIN', 'CASEWORKER', 'PROJECT_MANAGER', 'APPLICANT']
    ) RETURNING id INTO v_document_id;
    
    -- Update generation job with document ID
    UPDATE document_generation_jobs 
    SET output_document_id = v_document_id 
    WHERE case_id = p_case_id 
    AND output_document_id IS NULL;
    
    RETURN v_document_id;
END;
$$;


--
-- Name: generate_dummy_submission(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_dummy_submission(p_config jsonb DEFAULT '{}'::jsonb) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_id           INTEGER;
    v_first        TEXT      := COALESCE(p_config->>'first_name', 'Test');
    v_last         TEXT      := COALESCE(p_config->>'last_name',  'Applicant');
    v_email        TEXT      := COALESCE(p_config->>'email',
                                         LOWER(v_first || '.' || v_last) || '@example.com');
    v_zip          TEXT      := COALESCE(p_config->>'zip',  '28804');
    v_city         TEXT      := COALESCE(p_config->>'city', 'Asheville');
    v_address      TEXT      := COALESCE(p_config->>'address',
                                         (100 + FLOOR(RANDOM()*9000)::INT)::TEXT || ' Sample St');
    v_income       NUMERIC   := COALESCE((p_config->>'income')::NUMERIC, 28000);
    v_helene       BOOLEAN   := COALESCE((p_config->>'helene_related')::BOOLEAN, TRUE);
    v_submitted_at TIMESTAMP := COALESCE((p_config->>'submitted_at')::TIMESTAMP, CURRENT_TIMESTAMP);
    v_status       TEXT      := COALESCE(p_config->>'submission_status', 'ELIGIBLE');
    v_repair_codes TEXT[]    := CASE WHEN p_config ? 'repair_codes'
        THEN ARRAY(SELECT jsonb_array_elements_text(p_config->'repair_codes'))
        ELSE ARRAY['no_hvac','open_to_elements'] END;
    v_attr_codes   TEXT[]    := CASE WHEN p_config ? 'household_attributes'
        THEN ARRAY(SELECT jsonb_array_elements_text(p_config->'household_attributes'))
        ELSE ARRAY[]::TEXT[] END;
    v_prev_repl    TEXT;
BEGIN
    PERFORM _ensure_dummy_partner_orgs();

    -- Suppress user triggers ONLY for the intake_submissions insert:
    -- trigger_new_submission refreshes a materialized view CONCURRENTLY without
    -- the unique index that operation requires, which would abort the seed.
    -- Triggers on application_anchor / cases (anchor_id + case_number generators)
    -- are still needed, so restore session_replication_role immediately after.
    v_prev_repl := current_setting('session_replication_role');
    PERFORM set_config('session_replication_role', 'replica', true);

    INSERT INTO intake_submissions (
        applicant_first_name, applicant_last_name, applicant_dob,
        contact_email, cell_phone, preferred_email, preferred_phone,
        home_address, home_city, home_state, home_zip,
        is_primary_residence, home_type, year_built, move_in_date, owns_home, owns_lot,
        household_size, household_adults,
        helene_related,
        has_income, income_method, gross_annual_income,
        consent_agreed, language,
        submission_status, submitted_at, is_test
    ) VALUES (
        v_first, v_last, DATE '1975-01-01' - (FLOOR(RANDOM()*7000))::INT,
        v_email, '(828) 555-' || LPAD(FLOOR(RANDOM()*10000)::TEXT, 4, '0'), TRUE, TRUE,
        v_address, v_city, 'NC', v_zip,
        TRUE, 'traditional', 1960 + FLOOR(RANDOM()*50)::INT,
        CURRENT_DATE - INTERVAL '5 years', TRUE, TRUE,
        2 + FLOOR(RANDOM()*4)::INT, 1 + FLOOR(RANDOM()*2)::INT,
        v_helene,
        TRUE, 'gross', v_income,
        TRUE, 'eng',
        v_status, v_submitted_at, TRUE
    ) RETURNING id INTO v_id;

    PERFORM set_config('session_replication_role', v_prev_repl, true);

    -- Mirror urgent-condition flags to the boolean columns the queue reads.
    UPDATE intake_submissions SET
        urgent_no_hvac          = 'no_hvac'          = ANY(v_repair_codes),
        urgent_no_potable_water = 'no_potable_water' = ANY(v_repair_codes),
        urgent_open_to_elements = 'open_to_elements' = ANY(v_repair_codes),
        urgent_no_bathroom      = 'no_bathroom'      = ANY(v_repair_codes),
        urgent_no_kitchen       = 'no_kitchen'       = ANY(v_repair_codes),
        urgent_unable_to_stay   = 'unable_to_stay'   = ANY(v_repair_codes),
        urgent_no_entry         = 'no_entry'         = ANY(v_repair_codes),
        urgent_accessibility    = 'accessibility'    = ANY(v_repair_codes),
        urgent_eviction_risk    = 'eviction_risk'    = ANY(v_repair_codes)
    WHERE id = v_id;

    INSERT INTO submission_repair_categories (submission_id, category_id)
    SELECT v_id, rc.id FROM repair_categories rc WHERE rc.category_code = ANY(v_repair_codes);

    INSERT INTO submission_household_attributes (submission_id, attribute_id)
    SELECT v_id, ha.id FROM household_attributes ha WHERE ha.attribute_name = ANY(v_attr_codes);

    INSERT INTO submission_contact_methods (submission_id, method_id)
    SELECT v_id, cm.id FROM contact_methods cm WHERE cm.method_code IN ('email','phone');

    INSERT INTO application_anchor (
        submission_id, submitted_at, is_eligible, eligibility_score, current_status,
        income_bucket, county_bucket, repair_type_bucket, helene_related
    ) VALUES (
        v_id, v_submitted_at, TRUE, 60 + FLOOR(RANDOM()*40)::INT,
        CASE WHEN v_status = 'ELIGIBLE' THEN 'eligible' ELSE LOWER(v_status) END,
        get_income_bucket(v_income), get_county_bucket(v_city, v_zip),
        v_repair_codes[1], v_helene
    );

    INSERT INTO eligibility_results (submission_id, organization_id, match_score, is_eligible)
    SELECT v_id, co.id, 60 + FLOOR(RANDOM()*40)::INT, TRUE
    FROM coalition_organizations co WHERE co.is_active = TRUE
    ON CONFLICT (submission_id, organization_id) DO NOTHING;

    INSERT INTO review_queue (submission_id, status, queued_at, priority_score)
    VALUES (v_id, 'PENDING_REVIEW', v_submitted_at,
            10 * COALESCE(array_length(v_repair_codes, 1), 0));

    RETURN v_id;
END;
$$;


--
-- Name: generate_dummy_submissions(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_dummy_submissions(p_count integer DEFAULT 10) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_firsts  TEXT[] := ARRAY['Maria','David','Linda','James','Patricia','Robert','Jennifer',
                              'Michael','Barbara','William','Elizabeth','Thomas','Susan','Daniel'];
    v_lasts   TEXT[] := ARRAY['Garcia','Johnson','Williams','Brown','Davis','Miller','Wilson',
                              'Moore','Taylor','Anderson','Thomas','Jackson','White','Harris'];
    v_cities  TEXT[]  := ARRAY['Asheville','Black Mountain','Swannanoa','Weaverville','Candler','Arden'];
    v_zips    TEXT[]  := ARRAY['28801','28803','28804','28805','28806','28711','28778','28787'];
    -- JSONB[] (not TEXT[][]) so single-index access returns a whole inner list.
    v_repairs JSONB[] := ARRAY[
        '["no_hvac","open_to_elements"]'::JSONB,
        '["no_potable_water","no_bathroom"]'::JSONB,
        '["no_kitchen","accessibility"]'::JSONB,
        '["unable_to_stay","no_entry"]'::JSONB,
        '["eviction_risk","no_hvac"]'::JSONB
    ];
    v_attrs   JSONB[] := ARRAY[
        '["single_parent","child_under_5"]'::JSONB,
        '["person_over_62"]'::JSONB,
        '["person_with_disability","veteran"]'::JSONB,
        '["snap_wic","child_under_5"]'::JSONB,
        '[]'::JSONB
    ];
    v_first   TEXT;
    v_last    TEXT;
    v_idx     INTEGER;
    v_created INTEGER := 0;
BEGIN
    PERFORM _ensure_dummy_partner_orgs();
    FOR v_idx IN 1..p_count LOOP
        v_first := v_firsts[1 + FLOOR(RANDOM() * array_length(v_firsts, 1))::INT];
        v_last  := v_lasts [1 + FLOOR(RANDOM() * array_length(v_lasts,  1))::INT];
        PERFORM generate_dummy_submission(jsonb_build_object(
            'first_name',      v_first,
            'last_name',       v_last,
            'email',           LOWER(v_first || '.' || v_last) || v_idx || '@example.com',
            'city',            v_cities[1 + FLOOR(RANDOM() * array_length(v_cities, 1))::INT],
            'zip',             v_zips  [1 + FLOOR(RANDOM() * array_length(v_zips,   1))::INT],
            'income',          18000 + FLOOR(RANDOM() * 30000)::INT,
            'helene_related',  RANDOM() < 0.7,
            'submitted_at',    to_char(CURRENT_TIMESTAMP - (FLOOR(RANDOM() * 60)::TEXT || ' days')::INTERVAL,
                                       'YYYY-MM-DD HH24:MI:SS'),
            'repair_codes',    v_repairs[1 + FLOOR(RANDOM() * array_length(v_repairs, 1))::INT],
            'household_attributes', v_attrs[1 + FLOOR(RANDOM() * array_length(v_attrs, 1))::INT]
        ));
        v_created := v_created + 1;
    END LOOP;
    RETURN v_created;
END;
$$;


--
-- Name: generate_guest_access_token(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_guest_access_token(p_submission_id integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_token UUID;
    v_expires TIMESTAMP;
BEGIN
    v_token := gen_random_uuid();
    v_expires := CURRENT_TIMESTAMP + INTERVAL '30 days';
    
    INSERT INTO guest_access_tokens (submission_id, token, expires_at)
    VALUES (p_submission_id, v_token, v_expires)
    ON CONFLICT (submission_id) DO UPDATE
    SET token = EXCLUDED.token,
        expires_at = EXCLUDED.expires_at,
        last_accessed = NULL;
    
    RETURN '/track/' || v_token;
END;
$$;


--
-- Name: generate_placecode(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_placecode(p_address text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_addr TEXT;
    v_number TEXT;
    v_unit TEXT;
    v_street TEXT;
    v_letters TEXT;
    v_len INTEGER;
BEGIN
    IF p_address IS NULL OR trim(p_address) = '' THEN
        RETURN NULL;
    END IF;

    v_addr := upper(trim(p_address));

    -- Extract unit / apartment number (e.g., "APT 2", "UNIT B", "#4")
    v_unit := substring(v_addr FROM '((?:APT|UNIT|SUITE|STE|#)\s*\w+)');
    IF v_unit IS NOT NULL THEN
        v_unit := regexp_replace(v_unit, '^(APT|UNIT|SUITE|STE|#)\s*', '');
        v_addr := regexp_replace(v_addr, '\s*(?:APT|UNIT|SUITE|STE|#)\s*\w+', '');
    END IF;

    -- Extract leading numeric portion(s) (handles ranges like 123-125)
    v_number := substring(v_addr FROM '^([0-9]+[-]?[0-9]*)');
    IF v_number IS NULL THEN
        v_number := '';
    END IF;

    -- Remove the number, directionals, and punctuation from the remainder
    v_street := regexp_replace(v_addr, '^[0-9]+[-]?[0-9]*\s*', '');
    v_street := regexp_replace(v_street, '\b(NORTH|SOUTH|EAST|WEST|NORTHEAST|NORTHWEST|SOUTHEAST|SOUTHWEST|NE|NW|SE|SW|N|S|E|W)\b', '', 'g');
    v_street := regexp_replace(v_street, '[^A-Z]', '', 'g');

    v_len := 8 - length(v_number);
    IF v_len < 0 THEN v_len := 0; END IF;
    v_letters := substring(v_street FROM 1 FOR v_len);

    RETURN substring(coalesce(v_number || v_letters, ''), 1, 8) || CASE WHEN v_unit IS NOT NULL THEN '[' || v_unit || ']' ELSE '' END;
END;
$$;


--
-- Name: generate_project_prefix(boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_project_prefix(p_helene boolean) RETURNS character
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN CASE WHEN p_helene THEN 'D' ELSE 'R' END;
END;
$$;


--
-- Name: generate_project_prefix(boolean, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_project_prefix(p_helene boolean, p_home_type text) RETURNS character
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN CASE
        WHEN lower(coalesce(p_home_type, '')) = 'mobile' THEN 'H'
        WHEN p_helene THEN 'D'
        ELSE 'A'
    END;
END;
$$;


--
-- Name: generate_property_card(integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_property_card(p_case_id integer, p_parcel_id character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_document_id INTEGER;
    v_case_record RECORD;
    v_property_data JSONB;
BEGIN
    -- Get case information
    SELECT c.*, s.home_address, s.home_city, s.home_zip, s.home_type, s.year_built
    INTO v_case_record
    FROM cases c
    JOIN intake_submissions s ON c.submission_id = s.id
    WHERE c.id = p_case_id;
    
    -- In production, this would call a county assessor API or web scraper
    -- For now, we construct a JSONB object with available data
    v_property_data = jsonb_build_object(
        'parcel_id', p_parcel_id,
        'property_address', v_case_record.home_address,
        'property_city', v_case_record.home_city,
        'property_zip', v_case_record.home_zip,
        'year_built', v_case_record.year_built,
        'property_type', v_case_record.home_type,
        'generated_at', CURRENT_TIMESTAMP,
        'source', 'system_generated'
    );
    
    -- Create a document record
    INSERT INTO case_documents (
        case_id, category_id, status_id, file_name, storage_path, 
        metadata, uploaded_by, access_roles
    ) VALUES (
        p_case_id,
        (SELECT id FROM document_categories WHERE category_code = 'PROPERTY'),
        (SELECT id FROM document_statuses WHERE status_code = 'PENDING'),
        'property_card_' || p_case_id || '_' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '.json',
        '/cases/' || v_case_record.case_number || '/property/property_card.json',
        v_property_data,
        NULL,
        ARRAY['ADMIN', 'CASEWORKER', 'ASSESSOR']
    ) RETURNING id INTO v_document_id;
    
    -- Queue a job to convert to PDF if needed
    -- This would be handled by a separate worker process
    
    RETURN v_document_id;
END;
$$;


--
-- Name: generate_reimbursement_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_reimbursement_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.request_id := 'REIMB-' || TO_CHAR(NEW.submitted_at, 'YYYY') || '-' || LPAD(NEW.id::TEXT, 5, '0');
    RETURN NEW;
END;
$$;


--
-- Name: get_all_dashboard_metrics(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_all_dashboard_metrics(p_organization_id integer DEFAULT NULL::integer) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: get_county_bucket(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_county_bucket(p_city character varying, p_zip character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF p_zip IN ('28801','28803','28804','28805','28806') OR p_city ILIKE '%Asheville%' THEN
        RETURN 'Buncombe';
    ELSIF p_city ILIKE '%Marshall%' OR p_city ILIKE '%Mars Hill%' THEN
        RETURN 'Madison';
    ELSIF p_city ILIKE '%Hendersonville%' THEN
        RETURN 'Henderson';
    ELSE
        RETURN 'Other';
    END IF;
END;
$$;


--
-- Name: get_current_week_range(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_current_week_range() RETURNS TABLE(start_date date, end_date date)
    LANGUAGE plpgsql
    AS $$
BEGIN
    start_date := DATE_TRUNC('week', CURRENT_DATE)::DATE;
    end_date := CURRENT_DATE;
    RETURN NEXT;
END;
$$;


--
-- Name: get_docs_for_role(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_docs_for_role(p_role_code character varying) RETURNS TABLE(id integer, title character varying, category_name character varying, doc_type_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        hd.id,
        hd.title,
        hc.category_name,
        hdt.type_name
    FROM help_documents hd
    JOIN help_categories hc ON hd.category_id = hc.id
    JOIN help_document_types hdt ON hd.doc_type_id = hdt.id
    WHERE hd.status = 'published'
        AND (hd.target_roles IS NULL OR p_role_code = ANY(hd.target_roles))
    ORDER BY hc.display_order, hd.title;
END;
$$;


--
-- Name: get_income_bucket(numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_income_bucket(p_income numeric) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN CASE 
        WHEN p_income IS NULL OR p_income = 0 THEN '$0'
        WHEN p_income <= 15000 THEN '$1-15k'
        WHEN p_income <= 30000 THEN '$15k-30k'
        WHEN p_income <= 50000 THEN '$30k-50k'
        WHEN p_income <= 75000 THEN '$50k-75k'
        ELSE '$75k+'
    END;
END;
$_$;


--
-- Name: get_next_in_queue(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_next_in_queue(p_organization_id integer DEFAULT NULL::integer) RETURNS TABLE(submission_id integer, case_number character varying, applicant_name character varying, fifo_order bigint, priority_score integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        rq.submission_id,
        c.case_number,
        s.applicant_first_name || ' ' || s.applicant_last_name AS applicant_name,
        rq.fifo_order,
        rq.priority_score
    FROM review_queue rq
    JOIN intake_submissions s ON rq.submission_id = s.id
    LEFT JOIN cases c ON s.id = c.submission_id
    WHERE rq.status = 'PENDING_REVIEW'
      AND (p_organization_id IS NULL OR rq.organization_id = p_organization_id)
    ORDER BY rq.priority_score DESC, rq.fifo_order ASC
    LIMIT 1;
END;
$$;


--
-- Name: get_past_week_range(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_past_week_range() RETURNS TABLE(start_date date, end_date date)
    LANGUAGE plpgsql
    AS $$
BEGIN
    start_date := (CURRENT_DATE - INTERVAL '7 days')::DATE;
    end_date := (CURRENT_DATE - INTERVAL '1 day')::DATE;
    RETURN NEXT;
END;
$$;


--
-- Name: get_primary_repair_type(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_primary_repair_type(p_submission_id integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_primary_category VARCHAR;
BEGIN
    SELECT rc.category_code INTO v_primary_category
    FROM submission_repair_categories src
    JOIN repair_categories rc ON src.category_id = rc.id
    WHERE src.submission_id = p_submission_id
    ORDER BY src.id ASC
    LIMIT 1;
    
    RETURN COALESCE(v_primary_category, 'unknown');
END;
$$;


--
-- Name: get_unread_notifications(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_unread_notifications(p_user_id integer, p_limit integer DEFAULT 20) RETURNS TABLE(notification_id integer, notification_type character varying, title character varying, body text, created_at timestamp without time zone, priority character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        n.id,
        n.notification_type,
        n.title,
        n.body,
        n.created_at,
        n.priority
    FROM notifications n
    WHERE n.user_id = p_user_id
      AND n.is_read = FALSE
      AND n.is_archived = FALSE
    ORDER BY 
        CASE n.priority 
            WHEN 'urgent' THEN 1
            WHEN 'high' THEN 2
            WHEN 'normal' THEN 3
            ELSE 4
        END,
        n.created_at DESC
    LIMIT p_limit;
END;
$$;


--
-- Name: get_user_role_at_org(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_user_role_at_org(p_user_id integer, p_organization_id integer) RETURNS TABLE(role_code character varying, role_level integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT r.role_code, r.role_level
    FROM user_role_assignments ura
    JOIN roles r ON ura.role_id = r.id
    WHERE ura.user_id = p_user_id
        AND ura.organization_id = p_organization_id
        AND ura.is_active = true
        AND (ura.expires_at IS NULL OR ura.expires_at > CURRENT_TIMESTAMP)
    ORDER BY r.role_level DESC
    LIMIT 1;
END;
$$;


--
-- Name: has_received_previous_assistance(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.has_received_previous_assistance(p_first_name character varying, p_last_name character varying, p_address character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check for existing completed cases at same address or same name
    RETURN EXISTS (
        SELECT 1 FROM cases c
        JOIN intake_submissions s ON c.submission_id = s.id
        WHERE c.status_id IN (SELECT id FROM case_statuses WHERE status_code IN ('COMPLETED'))
          AND (s.home_address ILIKE p_address
               OR (s.applicant_first_name ILIKE p_first_name 
                   AND s.applicant_last_name ILIKE p_last_name))
    );
END;
$$;


--
-- Name: increment_help_view(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.increment_help_view(p_document_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE help_documents 
    SET view_count = view_count + 1,
        last_viewed_at = CURRENT_TIMESTAMP
    WHERE id = p_document_id;
END;
$$;


--
-- Name: is_in_service_area(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_in_service_area(p_zip character varying, p_city character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Service area: Buncombe, Madison, Henderson, Haywood counties
    RETURN p_zip IN ('28801','28803','28804','28805','28806','28711','28715','28716','28778','28787')
        OR p_city ILIKE '%Asheville%'
        OR p_city ILIKE '%Black Mountain%'
        OR p_city ILIKE '%Weaverville%'
        OR p_city ILIKE '%Marshall%'
        OR p_city ILIKE '%Hendersonville%'
        OR p_city ILIKE '%Waynesville%';
END;
$$;


--
-- Name: log_progress_event(integer, character varying, text, integer, boolean, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.log_progress_event(p_case_id integer, p_event_type character varying, p_event_description text, p_performed_by integer, p_is_progress boolean DEFAULT true, p_source character varying DEFAULT 'user'::character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: mark_notification_read(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mark_notification_read(p_notification_id integer, p_user_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE notifications 
    SET is_read = TRUE, read_at = CURRENT_TIMESTAMP
    WHERE id = p_notification_id AND user_id = p_user_id;
    
    RETURN FOUND;
END;
$$;


--
-- Name: on_new_submission(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.on_new_submission() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Refresh match scores
    PERFORM refresh_match_scores();
    -- Auto-assign
    PERFORM auto_assign_applications();
    RETURN NEW;
END;
$$;


--
-- Name: queue_new_application_emails(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.queue_new_application_emails(p_submission_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_submission RECORD;
    v_staff RECORD;
BEGIN
    SELECT * INTO v_submission FROM intake_submissions WHERE id = p_submission_id;
    
    -- Queue emails for each staff role (batched, not immediate)
    FOR v_staff IN 
        SELECT DISTINCT u.email, u.full_name, r.role_code
        FROM system_users u
        JOIN user_role_assignments ura ON u.id = ura.user_id
        JOIN roles r ON ura.role_id = r.id
        WHERE r.role_code IN ('ADMIN', 'CASEWORKER', 'PROJECT_MANAGER')
          AND u.email IS NOT NULL
    LOOP
        INSERT INTO email_queue (
            recipient_email, recipient_name, subject, body,
            notification_type, related_entity_type, related_entity_id,
            priority
        ) VALUES (
            v_staff.email,
            v_staff.full_name,
            '[ARCHR] New Application Ready for Review',
            E'Hello ' || v_staff.full_name || ',\n\n' ||
            'A new application has been submitted and is ready for review.\n\n' ||
            'Applicant: ' || v_submission.applicant_first_name || ' ' || v_submission.applicant_last_name || '\n' ||
            'Address: ' || v_submission.home_address || '\n' ||
            'Submitted: ' || v_submission.submitted_at || '\n\n' ||
            'View in queue: https://apply.archr.org/dashboard/review\n\n' ||
            'ARCHR Platform',
            'new_application',
            'submission',
            p_submission_id,
            3 -- Normal priority
        );
    END LOOP;
END;
$$;


--
-- Name: record_help_feedback(integer, integer, boolean, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.record_help_feedback(p_document_id integer, p_user_id integer, p_is_helpful boolean, p_rating integer DEFAULT NULL::integer, p_comment text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO help_document_feedback (document_id, user_id, is_helpful, rating, comment)
    VALUES (p_document_id, p_user_id, p_is_helpful, p_rating, p_comment);
    
    -- Update aggregate counts on document
    UPDATE help_documents 
    SET helpful_count = (
        SELECT COUNT(*) FROM help_document_feedback 
        WHERE document_id = p_document_id AND is_helpful = true
    ),
    not_helpful_count = (
        SELECT COUNT(*) FROM help_document_feedback 
        WHERE document_id = p_document_id AND is_helpful = false
    )
    WHERE id = p_document_id;
END;
$$;


--
-- Name: refresh_match_scores(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.refresh_match_scores() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    REFRESH MATERIALIZED VIEW application_match_scores;
END;
$$;


--
-- Name: register_application_anchor(integer, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.register_application_anchor(p_submission_id integer, p_eligibility_result jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_submission RECORD;
BEGIN
    SELECT * INTO v_submission FROM intake_submissions WHERE id = p_submission_id;
    
    INSERT INTO application_anchor (
        submission_id,
        submitted_at,
        submitted_from_ip,
        is_eligible,
        disqualification_reasons,
        eligibility_score,
        current_status,
        income_bucket,
        county_bucket,
        repair_type_bucket,
        helene_related
    ) VALUES (
        p_submission_id,
        v_submission.submitted_at,
        v_submission.ip_address,
        (p_eligibility_result->>'is_eligible')::BOOLEAN,
        ARRAY(SELECT jsonb_array_elements_text(p_eligibility_result->'disqualifiers')),
        (p_eligibility_result->>'eligibility_score')::INTEGER,
        CASE WHEN (p_eligibility_result->>'is_eligible')::BOOLEAN THEN 'eligible' ELSE 'ineligible' END,
        get_income_bucket(v_submission.gross_annual_income),
        get_county_bucket(v_submission.home_city, v_submission.home_zip),
        get_primary_repair_type(p_submission_id),
        v_submission.helene_related
    );
END;
$$;


--
-- Name: register_site_photos(integer, jsonb, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.register_site_photos(p_case_id integer, p_photos jsonb, p_uploaded_by integer) RETURNS TABLE(photo_id integer, storage_path character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_photo RECORD;
    v_case_number VARCHAR;
    v_category_id INTEGER;
    v_doc_id INTEGER;
    v_storage_path VARCHAR;
BEGIN
    -- Get case number
    SELECT case_number INTO v_case_number FROM cases WHERE id = p_case_id;
    
    FOR v_photo IN SELECT * FROM jsonb_to_recordset(p_photos) AS x(file_name TEXT, photo_type TEXT, capture_timestamp TIMESTAMP)
    LOOP
        -- Determine category based on photo type
        SELECT id INTO v_category_id FROM document_categories 
        WHERE category_code = CASE v_photo.photo_type
            WHEN 'before' THEN 'ASSESSMENT_PHOTOS_BEFORE'
            WHEN 'during' THEN 'ASSESSMENT_PHOTOS_DURING'
            WHEN 'after' THEN 'ASSESSMENT_PHOTOS_AFTER'
            ELSE 'ASSESSMENT_PHOTOS_BEFORE'
        END;
        
        -- Generate storage path
        v_storage_path := '/cases/' || v_case_number || '/assessments/' || 
            CASE v_photo.photo_type
                WHEN 'before' THEN 'initial/photos/'
                WHEN 'during' THEN 'final/photos/'
                WHEN 'after' THEN 'completion/final_photos/'
            END || 
            v_photo.photo_type || '_' || 
            TO_CHAR(COALESCE(v_photo.capture_timestamp, CURRENT_TIMESTAMP), 'YYYYMMDD_HH24MISS') || 
            '_' || v_photo.file_name;
        
        -- Create document record
        INSERT INTO case_documents (
            case_id, category_id, status_id, file_name, storage_path,
            uploaded_by, mime_type, access_roles, metadata
        ) VALUES (
            p_case_id, v_category_id, 
            (SELECT id FROM document_statuses WHERE status_code = 'PROCESSING'),
            v_photo.file_name, v_storage_path,
            p_uploaded_by, 'image/jpeg',
            ARRAY['ADMIN', 'ASSESSOR', 'CREW_LEAD', 'PROJECT_MANAGER'],
            jsonb_build_object('photo_type', v_photo.photo_type, 'capture_timestamp', v_photo.capture_timestamp)
        ) RETURNING id INTO v_doc_id;
        
        photo_id := v_doc_id;
        storage_path := v_storage_path;
        RETURN NEXT;
    END LOOP;
    
    RETURN;
END;
$$;


--
-- Name: seed_dashboard_placeholder(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.seed_dashboard_placeholder() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_submission_id INTEGER;
    v_case_id       INTEGER;
    v_requestor_id  INTEGER;
    v_caseworker_id INTEGER;
    v_habitat_id    INTEGER;
    v_status_id     INTEGER;
    v_submitted_at  TIMESTAMP := TIMESTAMP '2024-11-15 10:30:00';
    v_case_number   TEXT      := 'ARCHR-2024-001234';
    v_anchor_id     TEXT      := 'ANCHOR-2024-0001234';
BEGIN
    PERFORM _ensure_dummy_partner_orgs();
    SELECT id INTO v_habitat_id FROM coalition_organizations WHERE organization_code = 'AHFH';

    -- Drop any prior placeholder so the seeder stays idempotent.
    DELETE FROM intake_submissions
     WHERE applicant_first_name = 'John' AND applicant_last_name = 'Smith' AND is_test = TRUE;
    DELETE FROM system_users WHERE email IN ('john.smith@example.com', 'sarah.martinez@archr.org');

    -- Requestor + caseworker accounts.
    INSERT INTO system_users (email, full_name, phone, is_active)
    VALUES ('john.smith@example.com', 'John Smith', '(828) 555-0188', TRUE)
    RETURNING id INTO v_requestor_id;
    INSERT INTO user_role_assignments (user_id, role_id)
    SELECT v_requestor_id, id FROM roles WHERE role_code = 'REQUESTOR';

    INSERT INTO system_users (email, full_name, phone, is_active)
    VALUES ('sarah.martinez@archr.org', 'Sarah Martinez', '(828) 555-0123', TRUE)
    RETURNING id INTO v_caseworker_id;
    INSERT INTO user_role_assignments (user_id, organization_id, role_id)
    SELECT v_caseworker_id, v_habitat_id, id FROM roles WHERE role_code = 'CASEWORKER';

    -- Build the submission via the generic generator so all child rows line up.
    v_submission_id := generate_dummy_submission(jsonb_build_object(
        'first_name',            'John',
        'last_name',             'Smith',
        'email',                 'john.smith@example.com',
        'address',               '247 Riverside Drive',
        'city',                  'Asheville',
        'zip',                   '28804',
        'income',                32400,
        'helene_related',        TRUE,
        'submitted_at',          to_char(v_submitted_at, 'YYYY-MM-DD HH24:MI:SS'),
        'submission_status',     'ELIGIBLE',
        'repair_codes',          jsonb_build_array('no_hvac', 'open_to_elements', 'accessibility'),
        'household_attributes',  jsonb_build_array('person_over_62', 'person_with_disability')
    ));

    -- Pin the anchor id so the dashboard's ARCHR-2024-001234 reference resolves.
    UPDATE application_anchor
       SET anchor_id        = v_anchor_id,
           case_number      = v_case_number,
           current_status   = 'in_review',
           assigned_organization_id = v_habitat_id,
           assigned_at      = v_submitted_at + INTERVAL '18 days'
     WHERE submission_id = v_submission_id;

    -- Move the queue entry to "assigned to Habitat", matching the timeline copy.
    UPDATE review_queue
       SET status          = 'IN_REVIEW',
           organization_id = v_habitat_id,
           assigned_to_id  = v_caseworker_id,
           assigned_at     = v_submitted_at + INTERVAL '18 days'
     WHERE submission_id = v_submission_id;

    -- Active case row so the requestor + staff dashboards both see it.
    SELECT id INTO v_status_id FROM case_statuses WHERE status_code = 'PENDING_REVIEW';
    INSERT INTO cases (
        submission_id, case_number, status_id,
        assigned_caseworker_id, intake_completed_at, created_at, updated_at
    ) VALUES (
        v_submission_id, v_case_number, v_status_id,
        v_caseworker_id, v_submitted_at + INTERVAL '13 days',
        v_submitted_at, v_submitted_at + INTERVAL '20 days'
    ) RETURNING id INTO v_case_id;
    -- Trigger built the case_number from NEW.id; force the placeholder value.
    UPDATE cases SET case_number = v_case_number WHERE id = v_case_id;

    RETURN format('Seeded placeholder: submission_id=%s, case=%s, anchor=%s',
                  v_submission_id, v_case_number, v_anchor_id);
END;
$$;


--
-- Name: seed_demo_submission(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.seed_demo_submission(p_config jsonb) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_id INT;
    v_app_id INT;
    v_status_id INT;
    v_placecode VARCHAR(50);
    v_project_code VARCHAR(50);
    v_first TEXT := p_config->>'first_name';
    v_last TEXT := p_config->>'last_name';
    v_email TEXT := p_config->>'email';
    v_phone TEXT := p_config->>'phone';
    v_address TEXT := p_config->>'address';
    v_city TEXT := p_config->>'city';
    v_zip TEXT := p_config->>'zip';
    v_home_type TEXT := COALESCE(p_config->>'home_type', 'traditional');
    v_helene BOOLEAN := COALESCE((p_config->>'helene_related')::BOOLEAN, TRUE);
    v_has_income BOOLEAN := COALESCE((p_config->>'has_income')::BOOLEAN, TRUE);
    v_income_method TEXT := COALESCE(p_config->>'income_method', 'gross');
    v_income NUMERIC := (p_config->>'gross_income')::NUMERIC;
    v_repair_codes TEXT[] := ARRAY(SELECT jsonb_array_elements_text(p_config->'repair_categories'));
    v_urgent_codes TEXT[] := ARRAY(SELECT jsonb_array_elements_text(COALESCE(p_config->'urgent', '[]'::jsonb)));
    v_attr_codes TEXT[] := ARRAY(SELECT jsonb_array_elements_text(COALESCE(p_config->'attributes', '[]'::jsonb)));
    v_submitted_at TIMESTAMP := CURRENT_TIMESTAMP - ((COALESCE(p_config->>'days_ago', '0')) || ' days')::INTERVAL;
    v_is_referral BOOLEAN := COALESCE((p_config->>'is_referral')::BOOLEAN, FALSE);
    v_fema JSONB := p_config->'fema';
    v_ins JSONB := p_config->'insurance';
    v_repair JSONB;
    v_inc JSONB;
    v_i INT := 0;
    v_prev_repl TEXT;
BEGIN
    -- Suppress the intake trigger only for the INSERT (it refreshes a
    -- materialized view per row); anchor/case generators still fire.
    v_prev_repl := current_setting('session_replication_role');
    PERFORM set_config('session_replication_role', 'replica', true);

    INSERT INTO intake_submissions (
        submitted_at, language, is_referral,
        referrer_name, referrer_organization, referrer_email, referrer_notes,
        consent_agreed,
        applicant_first_name, applicant_last_name, applicant_dob,
        preferred_phone, preferred_text, preferred_email,
        home_phone, cell_phone, contact_email, contact_notes,
        home_address, home_city, home_state, home_zip,
        is_primary_residence, home_type, year_built, move_in_date,
        owns_home, owns_lot, insurance_provider, lived_one_year,
        household_size, household_adults, additional_repair_details,
        urgent_unable_to_stay, urgent_no_hvac, urgent_no_potable_water,
        urgent_no_bathroom, urgent_no_kitchen, urgent_open_to_elements,
        urgent_no_entry, urgent_accessibility, urgent_other_issue, urgent_eviction_risk,
        helene_related,
        fema_claim_filed, fema_outcome, fema_settlement_amount,
        fema_remaining_exists, fema_remaining_amount,
        insurance_claim_filed, insurance_outcome, insurance_settlement_amount,
        insurance_remaining_exists, insurance_remaining_amount,
        has_income, income_method, gross_annual_income, income_docs_method,
        zero_income_first_name, zero_income_last_name, zero_income_address, zero_income_agreed,
        applicant_signature, submission_status, is_test
    ) VALUES (
        v_submitted_at, 'eng', v_is_referral,
        CASE WHEN v_is_referral THEN p_config->>'referrer_name' END,
        CASE WHEN v_is_referral THEN p_config->>'referrer_organization' END,
        CASE WHEN v_is_referral THEN p_config->>'referrer_email' END,
        CASE WHEN v_is_referral THEN p_config->>'referrer_notes' END,
        TRUE,
        v_first, v_last, (p_config->>'dob')::DATE,
        'phone' = ANY(ARRAY(SELECT jsonb_array_elements_text(COALESCE(p_config->'contact_methods', '["email"]'::jsonb)))),
        'text' = ANY(ARRAY(SELECT jsonb_array_elements_text(COALESCE(p_config->'contact_methods', '["email"]'::jsonb)))),
        'email' = ANY(ARRAY(SELECT jsonb_array_elements_text(COALESCE(p_config->'contact_methods', '["email"]'::jsonb)))),
        v_phone, v_phone, v_email, p_config->>'contact_notes',
        v_address, v_city, 'NC', v_zip,
        TRUE, v_home_type, (p_config->>'year_built')::INTEGER,
        CURRENT_DATE - (COALESCE(p_config->>'years_in_home', '6') || ' years')::INTERVAL,
        COALESCE((p_config->>'owns_home')::BOOLEAN, TRUE),
        COALESCE((p_config->>'owns_lot')::BOOLEAN, TRUE),
        p_config->>'insurance_provider', TRUE,
        (p_config->>'household_size')::INTEGER, (p_config->>'household_adults')::INTEGER,
        p_config->>'details',
        'unable_to_stay' = ANY(v_urgent_codes), 'no_hvac' = ANY(v_urgent_codes),
        'no_potable_water' = ANY(v_urgent_codes), 'no_bathroom' = ANY(v_urgent_codes),
        'no_kitchen' = ANY(v_urgent_codes), 'open_to_elements' = ANY(v_urgent_codes),
        'no_entry' = ANY(v_urgent_codes), 'accessibility' = ANY(v_urgent_codes),
        'other_issue' = ANY(v_urgent_codes), 'eviction_risk' = ANY(v_urgent_codes),
        v_helene,
        COALESCE((v_fema->>'filed')::BOOLEAN, FALSE), v_fema->>'outcome',
        (v_fema->>'settlement')::NUMERIC, (v_fema->>'remaining_exists')::BOOLEAN, (v_fema->>'remaining')::NUMERIC,
        COALESCE((v_ins->>'filed')::BOOLEAN, FALSE), v_ins->>'outcome',
        (v_ins->>'settlement')::NUMERIC, (v_ins->>'remaining_exists')::BOOLEAN, (v_ins->>'remaining')::NUMERIC,
        v_has_income, v_income_method,
        CASE WHEN v_has_income AND v_income_method = 'gross' THEN v_income END,
        COALESCE(p_config->>'income_docs', 'email_link'),
        CASE WHEN NOT v_has_income THEN v_first END,
        CASE WHEN NOT v_has_income THEN v_last END,
        CASE WHEN NOT v_has_income THEN v_address || ', ' || v_city || ' NC ' || v_zip END,
        CASE WHEN NOT v_has_income THEN TRUE END,
        'data:image/png;base64,SEED-DEMO-SIGNATURE', 'pending', TRUE
    ) RETURNING id INTO v_id;

    PERFORM set_config('session_replication_role', v_prev_repl, true);

    -- Junction rows
    INSERT INTO submission_repair_categories (submission_id, category_id)
    SELECT v_id, rc.id FROM repair_categories rc WHERE rc.category_code = ANY(v_repair_codes)
    ON CONFLICT DO NOTHING;

    INSERT INTO submission_household_attributes (submission_id, attribute_id)
    SELECT v_id, ha.id FROM household_attributes ha WHERE ha.attribute_name = ANY(v_attr_codes)
    ON CONFLICT DO NOTHING;

    INSERT INTO submission_contact_methods (submission_id, method_id)
    SELECT v_id, cm.id FROM contact_methods cm
     WHERE cm.method_code = ANY(ARRAY(SELECT jsonb_array_elements_text(COALESCE(p_config->'contact_methods', '["email"]'::jsonb))))
    ON CONFLICT DO NOTHING;

    -- Applicant-reported repair rows (Repairs Needed list)
    FOR v_repair IN SELECT * FROM jsonb_array_elements(COALESCE(p_config->'repairs', '[]'::jsonb)) LOOP
        v_i := v_i + 1;
        INSERT INTO repair_requests (submission_id, repair_need, priority, sort_order)
        SELECT v_id, v_repair->>'need', (v_repair->>'priority')::INTEGER, v_i;
    END LOOP;

    -- Calculator-method income rows
    FOR v_inc IN SELECT * FROM jsonb_array_elements(COALESCE(p_config->'income_records', '[]'::jsonb)) LOOP
        INSERT INTO income_records (submission_id, whose_income, income_source, frequency, amount, created_at)
        VALUES (v_id, v_inc->>'whose', v_inc->>'source', v_inc->>'frequency', (v_inc->>'amount')::NUMERIC, v_submitted_at);
    END LOOP;

    -- ---- Real lifecycle: placecode -> application -> anchor -> queue -> case -> flags ----
    v_placecode := archr_generate_placecode(v_address);
    UPDATE intake_submissions SET placecode = v_placecode WHERE id = v_id;
    v_app_id := deduplicate_submissions(v_id);

    v_project_code := CASE WHEN v_placecode IS NULL THEN NULL
                           ELSE (CASE WHEN v_home_type = 'mobile' THEN 'H' WHEN v_helene THEN 'D' ELSE 'A' END) || v_placecode
                      END;

    INSERT INTO application_anchor (
        submission_id, submitted_at, submitted_from_ip,
        is_eligible, current_status,
        income_bucket, county_bucket, repair_type_bucket, helene_related,
        placecode, project_code
    ) VALUES (
        v_id, v_submitted_at, '127.0.0.1',
        TRUE, 'eligible',
        get_income_bucket(v_income), get_county_bucket(v_city, v_zip),
        v_repair_codes[1], v_helene,
        v_placecode, v_project_code
    );

    INSERT INTO review_queue (submission_id, status, queued_at, priority_score)
    VALUES (v_id, 'PENDING_REVIEW', v_submitted_at, 10 * COALESCE(array_length(v_urgent_codes, 1), 0));

    -- One unclaimed intake case per application (first claiming org adopts it).
    SELECT id INTO v_status_id FROM case_statuses WHERE status_code = 'PENDING_REVIEW' LIMIT 1;
    IF v_status_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM cases WHERE application_id = v_app_id AND organization_id IS NULL
    ) THEN
        INSERT INTO cases (submission_id, application_id, status_id, project_code, placecode, created_at, updated_at)
        VALUES (v_id, v_app_id, v_status_id, v_project_code, v_placecode, v_submitted_at, v_submitted_at);
    END IF;

    -- Flags-only eligibility (green/yellow/red; stored on the application).
    PERFORM check_eligibility(v_id);

    RETURN v_id;
END;
$$;


--
-- Name: send_daily_digest(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.send_daily_digest() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_user RECORD;
    v_digest_count INTEGER := 0;
    v_digest_body TEXT;
BEGIN
    FOR v_user IN 
        SELECT DISTINCT u.id, u.email, u.full_name
        FROM system_users u
        JOIN user_role_assignments ura ON u.id = ura.user_id
        WHERE u.email_digest_enabled = TRUE
          AND u.is_active = TRUE
    LOOP
        -- Build digest content
        WITH user_notifications AS (
            SELECT * FROM get_unread_notifications(v_user.id, 50)
        ),
        pending_applications AS (
            SELECT COUNT(*) AS pending_count
            FROM review_queue rq
            WHERE rq.status = 'PENDING_REVIEW'
        )
        SELECT 
            'Daily Digest - ' || CURRENT_DATE || E'\n\n' ||
            'Pending Applications: ' || pending_count || E'\n\n' ||
            'Your Notifications:\n' ||
            string_agg('- ' || n.title || ' (' || n.created_at::DATE || ')', E'\n')
        INTO v_digest_body
        FROM pending_applications, user_notifications n;
        
        -- Queue digest email
        INSERT INTO email_queue (
            recipient_email, recipient_name, subject, body,
            notification_type, priority
        ) VALUES (
            v_user.email,
            v_user.full_name,
            '[ARCHR] Daily Digest - ' || CURRENT_DATE,
            v_digest_body,
            'daily_digest',
            5 -- Lower priority, send after urgent emails
        );
        
        v_digest_count := v_digest_count + 1;
    END LOOP;
    
    RETURN v_digest_count;
END;
$$;


--
-- Name: set_application_status(integer, character varying, text, text[], integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_application_status(p_application_id integer, p_new_status character varying, p_reason text DEFAULT NULL::text, p_checkboxes text[] DEFAULT NULL::text[], p_changed_by integer DEFAULT NULL::integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: submit_intake_application(jsonb, boolean, character varying, character varying, inet, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.submit_intake_application(p_form_data jsonb, p_create_account boolean DEFAULT false, p_email character varying DEFAULT NULL::character varying, p_password_hash character varying DEFAULT NULL::character varying, p_ip_address inet DEFAULT NULL::inet, p_user_agent text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_submission_id INTEGER;
    v_user_id INTEGER;
    v_case_id INTEGER;
    v_result JSONB;
    v_eligibility_result JSONB;
BEGIN
        -- 1. Insert the intake submission
        INSERT INTO intake_submissions (
            language, is_referral, referrer_name, referrer_organization,
            referrer_email, referrer_notes, consent_agreed,
            applicant_first_name, applicant_last_name, applicant_dob,
            applicant_dob_unknown, home_phone, cell_phone, contact_email,
            other_contact_method_description, contact_notes,
            home_address, home_city, home_state, home_zip,
            is_primary_residence, receives_different_mail,
            mail_address, mail_city, mail_state, mail_zip,
            home_type, year_built, move_in_date, owns_home, owns_lot,
            insurance_provider, lived_one_year, household_size, household_adults,
            additional_repair_details, helene_related, has_income,
            income_method, gross_annual_income, income_docs_method,
            submission_status, submitted_at, ip_address, user_agent
        ) VALUES (
            p_form_data->>'language',
            (p_form_data->>'isReferral') = 'yes',
            p_form_data->>'referrerName',
            p_form_data->>'referrerOrganization',
            p_form_data->>'referrerEmail',
            p_form_data->>'referrerNotes',
            (p_form_data->>'consentAgree') = 'yes',
            p_form_data->>'applicantFirstName',
            p_form_data->>'applicantLastName',
            (p_form_data->>'applicantDob')::DATE,
            (p_form_data->>'applicantDobUnknown') = 'yes',
            p_form_data->>'homePhone',
            p_form_data->>'cellPhone',
            p_form_data->>'contactEmail',
            p_form_data->>'otherContactMethod',
            p_form_data->>'contactNotes',
            p_form_data->>'homeAddress',
            p_form_data->>'homeCity',
            p_form_data->>'homeState',
            p_form_data->>'homeZip',
            (p_form_data->>'isPrimaryResidence') = 'yes',
            (p_form_data->>'receivesDifferentMail') = 'yes',
            p_form_data->>'mailAddress',
            p_form_data->>'mailCity',
            p_form_data->>'mailState',
            p_form_data->>'mailZip',
            p_form_data->>'homeType',
            (p_form_data->>'yearBuilt')::INTEGER,
            (p_form_data->>'moveInDate')::DATE,
            (p_form_data->>'ownsHome') = 'yes',
            (p_form_data->>'ownsLot') = 'yes',
            p_form_data->>'insuranceProvider',
            (p_form_data->>'livedOneYear') = 'yes',
            (p_form_data->>'householdSize')::INTEGER,
            (p_form_data->>'householdAdults')::INTEGER,
            p_form_data->>'additionalRepairDetails',
            (p_form_data->>'heleneRelated') = 'yes',
            (p_form_data->>'haveIncome') = 'yes',
            p_form_data->>'incomeMethod',
            (p_form_data->>'grossAnnualIncome')::DECIMAL,
            p_form_data->>'incomeDocsMethod',
            'PENDING_ELIGIBILITY', -- Initial status
            CURRENT_TIMESTAMP,
            p_ip_address,
            p_user_agent
        )
        RETURNING id INTO v_submission_id;
        
        -- 2. Insert contact methods (preferredContact[] array)
        IF p_form_data->'preferredContact' IS NOT NULL THEN
            INSERT INTO submission_contact_methods (submission_id, method_id)
            SELECT v_submission_id, cm.id
            FROM jsonb_array_elements_text(p_form_data->'preferredContact') AS method_code
            JOIN contact_methods cm ON cm.method_code = method_code;
        END IF;
        
        -- 3. Insert household attributes
        IF p_form_data->'householdAttributes' IS NOT NULL THEN
            INSERT INTO submission_household_attributes (submission_id, attribute_id)
            SELECT v_submission_id, ha.id
            FROM jsonb_array_elements_text(p_form_data->'householdAttributes') AS attr_name
            JOIN household_attributes ha ON ha.attribute_name = attr_name;
        END IF;
        
        -- 4. Insert repair categories
        IF p_form_data->'repairCategory' IS NOT NULL THEN
            INSERT INTO submission_repair_categories (submission_id, category_id)
            SELECT v_submission_id, rc.id
            FROM jsonb_array_elements_text(p_form_data->'repairCategory') AS cat_code
            JOIN repair_categories rc ON rc.category_code = cat_code;
        END IF;
        
        -- 5. Insert repair requests (dynamic rows)
        IF p_form_data->'repairNeeds' IS NOT NULL THEN
            FOR i IN 0..jsonb_array_length(p_form_data->'repairNeeds') - 1 LOOP
                INSERT INTO repair_requests (
                    submission_id, repair_need, priority, sort_order
                ) VALUES (
                    v_submission_id,
                    p_form_data->'repairNeeds'->i->>'need',
                    (p_form_data->'repairNeeds'->i->>'priority')::INTEGER,
                    i
                );
            END LOOP;
        END IF;
        
        -- 6. Insert income records if using calculator
        IF p_form_data->'incomeRecords' IS NOT NULL THEN
            INSERT INTO income_records (
                submission_id, whose_income, income_source, frequency, amount
            )
            SELECT 
                v_submission_id,
                record->>'whose',
                record->>'source',
                record->>'frequency',
                (record->>'amount')::DECIMAL
            FROM jsonb_array_elements(p_form_data->'incomeRecords') AS record;
        END IF;
        
        -- 7. Optional: Create requestor account
        IF p_create_account = TRUE AND p_email IS NOT NULL THEN
            -- Check if user already exists
            SELECT id INTO v_user_id FROM system_users WHERE email = p_email;
            
            IF v_user_id IS NULL THEN
                -- Create new user
                INSERT INTO system_users (email, full_name, password_hash, created_at)
                VALUES (
                    p_email,
                    p_form_data->>'applicantFirstName' || ' ' || p_form_data->>'applicantLastName',
                    crypt(p_password_hash, gen_salt('bf')), -- bcrypt hash
                    CURRENT_TIMESTAMP
                )
                RETURNING id INTO v_user_id;
                
                -- Assign Requestor role
                INSERT INTO user_role_assignments (user_id, organization_id, role_id, assigned_at)
                SELECT v_user_id, NULL, id, CURRENT_TIMESTAMP
                FROM roles WHERE role_code = 'REQUESTOR';
                
                -- Create requestor profile
                INSERT INTO requestor_profiles (user_id, created_at)
                VALUES (v_user_id, CURRENT_TIMESTAMP);
                
            END IF;
            
            -- Link submission to user
            UPDATE intake_submissions 
            SET requestor_user_id = v_user_id 
            WHERE id = v_submission_id;
        END IF;
        
        -- 8. Run eligibility checker (see Phase 2)
        v_eligibility_result := check_eligibility(v_submission_id);
        
        -- 9. ANCHOR: Register application (always, regardless of eligibility)
        PERFORM register_application_anchor(v_submission_id, v_eligibility_result);
        
        -- 10. Trigger notifications (see Phase 3)
        PERFORM trigger_new_application_notifications(v_submission_id);
        
        -- 11. Add to review queue
        INSERT INTO review_queue (submission_id, status, queued_at, fifo_order)
        VALUES (
            v_submission_id, 
            CASE WHEN (v_eligibility_result->>'is_eligible')::BOOLEAN 
                 THEN 'PENDING_REVIEW' 
                 ELSE 'INELIGIBLE' 
            END,
            CURRENT_TIMESTAMP,
            nextval('fifo_sequence')
        );
        
        -- Build success response (caller's transaction commits implicitly)
        v_result := jsonb_build_object(
            'success', true,
            'submission_id', v_submission_id,
            'case_number', (SELECT case_number FROM cases WHERE submission_id = v_submission_id),
            'eligibility', v_eligibility_result,
            'has_account', p_create_account,
            'dashboard_url', CASE WHEN p_create_account 
                THEN '/dashboard/' || v_user_id 
                ELSE '/status/' || v_submission_id 
            END
        );
        
        RETURN v_result;

EXCEPTION WHEN OTHERS THEN
    -- plpgsql functions auto-rollback when an exception propagates out of
    -- the block; returning here keeps the caller (PHP) happy with a
    -- structured error instead of a 500.
    RETURN jsonb_build_object(
        'success', false,
        'error', SQLERRM,
        'detail', SQLSTATE
    );
END;
$$;


--
-- Name: trigger_new_application_notifications(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_new_application_notifications(p_submission_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_submission RECORD;
    v_role_codes VARCHAR[] := ARRAY['ADMIN', 'CASEWORKER', 'PROJECT_MANAGER', 'BURSAR'];
    v_role_id INTEGER;
    v_user RECORD;
BEGIN
    SELECT * INTO v_submission FROM intake_submissions WHERE id = p_submission_id;
    
    -- Notify all users with relevant roles
    FOR v_user IN 
        SELECT DISTINCT u.id, u.email, u.full_name, ura.role_id
        FROM system_users u
        JOIN user_role_assignments ura ON u.id = ura.user_id
        JOIN roles r ON ura.role_id = r.id
        WHERE r.role_code = ANY(v_role_codes)
          AND u.is_active = TRUE
    LOOP
        -- In-app notification
        INSERT INTO notifications (
            user_id, 
            notification_type, 
            title, 
            body, 
            entity_type, 
            entity_id,
            priority
        ) VALUES (
            v_user.id,
            'new_application',
            'New Application Submitted',
            'Application #' || v_submission.id || ' from ' || 
            v_submission.applicant_first_name || ' ' || v_submission.applicant_last_name,
            'submission',
            p_submission_id,
            'high'
        );
        
        -- Email notification (batch send, not per-record)
        -- Would be handled by a separate email worker
    END LOOP;
    
    -- Also trigger webhook for external integrations
    PERFORM trigger_webhook('new_application', p_submission_id);
END;
$$;


--
-- Name: update_case_timestamp(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_case_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


--
-- Name: update_help_doc_timestamp(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_help_doc_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


--
-- Name: update_organization_metrics(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_organization_metrics() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO organization_metrics (
        organization_id, metric_date,
        applications_assigned, applications_claimed, 
        applications_rejected, applications_completed,
        avg_time_to_claim_hours, avg_match_score
    )
    SELECT 
        o.id,
        CURRENT_DATE,
        COUNT(CASE WHEN aa.status IN ('pending', 'claimed', 'rejected', 'completed') THEN 1 END),
        COUNT(CASE WHEN aa.status = 'claimed' THEN 1 END),
        COUNT(CASE WHEN aa.status = 'rejected' THEN 1 END),
        COUNT(CASE WHEN aa.status = 'completed' THEN 1 END),
        AVG(EXTRACT(EPOCH FROM (aa.claimed_at - aa.assigned_at))/3600),
        AVG(aa.match_score)
    FROM coalition_organizations o
    LEFT JOIN application_assignments aa ON o.id = aa.organization_id
        AND aa.assigned_at >= CURRENT_DATE - INTERVAL '30 days'
    WHERE o.is_active = true
    GROUP BY o.id
    ON CONFLICT (organization_id, metric_date) DO UPDATE SET
        applications_assigned = EXCLUDED.applications_assigned,
        applications_claimed = EXCLUDED.applications_claimed,
        applications_rejected = EXCLUDED.applications_rejected,
        applications_completed = EXCLUDED.applications_completed,
        avg_time_to_claim_hours = EXCLUDED.avg_time_to_claim_hours,
        avg_match_score = EXCLUDED.avg_match_score,
        updated_at = CURRENT_TIMESTAMP;
END;
$$;


--
-- Name: user_has_permission(integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.user_has_permission(p_user_id integer, p_permission_code character varying, p_organization_id integer DEFAULT NULL::integer) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_has_permission BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1
        FROM user_role_assignments ura
        JOIN role_permissions rp ON ura.role_id = rp.role_id
        JOIN permissions p ON rp.permission_id = p.id
        WHERE ura.user_id = p_user_id
            AND p.permission_code = p_permission_code
            AND ura.is_active = true
            AND (p_organization_id IS NULL OR ura.organization_id = p_organization_id)
            AND (ura.expires_at IS NULL OR ura.expires_at > CURRENT_TIMESTAMP)
    ) INTO v_has_permission;
    
    RETURN v_has_permission;
END;
$$;


--
-- Name: validate_document_name(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_document_name(p_filename character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
BEGIN
    -- Check pattern: {case_number}_{doc_type}_{version_or_date}_{optional}.{ext}
    RETURN p_filename ~ '^ARCHR-\d{4}-\d{6}_[A-Z]{2,5}_[v\d+|YYYYMMDD](_[a-z0-9_]+)?\.(pdf|jpg|jpeg|png|json|docx)$';
END;
$_$;


--
-- Name: validate_guest_access(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_guest_access(p_token uuid) RETURNS TABLE(valid boolean, submission_id integer, case_number character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        gat.expires_at > CURRENT_TIMESTAMP AS valid,
        s.id,
        c.case_number
    FROM guest_access_tokens gat
    JOIN intake_submissions s ON gat.submission_id = s.id
    LEFT JOIN cases c ON s.id = c.submission_id
    WHERE gat.token = p_token;
    
    -- Update last accessed
    UPDATE guest_access_tokens 
    SET last_accessed = CURRENT_TIMESTAMP
    WHERE token = p_token;
END;
$$;


--
-- Name: validate_status_transition(integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_status_transition(p_application_id integer, p_new_status character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: version_help_document(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.version_help_document() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Store old version if content changed significantly
    IF OLD.content IS DISTINCT FROM NEW.content OR OLD.title IS DISTINCT FROM NEW.title THEN
        INSERT INTO help_document_versions (
            document_id, version_number, title, content, change_notes, 
            created_by, created_at, is_current
        ) VALUES (
            OLD.id, OLD.version, OLD.title, OLD.content, OLD.change_notes,
            OLD.updated_by, OLD.updated_at, false
        );
    END IF;
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activity_detail; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activity_detail (
    id bigint NOT NULL,
    event_guid uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expires_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP + '30 days'::interval) NOT NULL,
    ledger_id bigint,
    user_id integer,
    user_name character varying(200),
    session_id character varying(128),
    ip_address inet,
    application_id integer,
    case_id integer,
    action character varying(100) NOT NULL,
    field_name character varying(100),
    old_value text,
    new_value text,
    details jsonb DEFAULT '{}'::jsonb NOT NULL,
    source character varying(50) DEFAULT 'web'::character varying NOT NULL,
    prev_hash character(64),
    entry_hash character(64) NOT NULL
);


--
-- Name: activity_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.activity_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activity_detail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.activity_detail_id_seq OWNED BY public.activity_detail.id;


--
-- Name: activity_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activity_log (
    id bigint NOT NULL,
    event_guid uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    user_id integer,
    user_name character varying(200),
    session_id character varying(128),
    ip_address inet,
    application_id integer,
    case_id integer,
    organization_id integer,
    category character varying(50) NOT NULL,
    action character varying(100) NOT NULL,
    summary text,
    details jsonb DEFAULT '{}'::jsonb NOT NULL,
    source character varying(50) DEFAULT 'web'::character varying NOT NULL,
    prev_hash character(64),
    entry_hash character(64) NOT NULL
);


--
-- Name: activity_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.activity_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activity_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.activity_log_id_seq OWNED BY public.activity_log.id;


--
-- Name: coalition_organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.coalition_organizations (
    id integer NOT NULL,
    organization_code character varying(20) NOT NULL,
    organization_name character varying(200) NOT NULL,
    description text,
    website_url character varying(255),
    contact_email character varying(255),
    contact_phone character varying(20),
    logo_url character varying(255),
    is_active boolean DEFAULT true,
    max_active_applications integer DEFAULT 50,
    auto_claim_enabled boolean DEFAULT false,
    notification_email character varying(255),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(100),
    updated_by character varying(100),
    funding_limit numeric(12,2)
);


--
-- Name: COLUMN coalition_organizations.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.coalition_organizations.description IS 'Public/internal description of the organization';


--
-- Name: COLUMN coalition_organizations.funding_limit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.coalition_organizations.funding_limit IS 'Maximum funding this organization can commit to repairs';


--
-- Name: eligibility_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eligibility_results (
    id integer NOT NULL,
    submission_id integer,
    organization_id integer,
    match_score integer,
    is_eligible boolean,
    checked_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: fifo_sequence; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fifo_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: intake_submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.intake_submissions (
    id integer NOT NULL,
    submission_uuid uuid DEFAULT gen_random_uuid(),
    submitted_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    language character varying(3) DEFAULT 'eng'::character varying,
    is_referral boolean,
    referrer_name character varying(255),
    referrer_organization character varying(255),
    referrer_email character varying(255),
    referrer_notes text,
    consent_agreed boolean,
    applicant_first_name character varying(100),
    applicant_last_name character varying(100),
    applicant_dob date,
    applicant_dob_unknown boolean DEFAULT false,
    preferred_phone boolean DEFAULT false,
    preferred_text boolean DEFAULT false,
    preferred_email boolean DEFAULT false,
    preferred_other boolean DEFAULT false,
    home_phone character varying(20),
    cell_phone character varying(20),
    contact_email character varying(255),
    other_contact_method_description character varying(500),
    contact_notes text,
    home_address character varying(500),
    home_city character varying(100),
    home_state character varying(50),
    home_zip character varying(20),
    is_primary_residence boolean,
    receives_different_mail boolean,
    mail_address character varying(500),
    mail_city character varying(100),
    mail_state character varying(50),
    mail_zip character varying(20),
    home_type character varying(50),
    year_built integer,
    move_in_date date,
    owns_home boolean,
    owns_lot boolean,
    insurance_provider character varying(255),
    lived_one_year boolean,
    household_size integer,
    household_adults integer,
    additional_repair_details text,
    urgent_unable_to_stay boolean DEFAULT false,
    urgent_no_hvac boolean DEFAULT false,
    urgent_no_potable_water boolean DEFAULT false,
    urgent_no_bathroom boolean DEFAULT false,
    urgent_no_kitchen boolean DEFAULT false,
    urgent_open_to_elements boolean DEFAULT false,
    urgent_no_entry boolean DEFAULT false,
    urgent_accessibility boolean DEFAULT false,
    urgent_other_issue boolean DEFAULT false,
    urgent_eviction_risk boolean DEFAULT false,
    helene_related boolean,
    fema_claim_filed boolean,
    fema_outcome character varying(20),
    fema_settlement_amount numeric(12,2),
    fema_remaining_exists boolean,
    fema_remaining_amount numeric(12,2),
    insurance_claim_filed boolean,
    insurance_outcome character varying(20),
    insurance_settlement_amount numeric(12,2),
    insurance_remaining_exists boolean,
    insurance_remaining_amount numeric(12,2),
    has_income boolean,
    income_method character varying(10),
    gross_annual_income numeric(12,2),
    income_docs_method character varying(20),
    zero_income_first_name character varying(100),
    zero_income_last_name character varying(100),
    zero_income_address character varying(500),
    zero_income_agreed boolean,
    applicant_signature text,
    zero_income_signature text,
    submission_status character varying(20) DEFAULT 'pending'::character varying,
    assigned_organization character varying(100),
    reviewed_by character varying(100),
    reviewed_at timestamp without time zone,
    eligibility_checked_at timestamp without time zone,
    is_test boolean DEFAULT false,
    requestor_user_id integer,
    placecode character varying(10),
    is_duplicate boolean DEFAULT false,
    deduplicated_into integer,
    disqualification_reasons text[],
    eligibility_warnings text[]
);


--
-- Name: COLUMN intake_submissions.requestor_user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.intake_submissions.requestor_user_id IS 'Link to system_users table for requestor portal access. Set automatically on submission.';


--
-- Name: repair_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repair_categories (
    id integer NOT NULL,
    category_code character varying(50) NOT NULL,
    category_label character varying(100) NOT NULL
);


--
-- Name: review_queue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.review_queue (
    id integer NOT NULL,
    submission_id integer,
    fifo_order bigint DEFAULT nextval('public.fifo_sequence'::regclass),
    status character varying(50) DEFAULT 'PENDING_REVIEW'::character varying,
    assigned_to_id integer,
    assigned_at timestamp without time zone,
    organization_id integer,
    queued_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    reviewed_at timestamp without time zone,
    completed_at timestamp without time zone,
    priority_score integer DEFAULT 0,
    notes text
);


--
-- Name: submission_repair_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.submission_repair_categories (
    submission_id integer NOT NULL,
    category_id integer NOT NULL
);


--
-- Name: staff_review_queue; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.staff_review_queue AS
 SELECT rq.fifo_order,
    s.id AS submission_id,
    s.applicant_first_name,
    s.applicant_last_name,
    s.home_address,
    s.submitted_at,
    s.helene_related,
    rq.status,
    rq.priority_score,
    (EXTRACT(epoch FROM (CURRENT_TIMESTAMP - (rq.queued_at)::timestamp with time zone)) / (3600)::numeric) AS hours_in_queue,
    ( SELECT rc.category_label
           FROM (public.submission_repair_categories src
             JOIN public.repair_categories rc ON ((src.category_id = rc.id)))
          WHERE (src.submission_id = s.id)
          ORDER BY src.category_id
         LIMIT 1) AS primary_issue,
    ( SELECT count(*) AS count
           FROM (public.submission_repair_categories src
             JOIN public.repair_categories rc ON ((src.category_id = rc.id)))
          WHERE ((src.submission_id = s.id) AND ((rc.category_code)::text = ANY ((ARRAY['unable_to_stay'::character varying, 'no_hvac'::character varying, 'no_potable_water'::character varying])::text[])))) AS urgent_count,
    er.is_eligible,
    er.match_score AS best_match_score,
    co.organization_name AS best_match_org
   FROM (((public.review_queue rq
     JOIN public.intake_submissions s ON ((rq.submission_id = s.id)))
     LEFT JOIN public.eligibility_results er ON ((s.id = er.submission_id)))
     LEFT JOIN public.coalition_organizations co ON ((er.organization_id = co.id)))
  WHERE ((rq.status)::text = ANY ((ARRAY['PENDING_REVIEW'::character varying, 'IN_REVIEW'::character varying])::text[]))
  ORDER BY rq.priority_score DESC, rq.fifo_order;


--
-- Name: admin_review_queue; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.admin_review_queue AS
 SELECT fifo_order,
    submission_id,
    applicant_first_name,
    applicant_last_name,
    home_address,
    submitted_at,
    helene_related,
    status,
    priority_score,
    hours_in_queue,
    primary_issue,
    urgent_count,
    is_eligible,
    best_match_score,
    best_match_org
   FROM public.staff_review_queue;


--
-- Name: application_anchor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_anchor (
    id integer NOT NULL,
    submission_id integer,
    anchor_id character varying(50) NOT NULL,
    case_number character varying(50),
    submitted_at timestamp without time zone NOT NULL,
    submitted_from_ip inet,
    is_eligible boolean,
    disqualification_reasons text[],
    eligibility_score integer,
    current_status character varying(50),
    assigned_organization_id integer,
    assigned_at timestamp without time zone,
    income_bucket character varying(50),
    county_bucket character varying(50),
    repair_type_bucket character varying(50),
    helene_related boolean,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    placecode character varying(10),
    project_code character varying(11)
);


--
-- Name: application_anchor_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.application_anchor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: application_anchor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.application_anchor_id_seq OWNED BY public.application_anchor.id;


--
-- Name: application_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_assignments (
    id integer NOT NULL,
    submission_id integer,
    organization_id integer,
    status character varying(20) DEFAULT 'pending'::character varying,
    match_score integer,
    claimed_by integer,
    claimed_at timestamp without time zone,
    rejected_by integer,
    rejected_at timestamp without time zone,
    rejection_reason text,
    assigned_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    expires_at timestamp without time zone,
    notes text
);


--
-- Name: application_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.application_assignments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: application_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.application_assignments_id_seq OWNED BY public.application_assignments.id;


--
-- Name: criteria_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.criteria_types (
    id integer NOT NULL,
    type_code character varying(50) NOT NULL,
    type_name character varying(100) NOT NULL,
    input_type character varying(20) NOT NULL,
    description text
);


--
-- Name: household_attributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.household_attributes (
    id integer NOT NULL,
    attribute_name character varying(50) NOT NULL
);


--
-- Name: organization_eligibility_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_eligibility_rules (
    id integer NOT NULL,
    organization_id integer,
    criteria_type_id integer,
    rule_operator character varying(10) DEFAULT 'equals'::character varying,
    rule_value text NOT NULL,
    priority integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: submission_household_attributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.submission_household_attributes (
    submission_id integer NOT NULL,
    attribute_id integer NOT NULL
);


--
-- Name: application_match_scores; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.application_match_scores AS
 WITH application_data AS (
         SELECT s.id AS submission_id,
            s.owns_home,
            s.home_type,
            s.is_primary_residence,
            s.household_size,
            s.move_in_date,
            s.helene_related,
            (s.urgent_unable_to_stay OR s.urgent_no_hvac OR s.urgent_no_potable_water OR s.urgent_no_bathroom OR s.urgent_no_kitchen OR s.urgent_open_to_elements OR s.urgent_no_entry) AS is_urgent,
            s.gross_annual_income,
            s.insurance_claim_filed,
            s.fema_claim_filed,
            s.home_city,
            s.home_state,
            s.home_zip,
            s.household_adults,
            ( SELECT array_agg(rc.category_code) AS array_agg
                   FROM (public.submission_repair_categories src
                     JOIN public.repair_categories rc ON ((src.category_id = rc.id)))
                  WHERE (src.submission_id = s.id)) AS repair_categories,
            ( SELECT array_agg(ha.attribute_name) AS array_agg
                   FROM (public.submission_household_attributes sha
                     JOIN public.household_attributes ha ON ((sha.attribute_id = ha.id)))
                  WHERE (sha.submission_id = s.id)) AS household_attributes,
            EXTRACT(year FROM age((CURRENT_DATE)::timestamp with time zone, (s.applicant_dob)::timestamp with time zone)) AS applicant_age
           FROM public.intake_submissions s
          WHERE ((s.submission_status)::text = 'pending'::text)
        ), organization_criteria AS (
         SELECT o.id AS organization_id,
            o.organization_name,
            o.max_active_applications,
            o.auto_claim_enabled,
            jsonb_object_agg(ct.type_code, jsonb_build_object('operator', er.rule_operator, 'value', er.rule_value)) FILTER (WHERE (er.id IS NOT NULL)) AS criteria_map,
            count(DISTINCT aa.id) AS current_active_applications
           FROM (((public.coalition_organizations o
             LEFT JOIN public.organization_eligibility_rules er ON (((o.id = er.organization_id) AND (er.is_active = true))))
             LEFT JOIN public.criteria_types ct ON ((er.criteria_type_id = ct.id)))
             LEFT JOIN public.application_assignments aa ON (((o.id = aa.organization_id) AND ((aa.status)::text = ANY ((ARRAY['pending'::character varying, 'claimed'::character varying])::text[])) AND (aa.expires_at > CURRENT_TIMESTAMP))))
          WHERE (o.is_active = true)
          GROUP BY o.id, o.organization_name, o.max_active_applications, o.auto_claim_enabled
        )
 SELECT ad.submission_id,
    oc.organization_id,
    oc.organization_name,
    oc.current_active_applications,
    oc.max_active_applications,
    oc.auto_claim_enabled,
        CASE
            WHEN ((oc.criteria_map -> 'income_max'::text) IS NOT NULL) THEN (ad.gross_annual_income <= (((oc.criteria_map -> 'income_max'::text) ->> 'value'::text))::numeric)
            ELSE true
        END AS income_max_met,
        CASE
            WHEN ((oc.criteria_map -> 'income_min'::text) IS NOT NULL) THEN (ad.gross_annual_income >= (((oc.criteria_map -> 'income_min'::text) ->> 'value'::text))::numeric)
            ELSE true
        END AS income_min_met,
        CASE
            WHEN ((oc.criteria_map -> 'homeowner_status'::text) IS NOT NULL) THEN
            CASE ((oc.criteria_map -> 'homeowner_status'::text) ->> 'value'::text)
                WHEN 'yes'::text THEN (ad.owns_home = true)
                WHEN 'no'::text THEN (ad.owns_home = false)
                ELSE true
            END
            ELSE true
        END AS homeowner_status_met,
        CASE
            WHEN ((oc.criteria_map -> 'home_type_allowed'::text) IS NOT NULL) THEN ((ad.home_type)::text = ANY (string_to_array(((oc.criteria_map -> 'home_type_allowed'::text) ->> 'value'::text), ','::text)))
            ELSE true
        END AS home_type_met,
        CASE
            WHEN ((oc.criteria_map -> 'primary_residence_required'::text) IS NOT NULL) THEN (ad.is_primary_residence = (((oc.criteria_map -> 'primary_residence_required'::text) ->> 'value'::text))::boolean)
            ELSE true
        END AS primary_residence_met,
        CASE
            WHEN ((oc.criteria_map -> 'geography_zipcodes'::text) IS NOT NULL) THEN ((ad.home_zip)::text = ANY (string_to_array(((oc.criteria_map -> 'geography_zipcodes'::text) ->> 'value'::text), ','::text)))
            ELSE true
        END AS geography_zip_met,
        CASE
            WHEN ((oc.criteria_map -> 'helene_damage_only'::text) IS NOT NULL) THEN (ad.helene_related = (((oc.criteria_map -> 'helene_damage_only'::text) ->> 'value'::text))::boolean)
            ELSE true
        END AS helene_condition_met,
        CASE
            WHEN ((oc.criteria_map -> 'urgent_only'::text) IS NOT NULL) THEN (ad.is_urgent = (((oc.criteria_map -> 'urgent_only'::text) ->> 'value'::text))::boolean)
            ELSE true
        END AS urgent_only_met,
        CASE
            WHEN ((oc.criteria_map -> 'veteran_only'::text) IS NOT NULL) THEN ('veteran'::text = ANY ((ad.household_attributes)::text[]))
            ELSE true
        END AS veteran_condition_met,
        CASE
            WHEN ((oc.criteria_map -> 'disability_only'::text) IS NOT NULL) THEN ('person_with_disability'::text = ANY ((ad.household_attributes)::text[]))
            ELSE true
        END AS disability_condition_met,
    round(((((((
        CASE
            WHEN ((oc.criteria_map -> 'income_max'::text) IS NOT NULL) THEN
            CASE
                WHEN (ad.gross_annual_income <= (((oc.criteria_map -> 'income_max'::text) ->> 'value'::text))::numeric) THEN 1
                ELSE 0
            END
            ELSE 1
        END)::numeric * (
        CASE
            WHEN ((oc.criteria_map -> 'income_min'::text) IS NOT NULL) THEN
            CASE
                WHEN (ad.gross_annual_income >= (((oc.criteria_map -> 'income_min'::text) ->> 'value'::text))::numeric) THEN 1
                ELSE 0
            END
            ELSE 1
        END)::numeric) * (
        CASE
            WHEN ((oc.criteria_map -> 'homeowner_status'::text) IS NOT NULL) THEN
            CASE
                WHEN (ad.owns_home = (((oc.criteria_map -> 'homeowner_status'::text) ->> 'value'::text) = 'yes'::text)) THEN 1
                ELSE 0
            END
            ELSE 1
        END)::numeric) * (
        CASE
            WHEN ((oc.criteria_map -> 'home_type_allowed'::text) IS NOT NULL) THEN
            CASE
                WHEN ((ad.home_type)::text = ANY (string_to_array(((oc.criteria_map -> 'home_type_allowed'::text) ->> 'value'::text), ','::text))) THEN 1
                ELSE 0
            END
            ELSE 1
        END)::numeric) * (
        CASE
            WHEN ((oc.criteria_map -> 'primary_residence_required'::text) IS NOT NULL) THEN
            CASE
                WHEN (ad.is_primary_residence = (((oc.criteria_map -> 'primary_residence_required'::text) ->> 'value'::text))::boolean) THEN 1
                ELSE 0
            END
            ELSE 1
        END)::numeric) * (100)::numeric), 0) AS match_score,
    (oc.current_active_applications < oc.max_active_applications) AS has_capacity
   FROM (application_data ad
     CROSS JOIN organization_criteria oc)
  WHERE ((oc.current_active_applications < oc.max_active_applications) AND (NOT (EXISTS ( SELECT 1
           FROM public.application_assignments aa
          WHERE ((aa.submission_id = ad.submission_id) AND (aa.organization_id = oc.organization_id) AND ((aa.status)::text = ANY ((ARRAY['claimed'::character varying, 'rejected'::character varying])::text[])))))))
  WITH NO DATA;


--
-- Name: applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.applications (
    id integer NOT NULL,
    application_guid uuid DEFAULT gen_random_uuid(),
    placecode character varying(50),
    display_name character varying(255),
    property_address text,
    property_city character varying(100),
    property_state character varying(50),
    property_zip character varying(20),
    applicant_first_name character varying(100),
    applicant_last_name character varying(100),
    applicant_email character varying(255),
    applicant_phone character varying(20),
    household_size integer,
    status character varying(20) DEFAULT 'new'::character varying,
    status_reason text,
    terminated_reason_checkboxes text[],
    eligibility_flags jsonb DEFAULT '{"red": [], "green": [], "yellow": []}'::jsonb,
    eligibility_report text,
    consolidated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    consolidated_by integer,
    last_activity_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    workflow_status text,
    consent_agreed boolean
);


--
-- Name: applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.applications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.applications_id_seq OWNED BY public.applications.id;


--
-- Name: assessment_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment_documents (
    id bigint NOT NULL,
    assessment_id bigint NOT NULL,
    document_type character varying(40) NOT NULL,
    file_path text NOT NULL,
    file_name text NOT NULL,
    file_size bigint,
    mime_type character varying(100),
    uploaded_at timestamp with time zone DEFAULT now() NOT NULL,
    uploaded_by bigint,
    metadata jsonb DEFAULT '{}'::jsonb
);


--
-- Name: assessment_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assessment_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assessment_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assessment_documents_id_seq OWNED BY public.assessment_documents.id;


--
-- Name: assessment_notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment_notes (
    id integer NOT NULL,
    assessment_id integer,
    author_id integer,
    note_type character varying(50),
    content text NOT NULL,
    is_public boolean DEFAULT false,
    is_action_item boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: assessment_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assessment_notes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assessment_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assessment_notes_id_seq OWNED BY public.assessment_notes.id;


--
-- Name: assessment_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment_tasks (
    id integer NOT NULL,
    assessment_id integer,
    description text NOT NULL,
    priority character varying(20) DEFAULT 'normal'::character varying,
    estimated_hours numeric(4,1),
    status character varying(20) DEFAULT 'draft'::character varying,
    parent_task_id integer,
    materials_needed text,
    notes text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: assessment_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assessment_tasks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assessment_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assessment_tasks_id_seq OWNED BY public.assessment_tasks.id;


--
-- Name: assessments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessments (
    id integer NOT NULL,
    case_id integer,
    assessor_id integer,
    scheduled_start timestamp without time zone,
    scheduled_end timestamp without time zone,
    actual_start timestamp without time zone,
    actual_end timestamp without time zone,
    estimated_duration_hours numeric(3,1),
    status character varying(20) DEFAULT 'scheduled'::character varying,
    completion_percentage integer DEFAULT 0,
    check_in_location point,
    check_out_location point,
    check_in_at timestamp without time zone,
    check_out_at timestamp without time zone,
    repair_areas text[],
    measurements jsonb,
    notes text,
    travel_distance_miles numeric(5,1),
    travel_time_minutes integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    application_id bigint,
    organization_id bigint,
    claim_number character varying(32),
    date_created timestamp with time zone DEFAULT now(),
    date_of_loss date,
    date_inspected date,
    date_received date,
    date_entered date,
    policy_number character varying(64),
    homeowner_names jsonb DEFAULT '[]'::jsonb,
    full_address text,
    street text,
    city text,
    state text DEFAULT 'NC'::text,
    zip text,
    phone text,
    is_emergency boolean DEFAULT false,
    emergency_desc text,
    total_construction_price numeric(12,2),
    assessor_name text
);


--
-- Name: assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assessments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assessments_id_seq OWNED BY public.assessments.id;


--
-- Name: assignment_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assignment_log (
    id integer NOT NULL,
    assignment_id integer,
    action character varying(50),
    old_value text,
    new_value text,
    performed_by integer,
    performed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    notes text
);


--
-- Name: assignment_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assignment_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assignment_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assignment_log_id_seq OWNED BY public.assignment_log.id;


--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_log (
    id integer NOT NULL,
    submission_id integer,
    action character varying(50),
    old_value text,
    new_value text,
    performed_by character varying(100),
    performed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: audit_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audit_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audit_log_id_seq OWNED BY public.audit_log.id;


--
-- Name: badges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.badges (
    id integer NOT NULL,
    badge_code character varying(50) NOT NULL,
    badge_name character varying(100) NOT NULL,
    description text,
    icon_url character varying(500),
    criteria_type character varying(50),
    criteria_value integer,
    xp_bonus integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: badges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.badges_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: badges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.badges_id_seq OWNED BY public.badges.id;


--
-- Name: beneficiary_feedback; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.beneficiary_feedback (
    id integer NOT NULL,
    quest_id uuid,
    volunteer_id integer,
    beneficiary_id integer,
    quality_rating integer,
    kindness_rating integer,
    would_recommend boolean,
    comments text,
    thank_you_note text,
    photo_urls text[],
    reputation_delta integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT beneficiary_feedback_kindness_rating_check CHECK (((kindness_rating >= 1) AND (kindness_rating <= 5))),
    CONSTRAINT beneficiary_feedback_quality_rating_check CHECK (((quality_rating >= 1) AND (quality_rating <= 5)))
);


--
-- Name: beneficiary_feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.beneficiary_feedback_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: beneficiary_feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.beneficiary_feedback_id_seq OWNED BY public.beneficiary_feedback.id;


--
-- Name: blocked_ips; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.blocked_ips (
    id bigint NOT NULL,
    ip_address character varying(45) NOT NULL,
    blocked_at timestamp with time zone DEFAULT now() NOT NULL,
    blocked_by bigint,
    reason text,
    is_active boolean DEFAULT true NOT NULL,
    expires_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: blocked_ips_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.blocked_ips_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: blocked_ips_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.blocked_ips_id_seq OWNED BY public.blocked_ips.id;


--
-- Name: case_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.case_statuses (
    id integer NOT NULL,
    status_code character varying(50) NOT NULL,
    status_name character varying(100) NOT NULL,
    status_sequence integer NOT NULL,
    is_terminal boolean DEFAULT false,
    allowed_roles_for_transition text[],
    description text
);


--
-- Name: cases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cases (
    id integer NOT NULL,
    submission_id integer,
    case_number character varying(50) NOT NULL,
    status_id integer,
    assigned_caseworker_id integer,
    assigned_project_manager_id integer,
    assigned_assessor_id integer,
    intake_completed_at timestamp without time zone,
    assessment_scheduled_at timestamp without time zone,
    assessment_completed_at timestamp without time zone,
    approved_at timestamp without time zone,
    work_started_at timestamp without time zone,
    work_completed_at timestamp without time zone,
    total_budget numeric(12,2),
    total_actual_cost numeric(12,2),
    notes text,
    internal_notes text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by integer,
    updated_by integer,
    placecode character varying(10),
    project_code character varying(11),
    application_id integer,
    organization_id integer,
    claimed_at timestamp without time zone,
    claimed_by integer,
    claim_expires_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP + '90 days'::interval),
    claim_status character varying(20),
    last_progress_at timestamp without time zone,
    progress_events_count integer DEFAULT 0,
    CONSTRAINT cases_claim_status_check CHECK (((claim_status IS NULL) OR ((claim_status)::text = ANY ((ARRAY['active'::character varying, 'expired'::character varying, 'released'::character varying])::text[]))))
);


--
-- Name: system_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_users (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    full_name character varying(200) NOT NULL,
    phone character varying(20),
    avatar_url character varying(500),
    is_active boolean DEFAULT true,
    last_login timestamp without time zone,
    last_ip inet,
    password_hash character varying(255),
    reset_token character varying(255),
    reset_token_expires timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by integer,
    updated_by integer,
    username character varying(100),
    first_name character varying(100),
    last_name character varying(100),
    session_indefinite boolean DEFAULT false,
    menu_config jsonb
);


--
-- Name: COLUMN system_users.username; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_users.username IS 'Unique username for login (auto-generated from email on creation)';


--
-- Name: COLUMN system_users.first_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_users.first_name IS 'User first name';


--
-- Name: COLUMN system_users.last_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_users.last_name IS 'User last name';


--
-- Name: COLUMN system_users.session_indefinite; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_users.session_indefinite IS 'When true, the login session cookie should be persisted for a long duration instead of the default 24-hour expiry.';


--
-- Name: case_assignment_dashboard; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.case_assignment_dashboard AS
 SELECT c.id AS case_id,
    c.case_number,
    cs.status_name AS case_status,
    s.applicant_first_name,
    s.applicant_last_name,
    s.home_city,
    u1.full_name AS caseworker_name,
    u2.full_name AS project_manager_name,
    u3.full_name AS assessor_name,
    c.approved_at,
    c.total_budget,
    c.total_actual_cost,
        CASE
            WHEN (c.work_completed_at IS NOT NULL) THEN 'Completed'::text
            WHEN (c.work_started_at IS NOT NULL) THEN 'In Progress'::text
            WHEN (c.approved_at IS NOT NULL) THEN 'Approved'::text
            ELSE 'In Pipeline'::text
        END AS project_phase
   FROM (((((public.cases c
     JOIN public.case_statuses cs ON ((c.status_id = cs.id)))
     JOIN public.intake_submissions s ON ((c.submission_id = s.id)))
     LEFT JOIN public.system_users u1 ON ((c.assigned_caseworker_id = u1.id)))
     LEFT JOIN public.system_users u2 ON ((c.assigned_project_manager_id = u2.id)))
     LEFT JOIN public.system_users u3 ON ((c.assigned_assessor_id = u3.id)));


--
-- Name: case_claim_status; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.case_claim_status AS
 SELECT c.id AS case_id,
    c.case_number,
    s.home_address,
    s.home_city,
    s.home_zip,
    aa.organization_id AS claiming_org_id,
    co.organization_name AS claiming_org_name,
    aa.claimed_by,
    u.full_name AS claimed_by_name,
    aa.claimed_at,
    aa.status AS claim_status,
    aa.expires_at AS lock_expires_at,
    (EXISTS ( SELECT 1
           FROM (public.intake_submissions s2
             JOIN public.cases c2 ON ((s2.id = c2.submission_id)))
          WHERE (((s2.home_address)::text = (s.home_address)::text) AND ((s2.home_city)::text = (s.home_city)::text) AND (c2.id <> c.id) AND (c2.status_id IN ( SELECT case_statuses.id
                   FROM public.case_statuses
                  WHERE ((case_statuses.status_code)::text = ANY ((ARRAY['ASSIGNED_TO_CREW'::character varying, 'IN_PROGRESS'::character varying])::text[]))))))) AS duplicate_address_flag,
    (EXTRACT(epoch FROM ((aa.expires_at)::timestamp with time zone - now())) / (86400)::numeric) AS days_until_expiry
   FROM ((((public.cases c
     JOIN public.intake_submissions s ON ((c.submission_id = s.id)))
     LEFT JOIN public.application_assignments aa ON (((c.submission_id = aa.submission_id) AND ((aa.status)::text = ANY ((ARRAY['claimed'::character varying, 'locked'::character varying])::text[])))))
     LEFT JOIN public.coalition_organizations co ON ((aa.organization_id = co.id)))
     LEFT JOIN public.system_users u ON ((aa.claimed_by = u.id)))
  WHERE (NOT (c.status_id IN ( SELECT case_statuses.id
           FROM public.case_statuses
          WHERE ((case_statuses.status_code)::text = ANY ((ARRAY['COMPLETED'::character varying, 'DENIED'::character varying])::text[])))));


--
-- Name: case_claims; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.case_claims (
    case_id integer NOT NULL,
    claimed_by_org_id integer,
    claimed_at timestamp without time zone,
    expires_at timestamp without time zone,
    is_locked boolean DEFAULT true
);


--
-- Name: case_communications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.case_communications (
    id integer NOT NULL,
    case_id integer,
    from_user_id integer,
    to_user_id integer,
    to_applicant boolean DEFAULT false,
    communication_type character varying(50),
    subject character varying(500),
    body text,
    attachments jsonb,
    sent_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_read boolean DEFAULT false,
    read_at timestamp without time zone,
    notes text
);


--
-- Name: case_communications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.case_communications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: case_communications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.case_communications_id_seq OWNED BY public.case_communications.id;


--
-- Name: case_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.case_documents (
    id integer NOT NULL,
    case_id integer,
    category_id integer,
    status_id integer DEFAULT 1,
    file_name character varying(255) NOT NULL,
    file_size_bytes bigint,
    file_hash character varying(64),
    mime_type character varying(100),
    storage_path character varying(1000) NOT NULL,
    storage_provider character varying(50) DEFAULT 'dropbox'::character varying,
    storage_bucket character varying(255),
    storage_region character varying(100),
    version_number integer DEFAULT 1,
    parent_document_id integer,
    metadata jsonb DEFAULT '{}'::jsonb,
    extracted_text text,
    thumbnail_path character varying(1000),
    uploaded_by integer,
    uploaded_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    verified_by integer,
    verified_at timestamp without time zone,
    expires_at timestamp without time zone,
    deleted_at timestamp without time zone,
    access_roles text[],
    notes text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: document_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_categories (
    id integer NOT NULL,
    category_code character varying(50) NOT NULL,
    category_name character varying(100) NOT NULL,
    parent_category_id integer,
    storage_path_template text,
    requires_encryption boolean DEFAULT true,
    retention_months integer,
    description text
);


--
-- Name: document_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_statuses (
    id integer NOT NULL,
    status_code character varying(50) NOT NULL,
    status_name character varying(100) NOT NULL
);


--
-- Name: case_document_inventory; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.case_document_inventory AS
 SELECT c.id AS case_id,
    c.case_number,
    dc.category_code,
    dc.category_name,
    count(d.id) AS document_count,
    count(
        CASE
            WHEN (d.status_id = ( SELECT document_statuses.id
               FROM public.document_statuses
              WHERE ((document_statuses.status_code)::text = 'VERIFIED'::text))) THEN 1
            ELSE NULL::integer
        END) AS verified_count,
    count(
        CASE
            WHEN (d.status_id = ( SELECT document_statuses.id
               FROM public.document_statuses
              WHERE ((document_statuses.status_code)::text = 'PENDING'::text))) THEN 1
            ELSE NULL::integer
        END) AS pending_count,
    max(d.uploaded_at) AS last_upload,
    array_agg(DISTINCT d.file_name ORDER BY d.file_name) AS recent_documents
   FROM ((public.cases c
     CROSS JOIN public.document_categories dc)
     LEFT JOIN public.case_documents d ON (((c.id = d.case_id) AND (dc.id = d.category_id))))
  WHERE (dc.parent_category_id IS NOT NULL)
  GROUP BY c.id, c.case_number, dc.category_code, dc.category_name
  ORDER BY c.case_number, dc.category_code;


--
-- Name: case_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.case_documents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: case_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.case_documents_id_seq OWNED BY public.case_documents.id;


--
-- Name: case_funding; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.case_funding (
    id integer NOT NULL,
    case_id integer,
    funding_source_id integer,
    allocated_amount numeric(12,2),
    spent_amount numeric(12,2) DEFAULT 0,
    allocated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    allocated_by integer,
    notes text,
    approved_date date,
    expiration_date date,
    status character varying(50)
);


--
-- Name: case_funding_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.case_funding_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: case_funding_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.case_funding_id_seq OWNED BY public.case_funding.id;


--
-- Name: case_funding_summary; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.case_funding_summary AS
SELECT
    NULL::integer AS case_id,
    NULL::character varying(50) AS case_number,
    NULL::integer AS submission_id,
    NULL::character varying(100) AS applicant_first_name,
    NULL::character varying(100) AS applicant_last_name,
    NULL::character varying(100) AS assigned_organization,
    NULL::numeric AS approved_amount,
    NULL::numeric AS incurred_amount,
    NULL::numeric AS reimbursed_amount,
    NULL::numeric AS pending_reimbursement,
    NULL::numeric AS outstanding_balance,
    NULL::numeric AS remaining_available,
    NULL::text AS cap_status,
    NULL::boolean AS has_hold_amount;


--
-- Name: case_repair_claims; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.case_repair_claims (
    id integer NOT NULL,
    case_id integer NOT NULL,
    repair_request_id integer NOT NULL,
    organization_id integer NOT NULL,
    claimed_by integer,
    claimed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    released_at timestamp without time zone,
    released_by integer,
    notes text
);


--
-- Name: case_repair_claims_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.case_repair_claims_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: case_repair_claims_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.case_repair_claims_id_seq OWNED BY public.case_repair_claims.id;


--
-- Name: case_status_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.case_status_history (
    id integer NOT NULL,
    case_id integer,
    from_status_id integer,
    to_status_id integer,
    changed_by integer,
    notes text,
    changed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: case_status_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.case_status_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: case_status_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.case_status_history_id_seq OWNED BY public.case_status_history.id;


--
-- Name: case_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.case_statuses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: case_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.case_statuses_id_seq OWNED BY public.case_statuses.id;


--
-- Name: case_withdrawals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.case_withdrawals (
    id integer NOT NULL,
    case_id integer NOT NULL,
    withdrawn_by integer,
    withdrawn_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    requestor_confirmed boolean DEFAULT false NOT NULL,
    confirmation_method character varying(20) NOT NULL,
    confirmation_detail text NOT NULL,
    reason text
);


--
-- Name: case_withdrawals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.case_withdrawals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: case_withdrawals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.case_withdrawals_id_seq OWNED BY public.case_withdrawals.id;


--
-- Name: cases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cases_id_seq OWNED BY public.cases.id;


--
-- Name: caseworker_review_queue; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.caseworker_review_queue AS
 SELECT fifo_order,
    submission_id,
    applicant_first_name,
    applicant_last_name,
    home_address,
    submitted_at,
    helene_related,
    status,
    priority_score,
    hours_in_queue,
    primary_issue,
    urgent_count,
    is_eligible,
    best_match_score,
    best_match_org
   FROM public.staff_review_queue
  WHERE (is_eligible = true);


--
-- Name: coalition_organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.coalition_organizations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: coalition_organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.coalition_organizations_id_seq OWNED BY public.coalition_organizations.id;


--
-- Name: property_assessments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.property_assessments (
    id integer NOT NULL,
    case_id integer,
    assessor_id integer,
    assessment_date date NOT NULL,
    property_condition text,
    structural_issues text,
    electrical_issues text,
    plumbing_issues text,
    hvac_issues text,
    roofing_issues text,
    accessibility_needs text,
    safety_hazards text,
    photos jsonb,
    square_footage numeric(10,2),
    num_bedrooms integer,
    num_bathrooms integer,
    recommended_repairs text,
    priority_repairs text,
    estimated_hours numeric(10,2),
    estimated_material_cost numeric(12,2),
    estimated_labor_cost numeric(12,2),
    total_estimate numeric(12,2),
    assessment_notes text,
    assigned_at timestamp without time zone,
    assessment_completed_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: completed_assessments_with_triage; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.completed_assessments_with_triage AS
 SELECT pa.case_id,
    pa.id AS assessment_id,
    pa.total_estimate,
    pa.priority_repairs,
    c.submission_id,
    s.helene_related,
    LEAST(((COALESCE(((( SELECT count(*) AS count
           FROM (public.submission_repair_categories src
             JOIN public.repair_categories rc ON ((src.category_id = rc.id)))
          WHERE ((src.submission_id = s.id) AND ((rc.category_code)::text = ANY ((ARRAY['unable_to_stay'::character varying, 'no_hvac'::character varying, 'no_potable_water'::character varying, 'no_bathroom'::character varying, 'no_kitchen'::character varying, 'open_to_elements'::character varying, 'no_entry'::character varying])::text[])))))::numeric * 12.5), (0)::numeric) + COALESCE(((pa.total_estimate / NULLIF(( SELECT max(property_assessments.total_estimate) AS max
           FROM public.property_assessments), (0)::numeric)) * (30)::numeric), (0)::numeric)) + (
        CASE
            WHEN s.helene_related THEN 30
            ELSE 0
        END)::numeric), (100)::numeric) AS triage_score
   FROM ((public.property_assessments pa
     JOIN public.cases c ON ((pa.case_id = c.id)))
     JOIN public.intake_submissions s ON ((c.submission_id = s.id)))
  WHERE (pa.assessment_completed_at IS NOT NULL);


--
-- Name: contact_methods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contact_methods (
    id integer NOT NULL,
    method_code character varying(10) NOT NULL
);


--
-- Name: contact_methods_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contact_methods_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contact_methods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contact_methods_id_seq OWNED BY public.contact_methods.id;


--
-- Name: content_reads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_reads (
    id integer NOT NULL,
    content_id integer,
    volunteer_id integer,
    read_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    xp_awarded boolean DEFAULT false
);


--
-- Name: content_reads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_reads_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_reads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_reads_id_seq OWNED BY public.content_reads.id;


--
-- Name: crew_completion_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crew_completion_documents (
    id integer NOT NULL,
    job_id integer,
    document_type character varying(50),
    document_url text,
    document_name character varying(200),
    client_signed_at timestamp without time zone,
    client_signature_url text,
    crew_lead_signed_at timestamp without time zone,
    crew_lead_signature_url text,
    is_final boolean DEFAULT false,
    verified_by integer,
    verified_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: crew_completion_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.crew_completion_documents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crew_completion_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.crew_completion_documents_id_seq OWNED BY public.crew_completion_documents.id;


--
-- Name: crew_daily_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crew_daily_logs (
    id integer NOT NULL,
    job_id integer,
    crew_lead_id integer,
    log_date date DEFAULT CURRENT_DATE,
    log_text text,
    work_summary text,
    issues_encountered text,
    tomorrow_plan text,
    photo_urls text[],
    verified boolean DEFAULT false,
    verified_by integer,
    verified_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: crew_daily_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.crew_daily_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crew_daily_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.crew_daily_logs_id_seq OWNED BY public.crew_daily_logs.id;


--
-- Name: crew_incident_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crew_incident_reports (
    id integer NOT NULL,
    job_id integer,
    reported_by integer,
    incident_date date NOT NULL,
    incident_time time without time zone,
    incident_type character varying(50),
    severity character varying(20),
    description text NOT NULL,
    location text,
    witnesses text[],
    immediate_action_taken text,
    follow_up_required boolean DEFAULT false,
    follow_up_notes text,
    status character varying(20) DEFAULT 'reported'::character varying,
    photo_urls text[],
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    resolved_at timestamp without time zone,
    resolved_by integer
);


--
-- Name: crew_incident_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.crew_incident_reports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crew_incident_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.crew_incident_reports_id_seq OWNED BY public.crew_incident_reports.id;


--
-- Name: crew_job_cards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crew_job_cards (
    id integer NOT NULL,
    case_id integer,
    crew_lead_id integer,
    placecode character varying(50),
    address text,
    homeowner_name character varying(200),
    homeowner_phone character varying(20),
    weather_indoor_outdoor character varying(20),
    weather_icon character varying(10),
    weather_temperature integer,
    progress_percentage integer DEFAULT 0,
    total_tasks integer DEFAULT 0,
    completed_tasks integer DEFAULT 0,
    estimated_hours numeric(5,2),
    remaining_hours numeric(5,2),
    job_status character varying(20) DEFAULT 'active'::character varying,
    is_current_job boolean DEFAULT false,
    current_phase character varying(50),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: crew_job_cards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.crew_job_cards_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crew_job_cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.crew_job_cards_id_seq OWNED BY public.crew_job_cards.id;


--
-- Name: crew_job_phases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crew_job_phases (
    id integer NOT NULL,
    phase_code character varying(50) NOT NULL,
    phase_name character varying(100) NOT NULL,
    phase_order integer NOT NULL,
    description text,
    required_tasks jsonb,
    completion_criteria text,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: crew_job_phases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.crew_job_phases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crew_job_phases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.crew_job_phases_id_seq OWNED BY public.crew_job_phases.id;


--
-- Name: crew_volunteer_signin; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crew_volunteer_signin (
    id integer NOT NULL,
    job_id integer,
    volunteer_id integer,
    sign_in_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    sign_out_time timestamp without time zone,
    hours_worked numeric(5,2),
    safety_talk_confirmed boolean DEFAULT false,
    safety_talk_topics text,
    safety_talk_confirmed_at timestamp without time zone,
    assigned_task_ids integer[],
    verified_by integer,
    verified_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: crew_tomorrow_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.crew_tomorrow_view AS
 SELECT cjc.id AS job_id,
    cjc.placecode,
    cjc.address,
    cjc.crew_lead_id,
    cl.full_name AS crew_lead_name,
    cjc.weather_indoor_outdoor,
    cjc.weather_icon,
    cjc.weather_temperature,
    cjc.progress_percentage,
    cjc.estimated_hours,
    count(DISTINCT cvs.volunteer_id) AS volunteer_count,
    string_agg(DISTINCT (u.full_name)::text, ', '::text) AS volunteer_names
   FROM (((public.crew_job_cards cjc
     LEFT JOIN public.system_users cl ON ((cjc.crew_lead_id = cl.id)))
     LEFT JOIN public.crew_volunteer_signin cvs ON (((cjc.id = cvs.job_id) AND ((cvs.sign_in_time)::date = (CURRENT_DATE + '1 day'::interval)))))
     LEFT JOIN public.system_users u ON ((cvs.volunteer_id = u.id)))
  WHERE (((cjc.job_status)::text = ANY ((ARRAY['active'::character varying, 'in_progress'::character varying])::text[])) AND (cjc.is_current_job = false))
  GROUP BY cjc.id, cjc.placecode, cjc.address, cjc.crew_lead_id, cl.full_name, cjc.weather_indoor_outdoor, cjc.weather_icon, cjc.weather_temperature, cjc.progress_percentage, cjc.estimated_hours
  ORDER BY cjc.estimated_hours;


--
-- Name: crew_volunteer_signin_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.crew_volunteer_signin_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crew_volunteer_signin_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.crew_volunteer_signin_id_seq OWNED BY public.crew_volunteer_signin.id;


--
-- Name: criteria_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.criteria_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: criteria_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.criteria_types_id_seq OWNED BY public.criteria_types.id;


--
-- Name: document_access_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_access_log (
    id integer NOT NULL,
    document_id integer,
    accessed_by integer,
    access_type character varying(20),
    ip_address inet,
    user_agent text,
    accessed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: document_access_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.document_access_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: document_access_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.document_access_log_id_seq OWNED BY public.document_access_log.id;


--
-- Name: document_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.document_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: document_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.document_categories_id_seq OWNED BY public.document_categories.id;


--
-- Name: document_generation_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_generation_jobs (
    id integer NOT NULL,
    case_id integer,
    template_id integer,
    status character varying(20) DEFAULT 'pending'::character varying,
    data_source jsonb NOT NULL,
    output_document_id integer,
    error_message text,
    priority integer DEFAULT 5,
    created_by integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    completed_at timestamp without time zone,
    expires_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP + '7 days'::interval)
);


--
-- Name: document_generation_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.document_generation_jobs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: document_generation_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.document_generation_jobs_id_seq OWNED BY public.document_generation_jobs.id;


--
-- Name: document_share_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_share_links (
    id integer NOT NULL,
    document_id integer,
    share_token uuid DEFAULT gen_random_uuid(),
    shared_by integer,
    recipient_email character varying(255),
    expires_at timestamp without time zone,
    max_accesses integer,
    access_count integer DEFAULT 0,
    requires_auth boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: document_share_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.document_share_links_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: document_share_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.document_share_links_id_seq OWNED BY public.document_share_links.id;


--
-- Name: document_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.document_statuses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: document_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.document_statuses_id_seq OWNED BY public.document_statuses.id;


--
-- Name: document_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_templates (
    id integer NOT NULL,
    template_code character varying(50) NOT NULL,
    template_name character varying(200) NOT NULL,
    category_id integer,
    template_file_path character varying(1000),
    template_type character varying(50),
    output_format character varying(20) DEFAULT 'pdf'::character varying,
    requires_signature boolean DEFAULT false,
    signature_fields jsonb,
    version integer DEFAULT 1,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: document_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.document_templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: document_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.document_templates_id_seq OWNED BY public.document_templates.id;


--
-- Name: document_verifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_verifications (
    id integer NOT NULL,
    case_id integer,
    verified_by integer,
    document_code character varying(20) NOT NULL,
    document_id integer,
    verification_type character varying(20),
    verification_status character varying(20) DEFAULT 'pending'::character varying,
    findings text,
    notes text,
    is_reversible boolean DEFAULT true,
    verified_at timestamp without time zone,
    collected_physically boolean DEFAULT false,
    collected_at timestamp without time zone,
    collected_by character varying(100),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: document_verifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.document_verifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: document_verifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.document_verifications_id_seq OWNED BY public.document_verifications.id;


--
-- Name: help_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.help_documents (
    id integer NOT NULL,
    document_id character varying(50) NOT NULL,
    doc_type_id integer,
    category_id integer,
    title character varying(500) NOT NULL,
    subtitle character varying(500),
    version character varying(20) DEFAULT '1.0'::character varying,
    content text,
    content_format character varying(20) DEFAULT 'markdown'::character varying,
    file_path character varying(1000),
    language character varying(5) DEFAULT 'en'::character varying,
    original_document_id integer,
    author character varying(200),
    author_email character varying(255),
    owner_role_id integer,
    reviewer_id integer,
    reviewer_notes text,
    target_roles text[],
    tags text[],
    search_keywords text[],
    estimated_minutes integer,
    related_documents integer[],
    prerequisite_documents integer[],
    status character varying(20) DEFAULT 'draft'::character varying,
    is_featured boolean DEFAULT false,
    is_required boolean DEFAULT false,
    view_count integer DEFAULT 0,
    helpful_count integer DEFAULT 0,
    not_helpful_count integer DEFAULT 0,
    last_viewed_at timestamp without time zone,
    publish_at timestamp without time zone,
    expires_at timestamp without time zone,
    review_required_by date,
    previous_version_id integer,
    change_notes text,
    created_by integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by integer,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    reviewed_at timestamp without time zone,
    reviewed_by integer,
    archived_at timestamp without time zone,
    archived_by integer,
    custom_fields jsonb DEFAULT '{}'::jsonb,
    notes text,
    CONSTRAINT valid_status CHECK (((status)::text = ANY ((ARRAY['draft'::character varying, 'review'::character varying, 'published'::character varying, 'archived'::character varying, 'deprecated'::character varying])::text[])))
);


--
-- Name: documents_needing_review; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.documents_needing_review AS
 SELECT id,
    document_id,
    title,
    version,
    review_required_by,
    updated_at,
    (CURRENT_DATE - review_required_by) AS days_overdue
   FROM public.help_documents hd
  WHERE (((status)::text = 'published'::text) AND (review_required_by IS NOT NULL) AND (review_required_by < (CURRENT_DATE + '30 days'::interval)))
  ORDER BY review_required_by;


--
-- Name: duplicate_case_alerts; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.duplicate_case_alerts AS
 SELECT s1.id AS submission_id_1,
    s1.applicant_first_name,
    s1.applicant_last_name,
    s1.home_address,
    s1.home_city,
    s2.id AS submission_id_2,
    s2.applicant_first_name AS applicant_name_2,
    c1.case_number AS case_number_1,
    c2.case_number AS case_number_2,
    'SAME_ADDRESS'::text AS alert_type,
    co1.organization_name AS org_1,
    co2.organization_name AS org_2,
    now() AS detected_at
   FROM (((((((public.intake_submissions s1
     JOIN public.intake_submissions s2 ON (((s1.id < s2.id) AND ((s1.home_address)::text ~~* (s2.home_address)::text) AND ((s1.home_city)::text ~~* (s2.home_city)::text))))
     JOIN public.cases c1 ON ((s1.id = c1.submission_id)))
     JOIN public.cases c2 ON ((s2.id = c2.submission_id)))
     JOIN public.application_assignments a1 ON (((s1.id = a1.submission_id) AND ((a1.status)::text = ANY ((ARRAY['claimed'::character varying, 'locked'::character varying])::text[])))))
     JOIN public.application_assignments a2 ON (((s2.id = a2.submission_id) AND ((a2.status)::text = ANY ((ARRAY['claimed'::character varying, 'locked'::character varying])::text[])))))
     LEFT JOIN public.coalition_organizations co1 ON ((a1.organization_id = co1.id)))
     LEFT JOIN public.coalition_organizations co2 ON ((a2.organization_id = co2.id)))
  WHERE ((NOT (c1.status_id IN ( SELECT case_statuses.id
           FROM public.case_statuses
          WHERE ((case_statuses.status_code)::text = 'COMPLETED'::text)))) AND (NOT (c2.status_id IN ( SELECT case_statuses.id
           FROM public.case_statuses
          WHERE ((case_statuses.status_code)::text = 'COMPLETED'::text)))) AND (a1.organization_id <> a2.organization_id))
UNION
 SELECT s1.id AS submission_id_1,
    s1.applicant_first_name,
    s1.applicant_last_name,
    s1.home_address,
    s1.home_city,
    s2.id AS submission_id_2,
    s2.applicant_first_name AS applicant_name_2,
    c1.case_number AS case_number_1,
    c2.case_number AS case_number_2,
    'SAME_APPLICANT'::text AS alert_type,
    co1.organization_name AS org_1,
    co2.organization_name AS org_2,
    now() AS detected_at
   FROM (((((((public.intake_submissions s1
     JOIN public.intake_submissions s2 ON (((s1.id < s2.id) AND ((s1.applicant_first_name)::text ~~* (s2.applicant_first_name)::text) AND ((s1.applicant_last_name)::text ~~* (s2.applicant_last_name)::text) AND (s1.applicant_dob = s2.applicant_dob))))
     JOIN public.cases c1 ON ((s1.id = c1.submission_id)))
     JOIN public.cases c2 ON ((s2.id = c2.submission_id)))
     JOIN public.application_assignments a1 ON (((s1.id = a1.submission_id) AND ((a1.status)::text = ANY ((ARRAY['claimed'::character varying, 'locked'::character varying])::text[])))))
     JOIN public.application_assignments a2 ON (((s2.id = a2.submission_id) AND ((a2.status)::text = ANY ((ARRAY['claimed'::character varying, 'locked'::character varying])::text[])))))
     LEFT JOIN public.coalition_organizations co1 ON ((a1.organization_id = co1.id)))
     LEFT JOIN public.coalition_organizations co2 ON ((a2.organization_id = co2.id)))
  WHERE ((c1.id <> c2.id) AND (NOT (c1.status_id IN ( SELECT case_statuses.id
           FROM public.case_statuses
          WHERE ((case_statuses.status_code)::text = 'COMPLETED'::text)))) AND (NOT (c2.status_id IN ( SELECT case_statuses.id
           FROM public.case_statuses
          WHERE ((case_statuses.status_code)::text = 'COMPLETED'::text)))));


--
-- Name: edit_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.edit_requests (
    id integer NOT NULL,
    case_id integer,
    requested_by integer,
    field_name character varying(100),
    old_value text,
    new_value text,
    reason text,
    status character varying(20) DEFAULT 'pending'::character varying,
    reviewed_by integer,
    reviewed_at timestamp without time zone,
    approved_at timestamp without time zone,
    change_incorporated boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: edit_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.edit_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: edit_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.edit_requests_id_seq OWNED BY public.edit_requests.id;


--
-- Name: eligibility_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.eligibility_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: eligibility_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.eligibility_results_id_seq OWNED BY public.eligibility_results.id;


--
-- Name: email_queue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_queue (
    id integer NOT NULL,
    recipient_email character varying(255),
    recipient_name character varying(200),
    subject character varying(500),
    body text,
    body_html text,
    notification_type character varying(50),
    related_entity_type character varying(50),
    related_entity_id integer,
    status character varying(20) DEFAULT 'pending'::character varying,
    attempts integer DEFAULT 0,
    last_attempt_at timestamp without time zone,
    error_message text,
    priority integer DEFAULT 5,
    send_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    sent_at timestamp without time zone
);


--
-- Name: email_queue_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.email_queue_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_queue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.email_queue_id_seq OWNED BY public.email_queue.id;


--
-- Name: funding_sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.funding_sources (
    id integer NOT NULL,
    organization_id integer,
    source_name character varying(200) NOT NULL,
    source_type character varying(50),
    total_amount numeric(12,2),
    remaining_amount numeric(12,2),
    start_date date,
    end_date date,
    restrictions text,
    contact_name character varying(200),
    contact_email character varying(255),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: funding_source_summary; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.funding_source_summary AS
 SELECT fs.id AS source_id,
    fs.source_name,
    fs.source_type,
    fs.total_amount,
    fs.remaining_amount,
    COALESCE(sum(cf.allocated_amount), (0)::numeric) AS allocated_to_cases,
    COALESCE(count(DISTINCT cf.case_id), (0)::bigint) AS case_count,
    round((((fs.total_amount - fs.remaining_amount) / NULLIF(fs.total_amount, (0)::numeric)) * (100)::numeric), 1) AS utilization_percentage,
        CASE
            WHEN (fs.remaining_amount < (0)::numeric) THEN 'OVERDRAWN'::text
            WHEN (fs.remaining_amount = (0)::numeric) THEN 'EXHAUSTED'::text
            WHEN (fs.remaining_amount < (fs.total_amount * 0.1)) THEN 'DEPLETED'::text
            ELSE 'HEALTHY'::text
        END AS health_status
   FROM (public.funding_sources fs
     LEFT JOIN public.case_funding cf ON ((fs.id = cf.funding_source_id)))
  GROUP BY fs.id, fs.source_name, fs.source_type, fs.total_amount, fs.remaining_amount;


--
-- Name: funding_sources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.funding_sources_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: funding_sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.funding_sources_id_seq OWNED BY public.funding_sources.id;


--
-- Name: guest_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.guest_access_tokens (
    id integer NOT NULL,
    submission_id integer,
    token uuid DEFAULT gen_random_uuid(),
    expires_at timestamp without time zone,
    last_accessed timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: guest_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.guest_access_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: guest_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.guest_access_tokens_id_seq OWNED BY public.guest_access_tokens.id;


--
-- Name: help_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.help_categories (
    id integer NOT NULL,
    category_code character varying(50) NOT NULL,
    category_name character varying(100) NOT NULL,
    parent_category_id integer,
    display_order integer DEFAULT 0,
    icon_class character varying(100),
    is_active boolean DEFAULT true,
    description text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: help_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.help_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: help_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.help_categories_id_seq OWNED BY public.help_categories.id;


--
-- Name: help_center_overview; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.help_center_overview AS
 SELECT hc.category_name,
    count(hd.id) AS total_documents,
    count(
        CASE
            WHEN ((hd.status)::text = 'published'::text) THEN 1
            ELSE NULL::integer
        END) AS published_count,
    count(
        CASE
            WHEN ((hd.status)::text = 'draft'::text) THEN 1
            ELSE NULL::integer
        END) AS draft_count,
    count(
        CASE
            WHEN ((hd.status)::text = 'review'::text) THEN 1
            ELSE NULL::integer
        END) AS review_count,
    max(hd.updated_at) AS last_updated,
    sum(hd.view_count) AS total_views,
    round(avg(
        CASE
            WHEN ((hd.helpful_count + hd.not_helpful_count) > 0) THEN (((hd.helpful_count)::numeric / ((hd.helpful_count + hd.not_helpful_count))::numeric) * (100)::numeric)
            ELSE NULL::numeric
        END), 1) AS helpful_percentage
   FROM (public.help_categories hc
     LEFT JOIN public.help_documents hd ON ((hc.id = hd.category_id)))
  WHERE (hc.is_active = true)
  GROUP BY hc.id, hc.category_name, hc.display_order
  ORDER BY hc.display_order;


--
-- Name: help_document_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.help_document_attachments (
    id integer NOT NULL,
    document_id integer,
    attachment_type character varying(50),
    file_name character varying(255) NOT NULL,
    file_path character varying(1000) NOT NULL,
    file_size_bytes bigint,
    mime_type character varying(100),
    alt_text character varying(500),
    caption text,
    display_order integer DEFAULT 0,
    uploaded_by integer,
    uploaded_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: help_document_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.help_document_attachments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: help_document_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.help_document_attachments_id_seq OWNED BY public.help_document_attachments.id;


--
-- Name: help_document_feedback; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.help_document_feedback (
    id integer NOT NULL,
    document_id integer,
    user_id integer,
    is_helpful boolean,
    rating integer,
    comment text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT help_document_feedback_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


--
-- Name: help_document_feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.help_document_feedback_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: help_document_feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.help_document_feedback_id_seq OWNED BY public.help_document_feedback.id;


--
-- Name: help_document_reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.help_document_reviews (
    id integer NOT NULL,
    document_id integer,
    reviewer_id integer,
    review_status character varying(20),
    comments text,
    requested_changes text,
    assigned_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    completed_at timestamp without time zone
);


--
-- Name: help_document_reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.help_document_reviews_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: help_document_reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.help_document_reviews_id_seq OWNED BY public.help_document_reviews.id;


--
-- Name: help_document_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.help_document_types (
    id integer NOT NULL,
    type_code character varying(50) NOT NULL,
    type_name character varying(100) NOT NULL,
    icon_class character varying(100),
    is_interactive boolean DEFAULT false,
    requires_authentication boolean DEFAULT true,
    description text
);


--
-- Name: help_document_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.help_document_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: help_document_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.help_document_types_id_seq OWNED BY public.help_document_types.id;


--
-- Name: help_document_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.help_document_versions (
    id integer NOT NULL,
    document_id integer,
    version_number character varying(20) NOT NULL,
    title character varying(500),
    content text,
    change_notes text,
    created_by integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_current boolean DEFAULT false
);


--
-- Name: help_document_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.help_document_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: help_document_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.help_document_versions_id_seq OWNED BY public.help_document_versions.id;


--
-- Name: help_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.help_documents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: help_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.help_documents_id_seq OWNED BY public.help_documents.id;


--
-- Name: help_search_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.help_search_log (
    id integer NOT NULL,
    search_term character varying(500),
    user_id integer,
    result_count integer,
    clicked_document_id integer,
    search_type character varying(20),
    ip_address inet,
    user_agent text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: help_search_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.help_search_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: help_search_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.help_search_log_id_seq OWNED BY public.help_search_log.id;


--
-- Name: help_user_progress; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.help_user_progress (
    id integer NOT NULL,
    user_id integer,
    document_id integer,
    status character varying(20) DEFAULT 'not_started'::character varying,
    started_at timestamp without time zone,
    completed_at timestamp without time zone,
    last_position integer,
    notes text
);


--
-- Name: help_user_progress_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.help_user_progress_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: help_user_progress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.help_user_progress_id_seq OWNED BY public.help_user_progress.id;


--
-- Name: household_attributes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.household_attributes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: household_attributes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.household_attributes_id_seq OWNED BY public.household_attributes.id;


--
-- Name: income_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.income_records (
    id integer NOT NULL,
    submission_id integer,
    whose_income character varying(10),
    income_source character varying(30),
    frequency character varying(15),
    amount numeric(12,2),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: income_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.income_records_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: income_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.income_records_id_seq OWNED BY public.income_records.id;


--
-- Name: intake_submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.intake_submissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: intake_submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.intake_submissions_id_seq OWNED BY public.intake_submissions.id;


--
-- Name: invoice_line_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invoice_line_items (
    id integer NOT NULL,
    invoice_id integer,
    task_id integer,
    description text,
    quantity numeric(10,2),
    unit_price numeric(12,2),
    total numeric(12,2)
);


--
-- Name: invoice_line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invoice_line_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoice_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invoice_line_items_id_seq OWNED BY public.invoice_line_items.id;


--
-- Name: invoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invoices (
    id integer NOT NULL,
    case_id integer,
    invoice_number character varying(50) NOT NULL,
    vendor_name character varying(200),
    vendor_type character varying(50),
    invoice_date date,
    due_date date,
    paid_date date,
    subtotal numeric(12,2),
    tax numeric(12,2),
    total_amount numeric(12,2),
    status character varying(50) DEFAULT 'pending'::character varying,
    approved_by integer,
    approved_at timestamp without time zone,
    paid_by integer,
    notes text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invoices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invoices_id_seq OWNED BY public.invoices.id;


--
-- Name: login_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.login_attempts (
    id bigint NOT NULL,
    ip_address character varying(45) NOT NULL,
    email character varying(255) NOT NULL,
    attempted_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: login_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.login_attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: login_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.login_attempts_id_seq OWNED BY public.login_attempts.id;


--
-- Name: material_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.material_requests (
    id integer NOT NULL,
    task_id integer,
    requested_by integer,
    material_name character varying(200),
    quantity numeric(10,2),
    unit character varying(20),
    estimated_cost numeric(12,2),
    supplier character varying(200),
    status character varying(50) DEFAULT 'pending'::character varying,
    approved_by integer,
    approved_at timestamp without time zone,
    order_date date,
    received_date date,
    notes text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: material_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.material_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: material_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.material_requests_id_seq OWNED BY public.material_requests.id;


--
-- Name: materials_inventory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.materials_inventory (
    id bigint NOT NULL,
    sow_line_item_id bigint NOT NULL,
    material_name text NOT NULL,
    quantity numeric(10,2) NOT NULL,
    unit text,
    unit_cost numeric(10,2) NOT NULL,
    total_cost numeric(10,2) GENERATED ALWAYS AS ((quantity * unit_cost)) STORED,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: materials_inventory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.materials_inventory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: materials_inventory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.materials_inventory_id_seq OWNED BY public.materials_inventory.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    user_id integer,
    notification_type character varying(50) NOT NULL,
    title character varying(255) NOT NULL,
    body text,
    entity_type character varying(50),
    entity_id integer,
    is_read boolean DEFAULT false,
    read_at timestamp without time zone,
    is_archived boolean DEFAULT false,
    priority character varying(20) DEFAULT 'normal'::character varying,
    email_sent boolean DEFAULT false,
    sms_sent boolean DEFAULT false,
    in_app_delivered boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: organization_eligibility_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organization_eligibility_rules_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organization_eligibility_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organization_eligibility_rules_id_seq OWNED BY public.organization_eligibility_rules.id;


--
-- Name: organization_metrics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_metrics (
    id integer NOT NULL,
    organization_id integer,
    metric_date date NOT NULL,
    applications_assigned integer DEFAULT 0,
    applications_claimed integer DEFAULT 0,
    applications_rejected integer DEFAULT 0,
    applications_completed integer DEFAULT 0,
    applications_expired integer DEFAULT 0,
    avg_time_to_claim_hours numeric(10,2),
    avg_time_to_complete_days numeric(10,2),
    avg_match_score numeric(5,2),
    rejection_rate numeric(5,2),
    completion_rate numeric(5,2),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: organization_metrics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organization_metrics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organization_metrics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organization_metrics_id_seq OWNED BY public.organization_metrics.id;


--
-- Name: organization_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_users (
    id integer NOT NULL,
    organization_id integer,
    email character varying(255) NOT NULL,
    full_name character varying(200),
    role character varying(50) DEFAULT 'viewer'::character varying,
    is_active boolean DEFAULT true,
    last_login timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: organization_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organization_users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organization_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organization_users_id_seq OWNED BY public.organization_users.id;


--
-- Name: volunteer_hours; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.volunteer_hours (
    id integer NOT NULL,
    user_id integer,
    work_order_id integer,
    date date NOT NULL,
    hours numeric(5,2),
    task_description text,
    verified_by integer,
    verified_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: work_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.work_orders (
    id integer NOT NULL,
    case_id integer,
    work_order_number character varying(50) NOT NULL,
    project_manager_id integer,
    crew_lead_id integer,
    scheduled_start_date date,
    scheduled_end_date date,
    actual_start_date date,
    actual_end_date date,
    status character varying(50) DEFAULT 'planned'::character varying,
    approved_budget numeric(12,2),
    current_cost numeric(12,2),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: work_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.work_tasks (
    id integer NOT NULL,
    work_order_id integer,
    assigned_to_id integer,
    task_type character varying(50),
    description text,
    repair_category_id integer,
    estimate_id integer,
    status character varying(50) DEFAULT 'assigned'::character varying,
    priority integer DEFAULT 1,
    estimated_hours numeric(10,2),
    actual_hours numeric(10,2),
    due_date date,
    completed_at timestamp without time zone,
    instructions text,
    completion_notes text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by integer,
    job_code character varying(50),
    todo_list text[],
    suggested_at timestamp without time zone,
    claimed_at timestamp without time zone,
    accepted_at timestamp without time zone,
    estimate_date date,
    work_start_date date,
    work_finish_date date
);


--
-- Name: organization_workload; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.organization_workload AS
 SELECT o.id AS organization_id,
    o.organization_name,
    count(DISTINCT c.id) AS total_cases,
    count(DISTINCT
        CASE
            WHEN (cs.status_sequence < 10) THEN c.id
            ELSE NULL::integer
        END) AS active_cases,
    count(DISTINCT
        CASE
            WHEN ((cs.status_code)::text = 'COMPLETED'::text) THEN c.id
            ELSE NULL::integer
        END) AS completed_cases,
    count(DISTINCT wo.id) AS active_work_orders,
    count(DISTINCT wt.id) AS pending_tasks,
    sum(
        CASE
            WHEN ((wt.status)::text = 'in_progress'::text) THEN 1
            ELSE 0
        END) AS tasks_in_progress,
    sum(
        CASE
            WHEN (vh.id IS NOT NULL) THEN vh.hours
            ELSE (0)::numeric
        END) AS volunteer_hours_ytd
   FROM (((((public.coalition_organizations o
     LEFT JOIN public.cases c ON ((EXISTS ( SELECT 1
           FROM public.intake_submissions s
          WHERE ((s.id = c.submission_id) AND ((s.assigned_organization)::text = (o.organization_name)::text))))))
     LEFT JOIN public.case_statuses cs ON ((c.status_id = cs.id)))
     LEFT JOIN public.work_orders wo ON ((c.id = wo.case_id)))
     LEFT JOIN public.work_tasks wt ON ((wo.id = wt.work_order_id)))
     LEFT JOIN public.volunteer_hours vh ON (((vh.work_order_id = wo.id) AND (vh.date >= date_trunc('year'::text, (CURRENT_DATE)::timestamp with time zone)))))
  GROUP BY o.id, o.organization_name;


--
-- Name: pending_verification_documents; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.pending_verification_documents AS
 SELECT d.id,
    c.case_number,
    s.applicant_first_name,
    s.applicant_last_name,
    dc.category_name,
    d.file_name,
    d.uploaded_by,
    u.full_name AS uploaded_by_name,
    d.uploaded_at,
    d.extracted_text
   FROM ((((public.case_documents d
     JOIN public.cases c ON ((d.case_id = c.id)))
     JOIN public.intake_submissions s ON ((c.submission_id = s.id)))
     JOIN public.document_categories dc ON ((d.category_id = dc.id)))
     LEFT JOIN public.system_users u ON ((d.uploaded_by = u.id)))
  WHERE ((d.status_id = ( SELECT document_statuses.id
           FROM public.document_statuses
          WHERE ((document_statuses.status_code)::text = 'UPLOADED'::text))) OR (d.status_id = ( SELECT document_statuses.id
           FROM public.document_statuses
          WHERE ((document_statuses.status_code)::text = 'PROCESSING'::text))))
  ORDER BY d.uploaded_at;


--
-- Name: permission_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permission_categories (
    id integer NOT NULL,
    category_code character varying(50) NOT NULL,
    category_name character varying(100) NOT NULL,
    description text
);


--
-- Name: permission_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permission_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permission_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permission_categories_id_seq OWNED BY public.permission_categories.id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    id integer NOT NULL,
    permission_code character varying(100) NOT NULL,
    permission_name character varying(200) NOT NULL,
    category_id integer,
    description text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permissions_id_seq OWNED BY public.permissions.id;


--
-- Name: progress_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.progress_events (
    id integer NOT NULL,
    event_guid uuid DEFAULT gen_random_uuid(),
    case_id integer,
    organization_id integer,
    event_type character varying(50) NOT NULL,
    event_description text,
    event_source character varying(50) DEFAULT 'user'::character varying,
    performed_by integer,
    performed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    metadata jsonb DEFAULT '{}'::jsonb,
    is_progress_event boolean DEFAULT true,
    is_immutable boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: progress_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.progress_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: progress_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.progress_events_id_seq OWNED BY public.progress_events.id;


--
-- Name: project_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_assignments (
    id integer NOT NULL,
    case_id integer,
    project_manager_id integer,
    crew_lead_id integer,
    crew_member_ids integer[],
    assigned_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: project_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_assignments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.project_assignments_id_seq OWNED BY public.project_assignments.id;


--
-- Name: project_escalations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_escalations (
    id integer NOT NULL,
    case_id integer,
    raised_by integer,
    issue_type character varying(50),
    severity character varying(20),
    description text,
    action_taken text,
    resolved_at timestamp without time zone,
    resolved_by integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: project_escalations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_escalations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_escalations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.project_escalations_id_seq OWNED BY public.project_escalations.id;


--
-- Name: project_manager_review_queue; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.project_manager_review_queue AS
 SELECT fifo_order,
    submission_id,
    applicant_first_name,
    applicant_last_name,
    home_address,
    submitted_at,
    helene_related,
    status,
    priority_score,
    hours_in_queue,
    primary_issue,
    urgent_count,
    is_eligible,
    best_match_score,
    best_match_org
   FROM public.staff_review_queue
  WHERE ((is_eligible = true) AND (primary_issue IS NOT NULL));


--
-- Name: project_milestones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_milestones (
    id integer NOT NULL,
    case_id integer,
    milestone_type character varying(50),
    milestone_date date,
    milestone_notes text,
    is_complete boolean DEFAULT false,
    completed_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: project_milestones_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_milestones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_milestones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.project_milestones_id_seq OWNED BY public.project_milestones.id;


--
-- Name: project_snapshots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_snapshots (
    id integer NOT NULL,
    snapshot_date date NOT NULL,
    case_id integer,
    progress_percentage integer,
    budget_used numeric(12,2),
    budget_remaining numeric(12,2),
    milestones_completed_since_last integer,
    is_on_schedule boolean,
    is_on_budget boolean,
    days_until_deadline integer,
    days_since_started integer,
    calculated_cost_percentage numeric(5,2),
    calculated_time_percentage numeric(5,2),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: project_snapshots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_snapshots_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_snapshots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.project_snapshots_id_seq OWNED BY public.project_snapshots.id;


--
-- Name: project_status_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.project_status_view AS
 SELECT c.id AS case_id,
    c.case_number,
    c.total_budget AS approved_budget,
    c.total_actual_cost AS current_cost,
    COALESCE((c.total_budget - c.total_actual_cost), (0)::numeric) AS remaining_budget,
    round(COALESCE(((c.total_actual_cost / NULLIF(c.total_budget, (0)::numeric)) * (100)::numeric), (0)::numeric), 1) AS budget_used_percentage,
    s.applicant_first_name,
    s.applicant_last_name,
    s.home_address,
    s.home_city,
    s.home_zip,
    wo.scheduled_start_date,
    wo.scheduled_end_date,
    wo.actual_start_date,
    wo.actual_end_date,
    COALESCE(wo.status, 'pending'::character varying) AS work_order_status,
        CASE
            WHEN (wo.actual_end_date IS NOT NULL) THEN 'completed'::text
            WHEN (wo.actual_start_date IS NOT NULL) THEN 'in_progress'::text
            WHEN (wo.scheduled_start_date > CURRENT_DATE) THEN 'scheduled'::text
            WHEN (wo.scheduled_start_date <= CURRENT_DATE) THEN 'overdue'::text
            ELSE 'pending'::text
        END AS project_phase,
    pa.crew_lead_id,
    cl.full_name AS crew_lead_name,
    pa.crew_member_ids,
    ass.total_estimate,
    ass.assessment_date,
    ass.priority_repairs,
        CASE
            WHEN (c.total_actual_cost > c.total_budget) THEN true
            ELSE false
        END AS budget_alert,
        CASE
            WHEN ((wo.scheduled_end_date < CURRENT_DATE) AND (wo.actual_end_date IS NULL)) THEN true
            ELSE false
        END AS schedule_alert,
        CASE
            WHEN (EXISTS ( SELECT 1
               FROM public.project_escalations
              WHERE ((project_escalations.case_id = c.id) AND (project_escalations.resolved_at IS NULL) AND ((project_escalations.severity)::text = 'critical'::text)))) THEN true
            ELSE false
        END AS critical_alert,
        CASE
            WHEN (c.total_budget > (50000)::numeric) THEN true
            ELSE false
        END AS cap_alert
   FROM (((((public.cases c
     JOIN public.intake_submissions s ON ((c.submission_id = s.id)))
     LEFT JOIN public.work_orders wo ON ((c.id = wo.case_id)))
     LEFT JOIN public.project_assignments pa ON ((c.id = pa.case_id)))
     LEFT JOIN public.system_users cl ON ((pa.crew_lead_id = cl.id)))
     LEFT JOIN public.property_assessments ass ON ((c.id = ass.case_id)))
  WHERE (NOT (c.status_id IN ( SELECT case_statuses.id
           FROM public.case_statuses
          WHERE ((case_statuses.status_code)::text = ANY ((ARRAY['COMPLETED'::character varying, 'DENIED'::character varying])::text[])))));


--
-- Name: property_assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.property_assessments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: property_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.property_assessments_id_seq OWNED BY public.property_assessments.id;


--
-- Name: quest_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quest_assignments (
    id integer NOT NULL,
    quest_id uuid,
    volunteer_id integer,
    status character varying(20) DEFAULT 'assigned'::character varying,
    assigned_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    started_at timestamp without time zone,
    completed_at timestamp without time zone,
    cancelled_at timestamp without time zone,
    hours_logged numeric(5,2),
    hours_verified boolean DEFAULT false,
    verified_by integer,
    verified_at timestamp without time zone,
    before_photo_urls text[],
    during_photo_urls text[],
    after_photo_urls text[],
    volunteer_notes text,
    xp_awarded integer,
    reputation_awarded integer,
    rewards_claimed boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: quest_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.quest_assignments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quest_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.quest_assignments_id_seq OWNED BY public.quest_assignments.id;


--
-- Name: quests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    quest_number character varying(20),
    title character varying(200) NOT NULL,
    description text,
    quest_type character varying(50) NOT NULL,
    difficulty integer,
    xp_reward integer DEFAULT 10,
    reputation_reward integer DEFAULT 5,
    coin_reward integer DEFAULT 0,
    required_level integer DEFAULT 1,
    required_skills text[],
    required_certifications text[],
    max_volunteers integer DEFAULT 1,
    current_volunteers integer DEFAULT 0,
    location_address text,
    location_lat numeric(10,8),
    location_lng numeric(11,8),
    radius_miles integer DEFAULT 25,
    estimated_hours numeric(5,2),
    flexible_timing boolean DEFAULT true,
    scheduled_start timestamp without time zone,
    scheduled_end timestamp without time zone,
    parent_quest_id uuid,
    case_id integer,
    work_task_id integer,
    quest_giver_id integer,
    instructions text,
    safety_notes text,
    materials_needed text[],
    status character varying(20) DEFAULT 'available'::character varying,
    expires_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT quests_difficulty_check CHECK (((difficulty >= 1) AND (difficulty <= 5)))
);


--
-- Name: recently_updated_docs; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.recently_updated_docs AS
 SELECT hd.id,
    hd.document_id,
    hd.title,
    hdt.type_name,
    hc.category_name,
    hd.version,
    hd.updated_at,
    u.full_name AS updated_by_name,
    hd.change_notes
   FROM (((public.help_documents hd
     JOIN public.help_document_types hdt ON ((hd.doc_type_id = hdt.id)))
     JOIN public.help_categories hc ON ((hd.category_id = hc.id)))
     LEFT JOIN public.system_users u ON ((hd.updated_by = u.id)))
  WHERE ((hd.status)::text = 'published'::text)
  ORDER BY hd.updated_at DESC
 LIMIT 20;


--
-- Name: reimbursement_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reimbursement_requests (
    id integer NOT NULL,
    case_id integer,
    organization_id integer,
    amount numeric(12,2) NOT NULL,
    submitted_date date NOT NULL,
    approved_date date,
    paid_date date,
    status character varying(50),
    denial_reason text,
    funding_source_id integer
);


--
-- Name: reimbursement_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reimbursement_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reimbursement_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reimbursement_requests_id_seq OWNED BY public.reimbursement_requests.id;


--
-- Name: repair_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.repair_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repair_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.repair_categories_id_seq OWNED BY public.repair_categories.id;


--
-- Name: repair_category_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repair_category_details (
    id integer NOT NULL,
    submission_id integer,
    category_id integer,
    details_text text,
    heating_woodstove boolean DEFAULT false,
    heating_gas_propane boolean DEFAULT false,
    heating_electric boolean DEFAULT false,
    heating_kerosene boolean DEFAULT false,
    water_source character varying(20)
);


--
-- Name: repair_category_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.repair_category_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repair_category_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.repair_category_details_id_seq OWNED BY public.repair_category_details.id;


--
-- Name: repair_estimates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repair_estimates (
    id integer NOT NULL,
    assessment_id integer,
    repair_category_id integer,
    description text NOT NULL,
    quantity numeric(10,2),
    unit_cost numeric(10,2),
    material_cost numeric(12,2),
    labor_hours numeric(10,2),
    labor_rate numeric(10,2),
    labor_cost numeric(12,2),
    total_cost numeric(12,2),
    is_approved boolean DEFAULT false,
    approved_by integer,
    approved_at timestamp without time zone,
    notes text
);


--
-- Name: repair_estimates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.repair_estimates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repair_estimates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.repair_estimates_id_seq OWNED BY public.repair_estimates.id;


--
-- Name: repair_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repair_requests (
    id integer NOT NULL,
    submission_id integer,
    repair_need text NOT NULL,
    priority integer,
    sort_order integer
);


--
-- Name: repair_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.repair_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repair_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.repair_requests_id_seq OWNED BY public.repair_requests.id;


--
-- Name: review_queue_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.review_queue_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: review_queue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.review_queue_id_seq OWNED BY public.review_queue.id;


--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_permissions (
    id integer NOT NULL,
    role_id integer,
    permission_id integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: role_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.role_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: role_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.role_permissions_id_seq OWNED BY public.role_permissions.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    role_code character varying(50) NOT NULL,
    role_name character varying(100) NOT NULL,
    role_level integer NOT NULL,
    description text,
    is_system_role boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: scope_of_work_line_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scope_of_work_line_items (
    id bigint NOT NULL,
    assessment_id bigint NOT NULL,
    task_name text NOT NULL,
    location text,
    details text,
    estimated_cost numeric(12,2),
    quoted_cost numeric(12,2),
    actual_cost numeric(12,2),
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    repair_need_id bigint,
    case_id bigint,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: scope_of_work_line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.scope_of_work_line_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: scope_of_work_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.scope_of_work_line_items_id_seq OWNED BY public.scope_of_work_line_items.id;


--
-- Name: site_photos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_photos (
    id bigint NOT NULL,
    assessment_id bigint,
    repair_need_id bigint,
    file_path text NOT NULL,
    file_name text NOT NULL,
    title text,
    date_taken timestamp with time zone,
    taken_by text,
    photo_type character varying(20) DEFAULT 'before'::character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: site_photos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_photos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_photos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_photos_id_seq OWNED BY public.site_photos.id;


--
-- Name: skills; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.skills (
    id integer NOT NULL,
    skill_code character varying(50) NOT NULL,
    skill_name character varying(100) NOT NULL,
    category character varying(50),
    description text,
    requires_training boolean DEFAULT false,
    training_resource_url character varying(500),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: skills_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.skills_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: skills_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.skills_id_seq OWNED BY public.skills.id;


--
-- Name: storage_providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.storage_providers (
    id integer NOT NULL,
    provider_name character varying(50) NOT NULL,
    is_default boolean DEFAULT false,
    configuration jsonb NOT NULL,
    base_url character varying(500),
    max_file_size_bytes bigint DEFAULT 104857600,
    allowed_mime_types text[],
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: storage_providers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.storage_providers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: storage_providers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.storage_providers_id_seq OWNED BY public.storage_providers.id;


--
-- Name: subcontractor_communications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subcontractor_communications (
    id integer NOT NULL,
    task_id integer,
    subcontractor_id integer,
    sender_id integer,
    communication_type character varying(50),
    subject character varying(500),
    body text,
    is_read boolean DEFAULT false,
    read_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: subcontractor_communications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subcontractor_communications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subcontractor_communications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subcontractor_communications_id_seq OWNED BY public.subcontractor_communications.id;


--
-- Name: subcontractor_invoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subcontractor_invoices (
    id integer NOT NULL,
    task_id integer,
    subcontractor_id integer,
    invoice_number character varying(50) NOT NULL,
    invoice_date date NOT NULL,
    amount numeric(12,2) NOT NULL,
    work_performed text,
    payment_terms character varying(20) DEFAULT 'Net 30'::character varying,
    invoice_document_id integer,
    status character varying(20) DEFAULT 'submitted'::character varying,
    approved_by integer,
    approved_at timestamp without time zone,
    paid_by integer,
    paid_at timestamp without time zone,
    payment_reference character varying(100),
    rejection_reason text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: subcontractor_invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subcontractor_invoices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subcontractor_invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subcontractor_invoices_id_seq OWNED BY public.subcontractor_invoices.id;


--
-- Name: subcontractor_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subcontractor_profiles (
    id integer NOT NULL,
    user_id integer,
    company_name character varying(200),
    trade_specialty character varying(100) NOT NULL,
    license_number character varying(50),
    insurance_provider character varying(100),
    insurance_expiration date,
    business_phone character varying(20),
    business_email character varying(255),
    business_address text,
    max_active_tasks integer DEFAULT 5,
    service_radius_miles integer DEFAULT 50,
    available_days text[],
    avg_rating numeric(3,2),
    total_rating_count integer DEFAULT 0,
    is_active boolean DEFAULT true,
    is_approved boolean DEFAULT false,
    approval_notes text,
    approved_by integer,
    approved_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: subcontractor_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subcontractor_profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subcontractor_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subcontractor_profiles_id_seq OWNED BY public.subcontractor_profiles.id;


--
-- Name: subcontractor_quotes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subcontractor_quotes (
    id integer NOT NULL,
    task_id integer,
    subcontractor_id integer,
    quote_amount numeric(12,2) NOT NULL,
    labor_cost numeric(12,2),
    materials_cost numeric(12,2),
    travel_cost numeric(12,2),
    quote_details text,
    valid_until date,
    status character varying(20) DEFAULT 'submitted'::character varying,
    approved_by integer,
    approved_at timestamp without time zone,
    rejected_reason text,
    quote_document_id integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: subcontractor_quotes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subcontractor_quotes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subcontractor_quotes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subcontractor_quotes_id_seq OWNED BY public.subcontractor_quotes.id;


--
-- Name: submission_contact_methods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.submission_contact_methods (
    submission_id integer NOT NULL,
    method_id integer NOT NULL
);


--
-- Name: submission_full_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.submission_full_view AS
 SELECT id,
    submission_uuid,
    submitted_at,
    language,
    is_referral,
    referrer_name,
    referrer_organization,
    referrer_email,
    referrer_notes,
    consent_agreed,
    applicant_first_name,
    applicant_last_name,
    applicant_dob,
    applicant_dob_unknown,
    preferred_phone,
    preferred_text,
    preferred_email,
    preferred_other,
    home_phone,
    cell_phone,
    contact_email,
    other_contact_method_description,
    contact_notes,
    home_address,
    home_city,
    home_state,
    home_zip,
    is_primary_residence,
    receives_different_mail,
    mail_address,
    mail_city,
    mail_state,
    mail_zip,
    home_type,
    year_built,
    move_in_date,
    owns_home,
    owns_lot,
    insurance_provider,
    lived_one_year,
    household_size,
    household_adults,
    additional_repair_details,
    urgent_unable_to_stay,
    urgent_no_hvac,
    urgent_no_potable_water,
    urgent_no_bathroom,
    urgent_no_kitchen,
    urgent_open_to_elements,
    urgent_no_entry,
    urgent_accessibility,
    urgent_other_issue,
    urgent_eviction_risk,
    helene_related,
    fema_claim_filed,
    fema_outcome,
    fema_settlement_amount,
    fema_remaining_exists,
    fema_remaining_amount,
    insurance_claim_filed,
    insurance_outcome,
    insurance_settlement_amount,
    insurance_remaining_exists,
    insurance_remaining_amount,
    has_income,
    income_method,
    gross_annual_income,
    income_docs_method,
    zero_income_first_name,
    zero_income_last_name,
    zero_income_address,
    zero_income_agreed,
    applicant_signature,
    zero_income_signature,
    submission_status,
    assigned_organization,
    reviewed_by,
    reviewed_at,
    eligibility_checked_at,
    is_test,
    ( SELECT array_agg(rc.category_code) AS array_agg
           FROM (public.submission_repair_categories src
             JOIN public.repair_categories rc ON ((src.category_id = rc.id)))
          WHERE (src.submission_id = s.id)) AS repair_categories,
    ( SELECT array_agg(ha.attribute_name) AS array_agg
           FROM (public.submission_household_attributes sha
             JOIN public.household_attributes ha ON ((sha.attribute_id = ha.id)))
          WHERE (sha.submission_id = s.id)) AS household_attributes,
    ( SELECT array_agg(cm.method_code) AS array_agg
           FROM (public.submission_contact_methods scm
             JOIN public.contact_methods cm ON ((scm.method_id = cm.id)))
          WHERE (scm.submission_id = s.id)) AS contact_methods,
    ( SELECT sum(
                CASE income_records.frequency
                    WHEN 'weekly'::text THEN (income_records.amount * (52)::numeric)
                    WHEN 'biweekly'::text THEN (income_records.amount * (26)::numeric)
                    WHEN 'monthly'::text THEN (income_records.amount * (12)::numeric)
                    WHEN 'annually'::text THEN income_records.amount
                    ELSE income_records.amount
                END) AS sum
           FROM public.income_records
          WHERE (income_records.submission_id = s.id)) AS calculator_income_total
   FROM public.intake_submissions s;


--
-- Name: support_tickets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.support_tickets (
    id integer NOT NULL,
    submitted_by integer,
    submitter_name character varying(128) DEFAULT ''::character varying NOT NULL,
    submitter_email character varying(256) DEFAULT ''::character varying NOT NULL,
    category character varying(32) DEFAULT 'general'::character varying NOT NULL,
    subject character varying(256) DEFAULT ''::character varying NOT NULL,
    description text NOT NULL,
    screenshot_url text,
    status character varying(20) DEFAULT 'open'::character varying NOT NULL,
    priority character varying(10) DEFAULT 'normal'::character varying NOT NULL,
    assigned_to integer,
    resolved_at timestamp with time zone,
    resolved_by integer,
    resolution_note text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: support_tickets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.support_tickets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: support_tickets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.support_tickets_id_seq OWNED BY public.support_tickets.id;


--
-- Name: system_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.system_users_id_seq OWNED BY public.system_users.id;


--
-- Name: task_status_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_status_history (
    id integer NOT NULL,
    task_id integer,
    from_status character varying(50),
    to_status character varying(50),
    changed_by integer,
    notes text,
    changed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: task_status_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.task_status_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_status_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.task_status_history_id_seq OWNED BY public.task_status_history.id;


--
-- Name: urgent_conditions_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.urgent_conditions_view AS
 SELECT id AS submission_id,
    applicant_first_name,
    applicant_last_name,
    urgent_unable_to_stay,
    urgent_no_hvac,
    urgent_no_potable_water,
    urgent_no_bathroom,
    urgent_no_kitchen,
    urgent_open_to_elements,
    urgent_no_entry,
    urgent_accessibility,
    urgent_other_issue,
    urgent_eviction_risk,
    (((((((urgent_unable_to_stay)::integer + (urgent_no_hvac)::integer) + (urgent_no_potable_water)::integer) + (urgent_no_bathroom)::integer) + (urgent_no_kitchen)::integer) + (urgent_open_to_elements)::integer) + (urgent_no_entry)::integer) AS urgent_condition_count
   FROM public.intake_submissions
  WHERE (urgent_unable_to_stay IS NOT NULL);


--
-- Name: user_role_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_role_assignments (
    id integer NOT NULL,
    user_id integer,
    organization_id integer,
    role_id integer,
    assigned_by integer,
    assigned_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    expires_at timestamp without time zone,
    is_active boolean DEFAULT true,
    notes text
);


--
-- Name: COLUMN user_role_assignments.organization_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_role_assignments.organization_id IS 'Organization affiliation (NULL for requestors who are not part of an organization)';


--
-- Name: user_role_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_role_assignments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_role_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_role_assignments_id_seq OWNED BY public.user_role_assignments.id;


--
-- Name: volunteer_badges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.volunteer_badges (
    id integer NOT NULL,
    volunteer_id integer,
    badge_id integer,
    awarded_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    awarded_by integer
);


--
-- Name: volunteer_badges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.volunteer_badges_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: volunteer_badges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.volunteer_badges_id_seq OWNED BY public.volunteer_badges.id;


--
-- Name: volunteer_content; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.volunteer_content (
    id integer NOT NULL,
    content_id character varying(50) NOT NULL,
    title character varying(300) NOT NULL,
    content text,
    content_html text,
    yaml_frontmatter jsonb DEFAULT '{}'::jsonb,
    content_type character varying(50) NOT NULL,
    tags text[],
    author_id integer,
    author_name character varying(100),
    reviewed_by integer,
    reviewed_at timestamp without time zone,
    view_count integer DEFAULT 0,
    like_count integer DEFAULT 0,
    comment_count integer DEFAULT 0,
    read_xp_reward integer DEFAULT 10,
    status character varying(20) DEFAULT 'draft'::character varying,
    published_at timestamp without time zone,
    pinned_until timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: volunteer_content_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.volunteer_content_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: volunteer_content_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.volunteer_content_id_seq OWNED BY public.volunteer_content.id;


--
-- Name: volunteer_feedback; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.volunteer_feedback (
    id integer NOT NULL,
    quest_id uuid,
    volunteer_id integer,
    beneficiary_id integer,
    quality_rating integer,
    timeliness_rating integer,
    professionalism_rating integer,
    comments text,
    would_recommend boolean,
    photo_urls text[],
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    reputation_delta integer,
    CONSTRAINT volunteer_feedback_professionalism_rating_check CHECK (((professionalism_rating >= 1) AND (professionalism_rating <= 5))),
    CONSTRAINT volunteer_feedback_quality_rating_check CHECK (((quality_rating >= 1) AND (quality_rating <= 5))),
    CONSTRAINT volunteer_feedback_timeliness_rating_check CHECK (((timeliness_rating >= 1) AND (timeliness_rating <= 5)))
);


--
-- Name: volunteer_feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.volunteer_feedback_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: volunteer_feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.volunteer_feedback_id_seq OWNED BY public.volunteer_feedback.id;


--
-- Name: volunteer_hours_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.volunteer_hours_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: volunteer_hours_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.volunteer_hours_id_seq OWNED BY public.volunteer_hours.id;


--
-- Name: volunteer_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.volunteer_profiles (
    id integer NOT NULL,
    user_id integer,
    level integer DEFAULT 1,
    xp integer DEFAULT 0,
    xp_to_next_level integer DEFAULT 100,
    reputation_score integer DEFAULT 0,
    reputation_tier integer DEFAULT 0,
    total_quests_completed integer DEFAULT 0,
    total_hours_logged numeric(10,2) DEFAULT 0,
    consecutive_weeks_active integer DEFAULT 0,
    last_active_at timestamp without time zone,
    push_notifications_enabled boolean DEFAULT true,
    email_digest_enabled boolean DEFAULT true,
    weekly_quest_limit integer DEFAULT 5,
    avatar_choice character varying(50) DEFAULT 'default'::character varying,
    title_equipped character varying(100),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: volunteer_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.volunteer_profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: volunteer_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.volunteer_profiles_id_seq OWNED BY public.volunteer_profiles.id;


--
-- Name: volunteer_skills; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.volunteer_skills (
    id integer NOT NULL,
    volunteer_id integer,
    skill_id integer,
    proficiency_level integer DEFAULT 1,
    endorsed_by integer,
    endorsed_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT volunteer_skills_proficiency_level_check CHECK (((proficiency_level >= 1) AND (proficiency_level <= 5)))
);


--
-- Name: volunteer_skills_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.volunteer_skills_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: volunteer_skills_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.volunteer_skills_id_seq OWNED BY public.volunteer_skills.id;


--
-- Name: weekly_digests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.weekly_digests (
    id integer NOT NULL,
    digest_week date NOT NULL,
    title character varying(200),
    summary text,
    featured_content_ids integer[],
    sent_at timestamp without time zone,
    created_by integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: weekly_digests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.weekly_digests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: weekly_digests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.weekly_digests_id_seq OWNED BY public.weekly_digests.id;


--
-- Name: work_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.work_orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: work_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.work_orders_id_seq OWNED BY public.work_orders.id;


--
-- Name: work_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.work_tasks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: work_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.work_tasks_id_seq OWNED BY public.work_tasks.id;


--
-- Name: activity_detail id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_detail ALTER COLUMN id SET DEFAULT nextval('public.activity_detail_id_seq'::regclass);


--
-- Name: activity_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_log ALTER COLUMN id SET DEFAULT nextval('public.activity_log_id_seq'::regclass);


--
-- Name: application_anchor id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_anchor ALTER COLUMN id SET DEFAULT nextval('public.application_anchor_id_seq'::regclass);


--
-- Name: application_assignments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_assignments ALTER COLUMN id SET DEFAULT nextval('public.application_assignments_id_seq'::regclass);


--
-- Name: applications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.applications ALTER COLUMN id SET DEFAULT nextval('public.applications_id_seq'::regclass);


--
-- Name: assessment_documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_documents ALTER COLUMN id SET DEFAULT nextval('public.assessment_documents_id_seq'::regclass);


--
-- Name: assessment_notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_notes ALTER COLUMN id SET DEFAULT nextval('public.assessment_notes_id_seq'::regclass);


--
-- Name: assessment_tasks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_tasks ALTER COLUMN id SET DEFAULT nextval('public.assessment_tasks_id_seq'::regclass);


--
-- Name: assessments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessments ALTER COLUMN id SET DEFAULT nextval('public.assessments_id_seq'::regclass);


--
-- Name: assignment_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignment_log ALTER COLUMN id SET DEFAULT nextval('public.assignment_log_id_seq'::regclass);


--
-- Name: audit_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log ALTER COLUMN id SET DEFAULT nextval('public.audit_log_id_seq'::regclass);


--
-- Name: badges id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.badges ALTER COLUMN id SET DEFAULT nextval('public.badges_id_seq'::regclass);


--
-- Name: beneficiary_feedback id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.beneficiary_feedback ALTER COLUMN id SET DEFAULT nextval('public.beneficiary_feedback_id_seq'::regclass);


--
-- Name: blocked_ips id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocked_ips ALTER COLUMN id SET DEFAULT nextval('public.blocked_ips_id_seq'::regclass);


--
-- Name: case_communications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_communications ALTER COLUMN id SET DEFAULT nextval('public.case_communications_id_seq'::regclass);


--
-- Name: case_documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_documents ALTER COLUMN id SET DEFAULT nextval('public.case_documents_id_seq'::regclass);


--
-- Name: case_funding id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_funding ALTER COLUMN id SET DEFAULT nextval('public.case_funding_id_seq'::regclass);


--
-- Name: case_repair_claims id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_repair_claims ALTER COLUMN id SET DEFAULT nextval('public.case_repair_claims_id_seq'::regclass);


--
-- Name: case_status_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_status_history ALTER COLUMN id SET DEFAULT nextval('public.case_status_history_id_seq'::regclass);


--
-- Name: case_statuses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_statuses ALTER COLUMN id SET DEFAULT nextval('public.case_statuses_id_seq'::regclass);


--
-- Name: case_withdrawals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_withdrawals ALTER COLUMN id SET DEFAULT nextval('public.case_withdrawals_id_seq'::regclass);


--
-- Name: cases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cases ALTER COLUMN id SET DEFAULT nextval('public.cases_id_seq'::regclass);


--
-- Name: coalition_organizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coalition_organizations ALTER COLUMN id SET DEFAULT nextval('public.coalition_organizations_id_seq'::regclass);


--
-- Name: contact_methods id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contact_methods ALTER COLUMN id SET DEFAULT nextval('public.contact_methods_id_seq'::regclass);


--
-- Name: content_reads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_reads ALTER COLUMN id SET DEFAULT nextval('public.content_reads_id_seq'::regclass);


--
-- Name: crew_completion_documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_completion_documents ALTER COLUMN id SET DEFAULT nextval('public.crew_completion_documents_id_seq'::regclass);


--
-- Name: crew_daily_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_daily_logs ALTER COLUMN id SET DEFAULT nextval('public.crew_daily_logs_id_seq'::regclass);


--
-- Name: crew_incident_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_incident_reports ALTER COLUMN id SET DEFAULT nextval('public.crew_incident_reports_id_seq'::regclass);


--
-- Name: crew_job_cards id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_job_cards ALTER COLUMN id SET DEFAULT nextval('public.crew_job_cards_id_seq'::regclass);


--
-- Name: crew_job_phases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_job_phases ALTER COLUMN id SET DEFAULT nextval('public.crew_job_phases_id_seq'::regclass);


--
-- Name: crew_volunteer_signin id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_volunteer_signin ALTER COLUMN id SET DEFAULT nextval('public.crew_volunteer_signin_id_seq'::regclass);


--
-- Name: criteria_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.criteria_types ALTER COLUMN id SET DEFAULT nextval('public.criteria_types_id_seq'::regclass);


--
-- Name: document_access_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_access_log ALTER COLUMN id SET DEFAULT nextval('public.document_access_log_id_seq'::regclass);


--
-- Name: document_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_categories ALTER COLUMN id SET DEFAULT nextval('public.document_categories_id_seq'::regclass);


--
-- Name: document_generation_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_generation_jobs ALTER COLUMN id SET DEFAULT nextval('public.document_generation_jobs_id_seq'::regclass);


--
-- Name: document_share_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_share_links ALTER COLUMN id SET DEFAULT nextval('public.document_share_links_id_seq'::regclass);


--
-- Name: document_statuses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_statuses ALTER COLUMN id SET DEFAULT nextval('public.document_statuses_id_seq'::regclass);


--
-- Name: document_templates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_templates ALTER COLUMN id SET DEFAULT nextval('public.document_templates_id_seq'::regclass);


--
-- Name: document_verifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_verifications ALTER COLUMN id SET DEFAULT nextval('public.document_verifications_id_seq'::regclass);


--
-- Name: edit_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.edit_requests ALTER COLUMN id SET DEFAULT nextval('public.edit_requests_id_seq'::regclass);


--
-- Name: eligibility_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eligibility_results ALTER COLUMN id SET DEFAULT nextval('public.eligibility_results_id_seq'::regclass);


--
-- Name: email_queue id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_queue ALTER COLUMN id SET DEFAULT nextval('public.email_queue_id_seq'::regclass);


--
-- Name: funding_sources id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funding_sources ALTER COLUMN id SET DEFAULT nextval('public.funding_sources_id_seq'::regclass);


--
-- Name: guest_access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.guest_access_tokens_id_seq'::regclass);


--
-- Name: help_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_categories ALTER COLUMN id SET DEFAULT nextval('public.help_categories_id_seq'::regclass);


--
-- Name: help_document_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_document_attachments ALTER COLUMN id SET DEFAULT nextval('public.help_document_attachments_id_seq'::regclass);


--
-- Name: help_document_feedback id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_document_feedback ALTER COLUMN id SET DEFAULT nextval('public.help_document_feedback_id_seq'::regclass);


--
-- Name: help_document_reviews id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_document_reviews ALTER COLUMN id SET DEFAULT nextval('public.help_document_reviews_id_seq'::regclass);


--
-- Name: help_document_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_document_types ALTER COLUMN id SET DEFAULT nextval('public.help_document_types_id_seq'::regclass);


--
-- Name: help_document_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_document_versions ALTER COLUMN id SET DEFAULT nextval('public.help_document_versions_id_seq'::regclass);


--
-- Name: help_documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_documents ALTER COLUMN id SET DEFAULT nextval('public.help_documents_id_seq'::regclass);


--
-- Name: help_search_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_search_log ALTER COLUMN id SET DEFAULT nextval('public.help_search_log_id_seq'::regclass);


--
-- Name: help_user_progress id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_user_progress ALTER COLUMN id SET DEFAULT nextval('public.help_user_progress_id_seq'::regclass);


--
-- Name: household_attributes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.household_attributes ALTER COLUMN id SET DEFAULT nextval('public.household_attributes_id_seq'::regclass);


--
-- Name: income_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.income_records ALTER COLUMN id SET DEFAULT nextval('public.income_records_id_seq'::regclass);


--
-- Name: intake_submissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intake_submissions ALTER COLUMN id SET DEFAULT nextval('public.intake_submissions_id_seq'::regclass);


--
-- Name: invoice_line_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_line_items ALTER COLUMN id SET DEFAULT nextval('public.invoice_line_items_id_seq'::regclass);


--
-- Name: invoices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices ALTER COLUMN id SET DEFAULT nextval('public.invoices_id_seq'::regclass);


--
-- Name: login_attempts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.login_attempts ALTER COLUMN id SET DEFAULT nextval('public.login_attempts_id_seq'::regclass);


--
-- Name: material_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.material_requests ALTER COLUMN id SET DEFAULT nextval('public.material_requests_id_seq'::regclass);


--
-- Name: materials_inventory id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.materials_inventory ALTER COLUMN id SET DEFAULT nextval('public.materials_inventory_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: organization_eligibility_rules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_eligibility_rules ALTER COLUMN id SET DEFAULT nextval('public.organization_eligibility_rules_id_seq'::regclass);


--
-- Name: organization_metrics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_metrics ALTER COLUMN id SET DEFAULT nextval('public.organization_metrics_id_seq'::regclass);


--
-- Name: organization_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_users ALTER COLUMN id SET DEFAULT nextval('public.organization_users_id_seq'::regclass);


--
-- Name: permission_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permission_categories ALTER COLUMN id SET DEFAULT nextval('public.permission_categories_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions ALTER COLUMN id SET DEFAULT nextval('public.permissions_id_seq'::regclass);


--
-- Name: progress_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.progress_events ALTER COLUMN id SET DEFAULT nextval('public.progress_events_id_seq'::regclass);


--
-- Name: project_assignments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_assignments ALTER COLUMN id SET DEFAULT nextval('public.project_assignments_id_seq'::regclass);


--
-- Name: project_escalations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_escalations ALTER COLUMN id SET DEFAULT nextval('public.project_escalations_id_seq'::regclass);


--
-- Name: project_milestones id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_milestones ALTER COLUMN id SET DEFAULT nextval('public.project_milestones_id_seq'::regclass);


--
-- Name: project_snapshots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_snapshots ALTER COLUMN id SET DEFAULT nextval('public.project_snapshots_id_seq'::regclass);


--
-- Name: property_assessments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.property_assessments ALTER COLUMN id SET DEFAULT nextval('public.property_assessments_id_seq'::regclass);


--
-- Name: quest_assignments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quest_assignments ALTER COLUMN id SET DEFAULT nextval('public.quest_assignments_id_seq'::regclass);


--
-- Name: reimbursement_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reimbursement_requests ALTER COLUMN id SET DEFAULT nextval('public.reimbursement_requests_id_seq'::regclass);


--
-- Name: repair_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_categories ALTER COLUMN id SET DEFAULT nextval('public.repair_categories_id_seq'::regclass);


--
-- Name: repair_category_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_category_details ALTER COLUMN id SET DEFAULT nextval('public.repair_category_details_id_seq'::regclass);


--
-- Name: repair_estimates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_estimates ALTER COLUMN id SET DEFAULT nextval('public.repair_estimates_id_seq'::regclass);


--
-- Name: repair_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_requests ALTER COLUMN id SET DEFAULT nextval('public.repair_requests_id_seq'::regclass);


--
-- Name: review_queue id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_queue ALTER COLUMN id SET DEFAULT nextval('public.review_queue_id_seq'::regclass);


--
-- Name: role_permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions ALTER COLUMN id SET DEFAULT nextval('public.role_permissions_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: scope_of_work_line_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scope_of_work_line_items ALTER COLUMN id SET DEFAULT nextval('public.scope_of_work_line_items_id_seq'::regclass);


--
-- Name: site_photos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_photos ALTER COLUMN id SET DEFAULT nextval('public.site_photos_id_seq'::regclass);


--
-- Name: skills id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.skills ALTER COLUMN id SET DEFAULT nextval('public.skills_id_seq'::regclass);


--
-- Name: storage_providers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storage_providers ALTER COLUMN id SET DEFAULT nextval('public.storage_providers_id_seq'::regclass);


--
-- Name: subcontractor_communications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcontractor_communications ALTER COLUMN id SET DEFAULT nextval('public.subcontractor_communications_id_seq'::regclass);


--
-- Name: subcontractor_invoices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcontractor_invoices ALTER COLUMN id SET DEFAULT nextval('public.subcontractor_invoices_id_seq'::regclass);


--
-- Name: subcontractor_profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcontractor_profiles ALTER COLUMN id SET DEFAULT nextval('public.subcontractor_profiles_id_seq'::regclass);


--
-- Name: subcontractor_quotes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcontractor_quotes ALTER COLUMN id SET DEFAULT nextval('public.subcontractor_quotes_id_seq'::regclass);


--
-- Name: support_tickets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.support_tickets ALTER COLUMN id SET DEFAULT nextval('public.support_tickets_id_seq'::regclass);


--
-- Name: system_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_users ALTER COLUMN id SET DEFAULT nextval('public.system_users_id_seq'::regclass);


--
-- Name: task_status_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_status_history ALTER COLUMN id SET DEFAULT nextval('public.task_status_history_id_seq'::regclass);


--
-- Name: user_role_assignments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_role_assignments ALTER COLUMN id SET DEFAULT nextval('public.user_role_assignments_id_seq'::regclass);


--
-- Name: volunteer_badges id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_badges ALTER COLUMN id SET DEFAULT nextval('public.volunteer_badges_id_seq'::regclass);


--
-- Name: volunteer_content id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_content ALTER COLUMN id SET DEFAULT nextval('public.volunteer_content_id_seq'::regclass);


--
-- Name: volunteer_feedback id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_feedback ALTER COLUMN id SET DEFAULT nextval('public.volunteer_feedback_id_seq'::regclass);


--
-- Name: volunteer_hours id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_hours ALTER COLUMN id SET DEFAULT nextval('public.volunteer_hours_id_seq'::regclass);


--
-- Name: volunteer_profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_profiles ALTER COLUMN id SET DEFAULT nextval('public.volunteer_profiles_id_seq'::regclass);


--
-- Name: volunteer_skills id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_skills ALTER COLUMN id SET DEFAULT nextval('public.volunteer_skills_id_seq'::regclass);


--
-- Name: weekly_digests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weekly_digests ALTER COLUMN id SET DEFAULT nextval('public.weekly_digests_id_seq'::regclass);


--
-- Name: work_orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders ALTER COLUMN id SET DEFAULT nextval('public.work_orders_id_seq'::regclass);


--
-- Name: work_tasks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_tasks ALTER COLUMN id SET DEFAULT nextval('public.work_tasks_id_seq'::regclass);


--
-- Data for Name: activity_detail; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.activity_detail (id, event_guid, created_at, expires_at, ledger_id, user_id, user_name, session_id, ip_address, application_id, case_id, action, field_name, old_value, new_value, details, source, prev_hash, entry_hash) FROM stdin;
1	239f26fd-1814-4593-a6e8-8c146a34e21b	2026-09-04 15:11:15	2026-10-04 11:11:15.007239	14	151	Super Administrator	6t4k5pd06qcn1os806cvk5cn3c	127.0.0.1	5	\N	application_field_changed	applicant_last_name	Shanders	Smanders	[]	web	\N	5c14381d3fe621db7a32b90b0cb804ef02b0a9262cb5e342c15e55f39741681d
2	b1129357-e58f-4fa1-8be9-c05b2f6a7fc7	2026-09-07 14:16:06	2026-10-07 10:16:06.234731	19	151	Super Administrator		::1	53	52	application_field_changed	firstName	Williard	Williard	{"ledger_id": 19, "new_value": "Williard", "old_value": "Williard", "field_name": "firstName"}	vue	5c14381d3fe621db7a32b90b0cb804ef02b0a9262cb5e342c15e55f39741681d	6a1d8f2ed734c962bfc78c8dd303760ff8b8fb430b02a64842179192593f937f
4	e987b40e-d2f6-4921-914b-51d54c35a2d1	2026-09-07 14:16:06	2026-10-07 10:16:06.354325	19	151	Super Administrator		::1	53	52	application_field_changed	email	willard.mashburn@example.com	willard.mashburn@example.com	{"ledger_id": 19, "new_value": "willard.mashburn@example.com", "old_value": "willard.mashburn@example.com", "field_name": "email"}	vue	6a1d8f2ed734c962bfc78c8dd303760ff8b8fb430b02a64842179192593f937f	26751dbe481d913eae84d0943b5893146e08203ba55090372c0c5a717c4fce53
6	aaa77b34-aa63-4231-b2d6-b6f1e65006d4	2026-09-07 14:16:06	2026-10-07 10:16:06.458606	19	151	Super Administrator		::1	53	52	application_field_changed	phone	(828) 555-0181	(828) 555-0181	{"ledger_id": 19, "new_value": "(828) 555-0181", "old_value": "(828) 555-0181", "field_name": "phone"}	vue	26751dbe481d913eae84d0943b5893146e08203ba55090372c0c5a717c4fce53	d4f5518c289d774bfc1769f6dbba2d3c4f5401b59ab2cab3e2d3a800ba2c1264
7	bdfe2dd0-be95-4066-9f53-a86d2206c183	2026-09-07 14:21:48	2026-10-07 10:21:48.826244	20	151	Super Administrator		::1	\N	32	application_field_changed	firstName	Harold	Sharold	{"household": "310 New Haw Creek Road - Asheville", "ledger_id": 20, "new_value": "Sharold", "old_value": "Harold", "field_name": "firstName"}	vue	d4f5518c289d774bfc1769f6dbba2d3c4f5401b59ab2cab3e2d3a800ba2c1264	0e927d6dbe577a8ad4a6977b956843493821bbb371192193fe3ace0f19c81f3c
8	fca0144f-c6d1-4784-ad05-c4df4ba01755	2026-09-07 14:21:48	2026-10-07 10:21:48.860281	20	151	Super Administrator		::1	\N	32	application_field_changed	lastName	Gillespie	Gillespie	{"household": "310 New Haw Creek Road - Asheville", "ledger_id": 20, "new_value": "Gillespie", "old_value": "Gillespie", "field_name": "lastName"}	vue	0e927d6dbe577a8ad4a6977b956843493821bbb371192193fe3ace0f19c81f3c	0771f26ee5c88fd5adeb15f1b967c7f3114768f2896c015245edd2e01222836f
10	31630f12-ad78-4f7f-be53-6557687ba0fd	2026-09-07 14:21:48	2026-10-07 10:21:48.869023	20	151	Super Administrator		::1	\N	32	application_field_changed	phone	(828) 555-0169	(828) 555-0169	{"household": "310 New Haw Creek Road - Asheville", "ledger_id": 20, "new_value": "(828) 555-0169", "old_value": "(828) 555-0169", "field_name": "phone"}	vue	0771f26ee5c88fd5adeb15f1b967c7f3114768f2896c015245edd2e01222836f	c27cc2e83be0d91901f08d91e0fbaf9b8903a091f572c910da4e6a249995ff47
12	c2f1186b-ddb8-474e-ac12-af427ce78977	2026-09-07 14:21:48	2026-10-07 10:21:48.87772	20	151	Super Administrator		::1	\N	32	application_field_changed	email	harold.gillespie@example.com	harold.gillespie@example.com	{"household": "310 New Haw Creek Road - Asheville", "ledger_id": 20, "new_value": "harold.gillespie@example.com", "old_value": "harold.gillespie@example.com", "field_name": "email"}	vue	c27cc2e83be0d91901f08d91e0fbaf9b8903a091f572c910da4e6a249995ff47	d9b82597ac1e7223851685e1fb270b9590d32edd8c04b543be08a1e45d0e4a4c
13	f9a81ad2-23a3-442c-9442-451f50423b43	2026-09-08 12:32:18	2026-10-08 08:32:18.751018	21	151	Super Administrator		::1	\N	39	application_field_changed	firstName	Gladys	Gladys	{"household": "7 Claxton Place - Asheville", "ledger_id": 21, "new_value": "Gladys", "old_value": "Gladys", "field_name": "firstName"}	vue	d9b82597ac1e7223851685e1fb270b9590d32edd8c04b543be08a1e45d0e4a4c	ae15ebd8b75e1594688082fa074a10f32c4b97927ec91cf9fcb05daf71bc509a
15	a4890db7-9f05-4c2c-acb6-39ca74e9acbc	2026-09-08 12:32:18	2026-10-08 08:32:18.768197	21	151	Super Administrator		::1	\N	39	application_field_changed	lastName	Worley	Wurley	{"household": "7 Claxton Place - Asheville", "ledger_id": 21, "new_value": "Wurley", "old_value": "Worley", "field_name": "lastName"}	vue	ae15ebd8b75e1594688082fa074a10f32c4b97927ec91cf9fcb05daf71bc509a	44497b4c75ae247c22f92c033e9103f62e858c647bff56d339c63dfc84916f1e
16	ad7a4429-8b58-4f44-aa58-4ccd679d9558	2026-09-08 12:32:18	2026-10-08 08:32:18.778906	21	151	Super Administrator		::1	\N	39	application_field_changed	email	gladys.worley@example.com	gladys.worley@example.com	{"household": "7 Claxton Place - Asheville", "ledger_id": 21, "new_value": "gladys.worley@example.com", "old_value": "gladys.worley@example.com", "field_name": "email"}	vue	44497b4c75ae247c22f92c033e9103f62e858c647bff56d339c63dfc84916f1e	eb1687fb644b1c426dd1f1d10f5e3f217f7d18b6e0cad352e9a0a2a058247636
17	3a9b0653-8c0c-431c-9b03-b008edd0d6a0	2026-09-08 12:32:18	2026-10-08 08:32:18.794985	21	151	Super Administrator		::1	\N	39	application_field_changed	phone	(828) 555-0141	(828) 555-0141	{"household": "7 Claxton Place - Asheville", "ledger_id": 21, "new_value": "(828) 555-0141", "old_value": "(828) 555-0141", "field_name": "phone"}	vue	eb1687fb644b1c426dd1f1d10f5e3f217f7d18b6e0cad352e9a0a2a058247636	4a2d477b92ca85faba6ed191683781f486fe38e342ca30e214d2275f946b79e1
18	81604dda-54e9-440e-987a-62f9e2cf2318	2026-09-09 02:40:25	2026-10-08 22:40:25.151929	22	6	Sarah Martinez		::1	\N	1	application_field_changed	firstName	Dorothy	Dorothy	{"household": "88 Virginia Avenue - Asheville", "ledger_id": 22, "new_value": "Dorothy", "old_value": "Dorothy", "field_name": "firstName"}	vue	4a2d477b92ca85faba6ed191683781f486fe38e342ca30e214d2275f946b79e1	e7bbfe136b2337acd49bc825fa139720a1ac02562a20379c1e4183d618ff199e
19	b6ec8985-a349-4551-a01f-8e310ada554e	2026-09-09 02:40:25	2026-10-08 22:40:25.170631	22	6	Sarah Martinez		::1	\N	1	application_field_changed	lastName	Calloway	Callowatt	{"household": "88 Virginia Avenue - Asheville", "ledger_id": 22, "new_value": "Callowatt", "old_value": "Calloway", "field_name": "lastName"}	vue	e7bbfe136b2337acd49bc825fa139720a1ac02562a20379c1e4183d618ff199e	7d773f3ead54dd45576d5492d106788d169aec2e89dc08456c0bdff4f280f22f
20	34b5eb42-e3c2-49f4-94c2-e5afa67aa4a9	2026-09-09 02:40:25	2026-10-08 22:40:25.179685	22	6	Sarah Martinez		::1	\N	1	application_field_changed	phone	(828) 555-0143	(828) 555-0143	{"household": "88 Virginia Avenue - Asheville", "ledger_id": 22, "new_value": "(828) 555-0143", "old_value": "(828) 555-0143", "field_name": "phone"}	vue	7d773f3ead54dd45576d5492d106788d169aec2e89dc08456c0bdff4f280f22f	67120a2f658b9598e64252809e3c9a4dfb3c5d139d5bea1c4fe41aca308d509b
21	764d11ac-8b6c-4cc0-98f3-9d862eee6cc0	2026-09-09 02:40:25	2026-10-08 22:40:25.194517	22	6	Sarah Martinez		::1	\N	1	application_field_changed	email	dorothy.calloway@example.com	dorothy.calloway@example.com	{"household": "88 Virginia Avenue - Asheville", "ledger_id": 22, "new_value": "dorothy.calloway@example.com", "old_value": "dorothy.calloway@example.com", "field_name": "email"}	vue	67120a2f658b9598e64252809e3c9a4dfb3c5d139d5bea1c4fe41aca308d509b	8fb7729db0a08a7a2a6d812660bd4056ae583c6868c0ff1a26c2bcdb97812cac
22	22a5c2de-d90e-4a39-8a4c-bee7379427f3	2026-10-05 13:36:55	2026-11-04 09:36:56.001238	23	151	Super Administrator		127.0.0.1	\N	8	application_field_changed	firstName	Walter	Walter	{"household": "15 Church Street - Weaverville", "ledger_id": 23, "new_value": "Walter", "old_value": "Walter", "field_name": "firstName"}	vue	8fb7729db0a08a7a2a6d812660bd4056ae583c6868c0ff1a26c2bcdb97812cac	faa63b84943564faa94a7fea2fd7f8c625b96ab131a644516904c2121c0acace
24	e910c73f-b697-4df8-8f7c-1033cba8e1ca	2026-10-05 13:36:56	2026-11-04 09:36:56.01339	23	151	Super Administrator		127.0.0.1	\N	8	application_field_changed	lastName	Bloonie	Boone	{"household": "15 Church Street - Weaverville", "ledger_id": 23, "new_value": "Boone", "old_value": "Bloonie", "field_name": "lastName"}	vue	faa63b84943564faa94a7fea2fd7f8c625b96ab131a644516904c2121c0acace	9ff9a561f8f16fb2f8171a01de5510883ba42116d4e7dc398bc4382f59e82c0f
25	26a059d2-ca98-4b74-9366-a3c0da38cfd0	2026-10-05 13:36:56	2026-11-04 09:36:56.021427	23	151	Super Administrator		127.0.0.1	\N	8	application_field_changed	email	walter.boone@example.com	walter.boone@example.com	{"household": "15 Church Street - Weaverville", "ledger_id": 23, "new_value": "walter.boone@example.com", "old_value": "walter.boone@example.com", "field_name": "email"}	vue	9ff9a561f8f16fb2f8171a01de5510883ba42116d4e7dc398bc4382f59e82c0f	77029660d393d8dc4050e96e80dd3d2d59c372190fec2a68660ad1f294728aa5
26	56bf1a93-45ce-47dd-8cfb-6331a1416468	2026-10-05 13:36:56	2026-11-04 09:36:56.030784	23	151	Super Administrator		127.0.0.1	\N	8	application_field_changed	phone	(828) 555-0182	(828) 555-0182	{"household": "15 Church Street - Weaverville", "ledger_id": 23, "new_value": "(828) 555-0182", "old_value": "(828) 555-0182", "field_name": "phone"}	vue	77029660d393d8dc4050e96e80dd3d2d59c372190fec2a68660ad1f294728aa5	732b2627df47b4575e8eb7eb68aedc3cc29d1a15a1e990866de6fecae4756159
\.


--
-- Data for Name: activity_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.activity_log (id, event_guid, created_at, user_id, user_name, session_id, ip_address, application_id, case_id, organization_id, category, action, summary, details, source, prev_hash, entry_hash) FROM stdin;
1	ba1c1c59-ee99-4624-b4b9-d28f97659815	2026-09-04 14:39:11	165	Demo Org Admin	\N	\N	5	5	13	application	application_claimed	Case claimed by Asheville Habitat for Humanity (demo journey seed)	{"seeded": true}	system	\N	cda5c02f76349d7f0d890702e74b2ff44cbc793d796c20706396f9f61eb314db
2	031e7f79-45d8-4668-afdf-9a877a06d31b	2026-09-04 14:39:11	165	Demo Org Admin	\N	\N	5	5	13	application	intake_completed	Intake completed — contact made, claim active, assessor assigned.	{"seeded": true}	system	cda5c02f76349d7f0d890702e74b2ff44cbc793d796c20706396f9f61eb314db	d69ddbc28da9b114fcb925e1bb6bf3ca2ea2a35e37c23e4e62574f374d4404e8
3	f82d9b53-34d4-4889-b04d-a2178a7dbd81	2026-09-04 14:39:11	165	Demo Org Admin	\N	\N	5	5	13	case	assessment_scheduled	Assessment scheduled.	{"seeded": true}	system	d69ddbc28da9b114fcb925e1bb6bf3ca2ea2a35e37c23e4e62574f374d4404e8	74ed00cc53b2d16b534e56934860411ceae953023ad2782ed16fefac1d569d8c
4	7680c395-91a2-4bbe-965a-ac1d4234746d	2026-09-04 14:39:11	165	Demo Org Admin	\N	\N	5	5	13	case	assessment_completed	Assessment completed.	{"seeded": true}	system	74ed00cc53b2d16b534e56934860411ceae953023ad2782ed16fefac1d569d8c	58180c76073316ca796276cf58957c8870e5625ee14dab9b12856c1f11707c1d
5	b62b2279-7041-4d7f-8d87-cc176bc12d19	2026-09-04 14:39:11	165	Demo Org Admin	\N	\N	5	5	13	application	application_approved	Application approved — moving to Planning.	{"seeded": true}	system	58180c76073316ca796276cf58957c8870e5625ee14dab9b12856c1f11707c1d	3a71821a6b6b742c986f8bd35dd6367c54c23ae61cebab2ba73897204a850478
6	d0c63d3f-c4f5-41d9-9c59-438bf886489d	2026-09-04 14:39:31	165	Demo Org Admin	\N	\N	4	4	13	application	intake_completed	Intake completed — contact made, claim active, assessor assigned.	{"seeded": true}	system	3a71821a6b6b742c986f8bd35dd6367c54c23ae61cebab2ba73897204a850478	e255c5b007c8f81f19f6d53f201f3445538d8684d57d729df656628174ed44da
7	5b0a0049-5a4a-418d-a555-7293b6e18ed6	2026-09-04 14:39:32	165	Demo Org Admin	\N	\N	4	4	13	case	assessment_scheduled	Assessment scheduled.	{"seeded": true}	system	e255c5b007c8f81f19f6d53f201f3445538d8684d57d729df656628174ed44da	5783bb832d9ba19b8aa19deafdde3856cdbc5a7b9542e5e49dc2bb7bd678ff76
8	f6d303a8-d8a1-4cfb-8709-3f311f008d37	2026-09-04 14:39:32	165	Demo Org Admin	\N	\N	4	4	13	case	assessment_completed	Assessment completed.	{"seeded": true}	system	5783bb832d9ba19b8aa19deafdde3856cdbc5a7b9542e5e49dc2bb7bd678ff76	797b38b20ab336a6840a0c70f404c3e25fd7ec757f6d39ceb04723f2fa07c6e8
9	3c719ca0-7246-4f17-99b5-b4747dd081dc	2026-09-04 14:39:32	165	Demo Org Admin	\N	\N	4	4	13	application	application_approved	Application approved — moving to Planning.	{"seeded": true}	system	797b38b20ab336a6840a0c70f404c3e25fd7ec757f6d39ceb04723f2fa07c6e8	79753f7d8645227fee0a063d2ae862b3f7980cf195f44e97802cbc43c158a455
10	11be2d08-52c4-4fd4-8e0d-86c257854f73	2026-09-04 14:39:33	165	Demo Org Admin	\N	\N	4	4	13	application	application_claimed	Case claimed by Asheville Habitat for Humanity (demo journey seed)	{"seeded": true}	system	79753f7d8645227fee0a063d2ae862b3f7980cf195f44e97802cbc43c158a455	98077c92a4a093c75f49ee77e1174eab6f0729b8bc4ac31bc61d9b960934a351
11	bddfa5ea-8845-499a-a834-4bb52b53f8da	2026-09-04 14:30:42	151	Super Administrator	s8qdcl7b25ngvo0e0buohti4vh	127.0.0.1	5	\N	\N	application	application_updated	Applicant contact updated: last name	{"changed_fields": ["applicant_last_name"]}	web	98077c92a4a093c75f49ee77e1174eab6f0729b8bc4ac31bc61d9b960934a351	7ba5e94c36cbfda4897f8264a80f77c29291c19924b795ab7e1a1b07eac60dbc
12	dc26426b-0cae-4880-ac34-121b05f03772	2026-09-04 14:31:22	151	Super Administrator	s8qdcl7b25ngvo0e0buohti4vh	127.0.0.1	5	56	70	application	application_claimed	Case claimed by Community Housing Coalition (1 repair(s))	{"notes": null, "repair_ids": [8], "new_case_claim": true, "repairs_claimed": 1}	web	7ba5e94c36cbfda4897f8264a80f77c29291c19924b795ab7e1a1b07eac60dbc	94ab0644e5c0382353bc1d3f19853f20b4627feca6582f9640421c803d81790c
13	5d708b9d-5ffc-4f7d-a0bf-893f2ffc25c6	2026-09-04 14:57:58	151	Super Administrator	uv9rv21nhhvvubq3np6e4ctftj	127.0.0.1	4	\N	\N	application	application_updated	Applicant contact updated: first name, last name, email, phone	{"changed_fields": ["applicant_first_name", "applicant_last_name", "applicant_email", "applicant_phone"]}	web	94ab0644e5c0382353bc1d3f19853f20b4627feca6582f9640421c803d81790c	2a8f010fab0cdc236e2b5c33a9172772f1141861231cea0f3318a896fc0ff2e9
14	65b0d162-750d-4030-8c1a-78268abe25c7	2026-09-04 15:11:14	151	Super Administrator	6t4k5pd06qcn1os806cvk5cn3c	127.0.0.1	5	\N	\N	application	application_updated	Applicant contact updated: last name	{"changed_fields": ["applicant_last_name"]}	web	2a8f010fab0cdc236e2b5c33a9172772f1141861231cea0f3318a896fc0ff2e9	9be8db84c8590539aaadf4d0d4fc10e2e3c94d1391a40a6ecd80be582efd1464
15	552b25af-70f2-44fa-8de2-b9fcf0ed7f4b	2026-09-07 13:58:27	151	Super Administrator		::1	5	\N	\N	application	application_updated	Test entry from curl	{"test": true}	test	9be8db84c8590539aaadf4d0d4fc10e2e3c94d1391a40a6ecd80be582efd1464	5f50323737fcd187b1aa5de5d26bbe009498acf5f6ec0160a0b1b8b120f5bffa
16	219d1c27-69d7-4ef9-bfd5-aa2db7771de1	2026-09-07 13:59:28	151	Super Administrator		::1	16	15	\N	application	application_updated	Applicant contact updated: firstName, lastName, email, phone	{"changed_fields": ["firstName", "lastName", "email", "phone"]}	vue	5f50323737fcd187b1aa5de5d26bbe009498acf5f6ec0160a0b1b8b120f5bffa	115200a18156ab9c19d2729122e3287d46f4417be09beee41029b06f4787a748
17	6ff7ffca-6c7c-4bd5-9d08-d89bace85c5d	2026-09-07 14:11:22	151	Super Administrator		::1	5	\N	\N	application	application_updated	Test ledger entry	{"changed_fields": ["email"]}	test	115200a18156ab9c19d2729122e3287d46f4417be09beee41029b06f4787a748	9f462cfc193b4f98cf6d07fd199ab2cdde75b1abb5f8043c23ae5d2145257d36
18	3bd8a1bb-4ea2-45c4-8db7-dd78d002027e	2026-09-07 14:11:48	151	Super Administrator		::1	5	\N	\N	application	application_field_changed		{"ledger_id": 17, "new_value": "angela.rice@ejemple.com", "old_value": "angela.rice@example.com", "field_name": "email"}	test	9f462cfc193b4f98cf6d07fd199ab2cdde75b1abb5f8043c23ae5d2145257d36	ded5bd0cd67889c02c954096a04a0ea11b63036cd0b836e7a8e6e75016fc6485
19	a971688f-b344-4aa6-aa15-bd2c47a457fc	2026-09-07 14:16:05	151	Super Administrator		::1	53	52	\N	application	application_updated	Applicant contact updated: first name, last name, email, phone	{"changed_fields": ["firstName", "lastName", "email", "phone"]}	vue	ded5bd0cd67889c02c954096a04a0ea11b63036cd0b836e7a8e6e75016fc6485	c6c48ee8facd836eee2d11a16c3866d3aa60b38996d179f7221e8cfd7f1b1817
20	fb9dc8e3-d03d-4bfb-9d0b-dd0b2cc864b8	2026-09-07 14:21:48	151	Super Administrator		::1	\N	32	\N	application	application_updated	Applicant contact updated: first name, last name, email, phone	{"household": "310 New Haw Creek Road - Asheville", "changed_fields": ["firstName", "lastName", "email", "phone"]}	vue	c6c48ee8facd836eee2d11a16c3866d3aa60b38996d179f7221e8cfd7f1b1817	8bb05436a90c29baa42e9364dc95ff9f01dba1ac71d3e6f8b6b28ac373129215
21	0cddf7de-49e7-440f-a9cf-060a6341763f	2026-09-08 12:32:18	151	Super Administrator		::1	\N	39	\N	application	application_updated	Applicant contact updated: first name, last name, email, phone	{"household": "7 Claxton Place - Asheville", "changed_fields": ["firstName", "lastName", "email", "phone"]}	vue	8bb05436a90c29baa42e9364dc95ff9f01dba1ac71d3e6f8b6b28ac373129215	844c6c8598009e8b30fd7457f019a169caea129a80e76f08b7560d5faf7250ee
22	72962033-cc68-48c7-a2c4-fbb82c0db550	2026-09-09 02:40:25	6	Sarah Martinez		::1	\N	1	\N	application	application_updated	Applicant contact updated: first name, last name, email, phone	{"household": "88 Virginia Avenue - Asheville", "changed_fields": ["firstName", "lastName", "email", "phone"]}	vue	844c6c8598009e8b30fd7457f019a169caea129a80e76f08b7560d5faf7250ee	0fbdcfe981e7e034c2e042020cd524bd7d27b85ea9b6fa7fb8146a5f6ee7b01e
23	cf745e12-af3d-462f-ac1a-43ea5f3e8e61	2026-10-05 13:36:55	151	Super Administrator		127.0.0.1	\N	8	\N	application	application_updated	Applicant contact updated: first name, last name, email, phone	{"household": "15 Church Street - Weaverville", "changed_fields": ["firstName", "lastName", "email", "phone"]}	vue	0fbdcfe981e7e034c2e042020cd524bd7d27b85ea9b6fa7fb8146a5f6ee7b01e	ccb5e58c64e0f1ffeda55bef8be6914924b2e28e26a311106669a7bc669cd5ff
\.


--
-- Data for Name: application_anchor; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.application_anchor (id, submission_id, anchor_id, case_number, submitted_at, submitted_from_ip, is_eligible, disqualification_reasons, eligibility_score, current_status, assigned_organization_id, assigned_at, income_bucket, county_bucket, repair_type_bucket, helene_related, created_at, updated_at, placecode, project_code) FROM stdin;
1	1	ANCHOR-20260817-00001	\N	2026-08-17 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$15k-30k	Buncombe	open_to_elements	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	88VIRGIN	D88VIRGIN
2	2	ANCHOR-20260816-00002	\N	2026-08-16 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$30k-50k	Buncombe	no_hvac	f	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	45OLDHAW	A45OLDHAW
3	3	ANCHOR-20260814-00003	\N	2026-08-14 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$0	Other	no_bathroom	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	112RIDGE	D112RIDGE
4	4	ANCHOR-20260812-00004	\N	2026-08-12 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$15k-30k	Madison	no_hvac	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	8TURKEYC	H8TURKEYC
5	5	ANCHOR-20260811-00005	\N	2026-08-11 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$50k-75k	Buncombe	no_kitchen	f	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	220KIMBE	A220KIMBE
6	6	ANCHOR-20260810-00006	\N	2026-08-10 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$15k-30k	Buncombe	no_hvac	f	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	56BANKSA	A56BANKSA
7	7	ANCHOR-20260809-00007	\N	2026-08-09 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$15k-30k	Other	open_to_elements	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	34MAINST	D34MAINST
8	8	ANCHOR-20260808-00008	\N	2026-08-08 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$0	Other	no_potable_water	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	15CHURCH	D15CHURCH
9	9	ANCHOR-20260806-00009	\N	2026-08-06 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$0	Other	accessibility	f	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	90CROWEH	A90CROWEH
10	10	ANCHOR-20260710-00010	\N	2026-07-10 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$30k-50k	Buncombe	open_to_elements	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	12CHERRY	D12CHERRY
11	11	ANCHOR-20260713-00011	\N	2026-07-13 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$30k-50k	Buncombe	open_to_elements	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	12CHERRY	D12CHERRY
12	12	ANCHOR-20260805-00012	\N	2026-08-05 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$0	Other	no_kitchen	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	3LOCUSTS	D3LOCUSTS
13	13	ANCHOR-20260804-00013	\N	2026-08-04 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$15k-30k	Buncombe	no_hvac	f	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	204SUTTO	A204SUTTO
14	14	ANCHOR-20260803-00014	\N	2026-08-03 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$15k-30k	Buncombe	no_potable_water	f	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	7BEAVERD	A7BEAVERD
15	15	ANCHOR-20260802-00015	\N	2026-08-02 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$30k-50k	Other	open_to_elements	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	131MONTR	D131MONTR
16	16	ANCHOR-20260731-00016	\N	2026-07-31 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$15k-30k	Buncombe	no_bathroom	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	66FLORID	D66FLORID
17	17	ANCHOR-20260729-00017	\N	2026-07-29 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$30k-50k	Buncombe	other_issue	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	481SANDH	D481SANDH
18	18	ANCHOR-20260727-00018	\N	2026-07-27 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$15k-30k	Other	no_hvac	f	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	29OLDLEI	A29OLDLEI
19	19	ANCHOR-20260726-00019	\N	2026-07-26 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$0	Other	no_potable_water	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	152NEWST	D152NEWST
20	20	ANCHOR-20260725-00020	\N	2026-07-25 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$1-15k	Madison	no_entry	f	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	5HILLSTR	A5HILLSTR
21	21	ANCHOR-20260723-00021	\N	2026-07-23 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$30k-50k	Buncombe	open_to_elements	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	338BILTM	D338BILTM
22	22	ANCHOR-20260722-00022	\N	2026-07-22 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$50k-75k	Buncombe	no_kitchen	f	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	77GROVES	A77GROVES
23	23	ANCHOR-20260720-00023	\N	2026-07-20 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$15k-30k	Buncombe	no_hvac	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	410SWANN	H410SWANN
24	24	ANCHOR-20260719-00024	\N	2026-07-19 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$15k-30k	Buncombe	no_bathroom	f	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	18RICEBR	A18RICEBR
25	25	ANCHOR-20260717-00025	\N	2026-07-17 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$15k-30k	Buncombe	open_to_elements	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	263HAYWO	D263HAYWO
26	26	ANCHOR-20260716-00026	\N	2026-07-16 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$0	Buncombe	no_hvac	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	9BOSTONW	D9BOSTONW
27	27	ANCHOR-20260715-00027	\N	2026-07-15 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$30k-50k	Madison	open_to_elements	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	85UPPERB	D85UPPERB
28	28	ANCHOR-20260714-00028	\N	2026-07-14 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$0	Buncombe	no_potable_water	f	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	141PATTO	A141PATTO
29	29	ANCHOR-20260712-00029	\N	2026-07-12 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$30k-50k	Buncombe	no_bathroom	f	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	52PONDRO	A52PONDRO
30	30	ANCHOR-20260711-00030	\N	2026-07-11 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$15k-30k	Madison	no_hvac	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	12WALNUT	D12WALNUT
31	31	ANCHOR-20260708-00031	\N	2026-07-08 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$30k-50k	Buncombe	open_to_elements	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	1756RIVE	D1756RIVE
32	32	ANCHOR-20260707-00032	\N	2026-07-07 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$0	Buncombe	no_kitchen	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	23GRACEL	D23GRACEL
33	33	ANCHOR-20260706-00033	\N	2026-07-06 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$15k-30k	Buncombe	open_to_elements	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	310NEWHA	D310NEWHA
34	34	ANCHOR-20260704-00034	\N	2026-07-04 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$15k-30k	Buncombe	no_bathroom	f	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	4LANVALE	A4LANVALE
35	35	ANCHOR-20260703-00035	\N	2026-07-03 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$30k-50k	Buncombe	other_issue	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	612STATE	D612STATE
36	36	ANCHOR-20260702-00036	\N	2026-07-02 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$15k-30k	Other	no_potable_water	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	16OLDMAR	D16OLDMAR
37	37	ANCHOR-20260701-00037	\N	2026-07-01 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$50k-75k	Buncombe	no_hvac	f	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	91BURLIN	A91BURLIN
38	38	ANCHOR-20260629-00038	\N	2026-06-29 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$0	Madison	no_entry	f	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	28BROADW	A28BROADW
39	39	ANCHOR-20260628-00039	\N	2026-06-28 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$30k-50k	Buncombe	open_to_elements	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	503EMMAR	D503EMMAR
40	40	ANCHOR-20260626-00040	\N	2026-06-26 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$15k-30k	Buncombe	no_bathroom	f	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	7CLAXTON	A7CLAXTON
41	41	ANCHOR-20260624-00041	\N	2026-06-24 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$30k-50k	Other	no_hvac	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	840SMOKE	H840SMOKE
42	42	ANCHOR-20260622-00042	\N	2026-06-22 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$15k-30k	Other	open_to_elements	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	102STREE	D102STREE
43	43	ANCHOR-20260621-00043	\N	2026-06-21 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$30k-50k	Buncombe	no_potable_water	f	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	47OTEENC	A47OTEENC
44	44	ANCHOR-20260619-00044	\N	2026-06-19 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$30k-50k	Other	open_to_elements	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	19DILLIN	D19DILLIN
45	45	ANCHOR-20260617-00045	\N	2026-06-17 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$15k-30k	Buncombe	no_bathroom	f	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	231OLDCO	A231OLDCO
46	46	ANCHOR-20260615-00046	\N	2026-06-15 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$15k-30k	Buncombe	no_hvac	f	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	60ARIZON	A60ARIZON
47	47	ANCHOR-20260614-00047	\N	2026-06-14 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$0	Buncombe	no_kitchen	f	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	118WARRE	A118WARRE
48	48	ANCHOR-20260612-00048	\N	2026-06-12 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$15k-30k	Other	accessibility	f	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	33MOUNTA	A33MOUNTA
49	49	ANCHOR-20260610-00049	\N	2026-06-10 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$30k-50k	Buncombe	open_to_elements	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	9GOLDVIE	D9GOLDVIE
50	50	ANCHOR-20260608-00050	\N	2026-06-08 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$15k-30k	Buncombe	no_potable_water	f	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	72HAZELM	A72HAZELM
51	51	ANCHOR-20260818-00051	\N	2026-08-18 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$30k-50k	Buncombe	no_hvac	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	305OLDHA	D305OLDHA
52	52	ANCHOR-20260815-00052	\N	2026-08-15 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$15k-30k	Buncombe	no_bathroom	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	11BELMON	D11BELMON
53	53	ANCHOR-20260813-00053	\N	2026-08-13 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$50k-75k	Buncombe	other_issue	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	520NEWLE	D520NEWLE
54	54	ANCHOR-20260807-00054	\N	2026-08-07 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$0	Buncombe	no_hvac	f	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	26COURTL	A26COURTL
55	55	ANCHOR-20260730-00055	\N	2026-07-30 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$15k-30k	Buncombe	open_to_elements	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	144RIVER	D144RIVER
56	56	ANCHOR-20260801-00056	\N	2026-08-01 10:40:52.469126	127.0.0.1	t	\N	\N	eligible	\N	\N	$15k-30k	Buncombe	open_to_elements	t	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	144RIVER	D144RIVER
58	58	ANCHOR-20261017-00058	AR-2025-0847	2026-10-17 08:54:28.993501	\N	t	\N	78	intake_review	\N	\N	\N	\N	\N	\N	2026-10-17 08:54:28.993501	2026-10-29 08:54:28.993501	PLC-42891	\N
59	59	ANCHOR-20261021-00059	AR-2025-0851	2026-10-21 09:19:01.175171	\N	t	\N	72	intake_review	\N	\N	\N	\N	\N	\N	2026-10-21 09:19:01.175171	2026-10-29 09:19:01.175171	\N	\N
60	60	ANCHOR-20261024-00060	AR-2025-0854	2026-10-24 09:19:01.207177	\N	t	\N	81	intake_review	\N	\N	\N	\N	\N	\N	2026-10-24 09:19:01.207177	2026-10-29 09:19:01.207177	\N	\N
\.


--
-- Data for Name: application_assignments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.application_assignments (id, submission_id, organization_id, status, match_score, claimed_by, claimed_at, rejected_by, rejected_at, rejection_reason, assigned_at, expires_at, notes) FROM stdin;
1	5	70	claimed	\N	\N	2026-09-04 10:31:22.664262	\N	\N	\N	2026-09-04 10:31:22.664262	\N	Claimed by Super Administrator (system user #151)
\.


--
-- Data for Name: applications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.applications (id, application_guid, placecode, display_name, property_address, property_city, property_state, property_zip, applicant_first_name, applicant_last_name, applicant_email, applicant_phone, household_size, status, status_reason, terminated_reason_checkboxes, eligibility_flags, eligibility_report, consolidated_at, consolidated_by, last_activity_at, created_at, updated_at, workflow_status, consent_agreed) FROM stdin;
6	06cacecc-0b76-4a41-ae6f-e67035f9fe73	56BANKSA	56 Banks Avenue - Asheville	56 Banks Avenue	Asheville	NC	28801	Tom	Beck	tom.beck@example.com	(828) 555-0134	2	new	\N	\N	{"red": ["not_homeowner"], "green": ["in_service_area", "primary_residence_confirmed", "income_within_80pct_ami"], "yellow": []}	Green: in_service_area, primary_residence_confirmed, income_within_80pct_ami. Red: not_homeowner	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
7	e79b5df5-6632-4d23-879b-832bf518a3c5	34MAINST	34 Main Street - Rutherfordton	34 Main Street	Rutherfordton	NC	28139	Rosa	Jimenez	rosa.jimenez@example.com	(828) 555-0151	3	new	\N	\N	{"red": ["outside_service_area"], "green": ["homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami", "helene_related"], "yellow": []}	Green: homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami, helene_related. Red: outside_service_area	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
9	50ed48c9-bc0e-4912-9fb5-78833a3f2cf8	90CROWEH	90 Crowe Hollow Road - Candler	90 Crowe Hollow Road	Candler	NC	28715	Helen	Crowe	helen.crowe@example.com	(828) 555-0127	1	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
4	a686f0f6-af0e-45c6-9ca1-e217ea265e62	8TURKEYC	8 Turkey Creek Road - Marshall	8 Turkey Creek Road	Marshall	NC	28753	Jimmy	Raynaud	\N	\N	2	active	\N	\N	{"red": ["mobile_home_no_lot_ownership"], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami, helene_related. Red: mobile_home_no_lot_ownership	2026-08-19 10:40:52.469126	\N	2026-09-04 08:39:31.98948	2026-08-19 10:40:52.469126	2026-09-04 10:57:58.739667	\N	\N
5	9bfac80f-011b-4f8b-b40c-36aca36403a9	220KIMBE	220 Kimberly Avenue - Asheville	220 Kimberly Avenue	Asheville	NC	28804	Evelyn	Smanders	evelyn.sanders@example.com	(828) 555-0119	1	active	\N	\N	{"red": ["income_above_80pct_ami"], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed. Red: income_above_80pct_ami	2026-08-19 10:40:52.469126	\N	2026-09-04 10:31:22.664262	2026-08-19 10:40:52.469126	2026-09-04 11:11:14.993046	\N	\N
445504	61c11e8a-7722-4d15-8b57-b40bcab886e0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.033729	\N	2026-10-05 09:01:24.033729	2026-10-05 09:01:24.033729	2026-10-05 13:01:24.031	assessment-ready	\N
551552	92d2ea32-1f4d-43ea-ab67-7eae21fc47ed	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.061484	\N	2026-10-05 09:01:24.061484	2026-10-05 09:01:24.061484	2026-10-05 13:01:24.061	assessment-ready	\N
111552	6b67f838-a05e-4751-8835-bf174214df6a	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.062336	\N	2026-10-05 09:01:24.062336	2026-10-05 09:01:24.062336	2026-10-05 13:01:24.062	assessment-ready	\N
839808	b14ef030-f53e-46df-9f10-295ddc2596df	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.062961	\N	2026-10-05 09:01:24.062961	2026-10-05 09:01:24.062961	2026-10-05 13:01:24.062	assessment-ready	\N
398080	cc3f3d85-5cce-43f8-a66a-341c60b40de7	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.063479	\N	2026-10-05 09:01:24.063479	2026-10-05 09:01:24.063479	2026-10-05 13:01:24.063	assessment-ready	\N
621760	2a458560-13b6-4e34-9ebd-277b8adaca08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.064053	\N	2026-10-05 09:01:24.064053	2026-10-05 09:01:24.064053	2026-10-05 13:01:24.063	assessment-ready	\N
256384	1ff7a1fc-6d93-44a9-9f6c-9afa56d43f8f	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.066436	\N	2026-10-05 09:01:24.066436	2026-10-05 09:01:24.066436	2026-10-05 13:01:24.066	assessment-ready	\N
441024	4c6e3e42-c1f7-47fe-8488-a41556e0f186	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.067068	\N	2026-10-05 09:01:24.067068	2026-10-05 09:01:24.067068	2026-10-05 13:01:24.066	assessment-ready	\N
293120	395219ed-4e31-4eec-9138-8b5ae2f85f9b	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.067574	\N	2026-10-05 09:01:24.067574	2026-10-05 09:01:24.067574	2026-10-05 13:01:24.067	assessment-ready	\N
12	a50bb878-1955-4018-8fef-d385a752267e	204SUTTO	204 Sutton Avenue - Asheville	204 Sutton Avenue	Asheville	NC	28806	Henry	Abernathy	henry.abernathy@example.com	(828) 555-0108	2	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
13	bdfee0ed-f542-4bc5-a4e3-730b6b502185	7BEAVERD	7 Beaverdam Road - Asheville	7 Beaverdam Road	Asheville	NC	28804	Lucille	Plemmons	lucille.plemmons@example.com	(828) 555-0171	1	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
14	9a3dceb6-6b67-4da7-8c6b-5a00f91c2398	131MONTR	131 Montreat Road - Black Mountain	131 Montreat Road	Black Mountain	NC	28711	Robert	Trantham	robert.trantham@example.com	(828) 555-0139	2	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
15	85e26ace-7f36-4c1c-97e3-1d7af986e1f5	66FLORID	66 Florida Avenue - Asheville	66 Florida Avenue	Asheville	NC	28806	Angela	Rice	angela.rice@example.com	(828) 555-0112	3	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
16	306c7984-223a-4ce6-a3bd-eac90c2e6086	481SANDH	481 Sand Hill Road - Asheville	481 Sand Hill Road	Asheville	NC	28806	Charles	Sprinkle	charles.sprinkle@example.com	(828) 555-0166	2	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
17	f44f55a6-f4e8-437b-a262-0beb41198e00	29OLDLEI	29 Old Leicester Highway - Candler	29 Old Leicester Highway	Candler	NC	28715	Betty	Gudger	betty.gudger@example.com	(828) 555-0185	1	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
18	c3c5a9eb-9c18-415b-a658-87ee68ec4121	152NEWST	152 New Stock Road - Weaverville	152 New Stock Road	Weaverville	NC	28787	James	Whitson	james.whitson@example.com	(828) 555-0121	4	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
915712	67fb91a2-2198-48b3-b68b-91415e5c6302	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.068109	\N	2026-10-05 09:01:24.068109	2026-10-05 09:01:24.068109	2026-10-05 13:01:24.067	assessment-ready	\N
93632	513cb2a9-3eb2-4bd3-94b5-9d632f8eeda7	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.068584	\N	2026-10-05 09:01:24.068584	2026-10-05 09:01:24.068584	2026-10-05 13:01:24.068	assessment-ready	\N
577280	13d8fc04-ea2c-4694-9edb-59ce62b60528	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.06895	\N	2026-10-05 09:01:24.06895	2026-10-05 09:01:24.06895	2026-10-05 13:01:24.068	assessment-ready	\N
359040	c4c83f69-41f5-4b8e-a209-8ab0df34b9ec	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.069359	\N	2026-10-05 09:01:24.069359	2026-10-05 09:01:24.069359	2026-10-05 13:01:24.069	assessment-ready	\N
68096	d39bfee0-1086-404a-8bbd-9bf9943b405a	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.069736	\N	2026-10-05 09:01:24.069736	2026-10-05 09:01:24.069736	2026-10-05 13:01:24.069	assessment-ready	\N
662848	4ba0e3d2-3b2c-4e0b-99bb-d887f9b3ea58	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.070102	\N	2026-10-05 09:01:24.070102	2026-10-05 09:01:24.070102	2026-10-05 13:01:24.069	assessment-ready	\N
555328	0f90c240-567c-4288-ad2d-852e146073f4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.07087	\N	2026-10-05 09:01:24.07087	2026-10-05 09:01:24.07087	2026-10-05 13:01:24.07	assessment-ready	\N
759168	67fc8757-8bb1-4840-8ca6-a40f988421d6	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.071344	\N	2026-10-05 09:01:24.071344	2026-10-05 09:01:24.071344	2026-10-05 13:01:24.071	assessment-ready	\N
517696	dbaa33d3-741a-4674-9590-a02f2e4be843	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.071787	\N	2026-10-05 09:01:24.071787	2026-10-05 09:01:24.071787	2026-10-05 13:01:24.071	in-assessment	\N
557248	a411bbe7-854b-47be-b5b4-82e87a6859c6	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.072197	\N	2026-10-05 09:01:24.072197	2026-10-05 09:01:24.072197	2026-10-05 13:01:24.072	in-assessment	\N
960	ac427620-901a-485f-9a03-1f1d99871490	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.072549	\N	2026-10-05 09:01:24.072549	2026-10-05 09:01:24.072549	2026-10-05 13:01:24.072	in-assessment	\N
231744	cae35337-4d78-425c-b2dc-b21d7035c5f6	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.072931	\N	2026-10-05 09:01:24.072931	2026-10-05 09:01:24.072931	2026-10-05 13:01:24.072	in-assessment	\N
142464	e6835d84-ad1d-46d3-9198-a8dd384fb28d	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.073229	\N	2026-10-05 09:01:24.073229	2026-10-05 09:01:24.073229	2026-10-05 13:01:24.073	in-assessment	\N
327104	ae67b605-7d70-461c-b38c-fd1aeed40638	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.073518	\N	2026-10-05 09:01:24.073518	2026-10-05 09:01:24.073518	2026-10-05 13:01:24.073	in-assessment	\N
106176	89693fd9-bd9d-4f44-b999-eeac0f44f9ea	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.073802	\N	2026-10-05 09:01:24.073802	2026-10-05 09:01:24.073802	2026-10-05 13:01:24.073	in-assessment	\N
684352	6c8fdfeb-aea1-4bc3-b662-2b00ebf557f9	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.074132	\N	2026-10-05 09:01:24.074132	2026-10-05 09:01:24.074132	2026-10-05 13:01:24.073	in-assessment	\N
833792	3e1d1e0c-e651-4aa3-a7cf-e36bdb27bc52	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.074419	\N	2026-10-05 09:01:24.074419	2026-10-05 09:01:24.074419	2026-10-05 13:01:24.074	in-assessment	\N
716480	884ccb7e-90ee-4bfe-86ec-4e5f703a1c34	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.074696	\N	2026-10-05 09:01:24.074696	2026-10-05 09:01:24.074696	2026-10-05 13:01:24.074	in-assessment	\N
673216	60aecd12-5d1a-471f-9cca-c5b34acafc14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.074957	\N	2026-10-05 09:01:24.074957	2026-10-05 09:01:24.074957	2026-10-05 13:01:24.074	in-assessment	\N
697984	44fb16f9-d2bd-4198-8ff0-2c77990879f3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.075233	\N	2026-10-05 09:01:24.075233	2026-10-05 09:01:24.075233	2026-10-05 13:01:24.075	assessed	\N
542592	211c67cc-72c4-487a-819e-e68519a7f775	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.075496	\N	2026-10-05 09:01:24.075496	2026-10-05 09:01:24.075496	2026-10-05 13:01:24.075	assessed	\N
19	7baecdb5-3029-4c91-8088-1ab5fe84d26a	5HILLSTR	5 Hill Street - Marshall	5 Hill Street	Marshall	NC	28753	Frances	Hyatt	frances.hyatt@example.com	(828) 555-0144	1	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
20	9a22cd35-15de-45e4-afe1-30898ed4edd3	338BILTM	338 Biltmore Avenue - Asheville	338 Biltmore Avenue	Asheville	NC	28801	Douglas	Kirkpatrick	douglas.kirkpatrick@example.com	(828) 555-0158	2	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
21	f6a2bd62-0037-4140-9b1d-c2403ea0fabd	77GROVES	77 Grove Street - Asheville	77 Grove Street	Asheville	NC	28801	Wanda	Suttles	wanda.suttles@example.com	(828) 555-0199	3	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
22	5ca058fb-0bfb-4567-9a56-2cdef3483994	410SWANN	410 Swannanoa River Road - Asheville	410 Swannanoa River Road	Asheville	NC	28805	Billy	Messer	billy.messer@example.com	(828) 555-0116	2	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
23	3f9bec7d-b2b0-4155-95dd-19e4b1c95d15	18RICEBR	18 Rice Branch Road - Asheville	18 Rice Branch Road	Asheville	NC	28805	June	Arrowood	june.arrowood@example.com	(828) 555-0132	1	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
24	f6090e22-a516-4cef-8bc2-3ad7a2a6211a	263HAYWO	263 Haywood Road - Asheville	263 Haywood Road	Asheville	NC	28806	Albert	Pruitt	albert.pruitt@example.com	(828) 555-0173	2	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
25	74256127-0c07-4620-9315-3a95f18cbb81	9BOSTONW	9 Boston Way - Asheville	9 Boston Way	Asheville	NC	28806	Sheila	Godfrey	sheila.godfrey@example.com	(828) 555-0164	3	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
26	4ac08590-798c-49e3-83a2-b597a374a3c0	85UPPERB	85 Upper Brush Creek Road - Marshall	85 Upper Brush Creek Road	Marshall	NC	28753	Ray	Buckner	ray.buckner@example.com	(828) 555-0187	2	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
27	abd45337-3c4f-4dee-809d-c2a2a2502dcc	141PATTO	141 Patton Avenue - Asheville	141 Patton Avenue	Asheville	NC	28801	Carolyn	Metcalf	carolyn.metcalf@example.com	(828) 555-0129	1	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
28	3fceed0d-a734-4b48-8c81-167109b3a274	52PONDRO	52 Pond Road - Asheville	52 Pond Road	Asheville	NC	28806	Ernest	Balling	ernest.balling@example.com	(828) 555-0106	2	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
189120	cfcf0f0a-58fa-47e8-9d98-230e3f60cb9e	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.075762	\N	2026-10-05 09:01:24.075762	2026-10-05 09:01:24.075762	2026-10-05 13:01:24.075	assessed	\N
7232	4e95f796-b319-4046-b4fb-2ef859429379	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.076659	\N	2026-10-05 09:01:24.076659	2026-10-05 09:01:24.076659	2026-10-05 13:01:24.076	assessed	\N
255936	11208ccf-3228-49dd-902f-115f004a58d1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.076957	\N	2026-10-05 09:01:24.076957	2026-10-05 09:01:24.076957	2026-10-05 13:01:24.076	assessed	\N
83520	9337d43d-0395-415c-8c92-d10687ecab2d	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.077233	\N	2026-10-05 09:01:24.077233	2026-10-05 09:01:24.077233	2026-10-05 13:01:24.077	assessed	\N
878464	ab6e83e6-3e32-4a10-80b8-c9d3719f01bb	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.077502	\N	2026-10-05 09:01:24.077502	2026-10-05 09:01:24.077502	2026-10-05 13:01:24.077	assessed	\N
964032	a677f6c4-4209-4b7e-857a-3bb028580461	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.07778	\N	2026-10-05 09:01:24.07778	2026-10-05 09:01:24.07778	2026-10-05 13:01:24.077	assessed	\N
43520	8bfa8584-6aea-448a-99ac-3038557fdaf9	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.078049	\N	2026-10-05 09:01:24.078049	2026-10-05 09:01:24.078049	2026-10-05 13:01:24.077	assessed	\N
661248	0c987684-5f17-4e98-bb58-c249350ea12d	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.078322	\N	2026-10-05 09:01:24.078322	2026-10-05 09:01:24.078322	2026-10-05 13:01:24.078	assessed	\N
93184	25d61e6f-48a2-4955-bbf9-3f4baf9a752d	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.078586	\N	2026-10-05 09:01:24.078586	2026-10-05 09:01:24.078586	2026-10-05 13:01:24.078	assessed	\N
285760	78c55a58-7833-46c3-b1f7-f46453328aaa	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.078856	\N	2026-10-05 09:01:24.078856	2026-10-05 09:01:24.078856	2026-10-05 13:01:24.078	assessed	\N
31872	7d777270-59c6-4fde-9692-8bb83c42c535	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.07912	\N	2026-10-05 09:01:24.07912	2026-10-05 09:01:24.07912	2026-10-05 13:01:24.078	assessed	\N
203840	76d83ae2-c7f9-426a-a2ee-7f4fce049186	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.079398	\N	2026-10-05 09:01:24.079398	2026-10-05 09:01:24.079398	2026-10-05 13:01:24.079	assessed	\N
262592	1b674106-98d4-422b-86ec-0e5cc71f87df	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.079669	\N	2026-10-05 09:01:24.079669	2026-10-05 09:01:24.079669	2026-10-05 13:01:24.079	ready-for-contract	\N
2112	e36fd957-590e-40d3-92a8-feace803a533	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.079939	\N	2026-10-05 09:01:24.079939	2026-10-05 09:01:24.079939	2026-10-05 13:01:24.079	ready-for-contract	\N
573760	d13aa863-e564-4cfb-816e-63a7d2a6cb71	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.080212	\N	2026-10-05 09:01:24.080212	2026-10-05 09:01:24.080212	2026-10-05 13:01:24.08	ready-for-contract	\N
40896	aee79955-81eb-4b61-8a63-777a47924751	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.080585	\N	2026-10-05 09:01:24.080585	2026-10-05 09:01:24.080585	2026-10-05 13:01:24.08	ready-for-contract	\N
147712	988100a1-fdda-4422-a00b-bd4cedcba30d	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.081392	\N	2026-10-05 09:01:24.081392	2026-10-05 09:01:24.081392	2026-10-05 13:01:24.081	ready-for-contract	\N
29	9e8afe72-7304-4bca-be53-01c3dc5c217d	12WALNUT	12 Walnut Street - Marshall	12 Walnut Street	Marshall	NC	28753	Ruby	Hensley	ruby.hensley@example.com	(828) 555-0153	1	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
30	d7e4ecad-9e88-46d1-8caa-badac1cd52fd	1756RIVE	1756 Riverside Drive - Asheville	1756 Riverside Drive	Asheville	NC	28804	Vernon	Caldwell	vernon.caldwell@example.com	(828) 555-0118	2	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
31	f025b154-5155-48b1-984f-b81c8169738b	23GRACEL	23 Graceland Avenue - Asheville	23 Graceland Avenue	Asheville	NC	28806	Marlene	Fortner	marlene.fortner@example.com	(828) 555-0146	4	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
32	e274b00f-6cd2-4587-a7d1-d495e321823b	310NEWHA	310 New Haw Creek Road - Asheville	310 New Haw Creek Road	Asheville	NC	28805	Harold	Gillespie	harold.gillespie@example.com	(828) 555-0169	1	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
33	4f795f9b-6bd5-49d7-979b-c634ff5ccdd7	4LANVALE	4 Lanvale Avenue - Asheville	4 Lanvale Avenue	Asheville	NC	28801	Teresa	Lankford	teresa.lankford@example.com	(828) 555-0124	2	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
34	1051f14a-c423-43ef-9b1c-bfd47b4564c7	612STATE	612 State Street - Asheville	612 State Street	Asheville	NC	28806	Glenn	Marlowe	glenn.marlowe@example.com	(828) 555-0189	2	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
35	b0af6644-37a9-48bf-97bb-ec0c054ec9d7	16OLDMAR	16 Old Mars Hill Highway - Weaverville	16 Old Mars Hill Highway	Weaverville	NC	28787	Alice	Penland	alice.penland@example.com	(828) 555-0137	1	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
36	86ff06d0-48a8-4dae-b9a0-de3ee9496c8d	91BURLIN	91 Burlington Road - Asheville	91 Burlington Road	Asheville	NC	28806	Curtis	Revis	curtis.revis@example.com	(828) 555-0155	5	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
37	b514fed9-8d3e-46a8-8880-370543335c2e	28BROADW	28 Broadway Street - Marshall	28 Broadway Street	Marshall	NC	28753	Edna	Shelton	edna.shelton@example.com	(828) 555-0179	1	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
38	fe872a90-dd65-44a3-81cb-bfe780eb15fa	503EMMAR	503 Emma Road - Asheville	503 Emma Road	Asheville	NC	28806	Floyd	Treadway	floyd.treadway@example.com	(828) 555-0115	2	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
780800	acdc65ef-d7d1-4f04-a605-fc2e504de3a1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.081913	\N	2026-10-05 09:01:24.081913	2026-10-05 09:01:24.081913	2026-10-05 13:01:24.081	ready-for-contract	\N
680768	bb5d7928-e4df-45b0-9cb2-2abcf11a3e11	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.082457	\N	2026-10-05 09:01:24.082457	2026-10-05 09:01:24.082457	2026-10-05 13:01:24.082	ready-for-contract	\N
702016	5584219e-f558-460d-878a-0abacbd0e6a6	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.082976	\N	2026-10-05 09:01:24.082976	2026-10-05 09:01:24.082976	2026-10-05 13:01:24.082	ready-for-contract	\N
350336	af541181-4c50-46ef-aaf2-0902b598616f	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.083466	\N	2026-10-05 09:01:24.083466	2026-10-05 09:01:24.083466	2026-10-05 13:01:24.083	ready-for-contract	\N
934016	640197d7-514b-4861-9996-6af9ce101613	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.083837	\N	2026-10-05 09:01:24.083837	2026-10-05 09:01:24.083837	2026-10-05 13:01:24.083	ready-for-contract	\N
843584	3271171d-f744-4d5b-ad02-be3a9af436cf	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.084162	\N	2026-10-05 09:01:24.084162	2026-10-05 09:01:24.084162	2026-10-05 13:01:24.084	ready-for-contract	\N
274112	9e41772d-0b60-4aa6-b198-139ce8ce0984	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.084442	\N	2026-10-05 09:01:24.084442	2026-10-05 09:01:24.084442	2026-10-05 13:01:24.084	ready-for-contract	\N
617600	aaf03fa6-b008-4d4b-8611-8f2842fc7c53	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.084742	\N	2026-10-05 09:01:24.084742	2026-10-05 09:01:24.084742	2026-10-05 13:01:24.084	ready-for-contract	\N
534784	806f4c2e-0690-44ce-bc9c-4d2ee00d41e6	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	new	\N	\N	{"red": [], "green": [], "yellow": []}	\N	2026-10-05 09:01:24.085017	\N	2026-10-05 09:01:24.085017	2026-10-05 09:01:24.085017	2026-10-05 13:01:24.084	ready-for-contract	\N
39	b0249102-23b2-42fa-8a4b-a929518cdaba	7CLAXTON	7 Claxton Place - Asheville	7 Claxton Place	Asheville	NC	28801	Gladys	Worley	gladys.worley@example.com	(828) 555-0141	1	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
40	35ddcaa0-1918-40bb-bb30-5fb05e45c586	840SMOKE	840 Smokey Park Highway - Candler	840 Smokey Park Highway	Candler	NC	28715	Hubert	Angel	hubert.angel@example.com	(828) 555-0183	3	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
41	b0251ab3-6839-4c1f-8dfc-c2d44595903f	102STREE	102 West Street - Black Mountain	102 West Street	Black Mountain	NC	28711	Irene	Ballard	irene.ballard@example.com	(828) 555-0126	1	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
42	76a7b20b-b5fd-4eec-bc98-58618c663683	47OTEENC	47 Oteen Church Road - Asheville	47 Oteen Church Road	Asheville	NC	28805	Jesse	Carpenter	jesse.carpenter@example.com	(828) 555-0162	2	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
43	06fd7c16-d934-4f38-a8bf-8119944f832e	19DILLIN	19 Dillingham Circle - Barnardsville	19 Dillingham Circle	Barnardsville	NC	28709	Kathy	Dillingham	kathy.dillingham@example.com	(828) 555-0104	2	new	\N	\N	{"red": ["outside_service_area"], "green": ["homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami", "helene_related"], "yellow": []}	Green: homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami, helene_related. Red: outside_service_area	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
44	b9c2bc4b-9fc2-46a9-95ce-56a23ed7e31e	231OLDCO	231 Old County Home Road - Asheville	231 Old County Home Road	Asheville	NC	28806	Leonard	Ensley	leonard.ensley@example.com	(828) 555-0193	2	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
45	9e159563-a03e-4db8-b599-9303bf2e3f12	60ARIZON	60 Arizona Avenue - Asheville	60 Arizona Avenue	Asheville	NC	28806	Mabel	Fox	mabel.fox@example.com	(828) 555-0131	1	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
46	d85eb789-6d25-4a38-b763-aef73ed85354	118WARRE	118 Warren Avenue - Asheville	118 Warren Avenue	Asheville	NC	28803	Nathan	Gentry	nathan.gentry@example.com	(828) 555-0157	4	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
47	c5a5d2b6-ea23-4cba-b3a9-3d1938e56dc8	33MOUNTA	33 Mountain View Avenue - Waynesville	33 Mountain View Avenue	Waynesville	NC	28786	Opal	Hipps	opal.hipps@example.com	(828) 555-0175	1	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
48	407738e6-70f8-4ae6-b017-46cd2031b4a3	9GOLDVIE	9 Goldview Street - Asheville	9 Goldview Street	Asheville	NC	28806	Paul	Inman	paul.inman@example.com	(828) 555-0111	2	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
49	c0b3731a-cf5f-49ee-8c23-1645e919b502	72HAZELM	72 Hazel Mill Road - Asheville	72 Hazel Mill Road	Asheville	NC	28806	Ruth	Justice	ruth.justice@example.com	(828) 555-0149	2	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami"], "yellow": ["applicant_under_18_guardian_required"]}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami. Yellow: applicant_under_18_guardian_required. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
50	83897b5d-2590-4d91-9f26-7423541bcbef	305OLDHA	305 Old Haw Creek Road - Asheville	305 Old Haw Creek Road	Asheville	NC	28805	Samuel	Kuykendall	samuel.kuykendall@example.com	(828) 555-0168	2	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
51	e4a320fb-5124-4b2e-82ca-89abb7bff7bd	11BELMON	11 Belmont Avenue - Asheville	11 Belmont Avenue	Asheville	NC	28806	Viola	Lunsford	viola.lunsford@example.com	(828) 555-0123	1	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
52	743da5fc-5106-4c0b-a1ef-df71167fcdd5	520NEWLE	520 New Leicester Highway - Asheville	520 New Leicester Highway	Asheville	NC	28806	Willard	Mashburn	willard.mashburn@example.com	(828) 555-0181	3	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
53	b2e636f8-91c4-4dfe-afb5-1b6d8cb1c84b	26COURTL	26 Courtland Avenue - Asheville	26 Courtland Avenue	Asheville	NC	28801	Yolanda	Nieves	yolanda.nieves@example.com	(828) 555-0197	4	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
54	e6ba4b95-b537-4866-b48e-8d44e92e1220	144RIVER	144 Riverbend Road - Asheville	144 Riverbend Road	Asheville	NC	28805	Elsie	Barnwell	elsie.barnwell@example.com	(828) 555-0109	2	new	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
1	f32b6fce-5cdc-45fd-bd13-7bda1bca7fe0	88VIRGIN	88 Virginia Avenue - Asheville	88 Virginia Avenue	Asheville	NC	28806	Dorothy	Calloway	dorothy.calloway@example.com	(828) 555-0143	1	active	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
2	ac89f205-c47c-42f8-a469-cc032437d3ae	45OLDHAW	45 Old Haw Creek Road - Asheville	45 Old Haw Creek Road	Asheville	NC	28805	Marcus	Johnson	marcus.johnson@example.com	(828) 555-0161	2	active	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
3	c2434b6b-f23c-410c-a9d6-1bf8e7683f36	112RIDGE	112 Ridgecrest Drive - Black Mountain	112 Ridgecrest Drive	Black Mountain	NC	28711	Patricia	Alvarez	patricia.alvarez@example.com	(828) 555-0177	4	active	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
11	3aaeb279-f8aa-47df-a8a4-745a9614ce4e	3LOCUSTS	3 Locust Street - Black Mountain	3 Locust Street	Black Mountain	NC	28711	Sandra	McGee	sandra.mcgee@example.com	(828) 555-0195	3	active	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
10	48b55577-6adc-49a3-94fe-a7af51861b64	12CHERRY	12 Cherry Street - Asheville	12 Cherry Street	Asheville	NC	28801	George	Finley	george.finley@example.com	(828) 555-0148	2	active	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "income_within_80pct_ami", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, income_within_80pct_ami, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
8	2059c8e0-3b31-4761-bf49-9cc25fedd5b4	15CHURCH	15 Church Street - Weaverville	15 Church Street	Weaverville	NC	28787	Walter	Boone	walter.boone@example.com	(828) 555-0182	1	expired	\N	\N	{"red": [], "green": ["in_service_area", "homeownership_confirmed", "primary_residence_confirmed", "helene_related"], "yellow": []}	Green: in_service_area, homeownership_confirmed, primary_residence_confirmed, helene_related. 	2026-08-19 10:40:52.469126	\N	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	2026-08-19 10:40:52.469126	\N	\N
\.


--
-- Data for Name: assessment_documents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.assessment_documents (id, assessment_id, document_type, file_path, file_name, file_size, mime_type, uploaded_at, uploaded_by, metadata) FROM stdin;
\.


--
-- Data for Name: assessment_notes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.assessment_notes (id, assessment_id, author_id, note_type, content, is_public, is_action_item, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: assessment_tasks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.assessment_tasks (id, assessment_id, description, priority, estimated_hours, status, parent_task_id, materials_needed, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: assessments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.assessments (id, case_id, assessor_id, scheduled_start, scheduled_end, actual_start, actual_end, estimated_duration_hours, status, completion_percentage, check_in_location, check_out_location, check_in_at, check_out_at, repair_areas, measurements, notes, travel_distance_miles, travel_time_minutes, created_at, updated_at, application_id, organization_id, claim_number, date_created, date_of_loss, date_inspected, date_received, date_entered, policy_number, homeowner_names, full_address, street, city, state, zip, phone, is_emergency, emergency_desc, total_construction_price, assessor_name) FROM stdin;
1	\N	172	\N	\N	\N	\N	\N	scheduled	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-31 15:38:26.724442	2026-10-31 15:38:26.724442	58	\N	\N	2026-10-31 15:38:26.724442-04	\N	\N	\N	\N	\N	[]	42 Mountain View Drive, Asheville, NC	\N	\N	NC	\N	\N	f	\N	\N	Test Assessor
2	\N	172	\N	\N	\N	\N	\N	scheduled	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-02 01:15:51.153266	2026-11-02 01:15:51.153266	60	\N	\N	2026-11-02 01:15:51.153266-05	\N	\N	\N	\N	\N	[]	12 Riverbend Lane, Arden, NC	\N	\N	NC	\N	\N	f	\N	\N	Test Assessor
\.


--
-- Data for Name: assignment_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.assignment_log (id, assignment_id, action, old_value, new_value, performed_by, performed_at, notes) FROM stdin;
1	1	claimed	\N	claimed	\N	2026-09-04 10:31:22.664262	Claimed by Super Administrator
\.


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audit_log (id, submission_id, action, old_value, new_value, performed_by, performed_at) FROM stdin;
1	5	claimed	\N	Case claimed by Community Housing Coalition (1 repair(s))	Super Administrator	2026-09-04 10:31:22.664262
\.


--
-- Data for Name: badges; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.badges (id, badge_code, badge_name, description, icon_url, criteria_type, criteria_value, xp_bonus, created_at) FROM stdin;
1	FIRST_QUEST	First Quest	Complete your first volunteer task	\N	quests_completed	1	25	2026-06-11 16:00:32.398812
2	ROOF_RANGER	Roof Ranger	Complete 5 roofing tasks	\N	skill_quests	5	100	2026-06-11 16:00:32.398812
3	HUNDRED_HOURS	Century Club	Log 100 volunteer hours	\N	hours_logged	100	200	2026-06-11 16:00:32.398812
4	HELPER_HEART	Helper Heart	Receive 10 positive beneficiary ratings	\N	positive_ratings	10	50	2026-06-11 16:00:32.398812
5	MENTOR	Community Mentor	Help 5 new volunteers complete their first quest	\N	mentored_count	5	150	2026-06-11 16:00:32.398812
\.


--
-- Data for Name: beneficiary_feedback; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.beneficiary_feedback (id, quest_id, volunteer_id, beneficiary_id, quality_rating, kindness_rating, would_recommend, comments, thank_you_note, photo_urls, reputation_delta, created_at) FROM stdin;
\.


--
-- Data for Name: blocked_ips; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.blocked_ips (id, ip_address, blocked_at, blocked_by, reason, is_active, expires_at, created_at) FROM stdin;
\.


--
-- Data for Name: case_claims; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.case_claims (case_id, claimed_by_org_id, claimed_at, expires_at, is_locked) FROM stdin;
\.


--
-- Data for Name: case_communications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.case_communications (id, case_id, from_user_id, to_user_id, to_applicant, communication_type, subject, body, attachments, sent_at, is_read, read_at, notes) FROM stdin;
\.


--
-- Data for Name: case_documents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.case_documents (id, case_id, category_id, status_id, file_name, file_size_bytes, file_hash, mime_type, storage_path, storage_provider, storage_bucket, storage_region, version_number, parent_document_id, metadata, extracted_text, thumbnail_path, uploaded_by, uploaded_at, verified_by, verified_at, expires_at, deleted_at, access_roles, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: case_funding; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.case_funding (id, case_id, funding_source_id, allocated_amount, spent_amount, allocated_at, allocated_by, notes, approved_date, expiration_date, status) FROM stdin;
\.


--
-- Data for Name: case_repair_claims; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.case_repair_claims (id, case_id, repair_request_id, organization_id, claimed_by, claimed_at, released_at, released_by, notes) FROM stdin;
1	1	1	13	151	2026-08-19 10:40:52.469126	\N	\N	\N
2	1	2	13	151	2026-08-19 10:40:52.469126	\N	\N	\N
3	2	3	13	151	2026-08-19 10:40:52.469126	\N	\N	\N
4	3	4	14	151	2026-08-19 10:40:52.469126	\N	\N	\N
5	3	5	14	151	2026-08-19 10:40:52.469126	\N	\N	\N
6	11	20	14	151	2026-08-19 10:40:52.469126	\N	\N	\N
7	10	14	13	151	2026-08-19 10:40:52.469126	\N	\N	\N
8	10	17	13	151	2026-08-19 10:40:52.469126	\N	\N	\N
9	55	15	14	151	2026-08-19 10:40:52.469126	\N	\N	\N
10	55	16	14	151	2026-08-19 10:40:52.469126	\N	\N	\N
11	55	18	14	151	2026-08-19 10:40:52.469126	\N	\N	\N
12	55	19	14	151	2026-08-19 10:40:52.469126	\N	\N	\N
13	56	8	70	151	2026-09-04 10:31:22.664262	\N	\N	\N
\.


--
-- Data for Name: case_status_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.case_status_history (id, case_id, from_status_id, to_status_id, changed_by, notes, changed_at) FROM stdin;
1	1	1	1	151	Case claimed by seed org A (all repairs)	2026-08-19 10:40:52.469126
2	2	1	1	151	Case claimed by seed org A (all repairs)	2026-08-19 10:40:52.469126
3	3	1	1	151	Case claimed by seed org B (all repairs)	2026-08-19 10:40:52.469126
4	11	1	1	151	Case claimed by seed org B (all repairs)	2026-08-19 10:40:52.469126
5	10	1	1	151	Case claimed by seed org A (roof repair)	2026-08-19 10:40:52.469126
6	55	1	1	151	Case claimed by seed org B (plumbing + water heater)	2026-08-19 10:40:52.469126
7	56	1	1	151	Case claimed by Community Housing Coalition (1 repair(s))	2026-09-04 10:31:22.664262
\.


--
-- Data for Name: case_statuses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.case_statuses (id, status_code, status_name, status_sequence, is_terminal, allowed_roles_for_transition, description) FROM stdin;
1	PENDING_REVIEW	Pending Review	1	f	{ADMIN,CASEWORKER}	New application awaiting initial review
2	INTAKE_COMPLETE	Intake Complete	2	f	{ADMIN,CASEWORKER}	Initial eligibility determined
3	ASSESSMENT_SCHEDULED	Assessment Scheduled	3	f	{ADMIN,ASSESSOR,CASEWORKER}	Home visit scheduled
4	ASSESSMENT_COMPLETE	Assessment Complete	4	f	{ADMIN,ASSESSOR,CASEWORKER}	Home assessment finished, estimate created
5	APPROVED	Approved	5	f	{ADMIN,PROJECT_MANAGER,CASEWORKER}	Case approved for repair work
6	DENIED	Denied	99	f	{ADMIN,CASEWORKER}	Application denied - terminal
7	ASSIGNED_TO_CREW	Assigned to Crew	6	f	{ADMIN,PROJECT_MANAGER,CREW_LEAD}	Repair team assigned
8	IN_PROGRESS	In Progress	7	f	{CREW_LEAD,CREW_MEMBER,SUBCONTRACTOR}	Repair work underway
9	QUALITY_CHECK	Quality Check	8	f	{CREW_LEAD,PROJECT_MANAGER}	Final inspection before completion
10	COMPLETED	Completed	10	f	{ADMIN,PROJECT_MANAGER,CASEWORKER}	All work completed - terminal
11	ON_HOLD	On Hold	50	f	{ADMIN,PROJECT_MANAGER,CASEWORKER}	Temporary hold - not terminal
12	WITHDRAWN	Withdrawn	98	t	{ADMIN,SUPER_ADMIN,CASEWORKER}	Application withdrawn at the applicant's confirmed request - terminal
\.


--
-- Data for Name: case_withdrawals; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.case_withdrawals (id, case_id, withdrawn_by, withdrawn_at, requestor_confirmed, confirmation_method, confirmation_detail, reason) FROM stdin;
\.


--
-- Data for Name: cases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cases (id, submission_id, case_number, status_id, assigned_caseworker_id, assigned_project_manager_id, assigned_assessor_id, intake_completed_at, assessment_scheduled_at, assessment_completed_at, approved_at, work_started_at, work_completed_at, total_budget, total_actual_cost, notes, internal_notes, created_at, updated_at, created_by, updated_by, placecode, project_code, application_id, organization_id, claimed_at, claimed_by, claim_expires_at, claim_status, last_progress_at, progress_events_count) FROM stdin;
6	6	ARCHR-2026-000006	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-10 10:40:52.469126	2026-08-10 10:40:52.469126	\N	\N	56BANKSA	A56BANKSA	6	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
7	7	ARCHR-2026-000007	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-09 10:40:52.469126	2026-08-09 10:40:52.469126	\N	\N	34MAINST	D34MAINST	7	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
9	9	ARCHR-2026-000009	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-06 10:40:52.469126	2026-08-06 10:40:52.469126	\N	\N	90CROWEH	A90CROWEH	9	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
12	13	ARCHR-2026-000012	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-04 10:40:52.469126	2026-08-04 10:40:52.469126	\N	\N	204SUTTO	A204SUTTO	12	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
13	14	ARCHR-2026-000013	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-03 10:40:52.469126	2026-08-03 10:40:52.469126	\N	\N	7BEAVERD	A7BEAVERD	13	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
14	15	ARCHR-2026-000014	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-02 10:40:52.469126	2026-08-02 10:40:52.469126	\N	\N	131MONTR	D131MONTR	14	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
15	16	ARCHR-2026-000015	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-31 10:40:52.469126	2026-07-31 10:40:52.469126	\N	\N	66FLORID	D66FLORID	15	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
16	17	ARCHR-2026-000016	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-29 10:40:52.469126	2026-07-29 10:40:52.469126	\N	\N	481SANDH	D481SANDH	16	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
17	18	ARCHR-2026-000017	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-27 10:40:52.469126	2026-07-27 10:40:52.469126	\N	\N	29OLDLEI	A29OLDLEI	17	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
18	19	ARCHR-2026-000018	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-26 10:40:52.469126	2026-07-26 10:40:52.469126	\N	\N	152NEWST	D152NEWST	18	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
19	20	ARCHR-2026-000019	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-25 10:40:52.469126	2026-07-25 10:40:52.469126	\N	\N	5HILLSTR	A5HILLSTR	19	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
20	21	ARCHR-2026-000020	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 10:40:52.469126	2026-07-23 10:40:52.469126	\N	\N	338BILTM	D338BILTM	20	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
21	22	ARCHR-2026-000021	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 10:40:52.469126	2026-07-22 10:40:52.469126	\N	\N	77GROVES	A77GROVES	21	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
22	23	ARCHR-2026-000022	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-20 10:40:52.469126	2026-07-20 10:40:52.469126	\N	\N	410SWANN	H410SWANN	22	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
23	24	ARCHR-2026-000023	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-19 10:40:52.469126	2026-07-19 10:40:52.469126	\N	\N	18RICEBR	A18RICEBR	23	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
24	25	ARCHR-2026-000024	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-17 10:40:52.469126	2026-07-17 10:40:52.469126	\N	\N	263HAYWO	D263HAYWO	24	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
25	26	ARCHR-2026-000025	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-16 10:40:52.469126	2026-07-16 10:40:52.469126	\N	\N	9BOSTONW	D9BOSTONW	25	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
26	27	ARCHR-2026-000026	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-15 10:40:52.469126	2026-07-15 10:40:52.469126	\N	\N	85UPPERB	D85UPPERB	26	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
27	28	ARCHR-2026-000027	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-14 10:40:52.469126	2026-07-14 10:40:52.469126	\N	\N	141PATTO	A141PATTO	27	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
28	29	ARCHR-2026-000028	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-12 10:40:52.469126	2026-07-12 10:40:52.469126	\N	\N	52PONDRO	A52PONDRO	28	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
29	30	ARCHR-2026-000029	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-11 10:40:52.469126	2026-07-11 10:40:52.469126	\N	\N	12WALNUT	D12WALNUT	29	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
30	31	ARCHR-2026-000030	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-08 10:40:52.469126	2026-07-08 10:40:52.469126	\N	\N	1756RIVE	D1756RIVE	30	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
31	32	ARCHR-2026-000031	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-07 10:40:52.469126	2026-07-07 10:40:52.469126	\N	\N	23GRACEL	D23GRACEL	31	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
32	33	ARCHR-2026-000032	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-06 10:40:52.469126	2026-07-06 10:40:52.469126	\N	\N	310NEWHA	D310NEWHA	32	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
33	34	ARCHR-2026-000033	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-04 10:40:52.469126	2026-07-04 10:40:52.469126	\N	\N	4LANVALE	A4LANVALE	33	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
34	35	ARCHR-2026-000034	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-03 10:40:52.469126	2026-07-03 10:40:52.469126	\N	\N	612STATE	D612STATE	34	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
35	36	ARCHR-2026-000035	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-02 10:40:52.469126	2026-07-02 10:40:52.469126	\N	\N	16OLDMAR	D16OLDMAR	35	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
36	37	ARCHR-2026-000036	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-01 10:40:52.469126	2026-07-01 10:40:52.469126	\N	\N	91BURLIN	A91BURLIN	36	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
37	38	ARCHR-2026-000037	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-29 10:40:52.469126	2026-06-29 10:40:52.469126	\N	\N	28BROADW	A28BROADW	37	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
38	39	ARCHR-2026-000038	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-28 10:40:52.469126	2026-06-28 10:40:52.469126	\N	\N	503EMMAR	D503EMMAR	38	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
39	40	ARCHR-2026-000039	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-26 10:40:52.469126	2026-06-26 10:40:52.469126	\N	\N	7CLAXTON	A7CLAXTON	39	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
40	41	ARCHR-2026-000040	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-24 10:40:52.469126	2026-06-24 10:40:52.469126	\N	\N	840SMOKE	H840SMOKE	40	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
41	42	ARCHR-2026-000041	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-22 10:40:52.469126	2026-06-22 10:40:52.469126	\N	\N	102STREE	D102STREE	41	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
42	43	ARCHR-2026-000042	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-21 10:40:52.469126	2026-06-21 10:40:52.469126	\N	\N	47OTEENC	A47OTEENC	42	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
43	44	ARCHR-2026-000043	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-19 10:40:52.469126	2026-06-19 10:40:52.469126	\N	\N	19DILLIN	D19DILLIN	43	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
44	45	ARCHR-2026-000044	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-17 10:40:52.469126	2026-06-17 10:40:52.469126	\N	\N	231OLDCO	A231OLDCO	44	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
45	46	ARCHR-2026-000045	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-15 10:40:52.469126	2026-06-15 10:40:52.469126	\N	\N	60ARIZON	A60ARIZON	45	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
46	47	ARCHR-2026-000046	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-14 10:40:52.469126	2026-06-14 10:40:52.469126	\N	\N	118WARRE	A118WARRE	46	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
47	48	ARCHR-2026-000047	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-12 10:40:52.469126	2026-06-12 10:40:52.469126	\N	\N	33MOUNTA	A33MOUNTA	47	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
48	49	ARCHR-2026-000048	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-10 10:40:52.469126	2026-06-10 10:40:52.469126	\N	\N	9GOLDVIE	D9GOLDVIE	48	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
49	50	ARCHR-2026-000049	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-08 10:40:52.469126	2026-06-08 10:40:52.469126	\N	\N	72HAZELM	A72HAZELM	49	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
50	51	ARCHR-2026-000050	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-18 10:40:52.469126	2026-08-18 10:40:52.469126	\N	\N	305OLDHA	D305OLDHA	50	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
51	52	ARCHR-2026-000051	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-15 10:40:52.469126	2026-08-15 10:40:52.469126	\N	\N	11BELMON	D11BELMON	51	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
52	53	ARCHR-2026-000052	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-13 10:40:52.469126	2026-08-13 10:40:52.469126	\N	\N	520NEWLE	D520NEWLE	52	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
53	54	ARCHR-2026-000053	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-07 10:40:52.469126	2026-08-07 10:40:52.469126	\N	\N	26COURTL	A26COURTL	53	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
54	55	ARCHR-2026-000054	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-30 10:40:52.469126	2026-07-30 10:40:52.469126	\N	\N	144RIVER	D144RIVER	54	\N	\N	\N	2026-11-17 10:40:52.469126	\N	\N	0
1	1	ARCHR-2026-000001	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-17 10:40:52.469126	2026-08-19 10:46:25.333369	\N	\N	88VIRGIN	D88VIRGIN	1	13	2026-08-19 10:40:52.469126	151	2026-11-17 10:40:52.469126	active	2026-08-19 10:40:52.469126	2
2	2	ARCHR-2026-000002	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-16 10:40:52.469126	2026-08-19 10:46:25.333369	\N	\N	45OLDHAW	A45OLDHAW	2	13	2026-08-19 10:40:52.469126	151	2026-11-17 10:40:52.469126	active	2026-08-19 10:40:52.469126	2
5	5	ARCHR-2026-000005	1	\N	\N	\N	2026-08-31 08:39:11.107106	2026-09-01 08:39:11.107106	2026-09-03 08:39:11.107106	2026-09-04 06:39:11.107106	\N	\N	\N	\N	\N	\N	2026-08-11 10:40:52.469126	2026-09-04 08:39:11.129981	\N	\N	220KIMBE	A220KIMBE	5	13	2026-09-04 08:39:11.003872	165	2026-12-03 08:39:11.129981	active	2026-09-04 08:39:11.129981	5
4	4	ARCHR-2026-000004	1	\N	\N	\N	2026-08-31 08:39:31.954742	2026-09-01 08:39:31.954742	2026-09-03 08:39:31.954742	2026-09-04 06:39:31.954742	\N	\N	\N	\N	\N	\N	2026-08-12 10:40:52.469126	2026-09-04 08:39:31.98948	\N	\N	8TURKEYC	H8TURKEYC	4	13	2026-09-04 08:37:44.999481	165	2026-12-03 08:39:31.98948	active	2026-09-04 08:39:31.98948	5
3	3	ARCHR-2026-000003	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-14 10:40:52.469126	2026-08-19 10:46:25.333369	\N	\N	112RIDGE	D112RIDGE	3	14	2026-08-19 10:40:52.469126	151	2026-11-17 10:40:52.469126	active	2026-08-19 10:40:52.469126	2
11	12	ARCHR-2026-000011	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-05 10:40:52.469126	2026-08-19 10:46:25.333369	\N	\N	3LOCUSTS	D3LOCUSTS	11	14	2026-08-19 10:40:52.469126	151	2026-11-17 10:40:52.469126	active	2026-08-19 10:40:52.469126	2
10	10	ARCHR-2026-000010	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-10 10:40:52.469126	2026-08-19 10:46:25.333369	\N	\N	12CHERRY	D12CHERRY	10	13	2026-08-19 10:40:52.469126	151	2026-11-17 10:40:52.469126	active	2026-08-19 10:40:52.469126	2
8	8	ARCHR-2026-000008	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-08 10:40:52.469126	2026-08-19 10:46:25.333369	\N	\N	15CHURCH	D15CHURCH	8	13	2026-05-16 10:40:52.469126	151	2026-08-14 10:40:52.469126	expired	2026-05-16 10:40:52.469126	1
55	10	ARCHR-2026-000055	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-19 10:40:52.469126	2026-08-19 10:46:25.333369	151	151	12CHERRY	D12CHERRY	10	14	2026-08-19 10:40:52.469126	151	2026-11-17 10:40:52.469126	active	2026-08-19 10:40:52.469126	1
56	5	ARCHR-2026-000056	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-04 10:31:22.664262	2026-09-04 10:31:22.664262	151	151	220KIMBE	A220KIMBE	5	70	2026-09-04 10:31:22.664262	151	2026-12-03 10:31:22.664262	active	2026-09-04 10:31:22.664262	1
\.


--
-- Data for Name: coalition_organizations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.coalition_organizations (id, organization_code, organization_name, description, website_url, contact_email, contact_phone, logo_url, is_active, max_active_applications, auto_claim_enabled, notification_email, created_at, updated_at, created_by, updated_by, funding_limit) FROM stdin;
13	AHFH	Asheville Habitat for Humanity	\N	\N	intake@ashevillehabitat.org	\N	\N	t	60	f	\N	2026-06-12 08:59:24.970873	2026-06-12 08:59:24.970873	\N	\N	\N
14	MHO	Mountain Housing Opportunities	\N	\N	help@mtnhousing.org	\N	\N	t	40	f	\N	2026-06-12 08:59:24.970873	2026-06-12 08:59:24.970873	\N	\N	\N
15	CAO	Community Action Opportunities	\N	\N	intake@caoinc.org	\N	\N	t	30	f	\N	2026-06-12 08:59:24.970873	2026-06-12 08:59:24.970873	\N	\N	\N
70	CHC	Community Housing Coalition	\N	\N	hello@chc-madison.org	\N	\N	t	40	f	\N	2026-08-19 10:31:05.745863	2026-08-19 10:31:05.745863	\N	\N	\N
71	LANDOFSKY	Land of Sky	\N	\N	info@landofsky.org	\N	\N	t	40	f	\N	2026-08-19 10:31:05.745863	2026-08-19 10:31:05.745863	\N	\N	\N
\.


--
-- Data for Name: contact_methods; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.contact_methods (id, method_code) FROM stdin;
1	phone
2	text
3	email
4	other
\.


--
-- Data for Name: content_reads; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.content_reads (id, content_id, volunteer_id, read_at, xp_awarded) FROM stdin;
\.


--
-- Data for Name: crew_completion_documents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.crew_completion_documents (id, job_id, document_type, document_url, document_name, client_signed_at, client_signature_url, crew_lead_signed_at, crew_lead_signature_url, is_final, verified_by, verified_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: crew_daily_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.crew_daily_logs (id, job_id, crew_lead_id, log_date, log_text, work_summary, issues_encountered, tomorrow_plan, photo_urls, verified, verified_by, verified_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: crew_incident_reports; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.crew_incident_reports (id, job_id, reported_by, incident_date, incident_time, incident_type, severity, description, location, witnesses, immediate_action_taken, follow_up_required, follow_up_notes, status, photo_urls, created_at, updated_at, resolved_at, resolved_by) FROM stdin;
\.


--
-- Data for Name: crew_job_cards; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.crew_job_cards (id, case_id, crew_lead_id, placecode, address, homeowner_name, homeowner_phone, weather_indoor_outdoor, weather_icon, weather_temperature, progress_percentage, total_tasks, completed_tasks, estimated_hours, remaining_hours, job_status, is_current_job, current_phase, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: crew_job_phases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.crew_job_phases (id, phase_code, phase_name, phase_order, description, required_tasks, completion_criteria, is_active, created_at, updated_at) FROM stdin;
1	PREP	Preparation	1	Gather materials, review scope	\N	\N	t	2026-07-02 18:31:54.334517	2026-07-02 18:31:54.334517
2	SETUP	Site Setup	2	Set up ladders, safety equipment	\N	\N	t	2026-07-02 18:31:54.334517	2026-07-02 18:31:54.334517
3	WORK	Active Work	3	Perform repairs	\N	\N	t	2026-07-02 18:31:54.334517	2026-07-02 18:31:54.334517
4	CLEANUP	Cleanup	4	Clean site, dispose of debris	\N	\N	t	2026-07-02 18:31:54.334517	2026-07-02 18:31:54.334517
5	INSPECT	Final Inspection	5	Quality check, client walkthrough	\N	\N	t	2026-07-02 18:31:54.334517	2026-07-02 18:31:54.334517
6	COMPLETE	Completed	6	Job complete, documents signed	\N	\N	t	2026-07-02 18:31:54.334517	2026-07-02 18:31:54.334517
\.


--
-- Data for Name: crew_volunteer_signin; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.crew_volunteer_signin (id, job_id, volunteer_id, sign_in_time, sign_out_time, hours_worked, safety_talk_confirmed, safety_talk_topics, safety_talk_confirmed_at, assigned_task_ids, verified_by, verified_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: criteria_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.criteria_types (id, type_code, type_name, input_type, description) FROM stdin;
1	income_max	Maximum Annual Income	number	Maximum household annual income allowed
2	income_min	Minimum Annual Income	number	Minimum household annual income required
3	geography_counties	Eligible Counties	multiselect	Comma-separated list of eligible counties
4	geography_zipcodes	Eligible ZIP Codes	multiselect	Comma-separated list of eligible ZIP codes
5	homeowner_status	Homeowner Status Required	select	Must own home? Values: yes, no, either
6	home_type_allowed	Allowed Home Types	multiselect	traditional, modular, mobile, other
7	primary_residence_required	Primary Residence Required	boolean	Must be primary residence
8	min_household_size	Minimum Household Size	number	Minimum number of household members
9	max_household_size	Maximum Household Size	number	Maximum number of household members
10	min_years_in_home	Minimum Years in Home	number	Minimum years lived at current address
11	helene_damage_only	Helene Damage Only	boolean	Only accept Helene-related damage
12	repair_categories	Repair Categories Served	multiselect	Types of repairs organization handles
13	household_attributes	Household Attributes Served	multiselect	Special household characteristics served
14	urgent_only	Urgent Cases Only	boolean	Only accept urgent condition applications
15	age_requirement	Age Requirement	range	Minimum age of primary applicant
16	veteran_only	Veteran Only	boolean	Only serve veteran households
17	disability_only	Disability Only	boolean	Only serve households with disability
18	max_repair_estimate	Maximum Repair Cost	number	Maximum repair cost organization can handle
19	fema_claim_accepted	FEMA Claim Status	select	Accept applications with FEMA claims: any, yes, no
20	insurance_claim_accepted	Insurance Claim Status	select	Accept applications with insurance claims: any, yes, no
\.


--
-- Data for Name: document_access_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.document_access_log (id, document_id, accessed_by, access_type, ip_address, user_agent, accessed_at) FROM stdin;
\.


--
-- Data for Name: document_categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.document_categories (id, category_code, category_name, parent_category_id, storage_path_template, requires_encryption, retention_months, description) FROM stdin;
1	APPLICATION	Application Documents	\N	/cases/{case_number}/application/	t	120	\N
2	PROPERTY	Property Records	\N	/cases/{case_number}/property/	t	120	\N
3	INCOME	Income Verification	\N	/cases/{case_number}/income/	t	84	\N
4	ASSESSMENT	Property Assessments	\N	/cases/{case_number}/assessments/	t	120	\N
5	ASSESSMENT_PHOTOS_BEFORE	Before Photos	\N	/cases/{case_number}/assessments/initial/photos/	t	120	\N
6	ASSESSMENT_PHOTOS_DURING	During Photos	\N	/cases/{case_number}/assessments/final/photos/	t	120	\N
7	ASSESSMENT_PHOTOS_AFTER	After Photos	\N	/cases/{case_number}/completion/final_photos/	t	120	\N
8	CONTRACT	Repair Contracts	\N	/cases/{case_number}/contracts/	t	120	\N
9	CHANGE_ORDER	Change Orders	\N	/cases/{case_number}/contracts/	t	120	\N
10	WORK_ORDER	Work Orders	\N	/cases/{case_number}/work_orders/{work_order_number}/	t	84	\N
11	QUOTE	Subcontractor Quotes	\N	/cases/{case_number}/financial/quotes/	t	36	\N
12	INVOICE	Invoices	\N	/cases/{case_number}/financial/invoices/	t	84	\N
13	GRANT	Grant Documents	\N	/cases/{case_number}/financial/grants/	t	120	\N
14	ENV_REVIEW	Environmental Review	\N	/cases/{case_number}/financial/grants/	t	120	\N
15	SHPO	SHPO Records	\N	/cases/{case_number}/financial/grants/	t	120	\N
16	COMPLETION	Completion Certificate	\N	/cases/{case_number}/completion/	t	120	\N
17	COMMUNICATION	Communications	\N	/cases/{case_number}/communications/	t	36	\N
18	TEMPLATE	System Templates	\N	/shared/templates/	f	9999	\N
\.


--
-- Data for Name: document_generation_jobs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.document_generation_jobs (id, case_id, template_id, status, data_source, output_document_id, error_message, priority, created_by, created_at, completed_at, expires_at) FROM stdin;
\.


--
-- Data for Name: document_share_links; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.document_share_links (id, document_id, share_token, shared_by, recipient_email, expires_at, max_accesses, access_count, requires_auth, created_at) FROM stdin;
\.


--
-- Data for Name: document_statuses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.document_statuses (id, status_code, status_name) FROM stdin;
1	PENDING	Pending Upload
2	UPLOADED	Uploaded - Pending Processing
3	PROCESSING	Processing
4	VERIFIED	Verified
5	REJECTED	Rejected
6	ARCHIVED	Archived
7	DELETED	Deleted
\.


--
-- Data for Name: document_templates; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.document_templates (id, template_code, template_name, category_id, template_file_path, template_type, output_format, requires_signature, signature_fields, version, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: document_verifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.document_verifications (id, case_id, verified_by, document_code, document_id, verification_type, verification_status, findings, notes, is_reversible, verified_at, collected_physically, collected_at, collected_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: edit_requests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.edit_requests (id, case_id, requested_by, field_name, old_value, new_value, reason, status, reviewed_by, reviewed_at, approved_at, change_incorporated, created_at) FROM stdin;
\.


--
-- Data for Name: eligibility_results; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.eligibility_results (id, submission_id, organization_id, match_score, is_eligible, checked_at) FROM stdin;
1	1	13	100	t	2026-08-19 10:40:52.469126
2	1	14	100	t	2026-08-19 10:40:52.469126
3	1	15	100	t	2026-08-19 10:40:52.469126
4	1	70	100	t	2026-08-19 10:40:52.469126
5	1	71	100	t	2026-08-19 10:40:52.469126
6	2	13	100	t	2026-08-19 10:40:52.469126
7	2	14	100	t	2026-08-19 10:40:52.469126
8	2	15	100	t	2026-08-19 10:40:52.469126
9	2	70	100	t	2026-08-19 10:40:52.469126
10	2	71	100	t	2026-08-19 10:40:52.469126
11	3	13	100	t	2026-08-19 10:40:52.469126
12	3	14	100	t	2026-08-19 10:40:52.469126
13	3	15	100	t	2026-08-19 10:40:52.469126
14	3	70	100	t	2026-08-19 10:40:52.469126
15	3	71	100	t	2026-08-19 10:40:52.469126
16	4	13	100	t	2026-08-19 10:40:52.469126
17	4	14	100	t	2026-08-19 10:40:52.469126
18	4	15	100	t	2026-08-19 10:40:52.469126
19	4	70	100	t	2026-08-19 10:40:52.469126
20	4	71	100	t	2026-08-19 10:40:52.469126
21	5	13	100	t	2026-08-19 10:40:52.469126
22	5	14	100	t	2026-08-19 10:40:52.469126
23	5	15	100	t	2026-08-19 10:40:52.469126
24	5	70	100	t	2026-08-19 10:40:52.469126
25	5	71	100	t	2026-08-19 10:40:52.469126
26	6	13	100	t	2026-08-19 10:40:52.469126
27	6	14	100	t	2026-08-19 10:40:52.469126
28	6	15	100	t	2026-08-19 10:40:52.469126
29	6	70	100	t	2026-08-19 10:40:52.469126
30	6	71	100	t	2026-08-19 10:40:52.469126
31	7	13	100	t	2026-08-19 10:40:52.469126
32	7	14	100	t	2026-08-19 10:40:52.469126
33	7	15	100	t	2026-08-19 10:40:52.469126
34	7	70	100	t	2026-08-19 10:40:52.469126
35	7	71	100	t	2026-08-19 10:40:52.469126
36	8	13	100	t	2026-08-19 10:40:52.469126
37	8	14	100	t	2026-08-19 10:40:52.469126
38	8	15	100	t	2026-08-19 10:40:52.469126
39	8	70	100	t	2026-08-19 10:40:52.469126
40	8	71	100	t	2026-08-19 10:40:52.469126
41	9	13	100	t	2026-08-19 10:40:52.469126
42	9	14	100	t	2026-08-19 10:40:52.469126
43	9	15	100	t	2026-08-19 10:40:52.469126
44	9	70	100	t	2026-08-19 10:40:52.469126
45	9	71	100	t	2026-08-19 10:40:52.469126
46	10	13	100	t	2026-08-19 10:40:52.469126
47	10	14	100	t	2026-08-19 10:40:52.469126
48	10	15	100	t	2026-08-19 10:40:52.469126
49	10	70	100	t	2026-08-19 10:40:52.469126
50	10	71	100	t	2026-08-19 10:40:52.469126
51	11	13	100	t	2026-08-19 10:40:52.469126
52	11	14	100	t	2026-08-19 10:40:52.469126
53	11	15	100	t	2026-08-19 10:40:52.469126
54	11	70	100	t	2026-08-19 10:40:52.469126
55	11	71	100	t	2026-08-19 10:40:52.469126
56	12	13	100	t	2026-08-19 10:40:52.469126
57	12	14	100	t	2026-08-19 10:40:52.469126
58	12	15	100	t	2026-08-19 10:40:52.469126
59	12	70	100	t	2026-08-19 10:40:52.469126
60	12	71	100	t	2026-08-19 10:40:52.469126
61	13	13	100	t	2026-08-19 10:40:52.469126
62	13	14	100	t	2026-08-19 10:40:52.469126
63	13	15	100	t	2026-08-19 10:40:52.469126
64	13	70	100	t	2026-08-19 10:40:52.469126
65	13	71	100	t	2026-08-19 10:40:52.469126
66	14	13	100	t	2026-08-19 10:40:52.469126
67	14	14	100	t	2026-08-19 10:40:52.469126
68	14	15	100	t	2026-08-19 10:40:52.469126
69	14	70	100	t	2026-08-19 10:40:52.469126
70	14	71	100	t	2026-08-19 10:40:52.469126
71	15	13	100	t	2026-08-19 10:40:52.469126
72	15	14	100	t	2026-08-19 10:40:52.469126
73	15	15	100	t	2026-08-19 10:40:52.469126
74	15	70	100	t	2026-08-19 10:40:52.469126
75	15	71	100	t	2026-08-19 10:40:52.469126
76	16	13	100	t	2026-08-19 10:40:52.469126
77	16	14	100	t	2026-08-19 10:40:52.469126
78	16	15	100	t	2026-08-19 10:40:52.469126
79	16	70	100	t	2026-08-19 10:40:52.469126
80	16	71	100	t	2026-08-19 10:40:52.469126
81	17	13	100	t	2026-08-19 10:40:52.469126
82	17	14	100	t	2026-08-19 10:40:52.469126
83	17	15	100	t	2026-08-19 10:40:52.469126
84	17	70	100	t	2026-08-19 10:40:52.469126
85	17	71	100	t	2026-08-19 10:40:52.469126
86	18	13	100	t	2026-08-19 10:40:52.469126
87	18	14	100	t	2026-08-19 10:40:52.469126
88	18	15	100	t	2026-08-19 10:40:52.469126
89	18	70	100	t	2026-08-19 10:40:52.469126
90	18	71	100	t	2026-08-19 10:40:52.469126
91	19	13	100	t	2026-08-19 10:40:52.469126
92	19	14	100	t	2026-08-19 10:40:52.469126
93	19	15	100	t	2026-08-19 10:40:52.469126
94	19	70	100	t	2026-08-19 10:40:52.469126
95	19	71	100	t	2026-08-19 10:40:52.469126
96	20	13	100	t	2026-08-19 10:40:52.469126
97	20	14	100	t	2026-08-19 10:40:52.469126
98	20	15	100	t	2026-08-19 10:40:52.469126
99	20	70	100	t	2026-08-19 10:40:52.469126
100	20	71	100	t	2026-08-19 10:40:52.469126
101	21	13	100	t	2026-08-19 10:40:52.469126
102	21	14	100	t	2026-08-19 10:40:52.469126
103	21	15	100	t	2026-08-19 10:40:52.469126
104	21	70	100	t	2026-08-19 10:40:52.469126
105	21	71	100	t	2026-08-19 10:40:52.469126
106	22	13	100	t	2026-08-19 10:40:52.469126
107	22	14	100	t	2026-08-19 10:40:52.469126
108	22	15	100	t	2026-08-19 10:40:52.469126
109	22	70	100	t	2026-08-19 10:40:52.469126
110	22	71	100	t	2026-08-19 10:40:52.469126
111	23	13	100	t	2026-08-19 10:40:52.469126
112	23	14	100	t	2026-08-19 10:40:52.469126
113	23	15	100	t	2026-08-19 10:40:52.469126
114	23	70	100	t	2026-08-19 10:40:52.469126
115	23	71	100	t	2026-08-19 10:40:52.469126
116	24	13	100	t	2026-08-19 10:40:52.469126
117	24	14	100	t	2026-08-19 10:40:52.469126
118	24	15	100	t	2026-08-19 10:40:52.469126
119	24	70	100	t	2026-08-19 10:40:52.469126
120	24	71	100	t	2026-08-19 10:40:52.469126
121	25	13	100	t	2026-08-19 10:40:52.469126
122	25	14	100	t	2026-08-19 10:40:52.469126
123	25	15	100	t	2026-08-19 10:40:52.469126
124	25	70	100	t	2026-08-19 10:40:52.469126
125	25	71	100	t	2026-08-19 10:40:52.469126
126	26	13	100	t	2026-08-19 10:40:52.469126
127	26	14	100	t	2026-08-19 10:40:52.469126
128	26	15	100	t	2026-08-19 10:40:52.469126
129	26	70	100	t	2026-08-19 10:40:52.469126
130	26	71	100	t	2026-08-19 10:40:52.469126
131	27	13	100	t	2026-08-19 10:40:52.469126
132	27	14	100	t	2026-08-19 10:40:52.469126
133	27	15	100	t	2026-08-19 10:40:52.469126
134	27	70	100	t	2026-08-19 10:40:52.469126
135	27	71	100	t	2026-08-19 10:40:52.469126
136	28	13	100	t	2026-08-19 10:40:52.469126
137	28	14	100	t	2026-08-19 10:40:52.469126
138	28	15	100	t	2026-08-19 10:40:52.469126
139	28	70	100	t	2026-08-19 10:40:52.469126
140	28	71	100	t	2026-08-19 10:40:52.469126
141	29	13	100	t	2026-08-19 10:40:52.469126
142	29	14	100	t	2026-08-19 10:40:52.469126
143	29	15	100	t	2026-08-19 10:40:52.469126
144	29	70	100	t	2026-08-19 10:40:52.469126
145	29	71	100	t	2026-08-19 10:40:52.469126
146	30	13	100	t	2026-08-19 10:40:52.469126
147	30	14	100	t	2026-08-19 10:40:52.469126
148	30	15	100	t	2026-08-19 10:40:52.469126
149	30	70	100	t	2026-08-19 10:40:52.469126
150	30	71	100	t	2026-08-19 10:40:52.469126
151	31	13	100	t	2026-08-19 10:40:52.469126
152	31	14	100	t	2026-08-19 10:40:52.469126
153	31	15	100	t	2026-08-19 10:40:52.469126
154	31	70	100	t	2026-08-19 10:40:52.469126
155	31	71	100	t	2026-08-19 10:40:52.469126
156	32	13	100	t	2026-08-19 10:40:52.469126
157	32	14	100	t	2026-08-19 10:40:52.469126
158	32	15	100	t	2026-08-19 10:40:52.469126
159	32	70	100	t	2026-08-19 10:40:52.469126
160	32	71	100	t	2026-08-19 10:40:52.469126
161	33	13	100	t	2026-08-19 10:40:52.469126
162	33	14	100	t	2026-08-19 10:40:52.469126
163	33	15	100	t	2026-08-19 10:40:52.469126
164	33	70	100	t	2026-08-19 10:40:52.469126
165	33	71	100	t	2026-08-19 10:40:52.469126
166	34	13	100	t	2026-08-19 10:40:52.469126
167	34	14	100	t	2026-08-19 10:40:52.469126
168	34	15	100	t	2026-08-19 10:40:52.469126
169	34	70	100	t	2026-08-19 10:40:52.469126
170	34	71	100	t	2026-08-19 10:40:52.469126
171	35	13	100	t	2026-08-19 10:40:52.469126
172	35	14	100	t	2026-08-19 10:40:52.469126
173	35	15	100	t	2026-08-19 10:40:52.469126
174	35	70	100	t	2026-08-19 10:40:52.469126
175	35	71	100	t	2026-08-19 10:40:52.469126
176	36	13	100	t	2026-08-19 10:40:52.469126
177	36	14	100	t	2026-08-19 10:40:52.469126
178	36	15	100	t	2026-08-19 10:40:52.469126
179	36	70	100	t	2026-08-19 10:40:52.469126
180	36	71	100	t	2026-08-19 10:40:52.469126
181	37	13	100	t	2026-08-19 10:40:52.469126
182	37	14	100	t	2026-08-19 10:40:52.469126
183	37	15	100	t	2026-08-19 10:40:52.469126
184	37	70	100	t	2026-08-19 10:40:52.469126
185	37	71	100	t	2026-08-19 10:40:52.469126
186	38	13	100	t	2026-08-19 10:40:52.469126
187	38	14	100	t	2026-08-19 10:40:52.469126
188	38	15	100	t	2026-08-19 10:40:52.469126
189	38	70	100	t	2026-08-19 10:40:52.469126
190	38	71	100	t	2026-08-19 10:40:52.469126
191	39	13	100	t	2026-08-19 10:40:52.469126
192	39	14	100	t	2026-08-19 10:40:52.469126
193	39	15	100	t	2026-08-19 10:40:52.469126
194	39	70	100	t	2026-08-19 10:40:52.469126
195	39	71	100	t	2026-08-19 10:40:52.469126
196	40	13	100	t	2026-08-19 10:40:52.469126
197	40	14	100	t	2026-08-19 10:40:52.469126
198	40	15	100	t	2026-08-19 10:40:52.469126
199	40	70	100	t	2026-08-19 10:40:52.469126
200	40	71	100	t	2026-08-19 10:40:52.469126
201	41	13	100	t	2026-08-19 10:40:52.469126
202	41	14	100	t	2026-08-19 10:40:52.469126
203	41	15	100	t	2026-08-19 10:40:52.469126
204	41	70	100	t	2026-08-19 10:40:52.469126
205	41	71	100	t	2026-08-19 10:40:52.469126
206	42	13	100	t	2026-08-19 10:40:52.469126
207	42	14	100	t	2026-08-19 10:40:52.469126
208	42	15	100	t	2026-08-19 10:40:52.469126
209	42	70	100	t	2026-08-19 10:40:52.469126
210	42	71	100	t	2026-08-19 10:40:52.469126
211	43	13	100	t	2026-08-19 10:40:52.469126
212	43	14	100	t	2026-08-19 10:40:52.469126
213	43	15	100	t	2026-08-19 10:40:52.469126
214	43	70	100	t	2026-08-19 10:40:52.469126
215	43	71	100	t	2026-08-19 10:40:52.469126
216	44	13	100	t	2026-08-19 10:40:52.469126
217	44	14	100	t	2026-08-19 10:40:52.469126
218	44	15	100	t	2026-08-19 10:40:52.469126
219	44	70	100	t	2026-08-19 10:40:52.469126
220	44	71	100	t	2026-08-19 10:40:52.469126
221	45	13	100	t	2026-08-19 10:40:52.469126
222	45	14	100	t	2026-08-19 10:40:52.469126
223	45	15	100	t	2026-08-19 10:40:52.469126
224	45	70	100	t	2026-08-19 10:40:52.469126
225	45	71	100	t	2026-08-19 10:40:52.469126
226	46	13	100	t	2026-08-19 10:40:52.469126
227	46	14	100	t	2026-08-19 10:40:52.469126
228	46	15	100	t	2026-08-19 10:40:52.469126
229	46	70	100	t	2026-08-19 10:40:52.469126
230	46	71	100	t	2026-08-19 10:40:52.469126
231	47	13	100	t	2026-08-19 10:40:52.469126
232	47	14	100	t	2026-08-19 10:40:52.469126
233	47	15	100	t	2026-08-19 10:40:52.469126
234	47	70	100	t	2026-08-19 10:40:52.469126
235	47	71	100	t	2026-08-19 10:40:52.469126
236	48	13	100	t	2026-08-19 10:40:52.469126
237	48	14	100	t	2026-08-19 10:40:52.469126
238	48	15	100	t	2026-08-19 10:40:52.469126
239	48	70	100	t	2026-08-19 10:40:52.469126
240	48	71	100	t	2026-08-19 10:40:52.469126
241	49	13	100	t	2026-08-19 10:40:52.469126
242	49	14	100	t	2026-08-19 10:40:52.469126
243	49	15	100	t	2026-08-19 10:40:52.469126
244	49	70	100	t	2026-08-19 10:40:52.469126
245	49	71	100	t	2026-08-19 10:40:52.469126
246	50	13	100	t	2026-08-19 10:40:52.469126
247	50	14	100	t	2026-08-19 10:40:52.469126
248	50	15	100	t	2026-08-19 10:40:52.469126
249	50	70	100	t	2026-08-19 10:40:52.469126
250	50	71	100	t	2026-08-19 10:40:52.469126
251	51	13	100	t	2026-08-19 10:40:52.469126
252	51	14	100	t	2026-08-19 10:40:52.469126
253	51	15	100	t	2026-08-19 10:40:52.469126
254	51	70	100	t	2026-08-19 10:40:52.469126
255	51	71	100	t	2026-08-19 10:40:52.469126
256	52	13	100	t	2026-08-19 10:40:52.469126
257	52	14	100	t	2026-08-19 10:40:52.469126
258	52	15	100	t	2026-08-19 10:40:52.469126
259	52	70	100	t	2026-08-19 10:40:52.469126
260	52	71	100	t	2026-08-19 10:40:52.469126
261	53	13	100	t	2026-08-19 10:40:52.469126
262	53	14	100	t	2026-08-19 10:40:52.469126
263	53	15	100	t	2026-08-19 10:40:52.469126
264	53	70	100	t	2026-08-19 10:40:52.469126
265	53	71	100	t	2026-08-19 10:40:52.469126
266	54	13	100	t	2026-08-19 10:40:52.469126
267	54	14	100	t	2026-08-19 10:40:52.469126
268	54	15	100	t	2026-08-19 10:40:52.469126
269	54	70	100	t	2026-08-19 10:40:52.469126
270	54	71	100	t	2026-08-19 10:40:52.469126
271	55	13	100	t	2026-08-19 10:40:52.469126
272	55	14	100	t	2026-08-19 10:40:52.469126
273	55	15	100	t	2026-08-19 10:40:52.469126
274	55	70	100	t	2026-08-19 10:40:52.469126
275	55	71	100	t	2026-08-19 10:40:52.469126
276	56	13	100	t	2026-08-19 10:40:52.469126
277	56	14	100	t	2026-08-19 10:40:52.469126
278	56	15	100	t	2026-08-19 10:40:52.469126
279	56	70	100	t	2026-08-19 10:40:52.469126
280	56	71	100	t	2026-08-19 10:40:52.469126
\.


--
-- Data for Name: email_queue; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.email_queue (id, recipient_email, recipient_name, subject, body, body_html, notification_type, related_entity_type, related_entity_id, status, attempts, last_attempt_at, error_message, priority, send_at, created_at, sent_at) FROM stdin;
\.


--
-- Data for Name: funding_sources; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.funding_sources (id, organization_id, source_name, source_type, total_amount, remaining_amount, start_date, end_date, restrictions, contact_name, contact_email, created_at) FROM stdin;
\.


--
-- Data for Name: guest_access_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.guest_access_tokens (id, submission_id, token, expires_at, last_accessed, created_at) FROM stdin;
\.


--
-- Data for Name: help_categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.help_categories (id, category_code, category_name, parent_category_id, display_order, icon_class, is_active, description, created_at) FROM stdin;
1	GETTING_STARTED	Getting Started	\N	1	\N	t	First-time user guides and account setup	2026-06-11 16:00:32.538934
2	APPLICANTS	For Applicants & Homeowners	\N	2	\N	t	How to apply for home repair assistance	2026-06-11 16:00:32.538934
3	CASEWORKERS	For Caseworkers	\N	3	\N	t	Managing applications and client communication	2026-06-11 16:00:32.538934
4	ASSESSORS	For Assessors	\N	4	\N	t	Conducting home assessments and estimates	2026-06-11 16:00:32.538934
5	PROJECT_MANAGEMENT	For Project Managers & Crew	\N	5	\N	t	Managing repair projects and work orders	2026-06-11 16:00:32.538934
6	FINANCE	For Finance Staff	\N	6	\N	t	Budgeting, invoicing, and grant compliance	2026-06-11 16:00:32.538934
7	VOLUNTEERS	For Volunteers	\N	7	\N	t	Task assignments and hour tracking	2026-06-11 16:00:32.538934
8	ADMIN	For Administrators	\N	8	\N	t	System configuration and user management	2026-06-11 16:00:32.538934
9	TROUBLESHOOTING	Troubleshooting & FAQ	\N	9	\N	t	Common issues and solutions	2026-06-11 16:00:32.538934
10	DEVELOPER	For Developers	\N	10	\N	t	API documentation and system architecture	2026-06-11 16:00:32.538934
\.


--
-- Data for Name: help_document_attachments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.help_document_attachments (id, document_id, attachment_type, file_name, file_path, file_size_bytes, mime_type, alt_text, caption, display_order, uploaded_by, uploaded_at) FROM stdin;
\.


--
-- Data for Name: help_document_feedback; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.help_document_feedback (id, document_id, user_id, is_helpful, rating, comment, created_at) FROM stdin;
\.


--
-- Data for Name: help_document_reviews; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.help_document_reviews (id, document_id, reviewer_id, review_status, comments, requested_changes, assigned_at, completed_at) FROM stdin;
\.


--
-- Data for Name: help_document_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.help_document_types (id, type_code, type_name, icon_class, is_interactive, requires_authentication, description) FROM stdin;
1	SOP	Standard Operating Procedure	fa-file-alt	f	t	Step-by-step process documentation
2	GUIDE	User Guide	fa-book	f	t	Comprehensive feature guide
3	FAQ	Frequently Asked Questions	fa-question-circle	f	t	Common questions and answers
4	TUTORIAL	Interactive Tutorial	fa-graduation-cap	f	t	Walkthrough with screenshots/video
5	CHECKLIST	Checklist	fa-check-square	f	t	Task-based verification list
6	REFERENCE	Quick Reference	fa-table	f	t	One-page cheat sheet or lookup table
7	VIDEO	Video Tutorial	fa-video	f	t	Recorded training session
8	TEMPLATE	Template	fa-file	f	t	Form, letter, or document template
9	POLICY	Policy Document	fa-gavel	f	t	Organizational policy and compliance
10	RELEASE_NOTES	Release Notes	fa-code-branch	f	t	System update documentation
\.


--
-- Data for Name: help_document_versions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.help_document_versions (id, document_id, version_number, title, content, change_notes, created_by, created_at, is_current) FROM stdin;
\.


--
-- Data for Name: help_documents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.help_documents (id, document_id, doc_type_id, category_id, title, subtitle, version, content, content_format, file_path, language, original_document_id, author, author_email, owner_role_id, reviewer_id, reviewer_notes, target_roles, tags, search_keywords, estimated_minutes, related_documents, prerequisite_documents, status, is_featured, is_required, view_count, helpful_count, not_helpful_count, last_viewed_at, publish_at, expires_at, review_required_by, previous_version_id, change_notes, created_by, created_at, updated_by, updated_at, reviewed_at, reviewed_by, archived_at, archived_by, custom_fields, notes) FROM stdin;
\.


--
-- Data for Name: help_search_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.help_search_log (id, search_term, user_id, result_count, clicked_document_id, search_type, ip_address, user_agent, created_at) FROM stdin;
\.


--
-- Data for Name: help_user_progress; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.help_user_progress (id, user_id, document_id, status, started_at, completed_at, last_position, notes) FROM stdin;
\.


--
-- Data for Name: household_attributes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.household_attributes (id, attribute_name) FROM stdin;
1	single_parent
2	child_under_5
3	person_over_62
4	person_with_disability
5	snap_wic
6	veteran
\.


--
-- Data for Name: income_records; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.income_records (id, submission_id, whose_income, income_source, frequency, amount, created_at) FROM stdin;
1	3	mine	work	monthly	2600.00	2026-08-14 10:40:52.469126
2	9	mine	social_security	monthly	1640.00	2026-08-06 10:40:52.469126
3	9	mine	retirement	monthly	410.00	2026-08-06 10:40:52.469126
4	12	mine	self_employment	monthly	1750.00	2026-08-05 10:40:52.469126
5	12	other	work	weekly	310.00	2026-08-05 10:40:52.469126
6	19	mine	work	biweekly	1180.00	2026-07-26 10:40:52.469126
7	26	mine	work	weekly	430.00	2026-07-16 10:40:52.469126
8	32	mine	work	biweekly	940.00	2026-07-07 10:40:52.469126
9	32	other	work	weekly	380.00	2026-07-07 10:40:52.469126
10	38	mine	social_security	monthly	1290.00	2026-06-29 10:40:52.469126
11	47	mine	work	weekly	620.00	2026-06-14 10:40:52.469126
12	54	mine	work	biweekly	980.00	2026-08-07 10:40:52.469126
\.


--
-- Data for Name: intake_submissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.intake_submissions (id, submission_uuid, submitted_at, language, is_referral, referrer_name, referrer_organization, referrer_email, referrer_notes, consent_agreed, applicant_first_name, applicant_last_name, applicant_dob, applicant_dob_unknown, preferred_phone, preferred_text, preferred_email, preferred_other, home_phone, cell_phone, contact_email, other_contact_method_description, contact_notes, home_address, home_city, home_state, home_zip, is_primary_residence, receives_different_mail, mail_address, mail_city, mail_state, mail_zip, home_type, year_built, move_in_date, owns_home, owns_lot, insurance_provider, lived_one_year, household_size, household_adults, additional_repair_details, urgent_unable_to_stay, urgent_no_hvac, urgent_no_potable_water, urgent_no_bathroom, urgent_no_kitchen, urgent_open_to_elements, urgent_no_entry, urgent_accessibility, urgent_other_issue, urgent_eviction_risk, helene_related, fema_claim_filed, fema_outcome, fema_settlement_amount, fema_remaining_exists, fema_remaining_amount, insurance_claim_filed, insurance_outcome, insurance_settlement_amount, insurance_remaining_exists, insurance_remaining_amount, has_income, income_method, gross_annual_income, income_docs_method, zero_income_first_name, zero_income_last_name, zero_income_address, zero_income_agreed, applicant_signature, zero_income_signature, submission_status, assigned_organization, reviewed_by, reviewed_at, eligibility_checked_at, is_test, requestor_user_id, placecode, is_duplicate, deduplicated_into, disqualification_reasons, eligibility_warnings) FROM stdin;
1	18cd404e-fc8c-4786-ae78-ad510bbe7071	2026-08-17 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Dorothy	Calloway	1951-04-12	f	f	f	t	f	(828) 555-0143	(828) 555-0143	dorothy.calloway@example.com	\N	\N	88 Virginia Avenue	Asheville	NC	28806	t	\N	\N	\N	\N	\N	traditional	1948	2020-08-19	t	t	\N	t	1	1	Fixed income (Social Security). Bedroom ceiling stained and sagging; buckets out when it rains.	f	f	f	f	f	t	f	f	f	f	t	t	denied	\N	\N	\N	f	\N	\N	\N	\N	t	gross	21480.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	88VIRGIN	f	1	{}	{}
3	cdfcaccb-f7cb-48e1-8d6e-de32df58a617	2026-08-14 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Patricia	Alvarez	1989-06-21	f	f	f	t	f	(828) 555-0177	(828) 555-0177	patricia.alvarez@example.com	\N	\N	112 Ridgecrest Drive	Black Mountain	NC	28711	t	\N	\N	\N	\N	\N	traditional	1975	2020-08-19	t	t	\N	t	4	1	Three kids, youngest is three. Only one bathroom.	f	f	f	t	f	f	f	f	f	f	t	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	calculator	\N	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	112RIDGE	f	3	{}	{}
2	0b93d0d8-8936-461f-9378-5401862180f8	2026-08-16 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Marcus	Johnson	1968-09-02	f	f	f	t	f	(828) 555-0161	(828) 555-0161	marcus.johnson@example.com	\N	\N	45 Old Haw Creek Road	Asheville	NC	28805	t	\N	\N	\N	\N	\N	traditional	1962	2020-08-19	t	t	\N	t	2	2	VA disability household. Winter is the worry.	f	t	f	f	f	f	f	f	f	f	f	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	31200.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	45OLDHAW	f	2	{}	{}
4	c5d54cd2-97f7-4768-af1d-44327ed634aa	2026-08-12 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Jimmy	Raynaud	1958-02-14	f	f	f	t	f	(828) 555-0102	(828) 555-0102	jimmy.raynaud@example.com	\N	\N	8 Turkey Creek Road	Marshall	NC	28753	t	\N	\N	\N	\N	\N	mobile	1986	2020-08-19	t	f	\N	t	2	2	Own the trailer, rent the lot.	f	t	f	f	f	f	f	f	f	f	t	t	settled	4200.00	t	1500.00	f	\N	\N	\N	\N	t	gross	18900.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	needs_review	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	8TURKEYC	f	4	{mobile_home_no_lot_ownership}	{}
5	07a6b127-6124-4692-81c0-d561947505ed	2026-08-11 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Evelyn	Sanders	1962-11-30	f	f	f	t	f	(828) 555-0119	(828) 555-0119	evelyn.sanders@example.com	\N	\N	220 Kimberly Avenue	Asheville	NC	28804	t	\N	\N	\N	\N	\N	traditional	1958	2020-08-19	t	t	\N	t	1	1	Still working part-time at the hospital.	f	f	f	f	f	f	f	f	f	f	f	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	62500.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	needs_review	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	220KIMBE	f	5	{income_above_80pct_ami}	{}
58	7831b6b6-439e-4b62-88f2-cfcab603df20	2026-10-17 08:54:28.742186	eng	\N	\N	\N	\N	\N	t	Dorothy	Calloway	\N	f	t	f	t	f	(828) 555-0147	(828) 555-0199	dorothy.calloway@example.com	\N	\N	42 Mountain View Drive	Asheville	NC	28801	t	\N	\N	\N	\N	\N	single_family	1978	\N	t	t	State Farm	\N	4	2	Roof leaking in master bedroom and kitchen. Visible water damage on ceiling beams. Needs full replacement. Kitchen floor has sustained water damage.	f	t	f	f	t	t	f	f	f	f	t	t	denied	\N	\N	\N	t	\N	\N	\N	\N	t	monthly	32000.00	\N	\N	\N	\N	\N	\N	\N	pending_review	Habitat for Humanity	\N	\N	\N	f	171	PLC-42891	f	\N	\N	\N
6	ee5a9091-4b5f-4dee-b3cb-954fafea856c	2026-08-10 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Tom	Beck	1984-03-17	f	f	f	t	f	(828) 555-0134	(828) 555-0134	tom.beck@example.com	\N	\N	56 Banks Avenue	Asheville	NC	28801	t	\N	\N	\N	\N	\N	traditional	1925	2020-08-19	f	t	\N	t	2	2	Renting the house; landlord lives out of state.	f	f	f	f	f	f	f	f	f	f	f	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	27000.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	needs_review	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	56BANKSA	f	6	{not_homeowner}	{}
7	c8825c0a-178d-4ae7-a45e-5b430e0cabe9	2026-08-09 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Rosa	Jimenez	1972-08-08	f	f	f	t	f	(828) 555-0151	(828) 555-0151	rosa.jimenez@example.com	\N	\N	34 Main Street	Rutherfordton	NC	28139	t	\N	\N	\N	\N	\N	traditional	1969	2020-08-19	t	t	\N	t	3	2	FEMA said the damage was insufficient for the program.	f	f	f	f	f	t	f	f	f	f	t	t	other	\N	\N	\N	f	\N	\N	\N	\N	t	gross	24000.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	needs_review	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	34MAINST	f	7	{outside_service_area}	{}
8	f793101d-d1b7-41b9-8663-e919449bea29	2026-08-08 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Walter	Boone	1949-12-01	f	f	f	t	f	(828) 555-0182	(828) 555-0182	walter.boone@example.com	\N	\N	15 Church Street	Weaverville	NC	28787	t	\N	\N	\N	\N	\N	traditional	1938	2020-08-19	t	t	\N	t	1	1	No income this year after the shop closed. Zero income affidavit signed.	f	f	t	f	f	f	f	f	f	f	t	f	\N	\N	\N	\N	f	\N	\N	\N	\N	f	gross	\N	email_link	Walter	Boone	15 Church Street, Weaverville NC 28787	t	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	15CHURCH	f	8	{}	{}
9	5ac43429-e554-4705-9634-4e9aadff70db	2026-08-06 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Helen	Crowe	1946-05-25	f	f	f	t	f	(828) 555-0127	(828) 555-0127	helen.crowe@example.com	\N	\N	90 Crowe Hollow Road	Candler	NC	28715	t	\N	\N	\N	\N	\N	traditional	1952	2020-08-19	t	t	\N	t	1	1	Widowed last year. Daughter helps on weekends.	f	f	f	f	f	f	f	t	f	f	f	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	calculator	\N	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	90CROWEH	f	9	{}	{}
10	dd94ac2d-119b-4d0e-bf64-ce70da4eadf5	2026-07-10 10:40:52.469126	eng	f	\N	\N	\N	\N	t	George	Finley	1957-07-19	f	f	f	t	f	(828) 555-0148	(828) 555-0148	george.finley@example.com	\N	\N	12 Cherry Street	Asheville	NC	28801	t	\N	\N	\N	\N	\N	traditional	1946	2020-08-19	t	t	\N	t	2	2	Both denial letters in hand; can upload them.	f	f	f	f	f	t	f	f	f	f	t	t	denied	\N	\N	\N	t	denied	\N	\N	\N	t	gross	38900.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	12CHERRY	f	10	{}	{}
11	0084deca-bf30-423f-b116-303d586a81c8	2026-07-13 10:40:52.469126	eng	f	\N	\N	\N	\N	t	George	Finley	1957-07-19	f	f	f	t	f	(828) 555-0148	(828) 555-0148	george.finley@example.com	\N	Follow-up submission: forgot to attach income documents the first time.	12 Cherry Street	Asheville	NC	28801	t	\N	\N	\N	\N	\N	traditional	1946	2020-08-19	t	t	\N	t	2	2	Second submission to add paperwork.	f	f	f	f	f	t	f	f	f	f	t	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	38900.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	12CHERRY	t	10	{}	{}
60	2f2d3156-c1a5-4c5e-90ec-f8b30a396012	2026-10-24 09:19:01.181339	eng	t	Dorothy Calloway	\N	dorothy.calloway@example.com	\N	t	Dot	Fernandez	\N	f	t	f	t	f	(828) 555-0376	3	dot.fernandez@example.com	\N	\N	12 Riverbend Lane	Arden	NC	28704	t	\N	\N	\N	\N	\N	single_family	1962	\N	t	t	Allstate	\N	3	2	Tree fell on garage during storm. Roof damage to main house. HVAC unit flooded and non-functional. Kitchen cabinets water damaged.	f	t	f	f	t	f	f	f	f	f	t	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	t	monthly	38000.00	\N	\N	\N	\N	\N	\N	\N	pending_review	\N	\N	\N	\N	f	171	\N	f	\N	\N	\N
12	c3c1aa7e-6ea5-43e9-9f31-c390afe98420	2026-08-05 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Sandra	McGee	1978-04-03	f	f	f	t	f	(828) 555-0195	(828) 555-0195	sandra.mcgee@example.com	\N	\N	3 Locust Street	Black Mountain	NC	28711	t	\N	\N	\N	\N	\N	traditional	1971	2020-08-19	t	t	\N	t	3	2	I clean houses; my son stocks shelves.	f	f	f	f	t	f	f	f	f	f	t	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	calculator	\N	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	3LOCUSTS	f	11	{}	{}
59	0a5fce51-494a-40b4-a3c7-48931aa457ed	2026-10-21 09:19:01.068941	eng	t	Dorothy Calloway	\N	dorothy.calloway@example.com	\N	t	Cathy	Morrison	\N	f	t	f	t	f	(828) 555-0291	7	cathy.morrison@example.com	\N	\N	58 Mountain View Drive	Asheville	NC	28801	t	\N	\N	\N	\N	\N	mobile_home	1995	\N	t	f	\N	\N	2	1	Foundation shifting after heavy rain. Skirting damaged, steps pulling away from porch.	f	f	f	f	f	t	f	f	f	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	monthly	24000.00	\N	\N	\N	\N	\N	\N	\N	pending_review	\N	\N	\N	\N	f	171	\N	f	\N	\N	\N
13	519b7854-cca3-439f-bcc3-fe266cc23349	2026-08-04 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Henry	Abernathy	1955-10-11	f	f	f	t	f	(828) 555-0108	(828) 555-0108	henry.abernathy@example.com	\N	\N	204 Sutton Avenue	Asheville	NC	28806	t	\N	\N	\N	\N	\N	traditional	1940	2020-08-19	t	t	\N	t	2	2	Kerosene is expensive and I worry about the fumes.	f	f	f	f	f	f	f	f	f	f	f	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	27400.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	204SUTTO	f	12	{}	{}
14	95a4c659-4251-4d9d-8edf-a4f2931afd00	2026-08-03 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Lucille	Plemmons	1943-01-28	f	f	f	t	f	(828) 555-0171	(828) 555-0171	lucille.plemmons@example.com	\N	\N	7 Beaverdam Road	Asheville	NC	28804	t	\N	\N	\N	\N	\N	traditional	1935	2020-08-19	t	t	\N	t	1	1		f	f	f	f	f	f	f	f	f	f	f	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	15800.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	7BEAVERD	f	13	{}	{}
15	3fc2b897-79a7-4ef4-9bd2-24d1eea86a68	2026-08-02 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Robert	Trantham	1966-12-09	f	f	f	t	f	(828) 555-0139	(828) 555-0139	robert.trantham@example.com	\N	\N	131 Montreat Road	Black Mountain	NC	28711	t	\N	\N	\N	\N	\N	traditional	1965	2020-08-19	t	t	\N	t	2	2	Settlement went to the tree removal and the mortgage.	f	f	f	f	f	t	f	f	f	f	t	t	settled	9800.00	f	\N	t	denied	\N	\N	\N	t	gross	44600.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	131MONTR	f	14	{}	{}
16	f12dcc47-71e2-4a69-a311-3dc27be35760	2026-07-31 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Angela	Rice	1992-02-26	f	f	f	t	f	(828) 555-0112	(828) 555-0112	angela.rice@example.com	\N	\N	66 Florida Avenue	Asheville	NC	28806	t	\N	\N	\N	\N	\N	traditional	1955	2020-08-19	t	t	\N	t	3	1	SNAP household; two boys under ten.	f	f	f	t	f	f	f	f	f	f	t	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	23900.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	66FLORID	f	15	{}	{}
17	14513e71-89a0-4250-ae5b-663e980810cb	2026-07-29 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Charles	Sprinkle	1960-06-14	f	f	f	t	f	(828) 555-0166	(828) 555-0166	charles.sprinkle@example.com	\N	\N	481 Sand Hill Road	Asheville	NC	28806	t	\N	\N	\N	\N	\N	traditional	1972	2020-08-19	t	t	\N	t	2	2	The river came within two feet of the floor joists.	f	f	f	f	f	f	f	f	f	f	t	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	35100.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	481SANDH	f	16	{}	{}
18	7a376f05-4375-484d-9de8-a91f1b9b842b	2026-07-27 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Betty	Gudger	1950-09-23	f	f	f	t	f	(828) 555-0185	(828) 555-0185	betty.gudger@example.com	\N	\N	29 Old Leicester Highway	Candler	NC	28715	t	\N	\N	\N	\N	\N	traditional	1944	2020-08-19	t	t	\N	t	1	1		f	t	f	f	f	f	f	f	f	f	f	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	17200.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	29OLDLEI	f	17	{}	{}
19	8f728459-8095-431d-9644-e2b0d587bf74	2026-07-26 10:40:52.469126	eng	f	\N	\N	\N	\N	t	James	Whitson	1975-05-06	f	f	f	t	f	(828) 555-0121	(828) 555-0121	james.whitson@example.com	\N	\N	152 New Stock Road	Weaverville	NC	28787	t	\N	\N	\N	\N	\N	traditional	1980	2020-08-19	t	t	\N	t	4	2	Family of four, two teenagers.	f	f	t	f	f	f	f	f	f	f	t	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	calculator	\N	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	152NEWST	f	18	{}	{}
20	656e7bb6-989a-49ba-8313-2e165cbc986d	2026-07-25 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Frances	Hyatt	1948-08-17	f	f	f	t	f	(828) 555-0144	(828) 555-0144	frances.hyatt@example.com	\N	\N	5 Hill Street	Marshall	NC	28753	t	\N	\N	\N	\N	\N	traditional	1930	2020-08-19	t	t	\N	t	1	1	I cannot safely leave the house alone anymore.	f	f	f	f	f	f	t	f	f	f	f	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	14900.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	5HILLSTR	f	19	{}	{}
21	e89be7a1-25a4-47ed-b26b-35b4bb293342	2026-07-23 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Douglas	Kirkpatrick	1970-01-19	f	f	f	t	f	(828) 555-0158	(828) 555-0158	douglas.kirkpatrick@example.com	\N	\N	338 Biltmore Avenue	Asheville	NC	28801	t	\N	\N	\N	\N	\N	traditional	1922	2020-08-19	t	t	\N	t	2	2		f	f	f	f	f	f	f	f	f	f	t	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	41200.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	338BILTM	f	20	{}	{}
22	dbc3e365-5aa4-4789-832f-f64f9e454f6d	2026-07-22 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Wanda	Suttles	1963-03-30	f	f	f	t	f	(828) 555-0199	(828) 555-0199	wanda.suttles@example.com	\N	\N	77 Grove Street	Asheville	NC	28801	t	\N	\N	\N	\N	\N	traditional	1928	2020-08-19	t	t	\N	t	3	3	Three adults share the house.	f	f	f	f	f	f	f	f	f	f	f	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	52400.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	77GROVES	f	21	{}	{}
23	4d8d06bf-3b14-4240-bb82-b2421e920760	2026-07-20 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Billy	Messer	1982-07-07	f	f	f	t	f	(828) 555-0116	(828) 555-0116	billy.messer@example.com	\N	\N	410 Swannanoa River Road	Asheville	NC	28805	t	\N	\N	\N	\N	\N	mobile	1994	2020-08-19	t	t	\N	t	2	2	Own the trailer and the lot.	f	f	f	f	f	t	f	f	f	f	t	t	denied	\N	\N	\N	f	\N	\N	\N	\N	t	gross	29800.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	410SWANN	f	22	{}	{}
24	709ccc3a-ad6d-4a0f-ad94-c10f09348e8e	2026-07-19 10:40:52.469126	eng	f	\N	\N	\N	\N	t	June	Arrowood	1954-11-02	f	f	f	t	f	(828) 555-0132	(828) 555-0132	june.arrowood@example.com	\N	\N	18 Rice Branch Road	Asheville	NC	28805	t	\N	\N	\N	\N	\N	traditional	1950	2020-08-19	t	t	\N	t	1	1		f	f	f	f	f	f	f	f	f	f	f	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	19600.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	18RICEBR	f	23	{}	{}
25	39649f9b-9b01-46d4-aa49-a33827b0e001	2026-07-17 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Albert	Pruitt	1945-04-15	f	f	f	t	f	(828) 555-0173	(828) 555-0173	albert.pruitt@example.com	\N	\N	263 Haywood Road	Asheville	NC	28806	t	\N	\N	\N	\N	\N	traditional	1926	2020-08-19	t	t	\N	t	2	2	My wife has early dementia; I do the calling.	f	f	f	f	f	f	f	f	f	f	t	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	26700.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	263HAYWO	f	24	{}	{}
26	8cb6bf39-6306-48a9-965c-84f596e7fe6b	2026-07-16 10:40:52.469126	eng	t	Pastel Reyes	Poder Emma	intake@poderemma.org	Family referred through our community navigators.	t	Sheila	Godfrey	1987-10-27	f	f	f	t	f	(828) 555-0164	(828) 555-0164	sheila.godfrey@example.com	\N	\N	9 Boston Way	Asheville	NC	28806	t	\N	\N	\N	\N	\N	traditional	1968	2020-08-19	t	t	\N	t	3	1	Toddler at home; keeping rooms warm with the oven door open, which scares me.	f	t	f	f	f	f	f	f	f	f	t	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	calculator	\N	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	9BOSTONW	f	25	{}	{}
27	9c7eb4f1-f4f0-4cd6-a3af-8f6b28db0e91	2026-07-15 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Ray	Buckner	1959-01-23	f	f	f	t	f	(828) 555-0187	(828) 555-0187	ray.buckner@example.com	\N	\N	85 Upper Brush Creek Road	Marshall	NC	28753	t	\N	\N	\N	\N	\N	traditional	1978	2020-08-19	t	t	\N	t	2	2		f	f	f	f	f	f	f	f	f	f	t	f	\N	\N	\N	\N	t	settled	6100.00	t	2400.00	t	gross	33500.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	85UPPERB	f	26	{}	{}
28	10b3ee6a-07bb-4fdb-a749-e5291e4945d7	2026-07-14 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Carolyn	Metcalf	1947-06-09	f	f	f	t	f	(828) 555-0129	(828) 555-0129	carolyn.metcalf@example.com	\N	\N	141 Patton Avenue	Asheville	NC	28801	t	\N	\N	\N	\N	\N	traditional	1920	2020-08-19	t	t	\N	t	1	1	No income this year; affidavit signed at the library.	f	f	f	f	f	f	f	f	f	f	f	f	\N	\N	\N	\N	f	\N	\N	\N	\N	f	gross	\N	email_link	Carolyn	Metcalf	141 Patton Avenue, Asheville NC 28801	t	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	141PATTO	f	27	{}	{}
29	c5838e2f-4882-4b94-82c8-d66cceebc7b6	2026-07-12 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Ernest	Balling	1973-12-18	f	f	f	t	f	(828) 555-0106	(828) 555-0106	ernest.balling@example.com	\N	\N	52 Pond Road	Asheville	NC	28806	t	\N	\N	\N	\N	\N	traditional	1963	2020-08-19	t	t	\N	t	2	2		f	f	f	f	f	f	f	f	f	f	f	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	30800.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	52PONDRO	f	28	{}	{}
30	9d02e9a8-c42f-4478-a375-31dc33e3ad57	2026-07-11 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Ruby	Hensley	1953-02-11	f	f	f	t	f	(828) 555-0153	(828) 555-0153	ruby.hensley@example.com	\N	\N	12 Walnut Street	Marshall	NC	28753	t	\N	\N	\N	\N	\N	traditional	1942	2020-08-19	t	t	\N	t	1	1	The oven for heat worries my daughter.	f	t	f	f	f	f	f	f	f	f	t	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	16400.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	12WALNUT	f	29	{}	{}
31	4f58c3cb-ae9d-445e-82c6-258c71a26e4c	2026-07-08 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Vernon	Caldwell	1969-08-24	f	f	f	t	f	(828) 555-0118	(828) 555-0118	vernon.caldwell@example.com	\N	\N	1756 Riverside Drive	Asheville	NC	28804	t	\N	\N	\N	\N	\N	traditional	1957	2020-08-19	t	t	\N	t	2	2	Army vet. The house took on the river.	f	f	f	f	f	t	f	f	f	f	t	t	settled	12400.00	t	5000.00	f	\N	\N	\N	\N	t	gross	36200.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	1756RIVE	f	30	{}	{}
32	a4aa9460-156c-477a-948b-e82a500020fd	2026-07-07 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Marlene	Fortner	1980-05-16	f	f	f	t	f	(828) 555-0146	(828) 555-0146	marlene.fortner@example.com	\N	\N	23 Graceland Avenue	Asheville	NC	28806	t	\N	\N	\N	\N	\N	traditional	1960	2020-08-19	t	t	\N	t	4	2	Two incomes, four mouths, still under the line.	f	f	f	f	t	f	f	f	f	f	t	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	calculator	\N	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	23GRACEL	f	31	{}	{}
33	52f770aa-9b75-43a8-b42b-dfca8858dcbd	2026-07-06 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Harold	Gillespie	1942-09-05	f	f	f	t	f	(828) 555-0169	(828) 555-0169	harold.gillespie@example.com	\N	\N	310 New Haw Creek Road	Asheville	NC	28805	t	\N	\N	\N	\N	\N	traditional	1932	2020-08-19	t	t	\N	t	1	1		f	f	f	f	f	t	f	f	f	f	t	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	18200.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	310NEWHA	f	32	{}	{}
34	0ff92a3c-ec6a-423a-9b97-68f917297768	2026-07-04 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Teresa	Lankford	1995-04-21	f	f	f	t	f	(828) 555-0124	(828) 555-0124	teresa.lankford@example.com	\N	\N	4 Lanvale Avenue	Asheville	NC	28801	t	\N	\N	\N	\N	\N	traditional	1949	2020-08-19	t	t	\N	t	2	1	New baby; my mom watches her while I work.	f	f	f	f	f	f	f	f	f	f	f	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	28600.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	4LANVALE	f	33	{}	{}
35	d75f2a8f-546c-4241-8c51-936ec973f1e2	2026-07-03 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Glenn	Marlowe	1964-11-13	f	f	f	t	f	(828) 555-0189	(828) 555-0189	glenn.marlowe@example.com	\N	\N	612 State Street	Asheville	NC	28806	t	\N	\N	\N	\N	\N	traditional	1938	2020-08-19	t	t	\N	t	2	2	The corner dropped about two inches this spring.	f	f	f	f	f	f	f	f	f	f	t	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	41700.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	612STATE	f	34	{}	{}
36	aab0862b-1449-433a-85f2-dca38fe1f712	2026-07-02 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Alice	Penland	1956-12-28	f	f	f	t	f	(828) 555-0137	(828) 555-0137	alice.penland@example.com	\N	\N	16 Old Mars Hill Highway	Weaverville	NC	28787	t	\N	\N	\N	\N	\N	traditional	1967	2020-08-19	t	t	\N	t	1	1		f	f	f	f	f	f	f	f	f	f	t	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	20800.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	16OLDMAR	f	35	{}	{}
37	06d8bcdf-317a-4502-b38e-c6220cafd635	2026-07-01 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Curtis	Revis	1986-03-08	f	f	f	t	f	(828) 555-0155	(828) 555-0155	curtis.revis@example.com	\N	\N	91 Burlington Road	Asheville	NC	28806	t	\N	\N	\N	\N	\N	traditional	1974	2020-08-19	t	t	\N	t	5	2	Three kids; my brother lives with us since the mill closed.	f	t	f	f	f	f	f	f	f	f	f	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	68900.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	91BURLIN	f	36	{}	{}
38	7c35d858-2a54-4714-a24c-419dee1cf789	2026-06-29 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Edna	Shelton	1940-07-31	f	f	f	t	f	(828) 555-0179	(828) 555-0179	edna.shelton@example.com	\N	\N	28 Broadway Street	Marshall	NC	28753	t	\N	\N	\N	\N	\N	traditional	1918	2020-08-19	t	t	\N	t	1	1	I have not been to the mailbox in a month.	f	f	f	f	f	f	t	f	f	f	f	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	calculator	\N	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	28BROADW	f	37	{}	{}
39	9d4244ce-26b0-4a31-a3c0-f34763dcfafc	2026-06-28 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Floyd	Treadway	1961-06-02	f	f	f	t	f	(828) 555-0115	(828) 555-0115	floyd.treadway@example.com	\N	\N	503 Emma Road	Asheville	NC	28806	t	\N	\N	\N	\N	\N	traditional	1953	2020-08-19	t	t	\N	t	2	2		f	f	f	f	f	t	f	f	f	f	t	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	32400.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	503EMMAR	f	38	{}	{}
40	2b646c4b-5c9f-4bfc-bf82-bd796f00fe93	2026-06-26 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Gladys	Worley	1952-10-19	f	f	f	t	f	(828) 555-0141	(828) 555-0141	gladys.worley@example.com	\N	\N	7 Claxton Place	Asheville	NC	28801	t	\N	\N	\N	\N	\N	traditional	1941	2020-08-19	t	t	\N	t	1	1	Hip replacement in May.	f	f	f	f	f	f	f	f	f	f	f	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	17600.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	7CLAXTON	f	39	{}	{}
41	d007b916-0825-4d86-bb24-e0172e052e54	2026-06-24 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Hubert	Angel	1979-01-26	f	f	f	t	f	(828) 555-0183	(828) 555-0183	hubert.angel@example.com	\N	\N	840 Smokey Park Highway	Candler	NC	28715	t	\N	\N	\N	\N	\N	mobile	1998	2020-08-19	t	t	\N	t	3	2		f	t	f	f	f	f	f	f	f	f	t	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	33600.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	840SMOKE	f	40	{}	{}
42	9cd6b21a-9c4e-4d90-b2c5-138b761e12f3	2026-06-22 10:40:52.469126	eng	t	Dana Whitfield	Swannanoa Valley Christian Ministry	outreach@svcm.org	Neighbor asked us to help her apply.	t	Irene	Ballard	1944-05-12	f	f	f	t	f	(828) 555-0126	(828) 555-0126	irene.ballard@example.com	\N	\N	102 West Street	Black Mountain	NC	28711	t	\N	\N	\N	\N	\N	traditional	1936	2020-08-19	t	t	\N	t	1	1		f	f	f	f	f	f	f	f	f	f	t	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	18900.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	102STREE	f	41	{}	{}
43	a300b025-f855-423d-a4c6-16fec536289b	2026-06-21 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Jesse	Carpenter	1990-09-14	f	f	f	t	f	(828) 555-0162	(828) 555-0162	jesse.carpenter@example.com	\N	\N	47 Oteen Church Road	Asheville	NC	28805	t	\N	\N	\N	\N	\N	traditional	1966	2020-08-19	t	t	\N	t	2	2		f	f	t	f	f	f	f	f	f	f	f	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	30100.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	47OTEENC	f	42	{}	{}
44	201d3d79-5374-4526-95ef-d0ace4740290	2026-06-19 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Kathy	Dillingham	1965-02-20	f	f	f	t	f	(828) 555-0104	(828) 555-0104	kathy.dillingham@example.com	\N	\N	19 Dillingham Circle	Barnardsville	NC	28709	t	\N	\N	\N	\N	\N	traditional	1972	2020-08-19	t	t	\N	t	2	2	Never filed with FEMA; did not know we could.	f	f	f	f	f	t	f	f	f	f	t	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	37800.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	needs_review	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	19DILLIN	f	43	{outside_service_area}	{}
45	8f7d9190-53bf-4cc4-85be-2fba132d3425	2026-06-17 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Leonard	Ensley	1958-06-27	f	f	f	t	f	(828) 555-0193	(828) 555-0193	leonard.ensley@example.com	\N	\N	231 Old County Home Road	Asheville	NC	28806	t	\N	\N	\N	\N	\N	traditional	1959	2020-08-19	t	t	\N	t	2	2		f	f	f	f	f	f	f	f	f	f	f	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	24500.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	231OLDCO	f	44	{}	{}
46	c15e2b5a-8ce9-4280-9103-be28846b6a2b	2026-06-15 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Mabel	Fox	1950-12-06	f	f	f	t	f	(828) 555-0131	(828) 555-0131	mabel.fox@example.com	\N	\N	60 Arizona Avenue	Asheville	NC	28806	t	\N	\N	\N	\N	\N	traditional	1947	2020-08-19	t	t	\N	t	1	1	I keep a chair over the grate so I do not step on it barefoot.	f	f	f	f	f	f	f	f	f	f	f	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	16900.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	60ARIZON	f	45	{}	{}
47	723f5b0f-a6ce-4381-9a0c-4b27314f4dff	2026-06-14 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Nathan	Gentry	1983-04-09	f	f	f	t	f	(828) 555-0157	(828) 555-0157	nathan.gentry@example.com	\N	\N	118 Warren Avenue	Asheville	NC	28803	t	\N	\N	\N	\N	\N	traditional	1961	2020-08-19	t	t	\N	t	4	2	Cooking on a hot plate and the grill outside.	f	f	f	f	t	f	f	f	f	f	f	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	calculator	\N	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	118WARRE	f	46	{}	{}
48	ce4a730a-e9a2-4ffc-b500-ac30f439dfae	2026-06-12 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Opal	Hipps	1941-08-22	f	f	f	t	f	(828) 555-0175	(828) 555-0175	opal.hipps@example.com	\N	\N	33 Mountain View Avenue	Waynesville	NC	28786	t	\N	\N	\N	\N	\N	traditional	1939	2020-08-19	t	t	\N	t	1	1	Occupational therapist recommended the conversion in writing.	f	f	f	f	f	f	f	t	f	f	f	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	15400.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	33MOUNTA	f	47	{}	{}
49	201ada03-6798-40b7-a76f-e41118faacf1	2026-06-10 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Paul	Inman	1977-11-04	f	f	f	t	f	(828) 555-0111	(828) 555-0111	paul.inman@example.com	\N	\N	9 Goldview Street	Asheville	NC	28806	t	\N	\N	\N	\N	\N	traditional	1956	2020-08-19	t	t	\N	t	2	2		f	f	f	f	f	t	f	f	f	f	t	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	34900.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	9GOLDVIE	f	48	{}	{}
50	f21ef26a-99a4-4374-8c58-15079bfffdbd	2026-06-08 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Ruth	Justice	2009-03-16	f	f	f	t	f	(828) 555-0149	(828) 555-0149	ruth.justice@example.com	\N	Applicant is a minor; grandmother is the homeowner and co-signed.	72 Hazel Mill Road	Asheville	NC	28806	t	\N	\N	\N	\N	\N	traditional	1950	2020-08-19	t	t	\N	t	2	1	Applying with my grandmother; she owns the house and signed the consent. I am seventeen.	f	f	f	f	f	f	f	f	f	f	f	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	19200.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	72HAZELM	f	49	{}	{applicant_under_18_guardian_required}
51	2b63a799-537c-4c26-bbe8-a9ff09b2d0d6	2026-08-18 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Samuel	Kuykendall	1967-05-29	f	f	f	t	f	(828) 555-0168	(828) 555-0168	samuel.kuykendall@example.com	\N	\N	305 Old Haw Creek Road	Asheville	NC	28805	t	\N	\N	\N	\N	\N	traditional	1964	2020-08-19	t	t	\N	t	2	2	Gas is off at the meter until the flue is rebuilt.	f	t	f	f	f	t	f	f	f	f	t	t	denied	\N	\N	\N	f	\N	\N	\N	\N	t	gross	31300.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	305OLDHA	f	50	{}	{}
52	41cd0a00-1284-46a5-96a3-a925ad7a8ef6	2026-08-15 10:40:52.469126	eng	t	Marcus Webb	Community Housing Coalition	hello@chc-madison.org	Called our office; we helped her complete the form by phone.	t	Viola	Lunsford	1946-10-02	f	f	f	t	f	(828) 555-0123	(828) 555-0123	viola.lunsford@example.com	\N	\N	11 Belmont Avenue	Asheville	NC	28806	t	\N	\N	\N	\N	\N	traditional	1937	2020-08-19	t	t	\N	t	1	1		f	f	f	t	f	f	f	f	f	f	t	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	17800.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	11BELMON	f	51	{}	{}
53	221b3fd1-a9be-4fcb-97d9-2c3dbc5fbc26	2026-08-13 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Willard	Mashburn	1971-07-18	f	f	f	t	f	(828) 555-0181	(828) 555-0181	willard.mashburn@example.com	\N	\N	520 New Leicester Highway	Asheville	NC	28806	t	\N	\N	\N	\N	\N	traditional	1970	2020-08-19	t	t	\N	t	3	3	Three adults; my brother pays half the mortgage.	f	f	f	f	f	f	f	f	f	f	t	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	58700.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	520NEWLE	f	52	{}	{}
54	96081876-d9d2-497a-9e65-43a5665fec03	2026-08-07 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Yolanda	Nieves	1988-12-23	f	f	f	t	f	(828) 555-0197	(828) 555-0197	yolanda.nieves@example.com	\N	\N	26 Courtland Avenue	Asheville	NC	28801	t	\N	\N	\N	\N	\N	traditional	1954	2020-08-19	t	t	\N	t	4	2		f	t	f	f	f	f	f	f	f	f	f	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	calculator	\N	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	26COURTL	f	53	{}	{}
55	c92edbe2-f78c-466e-9fe9-014729d799b0	2026-07-30 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Elsie	Barnwell	1953-06-08	f	f	f	t	f	(828) 555-0109	(828) 555-0109	elsie.barnwell@example.com	\N	\N	144 Riverbend Road	Asheville	NC	28805	t	\N	\N	\N	\N	\N	traditional	1951	2020-08-19	t	t	\N	t	2	2		f	f	f	f	f	t	f	f	f	f	t	t	other	\N	\N	\N	f	\N	\N	\N	\N	t	gross	28400.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	144RIVER	f	54	{}	{}
56	5e1269f4-0b42-46ad-8f2f-d725dec29a3a	2026-08-01 10:40:52.469126	eng	f	\N	\N	\N	\N	t	Elsie	Barnwell	1953-06-08	f	f	f	t	f	(828) 555-0109	(828) 555-0109	elsie.barnwell@example.com	\N	Called to add that the back door lock failed; submitted again with the update.	144 Riverbend Road	Asheville	NC	28805	t	\N	\N	\N	\N	\N	traditional	1951	2020-08-19	t	t	\N	t	2	2	Second submission with the lock update.	f	f	f	f	f	t	t	f	f	f	t	f	\N	\N	\N	\N	f	\N	\N	\N	\N	t	gross	28400.00	email_link	\N	\N	\N	\N	data:image/png;base64,SEED-DEMO-SIGNATURE	\N	eligible	\N	\N	\N	2026-08-19 10:40:52.469126	t	\N	144RIVER	t	54	{}	{}
\.


--
-- Data for Name: invoice_line_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.invoice_line_items (id, invoice_id, task_id, description, quantity, unit_price, total) FROM stdin;
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.invoices (id, case_id, invoice_number, vendor_name, vendor_type, invoice_date, due_date, paid_date, subtotal, tax, total_amount, status, approved_by, approved_at, paid_by, notes, created_at) FROM stdin;
\.


--
-- Data for Name: login_attempts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.login_attempts (id, ip_address, email, attempted_at) FROM stdin;
\.


--
-- Data for Name: material_requests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.material_requests (id, task_id, requested_by, material_name, quantity, unit, estimated_cost, supplier, status, approved_by, approved_at, order_date, received_date, notes, created_at) FROM stdin;
\.


--
-- Data for Name: materials_inventory; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.materials_inventory (id, sow_line_item_id, material_name, quantity, unit, unit_cost, created_at) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notifications (id, user_id, notification_type, title, body, entity_type, entity_id, is_read, read_at, is_archived, priority, email_sent, sms_sent, in_app_delivered, created_at) FROM stdin;
65	167	case_claimed	Case claimed: 220 Kimberly Avenue - Asheville	Case claimed by Community Housing Coalition (1 repair(s)) by Super Administrator.	case	56	f	\N	f	high	f	f	t	2026-09-04 10:31:22.664262
\.


--
-- Data for Name: organization_eligibility_rules; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.organization_eligibility_rules (id, organization_id, criteria_type_id, rule_operator, rule_value, priority, is_active, created_at, updated_at) FROM stdin;
3	13	3	in_list	Buncombe County,Madison County	10	t	2026-09-10 11:39:36.356695	2026-09-10 11:39:36.356695
4	13	3	in_list	North Carolina	10	t	2026-09-10 11:39:36.370343	2026-09-10 11:39:36.370343
5	13	1	less_than	80	20	t	2026-09-10 11:39:36.3711	2026-09-10 11:39:36.3711
6	13	6	in_list	stick_built,modular,mobile,other	10	t	2026-09-10 11:39:36.382971	2026-09-10 11:39:36.382971
7	13	7	equals	true	20	t	2026-09-10 11:39:36.389267	2026-09-10 11:39:36.389267
8	13	5	equals	yes	20	t	2026-09-10 11:39:36.390057	2026-09-10 11:39:36.390057
9	70	3	in_list	Madison County	10	t	2026-09-10 19:58:05.73833	2026-09-10 19:58:05.73833
10	70	6	in_list	stick_built,modular,mobile,other	10	t	2026-09-10 19:58:05.765276	2026-09-10 19:58:05.765276
11	70	7	equals	true	20	t	2026-09-10 19:58:05.77071	2026-09-10 19:58:05.77071
12	70	5	equals	yes	20	t	2026-09-10 19:58:05.772278	2026-09-10 19:58:05.772278
\.


--
-- Data for Name: organization_metrics; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.organization_metrics (id, organization_id, metric_date, applications_assigned, applications_claimed, applications_rejected, applications_completed, applications_expired, avg_time_to_claim_hours, avg_time_to_complete_days, avg_match_score, rejection_rate, completion_rate, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: organization_users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.organization_users (id, organization_id, email, full_name, role, is_active, last_login, created_at) FROM stdin;
\.


--
-- Data for Name: permission_categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.permission_categories (id, category_code, category_name, description) FROM stdin;
1	CASE	Case Management	\N
2	APPLICATION	Application Management	\N
3	ASSESSMENT	Assessment & Estimation	\N
4	REPAIR	Repair Execution	\N
5	FINANCE	Financial Management	\N
6	USER	User Management	\N
7	ORG	Organization Settings	\N
8	REPORT	Reporting & Analytics	\N
9	DOCUMENT	Document Management	\N
10	COMMUNICATION	Communication Tools	\N
11	SYSTEM	System Administration	\N
12	AUDIT	Audit & Logs	\N
13	DATA	Data Management	\N
14	SUPPORT	Support & Maintenance	\N
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.permissions (id, permission_code, permission_name, category_id, description, created_at) FROM stdin;
1	CASE_VIEW	View case details	1	\N	2026-06-11 16:00:32.023808
2	CASE_CREATE	Create new case	1	\N	2026-06-11 16:00:32.023808
3	CASE_UPDATE	Update case information	1	\N	2026-06-11 16:00:32.023808
4	CASE_DELETE	Delete case	1	\N	2026-06-11 16:00:32.023808
5	CASE_ASSIGN	Assign cases to users	1	\N	2026-06-11 16:00:32.023808
6	CASE_STATUS_UPDATE	Update case status	1	\N	2026-06-11 16:00:32.023808
7	APP_SUBMIT	Submit intake application	2	\N	2026-06-11 16:00:32.023808
8	APP_VIEW_OWN	View own applications	2	\N	2026-06-11 16:00:32.023808
9	APP_VIEW_ALL	View all applications	2	\N	2026-06-11 16:00:32.023808
10	APP_REVIEW	Review applications	2	\N	2026-06-11 16:00:32.023808
11	APP_APPROVE	Approve applications	2	\N	2026-06-11 16:00:32.023808
12	ASSESS_CREATE	Create assessments	3	\N	2026-06-11 16:00:32.023808
13	ASSESS_VIEW	View assessments	3	\N	2026-06-11 16:00:32.023808
14	ASSESS_UPDATE	Update assessments	3	\N	2026-06-11 16:00:32.023808
15	ESTIMATE_CREATE	Create estimates	3	\N	2026-06-11 16:00:32.023808
16	ESTIMATE_APPROVE	Approve estimates	3	\N	2026-06-11 16:00:32.023808
17	PHOTO_UPLOAD	Upload photos	3	\N	2026-06-11 16:00:32.023808
18	REPAIR_VIEW	View repair tasks	4	\N	2026-06-11 16:00:32.023808
19	REPAIR_ASSIGN	Assign repair tasks	4	\N	2026-06-11 16:00:32.023808
20	REPAIR_UPDATE_STATUS	Update repair status	4	\N	2026-06-11 16:00:32.023808
21	REPAIR_COMPLETE	Mark repair complete	4	\N	2026-06-11 16:00:32.023808
22	MATERIAL_REQUEST	Request materials	4	\N	2026-06-11 16:00:32.023808
23	MATERIAL_APPROVE	Approve material requests	4	\N	2026-06-11 16:00:32.023808
24	FINANCE_VIEW	View financial data	5	\N	2026-06-11 16:00:32.023808
25	INVOICE_CREATE	Create invoices	5	\N	2026-06-11 16:00:32.023808
26	INVOICE_PROCESS	Process payments	5	\N	2026-06-11 16:00:32.023808
27	BUDGET_VIEW	View budgets	5	\N	2026-06-11 16:00:32.023808
28	BUDGET_UPDATE	Update budgets	5	\N	2026-06-11 16:00:32.023808
29	EXPENSE_TRACK	Track expenses	5	\N	2026-06-11 16:00:32.023808
30	USER_VIEW	View users	6	\N	2026-06-11 16:00:32.023808
31	USER_CREATE	Create users	6	\N	2026-06-11 16:00:32.023808
32	USER_UPDATE	Update users	6	\N	2026-06-11 16:00:32.023808
33	USER_DELETE	Delete users	6	\N	2026-06-11 16:00:32.023808
34	ROLE_ASSIGN	Assign roles	6	\N	2026-06-11 16:00:32.023808
35	ORG_VIEW	View organization settings	7	\N	2026-06-11 16:00:32.023808
36	ORG_UPDATE	Update organization settings	7	\N	2026-06-11 16:00:32.023808
37	RULE_CONFIG	Configure eligibility rules	7	\N	2026-06-11 16:00:32.023808
38	REPORT_VIEW	View reports	8	\N	2026-06-11 16:00:32.023808
39	REPORT_EXPORT	Export reports	8	\N	2026-06-11 16:00:32.023808
40	REPORT_SCHEDULE	Schedule reports	8	\N	2026-06-11 16:00:32.023808
41	DOC_UPLOAD	Upload documents	9	\N	2026-06-11 16:00:32.023808
42	DOC_VIEW	View documents	9	\N	2026-06-11 16:00:32.023808
43	DOC_DELETE	Delete documents	9	\N	2026-06-11 16:00:32.023808
44	COMM_VIEW	View communications	10	\N	2026-06-11 16:00:32.023808
45	COMM_SEND	Send communications	10	\N	2026-06-11 16:00:32.023808
46	COMM_BROADCAST	Broadcast to org	10	\N	2026-06-11 16:00:32.023808
47	SYSTEM_VIEW	View system status	11	\N	2026-07-25 10:45:39.519619
48	SYSTEM_EDIT	Edit system configuration	11	\N	2026-07-25 10:45:39.519619
49	SYSTEM_BACKUP	Trigger system backups	11	\N	2026-07-25 10:45:39.519619
50	SYSTEM_RESTORE	Restore from backup	11	\N	2026-07-25 10:45:39.519619
51	SYSTEM_CONFIG	Manage system-wide settings	11	\N	2026-07-25 10:45:39.519619
52	ORG_VIEW_ALL	View all organizations	11	\N	2026-07-25 10:45:39.519619
53	ORG_CREATE	Create organizations	11	\N	2026-07-25 10:45:39.519619
54	ORG_EDIT	Edit organizations	11	\N	2026-07-25 10:45:39.519619
55	ORG_ARCHIVE	Archive organizations	11	\N	2026-07-25 10:45:39.519619
56	ORG_RESTORE	Restore archived organizations	11	\N	2026-07-25 10:45:39.519619
57	USER_VIEW_ALL	View all users	11	\N	2026-07-25 10:45:39.519619
59	USER_EDIT	Edit users	11	\N	2026-07-25 10:45:39.519619
60	USER_DEACTIVATE	Deactivate users	11	\N	2026-07-25 10:45:39.519619
61	USER_IMPERSONATE	Impersonate users	11	\N	2026-07-25 10:45:39.519619
62	AUDIT_VIEW_ALL	View all audit logs	12	\N	2026-07-25 10:45:39.519619
63	AUDIT_EXPORT	Export audit logs	12	\N	2026-07-25 10:45:39.519619
64	AUDIT_CONFIG	Configure audit retention	12	\N	2026-07-25 10:45:39.519619
65	DATA_VIEW_ALL	View all data	13	\N	2026-07-25 10:45:39.519619
66	DATA_EXPORT	Export data	13	\N	2026-07-25 10:45:39.519619
67	DATA_IMPORT	Import data	13	\N	2026-07-25 10:45:39.519619
68	DATA_ARCHIVE	Archive data	13	\N	2026-07-25 10:45:39.519619
69	SUPPORT_TICKET_VIEW_ALL	View all support tickets	14	\N	2026-07-25 10:45:39.519619
70	SYSTEM_LOGS_VIEW	View system logs	14	\N	2026-07-25 10:45:39.519619
\.


--
-- Data for Name: progress_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.progress_events (id, event_guid, case_id, organization_id, event_type, event_description, event_source, performed_by, performed_at, metadata, is_progress_event, is_immutable, created_at) FROM stdin;
13	a2b4aa79-fbf4-4daa-8a4c-2e10bccfb6fe	8	13	claim_expired	Claim expired after 95 days without progress	system	\N	2026-08-19 10:40:52.469126	{}	f	t	2026-08-19 10:40:52.469126
1	8abd9c41-e04c-456b-b894-78093f1d5d64	1	13	case_claimed	Application claimed by organization	user	151	2026-08-19 10:40:52.469126	{}	t	t	2026-08-19 10:40:52.469126
2	0f66ae93-03cc-43f8-9274-c74559a629b7	1	13	comm_logged	Called the applicant and scheduled the home assessment	user	151	2026-08-19 10:40:52.469126	{}	t	t	2026-08-19 10:40:52.469126
3	2ee1c3d6-9ad9-45f7-a6f9-d2e131458c59	2	13	case_claimed	Application claimed by organization	user	151	2026-08-19 10:40:52.469126	{}	t	t	2026-08-19 10:40:52.469126
4	21d3ca0c-926f-41a9-bf72-b00b270ce73f	2	13	comm_logged	Called the applicant and scheduled the home assessment	user	151	2026-08-19 10:40:52.469126	{}	t	t	2026-08-19 10:40:52.469126
5	98865848-38e1-4981-bd24-86ea9c0325a8	3	14	case_claimed	Application claimed by organization	user	151	2026-08-19 10:40:52.469126	{}	t	t	2026-08-19 10:40:52.469126
6	634e3f9e-11fe-4456-8739-3e22fb930070	3	14	document_uploaded	Income documents uploaded for verification	user	151	2026-08-19 10:40:52.469126	{}	t	t	2026-08-19 10:40:52.469126
7	7f68aba3-a761-4d90-a31d-9836a21cebb0	11	14	case_claimed	Application claimed by organization	user	151	2026-08-19 10:40:52.469126	{}	t	t	2026-08-19 10:40:52.469126
8	3cdfcc5e-52e1-46fc-b496-f708545eb105	11	14	document_uploaded	Income documents uploaded for verification	user	151	2026-08-19 10:40:52.469126	{}	t	t	2026-08-19 10:40:52.469126
9	e4ecf0f8-e1a1-4eb1-9af8-500fed58a8bf	10	13	case_claimed	Application claimed by organization	user	151	2026-08-19 10:40:52.469126	{}	t	t	2026-08-19 10:40:52.469126
10	d3f04ec9-d9ec-445f-9642-a2955ea2809b	55	14	case_claimed	Application claimed by organization	user	151	2026-08-19 10:40:52.469126	{}	t	t	2026-08-19 10:40:52.469126
11	bfc2c8c8-b4db-4648-9195-d10cd71e3447	10	13	assessment_scheduled	Roof assessment scheduled for next week	user	151	2026-08-19 10:40:52.469126	{}	t	t	2026-08-19 10:40:52.469126
12	86ca475e-40b6-498a-a4f8-d345df02ec50	8	13	case_claimed	Application claimed by organization	user	151	2026-08-19 10:40:52.469126	{}	t	t	2026-08-19 10:40:52.469126
14	5c4e4a98-1f42-49f1-92ee-8f3251450da5	4	13	case_claimed	Application claimed by organization	user	165	2026-09-04 08:37:44.999481	{}	t	t	2026-09-04 08:37:44.999481
15	5cbf94ac-323e-4c10-9eb1-87ce3c83e3bb	5	13	case_claimed	Application claimed by organization	user	165	2026-09-04 08:39:11.003872	{}	t	t	2026-09-04 08:39:11.003872
16	cba53680-cbdb-4279-81b8-67c12b4ca6b4	5	13	comm_logged	Initial contact: spoke with the applicant, confirmed assessment interest.	user	165	2026-09-04 08:39:11.111264	{}	t	t	2026-09-04 08:39:11.111264
17	c96572de-8492-4b5a-9c92-486e7dfe88a2	5	13	assessment_event	Assessment scheduled with the assessor.	user	165	2026-09-04 08:39:11.117488	{}	t	t	2026-09-04 08:39:11.117488
18	4f633cc2-57bb-4978-b48b-fc3af0439402	5	13	assessment_event	Assessment completed; before-photos collected.	user	165	2026-09-04 08:39:11.123463	{}	t	t	2026-09-04 08:39:11.123463
19	f71820f7-13dd-4b70-8b61-e88be3f52448	5	13	progress_task	Repair scope and task list drafted for planning.	user	165	2026-09-04 08:39:11.129981	{}	t	t	2026-09-04 08:39:11.129981
20	35f175e6-e3ab-4904-8fba-598c72ad5cdd	4	13	comm_logged	Initial contact: spoke with the applicant, confirmed assessment interest.	user	165	2026-09-04 08:39:31.969189	{}	t	t	2026-09-04 08:39:31.969189
21	5e7589ad-7d05-4894-af95-b7c2f2f86c08	4	13	assessment_event	Assessment scheduled with the assessor.	user	165	2026-09-04 08:39:31.981244	{}	t	t	2026-09-04 08:39:31.981244
22	a0c3f162-1251-4011-8e29-65d6fc6c1270	4	13	assessment_event	Assessment completed; before-photos collected.	user	165	2026-09-04 08:39:31.9858	{}	t	t	2026-09-04 08:39:31.9858
23	ef6581e1-d956-4e7f-9bcd-04cbacc6b8dc	4	13	progress_task	Repair scope and task list drafted for planning.	user	165	2026-09-04 08:39:31.98948	{}	t	t	2026-09-04 08:39:31.98948
24	bb3e23e6-f46e-41b3-8415-55d3763a35c5	56	70	case_claimed	Application claimed by organization	user	151	2026-09-04 10:31:22.664262	{}	t	t	2026-09-04 10:31:22.664262
\.


--
-- Data for Name: project_assignments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.project_assignments (id, case_id, project_manager_id, crew_lead_id, crew_member_ids, assigned_at, updated_at) FROM stdin;
\.


--
-- Data for Name: project_escalations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.project_escalations (id, case_id, raised_by, issue_type, severity, description, action_taken, resolved_at, resolved_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: project_milestones; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.project_milestones (id, case_id, milestone_type, milestone_date, milestone_notes, is_complete, completed_at, created_at) FROM stdin;
\.


--
-- Data for Name: project_snapshots; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.project_snapshots (id, snapshot_date, case_id, progress_percentage, budget_used, budget_remaining, milestones_completed_since_last, is_on_schedule, is_on_budget, days_until_deadline, days_since_started, calculated_cost_percentage, calculated_time_percentage, created_at) FROM stdin;
\.


--
-- Data for Name: property_assessments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.property_assessments (id, case_id, assessor_id, assessment_date, property_condition, structural_issues, electrical_issues, plumbing_issues, hvac_issues, roofing_issues, accessibility_needs, safety_hazards, photos, square_footage, num_bedrooms, num_bathrooms, recommended_repairs, priority_repairs, estimated_hours, estimated_material_cost, estimated_labor_cost, total_estimate, assessment_notes, assigned_at, assessment_completed_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: quest_assignments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.quest_assignments (id, quest_id, volunteer_id, status, assigned_at, started_at, completed_at, cancelled_at, hours_logged, hours_verified, verified_by, verified_at, before_photo_urls, during_photo_urls, after_photo_urls, volunteer_notes, xp_awarded, reputation_awarded, rewards_claimed, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: quests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.quests (id, quest_number, title, description, quest_type, difficulty, xp_reward, reputation_reward, coin_reward, required_level, required_skills, required_certifications, max_volunteers, current_volunteers, location_address, location_lat, location_lng, radius_miles, estimated_hours, flexible_timing, scheduled_start, scheduled_end, parent_quest_id, case_id, work_task_id, quest_giver_id, instructions, safety_notes, materials_needed, status, expires_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: reimbursement_requests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reimbursement_requests (id, case_id, organization_id, amount, submitted_date, approved_date, paid_date, status, denial_reason, funding_source_id) FROM stdin;
\.


--
-- Data for Name: repair_categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.repair_categories (id, category_code, category_label) FROM stdin;
1	unable_to_stay	Unable to stay in home
2	no_hvac	No heating/AC
3	no_potable_water	No potable water
4	no_bathroom	Cannot use bathroom
5	no_kitchen	Cannot use kitchen
6	open_to_elements	Open to elements
7	no_entry	Cannot enter/exit
8	accessibility	Accessibility need
9	other_issue	Other issue
10	eviction_risk	Eviction risk
\.


--
-- Data for Name: repair_category_details; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.repair_category_details (id, submission_id, category_id, details_text, heating_woodstove, heating_gas_propane, heating_electric, heating_kerosene, water_source) FROM stdin;
\.


--
-- Data for Name: repair_estimates; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.repair_estimates (id, assessment_id, repair_category_id, description, quantity, unit_cost, material_cost, labor_hours, labor_rate, labor_cost, total_cost, is_approved, approved_by, approved_at, notes) FROM stdin;
\.


--
-- Data for Name: repair_requests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.repair_requests (id, submission_id, repair_need, priority, sort_order) FROM stdin;
1	1	Roof leaking over the bedroom; the tarp from the storm is failing	1	1
2	1	Rotted soffit and fascia at the rear eave	2	2
3	2	Furnace stopped working entirely; using space heaters	1	1
4	3	Bathroom floor rotted through around the toilet; soft subfloor	1	1
5	3	Bathtub drain leaks into the crawlspace	2	2
6	4	Skirting torn off on the north side; pipes froze twice	1	1
7	4	Furnace short-cycles and smells of gas	2	2
8	5	Kitchen supply line burst; cabinet base is swollen and moldy	1	1
9	6	Heat pump dead; landlord unresponsive for months	1	1
10	7	Tree limb punctured the roof during Helene; attic open to rain	1	1
11	8	Well pump failed; hauling water from the neighbor	1	1
12	9	Wheelchair ramp needed at the front steps; fell twice in July	1	1
13	9	Front door frame sagging; deadbolt no longer catches	2	2
14	10	Roof replacement; three-tab shingles blown off across the south slope	1	1
15	10	Plumbing stack cracked, leaks into the kitchen wall	2	2
16	10	Water heater rusted at the base	3	3
17	11	Roof replacement; three-tab shingles blown off across the south slope	1	1
18	11	Plumbing stack cracked, leaks into the kitchen wall	2	2
19	11	Water heater rusted at the base	3	3
20	12	Kitchen subfloor soft at the sink; stove unusable after the leak	1	1
21	13	Oil furnace quit in January; kerosene heater in the living room	1	1
22	14	Galvanized lines barely trickle; the house needs a re-pipe	1	1
23	15	Tree on the roof during Helene; rafters cracked over the den	1	1
24	15	Den ceiling drywall collapsed	2	2
25	16	Only toilet runs constantly and the flange leaks at the base	1	1
26	16	Wall heater emits a burning smell	2	2
27	17	Crawlspace joists were sistered with scrap after the flood; needs proper repair	1	1
28	18	No central heat; two window units for summer only	1	1
29	18	Chimney flashing leaks into the hall closet	2	2
30	19	Well runs dry every evening; pressure tank is waterlogged	1	1
31	20	Back steps collapsed; only one way in and out of the house	1	1
32	20	Grab bars needed in the bathroom	2	2
33	21	Porch roof pulling away from the ledger; gaps at the header	1	1
34	22	Kitchen wiring is knob-and-tube; the breaker trips with the microwave	1	1
35	23	Roof seam split after the storm; water runs down the hallway wall	1	1
36	23	Heat strips failed	2	2
37	24	Shower pan cracked; water getting under the vinyl	1	1
38	25	Front porch floorboards rotted through in two places	1	1
39	25	Gutter tore off the east side; water sheets down the wall	2	2
40	26	Baseboard heaters dead in the kids bedrooms	1	1
41	27	Metal roof panels lifted at the ridge; leaks at the seams	1	1
42	28	Water heater dead; heating water on the stove	1	1
43	29	Tub surround separated from the wall; studs are soft	1	1
44	30	Monitor heater quit; using the oven for heat on cold mornings	1	1
45	31	Flood water stood in the crawlspace for weeks; insulation down, joists questionable	1	1
46	31	Ductwork submerged and likely moldy	2	2
47	32	Kitchen floor joists cracked under the fridge; floor visibly slopes	1	1
48	33	Two sheets of roofing tin gone since the hurricane; attic rains	1	1
49	33	Heat pump compressor seized	2	2
50	34	Sewer smell from the tub drain; trap likely dry or cracked	1	1
51	35	Foundation pier collapsed under the northeast corner; doors racked	1	1
52	36	Spring box cracked; water runs muddy after rain	1	1
53	37	Package unit failed; five of us with two space heaters	1	1
54	38	Front porch steps are crumbling brick; cannot manage them	1	1
55	38	Handrail loose on the interior stairs	2	2
56	39	Branch through the kitchen roof; skylight of tarp and plywood	1	1
57	40	Bathroom only reachable by five steps; need main-floor wash options	1	1
58	41	Furnace blower dead; cold air return pulls from the crawlspace	1	1
59	42	Valley leak over the dining room; plaster falling	1	1
60	43	Pressure switch shorted; pump cycles every few seconds	1	1
61	44	Limb hole in the garage roof and the main roof ridge cap gone	1	1
62	45	Tub unusable; standing shower over a floor drain for now	1	1
63	46	Floor furnace grate gets dangerously hot; unit cycles off	1	1
64	47	Cabinet over the stove caught fire in June; scorched wall and no range	1	1
65	48	Tub-to-shower conversion with a seat; cannot lift my legs over the tub wall	1	1
66	49	Satellite dish tore a hole when it came down in the storm	1	1
67	50	Kitchen faucet snapped off at the base; main shutoff leaks too	1	1
68	51	Storm took half the ridge and the furnace flue with it	1	1
69	51	Furnace red-tagged by the gas company	2	2
70	52	Toilet rocks and leaks at the wax ring; floor spongy around it	1	1
71	53	Rear addition separating from the main house; crack widening	1	1
72	54	No working heat upstairs where the kids sleep	1	1
73	55	River took the back deck and the steps to the door	1	1
74	55	Skirting and two basement windows gone	2	2
75	56	River took the back deck and the steps to the door	1	1
76	56	Skirting and two basement windows gone	2	2
77	56	Now the back door lock has failed; the house is not secure	3	3
\.


--
-- Data for Name: review_queue; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.review_queue (id, submission_id, fifo_order, status, assigned_to_id, assigned_at, organization_id, queued_at, reviewed_at, completed_at, priority_score, notes) FROM stdin;
1	1	232	PENDING_REVIEW	\N	\N	\N	2026-08-17 10:40:52.469126	\N	\N	10	\N
2	2	233	PENDING_REVIEW	\N	\N	\N	2026-08-16 10:40:52.469126	\N	\N	10	\N
3	3	234	PENDING_REVIEW	\N	\N	\N	2026-08-14 10:40:52.469126	\N	\N	10	\N
4	4	235	PENDING_REVIEW	\N	\N	\N	2026-08-12 10:40:52.469126	\N	\N	10	\N
5	5	236	PENDING_REVIEW	\N	\N	\N	2026-08-11 10:40:52.469126	\N	\N	0	\N
6	6	237	PENDING_REVIEW	\N	\N	\N	2026-08-10 10:40:52.469126	\N	\N	0	\N
7	7	238	PENDING_REVIEW	\N	\N	\N	2026-08-09 10:40:52.469126	\N	\N	10	\N
8	8	239	PENDING_REVIEW	\N	\N	\N	2026-08-08 10:40:52.469126	\N	\N	10	\N
9	9	240	PENDING_REVIEW	\N	\N	\N	2026-08-06 10:40:52.469126	\N	\N	10	\N
10	10	241	PENDING_REVIEW	\N	\N	\N	2026-07-10 10:40:52.469126	\N	\N	10	\N
11	11	242	PENDING_REVIEW	\N	\N	\N	2026-07-13 10:40:52.469126	\N	\N	10	\N
12	12	243	PENDING_REVIEW	\N	\N	\N	2026-08-05 10:40:52.469126	\N	\N	10	\N
13	13	244	PENDING_REVIEW	\N	\N	\N	2026-08-04 10:40:52.469126	\N	\N	0	\N
14	14	245	PENDING_REVIEW	\N	\N	\N	2026-08-03 10:40:52.469126	\N	\N	0	\N
15	15	246	PENDING_REVIEW	\N	\N	\N	2026-08-02 10:40:52.469126	\N	\N	10	\N
16	16	247	PENDING_REVIEW	\N	\N	\N	2026-07-31 10:40:52.469126	\N	\N	10	\N
17	17	248	PENDING_REVIEW	\N	\N	\N	2026-07-29 10:40:52.469126	\N	\N	0	\N
18	18	249	PENDING_REVIEW	\N	\N	\N	2026-07-27 10:40:52.469126	\N	\N	10	\N
19	19	250	PENDING_REVIEW	\N	\N	\N	2026-07-26 10:40:52.469126	\N	\N	10	\N
20	20	251	PENDING_REVIEW	\N	\N	\N	2026-07-25 10:40:52.469126	\N	\N	10	\N
21	21	252	PENDING_REVIEW	\N	\N	\N	2026-07-23 10:40:52.469126	\N	\N	0	\N
22	22	253	PENDING_REVIEW	\N	\N	\N	2026-07-22 10:40:52.469126	\N	\N	0	\N
23	23	254	PENDING_REVIEW	\N	\N	\N	2026-07-20 10:40:52.469126	\N	\N	10	\N
24	24	255	PENDING_REVIEW	\N	\N	\N	2026-07-19 10:40:52.469126	\N	\N	0	\N
25	25	256	PENDING_REVIEW	\N	\N	\N	2026-07-17 10:40:52.469126	\N	\N	0	\N
26	26	257	PENDING_REVIEW	\N	\N	\N	2026-07-16 10:40:52.469126	\N	\N	10	\N
27	27	258	PENDING_REVIEW	\N	\N	\N	2026-07-15 10:40:52.469126	\N	\N	0	\N
28	28	259	PENDING_REVIEW	\N	\N	\N	2026-07-14 10:40:52.469126	\N	\N	0	\N
29	29	260	PENDING_REVIEW	\N	\N	\N	2026-07-12 10:40:52.469126	\N	\N	0	\N
30	30	261	PENDING_REVIEW	\N	\N	\N	2026-07-11 10:40:52.469126	\N	\N	10	\N
31	31	262	PENDING_REVIEW	\N	\N	\N	2026-07-08 10:40:52.469126	\N	\N	10	\N
32	32	263	PENDING_REVIEW	\N	\N	\N	2026-07-07 10:40:52.469126	\N	\N	10	\N
33	33	264	PENDING_REVIEW	\N	\N	\N	2026-07-06 10:40:52.469126	\N	\N	10	\N
34	34	265	PENDING_REVIEW	\N	\N	\N	2026-07-04 10:40:52.469126	\N	\N	0	\N
35	35	266	PENDING_REVIEW	\N	\N	\N	2026-07-03 10:40:52.469126	\N	\N	0	\N
36	36	267	PENDING_REVIEW	\N	\N	\N	2026-07-02 10:40:52.469126	\N	\N	0	\N
37	37	268	PENDING_REVIEW	\N	\N	\N	2026-07-01 10:40:52.469126	\N	\N	10	\N
38	38	269	PENDING_REVIEW	\N	\N	\N	2026-06-29 10:40:52.469126	\N	\N	10	\N
39	39	270	PENDING_REVIEW	\N	\N	\N	2026-06-28 10:40:52.469126	\N	\N	10	\N
40	40	271	PENDING_REVIEW	\N	\N	\N	2026-06-26 10:40:52.469126	\N	\N	0	\N
41	41	272	PENDING_REVIEW	\N	\N	\N	2026-06-24 10:40:52.469126	\N	\N	10	\N
42	42	273	PENDING_REVIEW	\N	\N	\N	2026-06-22 10:40:52.469126	\N	\N	0	\N
43	43	274	PENDING_REVIEW	\N	\N	\N	2026-06-21 10:40:52.469126	\N	\N	10	\N
44	44	275	PENDING_REVIEW	\N	\N	\N	2026-06-19 10:40:52.469126	\N	\N	10	\N
45	45	276	PENDING_REVIEW	\N	\N	\N	2026-06-17 10:40:52.469126	\N	\N	0	\N
46	46	277	PENDING_REVIEW	\N	\N	\N	2026-06-15 10:40:52.469126	\N	\N	0	\N
47	47	278	PENDING_REVIEW	\N	\N	\N	2026-06-14 10:40:52.469126	\N	\N	10	\N
48	48	279	PENDING_REVIEW	\N	\N	\N	2026-06-12 10:40:52.469126	\N	\N	10	\N
49	49	280	PENDING_REVIEW	\N	\N	\N	2026-06-10 10:40:52.469126	\N	\N	10	\N
50	50	281	PENDING_REVIEW	\N	\N	\N	2026-06-08 10:40:52.469126	\N	\N	0	\N
51	51	282	PENDING_REVIEW	\N	\N	\N	2026-08-18 10:40:52.469126	\N	\N	20	\N
52	52	283	PENDING_REVIEW	\N	\N	\N	2026-08-15 10:40:52.469126	\N	\N	10	\N
53	53	284	PENDING_REVIEW	\N	\N	\N	2026-08-13 10:40:52.469126	\N	\N	0	\N
54	54	285	PENDING_REVIEW	\N	\N	\N	2026-08-07 10:40:52.469126	\N	\N	10	\N
55	55	286	PENDING_REVIEW	\N	\N	\N	2026-07-30 10:40:52.469126	\N	\N	10	\N
56	56	287	PENDING_REVIEW	\N	\N	\N	2026-08-01 10:40:52.469126	\N	\N	20	\N
\.


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.role_permissions (id, role_id, permission_id, created_at) FROM stdin;
1	1	1	2026-06-11 16:00:32.038079
2	1	2	2026-06-11 16:00:32.038079
3	1	3	2026-06-11 16:00:32.038079
4	1	4	2026-06-11 16:00:32.038079
5	1	5	2026-06-11 16:00:32.038079
6	1	6	2026-06-11 16:00:32.038079
7	1	7	2026-06-11 16:00:32.038079
8	1	8	2026-06-11 16:00:32.038079
9	1	9	2026-06-11 16:00:32.038079
10	1	10	2026-06-11 16:00:32.038079
11	1	11	2026-06-11 16:00:32.038079
12	1	12	2026-06-11 16:00:32.038079
13	1	13	2026-06-11 16:00:32.038079
14	1	14	2026-06-11 16:00:32.038079
15	1	15	2026-06-11 16:00:32.038079
16	1	16	2026-06-11 16:00:32.038079
17	1	17	2026-06-11 16:00:32.038079
18	1	18	2026-06-11 16:00:32.038079
19	1	19	2026-06-11 16:00:32.038079
20	1	20	2026-06-11 16:00:32.038079
21	1	21	2026-06-11 16:00:32.038079
22	1	22	2026-06-11 16:00:32.038079
23	1	23	2026-06-11 16:00:32.038079
24	1	24	2026-06-11 16:00:32.038079
25	1	25	2026-06-11 16:00:32.038079
26	1	26	2026-06-11 16:00:32.038079
27	1	27	2026-06-11 16:00:32.038079
28	1	28	2026-06-11 16:00:32.038079
29	1	29	2026-06-11 16:00:32.038079
30	1	30	2026-06-11 16:00:32.038079
31	1	31	2026-06-11 16:00:32.038079
32	1	32	2026-06-11 16:00:32.038079
33	1	33	2026-06-11 16:00:32.038079
34	1	34	2026-06-11 16:00:32.038079
35	1	35	2026-06-11 16:00:32.038079
36	1	36	2026-06-11 16:00:32.038079
37	1	37	2026-06-11 16:00:32.038079
38	1	38	2026-06-11 16:00:32.038079
39	1	39	2026-06-11 16:00:32.038079
40	1	40	2026-06-11 16:00:32.038079
41	1	41	2026-06-11 16:00:32.038079
42	1	42	2026-06-11 16:00:32.038079
43	1	43	2026-06-11 16:00:32.038079
44	1	44	2026-06-11 16:00:32.038079
45	1	45	2026-06-11 16:00:32.038079
46	1	46	2026-06-11 16:00:32.038079
47	2	1	2026-06-11 16:00:32.042857
48	2	3	2026-06-11 16:00:32.042857
49	2	5	2026-06-11 16:00:32.042857
50	2	6	2026-06-11 16:00:32.042857
51	2	13	2026-06-11 16:00:32.042857
52	2	16	2026-06-11 16:00:32.042857
53	2	18	2026-06-11 16:00:32.042857
54	2	19	2026-06-11 16:00:32.042857
55	2	20	2026-06-11 16:00:32.042857
56	2	23	2026-06-11 16:00:32.042857
57	2	24	2026-06-11 16:00:32.042857
58	2	27	2026-06-11 16:00:32.042857
59	2	28	2026-06-11 16:00:32.042857
60	2	38	2026-06-11 16:00:32.042857
61	2	39	2026-06-11 16:00:32.042857
62	2	42	2026-06-11 16:00:32.042857
63	2	44	2026-06-11 16:00:32.042857
64	2	45	2026-06-11 16:00:32.042857
65	3	1	2026-06-11 16:00:32.044101
66	3	24	2026-06-11 16:00:32.044101
67	3	25	2026-06-11 16:00:32.044101
68	3	26	2026-06-11 16:00:32.044101
69	3	27	2026-06-11 16:00:32.044101
70	3	29	2026-06-11 16:00:32.044101
71	3	38	2026-06-11 16:00:32.044101
72	3	39	2026-06-11 16:00:32.044101
73	4	1	2026-06-11 16:00:32.045076
74	4	3	2026-06-11 16:00:32.045076
75	4	6	2026-06-11 16:00:32.045076
76	4	9	2026-06-11 16:00:32.045076
77	4	10	2026-06-11 16:00:32.045076
78	4	13	2026-06-11 16:00:32.045076
79	4	41	2026-06-11 16:00:32.045076
80	4	42	2026-06-11 16:00:32.045076
81	4	44	2026-06-11 16:00:32.045076
82	4	45	2026-06-11 16:00:32.045076
83	5	1	2026-06-11 16:00:32.04594
84	5	12	2026-06-11 16:00:32.04594
85	5	13	2026-06-11 16:00:32.04594
86	5	14	2026-06-11 16:00:32.04594
87	5	15	2026-06-11 16:00:32.04594
88	5	17	2026-06-11 16:00:32.04594
89	5	41	2026-06-11 16:00:32.04594
90	5	42	2026-06-11 16:00:32.04594
91	6	1	2026-06-11 16:00:32.046598
92	6	18	2026-06-11 16:00:32.046598
93	6	19	2026-06-11 16:00:32.046598
94	6	20	2026-06-11 16:00:32.046598
95	6	21	2026-06-11 16:00:32.046598
96	6	22	2026-06-11 16:00:32.046598
97	6	42	2026-06-11 16:00:32.046598
98	6	44	2026-06-11 16:00:32.046598
99	7	1	2026-06-11 16:00:32.047245
100	7	15	2026-06-11 16:00:32.047245
101	7	18	2026-06-11 16:00:32.047245
102	7	20	2026-06-11 16:00:32.047245
103	7	42	2026-06-11 16:00:32.047245
104	7	44	2026-06-11 16:00:32.047245
105	8	1	2026-06-11 16:00:32.047854
106	8	3	2026-06-11 16:00:32.047854
107	8	41	2026-06-11 16:00:32.047854
108	8	42	2026-06-11 16:00:32.047854
109	8	44	2026-06-11 16:00:32.047854
110	8	45	2026-06-11 16:00:32.047854
111	9	18	2026-06-11 16:00:32.048434
112	9	20	2026-06-11 16:00:32.048434
113	9	42	2026-06-11 16:00:32.048434
114	10	7	2026-06-11 16:00:32.049041
115	10	8	2026-06-11 16:00:32.049041
116	10	41	2026-06-11 16:00:32.049041
117	11	18	2026-06-11 16:00:32.04958
118	11	42	2026-06-11 16:00:32.04958
119	40	48	2026-07-25 10:45:39.526957
120	40	28	2026-07-25 10:45:39.526957
121	40	30	2026-07-25 10:45:39.526957
122	40	62	2026-07-25 10:45:39.526957
123	40	8	2026-07-25 10:45:39.526957
124	40	6	2026-07-25 10:45:39.526957
125	40	29	2026-07-25 10:45:39.526957
126	40	41	2026-07-25 10:45:39.526957
127	40	42	2026-07-25 10:45:39.526957
128	40	59	2026-07-25 10:45:39.526957
129	40	50	2026-07-25 10:45:39.526957
130	40	51	2026-07-25 10:45:39.526957
131	40	69	2026-07-25 10:45:39.526957
132	40	67	2026-07-25 10:45:39.526957
133	40	45	2026-07-25 10:45:39.526957
134	40	70	2026-07-25 10:45:39.526957
135	40	60	2026-07-25 10:45:39.526957
136	40	1	2026-07-25 10:45:39.526957
137	40	22	2026-07-25 10:45:39.526957
138	40	49	2026-07-25 10:45:39.526957
139	40	36	2026-07-25 10:45:39.526957
140	40	4	2026-07-25 10:45:39.526957
141	40	53	2026-07-25 10:45:39.526957
142	40	23	2026-07-25 10:45:39.526957
143	40	44	2026-07-25 10:45:39.526957
144	40	16	2026-07-25 10:45:39.526957
145	40	54	2026-07-25 10:45:39.526957
146	40	7	2026-07-25 10:45:39.526957
147	40	63	2026-07-25 10:45:39.526957
148	40	9	2026-07-25 10:45:39.526957
149	40	14	2026-07-25 10:45:39.526957
150	40	35	2026-07-25 10:45:39.526957
151	40	43	2026-07-25 10:45:39.526957
152	40	3	2026-07-25 10:45:39.526957
153	40	61	2026-07-25 10:45:39.526957
154	40	27	2026-07-25 10:45:39.526957
155	40	25	2026-07-25 10:45:39.526957
156	40	26	2026-07-25 10:45:39.526957
157	40	20	2026-07-25 10:45:39.526957
158	40	64	2026-07-25 10:45:39.526957
159	40	2	2026-07-25 10:45:39.526957
160	40	34	2026-07-25 10:45:39.526957
161	40	12	2026-07-25 10:45:39.526957
162	40	10	2026-07-25 10:45:39.526957
163	40	18	2026-07-25 10:45:39.526957
164	40	17	2026-07-25 10:45:39.526957
165	40	66	2026-07-25 10:45:39.526957
166	40	33	2026-07-25 10:45:39.526957
167	40	57	2026-07-25 10:45:39.526957
168	40	31	2026-07-25 10:45:39.526957
169	40	11	2026-07-25 10:45:39.526957
170	40	39	2026-07-25 10:45:39.526957
171	40	21	2026-07-25 10:45:39.526957
172	40	5	2026-07-25 10:45:39.526957
173	40	13	2026-07-25 10:45:39.526957
174	40	46	2026-07-25 10:45:39.526957
175	40	15	2026-07-25 10:45:39.526957
176	40	56	2026-07-25 10:45:39.526957
177	40	40	2026-07-25 10:45:39.526957
178	40	47	2026-07-25 10:45:39.526957
179	40	55	2026-07-25 10:45:39.526957
180	40	68	2026-07-25 10:45:39.526957
181	40	38	2026-07-25 10:45:39.526957
182	40	32	2026-07-25 10:45:39.526957
183	40	24	2026-07-25 10:45:39.526957
184	40	19	2026-07-25 10:45:39.526957
185	40	65	2026-07-25 10:45:39.526957
186	40	52	2026-07-25 10:45:39.526957
187	40	37	2026-07-25 10:45:39.526957
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.roles (id, role_code, role_name, role_level, description, is_system_role, created_at) FROM stdin;
1	ADMIN	Administrator	10	Full system administration and configuration	t	2026-06-11 16:00:31.99633
2	PROJECT_MANAGER	Project Manager	9	Oversees multiple projects, budgets, and timelines	t	2026-06-11 16:00:31.99633
3	BURSAR	Bursar	8	Financial management, payments, and invoicing	t	2026-06-11 16:00:31.99633
4	CASEWORKER	Caseworker	7	Primary applicant contact and case coordination	t	2026-06-11 16:00:31.99633
5	ASSESSOR	Assessor	6	Conducts home visits and repair assessments	t	2026-06-11 16:00:31.99633
6	CREW_LEAD	Crew Lead	5	Manages on-site repair crew and work quality	t	2026-06-11 16:00:31.99633
7	SUBCONTRACTOR	Subcontractor	4	External trade specialist	t	2026-06-11 16:00:31.99633
8	ENVOY	Envoy	3	Community liaison and applicant support	t	2026-06-11 16:00:31.99633
9	CREW_MEMBER	Crew Member	2	Performs repair work under supervision	t	2026-06-11 16:00:31.99633
10	REQUESTOR	Requestor	1	Submits initial intake applications	t	2026-06-11 16:00:31.99633
11	VOLUNTEER	Volunteer	0	Unpaid helper with limited access	t	2026-06-11 16:00:31.99633
34	PROJECT_MGR	Project Manager	60	Oversees repair projects from assessment to completion	t	2026-07-02 19:16:39.600812
36	ORG_ADMIN	Organization Admin	80	Administrative access for partner organizations	t	2026-07-02 19:16:39.600812
40	SUPER_ADMIN	Super Administrator	15	System-level administrator across all organizations and the entire platform	t	2026-07-25 10:45:39.512335
\.


--
-- Data for Name: scope_of_work_line_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.scope_of_work_line_items (id, assessment_id, task_name, location, details, estimated_cost, quoted_cost, actual_cost, status, repair_need_id, case_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: site_photos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.site_photos (id, assessment_id, repair_need_id, file_path, file_name, title, date_taken, taken_by, photo_type, created_at) FROM stdin;
\.


--
-- Data for Name: skills; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.skills (id, skill_code, skill_name, category, description, requires_training, training_resource_url, created_at) FROM stdin;
1	LADDER_SAFE	Ladder Safety	construction	\N	t	\N	2026-06-11 16:00:32.366055
2	ROOF_WORK	Roof Work	construction	\N	t	\N	2026-06-11 16:00:32.366055
3	DEMOLITION	Demolition	construction	\N	f	\N	2026-06-11 16:00:32.366055
4	CLEANUP	Debris Cleanup	cleanup	\N	f	\N	2026-06-11 16:00:32.366055
5	MATERIAL_TRANSPORT	Material Transport	logistics	\N	f	\N	2026-06-11 16:00:32.366055
6	PHOTO_DOC	Photo Documentation	admin	\N	f	\N	2026-06-11 16:00:32.366055
7	CLIENT_COMM	Client Communication	social	\N	f	\N	2026-06-11 16:00:32.366055
8	TOOL_MAINT	Tool Maintenance	construction	\N	f	\N	2026-06-11 16:00:32.366055
\.


--
-- Data for Name: storage_providers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.storage_providers (id, provider_name, is_default, configuration, base_url, max_file_size_bytes, allowed_mime_types, is_active, created_at) FROM stdin;
1	dropbox	t	{"app_key": "placeholder", "app_secret": "placeholder"}	https://www.dropbox.com/	104857600	\N	t	2026-06-11 16:00:32.829203
\.


--
-- Data for Name: subcontractor_communications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.subcontractor_communications (id, task_id, subcontractor_id, sender_id, communication_type, subject, body, is_read, read_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: subcontractor_invoices; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.subcontractor_invoices (id, task_id, subcontractor_id, invoice_number, invoice_date, amount, work_performed, payment_terms, invoice_document_id, status, approved_by, approved_at, paid_by, paid_at, payment_reference, rejection_reason, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: subcontractor_profiles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.subcontractor_profiles (id, user_id, company_name, trade_specialty, license_number, insurance_provider, insurance_expiration, business_phone, business_email, business_address, max_active_tasks, service_radius_miles, available_days, avg_rating, total_rating_count, is_active, is_approved, approval_notes, approved_by, approved_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: subcontractor_quotes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.subcontractor_quotes (id, task_id, subcontractor_id, quote_amount, labor_cost, materials_cost, travel_cost, quote_details, valid_until, status, approved_by, approved_at, rejected_reason, quote_document_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: submission_contact_methods; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.submission_contact_methods (submission_id, method_id) FROM stdin;
1	3
2	3
3	3
4	3
5	3
6	3
7	3
8	3
9	3
10	3
11	3
12	3
13	3
14	3
15	3
16	3
17	3
18	3
19	3
20	3
21	3
22	3
23	3
24	3
25	3
26	3
27	3
28	3
29	3
30	3
31	3
32	3
33	3
34	3
35	3
36	3
37	3
38	3
39	3
40	3
41	3
42	3
43	3
44	3
45	3
46	3
47	3
48	3
49	3
50	3
51	3
52	3
53	3
54	3
55	3
56	3
\.


--
-- Data for Name: submission_household_attributes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.submission_household_attributes (submission_id, attribute_id) FROM stdin;
1	3
2	6
3	1
3	2
8	3
9	3
9	4
13	3
14	3
16	1
16	5
18	3
20	3
20	4
24	3
25	3
26	1
26	2
26	5
28	3
30	3
31	6
33	3
34	1
36	3
38	3
38	4
40	3
42	3
46	3
48	3
48	4
52	3
54	2
54	5
\.


--
-- Data for Name: submission_repair_categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.submission_repair_categories (submission_id, category_id) FROM stdin;
1	6
2	2
3	4
4	2
4	6
5	5
6	2
7	6
8	3
9	7
9	8
10	6
11	6
12	5
13	2
14	3
15	6
16	2
16	4
17	9
18	2
18	6
19	3
20	7
20	8
21	6
22	5
23	2
23	6
24	4
25	6
25	7
26	2
27	6
28	3
29	4
30	2
31	6
32	5
33	2
33	6
34	4
35	9
36	3
37	2
38	7
38	8
39	6
40	4
40	9
41	2
42	6
43	3
44	6
45	4
46	2
47	5
48	8
49	6
50	3
51	2
51	6
52	4
53	9
54	2
55	6
56	6
56	7
\.


--
-- Data for Name: support_tickets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.support_tickets (id, submitted_by, submitter_name, submitter_email, category, subject, description, screenshot_url, status, priority, assigned_to, resolved_at, resolved_by, resolution_note, created_at, updated_at) FROM stdin;
2	101	James Thornton	james.thornton@archr.org	general	Help nothing to do	Help nothing to do	\N	open	normal	\N	\N	\N	\N	2026-09-10 09:06:20.081919-04	2026-09-10 09:06:20.081919-04
3	101	James Thornton	james.thornton@archr.org	general	ajlkasdfdfasjlkasdfjlk	ajlkasdfdfasjlkasdfjlk	\N	open	normal	\N	\N	\N	\N	2026-09-10 10:53:10.372387-04	2026-09-10 10:53:10.372387-04
1	151	Super Administrator	superadmin@archr.local	general	Help Library doesn't boot	idk	\N	resolved	normal	\N	2026-09-23 08:56:53.374906-04	151		2026-09-10 08:40:15.217418-04	2026-09-23 08:56:53.374906-04
\.


--
-- Data for Name: system_users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.system_users (id, email, full_name, phone, avatar_url, is_active, last_login, last_ip, password_hash, reset_token, reset_token_expires, created_at, updated_at, created_by, updated_by, username, first_name, last_name, session_indefinite, menu_config) FROM stdin;
167	aachips@aachips.co	aachips	615-502-0384	\N	t	\N	\N	$2y$10$uFG69bwoCMn3Vlf/8u6Vz.IUBNpHyScvkDBeAQllbe0K.d9umh9Hu	\N	\N	2026-08-19 19:06:09.652657	2026-09-08 08:55:30.355765	151	\N	aachips.superadmin	aachips		f	\N
172	test-assessor@archr.local	Test Assessor	\N	\N	t	2026-11-02 11:31:55.802028	\N	$2y$10$J7hIUMw76NIcamnMC0R7PeM9NOqYkm3fg0S6vCSbWskDulnJFBGF.	\N	\N	2026-10-28 08:41:17.333553	2026-10-28 08:41:17.333553	\N	\N	test_assessor	\N	\N	f	\N
171	test-requestor@archr.local	Test Requestor	\N	\N	t	2026-10-31 08:27:43.612293	\N	$2y$10$J7hIUMw76NIcamnMC0R7PeM9NOqYkm3fg0S6vCSbWskDulnJFBGF.	\N	\N	2026-10-28 08:41:17.315952	2026-10-28 08:41:17.315952	\N	\N	test_requestor	\N	\N	f	\N
173	test-envoy@archr.local	Test Envoy	\N	\N	t	2026-10-28 09:12:30.42457	\N	$2y$10$J7hIUMw76NIcamnMC0R7PeM9NOqYkm3fg0S6vCSbWskDulnJFBGF.	\N	\N	2026-10-28 08:41:17.342383	2026-10-28 08:41:17.342383	\N	\N	test_envoy	\N	\N	f	\N
176	test-caseworker@archr.local	Test Caseworker	\N	\N	t	2026-10-28 09:15:26.395916	\N	$2y$10$J7hIUMw76NIcamnMC0R7PeM9NOqYkm3fg0S6vCSbWskDulnJFBGF.	\N	\N	2026-10-28 08:41:17.358516	2026-10-28 08:41:17.358516	\N	\N	test_caseworker	\N	\N	f	\N
174	test-bursar@archr.local	Test Bursar	\N	\N	t	2026-10-28 09:16:47.582399	\N	$2y$10$J7hIUMw76NIcamnMC0R7PeM9NOqYkm3fg0S6vCSbWskDulnJFBGF.	\N	\N	2026-10-28 08:41:17.348106	2026-10-28 08:41:17.348106	\N	\N	test_bursar	\N	\N	f	\N
165	orgadmin@ashevillehabitat.org	Demo Org Admin	(828) 555-0100	\N	t	\N	\N	$2y$10$U3mCXiH7nX3JcWj0rjKEuev1H6avH9lC8sJ.FDs9EmW6G1zETFTra	\N	\N	2026-08-19 10:47:01.046439	2026-08-19 11:07:59.451715	\N	\N	orgadmin	Demo	Org Admin	f	\N
152	applechipkitchen@gmail.com	April Chips	615-502-0384	\N	t	\N	\N	$2y$10$0Qn5VFKWkrt0B/Fotf5m8uPzSp7juAtUZCa73Wo7OE.2PKe9aq7jm	\N	\N	2026-07-31 03:00:17.095479	2026-09-03 21:46:48.513643	151	\N	aachips	April	Chips	f	\N
175	test-admin@archr.local	Test Administrator	\N	\N	t	2026-10-31 15:40:53.676062	\N	$2y$10$J7hIUMw76NIcamnMC0R7PeM9NOqYkm3fg0S6vCSbWskDulnJFBGF.	\N	\N	2026-10-28 08:41:17.352657	2026-10-28 08:41:17.352657	\N	\N	test_admin	\N	\N	f	\N
151	superadmin@archr.local	Super Administrator	\N	\N	t	2026-10-31 15:53:44.715634	\N	$2y$10$rQB2alZ1rdPe85Q9pxVbPO0U1s0UjOM2cnDXVsco6F7iZ7mvZVMe2	\N	\N	2026-07-25 16:17:01.762538	2026-09-23 07:48:16.65259	\N	\N	superadmin	Super	Administrator	t	{"help": true, "team": false, "funding": false, "metrics": false, "invoices": false, "messages": false, "projects": false, "schedule": false, "dashboard": true, "documents": true, "unclaimed": false, "workflows": false, "case-search": true, "escalations": false, "marketplace": false, "applications": true, "review-queue": true, "eligible-jobs": false, "reimbursements": false}
6	sarah.martinez@archr.org	Sarah Martinez	(828) 555-0123	\N	t	2026-09-08 09:18:45.417643	\N	$2y$10$mCjyRB2vwl6kNOnoJwd.Gu3z6hBAVlsxh0F/m9F4.cKLxdbWiuf4e	\N	\N	2026-06-12 08:59:24.970873	2026-09-08 09:17:06.793508	\N	\N	sarah.martinez	\N	\N	f	\N
101	james.thornton@archr.org	James Thornton	828-555-0202	\N	t	2026-09-10 09:06:09.343954	\N	$2y$10$AlTno7Pu/8LOlKLzFb95j.wRcChBP6BKrNs0iN6vUdJdohWh64haO	\N	\N	2026-07-02 19:16:39.600812	2026-09-10 09:06:02.943925	1	\N	james.thornton	\N	\N	f	\N
1	admin@archr.org	System Administrator	828-555-0100	\N	t	\N	\N	$2y$10$dummy.hash.placeholder.for.testing.only	\N	\N	2026-07-02 19:16:39.600812	2026-07-02 19:16:39.600812	\N	\N	admin	\N	\N	f	\N
112	contact@bluestoneelectric.com	Bluestone Electric	828-555-0901	\N	t	\N	\N	$2y$10$12345	\N	\N	2026-07-02 19:16:39.600812	2026-07-02 19:16:39.600812	1	\N	contact	\N	\N	f	\N
113	info@ashevilleroofing.com	Asheville Roofing Co.	828-555-0902	\N	t	\N	\N	$2y$10$12345	\N	\N	2026-07-02 19:16:39.600812	2026-07-02 19:16:39.600812	1	\N	info	\N	\N	f	\N
114	hello@mountainplumbing.com	Mountain Plumbing Services	828-555-0903	\N	t	\N	\N	$2y$10$12345	\N	\N	2026-07-02 19:16:39.600812	2026-07-02 19:16:39.600812	1	\N	hello	\N	\N	f	\N
177	test-crew-member@archr.local	Test Crew Member	\N	\N	t	2026-10-28 08:51:10.784909	\N	$2y$10$4sADnM/6//Ly8gKxM8Ufi.1Cshe8qVZ5lf4bjwi3quwCCe1Ite2wG	\N	\N	2026-10-28 08:44:06.983123	2026-10-28 08:44:06.983123	\N	\N	test_crew_member	\N	\N	f	\N
169	test-sub@archr.local	Test Subcontractor	\N	\N	t	2026-10-28 09:11:00.023797	\N	$2y$10$JaUB.CQfAoxI7MRYuI8ZreDlXtCj1mmnLVz/DAgtpjYEurcunCL5m	\N	\N	2026-10-28 07:42:38.634142	2026-10-28 07:42:38.634142	\N	\N	test_sub	\N	\N	f	\N
170	test-volunteer@archr.local	Test Volunteer	\N	\N	t	2026-10-28 09:11:01.418846	\N	$2y$10$JaUB.CQfAoxI7MRYuI8ZreDlXtCj1mmnLVz/DAgtpjYEurcunCL5m	\N	\N	2026-10-28 07:42:38.653257	2026-10-28 07:42:38.653257	\N	\N	test_volunteer	\N	\N	f	\N
178	test-crew-lead@archr.local	Test Crew Lead	\N	\N	t	2026-10-28 09:13:28.71623	\N	$2y$10$4sADnM/6//Ly8gKxM8Ufi.1Cshe8qVZ5lf4bjwi3quwCCe1Ite2wG	\N	\N	2026-10-28 08:44:07.039929	2026-10-28 08:44:07.039929	\N	\N	test_crew_lead	\N	\N	f	\N
179	test-project-manager@archr.local	Test Project Manager	\N	\N	t	2026-10-28 09:17:34.003734	\N	$2y$10$4sADnM/6//Ly8gKxM8Ufi.1Cshe8qVZ5lf4bjwi3quwCCe1Ite2wG	\N	\N	2026-10-28 08:44:07.048474	2026-10-28 08:44:07.048474	\N	\N	test_project_manager	\N	\N	f	\N
180	test-org-admin@archr.local	Test Organization Admin	\N	\N	t	2026-10-28 10:18:39.560475	\N	$2y$10$4sADnM/6//Ly8gKxM8Ufi.1Cshe8qVZ5lf4bjwi3quwCCe1Ite2wG	\N	\N	2026-10-28 08:44:07.060547	2026-10-28 08:44:07.060547	\N	\N	test_org_admin	\N	\N	f	\N
\.


--
-- Data for Name: task_status_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.task_status_history (id, task_id, from_status, to_status, changed_by, notes, changed_at) FROM stdin;
\.


--
-- Data for Name: user_role_assignments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_role_assignments (id, user_id, organization_id, role_id, assigned_by, assigned_at, expires_at, is_active, notes) FROM stdin;
6	6	13	4	\N	2026-06-12 08:59:24.970873	\N	t	\N
19	112	\N	7	1	2026-07-02 19:16:39.600812	\N	t	\N
20	113	\N	7	1	2026-07-02 19:16:39.600812	\N	t	\N
21	114	\N	7	1	2026-07-02 19:16:39.600812	\N	t	\N
58	151	13	40	151	2026-07-25 16:17:01.762538	\N	t	\N
72	165	13	36	\N	2026-08-19 10:47:01.046439	\N	t	\N
74	167	70	40	151	2026-08-19 19:06:09.652657	\N	t	\N
75	169	13	7	151	2026-10-28 07:42:38.647318	\N	t	\N
76	170	13	11	151	2026-10-28 07:42:38.655122	\N	t	\N
77	171	13	10	151	2026-10-28 08:41:17.323244	\N	t	\N
78	172	13	5	151	2026-10-28 08:41:17.335902	\N	t	\N
79	173	13	8	151	2026-10-28 08:41:17.344077	\N	t	\N
80	174	13	3	151	2026-10-28 08:41:17.349486	\N	t	\N
81	175	13	1	151	2026-10-28 08:41:17.354699	\N	t	\N
82	176	13	4	151	2026-10-28 08:41:17.360322	\N	t	\N
83	177	13	9	151	2026-10-28 08:44:07.0086	\N	t	\N
84	178	13	6	151	2026-10-28 08:44:07.042439	\N	t	\N
85	179	13	2	151	2026-10-28 08:44:07.051479	\N	t	\N
86	180	13	36	151	2026-10-28 08:44:07.074725	\N	t	\N
\.


--
-- Data for Name: volunteer_badges; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.volunteer_badges (id, volunteer_id, badge_id, awarded_at, awarded_by) FROM stdin;
\.


--
-- Data for Name: volunteer_content; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.volunteer_content (id, content_id, title, content, content_html, yaml_frontmatter, content_type, tags, author_id, author_name, reviewed_by, reviewed_at, view_count, like_count, comment_count, read_xp_reward, status, published_at, pinned_until, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: volunteer_feedback; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.volunteer_feedback (id, quest_id, volunteer_id, beneficiary_id, quality_rating, timeliness_rating, professionalism_rating, comments, would_recommend, photo_urls, created_at, reputation_delta) FROM stdin;
\.


--
-- Data for Name: volunteer_hours; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.volunteer_hours (id, user_id, work_order_id, date, hours, task_description, verified_by, verified_at, created_at) FROM stdin;
\.


--
-- Data for Name: volunteer_profiles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.volunteer_profiles (id, user_id, level, xp, xp_to_next_level, reputation_score, reputation_tier, total_quests_completed, total_hours_logged, consecutive_weeks_active, last_active_at, push_notifications_enabled, email_digest_enabled, weekly_quest_limit, avatar_choice, title_equipped, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: volunteer_skills; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.volunteer_skills (id, volunteer_id, skill_id, proficiency_level, endorsed_by, endorsed_at, created_at) FROM stdin;
\.


--
-- Data for Name: weekly_digests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.weekly_digests (id, digest_week, title, summary, featured_content_ids, sent_at, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: work_orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.work_orders (id, case_id, work_order_number, project_manager_id, crew_lead_id, scheduled_start_date, scheduled_end_date, actual_start_date, actual_end_date, status, approved_budget, current_cost, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: work_tasks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.work_tasks (id, work_order_id, assigned_to_id, task_type, description, repair_category_id, estimate_id, status, priority, estimated_hours, actual_hours, due_date, completed_at, instructions, completion_notes, created_at, updated_at, created_by, job_code, todo_list, suggested_at, claimed_at, accepted_at, estimate_date, work_start_date, work_finish_date) FROM stdin;
\.


--
-- Name: activity_detail_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.activity_detail_id_seq', 26, true);


--
-- Name: activity_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.activity_log_id_seq', 23, true);


--
-- Name: application_anchor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.application_anchor_id_seq', 60, true);


--
-- Name: application_assignments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.application_assignments_id_seq', 1, true);


--
-- Name: applications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.applications_id_seq', 54, true);


--
-- Name: assessment_documents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.assessment_documents_id_seq', 1, false);


--
-- Name: assessment_notes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.assessment_notes_id_seq', 1, false);


--
-- Name: assessment_tasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.assessment_tasks_id_seq', 1, false);


--
-- Name: assessments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.assessments_id_seq', 2, true);


--
-- Name: assignment_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.assignment_log_id_seq', 1, true);


--
-- Name: audit_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.audit_log_id_seq', 1, true);


--
-- Name: badges_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.badges_id_seq', 5, true);


--
-- Name: beneficiary_feedback_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.beneficiary_feedback_id_seq', 1, false);


--
-- Name: blocked_ips_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.blocked_ips_id_seq', 1, false);


--
-- Name: case_communications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.case_communications_id_seq', 1, false);


--
-- Name: case_documents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.case_documents_id_seq', 1, false);


--
-- Name: case_funding_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.case_funding_id_seq', 1, false);


--
-- Name: case_repair_claims_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.case_repair_claims_id_seq', 13, true);


--
-- Name: case_status_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.case_status_history_id_seq', 7, true);


--
-- Name: case_statuses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.case_statuses_id_seq', 12, true);


--
-- Name: case_withdrawals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.case_withdrawals_id_seq', 1, false);


--
-- Name: cases_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cases_id_seq', 56, true);


--
-- Name: coalition_organizations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.coalition_organizations_id_seq', 75, true);


--
-- Name: contact_methods_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.contact_methods_id_seq', 4, true);


--
-- Name: content_reads_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.content_reads_id_seq', 1, false);


--
-- Name: crew_completion_documents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.crew_completion_documents_id_seq', 1, false);


--
-- Name: crew_daily_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.crew_daily_logs_id_seq', 1, false);


--
-- Name: crew_incident_reports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.crew_incident_reports_id_seq', 1, false);


--
-- Name: crew_job_cards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.crew_job_cards_id_seq', 1, false);


--
-- Name: crew_job_phases_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.crew_job_phases_id_seq', 37, true);


--
-- Name: crew_volunteer_signin_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.crew_volunteer_signin_id_seq', 1, false);


--
-- Name: criteria_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.criteria_types_id_seq', 21, true);


--
-- Name: document_access_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.document_access_log_id_seq', 1, false);


--
-- Name: document_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.document_categories_id_seq', 18, true);


--
-- Name: document_generation_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.document_generation_jobs_id_seq', 1, false);


--
-- Name: document_share_links_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.document_share_links_id_seq', 1, false);


--
-- Name: document_statuses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.document_statuses_id_seq', 7, true);


--
-- Name: document_templates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.document_templates_id_seq', 1, false);


--
-- Name: document_verifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.document_verifications_id_seq', 1, false);


--
-- Name: edit_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.edit_requests_id_seq', 1, false);


--
-- Name: eligibility_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.eligibility_results_id_seq', 560, true);


--
-- Name: email_queue_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.email_queue_id_seq', 1, false);


--
-- Name: fifo_sequence; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.fifo_sequence', 287, true);


--
-- Name: funding_sources_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.funding_sources_id_seq', 1, false);


--
-- Name: guest_access_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.guest_access_tokens_id_seq', 1, false);


--
-- Name: help_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.help_categories_id_seq', 10, true);


--
-- Name: help_document_attachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.help_document_attachments_id_seq', 1, false);


--
-- Name: help_document_feedback_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.help_document_feedback_id_seq', 1, false);


--
-- Name: help_document_reviews_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.help_document_reviews_id_seq', 1, false);


--
-- Name: help_document_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.help_document_types_id_seq', 10, true);


--
-- Name: help_document_versions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.help_document_versions_id_seq', 1, false);


--
-- Name: help_documents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.help_documents_id_seq', 1, false);


--
-- Name: help_search_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.help_search_log_id_seq', 1, false);


--
-- Name: help_user_progress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.help_user_progress_id_seq', 1, false);


--
-- Name: household_attributes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.household_attributes_id_seq', 6, true);


--
-- Name: income_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.income_records_id_seq', 12, true);


--
-- Name: intake_submissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.intake_submissions_id_seq', 60, true);


--
-- Name: invoice_line_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.invoice_line_items_id_seq', 1, false);


--
-- Name: invoices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.invoices_id_seq', 1, false);


--
-- Name: login_attempts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.login_attempts_id_seq', 3, true);


--
-- Name: material_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.material_requests_id_seq', 1, false);


--
-- Name: materials_inventory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.materials_inventory_id_seq', 1, false);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.notifications_id_seq', 65, true);


--
-- Name: organization_eligibility_rules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.organization_eligibility_rules_id_seq', 12, true);


--
-- Name: organization_metrics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.organization_metrics_id_seq', 1, false);


--
-- Name: organization_users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.organization_users_id_seq', 1, false);


--
-- Name: permission_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.permission_categories_id_seq', 26, true);


--
-- Name: permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.permissions_id_seq', 142, true);


--
-- Name: progress_events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.progress_events_id_seq', 24, true);


--
-- Name: project_assignments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.project_assignments_id_seq', 1, false);


--
-- Name: project_escalations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.project_escalations_id_seq', 1, false);


--
-- Name: project_milestones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.project_milestones_id_seq', 1, false);


--
-- Name: project_snapshots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.project_snapshots_id_seq', 1, false);


--
-- Name: property_assessments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.property_assessments_id_seq', 1, false);


--
-- Name: quest_assignments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.quest_assignments_id_seq', 1, false);


--
-- Name: reimbursement_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.reimbursement_requests_id_seq', 1, false);


--
-- Name: repair_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.repair_categories_id_seq', 10, true);


--
-- Name: repair_category_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.repair_category_details_id_seq', 1, false);


--
-- Name: repair_estimates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.repair_estimates_id_seq', 1, false);


--
-- Name: repair_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.repair_requests_id_seq', 77, true);


--
-- Name: review_queue_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.review_queue_id_seq', 56, true);


--
-- Name: role_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.role_permissions_id_seq', 187, true);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.roles_id_seq', 42, true);


--
-- Name: scope_of_work_line_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.scope_of_work_line_items_id_seq', 1, false);


--
-- Name: site_photos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.site_photos_id_seq', 1, false);


--
-- Name: skills_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.skills_id_seq', 8, true);


--
-- Name: storage_providers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.storage_providers_id_seq', 1, true);


--
-- Name: subcontractor_communications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.subcontractor_communications_id_seq', 1, false);


--
-- Name: subcontractor_invoices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.subcontractor_invoices_id_seq', 1, false);


--
-- Name: subcontractor_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.subcontractor_profiles_id_seq', 1, false);


--
-- Name: subcontractor_quotes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.subcontractor_quotes_id_seq', 1, false);


--
-- Name: support_tickets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.support_tickets_id_seq', 3, true);


--
-- Name: system_users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.system_users_id_seq', 180, true);


--
-- Name: task_status_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.task_status_history_id_seq', 1, false);


--
-- Name: user_role_assignments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_role_assignments_id_seq', 86, true);


--
-- Name: volunteer_badges_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.volunteer_badges_id_seq', 1, false);


--
-- Name: volunteer_content_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.volunteer_content_id_seq', 1, false);


--
-- Name: volunteer_feedback_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.volunteer_feedback_id_seq', 1, false);


--
-- Name: volunteer_hours_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.volunteer_hours_id_seq', 1, false);


--
-- Name: volunteer_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.volunteer_profiles_id_seq', 1, false);


--
-- Name: volunteer_skills_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.volunteer_skills_id_seq', 1, false);


--
-- Name: weekly_digests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.weekly_digests_id_seq', 1, false);


--
-- Name: work_orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.work_orders_id_seq', 1, false);


--
-- Name: work_tasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.work_tasks_id_seq', 1, false);


--
-- Name: activity_detail activity_detail_event_guid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_detail
    ADD CONSTRAINT activity_detail_event_guid_key UNIQUE (event_guid);


--
-- Name: activity_detail activity_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_detail
    ADD CONSTRAINT activity_detail_pkey PRIMARY KEY (id);


--
-- Name: activity_log activity_log_event_guid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_event_guid_key UNIQUE (event_guid);


--
-- Name: activity_log activity_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_pkey PRIMARY KEY (id);


--
-- Name: application_anchor application_anchor_anchor_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_anchor
    ADD CONSTRAINT application_anchor_anchor_id_key UNIQUE (anchor_id);


--
-- Name: application_anchor application_anchor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_anchor
    ADD CONSTRAINT application_anchor_pkey PRIMARY KEY (id);


--
-- Name: application_anchor application_anchor_submission_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_anchor
    ADD CONSTRAINT application_anchor_submission_id_key UNIQUE (submission_id);


--
-- Name: application_assignments application_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_assignments
    ADD CONSTRAINT application_assignments_pkey PRIMARY KEY (id);


--
-- Name: application_assignments application_assignments_submission_id_organization_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_assignments
    ADD CONSTRAINT application_assignments_submission_id_organization_id_key UNIQUE (submission_id, organization_id);


--
-- Name: applications applications_application_guid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_application_guid_key UNIQUE (application_guid);


--
-- Name: applications applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_pkey PRIMARY KEY (id);


--
-- Name: applications applications_placecode_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_placecode_key UNIQUE (placecode);


--
-- Name: assessment_documents assessment_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_documents
    ADD CONSTRAINT assessment_documents_pkey PRIMARY KEY (id);


--
-- Name: assessment_notes assessment_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_notes
    ADD CONSTRAINT assessment_notes_pkey PRIMARY KEY (id);


--
-- Name: assessment_tasks assessment_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_tasks
    ADD CONSTRAINT assessment_tasks_pkey PRIMARY KEY (id);


--
-- Name: assessments assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_pkey PRIMARY KEY (id);


--
-- Name: assignment_log assignment_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignment_log
    ADD CONSTRAINT assignment_log_pkey PRIMARY KEY (id);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--
-- Name: badges badges_badge_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.badges
    ADD CONSTRAINT badges_badge_code_key UNIQUE (badge_code);


--
-- Name: badges badges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.badges
    ADD CONSTRAINT badges_pkey PRIMARY KEY (id);


--
-- Name: beneficiary_feedback beneficiary_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.beneficiary_feedback
    ADD CONSTRAINT beneficiary_feedback_pkey PRIMARY KEY (id);


--
-- Name: blocked_ips blocked_ips_ip_address_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocked_ips
    ADD CONSTRAINT blocked_ips_ip_address_key UNIQUE (ip_address);


--
-- Name: blocked_ips blocked_ips_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocked_ips
    ADD CONSTRAINT blocked_ips_pkey PRIMARY KEY (id);


--
-- Name: case_claims case_claims_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_claims
    ADD CONSTRAINT case_claims_pkey PRIMARY KEY (case_id);


--
-- Name: case_communications case_communications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_communications
    ADD CONSTRAINT case_communications_pkey PRIMARY KEY (id);


--
-- Name: case_documents case_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_documents
    ADD CONSTRAINT case_documents_pkey PRIMARY KEY (id);


--
-- Name: case_funding case_funding_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_funding
    ADD CONSTRAINT case_funding_pkey PRIMARY KEY (id);


--
-- Name: case_repair_claims case_repair_claims_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_repair_claims
    ADD CONSTRAINT case_repair_claims_pkey PRIMARY KEY (id);


--
-- Name: case_status_history case_status_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_status_history
    ADD CONSTRAINT case_status_history_pkey PRIMARY KEY (id);


--
-- Name: case_statuses case_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_statuses
    ADD CONSTRAINT case_statuses_pkey PRIMARY KEY (id);


--
-- Name: case_statuses case_statuses_status_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_statuses
    ADD CONSTRAINT case_statuses_status_code_key UNIQUE (status_code);


--
-- Name: case_withdrawals case_withdrawals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_withdrawals
    ADD CONSTRAINT case_withdrawals_pkey PRIMARY KEY (id);


--
-- Name: cases cases_case_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cases
    ADD CONSTRAINT cases_case_number_key UNIQUE (case_number);


--
-- Name: cases cases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cases
    ADD CONSTRAINT cases_pkey PRIMARY KEY (id);


--
-- Name: coalition_organizations coalition_organizations_organization_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coalition_organizations
    ADD CONSTRAINT coalition_organizations_organization_code_key UNIQUE (organization_code);


--
-- Name: coalition_organizations coalition_organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coalition_organizations
    ADD CONSTRAINT coalition_organizations_pkey PRIMARY KEY (id);


--
-- Name: contact_methods contact_methods_method_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contact_methods
    ADD CONSTRAINT contact_methods_method_code_key UNIQUE (method_code);


--
-- Name: contact_methods contact_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contact_methods
    ADD CONSTRAINT contact_methods_pkey PRIMARY KEY (id);


--
-- Name: content_reads content_reads_content_id_volunteer_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_reads
    ADD CONSTRAINT content_reads_content_id_volunteer_id_key UNIQUE (content_id, volunteer_id);


--
-- Name: content_reads content_reads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_reads
    ADD CONSTRAINT content_reads_pkey PRIMARY KEY (id);


--
-- Name: crew_completion_documents crew_completion_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_completion_documents
    ADD CONSTRAINT crew_completion_documents_pkey PRIMARY KEY (id);


--
-- Name: crew_daily_logs crew_daily_logs_job_id_log_date_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_daily_logs
    ADD CONSTRAINT crew_daily_logs_job_id_log_date_key UNIQUE (job_id, log_date);


--
-- Name: crew_daily_logs crew_daily_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_daily_logs
    ADD CONSTRAINT crew_daily_logs_pkey PRIMARY KEY (id);


--
-- Name: crew_incident_reports crew_incident_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_incident_reports
    ADD CONSTRAINT crew_incident_reports_pkey PRIMARY KEY (id);


--
-- Name: crew_job_cards crew_job_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_job_cards
    ADD CONSTRAINT crew_job_cards_pkey PRIMARY KEY (id);


--
-- Name: crew_job_phases crew_job_phases_phase_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_job_phases
    ADD CONSTRAINT crew_job_phases_phase_code_key UNIQUE (phase_code);


--
-- Name: crew_job_phases crew_job_phases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_job_phases
    ADD CONSTRAINT crew_job_phases_pkey PRIMARY KEY (id);


--
-- Name: crew_volunteer_signin crew_volunteer_signin_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_volunteer_signin
    ADD CONSTRAINT crew_volunteer_signin_pkey PRIMARY KEY (id);


--
-- Name: criteria_types criteria_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.criteria_types
    ADD CONSTRAINT criteria_types_pkey PRIMARY KEY (id);


--
-- Name: criteria_types criteria_types_type_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.criteria_types
    ADD CONSTRAINT criteria_types_type_code_key UNIQUE (type_code);


--
-- Name: document_access_log document_access_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_access_log
    ADD CONSTRAINT document_access_log_pkey PRIMARY KEY (id);


--
-- Name: document_categories document_categories_category_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_categories
    ADD CONSTRAINT document_categories_category_code_key UNIQUE (category_code);


--
-- Name: document_categories document_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_categories
    ADD CONSTRAINT document_categories_pkey PRIMARY KEY (id);


--
-- Name: document_generation_jobs document_generation_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_generation_jobs
    ADD CONSTRAINT document_generation_jobs_pkey PRIMARY KEY (id);


--
-- Name: document_share_links document_share_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_share_links
    ADD CONSTRAINT document_share_links_pkey PRIMARY KEY (id);


--
-- Name: document_share_links document_share_links_share_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_share_links
    ADD CONSTRAINT document_share_links_share_token_key UNIQUE (share_token);


--
-- Name: document_statuses document_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_statuses
    ADD CONSTRAINT document_statuses_pkey PRIMARY KEY (id);


--
-- Name: document_statuses document_statuses_status_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_statuses
    ADD CONSTRAINT document_statuses_status_code_key UNIQUE (status_code);


--
-- Name: document_templates document_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_templates
    ADD CONSTRAINT document_templates_pkey PRIMARY KEY (id);


--
-- Name: document_templates document_templates_template_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_templates
    ADD CONSTRAINT document_templates_template_code_key UNIQUE (template_code);


--
-- Name: document_verifications document_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_verifications
    ADD CONSTRAINT document_verifications_pkey PRIMARY KEY (id);


--
-- Name: edit_requests edit_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.edit_requests
    ADD CONSTRAINT edit_requests_pkey PRIMARY KEY (id);


--
-- Name: eligibility_results eligibility_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eligibility_results
    ADD CONSTRAINT eligibility_results_pkey PRIMARY KEY (id);


--
-- Name: eligibility_results eligibility_results_submission_id_organization_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eligibility_results
    ADD CONSTRAINT eligibility_results_submission_id_organization_id_key UNIQUE (submission_id, organization_id);


--
-- Name: email_queue email_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_queue
    ADD CONSTRAINT email_queue_pkey PRIMARY KEY (id);


--
-- Name: funding_sources funding_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funding_sources
    ADD CONSTRAINT funding_sources_pkey PRIMARY KEY (id);


--
-- Name: guest_access_tokens guest_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_access_tokens
    ADD CONSTRAINT guest_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: guest_access_tokens guest_access_tokens_submission_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_access_tokens
    ADD CONSTRAINT guest_access_tokens_submission_id_key UNIQUE (submission_id);


--
-- Name: guest_access_tokens guest_access_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_access_tokens
    ADD CONSTRAINT guest_access_tokens_token_key UNIQUE (token);


--
-- Name: help_categories help_categories_category_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_categories
    ADD CONSTRAINT help_categories_category_code_key UNIQUE (category_code);


--
-- Name: help_categories help_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_categories
    ADD CONSTRAINT help_categories_pkey PRIMARY KEY (id);


--
-- Name: help_document_attachments help_document_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_document_attachments
    ADD CONSTRAINT help_document_attachments_pkey PRIMARY KEY (id);


--
-- Name: help_document_feedback help_document_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_document_feedback
    ADD CONSTRAINT help_document_feedback_pkey PRIMARY KEY (id);


--
-- Name: help_document_reviews help_document_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_document_reviews
    ADD CONSTRAINT help_document_reviews_pkey PRIMARY KEY (id);


--
-- Name: help_document_types help_document_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_document_types
    ADD CONSTRAINT help_document_types_pkey PRIMARY KEY (id);


--
-- Name: help_document_types help_document_types_type_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_document_types
    ADD CONSTRAINT help_document_types_type_code_key UNIQUE (type_code);


--
-- Name: help_document_versions help_document_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_document_versions
    ADD CONSTRAINT help_document_versions_pkey PRIMARY KEY (id);


--
-- Name: help_documents help_documents_document_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_documents
    ADD CONSTRAINT help_documents_document_id_key UNIQUE (document_id);


--
-- Name: help_documents help_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_documents
    ADD CONSTRAINT help_documents_pkey PRIMARY KEY (id);


--
-- Name: help_search_log help_search_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_search_log
    ADD CONSTRAINT help_search_log_pkey PRIMARY KEY (id);


--
-- Name: help_user_progress help_user_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_user_progress
    ADD CONSTRAINT help_user_progress_pkey PRIMARY KEY (id);


--
-- Name: help_user_progress help_user_progress_user_id_document_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_user_progress
    ADD CONSTRAINT help_user_progress_user_id_document_id_key UNIQUE (user_id, document_id);


--
-- Name: household_attributes household_attributes_attribute_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.household_attributes
    ADD CONSTRAINT household_attributes_attribute_name_key UNIQUE (attribute_name);


--
-- Name: household_attributes household_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.household_attributes
    ADD CONSTRAINT household_attributes_pkey PRIMARY KEY (id);


--
-- Name: income_records income_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.income_records
    ADD CONSTRAINT income_records_pkey PRIMARY KEY (id);


--
-- Name: intake_submissions intake_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intake_submissions
    ADD CONSTRAINT intake_submissions_pkey PRIMARY KEY (id);


--
-- Name: intake_submissions intake_submissions_submission_uuid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intake_submissions
    ADD CONSTRAINT intake_submissions_submission_uuid_key UNIQUE (submission_uuid);


--
-- Name: invoice_line_items invoice_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_line_items
    ADD CONSTRAINT invoice_line_items_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_invoice_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key UNIQUE (invoice_number);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: login_attempts login_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.login_attempts
    ADD CONSTRAINT login_attempts_pkey PRIMARY KEY (id);


--
-- Name: material_requests material_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.material_requests
    ADD CONSTRAINT material_requests_pkey PRIMARY KEY (id);


--
-- Name: materials_inventory materials_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.materials_inventory
    ADD CONSTRAINT materials_inventory_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: organization_eligibility_rules organization_eligibility_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_eligibility_rules
    ADD CONSTRAINT organization_eligibility_rules_pkey PRIMARY KEY (id);


--
-- Name: organization_metrics organization_metrics_organization_id_metric_date_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_metrics
    ADD CONSTRAINT organization_metrics_organization_id_metric_date_key UNIQUE (organization_id, metric_date);


--
-- Name: organization_metrics organization_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_metrics
    ADD CONSTRAINT organization_metrics_pkey PRIMARY KEY (id);


--
-- Name: organization_users organization_users_organization_id_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_users
    ADD CONSTRAINT organization_users_organization_id_email_key UNIQUE (organization_id, email);


--
-- Name: organization_users organization_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_users
    ADD CONSTRAINT organization_users_pkey PRIMARY KEY (id);


--
-- Name: permission_categories permission_categories_category_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permission_categories
    ADD CONSTRAINT permission_categories_category_code_key UNIQUE (category_code);


--
-- Name: permission_categories permission_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permission_categories
    ADD CONSTRAINT permission_categories_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_permission_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_permission_code_key UNIQUE (permission_code);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: progress_events progress_events_event_guid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.progress_events
    ADD CONSTRAINT progress_events_event_guid_key UNIQUE (event_guid);


--
-- Name: progress_events progress_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.progress_events
    ADD CONSTRAINT progress_events_pkey PRIMARY KEY (id);


--
-- Name: project_assignments project_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_assignments
    ADD CONSTRAINT project_assignments_pkey PRIMARY KEY (id);


--
-- Name: project_escalations project_escalations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_escalations
    ADD CONSTRAINT project_escalations_pkey PRIMARY KEY (id);


--
-- Name: project_milestones project_milestones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_milestones
    ADD CONSTRAINT project_milestones_pkey PRIMARY KEY (id);


--
-- Name: project_snapshots project_snapshots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_snapshots
    ADD CONSTRAINT project_snapshots_pkey PRIMARY KEY (id);


--
-- Name: project_snapshots project_snapshots_snapshot_date_case_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_snapshots
    ADD CONSTRAINT project_snapshots_snapshot_date_case_id_key UNIQUE (snapshot_date, case_id);


--
-- Name: property_assessments property_assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.property_assessments
    ADD CONSTRAINT property_assessments_pkey PRIMARY KEY (id);


--
-- Name: quest_assignments quest_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quest_assignments
    ADD CONSTRAINT quest_assignments_pkey PRIMARY KEY (id);


--
-- Name: quest_assignments quest_assignments_quest_id_volunteer_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quest_assignments
    ADD CONSTRAINT quest_assignments_quest_id_volunteer_id_key UNIQUE (quest_id, volunteer_id);


--
-- Name: quests quests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quests
    ADD CONSTRAINT quests_pkey PRIMARY KEY (id);


--
-- Name: quests quests_quest_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quests
    ADD CONSTRAINT quests_quest_number_key UNIQUE (quest_number);


--
-- Name: reimbursement_requests reimbursement_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reimbursement_requests
    ADD CONSTRAINT reimbursement_requests_pkey PRIMARY KEY (id);


--
-- Name: repair_categories repair_categories_category_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_categories
    ADD CONSTRAINT repair_categories_category_code_key UNIQUE (category_code);


--
-- Name: repair_categories repair_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_categories
    ADD CONSTRAINT repair_categories_pkey PRIMARY KEY (id);


--
-- Name: repair_category_details repair_category_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_category_details
    ADD CONSTRAINT repair_category_details_pkey PRIMARY KEY (id);


--
-- Name: repair_category_details repair_category_details_submission_id_category_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_category_details
    ADD CONSTRAINT repair_category_details_submission_id_category_id_key UNIQUE (submission_id, category_id);


--
-- Name: repair_estimates repair_estimates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_estimates
    ADD CONSTRAINT repair_estimates_pkey PRIMARY KEY (id);


--
-- Name: repair_requests repair_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_requests
    ADD CONSTRAINT repair_requests_pkey PRIMARY KEY (id);


--
-- Name: review_queue review_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_queue
    ADD CONSTRAINT review_queue_pkey PRIMARY KEY (id);


--
-- Name: review_queue review_queue_submission_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_queue
    ADD CONSTRAINT review_queue_submission_id_key UNIQUE (submission_id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_role_id_permission_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_role_id_permission_id_key UNIQUE (role_id, permission_id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: roles roles_role_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_role_code_key UNIQUE (role_code);


--
-- Name: scope_of_work_line_items scope_of_work_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scope_of_work_line_items
    ADD CONSTRAINT scope_of_work_line_items_pkey PRIMARY KEY (id);


--
-- Name: site_photos site_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_photos
    ADD CONSTRAINT site_photos_pkey PRIMARY KEY (id);


--
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (id);


--
-- Name: skills skills_skill_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_skill_code_key UNIQUE (skill_code);


--
-- Name: storage_providers storage_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storage_providers
    ADD CONSTRAINT storage_providers_pkey PRIMARY KEY (id);


--
-- Name: storage_providers storage_providers_provider_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storage_providers
    ADD CONSTRAINT storage_providers_provider_name_key UNIQUE (provider_name);


--
-- Name: subcontractor_communications subcontractor_communications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcontractor_communications
    ADD CONSTRAINT subcontractor_communications_pkey PRIMARY KEY (id);


--
-- Name: subcontractor_invoices subcontractor_invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcontractor_invoices
    ADD CONSTRAINT subcontractor_invoices_pkey PRIMARY KEY (id);


--
-- Name: subcontractor_profiles subcontractor_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcontractor_profiles
    ADD CONSTRAINT subcontractor_profiles_pkey PRIMARY KEY (id);


--
-- Name: subcontractor_profiles subcontractor_profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcontractor_profiles
    ADD CONSTRAINT subcontractor_profiles_user_id_key UNIQUE (user_id);


--
-- Name: subcontractor_quotes subcontractor_quotes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcontractor_quotes
    ADD CONSTRAINT subcontractor_quotes_pkey PRIMARY KEY (id);


--
-- Name: submission_contact_methods submission_contact_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_contact_methods
    ADD CONSTRAINT submission_contact_methods_pkey PRIMARY KEY (submission_id, method_id);


--
-- Name: submission_household_attributes submission_household_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_household_attributes
    ADD CONSTRAINT submission_household_attributes_pkey PRIMARY KEY (submission_id, attribute_id);


--
-- Name: submission_repair_categories submission_repair_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_repair_categories
    ADD CONSTRAINT submission_repair_categories_pkey PRIMARY KEY (submission_id, category_id);


--
-- Name: support_tickets support_tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.support_tickets
    ADD CONSTRAINT support_tickets_pkey PRIMARY KEY (id);


--
-- Name: system_users system_users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_users
    ADD CONSTRAINT system_users_email_key UNIQUE (email);


--
-- Name: system_users system_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_users
    ADD CONSTRAINT system_users_pkey PRIMARY KEY (id);


--
-- Name: system_users system_users_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_users
    ADD CONSTRAINT system_users_username_key UNIQUE (username);


--
-- Name: task_status_history task_status_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_status_history
    ADD CONSTRAINT task_status_history_pkey PRIMARY KEY (id);


--
-- Name: activity_detail uq_activity_detail_prev_hash; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_detail
    ADD CONSTRAINT uq_activity_detail_prev_hash UNIQUE (prev_hash);


--
-- Name: activity_log uq_activity_log_prev_hash; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT uq_activity_log_prev_hash UNIQUE (prev_hash);


--
-- Name: user_role_assignments user_role_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_role_assignments
    ADD CONSTRAINT user_role_assignments_pkey PRIMARY KEY (id);


--
-- Name: volunteer_badges volunteer_badges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_badges
    ADD CONSTRAINT volunteer_badges_pkey PRIMARY KEY (id);


--
-- Name: volunteer_badges volunteer_badges_volunteer_id_badge_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_badges
    ADD CONSTRAINT volunteer_badges_volunteer_id_badge_id_key UNIQUE (volunteer_id, badge_id);


--
-- Name: volunteer_content volunteer_content_content_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_content
    ADD CONSTRAINT volunteer_content_content_id_key UNIQUE (content_id);


--
-- Name: volunteer_content volunteer_content_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_content
    ADD CONSTRAINT volunteer_content_pkey PRIMARY KEY (id);


--
-- Name: volunteer_feedback volunteer_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_feedback
    ADD CONSTRAINT volunteer_feedback_pkey PRIMARY KEY (id);


--
-- Name: volunteer_feedback volunteer_feedback_quest_id_volunteer_id_beneficiary_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_feedback
    ADD CONSTRAINT volunteer_feedback_quest_id_volunteer_id_beneficiary_id_key UNIQUE (quest_id, volunteer_id, beneficiary_id);


--
-- Name: volunteer_hours volunteer_hours_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_hours
    ADD CONSTRAINT volunteer_hours_pkey PRIMARY KEY (id);


--
-- Name: volunteer_profiles volunteer_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_profiles
    ADD CONSTRAINT volunteer_profiles_pkey PRIMARY KEY (id);


--
-- Name: volunteer_profiles volunteer_profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_profiles
    ADD CONSTRAINT volunteer_profiles_user_id_key UNIQUE (user_id);


--
-- Name: volunteer_skills volunteer_skills_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_skills
    ADD CONSTRAINT volunteer_skills_pkey PRIMARY KEY (id);


--
-- Name: volunteer_skills volunteer_skills_volunteer_id_skill_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_skills
    ADD CONSTRAINT volunteer_skills_volunteer_id_skill_id_key UNIQUE (volunteer_id, skill_id);


--
-- Name: weekly_digests weekly_digests_digest_week_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weekly_digests
    ADD CONSTRAINT weekly_digests_digest_week_key UNIQUE (digest_week);


--
-- Name: weekly_digests weekly_digests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weekly_digests
    ADD CONSTRAINT weekly_digests_pkey PRIMARY KEY (id);


--
-- Name: work_orders work_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_pkey PRIMARY KEY (id);


--
-- Name: work_orders work_orders_work_order_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_work_order_number_key UNIQUE (work_order_number);


--
-- Name: work_tasks work_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_tasks
    ADD CONSTRAINT work_tasks_pkey PRIMARY KEY (id);


--
-- Name: idx_activity_detail_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_activity_detail_created ON public.activity_detail USING btree (created_at DESC);


--
-- Name: idx_activity_detail_expires; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_activity_detail_expires ON public.activity_detail USING btree (expires_at);


--
-- Name: idx_activity_detail_ledger; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_activity_detail_ledger ON public.activity_detail USING btree (ledger_id);


--
-- Name: idx_activity_detail_session; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_activity_detail_session ON public.activity_detail USING btree (session_id);


--
-- Name: idx_activity_log_action; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_activity_log_action ON public.activity_log USING btree (action);


--
-- Name: idx_activity_log_application; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_activity_log_application ON public.activity_log USING btree (application_id);


--
-- Name: idx_activity_log_case; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_activity_log_case ON public.activity_log USING btree (case_id);


--
-- Name: idx_activity_log_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_activity_log_category ON public.activity_log USING btree (category);


--
-- Name: idx_activity_log_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_activity_log_created ON public.activity_log USING btree (created_at DESC);


--
-- Name: idx_activity_log_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_activity_log_user ON public.activity_log USING btree (user_id);


--
-- Name: idx_applications_last_activity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_applications_last_activity ON public.applications USING btree (last_activity_at);


--
-- Name: idx_applications_placecode; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_applications_placecode ON public.applications USING btree (placecode);


--
-- Name: idx_applications_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_applications_status ON public.applications USING btree (status);


--
-- Name: idx_applications_zip; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_applications_zip ON public.applications USING btree (property_zip);


--
-- Name: idx_assessment_docs_assessment; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_assessment_docs_assessment ON public.assessment_documents USING btree (assessment_id);


--
-- Name: idx_assessments_application; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_assessments_application ON public.assessments USING btree (application_id);


--
-- Name: idx_assessments_assessor; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_assessments_assessor ON public.assessments USING btree (assessor_id);


--
-- Name: idx_assessments_claim_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_assessments_claim_number ON public.assessments USING btree (claim_number);


--
-- Name: idx_assessments_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_assessments_date ON public.assessments USING btree (scheduled_start);


--
-- Name: idx_assessments_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_assessments_org ON public.assessments USING btree (organization_id);


--
-- Name: idx_assessments_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_assessments_status ON public.assessments USING btree (status);


--
-- Name: idx_assignments_volunteer; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_assignments_volunteer ON public.quest_assignments USING btree (volunteer_id, status);


--
-- Name: idx_blocked_ips_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_blocked_ips_active ON public.blocked_ips USING btree (ip_address, is_active);


--
-- Name: idx_case_repair_claims_case; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_case_repair_claims_case ON public.case_repair_claims USING btree (case_id, released_at);


--
-- Name: idx_case_repair_claims_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_case_repair_claims_org ON public.case_repair_claims USING btree (organization_id, released_at);


--
-- Name: idx_case_withdrawals_case; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_case_withdrawals_case ON public.case_withdrawals USING btree (case_id, withdrawn_at DESC);


--
-- Name: idx_cases_application; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cases_application ON public.cases USING btree (application_id);


--
-- Name: idx_cases_claim_expires; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cases_claim_expires ON public.cases USING btree (claim_expires_at);


--
-- Name: idx_cases_last_progress; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cases_last_progress ON public.cases USING btree (last_progress_at);


--
-- Name: idx_cases_organization; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cases_organization ON public.cases USING btree (organization_id);


--
-- Name: idx_cases_unclaimed_app; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cases_unclaimed_app ON public.cases USING btree (application_id) WHERE (organization_id IS NULL);


--
-- Name: idx_comm_subcontractor; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comm_subcontractor ON public.subcontractor_communications USING btree (subcontractor_id, is_read);


--
-- Name: idx_comm_task; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comm_task ON public.subcontractor_communications USING btree (task_id);


--
-- Name: idx_completion_job; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_completion_job ON public.crew_completion_documents USING btree (job_id);


--
-- Name: idx_content_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_content_published ON public.volunteer_content USING btree (status, published_at DESC);


--
-- Name: idx_content_tags; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_content_tags ON public.volunteer_content USING gin (tags);


--
-- Name: idx_crew_jobs_current; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_crew_jobs_current ON public.crew_job_cards USING btree (is_current_job);


--
-- Name: idx_crew_jobs_lead; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_crew_jobs_lead ON public.crew_job_cards USING btree (crew_lead_id);


--
-- Name: idx_crew_jobs_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_crew_jobs_status ON public.crew_job_cards USING btree (job_status);


--
-- Name: idx_daily_logs_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_daily_logs_date ON public.crew_daily_logs USING btree (log_date DESC);


--
-- Name: idx_daily_logs_job; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_daily_logs_job ON public.crew_daily_logs USING btree (job_id);


--
-- Name: idx_eligibility_results_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_eligibility_results_org ON public.eligibility_results USING btree (organization_id, is_eligible);


--
-- Name: idx_eligibility_results_submission; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_eligibility_results_submission ON public.eligibility_results USING btree (submission_id, match_score DESC);


--
-- Name: idx_escalations_case; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_escalations_case ON public.project_escalations USING btree (case_id);


--
-- Name: idx_escalations_resolved; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_escalations_resolved ON public.project_escalations USING btree (resolved_at);


--
-- Name: idx_escalations_severity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_escalations_severity ON public.project_escalations USING btree (severity);


--
-- Name: idx_feedback_volunteer; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_feedback_volunteer ON public.beneficiary_feedback USING btree (volunteer_id, created_at DESC);


--
-- Name: idx_incident_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incident_date ON public.crew_incident_reports USING btree (incident_date DESC);


--
-- Name: idx_incident_job; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incident_job ON public.crew_incident_reports USING btree (job_id);


--
-- Name: idx_income_records_submission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_income_records_submission_id ON public.income_records USING btree (submission_id);


--
-- Name: idx_intake_submissions_deduplicated_into; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_intake_submissions_deduplicated_into ON public.intake_submissions USING btree (deduplicated_into);


--
-- Name: idx_intake_submissions_has_income; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_intake_submissions_has_income ON public.intake_submissions USING btree (has_income);


--
-- Name: idx_intake_submissions_helene_related; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_intake_submissions_helene_related ON public.intake_submissions USING btree (helene_related);


--
-- Name: idx_intake_submissions_placecode; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_intake_submissions_placecode ON public.intake_submissions USING btree (placecode);


--
-- Name: idx_intake_submissions_requestor_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_intake_submissions_requestor_user_id ON public.intake_submissions USING btree (requestor_user_id);


--
-- Name: idx_intake_submissions_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_intake_submissions_status ON public.intake_submissions USING btree (submission_status);


--
-- Name: idx_intake_submissions_submitted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_intake_submissions_submitted_at ON public.intake_submissions USING btree (submitted_at);


--
-- Name: idx_invoices_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_invoices_status ON public.subcontractor_invoices USING btree (status);


--
-- Name: idx_invoices_task; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_invoices_task ON public.subcontractor_invoices USING btree (task_id);


--
-- Name: idx_login_attempts_ip_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_login_attempts_ip_time ON public.login_attempts USING btree (ip_address, attempted_at);


--
-- Name: idx_match_scores_organization; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_match_scores_organization ON public.application_match_scores USING btree (organization_id);


--
-- Name: idx_match_scores_score; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_match_scores_score ON public.application_match_scores USING btree (match_score DESC);


--
-- Name: idx_match_scores_submission; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_match_scores_submission ON public.application_match_scores USING btree (submission_id);


--
-- Name: idx_materials_sow; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_materials_sow ON public.materials_inventory USING btree (sow_line_item_id);


--
-- Name: idx_milestones_case; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_milestones_case ON public.project_milestones USING btree (case_id);


--
-- Name: idx_milestones_complete; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_milestones_complete ON public.project_milestones USING btree (is_complete);


--
-- Name: idx_notifications_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notifications_user ON public.notifications USING btree (user_id, is_read, created_at DESC);


--
-- Name: idx_progress_events_case; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_progress_events_case ON public.progress_events USING btree (case_id);


--
-- Name: idx_progress_events_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_progress_events_org ON public.progress_events USING btree (organization_id);


--
-- Name: idx_progress_events_performed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_progress_events_performed ON public.progress_events USING btree (performed_at DESC);


--
-- Name: idx_progress_events_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_progress_events_type ON public.progress_events USING btree (event_type);


--
-- Name: idx_project_assignments_case; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_project_assignments_case ON public.project_assignments USING btree (case_id);


--
-- Name: idx_project_assignments_pm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_project_assignments_pm ON public.project_assignments USING btree (project_manager_id);


--
-- Name: idx_quests_location; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_quests_location ON public.quests USING btree (location_lat, location_lng);


--
-- Name: idx_quests_skills; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_quests_skills ON public.quests USING gin (required_skills);


--
-- Name: idx_quests_status_expires; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_quests_status_expires ON public.quests USING btree (status, expires_at);


--
-- Name: idx_queue_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_queue_order ON public.review_queue USING btree (fifo_order);


--
-- Name: idx_queue_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_queue_status ON public.review_queue USING btree (status, priority_score DESC);


--
-- Name: idx_quotes_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_quotes_status ON public.subcontractor_quotes USING btree (status);


--
-- Name: idx_quotes_task; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_quotes_task ON public.subcontractor_quotes USING btree (task_id);


--
-- Name: idx_reimbursement_case; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reimbursement_case ON public.reimbursement_requests USING btree (case_id);


--
-- Name: idx_reimbursement_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reimbursement_org ON public.reimbursement_requests USING btree (organization_id);


--
-- Name: idx_reimbursement_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reimbursement_status ON public.reimbursement_requests USING btree (status);


--
-- Name: idx_repair_category_details_submission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repair_category_details_submission_id ON public.repair_category_details USING btree (submission_id);


--
-- Name: idx_repair_requests_submission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repair_requests_submission_id ON public.repair_requests USING btree (submission_id);


--
-- Name: idx_site_photos_assessment; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_site_photos_assessment ON public.site_photos USING btree (assessment_id);


--
-- Name: idx_site_photos_repair_need; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_site_photos_repair_need ON public.site_photos USING btree (repair_need_id);


--
-- Name: idx_snapshots_case; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_snapshots_case ON public.project_snapshots USING btree (case_id);


--
-- Name: idx_snapshots_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_snapshots_date ON public.project_snapshots USING btree (snapshot_date);


--
-- Name: idx_sow_line_items_assessment; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sow_line_items_assessment ON public.scope_of_work_line_items USING btree (assessment_id);


--
-- Name: idx_sow_line_items_repair_need; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sow_line_items_repair_need ON public.scope_of_work_line_items USING btree (repair_need_id);


--
-- Name: idx_sow_line_items_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sow_line_items_status ON public.scope_of_work_line_items USING btree (status);


--
-- Name: idx_status_changed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_status_changed ON public.task_status_history USING btree (changed_at DESC);


--
-- Name: idx_status_task; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_status_task ON public.task_status_history USING btree (task_id);


--
-- Name: idx_subcontractor_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_subcontractor_active ON public.subcontractor_profiles USING btree (is_active, is_approved);


--
-- Name: idx_subcontractor_trade; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_subcontractor_trade ON public.subcontractor_profiles USING btree (trade_specialty);


--
-- Name: idx_system_users_username; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_system_users_username ON public.system_users USING btree (username);


--
-- Name: idx_user_role_null_org_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_user_role_null_org_unique ON public.user_role_assignments USING btree (user_id, role_id) WHERE (organization_id IS NULL);


--
-- Name: idx_user_role_org_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_user_role_org_unique ON public.user_role_assignments USING btree (user_id, role_id, organization_id) WHERE (organization_id IS NOT NULL);


--
-- Name: idx_verifications_case; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_verifications_case ON public.document_verifications USING btree (case_id);


--
-- Name: idx_verifications_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_verifications_status ON public.document_verifications USING btree (verification_status);


--
-- Name: idx_volunteer_signin_job; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_volunteer_signin_job ON public.crew_volunteer_signin USING btree (job_id);


--
-- Name: idx_volunteer_signin_volunteer; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_volunteer_signin_volunteer ON public.crew_volunteer_signin USING btree (volunteer_id);


--
-- Name: uq_case_repair_claims_active; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_case_repair_claims_active ON public.case_repair_claims USING btree (repair_request_id) WHERE (released_at IS NULL);


--
-- Name: uq_cases_app_org; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_cases_app_org ON public.cases USING btree (application_id, organization_id) WHERE (organization_id IS NOT NULL);


--
-- Name: case_funding_summary _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.case_funding_summary AS
 SELECT c.id AS case_id,
    c.case_number,
    c.submission_id,
    s.applicant_first_name,
    s.applicant_last_name,
    s.assigned_organization,
    COALESCE(sum(cf.allocated_amount), (0)::numeric) AS approved_amount,
    COALESCE(sum(cf.spent_amount), (0)::numeric) AS incurred_amount,
    COALESCE(sum(i.total_amount), (0)::numeric) AS reimbursed_amount,
    COALESCE(sum(i.total_amount), (0)::numeric) AS pending_reimbursement,
    (COALESCE(sum(cf.allocated_amount), (0)::numeric) - COALESCE(sum(i.total_amount), (0)::numeric)) AS outstanding_balance,
    (COALESCE(sum(cf.allocated_amount), (0)::numeric) - COALESCE(sum(cf.spent_amount), (0)::numeric)) AS remaining_available,
        CASE
            WHEN (COALESCE(sum(cf.allocated_amount), (0)::numeric) > (50000)::numeric) THEN 'EXCEEDS_CAP'::text
            WHEN (COALESCE(sum(cf.allocated_amount), (0)::numeric) = (50000)::numeric) THEN 'AT_CAP'::text
            ELSE 'UNDER_CAP'::text
        END AS cap_status,
        CASE
            WHEN (EXISTS ( SELECT 1
               FROM public.case_funding
              WHERE ((case_funding.case_id = c.id) AND ((case_funding.status)::text = 'on_hold'::text)))) THEN true
            ELSE false
        END AS has_hold_amount
   FROM (((public.cases c
     JOIN public.intake_submissions s ON ((c.submission_id = s.id)))
     LEFT JOIN public.case_funding cf ON ((c.id = cf.case_id)))
     LEFT JOIN public.invoices i ON (((c.id = i.case_id) AND ((i.status)::text = ANY ((ARRAY['pending'::character varying, 'approved'::character varying, 'paid'::character varying])::text[])))))
  GROUP BY c.id, c.case_number, s.applicant_first_name, s.applicant_last_name, s.assigned_organization;


--
-- Name: application_anchor trigger_anchor_id; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_anchor_id BEFORE INSERT ON public.application_anchor FOR EACH ROW EXECUTE FUNCTION public.generate_anchor_id();


--
-- Name: cases trigger_case_number; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_case_number BEFORE INSERT ON public.cases FOR EACH ROW EXECUTE FUNCTION public.generate_case_number();


--
-- Name: cases trigger_case_timestamp; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_case_timestamp BEFORE UPDATE ON public.cases FOR EACH ROW EXECUTE FUNCTION public.update_case_timestamp();


--
-- Name: help_documents trigger_help_doc_timestamp; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_help_doc_timestamp BEFORE UPDATE ON public.help_documents FOR EACH ROW EXECUTE FUNCTION public.update_help_doc_timestamp();


--
-- Name: intake_submissions trigger_new_submission; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_new_submission AFTER INSERT ON public.intake_submissions FOR EACH ROW EXECUTE FUNCTION public.on_new_submission();


--
-- Name: reimbursement_requests trigger_reimbursement_id; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_reimbursement_id BEFORE INSERT ON public.reimbursement_requests FOR EACH ROW EXECUTE FUNCTION public.generate_reimbursement_id();


--
-- Name: help_documents trigger_version_help_document; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_version_help_document BEFORE UPDATE ON public.help_documents FOR EACH ROW EXECUTE FUNCTION public.version_help_document();


--
-- Name: activity_detail activity_detail_application_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_detail
    ADD CONSTRAINT activity_detail_application_id_fkey FOREIGN KEY (application_id) REFERENCES public.applications(id);


--
-- Name: activity_detail activity_detail_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_detail
    ADD CONSTRAINT activity_detail_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.cases(id);


--
-- Name: activity_detail activity_detail_ledger_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_detail
    ADD CONSTRAINT activity_detail_ledger_id_fkey FOREIGN KEY (ledger_id) REFERENCES public.activity_log(id);


--
-- Name: activity_detail activity_detail_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_detail
    ADD CONSTRAINT activity_detail_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.system_users(id);


--
-- Name: activity_log activity_log_application_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_application_id_fkey FOREIGN KEY (application_id) REFERENCES public.applications(id);


--
-- Name: activity_log activity_log_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.cases(id);


--
-- Name: activity_log activity_log_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.coalition_organizations(id);


--
-- Name: activity_log activity_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.system_users(id);


--
-- Name: application_anchor application_anchor_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_anchor
    ADD CONSTRAINT application_anchor_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.intake_submissions(id);


--
-- Name: application_assignments application_assignments_claimed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_assignments
    ADD CONSTRAINT application_assignments_claimed_by_fkey FOREIGN KEY (claimed_by) REFERENCES public.organization_users(id);


--
-- Name: application_assignments application_assignments_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_assignments
    ADD CONSTRAINT application_assignments_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.coalition_organizations(id);


--
-- Name: application_assignments application_assignments_rejected_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_assignments
    ADD CONSTRAINT application_assignments_rejected_by_fkey FOREIGN KEY (rejected_by) REFERENCES public.organization_users(id);


--
-- Name: application_assignments application_assignments_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_assignments
    ADD CONSTRAINT application_assignments_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.intake_submissions(id) ON DELETE CASCADE;


--
-- Name: applications applications_consolidated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_consolidated_by_fkey FOREIGN KEY (consolidated_by) REFERENCES public.system_users(id);


--
-- Name: assessment_documents assessment_documents_assessment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_documents
    ADD CONSTRAINT assessment_documents_assessment_id_fkey FOREIGN KEY (assessment_id) REFERENCES public.assessments(id) ON DELETE CASCADE;


--
-- Name: assessment_documents assessment_documents_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_documents
    ADD CONSTRAINT assessment_documents_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.system_users(id);


--
-- Name: assessment_notes assessment_notes_assessment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_notes
    ADD CONSTRAINT assessment_notes_assessment_id_fkey FOREIGN KEY (assessment_id) REFERENCES public.assessments(id) ON DELETE CASCADE;


--
-- Name: assessment_notes assessment_notes_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_notes
    ADD CONSTRAINT assessment_notes_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.system_users(id);


--
-- Name: assessment_tasks assessment_tasks_assessment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_tasks
    ADD CONSTRAINT assessment_tasks_assessment_id_fkey FOREIGN KEY (assessment_id) REFERENCES public.assessments(id) ON DELETE CASCADE;


--
-- Name: assessment_tasks assessment_tasks_parent_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_tasks
    ADD CONSTRAINT assessment_tasks_parent_task_id_fkey FOREIGN KEY (parent_task_id) REFERENCES public.assessment_tasks(id);


--
-- Name: assessments assessments_assessor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_assessor_id_fkey FOREIGN KEY (assessor_id) REFERENCES public.system_users(id);


--
-- Name: assessments assessments_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.cases(id) ON DELETE CASCADE;


--
-- Name: assignment_log assignment_log_assignment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignment_log
    ADD CONSTRAINT assignment_log_assignment_id_fkey FOREIGN KEY (assignment_id) REFERENCES public.application_assignments(id) ON DELETE CASCADE;


--
-- Name: assignment_log assignment_log_performed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignment_log
    ADD CONSTRAINT assignment_log_performed_by_fkey FOREIGN KEY (performed_by) REFERENCES public.organization_users(id);


--
-- Name: audit_log audit_log_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.intake_submissions(id) ON DELETE CASCADE;


--
-- Name: beneficiary_feedback beneficiary_feedback_beneficiary_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.beneficiary_feedback
    ADD CONSTRAINT beneficiary_feedback_beneficiary_id_fkey FOREIGN KEY (beneficiary_id) REFERENCES public.intake_submissions(id);


--
-- Name: beneficiary_feedback beneficiary_feedback_quest_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.beneficiary_feedback
    ADD CONSTRAINT beneficiary_feedback_quest_id_fkey FOREIGN KEY (quest_id) REFERENCES public.quests(id);


--
-- Name: beneficiary_feedback beneficiary_feedback_volunteer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.beneficiary_feedback
    ADD CONSTRAINT beneficiary_feedback_volunteer_id_fkey FOREIGN KEY (volunteer_id) REFERENCES public.system_users(id);


--
-- Name: blocked_ips blocked_ips_blocked_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocked_ips
    ADD CONSTRAINT blocked_ips_blocked_by_fkey FOREIGN KEY (blocked_by) REFERENCES public.system_users(id);


--
-- Name: case_claims case_claims_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_claims
    ADD CONSTRAINT case_claims_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.cases(id);


--
-- Name: case_claims case_claims_claimed_by_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_claims
    ADD CONSTRAINT case_claims_claimed_by_org_id_fkey FOREIGN KEY (claimed_by_org_id) REFERENCES public.coalition_organizations(id);


--
-- Name: case_communications case_communications_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_communications
    ADD CONSTRAINT case_communications_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.cases(id) ON DELETE CASCADE;


--
-- Name: case_communications case_communications_from_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_communications
    ADD CONSTRAINT case_communications_from_user_id_fkey FOREIGN KEY (from_user_id) REFERENCES public.system_users(id);


--
-- Name: case_communications case_communications_to_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_communications
    ADD CONSTRAINT case_communications_to_user_id_fkey FOREIGN KEY (to_user_id) REFERENCES public.system_users(id);


--
-- Name: case_documents case_documents_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_documents
    ADD CONSTRAINT case_documents_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.cases(id) ON DELETE CASCADE;


--
-- Name: case_documents case_documents_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_documents
    ADD CONSTRAINT case_documents_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.document_categories(id);


--
-- Name: case_documents case_documents_parent_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_documents
    ADD CONSTRAINT case_documents_parent_document_id_fkey FOREIGN KEY (parent_document_id) REFERENCES public.case_documents(id);


--
-- Name: case_documents case_documents_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_documents
    ADD CONSTRAINT case_documents_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.document_statuses(id);


--
-- Name: case_documents case_documents_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_documents
    ADD CONSTRAINT case_documents_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.system_users(id);


--
-- Name: case_documents case_documents_verified_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_documents
    ADD CONSTRAINT case_documents_verified_by_fkey FOREIGN KEY (verified_by) REFERENCES public.system_users(id);


--
-- Name: case_funding case_funding_allocated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_funding
    ADD CONSTRAINT case_funding_allocated_by_fkey FOREIGN KEY (allocated_by) REFERENCES public.system_users(id);


--
-- Name: case_funding case_funding_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_funding
    ADD CONSTRAINT case_funding_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.cases(id) ON DELETE CASCADE;


--
-- Name: case_funding case_funding_funding_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_funding
    ADD CONSTRAINT case_funding_funding_source_id_fkey FOREIGN KEY (funding_source_id) REFERENCES public.funding_sources(id);


--
-- Name: case_repair_claims case_repair_claims_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_repair_claims
    ADD CONSTRAINT case_repair_claims_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.cases(id) ON DELETE CASCADE;


--
-- Name: case_repair_claims case_repair_claims_claimed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_repair_claims
    ADD CONSTRAINT case_repair_claims_claimed_by_fkey FOREIGN KEY (claimed_by) REFERENCES public.system_users(id);


--
-- Name: case_repair_claims case_repair_claims_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_repair_claims
    ADD CONSTRAINT case_repair_claims_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.coalition_organizations(id);


--
-- Name: case_repair_claims case_repair_claims_released_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_repair_claims
    ADD CONSTRAINT case_repair_claims_released_by_fkey FOREIGN KEY (released_by) REFERENCES public.system_users(id);


--
-- Name: case_repair_claims case_repair_claims_repair_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_repair_claims
    ADD CONSTRAINT case_repair_claims_repair_request_id_fkey FOREIGN KEY (repair_request_id) REFERENCES public.repair_requests(id) ON DELETE CASCADE;


--
-- Name: case_status_history case_status_history_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_status_history
    ADD CONSTRAINT case_status_history_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.cases(id) ON DELETE CASCADE;


--
-- Name: case_status_history case_status_history_changed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_status_history
    ADD CONSTRAINT case_status_history_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.system_users(id);


--
-- Name: case_status_history case_status_history_from_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_status_history
    ADD CONSTRAINT case_status_history_from_status_id_fkey FOREIGN KEY (from_status_id) REFERENCES public.case_statuses(id);


--
-- Name: case_status_history case_status_history_to_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_status_history
    ADD CONSTRAINT case_status_history_to_status_id_fkey FOREIGN KEY (to_status_id) REFERENCES public.case_statuses(id);


--
-- Name: case_withdrawals case_withdrawals_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_withdrawals
    ADD CONSTRAINT case_withdrawals_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.cases(id) ON DELETE CASCADE;


--
-- Name: case_withdrawals case_withdrawals_withdrawn_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_withdrawals
    ADD CONSTRAINT case_withdrawals_withdrawn_by_fkey FOREIGN KEY (withdrawn_by) REFERENCES public.system_users(id);


--
-- Name: cases cases_application_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cases
    ADD CONSTRAINT cases_application_id_fkey FOREIGN KEY (application_id) REFERENCES public.applications(id) ON DELETE CASCADE;


--
-- Name: cases cases_assigned_assessor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cases
    ADD CONSTRAINT cases_assigned_assessor_id_fkey FOREIGN KEY (assigned_assessor_id) REFERENCES public.system_users(id);


--
-- Name: cases cases_assigned_caseworker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cases
    ADD CONSTRAINT cases_assigned_caseworker_id_fkey FOREIGN KEY (assigned_caseworker_id) REFERENCES public.system_users(id);


--
-- Name: cases cases_assigned_project_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cases
    ADD CONSTRAINT cases_assigned_project_manager_id_fkey FOREIGN KEY (assigned_project_manager_id) REFERENCES public.system_users(id);


--
-- Name: cases cases_claimed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cases
    ADD CONSTRAINT cases_claimed_by_fkey FOREIGN KEY (claimed_by) REFERENCES public.system_users(id);


--
-- Name: cases cases_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cases
    ADD CONSTRAINT cases_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.system_users(id);


--
-- Name: cases cases_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cases
    ADD CONSTRAINT cases_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.coalition_organizations(id);


--
-- Name: cases cases_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cases
    ADD CONSTRAINT cases_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.case_statuses(id);


--
-- Name: cases cases_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cases
    ADD CONSTRAINT cases_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.intake_submissions(id) ON DELETE CASCADE;


--
-- Name: cases cases_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cases
    ADD CONSTRAINT cases_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.system_users(id);


--
-- Name: content_reads content_reads_content_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_reads
    ADD CONSTRAINT content_reads_content_id_fkey FOREIGN KEY (content_id) REFERENCES public.volunteer_content(id) ON DELETE CASCADE;


--
-- Name: content_reads content_reads_volunteer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_reads
    ADD CONSTRAINT content_reads_volunteer_id_fkey FOREIGN KEY (volunteer_id) REFERENCES public.system_users(id) ON DELETE CASCADE;


--
-- Name: crew_completion_documents crew_completion_documents_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_completion_documents
    ADD CONSTRAINT crew_completion_documents_job_id_fkey FOREIGN KEY (job_id) REFERENCES public.crew_job_cards(id) ON DELETE CASCADE;


--
-- Name: crew_completion_documents crew_completion_documents_verified_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_completion_documents
    ADD CONSTRAINT crew_completion_documents_verified_by_fkey FOREIGN KEY (verified_by) REFERENCES public.system_users(id);


--
-- Name: crew_daily_logs crew_daily_logs_crew_lead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_daily_logs
    ADD CONSTRAINT crew_daily_logs_crew_lead_id_fkey FOREIGN KEY (crew_lead_id) REFERENCES public.system_users(id);


--
-- Name: crew_daily_logs crew_daily_logs_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_daily_logs
    ADD CONSTRAINT crew_daily_logs_job_id_fkey FOREIGN KEY (job_id) REFERENCES public.crew_job_cards(id) ON DELETE CASCADE;


--
-- Name: crew_daily_logs crew_daily_logs_verified_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_daily_logs
    ADD CONSTRAINT crew_daily_logs_verified_by_fkey FOREIGN KEY (verified_by) REFERENCES public.system_users(id);


--
-- Name: crew_incident_reports crew_incident_reports_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_incident_reports
    ADD CONSTRAINT crew_incident_reports_job_id_fkey FOREIGN KEY (job_id) REFERENCES public.crew_job_cards(id) ON DELETE CASCADE;


--
-- Name: crew_incident_reports crew_incident_reports_reported_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_incident_reports
    ADD CONSTRAINT crew_incident_reports_reported_by_fkey FOREIGN KEY (reported_by) REFERENCES public.system_users(id);


--
-- Name: crew_incident_reports crew_incident_reports_resolved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_incident_reports
    ADD CONSTRAINT crew_incident_reports_resolved_by_fkey FOREIGN KEY (resolved_by) REFERENCES public.system_users(id);


--
-- Name: crew_job_cards crew_job_cards_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_job_cards
    ADD CONSTRAINT crew_job_cards_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.cases(id) ON DELETE CASCADE;


--
-- Name: crew_job_cards crew_job_cards_crew_lead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_job_cards
    ADD CONSTRAINT crew_job_cards_crew_lead_id_fkey FOREIGN KEY (crew_lead_id) REFERENCES public.system_users(id);


--
-- Name: crew_volunteer_signin crew_volunteer_signin_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_volunteer_signin
    ADD CONSTRAINT crew_volunteer_signin_job_id_fkey FOREIGN KEY (job_id) REFERENCES public.crew_job_cards(id) ON DELETE CASCADE;


--
-- Name: crew_volunteer_signin crew_volunteer_signin_verified_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_volunteer_signin
    ADD CONSTRAINT crew_volunteer_signin_verified_by_fkey FOREIGN KEY (verified_by) REFERENCES public.system_users(id);


--
-- Name: crew_volunteer_signin crew_volunteer_signin_volunteer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crew_volunteer_signin
    ADD CONSTRAINT crew_volunteer_signin_volunteer_id_fkey FOREIGN KEY (volunteer_id) REFERENCES public.system_users(id);


--
-- Name: document_access_log document_access_log_accessed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_access_log
    ADD CONSTRAINT document_access_log_accessed_by_fkey FOREIGN KEY (accessed_by) REFERENCES public.system_users(id);


--
-- Name: document_access_log document_access_log_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_access_log
    ADD CONSTRAINT document_access_log_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.case_documents(id) ON DELETE CASCADE;


--
-- Name: document_categories document_categories_parent_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_categories
    ADD CONSTRAINT document_categories_parent_category_id_fkey FOREIGN KEY (parent_category_id) REFERENCES public.document_categories(id);


--
-- Name: document_generation_jobs document_generation_jobs_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_generation_jobs
    ADD CONSTRAINT document_generation_jobs_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.cases(id);


--
-- Name: document_generation_jobs document_generation_jobs_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_generation_jobs
    ADD CONSTRAINT document_generation_jobs_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.system_users(id);


--
-- Name: document_generation_jobs document_generation_jobs_output_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_generation_jobs
    ADD CONSTRAINT document_generation_jobs_output_document_id_fkey FOREIGN KEY (output_document_id) REFERENCES public.case_documents(id);


--
-- Name: document_generation_jobs document_generation_jobs_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_generation_jobs
    ADD CONSTRAINT document_generation_jobs_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.document_templates(id);


--
-- Name: document_share_links document_share_links_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_share_links
    ADD CONSTRAINT document_share_links_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.case_documents(id) ON DELETE CASCADE;


--
-- Name: document_share_links document_share_links_shared_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_share_links
    ADD CONSTRAINT document_share_links_shared_by_fkey FOREIGN KEY (shared_by) REFERENCES public.system_users(id);


--
-- Name: document_templates document_templates_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_templates
    ADD CONSTRAINT document_templates_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.document_categories(id);


--
-- Name: document_verifications document_verifications_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_verifications
    ADD CONSTRAINT document_verifications_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.cases(id) ON DELETE CASCADE;


--
-- Name: document_verifications document_verifications_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_verifications
    ADD CONSTRAINT document_verifications_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.case_documents(id);


--
-- Name: document_verifications document_verifications_verified_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_verifications
    ADD CONSTRAINT document_verifications_verified_by_fkey FOREIGN KEY (verified_by) REFERENCES public.system_users(id);


--
-- Name: edit_requests edit_requests_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.edit_requests
    ADD CONSTRAINT edit_requests_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.cases(id);


--
-- Name: edit_requests edit_requests_requested_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.edit_requests
    ADD CONSTRAINT edit_requests_requested_by_fkey FOREIGN KEY (requested_by) REFERENCES public.system_users(id);


--
-- Name: edit_requests edit_requests_reviewed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.edit_requests
    ADD CONSTRAINT edit_requests_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES public.system_users(id);


--
-- Name: eligibility_results eligibility_results_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eligibility_results
    ADD CONSTRAINT eligibility_results_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.coalition_organizations(id) ON DELETE CASCADE;


--
-- Name: eligibility_results eligibility_results_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eligibility_results
    ADD CONSTRAINT eligibility_results_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.intake_submissions(id) ON DELETE CASCADE;


--
-- Name: funding_sources funding_sources_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funding_sources
    ADD CONSTRAINT funding_sources_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.coalition_organizations(id) ON DELETE CASCADE;


--
-- Name: guest_access_tokens guest_access_tokens_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_access_tokens
    ADD CONSTRAINT guest_access_tokens_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.intake_submissions(id);


--
-- Name: help_categories help_categories_parent_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_categories
    ADD CONSTRAINT help_categories_parent_category_id_fkey FOREIGN KEY (parent_category_id) REFERENCES public.help_categories(id);


--
-- Name: help_document_attachments help_document_attachments_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_document_attachments
    ADD CONSTRAINT help_document_attachments_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.help_documents(id) ON DELETE CASCADE;


--
-- Name: help_document_attachments help_document_attachments_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_document_attachments
    ADD CONSTRAINT help_document_attachments_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.system_users(id);


--
-- Name: help_document_feedback help_document_feedback_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_document_feedback
    ADD CONSTRAINT help_document_feedback_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.help_documents(id) ON DELETE CASCADE;


--
-- Name: help_document_feedback help_document_feedback_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_document_feedback
    ADD CONSTRAINT help_document_feedback_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.system_users(id);


--
-- Name: help_document_reviews help_document_reviews_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_document_reviews
    ADD CONSTRAINT help_document_reviews_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.help_documents(id) ON DELETE CASCADE;


--
-- Name: help_document_reviews help_document_reviews_reviewer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_document_reviews
    ADD CONSTRAINT help_document_reviews_reviewer_id_fkey FOREIGN KEY (reviewer_id) REFERENCES public.system_users(id);


--
-- Name: help_document_versions help_document_versions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_document_versions
    ADD CONSTRAINT help_document_versions_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.system_users(id);


--
-- Name: help_document_versions help_document_versions_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_document_versions
    ADD CONSTRAINT help_document_versions_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.help_documents(id) ON DELETE CASCADE;


--
-- Name: help_documents help_documents_archived_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_documents
    ADD CONSTRAINT help_documents_archived_by_fkey FOREIGN KEY (archived_by) REFERENCES public.system_users(id);


--
-- Name: help_documents help_documents_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_documents
    ADD CONSTRAINT help_documents_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.help_categories(id);


--
-- Name: help_documents help_documents_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_documents
    ADD CONSTRAINT help_documents_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.system_users(id);


--
-- Name: help_documents help_documents_doc_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_documents
    ADD CONSTRAINT help_documents_doc_type_id_fkey FOREIGN KEY (doc_type_id) REFERENCES public.help_document_types(id);


--
-- Name: help_documents help_documents_original_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_documents
    ADD CONSTRAINT help_documents_original_document_id_fkey FOREIGN KEY (original_document_id) REFERENCES public.help_documents(id);


--
-- Name: help_documents help_documents_owner_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_documents
    ADD CONSTRAINT help_documents_owner_role_id_fkey FOREIGN KEY (owner_role_id) REFERENCES public.roles(id);


--
-- Name: help_documents help_documents_previous_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_documents
    ADD CONSTRAINT help_documents_previous_version_id_fkey FOREIGN KEY (previous_version_id) REFERENCES public.help_documents(id);


--
-- Name: help_documents help_documents_reviewed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_documents
    ADD CONSTRAINT help_documents_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES public.system_users(id);


--
-- Name: help_documents help_documents_reviewer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_documents
    ADD CONSTRAINT help_documents_reviewer_id_fkey FOREIGN KEY (reviewer_id) REFERENCES public.system_users(id);


--
-- Name: help_documents help_documents_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_documents
    ADD CONSTRAINT help_documents_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.system_users(id);


--
-- Name: help_search_log help_search_log_clicked_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_search_log
    ADD CONSTRAINT help_search_log_clicked_document_id_fkey FOREIGN KEY (clicked_document_id) REFERENCES public.help_documents(id);


--
-- Name: help_search_log help_search_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_search_log
    ADD CONSTRAINT help_search_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.system_users(id);


--
-- Name: help_user_progress help_user_progress_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_user_progress
    ADD CONSTRAINT help_user_progress_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.help_documents(id) ON DELETE CASCADE;


--
-- Name: help_user_progress help_user_progress_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_user_progress
    ADD CONSTRAINT help_user_progress_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.system_users(id) ON DELETE CASCADE;


--
-- Name: income_records income_records_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.income_records
    ADD CONSTRAINT income_records_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.intake_submissions(id) ON DELETE CASCADE;


--
-- Name: intake_submissions intake_submissions_deduplicated_into_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intake_submissions
    ADD CONSTRAINT intake_submissions_deduplicated_into_fkey FOREIGN KEY (deduplicated_into) REFERENCES public.applications(id) ON DELETE SET NULL;


--
-- Name: intake_submissions intake_submissions_requestor_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intake_submissions
    ADD CONSTRAINT intake_submissions_requestor_user_id_fkey FOREIGN KEY (requestor_user_id) REFERENCES public.system_users(id) ON DELETE SET NULL;


--
-- Name: invoice_line_items invoice_line_items_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_line_items
    ADD CONSTRAINT invoice_line_items_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id) ON DELETE CASCADE;


--
-- Name: invoice_line_items invoice_line_items_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_line_items
    ADD CONSTRAINT invoice_line_items_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.work_tasks(id);


--
-- Name: invoices invoices_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.system_users(id);


--
-- Name: invoices invoices_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.cases(id) ON DELETE CASCADE;


--
-- Name: invoices invoices_paid_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_paid_by_fkey FOREIGN KEY (paid_by) REFERENCES public.system_users(id);


--
-- Name: material_requests material_requests_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.material_requests
    ADD CONSTRAINT material_requests_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.system_users(id);


--
-- Name: material_requests material_requests_requested_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.material_requests
    ADD CONSTRAINT material_requests_requested_by_fkey FOREIGN KEY (requested_by) REFERENCES public.system_users(id);


--
-- Name: material_requests material_requests_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.material_requests
    ADD CONSTRAINT material_requests_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.work_tasks(id) ON DELETE CASCADE;


--
-- Name: materials_inventory materials_inventory_sow_line_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.materials_inventory
    ADD CONSTRAINT materials_inventory_sow_line_item_id_fkey FOREIGN KEY (sow_line_item_id) REFERENCES public.scope_of_work_line_items(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.system_users(id);


--
-- Name: organization_eligibility_rules organization_eligibility_rules_criteria_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_eligibility_rules
    ADD CONSTRAINT organization_eligibility_rules_criteria_type_id_fkey FOREIGN KEY (criteria_type_id) REFERENCES public.criteria_types(id);


--
-- Name: organization_eligibility_rules organization_eligibility_rules_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_eligibility_rules
    ADD CONSTRAINT organization_eligibility_rules_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.coalition_organizations(id) ON DELETE CASCADE;


--
-- Name: organization_metrics organization_metrics_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_metrics
    ADD CONSTRAINT organization_metrics_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.coalition_organizations(id) ON DELETE CASCADE;


--
-- Name: organization_users organization_users_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_users
    ADD CONSTRAINT organization_users_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.coalition_organizations(id) ON DELETE CASCADE;


--
-- Name: permissions permissions_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.permission_categories(id);


--
-- Name: progress_events progress_events_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.progress_events
    ADD CONSTRAINT progress_events_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.cases(id) ON DELETE CASCADE;


--
-- Name: progress_events progress_events_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.progress_events
    ADD CONSTRAINT progress_events_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.coalition_organizations(id);


--
-- Name: progress_events progress_events_performed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.progress_events
    ADD CONSTRAINT progress_events_performed_by_fkey FOREIGN KEY (performed_by) REFERENCES public.system_users(id);


--
-- Name: project_assignments project_assignments_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_assignments
    ADD CONSTRAINT project_assignments_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.cases(id) ON DELETE CASCADE;


--
-- Name: project_assignments project_assignments_crew_lead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_assignments
    ADD CONSTRAINT project_assignments_crew_lead_id_fkey FOREIGN KEY (crew_lead_id) REFERENCES public.system_users(id);


--
-- Name: project_assignments project_assignments_project_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_assignments
    ADD CONSTRAINT project_assignments_project_manager_id_fkey FOREIGN KEY (project_manager_id) REFERENCES public.system_users(id);


--
-- Name: project_escalations project_escalations_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_escalations
    ADD CONSTRAINT project_escalations_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.cases(id) ON DELETE CASCADE;


--
-- Name: project_escalations project_escalations_raised_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_escalations
    ADD CONSTRAINT project_escalations_raised_by_fkey FOREIGN KEY (raised_by) REFERENCES public.system_users(id);


--
-- Name: project_escalations project_escalations_resolved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_escalations
    ADD CONSTRAINT project_escalations_resolved_by_fkey FOREIGN KEY (resolved_by) REFERENCES public.system_users(id);


--
-- Name: project_milestones project_milestones_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_milestones
    ADD CONSTRAINT project_milestones_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.cases(id) ON DELETE CASCADE;


--
-- Name: project_snapshots project_snapshots_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_snapshots
    ADD CONSTRAINT project_snapshots_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.cases(id) ON DELETE CASCADE;


--
-- Name: property_assessments property_assessments_assessor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.property_assessments
    ADD CONSTRAINT property_assessments_assessor_id_fkey FOREIGN KEY (assessor_id) REFERENCES public.system_users(id);


--
-- Name: property_assessments property_assessments_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.property_assessments
    ADD CONSTRAINT property_assessments_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.cases(id) ON DELETE CASCADE;


--
-- Name: quest_assignments quest_assignments_quest_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quest_assignments
    ADD CONSTRAINT quest_assignments_quest_id_fkey FOREIGN KEY (quest_id) REFERENCES public.quests(id) ON DELETE CASCADE;


--
-- Name: quest_assignments quest_assignments_verified_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quest_assignments
    ADD CONSTRAINT quest_assignments_verified_by_fkey FOREIGN KEY (verified_by) REFERENCES public.system_users(id);


--
-- Name: quest_assignments quest_assignments_volunteer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quest_assignments
    ADD CONSTRAINT quest_assignments_volunteer_id_fkey FOREIGN KEY (volunteer_id) REFERENCES public.system_users(id);


--
-- Name: quests quests_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quests
    ADD CONSTRAINT quests_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.cases(id);


--
-- Name: quests quests_parent_quest_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quests
    ADD CONSTRAINT quests_parent_quest_id_fkey FOREIGN KEY (parent_quest_id) REFERENCES public.quests(id);


--
-- Name: quests quests_quest_giver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quests
    ADD CONSTRAINT quests_quest_giver_id_fkey FOREIGN KEY (quest_giver_id) REFERENCES public.system_users(id);


--
-- Name: quests quests_work_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quests
    ADD CONSTRAINT quests_work_task_id_fkey FOREIGN KEY (work_task_id) REFERENCES public.work_tasks(id);


--
-- Name: reimbursement_requests reimbursement_requests_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reimbursement_requests
    ADD CONSTRAINT reimbursement_requests_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.cases(id);


--
-- Name: reimbursement_requests reimbursement_requests_funding_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reimbursement_requests
    ADD CONSTRAINT reimbursement_requests_funding_source_id_fkey FOREIGN KEY (funding_source_id) REFERENCES public.funding_sources(id);


--
-- Name: reimbursement_requests reimbursement_requests_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reimbursement_requests
    ADD CONSTRAINT reimbursement_requests_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.coalition_organizations(id);


--
-- Name: repair_category_details repair_category_details_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_category_details
    ADD CONSTRAINT repair_category_details_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.repair_categories(id);


--
-- Name: repair_category_details repair_category_details_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_category_details
    ADD CONSTRAINT repair_category_details_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.intake_submissions(id) ON DELETE CASCADE;


--
-- Name: repair_estimates repair_estimates_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_estimates
    ADD CONSTRAINT repair_estimates_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.system_users(id);


--
-- Name: repair_estimates repair_estimates_assessment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_estimates
    ADD CONSTRAINT repair_estimates_assessment_id_fkey FOREIGN KEY (assessment_id) REFERENCES public.property_assessments(id) ON DELETE CASCADE;


--
-- Name: repair_estimates repair_estimates_repair_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_estimates
    ADD CONSTRAINT repair_estimates_repair_category_id_fkey FOREIGN KEY (repair_category_id) REFERENCES public.repair_categories(id);


--
-- Name: repair_requests repair_requests_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_requests
    ADD CONSTRAINT repair_requests_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.intake_submissions(id) ON DELETE CASCADE;


--
-- Name: review_queue review_queue_assigned_to_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_queue
    ADD CONSTRAINT review_queue_assigned_to_id_fkey FOREIGN KEY (assigned_to_id) REFERENCES public.system_users(id);


--
-- Name: review_queue review_queue_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_queue
    ADD CONSTRAINT review_queue_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.coalition_organizations(id);


--
-- Name: review_queue review_queue_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_queue
    ADD CONSTRAINT review_queue_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.intake_submissions(id);


--
-- Name: role_permissions role_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: scope_of_work_line_items scope_of_work_line_items_assessment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scope_of_work_line_items
    ADD CONSTRAINT scope_of_work_line_items_assessment_id_fkey FOREIGN KEY (assessment_id) REFERENCES public.assessments(id) ON DELETE CASCADE;


--
-- Name: subcontractor_communications subcontractor_communications_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcontractor_communications
    ADD CONSTRAINT subcontractor_communications_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.system_users(id);


--
-- Name: subcontractor_communications subcontractor_communications_subcontractor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcontractor_communications
    ADD CONSTRAINT subcontractor_communications_subcontractor_id_fkey FOREIGN KEY (subcontractor_id) REFERENCES public.system_users(id);


--
-- Name: subcontractor_communications subcontractor_communications_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcontractor_communications
    ADD CONSTRAINT subcontractor_communications_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.work_tasks(id) ON DELETE CASCADE;


--
-- Name: subcontractor_invoices subcontractor_invoices_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcontractor_invoices
    ADD CONSTRAINT subcontractor_invoices_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.system_users(id);


--
-- Name: subcontractor_invoices subcontractor_invoices_invoice_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcontractor_invoices
    ADD CONSTRAINT subcontractor_invoices_invoice_document_id_fkey FOREIGN KEY (invoice_document_id) REFERENCES public.case_documents(id);


--
-- Name: subcontractor_invoices subcontractor_invoices_paid_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcontractor_invoices
    ADD CONSTRAINT subcontractor_invoices_paid_by_fkey FOREIGN KEY (paid_by) REFERENCES public.system_users(id);


--
-- Name: subcontractor_invoices subcontractor_invoices_subcontractor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcontractor_invoices
    ADD CONSTRAINT subcontractor_invoices_subcontractor_id_fkey FOREIGN KEY (subcontractor_id) REFERENCES public.system_users(id);


--
-- Name: subcontractor_invoices subcontractor_invoices_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcontractor_invoices
    ADD CONSTRAINT subcontractor_invoices_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.work_tasks(id) ON DELETE CASCADE;


--
-- Name: subcontractor_profiles subcontractor_profiles_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcontractor_profiles
    ADD CONSTRAINT subcontractor_profiles_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.system_users(id);


--
-- Name: subcontractor_profiles subcontractor_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcontractor_profiles
    ADD CONSTRAINT subcontractor_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.system_users(id);


--
-- Name: subcontractor_quotes subcontractor_quotes_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcontractor_quotes
    ADD CONSTRAINT subcontractor_quotes_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.system_users(id);


--
-- Name: subcontractor_quotes subcontractor_quotes_quote_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcontractor_quotes
    ADD CONSTRAINT subcontractor_quotes_quote_document_id_fkey FOREIGN KEY (quote_document_id) REFERENCES public.case_documents(id);


--
-- Name: subcontractor_quotes subcontractor_quotes_subcontractor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcontractor_quotes
    ADD CONSTRAINT subcontractor_quotes_subcontractor_id_fkey FOREIGN KEY (subcontractor_id) REFERENCES public.system_users(id);


--
-- Name: subcontractor_quotes subcontractor_quotes_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcontractor_quotes
    ADD CONSTRAINT subcontractor_quotes_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.work_tasks(id) ON DELETE CASCADE;


--
-- Name: submission_contact_methods submission_contact_methods_method_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_contact_methods
    ADD CONSTRAINT submission_contact_methods_method_id_fkey FOREIGN KEY (method_id) REFERENCES public.contact_methods(id);


--
-- Name: submission_contact_methods submission_contact_methods_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_contact_methods
    ADD CONSTRAINT submission_contact_methods_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.intake_submissions(id) ON DELETE CASCADE;


--
-- Name: submission_household_attributes submission_household_attributes_attribute_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_household_attributes
    ADD CONSTRAINT submission_household_attributes_attribute_id_fkey FOREIGN KEY (attribute_id) REFERENCES public.household_attributes(id);


--
-- Name: submission_household_attributes submission_household_attributes_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_household_attributes
    ADD CONSTRAINT submission_household_attributes_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.intake_submissions(id) ON DELETE CASCADE;


--
-- Name: submission_repair_categories submission_repair_categories_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_repair_categories
    ADD CONSTRAINT submission_repair_categories_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.repair_categories(id);


--
-- Name: submission_repair_categories submission_repair_categories_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_repair_categories
    ADD CONSTRAINT submission_repair_categories_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.intake_submissions(id) ON DELETE CASCADE;


--
-- Name: support_tickets support_tickets_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.support_tickets
    ADD CONSTRAINT support_tickets_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.system_users(id) ON DELETE SET NULL;


--
-- Name: support_tickets support_tickets_resolved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.support_tickets
    ADD CONSTRAINT support_tickets_resolved_by_fkey FOREIGN KEY (resolved_by) REFERENCES public.system_users(id) ON DELETE SET NULL;


--
-- Name: support_tickets support_tickets_submitted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.support_tickets
    ADD CONSTRAINT support_tickets_submitted_by_fkey FOREIGN KEY (submitted_by) REFERENCES public.system_users(id) ON DELETE SET NULL;


--
-- Name: system_users system_users_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_users
    ADD CONSTRAINT system_users_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.system_users(id);


--
-- Name: system_users system_users_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_users
    ADD CONSTRAINT system_users_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.system_users(id);


--
-- Name: task_status_history task_status_history_changed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_status_history
    ADD CONSTRAINT task_status_history_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.system_users(id);


--
-- Name: task_status_history task_status_history_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_status_history
    ADD CONSTRAINT task_status_history_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.work_tasks(id) ON DELETE CASCADE;


--
-- Name: user_role_assignments user_role_assignments_assigned_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_role_assignments
    ADD CONSTRAINT user_role_assignments_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES public.system_users(id);


--
-- Name: user_role_assignments user_role_assignments_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_role_assignments
    ADD CONSTRAINT user_role_assignments_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.coalition_organizations(id) ON DELETE CASCADE;


--
-- Name: user_role_assignments user_role_assignments_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_role_assignments
    ADD CONSTRAINT user_role_assignments_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: user_role_assignments user_role_assignments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_role_assignments
    ADD CONSTRAINT user_role_assignments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.system_users(id) ON DELETE CASCADE;


--
-- Name: volunteer_badges volunteer_badges_awarded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_badges
    ADD CONSTRAINT volunteer_badges_awarded_by_fkey FOREIGN KEY (awarded_by) REFERENCES public.system_users(id);


--
-- Name: volunteer_badges volunteer_badges_badge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_badges
    ADD CONSTRAINT volunteer_badges_badge_id_fkey FOREIGN KEY (badge_id) REFERENCES public.badges(id) ON DELETE CASCADE;


--
-- Name: volunteer_badges volunteer_badges_volunteer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_badges
    ADD CONSTRAINT volunteer_badges_volunteer_id_fkey FOREIGN KEY (volunteer_id) REFERENCES public.system_users(id) ON DELETE CASCADE;


--
-- Name: volunteer_content volunteer_content_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_content
    ADD CONSTRAINT volunteer_content_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.system_users(id);


--
-- Name: volunteer_content volunteer_content_reviewed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_content
    ADD CONSTRAINT volunteer_content_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES public.system_users(id);


--
-- Name: volunteer_feedback volunteer_feedback_beneficiary_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_feedback
    ADD CONSTRAINT volunteer_feedback_beneficiary_id_fkey FOREIGN KEY (beneficiary_id) REFERENCES public.intake_submissions(id);


--
-- Name: volunteer_feedback volunteer_feedback_quest_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_feedback
    ADD CONSTRAINT volunteer_feedback_quest_id_fkey FOREIGN KEY (quest_id) REFERENCES public.quests(id);


--
-- Name: volunteer_feedback volunteer_feedback_volunteer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_feedback
    ADD CONSTRAINT volunteer_feedback_volunteer_id_fkey FOREIGN KEY (volunteer_id) REFERENCES public.system_users(id);


--
-- Name: volunteer_hours volunteer_hours_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_hours
    ADD CONSTRAINT volunteer_hours_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.system_users(id);


--
-- Name: volunteer_hours volunteer_hours_verified_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_hours
    ADD CONSTRAINT volunteer_hours_verified_by_fkey FOREIGN KEY (verified_by) REFERENCES public.system_users(id);


--
-- Name: volunteer_hours volunteer_hours_work_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_hours
    ADD CONSTRAINT volunteer_hours_work_order_id_fkey FOREIGN KEY (work_order_id) REFERENCES public.work_orders(id);


--
-- Name: volunteer_profiles volunteer_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_profiles
    ADD CONSTRAINT volunteer_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.system_users(id);


--
-- Name: volunteer_skills volunteer_skills_endorsed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_skills
    ADD CONSTRAINT volunteer_skills_endorsed_by_fkey FOREIGN KEY (endorsed_by) REFERENCES public.system_users(id);


--
-- Name: volunteer_skills volunteer_skills_skill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_skills
    ADD CONSTRAINT volunteer_skills_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES public.skills(id) ON DELETE CASCADE;


--
-- Name: volunteer_skills volunteer_skills_volunteer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteer_skills
    ADD CONSTRAINT volunteer_skills_volunteer_id_fkey FOREIGN KEY (volunteer_id) REFERENCES public.system_users(id) ON DELETE CASCADE;


--
-- Name: weekly_digests weekly_digests_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weekly_digests
    ADD CONSTRAINT weekly_digests_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.system_users(id);


--
-- Name: work_orders work_orders_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.cases(id) ON DELETE CASCADE;


--
-- Name: work_orders work_orders_crew_lead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_crew_lead_id_fkey FOREIGN KEY (crew_lead_id) REFERENCES public.system_users(id);


--
-- Name: work_orders work_orders_project_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_project_manager_id_fkey FOREIGN KEY (project_manager_id) REFERENCES public.system_users(id);


--
-- Name: work_tasks work_tasks_assigned_to_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_tasks
    ADD CONSTRAINT work_tasks_assigned_to_id_fkey FOREIGN KEY (assigned_to_id) REFERENCES public.system_users(id);


--
-- Name: work_tasks work_tasks_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_tasks
    ADD CONSTRAINT work_tasks_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.system_users(id);


--
-- Name: work_tasks work_tasks_estimate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_tasks
    ADD CONSTRAINT work_tasks_estimate_id_fkey FOREIGN KEY (estimate_id) REFERENCES public.repair_estimates(id);


--
-- Name: work_tasks work_tasks_repair_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_tasks
    ADD CONSTRAINT work_tasks_repair_category_id_fkey FOREIGN KEY (repair_category_id) REFERENCES public.repair_categories(id);


--
-- Name: work_tasks work_tasks_work_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_tasks
    ADD CONSTRAINT work_tasks_work_order_id_fkey FOREIGN KEY (work_order_id) REFERENCES public.work_orders(id) ON DELETE CASCADE;


--
-- Name: application_match_scores; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: -
--

REFRESH MATERIALIZED VIEW public.application_match_scores;


--
-- PostgreSQL database dump complete
--

\unrestrict sy1QOrLSo4Kr3wK3ZZx6J8ygzg28Gaff7EufdBmiWadKjVTuOggFim9Gi4jydbu

