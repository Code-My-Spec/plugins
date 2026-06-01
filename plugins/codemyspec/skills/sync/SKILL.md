---
name: sync
description: Sync project components and regenerate architecture views. Use after git pulls, before design sessions, or when views feel stale.
user-invocable: true
allowed-tools: Bash(curl *)
---

!`curl -s -X POST http://localhost:4003/api/skills/start -H 'Content-Type: application/json' -H "X-Working-Dir: $(pwd)" -d '{"skill":"sync","external_id":"'"$CLAUDE_SESSION_ID"'"}'`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
