# Complete Mediation Analysis Workflow

## Overview

This vignette demonstrates a complete mediation analysis workflow using
all packages in the mediationverse ecosystem. We will:

1.  Simulate data with known ground truth
2.  Fit mediation models
3.  Extract mediation structure
4.  Compute confidence intervals
5.  Calculate effect sizes
6.  Perform sensitivity analysis
7.  Bootstrap inference

## Setup

The mediationverse uses **selective loading**: only `medfit`
(foundation) is loaded by default. We’ll load additional packages as
needed throughout the workflow.

``` r

# Load foundation package
library(mediationverse)  # Loads medfit automatically

# Load packages for this workflow
library(medsim)       # For data simulation
library(probmed)      # For P_med effect size
library(RMediation)   # For confidence intervals
library(medrobust)    # For sensitivity analysis

# Set seed for reproducibility
set.seed(2025)
```

## Step 1: Simulate Data

Using `medsim` (already loaded), we generate data with known population
parameters:

``` r

# Population parameters
a_true <- 0.5 # X -> M effect
b_true <- 0.4 # M -> Y effect
c_prime_true <- 0.2 # X -> Y direct effect

# True indirect effect
indirect_true <- a_true * b_true
cat("True indirect effect:", indirect_true, "\n")

# Define a data-generating scenario with medsim, then draw one dataset.
# medsim_scenario() wraps a data_generator(n) returning columns X, M, Y.
scenario <- medsim_scenario(
  name = "Workflow demo",
  description = "Single mediator, a = 0.5, b = 0.4, c' = 0.2",
  data_generator = function(n = 200) {
    X <- rnorm(n)
    M <- a_true * X + rnorm(n, sd = 1)
    Y <- b_true * M + c_prime_true * X + rnorm(n, sd = 1)
    data.frame(X = X, M = M, Y = Y)
  },
  params = list(a = a_true, b = b_true, indirect = indirect_true)
)

# Generate one dataset from the scenario
sim_data <- scenario$data_generator(n = 200)

head(sim_data)
```

## Step 2: Fit Mediation Models

Fit the mediator and outcome models using standard regression:

``` r

# Mediator model: M ~ X
fit_m <- lm(M ~ X, data = sim_data)

# Outcome model: Y ~ X + M
fit_y <- lm(Y ~ X + M, data = sim_data)

# View summaries
summary(fit_m)
summary(fit_y)
```

## Step 3: Extract Mediation Structure

Using `medfit`, extract the mediation paths into a standardized object:

``` r

med_data <- extract_mediation(
  fit_m,
  model_y = fit_y,
  treatment = "X",
  mediator = "M"
)

# View the extracted structure
print(med_data)

# Access individual paths
cat("Estimated a path:", med_data@a_path, "\n")
cat("Estimated b path:", med_data@b_path, "\n")
cat("Estimated c' path:", med_data@c_prime, "\n")
cat("Estimated indirect effect:", med_data@a_path * med_data@b_path, "\n")
```

## Step 4: Confidence Intervals (RMediation)

Use `RMediation` (already loaded) to compute confidence intervals for
the indirect effect:

### Distribution of Product Method

The most accurate method for normal theory CIs:

``` r

ci_dop <- ci(med_data, type = "dop", level = 0.95)
print(ci_dop)
```

### Monte Carlo Method

Simulation-based CIs that work for any distribution:

``` r

ci_mc <- ci(med_data, type = "MC", n.mc = 10000, level = 0.95)
print(ci_mc)
```

### Compare Methods

``` r

# Create comparison table
ci_comparison <- data.frame(
  Method = c("DOP", "Monte Carlo"),
  Lower = c(ci_dop$CI[1], ci_mc$CI[1]),
  Upper = c(ci_dop$CI[2], ci_mc$CI[2]),
  Width = c(diff(ci_dop$CI), diff(ci_mc$CI))
)

print(ci_comparison)
```

## Step 5: Probabilistic Effect Size (probmed)

Compute P_med (using `probmed` already loaded), the probability of a
positive indirect effect:

``` r

pmed_result <- pmed(med_data)
print(pmed_result)

# P_med interpretation:
# - 0.5 = no evidence of effect (coin flip)
# - > 0.8 = strong evidence of positive effect
# - < 0.2 = strong evidence of negative effect
```

## Step 6: Sensitivity Analysis (medrobust)

Assess robustness to unmeasured confounding (using `medrobust` already
loaded):

