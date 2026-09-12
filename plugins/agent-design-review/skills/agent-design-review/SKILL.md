---
name: agent-design-review
description: >-
  Review an agent, skill, or subagent spec against three design properties —
  Clear Purpose, Completion Satisfaction, Renewal/Reset — and flag gaps with
  a concrete fix per gap. Use when asked to "review this agent design",
  "audit this skill/subagent", "check this prompt for stopping conditions",
  or before shipping a new agent/skill definition.
---

# agent-design-review

Reviews a target (SKILL.md, subagent frontmatter+prompt, or workflow script)
against three properties. Each property has a pass/fail test and, on fail, a
one-line fix — not a rewrite of the whole spec.

## Properties and tests

1. **Clear Purpose** — does the spec state *why* the agent exists (the
   problem it serves), not just the actions it takes or the metric it
   optimizes? Fail if the spec is a list of steps/tools with no stated intent
   a reader could reason from in an unanticipated case.
   Fix: add one sentence naming who/what the agent serves and what "serving
   it well" means, above the step list.

2. **Completion Satisfaction** — is there an explicit, agent-checkable
   definition of "done" (or "good enough") that isn't just "ran out of
   steps"? Fail if the spec has no stop condition, or the only stop condition
   is exhausting a loop/budget rather than meeting a standard.
   Fix: add a concrete done-check ("stop when X holds") and, where relevant,
   an escalate-instead-of-guess path for cases outside that check.
   For a long-running or open-ended task specifically: fail if the done
   condition is only checkable *after* work happens (e.g. only a stop-list at
   the end of a lifecycle diagram), with nothing forcing it to be written
   down *before* the loop starts. A stop-condition list defined once for the
   whole skill (not re-derived per run) still passes — the requirement is
   that the threshold exists ahead of the loop, not that it be re-stated each
   time.
   Fix: add a step at the start of the loop that states or confirms the
   done/good-enough threshold for *this* run before work begins.

3. **Renewal/Reset** — does the spec say what happens to state between
   invocations or tasks (context cleared, files closed, ledger written) so
   the next run doesn't inherit stale assumptions? Fail if a long-running or
   repeatable skill/agent has no mention of what carries over vs. resets.
   Fix: add one line naming what persists (e.g. a ledger file) and confirming
   everything else is discarded.
   For a task in a loop or multi-task workflow specifically: fail if reset is
   only implied by "start a new session/file" with no explicit check that
   stale assumptions, partial state, or a prior task's scope don't leak into
   the next iteration.
   Fix: add an explicit pre-flight line at the top of each iteration: what
   from the previous task is discarded vs. what's the deliberately-carried
   input (e.g. a ledger), so reset isn't merely assumed from file boundaries.

## Steps

1. Read the target file in full. If it is a map/overview (it names other
   files as "owning" a rule, section, or mechanic rather than stating the
   rule itself), treat the target as that whole file set: also read every
   file it points to before scoring. Do not stop at the entry file just
   because it itself passes all three properties — an overview passing
   "Clear Purpose" by deferring to owning files is only a real pass if those
   files exist and hold up.
2. Score each of the 3 properties pass/fail per file, with a one-sentence
   reason citing the specific line or absence.
3. For each fail, give the one-line fix above — don't redesign unasked parts
   of the spec.
4. Report as a short table: file | property | pass/fail | evidence | fix (if
   fail). Don't apply fixes unless asked.
