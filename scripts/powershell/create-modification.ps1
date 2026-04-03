#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [switch]$Json,
    [switch]$ListFeatures,
    [string]$FeatureNum,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ModificationDescription
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/common.ps1"

$description = ($ModificationDescription -join ' ').Trim()
$projectRoot = Get-ProjectRoot -ScriptDir $PSScriptRoot
$extensionRoot = Get-ExtensionRoot -ScriptDir $PSScriptRoot
$specsDir = Join-Path $projectRoot 'specs'

if ($ListFeatures) {
    if ([string]::IsNullOrWhiteSpace($description)) {
        Write-Error "Description required for -ListFeatures"
        exit 1
    }
    $features = Get-FeatureDirectories -SpecsDir $specsDir | ForEach-Object {
        $number = $_.Name.Substring(0, 3)
        [pscustomobject]@{ number = $number; name = $_.Name.Substring(4); full = $_.Name }
    }
    [pscustomobject]@{ mode = 'list'; description = $description; features = $features } | ConvertTo-Json -Compress
    exit 0
}

if ([string]::IsNullOrWhiteSpace($FeatureNum) -or [string]::IsNullOrWhiteSpace($description)) {
    Write-Error "Usage: ./create-modification.ps1 [-Json] <feature-number> <modification-description>"
    exit 1
}

$featureDir = Get-ChildItem -LiteralPath $specsDir -Directory | Where-Object { $_.Name -like "$FeatureNum-*" } | Select-Object -First 1
if (-not $featureDir) {
    Write-Error "Could not find feature $FeatureNum in specs/"
    exit 1
}

$modificationsDir = Join-Path $featureDir.FullName 'modifications'
New-Item -ItemType Directory -Path $modificationsDir -Force | Out-Null
$modNum = Get-NextPrefixedNumber -SpecsDir $modificationsDir -Glob '*' -Pattern '^(\d{3})'
$slug = ConvertTo-Slug -Text $description
$words = Get-TopSlugWords -Slug $slug
$branchName = "$FeatureNum-mod-$modNum-$words"
$modId = "$FeatureNum-mod-$modNum"

if (Test-HasGitRepo -Root $projectRoot) { git -C $projectRoot checkout -b $branchName | Out-Null }

$modDir = Join-Path $modificationsDir "$modNum-$words"
New-Item -ItemType Directory -Path $modDir -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $modDir 'contracts') -Force | Out-Null

$template = Join-Path $extensionRoot 'extensions/workflows/modify/modification-template.md'
$modSpec = Join-Path $modDir 'modification-spec.md'
if (Test-Path -LiteralPath $template) { Copy-Item $template $modSpec -Force } else { New-Item -ItemType File -Path $modSpec -Force | Out-Null }

$impactFile = Join-Path $modDir 'impact-analysis.md'
@(
    "# Impact Analysis for $($featureDir.Name)"
    ""
    "**Generated**: $(Get-Date -Format s)"
    "**Modification**: $description"
    ""
    "Review these areas before implementation:"
    "- Command definitions and workflow prompts"
    "- Template paths and helper scripts"
    "- User-facing install and upgrade documentation"
) | Set-Content -Path $impactFile

$env:SPECIFY_MODIFICATION = $modId
if ($Json) {
    [pscustomobject]@{
        MOD_ID = $modId
        BRANCH_NAME = $branchName
        MOD_SPEC_FILE = $modSpec
        IMPACT_FILE = $impactFile
        FEATURE_NAME = $featureDir.Name
        MOD_NUM = $modNum
    } | ConvertTo-Json -Compress
} else {
    Write-Output "MOD_ID: $modId"
    Write-Output "BRANCH_NAME: $branchName"
    Write-Output "FEATURE_NAME: $($featureDir.Name)"
    Write-Output "MOD_SPEC_FILE: $modSpec"
    Write-Output "IMPACT_FILE: $impactFile"
}
