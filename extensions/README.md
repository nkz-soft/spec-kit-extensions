# Installed Workflow Overview

This directory contains the workflow templates and workflow-specific documentation shipped with the `spec-kit-extensions` package.

## Registered Command Surface

The extension registers the following commands:

- `speckit.spec-kit-extensions.bugfix`
- `speckit.spec-kit-extensions.modify`
- `speckit.spec-kit-extensions.refactor`
- `speckit.spec-kit-extensions.hotfix`
- `speckit.spec-kit-extensions.deprecate`

## Workflow Inventory

### Bugfix

- template source: `extensions/workflows/bugfix/`
- purpose: reproducible bug analysis and regression-first repair

### Modify

- template source: `extensions/workflows/modify/`
- purpose: behavior changes to existing features with impact review

### Refactor

- template source: `extensions/workflows/refactor/`
- purpose: structure and quality improvements without behavior change

### Hotfix

- template source: `extensions/workflows/hotfix/`
- purpose: expedited production incident response with follow-up documentation

### Deprecate

- template source: `extensions/workflows/deprecate/`
- purpose: phased removal with dependency and migration analysis

## Notes

- command registration is defined by the root [extension.yml](../extension.yml)
- shell scripts live in [../scripts](../scripts)
- PowerShell scripts live in [../scripts/powershell](../scripts/powershell)
- templates stay in this directory so both local development installs and packaged releases use the same workflow source
