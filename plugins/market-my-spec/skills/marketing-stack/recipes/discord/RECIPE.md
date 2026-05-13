---
name: discord
tier: extension
channel: discord
loop_fit: [acquisition, retention]
primary_mcp_status: community-active
requires_server_install: false
requires_deploy: false
detection:
  type: mcp
  args_contains: ["mcp-discord", "barryyip0625"]
validation:
  type: tool
  intent: "list servers via discord MCP"
  preferred_tool_pattern: "discord_list_servers"
  expect:
    shape: "array.{id,name}"
    min_items: 1
---

# Discord

## What it is
Discord bot integration via `mcp-discord` (barryyip0625). Actively maintained as of 2026 (v1.3.9, April 2026, MIT). Node-based, supports stdio + HTTP transports, ~30 tools across messages, channels, roles, search, reactions, and webhooks.

**Bot-based.** You register a Discord application + bot, invite it to your server(s), and the MCP acts as that bot. The bot only sees channels it has been explicitly granted access to. For pure "drop an announcement" use cases, a plain Discord webhook URL is lighter than running a bot — see Gotchas.

## Unlocks
- Activities: "post launch announcement in #releases," "scan community signal for FAQ themes," "draft AMA reply with thread context," "thread weekly digest summary"
- Use cases: own-community management (your Discord server), community marketing (third-party servers that have invited your bot), webhook-style cross-posting from blog/release flow

## Prerequisites
- A Discord account
- Server-owner or **Manage Server** permission on every server you want the bot to operate in

## Install steps
1. **Create a Discord application + bot:**
   - Open https://discord.com/developers/applications
   - **New Application** → name it (e.g. `acme-marketing-bot`)
   - Left nav → **Bot** → **Reset Token** (this is the only time the token is shown in full — copy immediately)
   - Bot settings → enable **Privileged Gateway Intents**:
     - `Message Content Intent` — required to read message bodies (without it, `read_messages` returns metadata only)
     - `Server Members Intent` — only if your activities need member lists
2. **Invite the bot to your server:**
   - Left nav → **OAuth2** → **URL Generator**
   - Scopes: `bot` (+ `applications.commands` if you plan to use slash commands)
   - Bot Permissions (minimum): `View Channels`, `Send Messages`, `Read Message History`. Add `Manage Webhooks` if you'll create webhooks via the MCP. Add `Embed Links` and `Attach Files` for richer posts.
   - Copy the generated URL → open in browser → pick your server → Authorize
3. **Register the MCP:**
   ```bash
   claude mcp add --transport stdio discord -s user -- npx -y mcp-discord
   ```
4. Add env vars to `.env`.
5. After the MCP first runs, verify the bot shows **online** in your server's member list. It stays offline until the MCP process starts and calls `discord_login`.

## .env requirements
```
DISCORD_TOKEN=               # Bot token from Developer Portal → Bot → Reset Token (single-display, store immediately)
DISCORD_GUILD_ID=            # Optional default server ID — enable Developer Mode in Discord (User Settings → Advanced), then right-click server icon → Copy Server ID
```

## Validation
Ask Claude: "Using the discord MCP, list the servers the bot is connected to." Expect JSON array with at least one entry containing `id` and `name`.

## Conventions to seed
Write `marketing/conventions/discord.md`:

```markdown
# Discord conventions

## Channel discipline
- Announcements only in the channel set aside for them. Never spray a launch across general/feedback/off-topic.
- Long replies → thread, not main channel feed. Choking the feed is a fast way to get muted.

## Webhook vs bot
- **Webhook** for one-way announcements (cross-post a blog drop, ship a release note). No MCP needed — `curl -X POST` to the webhook URL is enough.
- **Bot/MCP** for anything that reads messages, threads replies, reacts, or runs interactively.

## Voice
- Plain hyphens, not em dashes. Consistency reads less like AI-generated.
- No @here / @everyone unless the server expects it; reserved for actual release moments.
- Match the room's emoji culture — over-emoji'ing in a serious dev server lands worse than no emoji at all.

## Touchpoint log
- Each substantive engagement (thread reply in someone else's server, AMA, support hand-off) → one line in `marketing/touchpoints.md` with date, server, channel, message link.

## Account hygiene
- One bot per project. Don't share one bot identity across unrelated servers.
- Bot username/avatar should make its automated nature obvious (`acme-assistant`, not a person name).

## Rate limits
- Global: ~50 requests / second per bot; per-route limits stricter.
- Don't batch-react with dozens of emoji or fan-out DMs — both trip anti-abuse and look spammy.
```

## Gotchas
- **Message Content Intent must be enabled** in the Developer Portal or `read_messages` returns empty content. Easy to miss; symptom is "messages come back but `.content` is `""`."
- The bot only sees channels with explicit "View Channel" permission. Private channels need explicit role/permission additions.
- For announcement-only use cases, a **Discord webhook URL** is simpler than a bot. Server Settings → Integrations → Webhooks → New Webhook → copy URL. Then `curl -X POST -H "Content-Type: application/json" -d '{"content":"..."}' $WEBHOOK_URL`. Use the MCP only when you also need reads, threads, or reactions.
- Bot tokens are equivalent to passwords. Never commit. Rotate via "Reset Token" if leaked — old token invalidates immediately.
- **Discord ToS prohibits selfbots** (running automation against a user token). Always use a bot token. Don't try to wire the MCP to your personal account.
- Verified bots (>100 servers) require Discord's verification flow. Not a concern for solo-founder use.

## Links
- Source: https://github.com/barryyip0625/mcp-discord
- Discord Developer Portal: https://discord.com/developers/applications
- Bot permission calculator: https://discordapi.com/permissions.html
- Webhook docs (alternative to bot): https://support.discord.com/hc/en-us/articles/228383668
