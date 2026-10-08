<?php
declare(strict_types=1);

/* -----------------------------------------------------------------
 * Intake save mapper
 * Takes the JSON payload produced by intake.js and writes it across
 * intake_submissions, submission_repair_categories,
 * submission_household_attributes, submission_contact_methods,
 * application_anchor, and review_queue. Mirrors the layout used by
 * sql/dummy-data.sql so dashboards built on the same tables work
 * for both seeded and real submissions.
 *
 * Each Submission is then consolidated into its Application (one
 * deduplicated entry per placecode) per "ARCHR Core Terminology and
 * Operational Logic", and an unclaimed intake Case is created for the
 * application; the first claiming organization adopts it.
 *
 * Returns ['submission_id' => int, 'anchor_id' => string|null,
 *          'case_number' => string|null, 'application_id' => int].
 * ----------------------------------------------------------------- */

require_once __DIR__ . '/applications.php';

function archr_save_intake_submission(PDO $pdo, array $p, ?string $clientIp, ?string $userAgent): array {
    $yes = static fn($v) => $v === 'yes' || $v === true || $v === 'true' || $v === '1';
    $get = static fn(string $k, $default = null) => array_key_exists($k, $p) ? $p[$k] : $default;
    $arr = static function (string $k) use ($p): array {
        $v = $p[$k] ?? [];
        if (is_array($v)) return $v;
        if ($v === null || $v === '') return [];
        return [(string)$v];
    };
    $num = static function ($v) {
        if ($v === '' || $v === null) return null;
        return is_numeric($v) ? $v + 0 : null;
    };
    $strOrNull = static function ($v) {
        if ($v === null) return null;
        $s = trim((string)$v);
        return $s === '' ? null : $s;
    };
    $dateOrNull = static function ($v) {
        $s = is_string($v) ? trim($v) : '';
        return $s === '' ? null : $s;
    };

    $preferred = $arr('preferredContact');
    $repair    = $arr('repairCategory');
    $urgent    = $arr('urgentConditions');
    // urgentConditions and repairCategory share the same codes; merge for the
    // urgent_* boolean columns so either source flips the flag.
    $urgentAll = array_values(array_unique(array_merge($repair, $urgent)));
    $household = $arr('householdAttributes');

    $hasIncome = $yes($get('haveIncome'));
    $income    = $hasIncome ? $num($get('grossAnnualIncome')) : null;
    $heleneRel = $yes($get('heleneRelated'));

    $pdo->beginTransaction();
    try {
        // Bypass user triggers on intake_submissions to avoid the expensive
        // materialized-view refresh in trigger_new_submission. Anchor / case
        // triggers fire on their own tables and remain active.
        // session_replication_role is superuser-only; on hosts where the DB
        // user is not a superuser (shared hosting) the SET fails, so tolerate
        // it and let the triggers run normally.
        $replicaBypass = false;
        try {
            $pdo->exec("SET LOCAL session_replication_role = 'replica'");
            $replicaBypass = true;
        } catch (Throwable $e) {
            error_log('[intake-save] session_replication_role not permitted (non-superuser DB user); triggers will fire normally.');
        }

        $sql = <<<SQL
            INSERT INTO intake_submissions (
                language, is_referral, referrer_name, referrer_organization,
                referrer_email, referrer_notes, consent_agreed,
                applicant_first_name, applicant_last_name, applicant_dob, applicant_dob_unknown,
                preferred_phone, preferred_text, preferred_email, preferred_other,
                home_phone, cell_phone, contact_email,
                other_contact_method_description, contact_notes,
                home_address, home_city, home_state, home_zip,
                is_primary_residence, receives_different_mail,
                mail_address, mail_city, mail_state, mail_zip,
                home_type, year_built, move_in_date, owns_home, owns_lot,
                insurance_provider, lived_one_year,
                household_size, household_adults,
                additional_repair_details,
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
                applicant_signature, zero_income_signature,
                submission_status, is_test
            ) VALUES (
                :language, :is_referral, :referrer_name, :referrer_organization,
                :referrer_email, :referrer_notes, :consent_agreed,
                :applicant_first_name, :applicant_last_name, :applicant_dob, :applicant_dob_unknown,
                :pref_phone, :pref_text, :pref_email, :pref_other,
                :home_phone, :cell_phone, :contact_email,
                :other_contact, :contact_notes,
                :home_address, :home_city, :home_state, :home_zip,
                :is_primary_residence, :receives_different_mail,
                :mail_address, :mail_city, :mail_state, :mail_zip,
                :home_type, :year_built, :move_in_date, :owns_home, :owns_lot,
                :insurance_provider, :lived_one_year,
                :household_size, :household_adults,
                :additional_repair_details,
                :u_unable, :u_no_hvac, :u_no_water,
                :u_no_bath, :u_no_kitchen, :u_elements,
                :u_no_entry, :u_access, :u_other, :u_eviction,
                :helene_related,
                :fema_filed, :fema_outcome, :fema_settle,
                :fema_rem_exists, :fema_rem_amt,
                :ins_filed, :ins_outcome, :ins_settle,
                :ins_rem_exists, :ins_rem_amt,
                :has_income, :income_method, :gross_income, :income_docs_method,
                :zi_first, :zi_last, :zi_addr, :zi_agreed,
                :app_sig, :zi_sig,
                'pending', FALSE
            ) RETURNING id
SQL;

        $stmt = $pdo->prepare($sql);
        $stmt->execute(_archr_bind_intake($yes, $get, $strOrNull, $dateOrNull, $num,
                                          $preferred, $urgentAll, $hasIncome, $income, $heleneRel));
        $submissionId = (int)$stmt->fetchColumn();

        if ($replicaBypass) {
            $pdo->exec("SET LOCAL session_replication_role = 'origin'");
        }

        // Junction inserts use the canonical lookup tables.
        if ($repair) {
            _archr_link($pdo, 'submission_repair_categories', 'category_id',
                        'repair_categories', 'category_code', $submissionId, $repair);
        }
        if ($household) {
            _archr_link($pdo, 'submission_household_attributes', 'attribute_id',
                        'household_attributes', 'attribute_name', $submissionId, $household);
        }
        if ($preferred) {
            _archr_link($pdo, 'submission_contact_methods', 'method_id',
                        'contact_methods', 'method_code', $submissionId, $preferred);
        }

        // Dynamic rows from the Page 6 repair table and the income calculator.
        if (!empty($p['repairNeeds']) && is_array($p['repairNeeds'])) {
            _archr_save_repair_requests($pdo, $submissionId, $p['repairNeeds']);
        }
        if (!empty($p['incomeRecords']) && is_array($p['incomeRecords'])) {
            _archr_save_income_records($pdo, $submissionId, $p['incomeRecords']);
        }

        $homeAddress = $strOrNull($get('homeAddress'));
        $homeType    = $strOrNull($get('homeType')) ?? '';
        $placecode = _archr_placecode($homeAddress);
        $projectPrefix = match (true) {
            $homeType === 'mobile' => 'H',          // Mobile Home & Park
            $heleneRel             => 'D',          // Disaster Related
            default                => 'A',          // Traditional Home Repair
        };
        $projectCode = $placecode ? $projectPrefix . $placecode : null;

        if ($placecode) {
            $upd = $pdo->prepare("UPDATE intake_submissions SET placecode = :pc WHERE id = :id");
            $upd->execute([':pc' => $placecode, ':id' => $submissionId]);
        }

        // Consolidate this Submission into its Application (deduplicated by
        // placecode) before any case/anchor bookkeeping references it.
        $applicationId = archr_deduplicate_application($pdo, $submissionId);

        $anchorRes = _archr_create_anchor_and_queue($pdo, $submissionId, $income, $heleneRel,
                                                    $repair, $urgentAll, $get('homeCity'), $get('homeZip'),
                                                    $clientIp, $placecode, $projectCode, $applicationId);

        $pdo->commit();
        return [
            'submission_id' => $submissionId,
            'anchor_id'     => $anchorRes['anchor_id'],
            'case_number'   => $anchorRes['case_number'],
            'placecode'     => $anchorRes['placecode'] ?? $placecode,
            'project_code'  => $anchorRes['project_code'] ?? $projectCode,
            'application_id' => $applicationId,
        ];
    } catch (Throwable $e) {
        $pdo->rollBack();
        throw $e;
    }
}


