#!/bin/sh
# Check that a pull request meets the obligations its risk tier carries.
#
# Usage: check-tier-obligations.sh <body-file> <tier> <revdep-green:0|1> [head-ref]
#
# Exits 0 when satisfied, 1 when not. Warnings do not fail the check; missing
# declarations do. T0 carries no obligations.

set -eu

body=${1:?usage: check-tier-obligations.sh <body-file> <tier> <revdep-green>}
tier=${2:?}
revdep_green=${3:-0}
head_ref=${4:-}

if [ "$tier" = "0" ]; then
    echo "T0: no obligations."
    exit 0
fi

fail=0

# A ticked box in the Risk section. Unchecked or absent means the author has not
# classified the change at all, which is the thing the tier system exists to stop.
if ! grep -qE '^[[:space:]]*-[[:space:]]*\[[xX]\]' "$body"; then
    echo "::error::No risk tier ticked in the PR description. Tick the T$tier box."
    fail=1
else
    declared=$(grep -E '^[[:space:]]*-[[:space:]]*\[[xX]\]' "$body" |
        grep -oE 'T[0-2]' | head -1 | tr -d 'T')
    if [ -n "${declared:-}" ] && [ "$declared" -lt "$tier" ]; then
        echo "::warning::Declared T$declared but the diff computes to T$tier. The computed tier governs."
    fi
fi

# How to revert, for anything that can reach a user. Comments in the template
# are stripped, so leaving the placeholder untouched counts as empty.
revert=$(awk '/^#+[[:space:]]*How to revert/{flag=1;next} /^#+[[:space:]]/{flag=0} flag' "$body" |
    sed -e 's/<!--[^>]*-->//g' -e 's/<!--.*//' -e 's/.*-->//' |
    tr -d '[:space:]')
if [ -z "$revert" ]; then
    echo "::error::'How to revert' is empty. State the specific path (see ROLLBACK.md)."
    fail=1
fi

if [ "$tier" = "2" ] && [ "$revdep_green" != "1" ]; then
    # revdep-check is workflow_dispatch-only by design: it is expensive, so it
    # runs when asked rather than on every push. The gate therefore has to tell
    # you to ask, not merely that something is missing.
    echo "::error::T2 requires a green revdep-check or ecosystem-check on this commit. None found yet."
    if [ -n "$head_ref" ]; then
        echo "::notice::Dispatch it on this branch, then re-run this check:  gh workflow run revdep-check.yaml --ref $head_ref"
    else
        echo "::notice::Dispatch revdep-check.yaml on this branch, then re-run this check."
    fi
    fail=1
fi

[ "$fail" = "0" ] || exit 1
echo "T$tier obligations satisfied."
