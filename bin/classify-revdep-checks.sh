#!/bin/sh
# Decide what a set of revdep/ecosystem check-runs says about a T2 obligation.
#
# Usage: classify-revdep-checks.sh < lines
#
# Reads one check-run per line as "<status>\t<conclusion>", already filtered to
# the qualifying names, and prints exactly one of:
#
#   green    at least one qualifying run succeeded
#   pending  at least one qualifying run has not finished yet
#   failed   every qualifying run finished, none succeeded
#   absent   no qualifying run exists
#
# The distinction matters because the caller must act differently on each:
# pending is worth waiting for, absent means nobody has dispatched anything
# yet, and failed is a real answer that waiting will never improve.

set -eu

green=0
pending=0
seen=0

# `read` returns non-zero on a final line with no trailing newline, which
# would silently drop it, so the buffer is checked before giving up.
while IFS="$(printf '\t')" read -r status conclusion ||
    [ -n "$status$conclusion" ]; do
  [ -n "$status$conclusion" ] || continue
  seen=$((seen + 1))
  case "$conclusion" in
  success) green=1 ;;
  esac
  if [ "$status" != "completed" ]; then
    pending=1
  fi
done

if [ "$green" = "1" ]; then
  echo green
elif [ "$pending" = "1" ]; then
  echo pending
elif [ "$seen" = "0" ]; then
  echo absent
else
  echo failed
fi