/* ---------------- internal helpers ---------------- */

function _archr_bind_intake(callable $yes, callable $get, callable $strOrNull,
                            callable $dateOrNull, callable $num, array $preferred,
                            array $urgentAll, bool $hasIncome, $income, bool $heleneRel): array {
    $in = static fn(string $code) => in_array($code, $urgentAll, true);
    return [
        ':language'                 => $strOrNull($get('language')) ?? 'eng',
        ':is_referral'              => _b($yes($get('isReferral'))),
        ':referrer_name'            => $strOrNull($get('referrerName')),
        ':referrer_organization'    => $strOrNull($get('referrerOrganization')),
        ':referrer_email'           => $strOrNull($get('referrerEmail')),
        ':referrer_notes'           => $strOrNull($get('referrerNotes')),
        ':consent_agreed'           => _b($yes($get('consentAgree'))),
        ':applicant_first_name'     => $strOrNull($get('applicantFirstName')),
        ':applicant_last_name'      => $strOrNull($get('applicantLastName')),
        ':applicant_dob'            => $dateOrNull($get('applicantDob')),
        ':applicant_dob_unknown'    => _b($yes($get('applicantDobUnknown'))),
        ':pref_phone'               => _b(in_array('phone', $preferred, true)),
        ':pref_text'                => _b(in_array('text',  $preferred, true)),
        ':pref_email'               => _b(in_array('email', $preferred, true)),
        ':pref_other'               => _b(in_array('other', $preferred, true)),
        ':home_phone'               => $strOrNull($get('homePhone')),
        ':cell_phone'               => $strOrNull($get('cellPhone')),
        ':contact_email'            => $strOrNull($get('contactEmail')),
        ':other_contact'            => $strOrNull($get('otherContactMethod')),
        ':contact_notes'            => $strOrNull($get('contactNotes')),
        ':home_address'             => $strOrNull($get('homeAddress')),
        ':home_city'                => $strOrNull($get('homeCity')),
        ':home_state'               => $strOrNull($get('homeState')),
        ':home_zip'                 => $strOrNull($get('homeZip')),
        ':is_primary_residence'     => _b($yes($get('isPrimaryResidence'))),
        ':receives_different_mail'  => _b($yes($get('receivesDifferentMail'))),
        ':mail_address'             => $strOrNull($get('mailAddress')),
        ':mail_city'                => $strOrNull($get('mailCity')),
        ':mail_state'               => $strOrNull($get('mailState')),
        ':mail_zip'                 => $strOrNull($get('mailZip')),
        ':home_type'                => $strOrNull($get('homeType')),
        ':year_built'               => $num($get('yearBuilt')),
        ':move_in_date'             => $dateOrNull($get('moveInDate')),
        ':owns_home'                => _b($yes($get('ownsHome'))),
        ':owns_lot'                 => _b($yes($get('ownsLot'))),
        ':insurance_provider'       => $strOrNull($get('insuranceProvider')),
        ':lived_one_year'           => _b($yes($get('livedOneYear'))),
        ':household_size'           => $num($get('householdSize')),
        ':household_adults'         => $num($get('householdAdults')),
        ':additional_repair_details'=> $strOrNull($get('additionalRepairDetails')),
        ':u_unable'                 => _b($in('unable_to_stay')),
        ':u_no_hvac'                => _b($in('no_hvac')),
        ':u_no_water'               => _b($in('no_potable_water')),
        ':u_no_bath'                => _b($in('no_bathroom')),
        ':u_no_kitchen'             => _b($in('no_kitchen')),
        ':u_elements'               => _b($in('open_to_elements')),
        ':u_no_entry'               => _b($in('no_entry')),
        ':u_access'                 => _b($in('accessibility')),
        ':u_other'                  => _b($in('other_issue')),
        ':u_eviction'               => _b($in('eviction_risk')),
        ':helene_related'           => _b($heleneRel),
        ':fema_filed'               => _b($yes($get('femaClaim'))),
        ':fema_outcome'             => $strOrNull($get('femaOutcome')),
        ':fema_settle'              => $num($get('femaSettlementAmount')),
        ':fema_rem_exists'          => _b($yes($get('femaRemaining'))),
        ':fema_rem_amt'             => $num($get('femaRemainingAmount')),
        ':ins_filed'                => _b($yes($get('insuranceClaim'))),
        ':ins_outcome'              => $strOrNull($get('insuranceOutcome')),
        ':ins_settle'               => $num($get('insuranceSettlementAmount')),
        ':ins_rem_exists'           => _b($yes($get('insuranceRemaining'))),
        ':ins_rem_amt'              => $num($get('insuranceRemainingAmount')),
        ':has_income'               => _b($hasIncome),
        ':income_method'            => $strOrNull($get('incomeMethod')),
        ':gross_income'             => $income,
        ':income_docs_method'       => $strOrNull($get('incomeDocsMethod')),
        ':zi_first'                 => $strOrNull($get('zeroIncomeFirstName')),
        ':zi_last'                  => $strOrNull($get('zeroIncomeLastName')),
        ':zi_addr'                  => $strOrNull($get('zeroIncomeAddress')),
        ':zi_agreed'                => _b($yes($get('zeroIncomeAgree'))),
        ':app_sig'                  => $strOrNull($get('applicantSignature')),
        ':zi_sig'                   => $strOrNull($get('zeroIncomeSignature')),
    ];
}

