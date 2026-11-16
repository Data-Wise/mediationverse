# SPEC: mediationverse 0.2.0 (utility functions)

**Date**: 2026-11-16
**Status**: draft
**Chain**: [BRAINSTORM-tidyverse-functions-2026-06-19.md](BRAINSTORM-tidyverse-functions-2026-06-19.md) → [BRAINSTORM-release-0.2.0-2026-11-16.md](BRAINSTORM-release-0.2.0-2026-11-16.md) → this SPEC

## Problem

0.1.1 shipped 2026-10-08 and `dev` (0.1.1.9000) has no user-visible changes. The CRAN
submission is blocked on probmed, medrobust and medsim (`.STATUS`), so the next release
ships via GitHub and r-universe. The most useful unbuilt items from the June function
brainstorm are three small, offline utilities that do not depend on the blockers.

## Decision

Release **0.2.0** with three new exported functions. Channel: GitHub tag + release and
r-universe (as for 0.1.0 and 0.1.1). No CRAN submission, no `Remotes:` change.

**Cut:** `mv_options()` / `mv_get_option()`. Verified 2026-11-16 (grep of the local `R/`
sources of medfit, rmediation, probmed, medsim, medrobust, missingmed): no member reads any
`mediationverse.*` option; medfit uses its own `medfit.*` namespace. The function would set
values nothing consumes. Revisit only if a member adopts the options.

**Deferred:** `mediation_pipeline()` / `mediate()` (couple this package to medfit's API;
need their own design), `mediationverse_attach_all()` (conflicts with selective loading).

## Functions

All three operate over `mediationverse_packages()` and treat not-installed members as a
reported state, never an error. None touches the network. Output uses `cli` with a
plain-text fallback, matching `sitrep()`.

### `mediationverse_citations(style = c("apa", "bibtex"), include_self = TRUE)`

- One `utils::citation()` per installed member; `apa` prints formatted text, `bibtex` prints
  `toBibtex()` entries.
- Not-installed members are listed in a trailing note, not omitted silently.
- Returns invisibly a named list of `citation` objects (class `mediationverse_citations`
  with a print method).

### `mediationverse_news(n = 5, packages = NULL)`

- Per installed member, the newest `n` entries from `utils::news(package = )`, newest first.
- A member with no NEWS (or unparseable NEWS) shows "no NEWS available" and does not abort.
- Returns invisibly a data frame (`package`, `version`, `text`) with a print method.

### `mediationverse_doctor()`

- Checks: R version vs. `DESCRIPTION` requirement; each member's installed version vs. the
  minimum the ecosystem expects; optional dependencies (OpenMx, lavaan) and the feature each
  gates (e.g. `mbco()` needs OpenMx); known conflicts from `mediationverse_conflicts()`.
- Each check yields pass / warn / fail with a one-line fix hint. Reuse `sitrep` internals
  and its install-source map; do not duplicate that logic.
- Read-only and offline; returns invisibly a `mediationverse_doctor` object so callers can
  test `all_ok`.

## Requirements

1. Each function is exported, roxygen-documented (title, description, params, return,
   example in `\dontrun{}` where it needs optional installs), and listed in `_pkgdown.yml`.
2. No `library()`/`require()`; external calls use `::`; new Suggests/Imports only if
   unavoidable (none expected: `utils` and `cli` are already available).
3. Selective-loading behavior is unchanged (verify with
   `pkgload::load_all("."); search()` per project note).
4. Coverage stays at or above 80% (currently 93.88%); new files target 100%.
5. NEWS entries under the development heading; `DESCRIPTION` bumped to 0.2.0 at release.

## Test plan (tier: code, so full suite plus `R CMD check`)

- Each function with all, some and no members installed (mock `requireNamespace`/
  `packageVersion` as the existing sitrep tests do).
- Member with no NEWS; member with no citation; non-interactive session.
- Snapshot tests for printed output, both `cli` and fallback paths.
- Doctor: simulated old member version, missing OpenMx, missing lavaan.
- Run `scripts/check-local.sh`; the `.git` hidden-file NOTE is a worktree artifact only.

## Documentation

Roxygen reference pages; a short "Utilities" section in `vignettes/getting-started.qmd`;
README function list; NEWS; `.STATUS` and `STATUS.md` sync at release.

## Implementation order

1. `mediationverse_citations()` (lowest risk).
2. `mediationverse_news()`.
3. `mediationverse_doctor()` (largest; depends on sitrep internals).
4. Release PR: version bump, NEWS, docs sync, `dev` to `main`, tag `v0.2.0`, GitHub release,
   confirm r-universe build and the pkgdown root site, then bump `dev` to 0.2.0.9000.

## Out of scope / risks

- Not a CRAN release; do not touch `Remotes:` (probmed pins `medfit@v0.3.0`, conflicting
  with missingmed's `medfit (>= 0.3.1)`).
- `news()`/`citation()` cost with many members installed: acceptable; no caching in 0.2.0.
- Dependency status in `.STATUS` can drift; re-verify before any CRAN step.
