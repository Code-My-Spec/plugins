# Blueprint mode (`/marketing-library blueprint`)

Write or refresh the **"Playbook plugins" section** of `marketing/infrastructure.md`. Preserves all other sections (`/marketing-stack` owns recipe sections; library only touches its own).

## Phase 1 — Gather

Same as inventory mode Phase 1. Plus: read existing `marketing/infrastructure.md` to preserve non-library sections verbatim.

## Phase 2 — Compute state and fit per curated plugin

Same matchers as inventory.

Preserve `Last verified` and `Notes` from the prior blueprint when state hasn't changed.

## Phase 3 — Optionally batch re-verify `ready` plugins

> "Want to re-verify all `ready` plugins by running their verification specs? (~1 min total; y/n)"

If yes, run each plugin's `verification:` spec. Demote to `broken` on failure.

## Phase 4 — Write the section

The section template:

```markdown
## Playbook plugins (managed by /marketing-library)

Updated: <date>
Source: `/marketing-library blueprint`. Library plugins are Claude Code plugins that ship marketing playbook skills.

| Plugin | Tier | Skills shipped | State | Fit | Last verified | Notes |
|---|---|---|---|---|---|---|
| marketingskills | core | 40 (CRO, copy, SEO, growth, retention, paid) | ready | required | <date> | |
| claude-seo | core | 20 (seo, seo-page, seo-google, seo-content, seo-technical, ...) | ready | required | <date> | GCP SA covers GSC + GA4 + YouTube + PageSpeed + CrUX |
| anthropic-marketing | core | 7 (draft-content, campaign-plan, brand-review, ...) | absent | nice-to-have | — | requires enterprise MCPs (Slack, Klaviyo, Amplitude, Ahrefs) you don't currently run |

(extensions section appears only if any extension-tier plugins are installed)

## Plugin-level credential sharing

| Credential | Plugin | Location |
|---|---|---|
| GCP service account JSON + API key | claude-seo | ~/.config/claude-seo/google-api.json (also reusable by /marketing-stack's youtube recipe) |
```

If the user's infrastructure.md doesn't yet have these sections, insert them in the right place — after `## Recipes (extensions ...)` and before `## Strategy alignment`.

If sections exist, replace the Playbook plugins block; preserve everything else byte-for-byte.

## Phase 5 — Cross-skill coherence check

After writing, parse the file end-to-end and verify:

- `/marketing-stack`'s `## Recipes` sections are intact (we didn't accidentally truncate)
- `## Status matrix` summary at the top still reflects observed reality (it counts both stack recipes AND library plugins by state × fit)
- No duplicate section headers

If any check fails, restore from a backup of the file taken at start of this step.

## Phase 6 — Close

> "Playbook plugins section updated in `marketing/infrastructure.md`. <N> ready, <M> absent. `/daily-plan` reads this when checking which playbook skills are available."

## Anti-patterns

- **Editing recipe sections.** Library never touches stack's content. Bug if it does.
- **Auto-merging conflicts.** If the file has both an old library section AND new library content from this run, merge intentionally. When in doubt, ask.
- **Dropping notes.** User-edited Notes column is preserved across regenerations.
- **Generating when nothing changed.** If observed state matches existing section, tell the user "no changes" and skip the write.
