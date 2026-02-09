#!/usr/bin/env bash
# git-report.sh — Generate a structured snapshot of git repo state.
#
# Purpose: Produce a complete picture in ONE invocation so that an
# AI collaborator (or human reviewer) can draft a commit plan
# without needing follow-up queries.
#
# Usage:
#   ./git-report.sh [OPTIONS] [REPO_PATH ...]
#   ./git-report.sh --all              # all known project repos
#   ./git-report.sh --summary --all    # skip diffs, just file lists
#   ./git-report.sh --diff-lines 100   # limit diff output per repo
#
# Options:
#   --all           Report on all known project repos
#   --summary       Skip diff details (just stat summaries)
#   --diff-lines N  Max diff lines per repo (default: 150)
#   --output FILE   Write report to FILE instead of stdout
#
# Output: Org-mode formatted report to stdout (or --output file).

# Note: not using `set -e` because piping through head/wc can cause
# SIGPIPE (exit 141) which is harmless but would abort the script.
set -uo pipefail

# ── Project topology (edit if paths change) ─────────────────────
MAYALUCIA="$HOME/Darshan/research/develop/agentic/mayalucia"
MAYADEVGENI="$HOME/Darshan/research/develop/agentic/mayadevgeni"
MAYADEVGENZ="$MAYADEVGENI/agency/mayadevgenz"
MAYAPORTAL="$MAYALUCIA/modules/mayaportal"

# Canonical commit order: inner repos first, then outer
ALL_REPOS=("$MAYADEVGENZ" "$MAYADEVGENI" "$MAYAPORTAL" "$MAYALUCIA")

# ── Ensure git never invokes a pager ────────────────────────────
export GIT_PAGER=cat

# ── Defaults ────────────────────────────────────────────────────
SHOW_DIFF=true
MAX_DIFF_LINES=150
OUTPUT=""

# ── Parse options ───────────────────────────────────────────────
USE_ALL=false
POSITIONAL=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --all)       USE_ALL=true; shift ;;
        --summary)   SHOW_DIFF=false; shift ;;
        --diff-lines)
            MAX_DIFF_LINES="${2:?--diff-lines requires a number}"
            shift 2 ;;
        --output)
            OUTPUT="${2:?--output requires a filename}"
            shift 2 ;;
        -*)
            echo "Unknown option: $1" >&2; exit 1 ;;
        *)
            POSITIONAL+=("$1"); shift ;;
    esac
done

# ── Helpers ─────────────────────────────────────────────────────
separator() {
    echo "-----"
}

report_repo() {
    local repo_path="$1"
    local repo_name
    repo_name=$(basename "$repo_path")

    # Verify it's a git repo
    if ! git -C "$repo_path" rev-parse --git-dir &>/dev/null; then
        echo "** $repo_name — NOT A GIT REPO: $repo_path"
        echo ""
        return
    fi

    local branch
    branch=$(git -C "$repo_path" branch --show-current 2>/dev/null || echo "(detached)")

    echo "** $repo_name ($branch)"
    echo "   :PROPERTIES:"
    echo "   :path: $repo_path"
    echo "   :END:"
    echo ""

    # ── Recent commits (last 5) ──
    echo "*** Recent Commits"
    echo "#+begin_example"
    git -C "$repo_path" log --oneline --decorate -5 2>/dev/null || echo "(no commits yet)"
    echo "#+end_example"
    echo ""

    # ── Staged changes ──
    local staged
    staged=$(git -C "$repo_path" diff --cached --stat 2>/dev/null)
    echo "*** Staged Changes"
    if [[ -n "$staged" ]]; then
        echo "#+begin_example"
        echo "$staged"
        echo "#+end_example"
    else
        echo "None."
    fi
    echo ""

    # ── Unstaged changes (tracked files) — stat always, diff optional ──
    local unstaged
    unstaged=$(git -C "$repo_path" diff --stat 2>/dev/null)
    echo "*** Unstaged Changes (tracked)"
    if [[ -n "$unstaged" ]]; then
        echo "#+begin_example"
        echo "$unstaged"
        echo "#+end_example"

        if $SHOW_DIFF; then
            echo ""
            local diff_lines
            diff_lines=$(git -C "$repo_path" diff 2>/dev/null | wc -l | tr -d ' ')
            echo "**** Diff detail ($diff_lines lines total, showing ≤$MAX_DIFF_LINES)"
            echo "#+begin_src diff"
            git -C "$repo_path" diff 2>/dev/null | head -"$MAX_DIFF_LINES"
            if [[ "$diff_lines" -gt "$MAX_DIFF_LINES" ]]; then
                echo ""
                echo "... (truncated, $((diff_lines - MAX_DIFF_LINES)) more lines) ..."
            fi
            echo "#+end_src"
        fi
    else
        echo "None."
    fi
    echo ""

    # ── Untracked files ──
    local untracked
    untracked=$(git -C "$repo_path" ls-files --others --exclude-standard 2>/dev/null)
    echo "*** Untracked Files"
    if [[ -n "$untracked" ]]; then
        # Count and possibly truncate
        local untracked_count
        untracked_count=$(echo "$untracked" | wc -l | tr -d ' ')
        echo "($untracked_count files)"
        echo "#+begin_example"
        if [[ "$untracked_count" -gt 50 ]]; then
            echo "$untracked" | head -50
            echo "... ($((untracked_count - 50)) more files)"
        else
            echo "$untracked"
        fi
        echo "#+end_example"
    else
        echo "None."
    fi
    echo ""

    # ── Submodule status (if any) ──
    local submod
    submod=$(git -C "$repo_path" submodule status 2>/dev/null)
    if [[ -n "$submod" ]]; then
        echo "*** Submodule Status"
        echo "#+begin_example"
        echo "$submod"
        echo "#+end_example"
        echo ""
    fi

    separator
}

# ── Main ────────────────────────────────────────────────────────
main() {
    local repos=()

    if $USE_ALL || [[ ${#POSITIONAL[@]} -eq 0 ]]; then
        repos=("${ALL_REPOS[@]}")
    else
        repos=("${POSITIONAL[@]}")
    fi

    # Redirect output if --output specified
    if [[ -n "$OUTPUT" ]]; then
        exec > "$OUTPUT"
    fi

    echo "* Git Report — $(date '+%Y-%m-%d %H:%M')"
    echo ""
    local mode_label="full"
    $SHOW_DIFF || mode_label="summary (no diffs)"
    echo "  Mode: $mode_label"
    echo "  Repos reported (in commit order):"
    for r in "${repos[@]}"; do
        echo "  - $(basename "$r"): $r"
    done
    echo ""
    separator
    echo ""

    for repo in "${repos[@]}"; do
        report_repo "$repo"
    done
}

main
