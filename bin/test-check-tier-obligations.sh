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

GOOD='## Risk

- [x] **T1** — new behaviour

## How to revert

git revert abc123 and push.'

NO_TICK='## Risk

- [ ] **T1** — new behaviour

## How to revert

git revert abc123.'

NO_REVERT='## Risk

- [x] **T2** — exported API

## How to revert

<!-- The specific one-step path. See ROLLBACK.md -->'

echo "check-tier-obligations.sh"

expect "T0 skips every obligation"        pass 0 0 ""
expect "T1 complete"                      pass 1 0 "$GOOD"
expect "T1 with no tier ticked"           fail 1 0 "$NO_TICK"
expect "T2 with only the placeholder"     fail 2 1 "$NO_REVERT"
expect "T2 complete and revdep green"     pass 2 1 "$GOOD"
expect "T2 complete but revdep not green" fail 2 0 "$GOOD"
expect "T1 ignores revdep"                pass 1 0 "$GOOD"

UNDERDECLARED='## Risk

- [x] **T0** — docs

## How to revert

Revert the commit.'
expect "under-declared tier warns, does not fail" pass 1 0 "$UNDERDECLARED"

bf=$(mktemp)
printf '%s\n' "$GOOD" > "$bf"
if sh "$check" "$bf" 2 0 "feat/example" 2>&1 | grep -q 'gh workflow run revdep-check.yaml --ref feat/example'; then
    echo "  ok   missing revdep names the command that fixes it"; pass=$((pass + 1))
else
    echo "  FAIL missing revdep gave no actionable command"; fail=$((fail + 1))
fi

printf '%s\n' "$UNDERDECLARED" > "$bf"
if sh "$check" "$bf" 1 0 2>&1 | grep -q '::warning::Declared T0'; then
    echo "  ok   under-declaration is reported as a warning"; pass=$((pass + 1))
else
    echo "  FAIL no warning for under-declaration"; fail=$((fail + 1))
fi
rm -f "$bf"

echo ""
printf '%s passed, %s failed\n' "$pass" "$fail"
[ "$fail" = "0" ]
