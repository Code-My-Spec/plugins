---
name: implement
description: Autonomous implementation loop — start or stop requirements-driven development. The agent walks the requirement graph automatically.
user-invocable: true
allowed-tools: Bash(curl *), Read, Write, Glob, Grep, Task
argument-hint: "[start|stop]"
---

The JSON response from the skill endpoint:

!`HID="$(grep -o '"harness_id"[[:space:]]*:[[:space:]]*"[^"]*"' "${CLAUDE_PROJECT_DIR}/.cms_harness.json" | head -1 | cut -d'"' -f4)"; PORTS="4003 4004"; R=""; for P in $PORTS; do R="$(curl -s -f -X POST "http://localhost:$P/api/harnesses/${HID:-unonboarded}/skills/start" --data-urlencode "skill=implement" --data-urlencode "external_id=${CLAUDE_SESSION_ID}" --data-urlencode "arguments=$ARGUMENTS" --max-time 30)" && [ -n "$R" ] && break; done; [ -n "$R" ] || R="{\"error\":\"No CodeMySpec service answered on ports $PORTS. Start one and retry: \`cms start\` for the packaged CLI, or \`just refresh-harness\` in a checkout. The MCP tools do not use this port and work meanwhile.\"}"; echo "$R"`

If the response contains a `prompt` field, extract and follow it.

If the response is `{"stopped": true}`: Agentic mode has been disabled. The agent will no longer automatically continue to the next task. To resume, use `/codemyspec:implement` or `/codemyspec:implement start`.
