# Getting Started with mediationverse

## Introduction

The **mediationverse** is a collection of R packages for mediation
analysis. It provides a unified ecosystem for model fitting, effect size
computation, confidence interval estimation, sensitivity analysis, and
simulation studies.

This vignette introduces the core concepts and shows how to get started
with the mediationverse ecosystem.

## Installation

Install the mediationverse meta-package from GitHub:

``` r
# Install with pak (recommended)
pak::pak("data-wise/mediationverse")

# Or with remotes
remotes::install_github("data-wise/mediationverse")
```

This will install all core packages:

- **medfit** - Infrastructure (S7 classes, model fitting, extraction,
  bootstrap)
- **probmed** - Probabilistic effect size (P_med)
- **RMediation** - Confidence intervals (Distribution of Product, MBCO)
- **medrobust** - Sensitivity analysis (bounds, falsification)
- **medsim** - Simulation infrastructure

## Loading the Ecosystem

Load all packages with a single command:

``` r
library(mediationverse)
```

This attaches all core packages and displays a summary:

    -- Attaching packages ------------------- mediationverse 0.0.0.9000 --
    v medfit     0.1.0     v probmed    0.1.0
    v RMediation 1.4.0     v medrobust  0.1.0
    v medsim     0.1.0
    ---------------------------------------------------------------

## Package Management

The mediationverse provides utility functions to manage the ecosystem:

### Check Installed Versions

``` r
# List all mediationverse packages with versions and status
mediationverse_packages()
```

### Update Packages

``` r
# Update all packages from GitHub/CRAN
mediationverse_update()
```

### Check for Conflicts

``` r
# Show function name conflicts between packages
mediationverse_conflicts()
```

## Core Workflow

The mediationverse follows a consistent workflow for mediation analysis:

### 1. Fit Models

Using `medfit`, fit your mediator and outcome models:

``` r
# Fit models
fit_m <- lm(M ~ X + C, data = mydata)
fit_y <- lm(Y ~ X + M + C, data = mydata)
```

### 2. Extract Mediation Structure

Extract path coefficients and covariance matrix:

``` r
med_data <- extract_mediation(
  fit_m,
  model_y = fit_y,
  treatment = "X",
  mediator = "M"
)

# View the extracted structure
print(med_data)
```

### 3. Choose Your Analysis

Once you have a `MediationData` object, you can use any of the ecosystem
packages:

#### Confidence Intervals (RMediation)

``` r
# Distribution of Product method
ci_dop <- ci(med_data, type = "dop")

# Monte Carlo method
ci_mc <- ci(med_data, type = "MC", n.mc = 10000)
```

#### Probabilistic Effect Size (probmed)

``` r
# Compute P_med
pmed_result <- compute_pmed(med_data)
```

#### Sensitivity Analysis (medrobust)

``` r
# Bounds for unmeasured confounding
bounds <- sensitivity_bounds(med_data)
```

#### Bootstrap Inference (medfit)

``` r
# Nonparametric bootstrap
boot_result <- bootstrap_mediation(med_data, n_boot = 2000)
```

## Ecosystem Design

The mediationverse follows several design principles:

### Foundation Package

**medfit** serves as the foundation, providing:

- S7 classes (`MediationData`, `SerialMediationData`, `BootstrapResult`)
- Model extraction methods
- Bootstrap infrastructure
- Common utilities

### Specialized Packages

Each package focuses on one methodological contribution:

| Package    | Focus                | Key Functions               |
|------------|----------------------|-----------------------------|
| probmed    | Effect sizes         | `compute_pmed()`, `pmed()`  |
| RMediation | Confidence intervals | `ci()`, `medci()`, `mbco()` |
| medrobust  | Sensitivity          | `sensitivity_bounds()`      |
| medsim     | Simulation           | `run_simulation()`          |

### Type Safety

All packages use S7 classes for type safety and validation:

``` r
# MediationData validates input
med_data <- MediationData(
  a_path = 0.5,
  b_path = 0.4,
  c_prime = 0.1,
  estimates = c(a = 0.5, b = 0.4, c_prime = 0.1),
  vcov = matrix(c(0.01, 0, 0, 0, 0.01, 0, 0, 0, 0.01), 3, 3)
)
```

## Next Steps

- Read the [mediationverse
  Workflow](https://data-wise.github.io/mediationverse/articles/mediationverse-workflow.md)
  article for a complete analysis example
- Explore individual package documentation:
  - [medfit](https://data-wise.github.io/medfit/)
  - [probmed](https://data-wise.github.io/probmed/)
  - [RMediation](https://data-wise.github.io/rmediation/)
  - [medrobust](https://data-wise.github.io/medrobust/)
  - [medsim](https://data-wise.github.io/medsim/)

## Session Info

``` r
sessionInfo()
```

    R version 4.5.2 (2025-10-31)
    Platform: x86_64-pc-linux-gnu
    Running under: Ubuntu 24.04.3 LTS

    Matrix products: default
    BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3
    LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0

    locale:
     [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8
     [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8
     [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C
    [10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C

    time zone: UTC
    tzcode source: system (glibc)

    attached base packages:
    [1] stats     graphics  grDevices utils     datasets  methods   base

    loaded via a namespace (and not attached):
     [1] compiler_4.5.2  fastmap_1.2.0   cli_3.6.5       tools_4.5.2
     [5] htmltools_0.5.9 yaml_2.3.11     rmarkdown_2.30  knitr_1.50
     [9] jsonlite_2.0.0  xfun_0.54       digest_0.6.39   rlang_1.1.6
    [13] evaluate_1.0.5 
