<?php
declare(strict_types=1);

/**
 * Milestone definitions for the Event Resolver.
 *
 * Each milestone is a checkpoint in the application → case → project pipeline.
 * A milestone is "complete" when its `evaluate()` rule returns true based on
 * the events found in the progress_events ledger.
 *
 * Source: activity-log-progress-tracker/event-library.md
 *         activity-log-progress-tracker/Milestone Tracker.md
 */

/**
 * Return the canonical milestone definitions.
 *
 * Each milestone has:
 *   code          - unique identifier (M1, M2, ...)
 *   name          - human-readable label
 *   phase         - which phase (0-5) this belongs to
 *   column        - the cases table column to stamp when complete
 *                   (null = tracked but doesn't advance phase on its own)
 *   evaluate      - closure(PDO $pdo, int $caseId): bool
 *                   checks progress_events to determine completion
 */
function archr_milestone_definitions(): array {
    return [
        // ── Phase 0: Submission ──────────────────────────────────
        [
            'code'   => 'M1',
            'name'   => 'Application Submitted',
            'phase'  => 0,
            'column' => null,
            'description' => 'First submission for this placecode.',
            'evaluate' => function (PDO $pdo, int $caseId): bool {
                // An application exists with status_sequence >= 0.
                // (The intake-save.php creates it immediately.)
                $stmt = $pdo->prepare("
                    SELECT COUNT(*) FROM cases WHERE id = :id
                ");
                $stmt->execute([':id' => $caseId]);
                return (int) $stmt->fetchColumn() > 0;
            },
        ],
        [
            'code'   => 'M2',
            'name'   => 'Eligibility Checked',
            'phase'  => 0,
            'column' => null,
            'description' => 'Eligibility report generated and processed.',
            'evaluate' => function (PDO $pdo, int $caseId): bool {
                // Check for eligibility-related events
                $stmt = $pdo->prepare("
                    SELECT COUNT(*) FROM progress_events
                    WHERE application_id = :id
                      AND event_type = 'assessment_event'
                      AND details::text ILIKE '%eligibility%'
                ");
                $stmt->execute([':id' => $caseId]);
                return (int) $stmt->fetchColumn() > 0;
            },
        ],

        // ── Phase 1: Intake ──────────────────────────────────────
        [
            'code'   => 'M3',
            'name'   => 'Claimed by Organization',
            'phase'  => 1,
            'column' => 'intake_completed_at',
            'description' => 'An organization claimed the application.',
            'evaluate' => function (PDO $pdo, int $caseId): bool {
                // Check if claimed_org is set on the cases table
                $stmt = $pdo->prepare("
                    SELECT claimed_org FROM cases WHERE id = :id
                ");
                $stmt->execute([':id' => $caseId]);
                $org = $stmt->fetchColumn();
                return !empty($org);
            },
        ],
        [
            'code'   => 'M4',
            'name'   => 'Assessor Assigned',
            'phase'  => 1,
            'column' => null,
            'description' => 'An assessor has been assigned to this case.',
            'evaluate' => function (PDO $pdo, int $caseId): bool {
                // Check for an assignment event
                $stmt = $pdo->prepare("
                    SELECT COUNT(*) FROM progress_events
                    WHERE application_id = :id
                      AND event_type = 'assessment_event'
                      AND details::text ILIKE '%assign%'
                ");
                $stmt->execute([':id' => $caseId]);
                return (int) $stmt->fetchColumn() > 0;
            },
        ],
        [
            'code'   => 'M5',
            'name'   => 'Assessment Scheduled',
            'phase'  => 1,
            'column' => 'assessment_scheduled_at',
            'description' => 'Assessment date has been set.',
            'evaluate' => function (PDO $pdo, int $caseId): bool {
                $stmt = $pdo->prepare("
                    SELECT assessment_scheduled_at FROM cases WHERE id = :id
                ");
                $stmt->execute([':id' => $caseId]);
                return !empty($stmt->fetchColumn());
            },
        ],

        // ── Phase 2: Processing ──────────────────────────────────
        [
            'code'   => 'M6',
            'name'   => 'Assessment Completed',
            'phase'  => 2,
            'column' => 'assessment_completed_at',
            'description' => 'On-site assessment completed with report.',
            'evaluate' => function (PDO $pdo, int $caseId): bool {
                $stmt = $pdo->prepare("
                    SELECT assessment_completed_at FROM cases WHERE id = :id
                ");
                $stmt->execute([':id' => $caseId]);
                return !empty($stmt->fetchColumn());
            },
        ],
        [
            'code'   => 'M7',
            'name'   => 'Documents Verified',
            'phase'  => 2,
            'column' => null,
            'description' => 'Income and ownership documents collected and verified.',
            'evaluate' => function (PDO $pdo, int $caseId): bool {
                // Check for verified document events
                $stmt = $pdo->prepare("
                    SELECT COUNT(*) FROM progress_events
                    WHERE application_id = :id
                      AND event_type = 'document_event'
                      AND details::text ILIKE '%verif%'
                ");
                $stmt->execute([':id' => $caseId]);
                return (int) $stmt->fetchColumn() >= 2; // income + ownership
            },
        ],
        [
            'code'   => 'M8',
            'name'   => 'Budget Approved',
            'phase'  => 2,
            'column' => 'approved_at',
            'description' => 'Repair scope, task list, and budget approved.',
            'evaluate' => function (PDO $pdo, int $caseId): bool {
                $stmt = $pdo->prepare("
                    SELECT approved_at FROM cases WHERE id = :id
                ");
                $stmt->execute([':id' => $caseId]);
                return !empty($stmt->fetchColumn());
            },
        ],

        // ── Phase 3: Planning ────────────────────────────────────
        [
            'code'   => 'M9',
            'name'   => 'Contract Signed',
            'phase'  => 3,
            'column' => null,
            'description' => 'Repair contract signed by homeowner.',
            'evaluate' => function (PDO $pdo, int $caseId): bool {
                $stmt = $pdo->prepare("
                    SELECT COUNT(*) FROM progress_events
                    WHERE application_id = :id
                      AND event_type = 'document_event'
                      AND details::text ILIKE '%contract%sig%'
                ");
                $stmt->execute([':id' => $caseId]);
                return (int) $stmt->fetchColumn() > 0;
            },
        ],
        [
            'code'   => 'M10',
            'name'   => 'Work Scheduled',
            'phase'  => 3,
            'column' => null,
            'description' => 'Project timeline set, crew/subs assigned.',
            'evaluate' => function (PDO $pdo, int $caseId): bool {
                $stmt = $pdo->prepare("
                    SELECT COUNT(*) FROM progress_events
                    WHERE application_id = :id
                      AND event_type = 'schedule_event'
                ");
                $stmt->execute([':id' => $caseId]);
                return (int) $stmt->fetchColumn() > 0;
            },
        ],

        // ── Phase 4: Execution ───────────────────────────────────
        [
            'code'   => 'M11',
            'name'   => 'Work Started',
            'phase'  => 4,
            'column' => 'work_started_at',
            'description' => 'First repair task started on site.',
            'evaluate' => function (PDO $pdo, int $caseId): bool {
                $stmt = $pdo->prepare("
                    SELECT work_started_at FROM cases WHERE id = :id
                ");
                $stmt->execute([':id' => $caseId]);
                return !empty($stmt->fetchColumn());
            },
        ],
        [
            'code'   => 'M12',
            'name'   => 'Work Completed',
            'phase'  => 4,
            'column' => 'work_completed_at',
            'description' => 'All repair tasks finished, final walkthrough done.',
            'evaluate' => function (PDO $pdo, int $caseId): bool {
                $stmt = $pdo->prepare("
                    SELECT work_completed_at FROM cases WHERE id = :id
                ");
                $stmt->execute([':id' => $caseId]);
                return !empty($stmt->fetchColumn());
            },
        ],

        // ── Phase 5: Completion ──────────────────────────────────
        [
            'code'   => 'M13',
            'name'   => 'Final Inspection Passed',
            'phase'  => 5,
            'column' => null,
            'description' => 'Final inspection completed.',
            'evaluate' => function (PDO $pdo, int $caseId): bool {
                $stmt = $pdo->prepare("
                    SELECT COUNT(*) FROM progress_events
                    WHERE application_id = :id
                      AND event_type = 'assessment_event'
                      AND details::text ILIKE '%final%inspect%'
                ");
                $stmt->execute([':id' => $caseId]);
                return (int) $stmt->fetchColumn() > 0;
            },
        ],
        [
            'code'   => 'M14',
            'name'   => 'Certificate of Completion Signed',
            'phase'  => 5,
            'column' => null,
            'description' => 'Completion certificate signed by homeowner.',
            'evaluate' => function (PDO $pdo, int $caseId): bool {
                $stmt = $pdo->prepare("
                    SELECT COUNT(*) FROM progress_events
                    WHERE application_id = :id
                      AND event_type = 'document_event'
                      AND details::text ILIKE '%coc%sig%'
                ");
                $stmt->execute([':id' => $caseId]);
                return (int) $stmt->fetchColumn() > 0;
            },
        ],
        [
            'code'   => 'M15',
            'name'   => 'Case Closed',
            'phase'  => 5,
            'column' => null,
            'description' => 'Project closed out, draw request submitted, case archived.',
            'evaluate' => function (PDO $pdo, int $caseId): bool {
                $stmt = $pdo->prepare("
                    SELECT status_code FROM cases WHERE id = :id
                ");
                $stmt->execute([':id' => $caseId]);
                $status = strtoupper((string) $stmt->fetchColumn());
                return $status === 'CLOSED' || $status === 'COMPLETED';
            },
        ],
    ];
}
