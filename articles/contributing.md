# Contributing to mediationverse

## Contributing to mediationverse

Thank you for your interest in contributing to the mediationverse
ecosystem! This guide will help you get started.

### Ways to Contribute

#### 🐛 Report Bugs

Found a bug? Please [open an
issue](https://github.com/data-wise/mediationverse/issues/new) with:

- **Clear title**: Describe the problem concisely
- **Reproducible example**: Minimal code that demonstrates the bug
- **Expected behavior**: What should happen
- **Actual behavior**: What actually happens
- **Session info**: Output of
  [`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html)

**Example**:

``` r
# Bug report template
library(mediationverse)

# Minimal reproducible example
fit <- lm(M ~ X, data = mydata)
extract_mediation(fit)  # Error occurs here

# Session info
sessionInfo()
```

#### 💡 Suggest Features

Have an idea? [Start a
discussion](https://github.com/data-wise/mediationverse/discussions/new)
or open a feature request with:

- **Use case**: What problem does this solve?
- **Proposed solution**: How might it work?
- **Alternatives**: What else have you considered?
- **Related work**: Similar features in other packages?

#### 📖 Improve Documentation

Documentation improvements are always welcome:

- Fix typos or clarify wording
- Add examples to function documentation
- Write or improve vignettes
- Create blog posts or tutorials

#### 🔧 Contribute Code

Follow the workflow below for code contributions.

------------------------------------------------------------------------

### Development Workflow

#### 1. Setup

``` bash
# Fork the repository on GitHub
# Clone your fork
git clone https://github.com/YOUR-USERNAME/mediationverse.git
cd mediationverse

# Add upstream remote
git remote add upstream https://github.com/data-wise/mediationverse.git

# Install dependencies
Rscript -e 'remotes::install_deps(dependencies = TRUE)'
```

#### 2. Create a Branch

``` bash
# Fetch latest changes
git fetch upstream
git checkout dev
git merge upstream/dev

# Create feature branch
git checkout -b feature/your-feature-name
```

**Branch naming**: - `feature/description` - New features -
`fix/description` - Bug fixes - `docs/description` - Documentation -
`test/description` - Tests

#### 3. Make Changes

Follow our [coding standards](#coding-standards):

``` r
# Load package
devtools::load_all()

# Make your changes
# Write tests
# Update documentation

# Check package
devtools::check()
```

#### 4. Commit

Write clear commit messages:

``` bash
git add .
git commit -m "feat: add support for multiple mediators

- Implement SerialMediationData class
- Add extraction method for lavaan
- Update documentation with examples

Closes #123"
```

**Commit message format**: - `feat:` - New feature - `fix:` - Bug fix -
`docs:` - Documentation - `test:` - Tests - `refactor:` - Code
refactoring - `style:` - Code style (formatting) - `chore:` -
Maintenance

#### 5. Submit Pull Request

``` bash
# Push to your fork
git push origin feature/your-feature-name

# Open pull request on GitHub
# Target: dev branch (not main!)
```

**Pull request checklist**: - \[ \] Tests pass (`devtools::test()`) - \[
\] R CMD check passes (`devtools::check()`) - \[ \] Documentation
updated - \[ \] NEWS.md updated - \[ \] Code follows style guide - \[ \]
Commits are clear and atomic

------------------------------------------------------------------------

### Coding Standards

#### R Style

Follow the [tidyverse style guide](https://style.tidyverse.org/) with
these specifics:

**Naming**: - Functions: `snake_case()` (e.g., `extract_mediation()`) -
Variables: `snake_case` (e.g., `med_data`) - S7 Classes: `CamelCase`
(e.g., `MediationData`) - Private functions: `.snake_case()` (e.g.,
`.fit_mediation_glm()`)

**Code organization**:

``` r
# Function template
my_function <- function(x, y, method = "default") {
  # 1. Input validation
  checkmate::assert_numeric(x)
  checkmate::assert_character(method)
  checkmate::assert_choice(method, c("default", "alternative"))

  # 2. Main logic
  result <- compute_something(x, y)

  # 3. Return
  result
}
```

#### Documentation (roxygen2)

``` r
#' Extract Mediation Structure from Models
#'
#' @description
#' Extracts path coefficients and variance-covariance matrix from fitted
#' models for mediation analysis.
#'
#' @param object Fitted model object (lm, glm, lavaan)
#' @param treatment Character: name of treatment variable
#' @param mediator Character: name of mediator variable
#' @param ... Additional arguments passed to methods
#'
#' @return A [MediationData] object containing:
#' - `a_path`: Treatment → Mediator effect
#' - `b_path`: Mediator → Outcome effect
#' - `c_prime`: Direct effect
#' - `vcov`: Variance-covariance matrix
#'
#' @details
#' This function is a generic with methods for different model types.
#' See individual method documentation for details.
#'
#' @examples
#' \dontrun{
#' fit_m <- lm(M ~ X, data = mydata)
#' fit_y <- lm(Y ~ X + M, data = mydata)
#' med_data <- extract_mediation(fit_m, model_y = fit_y,
#'                               treatment = "X", mediator = "M")
#' }
#'
#' @seealso [MediationData], [fit_mediation()]
#' @export
extract_mediation <- S7::new_generic("extract_mediation", "object")
```

#### Testing

Write tests for all new functionality:

``` r
# tests/testthat/test-extraction.R
test_that("extract_mediation works for lm", {
  # Setup
  set.seed(123)
  data <- data.frame(X = rnorm(100), M = rnorm(100), Y = rnorm(100))
  fit_m <- lm(M ~ X, data = data)
  fit_y <- lm(Y ~ X + M, data = data)

  # Execute
  result <- extract_mediation(fit_m, model_y = fit_y,
                               treatment = "X", mediator = "M")

  # Verify
  expect_s3_class(result, "MediationData")
  expect_true(!is.na(result@a_path))
  expect_true(!is.na(result@b_path))
  expect_equal(nrow(result@vcov), 2)
})

test_that("extract_mediation validates inputs", {
  fit <- lm(Y ~ X, data = data.frame(X = 1:10, Y = 1:10))

  expect_error(extract_mediation(fit, treatment = "Z"),
               "treatment.*not found")
})
```

#### Package Structure

    mediationverse/
    ├── R/
    │   ├── aaa-imports.R      # Imports
    │   ├── package.R          # Package documentation
    │   ├── attach.R           # Attachment logic
    │   ├── conflicts.R        # Conflict detection
    │   └── update.R           # Update utilities
    ├── man/                   # Generated documentation
    ├── tests/
    │   └── testthat/          # Tests
    ├── vignettes/             # Long-form documentation
    ├── _pkgdown.yml           # Website configuration
    ├── DESCRIPTION            # Package metadata
    ├── NAMESPACE              # Generated namespace
    └── NEWS.md                # Changelog

------------------------------------------------------------------------

### Package-Specific Guidelines

#### medfit

- Focus on infrastructure, not effect sizes
- Maintain S7 class integrity
- Ensure backward compatibility
- Document breaking changes prominently

#### probmed

- Keep P_med computation separate from infrastructure
- Maintain formula interface
- Ensure backward compatibility with v0.1.0

#### RMediation

- Maintain CRAN stability
- Coordinate with medfit changes
- Keep DOP/MBCO methods intact

#### medrobust

- Focus on sensitivity analysis
- Keep bounds computation efficient
- Provide clear falsification output

#### medsim

- Maintain environment detection
- Keep parallel processing robust
- Ensure HPC compatibility

------------------------------------------------------------------------

### Code Review Process

All contributions go through code review:

1.  **Automated checks**: CI/CD runs R CMD check, tests, coverage
2.  **Maintainer review**: Code quality, design, documentation
3.  **Feedback**: Suggestions for improvement
4.  **Approval**: Once all checks pass and feedback addressed
5.  **Merge**: Into dev branch first, then main for releases

**Review criteria**: - Functionality: Does it work as intended? - Tests:
Are edge cases covered? - Documentation: Is it clear and complete? -
Style: Does it follow guidelines? - Performance: Is it efficient?

------------------------------------------------------------------------

### Release Process

Releases follow [semantic versioning](https://semver.org/):

- **Major** (x.0.0): Breaking changes
- **Minor** (0.x.0): New features, backward compatible
- **Patch** (0.0.x): Bug fixes

**Release workflow**: 1. Update NEWS.md 2. Bump version in DESCRIPTION
3. Run R CMD check 4. Create release branch 5. Tag release 6. Submit to
CRAN (if applicable) 7. Announce release

------------------------------------------------------------------------

### Communication

#### GitHub

- **Issues**: Bug reports, feature requests
- **Discussions**: Questions, ideas, announcements
- **Pull requests**: Code contributions

#### Email

For private inquiries: <dtofighi@gmail.com>

#### Community Guidelines

- Be respectful and inclusive
- Provide constructive feedback
- Help others learn
- Follow the [Code of
  Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html)

------------------------------------------------------------------------

### Recognition

Contributors are recognized in: - Package DESCRIPTION (Contributors
field) - NEWS.md (with GitHub handle) - README.md (significant
contributions) - Package website (Contributors page)

------------------------------------------------------------------------

### Resources

#### Documentation

- [R Packages book](https://r-pkgs.org/)
- [tidyverse style guide](https://style.tidyverse.org/)
- [S7 package documentation](https://rconsortium.github.io/S7/)

#### Tools

- [devtools](https://devtools.r-lib.org/)
- [usethis](https://usethis.r-lib.org/)
- [testthat](https://testthat.r-lib.org/)
- [pkgdown](https://pkgdown.r-lib.org/)

#### Getting Help

- [R Package Development course](https://r-pkgs.org/)
- [RStudio Community](https://community.rstudio.com/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/r)

------------------------------------------------------------------------

### Thank You!

Your contributions help make mediation analysis more accessible to
researchers worldwide. Every contribution, no matter how small, is
valued and appreciated.

------------------------------------------------------------------------

**Questions?** Open a
[discussion](https://github.com/data-wise/mediationverse/discussions) or
email <dtofighi@gmail.com>
