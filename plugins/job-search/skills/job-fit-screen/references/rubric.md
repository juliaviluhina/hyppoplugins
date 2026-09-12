# Fit Rubric

This is the canonical fit rubric. `job-fit-screen` reads its thresholds and
decision rules from here and from `job-search.config.yaml`; it must not
restate a threshold from memory.

Illustrative examples below use a fabricated persona, **Jordan Ashworth** — a
senior test-automation engineer pivoting toward AI/agent-tooling roles, with
two evaluation streams (QA/test-automation and developer). Replace every
config-sourced value with your own; Jordan doesn't exist.

## Input

- A normalized posting (`job-posting-retrieval`'s format).
- The evidence files named in `job-search.config.yaml`.
- The hard constraints and streams named in `job-search.config.yaml`.

## Hard constraints

Read from `target_roles.hard_constraints`: location/work-model, work
authorization, travel ceiling, role-nature exclusions, and comp floor. Report
these **separately** from the required-bullet table; never score them as
bullet rows.

- **Location** is a blocker unless the posting is remote, or hybrid/on-site
  within a market you've said you'd consider. A role needing relocation
  records location as **unresolved** — a real decision surfaced prominently
  — not a clean pass.
- **Compensation floor** — a posted range whose floor is below your
  configured floor clears only at or above its midpoint; never round a low
  floor up to a pass.

## Verdict scale (per required bullet)

| Verdict | Meaning |
|---|---|
| **Strong** | Direct, evidenced — a specific project/role/tool in the evidence base matches the requirement. |
| **Partial** | Adjacent or shallow — related experience, but not the thing asked for, or not at the asked-for depth. |
| **Fails** | Claimed but the evidence contradicts it. |
| **Absent** | No evidence at all. |
| **Unknown** | The posting or evidence needed to score this was not retrieved / not established. Not a negative and not a positive. |

### Fit estimate

```text
(Strong + 0.5 × Partial) / total required bullets × 100
```

`Fails`, `Absent`, and `Unknown` contribute zero. This estimate describes
capability coverage only; it never overrides the required-bullet SKIP gate
or a hard-constraint verdict.

### Overall verdict

- Any **required** bullet `Fails` or `Absent` ⇒ **SKIP** — **unless** the
  narrow-adjacent-subskill exception applies (§ SKIP gate), in which case ⇒
  **APPLY-AND-SEE**, naming the gap prominently as the interview risk.
- Otherwise, 2 or more **required** bullets only `Partial` ⇒
  **APPLY-AND-SEE**; name each interview risk.
- Otherwise, if comp floor, hard constraints, and role nature are all clear
  ⇒ **APPLY**.
- If a hard constraint or comp floor is unresolved (not failed) ⇒
  **APPLY-AND-SEE** with the blocker surfaced prominently, or **SKIP** if
  more likely than not to fail.

## SKIP gate

Any **required** bullet scored `Fails` or `Absent` ⇒ SKIP, regardless of
theme, compensation, or company fit. A strong "what you'll work on" list, an
exciting comp band, or company prestige never lifts the verdict past this
gate.

**Narrow-adjacent-subskill exception.** This gate exists to stop a specific
failure pattern: a role scores well on average while one or more required
bullets signal the candidate is in the **wrong specialization entirely**
(e.g. Jordan, a test-automation engineer, being scored against an ML-model-
training bullet) — that is always a hard SKIP, regardless of how the rest of
the bullets score.

Distinguish that from a single `Absent` required bullet that names a
**narrow sub-skill within the same discipline** the candidate is otherwise
strongly matched to (e.g. a specific OS-hardening technique within a
test-automation-engineering role Jordan is otherwise Strong on). That case
may instead verdict **APPLY-AND-SEE with the gap named prominently as the
interview risk** — do not silently average it away, and do not apply this
exception by feel; it requires that every *other* required bullet is
`Strong` or `Partial` (no other `Absent`/`Fails`) and that the gapped bullet
is plainly a sub-skill of the matched discipline, not a different discipline
wearing an adjacent-sounding label. When in doubt, treat the gap as
wrong-specialization and SKIP. An `Absent` produced by the domain-crossover
downgrade (below) never qualifies — it records a mismatch between streams,
which is the wrong-specialization case by definition.

## Board compensation-estimate rule

A board's own compensation estimate (an aggregator's inferred range, a
recruiter ballpark) is **context only**; it never moves the hard-constraint
verdict in either direction. Record compensation as
`Unconfirmed — board estimate <range>` and hold the comp gate at `Unknown`
until an employer-stated figure is found.

