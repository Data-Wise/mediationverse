# mediationverse: Ecosystem for Mediation Analysis in R

The mediationverse is a collection of R packages for mediation analysis.
This meta-package loads all core packages with a single
[`library()`](https://rdrr.io/r/base/library.html) command.

## Details

### Core Packages

The mediationverse includes the following packages:

- **medfit**: Infrastructure for model fitting, extraction, and
  bootstrap inference

- **probmed**: Probabilistic effect size (P_med)

- **RMediation**: Confidence intervals (DOP, MBCO, MC methods)

- **medrobust**: Sensitivity analysis for unmeasured confounding

- **medsim**: Simulation infrastructure for mediation research

### Installation

Install all packages at once:

    install.packages("mediationverse")

Or install development versions from GitHub:

    pak::pak("data-wise/mediationverse")

### Usage

Load all packages:

    library(mediationverse)

Check installed packages:

    mediationverse_packages()

Update all packages:

    mediationverse_update()

### Learn More

- medfit: <https://data-wise.github.io/medfit/>

- probmed: <https://data-wise.github.io/probmed/>

- RMediation: <https://cran.r-project.org/package=RMediation>

- medrobust: <https://data-wise.github.io/medrobust/>

- medsim: <https://data-wise.github.io/medsim/>

## See also

Useful links:

- <https://github.com/data-wise/mediationverse>

- <https://data-wise.github.io/mediationverse/>

- Report bugs at <https://github.com/data-wise/mediationverse/issues>

## Author

**Maintainer**: Davood Tofighi <dtofighi@gmail.com>
([ORCID](https://orcid.org/0000-0001-8523-7776))
