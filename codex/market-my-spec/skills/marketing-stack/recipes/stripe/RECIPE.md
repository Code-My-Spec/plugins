---
name: stripe
tier: core
channel: revenue
loop_fit: [monetization, activation]
primary_mcp_status: official
requires_server_install: false
requires_deploy: false
detection:
  type: mcp
  args_contains: ["@stripe/mcp", "stripe/agent-toolkit"]
  env_var: "STRIPE_RESTRICTED_KEY"
validation:
  type: shell
  command: 'curl -s -u "$STRIPE_RESTRICTED_KEY:" "https://api.stripe.com/v1/subscriptions?limit=1"'
  expect:
    contains: '"object": "list"'
---

# Stripe

## What it is
Stripe read-only MCP for marketing-relevant revenue intelligence. Uses the **official `@stripe/agent-toolkit`** with a restricted API key. Not finance — the marketing slice: new subscriptions, churn, MRR trend, attribution from Checkout metadata.

## Unlocks
- Activities: "Monday revenue standup — net new, churn, MRR delta," "map new subs to UTM source via Checkout metadata," "flag price-point experiments that moved conversion," "trials ending this week"

## Prerequisites
- A Stripe account
- Admin access in Stripe Dashboard to create restricted keys

## Install steps
1. **Create a restricted API key:**
   - Stripe Dashboard → Developers → API keys → Create restricted key
   - Name: `marketing-stack-read`
   - Grant **READ** on: Customers, Subscriptions, Invoices, Checkout Sessions, Charges, Products, Prices, Coupons, Promotion Codes
   - Leave everything else **None**
   - Copy the `rk_live_...` (or `rk_test_...` for dev)
2. **Register the MCP:**
   ```bash
   codex mcp add stripe -- npx -y @stripe/mcp --tools=read_only
   ```
   (The `@stripe/agent-toolkit` ships as `@stripe/mcp` on npm.)
3. Add env vars to `.env`, then name them in `~/.codex/config.toml` (names only — never the key itself):
   ```toml
   [mcp_servers.stripe]
   command = "npx"
   args = ["-y", "@stripe/mcp", "--tools=read_only"]
   env_vars = ["STRIPE_RESTRICTED_KEY", "STRIPE_ACCOUNT_ID"]
   ```
4. Load `.env` and start Codex from that shell (`set -a; . ./.env; set +a` then `codex`).

Undo: `codex mcp remove stripe` + delete the `.env` block. Revoke the restricted key in the Stripe Dashboard if you're done with it for good.

## .env requirements
```
STRIPE_RESTRICTED_KEY=   # rk_live_... read-only restricted key
STRIPE_ACCOUNT_ID=       # acct_... optional, only for Stripe Connect setups
```

## Validation
Ask Codex: "Using the Stripe MCP, list 3 recent active subscriptions." Expect JSON with subscription IDs, customer IDs, prices.

## Conventions to seed
Write `marketing/conventions/revenue.md`:

```markdown
# Revenue conventions (Stripe + HubSpot)

## Attribution at Checkout (critical — set this day 1)
- Every Checkout Session creation sets `metadata[utm_source]`, `metadata[utm_campaign]` from the traffic source.
- Every Customer object sets `metadata[hubspot_contact_id]` when known, for identity resolution.

## HubSpot mirror
- Custom contact property `stripe_customer_id` mirrors the Stripe Customer ID.
- Reverse lookup "Stripe → HubSpot" is O(1) when both are set.

## MRR derivation
- MRR is NOT first-class in Stripe. Derive from:
  - Active subscriptions: sum(item.price.unit_amount × item.quantity) in cents
  - Normalize multi-currency via monthly FX snapshot
- Sigma query is the pragmatic choice for history.

## Monday standup
- Read: new subs (last 7d), churned subs (last 7d), trials ending (next 7d), MRR delta.
- Don't read: revenue by product (that's finance).

## Key rotation
- Rotate restricted key every 6-12mo or after any suspected leak.
- Use test-mode key (`rk_test_...`) during local dev.
```

## Gotchas
- 100 read req/sec live, 25/sec test. Paginate via `starting_after`.
- Attribution only works if `metadata` is set at Checkout creation. Retrofitting is impossible.
- `canceled_at` ≠ `ended_at`. First is user click, second is access lapse.
- Multi-currency: `unit_amount` is smallest unit (cents, yen, etc.) — no automatic FX.
- Restricted keys can be revoked / rotated without downtime.

## Links
- Source: https://github.com/stripe/agent-toolkit
- API reference: https://stripe.com/docs/api
- Restricted keys: https://stripe.com/docs/keys#limit-access
