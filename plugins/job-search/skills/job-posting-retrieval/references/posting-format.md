# Normalized Job Posting Format

```yaml
company: <company>
role: <role>
source_url: <canonical URL>
retrieved_at: <UTC date>
retrieval_method: <user_provided | local_file | web_extract | ats_api | browser_tool>
retrieval_status: <complete | incomplete>
still_open: <confirmed | unverified>
```

Required Markdown sections:

- `## Location and work model`
- `## Compensation`
- `## Work authorization`
- `## Required qualifications`
- `## Preferred qualifications`
- `## Responsibilities`
- `## Work style and team information`
- `## Screening flags`
- `## Source notes`

Use `Not stated in source` for absent fields. If material sections are
missing, set `retrieval_status: incomplete` and list them in Source notes.
Preserve requirements, authorization, location, and employment wording
verbatim.

## Record variants

### Full record (default)

Front matter plus every required section, populated from source or
`Not stated in source`. `retrieval_status: complete`. This is the target for
**every** role reachable by public extraction, supplied text, or the
configured browser tool (excluded for LinkedIn).

### Public-URL-only record (last resort)

Used **only** when neither public `WebFetch` nor the browser tool can reach
the page:

- Front matter as normal, with `retrieval_method: web_extract` and
  `retrieval_status: incomplete`.
- Verbatim `## Required qualifications` and `## Screening flags` wherever any
  public fragment exists; otherwise `Not stated in source`.
- Every other required section: `Withheld — authenticated source`.
- `source_url` retained; the withheld sections listed in `## Source notes`.

### Required-section enforcement

The persistence step **must refuse** to write a `job-postings/*.md` that
omits a required section. It substitutes `Not stated in source` (Full record)
or `Withheld — authenticated source` (public-URL-only) rather than saving an
incomplete file silently.

## Screening flags

Record each field as a verbatim source span or `Not stated in source`:

- `CITIZENSHIP`
- `SECURITY_CLEARANCE`
- `WORK_MODE`
- `LOCATION`
- `TRAVEL`
- `SALARY`
- `DEGREE_REQUIRED`

These flags are extraction aids, not fit conclusions. The fit workflow must
still score every required qualification against cited candidate evidence and
apply the configured hard-constraint policy.

## Evidence states

Tag any field or claim you record with exactly one of these, rather than
presenting an inference or a gap as settled fact:

- **Confirmed** — directly supported by the current source.
- **Inferred** — a reasoned interpretation, never presented as confirmed fact.
- **Unknown** — the source does not establish the value.
- **Ambiguous** — the source contains conflicting or unclear values.
- **Unavailable** — the value could not be retrieved because access or
  content was blocked.

This is a source-reliability tag, distinct from `job-fit-screen`'s
per-bullet verdict scale (Strong/Partial/Fails/Absent/Unknown) — it
describes how well-supported a *retrieved fact* is, not how well a
requirement is *met*.
