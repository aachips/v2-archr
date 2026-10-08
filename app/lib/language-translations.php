<?php
declare(strict_types=1);

/* =====================================================================
   ARCHR Language-Translate file.

   Every piece of rendered UI text that does NOT come from the database
   belongs in the ARCHR_STRINGS dictionary below, keyed by a dotted name
   ('topbar.website', 'case_search.title', ...) with one slot per
   language: English (en, the source of truth), Spanish (es), Ukrainian (uk).

   FOR TRANSLATORS:
   - Fill the empty '' slots for 'es' and 'uk'. Never change a key or
     the 'en' text.
   - Anything in {curly braces} (e.g. {count}) is a placeholder the app
     fills in - keep it verbatim, placed wherever the sentence needs it.
   - Empty slots are safe: the site shows English until a slot is filled.

   FOR DEVELOPERS:
   - In templates: <?= __('key.name') ?> (HTML-escapes for you), or
     e(archr_translate('key.name', ['param' => $value])) inside an
     already-escaped expression.
   - The active language comes from ?lang=xx and is remembered in the
     session. archr_language_url('es') builds a switch link for the
     current page that preserves the current filters.
   ===================================================================== */

require_once __DIR__ . '/session.php';

/* Languages the portal can render. Names stay in their own language so
   the switcher reads naturally to every speaker. */
const ARCHR_LANGUAGES = [
    'en' => 'English',
    'es' => 'Español',
    'uk' => 'Українська',
];

const ARCHR_DEFAULT_LANGUAGE = 'en';

/* ---------------------------------------------------------------------
   The dictionary. One line per string: key => [en, es, uk].
   ------------------------------------------------------------------ */
