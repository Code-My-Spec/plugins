# Step 6 — Messaging

Translate the positioning canvas into external-facing messaging: headline, sub-headline, pillars mapped to buyer decision criteria, proof points, objection handling, and voice.

**Mode:** Synthesis. Voice-of-customer harvest before drafting. No new research.

**Artifact:** `marketing/06_messaging.md`

## Positioning vs. messaging

- **Positioning** (step 5, internal strategy): how you think about your place in the market — Dunford's 5-component canvas.
- **Messaging** (this step, external language): how you say it to the best-fit customer, in their words.

Not the same artifact. A positioning statement is often too jargony or strategic for a homepage. Messaging is the street-ready version, written in customer vocabulary.

## Inputs

Open all three before writing:

- `marketing/03_personas.md` — especially the **Vocabulary** section (verbatim quotes) and **Top pains**
- `marketing/05_positioning.md` — the 5-component canvas
- `marketing/02_jobs_and_segments.md` — the job-to-be-done

Messaging without them is guessing.

## Voice-of-customer harvest — do this first

Joanna Wiebe's core move (Copyhackers): **mine language, don't write it.** Before drafting anything, pull the raw material.

Quick VOC harvest by business type:

| Business type | Pull from |
|---|---|
| B2B SaaS | 3-star G2 reviews, sales call transcripts (if any), support tickets, cancellation surveys |
| Dev tool | GitHub issues, Stack Overflow threads, Reddit complaints about competitors |
| Local trade | 3-star Google reviews of you + competitors, Houzz project comments, Nextdoor threads |
| Consulting | LinkedIn comments on posts about your topic, podcast Q&As, client interviews if available |
| B2C physical | Amazon 3-star reviews, TikTok/YouTube comment sections on category videos |

Instruct: "pull the exact phrases customers use for the pain, the dream state, and the mechanism." If research in step 3 already yielded a good vocabulary section, pull from there.

Wiebe's **Pain-Dream-Fix** structure maps directly onto headline/sub/pillars:
- **Pain:** the before state, in their words
- **Dream:** the after state, in their words
- **Fix:** the bridge (you)

## Awareness-stage gating (Schwartz) — pick the entry point before drafting

Eugene Schwartz, *Breakthrough Advertising* (1966): the buyer's stage of awareness determines the entry point of the message. The same product needs different messages at different stages. The most common founder mistake: writing for product-aware buyers (people already comparing solutions) because that's the founder's mental state. If the real audience is problem-aware or solution-unaware, that copy lands flat.

Before drafting headlines, classify where the beachhead persona sits.

### The five stages

| Stage | What the buyer knows | Entry point of the message |
|---|---|---|
| **Unaware** | Vague pain or context, doesn't yet name the problem | Lead with the symptom in their words. Don't mention the product. The job is to make them *feel* the cost of the status quo. |
| **Problem-aware** | Names the problem, doesn't know the solution category exists | Lead with the cause / a new framing. Introduce the category as the named answer. |
| **Solution-aware** | Knows solutions exist, doesn't know specific products | Lead with mechanism — why your approach inside the category is different. |
| **Product-aware** | Knows specific products including yours, hasn't picked | Lead with proof and objection-handling. Compare honestly. |
| **Most-aware** | Knows you, ready to act | Lead with the offer, the urgency, the specific next step. |

A homepage that mixes stages confuses everyone. Pick the dominant stage and build from it.

### How to pick the stage

Pull from `marketing/03_personas.md`:
- **Vocabulary section:** do they name the problem in their own words? Do they name solution categories or specific products?
- **Where-to-reach-them:** is the venue one where people are already searching ("X vs Y comparisons"), or one where they're commiserating about the symptom?
- **Buying-behavior:** are they actively evaluating, or passively venting?

Default for new categories: market is mostly **problem-aware** at best. Don't write product-aware copy for an audience that doesn't know the category yet.

Default for mature categories: market is **solution-aware** — they know what category they're shopping in.

### Market sophistication (Schwartz's companion concept)

How crowded is the category? Each entrant must escalate the claim — direct claim → quantified claim → mechanism → refined mechanism → personality/identity. Entering a saturated category with the same claim everyone else makes is a lost fight before it starts.

| Sophistication | Claim type | What still works |
|---|---|---|
| 1 — fresh category | Direct claim ("Lose weight") | Direct claims |
| 2 — claims escalating | Quantified ("Lose 15 lbs in 30 days") | Direct + quantification |
| 3 — claims exhausted | Mechanism ("New X protocol") | Mechanism / how-it-works |
| 4 — mechanisms exhausted | Refined mechanism + identity | Better mechanism + character |
| 5 — fully saturated | Personality / community / narrative shift | Brand identity, community, "the world has changed" framing |

If "AI-powered X" is your claim in 2026, you're at level 4-5. The claim itself doesn't carry; you have to position around mechanism + identity.

