<?php
declare(strict_types=1);

/* -----------------------------------------------------------------
 * Application lifecycle library.
 *
 * Implements "ARCHR Core Terminology and Operational Logic" (2026-08-17):
 *
 *   SUBMISSION  raw form response            (intake_submissions)
 *   APPLICATION deduplicated entry per placecode (applications)
 *   CASE        organization-specific claim  (cases.application_id/organization_id)
 *   PROJECT     batch of repairs             (work_orders)
 *   REPAIR TASK smallest unit of work        (work_tasks)
 *
 * Behavior here is a thin, validated wrapper over the functions in
 * sql/application-lifecycle.sql (deduplicate_submissions, claim_application,
 * log_progress_event, expire_stale_claims, validate_status_transition,
 * set_application_status). Eligibility is flags-only: the system never
 * auto-denies an applicant; humans make final determinations.
 * ----------------------------------------------------------------- */

require_once __DIR__ . '/db.php';

/** The six application statuses defined by the terminology doc. */
function archr_application_statuses(): array {
    return ['new', 'active', 'concluded', 'terminated', 'withdrawn', 'expired'];
}

/**
 * Canonical termination checkbox reasons. Reads the single source of truth
 * (canonical_termination_reasons() in the database); falls back to a local
 * copy when the DB is unavailable.
 */
function archr_termination_reasons(?PDO $pdo = null): array {
    $fallback = [
        'Income above program limits',
        'Property outside service area',
        'Damage not Helene-related',
        'Applicant unresponsive after 3 contact attempts',
        'Duplicate application',
        'Previously served by another organization',
        'Applicant declined services',
        'Unable to verify homeownership',
        'Other (please specify)',
    ];
    if ($pdo !== null) {
        try {
            $rows = $pdo->query(
                "SELECT jsonb_array_elements_text(to_jsonb(canonical_termination_reasons()))"
            )->fetchAll(PDO::FETCH_COLUMN);
            if ($rows) {
                return array_map('strval', $rows);
            }
        } catch (Throwable $e) {
            error_log('[applications] canonical_termination_reasons() unavailable: ' . $e->getMessage());
        }
    }
    return $fallback;
}

/**
 * Derive an 8-character Placecode from a free-form address.
 * (Canonical implementation — sql archr_generate_placecode() mirrors this.)
 *
 * Rule: leading address number + enough letters from the street name to make
 * 8 characters total, uppercased. Unit numbers are appended in brackets.
 *
 *   "145 Lakewood"           -> "145LAKEW"
 *   "145 Lakewood Apt 2"     -> "145LAKEW[2]"
 *   "42 Evergreen Terrace"   -> "42EVERGR"
 */
function archr_placecode(?string $address): ?string {
    if ($address === null || trim($address) === '') {
        return null;
    }

    $addr = strtoupper(trim($address));

    // Extract unit/apartment number and remove it from the address.
    $unit = null;
    if (preg_match('/\b(?:APT|UNIT|SUITE|STE|#)\s*(\w+)\b/', $addr, $m)) {
        $unit = $m[1];
        $addr = preg_replace('/\s*(?:APT|UNIT|SUITE|STE|#)\s*\w+/', '', $addr);
    }

    // Extract leading number (supports ranges like 123-125).
    $number = '';
    if (preg_match('/^([0-9]+(?:-[0-9]+)?)/', $addr, $m)) {
        $number = $m[1];
    }

    // Remove the number, directionals, and any remaining non-letters from the street portion.
    $street = preg_replace('/^[0-9]+(?:-[0-9]+)?\s*/', '', $addr);
    $street = preg_replace('/\b(?:NORTH|SOUTH|EAST|WEST|NORTHEAST|NORTHWEST|SOUTHEAST|SOUTHWEST|NE|NW|SE|SW|N|S|E|W)\b/', '', $street);
    $street = preg_replace('/[^A-Z]/', '', $street);

    $lettersNeeded = max(0, 8 - strlen($number));
    $letters = substr($street, 0, $lettersNeeded);

    $code = substr($number . $letters, 0, 8);
    if ($unit !== null) {
        $code .= '[' . $unit . ']';
    }

    return $code === '' ? null : $code;
}

/** Human-readable label, e.g. "42 Cherry Street - Asheville". */
function archr_application_display_name(?string $address, ?string $city): ?string {
    $parts = array_filter([trim((string)$address), trim((string)$city)], fn($s) => $s !== '');
    return $parts ? implode(' - ', $parts) : null;
}

