---
name: reddit
tier: core
channel: reddit
loop_fit: [acquisition]
primary_mcp_status: community-active
requires_server_install: false
requires_deploy: false
detection:
  type: mcp
  args_contains: ["reddit-mcp-buddy"]
validation:
  type: tool
  intent: "browse r/elixir hot, 3 posts"
  preferred_tool_pattern: "browse_subreddit"
  expect:
    shape: "array.{title,author,score,url}"
    min_items: 1
---

# Reddit

## What it is
Reddit browsing, search, and user/thread analysis via `reddit-mcp-buddy` (karanb192). Actively maintained as of 2026. Three-tier auth: anonymous (10 rpm), app-only (60 rpm), authenticated (100 rpm).

**Read-only MCP.** Posting/commenting is a separate concern — best through Postiz (which supports Reddit) or manual. Matches the "John dictates, AI polishes" discipline.

## Unlocks
- Activities: "daily scan for empathy threads in target subs," "competitor/persona user research," "weekly subreddit trend check," "find threads where product is genuine answer," "draft comment with context"

## Prerequisites
- **Tier 1 (anonymous):** none
- **Tier 2+ (recommended for real use):** a Reddit account — ideally a dedicated "tools" account, not your personal one

## Install steps
1. **(Optional but strongly recommended)** Create Reddit app at https://www.reddit.com/prefs/apps:
   - Click "create another app"
   - Select **script** type for 100 rpm authenticated
   - Name: `claude-marketing`
   - Redirect URI: `http://localhost:8080` (not actually used for script type, but required field)
   - Click "create app"
   - Copy the 14-char Client ID (shown under the app name) and 27-char Client Secret
2. **Register the MCP:**
   ```bash
   claude mcp add --transport stdio reddit -s user -- npx -y reddit-mcp-buddy
   ```
3. Add env vars to `.env` per the tier you chose.
4. Reference `.env` from the MCP config. If you used `claude mcp add` above, the env passes through automatically when you set the values in `.env`. To verify or set explicitly, your `~/.claude.json` should look like:
   ```json
   "reddit": {
     "command": "npx",
     "args": ["-y", "reddit-mcp-buddy"],
     "env": {
       "REDDIT_CLIENT_ID": "${REDDIT_CLIENT_ID}",
       "REDDIT_CLIENT_SECRET": "${REDDIT_CLIENT_SECRET}",
       "REDDIT_USERNAME": "${REDDIT_USERNAME}",
       "REDDIT_PASSWORD": "${REDDIT_PASSWORD}"
     }
   }
   ```

## .env requirements
```
# Tier 1 (anonymous, 10 rpm): no vars

# Tier 2 (app-only, 60 rpm):
REDDIT_CLIENT_ID=            # 14-char from Reddit app page, under app name
REDDIT_CLIENT_SECRET=        # 27-char from Reddit app page, labeled "secret"

# Tier 3 (authenticated, 100 rpm) — adds:
REDDIT_USERNAME=             # account that created the script app
REDDIT_PASSWORD=             # account password — if 2FA is enabled, use an app-specific password
```

**Auth caveat:** Tier 3 uses the OAuth Resource Owner Password Credentials grant. Reddit only supports this for **script-type apps** authenticating as the **app's owner account**. If your account has 2FA enabled, generate an app password (Reddit Account Settings → Apps & Notifications) and use that as `REDDIT_PASSWORD`. If you don't want password auth at all, stay on Tier 2 (60 rpm is plenty for most daily-scan use).

## Validation
Ask Claude: "Using reddit-mcp-buddy, browse r/elixir hot, 3 posts." Expect JSON with title, author, url, score.

## Conventions to seed
Write `marketing/conventions/reddit.md`:

```markdown
# Reddit conventions

## UTM format
- Campaign = topic slug, not page slug: `?utm_source=reddit&utm_medium=comment&utm_campaign=agentic-coding-process`
- Medium = `comment` or `post`

## Pacing rule
- Max 2-3 substantive comments per session; spread across the day.
- Never burst 6+ in one window (rate-limit + community-perception).

## Link discipline
- Never link to homepage. Always a specific content page earning the click.
- URL prefixes: `/pages/:slug`, `/blog/:slug`, `/documentation/:slug`. Bare slugs 404.

## Voice
- Answer first, link second. Substantive value up front.
- Em dashes → plain hyphens (Reddit spam filters).
- Two-comment strategy: short no-link comment for upvotes + reply with link for clicks.

## Touchpoint log
- Every engagement → one line in `marketing/touchpoints.md` with date, subreddit, thread URL, comment URL, link used.

## Account hygiene
- Primary voice: your real account.
- Tools account (for authenticated-mode MCP): dedicated, not personal.
- Don't post from a freshly-created account.
```

## Gotchas
- Rate limits are honest — pacing matters for daily scan activity.
- Cache TTLs: 15min anonymous, 5min authenticated.
- `search_reddit` with broad queries burns rate-limit; always add a subreddit filter.
- Script app Reddit account should not be your personal one.
- MCP provides NO posting capability.

## Links
- Source: https://github.com/karanb192/reddit-mcp-buddy
- Reddit app setup: https://www.reddit.com/prefs/apps
