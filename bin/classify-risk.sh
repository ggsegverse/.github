#!/bin/sh
# Classify a pull request into a risk tier from the paths it changes.
#
# Risk is a property of the diff, not of how confident the author feels, so the
# tier is computed here and the tier declared in the PR description is only
# cross-checked against it.
#
# Usage: classify-risk.sh <paths-file> [patch-file]
#   EXTRA_T2  optional newline-separated extra path globs forcing T2
#
# Prints "tier=N" then "reasons<<" block lines on stdout.

set -eu

paths_file=${1:?usage: classify-risk.sh <paths-file> [patch-file]}
patch_file=${2:-}

tier=0
reasons=""
t1_notes=0
t1_omitted=0

note() {
    reasons="${reasons}- \`$1\` → **T$2** ($3)
"
}

# T2 paths are few by nature and all worth naming. T1 paths can be many, and a
# comment listing twenty R files teaches nothing, so cap the list.
note_t1() {
    if [ "$t1_notes" -lt 3 ]; then
        note "$1" 1 "$2"
        t1_notes=$((t1_notes + 1))
    else
        t1_omitted=$((t1_omitted + 1))
    fi
}

bump() {
    [ "$tier" -ge "$1" ] || tier=$1
}

while IFS= read -r f; do
    [ -n "$f" ] || continue
    case "$f" in
        DESCRIPTION | NAMESPACE | R/zzz.R)
            bump 2; note "$f" 2 "package contract" ;;
        data-raw/* | data/*)
            bump 2; note "$f" 2 "shipped data" ;;
        .github/workflows/*)
            bump 2; note "$f" 2 "a broken gate is worse than a broken function" ;;
        inst/* | src/* | configure | configure.ac | cleanup)
            bump 2; note "$f" 2 "installed or compiled artefact" ;;
        man/* | tests/* | *.md | pkgdown/* | .github/ISSUE_TEMPLATE/* | .Rbuildignore | .gitignore | LICENSE*)
            : ;;
        R/* | vignettes/* | _pkgdown.yml | *.Rmd)
            [ "$tier" -ge 2 ] || note_t1 "$f" "behaviour change"
            bump 1 ;;
        *)
            [ "$tier" -ge 2 ] || note_t1 "$f" "unclassified path"
            bump 1 ;;
    esac
done < "$paths_file"

if [ -n "${EXTRA_T2:-}" ]; then
    globs=$(mktemp)
    printf '%s\n' "$EXTRA_T2" > "$globs"
    while IFS= read -r glob; do
        [ -n "$glob" ] || continue
        while IFS= read -r f; do
            [ -n "$f" ] || continue
            # shellcheck disable=SC2254
            case "$f" in
                $glob) bump 2; note "$f" 2 "package-specific high-risk path" ;;
            esac
        done < "$paths_file"
    done < "$globs"
    rm -f "$globs"
fi

# An added or removed @export tag is a contract change however small the diff.
if [ -n "$patch_file" ] && [ -f "$patch_file" ] &&
    grep -qE '^[+-][^+-].*@export' "$patch_file"; then
    bump 2
    reasons="${reasons}- \`@export\` tag added or removed → **T2** (exported surface changed)
"
fi

if [ "$t1_omitted" -gt 0 ]; then
    reasons="${reasons}- …and $t1_omitted further path(s) at the same tier
"
fi

[ -n "$reasons" ] ||
    reasons="- only generated, documentation, or test paths changed
"

printf 'tier=%s\n' "$tier"
printf 'reasons<<CLASSIFY_EOF\n%sCLASSIFY_EOF\n' "$reasons"
