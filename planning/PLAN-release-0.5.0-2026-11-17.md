# Plan: mediationverse 0.5.0 (self-contained, executable without questions)

Date: 2026-11-17 | Base: `dev` at 48a9293 (0.4.0.9000; 0.4.0 released, tag `v0.4.0`).
Distribution: GitHub + r-universe, not CRAN (gates unchanged; see the hub `docs/ROADMAP.md`).
Branch for the work: `feature/release-0.5.0` (this file is its first commit).

Theme: **do the members still work together?** 0.2.0 to 0.4.0 made the ecosystem inspectable: what is installed,
where from, what changed, what is stale. None of it says whether the installed versions actually cooperate.
`sitrep()` can report medfit 0.19, RMediation 1.6.1 and probmed 0.4.1 as "fine" while a medfit change has broken the
hand-off to one of them. 0.5.0 adds **contract checks**: a tiny, deterministic analysis run through the real
packages that fails loudly when a member no longer accepts a shared `medfit` fit.

History of this plan: first drafted as a cookbook of recipe articles; changed to contract checks on 2026-11-17
at the user's request (they chose contract checks over building `mediate()` and over docs polish).

## 1. Evidence (read 2026-11-17)

- A `medfit::med()` fit is accepted directly by `RMediation::ci_mediation_data()` (returns `$CI`, `$Estimate`,
  `$SE`) and by `probmed::pmed()` (returns an S7 `PmedResult` with `estimate`, `ci_lower`, `ci_upper`,
  `converged`). Verified live on a 120-row simulated set: all three calls took 2.8 s together.
- `medfit::med()`'s signature `med(data, treatment, mediator, outcome, covariates, boot, n_boot, seed, ...)` did not
  change in medfit 0.16.0 to 0.18.0, but `fit_mediation()` renamed `engine = "native"` to `"sem"` in 0.18.0. So
  `DESIGN-mediate-pipeline-2026-11-17.md` exit criterion 1 (three stable releases) is **not met**, and criterion 2
  (a sibling agrees on a shared result interface) is **partly** met by exactly the two hand-offs above. Contract
  checks are the cheapest way to keep watching both. Decision: still no `mediate()`.
- `mv_checks()` in `R/checks.R` builds one row per check (`check`, `status`, `message`, `fix`), is read-only, and
  already has an opt-in network row (`updates`). Contract checks follow the same shape and the same opt-in pattern.
- The checks use mockable `pkg_*` helpers; tests mock them, never the real packages.

## 2. Design

- New argument `mediationverse_sitrep(contracts = FALSE)`. With `contracts = TRUE` the checks report runs even if
  `checks = FALSE` (documented), and gains one row per member contract. Not on by default: it runs real model code
  (about 3 s) and needs the siblings installed.
- Internal `check_contracts()` in `R/checks.R`, called from `mv_checks(contracts = FALSE)` after `source`/`updates`:
  - Build one tiny dataset with `contract_data()`: 120 rows, binary treatment, continuous mediator and outcome,
    fixed seed. It **must not disturb the user's RNG**: save `.Random.seed`, `on.exit()` restore it, or remove it if
    it did not exist.
  - Fit once with `contract_fit()` = `medfit::med(data, "A", "M", "Y")`. If medfit is not loadable, return a single
    `warn` row `contract:medfit` ("medfit is not available, contracts were not checked") and stop.
  - For each of RMediation and probmed that is loadable: call its hand-off in `tryCatch`. Row `contract:RMediation`
    passes when `ci_mediation_data(fit)` returns finite `$CI` of length 2; row `contract:probmed` passes when
    `pmed(fit)` returns an object with finite `estimate`. A member that errors or returns the wrong shape yields
    status **fail** with the error message and fix "Update medfit and <member> together (mediationverse_update())".
  - Members that are absent or broken get **no** contract row (the version and load checks already report them).
  - The call sites are isolated helpers (`contract_ci()`, `contract_pmed()`) so tests mock them.
- No new exports, no new dependencies, no network, no files written.

## 3. Tasks (in order; each ends with a commit on `feature/release-0.5.0`)

