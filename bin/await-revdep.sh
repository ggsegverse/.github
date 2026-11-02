#!/bin/sh
# Wait for a qualifying revdep or ecosystem check-run on a commit, and report
# whether one succeeded.
#
# Usage: await-revdep.sh <repo> <sha>
#
# Prints "1" if one succeeded, "0" otherwise. Always exits 0: the decision is
# the output, and the gate decides what to do with it.
#
# Why wait rather than look once. The gate finishes in seconds while the
# ecosystem check takes minutes, so a single look always reported "none found"
# and every T2 push failed the gate on timing alone. Waiting lets the check
# that already runs on every pull request be the thing that satisfies the
# obligation, without weakening it: a failed check still fails, and a commit
# with nothing qualifying still fails.
#
# revdep-check stays workflow_dispatch-only on purpose -- it is expensive --
# so "absent" is a legitimate end state, reached once the grace period shows
# nothing is coming.

set -eu

repo=${1:?usage: await-revdep.sh <repo> <sha>}
sha=${2:?}

timeout=${AWAIT_REVDEP_TIMEOUT:-1800}
interval=${AWAIT_REVDEP_INTERVAL:-15}
grace=${AWAIT_REVDEP_GRACE:-120}

here=$(dirname "$0")
waited=0
checks=$(mktemp)
trap 'rm -f "$checks"' EXIT

while :; do
  gh api --paginate "repos/$repo/commits/$sha/check-runs?per_page=100" \
    -q '.check_runs[] | select(.name | test("revdep|ecosystem"; "i"))
             | [.status, .conclusion // ""] | @tsv' >"$checks" 2>/dev/null ||
    : >"$checks"

  verdict=$(sh "$here/classify-revdep-checks.sh" <"$checks")

  case "$verdict" in
  green)
    echo "::notice::A qualifying revdep/ecosystem check succeeded after ${waited}s." >&2
    echo 1
    exit 0
    ;;
  failed)
    echo "::error::A qualifying revdep/ecosystem check ran and did not succeed." >&2
    echo 0
    exit 0
    ;;
  absent)
    if [ "$waited" -ge "$grace" ]; then
      echo "::notice::No revdep or ecosystem check registered within ${grace}s." >&2
      echo 0
      exit 0
    fi
    ;;
  esac

  if [ "$waited" -ge "$timeout" ]; then
    echo "::error::Timed out after ${waited}s waiting for a revdep/ecosystem check." >&2
    echo 0
    exit 0
  fi

  sleep "$interval"
  waited=$((waited + interval))
done
