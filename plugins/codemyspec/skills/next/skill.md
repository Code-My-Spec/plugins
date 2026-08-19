---
name: next
description: Find and start the next requirement task in one gesture. Use after each completed task as your single onboarding instruction.
user-invocable: true
allowed-tools: Bash(curl *), Read, Write, Edit, Glob, Grep, Task
---

The JSON response from the skill endpoint:

!`HID="$(grep -o '"harness_id"[[:space:]]*:[[:space:]]*"[^"]*"' "${CLAUDE_PROJECT_DIR}/.cms_harness.json" | head -1 | cut -d'"' -f4)"; PORTS="4003 4004"; R=""; for P in $PORTS; do R="$(curl -s -f -X POST "http://localhost:$P/api/harnesses/${HID:-unonboarded}/skills/start" --data-urlencode "skill=next" --data-urlencode "external_id=${CLAUDE_SESSION_ID}" --data-urlencode "arguments=$ARGUMENTS" --max-time 30)" && [ -n "$R" ] && break; done; [ -n "$R" ] || R="{\"error\":\"No CodeMySpec service answered on ports $PORTS. Start one and retry: \`cms start\` for the packaged CLI, or \`just refresh-harness\` in a checkout. The MCP tools do not use this port and work meanwhile.\"}"; echo "$R"`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
