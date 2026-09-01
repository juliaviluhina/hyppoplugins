# conversation-to-skill

One skill. Point it at a conversation you just finished — or a pasted transcript —
and it writes a reusable Claude Code skill from what actually happened: the
repeatable steps, the exact commands, and the corrections you made along the way
(those become the edge cases).

## Use it when

- "turn this conversation into a skill"
- "make this a skill"
- "save this workflow as a skill"

## What it does

1. Reads the conversation and separates the repeatable task from the one-off
   specifics.
2. Asks up to ~3 clarifying questions (name, scope, where to install).
3. Writes `SKILL.md` in the correct format, with edge cases drawn from your
   corrections and at least one worked example.
4. Tests that it loads and that following it would reproduce the good outcome.

It writes a skill for a workflow that *worked*. If the conversation ended in
failure it says so rather than encoding speculation.

## Install

```
/plugin install conversation-to-skill@hyppo-plugins
```
