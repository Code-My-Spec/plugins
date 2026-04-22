# Archive an activity

Invocation: `/daily-plan archive <name>`, e.g. `/daily-plan archive seo-audit`.

Also invoked as a sub-step from `steps/weekly_review.md` when the review recommends archival.

**Archival is reversible.** We move the skill directory; we never delete. The roster keeps the row (marked `archived`) so the history survives.

**Scope: we only archive skills we could have scaffolded.** That means project-local skills under `.claude/skills/<name>/`. User-global skills and plugin skills are infrastructure — we surface their non-use in the review report but don't touch them. If the user wants to remove a user-global or plugin skill, they do it manually or via `/plugin uninstall`.

## Phase 1 — Locate the target

Given `<name>`, check project-local first:

1. `.claude/skills/<name>/` — project-local skill. Our target.
2. If not there, check `~/.claude/skills/<name>/` (user-global). If found, **do not archive** — tell the user:

   > "`/<name>` is a user-global skill at `~/.claude/skills/<name>/`, not project-local. `/daily-plan archive` only handles project-local skills — user-global skills are infrastructure you installed intentionally. To remove it, do it manually (`mv ~/.claude/skills/<name> ~/.claude/skills-archive/<name>`) or ignore if it's fine sitting idle. Want me to remove this activity from the project's roster instead?"

3. If not there either, check `~/.claude/plugins/cache/*/*/*/skills/<name>/` (plugin). If found:

   > "`/<name>` is a plugin skill. To remove it, uninstall the plugin with `/plugin uninstall <plugin-name>`. Want me to remove this activity from the project's roster, leaving the plugin alone?"

4. If not found anywhere: "No skill named `<name>` found. Just remove the roster row? (yes → update `activities.md` only.)"

Also locate the `activities.md` row. If there's no row, create one at archive time so the history is captured.

## Phase 2 — Confirm with the user

Always confirm, even when invoked from review. Show:

- Full absolute path of the skill dir being archived
- Current status in roster
- Last used date (from hook log)
- Where it's going (`<project>/.claude/skills-archive/<name>/`)

Prompt:

> "Archive `/<name>`?
> - Source: `<project>/.claude/skills/<name>/`
> - Destination: `<project>/.claude/skills-archive/<name>/`
> - Last used: 2026-03-19 (33 days ago)
> - Reversible — restore with `/daily-plan add <name>`.
> Confirm? (yes / no / skip)"

Require explicit `yes`. "Skip" during review = continue to next item without archiving.

## Phase 3 — Move the skill

1. `mkdir -p .claude/skills-archive` (relative to project root; create once, idempotent)
2. `mv .claude/skills/<name> .claude/skills-archive/<name>`
   - If a `<name>` already exists in `skills-archive/`, append a date suffix: `.claude/skills-archive/<name>-YYYY-MM-DD/`
3. Write an archive marker inside the moved directory: `.claude/skills-archive/<name>/ARCHIVED.md`

Template for `ARCHIVED.md`:

```markdown
# Archived

- Archived: YYYY-MM-DD
- Reason: <from user or review>
- Last used: YYYY-MM-DD
- To restore: `/daily-plan add <name>` (or `mv` the directory back)
```

## Phase 4 — Update `activities.md`

- Set the row's `Status` to `archived`.
- Set the row's `Skill` column to `(archived: <name>)` so the daily picker never tries to run it.
- Preserve `Last used` as-is (the history matters).
- Update the `Updated:` date at the top.

## Phase 5 — Confirm to user

> "`/<name>` archived. Moved to `.claude/skills-archive/<name>/` (commit this alongside `marketing/` if the repo is tracked). Roster marked archived. Restore with `/daily-plan add <name>`."

If archival was part of a review batch, log this line in the review summary but continue to the next item.

## Restoration (for reference — triggered by scaffold flow)

`/daily-plan add <name>` checks for `.claude/skills-archive/<name>/` and offers to restore instead of scaffold. See `steps/scaffold_activity.md` Phase 1.

## Anti-patterns

- **Deleting instead of moving.** Always move. Archival is not deletion.
- **Archiving without confirmation.** Even during batch review, each confirm is cheap insurance.
- **Archiving user-global or plugin skills.** Out of scope — those are infrastructure. Surface non-use in the review report, but let the user act on them.
- **Dropping the roster row.** Keep it with `status: archived`. History is the point.
- **Silent archival during review.** Tell the user what was archived at the end; they should know.
