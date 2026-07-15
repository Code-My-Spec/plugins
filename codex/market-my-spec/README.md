# market-my-spec

Use Codex as your marketing strategist, then as your daily operator.

This is the **Codex port** of [`plugins/market-my-spec`](../../plugins/market-my-spec/), which
targets Claude Code. Same frameworks, same 9-step flow, same artifacts — wired for Codex's plugin
system, MCP config, skills discovery, and hooks.

- `/marketing-strategy` — guided 9-step strategy flow (steps 0–8). Interviews you, researches
  personas and competitive alternatives, produces brand foundations, positioning, messaging,
  channels, and a 90-day plan.
- `/marketing-stack` — sets up the marketing infrastructure your strategy calls for (MCP servers,
  API credentials, conventions). Recipe-based, MCP-first, `.env`-only secrets, reversible installs.
  16 recipes covering Reddit, Discord, Slack, Wix, Ghost, WordPress, Stripe, HubSpot, Postiz,
  Meta Ads, Facebook, Instagram, LinkedIn, Twitter/X, YouTube, Resend.
- `/daily-plan` — picks today's 1–3 marketing activities from your strategy, points you at the
  skills that execute them, and keeps your activity roster honest (weekly review, gap detection,
  project-local skill scaffolding, archival of dead activities). Reads `marketing/infrastructure.md`
  to gate activities on recipe readiness.

Industry-agnostic — works for software founders, consultants, trades, services, and B2C operators.

## Install

This repo ships a Codex marketplace at `.agents/plugins/marketplace.json`. From a shell:

```bash
codex plugin marketplace add Code-My-Spec/plugins
codex plugin add market-my-spec@codemyspec
```

Or from a local clone:

```bash
codex plugin marketplace add /path/to/plugins
codex plugin add market-my-spec@codemyspec
```

Verify:

```bash
codex plugin list
```

## The flow

1. **Strategy first** — `/marketing-strategy`. Full 9-step flow on first run; iteration mode on
   later runs. Produces `marketing/00_brand.md` through `marketing/08_plan.md`.
2. **Infrastructure** — `/marketing-stack`. Installs the MCP servers your strategy calls for
   (Reddit, Ghost, Stripe, etc.) into `~/.codex/config.toml`. `.env`-only secrets, reversible
   installs. Writes `marketing/infrastructure.md` — the source of truth for what's wired up.
3. **Daily execution** — `/daily-plan`. Reads strategy + infrastructure + activity roster; picks
   today's 1–3 activities; logs to `marketing/daily/YYYY-MM-DD.md`. Skips activities whose recipes
   aren't `state: ready`.
4. **Weekly re-tune** — `/daily-plan review`. Hit-rate analysis, loop-shift check, roster
   adjustments, infrastructure gap surfacing.
5. **As needed** — `/daily-plan add <name>` to scaffold a new activity as a real skill,
   `/daily-plan archive <name>` to bench an unused one, `/marketing-stack install <recipe>` when a
   new integration goes live, `/marketing-stack fix <recipe>` when one breaks.

## The 9 steps

| # | Step | Mode | Framework anchors |
|---|---|---|---|
| 0 | Brand | Interview | Brand foundations, first-pass visual identity |
| 1 | Current state | Interview | Mom Test (Fitzpatrick), Shape Up appetite/no-gos, Lean Canvas |
| 2 | Jobs & segments | Interview | Moesta Switch Interview, Ulwick Outcome-Driven Innovation |
| 3 | Persona research | Research | Verbatim VOC mining; vertical-specific sources; confidence rubric |
| 4 | Beachhead | Synthesis | Moore's 9-point checklist, Aulet graduation criteria |
| 5 | Positioning | Synthesis + light research | Dunford's 5-component canvas |
| 6 | Messaging | Synthesis | Wiebe / Copyhackers VOC mining; Harry Dry specificity |
| 7 | Channels | Synthesis + light research | Weinberg Bullseye, 24-channel 2026 list |
| 8 | 90-day plan | Synthesis | Shape Up 6-week cycles, Hacking Growth North Star |

## Artifacts

Writes to your project's `marketing/` directory:

```
marketing/
├── 00_brand.md                   ← produced by /marketing-strategy
├── 01_current_state.md
├── 02_jobs_and_segments.md
├── 03_personas.md
├── 04_beachhead.md
├── 05_positioning.md
├── 06_messaging.md
├── 07_channels.md
├── 08_plan.md
├── research/
│   ├── persona_<segment>.md
│   └── alternatives.md
├── infrastructure.md             ← produced by /marketing-stack
├── activities.md                 ← activity roster, managed by /daily-plan
└── daily/
    └── YYYY-MM-DD.md             ← daily logs
```

Activities scaffolded by `/daily-plan add <name>` land in `.codex/skills/<name>/` — project-local,
committed alongside `marketing/`.

## How this differs from the Claude Code plugin

| | Claude Code (`plugins/market-my-spec`) | Codex (`codex/market-my-spec`) |
|---|---|---|
| Manifest | `.claude-plugin/plugin.json` | `.codex-plugin/plugin.json` |
| Marketplace | `.claude-plugin/marketplace.json` | `.agents/plugins/marketplace.json` |
| Install | `/plugin install market-my-spec@codemyspec` | `codex plugin add market-my-spec@codemyspec` |
| MCP config | project `.mcp.json` | `~/.codex/config.toml` → `[mcp_servers.*]` |
| MCP install | `claude mcp add` | `codex mcp add` |
| Project-local skills | `.claude/skills/` | `.codex/skills/` |
| Usage-logging hook | installed into `~/.claude/settings.json` on consent | ships as `hooks.json`, trust-gated by Codex on install |
| Skills | 4 | 3 |

`/marketing-library` is **not** ported. Its entire job was curating Claude Code plugins that ship
marketing playbook skills (marketingskills, claude-seo, anthropic-marketing, digital-marketing-pro)
— none of which exist for Codex. Rather than emit install instructions that dead-end, the Codex port
drops the library layer: `marketing-stack` is the sole writer of `marketing/infrastructure.md`, and
`/daily-plan` gates on recipe readiness alone.

## License

MIT
