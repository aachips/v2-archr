<?php
declare(strict_types=1);

/* -----------------------------------------------------------------
 * Case review data loaders and helpers.
 * ----------------------------------------------------------------- */

require_once __DIR__ . '/db.php';
require_once __DIR__ . '/applications.php';

function archr_load_case(PDO $pdo, int $caseId): ?array {
    $stmt = $pdo->prepare("
        SELECT c.*,
               COALESCE(NULLIF(ap.applicant_first_name, ''), s.applicant_first_name) AS applicant_first_name,
               COALESCE(NULLIF(ap.applicant_last_name, ''), s.applicant_last_name) AS applicant_last_name,
               s.applicant_dob, s.applicant_dob_unknown,
               COALESCE(NULLIF(ap.applicant_email, ''), s.contact_email) AS contact_email,
               s.home_phone, COALESCE(NULLIF(ap.applicant_phone, ''), s.cell_phone) AS cell_phone,
               s.home_address, s.home_city, s.home_state, s.home_zip,
               s.mail_address, s.mail_city, s.mail_state, s.mail_zip,
               s.household_size, s.household_adults, s.gross_annual_income, s.has_income,
               s.owns_home, s.owns_lot, s.is_primary_residence, s.home_type, s.year_built, s.move_in_date,
               s.helene_related, s.additional_repair_details, s.submitted_at, s.submission_status,
               s.urgent_unable_to_stay, s.urgent_no_hvac, s.urgent_no_potable_water,
               s.urgent_no_bathroom, s.urgent_no_kitchen, s.urgent_open_to_elements,
               s.urgent_no_entry, s.urgent_accessibility, s.urgent_other_issue, s.urgent_eviction_risk,
               s.fema_claim_filed, s.fema_outcome, s.insurance_claim_filed, s.insurance_outcome,
               cs.status_code, cs.status_name, cs.status_sequence,
               a.anchor_id, a.current_status AS anchor_status, a.is_eligible AS anchor_is_eligible,
               a.eligibility_score AS anchor_eligibility_score, a.assigned_at AS anchor_assigned_at,
               a.assigned_organization_id AS anchor_assigned_org_id,
               a.project_code AS anchor_project_code, a.placecode AS anchor_placecode,
               ap.display_name, ap.status AS application_status, ap.eligibility_flags,
               cw.full_name AS caseworker_name, cw.email AS caseworker_email,
               q.status AS queue_status, q.queued_at, q.priority_score, q.assigned_at AS queue_assigned_at
          FROM cases c
          JOIN intake_submissions s ON s.id = c.submission_id
          LEFT JOIN case_statuses cs ON cs.id = c.status_id
          LEFT JOIN application_anchor a ON a.submission_id = c.submission_id
          LEFT JOIN applications ap ON ap.id = c.application_id
          LEFT JOIN system_users cw ON cw.id = c.assigned_caseworker_id
          LEFT JOIN review_queue q ON q.submission_id = c.submission_id
         WHERE c.id = :id
         LIMIT 1
    ");
    $stmt->execute([':id' => $caseId]);
    return $stmt->fetch() ?: null;
}

function archr_case_claimed_org(PDO $pdo, int $caseId): ?array {
    // cases.organization_id (per-org claim) is authoritative; case_claims and
    // application_anchor remain as fallbacks for legacy rows.
    $stmt = $pdo->prepare("
        SELECT o.id, o.organization_code, o.organization_name
          FROM (
              SELECT COALESCE(
                  (SELECT organization_id FROM cases WHERE id = :id LIMIT 1),
                  (SELECT claimed_by_org_id FROM case_claims WHERE case_id = :id LIMIT 1),
                  (SELECT assigned_organization_id FROM application_anchor WHERE submission_id = (SELECT submission_id FROM cases WHERE id = :id) LIMIT 1)
              ) AS org_id
          ) x
          LEFT JOIN coalition_organizations o ON o.id = x.org_id
    ");
    $stmt->execute([':id' => $caseId]);
    return $stmt->fetch() ?: null;
}

function archr_job_code(?array $caseOrg, ?string $projectCode): string {
    if (!$projectCode) return '—';
    $acronym = $caseOrg['organization_code'] ?? 'UNCLAIMED';
    return '[' . $acronym . ']-' . $projectCode;
}

function archr_case_repairs(PDO $pdo, int $submissionId): array {
    $stmt = $pdo->prepare("
        SELECT rc.category_label, rc.category_code
          FROM submission_repair_categories sr
          JOIN repair_categories rc ON rc.id = sr.category_id
         WHERE sr.submission_id = :id
         ORDER BY rc.id
    ");
    $stmt->execute([':id' => $submissionId]);
    return $stmt->fetchAll();
}

function archr_case_household_attrs(PDO $pdo, int $submissionId): array {
    $stmt = $pdo->prepare("
        SELECT ha.attribute_name
          FROM submission_household_attributes sh
          JOIN household_attributes ha ON ha.id = sh.attribute_id
         WHERE sh.submission_id = :id
         ORDER BY ha.id
    ");
    $stmt->execute([':id' => $submissionId]);
    return array_column($stmt->fetchAll(), 'attribute_name');
}

function archr_case_eligibility(PDO $pdo, int $submissionId): array {
    $stmt = $pdo->prepare("
        SELECT er.match_score, er.is_eligible, o.organization_name, o.organization_code
          FROM eligibility_results er
          JOIN coalition_organizations o ON o.id = er.organization_id
         WHERE er.submission_id = :id
         ORDER BY er.match_score DESC
    ");
    $stmt->execute([':id' => $submissionId]);
    return $stmt->fetchAll();
}

function archr_case_status_history(PDO $pdo, int $caseId): array {
    $stmt = $pdo->prepare("
        SELECT csh.*, fs.status_name AS from_status, ts.status_name AS to_status, u.full_name AS changed_by_name
          FROM case_status_history csh
          LEFT JOIN case_statuses fs ON fs.id = csh.from_status_id
          LEFT JOIN case_statuses ts ON ts.id = csh.to_status_id
          LEFT JOIN system_users u ON u.id = csh.changed_by
         WHERE csh.case_id = :id
         ORDER BY csh.changed_at DESC
    ");
    $stmt->execute([':id' => $caseId]);
    return $stmt->fetchAll();
}

function archr_case_assignment_log(PDO $pdo, int $submissionId): array {
    $stmt = $pdo->prepare("
        SELECT al.*, aa.organization_id, o.organization_name, ou.full_name AS performed_by_name
          FROM assignment_log al
          JOIN application_assignments aa ON aa.id = al.assignment_id
          LEFT JOIN coalition_organizations o ON o.id = aa.organization_id
          LEFT JOIN organization_users ou ON ou.id = al.performed_by
         WHERE aa.submission_id = :id
         ORDER BY al.performed_at DESC
    ");
    $stmt->execute([':id' => $submissionId]);
    return $stmt->fetchAll();
}

function archr_case_tasks(PDO $pdo, int $caseId): array {
    $stmt = $pdo->prepare("
        SELECT wt.*, wo.work_order_number, u.full_name AS assigned_to_name
          FROM work_orders wo
          LEFT JOIN work_tasks wt ON wt.work_order_id = wo.id
          LEFT JOIN system_users u ON u.id = wt.assigned_to_id
         WHERE wo.case_id = :id
         ORDER BY wo.created_at DESC, wt.created_at DESC
    ");
    $stmt->execute([':id' => $caseId]);
    return $stmt->fetchAll();
}

function archr_case_documents(PDO $pdo, int $caseId): array {
    $stmt = $pdo->prepare("
        SELECT cd.*, dc.category_name, dc.category_code, ds.status_code, u.full_name AS uploaded_by_name
          FROM case_documents cd
          LEFT JOIN document_categories dc ON dc.id = cd.category_id
          LEFT JOIN document_statuses ds ON ds.id = cd.status_id
          LEFT JOIN system_users u ON u.id = cd.uploaded_by
         WHERE cd.case_id = :id
         ORDER BY cd.uploaded_at DESC
    ");
    $stmt->execute([':id' => $caseId]);
    return $stmt->fetchAll();
}

function archr_case_repair_requests(PDO $pdo, int $submissionId): array {
    $stmt = $pdo->prepare("
        SELECT id, repair_need, priority, sort_order
          FROM repair_requests
         WHERE submission_id = :id
         ORDER BY sort_order NULLS LAST, priority NULLS LAST, id
    ");
    $stmt->execute([':id' => $submissionId]);
    return $stmt->fetchAll();
}

function archr_case_repair_details(PDO $pdo, int $submissionId): array {
    $stmt = $pdo->prepare("
        SELECT d.category_id, d.details_text, d.water_source,
               d.heating_woodstove, d.heating_gas_propane, d.heating_electric, d.heating_kerosene,
               rc.category_label, rc.category_code
          FROM repair_category_details d
          JOIN repair_categories rc ON rc.id = d.category_id
         WHERE d.submission_id = :id
         ORDER BY d.category_id
    ");
    $stmt->execute([':id' => $submissionId]);
    return $stmt->fetchAll();
}

function archr_case_repair_claims(PDO $pdo, int $caseId): array {
    $stmt = $pdo->prepare("
        SELECT crc.id, crc.repair_request_id, crc.organization_id, crc.claimed_at,
               crc.released_at, crc.notes,
               o.organization_name, o.organization_code,
               u.full_name AS claimed_by_name
          FROM case_repair_claims crc
          LEFT JOIN coalition_organizations o ON o.id = crc.organization_id
          LEFT JOIN system_users u ON u.id = crc.claimed_by
         WHERE crc.case_id = :id
         ORDER BY crc.claimed_at
    ");
    $stmt->execute([':id' => $caseId]);
    return $stmt->fetchAll();
}

/**
 * All organization cases attached to one application (one per claiming org),
 * with claim status and the 90-day countdown.
 */
function archr_application_cases(PDO $pdo, int $applicationId): array {
    $stmt = $pdo->prepare("
        SELECT c.id, c.case_number, c.organization_id, o.organization_name, o.organization_code,
               c.claim_status, c.claimed_at, c.claim_expires_at, c.last_progress_at,
               c.progress_events_count,
               cs.status_code, cs.status_name,
               CASE WHEN c.claim_status = 'active'
                    THEN GREATEST(0, (EXTRACT(EPOCH FROM (c.claim_expires_at - CURRENT_TIMESTAMP)) / 86400)::int)
               END AS days_until_expiry
          FROM cases c
          LEFT JOIN coalition_organizations o ON o.id = c.organization_id
          LEFT JOIN case_statuses cs ON cs.id = c.status_id
         WHERE c.application_id = :app
         ORDER BY c.organization_id IS NULL, c.id
    ");
    $stmt->execute([':app' => $applicationId]);
    return $stmt->fetchAll();
}

/**
 * Repair requests across ALL submissions consolidated into an application
 * (repair needs are shared at the application layer).
 */
function archr_application_repair_requests(PDO $pdo, int $applicationId): array {
    $stmt = $pdo->prepare("
        SELECT rr.id, rr.repair_need, rr.priority, rr.sort_order, rr.submission_id
          FROM repair_requests rr
          JOIN intake_submissions s ON s.id = rr.submission_id
         WHERE s.deduplicated_into = :app
         ORDER BY rr.sort_order NULLS LAST, rr.priority NULLS LAST, rr.id
    ");
    $stmt->execute([':app' => $applicationId]);
    return $stmt->fetchAll();
}

/**
 * Repair claims across ALL cases of an application (any org) — a repair row
 * may have at most one active claim coalition-wide.
 */
function archr_application_repair_claims(PDO $pdo, int $applicationId): array {
    $stmt = $pdo->prepare("
        SELECT crc.id, crc.case_id, crc.repair_request_id, crc.organization_id, crc.claimed_at,
               crc.released_at, crc.notes,
               o.organization_name, o.organization_code,
               u.full_name AS claimed_by_name
          FROM case_repair_claims crc
          JOIN cases c ON c.id = crc.case_id
          LEFT JOIN coalition_organizations o ON o.id = crc.organization_id
          LEFT JOIN system_users u ON u.id = crc.claimed_by
         WHERE c.application_id = :app
         ORDER BY crc.claimed_at
    ");
    $stmt->execute([':app' => $applicationId]);
    return $stmt->fetchAll();
}

function archr_case_withdrawal(PDO $pdo, int $caseId): ?array {
    $stmt = $pdo->prepare("
        SELECT cw.*, u.full_name AS withdrawn_by_name
          FROM case_withdrawals cw
          LEFT JOIN system_users u ON u.id = cw.withdrawn_by
         WHERE cw.case_id = :id
         ORDER BY cw.withdrawn_at DESC
         LIMIT 1
    ");
    $stmt->execute([':id' => $caseId]);
    return $stmt->fetch() ?: null;
}

function archr_ensure_case(PDO $pdo, int $submissionId): int {
    // Consolidate the submission into its application first so the case is
    // anchored to the deduplicated application record.
    $applicationId = archr_deduplicate_application($pdo, $submissionId);

    $stmt = $pdo->prepare('SELECT id FROM cases WHERE submission_id = :sid ORDER BY id LIMIT 1');
    $stmt->execute([':sid' => $submissionId]);
    $existing = $stmt->fetchColumn();
    if ($existing) {
        return (int)$existing;
    }

    // Reuse the application's unclaimed intake case when one already exists
    // (a duplicate submission for the same placecode must not spawn another).
    $unclaimed = $pdo->prepare('SELECT id FROM cases WHERE application_id = :app AND organization_id IS NULL ORDER BY id LIMIT 1');
    $unclaimed->execute([':app' => $applicationId]);
    $existing = $unclaimed->fetchColumn();
    if ($existing) {
        return (int)$existing;
    }

    $anchorStmt = $pdo->prepare('SELECT project_code, placecode FROM application_anchor WHERE submission_id = :sid');
    $anchorStmt->execute([':sid' => $submissionId]);
    $anchor = $anchorStmt->fetch();

    $statusId = (int)$pdo->query("SELECT id FROM case_statuses WHERE status_code = 'PENDING_REVIEW' LIMIT 1")->fetchColumn();

    $insert = $pdo->prepare("
        INSERT INTO cases (submission_id, application_id, status_id, project_code, placecode, created_by, updated_by)
        VALUES (:sid, :app, :status_id, :project_code, :placecode, NULL, NULL)
        RETURNING id
    ");
    $insert->execute([
        ':sid' => $submissionId,
        ':app' => $applicationId,
        ':status_id' => $statusId,
        ':project_code' => $anchor['project_code'] ?? null,
        ':placecode' => $anchor['placecode'] ?? null,
    ]);
    return (int)$insert->fetchColumn();
}
