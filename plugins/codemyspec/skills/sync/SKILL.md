---
name: sync
description: Sync project components and regenerate architecture views. Use after git pulls, before design sessions, or when views feel stale.
user-invocable: true
allowed-tools: Bash(curl *)
---

The JSON response from the skill endpoint:

!`HID="$(grep -o '"harness_id"[[:space:]]*:[[:space:]]*"[^"]*"' "${CLAUDE_PROJECT_DIR}/.cms_harness.json" | head -1 | cut -d'"' -f4)"; PORTS="4003 4004"; R=""; for P in $PORTS; do R="$(curl -s -f -X POST "http://localhost:$P/api/harnesses/${HID:-unonboarded}/skills/start" --data-urlencode "skill=sync" --data-urlencode "external_id=${CLAUDE_SESSION_ID}" --data-urlencode "arguments=$ARGUMENTS" --max-time 30)" && [ -n "$R" ] && break; done; [ -n "$R" ] || R="{\"error\":\"No CodeMySpec service answered on ports $PORTS. Start one and retry: \`cms start\` for the packaged CLI, or \`just refresh-harness\` in a checkout. The MCP tools do not use this port and work meanwhile.\"}"; echo "$R"`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
