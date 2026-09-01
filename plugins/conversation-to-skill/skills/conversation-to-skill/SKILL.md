---
name: conversation-to-skill
description: Distill the current (or a pasted) conversation into a reusable Claude Code skill — extract the repeatable workflow, ask clarifying questions, write SKILL.md in proper format with edge-case examples, and test it. Use when asked "turn this conversation into a skill", "make this a skill", or "save this workflow as a skill".
---

# conversation-to-skill

Convert a finished conversation into a reusable skill definition. The source is
the conversation itself: what was actually done, in what order, what went wrong,
and what corrections the user made along the way. Corrections are the most
valuable input — they are the edge cases the skill must encode.

## Steps

1. **Read the conversation as context.** Identify:
   - the repeatable task (not the one-off specifics of this session),
   - the concrete steps and commands that worked,
   - dead ends and user corrections (these become warnings/edge cases),
   - inputs the skill will need each time (file paths, arguments, flags).
   If the user points at a transcript file or note instead, read that.

2. **Ask clarifying questions** (use AskUserQuestion, max ~3):
   - skill name and one-line trigger phrasing,
   - scope: exactly what happened here, or the generalized workflow?
   - where it goes: a project skill (`.claude/skills/` in this repo), a personal
     skill (`~/.claude/skills/`), or a skill inside a plugin
     (`<plugin>/skills/`).
   Skip questions whose answers are obvious from the conversation.

3. **Write the skill** at `<location>/<name>/SKILL.md`:
   ```markdown
   ---
   name: <kebab-case-name>
   description: <what it does + "Use when ..." trigger phrases>
   ---

   # <name>

   <One short paragraph: purpose and the key principle.>

   ## Steps
   1. ...numbered, concrete, with exact commands/tools...

   ## Edge cases
   - <each user correction or dead end from the conversation, phrased as
     "if X, do Y">
   ```
   Conventions: kebab-case name matching the directory; description states both
   capability and trigger phrases (that is what routing sees); steps reference
   exact commands/paths, not vague advice; keep it under ~100 lines — link to
   reference files in the skill dir if more is needed.

4. **Include edge-case examples.** At least one worked example of a tricky input
   → correct handling, drawn from the actual conversation where possible.

5. **Test it.** Verify the skill actually loads and works:
   - check frontmatter parses (valid YAML, `name` matches directory),
   - dry-run the steps mentally against the original conversation: would
     following the skill reproduce the good outcome and avoid the recorded dead
     ends?
   - if the skill wraps commands, run the key command once to confirm it exists
     and the invocation is correct,
   - tell the user the skill is available next session (skill lists load at
     session start) and how to invoke it (`/<name>` or by trigger phrase).

## Edge cases

- Conversation contains several distinct workflows → ask which one to capture;
  don't merge them into one bloated skill.
- The workflow depends on secrets or machine-specific paths → parameterize them
  in the steps ("ask the user for X") rather than hardcoding.
- A skill with a similar name/purpose already exists → propose updating it
  instead of creating a duplicate.
- The conversation ended in failure → say so; a skill should encode a workflow
  that worked, not speculation.
- Target is a plugin skill → the directory is `<plugin>/skills/<name>/`, and the
  plugin's `.claude-plugin/plugin.json` must exist; the frontmatter format is
  identical.
