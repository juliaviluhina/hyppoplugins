# Board Reference — BackedNYC / Startup Jobs NYC

## Board name and URL patterns

- Board: `BackedNYC / Startup Jobs NYC`
- Inventory: `https://backednyc.com/`
- Detail links observed: `https://jobs.ashbyhq.com/<company>/<posting-uuid>`
- Surface type: curated startup-role inventory; Ashby is the detail/ATS host.

## Detection guidance

Detect `backednyc.com` as the inventory surface. A card or board URL is not a
canonical job posting. Detect an Ashby URL with a company slug and posting
UUID as the detail retrieval candidate; preserve both exactly.

## Preferred retrieval approach

1. Capture the inventory URL and the card's board position before opening
   it.
2. Extract the stable Ashby detail URL from the card and retrieve that URL
   through public HTML or the supported Ashby endpoint.
3. Verify company, title, location, and canonical URL on the Ashby detail
   page.
4. Capture the full responsibilities and qualification sections and
   independently verify that the role is still open before marking it
   complete.
5. Return to the captured inventory URL before selecting another role.
6. Reconcile the role against the retrieval ledger, application folders, and
   any outreach tracker before treating it as new.

## Inventory and completeness rules

BackedNYC is an inventory/discovery board, never the canonical source for a
role. Board cards may provide company, title, location, department, funding
stage, headcount, posting date, and a company summary, but those fields are
discovery metadata. Do not infer responsibilities, qualifications,
compensation, or open status from a card. Keep the role
`retrieved.incomplete` until the primary detail page contains the material
posting sections and still-open status is confirmed. The board posting date
is provenance only, not proof that the role remains open.

## Identity and canonical-link verification

At the card-to-detail handoff, verify company, role title, and material
location against the Ashby page. Persist the Ashby detail URL as the
canonical role URL, not the BackedNYC inventory URL. On mismatch, redirect,
or a detail URL that does not resolve to one role, return
`ambiguous.identity` or `invalid.redirect` and do not evaluate.

## Known failures and recovery

- A card can expose enough metadata to look like a posting while omitting
  the complete JD. Retrieve the Ashby page; otherwise record
  `retrieved.incomplete`.
- An Ashby URL may be stale or closed. Re-check the detail page and company
  board; record the named still-open outcome rather than inferring
  availability from the BackedNYC date.
- Filtered or navigated inventory state may not survive leaving the board.
  Use the captured inventory URL and verify the expected list before
  continuing.
- Duplicate roles may appear across board runs or ATS surfaces. Match first
  on the canonical Ashby URL/posting UUID, then normalized company and
  title, and reconcile application state before any new evaluation or
  application.

## Evidence quality and assessment

The board is useful for discovery — a sample run should expose stable Ashby
detail URLs for most entries and structured inventory metadata. It is not
sufficient for fit screening by itself; direct Ashby retrieval remains
required. Treat it as a reference for bounded discovery, not a source of
normalized postings.

## Confidence

Provisional-to-high for the observed URL and inventory rules, pending your
own sample run. Retrieval completeness, filter persistence, pagination, and
role-to-role variation still benefit from a multi-role live session before
promoting to durable.

## Privacy constraints

Do not persist credentials, tokens, cookies, session identifiers,
account-scoped content, or unrelated private page content. Keep inventory
captures bounded to the roles being processed; do not store a full board
dump when a bounded run artifact is sufficient.
