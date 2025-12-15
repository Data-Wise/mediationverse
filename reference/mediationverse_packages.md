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
#> ✔ mediationverse 0.0.0.9000 (attached)
#> ✔ medfit 0.1.0.9000 (attached)
#> ✔ probmed 0.0.0.9000
#> ✔ RMediation 1.3.0
#> ✔ medrobust 0.1.0.9000
#> ✔ medsim 0.0.0.9000
```
