# Install one recipe (`/marketing-stack install <name>`)

Guided install for a single recipe. Reads `recipes/<name>/RECIPE.md`, walks through it with the user, ends with a structured validation call.

**Time in user's mouth: 5-30 minutes depending on recipe.** Some (wix, reddit, ghost) are ~5 min. Postiz is the outlier (30+ due to deploy).

## Dry-run mode (`--plan`)

If the argument includes `--plan`, run in **dry-run mode**: read the recipe, simulate every phase (prerequisites check, install steps, `.env` writes, MCP registration, conventions seeding, validation), and print exactly what *would* happen. **Make no changes.** No Write, no Bash, no edits to `~/.codex/config.toml`.

Dry-run output format:
```
# Plan: install <recipe>

## Would check prerequisites
- [prereq 1 — status if detectable]
- ...

## Would execute install steps
1. [step description] — [shell command shown, NOT run]
2. ...

## Would write to .env
```
KEY_1=<placeholder — user provides at real install>
KEY_2=<placeholder>
```

## Would register MCP
```toml
<[mcp_servers.<name>] block that would land in ~/.codex/config.toml>
```

## Would seed conventions
- marketing/conventions/<file>.md (create / merge existing)

## Would validate via
<validation block from recipe frontmatter>
```

Then exit. No user prompts, no commits.

For `install-for-channel <channel> --plan`, the `install_for_channel.md` step loops plan-mode per bundle recipe.

## Phase 1 — Load the recipe

Parse `<name>` from the argument. Normalize: lowercase, hyphens.

Read `recipes/<name>/RECIPE.md`. If the file doesn't exist:
- Suggest close matches from the recipe inventory in `SKILL.md`
- Offer to show the full inventory: "recipe `<name>` not found. Did you mean: `<closest>`? Run `/marketing-stack` (no args) to see the full list."

If the recipe file exists, read it. Recipes are structured markdown with:

**Frontmatter (yaml)** — machine-readable metadata:
- `name`, `tier` (core | extension), `channel`, `loop_fit`
- `primary_mcp_status`, `requires_server_install`, `requires_deploy`
- `depends_on` (optional, list of other recipes)
- `detection` block — how to tell if this recipe is installed (see inventory.md)
- `validation` block — structured spec for post-install verification (see Phase 7)

**Body sections:**
- `## What it is`
- `## Unlocks`
- `## Prerequisites`
- `## Install steps`
- `## .env requirements`
- `## Validation` — human-readable mirror of the frontmatter spec
- `## Conventions to seed`
- `## Gotchas`
- `## Links`

## Phase 2 — Prerequisites check

Before touching anything, read the Prerequisites section and verify each:

- **Credential dependencies.** E.g., a recipe might depend on the GCP service account configured by the `google-apis` recipe (`~/.config/marketing-stack/google-api.json`). If absent, run `/marketing-stack install google-apis` first.
- **MCP dependencies.** E.g., `facebook-publish` routes through Postiz — check if `postiz` is already `ready`. If not: "facebook-publish routes through postiz. Install postiz first with `/marketing-stack install postiz`, or continue with a direct-API setup (not recommended for v1)?"
- **Server-side prerequisites.** E.g., `wordpress` needs mcp-adapter plugin installed on the WP site. Ask: "Have you installed the mcp-adapter plugin on your WordPress site? (yes/no/not yet)." If no/not-yet, show the user the install URL and how-to, wait for confirmation.

Don't proceed past this phase without prerequisites satisfied. That's usually where installs fail — not in the install itself.

## Phase 3 — Walk through install steps

Show each step one at a time with an explicit "ok to proceed?" gate for anything that:

- Touches `~/.codex/config.toml` (shared state — MCP servers are registered globally)
- Writes to `.env` (new secrets)
- Runs a deploy command (docker-compose, git clone)
- Changes the user's shell env or installs global npm/pip packages

For each step:

1. Show the command the user will run (or that the skill will run on their behalf).
2. Show the expected outcome.
3. Get explicit "yes" (or "run it"), then execute.
4. Show the result; confirm it matches expectation before moving to the next step.

**If the recipe requires manual user action** (e.g., "open this URL and copy the key"): format the action clearly:

```
### Step 3 — Create the Reddit app

1. Open https://www.reddit.com/prefs/apps
2. Click "create another app"
3. Select "script" type
4. Name: marketing-stack
5. Redirect URI: http://localhost:8080
6. Click "create app"
7. Copy the Client ID (14 chars, under the app name) and Client Secret (27 chars)
8. Come back and tell me "done" when you have them
```

