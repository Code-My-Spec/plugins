# CodeMySpec — Codex Plugin

OpenAI Codex port of the CodeMySpec plugin (Claude Code original in
`../claude/`, Antigravity port in `../antigravity/`).
Specification-driven development for Phoenix applications.

## Layout (Codex plugin format)

```
codemyspec/
├── .codex-plugin/plugin.json  # manifest (name/version/mcpServers refs)
└── .mcp.json                  # MCP servers (direct server map)
```

## Why this port is thin

- The MCP server in `.mcp.json` is named `plugin_codemyspec_local` so
  Codex's `mcp__<server>__<tool>` naming yields
  `mcp__plugin_codemyspec_local__*`.
- The server is the CodeMySpec server's own `/mcp/harness`, over HTTP. Codex
  signs in with OAuth: run `codex mcp login plugin_codemyspec_local` once.
  The plugin sends no identity of its own.

## Differences from the Claude Code plugin

| Claude Code | Codex | Notes |
|---|---|---|
| `.claude-plugin/plugin.json` with inline `mcpServers` | `.codex-plugin/plugin.json` + `.mcp.json` | manifest references components by path |
| AGENTS.md shipped in plugin | project-level AGENTS.md | Codex reads the repo's AGENTS.md natively |

## Install

- **Local test**: copy this directory to `~/.codex/plugins/codemyspec/` and
  add a matching entry in `~/.agents/plugins/marketplace.json`
  (`{"source": {"source": "local", "path": ...}}`), or repo-scoped under
  `$REPO_ROOT/plugins/` + `$REPO_ROOT/.agents/plugins/marketplace.json`.
- **From the published repo**:
  `codex plugin marketplace add Code-My-Spec/plugins`, then install
  `codemyspec` from `/plugins`.

The harness runs `vibium` for browser tools. MCP goes to codemyspec.com
directly; point a dev setup elsewhere with `mcp_servers.plugin_codemyspec_local.url`
in `~/.codex/config.toml`.

## Known gaps / verify on first install

1. `mcp__plugin_codemyspec_local__*` tool-name assumption (above).

## Codex Cloud onboarding (manual resumption)

Use **Connect a device → Codex Cloud** in CodeMySpec for the existing Phoenix
project. The connection screen generates the installation script, environment
settings, allowed hosts, and a **Start or resume** prompt for that device.

1. Open a cloud environment with the project's repository and committed
   `mix.exs`, `mix.lock`, and `.tool-versions`. Use x86_64 Linux.
2. Apply the generated environment/network settings and run its installation
   script from the repository root. Keep CMS reachable during agent turns.
3. Paste **Start or resume** into the cloud conversation. Approve the CMS device
   authorization link and code when shown. Credentials stay in the cloud
   environment's private state directory.
4. Wait for conversation readiness, including its agent identity and task tools,
   before asking it to work. Reuse the same conversation and prompt to resume.

The cloud helper's `resume` command restarts the harness if necessary and, when
`CODEX_THREAD_ID` is present, registers the current conversation. The `mcp`
command carries JSON-RPC requests through that registered session. This path
uses the existing cloud helper; installing the desktop plugin is
not a prerequisite. Task evaluation and progress recording must be explicit.

The client manually resumes the chat; automatic wake-up is not configured.
Installation success alone does not mean the harness or conversation is ready.
If the cloud environment loses its private state, rerun its installation and
authorization steps. A different conversation must use its own thread identity.
