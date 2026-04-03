# Quickstart

## 1. Install The Extension

```bash
specify extension add spec-kit-extensions --dev /path/to/spec-kit-extensions
```

## 2. Confirm It Is Registered

```bash
specify extension list
```

## 3. Run A Workflow

Examples:

```text
/speckit.spec-kit-extensions.bugfix "profile form crashes without image upload"
/speckit.spec-kit-extensions.modify 014 "make avatar optional"
/speckit.spec-kit-extensions.refactor "extract workflow setup helpers"
/speckit.spec-kit-extensions.hotfix "production auth callback returns 500"
/speckit.spec-kit-extensions.deprecate 014 "low usage and migration complete"
```

## 4. Continue Through Core spec-kit

After the workflow-specific artifact is created:

```text
/speckit.plan
/speckit.tasks
/speckit.implement
```

## 5. Platform Notes

- Linux uses the shell workflow scripts in `scripts/`
- Windows uses the PowerShell workflow scripts in `scripts/powershell/`
- both platforms share the same templates and manifest
