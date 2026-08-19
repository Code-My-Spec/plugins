---
name: product
description: Product management — guided story interview, review, and Three Amigos sessions. Use when defining what to build, refining requirements, reviewing story quality, or running an Example Mapping session on a story.
user-invocable: true
allowed-tools: Bash(curl *), mcp__plugin_codemyspec_local__*
argument-hint: "[interview|review|three-amigos <story_id>]"
---

The JSON response from the skill endpoint:

!`HID="$(grep -o '"harness_id"[[:space:]]*:[[:space:]]*"[^"]*"' "${CLAUDE_PROJECT_DIR}/.cms_harness.json" | head -1 | cut -d'"' -f4)"; R=""; for P in 4003 4003; do R="$(curl -s -f -X POST "http://localhost:$P/api/harnesses/${HID:-unonboarded}/skills/start" --data-urlencode "skill=product" --data-urlencode "external_id=${CLAUDE_SESSION_ID}" --data-urlencode "arguments=$ARGUMENTS" --max-time 30)" && [ -n "$R" ] && break; done; [ -n "$R" ] || R='{"error":"No CodeMySpec harness answered on :4003 (dev harness) or :4003 (packaged cms server). Start one — `just refresh-harness` in a checkout, or `cms start` for the packaged CLI — then retry. The MCP tools do not go through this port and work meanwhile."}'; echo "$R"`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
