#!/usr/bin/env bash
# git-commit.sh — Execute a commit plan generated from a git-report.
#
# Purpose: Take a declarative commit plan and execute it.
# The plan is reviewed by the human before running.
#
# Usage:
#   ./git-commit.sh PLAN_FILE          # execute the plan
#   ./git-commit.sh --dry-run PLAN_FILE  # show what would happen
#
# Plan file format (one stanza per commit):
#
#   --- REPO: /absolute/path/to/repo
#   --- MSG: commit message (single line)
#   --- ADD: path/to/file1
#   --- ADD: path/to/file2
#   --- ADD: .          (to add everything)
#   --- END
#
# Multiple stanzas can appear in one plan file.
# Execute them in order (inner repos first).

set -euo pipefail

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    shift
fi

PLAN_FILE="${1:?Usage: git-commit.sh [--dry-run] PLAN_FILE}"

if [[ ! -f "$PLAN_FILE" ]]; then
    echo "Error: Plan file not found: $PLAN_FILE" >&2
    exit 1
fi

# ── Parse and execute ───────────────────────────────────────────
current_repo=""
current_msg=""
current_files=()
stanza_count=0

execute_stanza() {
    if [[ -z "$current_repo" ]]; then
        return
    fi

    stanza_count=$((stanza_count + 1))
    echo ""
    echo "━━━ Stanza $stanza_count: $(basename "$current_repo") ━━━"
    echo "  Repo: $current_repo"
    echo "  Message: $current_msg"
    echo "  Files: ${current_files[*]}"
    echo ""

    if [[ ! -d "$current_repo/.git" ]] && ! git -C "$current_repo" rev-parse --git-dir &>/dev/null; then
        echo "  ERROR: Not a git repo: $current_repo" >&2
        return 1
    fi

    if $DRY_RUN; then
        echo "  [DRY RUN] Would execute:"
        for f in "${current_files[@]}"; do
            echo "    git -C $current_repo add $f"
        done
        echo "    git -C $current_repo commit -m \"$current_msg\""
    else
        for f in "${current_files[@]}"; do
            echo "  + git add $f"
            git -C "$current_repo" add "$f"
        done
        echo "  + git commit"
        git -C "$current_repo" commit -m "$current_msg"
        echo ""
        echo "  ✓ Committed. New HEAD:"
        git -C "$current_repo" log --oneline -1
    fi

    # Reset for next stanza
    current_repo=""
    current_msg=""
    current_files=()
}

while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip blank lines and comments
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

    if [[ "$line" =~ ^---\ REPO:\ (.+) ]]; then
        current_repo="${BASH_REMATCH[1]}"
        current_repo="${current_repo%"${current_repo##*[![:space:]]}"}"  # trim trailing whitespace
    elif [[ "$line" =~ ^---\ MSG:\ (.+) ]]; then
        current_msg="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^---\ ADD:\ (.+) ]]; then
        local_file="${BASH_REMATCH[1]}"
        local_file="${local_file%"${local_file##*[![:space:]]}"}"
        current_files+=("$local_file")
    elif [[ "$line" =~ ^---\ END ]]; then
        execute_stanza
    fi
done < "$PLAN_FILE"

# Handle case where file doesn't end with --- END
if [[ -n "$current_repo" ]]; then
    execute_stanza
fi

echo ""
echo "━━━ Done: $stanza_count stanza(s) processed ━━━"
