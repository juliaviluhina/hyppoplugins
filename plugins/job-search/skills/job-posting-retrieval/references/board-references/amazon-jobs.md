# Board Reference — amazon.jobs

## Board name and URL patterns

Amazon's first-party careers board, `amazon.jobs`. Search UI:
`https://www.amazon.jobs/en/search?...` (query-string filters); individual
postings: `https://www.amazon.jobs/en/jobs/<id>/<slug>`.

## Detection guidance

The search portal itself (`/en/search`) is a JS-rendered shell — not
fetchable via `WebFetch`/`WebSearch` directly. Individual job pages
(`/en/jobs/<id>/...`) **are** fetchable via `WebFetch` once a URL is known.
Practical retrieval path: `site:amazon.jobs` `WebSearch` to surface
individual job-page URLs, then `WebFetch` each one for the full JD — or, if
you have a browser tool, load the search UI directly with your filters
applied and paginate it read-only.

## Building a saved-search filter

Amazon's search UI supports query-string filters — category, job type,
country/state, business category, years-of-experience band, and an
IC-vs-manager flag. Build one from your `target_roles` config: engineering
category, full-time, your target states/countries, the business units you
actually want (e.g. exclude devices/physical-retail units if your titles are
software-only), and an IC-only flag. This is a much tighter starting filter
than an ad-hoc `site:amazon.jobs` search — worth running as the primary
method if you have a way to page through the JS search UI (a browser tool,
or asking the user to paste the result list).

## Preferred retrieval approach

1. Load the saved-search URL (browser tool, since the portal is
   JS-rendered) and capture the result list (title + job ID + posted date
   per row).
2. For each result, `WebFetch` the individual `/en/jobs/<id>/...` page for
   the full JD — a search-result snippet is never sufficient to score
   against; always fetch the primary posting.
3. Score against the fit rubric and your `target_roles` config as usual.

## Known failures and recovery

- `/en/search` itself returns a JS shell to `WebFetch` — do not attempt to
  fetch the search URL directly, and treat an empty/shell result as
  `retrieved.incomplete` ("the portal wasn't rendered"), never as
  `invalid.redirect` ("no jobs") — the two are not the same outcome and only
  the former is a retryable rendering failure.
- `site:amazon.jobs` `WebSearch` is a workable fallback for discovering
  individual job-page URLs when the search UI can't be loaded, but is less
  targeted than an actual filtered search — screen each result against
  `target_roles` and drop off-filter roles before retrieval, rather than
  retrieving first and screening later.

## Return-before-next

When paginating the saved-search filter with a browser tool: capture the
filtered search URL before opening any individual result. After each
`WebFetch` of a job page, return to that captured URL and confirm the
*filtered* result list — not a default/unfiltered view — reloaded before
opening the next result.

## Read the whole posting, not just the bullet list

Amazon's job postings use a small number of boilerplate required-bullet
templates across very different teams — the same generic "N+ years
professional software development, design or architecture of large-scale
distributed systems" bullet set appears on both build-focused and
ops/support-focused teams, and on teams whose actual domain is a narrow
specialization (e.g. a specific hardware/ML-silicon product line) framed in
generic software-engineering language. Two patterns worth watching for
across large Amazon batches:

1. **The boilerplate bullet reads as satisfiable by any senior engineer, but
   the team's real day-to-day is narrower than the bullet implies.** Score
   the bullet against what your evidence actually supports for *that*
   specific ask (e.g. production backend/distributed-systems ownership vs.
   adjacent tooling/test-framework work) rather than letting a generic
   template read as an automatic pass.
2. **The "About the team" section, not the bullet list, is often where the
   real product/domain surfaces** — fetch and read it in full before
   scoring, not just Basic/Preferred Qualifications and Responsibilities.
   A role framed around "building AI agents" or similar general language can
   still be serving an underlying specialized product domain (e.g. a
   specific hardware or ML-infrastructure line) that the bullet list alone
   doesn't reveal.

Also watch for a generic-bullet team that is in practice an ops/support
team: teams named "Incident Prevention," "Resilience," or whose
responsibilities lead with oncall/runbook/alarm ownership score identically
to a build team on the required-bullet template — the mismatch only shows up
in the responsibilities/team-charter text (see the fit rubric's day-to-day
specialization-mismatch check).

**Standing recommendation:** for a high-volume employer like Amazon/AWS
whose job-posting templates are largely boilerplate across very different
teams, budget time to read "About the team" and the real responsibilities on
every posting before scoring — the required-bullet template alone
systematically over-scores at this kind of employer.

## Evidence-quality notes

Individual `amazon.jobs` job pages typically fetch cleanly via `WebFetch`
once the URL is known.

## Confidence

List-capture method (browser tool against a filtered search) is generally
reliable once the filter URL is built correctly. Per-posting `WebFetch`
retrieval works cleanly for individual job pages.

## Privacy constraints

None — no credentials, tokens, or private content in a saved-search filter
built from public query parameters.