``` r

# medrobust derives partial-identification bounds for the natural effects when a
# variable is subject to differential misclassification. It needs the raw data,
# the (mis)measured variable, and a sensitivity region of sensitivity/specificity
# ranges. Here we generate a dataset with a misclassified exposure for illustration.
sim_dm <- simulate_dm_data(
  n = 500,
  true_params = list(beta_AM = 0.405, theta_AY = 0.405, theta_MY = 0.405),
  dm_params = list(sn0 = 0.85, sp0 = 0.85, psi_sn = 1.5, psi_sp = 1.0),
  misclass_type = "exposure",
  seed = 12345
)

# Compute sensitivity bounds over the misclassification region
sens_bounds <- bound_ne(
  data = sim_dm@observed,
  exposure = "A_star",
  mediator = "M",
  outcome = "Y",
  confounders = "C1",
  misclassified_variable = "exposure",
  sensitivity_region = list(
    sn0_range = c(0.80, 0.90),
    sp0_range = c(0.80, 0.90),
    psi_sn_range = c(1.0, 2.0),
    psi_sp_range = c(1.0, 1.0)
  ),
  n_grid = 10
)

print(sens_bounds)

# Falsification test: which regions of the sensitivity space are ruled out by
# the data. falsification_summary() consumes the bounds object from bound_ne().
falsification <- falsification_summary(sens_bounds)
print(falsification)
```

## Step 7: Bootstrap Inference (medfit)

Perform bootstrap inference for the indirect effect:

``` r

# Nonparametric bootstrap
boot_result <- bootstrap_mediation(
  med_data,
  n_boot = 2000,
  method = "nonparametric",
  ci_level = 0.95
)

print(boot_result)

# Access bootstrap distribution
hist(boot_result@boot_estimates,
  main = "Bootstrap Distribution of Indirect Effect",
  xlab = "Indirect Effect (a * b)",
  col = "steelblue",
  border = "white"
)
abline(v = indirect_true, col = "red", lwd = 2, lty = 2)
abline(v = boot_result@estimate, col = "blue", lwd = 2)
legend("topright",
  legend = c("True value", "Estimate"),
  col = c("red", "blue"),
  lwd = 2,
  lty = c(2, 1)
)
```

## Complete Results Summary

``` r

# Compile all results
results <- list(
  # Point estimates
  estimates = list(
    a = med_data@a_path,
    b = med_data@b_path,
    indirect = med_data@a_path * med_data@b_path,
    direct = med_data@c_prime
  ),

  # Confidence intervals
  ci_dop = ci_dop$CI,
  ci_mc = ci_mc$CI,
  ci_boot = c(boot_result@ci_lower, boot_result@ci_upper),

  # Effect size
  pmed = pmed_result@estimate,

  # Sensitivity
  sensitivity = sens_bounds
)

# Pretty print
cat("=== Mediation Analysis Results ===\n\n")
cat("Point Estimates:\n")
cat("  a path (X -> M):", round(results$estimates$a, 3), "\n")
cat("  b path (M -> Y):", round(results$estimates$b, 3), "\n")
cat("  c' path (X -> Y):", round(results$estimates$direct, 3), "\n")
cat("  Indirect effect:", round(results$estimates$indirect, 3), "\n\n")

cat("95% Confidence Intervals for Indirect Effect:\n")
cat("  DOP:", round(results$ci_dop, 3), "\n")
cat("  Monte Carlo:", round(results$ci_mc, 3), "\n")
cat("  Bootstrap:", round(results$ci_boot, 3), "\n\n")

cat("Effect Size:\n")
cat("  P_med:", round(results$pmed, 3), "\n\n")
```

## Interpretation

Based on our analysis:

1.  **Point Estimate**: The indirect effect estimate should be close to
    the true value of 0.20.

2.  **Confidence Intervals**: All three methods (DOP, Monte Carlo,
    Bootstrap) provide similar intervals, suggesting robust inference.

3.  **Effect Size**: P_med \> 0.8 indicates strong evidence that the
    indirect effect is positive.

4.  **Sensitivity**: The effect remains significant across reasonable
    levels of unmeasured confounding.

## Using SEM with lavaan

The mediationverse also supports structural equation models:

``` r

library(lavaan)

# Specify mediation model
model <- "
  # Regressions
  M ~ a*X
  Y ~ b*M + c*X

  # Indirect effect
  indirect := a*b
"

# Fit model
fit_lavaan <- sem(model, data = sim_data)

# Extract mediation structure
med_data_lavaan <- extract_mediation(fit_lavaan)

# Use same analysis pipeline
ci_lavaan <- ci(med_data_lavaan, type = "dop")
print(ci_lavaan)
```

## Session Information

``` r

sessionInfo()
```

    R version 4.6.1 (2026-06-24)
    Platform: x86_64-pc-linux-gnu
    Running under: Ubuntu 24.04.4 LTS

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
     [1] compiler_4.6.1  fastmap_1.2.0   cli_3.6.6       tools_4.6.1
     [5] htmltools_0.5.9 otel_0.2.0      yaml_2.3.12     rmarkdown_2.31
     [9] knitr_1.51      jsonlite_2.0.0  xfun_0.59       digest_0.6.39
    [13] rlang_1.2.0     evaluate_1.0.5 

## References

- MacKinnon, D. P. (2008). Introduction to Statistical Mediation
  Analysis. New York: Lawrence Erlbaum.

- Tofighi, D., & MacKinnon, D. P. (2011). RMediation: An R package for
  mediation analysis confidence intervals. Behavior Research Methods,
  43, 692-700.

- VanderWeele, T. J. (2015). Explanation in Causal Inference: Methods
  for Mediation and Interaction. Oxford University Press.
