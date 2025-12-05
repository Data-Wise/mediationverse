#' mediationverse: Ecosystem for Mediation Analysis in R
#'
#' @description
#' The mediationverse is a collection of R packages for mediation analysis.
#' This meta-package loads all core packages with a single `library()` command.
#'
#' @details
#' ## Core Packages
#'
#' The mediationverse includes the following packages:
#'
#' - **medfit**: Infrastructure for model fitting, extraction, and bootstrap inference
#' - **probmed**: Probabilistic effect size (P_med)
#' - **RMediation**: Confidence intervals (DOP, MBCO, MC methods)
#' - **medrobust**: Sensitivity analysis for unmeasured confounding
#' - **medsim**: Simulation infrastructure for mediation research
#'
#' ## Installation
#'
#' Install all packages at once:
#' ```r
#' install.packages("mediationverse")
#' ```
#'
#' Or install development versions from GitHub:
#' ```r
#' pak::pak("Data-Wise/mediationverse")
#' ```
#'
#' ## Usage
#'
#' Load all packages:
#' ```r
#' library(mediationverse)
#' ```
#'
#' Check installed packages:
#' ```r
#' mediationverse_packages()
#' ```
#'
#' Update all packages:
#' ```r
#' mediationverse_update()
#' ```
#'
#' ## Learn More
#'
#' - medfit: \url{https://data-wise.github.io/medfit/}
#' - probmed: \url{https://data-wise.github.io/probmed/}
#' - RMediation: \url{https://cran.r-project.org/package=RMediation}
#' - medrobust: \url{https://data-wise.github.io/medrobust/}
#' - medsim: \url{https://data-wise.github.io/medsim/}
#'
#' @keywords internal
"_PACKAGE"

# Core packages are declared in Imports to ensure they're installed
# with mediationverse, but are attached via library() calls in .onAttach()
# rather than imported with :: or @importFrom. This is the standard
# meta-package pattern (see tidyverse). The R CMD check NOTE about
# "Namespaces in Imports field not imported from" is expected and harmless.

## usethis namespace: start
## usethis namespace: end
NULL