function _b(bool $v): string { return $v ? 't' : 'f'; }

function _archr_link(PDO $pdo, string $linkTable, string $fkCol, string $lookupTable,
                     string $codeCol, int $submissionId, array $codes): void {
    $sql = "INSERT INTO {$linkTable} (submission_id, {$fkCol})
            SELECT :sid, lk.id FROM {$lookupTable} lk
             WHERE lk.{$codeCol} = ANY(:codes::text[])
            ON CONFLICT DO NOTHING";
    $stmt = $pdo->prepare($sql);
    $stmt->bindValue(':sid', $submissionId, PDO::PARAM_INT);
    $arrayLiteral = '{' . implode(',', array_map(
        static fn($c) => '"' . str_replace('"', '\\"', (string)$c) . '"',
        $codes
    )) . '}';
    $stmt->bindValue(':codes', $arrayLiteral);
    $stmt->execute();
}

function _archr_create_anchor_and_queue(PDO $pdo, int $submissionId, $income, bool $helene,
                                        array $repair, array $urgentAll, ?string $city,
                                        ?string $zip, ?string $clientIp,
                                        ?string $placecode, ?string $projectCode,
                                        ?int $applicationId): array {
    $bucketStmt = $pdo->prepare("SELECT get_income_bucket(:i::numeric) AS inc,
                                        get_county_bucket(:c, :z) AS cty");
    $bucketStmt->execute([
        ':i' => $income ?? 0,
        ':c' => $city   ?? '',
        ':z' => $zip    ?? '',
    ]);
    $b = $bucketStmt->fetch() ?: ['inc' => null, 'cty' => null];
    $repairBucket = $repair[0] ?? ($urgentAll[0] ?? null);

    // Eligibility philosophy (terminology doc Part 4): assume eligibility.
    // The system flags concerns for human review; it never auto-denies.
    $eligible = true;

    $anchorStmt = $pdo->prepare(
        "INSERT INTO application_anchor (
             submission_id, submitted_at, submitted_from_ip,
             is_eligible, current_status,
             income_bucket, county_bucket, repair_type_bucket, helene_related,
             placecode, project_code
         ) VALUES (
             :sid, CURRENT_TIMESTAMP, :ip::inet,
             :elig, :status,
             :inc, :cty, :rep, :hel,
             :pc, :prc
         ) RETURNING anchor_id, case_number, placecode, project_code"
    );
    $anchorStmt->execute([
        ':sid'    => $submissionId,
        ':ip'     => $clientIp ?: '0.0.0.0',
        ':elig'   => _b($eligible),
        ':status' => 'eligible',
        ':inc'    => $b['inc'],
        ':cty'    => $b['cty'],
        ':rep'    => $repairBucket,
        ':hel'    => _b($helene),
        ':pc'     => $placecode,
        ':prc'    => $projectCode,
    ]);
    $anchor = $anchorStmt->fetch() ?: ['anchor_id' => null, 'case_number' => null, 'placecode' => null, 'project_code' => null];

    $queueStmt = $pdo->prepare(
        "INSERT INTO review_queue (submission_id, status, queued_at, priority_score)
         VALUES (:sid, 'PENDING_REVIEW', CURRENT_TIMESTAMP, :p)"
    );
    $queueStmt->execute([':sid' => $submissionId, ':p' => 10 * count($urgentAll)]);

    // One unclaimed intake case per application so the case search and case
    // review pages can locate it; the first claiming organization adopts it
    // (see claim_application). Additional submissions for the same placecode
    // join the existing application instead of creating duplicate cases.
    $caseStatusStmt = $pdo->query("SELECT id FROM case_statuses WHERE status_code = 'PENDING_REVIEW' LIMIT 1");
    $caseStatusId = (int)$caseStatusStmt->fetchColumn();
    if ($caseStatusId > 0 && $applicationId !== null) {
        $existingCaseStmt = $pdo->prepare(
            "SELECT id FROM cases WHERE application_id = :app AND organization_id IS NULL LIMIT 1"
        );
        $existingCaseStmt->execute([':app' => $applicationId]);
        if (!$existingCaseStmt->fetchColumn()) {
            $caseStmt = $pdo->prepare(
                "INSERT INTO cases (submission_id, application_id, status_id, project_code, placecode, created_by, updated_by)
                 VALUES (:sid, :app, :status_id, :project_code, :placecode, NULL, NULL)"
            );
            $caseStmt->execute([
                ':sid'          => $submissionId,
                ':app'          => $applicationId,
                ':status_id'    => $caseStatusId,
                ':project_code' => $projectCode,
                ':placecode'    => $placecode,
            ]);
        }
    }

    return $anchor;
}


