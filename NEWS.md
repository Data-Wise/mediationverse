# mediationverse (development version)

## Bug fixes

* `mediationverse_update()` / `mediationverse_sitrep()`: keep `medfit` sourced from
  **GitHub** (`data-wise/medfit`), reverting the 2026-06-19 reclassification to
  `cran_pkgs`. CRAN serves only medfit 0.2.1, but the ecosystem requires
  medfit >= 0.3.0 (probmed, missingmed) — sourcing it from CRAN resolves a version too
  old for those packages. `RMediation` remains the only CRAN-sourced core package.
* `DESCRIPTION`: added `Data-Wise/medfit` to `Remotes:` so GitHub installs resolve
  medfit 0.3.x rather than CRAN 0.2.1.
* README + vignettes: corrected example calls to use real sibling exports
  (`pmed()`, `bound_ne()`, `falsification_summary()`, `medsim_run()`) in place of
  functions that do not exist in those packages.
* README: unified `pak::pak("Data-Wise/mediationverse")` casing in the Quick Start
  block to match the Installation section.
* Fixed badge URLs in README.md to use correct GitHub organization case (`Data-Wise`
  instead of `data-wise`). Updated workflow badges and ecosystem package table for
  consistency.
* Fixed pkgdown workflow failure caused by version constraint on RMediation in
  DESCRIPTION. Removed `(>= 1.4.0)` constraint as it conflicted with pak dependency
  resolution in CI environments.
* Fixed documentation typo in `mediationverse_packages()` where the `@return` section
  had a missing closing parenthesis in the `version` field description (R/packages.R:13).

## Breaking changes

* **Selective loading**: mediationverse now loads only `medfit` (foundation package) by
  default. Other packages must be loaded explicitly with `library()`.

  ```r
  # OLD behavior (v0.0.x)
  library(mediationverse)  # Loaded all 5 packages

  # NEW behavior
  library(mediationverse)  # Loads only medfit
  library(probmed)         # Load explicitly as needed
  library(RMediation)      # Load explicitly as needed
  ```

  New startup message shows which packages are available but not yet loaded.

## Documentation

* Added comprehensive ecosystem architecture and data flow diagrams to README.
* Updated all vignettes to demonstrate selective loading pattern:
  - `getting-started.qmd`: selective loading explanation and examples.
  - `mediationverse-workflow.qmd`: complete workflow showing explicit package loading.
* Added `SELECTIVE-LOADING-TEST.md` with comprehensive test results.

## Infrastructure

* `R/attach.R`: refactored to load only medfit by default.
* `R/zzz.R`: updated `.onAttach()` with informative startup message.
* Optimized R-CMD-check workflow: reduced from 5 to 3 platforms (macOS, Windows,
  Ubuntu release). Check workflows now complete in ~3 minutes (~50% faster).
* Added `--ignore-vignettes` flag to skip vignette validation during CI checks.
* Updated favicons; added Gemini AI workflows for code review and issue triage.
* `.Rbuildignore`: added `^CLAUDE\.md$` and `^STATUS\.md$`.
* `.gitignore`: added `CLAUDE.local.md`, `*.Rcheck/`, `*.tar.gz`.
* Aligned with medfit COORDINATION-BRAINSTORM.md (Option 2 selective loading strategy).

# mediationverse 0.0.0.9000

## New features

* `mediationverse_packages()` — list installed ecosystem packages with versions.
* `mediationverse_update()` — update all ecosystem packages from GitHub/CRAN.
* `mediationverse_conflicts()` — detect and display function name conflicts.
* Startup message displays attached packages when loading mediationverse.

## Ecosystem

The mediationverse meta-package provides unified access to:

* **medfit** — infrastructure (S7 classes, model fitting, extraction, bootstrap).
* **probmed** — probabilistic effect size (P_med).
* **RMediation** — confidence intervals (Distribution of Product, MBCO).
* **medrobust** — sensitivity analysis (bounds, falsification).
* **medsim** — simulation infrastructure.

## Infrastructure

* pkgdown website with standardized ecosystem theme.
* README with installation and usage instructions.
* Function documentation for all exports.
* GitHub Actions for R CMD check and pkgdown deployment.
* Standardized package structure following tidyverse patterns.
