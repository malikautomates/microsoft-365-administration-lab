<#
.SYNOPSIS
    Applies a chosen organisation name across the Microsoft 365 lab portfolio repository.

.DESCRIPTION
    Replaces the placeholder tokens {{COMPANY}}, {{ROOT_DOMAIN}} and {{TENANT}} in
    every Markdown, PowerShell, CSV and JSON file beneath the repository root.

    Parameters are validated before any file is written. If validation fails, no
    files are modified.

.PARAMETER Company
    Display name of the modelled organisation, used in prose.

.PARAMETER RootDomain
    Custom domain added to the tenant. Also the UPN suffix for user accounts.

.PARAMETER Tenant
    Initial tenant name, without the .onmicrosoft.com suffix. Assigned at tenant
    creation and immutable thereafter.

.EXAMPLE
    .\Set-LabName.ps1 -Company 'Example Freight' -RootDomain 'examplefreight.ca' `
        -Tenant 'examplefreight' -WhatIf

.NOTES
    Run with -WhatIf first to review the change set.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $Company,

    [Parameter(Mandatory)]
    [ValidatePattern('^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+$')]
    [string] $RootDomain,

    [Parameter(Mandatory)]
    [ValidateLength(1, 27)]
    [ValidatePattern('^[a-z0-9]([a-z0-9-]*[a-z0-9])?$')]
    [string] $Tenant
)

$ErrorActionPreference = 'Stop'

# --- Validation -----------------------------------------------------------

# The initial domain is <tenant>.onmicrosoft.com. Microsoft rejects a tenant name
# already in use globally; length and character rules are enforced here, uniqueness
# can only be confirmed at sign-up.
if ($Tenant -like '*.*') {
    throw "Tenant '$Tenant' must be the name only, without the .onmicrosoft.com suffix."
}

if ($Tenant -match '^(www|admin|portal|microsoft|office|login)$') {
    throw "Tenant name '$Tenant' is reserved and will be rejected at sign-up."
}

# --- Token map ------------------------------------------------------------

$replacements = [ordered]@{
    '{{COMPANY}}'     = $Company
    '{{ROOT_DOMAIN}}' = $RootDomain
    '{{TENANT}}'      = $Tenant
}

Write-Host 'Token map:' -ForegroundColor Cyan
$replacements.GetEnumerator() | ForEach-Object {
    Write-Host ('  {0,-16} -> {1}' -f $_.Key, $_.Value)
}
Write-Host ''

# --- Apply ----------------------------------------------------------------

$repoRoot   = Split-Path -Parent $PSScriptRoot
$extensions = '*.md', '*.ps1', '*.csv', '*.json'

$files = Get-ChildItem -Path $repoRoot -Include $extensions -Recurse -File |
         Where-Object { $_.FullName -ne $PSCommandPath }

$changed = 0

foreach ($file in $files) {
    $original = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
    $updated  = $original

    foreach ($pair in $replacements.GetEnumerator()) {
        $updated = $updated.Replace($pair.Key, $pair.Value)
    }

    if ($updated -ne $original) {
        $relative = $file.FullName.Substring($repoRoot.Length + 1)

        if ($PSCmdlet.ShouldProcess($relative, 'Apply organisation name')) {
            Set-Content -LiteralPath $file.FullName -Value $updated -Encoding UTF8 -NoNewline
        }

        Write-Host "  updated  $relative" -ForegroundColor Green
        $changed++
    }
}

Write-Host ''
if ($WhatIfPreference) {
    Write-Host "$changed file(s) would be modified. Re-run without -WhatIf to apply." -ForegroundColor Yellow
}
else {
    Write-Host "$changed file(s) modified." -ForegroundColor Cyan
    Write-Host ''
    Write-Host 'Verifying no tokens remain...' -ForegroundColor Cyan

    $remaining = Get-ChildItem -Path $repoRoot -Include $extensions -Recurse -File |
                 Where-Object { $_.FullName -ne $PSCommandPath } |
                 Select-String -Pattern '\{\{[A-Z_]+\}\}'

    if ($remaining) {
        Write-Warning 'Unreplaced tokens found:'
        $remaining | ForEach-Object {
            Write-Host ('  {0}:{1}  {2}' -f $_.Filename, $_.LineNumber, $_.Line.Trim())
        }
    }
    else {
        Write-Host 'No tokens remain.' -ForegroundColor Green
    }
}
