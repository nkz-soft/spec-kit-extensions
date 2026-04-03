#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [switch]$Json,
    [switch]$ListFeatures,
    [string]$FeatureNum,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Reason
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/common.ps1"

$reasonText = ($Reason -join ' ').Trim()
$projectRoot = Get-ProjectRoot -ScriptDir $PSScriptRoot
$extensionRoot = Get-ExtensionRoot -ScriptDir $PSScriptRoot
$specsDir = Join-Path $projectRoot 'specs'

if ($ListFeatures) {
    if ([string]::IsNullOrWhiteSpace($reasonText)) {
        Write-Error "Reason required for -ListFeatures"
        exit 1
    }
    $features = Get-FeatureDirectories -SpecsDir $specsDir | ForEach-Object {
        $number = $_.Name.Substring(0, 3)
        [pscustomobject]@{ number = $number; name = $_.Name.Substring(4); full = $_.Name }
    }
    [pscustomobject]@{ mode = 'list'; reason = $reasonText; features = $features } | ConvertTo-Json -Compress
    exit 0
}

if ([string]::IsNullOrWhiteSpace($FeatureNum) -or [string]::IsNullOrWhiteSpace($reasonText)) {
    Write-Error "Usage: ./create-deprecate.ps1 [-Json] <feature-number> <reason>"
    exit 1
}

$featureDir = Get-ChildItem -LiteralPath $specsDir -Directory | Where-Object { $_.Name -like "$FeatureNum-*" } | Select-Object -First 1
if (-not $featureDir) {
    Write-Error "Could not find feature $FeatureNum in specs/"
    exit 1
}

$deprecateNum = Get-NextPrefixedNumber -SpecsDir $specsDir -Glob 'deprecate-*' -Pattern '^deprecate-(\d{3})'
$featureShort = $featureDir.Name.Substring(4)
$branchName = "deprecate/$deprecateNum-$featureShort"
$deprecateId = "deprecate-$deprecateNum"

if (Test-HasGitRepo -Root $projectRoot) { git -C $projectRoot checkout -b $branchName | Out-Null }

$deprecateDir = Join-Path $specsDir "$deprecateId-$featureShort"
New-Item -ItemType Directory -Path $deprecateDir -Force | Out-Null
$template = Join-Path $extensionRoot 'extensions/workflows/deprecate/deprecation-template.md'
$deprecationFile = Join-Path $deprecateDir 'deprecation.md'
if (Test-Path -LiteralPath $template) { Copy-Item $template $deprecationFile -Force } else { New-Item -ItemType File -Path $deprecationFile -Force | Out-Null }
$dependenciesFile = Join-Path $deprecateDir 'dependencies.md'
@(
    "# Dependencies"
    ""
    "**Feature**: $($featureDir.Name)"
    "**Reason**: $reasonText"
    ""
    "Review code, routes, tests, and user-facing docs before removal."
) | Set-Content -Path $dependenciesFile

$env:SPECIFY_DEPRECATE = $deprecateId
if ($Json) {
    [pscustomobject]@{
        DEPRECATE_ID = $deprecateId
        BRANCH_NAME = $branchName
        DEPRECATION_FILE = $deprecationFile
        DEPENDENCIES_FILE = $dependenciesFile
        DEPRECATE_NUM = $deprecateNum
        FEATURE_NUM = $FeatureNum
        FEATURE_NAME = $featureDir.Name
        REASON = $reasonText
    } | ConvertTo-Json -Compress
} else {
    Write-Output "DEPRECATE_ID: $deprecateId"
    Write-Output "BRANCH_NAME: $branchName"
    Write-Output "DEPRECATION_FILE: $deprecationFile"
    Write-Output "DEPENDENCIES_FILE: $dependenciesFile"
}
