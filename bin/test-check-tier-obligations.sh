#!/bin/sh
# Tests for check-tier-obligations.sh. Run: sh bin/test-check-tier-obligations.sh
set -eu

here=$(dirname "$0")
check="$here/check-tier-obligations.sh"
pass=0
fail=0

expect() {
    name=$1
    want=$2
    tier=$3
    revdep=$4
    body=$5

    bf=$(mktemp)
    printf '%s\n' "$body" > "$bf"
    if out=$(sh "$check" "$bf" "$tier" "$revdep" "feat/example" 2>&1); then got=pass; else got=fail; fi
    rm -f "$bf"

    if [ "$got" = "$want" ]; then
        printf '  ok   %s\n' "$name"
        pass=$((pass + 1))
    else
        printf '  FAIL %s: expected %s, got %s\n    %s\n' "$name" "$want" "$got" "$out"
        fail=$((fail + 1))
    fi
}

GOOD='## Testing

Covered by CI.

## How to revert

git revert abc123 and push.'

NO_REVERT='## Testing

Covered by CI.

## How to revert

<!-- The specific one-step path. See ROLLBACK.md -->'

# The tier is computed, never declared, so a body that says nothing about risk
# is correct and must pass. This is the case the old tier-box requirement got
# wrong, and it only ever passed because the grep matched any ticked box at all,
# including the Checklist.
NO_RISK_SECTION='## Description

Adds a thing.

## How to revert

git revert abc123.'

echo "check-tier-obligations.sh"

expect "T0 skips every obligation"        pass 0 0 ""
expect "T1 complete"                      pass 1 0 "$GOOD"
expect "T1 with no risk section"          pass 1 0 "$NO_RISK_SECTION"
expect "T2 with only the placeholder"     fail 2 1 "$NO_REVERT"
expect "T2 complete and revdep green"     pass 2 1 "$GOOD"
expect "T2 complete but revdep not green" fail 2 0 "$GOOD"
expect "T1 ignores revdep"                pass 1 0 "$GOOD"

# A ticked box that is not a tier must not be mistaken for one, in either
# direction: it neither satisfies nor fails anything now.
TICKED_CHECKLIST='## How to revert

Revert the commit.

## Checklist

- [x] I have read the contributing guidelines'
expect "an unrelated ticked box is ignored"       pass 1 0 "$TICKED_CHECKLIST"

bf=$(mktemp)
printf '%s\n' "$GOOD" > "$bf"
if sh "$check" "$bf" 2 0 "feat/example" 2>&1 | grep -q 'gh workflow run revdep-check.yaml --ref feat/example'; then
    echo "  ok   missing revdep names the command that fixes it"; pass=$((pass + 1))
else
    echo "  FAIL missing revdep gave no actionable command"; fail=$((fail + 1))
fi

# There is no declared tier to disagree with the computed one any more, so the
# check must never emit the old warning, whatever the body says.
printf '%s\n' "$TICKED_CHECKLIST" > "$bf"
if sh "$check" "$bf" 1 0 2>&1 | grep -q '::warning::Declared'; then
    echo "  FAIL still reports a declared tier"; fail=$((fail + 1))
else
    echo "  ok   no tier is read from the body"; pass=$((pass + 1))
fi
rm -f "$bf"

echo ""
printf '%s passed, %s failed\n' "$pass" "$fail"
[ "$fail" = "0" ]
