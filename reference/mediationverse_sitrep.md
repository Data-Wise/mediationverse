# Situation Report for the mediationverse Ecosystem

Prints a summary of the installed mediationverse packages, their
versions, and installation sources. Inspired by
`tidyverse::tidyverse_sitrep()`.

## Usage

``` r
mediationverse_sitrep(checks = FALSE)
```

## Arguments

- checks:

  Logical. If `TRUE`, also run environment checks and print them after
  the report: installed members against the minimum versions the
  ecosystem requires (failing below it, e.g. medfit before 0.5.0),
  optional dependencies (OpenMx, needed for
  [`RMediation::mbco()`](https://data-wise.github.io/rmediation/reference/mbco.html)),
  and function conflicts among installed members. Default `FALSE` leaves
  the report unchanged apart from a one-line hint.

## Value

Invisibly returns a data frame with columns `package`, `installed`,
`version` and `source`. `source` is the *recommended* install source
(`"CRAN"` or `"GitHub"`) from the ecosystem registry; it is not detected
from the installed copy, so a package installed from elsewhere (for
example a CRAN `medfit` that predates the GitHub fixes) still shows its
recommended source. With `checks = TRUE` the checks are attached as the
`"checks"` attribute: a data frame with columns `check`, `status`
(`"pass"`, `"warn"` or `"fail"`), `message` and `fix`. Called mainly for
its side effect of printing the situation report.

## Examples

``` r
mediationverse_sitrep()
#> 
#> ── mediationverse situation report ─────────────────────────────────────────────
#> R 4.6.2 | Platform x86_64-pc-linux-gnu
#> mediationverse 0.2.0
#> ────────────────────────────────────────────────────────────────────────────────
#> 
#> ── Core packages ──
#> 
#> ✔ medfit 0.18.0 [recommended: GitHub]
#> ✔ probmed 0.4.1 [recommended: GitHub]
#> ✔ RMediation 1.6.1 [recommended: CRAN]
#> ✔ medrobust 0.4.4 [recommended: GitHub]
#> ✔ medsim 0.6.0 [recommended: GitHub]
#> ✖ missingmed (not installed) [recommended: GitHub]
#> Install: `pak::pak("Data-Wise/missingmed")`
#> ────────────────────────────────────────────────────────────────────────────────
#> 
#> ── CRAN status ──
#> 
#> • RMediation 1.6.1 - <https://cran.r-project.org/package=RMediation>
#> ℹ medfit - install from GitHub; CRAN has 0.3.2, which predates two
#>   result-changing fixes in 0.5.0
#> ℹ probmed, medrobust, medsim, missingmed - GitHub only (pre-CRAN)
#> Run `mediationverse_sitrep(checks = TRUE)` for dependency checks.
mediationverse_sitrep(checks = TRUE)
#> 
#> ── mediationverse situation report ─────────────────────────────────────────────
#> R 4.6.2 | Platform x86_64-pc-linux-gnu
#> mediationverse 0.2.0
#> ────────────────────────────────────────────────────────────────────────────────
#> 
#> ── Core packages ──
#> 
#> ✔ medfit 0.18.0 [recommended: GitHub]
#> ✔ probmed 0.4.1 [recommended: GitHub]
#> ✔ RMediation 1.6.1 [recommended: CRAN]
#> ✔ medrobust 0.4.4 [recommended: GitHub]
#> ✔ medsim 0.6.0 [recommended: GitHub]
#> ✖ missingmed (not installed) [recommended: GitHub]
#> Install: `pak::pak("Data-Wise/missingmed")`
#> ────────────────────────────────────────────────────────────────────────────────
#> 
#> ── CRAN status ──
#> 
#> • RMediation 1.6.1 - <https://cran.r-project.org/package=RMediation>
#> ℹ medfit - install from GitHub; CRAN has 0.3.2, which predates two
#>   result-changing fixes in 0.5.0
#> ℹ probmed, medrobust, medsim, missingmed - GitHub only (pre-CRAN)
#> ────────────────────────────────────────────────────────────────────────────────
#> 
#> ── Checks ──
#> 
#> ✔ All installed members can be loaded
#> ✔ medfit 0.18.0 meets the minimum 0.5.0
#> ✔ RMediation 1.6.1 meets the minimum 1.5.0
#> ! OpenMx is not installed; RMediation::mbco() will not work
#> Fix: install.packages("OpenMx")
#> ! 1 function exported by more than one member: extract_mediation
#> Fix: Call the version you want with package::function()
```
