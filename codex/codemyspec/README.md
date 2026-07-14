# CodeMySpec — Codex Plugin

OpenAI Codex port of the CodeMySpec plugin (Claude Code original in
`../claude/`, Antigravity port in `../antigravity/`).
Specification-driven development for Phoenix applications.

## Layout (Codex plugin format)

```
codemyspec/
├── .codex-plugin/plugin.json  # manifest (name/version/skills/mcpServers/hooks refs)
├── .mcp.json                  # MCP servers (direct server map)
├── hooks/hooks.json           # lifecycle hooks (Claude Code-compatible dialect)
├── bin/hook{,.cmd,.ps1}       # event router → cms server /api/hooks/*
└── skills/<name>/SKILL.md     # 8 skills; invoke via $name or /skills
```

## Why this port is thin

Codex adopted Claude Code's hook protocol nearly verbatim: same
`hooks.json` shape, same event names (SessionStart, PreToolUse,
PostToolUse, Stop, SubagentStart/Stop, PermissionRequest), same
snake_case input payload (`session_id`, `cwd`, `hook_event_name`,
`tool_name`, `tool_input`), and same output contracts
(`hookSpecificOutput.permissionDecision` + `updatedInput`,
`decision: "block"` on Stop). The plugin therefore posts to the **same
`/api/hooks/*` endpoints** as the Claude Code plugin — no server-side
adapter needed — and the `mix test`→analysis-service rewrite and stop-hook
eval loop work unchanged.

Two deliberate choices keep server logic reusable:

- The MCP server in `.mcp.json` is named `plugin_codemyspec_local` so
  Codex's `mcp__<server>__<tool>` naming yields
  `mcp__plugin_codemyspec_local__*` — the exact prefix the server's
  PreToolUse session-enrichment matcher expects. **Verify tool naming on
  first install**; if Codex namespaces plugin servers differently, the
  enrichment silently won't fire (tools still work).
- Hook commands run `${PLUGIN_ROOT}/bin/hook` (with a `commandWindows`
  `.cmd` twin), the same router script the Claude plugin ships. It routes
  by `hook_event_name`, so protocol drift shows up in one file.

## Differences from the Claude Code plugin

| Claude Code | Codex | Notes |
|---|---|---|
| `.claude-plugin/plugin.json` with inline `mcpServers` | `.codex-plugin/plugin.json` + `.mcp.json` | manifest references components by path |
| `!`-inline command execution in skills | explicit "run this command" instruction | skills carry `external_id=codex:$PWD` instead of `${CLAUDE_SESSION_ID}` |
| `/codemyspec:<skill>` slash commands | `$<skill>` mentions / `/skills` picker | |
| `agents/*.md` subagents | — | Codex has no documented plugin agent format; SubagentStart/Stop hooks still fire for Codex-native subagents |
| Write/Edit/MultiEdit edit tracking | `apply_patch` | server's PostToolUse edit tracker keys on Claude tool names; `apply_patch` edits are NOT tracked yet (server gap, noted below) |
| AGENTS.md shipped in plugin | project-level AGENTS.md | Codex reads the repo's AGENTS.md natively; `/init` installs it |

## Install

- **Local test**: copy this directory to `~/.codex/plugins/codemyspec/` and
  add a matching entry in `~/.agents/plugins/marketplace.json`
  (`{"source": {"source": "local", "path": ...}}`), or repo-scoped under
  `$REPO_ROOT/plugins/` + `$REPO_ROOT/.agents/plugins/marketplace.json`.
- **From the published repo**:
  `codex plugin marketplace add Code-My-Spec/plugins`, then install
  `codemyspec` from `/plugins`.
- Hooks require trust: review and enable via `/hooks` in the Codex CLI.

Requires the `cms` server (brew / Windows service) and `cms-mcp-relay` +
`vibium` on PATH. Source config points at dev port 4003 (hooks/skills) and
4003 (MCP); the release packager rewrites 4003→4003 for the published copy.

## Known gaps / verify on first install

1. `mcp__plugin_codemyspec_local__*` tool-name assumption (above).
2. Server-side edit tracking ignores `apply_patch` — stop-hook file scoping
   won't see Codex edits until the server's PostToolUse controller learns
   the tool name and its input shape.
3. `PermissionRequest` response schema: the server answers in Claude Code's
   dialect; Codex's documented shape (`hookSpecificOutput.decision.behavior`)
   looks compatible but is unverified.
4. Skills can't see the Codex `session_id` (hooks can), so they send a
   workspace-stable `codex:$PWD` external id — same open question as the
   Antigravity port.
