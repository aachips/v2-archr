<?php
declare(strict_types=1);

/* -----------------------------------------------------------------
 * Activity Log — the immutable ledger's single write path, plus
 * readers and the chain verifier. Tables: sql/add/activity-log.sql.
 *
 *   archr_log_event($pdo, $action, $opts)   -> permanent ledger entry
 *   archr_log_detail($pdo, $action, $opts)  -> 30-day granular detail
 *   archr_activity_query($pdo, $filters)    -> filtered ledger read
 *   archr_activity_verify_chain($pdo)       -> tamper check
 *   archr_activity_purge($pdo)              -> delete expired detail rows
 *
 * Every concrete action in app/ logs through here — the monolith's
 * equivalent of an Event Listener. Nothing else writes to these tables.
 *
 * CLI self-test (no database needed):  php app/lib/activity-log.php
 * -----------------------------------------------------------------
 */

/** Infer the canonical category from the action prefix. */
function archr_activity_category(string $action): string {
    static $map = [
        'client'        => 'client',
        'submission'    => 'application', // submissions roll up to the Household
        'application'   => 'application',
        'eligibility'   => 'application',
        'intake'        => 'application',
        'case'          => 'case',
        'assessment'    => 'case',
        'project'       => 'project',
        'task'          => 'task',
        'repair'        => 'repair',
        'document'      => 'document',
        'communication' => 'communication',
        'comm'          => 'communication',
        'schedule'      => 'schedule',
        'milestone'     => 'milestone',
        'user'          => 'user',
        'system'        => 'system',
    ];
    $prefix = strtok($action, '_');
    return $map[$prefix] ?? 'system';
}

/** Canonical JSON: recursively key-sorted, stable at write AND verify time.
 *  (PostgreSQL jsonb reorders keys on storage, so hashing raw input order
 *  would fail verification — decode + canonicalize is deterministic.) */
function archr_activity_canonicalize($value) {
    if (is_array($value)) {
        // Distinguish list vs assoc: PHP arrays with 0..n-1 keys stay in order.
        $isList = array_keys($value) === range(0, count($value) - 1);
        if (!$isList) ksort($value);
        return array_map('archr_activity_canonicalize', $value);
    }
    return $value;
}

/** Tamper-evidence hash over the canonical row contents + previous hash. */
function archr_activity_hash(?string $prevHash, array $row): string {
    $details = $row['details'] ?? [];
    if (is_string($details)) {
        $details = json_decode($details, true) ?: [];
    }
    return hash('sha256', json_encode([
        'prev'           => $prevHash,
        'created_at'     => (string)($row['created_at'] ?? ''),
        'user_id'        => $row['user_id'] ?? null,
        'application_id' => $row['application_id'] ?? null,
        'case_id'        => $row['case_id'] ?? null,
        'action'         => (string)($row['action'] ?? ''),
        'summary'        => (string)($row['summary'] ?? ''),
        'details'        => archr_activity_canonicalize($details),
        'source'         => (string)($row['source'] ?? ''),
    ], JSON_UNESCAPED_SLASHES));
}

/**
 * Insert one chained entry. $table: 'activity_log' | 'activity_detail'.
 * $opts keys: user_id, user_name, session_id, ip_address, application_id,
 * case_id, organization_id (ledger only), ledger_id / field_name /
 * old_value / new_value (detail only), category, summary, details, source.
 * Returns the new row id.
 */
