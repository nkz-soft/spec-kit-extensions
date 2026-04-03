#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

JSON_MODE=false
ARGS=()
for arg in "$@"; do
    case "$arg" in
        --json) JSON_MODE=true ;;
        --help|-h) echo "Usage: $0 [--json] <refactoring_description>"; exit 0 ;;
        *) ARGS+=("$arg") ;;
    esac
done

REFACTOR_DESCRIPTION="${ARGS[*]}"
if [ -z "$REFACTOR_DESCRIPTION" ]; then
    echo "Usage: $0 [--json] <refactoring_description>" >&2
    exit 1
fi

PROJECT_ROOT="$(get_project_root "$SCRIPT_DIR")"
EXTENSION_ROOT="$(get_extension_root "$SCRIPT_DIR")"
SPECS_DIR="$PROJECT_ROOT/specs"
mkdir -p "$SPECS_DIR"
REFACTOR_NUM="$(next_prefixed_number "$SPECS_DIR" 'refactor-*' 'refactor-')"
BRANCH_SUFFIX="$(slugify "$REFACTOR_DESCRIPTION")"
WORDS="$(top_slug_words "$BRANCH_SUFFIX")"
BRANCH_NAME="refactor/${REFACTOR_NUM}-${WORDS}"
REFACTOR_ID="refactor-${REFACTOR_NUM}"

if has_git_repo "$PROJECT_ROOT"; then
    git -C "$PROJECT_ROOT" checkout -b "$BRANCH_NAME"
fi

REFACTOR_DIR="$SPECS_DIR/${REFACTOR_ID}-${WORDS}"
mkdir -p "$REFACTOR_DIR"
REFACTOR_TEMPLATE="$EXTENSION_ROOT/extensions/workflows/refactor/refactor-template.md"
REFACTOR_SPEC_FILE="$REFACTOR_DIR/refactor-spec.md"
if [ -f "$REFACTOR_TEMPLATE" ]; then cp "$REFACTOR_TEMPLATE" "$REFACTOR_SPEC_FILE"; else echo "# Refactor Spec" > "$REFACTOR_SPEC_FILE"; fi

METRICS_BEFORE="$REFACTOR_DIR/metrics-before.md"
METRICS_AFTER="$REFACTOR_DIR/metrics-after.md"
BEHAVIORAL_SNAPSHOT="$REFACTOR_DIR/behavioral-snapshot.md"
printf '# Baseline Metrics (Before Refactoring)\n\n**Status**: Capture before making changes.\n' > "$METRICS_BEFORE"
printf '# Post-Refactoring Metrics (After Refactoring)\n\n**Status**: Capture after refactoring is complete.\n' > "$METRICS_AFTER"
printf '# Behavioral Snapshot\n\nDocument the observable behavior that must remain unchanged.\n' > "$BEHAVIORAL_SNAPSHOT"

export SPECIFY_REFACTOR="$REFACTOR_ID"
if $JSON_MODE; then
    printf '{"REFACTOR_ID":"%s","BRANCH_NAME":"%s","REFACTOR_SPEC_FILE":"%s","METRICS_BEFORE":"%s","METRICS_AFTER":"%s","BEHAVIORAL_SNAPSHOT":"%s","REFACTOR_NUM":"%s"}\n' \
        "$REFACTOR_ID" "$BRANCH_NAME" "$REFACTOR_SPEC_FILE" "$METRICS_BEFORE" "$METRICS_AFTER" "$BEHAVIORAL_SNAPSHOT" "$REFACTOR_NUM"
else
    echo "REFACTOR_ID: $REFACTOR_ID"
    echo "BRANCH_NAME: $BRANCH_NAME"
    echo "REFACTOR_SPEC_FILE: $REFACTOR_SPEC_FILE"
fi
