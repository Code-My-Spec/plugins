# Step 0 — Brand & Founder Story

Establish brand foundations before customer research. The WHY, the founder's lived credibility, the operating philosophy, the tone, and a first-pass visual identity. This is the layer everything downstream (positioning, messaging, channels, content) inherits from.

**Mode:** Interview + synthesis + design generation. Different from the other steps — you'll generate or specify visual artifacts here, not just write a markdown file.

**Artifact:** `marketing/00_brand.md` (plus generated design assets in `marketing/brand/` if produced)

## Why this step first

Steps 1-8 produce a customer-validated strategy. They don't surface *who the founder is* and *why this work matters to them*. That layer — the WHY, the founder story, the brand test — is what makes downstream content feel like a specific human, not a committee. Skipping it is how solo-founder marketing ends up sounding generic even when the strategy is sharp.

This step answers four questions the customer-discovery flow can't:

1. Why does this business exist beyond making money?
2. What lived experience earns the founder the right to make these claims?
3. What does the brand feel like when you see it (visual identity)?
4. What would the founder refuse to do, even if it converted?

**Two-pass note.** You'll define a *first-pass* visual identity here. Step 5 component 7 (Distinctive brand assets) refines it once positioning is set. Don't over-engineer this pass — get it good enough to inform the next 7 steps.

## Pre-fetch (before asking)

- Existing brand assets if any (logo files, brand books, color palette docs)
- The user's About page, LinkedIn profile, GitHub bio, Twitter bio
- Any prior interviews, podcasts, or blog posts where the founder explains themselves
- Existing visual identity from other tools (AI design-tool output, Figma files, Dribbble shots, hired-designer deliverables)

**If visual identity work has already been done elsewhere (a design tool, Figma, a hired designer), pull those assets and don't redo them. Capture them in this artifact and reference the source.** The job here is consolidation, not regeneration.

## Interview — the WHY

> "Why does this business exist beyond making money? If you sold it tomorrow for enough money to retire, what would still be unfinished?"

Push past the first answer. The first answer is usually a product description ("I want to make X easier"). The real WHY is below — about who they want to empower, what kind of world they want to live in, what wound or lucky break drove them to this work.

> "Has anyone in your life been on the receiving end of you trying to make this happen at a smaller scale? A direct report, a student, a family member, a community?"

Concrete people make the WHY credible. Vague mission statements don't survive Reddit.

## Interview — founder lived credibility

> "Walk me through the path that got you to this work. What hardships, what mentors, what lessons? Specific people, places, jobs, businesses — not a CV."

You're looking for the experience layer that earns the brand the right to claim its position.

> "What do you have direct experience of that most of your competitors don't?"

This is the unfair-credibility line. For a granite installer who used to be a kitchen designer, that's the angle. For a SaaS founder who built and ran a manufacturing IT department, that's the angle. For a consultant who actually held the operating role they now advise on, that's the angle.

## Interview — operating philosophy / signature phrase

> "Is there a phrase, idea, or principle you've operated by — that you've already said out loud to people you've taught or worked with — that captures how you think this kind of work should be done?"

You're looking for the signature phrase. Real example: a founder's leadership line to his first direct report — *"You can't break it so bad I can't fix it. Just try things and learn"* — turned out to be the exact promise his product made to its users. The line existed before the brand; the brand inherited it.

If they don't have one, drop it. A forced signature phrase is worse than no signature phrase.

## Interview — tone

> "Read three pieces of writing in your industry. Which ones make you cringe? Which ones feel right? What's the difference?"

Concrete writing samples beat abstract tone descriptors. "Sounds like Patrick McKenzie's blog" is a useful answer; "professional but approachable" is not.

> "Are you funny? Self-deprecating? Earnest? Sardonic? Be honest. Founders who claim to be funny in their copy when they aren't make terrible copy."

> "What words, phrases, or tropes do you actively want to avoid — even if they 'convert'?"

The avoid-list is as load-bearing as the do-list.

## Interview — visual feeling

> "If your brand were a place, what kind of place? A used car dealership, a modernist art museum, a craftsman's workshop, a software company in the 90s, a Brooklyn coffee shop, a Japanese stationery store?"

> "Pick 3-5 brands or websites whose visual feel you respect. What do they share?"

> "What do you actively NOT want to look like? Other companies in your category? VC-funded startups? Corporate enterprise software? AI-hype landing pages?"

Now you have raw material for visual generation.

## Brand test (the filter)

