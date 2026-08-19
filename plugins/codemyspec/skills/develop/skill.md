---
name: develop
description: Full-lifecycle development — context orchestration, LiveView orchestration, and interactive refactoring. Spawns subagents for multi-step workflows.
user-invocable: true
allowed-tools: Bash(curl *), Read, Write, Edit, Glob, Grep, Task
argument-hint: "[context|liveview|refactor] [ModuleName]"
---

The JSON response from the skill endpoint:

!`HID="$(grep -o '"harness_id"[[:space:]]*:[[:space:]]*"[^"]*"' "${CLAUDE_PROJECT_DIR}/.cms_harness.json" | head -1 | cut -d'"' -f4)"; curl -s -X POST "http://localhost:4003/api/harnesses/${HID:-unonboarded}/skills/start" --data-urlencode "skill=develop" --data-urlencode "external_id=${CLAUDE_SESSION_ID}" --data-urlencode "arguments=$ARGUMENTS"`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
