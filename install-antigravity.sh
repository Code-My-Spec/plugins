#!/bin/bash
# Install the CodeMySpec plugin for Google Antigravity.
#
# Downloads the plugin from the Code-My-Spec/plugins repo and copies it into
# Antigravity's global plugin directory (and the Antigravity CLI's, if the
# CLI is present). Safe to re-run — each run replaces the installed copy.
#
# macOS / Linux only. Requires: curl, tar.
set -euo pipefail

REPO="Code-My-Spec/plugins"
PLUGIN_SUBDIR="antigravity/codemyspec"
GLOBAL_DEST="$HOME/.gemini/config/plugins/codemyspec"
CLI_HOME="$HOME/.gemini/antigravity-cli"
CLI_DEST="$CLI_HOME/plugins/codemyspec"

BLUE='\033[0;34m'; GREEN='\033[0;32m'; RED='\033[0;31m'; BOLD='\033[1m'; NC='\033[0m'
info() { echo -e "${BLUE}${BOLD}>>>${NC} $1"; }
ok()   { echo -e "${GREEN}${BOLD}>>>${NC} $1"; }
err()  { echo -e "${RED}${BOLD}>>>${NC} $1"; }

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

info "Downloading CodeMySpec Antigravity plugin..."
curl -fsSL "https://github.com/${REPO}/archive/refs/heads/main.tar.gz" \
  | tar -xz -C "$TMP" --strip-components=3 "plugins-main/${PLUGIN_SUBDIR}"

if [ ! -f "$TMP/plugin.json" ]; then
  err "Download failed — plugin.json not found in archive"
  exit 1
fi

install_to() {
  local dest="$1"
  rm -rf "$dest"
  mkdir -p "$(dirname "$dest")"
  cp -R "$TMP" "$dest"
  chmod +x "$dest/bin/ag-hook.sh"
  ok "Installed to $dest"
}

install_to "$GLOBAL_DEST"

# Stage into the Antigravity CLI's plugin directory too, if the CLI is set up.
if [ -d "$CLI_HOME" ]; then
  install_to "$CLI_DEST"
fi

echo
ok "CodeMySpec plugin for Antigravity installed."
echo
echo "  Requires the cms server (skills, hooks, and MCP talk to it):"
echo "    brew install Code-My-Spec/tap/codemyspec && brew services start codemyspec"
echo
echo "  Restart Antigravity (or reload plugins) to pick it up."