1. **Helpers and checks.** Add `contract_data()`, `contract_fit()`, `contract_ci()`, `contract_pmed()` and
   `check_contracts()` to `R/checks.R`; add `contracts` to `mv_checks()` (rows inserted after `source`).
2. **Wire into `sitrep()`.** Add the `contracts` argument with validation (`TRUE`/`FALSE`, like `updates`), run the
   checks when `isTRUE(checks) || contracts`, update the hint line, and the roxygen (`@param contracts`, `@details`).
3. **Tests** (`tests/testthat/test-checks.R`, mocked helpers): rows pass when both hand-offs work; `fail` with the
   message when one errors; `fail` when the CI has the wrong shape or is non-finite; single `warn` row when medfit is
   missing; no rows for absent or broken siblings; no contract rows unless `contracts = TRUE`; the user's
   `.Random.seed` is identical before and after, including when none existed; `sitrep(contracts = TRUE)` runs the
   checks and `contracts = NA` errors. One unmocked test, skipped unless all three packages are installed, runs
   the real chain and expects `pass`.
4. **Live proof it can fail.** With the real packages, mock `contract_ci()` to return a bad shape in a scratch R
   session and confirm the row reads `fail`; separately run the real thing and confirm `pass`. Quote both in the PR.
5. **Docs.** `devtools::document()` (then `git checkout DESCRIPTION`: roxygen 8.1.1 churns the pinned
   `Config/roxygen2/version`), NEWS entry, README feature list, `vignettes/getting-started.qmd` (one short section,
   `eval = FALSE`), `_pkgdown.yml` unchanged (no new exports).
6. **Record the design result.** Add a dated "Exit criteria check, 2026-11-17" paragraph to
   `planning/DESIGN-mediate-pipeline-2026-11-17.md` with the section 1 findings.
7. **Release prep** (separate PR, as in 0.3.0 and 0.4.0): version `0.5.0`, NEWS heading, `.STATUS` (`done:` line),
   `STATUS.md` date; grep the whole repo for `0.4.0.9000` afterward.

## 4. Verification

- `scripts/check-local.sh` and `Rscript -e 'devtools::test()'`: every existing test still passes (477
  expectations, 0 failures before this release) plus the new ones; `covr` stays above 80% and `check.R` lines for
  the new code are covered.
- `Rscript -e 'pkgdown::check_pkgdown()'` clean; the getting-started article renders with `quarto::quarto_render()`.
- Live: `mediationverse_sitrep(contracts = TRUE)` on this machine prints two contract rows, both `pass`, and the
  session's `.Random.seed` is unchanged afterward.
- CI on the PR: all four checks, including Windows, before merging. The contract code must not run during R CMD
  check unless asked: it only runs when `contracts = TRUE`, and the unmocked test skips when a sibling is missing
  (CI installs only the Suggests it needs). Then the release flow of 0.3.0 and 0.4.0.

## 5. Risks

| Risk | Impact | Mitigation |
|------|--------|-----------|
| The check clobbers the user's random-number stream | High | save and restore `.Random.seed`; tested with and without a prior seed |
| A real analysis inside a diagnostic is slow or flaky | Med | 120 rows, about 3 s, opt-in only; `tryCatch` turns any error into a `fail` row |
| `pmed()` internals change its result fields | Med | the check asserts only a finite `estimate`; the contract is the point, so a break there is the signal |
| Windows CI differs (pmed bootstrap, parallelism) | Med | contract code is not run by default or by the mocked tests; the unmocked test skips unless all three packages are installed |
| Scope creep into `mediate()` or pipeline | High | listed out of scope below |

Out of scope, listed once: `mediate()` / `mediation_pipeline()`, `mv_options()` (no sibling reads a
`mediationverse.*` option), CRAN submission, the ADHD dashboard branch, any new dependency or export, contract rows
for medrobust, medsim and missingmed (their objects are not shared with the medfit fit; revisit if they adopt it).

## 6. Definition of done

`sitrep(contracts = TRUE)` reports one passing row per installed hand-off and a failing, explained row when one
breaks, with the RNG untouched; tests, NEWS, README, getting-started and `.STATUS` current; exit-criteria result
recorded in the design note; tag `v0.5.0` and GitHub release created from the merge commit on `main`; `dev` bumped
to 0.5.0.9000.