Then wait. When they return, prompt for the values to add to `.env`.

## Phase 4 — Write to `.env`

Secrets never go anywhere else. Procedure:

1. Check for a `.env` file in the project root.
2. If absent, create one and add it to `.gitignore` (create `.gitignore` if absent too).
3. Append the recipe's env vars with the values provided, with a comment block above naming the recipe:

```
# --- marketing-stack: reddit ---
REDDIT_CLIENT_ID=abc123xyz
REDDIT_CLIENT_SECRET=secret_goes_here
REDDIT_USERNAME=your_bot_username
REDDIT_PASSWORD=your_bot_password
# --- end reddit ---
```

4. If an env var already exists in `.env`, ask before overwriting.

**Never** write secrets to `~/.codex/config.toml` or any git-tracked file. Phase 5 is how the values reach the MCP server without being copied anywhere.

## Phase 5 — Register the MCP (if applicable)

For MCP-backed recipes: add the MCP to `~/.codex/config.toml`. Codex MCP servers are **user-global** — there is no project scope, so a registered server is visible from every project. Say so before writing.

**Register the server:**

```bash
codex mcp add <name> -- npx -y <package>
```

For a remote (streamable HTTP) server, use `--url` instead of a command:

```bash
codex mcp add <name> --url https://example.com/mcp
```

Codex auto-detects OAuth support on `--url` servers and starts the browser authorization flow immediately. Re-auth later with `codex mcp login <name>`.

### Getting secrets into the server — the `.env`-only mechanism

This is the load-bearing part. Three facts about Codex, verified against codex-cli 0.141.0:

1. **Codex does NOT expand `${VAR}` in MCP config.** A value of `"${GHOST_ADMIN_API_KEY}"` reaches the server as the literal seven-character-plus string `${GHOST_ADMIN_API_KEY}`, not the secret.
2. **MCP servers do NOT inherit your shell environment by default.** They get a small baseline (`HOME`, `PATH`, `PWD`, `SHELL`, `TERM`, `USER`, `LANG`, `TMPDIR`, and a few more) plus whatever config declares.
3. **`env_vars` forwards variables by name.** Listing a variable name in `env_vars` passes that variable's *value* from Codex's own environment into the server, without the value ever appearing in config.

So the pattern is: **`env_vars` in config (names only) + `.env` loaded into the shell that launches Codex (values).**

Add the `env_vars` line to the server's block in `~/.codex/config.toml`:

```toml
[mcp_servers.ghost]
command = "npx"
args = ["-y", "@fanyangmeng/ghost-mcp"]
env_vars = ["GHOST_API_URL", "GHOST_ADMIN_API_KEY", "GHOST_API_VERSION"]
```

Note what's absent: no values. Only names. The file stays safe to read over someone's shoulder.

`codex mcp add` has no flag for `env_vars` — it only offers `--env KEY=VALUE`, which writes the **literal value** into config and therefore violates the `.env`-only rule. **Do not use `--env` for secrets.** Register with `codex mcp add`, then edit the block to add `env_vars`.

Then the user loads `.env` before launching Codex:

```bash
set -a; . ./.env; set +a
codex
```

Tell the user this plainly: **the MCP only sees the secrets if `.env` is loaded in the shell that starts Codex.** If they launch Codex from a desktop launcher instead of that shell, the variables won't be there and the server will fail auth. That's the single most common cause of a recipe that installs clean and then 401s.

**Fallback for launches with no shell env (the Codex app):** point the server at the bundled wrapper, which sources `.env` itself at server start:

```toml
[mcp_servers.ghost]
command = "/absolute/path/to/skills/marketing-stack/scripts/mcp_env_wrapper.sh"
args = ["npx", "-y", "@fanyangmeng/ghost-mcp"]
env = { MCP_ENV_FILE = "/absolute/path/to/project/.env" }
```

`MCP_ENV_FILE` is a path, not a secret — safe to write into config. Because Codex does no variable expansion, **both paths must be absolute**; `~`, `$PWD`, and `${PLUGIN_ROOT}` will not resolve.

If neither mechanism is available to the user, **stop the install**:

> "Installing this recipe would require writing the secret literally into `~/.codex/config.toml`, which violates the `.env`-only rule. Use `env_vars` with `.env` loaded in your shell, or the `mcp_env_wrapper.sh` path."

