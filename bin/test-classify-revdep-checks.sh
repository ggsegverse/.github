#!/bin/sh
# Tests for classify-revdep-checks.sh. Run: sh bin/test-classify-revdep-checks.sh
set -eu

here=$(dirname "$0")
check="$here/classify-revdep-checks.sh"
pass=0
fail=0

tab=$(printf '\t')

expect() {
  name=$1
  want=$2
  lines=$3

  got=$(printf '%s' "$lines" | sh "$check")

  if [ "$got" = "$want" ]; then
    printf '  ok   %s\n' "$name"
    pass=$((pass + 1))
  else
    printf '  FAIL %s: expected %s, got %s\n' "$name" "$want" "$got"
    fail=$((fail + 1))
  fi
}

expect "no checks at all is absent" absent ""

expect "a queued check is pending" pending \
  "queued$tab"

expect "an in-progress check is pending" pending \
  "in_progress$tab"

expect "a completed success is green" green \
  "completed${tab}success"

expect "a completed failure is failed" failed \
  "completed${tab}failure"

expect "a skipped check is failed, not green" failed \
  "completed${tab}skipped"

expect "a cancelled check is failed" failed \
  "completed${tab}cancelled"

# Success wins over anything else: the obligation is "at least one green",
# so a failed ecosystem run alongside a green dispatched revdep still passes.
expect "one success among failures is green" green \
  "completed${tab}failure
completed${tab}success"

expect "success wins even while another is still running" green \
  "in_progress$tab
completed${tab}success"

# Pending beats failed, because waiting can still turn it green. Reporting
# failed here would fail the gate on a commit whose check had not finished.
expect "a failure with one still running is pending" pending \
  "completed${tab}failure
in_progress$tab"

expect "blank lines are ignored" green \
  "
completed${tab}success
"

echo ""
printf '%s passed, %s failed\n' "$pass" "$fail"
[ "$fail" = "0" ]
