# Situation Report for the mediationverse Ecosystem

Prints a summary of the installed mediationverse packages, their
versions, and installation sources. Inspired by
`tidyverse::tidyverse_sitrep()`.

## Usage

``` r
mediationverse_sitrep()
```

## Value

Invisibly returns a data frame with package status. Called for its side
effect of printing the situation report.

## Examples

``` r
mediationverse_sitrep()
#> 
#> ── mediationverse situation report ─────────────────────────────────────────────
#> R 4.6.0 | Platform x86_64-pc-linux-gnu
#> mediationverse 0.0.0.9000
#> ────────────────────────────────────────────────────────────────────────────────
#> 
#> ── Core packages ──
#> 
#> ✔ medfit 0.3.0 [CRAN]
#> ✔ probmed 0.2.0 [GitHub]
#> ✔ RMediation 1.5.0 [CRAN]
#> ✔ medrobust 0.4.0 [GitHub]
#> ✔ medsim 0.3.1 [GitHub]
#> ────────────────────────────────────────────────────────────────────────────────
#> 
#> ── CRAN status ──
#> 
#> • medfit 0.2.0+ - <https://cran.r-project.org/package=medfit>
#> • RMediation 1.5.0 - <https://cran.r-project.org/package=RMediation>
#> ℹ probmed, medrobust, medsim - GitHub only (pre-CRAN)
```
