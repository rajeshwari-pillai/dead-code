#!/usr/bin/env bash
set -e

SKILL_DIR="$HOME/.claude/skills/dead-code"

echo "Uninstalling dead-code..."

if [ -d "$SKILL_DIR" ]; then
  rm -rf "$SKILL_DIR"
  echo "Done. dead-code removed from $SKILL_DIR"
else
  echo "dead-code is not installed at $SKILL_DIR"
fi