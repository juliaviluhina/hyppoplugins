# markdown-to-pdf

`markdown → HTML (pandoc) → PDF (headless Chrome)`. One skill, one script, two
bundled stylesheets. Takes `.md` in, writes `.pdf` next to it.

## Use it when

- "make a PDF of this"
- "render this markdown to PDF"
- "convert X.md to PDF"

## Parameters (all env vars, all optional)

| Var | Default | What it does |
|---|---|---|
| `CSS` | `dense` | `dense` (compact sans), `prose` (roomy serif), or a path to your own `.css`. Fonts, margins, paper size all live in the stylesheet. |
| `CHROME_BIN` | macOS Google Chrome | Chromium-family binary; `google-chrome` / `chromium` on Linux. |
| `STRIP_BEFORE` | *(off)* | Drop every line before the first line containing this string — for sources with an internal header block. Source file is not modified. |
| `PAGE_TARGET` | *(off)* | Warn (never edit) if the PDF exceeds this many pages. Needs `pdfinfo`. |

```bash
PAGE_TARGET=2 CSS=dense bash scripts/md-to-pdf.sh doc.md
```

## Requires

`pandoc`, a Chromium-family browser, and optionally `poppler` (`pdfinfo` /
`pdftotext`) for the page check.

## Install

```
/plugin install markdown-to-pdf@hyppo-plugins
```
