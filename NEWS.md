# mediationverse (development version)

## New features

* `missingmed` (mediation analysis with multiple imputation and IPW for missing
  data) joins the core ecosystem: `mediationverse_packages()`,
  `mediationverse_sitrep()`, `mediationverse_conflicts()` and
  `mediationverse_update()` now include it. It is not attached by `library()`
  (selective loading is unchanged). It is deliberately not in `Remotes:` or
  `Suggests:`: probmed pins `medfit@v0.3.0`, which conflicts with missingmed's
  `medfit (>= 0.3.1)` and makes dependency resolution fail.

## Bug fixes

* `mediationverse_sitrep()` and `mediationverse_update()` no longer say CRAN has
  medfit 0.2.1 (CRAN has 0.3.2) or RMediation 1.5.0 (CRAN has 1.6.1). medfit stays
  sourced from GitHub because CRAN 0.3.2 predates two result-changing fixes in
  medfit 0.5.0 (serial `te()`/`pm()` and `confint(parm = "paths")`).
* The 0.1.0 entry below claimed `Data-Wise/medfit` was added to `Remotes:`; it never
  was (medfit is in `Imports:`). Corrected there.
* `pkgdown` no longer publishes internal planning documents or `CLAUDE.md`.
* Docs: removed a stale "Planned" entry that listed missingmed as having no repository; fixed
  the RMediation site link (`/rmediation/`, the URL is case-sensitive); replaced dead
  GitHub Discussions links with Issues; refreshed example output and the medfit citation
  (CRAN 0.3.2).
* Removed tracked junk: a vim swap file (`._pkgdown.yml.swp`) and four `gemini-*.toml`
  command files left over from the removed Gemini review bot.

# mediationverse 0.1.0

## Bug fixes

* `mediationverse_update()` / `mediationverse_sitrep()`: keep `medfit` sourced from
  **GitHub** (`data-wise/medfit`), reverting the 2026-06-19 reclassification to
  `cran_pkgs`. CRAN serves only medfit 0.2.1, but the ecosystem requires
  medfit >= 0.3.0 (probmed, missingmed) — sourcing it from CRAN resolves a version too
  old for those packages. `RMediation` remains the only CRAN-sourced core package.
* `mediationverse_update()` installs medfit from GitHub so installs resolve a medfit
  that carries the ecosystem's fixes (`DESCRIPTION` lists it in `Imports:` only).
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
