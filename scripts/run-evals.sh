#!/usr/bin/env bash
set -euo pipefail

# Run with_skill vs without_skill eval comparison.
# Requires: claude CLI, ANTHROPIC_API_KEY
# Usage: ./scripts/run-evals.sh [iteration]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ITERATION="${1:-ci}"
WORKSPACE="$ROOT_DIR/prompting-buddy-workspace/$ITERATION"
EVALS_FILE="$ROOT_DIR/evals/evals.json"
SKILL_PATH="$ROOT_DIR"

if ! command -v claude &>/dev/null; then
  echo "ERROR: claude CLI not found. Install Claude Code first." >&2
  exit 1
fi

if [ ! -f "$EVALS_FILE" ]; then
  echo "ERROR: $EVALS_FILE not found." >&2
  exit 1
fi

EVAL_COUNT=$(python3 -c "import json; print(len(json.load(open('$EVALS_FILE'))['evals']))")
echo "Running $EVAL_COUNT eval(s), iteration=$ITERATION"

for i in $(seq 0 $((EVAL_COUNT - 1))); do
  EVAL_ID=$(python3 -c "import json; print(json.load(open('$EVALS_FILE'))['evals'][$i]['id'])")
  PROMPT=$(python3 -c "import json; print(json.load(open('$EVALS_FILE'))['evals'][$i]['prompt'])")

  echo ""
  echo "=== Eval $EVAL_ID ==="

  # with_skill
  OUT_WITH="$WORKSPACE/eval-$EVAL_ID/with_skill/outputs"
  mkdir -p "$OUT_WITH"
  echo "  Running with_skill..."
  claude -p "You have access to the skill at $SKILL_PATH. Read the SKILL.md and follow it. Task: $PROMPT Save all outputs to $OUT_WITH/" \
    --output-format json \
    --max-turns 30 \
    > "$WORKSPACE/eval-$EVAL_ID/with_skill/transcript.json" 2>&1 || true

  # without_skill
  OUT_WITHOUT="$WORKSPACE/eval-$EVAL_ID/without_skill/outputs"
  mkdir -p "$OUT_WITHOUT"
  echo "  Running without_skill..."
  claude -p "$PROMPT Save all outputs to $OUT_WITHOUT/" \
    --output-format json \
    --max-turns 30 \
    > "$WORKSPACE/eval-$EVAL_ID/without_skill/transcript.json" 2>&1 || true

  echo "  Eval $EVAL_ID done."
done

echo ""
echo "All evals complete. Results in: $WORKSPACE"
