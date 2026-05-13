---
name: slack
tier: extension
channel: slack
loop_fit: [acquisition, retention]
primary_mcp_status: community-active
requires_server_install: false
requires_deploy: false
detection:
  type: mcp
  args_contains: ["slack-mcp-server", "korotovsky"]
validation:
  type: tool
  intent: "list slack channels"
  preferred_tool_pattern: "channels_list"
  expect:
    shape: "array.{id,name}"
    min_items: 1
---

# Slack

## What it is
Slack workspace integration via `korotovsky/slack-mcp-server`. Actively maintained as of 2026 (1.4k+ stars, MIT, v1.2.3 March 2026). 15 tools spanning conversations, search, channels, reactions, users, and usergroups.

**Read-only by default.** Posting (`conversations_add_message`) and marking-read (`conversations_mark`) require explicit opt-in via env flags. Matches the "don't accidentally publish" discipline.

**Why not Slack's own MCP?** Slack launched an official MCP + Real-Time Search API in 2025, but it requires Enterprise plan + admin-approved app enrollment. The korotovsky server uses browser tokens or OAuth and works on any workspace plan you have membership in.

## Unlocks
- Activities: "scan #customer-feedback for last week's themes," "search workspace for prior mentions of $topic before drafting," "post weekly digest in #marketing," "thread reply in #support with prior context"
- Use cases: own-workspace community + customer comms, community marketing in third-party Slack workspaces you've joined (founder communities, OSS project Slacks, customer DevRel rooms)

## Prerequisites
- Membership in the Slack workspace(s) you want to access
- For write mode: posting permission in the target channels

## Install steps

### Path A: Browser tokens (fastest, no admin approval)

1. **Capture browser tokens** while logged into your Slack workspace in a browser:
   - Open https://app.slack.com → DevTools (Cmd-Opt-I) → **Application** → **Local Storage** → `https://app.slack.com` → key `localConfig_v2` → expand → find your workspace → copy the `token` (starts with `xoxc-`).
   - DevTools → **Application** → **Cookies** → `https://app.slack.com` → cookie named `d` → copy the **Value** (starts with `xoxd-`). If it's URL-encoded, decode once.
2. **Register the MCP:**
   ```bash
   claude mcp add --transport stdio slack -s user -- npx -y slack-mcp-server@latest
   ```
   (Verify the exact npm package name in the upstream README; the canonical run path is the Go binary — `go install github.com/korotovsky/slack-mcp-server/cmd/slack-mcp-server@latest` then point the MCP at that binary.)
3. Add env vars to `.env`.

### Path B: OAuth bot/user tokens (durable, needs admin approval)

1. https://api.slack.com/apps → **Create New App** → **From scratch** → pick workspace.
2. **OAuth & Permissions** → add scopes:
   - Bot scopes (for `xoxb-`): `channels:read`, `channels:history`, `groups:read`, `groups:history`, `chat:write`, `users:read`, `reactions:read`, `reactions:write`
   - User scopes (for `xoxp-`, needed for full search): `search:read`
3. **Install to Workspace** → workspace admin approves.
4. Copy the **Bot User OAuth Token** (`xoxb-...`) and/or **User OAuth Token** (`xoxp-...`) from OAuth & Permissions page.

## .env requirements
```
# Path A — browser tokens (at least both):
SLACK_MCP_XOXC_TOKEN=        # xoxc-... from localConfig_v2 in browser
SLACK_MCP_XOXD_TOKEN=        # xoxd-... from cookie `d`

# Path B — OAuth tokens (alternative):
SLACK_MCP_XOXB_TOKEN=        # xoxb-... bot token (preferred for posting)
SLACK_MCP_XOXP_TOKEN=        # xoxp-... user token (preferred for search)

# Optional — enable writes (default: read-only):
SLACK_MCP_ADD_MESSAGE_TOOL=  # set to true to allow conversations_add_message
SLACK_MCP_MARK_TOOL=         # set to true to allow conversations_mark
```

## Validation
Ask Claude: "Using the slack MCP, list channels in my workspace." Expect JSON array with `id` and `name` fields.

## Conventions to seed
Write `marketing/conventions/slack.md`:

```markdown
# Slack conventions

## Read vs write
- Default to read-only. Flip `SLACK_MCP_ADD_MESSAGE_TOOL` only for the session that needs it, then unset.
- Never let the MCP post in a channel without a human-reviewed draft.

## Channel discipline
- Own workspace: post in the topic channel, never DM-blast.
- Third-party workspaces (customer/founder communities): respect the room's stated purpose. If it has a `#self-promo` lane, that's the lane — anywhere else reads as crashing.

## Voice
- Slack uses partial Markdown — `*bold*` is single asterisks, `_italics_` is underscores. Don't paste standard `**bold**` (it renders literally).
- Long-form → thread, not main channel.
- No emoji-only reactions for engagement farming.

## Search before you post
- Slack workspaces have institutional memory. Run `conversations_search_messages` for prior mentions of the topic before posting "has anyone tried X?" — faster, and avoids the look of ignoring previous threads.

## Touchpoint log
- Each substantive engagement → one line in `marketing/touchpoints.md` with date, workspace, channel, message permalink.

## Token hygiene
- xoxc/xoxd tokens are tied to your browser session — logout, password change, or session timeout invalidates them. Re-grab when validation starts failing.
- xoxb/xoxp tokens persist until the app is uninstalled or the admin revokes.
```

## Gotchas
- **xoxc/xoxd are browser-session-bound.** They invalidate on logout, password change, or session timeout. For long-lived setups, OAuth (xoxb/xoxp) is more durable but needs admin approval.
- **Workspace admin policies often block third-party MCP tokens.** Path A may work locally and silently fail when admin enables app restrictions. Symptom: `channels_list` returns empty array.
- The official Slack MCP + Real-Time Search API (launched May 2025) requires Slack Enterprise + admin enrollment. Not a fit for solo founders or workspaces you're a guest in.
- **Anthropic's old `@modelcontextprotocol/server-slack` was archived May 2025.** Don't wire to that package. Zencoder forked it, but korotovsky's server has broader tool surface (15 vs 8 tools) and active maintenance.
- Posting from a personal user token (xoxp/xoxc) appears as **you** in the channel, not a bot. Fine for community engagement; use xoxb if you want a separate "marketing bot" identity.
- Slack rate limits are per-method tiered (Tier 1: 1 rpm, Tier 4: 100+ rpm). Search APIs are stricter — don't batch hundreds of queries in a loop.

## Links
- Source: https://github.com/korotovsky/slack-mcp-server
- Slack token types reference: https://api.slack.com/concepts/token-types
- Slack app management: https://api.slack.com/apps
- Slack rate limits: https://api.slack.com/docs/rate-limits
- Slack's official MCP (Enterprise): https://slack.com/help/articles/48855576908307
