---
name: mnookin-analysis-artifacts
description: Cross-match the Mnookin two-pager against the downstream job-search artifacts it feeds (a shortlist, one or more CV-content docs, the sent CVs, screening questions) and propagate the implications — new contradictions, gaps, candidate directions, or new evidence such as a shipped project or a corrected fact — into every artifact that should reflect them. Use when asked to "reevaluate the shortlist/CVs against the two-pager", "fold the review into the artifacts", "propagate [new fact] into the CVs", or after a two-pager revision needs its conclusions actually applied, not just written down.
---

# mnookin-analysis-artifacts

Downstream of `mnookin-grill`. That skill produces or sharpens the two-pager
itself (Phase 1 interrogation). This skill starts once there is a two-pager
(locked or mid-revision) or a new fact worth reflecting, and ends with every
artifact that depends on it actually updated — not just a list of findings.

**Two modes, usually run back to back:**

1. **Analyze** — cross-match the current two-pager against the positioning
   artifacts, surface contradictions / gaps / candidate directions, write a
   dated review file.
2. **Apply** — take a review's TODOs, or a standalone new-evidence trigger (a
   new project, a corrected fact, an outside event), and actually edit every
   downstream artifact so it reflects the conclusion.

A request naming a specific new fact ("I built X", "I got rejected because Y",
"add Z as a project") usually only needs Apply — skip straight to step 4. A
request to "revisit" or "re-check" the whole positioning needs both modes in
order.

## The artifact map

This skill does **not** know the user's file layout. It reads a config file
(`mnookin.config.yaml`, found in the working directory or a parent — see the
plugin README) that names every artifact and how they depend on each other.
Read `references/artifact-map.md` for what each role in that config is *for* and
the dependency order that matters (source docs before generated CVs, direction
docs before the shortlist's evidence claims). `references/config-template.yaml`
is the annotated schema.

If there is no config file, ask the user to point at: the two-pager, the
strategy/positioning doc, each CV-content doc (one per positioning angle), the
shortlist, the screening-questions file, the folder of sent CVs, and the command
that renders a sent CV. Offer to write the config so the next run is one step.

## Steps

### 1. Load context

Read, in order: the `two_pager` (the criteria everything else is scored
against), the most recent review file in the same folder if one exists and
hasn't been fully applied yet, the `positioning_doc`, every `directions[].cv_content`
doc, and the `derived.shortlist`. Skim the `evidence` notes for the source any
new claim must trace to. Read `constraints` if set.

### 2. Establish what's new

Either a fresh two-pager revision (sections changed) or a standalone new fact
the user is reporting (a shipped project, a corrected number, market feedback).
**Pin down its actual status before treating it as evidence** — see the
"shipped vs. planned" rule below. This is the single most common mistake:
citing something before it exists.

### 3. Analyze (skip if the trigger is a single already-confirmed new fact)

Cross-match against each artifact:

- **Contradictions** — an artifact states something the two-pager's locked
  must-haves / must-nots now rule out (a header, a comp band, a stack, a
  must-not).
- **Gaps** — a two-pager theme (a culture axis, durability of what you build,
  schedule, employment terms) that no artifact's evaluation criteria currently
  captures.
- **Candidate new directions** — roles/titles the two-pager's goals sections
  open up that the shortlist doesn't search for yet; note which existing
  evidence supports each, and how strongly.

Write (or refresh) `review-<date>.md` next to the two-pager:
Contradictions / Gaps / Candidate new directions / TODOs sections, dated,
cross-linked. Stop here if the user only wanted the analysis — confirm before
proceeding to Apply on a large finding set.

### 4. Apply

Work source-to-derived, not the reverse — a sent CV should never carry a claim
its CV-content doc doesn't:

1. **CV-content docs** (`directions[].cv_content`) — the canonical CV content,
   one file per positioning angle. Fix contradictions here first (headers,
   tier/emphasis dials, screening filters), add durability / evidence language,
   add or correct new-evidence sections. Every new claim needs a source: either
   an `evidence` note (backfill it there too if it's a genuinely new fact about
   paid work) or, for something like an independent project, state it plainly as
   independent / unpaid work — don't blur the two.
2. **`derived.shortlist`** — re-score against updated must-have / must-not
   criteria if they changed; add/update evaluation dimensions the gap analysis
   surfaced; extend the candidate-directions list; keep the "what to ask on a
   first call" pointer current.
3. **`derived.screening_questions`** (create if missing) — the desk-substitute
   for the two-pager's open questions and the shortlist's first-call gap.
   Organize by access stage (recruiter → hiring manager → peer → offer); derive
   from the must-haves, the must-nots, and whatever the gap analysis flagged as
   under-tested (lead-fit, schedule, employment terms, comp-movement patterns).
4. **Sent CVs** (`derived.outgoing_dir`) — after the CV-content docs are
   settled, mirror the changes into the matching sent CV(s). Use the map's
   content-doc ↔ sent-file correspondence (see `references/artifact-map.md`);
   one content change often touches more than one sent file. Keep additions
   compact (2–3 lines) — these are already tight on space.
5. **Re-render** every sent doc you touched with `build_command` (substitute the
   file path for `{file}`). If `page_target` is set, check the actual rendered
   page count afterward — don't assume a short-looking markdown addition stays
   short after layout.

## Rules that have already caused real mistakes

- **Shipped vs. planned — cite only what actually exists.** A project in
  planning / spec stage is not evidence, no matter how well it will fit once it
  ships. (A common failure: a spec-stage companion project gets added to every
  CV and the shortlist as "demonstrated evidence" in the same pass that adds a
  genuinely shipped sibling, then has to be stripped back out of every file
  individually.) Before adding any new-evidence claim, verify: is this
  running / shipped / public right now, or planned? If planned, it goes in the
  CV-content doc as an explicit "not yet cited — revisit once shipped" note,
  never into a sent CV.
- **Page-length is real and silent edits break it.** If the map sets
  `page_target`, check the actual rendered page count after any addition —
  don't trust the markdown's apparent length. If a change pushes a CV over,
  say so and ask whether to do a full trim pass now or hold it — don't silently
  ship an over-length CV, and don't silently start cutting unrelated existing
  content.
- **Positioning-angle discipline.** If the strategy doc says one angle is only
  used when a condition holds (e.g. "only when the target role has real,
  verifiable AI content"), don't let a new-evidence pass quietly make that
  angle's CV read more strongly than the condition justifies.
- **Every claim traces to a source.** An `evidence` note for paid work; the
  project's own public repo / README for independent work. If a fact can't be
  traced, cut it rather than paraphrase-and-hope.

## Edge cases

- **User reports a fact you can't verify (a new project, a number)** — take it
  as given (it's their own record), but still apply the shipped-vs-planned
  check by asking directly if status is ambiguous, rather than assuming
  "mentioned" means "shipped."
- **The two-pager itself hasn't converged / locked yet** — analysis is still
  useful (flag it as provisional, re-run once locked) but hold off on a full
  Apply pass; a shortlist re-score against unlocked criteria will just need
  redoing.
- **User only wants one artifact touched** ("just update the shortlist") —
  fine, but still check whether the CV-content docs need the same fact for
  consistency; flag if they now diverge rather than silently leaving them stale.
- **The map lists only one direction** — that's valid; the skill just has one
  CV-content doc and (usually) one sent CV to keep in sync.
