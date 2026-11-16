# SPEC: mediationverse 0.2.0 (citations + sitrep checks)

**Date**: 2026-11-16 (revised after grill and adversarial review)
**Status**: draft
**Chain**: [BRAINSTORM-tidyverse-functions-2026-06-19.md](BRAINSTORM-tidyverse-functions-2026-06-19.md) → [BRAINSTORM-release-0.2.0-2026-11-16.md](BRAINSTORM-release-0.2.0-2026-11-16.md) → [GRILL-release-0.2.0-2026-11-16.md](GRILL-release-0.2.0-2026-11-16.md) → [REVIEW-release-0.2.0-2026-11-16.md](REVIEW-release-0.2.0-2026-11-16.md) → this SPEC

## Problem

0.1.1 shipped 2026-10-08; `dev` (0.1.1.9000) has no user-visible changes. CRAN submission is
blocked on probmed, medrobust and medsim (`.STATUS`), so the next release ships via GitHub and
r-universe. The member list is hardcoded in four files and there are no per-member minimum
versions, which blocks any dependency diagnostics.

## Decision

Release **0.2.0**: an internal registry refactor, one new exported function
(`mediationverse_citations()`), and an opt-in `checks` argument on `mediationverse_sitrep()`.
Channel: GitHub tag + release and r-universe. No CRAN submission, no `Remotes:` change.

**Cut:** `mv_options()` (no member reads `mediationverse.*` options; verified 2026-11-16).
**Folded:** `mediationverse_doctor()` into `sitrep(checks = TRUE)`.
**Deferred:** `mediationverse_news()` (per-bullet `utils::news()` rows make `n` ambiguous;
needs a versions-based design), `mediation_pipeline()`/`mediate()`, `mediationverse_attach_all()`.

## Work items (in order)

### 1. Internal registry (behavior-neutral refactor, own PR)

`R/registry.R` holds one table: member name, GitHub repo, CRAN status, minimum version,
optional dependencies. Migrate `packages.R`, `conflicts.R`, `sitrep.R`, `update.R` to read it.
Existing tests must pass unchanged (`test-sitrep.R` pins 6 members). Seed minimums from each
sibling's declared constraints; the medfit minimum is set by the strictest dependent
(missingmed `>= 0.3.1`); verify against sibling DESCRIPTIONs while building.

### 2. `mediationverse_sitrep(checks = FALSE)`

- Default output unchanged, plus a one-line hint pointing at `checks = TRUE`.
- `checks = TRUE` appends: member installed version vs registry minimum; optional
  dependencies per the table below; conflicts across all members.
- Conflicts via an internal quiet finder called with `only_loaded = FALSE` (the exported
  function prints and defaults to loaded packages only, so it is not reused directly).
- Read-only and offline. Each check yields pass/warn/fail with a one-line fix hint. Returns
  invisibly the existing report object with an added `checks` data frame
  (`check`, `status`, `message`, `fix`).

| Dependency | Owner | Gated feature | Severity if missing |
|---|---|---|---|
| OpenMx | RMediation (Suggests) | `mbco()` | warn |
| lavaan | RMediation (Imports), medfit (Suggests) | lavaan extraction in medfit | warn if absent (hard dependency of RMediation, so rare) |

### 3. `mediationverse_citations(style = c("text", "bibtex"), include_self = FALSE)`

- One entry per installed member via an internal `pkg_citation()` helper wrapping
  `utils::citation()` in `tryCatch`.
- `text` uses `format(ct, style = "text")`; `bibtex` uses `toBibtex()`. No APA.
- Empty citation (RMediation returns length 0) or an error: print "no citation available"
  for that member; never abort. Not-installed members are listed in a trailing note.
- Auto-generated source-install citations embed a commit SHA: note this in the output.
- Returns invisibly a named list of citations (class `mediationverse_citations`, print method).
- `include_self = FALSE` by default: the installed meta-package copy may be stale.

## Requirements

1. Roxygen docs (title, description, params, return, example); roxygen2 pinned at 8.1.0, so
   regenerate with that version and commit `NAMESPACE` and `man/`.
2. `_pkgdown.yml` reference index gets an entry for the new function (else
   `pkgdown::check_pkgdown()` fails); README function list updated (currently lists 4).
3. No `library()`/`require()`; `::` for external calls; no new Imports/Suggests.
4. Selective loading unchanged (`pkgload::load_all("."); search()`).
5. Coverage at or above 80% (currently 93.88%); new files target 100%.
6. NEWS entries under the development heading; `DESCRIPTION` to 0.2.0 at release.

## Test plan (tier: code, full suite + `R CMD check`)

- Style match: **no snapshot tests**. Add small internal helpers (`pkg_citation()`,
  `pkg_version()`, `pkg_installed()`) that tests mock (`.package = "utils"` for `utils::`
  calls); assert on content, as existing tests do.
- Registry: all four migrated functions return the same results as before; one test that the
  member list is identical everywhere.
- Citations: all/some/none installed; empty citation; erroring citation; both styles;
  `include_self`.
- Sitrep checks: simulated old member version, missing OpenMx, `checks = FALSE` output
  unchanged.
- Run `scripts/check-local.sh` (the `.git` hidden-file NOTE is a worktree artifact).
- `getting-started.qmd` is not built by `check-local.sh`; confirm any added text in CI.

## Release checklist

1. Registry PR, then citations PR, then sitrep-checks PR (each off `dev`).
2. Version bump, NEWS, README/`.STATUS`/`STATUS.md` sync.
3. `dev` → `main` release PR, tag `v0.2.0`, GitHub release, confirm r-universe build and the
   pkgdown root site, then bump `dev` to 0.2.0.9000.

## Out of scope / risks

- Not a CRAN release; do not touch `Remotes:` (probmed pins `medfit@v0.3.0`, conflicting with
  missingmed `medfit (>= 0.3.1)`).
- Registry minimums are only as accurate as the sibling DESCRIPTIONs at build time; re-verify
  before release.
- Value of citations is aggregation over `citation("pkg")`; the June claim that analysts
  "consistently miss citing all packages" is unverified.
