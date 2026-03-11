#!/usr/bin/env bash
set -e

TARGET=${1:-}

usage() {
  echo "Usage: $0 [cursor|claude]"
  echo ""
  echo "  cursor  Install to ~/.cursor/agents/, ~/.cursor/commands/, ~/.cursor/skills/"
  echo "  claude  Install to ~/.claude/agents/, ~/.claude/commands/, ~/.claude/skills/"
  exit 1
}

if [[ -z "$TARGET" ]]; then
  usage
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONFIG_DIR="$SCRIPT_DIR/configuration"

install_skills() {
  local dest="$1"
  if [ -d "$CONFIG_DIR/skills" ]; then
    mkdir -p "$dest/skills"
    for skill_dir in "$CONFIG_DIR/skills"/*/; do
      skill_name=$(basename "$skill_dir")
      mkdir -p "$dest/skills/$skill_name"
      cp -r "$skill_dir"* "$dest/skills/$skill_name/"
    done
    echo "  skills:   $(ls "$CONFIG_DIR/skills/" | wc -l | tr -d ' ') installed"
  fi
}

case "$TARGET" in
  cursor)
    mkdir -p ~/.cursor/agents ~/.cursor/commands
    cp "$CONFIG_DIR/cursor/agents/"*.md ~/.cursor/agents/
    cp "$CONFIG_DIR/cursor/commands/"*.md ~/.cursor/commands/
    install_skills ~/.cursor
    echo "Installed to ~/.cursor/"
    echo "  agents:   $(ls "$CONFIG_DIR/cursor/agents/"*.md | wc -l | tr -d ' ') files"
    echo "  commands: $(ls "$CONFIG_DIR/cursor/commands/"*.md | wc -l | tr -d ' ') files"
    echo ""
    echo "MCP servers: some skills require MCP setup. See configuration/mcp/ for guides:"
    echo "  GitHub MCP: $CONFIG_DIR/mcp/github.md"
    echo "  Figma MCP:  $CONFIG_DIR/mcp/figma.md"
    ;;
  claude)
    mkdir -p ~/.claude/agents ~/.claude/commands
    cp "$CONFIG_DIR/claude/agents/"*.md ~/.claude/agents/
    cp "$CONFIG_DIR/claude/commands/"*.md ~/.claude/commands/
    install_skills ~/.claude
    echo "Installed to ~/.claude/"
    echo "  agents:   $(ls "$CONFIG_DIR/claude/agents/"*.md | wc -l | tr -d ' ') files"
    echo "  commands: $(ls "$CONFIG_DIR/claude/commands/"*.md | wc -l | tr -d ' ') files"
    echo ""
    echo "Tip: Set RPI_DOCS_DIR in your shell profile to point to this repo:"
    echo "  export RPI_DOCS_DIR=\"$SCRIPT_DIR\""
    echo ""
    echo "MCP servers: some skills require MCP setup. See configuration/mcp/ for guides:"
    echo "  GitHub MCP: $CONFIG_DIR/mcp/github.md"
    echo "  Figma MCP:  $CONFIG_DIR/mcp/figma.md"
    ;;
  *)
    usage
    ;;
esac
