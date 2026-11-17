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
`version`, `source` and `installed_from`. `installed_from` is detected
from the installed copy's `DESCRIPTION`: `"CRAN"`, `"GitHub"`,
`"r-universe"`, `"base"`, `"local"` (source or `load_all()` installs),
`"other"`, or `NA` (not installed or unreadable). `source` is the
*recommended* install source (`"CRAN"` or `"GitHub"`) from the ecosystem
registry; compare it with `installed_from` to see whether an install
matches. With `checks = TRUE` the checks are attached as the `"checks"`
attribute: a data frame with columns `check`, `status` (`"pass"`,
`"warn"` or `"fail"`), `message` and `fix`. Called mainly for its side
effect of printing the situation report.

## Examples

``` r
mediationverse_sitrep()
#> 
#> ── mediationverse situation report ─────────────────────────────────────────────
#> R 4.6.2 | Platform x86_64-pc-linux-gnu
#> mediationverse 0.2.0.9000
#> ────────────────────────────────────────────────────────────────────────────────
#> 
#> ── Core packages ──
#> 
#> ✔ medfit 0.18.0 (from GitHub) [recommended: GitHub]
#> ✔ probmed 0.4.1 (from GitHub) [recommended: GitHub]
#> ✔ RMediation 1.6.1 (from CRAN) [recommended: CRAN]
#> ✔ medrobust 0.4.4 (from GitHub) [recommended: GitHub]
#> ✔ medsim 0.6.0 (from GitHub) [recommended: GitHub]
#> ✖ missingmed (not installed) [recommended: GitHub]
#> Install: `pak::pak("Data-Wise/missingmed")`
#> ────────────────────────────────────────────────────────────────────────────────
#> 
#> ── Install sources ──
#> 
#> Installed members come from their recommended source.
#> Run `mediationverse_sitrep(checks = TRUE)` for dependency checks.
mediationverse_sitrep(checks = TRUE)
#> 
#> ── mediationverse situation report ─────────────────────────────────────────────
#> R 4.6.2 | Platform x86_64-pc-linux-gnu
#> mediationverse 0.2.0.9000
#> ────────────────────────────────────────────────────────────────────────────────
#> 
#> ── Core packages ──
#> 
#> ✔ medfit 0.18.0 (from GitHub) [recommended: GitHub]
#> ✔ probmed 0.4.1 (from GitHub) [recommended: GitHub]
#> ✔ RMediation 1.6.1 (from CRAN) [recommended: CRAN]
#> ✔ medrobust 0.4.4 (from GitHub) [recommended: GitHub]
#> ✔ medsim 0.6.0 (from GitHub) [recommended: GitHub]
#> ✖ missingmed (not installed) [recommended: GitHub]
#> Install: `pak::pak("Data-Wise/missingmed")`
#> ────────────────────────────────────────────────────────────────────────────────
#> 
#> ── Install sources ──
#> 
#> Installed members come from their recommended source.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
#> ── Checks ──
#> 
#> ✔ All installed members can be loaded
#> ✔ medfit 0.18.0 meets the minimum 0.5.0
#> ✔ RMediation 1.6.1 meets the minimum 1.5.0
#> ✔ Installed members come from their recommended source
#> ! OpenMx is not installed; RMediation::mbco() will not work
#> Fix: install.packages("OpenMx")
#> ! 1 function exported by more than one member: extract_mediation
#> Fix: Call the version you want with package::function()
```
