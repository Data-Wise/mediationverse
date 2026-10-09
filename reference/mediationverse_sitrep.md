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
#> R 4.6.1 | Platform x86_64-pc-linux-gnu
#> mediationverse 0.1.0
#> ────────────────────────────────────────────────────────────────────────────────
#> 
#> ── Core packages ──
#> 
#> ✔ medfit 0.3.0 [GitHub]
#> ✔ probmed 0.3.0 [GitHub]
#> ✔ RMediation 1.6.1 [CRAN]
#> ✔ medrobust 0.4.4 [GitHub]
#> ✔ medsim 0.5.1 [GitHub]
#> ✖ missingmed (not installed) [GitHub]
#> Install: `pak::pak("Data-Wise/missingmed")`
#> ────────────────────────────────────────────────────────────────────────────────
#> 
#> ── CRAN status ──
#> 
#> • RMediation 1.6.1 - <https://cran.r-project.org/package=RMediation>
#> ℹ medfit - install from GitHub; CRAN has 0.3.2, which predates two
#>   result-changing fixes in 0.5.0
#> ℹ probmed, medrobust, medsim, missingmed - GitHub only (pre-CRAN)
```
