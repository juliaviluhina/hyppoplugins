# Board Reference — Welcome to the Jungle (ex-Otta)

**Status: NOT agent-retrievable. Human-browse only.** Detect it so the agent
stops early and hands back, rather than burning effort on a shape it cannot
work.

## Board name and URL patterns

- `welcometothejungle.com`, `us.welcometothejungle.com`,
  `www.welcometothejungle.com/en/jobs`
- `app.welcometothejungle.com/*` — the authenticated matching app (the
  ex-Otta product)
- Absorbed Otta; an `otta.com` link may redirect here.

## Detection guidance

Any `welcometothejungle.com` host. If the URL is under
`app.welcometothejungle.com`, it is the authenticated app; the public
marketing site is the other hosts.

## Preferred retrieval approach

**None succeeds for a sweep.** In order of what typically gets tried:

1. Public site — signup-walled. Anonymous visitors see a marketing landing
   page, no listings, no titles, no salary. `WebFetch` returns the landing
   page.
2. Authenticated app (user logged in, resume uploaded) — a **profile-matched
   card queue**: one job per screen, no list view, small pools.
3. **Pagination is typically blocked** by browser-automation safety layers
   that flag "next" controls as suspected submit controls. The agent can
   read only the currently-displayed card. No outbound ATS/canonical URL is
   in the card DOM without clicking "Apply" (an external act — not
   permitted).

**What the agent should do:** read the current card if one is open (it is a
valid single posting), record it, then return `user.input.required` — ask the
user to advance the queue between reads, or to browse the site themselves
and paste any role of interest. Do not attempt to script the queue.

## Scope / completeness checks

A single card is a complete primary posting (title, company, comp, location,
"Who you are," "What the job involves"). Treat one card as one role; there is
no list to inventory.

## Identity / canonical-link verification

The card title reads `<Company> <Role>`. The only stable link is the app's
own job URL. For a real canonical/ATS URL the user must open "Apply" and
paste the destination.

## Known failures and recovery

| Failure | Recovery |
|---|---|
| `WebFetch` on public site → marketing landing page, no jobs | Expected; there is no public listing. Hand to user. |
| Pagination control click/space → refused by the safety layer | Expected; cannot paginate. Read current card, return `user.input.required`. |
| Signup offered via a third-party login | If that third party is a blocked domain in your setup (e.g. LinkedIn), never route signup through it. Account creation is a user step regardless — the agent never logs in. |

## Evidence-quality notes

A read card is `full-primary-jd`. But coverage is whatever the profile match
surfaces — not a controllable search — so absence of a role here means
nothing.

## Confidence

High that the board is not agent-sweepable. The card-queue UI or the
safety-layer classification would each have to change for this to be
revisited.

## Privacy constraints

The app tab is authenticated to the user's account. Read only job-card
content; never read or transcribe account/profile/messaging panels. No
credentials, cookies, or tokens in notes.
