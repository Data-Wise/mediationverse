# mediationverse

> Unified ecosystem for mediation analysis in R

## Overview

The **mediationverse** is a collection of R packages for mediation
analysis, providing a unified ecosystem for:

- 🔧 Model fitting and extraction
- 📊 Effect size computation
- 📈 Confidence interval estimation
- 🛡️ Sensitivity analysis
- 🔬 Simulation studies

## Quick Start

``` r
# Install mediationverse
pak::pak("data-wise/mediationverse")

# Load foundation package + packages you need
library(mediationverse)  # Loads medfit (foundation)
library(probmed)         # For P_med effect size
library(RMediation)      # For confidence intervals
library(medrobust)       # For sensitivity analysis

# Fit mediation models
fit_m <- lm(M ~ X + C, data = mydata)
fit_y <- lm(Y ~ X + M + C, data = mydata)
med_data <- extract_mediation(fit_m, model_y = fit_y,
                               treatment = "X", mediator = "M")

# Get P_med effect size, confidence intervals, and sensitivity analysis
pmed_result <- compute_pmed(med_data)
ci_result <- ci(med_data, type = "dop")
sensitivity <- sensitivity_analysis(med_data)
```

## Ecosystem Status Dashboard

> **📊 [View Full
> Dashboard](https://github.com/data-wise/mediationverse/blob/main/STATUS.md)**
> \| **🗺️ [Development
> Roadmap](https://data-wise.github.io/mediationverse/articles/roadmap.html)**

### Package Overview

| Package                                                         | Status                                                                       | Build                                                                                                                                             | Website                                                                                                                              | Role                      |
|-----------------------------------------------------------------|------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------|---------------------------|
| [**medfit**](https://Data-Wise.github.io/medfit/)               | ![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg) | [![Build](https://github.com/Data-Wise/medfit/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Data-Wise/medfit/actions)         | [![Docs](https://github.com/Data-Wise/medfit/actions/workflows/pkgdown.yaml/badge.svg)](https://Data-Wise.github.io/medfit/)         | **Foundation**            |
| [**probmed**](https://Data-Wise.github.io/probmed/)             | ![Lifecycle](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)  | [![Build](https://github.com/Data-Wise/probmed/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Data-Wise/probmed/actions)       | [![Docs](https://github.com/Data-Wise/probmed/actions/workflows/pkgdown.yaml/badge.svg)](https://Data-Wise.github.io/probmed/)       | Effect Size               |
| [**RMediation**](https://cran.r-project.org/package=RMediation) | ![Lifecycle](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)  | [![Build](https://github.com/Data-Wise/rmediation/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Data-Wise/rmediation/actions) | [![Docs](https://github.com/Data-Wise/rmediation/actions/workflows/pkgdown.yaml/badge.svg)](https://Data-Wise.github.io/rmediation/) | Confidence Intervals      |
| [**medrobust**](https://Data-Wise.github.io/medrobust/)         | ![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg) | [![Build](https://github.com/Data-Wise/medrobust/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Data-Wise/medrobust/actions)   | [![Docs](https://github.com/Data-Wise/medrobust/actions/workflows/pkgdown.yaml/badge.svg)](https://Data-Wise.github.io/medrobust/)   | Sensitivity Analysis      |
| [**medsim**](https://Data-Wise.github.io/medsim/)               | ![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg) | [![Build](https://github.com/Data-Wise/medsim/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Data-Wise/medsim/actions)         | [![Docs](https://github.com/Data-Wise/medsim/actions/workflows/pkgdown.yaml/badge.svg)](https://Data-Wise.github.io/medsim/)         | Simulation Infrastructure |

### Development Progress

**Current Quarter (Q4 2025)**: Ecosystem Development Phase

| Milestone                      | Status         | Progress |
|--------------------------------|----------------|----------|
| medfit Phase 3 (Extraction)    | ✅ Complete    | 100%     |
| medfit Phase 4 (Model Fitting) | 🚧 In Progress | 60%      |
| probmed Integration            | ⏳ Pending     | 0%       |
| RMediation Integration         | ⏳ Pending     | 0%       |
| medsim Core Implementation     | ✅ Complete    | 100%     |
| Comprehensive Documentation    | ✅ Complete    | 100%     |

**Next Quarter (Q1 2026)**: Integration & Release

- Complete medfit Phase 4-5 (Bootstrap, Testing)
- Integrate probmed and RMediation with medfit
- CRAN submissions for medfit, probmed
- Finalize mediationverse meta-package

## Package Ecosystem

The mediationverse follows a **modular architecture** with **selective
loading** inspired by [tidyverse](https://www.tidyverse.org/) and
[easystats](https://easystats.github.io/easystats/):

### Architecture Diagram

    ┌──────────────────────────────────────────────────────────────────────┐
    │                        mediationverse                                │
    │                      (Meta-Package Loader)                           │
    │                                                                      │
    │  library(mediationverse)  →  Loads only medfit (foundation)         │
    │  library(probmed)         →  Explicit loading for effect sizes       │
    │  library(RMediation)      →  Explicit loading for CIs                │
    │  library(medrobust)       →  Explicit loading for sensitivity        │
    │  library(medsim)          →  Explicit loading for simulation         │
    └──────────────────────────────────────────────────────────────────────┘
                                        │
                                        │ Always loads
                                        ▼
    ┌──────────────────────────────────────────────────────────────────────┐
    │                            FOUNDATION LAYER                          │
    │  ┌────────────────────────────────────────────────────────────┐     │
    │  │                         medfit                             │     │
    │  │  • S7 classes (MediationData, SerialMediationData)         │     │
    │  │  • extract_mediation() - Extract from lm/glm/lavaan        │     │
    │  │  • fit_mediation() - Formula interface                     │     │
    │  │  • bootstrap_mediation() - Bootstrap inference             │     │
    │  └────────────────────────────────────────────────────────────┘     │
    └──────────────────────────────────────────────────────────────────────┘
                                        │
                        ┌───────────────┼───────────────┐
                        │               │               │
                        ▼               ▼               ▼
    ┌──────────────────────────────────────────────────────────────────────┐
    │                      SPECIALIZED PACKAGES LAYER                      │
    ├────────────────┬─────────────────┬────────────────┬─────────────────┤
    │   probmed      │  RMediation     │  medrobust     │    medsim       │
    │ ┌────────────┐ │ ┌─────────────┐ │ ┌────────────┐ │ ┌─────────────┐ │
    │ │ Effect     │ │ │ Confidence  │ │ │Sensitivity │ │ │ Simulation  │ │
    │ │ Sizes      │ │ │ Intervals   │ │ │ Analysis   │ │ │Infrastructure│ │
    │ ├────────────┤ │ ├─────────────┤ │ ├────────────┤ │ ├─────────────┤ │
    │ │• P_med     │ │ │• DOP        │ │ │• Bounds    │ │ │• Data gen   │ │
    │ │• Scale-free│ │ │• Monte Carlo│ │ │• Falsify   │ │ │• Parallel   │ │
    │ │• Continuous│ │ │• MBCO       │ │ │• Partial ID│ │ │• Caching    │ │
    │ │• Binary    │ │ │• Asymmetric │ │ │• Plots     │ │ │• Tables     │ │
    │ └────────────┘ │ └─────────────┘ │ └────────────┘ │ └─────────────┘ │
    └────────────────┴─────────────────┴────────────────┴─────────────────┘
                                        │
                                        │ All packages use
                                        ▼
                            ┌─────────────────────┐
                            │  MediationData (S7) │
                            │  Unified Interface  │
                            └─────────────────────┘

### Data Flow

    User Data
       │
       ▼
    fit_mediation() or lm()/glm()/lavaan::sem()
       │
       ▼
    extract_mediation()  ──────►  MediationData object
       │                                  │
       │                                  │
       ├──────────────┬──────────────┬────┴────────────┐
       │              │              │                 │
       ▼              ▼              ▼                 ▼
    probmed::     RMediation::   medrobust::      medfit::
    compute_pmed() medci()        sensitivity()   bootstrap_mediation()
       │              │              │                 │
       │              │              │                 │
       └──────────────┴──────────────┴─────────────────┘
                            │
                            ▼
                    Results & Inference

### Core Packages

#### medfit: Foundation Infrastructure

**Purpose**: Unified S7-based infrastructure for mediation analysis
**Status**: Phase 4 in progress **Provides**: - S7 classes
(`MediationData`, `SerialMediationData`, `BootstrapResult`) - Model
extraction from lm/glm/lavaan - Bootstrap inference (parametric,
nonparametric, plugin) - Type-safe data structures

**Links**: [Website](https://data-wise.github.io/medfit/) \|
[GitHub](https://github.com/data-wise/medfit) \|
[Issues](https://github.com/data-wise/medfit/issues)

#### probmed: Probabilistic Effect Sizes

**Purpose**: Compute P_med, a scale-free probabilistic effect size
**Status**: Stable, ready for integration **Provides**: - P_med
computation for continuous and binary outcomes - GLM support (logistic,
Poisson) - Integration with lavaan and mediation packages - Bootstrap
confidence intervals

**Links**: [Website](https://data-wise.github.io/probmed/) \|
[GitHub](https://github.com/data-wise/probmed) \|
[Issues](https://github.com/data-wise/probmed/issues)

#### RMediation: Confidence Intervals

**Purpose**: Asymmetric confidence intervals via Distribution of Product
**Status**: Stable on CRAN **Provides**: - Distribution of Product (DOP)
method - Monte Carlo (MC) confidence intervals - MBCO bootstrap method -
Integration with standard R models

**Links**: [CRAN](https://cran.r-project.org/package=RMediation) \|
[Website](https://data-wise.github.io/rmediation/) \|
[GitHub](https://github.com/data-wise/rmediation)

#### medrobust: Sensitivity Analysis

**Purpose**: Partial identification under differential misclassification
**Status**: In development **Provides**: - Partial identification bounds
for NDE/NIE - Data-driven falsification tests - Synthetic data
generation - Publication-ready visualizations

**Links**: [Website](https://data-wise.github.io/medrobust/) \|
[GitHub](https://github.com/data-wise/medrobust) \|
[Issues](https://github.com/data-wise/medrobust/issues)

#### medsim: Simulation Infrastructure

**Purpose**: Standardized infrastructure for Monte Carlo studies
**Status**: Core implementation complete **Provides**: -
Environment-aware execution (local/HPC) - Parallel processing with
progress bars - Ground truth caching - Publication-ready figures and
LaTeX tables

**Links**: [Website](https://data-wise.github.io/medsim/) \|
[GitHub](https://github.com/data-wise/medsim) \|
[Issues](https://github.com/data-wise/medsim/issues)

## Installation

### From GitHub (Development)

``` r
# Install all packages
pak::pak("Data-Wise/mediationverse")

# Or install individually
pak::pak("Data-Wise/medfit")
pak::pak("Data-Wise/probmed")
pak::pak("Data-Wise/medrobust")
pak::pak("Data-Wise/medsim")

# RMediation from CRAN
install.packages("RMediation")
```

### From CRAN (Future)

``` r
# Planned for Q2-Q3 2026
install.packages("mediationverse")
```

## Usage

### Loading Packages

The mediationverse uses **selective loading**: only the foundation
package (`medfit`) is loaded by default. Load other packages as needed
for your analysis.

``` r
library(mediationverse)
#> ── Attaching mediationverse 0.0.0.9000 ──
#> ✔ medfit 0.1.0 (foundation package)
#> ℹ Use library(probmed) for P_med effect size
#> ℹ Use library(RMediation) for DOP/MBCO inference
#> ℹ Use library(medrobust) for sensitivity analysis
#> ℹ Use library(medsim) for simulation utilities
#> ──────────────────────────────────────────────────────

# Load additional packages as needed
library(probmed)      # For probabilistic effect sizes
library(RMediation)   # For confidence intervals
library(medrobust)    # For sensitivity analysis
library(medsim)       # For simulation studies
```

**Why selective loading?** - Clean namespace (avoids function
conflicts) - Only load what you need for your analysis - `medfit` is
always available (foundation for all packages)

### Package Management

``` r
# List installed packages and versions
mediationverse_packages()

# Update all packages
mediationverse_update()

# Check for function conflicts
mediationverse_conflicts()
```

### Complete Analysis Workflow

``` r
# Load foundation and packages you need
library(mediationverse)  # Loads medfit (foundation)
library(probmed)         # For P_med effect size
library(RMediation)      # For confidence intervals
library(medrobust)       # For sensitivity analysis

# 1. Fit mediation models (medfit - already loaded)
fit_m <- lm(M ~ X + C, data = mydata)
fit_y <- lm(Y ~ X + M + C, data = mydata)

# 2. Extract mediation structure (medfit)
med_data <- extract_mediation(fit_m, model_y = fit_y,
                               treatment = "X", mediator = "M")

# 3. Bootstrap inference (medfit)
boot_result <- bootstrap_mediation(med_data, n_boot = 2000)

# 4. Compute probabilistic effect size (probmed)
pmed_result <- compute_pmed(med_data)

# 5. Get confidence intervals (RMediation)
ci_result <- ci(med_data, type = "dop")

# 6. Sensitivity analysis (medrobust)
robust_result <- sensitivity_analysis(med_data)

# 7. Run simulation study (medsim - load if needed)
library(medsim)
sim_results <- medsim_run(
  method = my_method,
  scenarios = medsim_scenarios_mediation(),
  config = medsim_config("local")
)
```

## Design Philosophy

Following principles from [tidyverse](https://design.tidyverse.org/) and
[easystats](https://easystats.github.io/easystats/):

1.  **Foundation Package**: medfit provides shared S7 infrastructure
2.  **Specialized Packages**: Each package focuses on one methodological
    contribution
3.  **Consistent API**: Unified interfaces across all packages
4.  **Type Safety**: S7 classes ensure data integrity
5.  **Low Dependencies**: Minimal external dependencies for stability
6.  **Comprehensive Testing**: \>90% code coverage across packages

## Documentation

### Getting Started

- [Quick Start
  Guide](https://data-wise.github.io/mediationverse/articles/getting-started.html)
- [Complete
  Workflow](https://data-wise.github.io/mediationverse/articles/mediationverse-workflow.html)

### Status & Planning

- [📊 Package Status
  Dashboard](https://github.com/data-wise/mediationverse/blob/main/STATUS.md)
- [🗺️ Development
  Roadmap](https://data-wise.github.io/mediationverse/articles/roadmap.html)
- [🤝 Contributing
  Guide](https://data-wise.github.io/mediationverse/articles/contributing.html)
- [📋 Ecosystem
  Coordination](https://github.com/data-wise/medfit/blob/main/planning/ECOSYSTEM.md)

### Package Documentation

- [medfit Documentation](https://data-wise.github.io/medfit/)
- [probmed Documentation](https://data-wise.github.io/probmed/)
- [RMediation Documentation](https://data-wise.github.io/rmediation/)
- [medrobust Documentation](https://data-wise.github.io/medrobust/)
- [medsim Documentation](https://data-wise.github.io/medsim/)

## Contributing

The mediationverse is in active development. Contributions are welcome!

- 🐛 **Report bugs**: [GitHub
  Issues](https://github.com/data-wise/mediationverse/issues)
- 💡 **Suggest features**:
  [Discussions](https://github.com/data-wise/mediationverse/discussions)
- 🔧 **Contribute code**: See our [Contributing
  Guide](https://data-wise.github.io/mediationverse/articles/contributing.html)
- 📖 **Improve docs**: Submit pull requests

**Development Workflow**: 1. Fork the repository 2. Create a feature
branch from `dev` 3. Make your changes with tests 4. Submit a pull
request to `dev`

See
[CONTRIBUTING.md](https://Data-Wise.github.io/mediationverse/CONTRIBUTING.md)
for detailed guidelines.

## Citation

If you use packages from the mediationverse in your research, please
cite the individual packages:

    Tofighi, D. (2025). medfit: Infrastructure for mediation analysis in R.
    R package version 0.1.0. https://github.com/data-wise/medfit

    Tofighi, D. (2025). probmed: Probabilistic effect sizes for mediation analysis.
    R package version 0.1.0. https://github.com/data-wise/probmed

Full citations available via `citation("packagename")`.

## Related Ecosystems

The mediationverse draws inspiration from:

- [**tidyverse**](https://www.tidyverse.org/) - Cohesive data science
  packages
- [**easystats**](https://easystats.github.io/easystats/) - Statistical
  modeling ecosystem
- [**mlr3**](https://mlr3.mlr-org.com/) - Machine learning framework

## Code of Conduct

Please note that the mediationverse project is released with a
[Contributor Code of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

## License

GPL (\>= 3)

## Contact

**Maintainer**: Davood Tofighi (<dtofighi@gmail.com>) **ORCID**:
[0000-0001-8523-7776](https://orcid.org/0000-0001-8523-7776)

------------------------------------------------------------------------

**Sources:** - [tidyverse meta-package
structure](https://github.com/tidyverse/tidyverse) - [easystats
ecosystem documentation](https://easystats.github.io/easystats/)
