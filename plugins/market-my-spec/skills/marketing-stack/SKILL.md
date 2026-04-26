---
name: marketing-stack
description: Set up the marketing infrastructure your strategy calls for — MCPs, API credentials, plugin dependencies, minimal conventions — so the skills you use daily actually have something to run against. Reads marketing/07_channels.md to know which channels matter, then installs recipes per channel (Reddit, Wix, Ghost, WordPress, Stripe, HubSpot, claude-seo, Postiz, Meta Ads, etc.). MCP-first, .env-only secrets, reversible installs, dry-run supported. Use when starting a new project, onboarding a new channel, or re-wiring infrastructure after a strategy shift. Also use to regenerate `marketing/infrastructure.md` — the source of truth for what's wired up.
user-invocable: true
argument-hint: [install <recipe> [--plan] | install-for-channel <channel> [--plan] | fix <recipe> | blueprint | --all]
---

# Marketing Stack

Infrastructure setup for a strategy-owning founder. Sits between `/marketing-strategy` (the plan) and `/daily-plan` (the execution). The strategy tells you what channels matter; this skill wires up the APIs, MCPs, and credentials that make those channels runnable.

## Operating philosophy (load-bearing)

- **MCP-first.** If a good maintained MCP exists for a channel, that's the recipe. Why: cross-client portability (Claude Desktop + Code + Cursor), typed tools beat shell commands, secrets centralize. Direct-API via Bash is a documented fallback for gaps, flagged ⚠️ "Claude Code only."
- **`.env` only for secrets.** Never written into MCP config files, never into `settings.json`, never into recipe templates committed to git.
- **Install in service of strategy, never speculatively.** If `07_channels.md` doesn't mention Facebook, don't install facebook-ads. The strategy is the demand side; this skill is the supply.
- **Reversible.** Every install step has a documented undo. No hidden global state.
- **Credential-aware ordering.** One Google Cloud project covers GSC + GA4 + YouTube. One Meta app covers Facebook + Instagram. Install in the order that reuses credentials instead of re-auth-ing three times.
- **Server-side changes require user consent.** Installing the WordPress MCP adapter on the user's WP site touches their site. Always document + verify, never automate without explicit "yes."

## Modes

| Invocation | Mode | Step file |
|---|---|---|
| `/marketing-stack` | Inventory (core tier only) — what's installed vs what strategy needs | `steps/inventory.md` |
| `/marketing-stack --all` | Inventory (all tiers, including extensions) | `steps/inventory.md` |
| `/marketing-stack install <recipe>` | Guided install for one recipe | `steps/install_recipe.md` |
| `/marketing-stack install <recipe> --plan` | **Dry-run:** show what would happen without changing anything | `steps/install_recipe.md` |
| `/marketing-stack install-for-channel <channel>` | Bundle install: all recipes for a channel + minimal conventions | `steps/install_for_channel.md` |
| `/marketing-stack install-for-channel <channel> --plan` | Dry-run for bundle install | `steps/install_for_channel.md` |
| `/marketing-stack fix <recipe>` | Diagnose a broken/expired install + re-auth | `steps/fix_recipe.md` |
| `/marketing-stack blueprint` | Regenerate `marketing/infrastructure.md` | `steps/blueprint.md` |

**Progressive disclosure.** Do NOT read step files or recipe files upfront. Orient first, then load only what's needed.

## Step 0 — Orient (always, before loading any step file)

Do these in parallel:

1. **Check `marketing/` exists.** If not: "No strategy found. Run `/marketing-strategy` first. (You can still run `/marketing-stack install <recipe>` for a specific recipe without a strategy, but inventory mode needs one.)"
2. **Read `marketing/07_channels.md`** if present — what channels are in the active/middle ring.
3. **Read `marketing/infrastructure.md`** if present — the blueprint from a prior run.
4. **Read `marketing/activities.md`** if present — tells us which recipes are referenced by the roster.
5. **Scan `~/.claude/plugins/installed_plugins.json`** and `~/.claude/skills/` to know what's already installed (claude-seo, marketingskills, etc.).
6. **Check for existing MCP configs** — `~/.claude.json`, `~/.claude/settings.json`, or per-project `.mcp.json` — to see which MCPs are registered.
7. **Parse the argument** to choose mode.

Greet briefly — one sentence confirming mode — and load the matching step file.

## Available recipes

