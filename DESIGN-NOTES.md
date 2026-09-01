# HyppoPlugins — design notes

How these plugins were built and what is deliberately left out. Not needed to
*use* the plugins — see the top-level `README.md` and each plugin's own README.

## What this is

Three plugins, each a genericized fork of a skill originally written for one
person's private setup:

- **mnookin-two-pager** — `mnookin-grill` + `mnookin-analysis-artifacts`
- **conversation-to-skill** — one skill of the same name
- **markdown-to-pdf** — one skill of the same name, with a bundled script + styles

Every place the original named a specific file or folder, the fork names a
*role* and reads the actual path from config or an argument the user supplies.

## Hard constraints every plugin here holds to

1. **Zero dependency on the author's data or folder layout.** No real employer
   names, no comp numbers, no personal file paths, no CV content, no job-search
   history. Paths come from a user-supplied config file or CLI args.
2. **A name on a LICENSE / author field is attribution, not exposure** — that is
   expected for OSS.
3. **No third party's personal document in the repo.** `mnookin-grill`'s
   calibration example is a fabricated composite ("Sam Rivera"), not a real
   person's two-pager — even a self-published one. A real named document would
   rot when its author edits it and is not ours to keep permanent. An unpinned
   "search for a current community example" pointer is the only external
   reference.

## Skill mapping (original → this repo)

| Original skill | Here | Main genericization move |
|---|---|---|
| `mnookin-grill`              | `mnookin-two-pager/skills/mnookin-grill`            | Two-pager / evidence-doc paths become config, not literals. Memory reference removed. Named public example replaced with a fabricated composite (`example.md`). |
| `mnookin-analysis-artifacts` | `mnookin-two-pager/skills/mnookin-analysis-artifacts` | The hardcoded artifact set becomes a user-supplied `mnookin.config.yaml` with N positioning angles, not a fixed two. Dated personal anecdotes in the "rules" section reduced to generic phrasing. |
| `conversation-to-skill`      | `conversation-to-skill/skills/conversation-to-skill` | Near-verbatim — already clean. Added: a plugin `skills/` dir as a third valid install target. |
| `md-to-pdf`                  | `markdown-to-pdf/skills/markdown-to-pdf`            | Rebuilt as a plain converter. Bundled the shell script + both stylesheets (renamed by typography, not use-case: `dense.css`, `prose.css`). Dropped: a hardcoded name as the content-split marker (→ optional `STRIP_BEFORE`, off by default), the auto-trim-until-2-pages loop (→ `PAGE_TARGET` *warn only*, never edits content), all personal paths, the sync-back step, and file-delivery. `CSS` / `CHROME_BIN` / `STRIP_BEFORE` / `PAGE_TARGET` are the only knobs. |

Not forked: `hyppovisor` (its home is the `juliaviluhina/hyppovisor` repo),
plus some vault-specific and vendored (github/spec-kit) skills.

## Pre-publish checks that were run

- `grep -ri` for real employer names, personal email/phone, personal file
  paths, `[[wikilink]]` refs → zero hits in shipped files (author name/email in
  `LICENSE` and `plugin.json` author fields is intentional).
- `claude plugin validate .` → passes.
- `markdown-to-pdf` converter smoke-tested: both stylesheets render, page-count
  guard warns without editing, `STRIP_BEFORE` drops a preamble without touching
  the source file.

## Still open

- Fill a real `version` bump and the repository URL in the manifests on the
  first tagged release.
- Add `CONTRIBUTING.md` if outside PRs are wanted.
