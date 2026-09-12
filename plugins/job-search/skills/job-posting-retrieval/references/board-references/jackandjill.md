# Jack & Jill Board Reference

- URL pattern: `app.jackandjill.ai/`
- Detection: confirm the page identifies one role, employer, location, and
  board detail URL.
- Preferred approach: read tracked-job cards, open the detail page, verify
  title/company against the card, then read the posting progressively while
  excluding navigation, recommendations, and unrelated listings.
- Inventory: use the actual Tracked jobs kanban and requested column count as
  the source of truth. Do not use Recent activity as the inventory; it can
  omit cards. Record every card in scope before opening any detail page and
  reconcile the final retrieved count to the column count.
- Card retrieval: click each card to obtain its current
  `/jack/dashboard/jobs/kanban/<UUID>` route, including cards without
  initially visible URLs. Treat UUIDs as volatile and replace stale ledger
  routes with the current card route.
- Return navigation: capture the tracked-jobs board URL before opening a
  card; return to that URL before selecting the next posting.
- Dynamic content: if `Read more` is present, click it only to reveal the
  rest of the description and re-read the page. Record whether expansion was
  required.
- Evidence quality: the board's own summary, "take," labels, and estimated
  compensation are not employer-provided posting facts. Prefer an external
  primary posting when available for conflicts about work mode or
  compensation.
- The board's estimated compensation falls under the board
  compensation-estimate rule (`../../job-fit-screen/references/rubric.md`
  § Board compensation-estimate rule).
- Known failures: dynamic content, redirected listings, incomplete fields,
  expired postings, and internal card URLs resolving to a different role.
- Recovery: verify title/company before scoring; mark `mapping-warning` for a
  mismatched URL. For missing or blocked material, use a named
  incomplete/blocked outcome and ask the user rather than infer.
- Intro status: record requested-intro cards as tracked roles; an intro
  request is not a submitted application and must not trigger an external
  action.
- Confidence: high for title/company verification, URL-mapping warning, and
  tracked-card → detail route; medium for other behavior.
