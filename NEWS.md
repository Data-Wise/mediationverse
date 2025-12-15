# mediationverse (development version)

## Major Changes (2025-12-15)

### Selective Loading Strategy (v0.1.0 preparation)

**Breaking Change**: mediationverse now uses **selective loading** - only `medfit` (foundation package) is loaded by default. Other packages must be loaded explicitly.

**Why this change?**
- Clean namespace with minimal function conflicts
- Users load only packages they need
- Explicit > implicit (better code clarity)
- Coordinated with medfit ecosystem integration

**Migration**:
```r
# OLD behavior (v0.0.x)
library(mediationverse)  # Loaded all 5 packages

# NEW behavior (v0.1.0+)
library(mediationverse)  # Loads only medfit
library(probmed)         # Load explicitly as needed
library(RMediation)      # Load explicitly as needed
```

**New startup message**:
```
── Attaching mediationverse 0.0.0.9000 ──
✔ medfit 0.1.0 (foundation package)
ℹ Use library(probmed) for P_med effect size
ℹ Use library(RMediation) for DOP/MBCO inference
ℹ Use library(medrobust) for sensitivity analysis
ℹ Use library(medsim) for simulation utilities
```

### Documentation Improvements

* **Architecture diagrams**: Added comprehensive ecosystem architecture and data flow diagrams to README
* **Vignettes updated**: All vignettes now demonstrate selective loading pattern
  - `getting-started.qmd`: Updated with selective loading explanation and examples
  - `mediationverse-workflow.qmd`: Complete workflow showing explicit package loading
* **Testing documentation**: Added `SELECTIVE-LOADING-TEST.md` with comprehensive test results

### Implementation

* `R/attach.R`: Refactored to load only medfit by default
* `R/zzz.R`: Updated `.onAttach()` with informative startup message
* All utility functions (`mediationverse_packages()`, `mediationverse_conflicts()`) tested and verified

### Coordination

* Aligned with medfit COORDINATION-BRAINSTORM.md (Option 2 strategy)
* Ready for medfit v0.1.0 integration (ETA Dec 21, 2025)
* Progress: 85% complete (waiting on medfit stabilization)

## Bug Fixes

* Fixed badge URLs in README.md to use correct GitHub organization case (`Data-Wise` instead of `data-wise`). Updated workflow badges and ecosystem package table for consistency
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
