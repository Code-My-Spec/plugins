---
name: init
description: Project setup, authentication, and sync. Use when starting a new project, logging in, or refreshing stale state.
user-invocable: true
allowed-tools: Bash(curl *)
argument-hint: "[project_id]"
---

The JSON response from the init endpoint:

!`PORTS="${CMS_HARNESS_PORT:-4003 4004}"; R=""; for P in $PORTS; do R="$(curl -s -f -X POST "http://localhost:$P/api/skills/init" -H "X-Working-Dir: ${CLAUDE_PROJECT_DIR}" --data-urlencode "skill=init" --data-urlencode "external_id=${CLAUDE_SESSION_ID}" --data-urlencode "arguments=$ARGUMENTS" --max-time 30)" && [ -n "$R" ] && break; done; [ -n "$R" ] || R="{\"error\":\"No CodeMySpec service answered on ports $PORTS. Start one and retry: \`cms start\` for the packaged CLI, or \`just refresh-harness\` in a checkout. The MCP tools do not use this port and work meanwhile.\"}"; echo "$R"`

Follow the `prompt` field. If there is only an `error` field, show it to the user and stop.