function archr_activity_insert(PDO $pdo, string $table, string $action, array $opts = []): int {
    if (!in_array($table, ['activity_log', 'activity_detail'], true)) {
        throw new InvalidArgumentException('Unknown activity table: ' . $table);
    }
    if (PHP_SAPI !== 'cli' && function_exists('archr_session_start')) {
        archr_session_start();
    }

    $row = [
        'created_at'     => date('Y-m-d H:i:s'),
        'user_id'        => $opts['user_id'] ?? (isset($_SESSION['archr_user_id']) ? (int)$_SESSION['archr_user_id'] : null),
        'user_name'      => $opts['user_name'] ?? ($_SESSION['archr_user_name'] ?? null),
        'session_id'     => $opts['session_id'] ?? (PHP_SAPI === 'cli' ? null : session_id()),
        'ip_address'     => $opts['ip_address'] ?? ($_SERVER['REMOTE_ADDR'] ?? null),
        'application_id' => isset($opts['application_id']) ? (int)$opts['application_id'] : null,
        'case_id'        => isset($opts['case_id']) ? (int)$opts['case_id'] : null,
        'action'         => $action,
        // Bound as a JSON string — PDO would stringify an array to "Array".
        // The hash path (archr_activity_hash) decodes strings, so hashing is
        // unaffected.
        'details'        => json_encode(archr_activity_canonicalize(is_array($opts['details'] ?? null) ? $opts['details'] : []), JSON_UNESCAPED_SLASHES),
        'source'         => $opts['source'] ?? (PHP_SAPI === 'cli' ? 'system' : 'web'),
    ];
    if ($table === 'activity_log') {
        // summary lives on the ledger only (activity_detail has no such column)
        $row['summary']         = $opts['summary'] ?? null;
        $row['category']        = $opts['category'] ?? archr_activity_category($action);
        $row['organization_id'] = isset($opts['organization_id']) ? (int)$opts['organization_id'] : null;
    } else {
        $row['ledger_id']  = isset($opts['ledger_id']) ? (int)$opts['ledger_id'] : null;
        $row['field_name'] = $opts['field_name'] ?? null;
        $row['old_value']  = isset($opts['old_value']) ? (string)$opts['old_value'] : null;
        $row['new_value']  = isset($opts['new_value']) ? (string)$opts['new_value'] : null;
    }

    // Chain write. UNIQUE(prev_hash) rejects a forked chain under concurrent
    // requests — retry once with a fresh head.
    for ($attempt = 0; $attempt < 2; $attempt++) {
        $prev = $pdo->query("SELECT entry_hash FROM {$table} ORDER BY id DESC LIMIT 1")
                    ->fetchColumn() ?: null;
        $row['prev_hash']  = $prev;
        $row['entry_hash'] = archr_activity_hash($prev, $row);

        $cols = implode(', ', array_keys($row));
        $ph = ':' . implode(', :', array_keys($row));
        try {
            $stmt = $pdo->prepare("INSERT INTO {$table} ({$cols}) VALUES ({$ph}) RETURNING id");
            $stmt->execute($row);
            return (int)$stmt->fetchColumn();
        } catch (PDOException $e) {
            if ($e->getCode() === '23505' && $attempt === 0) continue; // fork race — retry
            throw $e;
        }
    }
    throw new RuntimeException('Could not append to ' . $table . ' (chain conflict).');
}

/** Permanent curated ledger entry. */
function archr_log_event(PDO $pdo, string $action, array $opts = []): int {
    return archr_activity_insert($pdo, 'activity_log', $action, $opts);
}

/** Granular 30-day detail entry (field diffs, session/IP forensics). */
function archr_log_detail(PDO $pdo, string $action, array $opts = []): int {
    return archr_activity_insert($pdo, 'activity_detail', $action, $opts);
}

/**
 * Filtered ledger read for the admin audit view.
 * $filters: user_id, application_id, case_id, category, action, source,
 *           since ('Y-m-d'), until ('Y-m-d'), search (summary ILIKE),
 *           limit (default 200, max 1000), offset.
 */