/** Best available human-facing reference for a case/application row. */
function archr_case_display_name(array $row): string {
    return $row['display_name'] ?? $row['placecode'] ?? $row['case_number'] ?? ('#' . ($row['id'] ?? $row['case_id'] ?? '?'));
}
/* ---------------- operational wrappers (SQL functions) ---------------- */

/**
 * Consolidate a submission into its application (find-or-create by placecode).
 * Returns the application id.
 */
function archr_deduplicate_application(PDO $pdo, int $submissionId): int {
    $stmt = $pdo->prepare('SELECT deduplicate_submissions(:sid)');
    $stmt->execute([':sid' => $submissionId]);
    return (int)$stmt->fetchColumn();
}

/**
 * Claim an application for an organization. Creates (or reactivates) the
 * org-specific case, starts/resets the 90-day progress timer, and moves the
 * application to active. Returns the org case id.
 */
function archr_claim_application(PDO $pdo, int $applicationId, int $organizationId, int $claimedBy): int {
    $stmt = $pdo->prepare('SELECT claim_application(:app, :org, :by)');
    $stmt->execute([':app' => $applicationId, ':org' => $organizationId, ':by' => $claimedBy]);
    return (int)$stmt->fetchColumn();
}

/**
 * Log an event against a case. Progress events (tasks, communications,
 * milestones, documents) reset the claiming org 90-day cooldown timer;
 * pass $isProgress = false for administrative entries that must not extend
 * the claim (releases, withdrawals, expirations).
 * Returns the progress_events id.
 */
function archr_log_progress_event(
    PDO $pdo,
    int $caseId,
    string $eventType,
    string $description,
    ?int $performedBy,
    bool $isProgress = true,
    string $source = 'user'
): int {
    $stmt = $pdo->prepare('SELECT log_progress_event(:case, :type, :descr, :by, :progress, :source)');
    $stmt->execute([
        ':case'     => $caseId,
        ':type'     => $eventType,
        ':descr'    => $description,
        ':by'       => $performedBy,
        ':progress' => $isProgress ? 't' : 'f',
        ':source'   => $source,
    ]);
    return (int)$stmt->fetchColumn();
}

/**
 * Expire every claim whose 90-day window has elapsed without progress.
 * Applications with no remaining active claims become "expired" and can be
 * re-claimed by another organization. Returns the expired case rows.
 */
function archr_expire_stale_claims(PDO $pdo): array {
    return $pdo->query('SELECT * FROM expire_stale_claims()')->fetchAll();
}

/** PHP mirror of the doc transition rules (fast check without a DB call). */
function archr_validate_status_transition(string $currentStatus, string $newStatus): bool {
    return match ($currentStatus) {
        // Deliberate extensions beyond the doc: new and expired may also be
        // withdrawn / terminated so a never-claimed or lapsed application can
        // still be closed by a human (an applicant can withdraw at any point).
        'new'     => in_array($newStatus, ['active', 'withdrawn', 'terminated'], true),
        'active'  => in_array($newStatus, ['concluded', 'terminated', 'withdrawn', 'expired'], true),
        'expired' => in_array($newStatus, ['active', 'withdrawn', 'terminated'], true),
        default   => false, // concluded / terminated / withdrawn are terminal
    };
}

/**
 * Change an application status with the doc human-decision requirements:
 *   - terminated requires at least one canonical checkbox reason
 *     ("Other (please specify)" additionally requires a reason note)
 *   - withdrawn requires a human contact note in $reason
 * Throws InvalidArgumentException on any rule violation.
 */
function archr_set_application_status(
    PDO $pdo,
    int $applicationId,
    string $newStatus,
    ?string $reason = null,
    array $checkboxes = [],
    ?int $changedBy = null
): bool {
    if (!in_array($newStatus, archr_application_statuses(), true)) {
        throw new InvalidArgumentException("Unknown application status: $newStatus");
    }

    $checkboxes = array_values(array_filter(array_map('strval', $checkboxes), fn($r) => trim($r) !== ''));
    $reason = ($reason !== null && trim($reason) !== '') ? trim($reason) : null;

    if ($newStatus === 'terminated') {
        if (!$checkboxes) {
            throw new InvalidArgumentException('Terminating an application requires at least one checkbox reason.');
        }
        $unknown = array_diff($checkboxes, archr_termination_reasons($pdo));
        if ($unknown) {
            throw new InvalidArgumentException('Unknown termination reason(s): ' . implode(', ', $unknown));
        }
        if (in_array('Other (please specify)', $checkboxes, true) && $reason === null) {
            throw new InvalidArgumentException('"Other (please specify)" requires a reason note.');
        }
    }
    if ($newStatus === 'withdrawn' && $reason === null) {
        throw new InvalidArgumentException('Withdrawal requires a human contact note (who confirmed, how, when).');
    }

    // Checkbox list -> Postgres text[] via json aggregate (safe for quoting).
    $stmt = $pdo->prepare(
        "SELECT set_application_status(
            :app, :status, :reason,
            CASE WHEN :has_cb::boolean THEN (SELECT array_agg(x) FROM json_array_elements_text(:cb::json) AS x) ELSE NULL END,
            :by
         )"
    );
    $stmt->bindValue(':app', $applicationId, PDO::PARAM_INT);
    $stmt->bindValue(':status', $newStatus);
    $stmt->bindValue(':reason', $reason);
    $stmt->bindValue(':has_cb', $checkboxes ? 't' : 'f');
    $stmt->bindValue(':cb', json_encode($checkboxes));
    $stmt->bindValue(':by', $changedBy, $changedBy === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
    $stmt->execute();
    return (bool)$stmt->fetchColumn();
}
/* ---------------- read side (doc-shaped responses) ---------------- */

