#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [switch]$Json,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$IncidentDescription
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/common.ps1"

$description = ($IncidentDescription -join ' ').Trim()
if ([string]::IsNullOrWhiteSpace($description)) {
    Write-Error "Usage: ./create-hotfix.ps1 [-Json] <incident-description>"
    exit 1
}

$projectRoot = Get-ProjectRoot -ScriptDir $PSScriptRoot
$extensionRoot = Get-ExtensionRoot -ScriptDir $PSScriptRoot
$specsDir = Join-Path $projectRoot 'specs'
New-Item -ItemType Directory -Path $specsDir -Force | Out-Null
$hotfixNum = Get-NextPrefixedNumber -SpecsDir $specsDir -Glob 'hotfix-*' -Pattern '^hotfix-(\d{3})'
$slug = ConvertTo-Slug -Text $description
$words = Get-TopSlugWords -Slug $slug
$branchName = "hotfix/$hotfixNum-$words"
$hotfixId = "hotfix-$hotfixNum"

if (Test-HasGitRepo -Root $projectRoot) { git -C $projectRoot checkout -b $branchName | Out-Null }

$hotfixDir = Join-Path $specsDir "$hotfixId-$words"
New-Item -ItemType Directory -Path $hotfixDir -Force | Out-Null
$hotfixTemplate = Join-Path $extensionRoot 'extensions/workflows/hotfix/hotfix-template.md'
$postTemplate = Join-Path $extensionRoot 'extensions/workflows/hotfix/post-mortem-template.md'
$hotfixFile = Join-Path $hotfixDir 'hotfix.md'
$postmortemFile = Join-Path $hotfixDir 'post-mortem.md'
if (Test-Path -LiteralPath $hotfixTemplate) { Copy-Item $hotfixTemplate $hotfixFile -Force } else { New-Item -ItemType File -Path $hotfixFile -Force | Out-Null }
if (Test-Path -LiteralPath $postTemplate) { Copy-Item $postTemplate $postmortemFile -Force } else { New-Item -ItemType File -Path $postmortemFile -Force | Out-Null }
$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss 'UTC'")
$env:SPECIFY_HOTFIX = $hotfixId

if ($Json) {
    [pscustomobject]@{
        HOTFIX_ID = $hotfixId
        BRANCH_NAME = $branchName
        HOTFIX_FILE = $hotfixFile
        POSTMORTEM_FILE = $postmortemFile
        HOTFIX_NUM = $hotfixNum
        TIMESTAMP = $timestamp
    } | ConvertTo-Json -Compress
} else {
    Write-Output "HOTFIX_ID: $hotfixId"
    Write-Output "BRANCH_NAME: $branchName"
    Write-Output "HOTFIX_FILE: $hotfixFile"
    Write-Output "POSTMORTEM_FILE: $postmortemFile"
}