function _archr_save_repair_requests(PDO $pdo, int $submissionId, array $needs): void {
    $stmt = $pdo->prepare(
        "INSERT INTO repair_requests (submission_id, repair_need, priority, sort_order)
         VALUES (:sid, :need, :prio, :ord)"
    );
    foreach ($needs as $i => $row) {
        if (!is_array($row)) continue;
        $need = trim((string)($row['need'] ?? ''));
        if ($need === '') continue;
        $priority = $row['priority'] ?? '';
        $prio = is_numeric($priority) ? (int)$priority : null;
        $stmt->execute([
            ':sid'  => $submissionId,
            ':need' => $need,
            ':prio' => $prio,
            ':ord'  => $i + 1,
        ]);
    }
}

function _archr_save_income_records(PDO $pdo, int $submissionId, array $records): void {
    $stmt = $pdo->prepare(
        "INSERT INTO income_records (submission_id, whose_income, income_source, frequency, amount)
         VALUES (:sid, :whose, :source, :freq, :amt)"
    );
    foreach ($records as $row) {
        if (!is_array($row)) continue;
        $amount = $row['amount'] ?? null;
        if (!is_numeric($amount)) continue;
        $stmt->execute([
            ':sid'    => $submissionId,
            ':whose'  => $row['whose'] ?? null,
            ':source' => $row['source'] ?? null,
            ':freq'   => $row['frequency'] ?? null,
            ':amt'    => $amount + 0,
        ]);
    }
}

/**
 * Derive an 8-character Placecode from a free-form address.
 * Canonical implementation is archr_placecode() in lib/applications.php
 * (mirrored in SQL by archr_generate_placecode()); this alias remains for
 * the intake call sites above.
 */
function _archr_placecode(?string $address): ?string {
    return archr_placecode($address);
}
