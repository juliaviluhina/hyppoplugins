# agent-design-review

One skill. Point it at an agent, skill, or subagent spec — a `SKILL.md`,
subagent frontmatter+prompt, or workflow script — and it checks the spec
against three design properties, each with a pass/fail test and a one-line
fix on failure, rather than a full rewrite.

## Use it when

- "review this agent design"
- "audit this skill/subagent"
- "check this prompt for stopping conditions"
- before shipping a new agent/skill definition

## The three properties

1. **Clear Purpose** — does the spec say *why* the agent exists, not just
   what steps it takes?
2. **Completion Satisfaction** — is there an explicit, checkable definition
   of "done" that isn't just "ran out of steps"?
3. **Renewal/Reset** — does the spec say what carries over vs. resets
   between invocations, so the next run doesn't inherit stale state?

## What it does

1. Reads the target file in full — if it's an overview that defers to other
   files, reads those too before scoring.
2. Scores each property pass/fail per file, citing the specific line or
   absence.
3. Gives a one-line fix per failure.
4. Reports as a table: file | property | pass/fail | evidence | fix. It
   doesn't apply fixes unless you ask it to.

## Install

```
/plugin install agent-design-review@hyppo-plugins
```