Each recipe lives at `recipes/<name>/RECIPE.md`. First read is on demand, not upfront. When a user says `install <name>` or `install-for-channel <channel>`, load the relevant recipe(s).

Recipes are organized by **tier**:

- **Core (7):** recipes most solo founders will use. Surfaced in default inventory.
- **Extensions (7):** installable on demand but not listed in default inventory unless `--all` is used.

**Core tier:**

| Recipe | Channel(s) | Integration |
|---|---|---|
| `wix` | Wix CMS + CRM + store | Official Wix remote MCP (HTTP transport) |
| `ghost` | Ghost CMS + newsletter + memberships | `@fanyangmeng/ghost-mcp` |
| `wordpress` | WordPress CMS + WooCommerce | `WordPress/mcp-adapter` (server) + `@automattic/mcp-wordpress-remote` (client) |
| `reddit` | Reddit | `reddit-mcp-buddy` (karanb192) |
| `stripe` | Revenue intelligence (read) | Official `stripe/agent-toolkit` MCP |
| `hubspot` | CRM (read + write) | Community MCP + Private App token |
| `resend` | Email broadcast + transactional | ⚠️ Direct REST via Bash (Claude Code only) |

**Extensions (install on demand):**

| Recipe | Channel(s) | Integration |
|---|---|---|
| `postiz` | Social publishing hub (FB, IG, LinkedIn, X, YouTube, Reddit, TikTok, etc.) | Bundled MCP in postiz-app repo; requires deploy |
| `facebook-ads` | Meta Ads (Facebook + Instagram ads) | `brijr/meta-mcp` or `pipeboard-co/meta-ads-mcp` |
| `facebook-publish` | Facebook Page organic publishing | Routes through `postiz` |
| `instagram` | Instagram Business publishing + insights | Routes through `postiz`; Meta Graph direct via facebook-ads' app for insights |
| `linkedin` | LinkedIn personal + Company Page | Routes through `postiz` (direct is ⚠️ Bash-only fallback) |
| `twitter-x` | Twitter/X | Routes through `postiz` (direct is ⚠️ Bash + paid tier) |
| `youtube` | YouTube publishing + research | ⚠️ Data API direct via Bash (Claude Code only) |

**Note on SEO toolkit (claude-seo, GSC, GA4):** These are bundled in the `claude-seo` plugin and managed by `/marketing-library install claude-seo`, not by this skill. The plugin install brings the skills + Python scripts + bundled MCP extensions and handles the GCP service-account setup. `/marketing-library` writes its inventory to the same `marketing/infrastructure.md` file, in a separate "Playbook plugins" section.

## Channel → recipe bundles

When the user runs `install-for-channel <channel>`, install the recipe set below. Also seeds `marketing/conventions/<channel>.md` with minimal channel-specific patterns.

| Channel | Recipes (install order) | Conventions file |
|---|---|---|
| `reddit` | `reddit` | `marketing/conventions/reddit.md` |
| `social` | `postiz` → optional `facebook-ads` | `marketing/conventions/social.md` |
| `seo` | (delegate to `/marketing-library install claude-seo`) | `marketing/conventions/seo.md` |
| `content-wix` | `wix` | `marketing/conventions/content.md` |
| `content-ghost` | `ghost` → optional `resend` | `marketing/conventions/content.md` |
| `content-wordpress` | `wordpress` → optional `resend` | `marketing/conventions/content.md` |
| `email` | `resend` (unless Ghost is primary CMS) | `marketing/conventions/email.md` |
| `revenue` | `stripe` → `hubspot` (install in this order for identity-resolution metadata pattern) | `marketing/conventions/revenue.md` |
| `crm` | `hubspot` | `marketing/conventions/crm.md` |
| `youtube` | `youtube` | `marketing/conventions/youtube.md` |

## Install order (cold-start across the stack)

For a new project with a complete strategy, recommended cold-start order:

