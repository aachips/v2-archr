<?php
declare(strict_types=1);

/* -----------------------------------------------------------------
 * Six-phase application-to-completed-project pipeline.
 *
 * Source of truth: elemental-integration/task-engine/
 *   quick-add-progress-tracker/project-phases/p0..p5 + lifecycle doc.
 *
 *   0 Submission & Pre-Screening
 *   1 Intake
 *   2 Processing
 *   3 Planning
 *   4 Project (Execution)
 *   5 Completion & Report
 *
 * Possible exits: Paused · Withdrawn · Ineligible
 * ----------------------------------------------------------------- */

function archr_case_phases(): array {
    return [
        0 => [
            'name' => 'Submission',
            'full_name' => 'Submission & Pre-Screening',
            'description' => 'Application received. Verify storm-related damage, geographic and income eligibility, and collect homeowner / income documents before formal intake.',
            'next_steps' => [
                'Verify the damage is storm (Helene) related',
                'Confirm the property is inside the service area',
                'Confirm income eligibility and household demographics',
                'Collect homeowner and income documents (the applicant can upload these through their dashboard link)',
                'Decision point: advance to Intake, or pause / withdraw / mark ineligible',
            ],
        ],
        1 => [
            'name' => 'Intake',
            'full_name' => 'Intake',
            'description' => 'Establish the case record and assign initial resources: first applicant contact, claim decision, assessor assignment, assessment scheduling.',
            'next_steps' => [
                'Make initial contact with the applicant',
                'Claim the case for your organization (Repairs Needed section)',
                'Assign an assessor and schedule the home assessment',
                'Collect any outstanding income / ownership documents',
            ],
        ],
        2 => [
            'name' => 'Processing',
            'full_name' => 'Processing',
            'description' => 'Verify documentation, perform the home assessment, confirm eligibility, and build the repair scope, task list, and budget.',
            'next_steps' => [
                'Verify income and ownership documents',
                'Perform the on-site assessment and collect before photos',
                'Confirm final eligibility and create the assessment report',
                'Assign a funding source and create the repair task list',
                'Determine labor pool, subcontractor estimates, scope of work, and budget',
            ],
        ],
        3 => [
            'name' => 'Planning',
            'full_name' => 'Planning',
            'description' => 'Schedule resources, create and sign the repair contract, and prepare for work to begin.',
            'next_steps' => [
                'Determine the project timeline and schedule the start date',
                'Assign subcontractors, work crew, and volunteer groups',
                'Create the contract and arrange signing with the homeowner',
                'Create the initial materials list',
            ],
        ],
        4 => [
            'name' => 'Project',
            'full_name' => 'Project Execution',
            'description' => 'Perform the repair work: site safety, materials and logistics, repair tasks, punch list, final walkthrough, and documentation.',
            'next_steps' => [
                'Hold safety talks and plan jobsite logistics',
                'Run materials and track supplies / equipment needs',
                'Complete the repair tasks and punch list',
                'Perform the final walkthrough and record progress notes and photos',
                'Get the homeowner completion sign-off',
            ],
        ],
        5 => [
            'name' => 'Completion',
            'full_name' => 'Completion & Report',
            'description' => 'Close out the project financially and administratively: actual costs, draw request workbook, completion certificate, job closed.',
            'next_steps' => [
                'Record actual material, labor, and subcontractor expenses',
                'Complete the draw request workbook',
                'Sign the completion certificate with the homeowner',
                'Mark the job complete',
            ],
        ],
    ];
}

/**
 * Compute a case's current phase + exit state.
 *
 * @param array $case Row from archr_load_case() — uses status fields plus the
 *                    milestone timestamps on `cases` when available.
 * @return array{number:int, exit:?string, exit_label:?string}
 *   exit is null | 'paused' | 'withdrawn' | 'ineligible'
 */
function archr_case_phase(array $case): array {
    $statusCode = strtoupper((string)($case['status_code'] ?? ''));
    $submissionStatus = strtolower((string)($case['submission_status'] ?? ''));

    $exit = null;
    if ($submissionStatus === 'withdrawn' || $statusCode === 'WITHDRAWN') {
        $exit = 'withdrawn';
    } elseif ($statusCode === 'DENIED' || $submissionStatus === 'denied') {
        $exit = 'ineligible';
    } elseif ($statusCode === 'ON_HOLD') {
        $exit = 'paused';
    }

    // Derive the furthest phase reached from milestone timestamps first,
    // falling back to the workflow status sequence.
    $phase = 0;
    if (!empty($case['intake_completed_at'])) {
        $phase = 1;
    }
    if (!empty($case['assessment_scheduled_at']) || !empty($case['assessment_completed_at'])) {
        $phase = 2;
    }
    if (!empty($case['approved_at'])) {
        $phase = 3;
    }
    if (!empty($case['work_started_at'])) {
        $phase = 4;
    }
    if (!empty($case['work_completed_at'])) {
        $phase = 5;
    }

    if ($phase === 0 && $exit === null) {
        // Sequence fallback only for live workflow statuses — terminal/hold
        // statuses (ON_HOLD=50, WITHDRAWN=98, DENIED=99) must not map forward.
        $seq = (int)($case['status_sequence'] ?? 1);
        $phase = match (true) {
            $seq >= 10 => 5,
            $seq >= 6  => 4,
            $seq >= 5  => 3,
            $seq >= 3  => 2,
            $seq >= 2  => 1,
            default    => 0,
        };
    }

    $exitLabels = [
        'paused'     => 'Paused',
        'withdrawn'  => 'Withdrawn',
        'ineligible' => 'Ineligible / Denied',
    ];

    return [
        'number' => $phase,
        'exit' => $exit,
        'exit_label' => $exit !== null ? $exitLabels[$exit] : null,
    ];
}
