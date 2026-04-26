# Install one plugin (`/marketing-library install <name>`)

Guided install for a single curated plugin. Reads `plugins/<name>/PLUGIN.md`, walks the user through it, ends with verification.

**Time in user's mouth: 2-30 minutes depending on plugin.** marketingskills is a 30-second `/plugin install`. claude-seo is the outlier (GCP setup adds 20-30 min).

## Dry-run mode (`--plan`)

If the argument includes `--plan`, simulate every phase and print what *would* happen. **No mutating tool calls.** No `Write`, no `claude mcp add`, no `/plugin install`, no `Bash` that changes state.

Output:
```
# Plan: install <plugin>

## Would check prerequisites
- [list]

## Would run install command
<command shown, NOT executed>

## Would set up auth (if applicable)
- [auth steps shown, NOT executed]

## Would verify via
<verification block from PLUGIN.md frontmatter>

## Would update marketing/infrastructure.md
- Add row to "Playbook plugins" section

## Would seed conventions (if applicable)
- marketing/conventions/<file>.md
```

Then exit. No prompts.

## Phase 1 — Load the plugin definition

Parse `<name>` from the argument. Normalize: lowercase, hyphens.

Read `plugins/<name>/PLUGIN.md`. If the file doesn't exist:
- Suggest close matches from the curated list in `SKILL.md`
- Offer: "Plugin `<name>` is not in the curated set. You can install it directly with `/plugin install <name>` — but library won't track it. Want to proceed manually?"

If it exists, parse frontmatter + body.

## Phase 2 — Prerequisites check

Read the `## Prerequisites` section. Common patterns:

- **Account on a third-party service** (e.g., DataForSEO subscription for the claude-seo extension): list, don't try to verify.
- **Plugin marketplace registered** (e.g., the plugin's marketplace must be added before `/plugin install` works): check `~/.claude/plugins/marketplaces/` and offer to add if missing.
- **System dependencies** (e.g., Node.js version, Python version, Docker): check, halt if absent.

For claude-seo specifically:
- A Google Cloud account with billing enabled (free tier is fine for the APIs we use).
- Admin/owner access to the GSC properties + GA4 properties to grant the service account.

## Phase 3 — Install the plugin

Most plugins:
```
/plugin install <name>
```

Or if the plugin's marketplace isn't already added:
```
/plugin marketplace add <marketplace-url>
/plugin install <name>
```

Show the exact command, get explicit "yes" before running. After install, verify the plugin appears in `~/.claude/plugins/installed_plugins.json`.

## Phase 4 — Plugin-bundled auth setup

If the plugin's `## Auth setup` section has steps, walk through them — these are the plugin's own conventions, not ours. We respect them.

For example, claude-seo's auth setup:
1. GCP project + service account creation (Google Cloud Console steps)
2. Enable APIs (Google Search Console, GA4 Data, PageSpeed, CrUX, Indexing, optionally YouTube Data + Analytics)
3. Per-property grants (add service account `client_email` to each GSC property and each GA4 property)
4. Write `~/.config/claude-seo/google-api.json` config file
5. Place service account JSON at `~/.config/claude-seo/service_account.json` (chmod 600)
6. Optionally install MCP extensions: DataForSEO, Firecrawl, nanobanana

For each step that requires user action (opening a browser tab, copying a value), format clearly:

```
### Step N — <title>
1. Open <URL>
2. <action>
3. Copy <thing>
4. Tell me "done" when ready
```

Wait for the user's confirmation before continuing.

**Auth secrets stay where the plugin documents them.** For claude-seo, that's `~/.config/claude-seo/`. We do NOT try to migrate them into the project's `.env` — that's the plugin's contract, not ours.

## Phase 5 — Verify

Run the plugin's `verification:` spec from frontmatter. Same structured pattern as `/marketing-stack`'s `validation:`:

**Shell verification:**
```yaml
verification:
  type: shell
  command: 'python ~/.claude/skills/seo-google/scripts/google_auth.py --check --json 2>&1'
  expect:
    contains: '"tier"'
```

**Skill-present verification:**
```yaml
verification:
  type: skill_present
  skill_path: "~/.claude/plugins/cache/*/marketing-skills/*/skills/copywriting/SKILL.md"
```

Run the check. Pass → mark plugin `state: ready` in working state. Fail → show the error, match against `## Gotchas`, offer:
- Fix now with user input
- Defer with `state: partial` or `broken`, point at next-session debugging

Don't pretend success.

## Phase 6 — Seed conventions (optional)

If the plugin has a `## Conventions to seed` section (e.g., claude-seo seeds `marketing/conventions/seo.md`), check whether the file exists. Diff if so, ask before merging or overwriting. Write if absent.

## Phase 7 — Update infrastructure blueprint

If `marketing/infrastructure.md` exists and has a "Playbook plugins" section, update just the affected row in place. Preserve other rows + notes.

If the section doesn't exist, create it. If the file doesn't exist, don't auto-generate the whole blueprint — tell the user:
> "Plugin installed. Run `/marketing-library blueprint` to update `marketing/infrastructure.md`."

## Phase 8 — Close

Short summary:
> "`<plugin>` installed and verified. <skill count or capability summary>. <Number> skills now available — they'll show up in your slash command palette after restart. If anything breaks later, `/marketing-library` (inventory) will surface it."

Don't dump full plugin content. Point at files.

## Anti-patterns

- **Skipping prerequisites.** Auth ceremony failures are 90% of plugin install pain.
- **Trying to abstract plugin auth into `.env`.** Plugin owns its convention. Respect.
- **Silent verification success.** Always run the verification spec.
- **Auto-confirming `/plugin install`.** Modifies user state. Always get explicit yes.
- **Running `--plan` that mutates anything.** If `--plan` writes, registers, or installs anything, that's a bug.
- **Installing non-curated plugins through this skill.** Library is a curated layer. Direct `/plugin install` is the user's escape hatch — don't replicate it here.
