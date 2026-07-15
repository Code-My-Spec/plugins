---
name: ghost
tier: core
channel: content
loop_fit: [acquisition, activation, monetization]
primary_mcp_status: community-active
requires_server_install: false
requires_deploy: false
detection:
  type: mcp
  args_contains: ["@fanyangmeng/ghost-mcp", "ghost-mcp"]
  env_var: "GHOST_API_URL"
validation:
  type: tool
  intent: "list 5 most recent posts"
  preferred_tool_pattern: "browse_posts"
  expect:
    shape: "array.{id,title,slug}"
    min_items: 0
---

# Ghost

## What it is
Ghost CMS + native newsletter + paid memberships via `@fanyangmeng/ghost-mcp` (MFYDev). TypeScript MCP, MIT, active.

## Unlocks
- Activities: "draft weekly newsletter," "publish post + trigger member send," "tier performance audit," "create limited-time offer," "member engagement review"

## Prerequisites
- A Ghost site (self-hosted or Ghost Pro)
- Admin access to Ghost to create an integration

## Install steps
1. **Create Ghost integration (admin action on the Ghost site):**
   - Ghost Admin → Settings → Integrations → Add custom integration
   - Name: `marketing-stack`
   - Copy the **Admin API Key** (format: `id:secret` — 26-char id + 64-char hex secret, colon-separated)
   - Note the **API URL** (e.g., `https://yourblog.com`, no trailing slash)
2. **Register the MCP:**
   ```bash
   codex mcp add ghost -- npx -y @fanyangmeng/ghost-mcp
   ```
3. **Wire env vars** — see `.env requirements` below. Add to project `.env`.
4. **Let the server read them.** Codex does not expand `${VAR}` and MCP servers don't inherit your shell, so name the variables in `env_vars` — names only, never values. Edit `~/.codex/config.toml`:
   ```toml
   [mcp_servers.ghost]
   command = "npx"
   args = ["-y", "@fanyangmeng/ghost-mcp"]
   env_vars = ["GHOST_API_URL", "GHOST_ADMIN_API_KEY", "GHOST_API_VERSION"]
   ```
5. Load `.env` and start Codex from that same shell, so the values exist for `env_vars` to forward:
   ```bash
   set -a; . ./.env; set +a
   codex
   ```
   (If you launch Codex from the dock instead, use `scripts/mcp_env_wrapper.sh` — see `steps/install_recipe.md` Phase 5.)

Undo: `codex mcp remove ghost` + delete the `.env` block.

## .env requirements
```
GHOST_API_URL=           # https://yourblog.com (no trailing slash)
GHOST_ADMIN_API_KEY=     # id:secret from Ghost integration page
GHOST_API_VERSION=v5.0   # pin; bump when your Ghost major version moves
```

## Validation
Ask Codex: "Using the Ghost MCP, list the last 5 posts." Expect JSON with `id`, `title`, `slug`, `published_at`.

## Conventions to seed
Write `marketing/conventions/content.md` (create or merge):

```markdown
# Content conventions (Ghost)

## Post-vs-newsletter
- Default: every post emails members (Ghost's built-in newsletter send).
- Blog-only: set `email_recipient_filter: none` in the draft before publish.
- Newsletter-only (no public post): keep status as email-only.

## Tagging
- Use `#newsletter` for newsletter-only sends to distinguish in archive.
- Max 3 tags per post.

## Tiers / members
- Free tier: newsletter posts.
- Paid tier: premium posts locked behind `visibility: paid`.

## Migration
- If moving from WordPress, use Ghost's importer. Don't dual-publish.
```

## Gotchas
- Admin API Key is `id:secret` format — copy the whole string including the colon.
- No documented rate limits; Ghost's Admin API is generous (~100 req/min assumed).
- `email_recipient_filter` controls who gets emailed on publish.
- Admin API doesn't support member password reset — use the Ghost UI.
- Ghost Pro customers: API URL is `https://<subdomain>.ghost.io`; self-hosted: your domain.
- A 401 right after a clean install usually means `.env` wasn't loaded in the shell that started Codex — not a bad key. Check that first.

## Links
- Source: https://github.com/MFYDev/ghost-mcp
- npm: https://www.npmjs.com/package/@fanyangmeng/ghost-mcp
- Ghost Admin API: https://ghost.org/docs/admin-api/
