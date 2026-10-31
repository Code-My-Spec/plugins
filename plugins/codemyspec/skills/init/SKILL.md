---
name: init
description: Project setup, authentication, and sync. Use when starting a new project, logging in, or refreshing stale state.
user-invocable: true
allowed-tools: Bash(curl *)
argument-hint: "[project_id]"
---

The JSON response from the init endpoint:

!`PORTS="${CMS_HARNESS_PORT:-4003 4004}"; SAVED_PORT=""; [ -n "${CMS_HARNESS_PORT:-}" ] || { read -r SAVED_PORT < "$HOME/.codemyspec/harness.port" 2>/dev/null || :; }; [ -z "$SAVED_PORT" ] || PORTS="$SAVED_PORT $PORTS"; R=""; for P in $PORTS; do R="$(curl -s -f -X POST "http://localhost:$P/api/skills/init" -H "X-Working-Dir: ${CLAUDE_PROJECT_DIR}" --data-urlencode "skill=init" --data-urlencode "external_id=${CLAUDE_SESSION_ID}" --data-urlencode "arguments=$ARGUMENTS" --max-time 30)" && [ -n "$R" ] && break; done; [ -n "$R" ] || R="{\"error\":\"No CodeMySpec service answered on ports $PORTS. Start one and retry: \`cms start\` for the packaged CLI, or \`bash scripts/start-harness https://your-server.example\` in a source checkout. The MCP tools use the same port.\"}"; echo "$R"`

Follow the `prompt` field. If there is only an `error` field, show it to the user and stop.
