# General Web Search Board Reference

A general web search is a **discovery surface, not a posting host**. It
produces a list of candidate roles as SERP snippets; every hit must be traced
to a first-party / ATS posting and retrieved through the normal source order
before it can be scored. Nothing on a results page is evaluation input.

This is the **secondary** discovery surface — the default/primary surface is
the ATS-scoped search (`ats-boards-search.md`). Run this one for broader
coverage: non-ATS first-party boards and the "related jobs" bonus-discovery
harvest the ATS-domain search misses. Both surfaces de-duplicate against the
same ledger.

- Board name: General web search leads
- URL patterns (Google shown; adapt to your search engine):
  - `https://www.google.com/search?q=<query>&tbs=qdr:<h|d|w|m|y>` — plain
    web-results view with a recency filter. Run per target title, driven
    read-only via the configured browser tool.
  - `https://www.google.com/search?q=<query>&udm=8` — the Google Jobs widget.
    Unreliable under a recency filter in past runs — treat an empty widget as
    "no result", not an error.
  - The search engine may auto-locate the SERP to the machine's IP location.
    Keep the query location token explicit (`remote`, `remote usa`) rather
    than trusting auto-location.

## Detection

Host is the search engine's domain with a `/search` path. A recency-filter
parameter means a recency-filtered discovery sweep. Treat the whole page as
an inventory/search surface — never a posting.

## Inventory rule

A results page is **never** a job posting and must not be persisted as a role
or evaluated. Each result is a title + URL + snippet + (sometimes) a
search-engine-parsed age / salary chip. All of that is discovery metadata.
Return `retrieved.incomplete` for any role whose primary JD has not been
separately retrieved and verified.

## LinkedIn exclusion

**Drop every LinkedIn hit from the results** — do not open it, do not list
its URL. If a role appears LinkedIn-only in the SERP, try the company careers
site / ATS / an aggregator mirror; if none reach it, record
`user.input.required` and ask the user to paste the description.

## Pre-retrieval SERP screen

Location and compensation misses are usually visible in the snippet — screen
before spending retrieval effort:

- **Location.** If the snippet, source domain, or company's known base shows
  a country restriction or a named non-remote metro the config doesn't
  clear, do not retrieve — record `SKIP (geo, SERP-level)` with the snippet
  evidence.
- **Compensation.** If the snippet carries a salary chip or the posting is a
  known sub-floor employer/level below the configured comp floor, do not
  retrieve — record `SKIP (comp, SERP-level board estimate)`. Treat a search
  engine's salary chip as a board estimate, never the employer figure.
- **Aggregator "Remote" is not trustworthy.** Generic remote-jobs aggregators
  routinely relabel a country-restricted canonical posting as "Remote."
  Always trace to the first-party / origin board before scoring location.
- **Staffing-firm-fronted / aggregator-only listings** — the primary JD is
  usually unreachable without applying, and end client / work model / comp
  are unstated. Skip unless the end client is named *and* a primary JD is
  reachable.
- **Unverifiable employer pattern.** Same job text reposted across multiple
  aggregators with contradictory locations and no first-party careers page =
  staffing spam. Do not pursue.

## Retrieval (once a hit clears the SERP screen)

Follow the normal source order: supplied text → public `WebFetch` / ATS API →
configured browser tool (read-only) → ask the user. Run the still-open check
(`job-posting-retrieval` § Still-open check) before spending evaluation
effort on any search-sourced hit — a clean static fetch of an ATS posting is
not proof the req is open.

- `WebFetch` typically works for Greenhouse HTML and for the ATS JSON APIs.
- `WebFetch` typically fails (SPA shell or 403) on Ashby, Lever, and most
  enterprise careers sites → the configured browser tool is the workhorse for
  those.
- The Greenhouse job-board API 404s once a req is closed. Search-index
  results routinely point at a dead job ID — if the API 404s, look for the
  live requisition on the company's board.

## Identity and canonical-link verification

At every handoff (SERP → aggregator → first-party, or slug redirect), verify
company, role title, and material location against the first-party source.
Persist the first-party / ATS role URL as canonical, never the search-results
URL or an aggregator mirror. On mismatch or a redirect to a different role / a
search page, return `ambiguous.identity` or `invalid.redirect` and do not
evaluate.

## Bonus-discovery harvest

"Related jobs" / repeated-in-multiple-queries roles that weren't in the
planned title list are pre-filtered for thematic fit. Log these under a
"bonus discoveries" heading in the session file and run a dedicated retrieval
pass on them **before** starting a fresh keyword search.

## Search tuning

- Run one query per target title with an explicit location token and a
  recency filter matched to your sweep cadence (weekly recency for a
  biweekly sweep; daily for a same-week top-up).
- Attractiveness of a hit is **not** a stop condition; process the cleared
  list in order to the configured cap, then the bonus-discovery list.

## Scope

Exclude the search engine's own UI (People Also Ask, related searches, ads,
knowledge panel, map pack), aggregator navigation, and every other result
card from a posting record.

## Known failures and recovery

- LinkedIn-only hit → drop it; careers-site / ATS / paste fallback, else
  `user.input.required`.
- Aggregator "Remote" masking a country restriction → trace to origin board;
  score location off the first-party page only.
- Staffing-fronted listing with no reachable primary JD →
  `retrieved.incomplete`, no verdict; do not infer from the snippet.
- Dead job ID from the search index → find the live requisition on the
  company board; if none, `invalid.redirect` / role closed.
- Salary chip → board estimate, comp gate held at `Unknown` until the
  employer figure is read on the first-party page.

## Evidence quality

Everything on the results page — title, snippet, age chip, salary chip — is
the search engine's parse, not employer-posted fact. Primary-source quality
depends entirely on the first-party / ATS page the hit is traced to.

## Verification date

Provisional until your first live run — record the date and yield here.

## Confidence

**Provisional.** Promote to durable once a second sweep reproduces the yield
pattern and the tuning notes above hold up.

## Privacy constraints

Do not persist search-engine account state, cookies, session identifiers, the
signed-in user's search history, or full SERP dumps. Keep only the specific
role hits worth retrieving and their first-party URLs.
