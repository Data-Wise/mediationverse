# Changelog

## mediationverse 0.5.0

Feature release: `sitrep()` can now check that the installed members
still work together, not only that they are installed and current. The
check is opt-in because it runs a small real analysis. Distributed
through GitHub and r-universe; not a CRAN release.

### New features

- `mediationverse_sitrep(contracts = TRUE)` checks that the installed
  members still work together. It fits a small simulated analysis with
  [`medfit::med()`](https://data-wise.github.io/medfit/reference/med.html)
  and hands the fit to
  [`RMediation::ci_mediation_data()`](https://data-wise.github.io/rmediation/reference/ci_mediation_data.html)
  and
  [`probmed::pmed()`](https://data-wise.github.io/probmed/reference/pmed.html),
  adding a `contract:RMediation` and a `contract:probmed` row to the
  checks (`"fail"` with the error when a hand-off breaks). It runs real
  model code, so it is opt-in; it leaves your random-number state
  untouched, implies the checks report, and skips members that are not
  installed.

### Documentation

- New article “A First Analysis in Four Calls”: simulate,
  [`medfit::med()`](https://data-wise.github.io/medfit/reference/med.html),
  an `RMediation` interval and a `probmed` effect size on one fitted
  object. Documentation only; mediationverse adds no `mediate()`
  function because
  [`medfit::med()`](https://data-wise.github.io/medfit/reference/med.html)
  already is that entry point.

## mediationverse 0.4.0

Feature release: `sitrep()` and
[`mediationverse_update()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_update.md)
can now tell which installed members are behind the newest version on
their recommended source. The lookups are opt-in; nothing contacts the
network by default. Distributed through GitHub and r-universe; not a
CRAN release.

### New features

- `mediationverse_sitrep(updates = TRUE)` looks up the newest version of
  each installed member on its recommended source (CRAN for
  CRAN-recommended members, the Data-Wise r-universe for
  GitHub-recommended ones) and adds `latest` and `outdated` columns, an
  “Updates” section and a `-> x available` note on each outdated line.
  It is opt-in: the default makes no network requests, and a failed
  lookup is reported as “Could not check”, never an error. With
  `checks = TRUE` it also adds an `updates` check (a warning, never a
  failure).
- [`mediationverse_update()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_update.md)
  gains `only_outdated` (update only members that are outdated or not
  installed) and `dry_run` (print what would be installed and stop).
  Default behavior is unchanged.

## mediationverse 0.3.0

Feature release: `sitrep()` detects where each member was actually
installed from, and three session helpers arrive:
[`mediationverse_news()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_news.md),
[`mediationverse_attach_all()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_attach_all.md)
and the `mediationverse.quiet` option. Distributed through GitHub and
r-universe; not a CRAN release.

### New features

- [`mediationverse_sitrep()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_sitrep.md)
  now detects where each installed member actually came from (`CRAN`,
  `GitHub`, `r-universe`, `local`, `base` or `other`, read from the
  installed `DESCRIPTION`) and returns it as a new `installed_from`
  column. The `source` column is unchanged: it is still the recommended
  source from the registry. The report prints both, and
  `sitrep(checks = TRUE)` gains a `source` check that warns when a
  member was installed from somewhere other than its recommended source
  (a `local` or `load_all()` install is not flagged).
- The sitrep “CRAN status” section, which hard-coded package versions
  and claims about CRAN, is replaced by an “Install sources” section
  built from the detected provenance, so it no longer goes stale.
- [`mediationverse_news()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_news.md)
  collects the latest NEWS of each installed member, by released version
  rather than by bullet (`n = 3` versions by default). Versions are
  ordered numerically, headings that are not versions are ignored, and a
  package with no NEWS is listed instead of aborting.
- [`mediationverse_attach_all()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_attach_all.md)
  attaches every installed core member in one call and reports a status
  per package (attached, already attached, not installed, failed to
  load).
  [`library(mediationverse)`](https://Data-Wise.github.io/mediationverse/)
  still attaches only medfit.
- The new `mediationverse.quiet` option
  (`options(mediationverse.quiet = TRUE)`) suppresses the banner printed
  by
  [`library(mediationverse)`](https://Data-Wise.github.io/mediationverse/).
  A failure to load medfit is still reported.

## mediationverse 0.2.0

Feature release:
[`mediationverse_citations()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_citations.md)
collects the citations of the ecosystem packages,
[`mediationverse_sitrep()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_sitrep.md)
gains opt-in environment checks, and the member list now lives in one
internal registry. Distributed through GitHub and r-universe; not a CRAN
release.

### New features

- [`mediationverse_citations()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_citations.md)
  collects the citation of each installed ecosystem package, as `"text"`
  or `"bibtex"`. Empty or failing citations are reported instead of
  aborting, and `include_self = FALSE` by default because the installed
  meta-package copy can be stale.
- `mediationverse_sitrep(checks = TRUE)` adds opt-in environment checks:
  installed members against the minimum versions the ecosystem requires
  (medfit older than 0.5.0, such as CRAN’s 0.3.2, fails because it
  predates result-changing fixes), the optional OpenMx dependency
  (reported as available only when OpenMx meets RMediation’s declared
  minimum, 2.13, and RMediation meets its own minimum and exports
  [`mbco()`](https://data-wise.github.io/rmediation/reference/mbco.html)),
  and function conflicts among installed members (a package whose
  exports cannot be read, or an OpenMx whose version cannot be read,
  makes its check warn instead of pass; an installed member whose
  namespace fails to load, for example because of a broken dependency,
  fails a separate `load` check and is reported as uninspected rather
  than silently skipped). The results are attached to the returned data
  frame as the `"checks"` attribute. The default report is unchanged
  apart from a one-line hint.

### Bug fixes

- The README Quick Start now installs RMediation explicitly; it is only
  in `Suggests`, so
  [`library(RMediation)`](https://data-wise.github.io/rmediation/)
  failed on a fresh install.
- mediationverse now requires `medfit (>= 0.5.0)` and lists
  `Data-Wise/medfit` in `Remotes:`. Before, `medfit (>= 0.2.0)` was
  satisfied by CRAN’s 0.3.2, which predates two result-changing fixes in
  0.5.0, so a plain install (or an existing medfit 0.3.2) kept the
  affected version. The higher floor makes every install path upgrade
  medfit, and `pak` resolves it from GitHub through `Remotes:` (checked
  with
  [`pak::pkg_deps()`](https://pak.r-lib.org/reference/pkg_deps.html):
  CRAN 0.3.2 before, GitHub after). Because CRAN’s medfit is below
  0.5.0, a CRAN release of mediationverse needs medfit \>= 0.5.0 on CRAN
  first, and, like the other `Remotes:` entries, the medfit entry must
  be dropped before a CRAN submission. The old note that probmed pins
  `medfit@v0.3.0` no longer holds: probmed 0.4.1 and missingmed 0.10.0
  resolve together, so the getting-started article installs the sibling
  packages in one call.
- [`mediationverse_sitrep()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_sitrep.md)
  now labels the install source as *recommended* and documents it as
  such; it was never detected from the installed copy.
- [`mediationverse_conflicts()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_conflicts.md)
  no longer reports S4 method-table internals (`.__T__*`) as conflicting
  functions. It also warns that the result is incomplete when a
  package’s exports cannot be read or an installed member fails to load,
  instead of reporting “No conflicts found”.
- [`mediationverse_sitrep()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_sitrep.md)
  and
  [`mediationverse_packages()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_packages.md)
  no longer abort when an installed package’s version cannot be read;
  the version shows as unknown and `sitrep(checks = TRUE)` flags it.

### Internal

- A single internal registry now defines the ecosystem members,
  repositories, recommended sources and minimum versions;
  [`mediationverse_packages()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_packages.md),
  `_conflicts()`, `_sitrep()` and `_update()` all read it.

## mediationverse 0.1.1

Maintenance release: `missingmed` joins the core ecosystem, stale CRAN
claims and dead links are corrected, and the pkgdown site no longer
publishes `dev` over the release site.

### New features

- `missingmed` (mediation analysis with multiple imputation and IPW for
  missing data) joins the core ecosystem:
  [`mediationverse_packages()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_packages.md),
  [`mediationverse_sitrep()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_sitrep.md),
  [`mediationverse_conflicts()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_conflicts.md)
  and
  [`mediationverse_update()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_update.md)
  now include it. It is not attached by
  [`library()`](https://rdrr.io/r/base/library.html) (selective loading
  is unchanged). It is deliberately not in `Remotes:` or `Suggests:`:
  probmed pins `medfit@v0.3.0`, which conflicts with missingmed’s
  `medfit (>= 0.3.1)` and makes dependency resolution fail.

### Bug fixes

- [`mediationverse_sitrep()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_sitrep.md)
  and
  [`mediationverse_update()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_update.md)
  no longer say CRAN has medfit 0.2.1 (CRAN has 0.3.2) or RMediation
  1.5.0 (CRAN has 1.6.1). medfit stays sourced from GitHub because CRAN
  0.3.2 predates two result-changing fixes in medfit 0.5.0 (serial
  `te()`/`pm()` and `confint(parm = "paths")`).
- The 0.1.0 entry below claimed `Data-Wise/medfit` was added to
  `Remotes:`; it never was (medfit is in `Imports:`). Corrected there.
- `pkgdown` no longer publishes internal planning documents or
  `CLAUDE.md`.
- Docs: removed a stale “Planned” entry that listed missingmed as having
  no repository; fixed the RMediation site link (`/rmediation/`, the URL
  is case-sensitive); replaced dead GitHub Discussions links with
  Issues; refreshed example output and the medfit citation (CRAN 0.3.2).
- The pkgdown site no longer publishes `dev` over the release site.
  `dev` carried the release version (`0.1.0`), so pkgdown’s auto mode
  treated every `dev` push as a release and deployed it to the site
  root. `dev` now carries a `.9000` version, so development builds go to
  `/dev/` and only `main` updates the root.
- Retired the altdoc site generator (workflow, `altdoc/` folder,
  `Suggests: altdoc`). It deployed to the same `gh-pages` branch as
  pkgdown on every `main` push, so the last workflow to finish decided
  which site was live.
- Removed tracked junk: a vim swap file (`._pkgdown.yml.swp`) and four
  `gemini-*.toml` command files left over from the removed Gemini review
  bot.

## mediationverse 0.1.0

### Bug fixes

- [`mediationverse_update()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_update.md)
  /
  [`mediationverse_sitrep()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_sitrep.md):
  keep `medfit` sourced from **GitHub** (`data-wise/medfit`), reverting
  the 2026-06-19 reclassification to `cran_pkgs`. CRAN serves only
  medfit 0.2.1, but the ecosystem requires medfit \>= 0.3.0 (probmed,
  missingmed) — sourcing it from CRAN resolves a version too old for
  those packages. `RMediation` remains the only CRAN-sourced core
  package.
- [`mediationverse_update()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_update.md)
  installs medfit from GitHub so installs resolve a medfit that carries
  the ecosystem’s fixes (`DESCRIPTION` lists it in `Imports:` only).
- README + vignettes: corrected example calls to use real sibling
  exports
  ([`pmed()`](https://data-wise.github.io/probmed/reference/pmed.html),
  [`bound_ne()`](https://data-wise.github.io/medrobust/reference/bound_ne.html),
  [`falsification_summary()`](https://data-wise.github.io/medrobust/reference/falsification_summary.html),
  [`medsim_run()`](https://data-wise.github.io/medsim/reference/medsim_run.html))
  in place of functions that do not exist in those packages.
- README: unified `pak::pak("Data-Wise/mediationverse")` casing in the
  Quick Start block to match the Installation section.
- Fixed badge URLs in README.md to use correct GitHub organization case
  (`Data-Wise` instead of `data-wise`). Updated workflow badges and
  ecosystem package table for consistency.
- Fixed pkgdown workflow failure caused by version constraint on
  RMediation in DESCRIPTION. Removed `(>= 1.4.0)` constraint as it
  conflicted with pak dependency resolution in CI environments.
- Fixed documentation typo in
  [`mediationverse_packages()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_packages.md)
  where the `@return` section had a missing closing parenthesis in the
  `version` field description (R/packages.R:13).

### Breaking changes

- **Selective loading**: mediationverse now loads only `medfit`
  (foundation package) by default. Other packages must be loaded
  explicitly with [`library()`](https://rdrr.io/r/base/library.html).

  ``` r

  # OLD behavior (v0.0.x)
  library(mediationverse)  # Loaded all 5 packages

  # NEW behavior
  library(mediationverse)  # Loads only medfit
  library(probmed)         # Load explicitly as needed
  library(RMediation)      # Load explicitly as needed
  ```

  New startup message shows which packages are available but not yet
  loaded.

### Documentation

- Added comprehensive ecosystem architecture and data flow diagrams to
  README.
- Updated all vignettes to demonstrate selective loading pattern:
  - `getting-started.qmd`: selective loading explanation and examples.
  - `mediationverse-workflow.qmd`: complete workflow showing explicit
    package loading.
- Added `SELECTIVE-LOADING-TEST.md` with comprehensive test results.

### Infrastructure

- `R/attach.R`: refactored to load only medfit by default.
- `R/zzz.R`: updated `.onAttach()` with informative startup message.
- Optimized R-CMD-check workflow: reduced from 5 to 3 platforms (macOS,
  Windows, Ubuntu release). Check workflows now complete in ~3 minutes
  (~50% faster).
- Added `--ignore-vignettes` flag to skip vignette validation during CI
  checks.
- Updated favicons; added Gemini AI workflows for code review and issue
  triage.
- `.Rbuildignore`: added `^CLAUDE\.md$` and `^STATUS\.md$`.
- `.gitignore`: added `CLAUDE.local.md`, `*.Rcheck/`, `*.tar.gz`.
- Aligned with medfit COORDINATION-BRAINSTORM.md (Option 2 selective
  loading strategy).

## mediationverse 0.0.0.9000

### New features

- [`mediationverse_packages()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_packages.md)
  — list installed ecosystem packages with versions.
- [`mediationverse_update()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_update.md)
  — update all ecosystem packages from GitHub/CRAN.
- [`mediationverse_conflicts()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_conflicts.md)
  — detect and display function name conflicts.
- Startup message displays attached packages when loading
  mediationverse.

### Ecosystem

The mediationverse meta-package provides unified access to:

- **medfit** — infrastructure (S7 classes, model fitting, extraction,
  bootstrap).
- **probmed** — probabilistic effect size (P_med).
- **RMediation** — confidence intervals (Distribution of Product, MBCO).
- **medrobust** — sensitivity analysis (bounds, falsification).
- **medsim** — simulation infrastructure.

### Infrastructure

- pkgdown website with standardized ecosystem theme.
- README with installation and usage instructions.
- Function documentation for all exports.
- GitHub Actions for R CMD check and pkgdown deployment.
- Standardized package structure following tidyverse patterns.
