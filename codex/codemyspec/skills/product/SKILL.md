---
name: product
description: Product management — guided story interview, review, and Three Amigos sessions. Use when defining what to build, refining requirements, reviewing story quality, or running an Example Mapping session on a story.
---

# CodeMySpec — product

Fetch your instructions from the local CodeMySpec server, then follow them.

1. Run this shell command from the workspace root:

   ```bash
   curl -s -X POST http://localhost:4003/api/skills/start \
     -H "X-Working-Dir: $PWD" \
     --data-urlencode "skill=product" \
     --data-urlencode "external_id=codex:$PWD" \
     --data-urlencode "arguments=<args>"
   ```

   Replace `<args>` with what the user asked for: `interview`, `review`, or `three-amigos <story_id>`. Leave empty if unspecified.

2. The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
