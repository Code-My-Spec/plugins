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

# Which working copy this is, read at request time.
#
# Antigravity delivers the workspace as `workspacePaths` in the JSON body, and a
# plug used to lift that into a header so the working-directory chain could
# resolve it. Both are gone — that was a filesystem path arriving from outside
# in a different shape, and a wrong one succeeded against the wrong disk rather
# than failing.
#
# `.cms_harness.json` carries the id. Walking up because a hook's cwd is
# wherever the agent happens to be, which is not always the checkout root.
harness_id() {
  local dir="$PWD"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/.cms_harness.json" ]; then
      # grep, not jq: jq is not a dependency of this plugin and a hook that
      # fails on a missing binary is worse than one that sends no id.
      grep -o '"harness_id"[[:space:]]*:[[:space:]]*"[^"]*"' "$dir/.cms_harness.json" |
        head -1 | cut -d'"' -f4
      return
    fi
    dir="$(dirname "$dir")"
  done
}

# --fail keeps 4xx/5xx bodies (HTML error pages) out of stdout — Antigravity
# parses stdout as the hook decision, so only a 2xx JSON body may pass through.
RESPONSE=$(printf '%s' "$STDIN_DATA" | curl -sS --fail --max-time 30 -X POST \
  "http://localhost:${PORT}/api/antigravity/hooks/${EVENT}" \
  -H "Content-Type: application/json" \
  -H "X-Harness-Id: $(harness_id)" \
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
