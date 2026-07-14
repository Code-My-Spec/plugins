---
name: develop
description: Full-lifecycle development — context orchestration, LiveView orchestration, and interactive refactoring. Spawns subagents for multi-step workflows.
---

# CodeMySpec — develop

Fetch your instructions from the local CodeMySpec server, then follow them.

1. Run this shell command from the workspace root:

   ```bash
   curl -s -X POST http://localhost:4003/api/skills/start \
     -H "X-Working-Dir: $PWD" \
     --data-urlencode "skill=develop" \
     --data-urlencode "external_id=codex:$PWD" \
     --data-urlencode "arguments=<args>"
   ```

   Replace `<args>` with what the user asked for: `context`, `liveview`, or `refactor`, optionally followed by a module name (e.g. `context MyApp.Accounts`). Leave empty if unspecified.

2. The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
