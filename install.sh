#!/usr/bin/env bash
set -e

SKILL_DIR="$HOME/.claude/skills/dead-code"
COMMANDS_DIR="$HOME/.claude/commands"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing dead-code skill..."
mkdir -p "$SKILL_DIR"
cp "$REPO_DIR/SKILL.md" "$SKILL_DIR/SKILL.md"

echo "Installing dead-code commands..."
mkdir -p "$COMMANDS_DIR"
for cmd_file in "$REPO_DIR/commands/"*.md; do
  cmd_name="dead-code-$(basename "$cmd_file")"
  cp "$cmd_file" "$COMMANDS_DIR/$cmd_name"
done

echo ""
echo "Done. Installed:"
echo "  Skill  → $SKILL_DIR/SKILL.md"
echo "  Commands → $COMMANDS_DIR/dead-code-*.md"
echo ""
echo "Commands available in Claude Code:"
echo "  /dead-code-scan ."
echo "  /dead-code-scan-imports src/"
echo "  /dead-code-scan-functions payments/helpers/"
echo "  /dead-code-scan-endpoints ."
echo "  /dead-code-scan-tasks ."
echo "  /dead-code-scan-env ."
echo "  /dead-code-scan-unreachable src/"