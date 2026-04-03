#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [switch]$Json,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$RefactorDescription
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/common.ps1"

$description = ($RefactorDescription -join ' ').Trim()
if ([string]::IsNullOrWhiteSpace($description)) {
    Write-Error "Usage: ./create-refactor.ps1 [-Json] <refactoring-description>"
    exit 1
}

$projectRoot = Get-ProjectRoot -ScriptDir $PSScriptRoot
$extensionRoot = Get-ExtensionRoot -ScriptDir $PSScriptRoot
$specsDir = Join-Path $projectRoot 'specs'
New-Item -ItemType Directory -Path $specsDir -Force | Out-Null
$refactorNum = Get-NextPrefixedNumber -SpecsDir $specsDir -Glob 'refactor-*' -Pattern '^refactor-(\d{3})'
$slug = ConvertTo-Slug -Text $description
$words = Get-TopSlugWords -Slug $slug
$branchName = "refactor/$refactorNum-$words"
$refactorId = "refactor-$refactorNum"

if (Test-HasGitRepo -Root $projectRoot) { git -C $projectRoot checkout -b $branchName | Out-Null }

$refactorDir = Join-Path $specsDir "$refactorId-$words"
New-Item -ItemType Directory -Path $refactorDir -Force | Out-Null
$template = Join-Path $extensionRoot 'extensions/workflows/refactor/refactor-template.md'
$specFile = Join-Path $refactorDir 'refactor-spec.md'
if (Test-Path -LiteralPath $template) { Copy-Item $template $specFile -Force } else { New-Item -ItemType File -Path $specFile -Force | Out-Null }

$metricsBefore = Join-Path $refactorDir 'metrics-before.md'
$metricsAfter = Join-Path $refactorDir 'metrics-after.md'
$behavioralSnapshot = Join-Path $refactorDir 'behavioral-snapshot.md'
@(
    "# Baseline Metrics (Before Refactoring)"
    ""
    "**Status**: Capture before making changes."
) | Set-Content -Path $metricsBefore
@(
    "# Post-Refactoring Metrics (After Refactoring)"
    ""
    "**Status**: Capture after refactoring is complete."
) | Set-Content -Path $metricsAfter
@(
    "# Behavioral Snapshot"
    ""
    "Document the observable behavior that must remain unchanged."
) | Set-Content -Path $behavioralSnapshot

$env:SPECIFY_REFACTOR = $refactorId
if ($Json) {
    [pscustomobject]@{
        REFACTOR_ID = $refactorId
        BRANCH_NAME = $branchName
        REFACTOR_SPEC_FILE = $specFile
        METRICS_BEFORE = $metricsBefore
        METRICS_AFTER = $metricsAfter
        BEHAVIORAL_SNAPSHOT = $behavioralSnapshot
        REFACTOR_NUM = $refactorNum
    } | ConvertTo-Json -Compress
} else {
    Write-Output "REFACTOR_ID: $refactorId"
    Write-Output "BRANCH_NAME: $branchName"
    Write-Output "REFACTOR_SPEC_FILE: $specFile"
}
