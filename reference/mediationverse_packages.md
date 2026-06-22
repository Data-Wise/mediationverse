# List mediationverse Packages

Lists all core packages in the mediationverse ecosystem along with their
installation status and versions.

## Usage

``` r
mediationverse_packages(include_self = TRUE)
```

## Arguments

- include_self:

  Logical. Include mediationverse itself in the list? Default is TRUE.

## Value

A data frame with columns:

- `package`: Package name

- `installed`: Logical, whether package is installed

- `version`: Package version (NA if not installed)

- `attached`: Logical, whether package is currently attached

## Examples

``` r
mediationverse_packages()
#> 
#> ── mediationverse packages ─────────────────────────────────────────────────────
#> ✔ mediationverse 0.1.0 (attached)
#> ✔ medfit 0.3.0 (attached)
#> ✔ probmed 0.3.0
#> ✔ RMediation 1.5.0
#> ✔ medrobust 0.4.0
#> ✔ medsim 0.3.1
```
