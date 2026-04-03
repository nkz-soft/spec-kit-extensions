# spec-kit Extensions

Native [spec-kit](https://github.com/github/spec-kit) extension package for lifecycle workflows that are outside the core new-feature flow.

This repository is a fork of [MartyBonacci/spec-kit-extensions](https://github.com/MartyBonacci/spec-kit-extensions), adapted to work as a full-fledged native spec-kit extension.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## What This Package Adds

This extension adds five workflow commands:

- `speckit.spec-kit-extensions.bugfix`
- `speckit.spec-kit-extensions.modify`
- `speckit.spec-kit-extensions.refactor`
- `speckit.spec-kit-extensions.hotfix`
- `speckit.spec-kit-extensions.deprecate`

They cover:

- bug remediation with regression-first validation
- existing-feature changes with impact analysis
- refactors with behavior-preservation tracking
- production hotfixes with mandatory post-mortem follow-up
- phased deprecation work with dependency review

## Install

### Local Development Install

Use this while developing or testing the extension from a working copy:

```bash
specify extension add spec-kit-extensions --dev /path/to/spec-kit-extensions
```

### Release Install

Use this from a tagged release archive:

```bash
specify extension add spec-kit-extensions --from https://github.com/nkz-soft/spec-kit-extensions/archive/refs/tags/v2.1.0.zip
```

Full platform-specific guidance is in [INSTALLATION.md](INSTALLATION.md).

## Verify

After installation:

```bash
specify extension list
```

Then invoke one of the registered commands through your agent, for example:

```text
/speckit.spec-kit-extensions.bugfix "profile form crashes without image upload"
```

## Windows And Linux Support

This package ships:

- shell workflow creator scripts in [scripts](scripts)
- PowerShell workflow creator scripts in [scripts/powershell](scripts/powershell)
- workflow templates in [extensions/workflows](extensions/workflows)

Windows and Linux use the same extension manifest and command surface. Platform-specific examples are documented in [INSTALLATION.md](INSTALLATION.md) and [AI-AGENTS.md](AI-AGENTS.md).

## Command Migration

Previous revisions of this repository documented flat commands such as `/speckit.bugfix`.

The native extension package now registers namespaced commands:

- `/speckit.spec-kit-extensions.bugfix`
- `/speckit.spec-kit-extensions.modify`
- `/speckit.spec-kit-extensions.refactor`
- `/speckit.spec-kit-extensions.hotfix`
- `/speckit.spec-kit-extensions.deprecate`

If you have older agent instructions or team docs, update them to the namespaced form.

## Package Layout

The published extension package includes:

- root manifest: [extension.yml](extension.yml)
- registered commands: [commands](commands)
- helper scripts: [scripts](scripts)
- workflow templates and docs: [extensions](extensions)
- user docs: [README.md](README.md), [INSTALLATION.md](INSTALLATION.md), [AI-AGENTS.md](AI-AGENTS.md), [CHANGELOG.md](CHANGELOG.md), [LICENSE](LICENSE)

Development-only files are excluded from release installs by [.extensionignore](.extensionignore).

## Documentation

- [INSTALLATION.md](INSTALLATION.md) - Windows and Linux install, verify, upgrade, and removal steps
- [AI-AGENTS.md](AI-AGENTS.md) - agent-specific invocation guidance
- [extensions/README.md](extensions/README.md) - installed workflow overview
- [extensions/QUICKSTART.md](extensions/QUICKSTART.md) - quick usage walkthrough
- [extensions/DEVELOPMENT.md](extensions/DEVELOPMENT.md) - extending the extension package itself
- [docs/architecture.md](docs/architecture.md) - internal package architecture

## Publishing

This repository is structured to match the official spec-kit extension development guide:

- root `extension.yml`
- namespaced commands
- local `--dev` install support
- release archive install support
- optional `.extensionignore` package exclusions

For release workflow details, see [CHANGELOG.md](CHANGELOG.md) and [extensions/DEVELOPMENT.md](extensions/DEVELOPMENT.md).
