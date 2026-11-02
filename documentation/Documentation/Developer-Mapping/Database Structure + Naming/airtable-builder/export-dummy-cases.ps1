#Requires -Version 5.1
<#
.SYNOPSIS
  Exports ARCHR dummy/test cases from PostgreSQL to dummy-cases-export.json.

.DESCRIPTION
  Pulls every test case (joined to its intake submission, anchor, status and
  organization) plus every test intake submission, and writes one JSON file
  for sync-dummy-airtable.js to import into the dummy Airtable base.

  Credentials are read from archr_connect.php (repo root). When that file
  still holds template placeholders, the local-development defaults in
  app/config/database.php are used. Credentials are never printed.

  Uses the installed PostgreSQL ODBC driver (no psql required).

.USAGE
  powershell -ExecutionPolicy Bypass -File export-dummy-cases.ps1
#>

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$outFile  = Join-Path $PSScriptRoot 'dummy-cases-export.json'

# --- Credential resolution (placeholder-aware, never echoed) ----------------
function Get-PhpConfigValues($path) {
    $map = @{}
    if (-not (Test-Path $path)) { return $map }
    Select-String -Path $path -Pattern "'([A-Z_]+)'\s*=>\s*'([^']*)'" | ForEach-Object {
        $map[$_.Matches[0].Groups[1].Value] = $_.Matches[0].Groups[2].Value
    }
    return $map
}
function Test-Placeholder($v) { return ($null -eq $v -or $v -match 'YOUR|HERE|###|XXX') }

$cfg   = Get-PhpConfigValues (Join-Path $repoRoot 'archr_connect.php')
$defaults = Get-Content (Join-Path $repoRoot 'app\config\database.php') -Raw
function Get-Default($key) {
    $m = [regex]::Match($defaults, "getenv\('$key'\)\s*\?:\s*'([^']*)'")
    if ($m.Success) { return $m.Groups[1].Value } ; return $null
}
function Resolve-Pg($key) {
    if ($cfg.ContainsKey($key) -and -not (Test-Placeholder $cfg[$key])) { return $cfg[$key] }
    return (Get-Default $key)
}

$pg = @{
    host = Resolve-Pg 'PGHOST'; port = Resolve-Pg 'PGPORT'; db = Resolve-Pg 'PGDATABASE'
    user = Resolve-Pg 'PGUSER';  pass = Resolve-Pg 'PGPASSWORD'
}
if (Test-Placeholder $pg.pass) { throw 'No usable PGPASSWORD found in archr_connect.php or database.php defaults.' }

