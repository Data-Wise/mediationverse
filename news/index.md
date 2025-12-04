# Changelog

## mediationverse (development version)

### mediationverse 0.0.0.9000

#### New Features

- Initial package skeleton with core functionality
- [`mediationverse_packages()`](https://data-wise.github.io/mediationverse/reference/mediationverse_packages.md) -
  List installed ecosystem packages with versions
- [`mediationverse_update()`](https://data-wise.github.io/mediationverse/reference/mediationverse_update.md) -
  Update all ecosystem packages from GitHub/CRAN
- [`mediationverse_conflicts()`](https://data-wise.github.io/mediationverse/reference/mediationverse_conflicts.md) -
  Detect and display function name conflicts
- Startup message displays attached packages when loading mediationverse

#### Ecosystem

The mediationverse meta-package provides unified access to:

- **medfit** - Infrastructure (S7 classes, model fitting, extraction,
  bootstrap)
- **probmed** - Probabilistic effect size (P_med)
- **RMediation** - Confidence intervals (Distribution of Product, MBCO)
- **medrobust** - Sensitivity analysis (bounds, falsification)
- **medsim** - Simulation infrastructure

#### Documentation

- pkgdown website with standardized ecosystem theme
- README with installation and usage instructions
- Function documentation for all exports

#### Infrastructure

- GitHub Actions for R CMD check
- GitHub Actions for pkgdown deployment
- Standardized package structure following tidyverse patterns
