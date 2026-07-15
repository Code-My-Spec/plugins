---
name: google-apis
tier: core
channel: seo
loop_fit: [acquisition, activation]
primary_mcp_status: direct-api
requires_server_install: false
requires_deploy: false
detection:
  type: file
  file_path: "~/.config/marketing-stack/google-api.json"
  env_var: "GOOGLE_API_KEY"
validation:
  type: shell
  command: 'curl -s "https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=https://example.com&key=$GOOGLE_API_KEY"'
  expect:
    contains: '"lighthouseResult"'
---

# Google APIs (SEO + analytics foundation)

## What it is
The shared Google credential every other Google-shaped activity reuses. **One** Google Cloud project, **one** service account, **one** API key — covering:

| Surface | Auth | Used for |
|---|---|---|
| Search Console (GSC) | service account | impressions, clicks, queries, indexation |
| Analytics Data API (GA4) | service account | sessions, conversions, channel attribution |
| PageSpeed Insights | API key | lab Core Web Vitals |
| Chrome UX Report (CrUX) | API key | field Core Web Vitals |
| YouTube Data + Analytics | OAuth client in the same project | the `youtube` recipe |

⚠️ **Codex CLI only** (Bash + curl). There is no MCP for this set — these are REST calls, so this recipe does not travel to MCP-only clients. Install it **first**: doing it once here means `youtube` and every SEO activity skip their own credential setup.

## Unlocks
- Activities: "weekly GSC query report — what are we ranking for," "GA4 channel attribution review," "Core Web Vitals check on money pages," "indexation audit," "which pages lost impressions this month"
- Downstream: the `youtube` recipe reuses this project's OAuth consent screen and API key.

## Prerequisites
- A Google account with access to the properties you want to read
- **Owner** on the Search Console property (to grant the service account access)
- **Editor** or higher on the GA4 property
- `gcloud` CLI installed (`brew install google-cloud-sdk`) — used to mint access tokens from the service account

