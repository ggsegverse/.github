## Description

Brief description of what this PR does.

## Related Issues

Fixes #(issue number)

## Testing

<!-- Only what CI does not already prove: manual checks, visual inspection of a rendered
     atlas, snapshot acceptance rationale. Do not restate "tests pass" or "R CMD check
     clean" — CI shows that. If CI covers it entirely, write "Covered by CI." -->

## Risk

<!-- Tick one. The bot computes the tier from changed paths and will warn if you tick
     lower than it computes. See
     https://github.com/ggsegverse/.github/blob/main/RISK_TIERS.md -->

- [ ] **T0** — docs, tests, generated `man/`, no behaviour change
- [ ] **T1** — new or changed behaviour, no existing contract touched
- [ ] **T2** — exported API, shipped data, dependencies, `inst/`, CI gates, or a release

Reverse dependencies affected: <!-- none / list -->

## How to revert

<!-- The specific one-step path. Required for T1 and T2 — the gate fails if this is
     left as a placeholder. See
     https://github.com/ggsegverse/.github/blob/main/ROLLBACK.md -->

## Checklist

- [ ] I have read the [contributing guidelines](CONTRIBUTING.md)
- [ ] I have run `devtools::check()` with no errors
- [ ] I have added tests for my changes (if applicable)
- [ ] I have updated documentation (if applicable)
- [ ] My code follows the tidyverse style guide
