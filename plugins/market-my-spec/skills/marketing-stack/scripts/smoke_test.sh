#!/usr/bin/env bash
#
# Smoke test for the marketing-stack skill.
# Verifies that the skill's promises match its on-disk state:
# - Every recipe listed in SKILL.md has a RECIPE.md file
# - Every RECIPE.md has the required frontmatter fields
# - Every RECIPE.md has the required body sections
# - All step files referenced by SKILL.md exist
#
# Run from the plugin root, the skill root, or with SKILL_DIR set.
# Exits 0 if clean, 1 if any check fails.

set -u

# Resolve the skill directory.
if [ -n "${SKILL_DIR:-}" ]; then
  SKILL="$SKILL_DIR"
elif [ -f "./SKILL.md" ] && [ -d "./recipes" ]; then
  SKILL="."
elif [ -d "./plugins/market-my-spec/skills/marketing-stack" ]; then
  SKILL="./plugins/market-my-spec/skills/marketing-stack"
elif [ -d "./skills/marketing-stack" ]; then
  SKILL="./skills/marketing-stack"
else
  echo "ERROR: can't find marketing-stack skill dir. Set SKILL_DIR or run from plugin root." >&2
  exit 1
fi

cd "$SKILL" || exit 1

PASS=0
FAIL=0
WARN=0

ok() { echo "  ✓ $1"; PASS=$((PASS+1)); }
bad() { echo "  ✗ $1"; FAIL=$((FAIL+1)); }
warn() { echo "  ! $1"; WARN=$((WARN+1)); }

echo "# marketing-stack smoke test"
echo "Skill root: $(pwd)"
echo

# ---------------------------------------------------------------------------
# Check 1: Required top-level files exist.
# ---------------------------------------------------------------------------
echo "## Top-level files"
for f in SKILL.md steps/inventory.md steps/install_recipe.md steps/install_for_channel.md steps/fix_recipe.md steps/blueprint.md; do
  if [ -f "$f" ]; then
    ok "$f"
  else
    bad "$f missing"
  fi
done
echo

# ---------------------------------------------------------------------------
# Check 2: Every recipe directory is mentioned in SKILL.md (docs match disk).
# ---------------------------------------------------------------------------
echo "## Every recipe directory is documented in SKILL.md"

if [ -d recipes ]; then
  for d in recipes/*/; do
    name=$(basename "$d")
    # Look for the backticked recipe name in SKILL.md
    if grep -qF "\`$name\`" SKILL.md; then
      ok "$name documented in SKILL.md"
    else
      bad "$name has a recipe directory but isn't mentioned in SKILL.md"
    fi
  done
fi
echo

# ---------------------------------------------------------------------------
# Check 3: Every recipe directory has a RECIPE.md.
# ---------------------------------------------------------------------------
echo "## Recipe directories have RECIPE.md"
if [ -d recipes ]; then
  for d in recipes/*/; do
    name=$(basename "$d")
    if [ -f "${d}RECIPE.md" ]; then
      ok "recipes/$name/RECIPE.md"
    else
      bad "recipes/$name/ has no RECIPE.md"
    fi
  done
else
  bad "recipes/ directory missing"
fi
echo

# ---------------------------------------------------------------------------
# Check 4: Every RECIPE.md has required frontmatter fields.
# ---------------------------------------------------------------------------
echo "## Recipe frontmatter"

REQUIRED_FIELDS="name tier channel loop_fit primary_mcp_status detection validation"

for f in recipes/*/RECIPE.md; do
  name=$(basename "$(dirname "$f")")
  # Grab frontmatter: lines between first and second '---'
  frontmatter=$(awk 'BEGIN{n=0} /^---$/{n++; next} n==1{print}' "$f")
  missing=""
  for field in $REQUIRED_FIELDS; do
    if ! echo "$frontmatter" | grep -qE "^${field}:"; then
      missing="$missing $field"
    fi
  done
  if [ -z "$missing" ]; then
    ok "$name frontmatter complete"
  else
    bad "$name missing:$missing"
  fi
done
echo

# ---------------------------------------------------------------------------
# Check 5: Every RECIPE.md has required body sections.
# ---------------------------------------------------------------------------
echo "## Recipe body sections"

REQUIRED_SECTIONS="## What it is|## Unlocks|## Prerequisites|## Install steps|## .env requirements|## Validation|## Conventions to seed|## Gotchas|## Links"

for f in recipes/*/RECIPE.md; do
  name=$(basename "$(dirname "$f")")
  missing=""
  IFS='|' read -ra SECTIONS <<< "$REQUIRED_SECTIONS"
  for s in "${SECTIONS[@]}"; do
    if ! grep -qF "$s" "$f"; then
      missing="$missing;${s}"
    fi
  done
  if [ -z "$missing" ]; then
    ok "$name body sections present"
  else
    warn "$name missing sections:$missing"
  fi
done
echo

# ---------------------------------------------------------------------------
# Check 6: .env-only rule — no secrets hard-coded in RECIPE.md templates.
# ---------------------------------------------------------------------------
echo "## .env-only hygiene (no plausible secret patterns in recipes)"

# Heuristic: look for long alphanumeric tokens that look like real API keys.
# Skip placeholder patterns like "re_..." or "pat-na1-...".
found_suspected=false
for f in recipes/*/RECIPE.md; do
  name=$(basename "$(dirname "$f")")
  # Flag any string matching /[A-Za-z0-9]{30,}/ that's not in a code block's PLACEHOLDER style.
  if grep -vE '^(#|```|  |-)' "$f" | grep -qE '[A-Za-z0-9_-]{40,}' ; then
    # Further filter — only flag if it looks secret-like (mixed case + digits, not just a hash).
    matches=$(grep -vE '^(#|```|  |-)' "$f" | grep -oE '[A-Za-z0-9_-]{40,}' | grep -E '[0-9]' | grep -E '[a-z]' | grep -E '[A-Z]' || true)
    if [ -n "$matches" ]; then
      warn "$name has suspicious long token(s) — verify they're placeholders: $(echo "$matches" | head -1)"
      found_suspected=true
    fi
  fi
done
if [ "$found_suspected" = false ]; then
  ok "no suspicious long tokens found in recipe files"
fi
echo

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo "---"
echo "PASS: $PASS    FAIL: $FAIL    WARN: $WARN"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
