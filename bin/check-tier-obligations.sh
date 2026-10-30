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

# The tier is not the author's to declare. classify-risk.sh computes it from the
# changed paths, which is the whole point: "risk is a property of the diff, not
# of how confident the author feels". Asking for it twice invited exactly the
# disagreement the computed tier then has to overrule, and the check could not
# tell a ticked tier from any other ticked box in the body anyway.

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