# --- Queries ----------------------------------------------------------------
# One faithful row-set per table (no flattening). The dummy Airtable base
# mirrors the PSQL schema, so the importer creates these rows as-is and the
# Vue demo joins on submission_id / status_id / organization_id, the same way
# the live Airtable base pulls related data through lookups.
$queries = [ordered]@{
  case_statuses = @"
SELECT id, status_code, status_name, status_sequence
  FROM case_statuses ORDER BY status_sequence
"@
  coalition_organizations = @"
SELECT id, organization_code, organization_name, contact_email, is_active
  FROM coalition_organizations WHERE is_active = TRUE ORDER BY id
"@
  intake_submissions = @"
SELECT id, applicant_first_name, applicant_last_name,
       to_char(applicant_dob, 'YYYY-MM-DD') AS applicant_dob,
       contact_email, cell_phone, home_phone,
       home_address, home_city, home_state, home_zip,
       household_size, household_adults, gross_annual_income, has_income,
       owns_home, home_type, year_built, helene_related,
       submission_status, to_char(submitted_at, 'YYYY-MM-DD"T"HH24:MI:SS') AS submitted_at,
       urgent_unable_to_stay, urgent_no_hvac, urgent_no_potable_water,
       urgent_no_bathroom, urgent_no_kitchen, urgent_open_to_elements,
       urgent_no_entry, urgent_accessibility, urgent_eviction_risk,
       is_test
  FROM intake_submissions WHERE is_test = TRUE ORDER BY id
"@
  cases = @"
SELECT c.id, c.submission_id, c.case_number, c.status_id, c.organization_id,
       c.assigned_caseworker_id,
       to_char(intake_completed_at,      'YYYY-MM-DD"T"HH24:MI:SS') AS intake_completed_at,
       to_char(assessment_scheduled_at,  'YYYY-MM-DD"T"HH24:MI:SS') AS assessment_scheduled_at,
       to_char(assessment_completed_at,  'YYYY-MM-DD"T"HH24:MI:SS') AS assessment_completed_at,
       to_char(approved_at,              'YYYY-MM-DD"T"HH24:MI:SS') AS approved_at,
       to_char(work_started_at,          'YYYY-MM-DD"T"HH24:MI:SS') AS work_started_at,
       to_char(work_completed_at,        'YYYY-MM-DD"T"HH24:MI:SS') AS work_completed_at,
       total_budget, total_actual_cost, notes, internal_notes,
       to_char(created_at, 'YYYY-MM-DD"T"HH24:MI:SS') AS created_at,
       to_char(updated_at, 'YYYY-MM-DD"T"HH24:MI:SS') AS updated_at
  FROM cases c
  JOIN intake_submissions s ON s.id = c.submission_id
 WHERE s.is_test = TRUE
 ORDER BY c.id
"@
}

$cs = "Driver={PostgreSQL ODBC Driver(UNICODE)};Server=$($pg.host);Port=$($pg.port);Database=$($pg.db);Uid=$($pg.user);Pwd=$($pg.pass);"
$conn = New-Object System.Data.Odbc.OdbcConnection($cs)
$conn.Open()

$payload = [ordered]@{
    exported_at = (Get-Date).ToString('s')
    source      = "postgresql://$($pg.host):$($pg.port)/$($pg.db) (is_test rows)"
    tables      = [ordered]@{}
}
try {
    foreach ($name in $queries.Keys) {
        $adapter = New-Object System.Data.Odbc.OdbcDataAdapter($queries[$name], $conn)
        $table   = New-Object System.Data.DataTable
        [void]$adapter.Fill($table)
        # Columns that are SQL booleans; the ODBC driver may surface them as
        # the strings 'True'/'False', so normalize by name to real booleans.
        $boolCols = @('is_active','is_test','has_income','owns_home','owns_lot','helene_related',
                      'urgent_unable_to_stay','urgent_no_hvac','urgent_no_potable_water',
                      'urgent_no_bathroom','urgent_no_kitchen','urgent_open_to_elements',
                      'urgent_no_entry','urgent_accessibility','urgent_other_issue','urgent_eviction_risk')
        $rows = @()
        foreach ($r in $table.Rows) {
            $row = [ordered]@{}
            foreach ($col in $table.Columns) {
                $v = $r[$col.ColumnName]
                if ($v -is [System.DBNull]) { continue }           # omit NULLs entirely
                if ($boolCols -contains $col.ColumnName) { $row[$col.ColumnName] = ($v -eq $true -or "$v" -eq 'True' -or "$v" -eq '1') }
                elseif ($v -is [bool]) { $row[$col.ColumnName] = $v }
                else { $row[$col.ColumnName] = "$v" }
            }
            $rows += [PSCustomObject]$row
        }
        $payload.tables[$name] = $rows
        Write-Output ("  " + $name + ": " + $rows.Count + " rows")
    }
} finally { $conn.Close() }

$json = $payload | ConvertTo-Json -Depth 4
if ($json.Length -gt 0 -and $json[0] -ne '{') { $json = $json.Substring($json.IndexOf('{')) }
[System.IO.File]::WriteAllText($outFile, $json, (New-Object System.Text.UTF8Encoding($false)))
Write-Output ("Exported -> " + $outFile)
