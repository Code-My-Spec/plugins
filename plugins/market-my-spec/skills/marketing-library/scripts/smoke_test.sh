#!/usr/bin/env bash
#
# Smoke test for the marketing-library skill.
# Mirrors the marketing-stack smoke test pattern, adapted for plugins.

set -u

if [ -n "${SKILL_DIR:-}" ]; then
  SKILL="$SKILL_DIR"
elif [ -f "./SKILL.md" ] && [ -d "./plugins" ]; then
  SKILL="."
elif [ -d "./plugins/market-my-spec/skills/marketing-library" ]; then
  SKILL="./plugins/market-my-spec/skills/marketing-library"
elif [ -d "./skills/marketing-library" ]; then
  SKILL="./skills/marketing-library"
else
  echo "ERROR: can't find marketing-library skill dir." >&2
  exit 1
fi

cd "$SKILL" || exit 1

PASS=0
FAIL=0
WARN=0

ok()   { echo "  ✓ $1"; PASS=$((PASS+1)); }
bad()  { echo "  ✗ $1"; FAIL=$((FAIL+1)); }
warn() { echo "  ! $1"; WARN=$((WARN+1)); }

echo "# marketing-library smoke test"
echo "Skill root: $(pwd)"
echo

echo "## Top-level files"
for f in SKILL.md steps/inventory.md steps/install_plugin.md steps/audit.md steps/suggest.md steps/blueprint.md; do
  if [ -f "$f" ]; then ok "$f"; else bad "$f missing"; fi
done
echo

echo "## Every plugin directory is documented in SKILL.md"
if [ -d plugins ]; then
  for d in plugins/*/; do
    name=$(basename "$d")
    if grep -qF "\`$name\`" SKILL.md; then
      ok "$name documented in SKILL.md"
    else
      bad "$name has a plugin directory but isn't mentioned in SKILL.md"
    fi
  done
else
  bad "plugins/ directory missing"
fi
echo

echo "## Plugin directories have PLUGIN.md"
for d in plugins/*/; do
  name=$(basename "$d")
  if [ -f "${d}PLUGIN.md" ]; then ok "$name has PLUGIN.md"; else bad "$name missing PLUGIN.md"; fi
done
echo

echo "## Plugin frontmatter"
REQUIRED_FIELDS="name tier purpose covers_loops covers_channels install_command marketplace detection verification"
for f in plugins/*/PLUGIN.md; do
  name=$(basename "$(dirname "$f")")
  frontmatter=$(awk 'BEGIN{n=0} /^---$/{n++; next} n==1{print}' "$f")
  missing=""
  for field in $REQUIRED_FIELDS; do
    if ! echo "$frontmatter" | grep -qE "^${field}:"; then
      missing="$missing $field"
    fi
  done
  if [ -z "$missing" ]; then ok "$name frontmatter complete"; else bad "$name missing:$missing"; fi
done
echo

echo "## Plugin body sections"
REQUIRED_SECTIONS="## What it is|## Skills shipped|## When to install|## Strategy fit|## Prerequisites|## Install steps|## Auth setup|## Verification|## Gotchas|## Links"
for f in plugins/*/PLUGIN.md; do
  name=$(basename "$(dirname "$f")")
  missing=""
  IFS='|' read -ra SECTIONS <<< "$REQUIRED_SECTIONS"
  for s in "${SECTIONS[@]}"; do
    if ! grep -qF "$s" "$f"; then
      missing="$missing;${s}"
    fi
  done
  if [ -z "$missing" ]; then ok "$name body sections present"; else warn "$name missing sections:$missing"; fi
done
echo

echo "## .env-only hygiene (no plausible secret patterns in PLUGIN.md files)"
found_suspected=false
for f in plugins/*/PLUGIN.md; do
  name=$(basename "$(dirname "$f")")
  matches=$(grep -vE '^(#|```|  |-)' "$f" | grep -oE '[A-Za-z0-9_-]{40,}' | grep -E '[0-9]' | grep -E '[a-z]' | grep -E '[A-Z]' || true)
  if [ -n "$matches" ]; then
    warn "$name has suspicious long token(s) — verify they're placeholders: $(echo "$matches" | head -1)"
    found_suspected=true
  fi
done
if [ "$found_suspected" = false ]; then ok "no suspicious long tokens found"; fi
echo

echo "---"
echo "PASS: $PASS    FAIL: $FAIL    WARN: $WARN"
[ "$FAIL" -gt 0 ] && exit 1
exit 0