No fallback beyond those two. The rule is the rule. Workarounds are how secrets end up in committed files six months later.

## Phase 6 — Seed conventions

Read the recipe's `## Conventions to seed` section. For each file:

1. Check if it already exists at `marketing/conventions/<file>.md`.
2. If yes, show the diff between what's there and what the recipe suggests; ask before overwriting or merging.
3. If no, write it.
4. These files are marketing-specific operational patterns (e.g., Reddit UTM format, Stripe metadata conventions for attribution, Ghost tagging conventions). Short, opinionated, editable by the user.

If the recipe has no conventions section, skip this phase.

## Phase 7 — Validate (structured)

Read the `validation:` frontmatter block from the recipe. It has one of two shapes:

**Shell validation** (most deterministic — preferred when available):
```yaml
validation:
  type: shell
  command: 'curl -s -H "Authorization: Bearer $STRIPE_RESTRICTED_KEY" ...'
  expect:
    contains: '"object": "list"'
    # OR: not_contains: "FAILED"
    # OR: exit_code: 0
```
Run the command (with env vars resolved from `.env`). Compare output against `expect`. Pass if all clauses match.

**Tool validation** (MCP-mediated — used when shell isn't practical):
```yaml
validation:
  type: tool
  intent: "list 5 most recent posts"
  preferred_tool_pattern: "browse_posts"
  expect:
    shape: "array.{id,title,slug}"
    min_items: 0
```
Process:
1. List the tools exposed by the registered MCP.
2. Find the tool whose name contains `preferred_tool_pattern`.
3. Invoke it with arguments inferred from `intent` (usually "list ~5 items of <thing>").
4. Compare the response to `expect.shape` — parse as JSON, check each expected field is present, and count items against `min_items` / `contains_value`.

A newly registered MCP server is only picked up when Codex starts a session, so tool validation may need a restart before the tools exist. If the tools aren't visible, that's a restart, not a failure — say so rather than marking the recipe broken.

**Both types produce a pass/fail verdict.**

- Pass → mark the recipe `state: ready` in internal working state. Will be written to `infrastructure.md` on next `blueprint`.
- Fail → show the exact error output. Match against the recipe's `## Gotchas` section for hints. Offer two options:
  - Fix now with user's input (return to an earlier phase)
  - Defer with `state: partial` or `state: broken`, point at `/marketing-stack fix <name>` for next session.

Don't pretend success. A recipe without a passing validation is not ready.

## Phase 8 — Update `infrastructure.md`

If `marketing/infrastructure.md` exists, update just the affected row. Keep changes minimal.

If it doesn't exist, don't auto-generate it — the user runs `/marketing-stack blueprint` when they want it. Instead, tell them:

> "Recipe installed and verified. Run `/marketing-stack blueprint` to regenerate `marketing/infrastructure.md` with the new entry."

## Phase 9 — Close

Short summary:

> "`<recipe>` installed. `<tool count or capability summary>`. Next: either install a dependent recipe (`<suggestion>`), or if you're done, regenerate the blueprint. If anything breaks later, `/marketing-stack fix <recipe>`. To undo: `codex mcp remove <name>` plus delete the `.env` block."

Don't dump the full recipe content. Point at files.

## Anti-patterns

- **Installing without prerequisites.** Every failure-to-install I've seen in real use is a missed prerequisite. Check hard.
- **Writing secrets outside `.env`.** Hard rule, no fallback. `--env KEY=<secret>` is a violation — it writes the literal into config.
- **Silent success.** Every install ends with the validation spec actually passing.
- **Optimistic auto-registration of MCPs without consent.** `codex mcp add` modifies user-global state. Always confirm.
- **Glossing over server-side installs.** WordPress mcp-adapter install, Postiz deploy — these require explicit user action on their side. Document, verify, never skip.
- **Skipping convention seeding.** The conventions files are small but load-bearing — they're what makes the daily-plan skill able to run the activity correctly.
- **Natural-language validation.** Validation spec is structured (frontmatter). Don't invent prose calls.
- **Forgetting to tell the user about loading `.env`.** An MCP registered with `env_vars` and no loaded `.env` fails with an auth error that looks like a bad credential. Name the cause up front.
- **`--plan` that isn't actually dry.** If `--plan` runs ANY mutating command, that's a bug — the whole point is risk-free preview.
