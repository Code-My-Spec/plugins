---
name: anthropic-marketing
tier: core
purpose: enterprise-marketing-toolkit
covers_loops: [acquisition, activation, retention]
covers_channels: [content, copywriting, brand, campaign, performance, seo, email]
install_command: "/plugin install anthropic-marketing"
marketplace: "anthropics/knowledge-work-plugins"
auth_required: true
auth_via: enterprise-mcps
detection:
  type: plugin
  installed_plugins_match: ["anthropic-marketing", "marketing"]
verification:
  type: skill_present
  skill_path_glob: "~/.claude/plugins/cache/*/anthropic-marketing/*/skills/draft-content/SKILL.md"
---

# anthropic-marketing

## What it is
Anthropic's official Marketing plugin (Anthropic-Verified). Content creation + brand voice + campaign planning + competitive analysis + performance reporting. Designed for marketing **teams** at companies with an enterprise stack — connects Slack, Canva, Figma, HubSpot, Amplitude, Ahrefs, Klaviyo via MCPs.

## Skills shipped
- `/draft-content` — blog posts, social, email, landing pages, press releases, case studies
- `/campaign-plan` — objectives, channel strategy, content calendar, success metrics
- `/brand-review` — content vs brand voice + style guides
- `/competitive-brief` — competitive positioning analysis
- `/performance-report` — marketing performance reports
- `/seo-audit` — SEO audits (LLM-based, not API-backed like claude-seo)
- `/email-sequence` — multi-email nurture sequences

## When to install
- You're a marketing **team** (not solo).
- You already use Slack + at least one of: Canva, Figma, HubSpot, Amplitude, Ahrefs, Klaviyo.
- You want LLM-driven content with company-specific brand-voice enforcement.

## Strategy fit
- **Required if:** team-scale operation with the enterprise MCPs already in place.
- **Nice-to-have if:** you're solo but use HubSpot or Klaviyo and want their MCPs available alongside content skills.
- **Out-of-scope if:** solo founder, none of those enterprise tools.

## Prerequisites
- Anthropic-verified marketplace registered: `anthropics/knowledge-work-plugins`
- Whichever enterprise MCPs you intend to use (each has its own auth — Slack OAuth, HubSpot Private App token, etc.)

## Install steps
1. Add the marketplace if needed: `/plugin marketplace add anthropics/knowledge-work-plugins`
2. `/plugin install marketing` (the plugin's name in the Anthropic marketplace is just `marketing`)
3. Connect the enterprise MCPs you'll use — Settings → Connectors in Claude Desktop, or `claude mcp add` per integration. Each has its own auth flow.
4. Restart Claude Code.

## Auth setup
Per-MCP. The plugin doesn't bundle its own auth convention — it depends on whichever enterprise MCPs are wired up:

- **Slack:** Slack's MCP server, OAuth via Slack workspace
- **HubSpot:** Private App token (also in `/marketing-stack`'s hubspot recipe — share the credential)
- **Klaviyo:** Klaviyo MCP, API key
- **Amplitude:** Amplitude MCP, API key
- **Ahrefs:** Ahrefs MCP (paid plan required)
- **Canva, Figma:** OAuth via the respective product's MCP

If you're not running any of these enterprise MCPs, the plugin's content/brand/campaign skills still work in pure-LLM mode — just without the integrations.

## Verification
- Plugin installed: `~/.claude/plugins/cache/*/anthropic-marketing/*/skills/draft-content/SKILL.md` exists
- Slash command `/draft-content` available

## Conventions to seed
None directly. The plugin's skills layer on top of whatever enterprise tooling is already in place.

## Gotchas
- **Naming overlap with our skills.** The plugin ships `/seo-audit` (LLM-based) which has the same name as `coreyhaensines31/marketingskills`'s `/seo-audit` AND claude-seo's `/seo-audit`. If multiple are installed, slash command resolution may be ambiguous. Disable duplicates with `/plugin disable`.
- The plugin's `/seo-audit` is content-quality-focused, not API-backed. For real GSC + GA4 data, install `claude-seo` separately.
- Several MCPs (Ahrefs, Amplitude, Klaviyo, HubSpot Marketing Hub) require paid tiers.
- This plugin assumes a team-scale workflow. Solo founders typically get more value from `marketingskills` (lighter, no enterprise MCPs needed).

## Links
- Plugin page: https://claude.com/plugins/marketing
- Anthropic marketplace: https://github.com/anthropics/knowledge-work-plugins
