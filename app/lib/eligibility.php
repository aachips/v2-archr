<?php
declare(strict_types=1);

require_once __DIR__ . '/activity-log.php';

/**
 * Eligibility Checker — flags, not decisions.
 *
 * Implements the eligibility philosophy in "ARCHR Core Terminology and
 * Operational Logic" Part 4:
 *   - Assume eligibility: every applicant is treated as eligible by default.
 *   - Flag, don't decide: the system surfaces green/yellow/red flags.
 *   - No automated denials: final determinations are made by humans.
 *
 * Flags are stored on the Application (applications.eligibility_flags) and a
 * human-readable summary in applications.eligibility_report.
 */

/**
 * Evaluate a submission and attach green/yellow/red flags.
 * Never denies anyone: is_eligible is always true; red flags simply route
 * the application to human review.
 *
 * @param PDO $pdo Database connection
 * @param int $submissionId Intake submission ID
 * @return array Eligibility result with flags and a recommended action
 */
function check_eligibility(PDO $pdo, int $submissionId): array {
    // Fetch submission data
    $stmt = $pdo->prepare("SELECT * FROM intake_submissions WHERE id = :id");
    $stmt->execute([':id' => $submissionId]);
    $submission = $stmt->fetch();

    if (!$submission) {
        throw new Exception("Submission not found: $submissionId");
    }

    $flags = ['green' => [], 'yellow' => [], 'red' => []];

    $result = [
        'is_eligible' => true, // assume eligibility — humans decide otherwise
        'confidence' => 'high',
        'checks' => [],
        'flags' => $flags,
        'recommended_action' => 'approve',
    ];

    // Check 1: Income (80% AMI threshold) — over-threshold is a red flag
    // for human review, never an automated denial.
    $incomeCheck = check_income_eligibility($submission);
    $result['checks']['income'] = $incomeCheck;
    if ($incomeCheck['passed']) {
        $flags['green'][] = 'income_within_80pct_ami';
    } else {
        $flags['red'][] = 'income_above_80pct_ami';
    }

    // Check 2: Geographic eligibility
    $geoCheck = check_geographic_eligibility($submission);
    $result['checks']['geography'] = $geoCheck;
    if ($geoCheck['passed']) {
        $flags['green'][] = 'in_service_area';
    } else {
        $result['confidence'] = 'medium';
        $flags['red'][] = 'outside_service_area';
    }

    // Check 3: Home ownership requirement
    $ownershipCheck = check_ownership($submission);
    $result['checks']['ownership'] = $ownershipCheck;
    if ($ownershipCheck['passed']) {
        $flags['green'][] = 'homeownership_confirmed';
    } else {
        $flags['red'][] = 'homeownership_not_confirmed';
    }

    // Check 4: Primary residence
    $primary = _archr_pg_bool($submission['is_primary_residence'] ?? null);
    if ($primary === true) {
        $flags['green'][] = 'primary_residence_confirmed';
    } elseif ($primary === false) {
        $flags['red'][] = 'not_primary_residence';
    }

    // Check 5: Helene-related damage (context flag from the doc's example)
    if (!empty($submission['helene_related'])) {
        $flags['green'][] = 'helene_related';
    }

    // Check 6: Applicant age (under 18 needs a guardian — yellow for review)
    if (!empty($submission['applicant_dob'])) {
        $dob = strtotime((string)$submission['applicant_dob']);
        if ($dob !== false && $dob > strtotime('-18 years')) {
            $flags['yellow'][] = 'applicant_under_18_guardian_required';
        }
    }

    // Check 7: A repair need must be identifiable for the application to proceed
    $repairStmt = $pdo->prepare(
        "SELECT (EXISTS (SELECT 1 FROM submission_repair_categories WHERE submission_id = :id)
              OR EXISTS (SELECT 1 FROM repair_requests WHERE submission_id = :id)) AS has_repairs"
    );
    $repairStmt->execute([':id' => $submissionId]);
    $hasRepairs = (bool)$repairStmt->fetchColumn();
    if ($hasRepairs) {
        $flags['green'][] = 'repair_needs_identified';
    } else {
        $flags['yellow'][] = 'no_repair_need_identified';
    }

    // Priority scoring (urgent conditions increase priority — triage, not eligibility)
    $priorityScore = calculate_priority_score($submission);
    $result['priority_score'] = $priorityScore;

    // Recommended action is advice for a human reviewer, never a decision.
    if ($flags['red'] !== []) {
        $result['recommended_action'] = 'review_manually';
    } elseif ($priorityScore >= 50) {
        $result['recommended_action'] = 'expedite';
    } else {
        $result['recommended_action'] = 'approve';
    }
    // Store the assembled flags on the result.
    $result['flags'] = $flags;

    // Record the check. Red flags route to human review ('needs_review');
    // the system never writes 'ineligible'.
    $updateStmt = $pdo->prepare(
        "UPDATE intake_submissions
         SET eligibility_checked_at = CURRENT_TIMESTAMP,
             submission_status = CASE
                WHEN :has_red THEN 'needs_review'
                ELSE 'eligible'
             END
         WHERE id = :id"
    );
    $updateStmt->execute([
        ':has_red' => $result['flags']['red'] !== [] ? 't' : 'f',
        ':id' => $submissionId,
    ]);

    // Store the flags on the Application (the deduplicated source of truth).
    $reportParts = [];
    foreach (['green', 'yellow', 'red'] as $color) {
        if ($result['flags'][$color] !== []) {
            $reportParts[] = ucfirst($color) . ': ' . implode(', ', $result['flags'][$color]);
        }
    }
    $report = $reportParts ? implode('. ', $reportParts) : 'No flags.';
    $appStmt = $pdo->prepare(
        "UPDATE applications
            SET eligibility_flags = :flags::jsonb,
                eligibility_report = :report,
                updated_at = CURRENT_TIMESTAMP
          WHERE id = (SELECT deduplicated_into FROM intake_submissions WHERE id = :id)"
    );
    $appStmt->execute([
        ':flags'  => json_encode($result['flags']),
        ':report' => $report,
        ':id'     => $submissionId,
    ]);

    // Immutable ledger: the eligibility check completing is a milestone-class
    // event (M2 in activity-log-progress-tracker/Milestone Tracker.md). System
    // action at submission time — user_id stays null unless a staff session set it.
    $eligAppId = (int)$pdo->query("SELECT deduplicated_into FROM intake_submissions WHERE id = " . $submissionId)->fetchColumn();
    archr_log_event($pdo, 'eligibility_report_generated', [
        'application_id' => $eligAppId ?: null,
        'summary'        => 'Eligibility check: ' . $report,
        'details'        => [
            'submission_id' => $submissionId,
            'green'         => count($result['flags']['green']),
            'yellow'        => count($result['flags']['yellow']),
            'red'           => count($result['flags']['red']),
        ],
        'source'         => 'system',
    ]);

    return $result;
}

