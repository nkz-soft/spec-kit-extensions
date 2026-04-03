#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

JSON_MODE=false
ARGS=()
for arg in "$@"; do
    case "$arg" in
        --json) JSON_MODE=true ;;
        --help|-h) echo "Usage: $0 [--json] <incident_description>"; exit 0 ;;
        *) ARGS+=("$arg") ;;
    esac
done

INCIDENT_DESCRIPTION="${ARGS[*]}"
if [ -z "$INCIDENT_DESCRIPTION" ]; then
    echo "Usage: $0 [--json] <incident_description>" >&2
    exit 1
fi

PROJECT_ROOT="$(get_project_root "$SCRIPT_DIR")"
EXTENSION_ROOT="$(get_extension_root "$SCRIPT_DIR")"
SPECS_DIR="$PROJECT_ROOT/specs"
mkdir -p "$SPECS_DIR"
HOTFIX_NUM="$(next_prefixed_number "$SPECS_DIR" 'hotfix-*' 'hotfix-')"
BRANCH_SUFFIX="$(slugify "$INCIDENT_DESCRIPTION")"
WORDS="$(top_slug_words "$BRANCH_SUFFIX")"
BRANCH_NAME="hotfix/${HOTFIX_NUM}-${WORDS}"
HOTFIX_ID="hotfix-${HOTFIX_NUM}"

if has_git_repo "$PROJECT_ROOT"; then
    git -C "$PROJECT_ROOT" checkout -b "$BRANCH_NAME"
fi

HOTFIX_DIR="$SPECS_DIR/${HOTFIX_ID}-${WORDS}"
mkdir -p "$HOTFIX_DIR"
HOTFIX_TEMPLATE="$EXTENSION_ROOT/extensions/workflows/hotfix/hotfix-template.md"
POSTMORTEM_TEMPLATE="$EXTENSION_ROOT/extensions/workflows/hotfix/post-mortem-template.md"
HOTFIX_FILE="$HOTFIX_DIR/hotfix.md"
POSTMORTEM_FILE="$HOTFIX_DIR/post-mortem.md"
if [ -f "$HOTFIX_TEMPLATE" ]; then cp "$HOTFIX_TEMPLATE" "$HOTFIX_FILE"; else echo "# Hotfix" > "$HOTFIX_FILE"; fi
if [ -f "$POSTMORTEM_TEMPLATE" ]; then cp "$POSTMORTEM_TEMPLATE" "$POSTMORTEM_FILE"; else echo "# Post-Mortem" > "$POSTMORTEM_FILE"; fi
TIMESTAMP="$(date -u +"%Y-%m-%d %H:%M:%S UTC")"

export SPECIFY_HOTFIX="$HOTFIX_ID"
if $JSON_MODE; then
    printf '{"HOTFIX_ID":"%s","BRANCH_NAME":"%s","HOTFIX_FILE":"%s","POSTMORTEM_FILE":"%s","HOTFIX_NUM":"%s","TIMESTAMP":"%s"}\n' \
        "$HOTFIX_ID" "$BRANCH_NAME" "$HOTFIX_FILE" "$POSTMORTEM_FILE" "$HOTFIX_NUM" "$TIMESTAMP"
else
    echo "HOTFIX_ID: $HOTFIX_ID"
    echo "BRANCH_NAME: $BRANCH_NAME"
    echo "HOTFIX_FILE: $HOTFIX_FILE"
    echo "POSTMORTEM_FILE: $POSTMORTEM_FILE"
fi
