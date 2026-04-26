# Inventory mode (default `/marketing-library`)

Show the user which curated playbook plugins are installed, which match their strategy, and which are missing. Output a short prioritized to-do.

**Time in user's mouth: under 3 minutes.**

By default, inventory covers **core tier** (3 plugins). `/marketing-library --all` includes extension-tier plugins.

## Phase 1 — Gather

In parallel:

- `marketing/07_channels.md` — channels active vs middle vs ruled-out
- `marketing/04_beachhead.md` — bottleneck loop
- `marketing/infrastructure.md` if present — existing "Playbook plugins" section
- `marketing/activities.md` if present — which plugin skills are referenced by the roster
- `~/.claude/plugins/installed_plugins.json` — installed plugins
- `~/.claude/skills/` and `~/.claude/plugins/cache/*/*/*/skills/` — installed plugin skills
- All `plugins/*/PLUGIN.md` frontmatter — source of truth for each curated plugin's detection + verification

## Phase 2 — Detect each plugin's state

Use the plugin's own `detection:` frontmatter. Don't hard-code per-plugin checks here.

For each curated plugin:

1. Read `plugins/<name>/PLUGIN.md` frontmatter.
2. Apply its `detection:` block:
   - `type: plugin` — match `installed_plugins_match` against entries in `~/.claude/plugins/installed_plugins.json`. Match if any installed plugin's name OR source slug matches any string in the list.
   - `type: skill_present` — check if the named skill file exists at the listed path (supports glob: `~/.claude/skills/<name>/SKILL.md` or `~/.claude/plugins/cache/*/<plugin>/*/skills/<skill>/SKILL.md`).
3. If detection matches, run the plugin's `verification:` spec to confirm `state: ready`. If verification fails:
   - Plugin installed but auth missing (e.g., claude-seo with no GCP config) → `partial`
   - Plugin installed but verification call fails → `broken`
4. If detection doesn't match → `absent`.

## Phase 3 — Classify each plugin's fit to strategy

For each plugin, read its `covers_channels` and `covers_loops` fields, then cross-reference with strategy:

- Plugin's covered channels overlap with active/inner-ring channels → `fit: required`
- Plugin's covered channels overlap with middle-ring tests → `fit: nice-to-have`
- Plugin's covered channels are explicitly ruled out → `fit: out-of-scope`
- No overlap → `fit: nice-to-have` (default)

For plugins like `marketingskills` that cover broad categories (CRO, copy, growth) which apply to nearly every strategy, default to `fit: required` unless strategy is explicitly minimalist.

## Phase 4 — Present the inventory

Default (core tier) output:

```
# Marketing library — <date>

## Strategy signals
- Bottleneck loop: Acquisition
- Inner-ring channels: Reddit, Content (Ghost), SEO
- Middle-ring tests: Elixir Forum, LinkedIn (manual)
- Ruled out: Facebook Ads, TikTok

## Core tier (3 plugins)

| Plugin | State | Fit | Next action |
|---|---|---|---|
| marketingskills | absent | required | `/marketing-library install marketingskills` |
| claude-seo | ready | required | — |
| anthropic-marketing | absent | nice-to-have | (skip; needs enterprise MCPs you don't run) |

## Extensions (not shown — run `/marketing-library --all` to see)
```

If `--all`, append an Extensions section with the same column structure.

## Phase 5 — Recommend next action

One sentence. Priority order:
1. Any `broken` + `required` → "Fix this first."
2. Any `partial` + `required` → "Finish setup."
3. Any `absent` + `required` → install, highest-leverage first (cover-channel-aligned with bottleneck loop).
4. Otherwise: "Library matches strategy."

Examples:
> "Next: `/marketing-library install marketingskills` — covers your inner-ring (CRO + copy) and is the most-referenced plugin in the daily-plan ecosystem."

> "Library matches strategy. Run `/marketing-library audit` if you want a usage report on what's actually being used."

## Phase 6 — Optionally update blueprint

If `marketing/infrastructure.md` is older than 7 days OR the "Playbook plugins" section is missing/stale, offer:
> "Playbook plugins section last updated <date>. Regenerate? (y/n)"

If yes, load `steps/blueprint.md`.

## Anti-patterns

- **Listing plugins without strategy context.** Inventory is always against `07_channels.md`.
- **Hard-coded detection in this file.** Detection lives in PLUGIN.md frontmatter.
- **Asking the user what's installed.** Read configs yourself.
- **Long recommendation lists.** One next action.
- **Running install from inventory mode.** Inventory reports; explicit `install` command does the install.
- **Surfacing all curated plugins by default.** Core tier only unless `--all`.
