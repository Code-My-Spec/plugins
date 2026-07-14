---
name: qa
description: QA testing and issue management — full app QA, per-story QA, integration planning, issue triage, and fixes.
---

# CodeMySpec — qa

Fetch your instructions from the local CodeMySpec server, then follow them.

1. Run this shell command from the workspace root:

   ```bash
   curl -s -X POST http://localhost:4003/api/skills/start \
     -H "X-Working-Dir: $PWD" \
     --data-urlencode "skill=qa" \
     --data-urlencode "external_id=codex:$PWD" \
     --data-urlencode "arguments=<args>"
   ```

   Replace `<args>` with what the user asked for: `story <id>`, `integrations`, `triage [severity]`, or `fix [severity]`. Leave empty if unspecified.

2. The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
