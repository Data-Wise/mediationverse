# Plan: mediationverse 0.3.0

Date: 2026-11-17 | Base: `dev` at 477908a (0.2.0.9000, includes sitrep provenance, PR #33)
Source of the backlog: `BRAINSTORM-tidyverse-functions-2026-06-19.md` (items 3, 4, 6, 8, 9, 10 unbuilt),
the 0.2.0 SPEC "Deferred" list, and `.STATUS`.

## Theme

Session ergonomics and a docs refresh, distributed through GitHub and r-universe (not CRAN: still
blocked on probmed, medrobust, medsim and a medfit >= 0.5.0 on CRAN).

## Evidence that shaped the scope

- No sibling package reads a `mediationverse.*` option (grep of `R/` in medfit, probmed, RMediation,
  medrobust, medsim, missingmed: 0 files). `mv_options()` (brainstorm item 3) would set values nothing
  consumes, so it is dropped until a sibling adopts the option names.
- The 0.2.0 SPEC deferred `mediationverse_news()` because `utils::news()` returns one row per bullet,
  so `n` is ambiguous. It needs a versions-based design (last `n` *versions* per package).
- `mediation_pipeline()` / `mediate()` (items 6, 8) need stable cross-package APIs (medfit is at 0.18
  vs the registry floor 0.5.0). Too large and too coupled for a minor release.

## In scope

1. **`mediationverse_news(n = 3)`** (M): last `n` released versions per installed member, grouped by
   version header, not by bullet. Mockable `pkg_news()` helper; packages with no NEWS reported, not fatal.
2. **`mediationverse_attach_all()`** (S): attach every installed member; uses `mv_core_packages()`,
   skips absent or broken members (`pkg_state()`), prints what attached. `library(mediationverse)`
   selective loading stays unchanged.
3. **Startup-quiet option** (S): honor a single documented `mediationverse.quiet` option in
   `.onAttach`. The only option this release adds, because it is the only one the meta-package itself reads.
4. **Docs refresh** (M): `vignettes/roadmap.Rmd`, `STATUS.md`, README "From CRAN (future)" block and
   `.STATUS` still describe the pre-0.2.0 state. Run the doc-currency check first and edit only real drift.
5. **Release hygiene** (S): NEWS, roxygen (pinned 8.1.0), `scripts/check-local.sh`, coverage >= 80%,
   pkgdown reference index lists the two new exports.

## Out of scope (next)

- `mv_options()` until a sibling reads the option names (then spec the names with that sibling first).
- `mediation_pipeline()` and `mediate()`: 0.4.0 candidate; needs a design pass against medfit's current API.
- ADHD status-dashboard branch (`feature/adhd-friendly-status-dashboard`): atlas/README work, kept as is.
- CRAN submission: tracked in `.STATUS`; unchanged.

## Order and checkpoints

| # | Task | Size | Depends on |
|---|------|------|-----------|
| 1 | `mediationverse_news()` + tests | M | none |
| 2 | `mediationverse_attach_all()` + tests | S | none |
| 3 | `mediationverse.quiet` option + test | S | none |
| 4 | Docs refresh | M | 1-3 (documents them) |
| 5 | NEWS, roxygen, check-local, coverage, pkgdown index | S | 1-4 |

Checkpoint after 1-3: `devtools::test()` all green, live run of each new function on this machine
(positive control: RMediation, a GitHub install, still appears in `news` and `attach_all`).
Checkpoint after 5: `check-local.sh` PASS, then PR to `dev` (squash), then the usual release flow
(dev to main merge commit, tag `v0.3.0`, release, r-universe check, bump dev to 0.3.0.9000).

## Risks

| Risk | Impact | Mitigation |
|------|--------|-----------|
| NEWS formats differ per package (`NEWS.md` vs `NEWS.Rd`) | Med | Go through `utils::news(package=)`, group by `Version`; test a package with no NEWS |
| `attach_all()` hits a conflict or load failure mid-way | Med | Per-package `tryCatch` via `pkg_state()`; report, never abort |
| Scope creep into pipeline/mediate | High | Listed as out of scope here; revisit only after a separate spec |
