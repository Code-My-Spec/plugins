---
name: digital-marketing-pro
tier: extension
purpose: enterprise-comprehensive
covers_loops: [acquisition, activation, retention, monetization, referral]
covers_channels: [content, copywriting, seo, social, email, paid, growth, cro, retention, brand, multilingual]
install_command: "/plugin install digital-marketing-pro"
marketplace: "indranilbanerjee/digital-marketing-pro"
auth_required: true
auth_via: many-mcps
detection:
  type: plugin
  installed_plugins_match: ["digital-marketing-pro"]
verification:
  type: skill_present
  skill_path_glob: "~/.claude/plugins/cache/*/digital-marketing-pro/*/.claude-plugin/plugin.json"
---

# digital-marketing-pro

## What it is
Massive plugin: 115 commands, 25 specialist agents, 64 scripts, 67 MCP servers, 143 reference files. Includes eval/QA layer (hallucination detection, claim verification, A+ to F grading) and multilingual support (Sarvam AI, DeepL, Google Cloud Translation). Full execution with approval workflow.

By indranilbanerjee. Aimed at agencies and large marketing operations.

## Skills shipped
- 115 commands across the marketing lifecycle (acquisition, activation, retention, monetization, referral). Categories include content, copy, SEO, social, paid, brand, multilingual, eval/QA.
- 25 specialist agents (research, drafting, review, eval).
- 64 supporting Python scripts.
- 67 MCP servers (you enable a subset based on actual integrations).

(See the plugin's own README for the canonical command list — it's too long to mirror here.)

## When to install
- You run an agency or in-house marketing team at scale.
- You want enforced output evaluation (claim verification, brand compliance, factuality).
- You operate in multiple languages.

## Strategy fit
- **Almost always overkill for solo founders.** 115 commands is a discoverability problem at solo scale.
- **Required if:** agency operation with multilingual marketing AND evaluation requirements.
- **Out-of-scope if:** solo founder, single market, single language.

## Prerequisites
- 67 MCP servers means 67 potential auth flows. Realistically you'd enable a subset.
- Translation services (Sarvam AI, DeepL, GCP Translation) have their own API keys.
- A serious time budget for setup (~hours, not minutes).

## Install steps
1. `/plugin marketplace add indranilbanerjee/digital-marketing-pro`
2. `/plugin install digital-marketing-pro`
3. **Plan which MCPs you actually need** before enabling them. The plugin's docs walk through subset configurations.
4. Restart Claude Code.

## Auth setup
Per-MCP, per-script. Read the plugin's own setup guide — it's substantial.

## Verification
- Plugin installed and the plugin manifest is present in `~/.claude/plugins/cache/...`.
- Spot-check a few of the agents you intend to actually use.

## Conventions to seed
None at this level — the plugin has its own conventions that vary by which MCPs you enable.

## Gotchas
- **Discoverability.** 115 commands means slash-command palette overload. Use `/plugin disable` aggressively for skills you won't use.
- **Auth fatigue.** 67 MCPs is a lot of token rotation and refresh management.
- **Evaluation overhead.** The eval/QA layer adds latency to every output. Useful at scale, friction at solo.
- **Conflict with simpler plugins.** Skills with the same name across plugins create slash-command resolution ambiguity. If you install this alongside marketingskills + claude-seo, plan disambiguation.

## Links
- Source: https://github.com/indranilbanerjee/digital-marketing-pro