## Citation rule

No citation ⇒ not a `Strong`. An evaluation is not complete until every
`Strong`/`Partial` required-bullet row names a specific evidence file **and**
section (from `job-search.config.yaml`'s `evidence` list). `Absent`/`Unknown`
rows are exempt.

## Title check

If the title says one role type and half or more of the required bullets
describe another, state the mismatch in one sentence and score against what
the requirements say, not the title. Generic-sounding titles (e.g. "AI
Engineer") get used for wildly different roles across employers — always
check the requirements.

## Anti-patterns to watch for

These have historically produced wrong verdicts when skipped:

- **A subagent already summarized the role.** Discovery input only — fetch
  the primary JD before any verdict above SKIP.
- **Quoting the requirements is not scoring.** Every required bullet needs an
  explicit verdict + citation, not just a restatement.
- **Exciting project list vs. gating requirements.** "What you'll work on"
  can list appealing work while "what you need" gates on something the
  candidate doesn't have. Score the gate; mention the project list as upside
  only.
- **Comp range with a low floor.** A range straddling your floor is "clears
  only at/above midpoint," not "clears." Do not round up.
- **A job board's "Remote" flag vs. the actual posting.** Trust the primary
  posting page over an aggregator's normalized field.
- **The user says they'll consider hybrid/on-site for a good match.**
  Location stops being a hard gate for that role — but role-nature blockers
  (client-facing, heavy travel) do not; re-confirm those separately.
- **The conversation is triaging a batch.** Run discovery/shortlisting with
  subagents by all means, then screen each surviving role individually. A
  batch verdict is only ever provisional.

## Decision tree

```mermaid
flowchart TD
    A[Role or board result] --> B[Capture board/search/list URL<br/>and stable posting URL]
    B --> C{Existing match in<br/>retrieval ledger?}
    C -->|Yes| D[Verify current identity and log retrieval]
    D --> E{JD or hard constraints<br/>materially changed?}
    E -->|No| F[Reuse existing evaluation<br/>do not rescore]
    E -->|Yes| G[Continue to retrieval]
    C -->|No| G
    G --> H[Try public WebFetch/extraction;<br/>fall back to ATS API or browser tool<br/>for authenticated/JS content]
    H --> I{Title, company, location,<br/>and source identity agree?}
    I -->|No| J[Record ambiguous.identity or<br/>invalid.redirect; do not evaluate]
    I -->|Yes| K{Primary JD complete?}
    K -->|No| L[Record retrieved.incomplete;<br/>list missing sections; do not score]
    K -->|Yes| M[Persist normalized posting<br/>and provenance]
    M --> N[Extract literal Requirements /<br/>What You Need / Qualifications bullets.<br/>Split required vs nice-to-have]
    N --> O[Score each REQUIRED bullet:<br/>Strong / Partial / Fails / Absent,<br/>with cited candidate evidence]
    O --> O2{REQUIRED bullet demands<br/>stream-specific depth, answered only<br/>with evidence from the other stream?}
    O2 -->|Yes| O3[Downgrade that bullet one level<br/>Strong→Partial, Partial→Absent;<br/>record original verdict, downgraded<br/>verdict, and the stream-mismatch reason]
    O2 -->|No| P
    O3 --> P
    P{Title implies role type A<br/>but requirements describe type B?}
    P -->|Yes| Q[Name the mismatch; score<br/>against requirements, not title]
    P -->|No| Q2
    Q --> Q2{Posting's title/internal level,<br/>in its stream, vs. candidate's<br/>stream-specific ceiling}
    Q2 -->|Ambiguous / unstated| Q3[Surface the ambiguity as a<br/>named risk; do not silently pass]
    Q2 -->|Above ceiling| Q4[Name the specific level and<br/>stream ceiling it exceeds]
    Q2 -->|At the stream's "stretch" level| Q5[Pass the gate; record a caveat<br/>distinguishing it from a clean<br/>within-ceiling pass]
    Q2 -->|Within ceiling| R
    Q3 --> R
    Q4 --> S
    Q5 --> R
    R{Any REQUIRED bullet<br/>Fails or Absent?}
    R -->|Yes| R2{Exactly one Absent, a narrow<br/>sub-skill gap, every other<br/>REQUIRED bullet Strong/Partial,<br/>same discipline? SKIP-gate exception}
    R2 -->|No| S[Verdict = SKIP<br/>even with strong theme / comp / prestige]
    R2 -->|Yes| U2[Verdict = APPLY-AND-SEE;<br/>name the gap prominently as<br/>the interview risk]
    R -->|No| T{2+ REQUIRED bullets<br/>only Partial?}
    T -->|Yes| U[Verdict = APPLY-AND-SEE;<br/>name each interview risk]
    T -->|No| V{Comp floor + hard constraints<br/>+ role-nature all clear?}
    V -->|Failed| S
    V -->|Unresolved| W[APPLY-AND-SEE with blocker surfaced;<br/>SKIP if more likely than not to fail]
    V -->|Yes| X[Verdict = APPLY;<br/>persist evaluation artifacts]
```

## Domain crossover

A required bullet can demand stream-specific depth — direct evidence of
shipping/building within a specific technical stream — while the cited
evidence for it actually comes from the candidate's *other* stream. This is
distinct from a missing citation (already required above) and from the title
check (which judges the posting as a whole) — this catches evidence borrowed
from the wrong stream for one specific bullet.

When a required bullet names stream-specific depth and the cited evidence is
traceable only to the candidate's other stream, downgrade that bullet's
verdict one level (Strong→Partial, Partial→Absent) before the SKIP/
partial-count tally runs. Record the original verdict, the downgraded
verdict, and a one-sentence reason naming which stream the bullet asked for
vs. which stream the cited evidence came from.

*Illustration:* a developer-stream bullet asking for "production application
development, not just prototypes" answered only with Jordan's
test-automation-framework-building evidence is exactly this trigger — that
evidence doesn't establish production-application-development depth, even
though it's real, relevant senior engineering work in the other stream.

This applies bidirectionally — a QA-stream bullet answered only with
developer-stream-only evidence downgrades the same way. Absence of a
specific, nameable stream-depth phrase on the bullet means no downgrade — do
not infer a trigger that isn't stated.

## Day-to-day specialization mismatch

A role can score a clean required-bullet pass under a generic template while
its **responsibilities** are centered on service reliability, on-call
incident response, or operational support — a day-to-day direction the
candidate may not want, independent of whether they could technically do the
work. Required bullets alone often don't catch this, because a generic
"design/architecture" template reads the same whether the team builds
features or runs an incident desk.

**Check:** after extracting responsibilities, scan for whether the team's
**primary charter** — not an incidental "on-call rotation" line every req in
this space carries — is service resilience, incident prevention/response,
production support, or customer-facing operational triage (team names like
"Incident Prevention" or "Resilience," or responsibilities that open with
oncall/runbook/alarm/incident-response ownership rather than feature
design-and-build).

**Effect:** name the mismatch explicitly in soft-fit. It does not auto-SKIP
(the candidate can likely do the work; it's a direction preference, not a
capability gap) — downgrade the verdict one step from what the bullet tally
alone would give (APPLY → APPLY-AND-SEE; APPLY-AND-SEE → SKIP if already
carrying another flag), stating plainly that the team's primary charter is
ops/support-oriented, not build/product-oriented. Carry this exclusion into
your discovery-time excluded-archetypes list too, so future sweeps catch it
before retrieval when the title itself signals it.

## Preferred-qualification stretch

A **preferred** (not required) qualification can name a specific,
substantial technical specialization the candidate has zero record evidence
for. Because preferred bullets never gate the SKIP tally, this is correctly
excluded from the required-bullet fit estimate — but recording it only as a
passing footnote understates how much day-to-day stretch it signals if the
team actually weights it in practice.

**Check:** for each preferred qualification, ask whether it names a
specific, substantial technical domain or method (not a generic "nice to
have") for which the record has **zero** evidence anywhere — not thin, zero.
A vague or generic preferred item does not trigger this; a named
specialization with no supporting citation does.

**Effect:** name it prominently in its own soft-fit line, and downgrade an
otherwise-clean APPLY to APPLY-AND-SEE — one qualifying preferred-bullet
stretch is enough to trigger this on its own, a lower bar than the
required-bullet "2+ Partial" rule, because an unevidenced *preferred*
specialization is exactly the kind of thing a hiring team screens for
informally even when it isn't written as a hard requirement. Does not affect
the fit-estimate percentage (required-bullets only) — this is a
verdict-level downgrade, recorded separately from the tally.

## Recency discount

Several required-bullet templates ("experience as a mentor, tech lead, or
leading an engineering team") can score a clean Strong by citing older
people-leadership evidence — evidence that is real, but dated relative to
the candidate's current IC-only track record. Scoring these bullets a flat
Strong understates the switch this represents and, stacked across a batch,
compounds an unstated risk instead of naming it.

**Check:** when a required bullet demands **current or ongoing** tech-lead,
mentor, or people-leadership scope (not "has led before" but the role's
day-to-day expecting it now), and the candidate's supporting evidence for
that specific bullet is concentrated in a period the evidence record itself
already flags as dated relative to their current role — downgrade that
bullet's verdict one level (Strong → Partial) before the SKIP/partial-count
tally runs, mirroring the domain-crossover mechanism. Record the original
verdict, the downgraded verdict, and the recency reason. This does **not**
apply to bullets asking for past/historical leadership experience without a
current-scope implication, and it does not apply when the candidate has
*recent* tech-lead-equivalent evidence for the specific bullet.

## Seniority gate

Compare the posting's stated title or internal level, within its stream,
against the candidate's realistic ceiling for that specific stream (from
`target_roles.streams`). This gate runs after the title check and before the
partial-count/hard-constraint tally, and overrides a clean required-bullet
score when it fires.

- **Above the stream's ceiling** ⇒ verdict = SKIP, naming the specific level
  and the specific stream ceiling it exceeds — regardless of how the
  required bullets scored.
- **At the stream's "stretch" level** ⇒ the gate does not SKIP the role, but
  records a caveat distinguishing it from a posting fully within the
  confirmed ceiling.
- **Within the stream's confirmed ceiling** ⇒ passes cleanly — no caveat, no
  effect on the verdict path.
- **Ambiguous or unstated level** (no recognizable level label, only an
  unfamiliar internal ladder name) ⇒ do not silently pass the gate — surface
  the ambiguity as a named risk, distinct from both a clean pass and a SKIP.

The *mechanism* above is canonical; the *specific stream-ceiling values* are
owned by `target_roles.streams` in your config and must be read from there,
not hardcoded here.

## Where the checks sit in the decision tree

- **Recency discount** runs in the same step as **domain crossover** — per
  required bullet, immediately after it is scored, before the title check /
  seniority gate / SKIP tally.
- **Day-to-day mismatch** runs alongside the **title check** — after the
  required-bullet table, before the seniority gate — but reads
  responsibilities/team-charter text rather than required bullets.
- **Preferred-qualification stretch** runs after the overall verdict is
  otherwise determined, as a final downgrade step, since it depends on the
  preferred-qualification list extracted alongside but scored separately
  from the required-bullet table.
