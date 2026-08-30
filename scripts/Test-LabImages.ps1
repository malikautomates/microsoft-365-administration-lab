<#
.SYNOPSIS
    Reports which lab screenshots are still missing.

.DESCRIPTION
    Parses every lab README for Markdown image references, then checks whether the
    referenced file exists on disk. Reports missing images per lab, and flags any
    image files present that no README references.

    Run this before publishing. A pushed lab with missing images renders broken-image
    icons on GitHub.

.PARAMETER Lab
    Optional lab number filter, e.g. '01'. Omit to check all labs.

.EXAMPLE
    .\Test-LabImages.ps1

.EXAMPLE
    .\Test-LabImages.ps1 -Lab 01
#>

[CmdletBinding()]
param(
    [ValidatePattern('^\d{2}$')]
    [string] $Lab
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$labsRoot = Join-Path $repoRoot 'labs'

if (-not (Test-Path $labsRoot)) {
    throw "No labs directory found at $labsRoot"
}

$labDirs = Get-ChildItem -Path $labsRoot -Directory | Sort-Object Name
if ($Lab) {
    $labDirs = $labDirs | Where-Object { $_.Name -like "$Lab-*" }
    if (-not $labDirs) { throw "No lab directory matching '$Lab-*'" }
}

$totalReferenced = 0
$totalMissing    = 0
$totalOrphaned   = 0

foreach ($dir in $labDirs) {
    $readme = Join-Path $dir.FullName 'README.md'
    if (-not (Test-Path $readme)) { continue }

    $content = Get-Content -LiteralPath $readme -Raw

    # Markdown image references of the form ![alt](images/name.png)
    $matches = [regex]::Matches($content, '!\[[^\]]*\]\((images/[^)]+)\)')
    $referenced = $matches | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique

    if (-not $referenced) {
        Write-Host ("{0,-46} no image references" -f $dir.Name) -ForegroundColor DarkGray
        continue
    }

    $missing = @()
    foreach ($ref in $referenced) {
        $path = Join-Path $dir.FullName ($ref -replace '/', '\')
        if (-not (Test-Path $path)) { $missing += $ref }
    }

    # Image files on disk that nothing references.
    $imagesDir = Join-Path $dir.FullName 'images'
    $orphaned  = @()
    if (Test-Path $imagesDir) {
        $onDisk = Get-ChildItem -Path $imagesDir -File |
                  Where-Object { $_.Name -ne '.gitkeep' } |
                  ForEach-Object { "images/$($_.Name)" }
        $orphaned = $onDisk | Where-Object { $_ -notin $referenced }
    }

    $totalReferenced += $referenced.Count
    $totalMissing    += $missing.Count
    $totalOrphaned   += $orphaned.Count

    $have   = $referenced.Count - $missing.Count
    $colour = if ($missing.Count -eq 0) { 'Green' } elseif ($have -eq 0) { 'Red' } else { 'Yellow' }

    Write-Host ("{0,-46} {1,2}/{2,-2} captured" -f $dir.Name, $have, $referenced.Count) -ForegroundColor $colour

    foreach ($m in $missing)  { Write-Host "      missing   $m" -ForegroundColor DarkYellow }
    foreach ($o in $orphaned) { Write-Host "      orphaned  $o" -ForegroundColor DarkCyan }
}

Write-Host ''
Write-Host ('Referenced: {0}   Captured: {1}   Missing: {2}   Orphaned: {3}' -f
    $totalReferenced, ($totalReferenced - $totalMissing), $totalMissing, $totalOrphaned) -ForegroundColor Cyan

if ($totalMissing -gt 0) {
    Write-Host 'Labs with missing images will render broken-image icons on GitHub.' -ForegroundColor Yellow
}
