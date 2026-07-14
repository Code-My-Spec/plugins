---
name: sync
description: Sync project components and regenerate architecture views. Use after git pulls, before design sessions, or when views feel stale.
---

# CodeMySpec — sync

Fetch your instructions from the local CodeMySpec server, then follow them.

1. Run this shell command from the workspace root:

   ```bash
   curl -s -X POST http://localhost:4003/api/skills/start \
     -H "X-Working-Dir: $PWD" \
     --data-urlencode "skill=sync" \
     --data-urlencode "external_id=codex:$PWD"
   ```

2. The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
