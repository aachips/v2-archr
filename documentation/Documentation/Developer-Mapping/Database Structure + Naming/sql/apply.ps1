# =====================================================
# ARCHR PostgreSQL bootstrap script
# =====================================================
# Creates the `archr` database (if absent) and runs the
# master deployment script against it.
#
# Usage:
#     pwsh -File sql\apply.ps1
#     pwsh -File sql\apply.ps1 -Reset           # drop + recreate db
#     pwsh -File sql\apply.ps1 -User postgres -Port 5432
#
# Authentication:
#   Set the PGPASSWORD environment variable before running, e.g.
#       $env:PGPASSWORD = 'your-postgres-password'
#       pwsh -File sql\apply.ps1
#   Or configure a .pgpass file (recommended for repeated use).
# =====================================================

[CmdletBinding()]
param(
    [string]$Database = 'archr',
    [string]$User     = 'postgres',
    [string]$DbHost   = 'localhost',
    [int]   $Port     = 5432,
    [switch]$Reset
)

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$masterSql = Join-Path $scriptDir '_master.sql'

if (-not (Get-Command psql -ErrorAction SilentlyContinue)) {
    throw "psql is not on PATH. Add Laragon's PostgreSQL bin folder (e.g. C:\laragon\bin\postgresql\<version>\bin) to PATH and reopen the terminal."
}

if (-not (Test-Path $masterSql)) {
    throw "Master script not found at $masterSql"
}

$psqlBase = @('-h', $DbHost, '-p', $Port, '-U', $User, '-v', 'ON_ERROR_STOP=1')

if ($Reset) {
    Write-Host "Dropping database '$Database' if it exists..." -ForegroundColor Yellow
    & psql @psqlBase -d postgres -c "DROP DATABASE IF EXISTS $Database;"
    if ($LASTEXITCODE -ne 0) { throw "Failed to drop database '$Database'." }
}

# Create database if it does not already exist
$exists = & psql @psqlBase -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$Database';"
if ($LASTEXITCODE -ne 0) { throw "Could not connect to PostgreSQL on ${DbHost}:${Port} as $User." }

if (-not $exists -or "$exists".Trim() -ne '1') {
    Write-Host "Creating database '$Database'..." -ForegroundColor Cyan
    & psql @psqlBase -d postgres -c "CREATE DATABASE $Database;"
    if ($LASTEXITCODE -ne 0) { throw "Failed to create database '$Database'." }
} else {
    Write-Host "Database '$Database' already exists - applying master script in place." -ForegroundColor DarkGray
}

Write-Host "Applying master schema to '$Database'..." -ForegroundColor Cyan
& psql @psqlBase -d $Database -f $masterSql
if ($LASTEXITCODE -ne 0) { throw "Master script failed. See output above for the failing statement." }

Write-Host "ARCHR database ready." -ForegroundColor Green