## Install steps
1. **Create the Google Cloud project:**
   - https://console.cloud.google.com/projectcreate → name it `marketing-stack`
   - Note the Project ID (not the display name — it's the one with the random suffix).
2. **Enable the APIs** — APIs & Services → Library → enable each:
   - Google Search Console API
   - Google Analytics Data API
   - PageSpeed Insights API
   - Chrome UX Report API
   - (YouTube Data API v3 + YouTube Analytics API too, if you plan to run the `youtube` recipe.)
3. **Create the service account:**
   - IAM & Admin → Service Accounts → Create service account
   - Name: `marketing-stack-reader`. No project roles needed — access is granted per-property, not via IAM.
   - Open it → Keys → Add key → Create new key → **JSON** → download.
   - Store it outside the repo and lock it down:
     ```bash
     mkdir -p ~/.config/marketing-stack
     mv ~/Downloads/<downloaded>.json ~/.config/marketing-stack/google-api.json
     chmod 600 ~/.config/marketing-stack/google-api.json
     ```
   - Copy the service account's email (`marketing-stack-reader@<project>.iam.gserviceaccount.com`) — the next two steps need it.
4. **Grant the service account access to your properties** (this is the step people miss — enabling the API is not access):
   - **Search Console:** property → Settings → Users and permissions → Add user → paste the service account email → **Full** (needs Full, not Restricted, for the Search Analytics API).
   - **GA4:** Admin → Property access management → `+` → paste the service account email → **Viewer**.
5. **Create the API key** (for PageSpeed + CrUX, which don't take a service account):
   - APIs & Services → Credentials → Create credentials → API key
   - Edit it → Restrict key → API restrictions → allow only PageSpeed Insights API + Chrome UX Report API. An unrestricted key is a standing liability.
6. **Save env vars to `.env`.** No MCP registration — this recipe is Bash + curl. Load `.env` into your shell before running calls:
   ```bash
   set -a; . ./.env; set +a
   ```

Undo: delete the `.env` block, delete `~/.config/marketing-stack/google-api.json`, and delete the service account + API key in the Cloud Console (deleting the local file alone does not revoke anything).

## .env requirements
```
GOOGLE_APPLICATION_CREDENTIALS=   # ~/.config/marketing-stack/google-api.json (absolute path)
GOOGLE_API_KEY=                   # API key for PageSpeed + CrUX
GSC_SITE_URL=                     # exactly as GSC shows it: https://example.com/ or sc-domain:example.com
GA4_PROPERTY_ID=                  # numeric, GA4 Admin → Property Settings (not the G-XXXX measurement ID)
```

The JSON key file stays at that path and is referenced by path — never paste its contents into `.env` or `~/.codex/config.toml`.

## Validation
API key path (no auth dance — this is the frontmatter validation):
```bash
curl -s "https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=https://example.com&key=$GOOGLE_API_KEY"
```
Expect JSON containing `"lighthouseResult"`.

Service-account path — mint a token, then hit GSC:
```bash
gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"
TOKEN=$(gcloud auth print-access-token)
curl -s -H "Authorization: Bearer $TOKEN" "https://www.googleapis.com/webmasters/v3/sites"
```
Expect a `siteEntry` array that **includes `GSC_SITE_URL`**. If the array is empty or missing your site, step 4 didn't take — the credential is valid but has no property access.

GA4:
```bash
curl -s -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  "https://analyticsdata.googleapis.com/v1beta/properties/$GA4_PROPERTY_ID:runReport" \
  -d '{"dateRanges":[{"startDate":"7daysAgo","endDate":"today"}],"metrics":[{"name":"sessions"}]}'
```
Expect a `rows` array with a session count.

## Conventions to seed
Write `marketing/conventions/seo.md`:

```markdown
# SEO + analytics conventions

## One project, one credential
- All Google surfaces (GSC, GA4, PageSpeed, CrUX, YouTube) authenticate against the same Cloud project.
- Adding a Google surface = enable the API in that project. Never a second project, never a second key.

## Property identifiers
- GSC site URL is exact-match and format-sensitive: `sc-domain:example.com` (domain property) and
  `https://example.com/` (URL-prefix property) are different properties with different data.
- GA4 wants the numeric property ID, not the `G-XXXXXXX` measurement ID. Mixing them up is the #1 400-error.

## Reporting cadence
- Weekly: top queries by impression delta, pages that gained/lost clicks.
- Monthly: indexation coverage, Core Web Vitals on money pages (CrUX field data, not lab).
- Lab (PageSpeed) is for debugging; field (CrUX) is what Google actually ranks on. Don't confuse them.

## Query discipline
- GSC data lags 2-3 days. "Yesterday" is always empty — don't read it as a traffic drop.
- GSC caps at 25k rows/request and samples above that; paginate with `startRow` for full pulls.
- Attribute conversions in GA4, not GSC. GSC has no revenue.

## Key hygiene
- Service account JSON lives at ~/.config/marketing-stack/google-api.json, chmod 600, never in the repo.
- API key restricted to PageSpeed + CrUX only.
- Rotate the JSON key every 6-12mo or immediately on suspected leak (Cloud Console → Keys → delete + recreate).
```

## Gotchas
- **Enabling an API is not the same as granting access.** The service account must be added as a user on the GSC property and the GA4 property separately. Symptom: valid token, empty `siteEntry` array, 403 on GA4.
- **GSC needs "Full" permission**, not "Restricted", for the Search Analytics API. Restricted silently returns nothing useful.
- **`sc-domain:example.com` vs `https://example.com/`** are distinct properties. Copy the string exactly as GSC displays it.
- GA4 numeric property ID ≠ `G-XXXXXXX` measurement ID.
- Service account keys don't expire but can be revoked or deleted. `gcloud auth print-access-token` mints a 1-hour token — re-mint per session, don't cache it in `.env`.
- Default quotas are generous for a solo founder (GSC 1200 req/min; PageSpeed 25k/day) but PageSpeed without a key is 1 req/sec and throttles fast — always pass the key.
- CrUX only has field data for pages with enough real traffic. No data ≠ good scores; low-traffic pages simply won't appear.
- **This is a Bash recipe.** Nothing here surfaces as MCP tools.

## Links
- Search Console API: https://developers.google.com/webmaster-tools/v1/api_reference_index
- GA4 Data API: https://developers.google.com/analytics/devguides/reporting/data/v1
- PageSpeed Insights API: https://developers.google.com/speed/docs/insights/v5/get-started
- CrUX API: https://developer.chrome.com/docs/crux/api
- Service accounts: https://cloud.google.com/iam/docs/service-account-overview
