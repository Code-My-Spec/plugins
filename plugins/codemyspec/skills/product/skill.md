---
name: product
description: Product management — guided story interview, review, and Three Amigos sessions. Use when defining what to build, refining requirements, reviewing story quality, or running an Example Mapping session on a story.
user-invocable: true
allowed-tools: Bash(*/skill *), mcp__plugin_codemyspec_local__*
argument-hint: [interview|review|three-amigos <story_id>]
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/skill product ${CLAUDE_SESSION_ID} $ARGUMENTS`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
