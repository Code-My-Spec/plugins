---
name: next
description: Find and start the next requirement task in one gesture. Use after each completed task as your single onboarding instruction.
user-invocable: true
allowed-tools: Bash(curl *), Read, Write, Edit, Glob, Grep, Task
---

The JSON response from the skill endpoint:

!`curl -s -X POST http://localhost:4003/api/skills/start -H "X-Working-Dir: ${CLAUDE_PROJECT_DIR}" --data-urlencode "skill=next" --data-urlencode "external_id=${CLAUDE_SESSION_ID}" --data-urlencode "arguments=$ARGUMENTS"`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
