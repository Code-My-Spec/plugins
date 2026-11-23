# CodeMySpec

**Scaffolding you own. Not a platform you rent.**

An AI build harness for Phoenix. It gives your coding agent the structure to build
*production* software — an app people actually log into, not a prototype that falls over
at ten users — then gets out of the way. It runs on your machine and drives the Claude
Code you already have. **Free forever.**

- **Your model.** It drives the Claude Code you already run. Bring your own keys — we never proxy, meter, or mark up your requests.
- **Your code.** A standard Phoenix app on your disk. It compiles, tests, and ships without us. Walk away any time, with everything.
- **Your hands on the wheel.** You steer, review, and approve every step. It structures the work; it never takes the wheel and never goes rogue.

It doesn't sit *between* you and the model. It sits *around* it.

Full story → **[codemyspec.com/developers](https://codemyspec.com/developers)**

---

## Install

Add the MCP server, sign in, then ask your agent for what you want built.

### 1 · Install the loop

```sh
brew install code-my-spec/tap/codemyspec
workflow init
brew services start codemyspec
```

`brew install code-my-spec/tap/codemyspec` installs the loop (`workflow`) and the optional
local runner.

### 2 · Install the plugin

In Claude Code:

```
/plugin marketplace add Code-My-Spec/plugins
/plugin install codemyspec@codemyspec
```

The plugin adds the MCP server `https://codemyspec.com/mcp/harness`.

### 3 · First run

Open Claude Code in your Phoenix project and sign in once: run `/mcp`, pick the
`codemyspec` server, and authenticate in the browser. Then ask your agent for what you
want built. The tools are what the server lists: `health`, `start_here`, `tool_docs`,
`run_script`, `ask_manager`, and through `run_script` the project tools.

---

## Why it's free

We make money when your app is *running* — the hosted layer for email on your own domain,
live chat, ads, and analytics that keeps it alive in the world. Not when you build it.
So the build tool is free, your code is yours, and we have every reason to stay out of
your way. On purpose.

## How it works

You write user stories. CodeMySpec builds a dependency graph of what needs to happen,
then walks your agent through it, one reviewable step at a time:

1. **Design** — map stories to bounded contexts and the components that satisfy them
2. **Specify** — turn each component into a spec with acceptance criteria
3. **Test** — generate BDD specs and unit tests from that spec
4. **Implement** — write code that passes the tests
5. **QA** — browser-based checks against your running app

Each step comes with a role-specific prompt and the rules for that component type, so the
agent stays on-rails and the codebase doesn't rot as it grows.

## Requirements

- macOS (Apple Silicon)
- Claude Code CLI
- For your Phoenix project: Elixir 1.18+, Phoenix 1.8+, PostgreSQL

## Managing & updating the loop

`brew services restart codemyspec` to restart; `brew upgrade codemyspec` to update. Logs
at `/opt/homebrew/var/log/codemyspec.log`.

## License

MIT
