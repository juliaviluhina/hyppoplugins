# HiringCafe Board Reference

- Board name: HiringCafe
- URL patterns:
  - `hiringcafe.com/` — the search/inventory surface. Filters (Location,
    Departments, Job Titles & Keywords, Salary, Security Clearance, Travel
    Requirement, Commitment, …) are applied here. Filter/search state is
    **not reliably reflected in the URL** — an applied search can still show
    a bare `https://hiringcafe.com/` address, with state held in client
    storage.
  - `hiringcafe.com/job/<role-slug>-<company-slug>-<location-slug>-<16-char-id>`
    — one specific role-detail page. The trailing 16-character token is the
    stable job ID. This is the canonical role URL to persist.
- Detection: host is `hiringcafe.com`. A path of `/job/...` is a specific
  role; `/` (with or without query parameters) is the inventory/search
  surface.
- Inventory rule: `hiringcafe.com/` and any filtered search view is an
  inventory/search page — not a job posting, must not be persisted or
  evaluated. If a specific role identity and primary description are not
  available, return `retrieved.incomplete` or `user.input.required`.
- Filtered-list capture rule: because filter state may not live in the URL,
  capture the **exact URL present in the tab after filters are applied** as
  the session return location, and record separately which filters are
  active, read from the visible filter chips / results header. Do **not**
  perform a full page reload of the inventory tab during the session — a
  reload can drop the filters back to the generic "Latest jobs" feed.
- List-state verification: before treating the inventory as the filtered
  list, confirm the results header is **not** the generic relevance feed
  unless that is genuinely the intended search. If the generic feed appears
  where a filtered list is expected, stop and ask the user to re-apply
  filters; record `retrieved.incomplete` for the list, not a guess.
- Card structure (discovery only): each result card carries recency (e.g.
  `1h`), role title, location, a salary string, work model
  (`Remote`/`Hybrid`/`Onsite`/`Field`), commitment (`Full Time`/`Part
  Time`/`Contract`/…), company block (name + a one-line HiringCafe company
  description + favicon), a one-paragraph HiringCafe-generated requirements
  distillation, a `Job Posting` link to `/job/<slug>`, and a signal row
  (views · saves · applications). All of this is HiringCafe metadata —
  discovery only, never a substitute for the employer's detail-page wording.
- Detail retrieval: from the selected card, take the `Job Posting` link's
  `href` (`/job/<slug>`), capture the current inventory URL as the return
  location, then navigate the tab to the detail URL (read-only). Wait for the
  `Job description` section to render, then read the page. The full employer
  JD renders on a single page.
- What counts as employer text: use only the **`Job description` →
  `Description & Requirements`** body (verbatim employer JD). The top-of-page
  `RESPONSIBILITIES` / `REQUIREMENTS` chips and the card paragraph are
  HiringCafe's AI distillation — **not** verbatim; do not score against them.
  The `Company info` panel is HiringCafe-aggregated context.
- Identity and canonical-link verification: verify company, role title, and
  material location against the detail-page header and the browser tab
  title. Persist the detail-page URL as the canonical role URL. On mismatch,
  redirect, or a detail page that fails to resolve to a single role, return
  `ambiguous.identity` or `invalid.redirect` and do not evaluate.
- Compensation rule: prefer the employer-stated figure in the detail page's
  **`Compensation & Benefits Package`** section (e.g. "Base Pay Range: $X –
  $Y"). The card salary string and any range shown outside that section are
  HiringCafe parses — treat those as a board estimate
  (`../../job-fit-screen/references/rubric.md` § Board compensation-estimate
  rule). If the detail page has no employer compensation section, mark
  `Not stated in source` and hold the comp gate at `Unknown`.
- Return-before-next rule: after reading or saving the current role,
  navigate the tab back to the captured inventory URL. Confirm the filtered
  result list (not the generic feed) has reloaded before selecting another
  role. If the filters have dropped, stop and ask the user rather than
  screening the wrong list.
- External-link rule: `Apply directly on employer's site`, `Job Posting`
  (when it points off-site), `Save job`, `Track`, `Hide`, and `Talent Agent`
  are actions/links to employer ATSes or authenticated HiringCafe features.
  Never follow them to apply, save, track, or message. If the detail page
  itself is incomplete, the employer ATS URL may be used as a fallback
  **retrieval** source under the normal source order — read-only, identity
  re-verified — but this is the exception, not the default.
- Scope: exclude navigation, filter panels, `EXPLORE JOBS` / `Browse Jobs by
  State` footer links, `Want more roles like this?` / `Talent Agent` promos,
  company-info aggregation, and other result cards from the posting record.
- Known failures: inventory reload drops filters to the generic feed;
  confusing the AI distillation chips for verbatim employer requirements;
  filter state absent from the URL so a naive "return to list URL" can land
  on the unfiltered root; numbered pagination where advancing a page is a
  list action.
- Recovery: if no single role identity resolves, return `retrieved.incomplete`
  or `user.input.required`; do not infer the role from a card. If the
  filtered list is lost, ask the user to re-apply filters before continuing.
- Evidence quality: HiringCafe reproduces the employer JD in full on the
  detail page, including the employer's own compensation section — good
  primary-source quality when the job-description body is used. Everything
  else it generates or aggregates is board metadata, not employer-posted
  fact.

## Search tuning

- A bare AI-flavoured `jobTitleQuery` returns a large list dominated by roles
  that match the keyword without matching an engineering IC profile. To raise
  signal:
  - **Add `departments`** (Filters → Departments) = Engineering / Software
    Engineering — this is the single highest-leverage cut, removing
    PM/sales/marketing/design/procurement noise the keyword query pulls in.
  - **Prune the `jobTitleQuery`** to your actual target titles and drop bare
    generic tokens (e.g. a lone `"AI"`) that match unrelated roles. HiringCafe
    also supports **`Exclude Jobs`** (Filters → Exclude Jobs) to back this up
    (Product Manager, Sales, Analyst, Designer, …).
  - **`Sort by: Date`** instead of Relevance for the newest reqs rather than
    the highest keyword-density matches.
  - **Salary filter semantics — verify before trusting.** Field names
    (`maxCompensationLowEnd`, the paired `minCompensationHighEnd`) don't
    obviously map to "floor at least X." Set the salary slider in the UI to
    the intended band and read back the resulting `searchState` rather than
    hand-editing the number, so the filter isn't silently excluding or
    including the wrong end of the range.
  - **`restrictJobsToTransparentSalaries: true` is worth keeping** — it
    guarantees every card carries an employer figure, so the comp gate can
    resolve instead of sitting at `Unknown`.
  - **`roleTypes: ["Individual Contributor"]` did not reliably exclude** PM
    or analyst roles in practice (those are IC-titled). It is not a
    substitute for the department filter.
  - Attractiveness of the resulting list is still not a stop condition;
    process in list order to the configured role cap.
- Confidence: **provisional**. Filtered-list URL behavior with real filters
  applied, numbered-pagination navigation, authenticated-only views, and
  role-to-role completeness variation all need a multi-role session to
  verify. Promote to durable after that.
- Privacy constraints: do not persist credentials, tokens, cookies, session
  identifiers, the signed-in user's saved/tracked lists, unrelated private
  page content, or full inventory dumps.
