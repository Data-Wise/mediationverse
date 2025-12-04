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
#' pak::pak("data-wise/mediationverse")
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

## usethis namespace: start
## usethis namespace: end
NULL
