---
name: next
description: Find and start the next requirement task in one gesture. Use after each completed task as your single onboarding instruction.
---

# CodeMySpec — next

Fetch your instructions from the local CodeMySpec server, then follow them.

1. Run this shell command from the workspace root:

   ```bash
   curl -s -X POST http://localhost:4003/api/skills/start \
     -H "X-Harness-Id: $(grep -o '"harness_id"[[:space:]]*:[[:space:]]*"[^"]*"' "$PWD/.cms_harness.json" | head -1 | cut -d'"' -f4)" \
     --data-urlencode "skill=next" \
     --data-urlencode "external_id=antigravity:$PWD" \
     --data-urlencode "arguments="
   ```

2. The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
