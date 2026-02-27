#!/usr/bin/env bash
# Deploy tangled agent definitions to their target locations.
#
# Run from the mayadevgeni project root after tangling:
#   ./scripts/deploy-agents.sh
#
# Targets:
#   gptel-agent  → agency/agents/
#   claude-code  → ../mayalucia/.claude/agents/  (sibling project)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

LIBRARY="$PROJECT_ROOT/develop/system-prompt/library"
GPTEL_SRC="$LIBRARY/gptel"
CLAUDE_SRC="$LIBRARY/claude-code"

GPTEL_DST="$PROJECT_ROOT/agency/agents"
CLAUDE_DST="$PROJECT_ROOT/../mayalucia/.claude/agents"

if [ ! -d "$GPTEL_SRC" ] || [ ! -d "$CLAUDE_SRC" ]; then
    echo "Error: Library directories not found. Run tangle first (C-c C-v t on agency/tangle.org)."
    exit 1
fi

# Deploy gptel-agent definitions
echo "Deploying gptel-agent definitions..."
mkdir -p "$GPTEL_DST"
for f in "$GPTEL_SRC"/*.md; do
    [ -f "$f" ] || continue
    cp "$f" "$GPTEL_DST/"
    echo "  $(basename "$f") → agency/agents/"
done

# Deploy Claude Code definitions
if [ -d "$(dirname "$CLAUDE_DST")" ]; then
    echo "Deploying Claude Code definitions..."
    mkdir -p "$CLAUDE_DST"
    for f in "$CLAUDE_SRC"/*.md; do
        [ -f "$f" ] || continue
        cp "$f" "$CLAUDE_DST/"
        echo "  $(basename "$f") → mayalucia/.claude/agents/"
    done
else
    echo "Warning: mayalucia project not found at $CLAUDE_DST"
    echo "  Skipping Claude Code deployment."
    echo "  Deploy manually: cp $CLAUDE_SRC/*.md <target>/.claude/agents/"
fi

echo "Done."