Synthesize everything above into a single test sentence. Format:

> "Does this empower [the WHY's beneficiary] to [achieve the WHY's outcome]? If yes, ship it. If it serves a bigger audience by making them more dependent on a gatekeeper (us included), rethink."

The brand test is what every piece of downstream content gets checked against. If a tactic converts but fails the brand test, the test wins. (If the test never wins anything, it's not a real test — sharpen it.)

## Where the brand shows up vs. doesn't

Not everything wears the brand the same way. Be explicit:

- **Brand-forward:** about page, podcast appearances, long-form content, speaking, internal-team docs.
- **Brand-light:** homepage hero (if too earnest would alienate the ICP), Reddit comments (substance only — Reddit smells performance), short-form social.
- **Brand-absent:** technical docs, SDK reference, pricing comparisons. These compete on their own merits.

Founders default to "brand everywhere." Wrong. Brand belongs where it earns the engagement, not where it might cost a conversion.

## Visual identity — first pass

Generate (or capture, if already done) the visual layer.

**If visual identity already exists** (design-tool output, Figma file, hired designer deliverables): capture the existing color hex codes, font names, logo files, and design rules into the artifact. Reference the source ("colors from the design-tool session 2026-04-15"). Skip generation.

**If no visual identity exists yet:** produce a first-pass spec, plus generation prompts for downstream tools.

### Color palette

Generate 4-6 hex codes with explicit justification per color:

- **Primary** — the dominant brand color. What mood / association does this carry, and why does it match the brand?
- **Secondary** — complementary, used for variety / accents.
- **Neutral pair** — light + dark for body text, backgrounds.
- **Accent / alert** — used sparingly, for CTAs or critical UI.

Justify against the visual-feeling interview answers. *"Forest green primary because the brand-as-place answer was 'a craftsman's workshop' and forest green carries the artisan/operator association without being twee"* beats *"forest green because we like green."*

### Typography

Pick 1-2 typefaces with justification:

- **Display / heading** — what character does this convey?
- **Body** — readability + tone match

Default to Google Fonts (free, web-safe). Pairing patterns that work:
- *Technical / clean:* Inter + IBM Plex Mono
- *Editorial / serious:* Söhne + Tiempos (or free alternatives: Geist + Source Serif)
- *Warm / professional:* Work Sans + Lora
- *Anti-corporate / handmade:* Space Grotesk + JetBrains Mono

### Logo / wordmark

Describe the concept in detail. You can't produce a final SVG inside this skill alone, but you can:

- Specify the type: wordmark / lettermark / icon-and-wordmark / icon-only
- Describe the visual treatment (geometric? handwritten? monospace? italic? all-caps?)
- Suggest 2-3 directions for a designer or design tool to execute
- Provide a generation prompt for an AI design tool / Midjourney / Figma AI

### Imagery direction

What kind of images go with this brand?

- **Photography style** — documentary, polished, candid, studio, none
- **Illustration style** — none, geometric, hand-drawn, technical-diagram, retro
- **Iconography** — Heroicons, Tabler, Lucide, Phosphor, custom

### Design guidelines (DO / DON'T)

The compressed brief a designer or content tool can apply without re-reading the whole artifact:

- **DO:** [3-5 specific things, e.g., "Use plenty of whitespace. Bias toward editorial layout over dense feature grids. Specifics over adjectives in copy. Real customer names, real numbers."]
- **DON'T:** [3-5 specific things, e.g., "No stock photography of diverse people in conference rooms. No gradient hero backgrounds. No 'best-in-class' / 'leverage' / 'empower' / 'seamless'. No AI-generated illustrations of robot hands and human hands touching."]

## Design tool handoff

If the user hasn't done visual identity work elsewhere, provide ready-to-paste prompts for downstream tools.

### AI design tool prompt template

```
Brand: [name]
Mission: [WHY in one sentence]
Audience: [persona summary — leave placeholder if pre-research]
Visual feel: [the place metaphor + 2-3 reference brands]
Specifically NOT: [the avoid list]

Produce:
1. Color palette (4-6 colors, hex codes, with justification per color)
2. Typography pair (display + body, Google Fonts preferred)
3. Logo concept — [type: wordmark/lettermark], [direction: e.g. "geometric, confident, slightly retro"]
4. One landing-page hero composition demonstrating the system
```

### Midjourney / image-gen prompt template

```
Logo concept for [brand name], [type: wordmark/lettermark], [character: e.g., "geometric, confident, slightly retro"], minimal, two-color palette using [#hex1] and [#hex2], white background, no tagline, vector-style, --no text-effects, drop-shadow, gradient
```

### Figma / hired-designer brief

Hand the designer the `marketing/00_brand.md` artifact directly. It gives them everything except aesthetic execution: WHY, audience, visual feel, avoid list, palette draft, typography draft, logo direction, design guidelines.

## Try the design directly (if tooling is available)

If the user wants you to produce visual assets in this conversation:

- Generate hex codes, font names, layout descriptions, logo concept text directly into the artifact.
- For actual visual generation, use whatever image-generation tool is available in the session (e.g., an image-gen MCP server, Midjourney, or a design subagent).
- Save generated assets to `marketing/brand/` (e.g., `marketing/brand/logo-concept-1.png`, `marketing/brand/palette.png`, `marketing/brand/hero-mockup.png`).
- Always include the prompt used + the justification next to the asset, so a future designer can iterate or replace.

If no image-generation tool is available, output the prompts and tell the user to run them in their tool of choice. Don't fake images by describing what they would look like as if they exist.

## Write the artifact

Write `marketing/00_brand.md`:

```markdown
# Brand & Founder Story — [Business name]

## The WHY
> [one-sentence mission, in the founder's words]

[Two-paragraph elaboration. Concrete people, places, lessons. Not abstract values.]

## Operating philosophy / signature phrase
> "[the line]"

[Why this line, what it captures, where it shows up downstream — about page anchor, podcast opener, long-form lede, etc. Or "no signature phrase yet" — don't fabricate.]

## Founder lived credibility
- [proof point — specific, e.g., "Manufacturing IT at Enova Premier, 2014-2019"]
- [proof point]
- [proof point]

**What this means strategically:**
1. [implication for tone — e.g., "We can talk to engineers without condescension"]
2. [implication for positioning — e.g., "Anti-enterprise framing is credible"]
3. [implication for content — e.g., "Teaching is a real asset, not a marketing pose"]

## Where the brand shows up
**Brand-forward:** [list of surfaces]
**Brand-light:** [list]
**Brand-absent:** [list]

## Tone implications
- [direct guidance, e.g., "First-person, lived experience. 'After six months of teaching myself...' is the founder's voice."]
- [what to avoid, e.g., "Hates 'lights out software factory' — reads as anti-human."]

## Brand test
> "Does this empower [WHY beneficiary] to [WHY outcome]? If yes, ship it. If it serves a bigger audience by making them more dependent on a gatekeeper (us included), rethink."

## Visual identity (first pass)

### Source
[Generated this session / Design tool [date] / Figma [link] / Hired designer [name+date]]

### Colors
| Role | Hex | Justification |
|---|---|---|
| Primary | #...... | [why] |
| Secondary | #...... | [why] |
| Neutral light | #...... | [why] |
| Neutral dark | #...... | [why] |
| Accent | #...... | [why] |

### Typography
- Display: [font name] — [why]
- Body: [font name] — [why]

### Logo / wordmark concept
[Type + visual treatment + 2-3 direction options + generation prompt for downstream tools]

### Imagery
- Photography: [style or "none"]
- Illustration: [style or "none"]
- Iconography: [system]

### Design guidelines
**DO:**
- [...]
- [...]
- [...]

**DON'T:**
- [...]
- [...]
- [...]

### Generated / linked assets
- `marketing/brand/[file]` — [description, prompt used or source]

## One-paragraph summary (for re-use)
> [Paragraph that can be pasted into other docs as the brand intro. Self-contained. Concrete.]
```

## Guardrails

- **Lived experience over aspiration.** If the founder hasn't done the thing they want to claim credibility for, leave it out. Manufactured credibility breaks at the first DM.
- **No invented signature phrases.** If the founder doesn't say it in real life, don't put it in the artifact.
- **Capture > regenerate.** If visual identity exists from another tool, reference it. Don't redo it for completeness.
- **First pass, not final pass.** Step 5 component 7 will refine the distinctive assets once positioning is set. Don't get stuck in this step trying to perfect.
- **Brand test must rule things out.** If the test approves everything, it's not a test — sharpen it.

## Hand off to step 1

> "Brand foundations down. Now I'll work through the customer side — what you do, who you serve, what you've tried. Step 5's positioning will refine the distinctive assets given the audience; for now, we're locked on the WHY."

Then load `steps/01_current_state.md`.
