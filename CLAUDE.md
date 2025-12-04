# CLAUDE.md for mediationverse Package

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository.

## About This Package

**mediationverse** is a meta-package that provides a unified entry point
for the mediation analysis ecosystem in R. Similar to tidyverse for data
science or easystats for statistical modeling, mediationverse loads all
core packages with a single
[`library(mediationverse)`](https://github.com/data-wise/mediationverse)
call.

### Core Mission

Simplify installation and loading of the complete mediation analysis
toolkit, ensuring users have access to all complementary packages for
model fitting, effect sizes, confidence intervals, and sensitivity
analysis.

### Core Packages

| Package        | Purpose                              | Role        |
|----------------|--------------------------------------|-------------|
| **medfit**     | Model fitting, extraction, bootstrap | Foundation  |
| **probmed**    | Probabilistic effect size (P_med)    | Application |
| **RMediation** | Confidence intervals (DOP, MBCO)     | Application |
| **medrobust**  | Sensitivity analysis                 | Application |
| **medsim**     | Simulation infrastructure            | Support     |

## Common Development Commands

### Package Building and Checking

``` r
# Install package dependencies
remotes::install_deps(dependencies = TRUE)

# Check package (standard R CMD check)
rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "error")

# Build package
devtools::build()

# Install and reload during development
devtools::load_all()
```

### Documentation

``` r
# Generate documentation from roxygen2 comments
devtools::document()

# Build pkgdown site
pkgdown::build_site()
```

## Coding Standards

### R Version and Style

- **Minimum R version**: 4.1.0 (native pipe `|>` support)
- **Style**: tidyverse style guide
- **Roxygen2**: Use roxygen2 for documentation

### File Organization

    R/
    ├── attach.R              # Package attachment logic
    ├── conflicts.R           # Conflict resolution (planned)
    ├── logo.R                # ASCII art logo (planned)
    ├── mediationverse-package.R  # Package documentation
    ├── update.R              # Update function (planned)
    └── zzz.R                 # .onAttach() startup hooks

## Key Functions

### Implemented

- **`mediationverse_attach()`**: Internal function to load core packages
- **`is_attached()`**: Check if packages are attached
- **`package_version_string()`**: Get package versions
- **`.onAttach()`**: Startup message with package versions

### Planned

- **`mediationverse_packages()`**: List installed ecosystem packages
  with versions
- **`mediationverse_update()`**: Update all packages to latest versions
- **`mediationverse_conflicts()`**: Show function name conflicts between
  packages
- **`mediationverse_logo()`**: ASCII art logo

## Package Loading Behavior

When
[`library(mediationverse)`](https://github.com/data-wise/mediationverse)
is called:

1.  Loads all core packages silently

2.  Displays startup message with package versions:

        ── Attaching packages ──────────── mediationverse 0.0.0.9000 ──
        ✔ medfit     0.1.0     ✔ probmed    0.1.0
        ✔ RMediation 1.4.0     ✔ medrobust  0.1.0
        ✔ medsim     0.1.0
        ───────────────────────────────────────────────────────────────

3.  If packages are missing, displays installation instructions

## Dependencies

### Imports (Required)

- **cli**: Beautiful command line output for startup messages

### Suggests (Core Packages)

- **medfit**: Foundation package
- **probmed**: P_med effect size
- **RMediation**: Confidence intervals (CRAN)
- **medrobust**: Sensitivity analysis
- **medsim**: Simulation infrastructure

### Remotes

All development packages installed from GitHub:

    data-wise/medfit
    data-wise/probmed
    data-wise/medrobust
    data-wise/medsim

## Testing Strategy

### Unit Tests Should Cover

1.  **Package Loading**
    - All packages load without errors
    - Startup message displays correctly
    - Missing packages handled gracefully
2.  **Utility Functions**
    - `is_attached()` correctly identifies loaded packages
    - `package_version_string()` returns valid versions or “(not
      installed)”
3.  **Conflict Detection** (when implemented)
    - Correctly identifies overlapping function names
    - Suggests resolution strategies

## Ecosystem Coordination

mediationverse is the **meta-package** in the mediationverse ecosystem.

### Central Planning Documents

All ecosystem-wide coordination is managed in
`/Users/dt/mediation-planning/`:

| Document                       | Purpose                                              |
|--------------------------------|------------------------------------------------------|
| `ECOSYSTEM-COORDINATION.md`    | Version matrix, change propagation, release timeline |
| `MONTHLY-CHECKLIST.md`         | Recurring ecosystem health checks                    |
| `templates/README-template.md` | Standardized README structure                        |
| `templates/NEWS-template.md`   | Standardized NEWS.md format                          |

### Package Repositories

| Package        | GitHub                                                                  | CRAN                                                        |
|----------------|-------------------------------------------------------------------------|-------------------------------------------------------------|
| mediationverse | [data-wise/mediationverse](https://github.com/data-wise/mediationverse) | Planned                                                     |
| medfit         | [data-wise/medfit](https://github.com/data-wise/medfit)                 | Planned                                                     |
| probmed        | [data-wise/probmed](https://github.com/data-wise/probmed)               | Planned                                                     |
| RMediation     | [data-wise/rmediation](https://github.com/data-wise/rmediation)         | [RMediation](https://cran.r-project.org/package=RMediation) |
| medrobust      | [data-wise/medrobust](https://github.com/data-wise/medrobust)           | Planned                                                     |
| medsim         | [data-wise/medsim](https://github.com/data-wise/medsim)                 | Planned                                                     |

See [Ecosystem
Coordination](https://github.com/data-wise/medfit/blob/main/planning/ECOSYSTEM.md)
for guidelines.

## Development Roadmap

### Current Status (v0.0.0.9000)

Package skeleton

Basic attach functionality

Startup message with cli

pkgdown website

### Next Steps

Add `mediationverse_packages()` function

Add `mediationverse_update()` function

Add `mediationverse_conflicts()` function

Create getting started vignette

Add logo (hex sticker)

Test with all packages installed

CRAN submission (after all dependencies stable)

## Inspiration

This package is modeled after successful R meta-packages:

- **tidyverse**: Data science ecosystem
- **easystats**: Statistical modeling ecosystem
- **mlr3verse**: Machine learning ecosystem

## Additional Resources

### Package Website

- GitHub: <https://github.com/data-wise/mediationverse>
- Documentation: <https://data-wise.github.io/mediationverse/>

### Related Packages

- tidyverse source: <https://github.com/tidyverse/tidyverse>
- easystats source: <https://github.com/easystats/easystats>
