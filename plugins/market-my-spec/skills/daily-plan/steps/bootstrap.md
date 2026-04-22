# Bootstrap — first run

Runs once, when `marketing/activities.md` does not yet exist. Seeds the roster from the strategy and offers to install the PreToolUse hook for skill-usage tracking.

After this step completes, return to the mode the user invoked (daily / review / etc.) and continue.

## What bootstrap produces

1. `marketing/activities.md` — seeded roster, with rows derived from `07_channels.md` and `08_plan.md`.
2. `marketing/daily/` directory (empty).
3. (Optional, user-consented) PreToolUse hook installed at `~/.claude/hooks/log_skill_use.sh` with entries in `~/.claude/settings.json` so future skill invocations are logged.

## Step 1 — Seed the roster from strategy

Read:

- `marketing/07_channels.md` — look for the "inner ring", "core", and "middle ring" channels, and the per-channel activity descriptions. Each active/tested channel typically maps to 1-2 activities.
- `marketing/08_plan.md` — look for the "Weekly rhythm" or equivalent section. Each recurring item there is a candidate activity.
- `marketing/03_personas.md` and `04_beachhead.md` (light skim) — to get the bottleneck loop. If the strategy names it explicitly, use that. Otherwise infer from the 90-day goal ("signups" → acquisition; "conversion rate" → activation; "retention" → retention; etc.).

Extract 4-8 activities. Don't try to be exhaustive — the roster is easy to add to later. Prioritize anything the strategy labels as daily or weekly over as-needed.

For each candidate activity:

1. **Check if an installed skill matches.**
   - Look in `~/.claude/skills/` (user-global): `ls ~/.claude/skills/ 2>/dev/null`
   - Look in `~/.claude/plugins/cache/*/*/*/skills/` (plugin-installed)
   - Look in `<project>/.claude/skills/` (project-local)
   - Match by name similarity and description. For example "Scan Reddit" might match `/scan-reddit` or `/reddit-scan`. Be loose — when in doubt, ask.
2. **If a skill matches**, use its slash command in the Skill column.
3. **If no skill matches**, mark `(gap)` in the Skill column and `gap` in the Status column. The user can later scaffold with `/daily-plan add <name>`.

## Step 2 — Write `marketing/activities.md`

Template:

```markdown
# Active Activities

Updated: <today's date>

Source: seeded from `07_channels.md` and `08_plan.md` on <today's date>.

## Current bottleneck loop
<Acquisition | Activation | Retention | Monetization | Referral> — <one-line reason from strategy>

## Roster

| Activity | Skill | Channel | Loop | Cadence | Time | Status | Last used |
|---|---|---|---|---|---|---|---|
| <row per activity> |

## Notes

_First run: roster seeded from strategy. Review in a week; prune what isn't sticking._
```

**Populate each row** with your best guess, clearly labeled as seeded. The user will correct on first run or at first review.

**Status on first run:**
- `active` if the strategy explicitly calls it a daily/weekly activity AND a matching skill exists.
- `gap` if the strategy calls for it but no skill exists.
- `dormant` if the strategy lists it as optional or "maintain" rather than "grow."

## Step 3 — Create daily directory

```
mkdir -p marketing/daily
```

(Use the Bash tool.)

## Step 4 — Offer the hook install

Show the user, verbatim:

> **Optional: install the skill-usage hook.** A tiny bash script at `~/.claude/hooks/log_skill_use.sh` that logs every skill invocation to `~/.claude/skill_invocations.jsonl`. Used by `/daily-plan review` to compute hit rates and flag dormant skills. Reversible — edits `~/.claude/settings.json` and can be removed any time. Install? (yes / no / remind me later)

**If yes:**

1. Locate the hook script in the plugin install dir. On a plugin install it'll be at something like `~/.claude/plugins/cache/codemyspec/market-my-spec/<version>/skills/daily-plan/hooks/log_skill_use.sh`. Find it with:
   ```
   ls ~/.claude/plugins/cache/*/market-my-spec/*/skills/daily-plan/hooks/log_skill_use.sh 2>/dev/null | head -1
   ```
   (If running the plugin from a local dev path, resolve relative to this skill's own directory.)
2. Copy it to a stable location: `~/.claude/hooks/log_skill_use.sh`. The copy matters — plugin versions change, and you don't want the settings.json hook path to go stale after an update. Make it executable: `chmod +x ~/.claude/hooks/log_skill_use.sh`.
3. Read `~/.claude/settings.json` (create an empty `{}` if it doesn't exist).
4. Add two hook entries:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Read",
        "hooks": [
          { "type": "command", "command": "$HOME/.claude/hooks/log_skill_use.sh" }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          { "type": "command", "command": "$HOME/.claude/hooks/log_skill_use.sh" }
        ]
      }
    ]
  }
}
```

Merge carefully — don't clobber existing hooks. If the user already has `PreToolUse` or `UserPromptSubmit` entries, append to the arrays rather than replacing.

5. Tell the user: "Hook installed. Skill uses will be logged to `~/.claude/skill_invocations.jsonl` going forward. Restart the Claude Code session for the hook to take effect."

**If no:**

Write a marker file `~/.claude/market-my-spec/.hook-declined` (create parent dir as needed). Future runs check for this and skip the offer. The weekly review will fall back to transcript-grepping `~/.claude/projects/*/*.jsonl` for usage data — slightly noisier, still works.

**If "remind me later":**

Don't write the marker. Skip the install this run. Offer again on next first-of-week `review`.

## Step 5 — Hand off

Tell the user: "Roster seeded. <N> activities, <M> marked as gaps. Continuing to [mode]."

Then continue with the mode the user originally invoked (daily / review / etc.).

## Anti-patterns

- **Seeding every possible activity.** 4-8 is plenty. More becomes noise.
- **Guessing aggressively on skill matches.** If uncertain, mark `(gap)` and let the user scaffold or hand-edit.
- **Installing hooks without consent.** Always ask. The hook touches user settings.
- **Forgetting the handoff.** Bootstrap is setup, not the endpoint. Continue to the invoked mode afterward.