function archr_activity_query(PDO $pdo, array $filters = []): array {
    $where = [];
    $params = [];
    foreach (['user_id', 'application_id', 'case_id'] as $f) {
        if (!empty($filters[$f])) { $where[] = "$f = :$f"; $params[$f] = (int)$filters[$f]; }
    }
    foreach (['category', 'action', 'source'] as $f) {
        if (!empty($filters[$f])) { $where[] = "$f = :$f"; $params[$f] = (string)$filters[$f]; }
    }
    if (!empty($filters['since'])) { $where[] = "created_at >= :since"; $params['since'] = $filters['since'] . ' 00:00:00'; }
    if (!empty($filters['until'])) { $where[] = "created_at <= :until"; $params['until'] = $filters['until'] . ' 23:59:59'; }
    if (!empty($filters['search'])) { $where[] = "summary ILIKE :search"; $params['search'] = '%' . $filters['search'] . '%'; }

    $limit = min(1000, max(1, (int)($filters['limit'] ?? 200)));
    $offset = max(0, (int)($filters['offset'] ?? 0));
    $sql = "SELECT * FROM activity_log"
         . ($where ? ' WHERE ' . implode(' AND ', $where) : '')
         . " ORDER BY id DESC LIMIT $limit OFFSET $offset";
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

/** Pure chain check over already-fetched rows (oldest first). Testable
 *  without a database. Returns ['ok','checked','first_bad_id','error']. */
function archr_activity_check_rows(array $rows): array {
    $prev = null;
    $checked = 0;
    foreach ($rows as $row) {
        $checked++;
        if (($row['prev_hash'] ?? null) !== $prev) {
            return ['ok' => false, 'checked' => $checked, 'first_bad_id' => $row['id'] ?? null,
                    'error' => 'Broken chain link (prev_hash mismatch)'];
        }
        $details = $row['details'] ?? [];
        if (is_string($details)) $details = json_decode($details, true) ?: [];
        $expect = archr_activity_hash($prev, array_merge($row, ['details' => $details]));
        if (!hash_equals((string)($row['entry_hash'] ?? ''), $expect)) {
            return ['ok' => false, 'checked' => $checked, 'first_bad_id' => $row['id'] ?? null,
                    'error' => 'Content hash mismatch (row was modified)'];
        }
        $prev = $row['entry_hash'];
    }
    return ['ok' => true, 'checked' => $checked, 'first_bad_id' => null, 'error' => null];
}

/** Verify a table's hash chain. Returns the archr_activity_check_rows shape. */
function archr_activity_verify_chain(PDO $pdo, string $table = 'activity_log', int $afterId = 0): array {
    if (!in_array($table, ['activity_log', 'activity_detail'], true)) {
        throw new InvalidArgumentException('Unknown activity table: ' . $table);
    }
    $stmt = $pdo->prepare("SELECT * FROM {$table} WHERE id > :after ORDER BY id ASC");
    $stmt->execute([':after' => $afterId]);
    return archr_activity_check_rows($stmt->fetchAll(PDO::FETCH_ASSOC));
}

/** Delete expired detail rows. Returns the count deleted. */
function archr_activity_purge(PDO $pdo): int {
    return (int)$pdo->query("SELECT archr_activity_purge_expired()")->fetchColumn();
}

/* -----------------------------------------------------------------
 * CLI self-test — proves the chain without a database:
 *   php app/lib/activity-log.php
 * -----------------------------------------------------------------
 */
if (PHP_SAPI === 'cli' && basename((string)($_SERVER['argv'][0] ?? '')) === basename(__FILE__)) {
    $failures = 0;
    $check = function (bool $cond, string $label) use (&$failures) {
        echo ($cond ? 'PASS' : 'FAIL') . ": $label\n";
        if (!$cond) $failures++;
    };

    // Build a 3-entry fake chain exactly as the DB writer would.
    $chain = [];
    $prev = null;
    $samples = [
        ['id' => 1, 'action' => 'application_claimed', 'summary' => 'Case claimed by Habitat (2 repairs)', 'user_id' => 7],
        ['id' => 2, 'action' => 'document_uploaded',   'summary' => 'paystub.pdf uploaded', 'details' => ['b' => 2, 'a' => 1]],
        ['id' => 3, 'action' => 'application_withdrawn', 'summary' => 'Withdrawn after phone confirmation'],
    ];
    foreach ($samples as $s) {
        $row = array_merge([
            'created_at' => '2026-09-01 09:14:32', 'user_id' => null,
            'application_id' => 42, 'case_id' => null,
            'summary' => '', 'details' => [], 'source' => 'web',
        ], $s);
        $row['details'] = archr_activity_canonicalize($row['details']);
        $row['prev_hash'] = $prev;
        $row['entry_hash'] = archr_activity_hash($prev, $row);
        $chain[] = $row;
        $prev = $row['entry_hash'];
    }

    $ok = archr_activity_check_rows($chain);
    $check($ok['ok'] && $ok['checked'] === 3, 'intact chain verifies');

    $tampered = $chain;
    $tampered[1]['summary'] = 'paystub.pdf uploaded (edited by fraudster)';
    $bad = archr_activity_check_rows($tampered);
    $check(!$bad['ok'] && $bad['first_bad_id'] === 2, 'tampered row caught at id 2');

    $broken = [$chain[0], $chain[2]]; // row 2 deleted
    $bad2 = archr_activity_check_rows($broken);
    $check(!$bad2['ok'] && $bad2['first_bad_id'] === 3, 'deleted row breaks chain at id 3');

    $check(archr_activity_category('document_verified') === 'document', 'category inference: document');
    $check(archr_activity_category('comm_logged') === 'communication', 'category inference: comm_* -> communication');
    $check(archr_activity_category('weird_new_thing') === 'system', 'unknown prefix falls back to system');

    // jsonb-order independence: details in different key order hash identically.
    $h1 = archr_activity_hash(null, ['action' => 'a', 'details' => ['x' => 1, 'y' => ['p' => 1, 'q' => 2]]]);
    $h2 = archr_activity_hash(null, ['action' => 'a', 'details' => ['y' => ['q' => 2, 'p' => 1], 'x' => 1]]);
    $check($h1 === $h2, 'details key order does not change the hash');

    echo $failures === 0 ? "ALL ACTIVITY-LOG SELF-TESTS PASSED\n" : "$failures TEST(S) FAILED\n";
    exit($failures === 0 ? 0 : 1);
}