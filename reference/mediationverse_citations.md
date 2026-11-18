# Cite the mediationverse Packages

Collects the citation of each installed mediationverse package in one
place, so analyses can cite every package they used. Prints the
citations and invisibly returns them.

## Usage

``` r
mediationverse_citations(style = c("text", "bibtex"), include_self = FALSE)
```

## Arguments

- style:

  Output style: `"text"` (human-readable, the default) or `"bibtex"`.

- include_self:

  Logical. Include mediationverse itself? Default is `FALSE`: the
  installed copy of the meta-package can be stale, and most analyses
  cite the member packages they used.

## Value

Invisibly, a named list of class `mediationverse_citations` with one
citation object per installed package that provides one. Attributes
record the `style`, the packages that are `not_installed`, and the
installed packages with `no_citation`.

## Details

Packages that are not installed are listed in a note. A package whose
citation is empty or cannot be built is listed as having no citation
available; it never aborts the call. Packages installed from source
without a `CITATION` file get an auto-generated citation that can embed
a commit hash, which is noted in the output.

## Examples

``` r
mediationverse_citations()
#> 
#> ── mediationverse citations ────────────────────────────────────────────────────
#> 
#> ── medfit ──
#> 
#> Tofighi D (2026). _medfit: Infrastructure for Mediation Model Fitting
#> and Extraction_. R package version 0.19.0,
#> <https://data-wise.github.io/medfit/>.
#> 
#> MacKinnon D, Lockwood C, Williams J (2004). “Confidence Limits for the
#> Indirect Effect: Distribution of the Product and Resampling Methods.”
#> _Multivariate Behavioral Research_, *39*(1), 99-128.
#> doi:10.1207/s15327906mbr3901_4
#> <https://doi.org/10.1207/s15327906mbr3901_4>.
#> 
#> Preacher K, Hayes A (2008). “Asymptotic and resampling strategies for
#> assessing and comparing indirect effects in multiple mediator models.”
#> _Behavior Research Methods_, *40*(3), 879-891. doi:10.3758/brm.40.3.879
#> <https://doi.org/10.3758/brm.40.3.879>.
#> 
#> Tofighi D, MacKinnon D (2011). “RMediation: An R package for mediation
#> analysis confidence intervals.” _Behavior Research Methods_, *43*(3),
#> 692-700. doi:10.3758/s13428-011-0076-x
#> <https://doi.org/10.3758/s13428-011-0076-x>.
#> 
#> VanderWeele T (2014). “A Unification of Mediation and Interaction: A
#> Four-Way Decomposition.” _Epidemiology_, *25*(5), 749-761.
#> doi:10.1097/EDE.0000000000000121
#> <https://doi.org/10.1097/EDE.0000000000000121>.
#> ── probmed ──
#> 
#> Tofighi D (2026). _probmed: Probabilistic Effect Sizes for Causal
#> Mediation Analysis_. R package version 0.4.1, commit
#> ab411df7f083e169dd4b56f264e867e4fd51e1c4,
#> <https://github.com/Data-Wise/probmed>.
#> ── medrobust ──
#> 
#> Tofighi D (2025). _medrobust: Robust Causal Mediation Analysis Under
#> Differential Misclassification_. R package version 0.4.4,
#> <https://github.com/data-wise/medrobust>.
#> 
#> Tofighi D (2025). “Partial Identification of Causal Mediation Effects
#> Under Differential Misclassification.” _Biostatistics_, *XX*, XXX-XXX.
#> ── medsim ──
#> 
#> Tofighi D (2026). _medsim: Simulation Infrastructure for Mediation
#> Analysis_. R package version 0.6.0, commit
#> 0caced58c78b72e5d47c68c1261709ec974e219a,
#> <https://github.com/Data-Wise/medsim>.
#> ℹ No citation available for: RMediation
#> ℹ Not installed: missingmed
#> ℹ Some citations are auto-generated from a source install and embed a commit hash.
mediationverse_citations(style = "bibtex")
#> 
#> ── mediationverse citations ────────────────────────────────────────────────────
#> 
#> ── medfit ──
#> 
#> @Manual{,
#>   title = {{medfit}: Infrastructure for Mediation Model Fitting and Extraction},
#>   author = {Davood Tofighi},
#>   year = {2026},
#>   note = {R package version 0.19.0},
#>   url = {https://data-wise.github.io/medfit/},
#> }
#> 
#> @Article{,
#>   title = {Confidence Limits for the Indirect Effect: Distribution of the Product and Resampling Methods},
#>   author = {David P. MacKinnon and Chondra M. Lockwood and Jason Williams},
#>   journal = {Multivariate Behavioral Research},
#>   year = {2004},
#>   volume = {39},
#>   number = {1},
#>   pages = {99--128},
#>   doi = {10.1207/s15327906mbr3901_4},
#> }
#> 
#> @Article{,
#>   title = {Asymptotic and resampling strategies for assessing and comparing indirect effects in multiple mediator models},
#>   author = {Kristopher J. Preacher and Andrew F. Hayes},
#>   journal = {Behavior Research Methods},
#>   year = {2008},
#>   volume = {40},
#>   number = {3},
#>   pages = {879--891},
#>   doi = {10.3758/brm.40.3.879},
#> }
#> 
#> @Article{,
#>   title = {{RMediation}: An {R} package for mediation analysis confidence intervals},
#>   author = {Davood Tofighi and David P. MacKinnon},
#>   journal = {Behavior Research Methods},
#>   year = {2011},
#>   volume = {43},
#>   number = {3},
#>   pages = {692--700},
#>   doi = {10.3758/s13428-011-0076-x},
#> }
#> 
#> @Article{,
#>   title = {A Unification of Mediation and Interaction: A Four-Way Decomposition},
#>   author = {Tyler J. VanderWeele},
#>   journal = {Epidemiology},
#>   year = {2014},
#>   volume = {25},
#>   number = {5},
#>   pages = {749--761},
#>   doi = {10.1097/EDE.0000000000000121},
#> }
#> ── probmed ──
#> 
#> @Manual{,
#>   title = {probmed: Probabilistic Effect Sizes for Causal Mediation Analysis},
#>   author = {Davood Tofighi},
#>   year = {2026},
#>   note = {R package version 0.4.1, commit ab411df7f083e169dd4b56f264e867e4fd51e1c4},
#>   url = {https://github.com/Data-Wise/probmed},
#> }
#> ── medrobust ──
#> 
#> @Manual{,
#>   title = {medrobust: Robust Causal Mediation Analysis Under Differential Misclassification},
#>   author = {Davood Tofighi},
#>   year = {2025},
#>   note = {R package version 0.4.4},
#>   url = {https://github.com/data-wise/medrobust},
#> }
#> 
#> @Article{,
#>   title = {Partial Identification of Causal Mediation Effects Under Differential Misclassification},
#>   author = {Davood Tofighi},
#>   journal = {Biostatistics},
#>   year = {2025},
#>   volume = {XX},
#>   pages = {XXX--XXX},
#> }
#> ── medsim ──
#> 
#> @Manual{,
#>   title = {medsim: Simulation Infrastructure for Mediation Analysis},
#>   author = {Davood Tofighi},
#>   year = {2026},
#>   note = {R package version 0.6.0, commit 0caced58c78b72e5d47c68c1261709ec974e219a},
#>   url = {https://github.com/Data-Wise/medsim},
#> }
#> ℹ No citation available for: RMediation
#> ℹ Not installed: missingmed
#> ℹ Some citations are auto-generated from a source install and embed a commit hash.
```
