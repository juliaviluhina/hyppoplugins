#!/usr/bin/env bash
# Convert markdown file(s) to a styled PDF via pandoc + headless Chrome.
#
# Usage:  md-to-pdf.sh FILE.md [FILE2.md ...]
#         writes FILE.pdf next to each input.
#
# Env (all optional):
#   CSS=dense|prose|/path/to.css   stylesheet; "dense" and "prose" are bundled
#                                  (default: dense). Fonts, margins and paper
#                                  size live in this file's body / @page rules.
#   CHROME_BIN=/path/to/chrome     Chromium-family binary
#                                  (default: macOS Google Chrome; on Linux try
#                                  "google-chrome" or "chromium")
#   STRIP_BEFORE="text"            drop every line before the first line that
#                                  contains "text"; the source file is not
#                                  modified (default: render the whole file)
#   PAGE_TARGET=N                  if pdfinfo is present, warn (do not edit)
#                                  when the PDF exceeds N pages
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHROME="${CHROME_BIN:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"

CSS="${CSS:-dense}"
case "$CSS" in
  dense|prose) CSS="$DIR/../styles/${CSS}.css" ;;
esac
[ -f "$CSS" ] || { echo "stylesheet not found: $CSS" >&2; exit 1; }
command -v pandoc >/dev/null || { echo "pandoc not found (brew install pandoc)" >&2; exit 1; }
[ -x "$CHROME" ] || command -v "$CHROME" >/dev/null 2>&1 || {
  echo "browser not found: $CHROME  (set CHROME_BIN)" >&2; exit 1; }
[ "$#" -gt 0 ] || { echo "usage: md-to-pdf.sh FILE.md [...]" >&2; exit 1; }

for md in "$@"; do
  base="${md%.md}"
  html="${base}.tmp.html"
  pdf="${base}.pdf"
  src="$md"

  if [ -n "${STRIP_BEFORE:-}" ]; then
    src="${base}.tmp.md"
    awk -v m="$STRIP_BEFORE" 'index($0,m){f=1} f' "$md" > "$src"
    [ -s "$src" ] || { echo "STRIP_BEFORE marker not found in $md" >&2; rm -f "$src"; exit 1; }
  fi

  pandoc "$src" -o "$html" --standalone --css="$CSS" --metadata title=" "

  "$CHROME" --headless --no-sandbox --disable-gpu \
    --print-to-pdf="$pdf" --no-pdf-header-footer \
    "file://$(cd "$(dirname "$html")" && pwd)/$(basename "$html")" \
    2>/dev/null

  rm -f "$html"
  [ "$src" = "$md" ] || rm -f "$src"
  echo "-> $pdf"

  if [ -n "${PAGE_TARGET:-}" ] && command -v pdfinfo >/dev/null; then
    pages="$(pdfinfo "$pdf" | awk '/^Pages:/{print $2}')"
    if [ -n "$pages" ] && [ "$pages" -gt "$PAGE_TARGET" ]; then
      echo "   WARNING: $pdf is $pages pages (target $PAGE_TARGET) — tighten the markdown or the stylesheet" >&2
    fi
  fi
done
