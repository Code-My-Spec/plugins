# Story interview: the first conversation

The first conversation finds everything the person wants their customers to be
able to do, each as a bare story. Rules and scenarios come later, one story at a
time (three-amigos.md). Do not start them here.

## What a story is

- **"As a [human role], I want [goal] so that [business value]."**
- The role is a real person: a customer, an admin, an operator. Never a system,
  an API or a database. If you are tempted to write a technical story, ask who
  the human is that benefits.
- The "so that" is something a non-technical buyer would care about.

Bad: "As a system, I want to sync data so that records are consistent."
Good: "As an operator, I want data to sync by itself so that I never reconcile
records by hand."

## The interview

- Ask who the user is, what they want to do, and why it matters to the business.
- Find what must exist before what (a story that means nothing without another).
- Ask whether a thing belongs to one user or to a whole account.
- Prefer fewer, well-cut stories over many that overlap.
- Check the set covers the whole job, start to finish.

## Done

The person says the list covers what they want. Read it back. Then take the
stories one at a time through three-amigos.md, in the order the person chooses.
