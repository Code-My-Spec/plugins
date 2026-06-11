---
name: qa
description: QA testing and issue management — full app QA, per-story QA, integration planning, issue triage, and fixes.
user-invocable: true
allowed-tools: Bash(curl *), Bash(web *), Bash(lsof *), Bash(mix phx.*), Bash(mix run *), Bash(mix test *), Read, Write, Glob, Grep, Task, Agent
argument-hint: [story <id>|integrations|triage [severity]|fix [severity]]
---

The JSON response from the skill endpoint:

!`curl -s -X POST http://localhost:4003/api/skills/start -H "X-Working-Dir: ${CLAUDE_PROJECT_DIR}" --data-urlencode "skill=qa" --data-urlencode "external_id=${CLAUDE_SESSION_ID}" --data-urlencode "arguments=$ARGUMENTS"`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
