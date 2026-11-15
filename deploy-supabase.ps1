[CmdletBinding()]
param(
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'
$projectRef = 'kuhibiszzisezijhwmxa'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRefPath = Join-Path $root 'supabase\.temp\project-ref'

if (-not (Get-Command supabase -ErrorAction SilentlyContinue)) {
    throw 'Supabase CLI not found. Install the official Supabase CLI and try again.'
}

if (-not (Test-Path $projectRefPath)) {
    throw "Project is not linked. Run 'supabase login' and 'supabase link --project-ref $projectRef' first."
}

$linkedProjectRef = (Get-Content -Raw $projectRefPath).Trim()
if ($linkedProjectRef -ne $projectRef) {
    throw "Linked project '$linkedProjectRef' does not match expected project '$projectRef'."
}

Push-Location $root
try {
    & supabase db push --dry-run
    if ($LASTEXITCODE -ne 0) {
        throw 'Migration dry run failed.'
    }

    if (-not $Apply) {
        Write-Host 'Dry run only. Review the plan, then run .\deploy-supabase.ps1 -Apply to deploy.'
        return
    }

    $confirmation = Read-Host "Type APPLY to deploy migrations to project '$projectRef'"
    if ($confirmation -cne 'APPLY') {
        Write-Host 'Deployment cancelled.'
        return
    }

    & supabase db push
    if ($LASTEXITCODE -ne 0) {
        throw 'Supabase migration deployment failed.'
    }

    Write-Host 'Supabase migrations deployed successfully.'
}
finally {
    Pop-Location
}
