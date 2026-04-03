#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

JSON_MODE=false
ARGS=()
for arg in "$@"; do
    case "$arg" in
        --json) JSON_MODE=true ;;
        --help|-h) echo "Usage: $0 [--json] <bug_description>"; exit 0 ;;
        *) ARGS+=("$arg") ;;
    esac
done

BUG_DESCRIPTION="${ARGS[*]}"
if [ -z "$BUG_DESCRIPTION" ]; then
    echo "Usage: $0 [--json] <bug_description>" >&2
    exit 1
fi

PROJECT_ROOT="$(get_project_root "$SCRIPT_DIR")"
EXTENSION_ROOT="$(get_extension_root "$SCRIPT_DIR")"
HAS_GIT=false
if has_git_repo "$PROJECT_ROOT"; then
    HAS_GIT=true
fi

cd "$PROJECT_ROOT"

SPECS_DIR="$PROJECT_ROOT/specs"
mkdir -p "$SPECS_DIR"
BUG_NUM="$(next_prefixed_number "$SPECS_DIR" 'bugfix-*' 'bugfix-')"
BRANCH_SUFFIX="$(slugify "$BUG_DESCRIPTION")"
WORDS="$(top_slug_words "$BRANCH_SUFFIX")"
BRANCH_NAME="bugfix/${BUG_NUM}-${WORDS}"
BUG_ID="bugfix-${BUG_NUM}"

if [ "$HAS_GIT" = true ]; then
    git checkout -b "$BRANCH_NAME"
fi

BUG_DIR="$SPECS_DIR/${BUG_ID}-${WORDS}"
mkdir -p "$BUG_DIR"
BUGFIX_TEMPLATE="$EXTENSION_ROOT/extensions/workflows/bugfix/bug-report-template.md"
BUG_REPORT_FILE="$BUG_DIR/bug-report.md"

if [ -f "$BUGFIX_TEMPLATE" ]; then
    cp "$BUGFIX_TEMPLATE" "$BUG_REPORT_FILE"
else
    echo "# Bug Report" > "$BUG_REPORT_FILE"
fi

export SPECIFY_BUGFIX="$BUG_ID"

if $JSON_MODE; then
    printf '{"BUG_ID":"%s","BRANCH_NAME":"%s","BUG_REPORT_FILE":"%s","BUG_NUM":"%s"}\n' \
        "$BUG_ID" "$BRANCH_NAME" "$BUG_REPORT_FILE" "$BUG_NUM"
else
    echo "BUG_ID: $BUG_ID"
    echo "BRANCH_NAME: $BRANCH_NAME"
    echo "BUG_REPORT_FILE: $BUG_REPORT_FILE"
    echo "BUG_NUM: $BUG_NUM"
fi
