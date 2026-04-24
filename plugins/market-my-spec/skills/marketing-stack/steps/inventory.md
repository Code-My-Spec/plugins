# Inventory mode (default `/marketing-stack`)

Show the user what infrastructure is installed, what the strategy calls for, and what's missing. Output a short prioritized to-do.

**Time in user's mouth: under 3 minutes.**

By default, inventory covers the **core tier only** (8 recipes). Use `/marketing-stack --all` to include extensions (9 more).

## Phase 1 — Gather

In parallel, read:

- `marketing/07_channels.md` — which channels are active / middle-ring
- `marketing/04_beachhead.md` — primary bottleneck loop
- `marketing/infrastructure.md` if present — prior blueprint
- `marketing/activities.md` if present — which recipes the roster references
- `~/.claude/plugins/installed_plugins.json` — installed plugins
- `~/.claude.json`, `~/.claude/settings.json`, project `.mcp.json` — registered MCPs
- Project `.env` — env vars present
- All `recipes/*/RECIPE.md` frontmatter — source of truth for detection + validation specs

## Phase 2 — Detect each recipe's state

Use the recipe's own `detection:` frontmatter, not hard-coded heuristics. This keeps detection local to each recipe and avoids inventory.md rotting when a recipe changes.

For each recipe:

1. Read `recipes/<name>/RECIPE.md` frontmatter.
2. Apply its `detection:` block:
   - `type: mcp` — scan all registered MCP commands + args across `~/.claude.json` + `.mcp.json`. Match if any MCP's args array contains any string in `args_contains`. Detection is by command+args pattern, never by MCP key name (users name MCPs whatever they want).
   - `type: env` — check if `env_var` is present in project `.env`.
   - `type: skill` — check if the `skill_path` file exists.
   - `type: derived` — look up the parent recipe (`source_recipe`) state; if that's `ready`, check for the `channel_match` within its output (e.g., postiz `list_channels` returning a facebook entry).
3. If the MCP/env check passes, run the recipe's `validation:` spec to confirm state=`ready`. If validation fails, state=`partial` or `broken` depending on the error:
   - Missing creds / not yet authed → `partial`
   - 401/403/500 → `broken`
4. If detection doesn't match at all, state=`absent`.

**Don't over-ask the user.** Most detection should work without user input. If truly ambiguous (e.g., detection matches but validation wasn't runnable), ask once.

## Phase 3 — Classify each recipe's fit to strategy

For each recipe:

1. Read the recipe's `channel` field + `loop_fit` array.
2. Cross-reference with `07_channels.md`:
   - Recipe's channel is explicitly in active/inner-ring or middle-ring → `fit: required`
   - Recipe's channel is explicitly ruled out → `fit: out-of-scope`
   - Channel not mentioned but `loop_fit` overlaps with current bottleneck loop → `fit: nice-to-have`
   - Neither mentioned nor aligned → `fit: nice-to-have` (default)

## Phase 4 — Present the inventory

Default (core tier only) output:

```
# Marketing stack — <date>

## Strategy signals
- Bottleneck loop: Acquisition
- Inner-ring channels: Reddit, Content (Ghost), SEO
- Middle-ring tests: Elixir Forum, LinkedIn (manual)
- Ruled out (from 07_channels.md): Facebook Ads, TikTok

## Core tier (8 recipes)

| Recipe | State | Fit | Next action |
|---|---|---|---|
| claude-seo | ready | required | — |
| reddit | ready | required | — |
| ghost | partial | required | `/marketing-stack fix ghost` — admin key missing |
| stripe | absent | required | `/marketing-stack install stripe` |
| hubspot | absent | required | `/marketing-stack install hubspot` |
| wordpress | absent | out-of-scope | — |
| wix | absent | out-of-scope | — |
| resend | ready | required | — |

## Extensions (not shown — run `/marketing-stack --all` to see)
```

If `--all`, append an Extensions section with the same table columns.

## Phase 5 — Recommend next action

One sentence naming the highest-leverage unblocker.

Priority order for the "next action" pick:
1. Any `broken` + `required` → "Fix this first, it was working."
2. Any `partial` + `required` → "Finish setup on this."
3. Any `absent` + `required` → install, highest-leverage first (beachhead-loop-aligned).
4. Otherwise "Infrastructure matches strategy."

Example:
> "Next: `/marketing-stack install stripe` — strategy calls for weekly revenue review and that's the only unblockable piece today."

If nothing is missing:
> "Infrastructure matches strategy. Regenerate `marketing/infrastructure.md` with `/marketing-stack blueprint` if it's older than 7 days."

## Phase 6 — Optionally update blueprint

If `marketing/infrastructure.md` is older than 7 days or has drifted from what's observed, offer:
> "Blueprint last updated <date>. Regenerate? (y/n)"

If yes, load `steps/blueprint.md`.

## Anti-patterns

- **Listing recipes without strategy context.** Inventory is always against `07_channels.md`.
- **Hard-coded detection heuristics in this file.** All detection logic lives in the recipe's `detection:` frontmatter; this file only runs the generic matchers.
- **Asking the user what's installed.** Read the configs yourself. Only ask when detection is genuinely ambiguous.
- **Long recommendation lists.** One next action.
- **Running install from inventory mode.** Inventory reports; it does not install. Point at the explicit command.
- **Surfacing all 17 recipes by default.** Core tier only unless `--all`. More context than that creates noise.
