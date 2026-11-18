# A First Analysis in Four Calls

## Overview

mediationverse does not define its own `mediate()` function. The entry
point already exists upstream:
[`medfit::med()`](https://data-wise.github.io/medfit/reference/med.html)
takes a data frame and three variable names and returns a fitted
mediation object. The other packages then work on that same object.

This article runs one complete analysis in four calls:

1.  Simulate data (or bring your own).
2.  Fit the model with
    [`medfit::med()`](https://data-wise.github.io/medfit/reference/med.html).
3.  Get a confidence interval for the indirect effect with `RMediation`.
4.  Get the effect size P_(med) with `probmed`.

`medfit` is attached with
[`library(mediationverse)`](https://Data-Wise.github.io/mediationverse/);
the code below calls it with `medfit::` so it runs the same either way.
`RMediation` and `probmed` are optional, so each of their calls is
guarded and is skipped when the package is not installed.

## Call 1: data

A binary treatment `A`, a mediator `M`, an outcome `Y` and one covariate
`C`. The true indirect effect is 0.5 x 0.4 = 0.2.

``` r

set.seed(1)
n <- 300
A <- rbinom(n, 1, 0.5)
C <- rnorm(n)
M <- 0.5 * A + 0.3 * C + rnorm(n)
Y <- 0.4 * M + 0.2 * A + 0.1 * C + rnorm(n)
dat <- data.frame(A, M, Y, C)
```

## Call 2: fit

``` r

fit <- medfit::med(
  dat,
  treatment = "A",
  mediator = "M",
  outcome = "Y",
  covariates = "C"
)
fit
```

    MediationData object
    ====================

    Path coefficients:
      a (X -> M):        0.4755
      b (M -> Y|X):      0.4355
      c' (X -> Y|M):     0.2472
      Indirect (a*b):    0.2071

    Variables:
      Treatment: A
      Mediator:  M
      Outcome:   Y

    Model info:
      N observations: 300
      Converged:      Yes
      Source:         stats::glm

    Residual SDs:
      Mediator model:   1.0879
      Outcome model:    1.0485

Extractors return single effects: `medfit::nie(fit)` (natural indirect),
`medfit::nde(fit)` (natural direct), `medfit::te(fit)` (total) and
`medfit::pm(fit)` (proportion mediated). For bootstrap inference add
`boot = TRUE, n_boot = 1000, seed = 123` to the call.

## Call 3: confidence interval for the indirect effect

[`RMediation::ci_mediation_data()`](https://data-wise.github.io/rmediation/reference/ci_mediation_data.html)
accepts the fitted object directly and uses the distribution of the
product by default.

``` r

if (requireNamespace("RMediation", quietly = TRUE)) {
  RMediation::ci_mediation_data(fit, level = 0.95)
}
```

    $CI
    [1] 0.09453522 0.33518940

    $Estimate
    [1] 0.2070642

    $SE
    [1] 0.06140013

## Call 4: effect size

[`probmed::pmed()`](https://data-wise.github.io/probmed/reference/pmed.html)
also accepts the fitted object. P_(med) is the probability that the
mediator shift leaves a random individual better off.

``` r

if (requireNamespace("probmed", quietly = TRUE)) {
  set.seed(2)
  probmed::pmed(fit)
}
```


    P_med: Probability of Mediated Shift
    ====================================

    Estimate: 0.55
    95% CI: [ 0.519 ,  0.58 ]

    Indirect Effect (Product of Coefficients):
    Estimate: 0.205
    95% CI: [ 0.0898 ,  0.33 ]

    Inference: parametric_bootstrap
    Bootstrap samples: 1000

    Treatment contrast: X = 1 vs. X* = 0

    Interpretation:
      P(Y(1, M(1)) > Y(1, M(0))) = 0.55
      P that the mediator shift (M(0) -> M(1)) leaves a random individual better off, holding X = 1.

## Where to go next

- [`mediationverse_sitrep()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_sitrep.md)
  shows which of these packages are installed and current;
  [`mediationverse_news()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_news.md)
  shows what changed in each.
- [`vignette("mediationverse-workflow")`](https://Data-Wise.github.io/mediationverse/articles/mediationverse-workflow.md)
  extends this to sensitivity analysis and simulation.
- Assumptions (sequential ignorability, positivity, consistency) still
  apply; none of the four calls checks them.
