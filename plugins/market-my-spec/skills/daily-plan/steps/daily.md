# Daily mode

Default invocation: `/daily-plan`. Also handles `/daily-plan run <name>` (skip pick phase).

The flow is OODA: **Observe → Orient → Decide → Act**. Orient is handled in Step 0 of `SKILL.md`; this file covers Observe, Decide, and Act.

**Total time in the user's mouth: under 3 minutes.** If the interview runs long, cut questions.

## Phase 1 — Observe (≤1 question)

Before asking, read:

- `marketing/activities.md` — current roster with status and last-used dates
- `marketing/08_plan.md` — specifically the current week/cycle section
- `marketing/infrastructure.md` if present — recipe state per `/marketing-stack`
- Last 3 files in `marketing/daily/` (use `ls marketing/daily/ | sort -r | head -3`)
- Any analytics artifacts in the project (e.g. `reports/`, `knowledge/analytics*`) — use Glob to find them

From these, you should already know:

- Current bottleneck loop
- What was attempted yesterday and whether it completed
- Any deferred activities from prior days
- Cadence-due activities (daily ones always due; weekly ones due if not run in 7 days)
- Which activities are **infrastructure-runnable** vs blocked (see Phase 1.5)

Then ask **one** signal question. Pick the most useful of these based on what's missing from the files:

- "Anything happen since yesterday I should know about? New signal, blocker, user message, metric move?"
- "Yesterday you deferred [X]. Still want it in today's rotation?" (if applicable)
- "How did [yesterday's activity] go? Want to log the outcome?" (if yesterday's log is empty)

Wait for the answer. Don't pile on questions.

## Phase 1.5 — Infrastructure check

If `marketing/infrastructure.md` exists, build a runnable-set from BOTH sections:

1. Parse the **`## Recipes`** sections (managed by `/marketing-stack`). For each recipe row, extract its `state` column (`ready` | `partial` | `broken` | `absent`).
2. Parse the **`## Playbook plugins`** section (managed by `/marketing-library`). For each plugin row, extract its `state`.
3. Parse `marketing/activities.md`. For each activity, check its Infrastructure column (if present). The activity is **runnable** iff every listed recipe AND plugin in the column is `state: ready`.
4. Build the lookup: `{activity_name → runnable: bool, blocking: [{name, kind, state}]}`. `kind` is `recipe` or `plugin`.

If `marketing/infrastructure.md` does NOT exist: skip Phase 1.5. All activities are treated as runnable (legacy behavior, same as pre-integration). Note in the daily file: "Infrastructure unknown (no `marketing/infrastructure.md`) — run `/marketing-stack blueprint` and `/marketing-library blueprint` to enable gating."

## Phase 2 — Loop-shift check

Before picking, scan for signals that the bottleneck loop has moved:

- User reports a metric that contradicts the current loop focus (e.g. loop = acquisition, but they mention signups are flat AND site traffic is high — activation is the real bottleneck now)
- User reports sustained failure on the current loop's activities (2+ weeks of dormant status)
- User explicitly asks to change focus

**If any of these trigger:** stop. Do not proceed to Decide. Say:

> "Heads up — signal suggests the bottleneck loop may have shifted (<one-line reason>). Daily mode doesn't re-decide strategy. Recommend running `/daily-plan review` to re-examine the roster before picking today. Want to do that now, or push through with today's pick as-is?"

If they push through, note it in the daily file and continue. If they switch to review, load `steps/weekly_review.md`.

## Phase 3 — Decide (pick 1-3 activities)

**Ranking order:**

1. **Cadence-overdue daily activities.** If a `Daily` activity hasn't been run in 2+ days, it jumps to the top.
2. **Cadence-due weekly activities.** If a `Weekly` activity hasn't been run in 7+ days, and it's aligned with the current loop, include it.
3. **Current loop alignment.** Between two candidates, pick the one in the current bottleneck loop.
4. **User priority.** If the signal question surfaced an obvious priority, honor it.
5. **Time fit.** Sum of time budgets ≤ the user's stated weekly marketing time ÷ 5 (roughly). If the user has 5 hrs/week, a day's rotation should fit in ~1 hour.

**Hard rules:**

- **Max 3 activities.** If you can't narrow down, ask the user to break the tie.
- **Skip `gap` and `archived` activities.** A gap can't be picked — if a gap activity is the only one due, surface it: "Today's clear choice is [activity] but it's a gap. Want to scaffold it now with `/daily-plan add <name>`?"
- **Skip `dormant` activities unless the user explicitly wants to revive one.** Dormant = intentionally benched.
- **Skip infrastructure-blocked activities.** If Phase 1.5 flagged an activity as not-runnable, surface it but don't pick it:
  > "Today's clear choice is [activity] but [name] (kind: <recipe|plugin>) is `state: <state>`. Run `/marketing-stack fix <recipe>` (or `/marketing-library install <plugin>`) first, or pick the next-highest activity."
  If ALL top candidates are infrastructure-blocked, recommend the appropriate fix/install path for the most-blocking item before doing anything else today.

**Ad-hoc mode (`/daily-plan run <name>`):**

If the argument is `run <name>`, skip Phase 1-3. Go straight to Phase 4 with the single named activity. If the name doesn't match an `active` row in `activities.md`, ask: "[name] is not active (status: <status>). Run it anyway?"

## Phase 4 — Write the daily file

Write `marketing/daily/YYYY-MM-DD.md`. Template:

```markdown
# YYYY-MM-DD

## Bottleneck loop
<Loop name> — <one-line from strategy or last review>

## Signal since last session
- <from the Observe question>

## Today's activities (WIP: N of 3)
- [ ] **<Activity>** — `<skill>` — <time>m — <one-line why today>
- [ ] ...

## Deferred
- <anything that was in the running but not picked — one line each, so tomorrow can see it>

## Log
_Fill in as activities complete._
```

**Immediately after writing**, tell the user the plan in 2-3 sentences:

> "Today's pick: [activity 1] (`/skill1`, 30m), [activity 2] (`/skill2`, 45m). Both in the acquisition loop. Want me to kick off [activity 1] now, or are you driving?"

## Phase 5 — Act (optional)

If the user wants you to drive, invoke the first activity's skill directly. The skill will take over.

If the user wants to drive themselves, exit. They'll run the skills and come back later to log outcomes — which they can do by editing the daily file or running `/daily-plan` again tomorrow.

## Logging outcomes

If the user returns same-day (another `/daily-plan` invocation), offer to log completed activities in the existing daily file before producing tomorrow's pick. This is how hit rate stays honest.

## Anti-patterns

- **Running the interview before reading.** Always read the files first. Half the signal questions become unnecessary.
- **Ignoring cadence.** If `Daily` activities keep getting skipped, the roster is lying. Flag at review.
- **Pushing through loop-shift signals.** Don't do today's pick if the strategy is wrong. Force the review.
- **Writing >3 activities because "they're all small."** They're not. Hold the line.
- **Logging speculative outcomes.** Only log what the user confirms or what you can verify from tool output.
