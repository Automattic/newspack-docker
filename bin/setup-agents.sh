#!/usr/bin/env bash
#
# Set up AI agent tooling for Newspack development.
# Reads marketplace and plugin configuration from .claude/settings.json
# and installs everything at user scope.
#
# Usage: n setup-agents

set -euo pipefail

# ── Resolve workspace root ────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SETTINGS_FILE="$ROOT_DIR/.claude/settings.json"

if [[ ! -f "$SETTINGS_FILE" ]]; then
  echo "Error: $SETTINGS_FILE not found" >&2
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not installed" >&2
  exit 1
fi

# ── Colors ─────────────────────────────────────────────────────

bold="\033[1m"
dim="\033[2m"
green="\033[32m"
yellow="\033[33m"
cyan="\033[36m"
reset="\033[0m"

# ── Claude Code ────────────────────────────────────────────────

echo ""
echo -e "${bold}🤖 Setting up AI agent tooling...${reset}"

# Add marketplaces from extraKnownMarketplaces (github sources only)
echo ""
echo -e "${cyan}📦 Adding marketplaces...${reset}"
jq -r '.extraKnownMarketplaces // {} | to_entries[] | select(.value.source.source == "github") | .value.source | if .ref then "\(.repo)#\(.ref)" else .repo end' "$SETTINGS_FILE" | while read -r m; do
  echo -e "   ${dim}${m}${reset}"
  claude plugin marketplace add "$m" 2>/dev/null || true
done

# Install plugins from enabledPlugins
echo ""
echo -e "${cyan}🔌 Installing plugins...${reset}"
jq -r '.enabledPlugins // {} | to_entries[] | select(.value == true) | .key' "$SETTINGS_FILE" | while read -r p; do
  echo -e "   ${dim}${p}${reset}"
  if claude plugin install "$p" --scope user 2>/dev/null; then
    echo -e "   ${green}✓${reset} ${p}"
  else
    echo -e "   ${yellow}⚠${reset} ${p} ${dim}(may already be installed)${reset}"
  fi
done

echo ""
echo -e "${green}✅ Done!${reset} Restart Claude Code to load the new plugins and MCP servers."
echo ""
echo -e "${yellow}💡 Optional:${reset} set environment variables in your shell profile (~/.zshrc):"
echo -e "   ${dim}export CONTEXT7_API_KEY=\"ctx7sk-...\"  # Higher rate limits (free key at context7.com/dashboard)${reset}"
echo ""
