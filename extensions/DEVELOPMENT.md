# Extension Development Guide

This repository is now structured as a native spec-kit extension package.

## Package Contract

The extension package is defined by:

- [extension.yml](../extension.yml)
- [commands](../commands)
- [scripts](../scripts)
- [scripts/powershell](../scripts/powershell)
- [extensions/workflows](workflows)

## Adding Or Updating A Workflow

1. Add or update the command definition in `commands/`
2. Add or update the shell workflow creator in `scripts/`
3. Add or update the PowerShell workflow creator in `scripts/powershell/`
4. Add or update the workflow templates in `extensions/workflows/<workflow>/`
5. Update [extension.yml](../extension.yml) if the registered command surface changes
6. Update [README.md](../README.md), [INSTALLATION.md](../INSTALLATION.md), and [AI-AGENTS.md](../AI-AGENTS.md)

## Publishing Checklist

- manifest metadata is current
- command list in the manifest matches the command files
- PowerShell and shell script coverage is present for supported workflows
- root docs describe local `--dev` install and release install
- `.extensionignore` excludes maintainer-only files from consumer installs
- release notes are recorded in [CHANGELOG.md](../CHANGELOG.md)

## Local Validation

From a clean spec-kit project:

```bash
specify extension add spec-kit-extensions --dev /path/to/spec-kit-extensions
specify extension list
```

Then verify each command can initialize its workflow artifacts.

## Package Boundaries

The release package intentionally excludes development-only material via [.extensionignore](../.extensionignore). If you add new repo-only assets, review that file before publishing.
