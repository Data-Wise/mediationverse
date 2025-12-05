# mediationverse Package Development

## Project Overview

mediationverse is a comprehensive R package ecosystem for causal
mediation analysis. Core principles: - **Unified interface**: Consistent
API across different mediation methods - **Modern R**: S7 object system,
tidyverse-compatible - **Rigorous methods**: Implement state-of-art
causal inference techniques - **Pedagogical**: Clear documentation for
applied researchers

## Essential Commands

### Development Workflow

``` r
devtools::load_all()           # Load package during development (Cmd+Shift+L in RStudio)
devtools::test()               # Run test suite (Cmd+Shift+T)
devtools::check()              # R CMD check (Cmd+Shift+E)
devtools::document()           # Update docs from roxygen2 (Cmd+Shift+D)
devtools::build()              # Build package tarball
```

### Testing & Coverage

``` r
devtools::test_active_file()   # Test current file only
testthat::test_file("tests/testthat/test-mediation.R")
covr::package_coverage()       # Must maintain >80% coverage
covr::report()                 # View coverage report in browser
```

### Code Quality

``` r
styler::style_pkg()            # Auto-format to tidyverse style
lintr::lint_package()          # Static code analysis
spelling::spell_check_package() # Check spelling in docs
goodpractice::gp()             # Comprehensive package checks
```

### Documentation

``` r
pkgdown::build_site()          # Build package website
pkgdown::build_reference()     # Just rebuild function reference
usethis::use_vignette("name")  # Create new vignette
```

## R Code Standards

### Package Structure Requirements

