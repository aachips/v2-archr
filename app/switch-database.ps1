# ================================================================
# Database Switching Helper Script
# ================================================================
# This script helps you quickly switch between PostgreSQL and Airtable.
#
# Usage:
#   .\switch-database.ps1 postgresql
#   .\switch-database.ps1 airtable
#   .\switch-database.ps1 status
# ================================================================

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('postgresql', 'airtable', 'status')]
    [string]$Driver = 'status'
)

Write-Host "=== ARCHR Database Switcher ===" -ForegroundColor Cyan
Write-Host ""

# Show current status
function Show-Status {
    $currentDriver = $env:DB_DRIVER
    if (-not $currentDriver) {
        $currentDriver = "postgresql (default)"
    }
    
    Write-Host "Current Database Driver: " -NoNewline
    Write-Host $currentDriver -ForegroundColor Yellow
    
    if ($env:AIRTABLE_API_KEY) {
        Write-Host "Airtable API Key: " -NoNewline
        Write-Host "Configured (${($env:AIRTABLE_API_KEY.Length)} characters)" -ForegroundColor Green
    } else {
        Write-Host "Airtable API Key: " -NoNewline
        Write-Host "Not configured" -ForegroundColor Red
    }
    
    Write-Host "PostgreSQL Database: " -NoNewline
    $pgDb = $env:PGDATABASE
    if (-not $pgDb) { $pgDb = "archr (default)" }
    Write-Host $pgDb -ForegroundColor Green
    
    Write-Host ""
}

# Switch to PostgreSQL
function Switch-PostgreSQL {
    Write-Host "Switching to PostgreSQL..." -ForegroundColor Green
    $env:DB_DRIVER = "postgresql"
    
    # Optional: Set PostgreSQL variables if not already set
    if (-not $env:PGHOST) { $env:PGHOST = "127.0.0.1" }
    if (-not $env:PGPORT) { $env:PGPORT = "5432" }
    if (-not $env:PGDATABASE) { $env:PGDATABASE = "archr" }
    if (-not $env:PGUSER) { $env:PGUSER = "postgres" }
    
    Write-Host "✓ Database driver set to: postgresql" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now use:" -ForegroundColor Cyan
    Write-Host "  - Raw SQL queries"
    Write-Host "  - Database transactions"
    Write-Host "  - Complex joins and filters"
    Write-Host ""
}

# Switch to Airtable
function Switch-Airtable {
    Write-Host "Switching to Airtable..." -ForegroundColor Green
    $env:DB_DRIVER = "airtable"
    
    # Check if API key is set
    if (-not $env:AIRTABLE_API_KEY) {
        Write-Host ""
        Write-Host "⚠ Warning: AIRTABLE_API_KEY is not set!" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "To set your API key:" -ForegroundColor Cyan
        Write-Host '  $env:AIRTABLE_API_KEY = "your_api_key_here"'
        Write-Host ""
        Write-Host "Get your API key from: https://airtable.com/create/tokens"
        Write-Host ""
    }
    
    Write-Host "✓ Database driver set to: airtable" -ForegroundColor Green
    Write-Host ""
    Write-Host "Remember:" -ForegroundColor Cyan
    Write-Host "  - Update table mappings in app/config/database.php"
    Write-Host "  - Use abstracted methods only (no raw SQL)"
    Write-Host "  - Transactions are not supported"
    Write-Host ""
}

# Main logic
switch ($Driver) {
    'postgresql' {
        Switch-PostgreSQL
        Show-Status
    }
    'airtable' {
        Switch-Airtable
        Show-Status
    }
    'status' {
        Show-Status
        Write-Host "Usage:" -ForegroundColor Cyan
        Write-Host "  .\switch-database.ps1 postgresql  # Switch to PostgreSQL"
        Write-Host "  .\switch-database.ps1 airtable    # Switch to Airtable"
        Write-Host "  .\switch-database.ps1 status      # Show current status"
        Write-Host ""
    }
}

Write-Host "To test the connection, run:" -ForegroundColor Cyan
Write-Host "  php app/examples/database-example.php"
Write-Host ""
