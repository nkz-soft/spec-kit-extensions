#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

JSON_MODE=false
LIST_FEATURES=false
FEATURE_NUM=""
MOD_DESCRIPTION=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --json) JSON_MODE=true; shift ;;
        --list-features) LIST_FEATURES=true; JSON_MODE=true; shift ;;
        --help|-h)
            echo "Usage: $0 [--json] [--list-features] [<feature-number>] <modification-description>"
            exit 0
            ;;
        *)
            if [ -z "$FEATURE_NUM" ]; then
                FEATURE_NUM="$1"
            else
                MOD_DESCRIPTION="$MOD_DESCRIPTION $1"
            fi
            shift
            ;;
    esac
done

MOD_DESCRIPTION="${MOD_DESCRIPTION## }"
PROJECT_ROOT="$(get_project_root "$SCRIPT_DIR")"
EXTENSION_ROOT="$(get_extension_root "$SCRIPT_DIR")"
SPECS_DIR="$PROJECT_ROOT/specs"

if $LIST_FEATURES; then
    if [ -z "$MOD_DESCRIPTION" ]; then
        echo '{"error":"Description required for --list-features mode"}' >&2
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
    printf '{"mode":"list","description":"%s","features":%s}\n' "$MOD_DESCRIPTION" "$JSON_FEATURES"
    exit 0
fi

if [ -z "$FEATURE_NUM" ] || [ -z "$MOD_DESCRIPTION" ]; then
    echo "Usage: $0 [--json] <feature-number> <modification-description>" >&2
    exit 1
fi

FEATURE_DIR="$(find "$SPECS_DIR" -maxdepth 1 -type d -name "${FEATURE_NUM}-*" | head -1)"
if [ -z "$FEATURE_DIR" ]; then
    echo "Error: Could not find feature ${FEATURE_NUM} in specs/" >&2
    exit 1
fi

FEATURE_NAME="$(basename "$FEATURE_DIR")"
MODIFICATIONS_DIR="$FEATURE_DIR/modifications"
mkdir -p "$MODIFICATIONS_DIR"
MOD_NUM="$(next_prefixed_number "$MODIFICATIONS_DIR" '*' '')"
BRANCH_SUFFIX="$(slugify "$MOD_DESCRIPTION")"
WORDS="$(top_slug_words "$BRANCH_SUFFIX")"
BRANCH_NAME="${FEATURE_NUM}-mod-${MOD_NUM}-${WORDS}"
MOD_ID="${FEATURE_NUM}-mod-${MOD_NUM}"

if has_git_repo "$PROJECT_ROOT"; then
    git -C "$PROJECT_ROOT" checkout -b "$BRANCH_NAME"
fi

MOD_DIR="$MODIFICATIONS_DIR/${MOD_NUM}-${WORDS}"
mkdir -p "$MOD_DIR/contracts"
MODIFY_TEMPLATE="$EXTENSION_ROOT/extensions/workflows/modify/modification-template.md"
MOD_SPEC_FILE="$MOD_DIR/modification-spec.md"
if [ -f "$MODIFY_TEMPLATE" ]; then cp "$MODIFY_TEMPLATE" "$MOD_SPEC_FILE"; else echo "# Modification Spec" > "$MOD_SPEC_FILE"; fi

IMPACT_FILE="$MOD_DIR/impact-analysis.md"
cat > "$IMPACT_FILE" << EOF
# Impact Analysis for ${FEATURE_NAME}

**Generated**: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
**Modification**: ${MOD_DESCRIPTION}

Review these areas before implementation:
- command definitions and workflow prompts
- template and helper-script paths
- user-facing installation and upgrade guidance
EOF

export SPECIFY_MODIFICATION="$MOD_ID"

if $JSON_MODE; then
    printf '{"MOD_ID":"%s","BRANCH_NAME":"%s","MOD_SPEC_FILE":"%s","IMPACT_FILE":"%s","FEATURE_NAME":"%s","MOD_NUM":"%s"}\n' \
        "$MOD_ID" "$BRANCH_NAME" "$MOD_SPEC_FILE" "$IMPACT_FILE" "$FEATURE_NAME" "$MOD_NUM"
else
    echo "MOD_ID: $MOD_ID"
    echo "BRANCH_NAME: $BRANCH_NAME"
    echo "FEATURE_NAME: $FEATURE_NAME"
    echo "MOD_SPEC_FILE: $MOD_SPEC_FILE"
    echo "IMPACT_FILE: $IMPACT_FILE"
fi
