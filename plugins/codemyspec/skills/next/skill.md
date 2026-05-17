---
name: next
description: Find and start the next requirement task in one gesture. Use after each completed task as your single onboarding instruction.
user-invocable: true
allowed-tools: Bash(*/skill *), Read, Write, Edit, Glob, Grep, Task
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/skill next ${CLAUDE_SESSION_ID} $ARGUMENTS`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
