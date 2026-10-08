---
document_name: Intake Deployment Checklist
document_type: Checklist
version: 1.0
last_updated: 2026-08-01
author: ARCHR Development Team
audience: Developers, Admins
complexity_level: Intermediate
estimated_reading_minutes: 5
tags: [deployment, checklist, intake, pre-flight]
visibility: ["admin", "super-admin"]
---

## Pre-Deployment

- [ ] Create all tables (run schema creation scripts)
- [ ] Create sequences (fifo_sequence)
- [ ] Create helper functions (is_in_service_area, get_income_bucket, etc.)
- [ ] Create main functions (submit_intake_application, check_eligibility)
- [ ] Create triggers (anchor_id, timestamps)
- [ ] Create views (staff_review_queue, role-specific views)
- [ ] Grant appropriate permissions to application user

## Post-Deployment Validation

- [ ] Test submission with valid data → eligible
- [ ] Test submission with invalid data → ineligible with reason
- [ ] Test optional account creation
- [ ] Verify notifications appear for staff roles
- [ ] Verify queue maintains FIFO order
- [ ] Verify anchor captures all applications
- [ ] Test guest access token generation
- [ ] Verify email queue entries created

## Rollback Plan

If issues occur:
1. Set application to maintenance mode
2. Truncate test submissions (if any)
3. Rollback to previous version of functions
4. No schema rollback without data migration

## Monitoring Queries

-- Check recent submissions
SELECT id, applicant_first_name, applicant_last_name, submission_status, submitted_at
FROM intake_submissions 
ORDER BY submitted_at DESC LIMIT 10;

-- Check queue health
SELECT status, COUNT(*) FROM review_queue GROUP BY status;

-- Check notification delivery
SELECT status, COUNT(*) FROM email_queue GROUP BY status;

-- Check anchor coverage
SELECT COUNT(*) FROM intake_submissions s
LEFT JOIN application_anchor a ON s.id = a.submission_id
WHERE a.id IS NULL;


## Appendix: Quick Reference

|Component|Function/Table|Purpose|
|---|---|---|
|Submission Handler|`submit_intake_application()`|Main entry point|
|Eligibility Check|`check_eligibility()`|"Accept until disqualify" logic|
|Anchor Registry|`application_anchor`|Tracks EVERY application|
|Review Queue|`review_queue`|FIFO with priority|
|Notifications|`notifications`|In-app alerts|
|Email Queue|`email_queue`|Batched email delivery|
|Staff Views|`staff_review_queue`|Unified queue display|

---

_End of Technical Specification_

text

This comprehensive implementation guide provides:
1. **Complete submission handler** with optional account creation
2. **"Accept until disqualify" eligibility checker** that defaults to eligible
3. **Anchor registration** for every application (critical for metrics)
4. **FIFO review queue** with priority scoring
5. **Notification system** for staff roles
6. **Email digest** system for batched notifications
7. **Test cases** for validation
8. **Deployment checklist** for your PostgreSQL learning journey
The philosophy throughout is "accept until disqualifying information found" - meaning the system errs on the side of including applications, then marks them appropriately for tracking. Every application gets anchored, regardless of outcome, ensuring your metrics are complete.