# Show mediationverse Conflicts

Identifies functions that are exported by multiple mediationverse
packages, which could lead to masking issues.

## Usage

``` r
mediationverse_conflicts(only_loaded = TRUE)
```

## Arguments

- only_loaded:

  Logical. Only check currently loaded packages? Default is TRUE.

## Value

A data frame with columns:

- `function_name`: Name of the conflicting function

- `packages`: Character vector of packages exporting this function

- `winner`: The package whose version will be used (last loaded)

## Details

When multiple packages export a function with the same name, R uses the
version from the package that was loaded last. This function helps
identify such conflicts so you can use explicit namespacing (e.g.,
[`medfit::extract_mediation()`](https://rdrr.io/pkg/medfit/man/extract_mediation.html))
when needed.

## Examples

``` r
if (FALSE) { # \dontrun{
# Show conflicts among loaded mediationverse packages
mediationverse_conflicts()
} # }
```
