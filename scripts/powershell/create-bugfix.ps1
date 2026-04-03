#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [switch]$Json,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$BugDescription
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/common.ps1"

$description = ($BugDescription -join ' ').Trim()
if ([string]::IsNullOrWhiteSpace($description)) {
    Write-Error "Usage: ./create-bugfix.ps1 [-Json] <bug_description>"
    exit 1
}

$projectRoot = Get-ProjectRoot -ScriptDir $PSScriptRoot
$extensionRoot = Get-ExtensionRoot -ScriptDir $PSScriptRoot
$hasGit = Test-HasGitRepo -Root $projectRoot
$specsDir = Join-Path $projectRoot 'specs'
New-Item -ItemType Directory -Path $specsDir -Force | Out-Null

$bugNum = Get-NextPrefixedNumber -SpecsDir $specsDir -Glob 'bugfix-*' -Pattern '^bugfix-(\d{3})'
$slug = ConvertTo-Slug -Text $description
$words = Get-TopSlugWords -Slug $slug
$branchName = "bugfix/$bugNum-$words"
$bugId = "bugfix-$bugNum"

if ($hasGit) { git -C $projectRoot checkout -b $branchName | Out-Null }

$bugDir = Join-Path $specsDir "$bugId-$words"
New-Item -ItemType Directory -Path $bugDir -Force | Out-Null
$template = Join-Path $extensionRoot 'extensions/workflows/bugfix/bug-report-template.md'
$bugReport = Join-Path $bugDir 'bug-report.md'
if (Test-Path -LiteralPath $template) { Copy-Item $template $bugReport -Force } else { New-Item -ItemType File -Path $bugReport -Force | Out-Null }
$env:SPECIFY_BUGFIX = $bugId

if ($Json) {
    [pscustomobject]@{
        BUG_ID = $bugId
        BRANCH_NAME = $branchName
        BUG_REPORT_FILE = $bugReport
        BUG_NUM = $bugNum
    } | ConvertTo-Json -Compress
} else {
    Write-Output "BUG_ID: $bugId"
    Write-Output "BRANCH_NAME: $branchName"
    Write-Output "BUG_REPORT_FILE: $bugReport"
    Write-Output "BUG_NUM: $bugNum"
}