- **NEVER** use [`library()`](https://rdrr.io/r/base/library.html) or
  [`require()`](https://rdrr.io/r/base/library.html) inside package code
- **ALWAYS** use `::` notation for external functions (e.g.,
  [`dplyr::mutate()`](https://dplyr.tidyverse.org/reference/mutate.html))
- **ALWAYS** use `@importFrom` or `@import` in roxygen2 for dependencies
- All dependencies must be in DESCRIPTION file (Imports or Suggests)

### S7 Object System Guidelines

#### Class Definitions

``` r
# GOOD - Complete S7 class with validator
MediationResult <- new_class(
  name = "MediationResult",
  properties = list(
    direct_effect = class_double,
    indirect_effect = class_double,
    total_effect = class_double,
    standard_errors = class_double,
    confidence_intervals = class_matrix
  ),
  validator = function(self) {
    # CRITICAL: Always include validators
    if (length(self@standard_errors) == 0) {
      return("Standard errors cannot be empty")
    }
    if (any(self@standard_errors < 0)) {
      return("Standard errors must be non-negative")
    }
    if (!all(is.finite(c(self@direct_effect, self@indirect_effect)))) {
      return("Effects must be finite")
    }
  }
)

# BAD - Missing validator
BadClass <- new_class(
  name = "BadClass",
  properties = list(x = class_double)
  # Missing validator!
)
```

#### Method Definitions

``` r
# GOOD - Proper generic and method
method(print, MediationResult) <- function(x, ...) {
  cat("Mediation Analysis Results\n")
  cat("Direct Effect:", format(x@direct_effect, digits = 3), "\n")
  cat("Indirect Effect:", format(x@indirect_effect, digits = 3), "\n")
}

# BAD - Using old S3 style in S7 package
print.MediationResult <- function(x, ...) { }  # Don't do this!
```

### Function Documentation (roxygen2)

EVERY exported function MUST include:

``` r
#' @title Brief one-line description
#' @description Longer description with statistical details
#' @param outcome Character. Name of outcome variable
#' @param mediator Character. Name of mediator variable
#' @param treatment Character. Name of treatment variable
#' @param data Data frame containing all variables
#' @return S7 object of class MediationResult containing:
#'   \item{direct_effect}{Natural direct effect estimate}
#'   \item{indirect_effect}{Natural indirect effect estimate}
#'   \item{standard_errors}{Bootstrap standard errors}
#' @examples
#' \dontrun{
#'   # Simulate data
#'   set.seed(123)
#'   n <- 500
#'   data <- simulate_mediation_data(n = n)
#'   
#'   # Fit mediation model
#'   fit <- mediate(
#'     outcome = "Y",
#'     mediator = "M", 
#'     treatment = "A",
#'     data = data
#'   )
#'   print(fit)
#' }
#' @references 
#' VanderWeele, T. J. (2015). Explanation in Causal Inference: Methods for 
#' Mediation and Interaction. Oxford University Press.
#' @export
```

### Code Style (tidyverse)

``` r
# GOOD
calculate_natural_effects <- function(outcome, mediator, treatment, 
                                      data, confounders = NULL) {
  # Input validation
  stopifnot(
    is.character(outcome), length(outcome) == 1,
    is.character(mediator), length(mediator) == 1,
    is.data.frame(data)
  )
  
  # Clear variable names
  outcome_model <- fit_outcome_model(data, outcome, mediator, treatment)
  mediator_model <- fit_mediator_model(data, mediator, treatment)
  
  # Compute effects
  effects <- compute_effects(outcome_model, mediator_model)
  
  return(effects)
}

# BAD - Poor style
calcNatEff <- function(y,m,a,d,c=NULL) {  # Unclear names
  x=lm(d[,y]~d[,m]+d[,a])  # No spaces, unclear
  # No input validation
  return(x)
}
```

## Testing Standards

### Test Structure (testthat3)

``` r
# tests/testthat/test-mediation.R

test_that("mediate() handles continuous mediator correctly", {
  # Arrange
  set.seed(123)
  n <- 200
  data <- simulate_continuous_mediator(n)
  
  # Act
  result <- mediate(
    outcome = "Y",
    mediator = "M",
    treatment = "A", 
    data = data
  )
  
  # Assert
  expect_s7_class(result, "MediationResult")
  expect_true(is.finite(result@direct_effect))
  expect_true(is.finite(result@indirect_effect))
  expect_length(result@standard_errors, 2)
})

test_that("mediate() throws error with missing data", {
  data <- data.frame(Y = c(1, 2, NA), M = c(1, 2, 3), A = c(0, 1, 0))
  
  expect_error(
    mediate(outcome = "Y", mediator = "M", treatment = "A", data = data),
    "Missing values detected"
  )
})
```

### Critical Edge Cases to Test

**ALWAYS** test these scenarios: - Missing data (NA values) - Zero
variance in variables - Perfect collinearity - Singular covariance
matrices - Empty data frames - Single observation - Character vs factor
variables - Different treatment types (binary, continuous,
categorical) - Confounders with missing values - Interaction terms -
Non-standard variable names (spaces, special characters)

### Snapshot Testing

For complex output:

``` r
test_that("print method produces correct output", {
  result <- create_test_mediation_result()
  expect_snapshot(print(result))
})
```

## Statistical Requirements

### Identification Assumptions

EVERY mediation function MUST clearly document required assumptions: 1.
**Sequential ignorability**: No unmeasured confounding 2.
**Positivity**: All combinations of treatment/mediator have positive
probability 3. **Consistency**: Well-defined interventions 4.
**Cross-world independence** (for natural effects)

Include assumption checking functions where possible:

``` r
check_positivity(data, treatment, mediator)
assess_overlap(data, treatment, confounders)
```

### Effect Measures

Use standard notation from VanderWeele (2015): - **NDE**: Natural Direct
Effect - **NIE**: Natural Indirect Effect  
- **TE**: Total Effect (TE = NDE + NIE under rare outcome assumption) -
**PM**: Proportion Mediated

### Inference Methods

Support multiple inference approaches: - **Delta method**: Fast,
asymptotic - **Bootstrap**: Robust, computationally intensive - Use
`boot` package with `parallel = "multicore"` - Default B = 1000, allow
user to specify - **Monte Carlo**: For complex mediation models -
**Bayesian**: Via `brms` or `rstan` interfaces (future)

## Common Pitfalls to Avoid

### ❌ DON’T DO THIS

``` r
# Using library() in package code
my_function <- function(data) {
  library(dplyr)  # WRONG!
  data %>% mutate(x = 1)
}

# Modifying global options without reset
my_function <- function() {
  options(scipen = 999)  # Will affect user's R session!
  # ... code ...
}

# Using T/F instead of TRUE/FALSE
if (x == T) { }  # WRONG! T can be overwritten

# Partial matching in data frame subsetting
data[, "outcome"]  # Can be ambiguous
```

### ✅ DO THIS INSTEAD

``` r
# Use :: notation
my_function <- function(data) {
  dplyr::mutate(data, x = 1)
}

# Save and restore options
my_function <- function() {
  old_opts <- options(scipen = 999)
  on.exit(options(old_opts), add = TRUE)
  # ... code ...
}

# Use TRUE/FALSE
if (isTRUE(x)) { }

# Exact column matching
data[, "outcome", drop = FALSE]
```

## Git Workflow

### Branch Naming

- `feature/natural-effects-s7` - New features
- `fix/bootstrap-ci-bug` - Bug fixes
- `refactor/mediator-models` - Code refactoring
- `docs/vignette-sensitivity` - Documentation
- `test/edge-cases-missing-data` - Test additions

### Commit Messages

    feat: Add multiply robust mediation estimator

    - Implement doubly robust outcome regression
    - Add inverse probability weighting for mediator
    - Include 95% CIs via bootstrap (B=1000)
    - Add tests for continuous and binary mediators
    - Update vignette with new example

    Closes #42

### Never Commit

- `.Rproj.user/` - RStudio user files
- `.Rhistory` - Command history
- `.RData` - Workspace data
- `*.Rcheck/` - Check output
- Personal notes in `.Rmd` files

## Performance Considerations

### Vectorization

``` r
# GOOD - Vectorized
effects <- mean((Y1 - Y0) * weights)

# BAD - Slow loop
effects <- 0
for (i in seq_along(Y1)) {
  effects <- effects + (Y1[i] - Y0[i]) * weights[i]
}
effects <- effects / length(Y1)
```

### Large Datasets

- Use `data.table` for n \> 100,000
- Consider `collapse` package for grouped operations
- Profile with `profvis::profvis()`
- Use `bench::mark()` to compare implementations

### Bootstrap Parallelization

``` r
# Template for parallel bootstrap
bootstrap_ci <- function(data, B = 1000, parallel = TRUE) {
  ncores <- if (parallel) parallel::detectCores() - 1 else 1
  
  boot_results <- parallel::mclapply(
    seq_len(B),
    function(b) {
      boot_data <- data[sample(nrow(data), replace = TRUE), ]
      compute_effect(boot_data)
    },
    mc.cores = ncores
  )
  
  unlist(boot_results)
}
```

## Documentation Website (pkgdown)

### \_pkgdown.yml Structure

``` yaml
template:
  bootstrap: 5
  
reference:
  - title: "Main Functions"
    desc: "Core mediation analysis functions"
    contents:
      - mediate
      - mediate_bootstrap
      
  - title: "Effect Measures"
    contents:
      - natural_direct_effect
      - natural_indirect_effect
      
  - title: "Sensitivity Analysis"
    contents:
      - sensitivity_analysis
      - evalue_mediation
```

## When Working with Claude Code

### Explicitly State Goals

Instead of: “Fix the mediation function” Use: “The
natural_direct_effect() function gives incorrect CIs when using
bootstrap with B=1000. The issue appears to be in how we’re computing
the percentile intervals. Please review the bootstrap_ci() helper
function and fix the quantile calculation.”

### Request Verification

After changes: “Run the test suite and confirm all tests pass. Then run
a simple example to verify the bootstrap CIs look reasonable.”

### Use Iterative Development

1.  “Read the current mediate() function implementation”
2.  “Create a plan for adding multiply robust estimation without
    breaking existing functionality”
3.  “Implement the multiply robust estimator following our S7 class
    structure”
4.  “Write comprehensive tests including edge cases”
5.  “Update documentation with new parameter and examples”
6.  “Run R CMD check and fix any issues”

### Reference Key Files

“Look at how we implemented the bootstrap CI in `R/bootstrap.R` lines
45-67. Use that same pattern for the new sensitivity analysis function.”

## Quick Reference Links

- [S7 Documentation](https://rconsortium.github.io/S7/)
- [R Packages Book](https://r-pkgs.org/)
- [Tidyverse Style Guide](https://style.tidyverse.org/)
- [VanderWeele (2015)](https://doi.org/10.1093/aje/kwv034) - Mediation
  methods
- [RMediation Package](https://github.com/your-username/RMediation) -
  Our related work

## Common Commands Shortlist

``` bash
# Development cycle
R -e "devtools::load_all(); devtools::test(); devtools::check()"

# Before committing
R -e "styler::style_pkg(); lintr::lint_package(); spelling::spell_check_package()"

# Documentation
R -e "devtools::document(); pkgdown::build_site()"

# Coverage report
R -e "covr::report()"
```

------------------------------------------------------------------------

**Last Updated**: 2025-12-05 **Maintainer**: Update this file as
patterns emerge!
