---
name: product
description: Product management — guided story interview, review, and Three Amigos sessions. Use when defining what to build, refining requirements, reviewing story quality, or running an Example Mapping session on a story.
user-invocable: true
allowed-tools: Bash(curl *), mcp__plugin_codemyspec_local__*
argument-hint: [interview|review|three-amigos <story_id>]
---

The JSON response from the skill endpoint:

!`curl -s -X POST http://localhost:4003/api/skills/start -H "X-Working-Dir: ${CLAUDE_PROJECT_DIR}" --data-urlencode "skill=product" --data-urlencode "external_id=${CLAUDE_SESSION_ID}" --data-urlencode "arguments=$ARGUMENTS"`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
