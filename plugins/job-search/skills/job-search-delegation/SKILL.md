---
name: job-search-delegation
description: >-
  Delegate bounded, checkable job-search subtasks (requirement extraction,
  normalized-section drafting, evidence matching, citation audit, evaluation
  critique, discovery SERP triage, still-open classification) to a Haiku
  subagent. Use when a job-search step is mechanical and cheap to verify. The
  orchestrator keeps every final decision and every write.
---

# job-search-delegation

Routes **bounded advisory work** to a cheaper model without granting it
workflow authority. This skill is the single owner of the delegation
boundary for the other four skills in this plugin.

## Mechanism

Spawn one subagent per task with the `Agent` tool:

- `subagent_type`: `"claude"` (or `"general-purpose"`)
- `model`: `"haiku"`
- `prompt`: the single bounded task, the **minimal** input it needs, the
  exact return shape, and an instruction to flag uncertainty rather than
  guess.

## Allowed task types

| `task_type` | Input scope | Return |
|---|---|---|
| `extraction` | Raw posting text | Required and preferred bullets, **verbatim**, as two lists. |
| `normalization` | Raw posting text + required-section list from `job-posting-retrieval/references/posting-format.md` | Draft sections with source wording preserved; absent fields `Not stated in source`. |
| `evidence_match` | One requirement + the relevant evidence-file excerpts | Proposed file + section, draft verdict on the fit-rubric scale, uncertainty note. |
| `citation_audit` | Drafted evaluation + the evidence files it cites | Every citation that is missing, misworded, or does not support its claim. |
| `evaluation_critique` | Drafted evaluation | Findings on title bias, optimism, hidden unknowns, hard-constraint omissions, SKIP-gate violations. No rescoring. |
| `discovery_triage` | One query's SERP rows (title + URL + snippet) + the config's excluded archetypes and hard pre-filters | Per row a **proposal** — `dropped` / `discovery-skip <reason>` / `needs-retrieval` — with the rule and snippet span. Snippet-only, no fetching; an ambiguous row is `needs-retrieval`. `needs-retrieval` is a triage label, not a disposition: the row continues to dedup and still-open checks. |
| `still_open_scan` | One posting URL (+ careers URL when known), read with one stateless `WebFetch` | A **signal** — `application_form_present` · `http_404` · `error_redirect` · `not_in_careers_listing` · `redirect_to_other_role` · `blocked_403` · `js_shell_empty` — with quoted trigger text. No disposition. |

## Orchestrator review gate

Before using any output:

1. **Source fidelity** — every "verbatim" span matches the source.
2. **Citations resolve** — `Read`/`Grep` each cited file + section.
3. **Completeness is yours** — a draft that "looks complete" is not a
   decision.
4. **Identity is yours** — never accept a company / role / location the
   subagent introduced or changed.
5. **Reject** empty, truncated, malformed, uncited, identity-changing, or
   overconfident output; continue without it or ask the user. A rejected
   `citation_audit` blocks persistence the same as an unresolved flag — it
   does not fall back to skipping the audit.
6. **Ambiguous stays unresolved** — conflicting trigger text or an uncovered
   edge case is decided manually or re-checked, never accepted as a default.

## Delegation log

Each delegated task gets a staging row in the run or session file that
triggered it: `task_type`, `input_scope`, `model`, `timestamp`,
`review_status` (`pending` · `accepted` · `corrected` · `rejected`), plus
citations and uncertainty notes when relevant. Advisory, not canonical.

## A Haiku subagent must never

- detect the board or make the final source selection;
- use any tool beyond the single stateless `WebFetch` allowed for
  `still_open_scan` — no session-bearing browser tool, no clicking,
  scrolling, or list navigation;
- verify role identity as the final authority;
- transition session state or decide a stop condition;
- reconcile duplicates or application state;
- make the final completeness decision;
- assign final scores, verdicts, or dispositions;
- write any state file, including the journal;
- perform any external action (login, submit, upload, message, consent).
