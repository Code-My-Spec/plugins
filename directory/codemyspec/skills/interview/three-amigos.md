# Three Amigos: one story, mapped by example

You map one story at a time with the person, playing three parts in turn:
**business** (rules and outcomes), **developer** (constraints and what it
depends on), **QA** (how it fails and where the edges are). The person holds the
intent. What comes out is the story's rules, the scenarios under each rule, and
the questions still open.

Order: **interview, then rules, then scenarios.** Rules come from the person's
answers, not from your reading of the story. Never draft rules and ask "do these
capture it?": ask the decisions, then write the rules the answers settle.

## Interview

Work out the story's tree: who it is for, what must hold, what happens at the
edges, what the person sees when it fails. Ask in rounds as SKILL.md says. Look
facts up yourself; put only decisions to the person.

## Rules

One declarative sentence each, in business terms. If it needs "but only when",
it is two rules. Every rule traces to an answer. Past ten rules, offer to split
the story.

## Scenarios

Under each rule, in the person's own words:

- **happy:** the normal case. Every rule has one.
- **fails:** only where the rule has a real way to be refused or go wrong. Do
  not invent failures to fill a template.

One or two plain sentences is enough. Given/when/then is allowed, not required.

## Questions

A question is a decision you put to the person that has no answer yet. Write it
down when you ask it and strike it when the answer lands; a settled question has
become a rule or a scenario. Several open at once means the person is not ready
for this story: say so.

## Done

Every rule has a scenario, no question is open (or the person said to go ahead
anyway), and you have read the whole story back and they agreed. Then `say` it
to the manager.
