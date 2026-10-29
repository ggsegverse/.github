#!/bin/sh
# Tests for classify-risk.sh. Run: sh bin/test-classify-risk.sh
set -eu

here=$(dirname "$0")
classify="$here/classify-risk.sh"
pass=0
fail=0

expect_tier() {
    name=$1
    want=$2
    paths=$3
    patch=${4:-}
    extra=${5:-}

    pf=$(mktemp)
    printf '%s\n' "$paths" > "$pf"
    if [ -n "$patch" ]; then
        gf=$(mktemp)
        printf '%s\n' "$patch" > "$gf"
    else
        gf=""
    fi

    got=$(EXTRA_T2="$extra" sh "$classify" "$pf" "$gf" | sed -n 's/^tier=//p')
    rm -f "$pf" "$gf"

    if [ "$got" = "$want" ]; then
        printf '  ok   %s (T%s)\n' "$name" "$got"
        pass=$((pass + 1))
    else
        printf '  FAIL %s: expected T%s, got T%s\n' "$name" "$want" "$got"
        fail=$((fail + 1))
    fi
}

echo "classify-risk.sh"

expect_tier "docs only"              0 "README.md
man/plot.Rd"
expect_tier "tests only"             0 "tests/testthat/test-atlas.R"
expect_tier "generated man + news"   0 "man/ggseg.Rd
NEWS.md"

expect_tier "internal R change"      1 "R/utils.R"
expect_tier "vignette"               1 "vignettes/intro.Rmd"
expect_tier "unclassified path"      1 "Makefile"

expect_tier "DESCRIPTION"            2 "DESCRIPTION"
expect_tier "NAMESPACE"              2 "NAMESPACE"
expect_tier "zzz.R"                  2 "R/zzz.R"
expect_tier "shipped data"           2 "data/dk.rda"
expect_tier "data-raw"               2 "data-raw/build-atlas.R"
expect_tier "workflow"               2 ".github/workflows/R-CMD-check.yaml"
expect_tier "inst"                   2 "inst/atlases/dk.json"
expect_tier "src"                    2 "src/reproject.cpp"

expect_tier "tier is the max"        2 "README.md
R/utils.R
DESCRIPTION"
expect_tier "T0 and T1 mix"          1 "README.md
R/utils.R"

expect_tier "added @export"          2 "R/utils.R" "+#' @export
+new_fun <- function() NULL"
expect_tier "removed @export"        2 "R/utils.R" "-#' @export"
expect_tier "@export in context only" 1 "R/utils.R" " #' @export
+  x <- 1"
expect_tier "diff header not @export" 1 "R/utils.R" "+++ b/R/utils.R
--- a/R/utils.R"

expect_tier "extra glob forces T2"   2 "R/registry.R" "" "R/registry.R"
expect_tier "extra glob wildcard"    2 "foo/bar/baz.R" "" "foo/**"
expect_tier "extra glob no match"    1 "R/utils.R" "" "R/registry.R"

echo ""
echo "reasons output"
pf=$(mktemp)
printf 'README.md\n' > "$pf"
if EXTRA_T2="" sh "$classify" "$pf" | grep -q 'only generated, documentation, or test paths'; then
    echo "  ok   clean diff explains itself"; pass=$((pass + 1))
else
    echo "  FAIL clean diff produced no explanation"; fail=$((fail + 1))
fi

printf 'R/a.R\nR/b.R\nR/c.R\nR/d.R\nR/e.R\n' > "$pf"
out=$(EXTRA_T2="" sh "$classify" "$pf")
if printf '%s' "$out" | grep -q 'and 2 further path'; then
    echo "  ok   T1 list is capped at 3 with a remainder count"; pass=$((pass + 1))
else
    echo "  FAIL T1 list not capped: $out"; fail=$((fail + 1))
fi
rm -f "$pf"

echo ""
printf '%s passed, %s failed\n' "$pass" "$fail"
[ "$fail" = "0" ]