const ARCHR_STRINGS = [
    // Shared bits
    'common.search' => ['en' => 'Search', 'es' => '', 'uk' => ''],

    // Top bar and portal chrome
    'topbar.quick_search_aria' => ['en' => 'Quick case search', 'es' => '', 'uk' => ''],
    'topbar.search_placeholder' => ['en' => 'Search by case number, address, or name…', 'es' => '', 'uk' => ''],
    'topbar.website' => ['en' => 'Website', 'es' => '', 'uk' => ''],
    'topbar.view_as' => ['en' => 'View as', 'es' => '', 'uk' => ''],
    'topbar.toggle_theme' => ['en' => 'Toggle dark mode', 'es' => '', 'uk' => ''],
    'topbar.language' => ['en' => 'Language', 'es' => '', 'uk' => ''],
    'topbar.language_menu' => ['en' => 'Change language', 'es' => '', 'uk' => ''],
    'topbar.account_menu' => ['en' => 'Account menu', 'es' => '', 'uk' => ''],
    'topbar.profile_settings' => ['en' => 'Profile Settings', 'es' => '', 'uk' => ''],
    'topbar.log_out' => ['en' => 'Log-Out', 'es' => '', 'uk' => ''],

    // Sidebar buttons
    'sidebar.open_menu' => ['en' => 'Open menu', 'es' => '', 'uk' => ''],
    'sidebar.close_menu' => ['en' => 'Close menu', 'es' => '', 'uk' => ''],

    // Role names shown in the "View as" switcher
    'roles.super_admin' => ['en' => 'Super Admin', 'es' => '', 'uk' => ''],
    'roles.org_admin' => ['en' => 'Org Admin', 'es' => '', 'uk' => ''],
    'roles.assessor' => ['en' => 'Assessor', 'es' => '', 'uk' => ''],
    'roles.bursar' => ['en' => 'Bursar', 'es' => '', 'uk' => ''],
    'roles.crew_lead' => ['en' => 'Crew Lead', 'es' => '', 'uk' => ''],
    'roles.crew_member' => ['en' => 'Crew Member', 'es' => '', 'uk' => ''],
    'roles.subcontractor' => ['en' => 'Subcontractor', 'es' => '', 'uk' => ''],
    'roles.envoy' => ['en' => 'Envoy', 'es' => '', 'uk' => ''],
    'roles.project_manager' => ['en' => 'Project Manager', 'es' => '', 'uk' => ''],
    'roles.volunteer' => ['en' => 'Volunteer', 'es' => '', 'uk' => ''],
    'roles.tle_poc' => ['en' => 'Tasks/Logs/Events', 'es' => '', 'uk' => ''],

    // Case search page (partials/case-search-body.php)
    'case_search.title' => ['en' => 'Case Search', 'es' => '', 'uk' => ''],
    'case_search.intro' => ['en' => 'Search all cases by applicant, address, case number, project code, or placecode. Filter by claimed organization, status, township, ZIP, submission date, or urgent need.', 'es' => '', 'uk' => ''],
    'case_search.filters_aria' => ['en' => 'Search filters', 'es' => '', 'uk' => ''],
    'case_search.results_aria' => ['en' => 'Search results', 'es' => '', 'uk' => ''],
    'case_search.search_placeholder' => ['en' => 'Case #, name, address, project code', 'es' => '', 'uk' => ''],
    'case_search.status' => ['en' => 'Project status', 'es' => '', 'uk' => ''],
    'case_search.all_statuses' => ['en' => 'All statuses', 'es' => '', 'uk' => ''],
    'case_search.claimed_org' => ['en' => 'Claimed organization', 'es' => '', 'uk' => ''],
    'case_search.all_orgs' => ['en' => 'All organizations', 'es' => '', 'uk' => ''],
    'case_search.unclaimed' => ['en' => 'Unclaimed', 'es' => '', 'uk' => ''],
    'case_search.city' => ['en' => 'Township / city', 'es' => '', 'uk' => ''],
    'case_search.all_cities' => ['en' => 'All townships', 'es' => '', 'uk' => ''],
    'case_search.zip' => ['en' => 'ZIP code', 'es' => '', 'uk' => ''],
    'case_search.zip_placeholder' => ['en' => 'e.g. 28804', 'es' => '', 'uk' => ''],
    'case_search.date_from' => ['en' => 'Submitted from', 'es' => '', 'uk' => ''],
    'case_search.date_to' => ['en' => 'Submitted to', 'es' => '', 'uk' => ''],
    'case_search.sort' => ['en' => 'Sort by', 'es' => '', 'uk' => ''],
    'case_search.sort_newest' => ['en' => 'Newest first', 'es' => '', 'uk' => ''],
    'case_search.sort_updated' => ['en' => 'Recently updated', 'es' => '', 'uk' => ''],
    'case_search.sort_priority' => ['en' => 'Highest priority', 'es' => '', 'uk' => ''],
    'case_search.sort_oldest' => ['en' => 'Oldest first', 'es' => '', 'uk' => ''],
    'case_search.sort_name' => ['en' => 'Applicant A–Z', 'es' => '', 'uk' => ''],
    'case_search.urgent_only' => ['en' => 'Urgent action needed', 'es' => '', 'uk' => ''],
    'case_search.clear' => ['en' => 'Clear', 'es' => '', 'uk' => ''],
    'case_search.results_found' => ['en' => '{count} case/application(s) found.', 'es' => '', 'uk' => ''],
    'case_search.results_limit' => ['en' => 'Showing the first 200 — narrow the filters for a smaller set.', 'es' => '', 'uk' => ''],
    'case_search.export_csv' => ['en' => 'Export CSV', 'es' => '', 'uk' => ''],
    'case_search.export_excel' => ['en' => 'Export Excel', 'es' => '', 'uk' => ''],
    'case_search.restricted_note_staff' => ['en' => 'Office-worker view: contact details are restricted and funding is summarized.', 'es' => '', 'uk' => ''],
    'case_search.restricted_note_org_admin' => ['en' => 'Org-admin view: contact details are restricted for cases claimed by other organizations.', 'es' => '', 'uk' => ''],
    'case_search.no_results' => ['en' => 'No cases or applications match your filters.', 'es' => '', 'uk' => ''],
    'case_search.col_case_number' => ['en' => 'Case #', 'es' => '', 'uk' => ''],
    'case_search.col_job_code' => ['en' => 'Job code', 'es' => '', 'uk' => ''],
    'case_search.col_homeowner' => ['en' => 'Homeowner', 'es' => '', 'uk' => ''],
    'case_search.col_address' => ['en' => 'Address', 'es' => '', 'uk' => ''],
    'case_search.col_township' => ['en' => 'Township', 'es' => '', 'uk' => ''],
    'case_search.col_zip' => ['en' => 'ZIP', 'es' => '', 'uk' => ''],
    'case_search.col_phone' => ['en' => 'Phone', 'es' => '', 'uk' => ''],
    'case_search.col_claimed_org' => ['en' => 'Claimed org', 'es' => '', 'uk' => ''],
    'case_search.col_status' => ['en' => 'Status', 'es' => '', 'uk' => ''],
    'case_search.col_phase' => ['en' => 'Phase', 'es' => '', 'uk' => ''],
    'case_search.col_submitted' => ['en' => 'Submitted', 'es' => '', 'uk' => ''],
    'case_search.col_updated' => ['en' => 'Updated', 'es' => '', 'uk' => ''],
    'case_search.urgent_flag_title' => ['en' => 'Urgent action needed — the applicant reported unsafe living conditions', 'es' => '', 'uk' => ''],
    'case_search.restricted' => ['en' => 'Restricted', 'es' => '', 'uk' => ''],
    'case_search.application_fallback' => ['en' => 'Application #{id}', 'es' => '', 'uk' => ''],

    // ---- Audit Trail (super-admin ledger viewer, audit-log.php) ----
    'audit.title' => ['en' => 'Audit Trail', 'es' => '', 'uk' => ''],
    'audit.subtitle' => ['en' => 'The immutable activity ledger. Entries are hash-chained and cannot be edited or deleted.', 'es' => '', 'uk' => ''],
    'audit.filters' => ['en' => 'Filters', 'es' => '', 'uk' => ''],
    'audit.user' => ['en' => 'User', 'es' => '', 'uk' => ''],
    'audit.application' => ['en' => 'Application', 'es' => '', 'uk' => ''],
    'audit.case' => ['en' => 'Case', 'es' => '', 'uk' => ''],
    'audit.category' => ['en' => 'Category', 'es' => '', 'uk' => ''],
    'audit.action' => ['en' => 'Action', 'es' => '', 'uk' => ''],
    'audit.source' => ['en' => 'Source', 'es' => '', 'uk' => ''],
    'audit.since' => ['en' => 'From', 'es' => '', 'uk' => ''],
    'audit.until' => ['en' => 'To', 'es' => '', 'uk' => ''],
    'audit.search' => ['en' => 'Search summaries', 'es' => '', 'uk' => ''],
    'audit.apply' => ['en' => 'Apply filters', 'es' => '', 'uk' => ''],
    'audit.reset' => ['en' => 'Reset', 'es' => '', 'uk' => ''],
    'audit.chain_ok' => ['en' => 'Ledger chain intact — {count} entries verified', 'es' => '', 'uk' => ''],
    'audit.chain_bad' => ['en' => 'Ledger chain BROKEN at entry #{id} ({error})', 'es' => '', 'uk' => ''],
    'audit.col_when' => ['en' => 'When', 'es' => '', 'uk' => ''],
    'audit.col_who' => ['en' => 'Who', 'es' => '', 'uk' => ''],
    'audit.col_what' => ['en' => 'What', 'es' => '', 'uk' => ''],
    'audit.col_household' => ['en' => 'Household', 'es' => '', 'uk' => ''],
    'audit.col_source' => ['en' => 'Source', 'es' => '', 'uk' => ''],
    'audit.selected' => ['en' => '{count} selected', 'es' => '', 'uk' => ''],
    'audit.no_results' => ['en' => 'No ledger entries match these filters.', 'es' => '', 'uk' => ''],
    'audit.details_toggle' => ['en' => 'Details', 'es' => '', 'uk' => ''],
    'audit.system_user' => ['en' => 'System', 'es' => '', 'uk' => ''],

    // ---- Case Review: applicant contact editing ----
    'case_review.edit_contact' => ['en' => 'Edit contact info', 'es' => '', 'uk' => ''],
    'case_review.save_changes' => ['en' => 'Save changes', 'es' => '', 'uk' => ''],
    'case_review.saving' => ['en' => 'Saving…', 'es' => '', 'uk' => ''],
    'case_review.cancel' => ['en' => 'Cancel', 'es' => '', 'uk' => ''],
    'case_review.first_name' => ['en' => 'First name', 'es' => '', 'uk' => ''],
    'case_review.last_name' => ['en' => 'Last name', 'es' => '', 'uk' => ''],
    'case_review.email' => ['en' => 'Email', 'es' => '', 'uk' => ''],
    'case_review.phone' => ['en' => 'Phone', 'es' => '', 'uk' => ''],
    'case_review.contact_edit_note' => ['en' => 'Edits write to the application — the editable working copy. The original submission is never modified.', 'es' => '', 'uk' => ''],
];

