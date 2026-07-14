---
name: design
description: Architecture design, UI design system, and technology strategy. Use before writing code to plan how to build it.
---

# CodeMySpec — design

Fetch your instructions from the local CodeMySpec server, then follow them.

1. Run this shell command from the workspace root:

   ```bash
   curl -s -X POST http://localhost:4003/api/skills/start \
     -H "X-Working-Dir: $PWD" \
     --data-urlencode "skill=design" \
     --data-urlencode "external_id=antigravity:$PWD" \
     --data-urlencode "arguments=<args>"
   ```

   Replace `<args>` with whatever the user asked for: `architecture`, `ui`, or `strategy` (leave empty if unspecified).

2. The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