/**
 * Full application payload matching the terminology doc's example
 * GET /api/applications/:id response: the application, its submission ids,
 * eligibility flags, and every organization case (with claim status,
 * 90-day countdown, projects and repair tasks).
 */
function archr_get_application(PDO $pdo, int $applicationId): ?array {
    $stmt = $pdo->prepare(
        "SELECT a.*, to_jsonb(a.terminated_reason_checkboxes) AS terminated_reason_checkboxes_json
           FROM applications a WHERE a.id = :id LIMIT 1"
    );
    $stmt->execute([':id' => $applicationId]);
    $app = $stmt->fetch();
    if (!$app) {
        return null;
    }

    unset($app['terminated_reason_checkboxes']);
    $app['terminated_reason_checkboxes'] = json_decode((string)$app['terminated_reason_checkboxes_json'], true) ?: [];
    unset($app['terminated_reason_checkboxes_json']);
    $app['eligibility_flags'] = json_decode((string)($app['eligibility_flags'] ?? ''), true)
        ?: ['green' => [], 'yellow' => [], 'red' => []];

    // All submissions consolidated into this application.
    $sub = $pdo->prepare('SELECT id FROM intake_submissions WHERE deduplicated_into = :id ORDER BY id');
    $sub->execute([':id' => $applicationId]);
    $app['submission_ids'] = array_map('intval', $sub->fetchAll(PDO::FETCH_COLUMN));

    // Organization cases (one per claiming org) with the 90-day countdown.
    $cases = $pdo->prepare(
        "SELECT c.id, c.case_number, c.organization_id, o.organization_name AS organization,
                c.claim_status, c.claimed_at, c.claim_expires_at, c.last_progress_at,
                c.progress_events_count, c.placecode, c.project_code,
                cs.status_code AS case_status, cs.status_name AS case_status_name,
                CASE WHEN c.claim_status = 'active'
                     THEN GREATEST(0, (EXTRACT(EPOCH FROM (c.claim_expires_at - CURRENT_TIMESTAMP)) / 86400)::int)
                END AS days_until_expiry
           FROM cases c
           LEFT JOIN coalition_organizations o ON o.id = c.organization_id
           LEFT JOIN case_statuses cs ON cs.id = c.status_id
          WHERE c.application_id = :id
          ORDER BY c.id"
    );
    $cases->execute([':id' => $applicationId]);
    $caseRows = $cases->fetchAll();

    // Projects (work_orders) and repair tasks (work_tasks) per case.
    $projStmt = $pdo->prepare(
        "SELECT wo.id, wo.work_order_number AS name, wo.status,
                wo.approved_budget AS budget_approved, wo.current_cost AS budget_actual,
                wo.scheduled_start_date AS start_date, wo.scheduled_end_date AS estimated_completion,
                wo.actual_end_date AS actual_completion
           FROM work_orders wo WHERE wo.case_id = :case ORDER BY wo.id"
    );
    $taskStmt = $pdo->prepare(
        "SELECT wt.id, wt.description, wt.status, wt.due_date, wt.completed_at,
                u.full_name AS assigned_to
           FROM work_tasks wt
           LEFT JOIN system_users u ON u.id = wt.assigned_to_id
          WHERE wt.work_order_id = :wo ORDER BY wt.id"
    );

    foreach ($caseRows as &$caseRow) {
        $projStmt->execute([':case' => (int)$caseRow['id']]);
        $projects = $projStmt->fetchAll();
        foreach ($projects as &$project) {
            $taskStmt->execute([':wo' => (int)$project['id']]);
            $project['repair_tasks'] = $taskStmt->fetchAll();
        }
        unset($project);
        $caseRow['projects'] = $projects;
    }
    unset($caseRow);
    $app['cases'] = $caseRows;

    return ['application' => $app];
}

