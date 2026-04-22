# Weekly review mode

Invocation: `/daily-plan review`.

This is where the daily roster gets re-decided. Daily mode is execution; review is the steering step. Run it weekly (Monday mornings work well) or on-demand when something feels off.

**Time in user's mouth: 15-30 minutes.** Longer than daily, shorter than strategy work.

## What review produces

1. Updated `marketing/activities.md` — some rows change status, some get added, some get archived.
2. Updated or newly-created `marketing/operating_rhythm.md` — narrative snapshot of the current routine.
3. A short decisions summary shown to the user at the end.

## Phase 1 — Gather data

Read in parallel:

- `marketing/activities.md` — current roster
- `marketing/08_plan.md` + `marketing/07_channels.md` — strategy anchors
- Last 7-14 files in `marketing/daily/` — execution record. Use `ls marketing/daily/ | sort -r | head -14`.
- Any analytics / metrics files the user keeps (grep `reports/`, `analytics*`, `knowledge/` in the project)

Then pull skill-usage data:

- If `~/.claude/skill_invocations.jsonl` exists: read the last 30 days. Group by skill, compute: count, first-used-in-window, last-used, frequency.
- If not (hook not installed): fall back to transcript grep:
  ```
  grep -hoE 'skills/[a-z-]+/SKILL\.md' ~/.claude/projects/*/*.jsonl | sort | uniq -c | sort -rn
  ```
  Plus for slash commands:
  ```
  grep -hoE '<command-name>[^<]+</command-name>' ~/.claude/projects/*/*.jsonl | sort | uniq -c | sort -rn
  ```
  Get approximate last-used dates from `.jsonl` file mtimes where those matches occurred. Less precise than the hook but workable.

## Phase 2 — Compute hit rate per activity

For each row in `activities.md`:

- **Hit rate (14d) =** days in last 14 where this activity appeared in a daily file's "Today's activities" section AND the log confirmed completion, ÷ expected run count (14 for daily cadence, 2 for weekly cadence, N/A for as-needed).
- **Last used:** most recent date from the hook log OR the daily file log section.
- **Status recommendation:**
  - Hit rate ≥ 60% → keep `active`
  - Hit rate 30-60% → flag: "intent-execution gap, discuss"
  - Hit rate < 30% over 14 days → recommend `dormant` (benched, not archived)
  - No usage in 30+ days → recommend `archived`

Activities flagged as `gap` (no skill) stay `gap` unless the user scaffolds.

## Phase 3 — Loop-shift check

Explicit version of the daily-mode check. Questions to surface:

- **Is the bottleneck still where strategy says it is?** Compare goal metrics in `08_plan.md` to current reality (from analytics files or user-reported).
- **Did last week produce more signal on the problem we're working, or on a different problem?**
- **Are we shipping to the wrong loop?** E.g., still running acquisition activities when the real leak is activation.

Ask the user, once:

> "Quick check on the bottleneck loop. Strategy says it's [loop] because [reason]. After last week, does that still feel right? (yes / no / unsure)"

If **no** or **unsure**, spend 2-3 minutes discussing before moving on. If the loop really has shifted, this is a big update — the review may include demoting and promoting entire channels. Still, don't rewrite the strategy here — if changes are structural, recommend a full `/marketing-strategy` iteration and stop.

## Phase 4 — Identify gaps and candidates

From the strategy + last 14 days of daily files, look for:

- **Gaps.** Activities the strategy calls for that have no matching skill. These should already be rows with `status: gap`, but check that the roster is complete.
- **Implicit activities.** Things the user has been doing ad-hoc (visible in daily file logs, but not in the roster). Candidates for promotion to the roster.
- **Skill presence without activity.** Skills that show up in the hook log but aren't tied to any roster row. Usually fine — the user was exploring. But flag if a skill has been used 3+ times and isn't on the roster.
- **User-global / plugin skills sitting unused.** From the broader skill-usage data, surface any `~/.claude/skills/<x>` or plugin skill that has zero uses in 30+ days. **Do not propose to archive these** — just report them so the user can decide to uninstall or manually clean up. They're infrastructure, not our scope.

## Phase 5 — Present findings

Show the user a single summary. Keep it scannable. Example:

```
# Weekly review — 2026-04-21

## Bottleneck loop
Still Acquisition (signups/week flat, traffic trending up → acquisition holding, activation next)

## Hit rate, last 14 days
- Scan Reddit          92%  ✓ keep active
- CRO audit            21%  ↓ flag: intent-execution gap
- Content gap scan     14%  ↓ recommend dormant
- SEO audit             0%  ↓ recommend archive (no usage in 32 days)

## Gaps
- Elixir Forum post (Acquisition, weekly) — no skill. Scaffold with `/daily-plan add elixir-forum-post`?

## Proposed changes
- CRO audit: discuss — is 60m the right time budget, or is the skill heavy?
- Content gap scan → dormant
- SEO audit → archived (move skill out of `~/.claude/skills/`)
- Add Elixir Forum post as active-gap

## Skill usage (broader, for awareness — we don't touch these)
- /seo-page: 8 uses
- /seo-technical: 0 uses in 30+ days  ← user-global, you might want to uninstall the plugin
- /scan-reddit: 14 uses
- /marketing-strategy: 1 use
```

## Phase 6 — Apply changes

Go through the proposed changes one at a time with the user. For each:

- **Keep active:** no action.
- **Flag for discussion:** ask one clarifying question, update roster with user's answer.
- **Dormant:** change status in `activities.md` to `dormant`. Don't touch the skill.
- **Archive:** load `steps/archive_activity.md` for that activity (confirms + moves skill + updates roster).
- **Scaffold new:** load `steps/scaffold_activity.md` for that activity.

Batch-apply only when the user says "approve all remaining."

## Phase 7 — Update `operating_rhythm.md`

After changes are applied, write or update `marketing/operating_rhythm.md`:

```markdown
# Operating Rhythm

Updated: YYYY-MM-DD (weekly review)

## Current bottleneck loop
<Loop> — <one-line reason from review>

## Weekly routine
<A short narrative of the current routine. Not a table — prose. Matches 08_plan.md's weekly rhythm section in tone.>

Example:
> This week's rotation is Reddit scan daily (30m each AM), one CRO fix per day (60m), and one Elixir Forum post Tuesday. SEO audits are benched until acquisition loop stabilizes. The fourth thing — long-form writing — is blocked on the Landscape audit finishing; not on the daily roster.

## What we stopped doing (this cycle)
- <bulleted list with one-line reason each>

## What we started doing (this cycle)
- <same>

## Watch for next week
- <1-3 signals that would trigger another review mid-cycle>
```

## Phase 8 — Close

Summarize for the user:

> "Review done. Roster: N active, M dormant, K archived, L gaps. Next daily run picks from N. Next review in 7 days or sooner if [watch signal] hits."

Don't re-paste the whole roster. Point them at `marketing/activities.md` and `marketing/operating_rhythm.md`.

## Anti-patterns

- **Rewriting the strategy in review.** Review updates the roster within the current strategy. If strategy itself is wrong, recommend `/marketing-strategy` iteration and stop.
- **Archiving everything under 50% hit rate.** Hit rate is signal, not sentence. Some weekly activities will show 50% naturally. Use 30%/30-days thresholds, not arbitrary cuts.
- **Skipping the loop-shift check.** It's the whole point of review.
- **Not updating `operating_rhythm.md`.** The roster is the spec; operating_rhythm is the narrative. Both matter.
- **Taking > 30 minutes.** If the review is long, the roster is too big. Prune.
