# market-my-spec

Use Claude Code as your marketing strategist. Guided 8-step strategy flow that interviews you, dispatches research agents for customer personas and competitive alternatives, then synthesizes positioning, messaging, channels, and a 90-day plan.

Industry-agnostic — works for software founders, consultants, trades, services, and B2C operators.

## Install

From a Claude Code session:

```
/plugin marketplace add Code-My-Spec/plugins
/plugin install market-my-spec@codemyspec
```

## Run

```
/marketing-strategy
```

First run: full 8-step flow from scratch. Later runs: iteration mode — reads existing `marketing/` files, asks what's changed, updates in place.

## The 8 steps

| # | Step | Mode | Framework anchors |
|---|---|---|---|
| 1 | Current state | Interview | Mom Test (Fitzpatrick), Shape Up appetite/no-gos, Lean Canvas |
| 2 | Jobs & segments | Interview | Moesta Switch Interview, Ulwick Outcome-Driven Innovation |
| 3 | Persona research | Research agents | Verbatim VOC mining; vertical-specific sources; confidence rubric |
| 4 | Beachhead | Synthesis | Moore's 9-point checklist, Aulet graduation criteria |
| 5 | Positioning | Synthesis + light research | Dunford's 5-component canvas |
| 6 | Messaging | Synthesis | Wiebe / Copyhackers VOC mining; Harry Dry specificity |
| 7 | Channels | Synthesis + light research | Weinberg Bullseye, 24-channel 2026 list |
| 8 | 90-day plan | Synthesis | Shape Up 6-week cycles, Hacking Growth North Star |

## Artifacts

Writes to your project's `marketing/` directory:

```
marketing/
├── 01_current_state.md
├── 02_jobs_and_segments.md
├── 03_personas.md
├── 04_beachhead.md
├── 05_positioning.md
├── 06_messaging.md
├── 07_channels.md
├── 08_plan.md
└── research/
    ├── persona_<segment>.md
    ├── alternatives.md
    ├── competitor_positioning.md
    └── channel_<name>.md
```

## Business types supported

Adapts examples, research sources, channel defaults, and metrics by type:

- **Software / SaaS / dev tools**
- **Local trades** (granite, HVAC, roofing, etc.)
- **Consulting / professional services**
- **Prosumer / creator**
- **B2C physical / DTC**
