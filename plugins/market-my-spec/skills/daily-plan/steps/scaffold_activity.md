# Scaffold a new activity

Invocation: `/daily-plan add <name>`, e.g. `/daily-plan add elixir-forum-post`.

Creates a real Claude Code skill at `.claude/skills/<name>/SKILL.md` **in the current project** (not user-global) and adds a row to `marketing/activities.md`. The skill is minimum-viable — just enough to be useful on day 1. The user iterates on it later.

## Why project-local, not user-global

Scaffolded activities are project-specific — they're built against this project's strategy, personas, and voice. They don't belong in `~/.claude/skills/`, which would pollute every other project with this one's marketing skills.

Project-local skills:

- Live next to `marketing/` in the same repo
- Get committed alongside the strategy — version-controlled, reviewable, shareable via git
- Stay scoped to where they make sense
- Archive cleanly (local `.claude/skills-archive/`, also committed)

Reserve `~/.claude/skills/` for genuine infrastructure the user installs globally (SEO tools, generic utilities) — typically via plugins.

## Why real skills, not sub-playbooks

(Reminder from the parent `SKILL.md` — keep it in mind here.)

- Skills are the native unit. Composable, shareable, installable.
- Archival = move the directory. Reversible.
- Users can invoke them directly outside of `/daily-plan`.
- No reinventing SKILL.md conventions under a different name.

## Phase 1 — Check the name

Normalize the name from the argument:

- lowercase, hyphens not underscores, no spaces
- strip any leading slash
- singular where reasonable (`/scan-reddit`, not `/scan-reddits`)

Check if a skill with that name already exists, **in priority order**:

1. **Project-local** — `ls .claude/skills/<name>` — if it exists, ask: "`.claude/skills/<name>` already exists in this project. Add to roster without scaffolding, replace it, or pick a different name?"
2. **Project-local archive** — `ls .claude/skills-archive/<name>` — if archived here, ask: "`<name>` is in this project's archive. Restore, or scaffold fresh?"
   - **Restore:** move `.claude/skills-archive/<name>/` back to `.claude/skills/<name>/`, update the existing `activities.md` row to `active`, done.
3. **User-global** — `ls ~/.claude/skills/<name>` — if it exists there, ask: "A user-global skill `/<name>` already exists at `~/.claude/skills/<name>/`. Add that to your roster (it'll work from this project too), or scaffold a project-local one that overrides it?"
4. **Installed plugin skill** — search `~/.claude/plugins/cache/*/*/*/skills/<name>/`. If found: "Plugin skill `/<name>` exists (from plugin `X`). Add that to your roster instead of scaffolding a duplicate?"

Default action on existing-match: use what's there, add it to the roster, don't scaffold. Only scaffold fresh if the user wants different behavior than the existing skill provides.

## Phase 2 — Interview (≤3 questions, asked one at a time)

Pull context from `marketing/08_plan.md`, `marketing/07_channels.md`, and the current activity roster so most of this is inferred, not asked.

Ask only what's actually missing:

1. **"In one sentence, what does this activity produce or accomplish?"**
   - Skip if the name + strategy context make it obvious.
2. **"Cadence — daily, weekly, or as-needed?"**
   - Skip if the strategy already specifies.
3. **"Time budget — how long per run, honestly?"**
   - Always ask. The honest answer is usually longer than the aspirational one.

You probably already know from the strategy:

- Channel (from `07_channels.md`)
- Loop (from the current bottleneck)
- Why it matters (from the strategy's goal math)

Don't re-ask those. Use them.

## Phase 3 — Draft the SKILL.md

Minimum-viable skill. The frontmatter is non-negotiable; the body is a starting point the user will iterate on.

Template:

```markdown
---
name: <name>
description: <one-sentence what-it-does, in the user's voice, with a "use when..." clause so Claude knows when to suggest it>. Part of the marketing daily rotation (channel: <channel>, loop: <loop>).
user-invocable: true
argument-hint: <optional — e.g. "[topic]" or nothing>
---

# <Title>

<One paragraph explaining what this activity ships and why. Concrete, not abstract.>

## Inputs
- <What the user should have ready / what the skill will read>
- <e.g. "A topic or thread to engage with", or "marketing/07_channels.md for tone">

## Process

<Numbered steps. 3-7 steps. Keep it minimum-viable — the user will refine.>

1. Orient — read <what to read>
2. <Core action>
3. <Output / where it goes>

## Output

<What the user ends up with. File path, message draft, artifact, etc.>

## Success signal

<One measurable thing that indicates this run worked. E.g. "At least one substantive comment drafted", "One content gap identified with draft angle".>

## Time budget

~<N> minutes.

## Notes

<Freeform. Leave empty on first scaffold; the user will add learnings over time.>
```

**Drafting guidance:**

- **Fill in what you know from the strategy.** Tone, voice, channel-specific rules (from `07_channels.md`), relevant skills to call out.
- **Don't over-engineer.** No `steps/` subdirectory on first scaffold. If the activity turns out to be complex, the user can split it later.
- **Include one reference to relevant strategy files.** E.g. "See `marketing/07_channels.md` for channel rules." Keeps the skill tied to the source of truth.
- **If the strategy has a playbook file** (e.g. `marketing/research/channel_*.md`, `strategy/*playbook*.md`), reference it instead of duplicating.

## Phase 4 — Write the skill

1. `mkdir -p .claude/skills/<name>` (relative to the project root — the working directory)
2. Write SKILL.md to `<project>/.claude/skills/<name>/SKILL.md` (Write tool needs an absolute path — resolve it from the working directory)

The Write tool requires absolute paths. Resolve the project root from the working directory (usually Claude Code's `cwd`), then build the absolute path as `<cwd>/.claude/skills/<name>/SKILL.md`.

## Phase 5 — Update `marketing/activities.md`

- If the activity was already a `gap` row: update it in place. Change Skill from `(gap)` to `/<name>` and Status from `gap` to `active`.
- If it's new: append a row to the roster. Put `—` in Last used.
- Update the `Updated:` date at the top.

## Phase 6 — Confirm to user

> "Scaffolded `/<name>` at `.claude/skills/<name>/SKILL.md` (project-local — commit it alongside `marketing/` if you want it versioned). Added to roster as active. Restart Claude Code for the slash command to register. Edit the SKILL.md to refine — it's minimum-viable by design."

Show the absolute path explicitly so they can open and iterate.

## Anti-patterns

- **Over-drafting.** The user will rewrite half of it. Ship minimum-viable.
- **Skipping the check for existing skills.** Scaffolding duplicates is worse than asking.
- **Writing multiple files on first scaffold.** One SKILL.md. `steps/` comes later if needed.
- **Hard-coding project paths.** The skill should work across projects — refer to `marketing/` relatively, not with absolute paths.
- **Promising capabilities the skill doesn't have.** The description should be accurate to what the minimum-viable body does.
