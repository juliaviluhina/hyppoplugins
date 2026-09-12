# Board Reference — Remote100K

**Status: agent-retrievable, but often low-value inventory depending on your
target roles.** Mechanics are fine; check whether the role mix matches your
titles before running a full sweep — a Tier-A-only skim is a reasonable
starting bet.

## Board name and URL patterns

- `remote100k.com`
- Listing paths: `/remote-jobs/<facet>` — e.g. `/remote-jobs/engineering`,
  `/remote-jobs/usa`, `/remote-jobs/seniority/senior`, `/remote-jobs/full-time`,
  `/remote-jobs/contract`, per-country and per-region paths.
- Detail paths: `/remote-job/<company-slug>-<role-slug>`.

## Detection guidance

Any `remote100k.com` host.

## Preferred retrieval approach

1. **Browser-tool page read on a listing path** — no login required; the
   full list is returned verbatim (a category listing page can run well over
   100 cards). Parse cards: `title, company, age, salary, "Remote: <country>",
   function, type, [seniority]`.
2. `WebFetch` on the same paths can work but the summarizer is lossy on a
   large card page and multi-facet query-param combining is unconfirmed —
   prefer a full page read for the list.
3. Detail pages (`/remote-job/...`) are static enough for `WebFetch`; each
   card also carries the employer's own posting, so follow through to the
   first-party/ATS URL and evaluate that (Remote100K is an aggregator —
   "apply directly, no account required").

## Filtering

Path-based, one facet per path segment. Combining facets in one URL is not
confirmed to work reliably (appended query params can be ignored). Filter
after retrieval instead: location, IC-only (drop Manager/Director/Executive),
comp floor, then your target-role tier keywords.

## Scope / completeness checks

The listing header states the count (e.g. "Showing N Engineering jobs"). A
parse that yields materially fewer than the stated count is incomplete —
re-read.

## Identity / canonical-link verification

Card salary/location/seniority are Remote100K's normalization, not the
employer's — verify against the first-party posting the detail page links to
before scoring. Confirm work-model on the primary JD even when the card
looks reliable.

## Known failures and recovery

| Failure | Recovery |
|---|---|
| Page-read output exceeds the token cap (large list) | It is saved to a file; parse with a script (title/company/salary/location/seniority), don't re-read raw. |
| Appended query params ignored | Expected; filter post-retrieval. |
| Detail page thin / stale | Aggregator lag. Go to the employer's own board; if the req is gone, record `invalid.redirect`. |

## Evidence-quality notes

Run a full engineering-category scan once before committing to this board as
a regular surface, and record the tier mix you find (Tier A / B / C counts)
so future runs know whether the yield justifies the effort.

## Confidence

Mechanics (listing read, detail-page fetch, filter-after-retrieval pattern)
are stable. Filter-URL combining mechanics are only partly mapped.

## Privacy constraints

No login; nothing account-scoped. Standard: no credentials/tokens/cookies in
notes.
