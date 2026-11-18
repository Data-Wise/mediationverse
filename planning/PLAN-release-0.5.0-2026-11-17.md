# Plan: mediationverse 0.5.0 (self-contained, executable without questions)

Date: 2026-11-17 | Base: `dev` at 48a9293 (0.4.0.9000; 0.4.0 released, tag `v0.4.0`).
Distribution: GitHub + r-universe, not CRAN (gates unchanged; see the hub `docs/ROADMAP.md`).
Branch for the work: `feature/release-0.5.0` (this file is its first commit).

Theme: **a cookbook for the first real analyses.** 0.2.0 to 0.4.0 made the ecosystem inspectable (what is
installed, where from, what changed, what is stale). 0.5.0 shows what to do with it: one short recipe per
sibling, each built on the same fitted object, each running in CI when the sibling is installed. No new exports,
no new dependencies; the release is documentation plus two small honesty fixes.

Assumption (the roadmap left 0.5.0 uncommitted): I chose this theme because the one design exit criterion that
can be tested today says not to build `mediate()` (section 1), and the first recipe (PR #42) is the only
user-facing addition that has been asked for twice. Swap the theme before starting if you disagree; sections 3 to 5
are the only parts that depend on it.

## 1. Evidence (read 2026-11-17)

- `medfit::med()` is the entry point; its signature `med(data, treatment, mediator, outcome, covariates, boot,
  n_boot, seed, ...)` did not change in 0.16.0, 0.17.0 or 0.18.0 NEWS.
- `fit_mediation()` did change across those three releases: `engine = "native"` was renamed `engine = "sem"` in
  0.18.0, and `control` handling moved into a documented object. So **exit criterion 1 of
  `DESIGN-mediate-pipeline-2026-11-17.md` (no breaking change to `med()` / `fit_mediation()` across three
  consecutive releases) is not met.** Decision: still no `mediate()` or pipeline object. Record this in the design
  note (task 6).
- Exit criterion 2 (a sibling agrees on a shared result interface): RMediation's `ci_mediation_data()` and
  probmed's `pmed()` both already accept a `medfit` fit (verified in PR #42), which is a start; medrobust and
  missingmed take their own objects. Not met.
- Exports available for recipes (installed versions 2026-11-17): medrobust 0.4.4 has `medrobust_bounds`,
  `sensitivity_region`, `sensitivity_plot`, `simulate_dm_data`, `power_analysis`; missingmed 0.9.0.9000 (0.10.0
  released) has `set_md_mediation`, `pool`, `infer`, `sensitivity_mnar`, `mbco_d4`; medsim has 63 exports.
  **Verify each call with `args()` and one live run before writing it** (section 3); installed versions lag the
  releases.
- Registry floors (`R/registry.R`): medfit `min_version` 0.5.0 and DESCRIPTION `medfit (>= 0.5.0)` against a latest
  of 0.19.0; RMediation 1.5.0 against CRAN 1.6.1. A floor only matters if a recipe calls an API newer than it.

## 2. Scope

In: three recipe articles, an articles-menu "Recipes" group, a recorded exit-criteria result, floor check, NEWS,
README, `.STATUS`, release. Out, listed once so nobody re-opens them: `mediate()` / `mediation_pipeline()`,
`mv_options()` (no sibling reads a `mediationverse.*` option), CRAN submission, the ADHD dashboard branch, any new
dependency, any new export.

## 3. Tasks (in order; each ends with a commit on `feature/release-0.5.0`)

1. **Recipe: intervals and bootstrap.** `vignettes/recipe-intervals.qmd`. `medfit::med(boot = TRUE, n_boot = 500,
   seed = 1)` versus the distribution-of-the-product interval from `RMediation::ci_mediation_data()`, side by side
   on the data of the first-analysis article. Keep `n_boot` small enough that the vignette builds in under a minute.
2. **Recipe: how much could an unmeasured confounder change this.** `vignettes/recipe-sensitivity.qmd`.
   `medrobust::simulate_dm_data()` or the first-analysis data, then `medrobust_bounds()` and `sensitivity_plot()`.
   Verify the argument names live; if a call needs a sibling version newer than installed, mark the chunk
   `eval = FALSE` and say which version it needs.
3. **Recipe: some outcomes are missing.** `vignettes/recipe-missing-data.qmd`. `missingmed::set_md_mediation()`
   then `pool()` / `infer()` on data with a known missingness mechanism, then `sensitivity_mnar()`. Same rule on
   versions as task 2.
4. **Wire the recipes in.** `_pkgdown.yml` articles menu: group "A First Analysis in Four Calls" and the three
   recipes under a "Recipes" heading; README Getting Started list; link each recipe from the others and from
   `vignettes/getting-started.qmd`'s "next steps".
5. **Floors.** For each recipe, read the sibling's NEWS for the version that introduced each call used. If any is
   newer than the registry floor, raise `min_version` in `R/registry.R` and the DESCRIPTION constraint, update the
   registry tests, and note it in NEWS. If none is, change nothing and say so in the PR body. Do not guess a floor.
6. **Record the design result.** Add a dated "Exit criteria check, 2026-11-17" paragraph to
   `planning/DESIGN-mediate-pipeline-2026-11-17.md` with the section 1 findings (criterion 1 not met: engine
   rename in medfit 0.18.0; criterion 2 not met).
7. **Docs and release prep** (separate PR, as in 0.3.0 and 0.4.0): version `0.5.0`, NEWS heading, `.STATUS`
   (`done:` line), `STATUS.md` date; grep the whole repo for `0.4.0.9000` afterward.

## 4. Verification

- Render each new article with `quarto::quarto_render()` once and check that every chunk output is present and no
  chunk errored; then `Rscript -e 'pkgdown::check_pkgdown()'`.
- **The vignettes must build without the package installed.** R CMD check builds vignettes before installing
  (memory `vignette-build-before-install`; this broke Windows CI on PR #42): use `medfit::` directly, never
  `library(mediationverse)`, and guard every sibling call with `requireNamespace()` inside the chunk.
- A failure case: temporarily rename one sibling call's argument in a scratch copy and confirm the render fails
  (proves the chunk actually runs and is not silently skipped), then discard the scratch copy.
- `scripts/check-local.sh` and `Rscript -e 'devtools::test()'`: expect the same 477 expectations, 0 failures
  (no R code changes unless task 5 raises a floor).
- CI on the PR: all four checks, including Windows, before merging. Then the release flow of 0.3.0 and 0.4.0.

## 5. Risks

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Sibling API in a recipe changed since the installed version | High | verify with `args()` and a live run first; `eval = FALSE` plus a stated version where it cannot run |
| Windows CI breaks on a vignette that evaluates code | High | no `library(mediationverse)`, guards in code (the PR #42 fix) |
| Recipes drift as medfit moves fast | Med | each recipe is built on `med()`, whose signature was stable across 0.16.0 to 0.18.0; the check is the vignette build itself |
| Bootstrap chunk slows the build | Low | `n_boot = 500` and a fixed seed; measure once |
| A docs-only release reads as thin | Low | say so in NEWS; if you prefer, ship it as 0.4.1 instead (no code changes either way) |

## 6. Definition of done

Three recipes published (root site after release, `/dev/` before), exit-criteria result recorded, floors checked and
either raised with tests or left with a stated reason, NEWS/README/`.STATUS` current, tag `v0.5.0` and GitHub
release created from the merge commit on `main`, `dev` bumped to 0.5.0.9000.
