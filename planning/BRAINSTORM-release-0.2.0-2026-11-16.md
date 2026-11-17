# BRAINSTORM: mediationverse 0.2.0 release (utility functions)

**Date:** 2026-11-16 | **Mode:** feature / default | **Base:** 0.1.1.9000 (`dev`)
**Decision:** 0.2.0 = three small utilities (`mv_options()` cut, see open question 1), published via GitHub tag/release + r-universe.
No CRAN submission (blocked on probmed, medrobust, medsim; see `.STATUS`).

## Starting point

- Shipped: 0.1.1 (2026-10-08). `dev` is 0.1.1.9000 with an empty NEWS dev section.
- Exported today: `mediationverse_packages()`, `_update()`, `_conflicts()`, `_sitrep()`.
- Test coverage 93.88% (2026-11-16); weakest file `R/zzz.R` at 64.29%.
- Source of the remaining-work list: `planning/BRAINSTORM-tidyverse-functions-2026-06-19.md`
  (items 3, 4, 5, 7 unbuilt; 6, 8-10 deferred).

## Scope (in)

| Function | Effort | Notes |
|---|---|---|
| `mediationverse_citations(style)` | ~2 h | Wraps `utils::citation()` per installed member; `apa`/`bibtex`. Skips not-installed packages with a note. |
| `mediationverse_news(n)` | ~2 h | `utils::news(package =)` per installed member; must degrade cleanly when a package ships no NEWS. |
| `mediationverse_doctor()` | ~3 h | R version, member versions vs. declared minimums, optional deps (OpenMx, lavaan). Reuses `sitrep` internals; should not duplicate its CRAN source map. |
| ~~`mv_options()` / `mv_get_option()`~~ | cut | No member reads `mediationverse.*` options; see open question 1. |

## Scope (out)

- `mediation_pipeline()` / `mediate()`: couples this package to medfit's API; separate design.
- Any CRAN submission or `Remotes:` change (the missingmed/medfit pin conflict still applies).
- `mediationverse_attach_all()`: conflicts with the selective-loading design.

## Open questions / risks

1. **RESOLVED 2026-11-16: cut `mv_options()` from 0.2.0.** Grep of the local medfit,
   rmediation, probmed, medsim, medrobust and missingmed `R/` sources found no reader of any
   `mediationverse.*` option. medfit uses its own `medfit.*` namespace (e.g.
   `medfit.covariate_mean_variance`, plus lavaan two-level defaults), so the function would
   set values nothing consumes. Revisit only if a member adds support. Original concern:
   `mv_options()` only helps if members read the options. The 2026-06 note says the
   values feed `ci()`/`medci()` defaults, but those live in other packages. Either
   (a) ship `mv_options()` as a documented convention and open issues in medfit/RMediation
   to honor `mediationverse.*`, or (b) cut it from 0.2.0. Recommendation: (b) unless a
   member already reads these options. Verify before building.
2. **Network/side effects in `doctor()`**: keep it offline and read-only; any CRAN lookup
   goes behind an opt-in argument, matching how `sitrep()` behaves.
3. **`news()`/`citation()` cost** on machines with many members installed; test with none,
   some, and all installed.

## Release checklist (mirrors the 0.1.1 flow)

1. Feature branches per function off `dev`; each with tests, roxygen docs, `_pkgdown.yml` entry.
2. NEWS entries under the dev heading; bump `DESCRIPTION` to 0.2.0.
3. `scripts/check-local.sh` plus `R CMD check` clean; coverage stays above 80%.
4. Sync `.STATUS`, `STATUS.md`, README function list.
5. `dev` to `main` release PR, tag `v0.2.0`, GitHub release, confirm r-universe build and pkgdown root.
6. Bump `dev` to 0.2.0.9000.

## Test plan

- Unit: each function with all/some/no members installed (mock `requireNamespace`).
- Snapshot tests for printed output (`cli` and plain-text fallback).
- Edge cases: package without NEWS or citation, non-interactive session, `quiet` option.
- Tier: full suite plus `R CMD check` (code change).

## Documentation

Reference pages (roxygen), a short "Utilities" section in `getting-started.qmd`, NEWS entry,
`_pkgdown.yml` reference group. No count or version cascade beyond the bump.

## Next

Decide open question 1, then spec (`--save`) or start with `mediationverse_citations()` as the
lowest-risk first PR.
