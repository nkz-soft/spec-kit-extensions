# Architecture

## Overview

This repository is packaged as a native spec-kit extension. The package contract is driven by [extension.yml](../extension.yml), not by manual copying into a consumer project.

## Main Components

### Manifest

[extension.yml](../extension.yml) declares:

- extension identity and version
- spec-kit compatibility
- registered command names
- command file locations

### Commands

[commands](../commands) contains the user-facing workflow prompts that spec-kit registers.

The registered command surface is:

- `speckit.spec-kit-extensions.bugfix`
- `speckit.spec-kit-extensions.modify`
- `speckit.spec-kit-extensions.refactor`
- `speckit.spec-kit-extensions.hotfix`
- `speckit.spec-kit-extensions.deprecate`

### Scripts

- shell workflow creators: [scripts](../scripts)
- PowerShell workflow creators: [scripts/powershell](../scripts/powershell)

They create the initial workflow artifacts for each command.

### Templates

[extensions/workflows](../extensions/workflows) holds the workflow-specific markdown templates used by the scripts.

## Package Layout

At install time, spec-kit copies the extension package into the consuming project’s extension area and registers the declared commands. The package keeps its own templates and helper scripts instead of assuming they have been copied into core `.specify` paths.

## Cross-Platform Model

- Windows uses native PowerShell workflow creator scripts
- Linux uses shell workflow creator scripts
- both platforms share the same templates, manifest, and documentation

## Package Exclusions

[.extensionignore](../.extensionignore) excludes maintainer-only files such as local specs, repo metadata, and editor state from the published extension package.
