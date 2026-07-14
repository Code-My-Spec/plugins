# CodeMySpec — Antigravity Plugin

Google Antigravity port of the CodeMySpec plugin (the Claude Code original
lives in `../claude/`). Specification-driven development for Phoenix
applications: design architecture, write specs, generate tests, and implement
with specialized AI agents.

## Layout (Antigravity plugin format)

```
codemyspec/
├── plugin.json        # manifest (schema allows name + description only)
├── mcp_config.json    # cms-mcp-relay (stdio → :4003) + vibium
├── hooks.json         # PreInvocation / Pre+PostToolUse / PostInvocation / Stop
├── bin/ag-hook.sh     # forwards hook payloads to the cms server (:4003)
├── skills/<name>/SKILL.md   # 8 skills; auto-become /slash-commands in the CLI
├── agents/<name>/agent.md   # 5 custom subagents (body = system prompt)
└── rules/codemyspec.md      # AGENTS.md content as an always-available rule
```

## Install

- **Workspace**: copy this directory to `<workspace>/.agents/plugins/codemyspec/`
- **Global (IDE / Antigravity 2.0)**: `~/.gemini/config/plugins/codemyspec/`
- **CLI**: `agy plugin install /path/to/codemyspec` (stages into
  `~/.gemini/antigravity-cli/plugins/`)

Requires the `cms` server running locally (brew service / Windows service) and
`cms-mcp-relay` + `vibium` on PATH. Source config points at dev ports
(4003 MCP, 4003 hooks/skills); the release packager rewrites these for the
published plugin, and `CODEMYSPEC_PORT` overrides the hook port ad hoc.

## Port mapping (Claude Code → Antigravity)

| Claude Code | Antigravity | Notes |
|---|---|---|
| `.claude-plugin/plugin.json` (mcpServers inline) | `plugin.json` + `mcp_config.json` | AG manifest is name+description only (`additionalProperties: false`) |
| `SessionStart` hook | `PreInvocation` | server treats `invocationNum == 0` per `conversationId` as session start |
| `PreToolUse` / `PostToolUse` | same events | payloads are camelCase (`toolCall.name`, `toolCall.args`); tool names differ (`run_command`, `write_to_file`, …) |
| `Stop` hook (block + reason) | `Stop` → `{"decision":"continue","reason":…}` | drives the requirement-graph eval loop |
| `SubagentStart`/`SubagentStop`, `PermissionRequest` | — | no AG equivalent; dropped |
| `!`-inline command in skills | explicit "run this command" instruction | AG skills have no inline execution |
| `${CLAUDE_PROJECT_DIR}` | `$PWD` at command time / `workspacePaths[0]` in hooks | relay falls back to cwd when the env var is unset |
| `${CLAUDE_SESSION_ID}` → `external_id` | `antigravity:$PWD` (workspace-stable) | see open questions |
| `agents/*.md` subagents | `agents/<name>/agent.md` | frontmatter: `name`+`description` only; body = system prompt; no `tools`/`model` fields (parent decides tool grants at spawn time); invoked via delegation or `@agent-name` |

## Server side (implemented)

`CodeMySpecLocalWeb.Antigravity.HooksController` serves
`/api/antigravity/hooks/{pre-invocation,pre-tool-use,post-tool-use,post-invocation,stop}`
behind the `:antigravity_hook` pipeline (`AntigravityWorkspace` lifts
`workspacePaths[0]` into `X-Working-Dir`, then the standard scope chain).
Sessions key on `conversationId`. Stop reuses the full Claude StopController
decision tree with the response translated to Antigravity's dialect
(`block` → `continue`). Known gaps, forced by Antigravity's hook schemas:

- PreToolUse can't mutate tool input → the `mix test`/`mix spex` rewrite is a
  deny-with-redirect (agent is told the exact analysis-service curl to run),
  and MCP `session_id` enrichment doesn't exist on this surface.
- PostToolUse carries no tool identity → file edits are tracked at
  PreToolUse time from `toolCall.args.TargetFile`.
- Stop terminus extras (`retrospective`, `systemMessage`) have no output slot
  and are dropped.
- No subagent events → per-agent edit attribution and R5a/R5b subagent rules
  don't apply on this surface.

If the server is unreachable, `bin/ag-hook.sh` degrades to safe no-op defaults.

## Open questions / assumptions to verify

1. **Hook command cwd**: docs show plugin-relative paths (`./scripts/lint.sh`),
   so we assume hook commands run from the plugin root. Verify on first install.
2. **external_id for skills**: skills can't see their conversation id (hooks
   can), so they send a workspace-stable `antigravity:$PWD`. The server may
   want to bridge that to the `conversationId` seen by hooks.
3. **Env interpolation in mcp_config.json**: not documented; we rely on the
   relay's cwd fallback instead of `${...}` variables.
4. **Windows**: `ag-hook.sh` is bash-only; needs a `.cmd`/`.ps1` twin like the
   Claude plugin's `hook.cmd` before shipping.
5. **`_agents/plugins/`** is also scanned at workspace level (alt prefix).
