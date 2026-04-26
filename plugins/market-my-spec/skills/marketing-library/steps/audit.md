# Audit mode (`/marketing-library audit`)

Surface installed plugin skills that aren't being used, so the user can decide whether to keep, archive, or uninstall. **Reports only — never auto-uninstalls.**

**Time in user's mouth: 5 minutes.**

## Phase 1 — Gather

- All installed plugins from `~/.claude/plugins/installed_plugins.json`
- All installed plugin skills (walk `~/.claude/plugins/cache/*/*/*/skills/*/SKILL.md`)
- Skill-usage data:
  - Primary: `~/.claude/skill_invocations.jsonl` (set up by `/daily-plan`'s bootstrap hook)
  - Fallback: grep `~/.claude/projects/*/*.jsonl` for `<command-name>...` and SKILL.md reads
- `marketing/activities.md` — which plugin skills the roster references explicitly

## Phase 2 — Compute usage per skill

For each plugin skill:

- **Used in last 30 days:** count of invocations or SKILL.md reads in the usage log
- **Last used:** most recent date
- **In activities.md roster:** boolean — does any activity row reference this skill?

## Phase 3 — Classify each skill

| Class | Definition | Recommendation |
|---|---|---|
| `active` | Used 3+ times in last 30 days OR referenced in roster | Keep |
| `dormant` | Used 1-2 times in last 30 days, not in roster | Watch — may be exploring |
| `unused-30d` | Zero invocations in last 30 days, not in roster | Audit candidate |
| `unused-90d` | Zero invocations in last 90 days, not in roster | Strong archive/uninstall candidate |

## Phase 4 — Present the report

Group by plugin:

```
# Library audit — <date>

Hook log: ~/.claude/skill_invocations.jsonl (5,234 entries since 2026-01-15)
Fallback transcript scan: 14 transcripts grepped

## marketingskills (40 skills)
- Active (5): /copywriting, /cold-email, /page-cro, /email-sequence, /churn-prevention
- Dormant (3): /referral-program, /lead-magnets, /aso-audit
- Unused 30d (32): /paid-ads, /ad-creative, /pricing-strategy, /sales-enablement, ...
  Recommendation: keep installed (zero auth cost, low marginal disk), but consider /plugin disable individual unused ones if the slash-command palette feels crowded.

## claude-seo (20 skills)
- Active (4): /seo-page, /seo-technical, /seo-content, /seo-google
- Dormant (1): /seo-audit
- Unused 30d (15): /seo-local, /seo-maps, /seo-hreflang, ...
  Recommendation: keep — these are situationally valuable (e.g., /seo-local matters when a local-business client engages).

## anthropic-marketing (7 skills)
Not installed — see /marketing-library install.
```

## Phase 5 — Recommendations

After the per-plugin breakdown, summarize at the bottom:

```
## Plugin-level recommendations

- marketingskills: keep installed. 5/40 skills active is normal — playbook libraries are reference material, not daily drivers.
- claude-seo: keep installed. Core skills (seo-page, seo-google) are doing real work weekly.
- (any plugin with all skills unused-90d) → "uninstall candidate. Run `/plugin uninstall <plugin>` if you're sure."

## Roster-vs-installed gaps
- /marketing-library suggests adding /copywriting to marketing/activities.md as a "weekly newsletter draft" activity (used 8 times in the last 14 days, not in roster).
```

## Phase 6 — Close

> "Audit complete. <N> active, <M> dormant, <K> unused-30d, <L> unused-90d across <P> plugins. No changes made — recommendations above. Re-run after a strategy shift to re-baseline."

## Anti-patterns

- **Auto-uninstalling.** Audit reports; user decides.
- **Treating low usage as failure.** Playbook libraries are reference material — 5/40 active is healthy.
- **Ignoring the roster.** A skill used zero times that's in `marketing/activities.md` is not unused — the user committed to it; usage hasn't materialized yet (a different problem, surface in `/daily-plan review`).
- **Reporting without timeframes.** Always say "last 30d" / "last 90d." "Unused" without a window is meaningless.
