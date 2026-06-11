---
name: design
description: Architecture design, UI design system, and technology strategy. Use before writing code to plan how to build it.
user-invocable: true
allowed-tools: Bash(curl *), Read, Write, Glob, Grep, WebSearch, WebFetch, Task, mcp__plugin_codemyspec_local__*
argument-hint: [architecture|ui|strategy]
---

The JSON response from the skill endpoint:

!`curl -s -X POST http://localhost:4003/api/skills/start -H "X-Working-Dir: ${CLAUDE_PROJECT_DIR}" --data-urlencode "skill=design" --data-urlencode "external_id=${CLAUDE_SESSION_ID}" --data-urlencode "arguments=$ARGUMENTS"`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
