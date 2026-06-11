---
name: sync
description: Sync project components and regenerate architecture views. Use after git pulls, before design sessions, or when views feel stale.
user-invocable: true
allowed-tools: Bash(curl *)
---

The JSON response from the skill endpoint:

!`curl -s -X POST http://localhost:4003/api/skills/start -H "X-Working-Dir: ${CLAUDE_PROJECT_DIR}" --data-urlencode "skill=sync" --data-urlencode "external_id=${CLAUDE_SESSION_ID}"`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
