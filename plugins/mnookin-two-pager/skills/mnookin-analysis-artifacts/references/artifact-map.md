# Artifact map

Reference for `mnookin-analysis-artifacts`. The skill never hardcodes file
names — it reads them from `mnookin.config.yaml` (schema:
`config-template.yaml`). This file explains what each configured role is *for*
and the order edits must happen in.

## Source of truth, in dependency order

1. **`two_pager`** — the criteria (must-haves, must-nots, goals) everything else
   is scored or filtered against. Owned by `mnookin-grill`; this skill reads it,
   never edits it directly. Edits to the two-pager itself belong to that skill
   and the listening tour.
2. **`evidence[]`** — the evidence ledger(s). Every CV claim about paid work
   must trace to one of these. When a genuinely new fact about paid work
   surfaces, backfill it here — don't let it live only in a CV-content doc.
3. **`positioning_doc`** — the strategic decision: which positioning angle is
   primary, the condition under which a secondary angle gets used, the
   headline / lead-paragraph locks. Rarely edited by this skill; read it to stay
   consistent, touch it only for a real strategy change.
4. **`directions[].cv_content`** — canonical CV *content*, one file per angle.
   These are edited first when a fact or framing changes. If a file keeps a
   running changelog (`## ADDITION <date>` sections), follow that convention
   rather than silently rewriting prose.

## Generated from the above

5. **`derived.shortlist`** — ranks specific opportunities against the
   two-pager's locked criteria; also where candidate *new directions*
   (title/domain shapes to search for, not yet specific postings) live.
6. **`derived.screening_questions`** — interview questions by access stage,
   derived from the two-pager's must-haves / must-nots / weaknesses plus any
   known recruiter-failure patterns.
7. **`derived.outgoing_dir` + `build_command`** — the documents that actually
   get sent. Re-render with `build_command` after any `.md` edit; nothing reads
   those `.md` files except the render pipeline.

## Content-doc ↔ sent-file correspondence

One CV-content doc can feed several sent files (a base version, an
expanded/deep version, a combined version). The config's `directions[]` entries
should each list their sent files if the mapping isn't 1:1 — add a `sent:` list
under a direction when needed:

```yaml
directions:
  - name: Angle A
    priority: 1
    cv_content: ./cv-content-a.md
    sent:
      - ./outgoing/CV_AngleA_base.md
  - name: Angle B
    priority: 2
    cv_content: ./cv-content-b.md
    sent:
      - ./outgoing/CV_AngleB.md
      - ./outgoing/CV_AngleB_deep.md
```

When a new fact belongs to an angle, check every `sent:` file under it, not just
the one whose name looks closest.

## Page-length check (when `page_target` is set)

After `build_command` renders a file, count pages on the actual output. A
portable check on a PDF:

```
python3 -c "import re,sys; d=open(sys.argv[1],'rb').read(); print(len(re.findall(rb'/Type\s*/Page[^s]', d)))" <file>.pdf
```

or `pdfinfo <file>.pdf | grep Pages`. If a change pushes a file past
`page_target`, stop and ask — don't trim silently and don't ship over length.

## Known failure mode

A companion project still in spec/planning stage gets added as "demonstrated,
independent evidence" to the CV-content docs, the shortlist, and several sent
CVs in the same pass that adds a genuinely shipped sibling project — then has to
be located and stripped back out of every file one by one. Cause: not checking
ship status before treating "the user mentioned it" as "it's real, citable
evidence." Always run the shipped-vs-planned check before writing a new-evidence
claim into more than one file — cheaper to ask once than to grep-and-fix later.
