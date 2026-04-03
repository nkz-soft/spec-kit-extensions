# Installation Guide

This package installs as a native spec-kit extension. Manual file copying is no longer the recommended path.

## Prerequisites

- spec-kit with extension support
- Git available on the machine
- a spec-kit project with a `.specify/` directory
- an AI agent or workflow runner that can invoke registered spec-kit extension commands

## Option 1: Local Development Install

Use this when testing the extension from a working copy.

### Linux

```bash
cd /path/to/your-spec-kit-project
specify extension add spec-kit-extensions --dev /path/to/spec-kit-extensions
```

### Windows PowerShell

```powershell
Set-Location D:\path\to\your-spec-kit-project
specify extension add spec-kit-extensions --dev D:\path\to\spec-kit-extensions
```

## Option 2: Release Install

Use this when installing from a published archive.

### Linux

```bash
specify extension add spec-kit-extensions --from https://github.com/nkz-soft/spec-kit-extensions/archive/refs/tags/v2.1.0.zip
```

### Windows PowerShell

```powershell
specify extension add spec-kit-extensions --from https://github.com/nkz-soft/spec-kit-extensions/archive/refs/tags/v2.1.0.zip
```

## Verify Installation

List installed extensions:

```bash
specify extension list
```

Expected result:

- the extension appears as `spec-kit Extensions`
- the listed version matches the installed package
- the registered command count is five

Verify a workflow command is available through your agent:

```text
/speckit.spec-kit-extensions.bugfix "save button crashes on empty payload"
```

## Registered Commands

- `speckit.spec-kit-extensions.bugfix`
- `speckit.spec-kit-extensions.modify`
- `speckit.spec-kit-extensions.refactor`
- `speckit.spec-kit-extensions.hotfix`
- `speckit.spec-kit-extensions.deprecate`

## Upgrade

Reinstall from a newer local working copy or release archive:

```bash
specify extension update spec-kit-extensions
```

If your environment does not support `extension update`, remove and reinstall with the newer source.

After upgrading:

- run `specify extension list`
- confirm the new version
- verify the registered command surface still matches the docs

## Remove

Remove the extension from the project:

```bash
specify extension remove spec-kit-extensions
```

After removal:

- confirm the extension no longer appears in `specify extension list`
- confirm the namespaced commands are no longer registered
- remove any workflow artifacts only if your team no longer needs the historical records in `specs/`

## Troubleshooting

### Manifest Validation Failure

Symptoms:

- install fails before registration
- spec-kit reports invalid extension metadata

Checks:

- confirm [extension.yml](extension.yml) exists in the package root
- confirm command file paths in the manifest exist in the package
- confirm the spec-kit version satisfies the declared compatibility range

### Command Registration Failure

Symptoms:

- install succeeds but commands are missing

Checks:

- rerun `specify extension list`
- confirm the agent supports registered extension commands
- review the installed command files under the consuming project’s extension area

### Windows Execution Problems

The package ships native PowerShell workflow creator scripts under [scripts/powershell](scripts/powershell). If a workflow fails on Windows:

- confirm your agent is selecting the PowerShell script entry
- run the PowerShell workflow script manually to confirm it can create artifacts

### Linux Execution Problems

The package ships shell workflow creator scripts under [scripts](scripts). If a workflow fails on Linux:

- confirm the scripts are executable
- run the shell workflow script manually to confirm it can create artifacts

## Validation Checklist

For release readiness, validate:

- local `--dev` install succeeds
- release install succeeds
- Windows workflow creation succeeds
- Linux workflow creation succeeds
- invalid metadata fails clearly
- upgrade and removal are documented and reproducible
