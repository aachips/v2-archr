Make edits like a Github. Save all things in one big batch. Prevent having hundreds of granular events. 

Concerns about granularity of events and how fast the log will blow up.

Archive log each day, searchable indexable log of edits. Set timer for 30 days. 

Snapshot of periodic times

Activity Log: Tracks everything that happens - Like a security camera footage—records everything

Milestone Tracker: Tracks progress toward goals - Like a checklist for completing a level in a game

Two separate ecosystems - Activity log in 30 day range. Then what is similar to the Edit History, with a Save/ Commit Option

Does Pinia have built in error logging?

Event Emitter - Contained Processes Repeatable Everytime
To Do Item vs Doing It
Event - Milk was Bought
Actions are - Drove to store, bought milk on card, kept receipt, logged mileage
Emitter - series of actions grouped together to buy milk

Object Mutator: 

Event Resolver: 


An Activity Log entry needs:

|Field|Type|Example|
|---|---|---|
|**id**|UUID|`act_12345678`|
|**timestamp**|DateTime|`2026-09-01 09:14:32`|
|**user_id**|UUID|`usr_abcdefg` (or "system")|
|**session_id**|UUID|`ses_9876543` (optional)|
|**application_id**|UUID|`app_42CHERRY`|
|**action**|String|`document_uploaded`|
|**details**|JSON|`{"document_type":"income","filename":"paystub.pdf"}`|
|**source**|String|`web_interface` or `api` or `backend_script`|

In Airtable, we have a Progress Tracker application. There are 41 tables, and a warning display before opening that it is reaching peak records supported for our Airtable plan. If we are hitting that limit, the existing system is already at capacity.

So the first step would be recreating this entire system, with it's 41 relational tables, as a PostgreSQL version.

In PostgreSQL, this would be a table with the same fields, plus indexes for fast searching:

CREATE TABLE activity_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id UUID REFERENCES system_users(id),
    session_id UUID,
    application_id UUID REFERENCES applications(id),
    action VARCHAR(100) NOT NULL,
    details JSONB DEFAULT '{}'::jsonb,
    source VARCHAR(50),
    INDEX idx_activity_timestamp (timestamp),
    INDEX idx_activity_user (user_id),
    INDEX idx_activity_application (application_id)
);
## Quick Reference: Activity Log Actions

|Category|Actions|
|---|---|
|**Submission**|`submission_created`, `submission_updated`, `submission_deduplicated`|
|**Application**|`application_created`, `application_status_changed`, `application_claimed`|
|**Document**|`document_uploaded`, `document_verified`, `document_rejected`|
|**Assessment**|`assessment_scheduled`, `assessment_completed`, `assessment_report_created`|
|**Case**|`case_created`, `case_assigned`, `case_status_changed`, `case_claim_expired`|
|**Project**|`project_created`, `project_budget_approved`, `project_task_completed`, `project_completed`|
|**User**|`user_login`, `user_logout`, `user_permission_changed`|
|**System**|`system_backup_started`, `system_backup_completed`, `system_error`|

## Summary

| Component                    | Purpose                      | Where It Lives                           |
| ---------------------------- | ---------------------------- | ---------------------------------------- |
| **Activity Log**             | Records every action         | PostgreSQL primary, Airtable optionally  |
| **Milestone Tracker**        | Tracks progress toward goals | Both systems (derived from Activity Log) |
| **Pipeline Progress Widget** | Visual display of milestones | UI layer                                 |
