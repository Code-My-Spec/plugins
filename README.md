# CodeMySpec — Claude Code Plugin Marketplace

Specification-driven development plugins for Claude Code, powered by CodeMySpec.

Today this marketplace ships one plugin — `codemyspec` — which turns user
stories into working Phoenix code through a structured workflow: design
architecture, write specifications, generate tests, then implement — all
orchestrated by specialized AI agents that enforce clean architecture and
maintain spec compliance.

## Installation

CodeMySpec is two pieces: the `cms` server, a local background OS service that
hosts the MCP tools and architecture graph, and the Claude Code plugin that
drives it. Install the server first, then the plugin.

### 1. Install the `cms` server

macOS (Apple Silicon):
```
brew install Code-My-Spec/tap/codemyspec
brew services start codemyspec
```

Windows (x64): download `cms-setup-x64.msi` from the latest release and run it,
or from an elevated PowerShell:
```
iwr -useb https://raw.githubusercontent.com/Code-My-Spec/plugins/main/install.ps1 -OutFile install.ps1; .\install.ps1
```

Either installer registers `cms` as a background service (launchd via `brew
services` on macOS, a Shawl-wrapped service via the MSI) listening on
http://localhost:4003, and puts `cms` and `cms-mcp-relay` on your PATH.

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
or `~/.gemini/config/plugins/` (global). The `cms` server install from
step 1 is required either way.

### OpenAI Codex

The Codex port lives under `codex/codemyspec/`, and this repo doubles as
a Codex plugin marketplace:

```
codex plugin marketplace add Code-My-Spec/plugins
```

Then install `codemyspec` from the `/plugins` picker, and trust its hooks
via `/hooks`. The `cms` server install from step 1 is required.

## Layout

- `.claude-plugin/marketplace.json` — Claude Code marketplace manifest
- `.agents/plugins/marketplace.json` — Codex marketplace catalog
- `plugins/codemyspec/` — the CodeMySpec Claude Code plugin (manifest, MCP
  config, hooks)
- `antigravity/codemyspec/` — the Google Antigravity port (skills, agents,
  rules, hooks, MCP config)
- `codex/codemyspec/` — the OpenAI Codex port (skills, hooks, MCP config)

## Getting Started

Open Claude Code in your Phoenix project directory and ask the agent to call
the `get_next_requirement` tool.

## How It Works

CodeMySpec runs a local server (`bin/cms`) that provides:

- **MCP Server** — Exposes architecture tools (component graph, dependency validation,
  story mapping) to Claude Code over HTTP
- **Agent Task API** — Hands the agent one requirement at a time with a
  role-specific prompt
- **Hooks** — Intercepts file writes and test runs for real-time feedback

The extension includes a **knowledge base** with framework guides for Phoenix
LiveView, HEEx, Tailwind/DaisyUI, BDD testing, and clean architecture patterns.
Agents reference these during generation for accurate, idiomatic code.

### Project Structure

CodeMySpec creates and manages these directories in your Phoenix project:

```
.code_my_spec/
├── spec/               # Component specifications (mirrors Elixir namespace)
├── rules/              # Design and test rules by component type
├── architecture/       # Dependency graph, namespace hierarchy, overview
├── status/             # Implementation checklists
├── knowledge/          # Project-specific research
├── plugin_knowledge/   # Framework knowledge (symlink to plugin)
├── design/             # Design system assets
├── issues/             # Known bugs and technical debt
└── qa/                 # QA test results
```

## Requirements

- macOS (Apple Silicon or Intel) or Linux
- Claude Code CLI
- Elixir 1.18+, Phoenix 1.8+, PostgreSQL
- A CodeMySpec account (OAuth login via `cms login`)

## Troubleshooting

### macOS security warning

If macOS blocks the binary, allow it in System Preferences > Security & Privacy.

### Permission denied

```bash
chmod +x bin/cms
```

### Server not running

Hooks require the local server. Start it with:

```bash
bin/cms server
```

## License

MIT
