---
description: Create a refactor workflow with behavior-preservation validation.
scripts:
  sh: scripts/create-refactor.sh --json "{ARGS}"
  ps: scripts/powershell/create-refactor.ps1 -Json "{ARGS}"
---

The user input to you can be provided directly by the agent or as a command argument. You MUST consider it before proceeding.

User input:

$ARGUMENTS

The text typed after `/speckit.spec-kit-extensions.refactor` is the refactoring description.

1. Run `{SCRIPT}` from the project root and parse its JSON output for `REFACTOR_ID`, `BRANCH_NAME`, `REFACTOR_SPEC_FILE`, `METRICS_BEFORE`, `METRICS_AFTER`, and `BEHAVIORAL_SNAPSHOT`.
2. Load the installed refactor template to understand the required sections.
3. Write `REFACTOR_SPEC_FILE` with motivation, targeted files, risk level, and behavior-preservation requirements.
4. Update `BEHAVIORAL_SNAPSHOT` with the observable behavior that must remain unchanged.
5. Report completion with the created files and the next steps: capture baseline metrics, plan, tasks, and implement.
