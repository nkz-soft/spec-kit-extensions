# AI Agent Compatibility Guide

This extension is agent-agnostic at the package level: spec-kit installs the extension, registers the command files, and the agent invokes the registered namespaced commands.

## Registered Commands

- `speckit.spec-kit-extensions.bugfix`
- `speckit.spec-kit-extensions.modify`
- `speckit.spec-kit-extensions.refactor`
- `speckit.spec-kit-extensions.hotfix`
- `speckit.spec-kit-extensions.deprecate`

## Platform Execution

- Linux and macOS-style shells use the scripts in [scripts](scripts)
- Windows PowerShell uses the scripts in [scripts/powershell](scripts/powershell)

## General Setup

1. Install the extension in the target spec-kit project
2. Confirm it appears in `specify extension list`
3. Invoke the namespaced command through your agent

## Agent Notes

### Claude Code

Use the registered command directly:

```text
/speckit.spec-kit-extensions.bugfix "form crashes without image upload"
```

### GitHub Copilot

Reference the installed command name in chat and ensure Copilot has access to the project files. If you keep a Copilot instructions file, point it at the namespaced commands rather than the old flat command names.

### Cursor And Windsurf

Use the namespaced command in chat, or tell the agent to invoke the matching installed command file.

### CLI Agents

If your agent does not support registered slash commands, run the platform-appropriate workflow creator script manually and then continue with `/speckit.plan`, `/speckit.tasks`, and `/speckit.implement`.

Linux example:

```bash
./.specify/extensions/spec-kit-extensions/scripts/create-bugfix.sh --json "bug description"
```

Windows example:

```powershell
.\.specify\extensions\spec-kit-extensions\scripts\powershell\create-bugfix.ps1 -Json "bug description"
```

## Migration Note

Older revisions of this repository documented `/speckit.bugfix`-style commands. Update local rules and agent prompts to the namespaced command surface shipped by the extension package.
