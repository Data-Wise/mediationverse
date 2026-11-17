# Attach All mediationverse Packages

[`library(mediationverse)`](https://Data-Wise.github.io/mediationverse/)
attaches only medfit (selective loading). This attaches every installed
core member in one call, which suits teaching and scripts that use the
whole ecosystem.

## Usage

``` r
mediationverse_attach_all()
```

## Value

Invisibly, a named character vector with one status per core package:
`"attached"`, `"already attached"`, `"not installed"` or
`"failed to load"`. A package that cannot be attached never aborts the
call.

## Details

Attaching several packages can mask functions. Run
[`mediationverse_conflicts()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_conflicts.md)
afterwards to see which.

## Examples

``` r
if (FALSE) { # \dontrun{
mediationverse_attach_all()
} # }
```
