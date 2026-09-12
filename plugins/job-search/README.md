# job-search

Five skills for a disciplined, evidence-cited job search — discovery,
retrieval, fit screening, bounded cheap-model delegation, and a resumable
session loop, all reading from one config file so nothing here is tied to a
particular person's titles, thresholds, or folder layout.

| Skill | Role |
|---|---|
| **`job-discovery`** | Default/primary discovery: one aggregator-excluded `WebSearch` per target title across Greenhouse / Lever / Ashby → dedup → discovery screen → still-open check → dated candidate list. No verdict. |
| **`job-posting-retrieval`** | Duplicate check, source order, still-open check, identity gate, normalized posting or named outcome. Board-specific navigation lives in `references/board-references/`. |
| **`job-fit-screen`** | Score a normalized posting against cited evidence via the fit rubric; verdict and application-state reconciliation. |
| **`job-search-delegation`** | Bounded Haiku subagent tasks under an orchestrator review gate — used by the other four skills for mechanical, cheap-to-verify steps. |
| **`job-search-session`** | Runs the iterative loop: process roles one at a time to a stop condition, return to the list, leave a resumable summary. |

They read and write a state folder you point them at — nothing is hardcoded
to a particular career, evidence file, or output path.

## Dependency: HyppoVisor

[HyppoVisor](https://github.com/juliaviluhina/hyppovisor) is a separate local
Electron app + MCP server that opens URLs in real browser tabs carrying
**your own logins**, and exposes them as MCP tools (`open_url`, `read_page`,
`read_form_fields`, `interact`, `screenshot`, …). `job-posting-retrieval` uses
it as the last-resort fallback source — after public `WebFetch` and the ATS
JSON APIs — for postings behind a login wall or that need JS rendering to
render their content. It is read-and-draft-only: nothing in this plugin, or
in HyppoVisor itself, submits a form, applies, or signs in on your behalf.

It is optional but recommended. Without it, `job-posting-retrieval` still
works for the majority of postings (ATS APIs + public fetch); it just asks
you to paste the page text yourself for the postings that need a logged-in
or JS-rendered view.

**Before you start using this plugin:**

1. Install HyppoVisor per its own README, then give it a project slug and
   port for the project where you're running this job-search plugin (its
   README documents that setup — pick any free port, one instance per
   project).
2. Launch that instance and register it as an MCP server in this project
   (`claude mcp add --transport http --scope local <slug> http://127.0.0.1:<port>/mcp`).
3. Point this plugin's `browser_tool` config key (below) at the resulting
   tool name, e.g. `mcp__hyppovisor-<slug>__read_page`.
4. If any target board is LinkedIn: HyppoVisor must block `linkedin.com` at
   the app level (its blocked-domains setting), and this plugin never routes
   LinkedIn through `browser_tool` regardless of that config — see
   `job-posting-retrieval/references/board-references/linkedin.md`. Retrieve
   LinkedIn postings via public `WebFetch` or by pasting the page text.

If you skip HyppoVisor entirely, leave `browser_tool` blank in the config —
the skill degrades gracefully to asking you for pasted text.

## Prerequisites: what to fill in before your first real session

Nothing here works out of the box on your own career — it ships wired to the
fabricated "Jordan Ashworth" persona so you can see the shape of a filled-in
setup. Before a real session, refill:

| Document | Replace with |
|---|---|
| `job-search.config.yaml` (copy from `skills/job-posting-retrieval/references/config-template.yaml`) | Your `state_dir`, `browser_tool`, and `target_roles` (title tiers, evaluation streams + seniority ceilings, excluded archetypes, hard constraints/comp floor). |
| `evidence/career-history.md` | Your actual chronological project/role history — what `job-fit-screen` cites evidence from. |
| `evidence/cv-content.md` | The wording you actually use in your CV/resume. |
| `evidence/constraints.md` (optional) | Known limits on what your evidence supports (e.g. "used framework X with language Y, never Z") so the rubric doesn't let a verdict overclaim. |

Everything under `job-posting-retrieval/references/board-references/`
(Greenhouse/Lever/Ashby, LinkedIn, Himalayas, etc.) is board mechanics, not
personal data — leave it as-is unless a board changes its site.

## One-time setup: the config file

All five skills read a single `job-search.config.yaml` (the skills search the
working directory and then parent directories for it). Create it in your
job-search folder:

