#!/usr/bin/env pwsh

function Find-ProjectRoot {
    param([string]$StartDir = (Get-Location).Path)

    $resolved = Resolve-Path -LiteralPath $StartDir -ErrorAction SilentlyContinue
    $current = if ($resolved) { $resolved.Path } else { $null }
    if (-not $current) { return $null }

    while ($true) {
        if (Test-Path -LiteralPath (Join-Path $current ".specify") -PathType Container) { return $current }
        if (Test-Path -LiteralPath (Join-Path $current ".git")) { return $current }

        $parent = Split-Path $current -Parent
        if ([string]::IsNullOrEmpty($parent) -or $parent -eq $current) { return $null }
        $current = $parent
    }
}

function Get-ProjectRoot {
    param([string]$ScriptDir)

    $cwdRoot = Find-ProjectRoot -StartDir (Get-Location).Path
    if ($cwdRoot) { return $cwdRoot }

    $scriptRoot = Find-ProjectRoot -StartDir $ScriptDir
    if ($scriptRoot) { return $scriptRoot }

    return $ScriptDir
}

function Get-ExtensionRoot {
    param([string]$ScriptDir)
    return (Resolve-Path -LiteralPath (Join-Path $ScriptDir "..")).Path
}

function Test-HasGitRepo {
    param([string]$Root)
    try {
        git -C $Root rev-parse --is-inside-work-tree *> $null
        return ($LASTEXITCODE -eq 0)
    } catch {
        return $false
    }
}

function ConvertTo-Slug {
    param([string]$Text)

    $slug = $Text.ToLowerInvariant() -replace '[^a-z0-9]', '-' -replace '-{2,}', '-' -replace '^-', '' -replace '-$', ''
    return $slug
}

function Get-TopSlugWords {
    param([string]$Slug)

    $parts = $Slug -split '-' | Where-Object { $_ } | Select-Object -First 3
    return ($parts -join '-')
}

function Get-NextPrefixedNumber {
    param(
        [string]$SpecsDir,
        [string]$Glob,
        [string]$Pattern
    )

    $highest = 0
    if (Test-Path -LiteralPath $SpecsDir) {
        Get-ChildItem -LiteralPath $SpecsDir -Directory -Filter $Glob -ErrorAction SilentlyContinue | ForEach-Object {
            if ($_.Name -match $Pattern) {
                $value = [int]$matches[1]
                if ($value -gt $highest) { $highest = $value }
            }
        }
    }

    return ('{0:000}' -f ($highest + 1))
}

function Get-FeatureDirectories {
    param([string]$SpecsDir)

    if (-not (Test-Path -LiteralPath $SpecsDir)) { return @() }
    return Get-ChildItem -LiteralPath $SpecsDir -Directory | Where-Object { $_.Name -match '^\d{3}-' } | Sort-Object Name
}
