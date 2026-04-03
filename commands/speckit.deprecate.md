---
description: Create a phased deprecation workflow with dependency analysis.
scripts:
  sh: scripts/create-deprecate.sh --json "{ARGS}"
  ps: scripts/powershell/create-deprecate.ps1 -Json "{ARGS}"
---

The user input to you can be provided directly by the agent or as a command argument. You MUST consider it before proceeding.

User input:

$ARGUMENTS

The text typed after `/speckit.spec-kit-extensions.deprecate` can be:
- `/speckit.spec-kit-extensions.deprecate <feature-number> "reason"`
- `/speckit.spec-kit-extensions.deprecate "reason"` for interactive feature selection

1. Parse the input to determine whether a feature number was supplied.
2. If no feature number was supplied:
   - run the list-features mode for the current platform script
   - present the feature list to the user
   - wait for a selection before continuing
3. Run `{SCRIPT}` from the project root and parse its JSON output for `DEPRECATE_ID`, `BRANCH_NAME`, `DEPRECATION_FILE`, `DEPENDENCIES_FILE`, `FEATURE_NUM`, and `FEATURE_NAME`.
4. Load the deprecation template and read `DEPENDENCIES_FILE`.
5. Write `DEPRECATION_FILE` with rationale, affected users, migration path, phased rollout, rollback notes, and dependency summary.
6. Report completion with the generated files and the next steps for stakeholder review, planning, tasks, and implementation.
