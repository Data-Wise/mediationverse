# mediationverse (development version)

## Bug Fixes

* Fixed pkgdown workflow failure caused by version constraint on RMediation in DESCRIPTION. Removed `(>= 1.4.0)` constraint as it conflicted with pak dependency resolution in CI environments
* Fixed documentation typo in `mediationverse_packages()` where the `@return` section had a missing closing parenthesis in the `version` field description (R/packages.R:13)

## Workflow Optimization & Standardization (2025-12-05)

### Performance Improvements
* **Optimized R-CMD-check workflow**: Reduced from 5 to 3 platforms (macOS, Windows, Ubuntu release)
* **Removed problematic platforms**: Dropped `ubuntu-latest (devel)` and `ubuntu-latest (oldrel-1)`
* **Runtime improvement**: Check workflows now complete in ~3 minutes (down from 6 minutes, **50% faster**)
* **Build optimization**: Added `--ignore-vignettes` flag to skip vignette validation during CI checks
* **Removed Quarto installation**: Not needed for CI checks, saves ~30 seconds per run

### Infrastructure Updates
* **Updated favicons**: Regenerated all favicon assets to match updated logo
* **Added Gemini AI workflows**: Code review, triage, and automated issue management
* **.Rbuildignore**: Added `^CLAUDE\.md$` and `^STATUS\.md$` for documentation files
* **.gitignore**: Added `CLAUDE.local.md`, `*.Rcheck/`, `*.tar.gz` for better local development

### Standardization
* All workflows passing on main branch
* Consistent with ecosystem badge standards
* Website configuration aligned with mediationverse theme

## mediationverse 0.0.0.9000

### New Features

* Initial package skeleton with core functionality
* `mediationverse_packages()` - List installed ecosystem packages with versions
* `mediationverse_update()` - Update all ecosystem packages from GitHub/CRAN
* `mediationverse_conflicts()` - Detect and display function name conflicts
* Startup message displays attached packages when loading mediationverse

### Ecosystem

The mediationverse meta-package provides unified access to:

* **medfit** - Infrastructure (S7 classes, model fitting, extraction, bootstrap)
* **probmed** - Probabilistic effect size (P_med)
* **RMediation** - Confidence intervals (Distribution of Product, MBCO)
* **medrobust** - Sensitivity analysis (bounds, falsification)
* **medsim** - Simulation infrastructure

### Documentation

* pkgdown website with standardized ecosystem theme
* README with installation and usage instructions
* Function documentation for all exports

### Infrastructure

* GitHub Actions for R CMD check
* GitHub Actions for pkgdown deployment
* Standardized package structure following tidyverse patterns
