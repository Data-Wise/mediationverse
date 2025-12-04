# mediationverse

> Unified ecosystem for mediation analysis in R

## Overview

The **mediationverse** is a collection of R packages for mediation
analysis, providing a unified ecosystem for:

- Model fitting and extraction
- Effect size computation
- Confidence interval estimation
- Sensitivity analysis
- Simulation studies

## Packages

The mediationverse includes five core packages:

| Package        | Purpose                                          | Status                | Links                                                 |
|----------------|--------------------------------------------------|-----------------------|-------------------------------------------------------|
| **medfit**     | Infrastructure (S7 classes, fitting, extraction) | In Development        | [GitHub](https://github.com/data-wise/medfit)         |
| **probmed**    | Probabilistic effect size (P_med)                | Ready for Integration | [GitHub](https://github.com/data-wise/probmed)        |
| **RMediation** | Confidence intervals (DOP, MBCO)                 | On CRAN               | [CRAN](https://cran.r-project.org/package=RMediation) |
| **medrobust**  | Sensitivity analysis                             | In Development        | [GitHub](https://github.com/data-wise/medrobust)      |
| **medsim**     | Simulation infrastructure                        | On GitHub             | [GitHub](https://github.com/data-wise/medsim)         |

## Installation

Install from GitHub (development version):

``` r
# Install mediationverse (loads all packages)
pak::pak("data-wise/mediationverse")

# Or install packages individually
pak::pak("data-wise/medfit")
pak::pak("data-wise/probmed")
pak::pak("data-wise/medrobust")
pak::pak("data-wise/medsim")

# RMediation from CRAN
install.packages("RMediation")
```

## Usage

Load all packages with one command:

``` r
library(mediationverse)
#> -- Attaching packages ------------------ mediationverse 0.0.0.9000 --
#> v medfit     0.1.0     v probmed    0.1.0
#> v RMediation 1.4.0     v medrobust  0.1.0
#> v medsim     0.1.0
#> ---------------------------------------------------------------
```

### Package Management

``` r
# List installed packages and versions
mediationverse_packages()

# Update all packages
mediationverse_update()

# Check for function conflicts
mediationverse_conflicts()
```

## Example Workflow

``` r
library(mediationverse)

# Fit mediation models (medfit)
fit_m <- lm(M ~ X + C, data = mydata)
fit_y <- lm(Y ~ X + M + C, data = mydata)

# Extract mediation structure
med_data <- extract_mediation(fit_m, model_y = fit_y,
                               treatment = "X", mediator = "M")

# Bootstrap inference (medfit)
boot_result <- bootstrap_mediation(med_data, n_boot = 2000)

# Compute probabilistic effect size (probmed)
pmed_result <- compute_pmed(med_data)

# Get confidence intervals (RMediation)
ci_result <- ci(med_data, type = "dop")

# Sensitivity analysis (medrobust)
robust_result <- sensitivity_analysis(med_data)
```

## Design Philosophy

The mediationverse follows these principles:

1.  **Foundation Package**: medfit provides shared S7 infrastructure
2.  **Specialized Packages**: Each package focuses on one methodological
    contribution
3.  **Consistent API**: Unified interfaces across all packages
4.  **Type Safety**: S7 classes ensure data integrity
5.  **Comprehensive Testing**: \>90% code coverage across packages

## Ecosystem

Part of the **mediationverse** ecosystem for causal mediation analysis:

| Package                                                     | Role                 | Description                                         |
|-------------------------------------------------------------|----------------------|-----------------------------------------------------|
| [medfit](https://data-wise.github.io/medfit/)               | Foundation           | S7 classes, model fitting, extraction, bootstrap    |
| [probmed](https://data-wise.github.io/probmed/)             | Effect Size          | Probabilistic effect size (P_med)                   |
| [RMediation](https://cran.r-project.org/package=RMediation) | Confidence Intervals | Distribution of Product, MBCO methods               |
| [medrobust](https://data-wise.github.io/medrobust/)         | Sensitivity          | Bounds and falsification for unmeasured confounding |
| [medsim](https://data-wise.github.io/medsim/)               | Simulation           | Standardized simulation infrastructure              |

## Development Status

**Current Phase**: Ecosystem development (Q4 2024 - Q1 2025)

medfit Phase 3 complete (S7 classes, extraction)

medsim core implementation complete

mediationverse meta-package skeleton

medfit Phase 4 (model fitting)

Package integrations

CRAN submissions

## Inspiration

This ecosystem is inspired by successful R package ecosystems:

- [tidyverse](https://www.tidyverse.org/) - Cohesive data science
  packages
- [easystats](https://easystats.github.io/easystats/) - Statistical
  modeling ecosystem
- [mlr3](https://mlr3.mlr-org.com/) - Machine learning framework

## Contributing

The mediationverse is in active development. Contributions are welcome!

- Report issues: [GitHub
  Issues](https://github.com/data-wise/mediationverse/issues)
- Suggest features: Open a discussion on GitHub
- Contribute code: Submit pull requests

## Citation

If you use packages from the mediationverse in your research, please
cite the individual packages:

    Tofighi, D. (2025). medfit: Infrastructure for mediation analysis in R.
    R package version 0.1.0. https://github.com/data-wise/medfit

*(Additional citations will be added as packages are released)*

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
