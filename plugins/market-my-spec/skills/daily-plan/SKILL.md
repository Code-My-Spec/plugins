---
name: daily-plan
description: Pick today's 1-3 marketing activities from your strategy. Reads marketing/08_plan.md, marketing/07_channels.md, your activity roster, and yesterday's log; picks what to ship today; points you at the skills that execute it. Also runs weekly review (hit rate, loop-shift check, archive dead activities) and scaffolds new activities as real skills when there's a gap. Use when you want to know what to work on today, review last week, or add/archive an activity. Requires `/marketing-strategy` to have been run first.
user-invocable: true
argument-hint: [review | add <name> | archive <name> | run <name>]
---

# Daily Plan

Daily marketing operator for a strategy-owning founder. Sits on top of the marketing strategy produced by `/marketing-strategy`. The strategy tells you where to go over 90 days; this skill tells you what to ship today.

## Operating philosophy (load-bearing)

- **Daily = execution.** Strategy shifts belong to weekly/monthly review, not today.
- **WIP limit: 1-3 activities/day.** More = abandoned. Hold the line at 3.
- **Hit rate over 14 days, not streaks.** "Never miss twice" beats "never miss." Streak-based UX collapses on first miss.
- **Work the current bottleneck loop.** When the bottleneck moves (acquisition → activation → retention → monetization), the daily rotation changes. Not the other way around.
- **If signals suggest the bottleneck shifted, stop and recommend `/daily-plan review`.** Do not re-decide strategy in daily mode.
- **Activities are real skills.** Composable, shareable, installable. The roster (`marketing/activities.md`) is the marketing-metadata layer on top — channel, loop, cadence, time budget.
- **Scaffolded activities live project-local** (`.claude/skills/<name>/`), not in `~/.claude/skills/`. They belong with this project's strategy, commit them alongside `marketing/`. User-global skills and plugin skills are infrastructure — we surface their usage in the review report but never scaffold or archive them.

## Modes

| Invocation | Mode | Step file |
|---|---|---|
| `/daily-plan` | Daily pick + log | `steps/daily.md` |
| `/daily-plan review` | Weekly review | `steps/weekly_review.md` |
| `/daily-plan add <name>` | Scaffold new activity as a skill | `steps/scaffold_activity.md` |
| `/daily-plan archive <name>` | Archive an activity | `steps/archive_activity.md` |
| `/daily-plan run <name>` | Ad-hoc: skip pick, run one activity | `steps/daily.md` (skip pick phase) |

**Progressive disclosure.** Do NOT read step files upfront. Orient first, load only the step file that matches the invocation.

## Step 0 — Orient (always, before loading any step file)

Do these in parallel:

1. **Check `marketing/` exists** in the working directory. If not, stop: "No strategy found. Run `/marketing-strategy` first."
2. **Check `marketing/08_plan.md` and `marketing/07_channels.md` exist.** If either is missing, the strategy is incomplete — stop and point at `/marketing-strategy`.
3. **Check `marketing/activities.md` exists.**
   - If yes: read it. It's the roster.
   - If no: first run — after orienting, load `steps/bootstrap.md` *before* the mode-specific step.
4. **Check if the PreToolUse skill-usage hook is installed.** Look in `~/.claude/settings.json` for a hook entry pointing at `~/.claude/hooks/log_skill_use.sh`.
   - If present: fine, skip.
   - If absent: note it. Bootstrap step will offer to install. Don't re-ask if user previously declined (see `~/.claude/market-my-spec/.hook-declined` marker file).
5. **Today's date.** Use the current date from the environment.
6. **Parse the argument** (from `$ARGUMENTS` or user message) to decide which mode to load.

Greet briefly — one sentence confirming mode — and load the matching step file.

## The activity roster (`marketing/activities.md`)

Source of truth for what's currently in rotation. Example:

```markdown
# Active Activities

Updated: 2026-04-21

| Activity | Skill | Channel | Loop | Cadence | Time | Status | Last used |
|---|---|---|---|---|---|---|---|
| Scan Reddit | `/scan-reddit` | Reddit | Acquisition | Daily | 30m | active | 2026-04-20 |
| CRO audit | `/seo-page` | On-site | Conversion | Daily | 60m | active | 2026-04-18 |
| Elixir Forum post | (gap) | Elixir venues | Acquisition | Weekly | 60m | gap | — |
| SEO audit | `/seo-technical` | SEO | Acquisition | Weekly | 45m | dormant | 2026-04-05 |

## Notes

[Freeform notes from last review]
```

**Columns:**

- **Activity** — human name
- **Skill** — slash command that executes it, or `(gap)` if no skill yet
- **Channel** — from `marketing/07_channels.md`
- **Loop** — Acquisition / Activation / Retention / Monetization / Referral
- **Cadence** — Daily / Weekly / As-needed
- **Time** — honest time budget
- **Status** — `active` / `dormant` / `archived` / `gap`
- **Last used** — YYYY-MM-DD of last invocation (from hook log), or `—` if never

The planner owns this file. Users can edit it by hand between runs.

## Daily file format (`marketing/daily/YYYY-MM-DD.md`)

One per day. The plan on top, the log on the bottom, filled in as the day progresses.

```markdown
# 2026-04-21

## Bottleneck loop
[Current loop — from strategy or last review]

## Signal since last session
- [User-reported or observed — max 2-3 bullets]

## Today's activities (WIP: 1-3)
- [ ] [Activity name] — `/skill-to-run` — [time budget] — [one-line why this today]
- [ ] ...

## Log
[Filled in as activities complete — outcomes, what to remember, what to defer]
```

## Operating principles

- **Read before ask.** Strategy, roster, last 3-5 daily files, analytics snapshots if present — all read before any question.
- **One question max in daily mode.** "Any signal since yesterday?" is usually enough.
- **Write the daily file immediately.** Before any activity runs. The file is the plan; the log gets appended.
- **Honor the WIP limit.** 3 max. If there are more candidates, pick the 3 highest-leverage and say "deferring [X] to tomorrow." No silent drops.
- **Don't re-decide strategy in daily mode.** If the user wants to change channel focus, or signals suggest the bottleneck moved, stop and recommend `review`.
- **Archival is reversible.** `archive` moves (`~/.claude/skills-archive/<name>/`), never deletes. Confirm before every archive.
- **Scaffolding is opinionated but minimal.** A new activity = a real SKILL.md in `~/.claude/skills/<name>/` with just enough structure to be useful. Let the user iterate.

## Anti-patterns

- **"Check analytics" as an activity.** Analytics review is the Orient phase, not an activity — no shipping happens from it.
- **Strategy drift in daily mode.** Re-debating channels every morning. That's the review's job.
- **>3 activities.** Attention collapses.
- **Skipping the signal question.** Without the Observe step, the pick is stale.
- **Duplicating a skill as a sub-playbook.** The whole reason we use real skills is composability. Metadata belongs in `activities.md`, not in a duplicate playbook.
- **Treating the daily file as a to-do list.** It's today's committed plan. 3 items. If you want more, use a task tracker.

## What this skill does NOT do

- Decide the 90-day strategy — that's `/marketing-strategy`.
- Generate content (posts, pages, emails) — that's the downstream skill each activity points at.
- Manage non-marketing skills — the audit is marketing-scoped.
- Run analytics dashboards or SEO tools — it reads their outputs.
- Promise outcomes — it commits to shipping, not to results.

---

Based on the argument, load the matching step file now. If this is a first run (no `marketing/activities.md`), load `steps/bootstrap.md` first, then continue to the mode-specific step.
