#!/usr/bin/env bash

set -e

find_project_root() {
    local start_dir="$1"
    local current="$start_dir"

    while [ -n "$current" ] && [ "$current" != "/" ]; do
        if [ -d "$current/.specify" ] || [ -d "$current/.git" ] || [ -f "$current/.git" ]; then
            echo "$current"
            return 0
        fi
        current="$(dirname "$current")"
    done

    if [ -d "/.specify" ]; then
        echo "/"
        return 0
    fi

    return 1
}

get_project_root() {
    local script_dir="$1"

    if root="$(find_project_root "$(pwd)")"; then
        echo "$root"
        return 0
    fi

    if root="$(find_project_root "$script_dir")"; then
        echo "$root"
        return 0
    fi

    echo "$script_dir"
}

get_extension_root() {
    local script_dir="$1"
    cd "$script_dir/.." && pwd
}

has_git_repo() {
    local root="$1"
    git -C "$root" rev-parse --is-inside-work-tree >/dev/null 2>&1
}

slugify() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-//' | sed 's/-$//'
}

top_slug_words() {
    local slug="$1"
    echo "$slug" | tr '-' '\n' | grep -v '^$' | head -3 | tr '\n' '-' | sed 's/-$//'
}

next_prefixed_number() {
    local specs_dir="$1"
    local glob="$2"
    local strip_prefix="$3"
    local highest=0

    if [ -d "$specs_dir" ]; then
        for dir in "$specs_dir"/$glob; do
            [ -d "$dir" ] || continue
            local dirname
            dirname="$(basename "$dir")"
            local number
            if [ -n "$strip_prefix" ]; then
                number="$(echo "$dirname" | sed "s/$strip_prefix//" | grep -o '^[0-9]\+' || echo "0")"
            else
                number="$(echo "$dirname" | grep -o '^[0-9]\+' || echo "0")"
            fi
            number=$((10#$number))
            if [ "$number" -gt "$highest" ]; then
                highest="$number"
            fi
        done
    fi

    printf "%03d" $((highest + 1))
}
