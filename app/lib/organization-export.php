<?php
declare(strict_types=1);

/* -----------------------------------------------------------------
 * Organization data export / retention helpers.
 *
 * Gathers every record associated with a coalition organization so
 * Super-Admins can download a retention archive before deletion.
 * ----------------------------------------------------------------- */

function archr_organization_association_counts(PDO $pdo, int $orgId): array {
    $counts = [
        'organization_users'       => 0,
        'user_role_assignments'    => 0,
        'organization_eligibility_rules' => 0,
        'eligibility_results'      => 0,
        'organization_metrics'     => 0,
        'funding_sources'          => 0,
        'application_assignments'  => 0,
        'review_queue'             => 0,
        'case_claims'              => 0,
        'reimbursement_requests'   => 0,
        'bursar_action_audit'      => 0,
    ];

    $stmts = [
        'organization_users'       => 'SELECT COUNT(*) FROM organization_users WHERE organization_id = :org',
        'user_role_assignments'    => 'SELECT COUNT(*) FROM user_role_assignments WHERE organization_id = :org',
        'organization_eligibility_rules' => 'SELECT COUNT(*) FROM organization_eligibility_rules WHERE organization_id = :org',
        'eligibility_results'      => 'SELECT COUNT(*) FROM eligibility_results WHERE organization_id = :org',
        'organization_metrics'   => 'SELECT COUNT(*) FROM organization_metrics WHERE organization_id = :org',
        'funding_sources'          => 'SELECT COUNT(*) FROM funding_sources WHERE organization_id = :org',
        'application_assignments'  => 'SELECT COUNT(*) FROM application_assignments WHERE organization_id = :org',
        'review_queue'             => 'SELECT COUNT(*) FROM review_queue WHERE organization_id = :org',
        'case_claims'              => 'SELECT COUNT(*) FROM case_claims WHERE claimed_by_org_id = :org',
        'reimbursement_requests'   => 'SELECT COUNT(*) FROM reimbursement_requests WHERE organization_id = :org',
    ];

    foreach ($stmts as $key => $sql) {
        $stmt = $pdo->prepare($sql);
        $stmt->execute([':org' => $orgId]);
        $counts[$key] = (int)$stmt->fetchColumn();
    }

    // bursar audit table may not exist in every deployment.
    $tableExists = (bool)$pdo->query("
        SELECT 1 FROM information_schema.tables
         WHERE table_schema = 'public' AND table_name = 'bursar_action_audit'
    ")->fetchColumn();
    if ($tableExists) {
        $stmt = $pdo->prepare('SELECT COUNT(*) FROM bursar_action_audit WHERE organization_id = :org');
        $stmt->execute([':org' => $orgId]);
        $counts['bursar_action_audit'] = (int)$stmt->fetchColumn();
    }

    return $counts;
}

function archr_export_organization(PDO $pdo, int $orgId, int $deletedBy): array {
    $org = $pdo->prepare('SELECT * FROM coalition_organizations WHERE id = :org');
    $org->execute([':org' => $orgId]);
    $orgRow = $org->fetch();
    if (!$orgRow) {
        throw new RuntimeException('Organization not found');
    }

    $fetchAll = static function (PDO $pdo, string $sql, int $orgId): array {
        $stmt = $pdo->prepare($sql);
        $stmt->execute([':org' => $orgId]);
        return $stmt->fetchAll();
    };

    $data = [
        'metadata' => [
            'exported_at' => date('c'),
            'deleted_by_user_id' => $deletedBy,
            'organization_id' => $orgId,
        ],
        'organization' => $orgRow,
        'counts' => archr_organization_association_counts($pdo, $orgId),
        'organization_users' => $fetchAll($pdo, 'SELECT * FROM organization_users WHERE organization_id = :org', $orgId),
        'user_role_assignments' => $fetchAll($pdo, "
            SELECT ura.*, u.username, u.email, u.full_name, r.role_name
              FROM user_role_assignments ura
              JOIN system_users u ON u.id = ura.user_id
              JOIN roles r ON r.id = ura.role_id
             WHERE ura.organization_id = :org
        ", $orgId),
        'organization_eligibility_rules' => $fetchAll($pdo, 'SELECT * FROM organization_eligibility_rules WHERE organization_id = :org', $orgId),
        'eligibility_results' => $fetchAll($pdo, 'SELECT * FROM eligibility_results WHERE organization_id = :org', $orgId),
        'organization_metrics' => $fetchAll($pdo, 'SELECT * FROM organization_metrics WHERE organization_id = :org', $orgId),
        'funding_sources' => $fetchAll($pdo, 'SELECT * FROM funding_sources WHERE organization_id = :org', $orgId),
        'application_assignments' => $fetchAll($pdo, "
            SELECT aa.*, s.applicant_first_name, s.applicant_last_name, s.home_address
              FROM application_assignments aa
              JOIN intake_submissions s ON s.id = aa.submission_id
             WHERE aa.organization_id = :org
        ", $orgId),
        'assignment_logs' => $fetchAll($pdo, "
            SELECT al.*
              FROM assignment_log al
              JOIN application_assignments aa ON aa.id = al.assignment_id
             WHERE aa.organization_id = :org
        ", $orgId),
        'review_queue' => $fetchAll($pdo, 'SELECT * FROM review_queue WHERE organization_id = :org', $orgId),
        'case_claims' => $fetchAll($pdo, "
            SELECT cc.*, c.case_number
              FROM case_claims cc
              JOIN cases c ON c.id = cc.case_id
             WHERE cc.claimed_by_org_id = :org
        ", $orgId),
        'reimbursement_requests' => $fetchAll($pdo, "
            SELECT rr.*, c.case_number
              FROM reimbursement_requests rr
              LEFT JOIN cases c ON c.id = rr.case_id
             WHERE rr.organization_id = :org
        ", $orgId),
    ];

    // Bursar audit table may not exist in every deployment.
    $tableExists = (bool)$pdo->query("
        SELECT 1 FROM information_schema.tables
         WHERE table_schema = 'public' AND table_name = 'bursar_action_audit'
    ")->fetchColumn();
    if ($tableExists) {
        $data['bursar_action_audit'] = $fetchAll($pdo, 'SELECT * FROM bursar_action_audit WHERE organization_id = :org', $orgId);
    }

    return $data;
}

/**
 * Save an organization export to a server-side retention directory and
 * return the file path. Falls back to a temporary directory if the backup
 * dir cannot be created.
 */
function archr_save_organization_export(array $export): string {
    $orgId = (int)($export['organization']['id'] ?? 0);
    $code  = preg_replace('/[^a-z0-9_-]/i', '', (string)($export['organization']['organization_code'] ?? 'org')) ?: 'org';
    $ts    = date('Ymd-His');
    $dir   = __DIR__ . '/../backups/organization-deletions';
    if (!is_dir($dir)) {
        @mkdir($dir, 0750, true);
    }
    $path = $dir . '/org-' . $orgId . '-' . $code . '-' . $ts . '.json';
    file_put_contents($path, json_encode($export, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES));
    return $path;
}
