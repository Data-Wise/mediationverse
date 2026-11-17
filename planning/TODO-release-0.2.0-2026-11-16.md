# Task list: mediationverse 0.2.0

Plan: [PLAN-release-0.2.0-2026-11-16.md](PLAN-release-0.2.0-2026-11-16.md)
Verify command for every code task: `devtools::test()` then `bash scripts/check-local.sh`.

## Phase 1: Codex findings

- [x] **T1 (XS) README Quick Start installs RMediation.** Add an explicit RMediation install line
  (it is Suggests only). AC: Quick Start runs on a fresh library. Files: `README.md`.
- [x] **T2 (S) Sitrep labels the recommended source.** Roxygen documents `source` as recommended;
  printed label reads "recommended: GitHub/CRAN". AC: column name and values unchanged; new test
  asserts printed label wording; docs regenerated. Files: `R/sitrep.R`, `man/mediationverse_sitrep.Rd`,
  `tests/testthat/test-sitrep.R`.

### Checkpoint 1
- [x] Suite green, `check-local.sh` PASS, commit.

## Phase 2: citations

- [x] **T3 (M) `mediationverse_citations()`.** Per SPEC: `pkg_citation()` helper with `tryCatch`,
  `style = c("text", "bibtex")`, `include_self = FALSE`, empty/erroring citation message,
  not-installed note, commit-SHA note, classed invisible return + print method. AC: all/some/none
  installed, empty and erroring citation, both styles, include_self all tested via mocked helpers.
  Files: `R/citations.R`, `tests/testthat/test-citations.R`, `NAMESPACE`, `man/`, `_pkgdown.yml`.

### Checkpoint 2
- [x] Suite green, `check-local.sh` PASS, `pkgdown::check_pkgdown()` clean, commit.

## Phase 3: sitrep checks

- [x] **T4 (S) Extract quiet `find_conflicts()`.** Internal helper used by `mediationverse_conflicts()`;
  exported behavior identical. AC: existing conflicts tests pass unchanged. Files: `R/conflicts.R`.
- [x] **T5 (M) `mediationverse_sitrep(checks = FALSE)`.** Default output unchanged plus one-line hint;
  `checks = TRUE` appends version-vs-minimum, OpenMx optional dependency (warn), conflicts with
  `only_loaded = FALSE`; returns report with `checks` data frame (`check`, `status`, `message`, `fix`).
  AC: simulated old version, missing OpenMx, `checks = FALSE` output unchanged. Files: `R/sitrep.R`,
  `R/checks.R`, tests, `man/`.

### Checkpoint 3
- [x] Suite green, `check-local.sh` PASS, commit.

## Phase 4: release prep

- [x] **T6 (S) Docs and NEWS.** NEWS entries, README function list, `.STATUS`/`STATUS.md` sync.
  Version bump to 0.2.0 deferred to the release PR.

### Checkpoint 4
- [x] Coverage >= 80% (`covr`), full suite green, `check-local.sh` PASS, commit.
