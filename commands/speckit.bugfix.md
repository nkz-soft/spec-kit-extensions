---
description: Create a bugfix workflow with regression-first validation.
scripts:
  sh: scripts/create-bugfix.sh --json "{ARGS}"
  ps: scripts/powershell/create-bugfix.ps1 -Json "{ARGS}"
---

The user input to you can be provided directly by the agent or as a command argument. You MUST consider it before proceeding.

User input:

$ARGUMENTS

The text typed after `/speckit.spec-kit-extensions.bugfix` is the bug description.

1. Run `{SCRIPT}` from the project root and parse its JSON output for `BUG_ID`, `BRANCH_NAME`, and `BUG_REPORT_FILE`. All file paths must be absolute.
2. Load `extensions/workflows/bugfix/bug-report-template.md` from the installed extension package to understand the required sections.
3. Write `BUG_REPORT_FILE` using the template structure:
   - capture current behavior, expected behavior, and reproduction steps from the description
   - classify severity from the reported impact
   - leave root-cause and fix-strategy sections for later planning
4. Report completion with:
   - branch name
   - bug ID
   - bug report path
   - next steps: investigate, `/speckit.plan`, `/speckit.tasks`, `/speckit.implement`
   - reminder: regression test first
