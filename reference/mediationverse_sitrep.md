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
#> mediationverse 0.1.0
#> ────────────────────────────────────────────────────────────────────────────────
#> 
#> ── Core packages ──
#> 
#> ✔ medfit 0.3.0 [GitHub]
#> ✔ probmed 0.3.0 [GitHub]
#> ✔ RMediation 1.5.0 [CRAN]
#> ✔ medrobust 0.4.0 [GitHub]
#> ✔ medsim 0.3.1 [GitHub]
#> ────────────────────────────────────────────────────────────────────────────────
#> 
#> ── CRAN status ──
#> 
#> • RMediation 1.5.0 - <https://cran.r-project.org/package=RMediation>
#> ℹ medfit - install 0.3.x from GitHub; CRAN has 0.2.1, but the ecosystem needs
#>   >= 0.3.0
#> ℹ probmed, medrobust, medsim - GitHub only (pre-CRAN)
```
