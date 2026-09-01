# mnookin-two-pager

Two skills for the *Never Search Alone* career-clarity exercise (the "Mnookin
two-pager", from Phyl Terry's book, named after Allison H. Mnookin):

| Skill | Use it when |
|---|---|
| **`mnookin-grill`** | You want to draft the two-pager, or pressure-test a section you already wrote. It interviews you one question at a time and pushes back on vague or self-flattering answers using your own career evidence. |
| **`mnookin-analysis-artifacts`** | Your two-pager just changed (converged, got revised, or a new fact needs folding in) and the documents built on top of it — a shortlist, one or more CV variants, screening questions — need to be brought back into line with it. |

Neither skill invents your criteria for you, and neither one sends anything
anywhere.

## One-time setup: the config file

Both skills read a single config file so they never hardcode your paths. Create
`mnookin.config.yaml` in your job-search folder (the skills look for it in the
working directory, then parent directories):

```yaml
# --- used by both skills ---
two_pager: ./two-pager.md            # the draft everything centers on
evidence:                            # notes the interview checks answers against
  - ./career-history.md
  - ./evidence-notes.md
constraints: ./constraints.md        # optional: known limits on what your evidence supports
example: ""                          # optional: URL of a public two-pager, for calibration

# --- used only by mnookin-analysis-artifacts ---
positioning_doc: ./positioning.md    # the "which angle is primary, and when" strategy doc
directions:                          # one block per positioning angle; any number, not just two
  - name: Angle A
    priority: 1                      # 1 = primary; drives ranking, not just tie-breaks
    cv_content: ./cv-content-a.md
  - name: Angle B
    priority: 2
    cv_content: ./cv-content-b.md
derived:                             # artifacts generated from the above, to keep in sync
  shortlist: ./shortlist.md
  screening_questions: ./screening-questions.md
  outgoing_dir: ./outgoing/          # the CVs/letters that actually get sent
build_command: "bash ./build-pdf.sh {file}"   # how an outgoing .md is rendered ({file} = path)
page_target: 2                       # expected rendered page count; leave "" to skip the check
```

Every field except `two_pager` and `evidence` is optional — the analysis skill
only touches what you point it at. A minimal setup (grill only) needs the first
three lines.

See [`skills/mnookin-analysis-artifacts/references/config-template.yaml`](./skills/mnookin-analysis-artifacts/references/config-template.yaml)
for the annotated version.

## What "the method" is

- **Phase 1 — draft (solo).** Two pages, nine sections. `mnookin-grill` runs this.
- **Phase 2 — listening tour.** 6–10 conversations with people who know your work
  and your target market. The skill *ends* by handing you sharpened questions for
  these; it does not replace them.
- **Phase 3 — revise & lock.** Stop when 3+ conversations in a row produce no
  material change. The locked two-pager becomes the filter you score
  opportunities against — which is where `mnookin-analysis-artifacts` takes over.

Full method: [`skills/mnookin-grill/references/method.md`](./skills/mnookin-grill/references/method.md).
