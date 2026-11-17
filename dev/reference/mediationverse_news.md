# Recent News from the mediationverse Packages

Collects the latest NEWS entries of each installed mediationverse
package in one place, so a change in any member is easy to spot. Prints
the entries and invisibly returns them.

## Usage

``` r
mediationverse_news(n = 3L, include_self = FALSE)
```

## Arguments

- n:

  Number of most recent released versions to show per package: a single
  whole number \>= 1. Default is `3`.

- include_self:

  Logical. Include mediationverse itself? Default is `FALSE`, matching
  [`mediationverse_citations()`](https://Data-Wise.github.io/mediationverse/dev/reference/mediationverse_citations.md).

## Value

Invisibly, a long data frame of class `mediationverse_news` with one row
per NEWS bullet and columns `package`, `version`, `date`, `category` and
`text`. Attributes record the packages that are `not_installed`, the
installed packages that cannot be loaded (`broken`), and the installed
packages with `no_news`.

## Details

`n` counts released versions, not bullets. Versions are ordered
numerically (0.10.0 is newer than 0.9.0); headings that are not version
numbers, such as "development version", are ignored. A package with no
usable NEWS is listed in a note and never aborts the call.

## Examples

``` r
mediationverse_news()
#> 
#> ── mediationverse news ─────────────────────────────────────────────────────────
#> ℹ No NEWS available for: medfit, probmed, RMediation, medrobust, and medsim
#> ℹ Not installed: missingmed
mediationverse_news(n = 1)
#> 
#> ── mediationverse news ─────────────────────────────────────────────────────────
#> ℹ No NEWS available for: medfit, probmed, RMediation, medrobust, and medsim
#> ℹ Not installed: missingmed
```
