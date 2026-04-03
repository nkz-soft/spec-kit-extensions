---
description: Create a modification workflow with impact analysis and compatibility tracking.
scripts:
  sh: scripts/create-modification.sh --json "{ARGS}"
  ps: scripts/powershell/create-modification.ps1 -Json "{ARGS}"
---

The user input to you can be provided directly by the agent or as a command argument. You MUST consider it before proceeding.

User input:

$ARGUMENTS

The text typed after `/speckit.spec-kit-extensions.modify` can be:
- `/speckit.spec-kit-extensions.modify <feature-number> "modification description"`
- `/speckit.spec-kit-extensions.modify "modification description"` for interactive feature selection

1. Parse the input to determine whether a feature number was supplied.
2. If no feature number was supplied:
   - run the list-features mode for the current platform script
   - present the numbered feature list to the user
   - wait for the user to select a feature before continuing
3. Once the feature number is known, run `{SCRIPT}` and parse its JSON output for `MOD_ID`, `BRANCH_NAME`, `MOD_SPEC_FILE`, `IMPACT_FILE`, and `FEATURE_NAME`.
4. Read `IMPACT_FILE` and the original feature spec to understand the baseline.
5. Write `MOD_SPEC_FILE` using the modification template:
   - explain why the feature is changing
   - capture added, modified, and removed behavior
   - summarize impact analysis and backward-compatibility considerations
6. Report completion with the modification ID, spec path, impact-analysis path, and next steps through planning, tasks, and implementation.
