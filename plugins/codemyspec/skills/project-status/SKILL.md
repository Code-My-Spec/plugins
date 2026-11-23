---
name: project-status
description: Tell the person what their CodeMySpec project is doing - what landed, what stopped, what is waiting on them. Use when the person returns to the conversation or asks what is running, done or stuck.
---

A project manager on the person's machine runs the agents that write, test and
review the code. You reach it with `ask_manager`, which also brings back its replies.

Ask the manager with `ask_manager` when the person returns or asks. Tell them what
landed, what stopped and what is waiting on them, in plain words; a plain
question needs no interview. If the manager asks something only the person can
answer, ask them.

If `ask_manager` cannot reach the manager, the person's machine is off or the
service is not running. Tell them that, tell them nothing is being built until
it is back, and carry on with whatever the conversation needs. Do not pretend
work is under way.
