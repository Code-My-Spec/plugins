# CodeMySpec — Antigravity Plugin

Google Antigravity port of the CodeMySpec plugin (the Claude Code original
lives in `../claude/`). Specification-driven development for Phoenix
applications: design architecture, write specs, generate tests, and implement
with specialized AI agents.

## Layout (Antigravity plugin format)

```
codemyspec/
├── plugin.json        # manifest (schema allows name + description only)
├── mcp_config.json    # MCP server https://codemyspec.com/mcp/harness
└── rules/codemyspec.md      # AGENTS.md content as an always-available rule
```

## Install

- **Workspace**: copy this directory to `<workspace>/.agents/plugins/codemyspec/`
- **Global (IDE / Antigravity 2.0)**: `~/.gemini/config/plugins/codemyspec/`
- **CLI**: `agy plugin install /path/to/codemyspec` (stages into
  `~/.gemini/antigravity-cli/plugins/`)

Add the MCP server, sign in, then ask your agent for what you want built. The
tools are what the server lists (`health`, `start_here`, `tool_docs`,
`run_script`, `ask_manager`, and through `run_script` the project tools).
`brew install code-my-spec/tap/codemyspec` installs the loop (`workflow`) and
the optional local runner, then `workflow init` and
`brew services start codemyspec`.

## Port mapping (Claude Code → Antigravity)

| Claude Code | Antigravity | Notes |
|---|---|---|
| `.claude-plugin/plugin.json` (mcpServers inline) | `plugin.json` + `mcp_config.json` | AG manifest is name+description only (`additionalProperties: false`) |

## Open questions / assumptions to verify

1. **`_agents/plugins/`** is also scanned at workspace level (alt prefix).
