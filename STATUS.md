# Mediationverse Ecosystem Status

> **The live CI/CD badge wall** for the ecosystem. This page is intentionally a
> badge dashboard — per-package status, blockers, dependency order, and CRAN
> sequence are **not** hand-maintained here (they drift).

**Last Updated**: 2026-06-10

> 🩺 **Live health:** `cd ~/projects/r-packages && /rforge:status` (or `:thorough`).
> Per-package status lives in each repo's `.STATUS` file.
>
> 🗺️ **Planning & roadmap:** the ecosystem hub —
> [`mediation-planning`](https://github.com/Data-Wise/mediation-planning)
> (`PROJECT-HUB.md`, `ECOSYSTEM-MANIFEST.yaml`, `docs/ROADMAP.md`).

---

## Package Status Overview

| Package | Lifecycle | Repo Status | Build | Website | R-hub | Coverage | CRAN |
|---------|-----------|-------------|-------|---------|-------|----------|------|
| [medfit](https://github.com/data-wise/medfit) | [![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental) | [![Repo Status](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip) | [![R-CMD-check](https://github.com/data-wise/medfit/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/data-wise/medfit/actions/workflows/R-CMD-check.yaml) | [![Website Status](https://github.com/data-wise/medfit/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/data-wise/medfit/actions/workflows/pkgdown.yaml) | [![R-hub](https://github.com/data-wise/medfit/actions/workflows/rhub.yaml/badge.svg)](https://github.com/data-wise/medfit/actions/workflows/rhub.yaml) | [![Codecov](https://codecov.io/gh/data-wise/medfit/graph/badge.svg)](https://codecov.io/gh/data-wise/medfit) | Not on CRAN |
| [probmed](https://github.com/data-wise/probmed) | [![Lifecycle](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable) | [![Repo Status](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) | [![R-CMD-check](https://github.com/data-wise/probmed/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/data-wise/probmed/actions/workflows/R-CMD-check.yaml) | [![Website Status](https://github.com/data-wise/probmed/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/data-wise/probmed/actions/workflows/pkgdown.yaml) | [![R-hub](https://github.com/data-wise/probmed/actions/workflows/rhub.yaml/badge.svg)](https://github.com/data-wise/probmed/actions/workflows/rhub.yaml) | [![Codecov](https://codecov.io/gh/data-wise/probmed/graph/badge.svg)](https://codecov.io/gh/data-wise/probmed) | Not on CRAN |
| [RMediation](https://github.com/data-wise/rmediation) | [![Lifecycle](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable) | [![Repo Status](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) | [![R-CMD-check](https://github.com/data-wise/rmediation/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/data-wise/rmediation/actions/workflows/R-CMD-check.yaml) | [![Website Status](https://github.com/data-wise/rmediation/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/data-wise/rmediation/actions/workflows/pkgdown.yaml) | [![R-hub](https://github.com/data-wise/rmediation/actions/workflows/rhub.yaml/badge.svg)](https://github.com/data-wise/rmediation/actions/workflows/rhub.yaml) | [![Codecov](https://codecov.io/gh/data-wise/rmediation/graph/badge.svg)](https://codecov.io/gh/data-wise/rmediation) | [![CRAN](https://www.r-pkg.org/badges/version/RMediation)](https://CRAN.R-project.org/package=RMediation) |
| [medrobust](https://github.com/data-wise/medrobust) | [![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental) | [![Repo Status](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip) | [![R-CMD-check](https://github.com/data-wise/medrobust/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/data-wise/medrobust/actions/workflows/R-CMD-check.yaml) | [![Website Status](https://github.com/data-wise/medrobust/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/data-wise/medrobust/actions/workflows/pkgdown.yaml) | [![R-hub](https://github.com/data-wise/medrobust/actions/workflows/rhub.yaml/badge.svg)](https://github.com/data-wise/medrobust/actions/workflows/rhub.yaml) | [![Codecov](https://codecov.io/gh/data-wise/medrobust/graph/badge.svg)](https://codecov.io/gh/data-wise/medrobust) | Not on CRAN |
| [medsim](https://github.com/data-wise/medsim) | [![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental) | [![Repo Status](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip) | [![R-CMD-check](https://github.com/data-wise/medsim/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/data-wise/medsim/actions/workflows/R-CMD-check.yaml) | [![Website Status](https://github.com/data-wise/medsim/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/data-wise/medsim/actions/workflows/pkgdown.yaml) | [![R-hub](https://github.com/data-wise/medsim/actions/workflows/rhub.yaml/badge.svg)](https://github.com/data-wise/medsim/actions/workflows/rhub.yaml) | [![Codecov](https://codecov.io/gh/data-wise/medsim/graph/badge.svg)](https://codecov.io/gh/data-wise/medsim) | Not on CRAN |
| [mediationverse](https://github.com/data-wise/mediationverse) | [![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental) | [![Repo Status](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip) | [![R-CMD-check](https://github.com/data-wise/mediationverse/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/data-wise/mediationverse/actions/workflows/R-CMD-check.yaml) | [![Website Status](https://github.com/data-wise/mediationverse/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/data-wise/mediationverse/actions/workflows/pkgdown.yaml) | [![R-hub](https://github.com/data-wise/mediationverse/actions/workflows/rhub.yaml/badge.svg)](https://github.com/data-wise/mediationverse/actions/workflows/rhub.yaml) | - | Not on CRAN |

---

## Quick Links

### Package Websites
- [medfit](https://data-wise.github.io/medfit/)
- [probmed](https://data-wise.github.io/probmed/)
- [RMediation](https://data-wise.github.io/rmediation/)
- [medrobust](https://data-wise.github.io/medrobust/)
- [medsim](https://data-wise.github.io/medsim/)
- [mediationverse](https://data-wise.github.io/mediationverse/)

### GitHub Actions
- [medfit workflows](https://github.com/data-wise/medfit/actions)
- [probmed workflows](https://github.com/data-wise/probmed/actions)
- [RMediation workflows](https://github.com/data-wise/rmediation/actions)
- [medrobust workflows](https://github.com/data-wise/medrobust/actions)
- [medsim workflows](https://github.com/data-wise/medsim/actions)
- [mediationverse workflows](https://github.com/data-wise/mediationverse/actions)

### Code Coverage
- [medfit on Codecov](https://codecov.io/gh/data-wise/medfit)
- [medrobust on Codecov](https://codecov.io/gh/data-wise/medrobust)

---

## Standard Badge Template

All packages should use this badge order in their README.md:

```markdown
<!-- badges: start -->
[![Lifecycle: {status}](https://img.shields.io/badge/lifecycle-{status}-{color}.svg)](https://lifecycle.r-lib.org/articles/stages.html#{status})
[![Repo Status](https://www.repostatus.org/badges/latest/{status}.svg)](https://www.repostatus.org/#{status})
[![CRAN status](https://www.r-pkg.org/badges/version/{package})](https://CRAN.R-project.org/package={package})
[![R-CMD-check](https://github.com/data-wise/{package}/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/data-wise/{package}/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/data-wise/{package}/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/data-wise/{package}/actions/workflows/pkgdown.yaml)
[![Codecov](https://codecov.io/gh/data-wise/{package}/graph/badge.svg)](https://codecov.io/gh/data-wise/{package})
<!-- badges: end -->
```

### Lifecycle Options
- `experimental` (orange) - Under active development
- `stable` (green) - Ready for production use
- `deprecated` (orange) - No longer recommended
- `superseded` (blue) - Replaced by newer package

### Repo Status Options
- `wip` - Work in Progress
- `active` - Active development
- `inactive` - Not actively maintained
- `unsupported` - No longer supported

---

## Current Issues & Per-Package Status

Not tracked here — it drifts. Two sources of truth:

- **Live status / blockers / progress:** `cd ~/projects/r-packages && /rforge:status`
  (reads each package's `.STATUS`). For the full rollup incl. dependency order and
  CRAN sequence: `/rforge:thorough`.
- **Cross-package tasks & roadmap:** the hub —
  [`mediation-planning/TODOS.md`](https://github.com/Data-Wise/mediation-planning/blob/main/TODOS.md)
  and [`docs/ROADMAP.md`](https://github.com/Data-Wise/mediation-planning/blob/main/docs/ROADMAP.md).

---

## Monitoring Best Practices

1. **Check this page weekly** for build failures
2. **Badge colors indicate status**:
   - 🟢 Green = Passing
   - 🔴 Red = Failing
   - 🟡 Orange = Warning/In Progress
3. **Click badges** to see detailed workflow logs
4. **Priority**: Fix red badges before release
5. **Expected failures**: Some packages may fail until dependencies published

---

## Release Readiness

Per-package CRAN gate and ecosystem submission order are automated — don't track
them by hand here:

```bash
cd ~/projects/r-packages
/rforge:r:cran-prep    # per-package gate: document→lint→spell→urlcheck→test→coverage→check→revdep
/rforge:release        # dependency-ordered ecosystem CRAN submission sequence
```

---

## Contact

**Maintainer**: Davood Tofighi (dtofighi@gmail.com)
**ORCID**: [0000-0001-8523-7776](https://orcid.org/0000-0001-8523-7776)
