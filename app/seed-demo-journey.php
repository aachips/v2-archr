<?php declare(strict_types=1);
/**
 * Demo journey seeder — CLI only.
 *
 * Takes a raw-submission-based application (default: the first unclaimed
 * one) and mock-completes the pipeline through Phase 3 (Planning), using the
 * real library functions so every step lands on the activity ledger:
 *
 *   1. eligibility check        (only if flags missing; ledger auto-wired)
 *   2. claim for Asheville Habitat (archr_claim_application + ledger)
 *   3. milestone timestamps on the org's case through approved_at
 *   4. progress events on the case feed (90-day timer resets)
 *   5. matching ledger entries for each milestone
 *
 * Ledger entries carry details.seeded = true so mock history is always
 * distinguishable from real history. Re-running duplicates the progress
 * events and ledger entries (append-only is honest); pick another
 * application or withdraw first if you want a clean re-run.
 *
 * Usage:  php app/seed-demo-journey.php [application_id]
 */

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "CLI only.\n");
    exit(1);
}

require_once __DIR__ . '/lib/db.php';
require_once __DIR__ . '/lib/applications.php';
require_once __DIR__ . '/lib/eligibility.php';
require_once __DIR__ . '/lib/activity-log.php';

$pdo = archr_pdo();

// ---- pick the application ----
$applicationId = (int)($argv[1] ?? 0);
if ($applicationId === 0) {
    $applicationId = (int)$pdo->query(
        "SELECT a.id FROM applications a
          WHERE a.status IN ('new','active')
            AND NOT EXISTS (SELECT 1 FROM cases c WHERE c.application_id = a.id AND c.claim_status = 'active')
          ORDER BY a.id LIMIT 1"
    )->fetchColumn();
}
if (!$applicationId) {
    fwrite(STDERR, "No unclaimed application found. Pass one: php app/seed-demo-journey.php 4\n");
    exit(1);
}
$app = $pdo->query("SELECT id, status, display_name, placecode, eligibility_flags FROM applications WHERE id = " . $applicationId)->fetch();
if (!$app) {
    fwrite(STDERR, "Application {$applicationId} not found.\n");
    exit(1);
}
echo "Application #{$app['id']} — " . ($app['display_name'] ?? $app['placecode']) . "\n";

// ---- actor + org (realistic attribution) ----
$actor = $pdo->query("SELECT id, full_name FROM system_users WHERE username = 'orgadmin' LIMIT 1")->fetch()
      ?: $pdo->query("SELECT id, full_name FROM system_users WHERE username = 'superadmin' LIMIT 1")->fetch();
if (!$actor) {
    fwrite(STDERR, "No orgadmin/superadmin user found to attribute the seed to.\n");
    exit(1);
}
$org = $pdo->query("SELECT id, organization_name FROM coalition_organizations WHERE organization_code = 'AHFH' LIMIT 1")->fetch()
    ?: $pdo->query("SELECT id, organization_name FROM coalition_organizations WHERE is_active = true ORDER BY id LIMIT 1")->fetch();
if (!$org) {
    fwrite(STDERR, "No organization found.\n");
    exit(1);
}
$actorId = (int)$actor['id'];
$actorName = (string)$actor['full_name'];

// ---- 1. eligibility (skip when flags already stored) ----
$flagsRaw = (string)($app['eligibility_flags'] ?? '');
if ($flagsRaw === '' || $flagsRaw === '[]' || $flagsRaw === '{}') {
    $subs = $pdo->query("SELECT id FROM intake_submissions WHERE deduplicated_into = " . $applicationId)->fetchAll(PDO::FETCH_COLUMN);
    foreach ($subs as $sid) {
        check_eligibility($pdo, (int)$sid);
    }
    echo "1. eligibility checked for " . count($subs) . " submission(s) (ledger: eligibility_report_generated)\n";
} else {
    echo "1. eligibility flags already present — skipped\n";
}

// ---- 2. claim for the org ----
$caseId = (int)$pdo->query(
    "SELECT id FROM cases WHERE application_id = {$applicationId} AND organization_id = " . (int)$org['id'] . " AND claim_status = 'active' ORDER BY id DESC LIMIT 1"
)->fetchColumn();
if (!$caseId) {
    $caseId = archr_claim_application($pdo, $applicationId, (int)$org['id'], $actorId);
    archr_log_event($pdo, 'application_claimed', [
        'application_id'  => $applicationId,
        'case_id'         => $caseId,
        'organization_id' => (int)$org['id'],
        'user_id'         => $actorId,
        'user_name'       => $actorName,
        'summary'         => 'Case claimed by ' . $org['organization_name'] . ' (demo journey seed)',
        'details'         => ['seeded' => true],
        'source'          => 'system',
    ]);
    echo "2. claimed for {$org['organization_name']} — case #{$caseId} (ledger: application_claimed)\n";
} else {
    echo "2. already claimed by {$org['organization_name']} — case #{$caseId}\n";
}

// ---- 3. milestone timestamps -> Phase 3 (Planning) ----
$offsets = [
    'intake_completed_at'       => '-4 days',
    'assessment_scheduled_at'   => '-3 days',
    'assessment_completed_at'   => '-1 day',
    'approved_at'               => '-2 hours',
];
$set = [];
foreach ($offsets as $col => $when) {
    $set[] = "$col = CURRENT_TIMESTAMP + INTERVAL '$when'";
}
$pdo->exec("UPDATE cases SET " . implode(', ', $set) . " WHERE id = " . $caseId);
echo "3. milestones set through Planning (approved_at) on case #{$caseId}\n";

// ---- 4. progress events (per-case feed + 90-day timer) ----
$events = [
    ['comm_logged',       'Initial contact: spoke with the applicant, confirmed assessment interest.'],
    ['assessment_event',  'Assessment scheduled with the assessor.'],
    ['assessment_event',  'Assessment completed; before-photos collected.'],
    ['progress_task',     'Repair scope and task list drafted for planning.'],
];
$evStmt = $pdo->prepare("SELECT log_progress_event(:case, :type, :descr, :by, 't', 'user')");
foreach ($events as [$type, $descr]) {
    $evStmt->execute([':case' => $caseId, ':type' => $type, ':descr' => $descr, ':by' => $actorId]);
}
echo "4. " . count($events) . " progress events logged on case #{$caseId}\n";

// ---- 5. matching milestone entries on the ledger ----
$milestones = [
    ['intake_completed',       'Intake completed — contact made, claim active, assessor assigned.'],
    ['assessment_scheduled',   'Assessment scheduled.'],
    ['assessment_completed',   'Assessment completed.'],
    ['application_approved',   'Application approved — moving to Planning.'],
];
foreach ($milestones as [$action, $summary]) {
    archr_log_event($pdo, $action, [
        'application_id'  => $applicationId,
        'case_id'         => $caseId,
        'organization_id' => (int)$org['id'],
        'user_id'         => $actorId,
        'user_name'       => $actorName,
        'summary'         => $summary,
        'details'         => ['seeded' => true],
        'source'          => 'system',
    ]);
}
echo "5. " . count($milestones) . " milestone entries on the ledger\n\n";
echo "Open:  app/case.php?id={$caseId}\n";
echo "Then:  Super Admin → Audit Trail — every step above is on the ledger.\n";