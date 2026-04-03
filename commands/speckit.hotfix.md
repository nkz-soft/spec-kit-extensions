---
description: Create an expedited hotfix workflow with post-mortem follow-up.
scripts:
  sh: scripts/create-hotfix.sh --json "{ARGS}"
  ps: scripts/powershell/create-hotfix.ps1 -Json "{ARGS}"
---

The user input to you can be provided directly by the agent or as a command argument. You MUST consider it before proceeding.

User input:

$ARGUMENTS

The text typed after `/speckit.spec-kit-extensions.hotfix` is the incident description.

1. Run `{SCRIPT}` from the project root and parse its JSON output for `HOTFIX_ID`, `BRANCH_NAME`, `HOTFIX_FILE`, `POSTMORTEM_FILE`, and `TIMESTAMP`.
2. Load the installed hotfix template to understand the required sections.
3. Write `HOTFIX_FILE` with incident description, severity, impact, timeline start, and the initial response context.
4. Report completion with the hotfix ID, generated files, and the next steps for planning, tasks, implementation, and post-mortem follow-up.
