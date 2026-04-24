---
name: wix
tier: core
channel: content
loop_fit: [acquisition, activation, monetization]
primary_mcp_status: official-remote-http
requires_server_install: false
requires_deploy: false
detection:
  type: mcp
  args_contains: ["mcp.wix.com/mcp"]
validation:
  type: tool
  intent: "list 5 most recent blog posts"
  expect:
    shape: "array.{id,title}"
    min_items: 1
---

# Wix

## What it is
Wix CMS + CRM + store via the **official remote Wix MCP server** at `https://mcp.wix.com/mcp`. HTTP transport — no local install of MCP code, no `.env` secrets. OAuth happens during the first chat with your LLM client.

Requires **Node.js 19.9+** on the user's machine (Wix CLI runs OAuth flow).

## Unlocks
- Activities: "draft weekly blog post as Wix draft," "audit product catalog," "weekly new-contacts review," "bookings pipeline check," "blog post SEO field edits"

## Prerequisites
- A Wix account
- Node.js 19.9+ installed locally
- Admin access to the site(s) to expose

## Install steps
1. Add the Wix remote MCP to your Claude config (`~/.claude.json`, `.mcp.json` for project-scoped, or via `claude mcp add`):
   ```json
   {
     "mcpServers": {
       "wix-mcp-remote": {
         "type": "http",
         "url": "https://mcp.wix.com/mcp"
       }
     }
   }
   ```
   Or via CLI: `claude mcp add --transport http wix-mcp-remote -s user https://mcp.wix.com/mcp`
2. Restart Claude Code (or your client) so the MCP loads.
3. First Wix-related call triggers the OAuth flow — Wix will prompt you to sign in (or create an account) and authorize the site(s) you want exposed.
4. For multi-site users, authorize each site separately when first accessed.

## .env requirements
None. Wix manages auth server-side.

## Validation
**Intent:** "list 5 most recent blog posts."
**Expect:** non-empty array with at least `id` and `title` per item.

If validation fails:
- Confirm Node.js 19.9+ is installed (`node --version`)
- Re-trigger OAuth by clearing client cache and restarting

## Conventions to seed
Write `marketing/conventions/content.md` (create or merge):

```markdown
# Content conventions (Wix)

## Drafting flow
- New post → Wix draft first; never publish directly from the MCP.
- SEO fields (title, description, slug, OG image) filled before publish.

## Tagging
- Use existing Wix tags; don't create new ones without intent.
- Max 3 tags per post.

## Images
- Upload to Wix Media Manager via the editor; reference by URL in draft body.
- Alt text required on all images.
```

## Gotchas
- Wix Studio (newer dev product) has fuller MCP coverage than classic Wix Editor sites.
- Multi-site: authorize each separately. Confusion source if one works and another doesn't.
- Programmatic non-Claude access uses Wix REST API directly (different setup, not this recipe).
- HTTP transport — needs network. No offline use.

## Links
- Wix MCP setup: https://www.wix.com/studio/developers/mcp-server
- Docs: https://dev.wix.com/docs/api-reference/articles/wix-mcp/about-the-wix-mcp
