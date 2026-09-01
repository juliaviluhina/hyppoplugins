---
name: mnookin-grill
description: Interrogate the user one question at a time to fill or sharpen their Mnookin two-pager (Never Search Alone career-clarity exercise), challenging vague or self-flattering answers against their own career evidence. Use when asked to "grill me on the two-pager", "run the Mnookin interview", "help me fill the two-pager", or to pressure-test a drafted section.
---

# mnookin-grill

Relentless one-question-at-a-time interrogation (the `grill-me` technique),
adapted for introspection instead of technical planning. The target is the
user's two-pager draft — a nine-section career-clarity doc. Skill material is in
`references/`: `method.md` (the phases, section list, call format, checklist)
and `example.md` (how to find a calibration example).

Two differences from a technical grill:

1. **Not everything must resolve.** Some answers (long-term goal, ideal domain)
   are legitimately unsettled — the job is to make them *honest and specific*,
   not falsely precise. Park genuine unknowns as open questions; don't badger
   them shut.
2. **The AI grill does not replace the listening tour.** This is Phase 1
   scaffolding only. It ends by handing the user sharpened questions to take to
   real people (Phase 2 in `references/method.md`) — or, if the user won't do
   conversations, to the desk substitutes noted there.

This skill stops at the two-pager draft itself. Once it converges — or a new
fact (a new project, corrected evidence, market feedback) needs folding in —
propagating that into the shortlist, CV-content docs, and generated CVs is a
separate skill: **`mnookin-analysis-artifacts`**.

## Steps

1. **Load context.** Read `references/method.md` and `references/example.md`.
   Then find the user's config file (`mnookin.config.yaml` in the working
   directory or a parent — see the plugin README). From it, read:
   - `two_pager` — the draft to work on. If it doesn't exist yet, create it from
     the nine-section skeleton in `method.md`.
   - every path in `evidence` — career facts to check answers against.
   - `constraints` if set — known limits on what the evidence actually supports
     (e.g. "tool X was used with language Y, not Z"); don't let claims drift past
     these.
   - `example` if set — a public two-pager URL for calibration; otherwise follow
     `references/example.md` to pick one.

   If there is no config file, ask the user for the two-pager path and any
   career-notes paths, and offer to write a config file so future runs skip this.

2. **Pick the target.** If the user named a section, grill only that. Otherwise
   walk the 9 sections in `two_pager` order, skipping ones already filled and
   solid.

3. **Interrogate, one question per turn.** Never dump a list. Each turn: ask a
   single sharp question, wait for the answer, then either follow up or move on.
   Techniques:
   - **Concrete over abstract:** "good culture" → "name a team you thrived on
     and one you didn't — what was different day to day?"
   - **Evidence check:** if an answer contradicts the `evidence` notes, quote the
     discrepancy and ask which is true.
   - **Cost test for must-haves:** "would you turn down a great role that missed
     this? If not, it's a preference, not a must-have — move it."
   - **Symmetry:** every must-have needs its must-not; every strength needs a
     real weakness (not a disguised strength).
   - **Five-whys on goals:** push "why" up to 3 times, then stop.
   - **Regret mining for hates:** "what task in the last 3 roles made you check
     the clock?"

4. **Know when to stop a thread.** Move on when the answer is concrete,
   evidence-consistent, and the user has said the same thing two different ways.
   If it's a real unknown, write it to the open-questions list and move on —
   don't keep pushing.

5. **Write as you go.** After each section converges, update that section of
   `two_pager` in the user's own words (tighten, don't inflate). Keep the whole
   doc to two pages.

6. **Close with the handoff.** Append/refresh an `## Open questions for the
   listening tour` list in the draft: the unresolved items plus the 2–3 answers
   you found least convincing, phrased as questions to ask other people.
   Remind the user these go into Phase 2 conversations.

## Edge cases

- **User gives polished, PR-ready answers fast** → that's a smell; slow down,
  ask for the specific incident behind the generality before accepting it.
- **Answer flatly contradicts the evidence notes** → surface it plainly, don't
  paper over it; the contradiction itself is material for the two-pager.
- **User wants every section resolved in one sitting** → fine to do multiple
  sections, but respect step 4; a rushed two-pager defeats the exercise.
- **User asks you to just write the two-pager for them** → decline; the value is
  in their answers. Offer to grill instead, or to draft only from answers they
  have already given.
- **Section already well-filled** → don't re-grill for its own sake; confirm it
  survives the cost test / symmetry check and move on.
- **No config file and the user doesn't want to make one** → run from paths they
  give inline; just don't persist anything they didn't ask you to.
