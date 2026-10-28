---
name: init
description: Project setup, authentication, and sync. Use when starting a new project, logging in, or refreshing stale state.
---

# CodeMySpec — init

Fetch your instructions from the local CodeMySpec server, then follow them.

1. Run this shell command from the workspace root:

   ```bash
   curl -s -X POST http://localhost:4003/api/skills/init \
     -H "X-Working-Dir: $PWD" \
     --data-urlencode "skill=init" \
     --data-urlencode "external_id=codex:$PWD"
   ```

2. Follow the `prompt` field in the response. If there is only an `error` field, show it to the user and stop.
