---
name: implement
description: Autonomous implementation loop — start or stop requirements-driven development. The agent walks the requirement graph automatically.
user-invocable: true
allowed-tools: Bash(curl *), Read, Write, Glob, Grep, Task
argument-hint: [start|stop]
---

The JSON response from the skill endpoint:

!`curl -s -X POST http://localhost:4003/api/skills/start -H 'Content-Type: application/json' -H "X-Working-Dir: ${CLAUDE_PROJECT_DIR}" -d '{"skill":"implement","external_id":"'"$CLAUDE_SESSION_ID"'","arguments":"'"$ARGUMENTS"'"}'`

If the response contains a `prompt` field, extract and follow it.

If the response is `{"stopped": true}`: Agentic mode has been disabled. The agent will no longer automatically continue to the next task. To resume, use `/codemyspec:implement` or `/codemyspec:implement start`.
