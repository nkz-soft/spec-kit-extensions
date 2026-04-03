#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

JSON_MODE=false
LIST_FEATURES=false
ARGS=()
for arg in "$@"; do
    case "$arg" in
        --json) JSON_MODE=true ;;
        --list-features) LIST_FEATURES=true; JSON_MODE=true ;;
        --help|-h) echo "Usage: $0 [--json] [--list-features] [<feature_number>] <reason>"; exit 0 ;;
        *) ARGS+=("$arg") ;;
    esac
done

FEATURE_NUM="${ARGS[0]}"
REASON="${ARGS[*]:1}"
PROJECT_ROOT="$(get_project_root "$SCRIPT_DIR")"
EXTENSION_ROOT="$(get_extension_root "$SCRIPT_DIR")"
SPECS_DIR="$PROJECT_ROOT/specs"

if $LIST_FEATURES; then
    if [ -z "$REASON" ]; then
        echo '{"error":"Reason required for --list-features mode"}' >&2
        exit 1
    fi
    FEATURES=()
    while IFS= read -r dir; do
        [ -d "$dir" ] || continue
        FEATURES+=("$(basename "$dir")")
    done < <(find "$SPECS_DIR" -maxdepth 1 -type d -name '[0-9][0-9][0-9]-*' | sort)

    JSON_FEATURES="["
    FIRST=true
    for feature in "${FEATURES[@]}"; do
        if [ "$FIRST" = true ]; then FIRST=false; else JSON_FEATURES="$JSON_FEATURES,"; fi
        FEATURE_NUM_ONLY="$(echo "$feature" | grep -o '^[0-9]\+')"
        FEATURE_NAME_ONLY="$(echo "$feature" | sed "s/^${FEATURE_NUM_ONLY}-//")"
        JSON_FEATURES="$JSON_FEATURES{\"number\":\"$FEATURE_NUM_ONLY\",\"name\":\"$FEATURE_NAME_ONLY\",\"full\":\"$feature\"}"
    done
    JSON_FEATURES="$JSON_FEATURES]"
    printf '{"mode":"list","reason":"%s","features":%s}\n' "$REASON" "$JSON_FEATURES"
    exit 0
fi

if [ -z "$FEATURE_NUM" ] || [ -z "$REASON" ]; then
    echo "Usage: $0 [--json] <feature_number> <reason>" >&2
    exit 1
fi

FEATURE_DIR="$(find "$SPECS_DIR" -maxdepth 1 -type d -name "${FEATURE_NUM}-*" | head -1)"
if [ -z "$FEATURE_DIR" ] || [ ! -d "$FEATURE_DIR" ]; then
    echo "Error: Feature directory not found for feature number ${FEATURE_NUM}" >&2
    exit 1
fi

FEATURE_NAME="$(basename "$FEATURE_DIR")"
DEPRECATE_NUM="$(next_prefixed_number "$SPECS_DIR" 'deprecate-*' 'deprecate-')"
FEATURE_SHORT="$(echo "$FEATURE_NAME" | sed "s/^${FEATURE_NUM}-//")"
BRANCH_NAME="deprecate/${DEPRECATE_NUM}-${FEATURE_SHORT}"
DEPRECATE_ID="deprecate-${DEPRECATE_NUM}"

if has_git_repo "$PROJECT_ROOT"; then
    git -C "$PROJECT_ROOT" checkout -b "$BRANCH_NAME"
fi

DEPRECATE_DIR="$SPECS_DIR/${DEPRECATE_ID}-${FEATURE_SHORT}"
mkdir -p "$DEPRECATE_DIR"
DEPRECATION_TEMPLATE="$EXTENSION_ROOT/extensions/workflows/deprecate/deprecation-template.md"
DEPRECATION_FILE="$DEPRECATE_DIR/deprecation.md"
DEPENDENCIES_FILE="$DEPRECATE_DIR/dependencies.md"
if [ -f "$DEPRECATION_TEMPLATE" ]; then cp "$DEPRECATION_TEMPLATE" "$DEPRECATION_FILE"; else echo "# Deprecation Plan" > "$DEPRECATION_FILE"; fi

cat > "$DEPENDENCIES_FILE" << EOF
# Dependencies

**Feature**: ${FEATURE_NAME}
**Reason**: ${REASON}

Review code, routes, tests, and user-facing docs before removal.
EOF

export SPECIFY_DEPRECATE="$DEPRECATE_ID"
if $JSON_MODE; then
    printf '{"DEPRECATE_ID":"%s","BRANCH_NAME":"%s","DEPRECATION_FILE":"%s","DEPENDENCIES_FILE":"%s","DEPRECATE_NUM":"%s","FEATURE_NUM":"%s","FEATURE_NAME":"%s","REASON":"%s"}\n' \
        "$DEPRECATE_ID" "$BRANCH_NAME" "$DEPRECATION_FILE" "$DEPENDENCIES_FILE" "$DEPRECATE_NUM" "$FEATURE_NUM" "$FEATURE_NAME" "$REASON"
else
    echo "DEPRECATE_ID: $DEPRECATE_ID"
    echo "BRANCH_NAME: $BRANCH_NAME"
    echo "DEPRECATION_FILE: $DEPRECATION_FILE"
    echo "DEPENDENCIES_FILE: $DEPENDENCIES_FILE"
fi
