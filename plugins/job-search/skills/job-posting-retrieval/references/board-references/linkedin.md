# LinkedIn Board Reference

> **⛔ Browser-tool retrieval is off-limits for LinkedIn, as a standing rule.**
> Do not point the configured `browser_tool` (or any assisted browser) at any
> `linkedin.com` URL — navigation, page reads, form reads, interaction, and
> screenshots are all off-limits. Assisted browsing on LinkedIn risks account
> restriction; treat this as non-negotiable regardless of how the rest of
> your config is set up.
>
> For a LinkedIn posting: use public `WebFetch` / the ATS API / the user's
> pasted text; if none reach it, return `user.input.required` and ask the
> user to paste the description. **Everything below still applies to
> user-supplied LinkedIn content** — identity checks, canonical
> `/jobs/view/<id>/` URL rules, scope, and evidence-quality rules — it just
> no longer authorizes a browser-tool retrieval path.

- URL pattern: `linkedin.com/jobs/view/`
- Detection: confirm the page is in the LinkedIn Jobs product, not a profile,
  feed, search landing page, or recommendation page.
- Board navigation: if LinkedIn opens on a profile or another product, use
  the top navigation `Jobs` link. On the Jobs landing page, use `View all` on
  the relevant recommendation/search section before selecting a posting.
- Inventory: use the active search/list result set and its visible scope or
  count, not recommendations, notifications, or recent-activity shortcuts.
  Record every role in scope before opening details and reconcile the final
  retrieved count.
- Return navigation: capture the current jobs search/list URL before opening
  a title link or detail view; return to that URL before selecting the next
  role.
- Detail retrieval: open the job card and verify the header title, company,
  location, and work model. In the job description, click `More` when
  present to expand all details, then re-read the page and extract the
  requirements.
- Canonical link: prefer the direct `/jobs/view/<id>/` URL. If the card or
  browser URL is a search/redirect URL, use the job header `…` menu →
  `Share` → `Copy link`, then verify that the copied URL resolves to the
  same title and company. If that path is unavailable, record the current
  URL as provisional.
- Identity: verify the detail header title, company, location, and work
  model against the originating card. Treat card-to-detail IDs and redirect
  URLs as volatile; record a mapping warning when they disagree.
- Scope: exclude LinkedIn navigation, recommendations, applicant analytics,
  promotional modules, and unrelated jobs from the posting record.
- Evidence quality: distinguish employer-posted compensation and work model
  from LinkedIn labels, promoted status, recommendations, and match advice.
- Known failures: login wall, expired posting, duplicated responsive markup,
  redirected search pages, stale card-to-detail IDs, and incomplete content.
- Recovery: record the appropriate named outcome; mark identity ambiguous
  when title/company cannot be verified; ask the user for supplied posting
  text when reliable content cannot be retrieved.
- Confidence: medium — navigation and `More` expansion are the well-tested
  path; canonical-link copying is more failure-prone.