1. **SEO + analytics foundation:** `/marketing-library install claude-seo` (managed in the library, not here). The plugin sets up the GCP project + service account + API key that covers GSC + GA4 + YouTube + PageSpeed + CrUX.
2. **Primary CMS (pick one):** `wix` OR `ghost` OR `wordpress`. Warn if more than one, but allow (agencies legitimately run multiple).
3. **Social publishing hub:** `postiz` deploy → local or BYO URL. Once deployed, Postiz holds OAuth for FB/IG/LinkedIn/X/YouTube/Reddit/TikTok publishing.
4. **Meta app (one-time):** only if running Meta Ads OR if postiz deploy isn't happening yet. Covers `facebook-ads` + `instagram` + direct Graph fallback.
5. **CRM + revenue:** `hubspot` Private App token → `stripe` restricted key. **Seed identity-resolution metadata** — `metadata[hubspot_contact_id]` on Stripe Customer objects, `stripe_customer_id` custom contact property in HubSpot. Critical for "which MQLs converted to paid?" queries later.
6. **Email:** skip if Ghost is primary CMS (Ghost handles newsletters natively). Otherwise `resend` for broadcasts + transactional.
7. **Reddit:** `reddit` MCP with tier-3 creds on a dedicated bot account.
8. **YouTube:** only if the strategy includes YouTube (usually no for beachhead phase).

The `inventory` mode surfaces this order dynamically based on which recipes the user's strategy actually calls for.

## Status model

Each recipe has two orthogonal dimensions:

**State** (derived from detection + validation):
- `ready` — MCP registered, creds present, validation passed
- `partial` — MCP registered but creds missing OR validation not yet run
- `broken` — was ready, now failing (expired creds, MCP unreachable)
- `absent` — not installed

**Fit** (derived from strategy):
- `required` — strategy explicitly calls for this channel
- `nice-to-have` — complements the strategy but not explicit
- `out-of-scope` — strategy rules out this channel

The product of the two is what inventory surfaces:
- `absent` + `required` → install next
- `broken` + `required` → fix now
- `partial` + `required` → finish setup
- `ready` + `out-of-scope` → candidate to uninstall (surface, don't act)

## The blueprint file — `marketing/infrastructure.md`

Source of truth for what's wired up. Written and regenerated by the `blueprint` mode.

The blueprint lists each recipe with its tier, state, fit, and a brief notes column. Status summary counts are grouped by the state × fit matrix. See `steps/blueprint.md` for the full template.

## Integration with `/daily-plan`

`/daily-plan` reads `marketing/infrastructure.md` and the per-recipe state when picking activities. An activity whose recipe is `state: ready` is runnable; `partial` or `broken` means daily-plan surfaces "run `/marketing-stack fix <recipe>`" instead of picking the activity.

Activities in `marketing/activities.md` gain an optional **Infrastructure** column listing the recipes they depend on:

| Activity | Skill | Infrastructure | Loop | ... |
|---|---|---|---|---|
| Scan Reddit | `/scan-reddit` | `reddit` | Acquisition |
| Publish weekly post | `/draft-content` → Ghost | `ghost` | Acquisition |
| CRO audit | `/page-cro` → `/seo-page` | `claude-seo`, `ga4` | Activation |

This integration is wired in `/daily-plan`'s `steps/daily.md` (Phase 1.5 — Infrastructure check). The `blueprint` mode here updates `infrastructure.md`; daily-plan reads it.

## Anti-patterns

- **Installing speculatively.** If the strategy doesn't call for a channel, don't install recipes for it. Bloat makes audits harder.
- **Writing secrets to MCP config files.** `.env` only. If a recipe's canonical install wants secrets in config, rewrite the install to use env-var interpolation from `.env`.
- **Skipping verification.** Every install ends with a validation call. "Install complete" without a verified tool call is a lie.
- **Automating server-side changes.** Installing the WP mcp-adapter plugin on the user's WordPress site requires their admin action. Document + verify. Never reach across that boundary.
- **Conflating stack with library.** This skill manages **infrastructure**. Plugin-skill inventory (marketingskills, Anthropic Marketing) belongs to `/marketing-library` (separate skill, later).
- **Promising health monitoring.** Ongoing credential-freshness checks are a separate concern, likely a separate skill. This skill's `fix` mode handles user-initiated "it broke," not continuous monitoring.

## What this skill does NOT do

- Define the strategy — that's `/marketing-strategy`.
- Curate playbook skills / plugins (marketingskills, Anthropic Marketing, etc.) — that's `/marketing-library` (future).
- Execute daily activities — that's `/daily-plan`.
- Run continuous health monitoring — separate concern, likely a future skill.
- Deploy Postiz (or other self-hosted tools) for the user — v1 caps at local docker-compose install OR bring-your-own URL. Hetzner deployment path is a future feature.
- Write content, draft posts, or run campaigns — that's the downstream skill each recipe enables.

---

Based on the argument, load the matching step file now. If no argument, load `steps/inventory.md`.
