# Himalayas Board Reference

- Board name: Himalayas
- URL patterns: `himalayas.app/jobs`, `himalayas.app/jobs/<role-slug>`,
  `himalayas.app/jobs/countries/<country>/<category>?<filters>`,
  `himalayas.app/onboarding/talent/matches`, and role-detail URLs reached
  from a job card.
- Filtered-list URL rule: filtered URLs narrow discovery by country,
  category, and query/filter parameters. Treat them as inventory/search
  pages, not postings; preserve the full filtered URL as the session return
  location and use it only to discover specific role cards.
- Detection: confirm the page belongs to Himalayas and determine whether it
  is a generic inventory/search page, an authenticated resume-based matches
  page, or one specific role detail page.
- Inventory rule: `/jobs` and `/onboarding/talent/matches` are inventory/
  search pages. They are not job postings and must not be persisted as roles
  or evaluated. Return `retrieved.incomplete` or `user.input.required` until
  a specific role identity and primary description are available.
- Matches-page context: record the visible match count and, when shown, the
  matching inputs (uploaded-resume matching, salary preference, search
  status). Treat this context as discovery metadata, not employer-provided
  qualification evidence.
- Card rule: extract a role-card title, company, and stable role link for
  discovery only. Card salary, employee count, categories, recency, and
  match placement are Himalayas metadata; do not use them as a substitute for
  the employer's detail-page wording. The matches page may show roles below
  your configured comp floor, so compensation must be checked on the detail
  page.
- Detail retrieval: from the selected card, capture the current matches/
  search URL as the return location, click the specific position title, and
  wait for the role-detail page to load. Verify company, role title,
  canonical source URL, location/work model, responsibilities, and required
  qualifications on that page. Preserve employer wording.
- Return-before-next rule: after reading or saving the current role,
  navigate back to the captured matches/search URL before selecting another
  position; do not rely on browser history or an in-page back button.
  Confirm that the inventory page and its role list have loaded before
  continuing.
- Stable-URL rule: persist the role-detail URL (e.g.
  `/companies/<company>/jobs/<role-slug>`), never the matches-page URL or a
  card's surrounding inventory URL.
- Scope: exclude navigation, sponsored content, recommendations, related
  searches, and other inventory cards from the posting record.
- Known failures: landing-page-only URLs, inventory cards without a stable
  role URL, incomplete descriptions, login walls, and redirects to search
  results.
- Recovery: select/open the specific role detail page and verify identity.
  If no specific role can be identified, return `retrieved.incomplete` or
  `user.input.required`; do not infer the role from a card or search phrase.
- Evidence quality: distinguish Himalayas labels, estimates, sponsored
  content, and recommendation metadata from employer-posted facts. Mark
  absent compensation, authorization, and work-model fields
  `Not stated in source`.
- Confidence: high for the authenticated matches-page inventory and
  role-detail navigation when tested through a live browser-tool session;
  individual roles may still vary in completeness or redirect behavior.
- Privacy constraints: do not persist credentials, tokens, cookies,
  unrelated private page content, or full inventory dumps.