/**
 * Check income eligibility (80% AMI threshold)
 */
function check_income_eligibility(array $submission): array {
    $income = $submission['gross_annual_income'] ?? 0;
    $householdSize = $submission['household_size'] ?? 1;
    
    // Placeholder AMI thresholds (80% AMI for Buncombe County, NC - 2024)
    // These should be loaded from a configuration table
    $amiThresholds = [
        1 => 48800,
        2 => 55800,
        3 => 62750,
        4 => 69700,
        5 => 75300,
        6 => 80900,
        7 => 86500,
        8 => 92050,
    ];
    
    $threshold = $amiThresholds[$householdSize] ?? $amiThresholds[8];
    $passed = $income <= $threshold;
    
    return [
        'passed' => $passed,
        'income' => $income,
        'threshold' => $threshold,
        'household_size' => $householdSize,
        'percentage_of_ami' => $threshold > 0 ? round(($income / $threshold) * 100, 1) : 0,
    ];
}

/**
 * Check geographic eligibility
 */
function check_geographic_eligibility(array $submission): array {
    $city = strtolower($submission['home_city'] ?? '');
    $zip = $submission['home_zip'] ?? '';
    
    // Placeholder service area check
    // Should be loaded from database configuration
    $serviceCities = ['asheville', 'marshall', 'weaverville', 'black mountain', 'leicester'];
    $serviceZips = ['28801', '28803', '28804', '28805', '28806', '28813', '28748'];
    
    $inServiceCity = in_array($city, $serviceCities);
    $inServiceZip = in_array(substr($zip, 0, 5), $serviceZips);
    
    return [
        'passed' => $inServiceCity || $inServiceZip,
        'city' => $submission['home_city'] ?? '',
        'zip' => $zip,
        'in_service_area' => $inServiceCity || $inServiceZip,
    ];
}

/**
 * Normalize a PostgreSQL boolean from PDO (may arrive as 't'/'f' strings).
 */
function _archr_pg_bool($value): ?bool {
    if ($value === null || $value === '') {
        return null;
    }
    if (is_bool($value)) {
        return $value;
    }
    return in_array(strtolower((string)$value), ['t', 'true', '1', 'yes'], true);
}

/**
 * Check ownership requirement
 */
function check_ownership(array $submission): array {
    $ownsHome = _archr_pg_bool($submission['owns_home'] ?? null) ?? false;
    $homeType = $submission['home_type'] ?? '';
    $ownsLot = _archr_pg_bool($submission['owns_lot'] ?? null) ?? true; // Default to true for non-mobile homes
    
    // For mobile homes, must own both home and lot
    if ($homeType === 'mobile') {
        $passed = $ownsHome && $ownsLot;
    } else {
        $passed = $ownsHome;
    }

    return [
        'passed' => $passed,
        'owns_home' => $ownsHome,
        'home_type' => $homeType,
        'owns_lot' => $ownsLot,
    ];
}

/**
 * Calculate priority score based on urgent conditions and demographics
 */
function calculate_priority_score(array $submission): int {
    $score = 0;

    // Urgent conditions (10 points each)
    $urgentFields = [
        'urgent_unable_to_stay',
        'urgent_no_hvac',
        'urgent_no_potable_water',
        'urgent_no_bathroom',
        'urgent_no_kitchen',
        'urgent_open_to_elements',
        'urgent_no_entry',
        'urgent_accessibility',
        'urgent_eviction_risk',
    ];

    foreach ($urgentFields as $field) {
        if (!empty($submission[$field])) {
            $score += 10;
        }
    }

    // Helene-related (20 points)
    if (!empty($submission['helene_related'])) {
        $score += 20;
    }

    // Demographics (5 points each)
    // Note: These come from household_attributes junction table
    // For now, just use a placeholder check

    return min($score, 100); // Cap at 100
}
