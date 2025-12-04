# CLAUDE.md for mediationverse Package

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## About This Package

**mediationverse** is a meta-package that provides a unified entry point for the mediation analysis ecosystem in R. Similar to tidyverse for data science, mediationverse loads all core packages with a single `library(mediationverse)` call.

### Core Mission

Simplify installation and loading of the complete mediation analysis toolkit, ensuring users have access to all complementary packages for model fitting, effect sizes, confidence intervals, and sensitivity analysis.

### Core Packages

| Package | Purpose | Role |
|---------|---------|------|
| **medfit** | Model fitting, extraction, bootstrap | Foundation |
| **probmed** | Probabilistic effect size (P_med) | Application |
| **RMediation** | Confidence intervals (DOP, MBCO) | Application |
| **medrobust** | Sensitivity analysis | Application |
| **medsim** | Simulation infrastructure | Support |

---

## Common Development Commands

```r
# Install dependencies and check package
remotes::install_deps(dependencies = TRUE)
rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "error")

# Development workflow
devtools::load_all()
devtools::document()

# Build pkgdown site
pkgdown::build_site()
```

---

## Code Architecture

### Key Functions

**Implemented:**
- `mediationverse_attach()`: Internal function to load core packages
- `is_attached()`: Check if packages are attached
- `.onAttach()`: Startup message with package versions

**Planned:**
- `mediationverse_packages()`: List installed ecosystem packages with versions
- `mediationverse_update()`: Update all packages to latest versions
- `mediationverse_conflicts()`: Show function name conflicts
- `mediationverse_logo()`: ASCII art logo

### Package Loading Behavior

When `library(mediationverse)` is called:
1. Loads all core packages silently
2. Displays startup message with package versions
3. If packages missing, displays installation instructions

---

## Ecosystem Coordination

mediationverse is the **meta-package** in the mediationverse ecosystem.

### Central Planning

Ecosystem coordination managed in `/Users/dt/mediation-planning/`:
- `ECOSYSTEM-COORDINATION.md` - Version matrix, release timeline
- `MONTHLY-CHECKLIST.md` - Health checks

### Package Repositories

| Package | GitHub | Website | CRAN |
|---------|--------|---------|------|
| mediationverse | [data-wise/mediationverse](https://github.com/data-wise/mediationverse) | [Website](https://data-wise.github.io/mediationverse/) | Planned |
| medfit | [data-wise/medfit](https://github.com/data-wise/medfit) | [Website](https://data-wise.github.io/medfit/) | Planned |
| probmed | [data-wise/probmed](https://github.com/data-wise/probmed) | [Website](https://data-wise.github.io/probmed/) | Planned |
| RMediation | [data-wise/rmediation](https://github.com/data-wise/rmediation) | [Website](https://data-wise.github.io/rmediation/) | [CRAN](https://cran.r-project.org/package=RMediation) |
| medrobust | [data-wise/medrobust](https://github.com/data-wise/medrobust) | [Website](https://data-wise.github.io/medrobust/) | Planned |
| medsim | [data-wise/medsim](https://github.com/data-wise/medsim) | [Website](https://data-wise.github.io/medsim/) | Planned |

### Consistent Website Features

All package websites should have:
- **Ecosystem dropdown menu**: Links to all packages
- **Status menu**: Dashboard, Roadmap, Contributing links
- **Consistent styling**: Academic blue (#0054AD), Inter/Montserrat/Fira Code fonts
- **Standard badge order**: CRAN (if applicable), Lifecycle, R-CMD-check, Website, R-hub, Codecov

---

## Development Roadmap

### Current Status

- [x] Package skeleton
- [x] Basic attach functionality
- [x] Startup message with cli
- [x] pkgdown website

### Next Steps

- [ ] Add `mediationverse_packages()` function
- [ ] Add `mediationverse_update()` function
- [ ] Add `mediationverse_conflicts()` function
- [ ] Create getting started vignette
- [ ] CRAN submission (after all dependencies stable)

---

**Last Updated**: 2025-12-04
