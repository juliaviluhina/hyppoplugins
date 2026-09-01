# HyppoPlugins

<img src="assets/hyppoplugins.png" alt="HyppoPlugins" width="200" align="right">

**A small marketplace of general-purpose [Claude Code](https://docs.claude.com/en/docs/claude-code) skills.**

Nothing here is tied to one person's data or folder layout — each skill takes its
paths and options from config or arguments you supply. One of the HyppoHelpers.

<br clear="right" />

## Plugins

| Plugin | What it does |
|---|---|
| **[mnookin-two-pager](./plugins/mnookin-two-pager)** | Two skills for the *Never Search Alone* (Mnookin) two-pager: `mnookin-grill` interviews you one question at a time to draft or sharpen it; `mnookin-analysis-artifacts` propagates a locked/updated two-pager into your downstream docs (shortlist, CV variants, screening questions) so they never silently drift from your stated criteria. |
| **[conversation-to-skill](./plugins/conversation-to-skill)** | Turn a finished conversation into a reusable Claude Code skill — repeatable steps, exact commands, and your corrections captured as edge cases. |
| **[markdown-to-pdf](./plugins/markdown-to-pdf)** | Render Markdown to a styled PDF (pandoc + headless Chrome). Bundled compact / prose stylesheets or your own; optional preamble-strip and page-count guard. |

More to come — this is a collection, not a single tool.

## Install

```
/plugin marketplace add juliaviluhina/HyppoPlugins
/plugin install mnookin-two-pager@hyppo-plugins
```

Then, once, create the config the skills expect (see the plugin's own README).

## Design rules for anything added here

1. **No author's-own data in the skill body.** Paths, thresholds, document
   names, and build commands come from a user-supplied config file, never
   hardcoded.
2. **Examples are synthetic or unpinned.** A calibration example is a
   fabricated composite, or a "go find a current community example" pointer —
   never a named individual's personal career document baked into the repo,
   even a self-published one. It isn't ours to keep, and it rots when the
   author edits it.
3. **Skills state their limits.** Where a skill can produce a subtly wrong
   result (over-length output, an unverified claim), it says so and stops
   rather than guessing.

## License

MIT — see [LICENSE](./LICENSE).
