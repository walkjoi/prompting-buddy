#!/usr/bin/env bash
set -euo pipefail

# Build the .skill distributable from source files.
# Usage: ./scripts/build-skill.sh [output-path]
# Default output: ./prompting-buddy.skill

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT="${1:-$ROOT_DIR/prompting-buddy.skill}"

cd "$ROOT_DIR"

# Validate required files exist
for f in SKILL.md references/best-practices.md; do
  if [ ! -f "$f" ]; then
    echo "ERROR: Missing required file: $f" >&2
    exit 1
  fi
done

rm -f "$OUTPUT"
zip -r "$OUTPUT" SKILL.md references/
echo "Built: $OUTPUT"
