---
name: markdown-to-pdf
description: Convert a Markdown file into a styled PDF using pandoc + headless Chrome. Use when asked "make a PDF of this", "render this markdown to PDF", "convert X.md to PDF", or when a finalized markdown document needs a shippable PDF.
---

# markdown-to-pdf

`markdown → HTML (pandoc) → PDF (headless Chrome print)`. Bundled here:
`scripts/md-to-pdf.sh` and two stylesheets in `styles/`. The script takes one or
more `.md` files and writes a `.pdf` next to each. All tuning is env vars — no
flags to learn.

## Preconditions

- **pandoc** — `brew install pandoc` (macOS), or your package manager.
- **A Chromium-family browser** — Google Chrome, Chromium, or Edge. Default path
  is macOS Google Chrome; override with `CHROME_BIN` (`google-chrome`,
  `chromium`, or a full path).
- **poppler** (optional) — `pdfinfo` / `pdftotext`, only for the page-count
  check and verification.

If pandoc or the browser is missing, install it — don't substitute another
toolchain, the output styling depends on Chrome's print renderer.

## Steps

1. **Pick a stylesheet.**
   - `CSS=dense` (default) — compact sans-serif; fits a lot on few pages
     (résumés, one-pagers, dense tables).
   - `CSS=prose` — roomy serif; built for reading (letters, memos).
   - `CSS=/path/to/your.css` — anything else. **Fonts, margins, and paper size
     all live in the stylesheet** (`body { font-family / font-size }`, `@page
     { size / margin }`). To change fonts, copy a bundled file and edit its
     `body` rule.

2. **Convert.**
   ```bash
   CSS=dense bash scripts/md-to-pdf.sh path/to/doc.md
   # -> path/to/doc.pdf
   ```
   Multiple files in one call are fine.

3. **Optional — strip a preamble.** If the source has an internal header block
   (frontmatter, notes) before the real content, drop it without touching the
   file:
   ```bash
   STRIP_BEFORE="# Report title" bash scripts/md-to-pdf.sh path/to/doc.md
   ```
   Everything before the first line containing that string is removed from the
   rendered copy only.

4. **Optional — page-count guard.** Set a target; the script warns (it does
   **not** edit anything) if the PDF runs longer:
   ```bash
   PAGE_TARGET=2 CSS=dense bash scripts/md-to-pdf.sh path/to/doc.md
   ```

5. **Verify** (if poppler is installed):
   ```bash
   pdfinfo doc.pdf | grep -E "Pages|Page size"
   pdftotext doc.pdf - | head -40          # spot-check text, links, no mojibake
   ```

6. **Deliver** the `.pdf` however your workflow does — the script only writes it
   next to the source.

## Edge cases

- **A `**Bold line**` immediately followed by a `- bullet` with no blank line
  between** → pandoc renders the list as run-on text. Insert a blank line
  between them in the source.
- **PDF is over the page target and prose edits won't shift the last orphan
  line** → tighten the *stylesheet* (smaller `@page` margin, `font-size`, or
  `line-height`) rather than cutting content; or remove one `---` before a short
  trailing section.
- **`mdls -name kMDItemNumberOfPages` returns `(null)`** on a freshly written
  file → Spotlight hasn't indexed it; use `pdfinfo` for the page count.
- **Links or emoji render as boxes / wrong glyphs** → the stylesheet's
  `font-family` stack has no face with those glyphs; add one to the `body` rule.
- **Linux/CI** → `CHROME_BIN=google-chrome` (or `chromium`) and keep
  `--no-sandbox` (already in the script).
- **`STRIP_BEFORE` marker not found** → the script errors instead of producing a
  wrong PDF; check the exact text of the first real content line.
