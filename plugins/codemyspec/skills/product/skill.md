---
name: product
description: Product management — guided story interview, review, and Three Amigos sessions. Use when defining what to build, refining requirements, reviewing story quality, or running an Example Mapping session on a story.
user-invocable: true
allowed-tools: Bash(curl *), mcp__plugin_codemyspec_local__*
argument-hint: [interview|review|three-amigos <story_id>]
---

Use the **Bash tool** to run the command below, then read the JSON response and follow its `prompt` field:

```bash
curl -s -X POST http://localhost:4003/api/skills/start \
  -H 'Content-Type: application/json' \
  -H "X-Working-Dir: $(pwd)" \
  -d '{"skill":"product","external_id":"'"$CLAUDE_SESSION_ID"'","arguments":"'"$ARGUMENTS"'"}'
```

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
