# ATS Boards Search Reference

The ATS-scoped search is a **discovery surface, not a posting host**. It
produces a list of candidate roles as search-result snippets; every hit must
be traced to its first-party / ATS posting and retrieved through the normal
source order before it can be scored. Nothing on a results page is evaluation
input. Method rules live in `../../job-discovery/references/method.md`; this
file is the atomic board reference.

- Board name: `ATS boards search (Greenhouse/Lever/Ashby, WebSearch)`
- Surface type: a web-search-tool query restricted to shared ATS vendor
  domains — no login, no browser tab.
- **Positioning: default/primary discovery surface.** A general browser-driven
  web search is the secondary surface, run for broader coverage (non-ATS
  first-party boards, "related jobs" bonus-discovery harvest).

## Query patterns

Run one query per individual target title:

```
site:job-boards.greenhouse.io OR site:boards.greenhouse.io OR site:jobs.lever.co OR site:jobs.ashbyhq.com "<title>" -site:linkedin.com -site:indeed.com -site:glassdoor.com -site:ziprecruiter.com
```

- Add `remote usa` / `"United States" remote` and negative geo terms
  (`-canada -india -"united kingdom"` …) where a title attracts offshore
  outstaff shops.
- **Recency:** apply a search-side date-restricted operator per query *where
  the search tool supports one*. A `site:` OR-domain query frequently has no
  reliable date filter; when none is available, bound actionable output
  through ledger de-dup + still-open verification instead — not an error.
- **Recency window:** at least the sweep cadence — e.g. last 14 days for a
  ~biweekly sweep, last 1–7 days for a top-up.

## Detection

- **Search surface:** invoked deliberately by the discovery skill; no URL to
  detect. Every result is inventory/search metadata (title + URL + snippet +
  any parsed age/salary chip), never a posting.
- **Posting URLs:** `job-boards.greenhouse.io/<token>/jobs/<id>`,
  `boards.greenhouse.io/<token>/jobs/<id>`, `jobs.lever.co/<token>/<id>`,
  `jobs.ashbyhq.com/<token>/<id>`. A posting on these hosts detects as this
  board reference; retrieve it through the normal source order (public fetch
  → ATS posting API) and apply the identity rules below.

## Inventory rule

A results page is **never** a job posting and must not be persisted as a role
or evaluated. Return `retrieved.incomplete` for any role whose first-party JD
has not been separately retrieved and verified.

## Exclusions

- **LinkedIn** — `dropped` per the discovery method's § Discovery screen.
- **Indeed / Glassdoor / ZipRecruiter** — excluded at the query with `-site:`.
- **Non-posting vendor pages** — the vendor domains also serve marketing, help
  docs, and the vendor's own jobs; drop anything that is not a single company
  requisition.
- **Staffing-spam reposts** — the same JD across generic job aggregators with
  contradictory locations and no first-party careers page. Do not pursue.

## Known failures and recovery

- **Stale requisitions** — client-side-redirect staleness (Greenhouse
  especially), orphaned boards after an acquisition, and dead job IDs from the
  search index. Handle per the still-open check in `job-posting-retrieval`.
  For a dead ID, first look for a live requisition for the same role on the
  company's board.
- **Aggregator mirror of an ATS posting.** Trace to the first-party / ATS URL
  and persist that as canonical; score location off the first-party page
  only.
- **A company on more than one ATS platform, or the same role under two
  vendor URLs.** List it once; keep the first-party URL canonical.
- **A title group returns too many results.** Apply a bounded cap with
  recency-preferred ordering; note the truncation in the run file.
- **A run finds nothing new after de-dup + filter.** Say so plainly; still
  write the run file with the query set and a zero-count summary.

## Identity and canonical-link verification

At every handoff (result → aggregator → first-party, or slug redirect),
verify company, role title, and material location against the first-party
source. Persist the first-party / ATS role URL as canonical, never the
search-results URL or an aggregator mirror. On mismatch or a redirect to a
different role / a search page, return `ambiguous.identity` or
`invalid.redirect` and do not evaluate.

## Evidence quality

Everything on a results page — title, snippet, age chip, salary chip — is the
search engine's parse, not employer-posted fact. Primary-source quality
depends entirely on the first-party / ATS page the hit is traced to. Mark
absent comp / authorization / work-model fields `Not stated in source` after
reading that page.

## Verification date

Provisional until you've run it at least once — record the date of your
first live run here, along with the query count and candidate yield, so you
know when to promote this reference from provisional to durable.

## Confidence

**Provisional.** Promote to durable after a sweep reproduces the yield
pattern and a `job-search-session` consumes the run file end to end.

## Privacy constraints

Persist only the specific role hits worth retrieving and their first-party
URLs. Do not persist search-engine account state, cookies, session
identifiers, the signed-in user's search history, or full results dumps.
