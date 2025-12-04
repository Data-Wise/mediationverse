# Update mediationverse Packages

Updates all mediationverse packages to their latest versions from GitHub
or CRAN.

## Usage

``` r
mediationverse_update(packages = NULL, ...)
```

## Arguments

- packages:

  Character vector of package names to update. Default is all core
  packages.

- ...:

  Additional arguments passed to the installation function.

## Value

Invisibly returns a character vector of updated package names.

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

- **medfit**: GitHub (data-wise/medfit)

- **probmed**: GitHub (data-wise/probmed)

- **RMediation**: CRAN

- **medrobust**: GitHub (data-wise/medrobust)

- **medsim**: GitHub (data-wise/medsim)

## Examples

``` r
if (FALSE) { # \dontrun{
# Update all packages
mediationverse_update()

# Update specific packages
mediationverse_update(c("medfit", "probmed"))
} # }
```