### Write the awareness assessment first

Before headline candidates, write to `marketing/06_messaging.md`:

```markdown
## Awareness gating

- **Dominant awareness stage:** [unaware / problem-aware / solution-aware / product-aware / most-aware]
- **Reason from research:** [one line, citing personas]
- **Entry-point implication:** [what the lead message must do at this stage]
- **Market sophistication level:** [1-5]
- **Sophistication implication:** [what claim shapes still work, which are exhausted]
- **What this rules out:** [message types that won't work for this stage]
```

This is the constraint the headline, sub, and pillars must respect. If a draft headline conflicts with the gating, fix the headline (or revisit the gating if research shifts).

## The components

### Headline (1 line, usually ≤ 10 words)

The one sentence that makes the best-fit customer say "that's for me." Test: would they stop scrolling / stop clicking away?

Patterns that work (pick what fits; don't force):

- **Problem-named:** "Your AI code reviews drift on Elixir. Ours don't."
- **Outcome-promised:** "Counters installed in 5 days. Guaranteed."
- **Category-declared:** "The fractional CFO built for seed-stage founders."
- **Against-the-alternative:** "Stone countertops without the 4-week wait."
- **Customer-quote-lightly-edited:** often the strongest — steal directly from VOC

### Harry Dry's specificity check

Strike any headline containing: "solutions," "empower," "streamline," "leverage," "seamless," "best-in-class," "cutting-edge," "next-generation," "transform." These are signs of marketing-speak, not customer speech.

A good headline names at least one of: a concrete outcome, a concrete customer, a concrete mechanism, or a concrete number.

### Sub-headline (1–2 sentences)

Backs up the headline with the ICP and the mechanism. Common pattern:

> **For [best-fit customer]** who **[trigger/JTBD]**. **[Why this works / what's different].**

Examples:
- "For Elixir teams shipping to production. We specialize in Phoenix — not 20 languages — so the reviews actually catch issues."
- "For homeowners remodeling their kitchen. We fabricate in-house, so design changes happen same-day instead of pushing your project 3 weeks."

### Pillars mapped to buyer decision criteria

Three pillars is the convention. Here's the upgrade from naive pillar writing:

**Pillars should map to the top 3 buyer decision criteria or objections** — not to your feature categories. Pull these from `marketing/03_personas.md` buying-behavior section and the value themes from step 5.

For each pillar:

- **Pillar name** (2–4 words, in the persona's vocabulary)
- **Claim** (one sentence — what you do, why it matters)
- **Proof points** (how the claim is substantiated)

Proof types to use (honestly):

- **Numbers / benchmarks** ("Installed in 5 days vs. industry avg 21")
- **Customer quotes** ("'First stone guy who actually showed up on time' — verified Google review")
- **Process / methodology** ("In-house CNC fabrication — not outsourced")
- **Credentials / experience** ("12 years, 400+ kitchens")
- **Guarantees** ("Full refund if we miss the deadline")
- **Work samples** ("Portfolio of 50 completed installs")

**If a pillar has no real proof, cut the pillar or find proof.** Pillars without proof are vaporware.

### Objections → proof table

Wiebe's "False Belief" worksheet and Joel Klettke's objection-mapping — list the top 2–3 reasons a best-fit buyer *wouldn't* buy, and write one proof element for each:

| Objection (verbatim where possible) | Counter-message | Proof |
|---|---|---|
| "Stone installs always run late" | "We guarantee 5 days or refund the deposit" | "3 years, 0 missed deadlines — case log" |
| "You'll disappear after payment" | "Ongoing support for 1 year included" | "Post-install check-in system + 40 5-star follow-up reviews" |

Objections belong on the page. Avoiding them is how trust dies.

### Elevator version (spoken)

2 sentences for when someone asks "what do you do?" This is what the user actually says at a dinner party or on a sales call. It should sound like a human, not ad copy.

### Founder-brand voice

For solo operators and small shops, the **founder is the differentiation** (Dave Gerhardt, *Founder Brand*, 2022). Messaging should sound like one specific human, not a committee. First person. Strong POV. Pull from:

> "What do you believe about this work that most of your competitors don't?"

Feed the answer into pillars or the sub-headline.

## Drafting process

1. **VOC first.** Pull verbatim phrases from step 3 research. Work from customer language, not your own brand voice.
2. **Draft the pillars.** Three value themes from step 5 → three pillars, each mapped to a buyer decision criterion. Verify each has real proof.
3. **Draft the sub-headline.** Name the ICP and the differentiating mechanism.
4. **Draft 3 headline candidates.** Test each against the specificity check and the "could my competitor say this verbatim?" swap test.
5. **Write the elevator version.** Say it out loud. If it sounds like a press release, rewrite.
6. **Map objections.** 2–3 top objections with proof.
7. **Voice and tone notes.** What vocabulary to use, what to avoid.

## Signaling check (Sutherland)

Beyond what the copy literally claims, what does it *signal*? Rory Sutherland (*Alchemy*, 2019): buyers process signals — price, design polish, the company you keep, the depth of writing, willingness to take a strong position — *before* they evaluate claims. Costly signals (things hard for a competitor to fake) are the credible ones.

Once the messaging is drafted, run this check against every public artifact:

- **Tone signal.** Casual + technical = "operator." Polished + corporate = "established." Apologetic = "small / unsure."
- **Depth signal.** Long-form, specific, opinionated = expert. Generic, bullet-list, clichéd = farm content.
- **Visual signal.** Custom illustration / photography = serious. Stock photos = budget. (Pulls from the visual identity in step 5's distinctive assets.)
- **Company-you-keep signal.** Customers mentioned, conferences referenced, peers cited — these signal the league.

Most signal failures are mismatches: a serious technical product paired with stock-photo marketing reads as not-yet-serious to the target buyer. A bootstrapped indie project paired with corporate VC-deck design reads as fake. Get the signals coherent with the positioning before shipping.

## Techniques for getting human language out of founders

Some founders default to marketing-speak when they write. Unstick them:

- **Record, don't type.** "Describe it to your neighbor in a voice memo." Transcribe the audio — the spoken version is almost always sharper than the typed version.
- **Forbid adjectives in the first pass.** Require verbs and nouns only. Adjectives can come back in round 2 if necessary.
- **Ask: "What did your last happy customer literally say to you?"** Use their exact words.
- **Ask: "What do you wish your customers would stop asking?"** Often surfaces the #1 objection in their own words.

## Frameworks to borrow from selectively

- **StoryBrand (Donald Miller)** — useful for the "guide, not hero" posture and the problem-solution-result one-liner. Don't adopt the full 7-part SB7 framework — it flattens positioning work and makes brands sound identical.
- **Andy Raskin's strategic narrative** — use only if the user is in an emerging category or has a strong POV. Five beats: name a shift → stakes of losing → promised land → magic gifts (product) → proof. Overkill for commodity trades.
- **Osterwalder's Value Proposition Canvas** — Jobs / Pains / Gains + Pain Relievers / Gain Creators. Useful upstream as raw-material generator; don't use as the messaging scaffold itself.

## Write the artifact

Write `marketing/06_messaging.md`:

```markdown
# Messaging — [Business name]

## Voice-of-customer vocabulary (from step 3)
- Pain phrases: "[verbatim]", "[verbatim]"
- Dream-state phrases: "[verbatim]", "[verbatim]"
- Solution phrases: "[verbatim]", "[verbatim]"

## Awareness gating
- **Dominant stage:** [unaware / problem-aware / solution-aware / product-aware / most-aware]
- **Reason from research:** [one line, citing personas]
- **Entry-point implication:** [what the lead message must do]
- **Market sophistication level:** [1-5]
- **What this rules out:** [message types that won't work for this stage]

## Headline
**[one line]**

## Sub-headline
[1-2 sentences]

## Elevator version (spoken)
[2 sentences, human-sounding]

## Pillar 1 — [short name, persona vocabulary]
**Maps to buyer criterion:** [which decision criterion or objection this addresses]
**Claim:** [one sentence]
**Proof:**
- [proof point with source]
- [proof point with source]

## Pillar 2 — [short name]
[same structure]

## Pillar 3 — [short name]
[same structure]

## Objections → proof
| Objection | Counter-message | Proof |
|---|---|---|
| [verbatim or close] | [counter] | [evidence] |
| [...] | [...] | [...] |

## Voice and tone
- Use: [key phrases from VOC, founder's natural vocabulary]
- Avoid: ["leverage", "solutions", industry jargon the persona doesn't use]
- Tone: [formal / casual / technical / warm — one label, consistent]
- POV / belief: [what the founder believes that competitors don't — from founder-brand prompt]

## Specificity check
- [ ] Headline contains a concrete outcome, customer, mechanism, or number
- [ ] No marketing-speak banned words present
- [ ] Swap test: could a competitor truthfully use this exact copy? If yes, sharpen.
- [ ] Awareness-gating respected: the lead message matches the persona's stage, not the founder's
- [ ] Signaling check: tone, depth, and visual layer match the positioning (see Signaling check section)
```

## Guardrails

- **No claim without proof.** Cut claims that can't be substantiated.
- **Lead with customer language.** VOC beats creative writing.
- **Kill any sentence that could appear verbatim on a competitor's site.** Swap test.
- **Short over clever.** A blunt line the persona understands beats a clever line that requires decoding.

## Hand off to step 7

> "Messaging done. Now the fun part — picking where you'll actually show up. I'll use Traction's Bullseye framework, biased by where step 3 research said [persona] actually hangs out."

Then load `steps/07_channels.md`.
