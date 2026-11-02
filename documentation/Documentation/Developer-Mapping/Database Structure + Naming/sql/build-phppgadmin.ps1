# =====================================================
# Rebuild sql/_master.phppgadmin.sql from source.
# =====================================================
# Flattens _master.sql (strips psql meta-commands, inlines every \ir file)
# and appends post-master migrations needed for a complete fresh deploy.
# Re-run this after ANY change to the sql files below, then re-paste the
# output into phpPgAdmin (or feed it to psql).
#
# Usage:  pwsh -File sql\build-phppgadmin.ps1
# =====================================================

$ErrorActionPreference = 'Stop'
$sqlDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Files inlined in dependency order (mirrors _master.sql's \ir sequence).
$files = @(
    'intake.sql',
    'partner-organizations.sql',
    'role-based-access.sql',
    'anchor-registration.sql',
    'volunteer-gamification.sql',
    'notifications.sql',
    'email-notification-digest.sql',
    'edit-application.sql',
    'documentation-sops.sql',
    'document-storage.sql',
    'project-level-finance.sql',
    'review-queue.sql',
    'requestor-dashboard-access.sql',
    'volunteer-task-claim.sql',
    'eligibility-tracker.sql',
    'feedback-collection.sql',
    'submission-handler.sql',
    'staff-dashboard-queue.sql',
    'metric-tracking.sql'
)

# Post-master migrations (not in _master.sql, required for login/accounts).
$postMaster = @(
    'requestor-account-link.sql',          # requestor_user_id FK + REQUESTOR role
    'add\super-admin-role.sql',            # SUPER_ADMIN role + permissions
    'add\system-users-username-fields.sql',# username/first_name/last_name columns
    'add\session-indefinite.sql'           # session_indefinite column
)

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine('-- =====================================================================')
[void]$sb.AppendLine('-- ARCHR flattened deploy for phpPgAdmin')
[void]$sb.AppendLine('-- GENERATED FILE - do not edit by hand. Regenerate with:')
[void]$sb.AppendLine('--     pwsh -File sql\build-phppgadmin.ps1')
[void]$sb.AppendLine('-- HOW TO USE: phpPgAdmin > select the archr database > SQL tab > paste')
[void]$sb.AppendLine('-- this entire file > Execute.')
[void]$sb.AppendLine('-- =====================================================================')
[void]$sb.AppendLine('')
[void]$sb.AppendLine('-- NOTE: CREATE EXTENSION pgcrypto is intentionally NOT in this script.')
[void]$sb.AppendLine('-- Shared cPanel PostgreSQL users are not superusers and cannot create')
[void]$sb.AppendLine('-- extensions. Instead, the compatibility shim below provides')
[void]$sb.AppendLine('-- gen_random_uuid() ONLY when neither the PostgreSQL 13+ built-in nor')
[void]$sb.AppendLine('-- the pgcrypto extension is present. It is a no-op on both.')
[void]$sb.AppendLine('')
$shim = @'
-- gen_random_uuid() compatibility shim (pure SQL, works on PG 9.x+).
DO $shim$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM pg_proc p
          JOIN pg_namespace n ON n.oid = p.pronamespace
         WHERE p.proname = 'gen_random_uuid'
    ) THEN
        EXECUTE $fn$
            CREATE FUNCTION gen_random_uuid() RETURNS uuid AS $body$
            DECLARE
                b text := '';
                i int;
            BEGIN
                FOR i IN 1..16 LOOP
                    b := b || lpad(to_hex(floor(random() * 256)::int), 2, '0');
                END LOOP;
                -- set version (4) and variant (10xx) bits of a UUID v4
                b := overlay(b placing lpad(to_hex(64  + floor(random() * 16)::int), 2, '0') from 13 for 2);
                b := overlay(b placing lpad(to_hex(128 + floor(random() * 64)::int), 2, '0') from 17 for 2);
                RETURN b::uuid;
            END;
            $body$ LANGUAGE plpgsql;
        $fn$;
    END IF;
END $shim$;
'@
[void]$sb.AppendLine($shim)

foreach ($f in ($files + $postMaster)) {
    $path = Join-Path $sqlDir $f
    if (-not (Test-Path $path)) { throw "Missing source file: $path" }
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('-- ----------------------------------------------------------------')
    [void]$sb.AppendLine("-- BEGIN sql/$f")
    [void]$sb.AppendLine('-- ----------------------------------------------------------------')
    [void]$sb.AppendLine([System.IO.File]::ReadAllText($path))
    [void]$sb.AppendLine("-- END sql/$f")
}

$out = Join-Path $sqlDir '_master.phppgadmin.sql'
[System.IO.File]::WriteAllText($out, $sb.ToString(), (New-Object System.Text.UTF8Encoding($false)))
$lines = (Get-Content $out | Measure-Object -Line).Lines
Write-Host "Wrote $out ($((Get-Item $out).Length) bytes, $lines lines)"
