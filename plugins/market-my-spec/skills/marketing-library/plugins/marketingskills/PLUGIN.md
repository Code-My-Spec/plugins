---
name: marketingskills
tier: core
purpose: thinking-layer
covers_loops: [acquisition, activation, retention, monetization, referral]
covers_channels: [content, copywriting, seo, social, email, paid, growth, cro, retention]
install_command: "/plugin install marketing-skills"
marketplace: "coreyhaines31/marketingskills"
auth_required: false
detection:
  type: plugin
  installed_plugins_match: ["marketing-skills", "marketingskills"]
verification:
  type: skill_present
  skill_path_glob: "~/.claude/plugins/cache/*/marketing-skills/*/skills/copywriting/SKILL.md"
---

# marketingskills

## What it is
40 marketing playbook skills covering CRO, copywriting, SEO methodology, content strategy, paid ads, growth tactics, retention, and pricing. **Pure playbooks** — no MCPs, no API setup, no auth. Skills are markdown frameworks the LLM applies to your context.

By Corey Haines (Conversion Factory / Swipe Files). Heavily adopted, actively maintained.

## Skills shipped (groups)

- **CRO (6):** page-cro, signup-flow-cro, onboarding-cro, form-cro, popup-cro, paywall-upgrade-cro
- **Content & copy (5):** copywriting, copy-editing, cold-email, email-sequence, social-content
- **SEO & discovery (6):** seo-audit, ai-seo, programmatic-seo, site-architecture, competitor-alternatives, schema-markup
- **Paid & distribution (3):** paid-ads, ad-creative, social-content
- **Measurement (2):** analytics-tracking, ab-test-setup
- **Retention (1):** churn-prevention
- **Growth & strategy (multiple):** free-tool-strategy, referral-program, marketing-ideas, marketing-psychology, launch-strategy, pricing-strategy, revops, sales-enablement, customer-research, content-strategy, competitor-profiling, directory-submissions, lead-magnets, aso-audit, plus product-marketing-context (foundation)

## When to install
- Almost always — it's the playbook-layer default for marketing-my-spec users.
- Especially valuable when strategy includes any of: CRO, copywriting, content, growth experimentation, paid acquisition.

## Strategy fit
- **Required if:** strategy lists content, copy, CRO, or growth as inner-ring concerns.
- **Nice-to-have if:** strategy is narrowly focused (e.g., one-channel beachhead) but copy/CRO will eventually matter.
- **Out-of-scope if:** never (it's playbook reference material; even narrow strategies benefit from a few skills).

## Prerequisites
- None. Pure markdown skills — no API keys, no auth, no system dependencies beyond Claude Code.

## Install steps
1. `/plugin marketplace add coreyhaines31/marketingskills` (if marketplace not already added)
2. `/plugin install marketing-skills`
3. Restart Claude Code so the skills register.

## Auth setup
None.

## Verification
After install:
- `~/.claude/plugins/installed_plugins.json` should list marketing-skills.
- `~/.claude/plugins/cache/*/marketing-skills/*/skills/copywriting/SKILL.md` should exist.
- Slash command `/copywriting` should appear in your palette.

## Conventions to seed
None this skill seeds directly. Marketing-strategy and daily-plan reference these skills naturally.

## Gotchas
- 40 skills can crowd the slash command palette. If a few feel like noise, `/plugin disable marketing-skills:<skill-name>` per-skill.
- Skills use a shared `product-marketing-context` foundation skill — make sure your project has at least basic context (the marketing-strategy 8-step output covers this).

## Links
- Source: https://github.com/coreyhaines31/marketingskills
- Author: Corey Haines (Conversion Factory)
