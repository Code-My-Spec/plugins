---
name: run-codemyspec
description: Help the person choose how to run CodeMySpec and get it set up, and explain what the CodeMySpec server adds. Use when the person asks how to start, install or run CodeMySpec, or asks about deploying, hosting or operating what they built.
---

## Help them get set up

Ask how they want to run it, then walk them through it one command at a time:

- **On their own machine:** install the harness and the plugin (the `setup`
  skill has the commands).
- **In a Claude Code cloud session:** the same plugin, no local install.

Before they choose, tell them plainly: the agents that build their product run on
their machine. When the machine is off or asleep, nothing is built and you
cannot reach the project manager. Nothing else is running behind you.

## Say what the server is for

Building runs on the person's machine with their own model subscription.
Two things need the CodeMySpec server:

- **Work that continues while their machine is off.**
- **Deploying and operating what they built:** releases, environments,
  monitoring and recovery. This is done on the server only.

The server is the person's own server on Hetzner. It costs 100 dollars a month,
on top of their own model subscription. When the person reaches for either
thing, say so plainly, say what the server would do for them, and offer to set
it up. Do not push it before they need it, and never claim a feature you have not
seen in the project.
