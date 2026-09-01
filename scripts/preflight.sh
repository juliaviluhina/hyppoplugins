#!/usr/bin/env bash
# Preflight for HyppoPlugins — the mechanical "don't ship this" checks.
#
# Run by hand:   bash scripts/preflight.sh
# As a hook:     ln -s ../../scripts/preflight.sh .git/hooks/pre-push
#
# Exit 0 = clean, 1 = something to look at. The judgment-call checklist that a
# grep can't do lives in DESIGN-NOTES.md ("Before publishing").
# Portable to bash 3.2 (stock macOS).
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
fail=0
note() { printf '  %s\n'            "$1"; }
bad()  { printf '\033[31mFAIL\033[0m %s\n' "$1"; fail=1; }
ok()   { printf '\033[32mok  \033[0m %s\n' "$1"; }

# Tracked text files. Author name/email is intentional in the attribution files;
# it is suspect anywhere else. This script is excluded — it defines the very
# patterns it looks for.
TEXT_FILES=$(git ls-files | grep -vE '\.(png|jpg|jpeg|gif|pdf|ico|woff2?)$' \
  | grep -vxF 'scripts/preflight.sh')
ATTRIB_RE='^(LICENSE|.*/plugin\.json|\.claude-plugin/marketplace\.json)$'

# scan <label> <grep-ere>  — flag any match in TEXT_FILES
scan() {
  local hits
  hits=$(printf '%s\n' "$TEXT_FILES" | tr '\n' '\0' | xargs -0 grep -nEI -- "$2" 2>/dev/null)
  if [ -n "$hits" ]; then bad "$1"; printf '%s\n' "$hits" | sed 's/^/     /'
  else ok "$1"; fi
}

echo "== content =="
scan "no absolute home paths (/Users/… /home/…)"          '/(Users|home)/[a-z]'
scan "no [[wikilink]] vault refs"                          '\[\[[^]]+\]\]'
scan "no personal iCloud/account handle"                   'naval-94coals'
scan "no obvious secrets (sk-/ghp_/AKIA/xoxb-/PRIVATE KEY)" \
     '(sk-[A-Za-z0-9]{20}|ghp_[A-Za-z0-9]{20}|AKIA[0-9A-Z]{16}|xoxb-[0-9]|-----BEGIN [A-Z ]*PRIVATE KEY-----)'

mail_hits=$(printf '%s\n' "$TEXT_FILES" | grep -vE "$ATTRIB_RE" | tr '\n' '\0' \
  | xargs -0 grep -nEI -- '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' 2>/dev/null)
if [ -n "$mail_hits" ]; then
  bad "no email addresses outside LICENSE / plugin.json / marketplace.json"
  printf '%s\n' "$mail_hits" | sed 's/^/     /'
else ok "no stray email addresses"; fi

echo "== structure =="
if git ls-files | grep -qi 'ds_store'; then bad ".DS_Store is tracked"; else ok "no .DS_Store tracked"; fi

sk_fail=0
while IFS= read -r sk; do
  [ -n "$sk" ] || continue
  dir=$(basename "$(dirname "$sk")")
  nm=$(awk -F': *' '/^name:/{print $2; exit}' "$sk" | tr -d '[:space:]')
  if [ "$dir" != "$nm" ]; then bad "SKILL name '$nm' != dir '$dir'  ($sk)"; sk_fail=1; fi
done < <(git ls-files '*/SKILL.md')
[ "$sk_fail" -eq 0 ] && ok "every SKILL.md name matches its directory"

while IFS= read -r src; do
  [ -n "$src" ] || continue
  if [ -f "$src/.claude-plugin/plugin.json" ]; then ok "manifest source resolves: $src"
  else bad "marketplace source has no plugin.json: $src"; fi
done < <(grep -oE '"source": *"[^"]+"' .claude-plugin/marketplace.json | sed -E 's/.*"(\.[^"]*)"/\1/')

while IFS= read -r s; do
  [ -n "$s" ] || continue
  if bash -n "$s" 2>/dev/null; then ok "bash -n $s"; else bad "bash -n failed: $s"; fi
done < <(git ls-files '*.sh')

echo "== plugin manifest =="
if command -v claude >/dev/null 2>&1; then
  if claude plugin validate . >/tmp/pf.$$ 2>&1; then ok "claude plugin validate ."
  else bad "claude plugin validate ."; sed 's/^/     /' /tmp/pf.$$; fi
  rm -f /tmp/pf.$$
else
  note "claude CLI not on PATH — skipped 'claude plugin validate .'"
fi

echo
if [ "$fail" -eq 0 ]; then echo "preflight: clean"; else echo "preflight: review the FAIL lines above"; fi
exit "$fail"
