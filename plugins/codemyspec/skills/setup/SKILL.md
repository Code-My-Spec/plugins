---
name: setup
description: Set up CodeMySpec on this machine - install the loop and the full CodeMySpec plugin. Use when the user wants to start using CodeMySpec, or when CodeMySpec tools say no loop is connected.
---

This listing carries CodeMySpec's MCP tools only. The development loop needs the
loop on this machine and the full plugin from CodeMySpec's own marketplace. Walk
the user through it; they run each command themselves.

1. Install the loop: `brew install code-my-spec/tap/codemyspec` installs the
   loop (`workflow`) and the optional local runner, then `workflow init` and
   `brew services start codemyspec`.
2. Add CodeMySpec's marketplace and install the full plugin, in Claude Code:
   `/plugin marketplace add Code-My-Spec/plugins`, then
   `/plugin install codemyspec@codemyspec`.
3. If this `codemyspec` plugin came from Anthropic's plugin Directory, uninstall
   that copy so the two don't both load.
4. Restart Claude Code in the project folder and sign in when prompted.
