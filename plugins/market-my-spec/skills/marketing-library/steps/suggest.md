# Suggest mode (`/marketing-library suggest`)

Strategy-aligned recommendation. Read `07_channels.md` + `04_beachhead.md`, cross-reference each curated plugin's `covers_channels` + `covers_loops`, and surface the top-3 strongest fits not currently installed.

**Time in user's mouth: 1 minute.**

## Phase 1 — Read strategy

- `marketing/07_channels.md` — active/middle/ruled-out channels
- `marketing/04_beachhead.md` — bottleneck loop
- `marketing/02_jobs_and_segments.md` — JTBD context for tone matching
- `marketing/06_messaging.md` — voice signal

## Phase 2 — Score each curated plugin

For each plugin in `plugins/<name>/PLUGIN.md`:

1. **Channel match score:** count overlapping channels between plugin's `covers_channels` and active/middle channels.
2. **Loop match score:** does plugin's `covers_loops` include the current bottleneck loop? (binary: 0 or 1)
3. **Roster gap:** if any activity in `marketing/activities.md` is `status: gap` AND the plugin's skills could fill it, add 1.
4. **Already installed:** if `state: ready`, exclude from suggestions.

Aggregate score: channel_match × 2 + loop_match + roster_gap.

## Phase 3 — Present top 3 not-installed

```
# Library suggestions — <date>

Based on:
- Bottleneck loop: Acquisition
- Inner-ring channels: Reddit, Content, SEO
- Middle-ring tests: Elixir Forum, LinkedIn

## Top suggestions

### 1. marketingskills (score: 8) — `/marketing-library install marketingskills`
- **Why:** covers 6 of your 6 marketing concerns (CRO, copy, SEO, content, growth, email). 40 playbook skills, zero auth setup.
- **Strongest fit:** /copywriting, /cold-email, /page-cro for content + activation work.

### 2. claude-seo (score: 5) — `/marketing-library install claude-seo`
- **Why:** SEO is in your inner ring; this brings GSC + GA4 + technical SEO + content audit + schema in one install.
- **Strongest fit:** /seo-google for weekly GSC + GA4 pulls; /seo-page for landing-page audits.
- **Setup cost:** GCP project + service account + per-property grants (~20 min).

### 3. (no third recommendation — anthropic-marketing requires enterprise MCPs you don't run)

## Already aligned
- (List installed-and-required plugins with one-line "why this matters" each)
```

## Phase 4 — Close

> "Pick 1-2 to install. Run `/marketing-library install <name>` per plugin. After install, regenerate the blueprint with `/marketing-library blueprint`."

## Anti-patterns

- **Suggesting every plugin.** Top 3 max. The point is signal.
- **Suggesting installed plugins.** Already-installed are listed under "Already aligned," not in suggestions.
- **Generic "add this for X" reasoning.** Cite specific channels and loops the plugin covers vs the user's specific strategy. "Why" must reference the strategy file content.
- **Suggesting plugins the user explicitly rejected.** If the user has dismissed a plugin in a prior session (via a marker file or notes in infrastructure.md), respect that.
