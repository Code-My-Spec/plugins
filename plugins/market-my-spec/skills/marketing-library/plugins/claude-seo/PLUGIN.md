---
name: claude-seo
tier: core
purpose: seo-toolkit
covers_loops: [acquisition, activation]
covers_channels: [seo, analytics, content]
install_command: "/plugin install claude-seo"
marketplace: "AgriciDaniel/claude-seo"
auth_required: true
auth_config_path: "~/.config/claude-seo/google-api.json"
detection:
  type: plugin
  installed_plugins_match: ["claude-seo"]
  skill_present_glob: "~/.claude/skills/seo/SKILL.md"
verification:
  type: shell
  command: "python ~/.claude/skills/seo-google/scripts/google_auth.py --check --json 2>&1 || echo 'AUTH_CHECK_FAILED'"
  expect:
    contains: '"tier"'
    not_contains: "AUTH_CHECK_FAILED"
---

# claude-seo

## What it is
Comprehensive SEO playbook plugin: 20 skills (1 orchestrator + 15 always-on + 4 MCP extensions) covering audits, page analysis, technical SEO, E-E-A-T content, schema, sitemaps, local SEO, maps, hreflang, programmatic SEO, competitor pages, GEO, plus first-class Google API integrations (GSC, GA4, PageSpeed, CrUX, Indexing, optionally Ads).

By AgriciDaniel. Bundles its own Python scripts + 3 optional MCP extensions (DataForSEO, Firecrawl, nanobanana for image gen).

## Skills shipped

- **Orchestrator:** seo
- **Always-available (15):** seo-audit, seo-page, seo-technical, seo-content, seo-schema, seo-images, seo-sitemap, seo-geo, seo-plan, seo-programmatic, seo-competitor-pages, seo-hreflang, seo-local, seo-maps, seo-google, seo-backlinks
- **MCP-dependent extensions (4):** seo-firecrawl (Firecrawl MCP), seo-dataforseo (DataForSEO MCP), seo-image-gen (nanobanana for Gemini)

## When to install
- Strategy includes SEO, organic search, content marketing as a real channel.
- You want analytics-driven decisions (weekly GSC + GA4 pulls).
- You manage 1+ web properties whose Search Console / GA4 you have admin access to.

## Strategy fit
- **Required if:** SEO is in active or middle ring; content is an inner-ring channel; you make data-driven content decisions.
- **Nice-to-have if:** you publish but don't yet measure.
- **Out-of-scope if:** you have no web property OR your strategy explicitly defers SEO to later.

## Prerequisites
- A Google Cloud account (free tier is fine for the APIs we use)
- Admin/owner access to your GSC properties (to grant the service account)
- Admin/editor access to your GA4 property (same)
- Python available locally (for the auth-check script)

## Install steps
1. `/plugin marketplace add AgriciDaniel/claude-seo` (if marketplace not already added)
2. `/plugin install claude-seo`
3. Restart Claude Code.

## Auth setup
This plugin uses its own credential convention — `~/.config/claude-seo/google-api.json`. Library walks the user through it.

1. **Create a GCP project** at console.cloud.google.com → New Project. Note the project ID.
2. **Enable APIs** (APIs & Services → Library):
   - Google Search Console API
   - Google Analytics Data API
   - PageSpeed Insights API
   - Chrome UX Report API
   - Web Search Indexing API
   - YouTube Data API v3 (optional, for later)
3. **Create service account** (IAM & Admin → Service Accounts):
   - Name: `claude-seo`
   - Keys → Add Key → JSON → download
   - Place at `~/.config/claude-seo/service_account.json` (chmod 600)
4. **Create API key** (APIs & Services → Credentials → Create Credentials → API key)
5. **Grant service account access** to each property:
   - **GSC:** Search Console → property → Settings → Users and permissions → Add user → paste service account `client_email` → Full (or Owner for Indexing API)
   - **GA4:** analytics.google.com → Admin (gear, bottom left) → Property Access Management → `+` → paste `client_email` → Viewer
6. **Write config file** at `~/.config/claude-seo/google-api.json`:
   ```json
   {
     "service_account_path": "~/.config/claude-seo/service_account.json",
     "api_key": "AIzaSy...",
     "default_property": "sc-domain:example.com",
     "ga4_property_id": "properties/123456789"
   }
   ```
7. **Optional MCP extensions** (run from claude-seo's plugin directory):
   - `./extensions/dataforseo/install.sh` — DataForSEO login + password (paid)
   - `./extensions/firecrawl/install.sh` — `FIRECRAWL_API_KEY`
   - `./extensions/banana/install.sh` — Gemini API key from aistudio.google.com/apikey

**Why config file, not `.env`:** This is claude-seo's own convention, not ours. Library respects plugin conventions.

## Verification
```
python ~/.claude/skills/seo-google/scripts/google_auth.py --check --json
```
Returns JSON with `tier` field showing which credential tier is active (0=API key, 1=+SA, 2=+GA4, 3=+Ads).

## Conventions to seed
Write `marketing/conventions/seo.md`:

```markdown
# SEO conventions

## Weekly review
- GSC: top 50 landing pages by impressions (28d), top 50 queries
- GA4: Organic Search sessions by landing page (28d), conversions
- Diff vs last week — 3 moves to flag

## Content audit cadence
- Monthly: top-10 audit → refresh/consolidate candidates
- Quarterly: full inventory, kill/redirect underperformers

## Technical cadence
- Weekly: /seo-technical full crawl
- Monthly: CWV via CrUX (27-week history)
- On deploy: /seo-schema validation of changed pages

## Service account hygiene
- Rotate SA key annually
- Document client_email in marketing/infrastructure.md
```

## Gotchas
- **Per-property grants required.** Most common gotcha — valid SA with no per-property grant returns 403s that look like auth failures. Always grant access to EACH GSC property and EACH GA4 property explicitly.
- Indexing API officially supports only JobPosting + BroadcastEvent/VideoObject content types.
- GSC URL Inspection hard-capped at 2,000 per site per day.
- GA4 Data API daily token budget (~25K/day free tier; complex reports burn more).
- 4 credential tiers (API-key only, +SA for GSC, +GA4 ID, +Ads tokens). Higher tiers unlock more skills.

## Links
- Repo: https://github.com/AgriciDaniel/claude-seo
- Companion (image gen): https://github.com/AgriciDaniel/banana-claude
- Google Cloud Console: https://console.cloud.google.com