```yaml
state_dir: ./job-search-data/
evidence:
  - ./evidence/career-history.md
  - ./evidence/cv-content.md
target_roles:
  tiers: [...]
  streams: [...]
  excluded_archetypes: [...]
  hard_constraints: {...}
browser_tool: ""   # optional: an authenticated/JS-rendering browser MCP tool
```

See
[`skills/job-posting-retrieval/references/config-template.yaml`](./skills/job-posting-retrieval/references/config-template.yaml)
for the fully annotated version — it's seeded with a **fabricated persona**
("Jordan Ashworth") purely to show what a filled-in config looks like. Replace
every field with your own target titles, streams, and thresholds before
using this for real.

## What isn't bundled

- **A browser-automation tool.** `job-posting-retrieval` falls back to one
  (via the `browser_tool` config key) only after public `WebFetch` and the
  ATS JSON APIs fail — for authenticated or JS-rendered pages. Point it at
  any browser-automation MCP tool you already have; without one, the skill
  asks you to paste the page text instead.
- **Your evidence base.** The fit rubric cites specific files/sections you
  provide; it never invents career history.
- **An application-tracking system.** `job-search-session` reconciles
  application state against whatever artifacts you keep in `state_dir`; it
  doesn't assume a CRM or tracker beyond plain Markdown files.

## Board coverage

`job-posting-retrieval/references/board-references/` ships reference
material for: Greenhouse/Lever/Ashby (the default ATS-scoped search
surface), a general web-search secondary surface, LinkedIn (retrieval-only,
browser automation is off-limits there — see that file), Jack & Jill,
Himalayas, HiringCafe, Remote100K, Welcome to the Jungle, BackedNYC, and
Amazon Jobs. Add a new board by copying the contract in
`job-posting-retrieval/references/board-reference-format.md`.

## Usual flow of usage

**You ask** something like "go through this board" (with a job-list URL),
"screen roles from my ATS search," or "resume my session from Tuesday" —
`job-search-session` treats each of these as a starting list and takes over
the sequencing.

**What the plugin does**, per role, in order:

1. **Discover** (only if you asked for board-wide discovery rather than
   handing over a list/posting): `job-discovery` runs one aggregator-excluded
   `WebSearch` per target title across Greenhouse/Lever/Ashby, dedups, and
   writes a dated candidate list — no verdict yet.
2. **Retrieve**: `job-posting-retrieval` checks the role isn't already in
   your ledger, fetches the posting (public fetch → ATS API → HyppoVisor →
   asks you to paste), confirms the posting is still open and the identity
   matches, and normalizes it into one record — or stops with a named
   outcome (e.g. `closed`, `login_required`, `duplicate`) instead of guessing.
3. **Screen**: `job-fit-screen` scores the normalized posting against your
   cited evidence via the fit rubric, runs the anti-pattern checks
   (overclaim, seniority mismatch, etc.), and produces a verdict plus a
   reconciled application state.
4. **Delegate** (as needed, not as a separate step you ask for): mechanical
   sub-steps — SERP triage, still-open checks, extraction, citation audits —
   go to a bounded Haiku call via `job-search-delegation`, reviewed by the
   orchestrator before anything is used or written.
5. **Record and continue**: `job-search-session` writes the role's row and
   terminal state to the session file, returns to your starting list, and
   either moves to the next role or stops on a configured condition (user
   direction, role/time/queue limit, a positive verdict, a login wall, or a
   browser failure).

**What you get back**, per role: a normalized posting record, a cited
evaluation with verdict, a ledger entry (duplicate-proofing future runs),
and an application-state marker — or, for anything that couldn't be
completed, a named outcome and the missing piece, never an inferred record
or an optimistic guess. At the end of a session: a dated, resumable summary
(role rows, counts, stop reason) you can hand back to `job-search-session`
later to continue exactly where you left off.

## Design notes

- The fit rubric's anti-pattern checks (domain-crossover overclaim,
  day-to-day ops/support mismatch, preferred-qualification stretch,
  leadership-recency discount) are generalized versions of failure patterns
  that are common across career pivots and high-volume employers, not
  specific to any one person's history — but you should expect to tune the
  wording as you hit your own version of each.
- Nothing in this plugin logs in, submits an application, uploads a file, or
  sends a message. Every skill is explicitly read-and-draft-only; a human
  approves every outbound action.
