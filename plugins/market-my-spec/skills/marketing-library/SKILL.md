---
name: marketing-library
description: Curate the playbook plugins your marketing strategy benefits from — Claude Code plugins that ship marketing-thinking skills (cold-email playbooks, CRO playbooks, SEO frameworks, copywriting, growth strategy). Reads marketing/07_channels.md to pick relevant plugins from a curated set (marketingskills, claude-seo, anthropic Marketing, digital-marketing-pro). MCP-aware install (some plugins bring their own MCPs and config — that's fine; library installs the plugin and its bundled setup, marketing-stack handles standalone MCPs). Writes to marketing/infrastructure.md alongside marketing-stack so daily-plan reads one source of truth. Use when you want to discover new playbook plugins, install a curated one, audit which installed plugin skills are actually being used, or align your library with strategy.
user-invocable: true
argument-hint: [install <plugin> [--plan] | audit | suggest | blueprint | --all]
---

# Marketing Library

Curates the **playbook layer** — Claude Code plugins that ship marketing skills (the "how to think" framing, copywriting playbooks, CRO frameworks, SEO methodologies). Sits next to `/marketing-stack` (which owns the *infrastructure* layer — MCPs, API credentials, standalone integrations).

The split:

| Layer | Skill | What it manages |
|---|---|---|
| Strategy | `/marketing-strategy` | The 90-day plan, positioning, channels |
| **Library (this skill)** | `/marketing-library` | **Playbook plugins** — `/plugin install <thing>` ones that bundle skills (and sometimes their own MCPs and config) |
| Infrastructure | `/marketing-stack` | Standalone MCPs (Reddit, Ghost, Stripe), API creds, `.env` discipline |
| Execution | `/daily-plan` | Today's activities, picked from strategy + active playbooks + ready infra |

## Operating philosophy (load-bearing)

- **A "plugin" is the unit.** If installing it gets you skills + scripts + (optionally) bundled MCPs in one go via `/plugin install`, it's library territory. If it's a single MCP server you wire up via `claude mcp add`, it's stack territory.
- **The plugin owns its own auth.** If a plugin (like claude-seo) has its own credential convention (e.g., `~/.config/claude-seo/google-api.json`), library handles that setup as part of install. We don't try to abstract it into stack's `.env`-only world — that's the plugin author's contract.
- **Curated, not generic.** This skill maintains an opinionated short list. Users can `/plugin install` anything they want directly; the library is a recommendation engine + audit layer for the curated set.
- **Strategy-aligned.** Don't recommend a plugin whose skills don't serve the user's current channels/loops. Curated set lives in `plugins/<name>/PLUGIN.md`; each declares which channels and loops it serves.
- **Audit, don't archive.** Library reports unused plugin skills (no recent invocations, no roster references) so the user can decide. We do not auto-uninstall.

## Modes

| Invocation | Mode | Step file |
|---|---|---|
| `/marketing-library` | Inventory (core tier only) — what plugins are installed vs recommended vs missing | `steps/inventory.md` |
| `/marketing-library --all` | Inventory including extension-tier curated plugins | `steps/inventory.md` |
| `/marketing-library install <plugin>` | Guided install for one curated plugin | `steps/install_plugin.md` |
| `/marketing-library install <plugin> --plan` | **Dry-run:** show what would happen, no changes | `steps/install_plugin.md` |
| `/marketing-library audit` | Which installed plugin skills haven't been used; cross-reference with `marketing/activities.md` | `steps/audit.md` |
| `/marketing-library suggest` | Strategy-aligned plugin recommendations | `steps/suggest.md` |
| `/marketing-library blueprint` | Update the "Playbook plugins" section of `marketing/infrastructure.md` | `steps/blueprint.md` |

**Progressive disclosure.** Don't read step or plugin files upfront. Orient first, then load only what's needed.

## Step 0 — Orient (always, before loading any step file)

In parallel:

1. **Check `marketing/` exists.** If not: "No strategy found. Run `/marketing-strategy` first." (`install <plugin>` works without strategy as an escape hatch.)
2. **Read `marketing/07_channels.md`** if present — channels in active/middle/ruled-out rings.
3. **Read `marketing/04_beachhead.md`** if present — bottleneck loop.
4. **Read `marketing/infrastructure.md`** if present — for the existing "Playbook plugins" section to update.
5. **Read `marketing/activities.md`** if present — to know which plugin skills are referenced by the roster.
6. **Scan `~/.claude/plugins/installed_plugins.json`** — what plugins are installed.
7. **Scan `~/.claude/skills/` and `~/.claude/plugins/cache/*/*/*/skills/`** — which plugin skills are present.
8. **Check skill-usage log** at `~/.claude/skill_invocations.jsonl` (set up by `/daily-plan`'s bootstrap hook). Falls back to transcript grep across `~/.claude/projects/*/*.jsonl` if log missing.
9. **Parse the argument** to choose mode.

Greet briefly, confirm mode, load the matching step file.

## Curated plugins

Each lives at `plugins/<name>/PLUGIN.md` with frontmatter + body sections. First read on demand, not upfront.

**Core (3):**

| Plugin | Author | What it ships | When required |
|---|---|---|---|
| `marketingskills` | coreyhaines31 | 40 marketing playbook skills (CRO, copy, SEO, growth, retention, paid). Zero MCPs — pure playbooks. | Almost always. The thinking-layer default. |
| `claude-seo` | AgriciDaniel | 20 SEO skills + bundled DataForSEO/Firecrawl/nanobanana MCPs + GCP wrapper for GSC/GA4/PageSpeed/CrUX/Indexing/YouTube. | If strategy includes SEO, organic content, or analytics-driven decisions. |
| `anthropic-marketing` | Anthropic (official) | Content/brand/campaign skills with enterprise MCPs (Slack, Canva, Figma, HubSpot, Amplitude, Ahrefs, Klaviyo). | Team users with the matching enterprise stack. Not a default for solo founders. |

**Extensions (1):**

| Plugin | Author | What it ships | When |
|---|---|---|---|
| `digital-marketing-pro` | indranilbanerjee | 115 commands, 25 agents, 67 MCPs, eval/QA layer, multilingual. | Probably over-scale for a solo founder. Listed for completeness. |

## How library writes to `marketing/infrastructure.md`

`marketing/infrastructure.md` is co-owned by `/marketing-stack` and `/marketing-library`. Each writes **only its own section** and never touches the other.

Sections this skill manages:

```markdown
## Playbook plugins (managed by /marketing-library)

| Plugin | Tier | Skills shipped | State | Fit | Last verified | Notes |
|---|---|---|---|---|---|---|
| marketingskills | core | 40 (CRO, copy, SEO, ...) | ready | required | 2026-04-25 | |
| claude-seo | core | 20 (seo, seo-page, seo-google, ...) | ready | required | 2026-04-25 | GCP SA configured |
| anthropic-marketing | core | 7 (draft-content, campaign-plan, ...) | absent | nice-to-have | — | requires enterprise MCPs (Klaviyo, etc.) |
```

`/marketing-stack blueprint` preserves this section verbatim. `/marketing-library blueprint` preserves the stack's recipe sections verbatim. The contract is: each manager owns its section header, never edits the other.

## Status model (same as marketing-stack)

**State** (derived from plugin install detection + skill availability):
- `ready` — plugin installed, skills load, any required auth is configured
- `partial` — plugin installed but auth incomplete (e.g., claude-seo with no GCP config)
- `broken` — plugin installed but skills failing or auth invalidated
- `absent` — plugin not installed

**Fit** (derived from strategy):
- `required` — plugin's covered channels match active/inner-ring channels
- `nice-to-have` — overlaps with current loop or strategy-adjacent
- `out-of-scope` — plugin's channels are ruled out

## Anti-patterns

- **Installing speculatively.** If 07_channels.md doesn't call for SEO, don't install claude-seo. Bloat is the enemy.
- **Auto-uninstalling.** Audit reports unused plugins; user decides.
- **Trying to abstract plugin auth into our `.env` discipline.** Plugins own their auth conventions. Respect them.
- **Re-installing what's already installed.** Inventory detects; install is idempotent if it confirms ready and exits.
- **Touching `/marketing-stack`'s sections of `infrastructure.md`.** Each manager owns its section. Cross-edits are bugs.
- **Suggesting plugins not in the curated list.** Users install whatever they want, but library only recommends from `plugins/<name>/PLUGIN.md`. Adding a plugin to the curated list is a PR, not a runtime decision.

## What this skill does NOT do

- Define the strategy — `/marketing-strategy`.
- Set up standalone MCPs (Reddit, Ghost, Stripe, etc.) — `/marketing-stack`.
- Write content or run campaigns — that's the downstream skills installed plugins enable.
- Auto-uninstall unused plugins — surface, let user decide.
- Manage non-marketing plugins.

---

Based on the argument, load the matching step file. If no argument, load `steps/inventory.md`.
