# Bootstrap — first run

Runs once, when `marketing/activities.md` does not yet exist. Seeds the roster from the strategy and discloses the skill-usage hook that ships with this plugin.

After this step completes, return to the mode the user invoked (daily / review / etc.) and continue.

## What bootstrap produces

1. `marketing/activities.md` — seeded roster, with rows derived from `07_channels.md` and `08_plan.md`.
2. `marketing/daily/` directory (empty).
3. A one-time, plain-language disclosure of the skill-usage hook: what it logs, where it writes, and how to turn it off.

## Step 1 — Seed the roster from strategy

Read:

- `marketing/07_channels.md` — look for the "inner ring", "core", and "middle ring" channels, and the per-channel activity descriptions. Each active/tested channel typically maps to 1-2 activities.
- `marketing/08_plan.md` — look for the "Weekly rhythm" or equivalent section. Each recurring item there is a candidate activity.
- `marketing/03_personas.md` and `04_beachhead.md` (light skim) — to get the bottleneck loop. If the strategy names it explicitly, use that. Otherwise infer from the 90-day goal ("signups" → acquisition; "conversion rate" → activation; "retention" → retention; etc.).

Extract 4-8 activities. Don't try to be exhaustive — the roster is easy to add to later. Prioritize anything the strategy labels as daily or weekly over as-needed.

For each candidate activity:

1. **Check if an installed skill matches.**
   - Look in `~/.codex/skills/` (user-global): `ls ~/.codex/skills/ 2>/dev/null`
   - Look in `~/.codex/plugins/cache/*/*/*/skills/` (plugin-installed)
   - Look in `<project>/.codex/skills/` (project-local)
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

## Step 4 — Disclose the skill-usage hook

There is nothing to install here. The hook ships with this plugin (`hooks.json` at the plugin root, script at `scripts/log_skill_use.sh`) and is wired up by installing the plugin. Codex gates plugin hooks behind **hook trust** — they don't run until the user approves the hook source, so the user is always in the loop before anything executes. Do not offer to edit `~/.codex/config.toml` to install hooks; that is not how Codex plugin hooks work, and telling the user to do it would be a dead end.

What bootstrap owes the user is disclosure, not a consent prompt. Show them, verbatim:

> **This plugin logs skill usage.** A small bash script (`scripts/log_skill_use.sh`, shipped with the plugin) runs on two events and appends one JSON line per skill invocation to `~/.codex/skill_invocations.jsonl`. `/daily-plan review` reads that log to compute hit rates and flag activities that have gone dormant.
>
> - **What's logged:** a UTC timestamp, the skill name, the SKILL.md path, and the working directory — plus, for slash commands, the command name only (e.g. `daily-plan`).
> - **What's not logged:** your prompt text, file contents, tool output, or anything else. The script reads the leading slash command token and discards the rest of the prompt.
> - **Where it goes:** `~/.codex/skill_invocations.jsonl`, on your machine. Nothing is sent anywhere.
> - **Turning it off:** remove the plugin (`codex plugin remove market-my-spec@codemyspec` — the `@<marketplace>` suffix is required), or decline the hook-trust prompt so the hook never runs. Delete `~/.codex/skill_invocations.jsonl` any time to clear history — the log is append-only and safe to delete or truncate.
>
> Without the log, `/daily-plan review` still works — it falls back to grepping session transcripts under `~/.codex/sessions/`, which is coarser but workable.

This is a notice, not a question. Don't block the run waiting for approval, and don't re-show it on later runs — bootstrap only runs once.

**If the user asks why the log is empty:** the most likely reason is that the plugin's hooks haven't been trusted yet in this environment. Codex prompts for hook trust on first use; approving it there is all that's needed. (There is a `--dangerously-bypass-hook-trust` flag intended only for automation that already vets its hook sources — an interactive user should not need it, and you should not recommend it.)

**If the user wants the logging off but the plugin on:** point them at declining hook trust, and note that review will use the transcript fallback. Don't invent a config toggle.

## Step 5 — Hand off

Tell the user: "Roster seeded. <N> activities, <M> marked as gaps. Continuing to [mode]."

Then continue with the mode the user originally invoked (daily / review / etc.).

## Anti-patterns

- **Seeding every possible activity.** 4-8 is plenty. More becomes noise.
- **Guessing aggressively on skill matches.** If uncertain, mark `(gap)` and let the user scaffold or hand-edit.
- **Logging without disclosure.** Codex's hook trust gate means nothing runs unattended, but the user should still hear in plain language what's being written and where. Say it once, on first run.
- **Talking the user into hand-wiring the hook.** It ships with the plugin. Never send them to `~/.codex/config.toml` to install it, and never recommend bypassing hook trust.
- **Forgetting the handoff.** Bootstrap is setup, not the endpoint. Continue to the invoked mode afterward.
