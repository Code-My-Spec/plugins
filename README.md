# CodeMySpec — Claude Code Plugin Marketplace

Specification-driven development plugins for Claude Code, powered by CodeMySpec.

Today this marketplace ships one plugin — `codemyspec` — which turns user
stories into working Phoenix code through a structured workflow: design
architecture, write specifications, generate tests, then implement — all
orchestrated by specialized AI agents that enforce clean architecture and
maintain spec compliance.

## Installation

Add the MCP server, sign in, then ask your agent for what you want built.
The tools are what the server lists (`health`, `start_here`, `tool_docs`,
`run_script`, `ask_manager`, and through `run_script` the project tools).

### 1. Install the loop

```
brew install code-my-spec/tap/codemyspec
workflow init
brew services start codemyspec
```

`brew install code-my-spec/tap/codemyspec` installs the loop (`workflow`)
and the optional local runner.

### 2. Install the plugin

In Claude Code:
```
/plugin marketplace add Code-My-Spec/plugins
/plugin install codemyspec@codemyspec
```

### Google Antigravity

One-liner (installs into `~/.gemini/config/plugins/`, plus the Antigravity
CLI's plugin directory if present):

```
curl -fsSL https://raw.githubusercontent.com/Code-My-Spec/plugins/main/install-antigravity.sh | bash
```

Or manually: the plugin lives under `antigravity/codemyspec/` — with this
repo checked out, `agy plugin install ./antigravity/codemyspec`, or copy
that directory into your workspace's `.agents/plugins/` (workspace-scoped)
or `~/.gemini/config/plugins/` (global). The loop install from step 1 is
required either way.

### OpenAI Codex

The Codex port lives under `codex/codemyspec/`, and this repo doubles as
a Codex plugin marketplace:

```
codex plugin marketplace add Code-My-Spec/plugins
```

Then install `codemyspec` from the `/plugins` picker. The loop install
from step 1 is required.

## Layout

- `.claude-plugin/marketplace.json` — Claude Code marketplace manifest
- `.agents/plugins/marketplace.json` — Codex marketplace catalog
- `plugins/codemyspec/` — the CodeMySpec Claude Code plugin (manifest, MCP
  config)
- `antigravity/codemyspec/` — the Google Antigravity port (rules, MCP
  config)
- `codex/codemyspec/` — the OpenAI Codex port (MCP config)

## Getting Started

Open Claude Code in your Phoenix project directory, sign in to the
`codemyspec` MCP server (https://codemyspec.com/mcp/harness) with `/mcp`,
then ask your agent for what you want built.

### Project Structure

CodeMySpec creates and manages these directories in your Phoenix project:

```
.code_my_spec/
├── rules/              # Design and test rules by component type
├── architecture/       # Technology decisions
├── knowledge/          # Project-specific research
└── issues/             # Known bugs and technical debt
```

## Requirements

- macOS (Apple Silicon)
- Claude Code CLI
- Elixir 1.18+, Phoenix 1.8+, PostgreSQL
- A CodeMySpec account (sign in through the MCP server)

## License

MIT
