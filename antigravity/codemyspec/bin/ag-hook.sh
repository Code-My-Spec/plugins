#!/bin/bash
# Route Antigravity hooks to the local cms server.
#
# Usage: ag-hook.sh <event>
#   event ∈ pre-invocation | pre-tool-use | post-tool-use | post-invocation | stop
#
# Reads the Antigravity hook payload (camelCase JSON) on stdin, POSTs it to
# the cms server, and echoes the server's response to stdout — Antigravity
# consumes stdout as the hook's decision. The cms server runs as a standalone
# service installed out-of-band (brew services / Windows service); this script
# only forwards. If the server is unreachable, it emits a per-event safe
# default so the agent loop is never blocked by a missing server.

EVENT="$1"

# Default port is rewritten by the release packager when shipping the
# published plugin. CODEMYSPEC_PORT overrides for ad-hoc setups.
PORT="${CODEMYSPEC_PORT:-4003}"

STDIN_DATA=$(cat)

# --fail keeps 4xx/5xx bodies (HTML error pages) out of stdout — Antigravity
# parses stdout as the hook decision, so only a 2xx JSON body may pass through.
RESPONSE=$(printf '%s' "$STDIN_DATA" | curl -sS --fail --max-time 30 -X POST \
  "http://localhost:${PORT}/api/antigravity/hooks/${EVENT}" \
  -H "Content-Type: application/json" \
  --data-binary @- 2>/dev/null)

if [ -n "$RESPONSE" ]; then
  printf '%s' "$RESPONSE"
  exit 0
fi

# Server down or empty response — safe defaults per event schema:
#   PreToolUse requires a decision; "ask" preserves the normal permission flow.
#   Stop requires a decision; any value other than "continue" allows the stop.
case "$EVENT" in
  pre-tool-use) echo '{"decision":"ask"}' ;;
  stop)         echo '{"decision":"stop"}' ;;
  *)            echo '{}' ;;
esac
