# Update mediationverse Packages

Updates all mediationverse packages to their latest versions from GitHub
or CRAN.

## Usage

``` r
mediationverse_update(
  packages = NULL,
  ...,
  only_outdated = FALSE,
  dry_run = FALSE
)
```

## Arguments

- packages:

  Character vector of package names to update. Default is all core
  packages.

- ...:

  Additional arguments passed to the installation function.

- only_outdated:

  Logical. If `TRUE`, update only members whose installed version is
  older than the newest on their recommended source, plus members that
  are not installed. A member whose newest version cannot be determined
  (for example offline) is kept. This makes network requests to look up
  the newest versions. Default `FALSE`.

- dry_run:

  Logical. If `TRUE`, print what would be installed and return it
  without installing anything. Default `FALSE`.

## Value

Invisibly returns a character vector of updated package names (with
`dry_run = TRUE`, the names that would be updated).

## Details

This function uses
[`pak::pak()`](https://pak.r-lib.org/reference/pak.html) if available
(recommended), otherwise falls back to
[`remotes::install_github()`](https://remotes.r-lib.org/reference/install_github.html)
for GitHub packages and
[`utils::install.packages()`](https://rdrr.io/r/utils/install.packages.html)
for CRAN packages.

Package sources:

- **mediationverse**: GitHub (data-wise/mediationverse)

- **medfit**: GitHub (data-wise/medfit) — CRAN has 0.3.2, which predates
  two result-changing fixes in 0.5.0 (serial `te()`/`pm()` and
  `confint(parm = "paths")`)

- **probmed**: GitHub (data-wise/probmed)

- **RMediation**: CRAN

- **medrobust**: GitHub (data-wise/medrobust)

- **medsim**: GitHub (data-wise/medsim)

- **missingmed**: GitHub (data-wise/missingmed)

## Examples

``` r
if (FALSE) { # \dontrun{
# Update all packages
mediationverse_update()

# Update specific packages
mediationverse_update(c("medfit", "probmed"))

# Only what is outdated, and preview first
mediationverse_update(only_outdated = TRUE, dry_run = TRUE)
} # }
```
