---
name: implement
description: Autonomous implementation loop — start or stop requirements-driven development. The agent walks the requirement graph automatically.
---

# CodeMySpec — implement

Fetch your instructions from the local CodeMySpec server, then follow them.

1. Run this shell command from the workspace root:

   ```bash
   curl -s -X POST http://localhost:4003/api/skills/start \
     -H "X-Working-Dir: $PWD" \
     --data-urlencode "skill=implement" \
     --data-urlencode "external_id=codex:$PWD" \
     --data-urlencode "arguments=<args>"
   ```

   Replace `<args>` with `start` or `stop` as the user requested (leave empty if unspecified).

2. If the response contains a `prompt` field, extract and follow it.

3. If the response is `{"stopped": true}`: Agentic mode has been disabled. The agent will no longer automatically continue to the next task. To resume, use `$implement` or `$implement start`.
