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
plus some environment-specific and vendored (github/spec-kit) skills that don't
generalize.

## Before publishing

Run `bash scripts/preflight.sh` (or wire it as a pre-push hook — see the script
header). The same script runs in CI as a required gate on every PR into `main`
(`.github/workflows/preflight.yml`). It fails on:

- absolute home paths, Obsidian-style wiki-links, stray email addresses (the
  author fields in `LICENSE` / `plugin.json` / `marketplace.json` are the only
  allowed spot), the operator's own account handle, obvious secret tokens
- a tracked `.DS_Store`
- a `SKILL.md` whose `name:` doesn't match its directory
- a `marketplace.json` source with no `plugin.json`
- a bundled shell script that fails `bash -n`
- `claude plugin validate .`

What preflight can't judge — check by eye when adding or changing a plugin:

- **Examples still synthetic / unpinned.** No real person's document baked in,
  even a self-published one (rule 2 above).
- **No new hardcoded data.** A new path, threshold, or command name goes in
  config or an argument, not the skill body (rule 1).
- **The skill states its limits** where it can produce a subtly wrong result
  (rule 3).
- **Docs and versions updated** — top-level README, this file, and the
  `marketplace.json` / `plugin.json` version fields for the changed plugin.

Smoke-tested once at 0.2.0: `markdown-to-pdf` renders with both stylesheets, the
page-count guard warns without editing, `STRIP_BEFORE` drops a preamble without
touching the source file.

## Still open

- Fill a real repository URL in the manifests on the first tagged release.
- Add `CONTRIBUTING.md` if outside PRs are wanted.