/** Resolve the active language: ?lang= wins and is remembered in the
    session; otherwise the remembered choice; otherwise English. */
function archr_current_language(): string {
    static $lang = null;
    if ($lang !== null) {
        return $lang;
    }
    archr_session_start();
    $requested = strtolower(trim((string)($_GET['lang'] ?? '')));
    if (array_key_exists($requested, ARCHR_LANGUAGES)) {
        $_SESSION['archr_lang'] = $requested;
    }
    $lang = $_SESSION['archr_lang'] ?? ARCHR_DEFAULT_LANGUAGE;
    if (!array_key_exists($lang, ARCHR_LANGUAGES)) {
        $lang = ARCHR_DEFAULT_LANGUAGE;
    }
    return $lang;
}

/** Look up a UI string in the active language. Falls back to English
    when the slot is empty, then to the key itself so a missing entry is
    obvious on screen. {placeholders} are filled from $params. */
function archr_translate(string $key, array $params = []): string {
    $entry = ARCHR_STRINGS[$key] ?? null;
    if ($entry === null) {
        return $key;
    }
    $text = $entry[archr_current_language()] ?? '';
    if ($text === '') {
        $text = $entry[ARCHR_DEFAULT_LANGUAGE] ?? $key;
    }
    foreach ($params as $name => $value) {
        $text = str_replace('{' . $name . '}', (string)$value, $text);
    }
    return $text;
}

/** archr_translate + HTML-escaping - the common case in templates.
    Mirrors e() from layout.php so this file only depends on session. */
function __(string $key, array $params = []): string {
    return htmlspecialchars(archr_translate($key, $params), ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

/** URL of the current page with ?lang switched - the language menu's
    links. Existing query filters (search, status, ...) are preserved. */
function archr_language_url(string $lang): string {
    $params = array_merge($_GET, ['lang' => $lang]);
    return (string)($_SERVER['SCRIPT_NAME'] ?? '') . '?' . http_build_query($params);
}