/** Same payload, addressed by placecode instead of numeric id. */
function archr_get_application_by_placecode(PDO $pdo, string $placecode): ?array {
    $stmt = $pdo->prepare('SELECT id FROM applications WHERE placecode = :pc LIMIT 1');
    $stmt->execute([':pc' => strtoupper(trim($placecode))]);
    $id = $stmt->fetchColumn();
    return $id ? archr_get_application($pdo, (int)$id) : null;
}

/**
 * Applications visible to the given organizations: any application one of
 * the orgs holds (or held) a case on, plus unclaimed / expired applications
 * that are claimable. Super admins ($orgIds = null) see everything.
 * Ordered by most recent activity.
 */
function archr_list_applications(PDO $pdo, ?array $orgIds = null, ?string $status = null, int $limit = 100): array {
    $where = [];
    $params = [];

    if ($orgIds !== null) {
        if (!$orgIds) {
            return [];
        }
        $in = implode(',', array_map('intval', $orgIds));
        $where[] = "(
            EXISTS (SELECT 1 FROM cases c WHERE c.application_id = a.id AND c.organization_id IN ($in))
            OR NOT EXISTS (SELECT 1 FROM cases c WHERE c.application_id = a.id AND c.claim_status = 'active')
        )";
    }
    if ($status !== null && in_array($status, archr_application_statuses(), true)) {
        $where[] = 'a.status = :status';
        $params[':status'] = $status;
    }

    $sql = "SELECT a.id, a.placecode, a.display_name, a.status,
                   a.property_address, a.property_city, a.property_state, a.property_zip,
                   a.applicant_first_name, a.applicant_last_name, a.last_activity_at,
                   (SELECT COUNT(*) FROM cases c WHERE c.application_id = a.id AND c.claim_status = 'active') AS active_case_count,
                   (SELECT MIN(c.claim_expires_at) FROM cases c WHERE c.application_id = a.id AND c.claim_status = 'active') AS next_claim_expires_at
              FROM applications a"
        . ($where ? ' WHERE ' . implode(' AND ', $where) : '')
        . ' ORDER BY a.last_activity_at DESC LIMIT :lim';

    $stmt = $pdo->prepare($sql);
    foreach ($params as $k => $v) {
        $stmt->bindValue($k, $v);
    }
    $stmt->bindValue(':lim', max(1, min(500, $limit)), PDO::PARAM_INT);
    $stmt->execute();
    return $stmt->fetchAll();
}

/**
 * Update the application-layer applicant contact fields — the editable
 * working copy in the submission -> application -> case lifecycle (the raw
 * submission is never modified). Reads prefer the application copy
 * (archr_load_case COALESCEs these over the submission's).
 *
 * @param array $fields first_name / last_name / email / phone (all optional;
 *                      only present keys are considered)
 * @return array change map: applications column => ['old' =>, 'new' =>]
 *         (empty when nothing actually changed)
 */
function archr_update_application_contact(PDO $pdo, int $applicationId, array $fields): array {
    $stmt = $pdo->prepare("SELECT applicant_first_name, applicant_last_name, applicant_email, applicant_phone FROM applications WHERE id = :id");
    $stmt->execute([':id' => $applicationId]);
    $current = $stmt->fetch();
    if (!$current) {
        throw new InvalidArgumentException('Application not found.');
    }

    $allowed = [
        'first_name' => 'applicant_first_name',
        'last_name'  => 'applicant_last_name',
        'email'      => 'applicant_email',
        'phone'      => 'applicant_phone',
    ];
    $changed = [];
    foreach ($allowed as $key => $column) {
        if (!array_key_exists($key, $fields)) {
            continue;
        }
        $new = trim((string)$fields[$key]);
        $old = (string)($current[$column] ?? '');
        if ($new !== $old) {
            $changed[$column] = ['old' => $old, 'new' => $new];
        }
    }

    if ($changed) {
        $set = [];
        $params = [':id' => $applicationId];
        foreach ($changed as $column => $pair) {
            $set[] = "$column = :$column";
            $params[":$column"] = $pair['new'] === '' ? null : $pair['new'];
        }
        $pdo->prepare("UPDATE applications SET " . implode(', ', $set) . ", updated_at = CURRENT_TIMESTAMP WHERE id = :id")
            ->execute($params);
    }
    return $changed;
}