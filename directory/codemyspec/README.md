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

Two pieces: a local **`cms` server** (a background process that hosts the tools) and the
**Claude Code plugin** that drives it. Server first, then plugin — about five minutes.

### 1 · Install the server

**macOS (Apple Silicon):**

```sh
brew install Code-My-Spec/tap/codemyspec
brew services start codemyspec
```

**Windows (x64):** download `cms-setup-x64.msi` from the
[latest release](https://github.com/Code-My-Spec/plugins/releases) and run it, or from an
elevated PowerShell:

```powershell
iwr -useb https://raw.githubusercontent.com/Code-My-Spec/plugins/main/install.ps1 -OutFile install.ps1; .\install.ps1
```

Either installer registers `cms` as a background service listening on
`http://localhost:4003`, and puts `cms` and `cms-mcp-relay` on your `PATH`. It starts on
install and restarts on boot. The plugin only talks to it — it never launches or
downloads it.

The lifecycle hooks post to the harness at `http://127.0.0.1:4003`.

### 2 · Install the plugin

In Claude Code:

```
/plugin marketplace add Code-My-Spec/plugins
/plugin install codemyspec@codemyspec
```

### 3 · First run

Open Claude Code in your Phoenix project and sign in once: run `/mcp`, pick the
`codemyspec` server, and authenticate in the browser.

Then tell the agent to use the `get_next_requirement` tool. **That's the only command you
need to remember** — every time the agent doesn't know what to do next, the answer is the
same: `get_next_requirement`. It walks you through linking the project, syncing
components, and handing off the next unit of work.

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

Each step comes with a role-specific prompt and the rules for that component type. The
local server tracks the architecture graph, validates dependencies, and serves the next
actionable requirement — so the agent stays on-rails and the codebase doesn't rot as it
grows.

## Requirements

- macOS (Apple Silicon) or Windows (x64)
- Claude Code CLI
- For your Phoenix project: Elixir 1.18+, Phoenix 1.8+, PostgreSQL

## Managing & updating the server

- **macOS:** `brew services restart codemyspec` to restart; `brew upgrade codemyspec` to
  update. Logs at `/opt/homebrew/var/log/codemyspec.log`.
- **Windows:** `Restart-Service CodeMySpec` to restart; re-run the MSI (or `install.ps1`)
  to update in place, `.\install.ps1 -Uninstall` to remove. Data and logs live under
  `C:\ProgramData\CodeMySpec`.

## License

MIT
