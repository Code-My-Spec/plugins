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
     --data-urlencode "external_id=antigravity:$PWD" \
     --data-urlencode "arguments=<args>"
   ```

   Replace `<args>` with `auth` if the user asked to authenticate (leave empty if unspecified).

2. If the response contains a `prompt` field, extract and follow it.

3. If the response is `{"auth": true}`, follow the auth flow:

   1. Run: `curl -s http://localhost:4003/api/bootstrap/auth/status`
      - If `"authenticated": true`, tell the user and stop.
   2. Run: `curl -s -X POST http://localhost:4003/api/bootstrap/auth/start`
      - Returns JSON with `auth_url`. Tell the user the URL, then open it:
        - macOS: `open "<auth_url>"`
        - Linux: `xdg-open "<auth_url>"`
        - Windows: `start "<auth_url>"`
      - If you can't determine the OS, just share the URL for the user to open.
   3. Wait for the user to confirm they completed sign-in.
   4. Run the status check again. Confirm success or offer retry.
