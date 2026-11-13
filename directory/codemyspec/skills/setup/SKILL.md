---
name: setup
description: Set up CodeMySpec on this machine - install the cms harness and the full CodeMySpec plugin. Use when the user wants to start using CodeMySpec, or when CodeMySpec tools say the harness is not connected.
---

This listing carries CodeMySpec's MCP tools only. The development loop (stop-hook
evaluation, test runs through the harness, the agent's briefing) needs the `cms`
harness and the full plugin from CodeMySpec's own marketplace. Walk the user
through it; they run each command themselves.

1. Install the harness:
   - macOS: `brew install Code-My-Spec/tap/codemyspec`
   - Windows: download `cms-setup-x64.msi` from
     https://github.com/Code-My-Spec/plugins/releases/latest and run it.
2. Add CodeMySpec's marketplace and install the full plugin, in Claude Code:
   `/plugin marketplace add Code-My-Spec/plugins`, then
   `/plugin install codemyspec@codemyspec`.
3. Uninstall this Directory listing's `codemyspec` plugin so the two don't both load.
4. Restart Claude Code in the project folder and sign in when prompted.
