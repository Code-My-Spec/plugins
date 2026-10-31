---
name: init
description: Project setup, authentication, and sync. Use when starting a new project, logging in, or refreshing stale state.
---

# CodeMySpec — init

Fetch onboarding instructions from the running CodeMySpec harness.

1. Run from the workspace root. An explicit port takes precedence; otherwise try
   the port saved by onboarding, then the development and packaged defaults:

   ```bash
   bash <<'BASH'
   ports="${CMS_HARNESS_PORT:-4003 4004}"
   if [ -z "${CMS_HARNESS_PORT:-}" ] && [ -r "$HOME/.codemyspec/harness.port" ]; then
     saved_port=$(cat "$HOME/.codemyspec/harness.port")
     case "$saved_port" in
       ''|*[!0-9]*) ;;
       *) ports="$saved_port $ports" ;;
     esac
   fi
   for port in $ports; do
     if response=$(curl --noproxy '*' --connect-timeout 3 --max-time 30 -fsS \
       -X POST "http://127.0.0.1:$port/api/skills/init" \
       -H "X-Working-Dir: $PWD" \
       --data-urlencode "skill=init" \
       --data-urlencode "external_id=${CODEX_THREAD_ID:-codex:$PWD}") && [ -n "$response" ]; then
       printf '%s\n' "$response"
       exit 0
     fi
   done
   printf 'No CodeMySpec service answered on ports %s. Start the harness and retry.\n' "$ports" >&2
   exit 1
   BASH
   ```

2. If no service answers, use the existing installation's startup path:
   - Codex Cloud: run the device's **Start or resume** prompt from CodeMySpec's
     connection screen. It starts the cloud harness and registers this conversation.
   - Source checkout: run `bash scripts/start-harness <server-url>` with the
     project's configured CodeMySpec server URL. It installs missing Hex and Rebar,
     handles device authorization, onboards the checkout, and starts the harness.
   - Packaged installation: run `cms start`.
   Show the verification URL and user code when authorization is requested. After
   startup succeeds, retry step 1. Report startup errors rather than retrying indefinitely.

3. Follow the response's `prompt` field. If it contains only an `error`, show it
   to the user and stop. Cloud sessions are resumed manually; this workflow does
   not configure automatic wake-up.
