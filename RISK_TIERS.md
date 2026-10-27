# Risk Tiers

Organisation-wide policy for every ggsegverse package. Enforced automatically by the
`pr-risk-tier` reusable workflow, which computes the tier from the paths a pull request
changes and labels it `risk:T0`/`risk:T1`/`risk:T2`.

Risk is a property of the diff, not of how confident the author feels. Classify by what the
change touches, then apply the matching gate.

## T0 — merge on green CI

Documentation, comments, tests only, typo fixes, internal refactors with no behaviour change,
dev-dependency bumps, pkgdown/vignette prose.

**Gate:** CI green. One correctness reviewer locally. No deliberate re-read needed.

## T1 — green CI plus a deliberate read

New exported function, new argument with a safe default, internal logic changes, new tests for
existing behaviour, CI workflow edits that don't remove a check.

**Gate:** CI green, full `pre-merge-review` fan-out, and you read the diff yourself once with
the PR description closed. If you can't say what it does from the diff alone, it needs better
naming or a comment before it merges.

## T2 — green CI, deliberate read, and a soak

Changes to an exported signature, defaults, or return type. S3/S4 methods. Shipped data under
`data/` or anything in `data-raw/` that regenerates it. `DESCRIPTION` dependencies. Release
commits and version bumps. Removing or weakening a CI check. Anything CRAN sees.

**Gate:** everything in T1, plus:

- `revdep-check` / `ecosystem-check` green
- Merged to main and published to r-universe, then **left there** before it goes to CRAN —
  r-universe is the staged rollout; CRAN is the irreversible one
- A written revert path in the PR

## Always T2 regardless of size

`DESCRIPTION`, `NAMESPACE`, `data-raw/`, `data/`, `R/zzz.R`, `.github/workflows/`, `inst/`,
`src/`, and any diff that adds or removes an `@export` tag.

Individual packages add their own via the workflow's `extra-t2-paths` input — for example an
atlas registry, or `inst/atlases/`.

## Solo-maintainer note

With no second human, the T1/T2 "deliberate read" is the only human layer there is. Protect it:
it is worth more than another agent pass. Read the diff cold, not immediately after writing it —
a different day, or at minimum after the agents have reported, so you're reading code rather
than remembering intentions.

## Overriding

Add the `risk-override` label to skip the gate. It is for a genuine emergency — a broken CI
gate blocking every other PR, say — and the reason belongs in the PR description, because the
label is the only record that the gate was bypassed.

## Why this is computed, not declared

The tier comes from the diff. The box you tick in the PR description is only cross-checked
against it: tick lower than the computed tier and the bot warns, but the computed tier governs.
Author confidence is the least reliable available signal about risk, and it is lowest exactly
when it matters — on the change you were sure was trivial.
