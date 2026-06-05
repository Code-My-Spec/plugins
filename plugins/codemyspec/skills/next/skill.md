---
name: next
description: Find and start the next requirement task in one gesture. Use after each completed task as your single onboarding instruction.
user-invocable: true
allowed-tools: Bash(curl *), Read, Write, Edit, Glob, Grep, Task
---

Use the **Bash tool** to run the command below, then read the JSON response and follow its `prompt` field:

```bash
curl -s -X POST http://localhost:4003/api/skills/start \
  -H 'Content-Type: application/json' \
  -H "X-Working-Dir: $(pwd)" \
  -d '{"skill":"next","external_id":"'"$CLAUDE_SESSION_ID"'","arguments":"'"$ARGUMENTS"'"}'
```

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
