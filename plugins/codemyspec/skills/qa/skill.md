---
name: qa
description: QA testing and issue management — full app QA, per-story QA, integration planning, issue triage, and fixes.
user-invocable: true
allowed-tools: Bash(curl *), Bash(web *), Bash(lsof *), Bash(mix phx.*), Bash(mix run *), Bash(mix test *), Read, Write, Glob, Grep, Task, Agent
argument-hint: [story <id>|integrations|triage [severity]|fix [severity]]
---

!`curl -s -X POST http://localhost:4003/api/skills/start -H 'Content-Type: application/json' -H "X-Working-Dir: $(pwd)" -d '{"skill":"qa","external_id":"'"$CLAUDE_SESSION_ID"'","arguments":"'"$ARGUMENTS"'"}'`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
