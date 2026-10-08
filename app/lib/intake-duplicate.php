<?php
declare(strict_types=1);

/* -----------------------------------------------------------------
 * Duplicate-intake helpers.
 *
 * Used by the early-warning API and the final submit endpoint so the
 * same rules and call-in number are applied everywhere.
 * ----------------------------------------------------------------- */

/**
 * The phone number callers should use to resolve suspected duplicate
 * submissions. Override with the ARCHR_CALL_IN_NUMBER environment variable.
 */
function archr_intake_call_in_number(): string {
    $env = trim((string)getenv('ARCHR_CALL_IN_NUMBER'));
    return $env !== '' ? $env : '(828) 555-0199';
}

/**
 * How many hours back the duplicate check should look.
 */
function archr_intake_duplicate_window_hours(): int {
    $h = (int)getenv('ARCHR_DUPLICATE_WINDOW_HOURS');
    return $h > 0 ? $h : 24;
}

/**
 * Look for a recent submission matching the supplied contact identifiers.
 * Returns the matching row (or null). The match is OR-based across any
 * non-empty identifier.
 */
function archr_intake_find_duplicate(
    PDO $pdo,
    ?string $email,
    ?string $homeAddress,
    ?string $homePhone,
    ?string $cellPhone
): ?array {
    $email       = trim((string)$email);
    $homeAddress = trim((string)$homeAddress);
    $homePhone   = trim((string)$homePhone);
    $cellPhone   = trim((string)$cellPhone);

    if ($email === '' && $homeAddress === '' && $homePhone === '' && $cellPhone === '') {
        return null;
    }

    $hours = archr_intake_duplicate_window_hours();

    $where = ['submitted_at > CURRENT_TIMESTAMP - INTERVAL ' . (int)$hours . ' HOURS'];
    $params = [];
    $or = [];

    if ($email !== '') {
        $or[] = 'contact_email = :email';
        $params[':email'] = $email;
    }
    if ($homeAddress !== '') {
        $or[] = 'home_address = :addr';
        $params[':addr'] = $homeAddress;
    }
    if ($homePhone !== '') {
        $or[] = 'home_phone = :home_phone';
        $params[':home_phone'] = $homePhone;
    }
    if ($cellPhone !== '') {
        $or[] = 'cell_phone = :cell_phone';
        $params[':cell_phone'] = $cellPhone;
    }

    $where[] = '(' . implode(' OR ', $or) . ')';

    $stmt = $pdo->prepare(
        'SELECT id, submitted_at, contact_email, home_address, home_phone, cell_phone ' .
        'FROM intake_submissions ' .
        'WHERE ' . implode(' AND ', $where) . ' ' .
        'ORDER BY submitted_at DESC LIMIT 1'
    );
    $stmt->execute($params);
    $row = $stmt->fetch();
    return $row ?: null;
}

/**
 * Describe which identifier(s) matched the duplicate row.
 */
function archr_intake_duplicate_match_label(array $row, ?string $email, ?string $homeAddress, ?string $homePhone, ?string $cellPhone): string {
    $matches = [];
    if ($email !== '' && trim((string)($row['contact_email'] ?? '')) === $email) {
        $matches[] = 'email';
    }
    if ($homeAddress !== '' && trim((string)($row['home_address'] ?? '')) === $homeAddress) {
        $matches[] = 'address';
    }
    if ($homePhone !== '' && trim((string)($row['home_phone'] ?? '')) === $homePhone) {
        $matches[] = 'home phone';
    }
    if ($cellPhone !== '' && trim((string)($row['cell_phone'] ?? '')) === $cellPhone) {
        $matches[] = 'cell phone';
    }
    return implode(', ', $matches) ?: 'information';
}
