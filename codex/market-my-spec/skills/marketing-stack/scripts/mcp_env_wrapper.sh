#!/usr/bin/env bash
#
# Launch an MCP server with secrets sourced from a .env file.
#
# Codex does not expand ${VAR} in ~/.codex/config.toml, and MCP servers do not
# inherit the shell environment. The normal mechanism is `env_vars = [...]`,
# which forwards variables by name from Codex's own environment -- but that only
# works when Codex was launched from a shell that had .env loaded.
#
# Use this wrapper when it wasn't (e.g. the Codex app, launched from the dock).
# It sources .env at server start, so config.toml holds only a path, never a secret.
#
# Wire it up in ~/.codex/config.toml -- both paths MUST be absolute, because
# Codex performs no variable or tilde expansion:
#
#   [mcp_servers.ghost]
#   command = "/abs/path/to/skills/marketing-stack/scripts/mcp_env_wrapper.sh"
#   args = ["npx", "-y", "@fanyangmeng/ghost-mcp"]
#   env = { MCP_ENV_FILE = "/abs/path/to/project/.env" }
#
# Usage: mcp_env_wrapper.sh <command> [args...]
#   MCP_ENV_FILE -- absolute path to the .env file to source (required)

set -euo pipefail

if [ "$#" -eq 0 ]; then
  echo "mcp_env_wrapper.sh: no command given" >&2
  echo "usage: MCP_ENV_FILE=/abs/path/.env mcp_env_wrapper.sh <command> [args...]" >&2
  exit 64
fi

if [ -z "${MCP_ENV_FILE:-}" ]; then
  echo "mcp_env_wrapper.sh: MCP_ENV_FILE is not set." >&2
  echo "Set it to the absolute path of your .env in the [mcp_servers.<name>.env] block." >&2
  exit 78
fi

if [ ! -f "$MCP_ENV_FILE" ]; then
  echo "mcp_env_wrapper.sh: no .env at '$MCP_ENV_FILE'." >&2
  echo "Codex does not expand '~' or variables in config.toml -- use an absolute path." >&2
  exit 78
fi

# Export everything defined in the .env for the duration of the source.
set -a
# shellcheck disable=SC1090
. "$MCP_ENV_FILE"
set +a

exec "$@"
